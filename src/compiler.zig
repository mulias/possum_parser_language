const std = @import("std");
const ArrayList = std.ArrayList;
const unicode = std.unicode;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("chunk.zig").Chunk;
const ChunkError = @import("chunk.zig").ChunkError;
const Elem = @import("elem.zig").Elem;
const Location = @import("location.zig").Location;
const OpCode = @import("op_code.zig").OpCode;
const Scanner = @import("scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const WriterError = @import("writer.zig").VMWriter.Error;
const Writers = @import("writer.zig").Writers;

pub const Compiler = struct {
    vm: *VM,
    ast: Ast,
    functions: ArrayList(*Elem.Dyn.Function),
    writers: Writers,
    printBytecode: bool,

    const Error = error{
        InvalidAst,
        ChunkWriteFailure,
        MultipleMainParsers,
        UnexpectedMainParser,
        MaxFunctionArgs,
        MaxFunctionLocals,
        OutOfMemory,
        TooManyConstants,
        ShortOverflow,
        VariableNameUsedInScope,
        InvalidGlobalValue,
        InvalidGlobalParser,
        AliasCycle,
        UnknownVariable,
        UndefinedVariable,
        FunctionCallTooManyArgs,
        FunctionCallTooFewArgs,
        RangeNotSingleCodepoint,
        RangeCodepointsUnordered,
        RangeIntegersUnordered,
        RangeInvalidNumberFormat,
        RangeIntegerTooLarge,
        UnlabeledStringValue,
        UnlabeledNumberValue,
        UnlabeledBooleanValue,
        UnlabeledNullValue,
    } || WriterError;

    pub fn init(vm: *VM, ast: Ast, printBytecode: bool) !Compiler {
        const main = try Elem.Dyn.Function.create(vm, .{
            .name = try vm.strings.insert("@main"),
            .functionType = .Main,
            .arity = 0,
        });

        var functions = ArrayList(*Elem.Dyn.Function).init(vm.allocator);
        try functions.append(main);

        // Ensure that the strings table includes the placeholder var, which
        // might be used directly by the compiler.
        _ = try vm.strings.insert("_");

        return Compiler{
            .vm = vm,
            .ast = ast,
            .functions = functions,
            .writers = vm.writers,
            .printBytecode = printBytecode,
        };
    }

    pub fn deinit(self: *Compiler) void {
        self.functions.deinit();
    }

    pub fn compile(self: *Compiler) !?*Elem.Dyn.Function {
        try self.declareGlobals();
        try self.validateGlobals();
        try self.resolveGlobalAliases();
        try self.compileGlobalFunctions();
        return self.compileMain();
    }

    fn declareGlobals(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal)) |infix| {
                try self.declareGlobal(infix.left, infix.right);
            }
        }
    }

    fn validateGlobals(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal)) |infix| {
                try self.validateGlobal(infix.left);
            }
        }
    }

    fn resolveGlobalAliases(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal)) |infix| {
                try self.resolveGlobalAlias(infix.left);
            }
        }
    }

    fn compileGlobalFunctions(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal)) |infix| {
                try self.compileGlobalFunction(infix.left, infix.right);
            }
        }
    }

    fn compileMain(self: *Compiler) !?*Elem.Dyn.Function {
        var main: ?*Ast.LocNode = null;

        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal) == null) {
                if (main == null) {
                    main = root;
                } else {
                    return Error.MultipleMainParsers;
                }
            }
        }

        if (main) |main_loc_node| {
            try self.addValueLocals(main_loc_node);
            try self.writeParser(main_loc_node, false);
            try self.emitOp(.End, main_loc_node.loc);

            const main_fn = self.functions.pop();

            if (self.printBytecode) {
                try main_fn.disassemble(self.vm.*, self.writers.debug);
            }

            return main_fn;
        } else {
            return null;
        }
    }

    fn declareGlobal(self: *Compiler, head: *Ast.LocNode, body: *Ast.LocNode) !void {
        switch (head.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .CallOrDefineFunction => {
                    // A function with params
                    const name = infix.left;
                    const params = infix.right;
                    try self.declareGlobalFunction(name, params);
                },
                else => return Error.InvalidAst,
            },
            .ElemNode => |nameElem| switch (body.node) {
                .InfixNode,
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => {
                    // A function without params
                    try self.declareGlobalFunction(head, null);
                },
                .ElemNode => |bodyElem| {
                    try self.declareGlobalAlias(nameElem, bodyElem);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => return Error.InvalidAst,
        }
    }

    fn declareGlobalFunction(self: *Compiler, name: *Ast.LocNode, params: ?*Ast.LocNode) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const nameElem = name.node.asElem() orelse return Error.InvalidAst;
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name_sid = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };
        const functionType: Elem.Dyn.FunctionType = switch (nameVar) {
            .ValueVar => .NamedValue,
            .ParserVar => .NamedParser,
            else => return Error.InvalidAst,
        };

        var function = try Elem.Dyn.Function.create(self.vm, .{
            .name = name_sid,
            .functionType = functionType,
            .arity = 0,
        });

        try self.vm.globals.put(name_sid, function.dyn.elem());

        try self.functions.append(function);

        if (params) |first_param| {
            var param = first_param;

            while (true) {
                switch (param.node) {
                    .InfixNode => |infix| {
                        if (infix.infixType == .ParamsOrArgs) {
                            if (infix.left.node.asElem()) |leftElem| {
                                _ = try self.addLocal(
                                    leftElem,
                                    infix.left.loc,
                                );
                                function.arity += 1;
                            } else {
                                return Error.InvalidAst;
                            }
                        } else {
                            return Error.InvalidAst;
                        }

                        param = infix.right;
                    },
                    .ElemNode => |elem| {
                        // This is the last param
                        _ = try self.addLocal(elem, param.loc);
                        function.arity += 1;
                        break;
                    },
                    .UpperBoundedRange,
                    .LowerBoundedRange,
                    .Negation,
                    .ValueLabel,
                    => return Error.InvalidAst,
                }
            }
        }

        _ = self.functions.pop();
    }

    fn declareGlobalAlias(self: *Compiler, nameElem: Elem, bodyElem: Elem) !void {
        // Add an alias to the global namespace. Set the given body element as the alias's value.
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        try self.vm.globals.put(name, bodyElem);
    }

    fn validateGlobal(self: *Compiler, head: *Ast.LocNode) !void {
        const nameElem = switch (head.node) {
            .InfixNode => |infix| infix.left.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => return Error.InvalidAst,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;

        switch (nameVar) {
            .ValueVar => |name| switch (self.vm.globals.get(name).?) {
                .ValueVar,
                .String,
                .NumberString,
                .Boolean,
                .Null,
                => {},
                .ParserVar,
                => return Error.InvalidGlobalValue,
                .Dyn => |dyn| switch (dyn.dynType) {
                    .String,
                    .Array,
                    .Object,
                    => {},
                    .Function => {
                        if (dyn.asFunction().functionType != .NamedValue) {
                            return Error.InvalidGlobalValue;
                        }
                    },
                    .Closure => @panic("Internal Error"),
                },
                .InputSubstring,
                .Integer,
                .Float,
                .Failure,
                => @panic("Internal Error"),
            },
            .ParserVar => |name| switch (self.vm.globals.get(name).?) {
                .ParserVar,
                .String,
                .NumberString,
                => {},
                .ValueVar => return Error.InvalidGlobalParser,
                .Dyn => |dyn| switch (dyn.dynType) {
                    .String,
                    => {},
                    .Array,
                    .Object,
                    => return Error.InvalidGlobalParser,
                    .Function => {
                        if (dyn.asFunction().functionType != .NamedParser) {
                            return Error.InvalidGlobalParser;
                        }
                    },
                    .Closure => @panic("Internal Error"),
                },
                .Failure,
                .InputSubstring,
                .Boolean,
                .Integer,
                .Float,
                .Null,
                => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        }
    }

    fn resolveGlobalAlias(self: *Compiler, head: *Ast.LocNode) !void {
        const globalName = try self.getGlobalName(head);
        var aliasName = globalName;
        var value = self.vm.globals.get(aliasName);

        if (!value.?.isType(.ValueVar) and !value.?.isType(.ParserVar)) {
            return;
        }

        var path = ArrayList(StringTable.Id).init(self.vm.allocator);
        defer path.deinit();

        while (true) {
            if (value) |foundValue| {
                try path.append(aliasName);

                aliasName = switch (foundValue) {
                    .ValueVar => |name| name,
                    .ParserVar => |name| name,
                    else => {
                        try self.vm.globals.put(globalName, foundValue);
                        break;
                    },
                };

                for (path.items) |aliasVisited| {
                    if (aliasName == aliasVisited) {
                        return Error.AliasCycle;
                    }
                }

                value = self.vm.globals.get(aliasName);
            } else {
                return Error.UnknownVariable;
            }
        }
    }

    fn compileGlobalFunction(self: *Compiler, head: *Ast.LocNode, body: *Ast.LocNode) !void {
        const globalName = try self.getGlobalName(head);
        const globalVal = self.vm.globals.get(globalName).?;

        // Exit early if the node is an alias, not a function def
        if (head.node.asElem() != null and body.node.asElem() != null) {
            return;
        }

        if (globalVal.isDynType(.Function)) {
            const function = globalVal.asDyn().asFunction();

            try self.functions.append(function);

            if (function.functionType == .NamedParser) {
                try self.addValueLocals(body);
                try self.writeParser(body, true);
            } else {
                try self.addValueLocals(body);
                try self.writeValue(body, true);
            }

            try self.emitOp(.End, body.loc);

            if (self.printBytecode) {
                try function.disassemble(self.vm.*, self.writers.debug);
            }

            _ = self.functions.pop();
        }
    }

    fn getGlobalName(self: *Compiler, head: *Ast.LocNode) !StringTable.Id {
        const nameElem = switch (head.node) {
            .InfixNode => |infix| infix.left.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => return Error.InvalidAst,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar) {
            .ValueVar => |sId| sId,
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };
        return name;
    }

    fn writeParser(self: *Compiler, loc_node: *Ast.LocNode, isTailPosition: bool) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.Merge, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .StringTemplate => {
                    try self.writeStringTemplate(infix.left, infix.right, .Parser);
                },
                .Range => {
                    const low = infix.left;
                    const high = infix.right;
                    const low_elem = try getParserRangeElemNode(low);
                    const high_elem = try getParserRangeElemNode(high);

                    if (low_elem == .String and high_elem == .String) {
                        const low_str = low_elem.String;
                        const high_str = high_elem.String;
                        const low_bytes = self.vm.strings.get(low_str);
                        const high_bytes = self.vm.strings.get(high_str);
                        const low_codepoint = unicode.utf8Decode(low_bytes) catch return Error.RangeNotSingleCodepoint;
                        const high_codepoint = unicode.utf8Decode(high_bytes) catch return Error.RangeNotSingleCodepoint;

                        if (low_codepoint > high_codepoint) {
                            return Error.RangeCodepointsUnordered;
                        } else if (low_codepoint == 0 and high_codepoint == 0x10ffff) {
                            try self.emitOp(.ParseCharacter, loc);
                        } else {
                            const low_id = try self.makeConstant(low_elem);
                            const high_id = try self.makeConstant(high_elem);
                            try self.emitOp(.ParseRange, loc);
                            try self.emitByte(low_id, low.loc);
                            try self.emitByte(high_id, high.loc);
                        }
                    } else if (low_elem == .NumberString and high_elem == .NumberString) {
                        const low_ns = low_elem.NumberString;
                        const high_ns = high_elem.NumberString;

                        if (low_ns.format == .Integer and high_ns.format == .Integer) {
                            const low_int = low_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                            const high_int = high_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                            if (low_int.Integer > high_int.Integer) {
                                return Error.RangeIntegersUnordered;
                            } else {
                                const low_id = try self.makeConstant(low_int);
                                const high_id = try self.makeConstant(high_int);
                                try self.emitOp(.ParseRange, loc);
                                try self.emitByte(low_id, low.loc);
                                try self.emitByte(high_id, high.loc);
                            }
                        } else {
                            return Error.RangeInvalidNumberFormat;
                        }
                    } else {
                        return Error.InvalidAst;
                    }
                },
                .TakeLeft => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.TakeLeft, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeRight => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writeParser(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, loc);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseLoc = infix.right.loc;

                    // Get each part of `if ? then : else`
                    const if_loc_node = infix.left;
                    const then_loc_node = thenElseOp.left;
                    const else_loc_node = thenElseOp.right;

                    try self.emitOp(.SetInputMark, loc);
                    try self.writeParser(if_loc_node, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, loc);
                    try self.writeParser(then_loc_node, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseLoc);
                    try self.patchJump(ifThenJumpIndex, loc);
                    try self.writeParser(else_loc_node, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseLoc);
                },
                .ConditionalThenElse => @panic("internal error"), // always handled via ConditionalIfThen
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => {
                    try self.writeParserFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
                .ArrayHead,
                .ArrayCons,
                .ObjectCons,
                .ObjectPair,
                .NumberSubtract,
                .StringTemplateCons,
                => return Error.InvalidAst,
            },
            .UpperBoundedRange => |high| {
                const high_elem = try getParserRangeElemNode(high);
                const high_loc = high.loc;

                if (high_elem == .String) {
                    const high_str = high_elem.String;
                    const high_bytes = self.vm.strings.get(high_str);
                    const high_codepoint = unicode.utf8Decode(high_bytes) catch return Error.RangeNotSingleCodepoint;

                    if (high_codepoint == 0x10ffff) {
                        try self.emitOp(.ParseCharacter, loc);
                    } else {
                        const high_id = try self.makeConstant(high_elem);
                        try self.emitOp(.ParseUpperBoundedRange, loc);
                        try self.emitByte(high_id, high_loc);
                    }
                } else if (high_elem == .NumberString) {
                    const high_ns = high_elem.NumberString;

                    if (high_ns.format == .Integer) {
                        const high_int = high_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                        const high_id = try self.makeConstant(high_int);
                        try self.emitOp(.ParseUpperBoundedRange, loc);
                        try self.emitByte(high_id, high_loc);
                    } else {
                        return Error.RangeInvalidNumberFormat;
                    }
                } else {
                    return Error.InvalidAst;
                }
            },
            .LowerBoundedRange => |low| {
                const low_elem = try getParserRangeElemNode(low);
                const low_loc = low.loc;

                if (low_elem == .String) {
                    const low_str = low_elem.String;
                    const low_bytes = self.vm.strings.get(low_str);
                    const low_codepoint = unicode.utf8Decode(low_bytes) catch return Error.RangeNotSingleCodepoint;

                    if (low_codepoint == 0) {
                        try self.emitOp(.ParseCharacter, loc);
                    } else {
                        const low_id = try self.makeConstant(low_elem);
                        try self.emitOp(.ParseLowerBoundedRange, loc);
                        try self.emitByte(low_id, low_loc);
                    }
                } else if (low_elem == .NumberString) {
                    const low_ns = low_elem.NumberString;

                    if (low_ns.format == .Integer) {
                        const low_int = low_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                        const low_id = try self.makeConstant(low_int);
                        try self.emitOp(.ParseLowerBoundedRange, loc);
                        try self.emitByte(low_id, low_loc);
                    } else {
                        return Error.RangeInvalidNumberFormat;
                    }
                } else {
                    return Error.InvalidAst;
                }
            },
            .ElemNode => try self.writeParserElem(loc_node),
            .Negation,
            .ValueLabel,
            => return Error.InvalidAst,
        }
    }

    fn getParserRangeElemNode(loc_node: *Ast.LocNode) !Elem {
        switch (loc_node.node) {
            .ElemNode => |elem| return elem,
            .Negation => |inner| {
                if (inner.node.asElem()) |elem| {
                    const negated = Elem.negateNumber(elem) catch |err| switch (err) {
                        error.ExpectedNumber => return Error.InvalidAst,
                    };
                    return negated;
                } else {
                    return Error.InvalidAst;
                }
            },
            else => return Error.InvalidAst,
        }
    }

    fn writeParserFunctionCall(self: *Compiler, function_loc_node: *Ast.LocNode, args_loc_node: *Ast.LocNode, isTailPosition: bool) !void {
        const functionElem = function_loc_node.node.asElem() orelse @panic("internal error");
        const functionLoc = function_loc_node.loc;

        const functionName = switch (functionElem) {
            .ParserVar => |sId| sId,
            .Boolean => |b| try self.vm.strings.insert(if (b) "true" else "false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.Dyn.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, functionLoc);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, functionLoc);
            } else {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(functionName)});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeParserFunctionArguments(args_loc_node, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, functionLoc);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, functionLoc);
        }
    }

    fn writeParserElem(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const loc = loc_node.loc;

        switch (loc_node.node) {
            .ElemNode => |elem| {
                switch (elem) {
                    .ParserVar => {
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .ValueVar => {
                        try self.printError("Variable is only valid as a pattern or value", loc);
                        return Error.InvalidAst;
                    },
                    .String,
                    .NumberString,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .Boolean => {
                        // In this context `true`/`false` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .Null => {
                        // In this context `null` could be a zero-arg function call
                        try self.writeGetVar(elem, loc, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, loc);
                    },
                    .Failure,
                    .Integer,
                    .Float,
                    .InputSubstring,
                    .Dyn,
                    => @panic("Internal Error"),
                }
            },
            .InfixNode,
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("Internal Error"),
        }
    }

    fn writeGetVar(self: *Compiler, elem: Elem, loc: Location, context: enum { Parser, Pattern, Value }) !void {
        const varName = switch (elem) {
            .ParserVar => |sId| sId,
            .ValueVar => |sId| sId,
            .Boolean => |b| try self.vm.strings.insert(if (b) "true" else "false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        if (self.localSlot(varName)) |slot| {
            if (context == .Pattern) {
                try self.emitUnaryOp(.GetLocal, slot, loc);
            } else {
                try self.emitUnaryOp(.GetBoundLocal, slot, loc);
            }
        } else {
            if (self.vm.globals.get(varName)) |globalElem| {
                const constId = try self.makeConstant(globalElem);
                try self.emitUnaryOp(.GetConstant, constId, loc);
            } else {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(varName)});
                return Error.UndefinedVariable;
            }
        }
    }

    fn elemToVar(self: *Compiler, elem: Elem) !?Elem {
        return switch (elem) {
            .ParserVar,
            .ValueVar,
            => elem,
            .Boolean => |b| Elem.parserVar(try self.vm.strings.insert(if (b) "true" else "false")),
            .Null => Elem.parserVar(try self.vm.strings.insert("null")),
            else => null,
        };
    }

    const ArgType = enum { Parser, Value, Unspecified };

    fn writeParserFunctionArguments(self: *Compiler, first_arg: *Ast.LocNode, function: ?*Elem.Dyn.Function) Error!u8 {
        var argCount: u8 = 0;
        var arg = first_arg;
        var argType: ArgType = .Unspecified;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                try self.printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    arg.loc,
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (function) |f| {
                if (f.arity < argCount) return Error.FunctionCallTooManyArgs;

                const argPos = argCount - 1;
                switch (f.localVar(argPos)) {
                    .ParserVar => argType = .Parser,
                    .ValueVar => argType = .Value,
                }
            } else {
                argType = .Unspecified;
            }

            if (arg.node.asInfixOfType(.ParamsOrArgs)) |infix| {
                try self.writeParserFunctionArgument(infix.left, argType);
                arg = infix.right;
            } else {
                // This is the last arg
                try self.writeParserFunctionArgument(arg, argType);
                break;
            }
        }

        if (function) |f| {
            if (f.arity != argCount) return Error.FunctionCallTooFewArgs;
        }

        return argCount;
    }

    fn writeParserFunctionArgument(self: *Compiler, loc_node: *Ast.LocNode, argType: ArgType) !void {
        const loc = loc_node.loc;

        switch (argType) {
            .Parser => switch (loc_node.node) {
                .InfixNode,
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                => {
                    const function = try self.writeAnonymousFunction(loc_node);
                    const constId = try self.makeConstant(function.dyn.elem());
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                    try self.writeCaptureLocals(function, loc);
                },
                .ElemNode => |elem| switch (elem) {
                    .ParserVar => try self.writeGetVar(elem, loc, .Value),
                    else => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
                .ValueLabel => @panic("todo"),
            },
            .Value => try self.writeValueArgument(loc_node, false),
            .Unspecified => {
                // In this case we don't know the arg type because the function
                // will be passed in as a variable and is not yet known. Things
                // we could do:
                // - Find all places the var is assigned and monomoprphise
                // - Defer logic to runtime
                // - For each arg determine if the arg must be a parser or
                //   value. If it could be either then fail with a message
                //   asking the user to extract a variable to specify.
                @panic("todo");
            },
        }
    }

    fn writeAnonymousFunction(self: *Compiler, loc_node: *Ast.LocNode) !*Elem.Dyn.Function {
        const loc = loc_node.loc;

        const function = try Elem.Dyn.Function.createAnonParser(self.vm, .{ .arity = 0 });

        try self.functions.append(function);

        try self.addClosureLocals(loc_node);

        if (function.locals.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, loc);
        }

        try self.writeParser(loc_node, true);
        try self.emitOp(.End, loc);

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        return self.functions.pop();
    }

    fn writeCaptureLocals(self: *Compiler, targetFunction: *Elem.Dyn.Function, loc: Location) !void {
        for (self.currentFunction().locals.items, 0..) |local, fromSlot| {
            if (targetFunction.localSlot(local.name())) |toSlot| {
                try self.emitOp(.CaptureLocal, loc);
                try self.emitByte(@as(u8, @intCast(fromSlot)), loc);
                try self.emitByte(toSlot, loc);
            }
        }
    }

    fn writeDestructurePattern(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead => {
                    try self.writePatternArray(infix.left, infix.right);
                },
                .ObjectCons => {
                    try self.writePatternObject(infix.left, infix.right);
                },
                .Merge => {
                    try self.writePatternMerge(loc_node);
                },
                .NumberSubtract => {
                    @panic("TODO");
                },
                .Range => {
                    try self.writePattern(infix.left);
                    try self.writePattern(infix.right);
                    try self.emitOp(.DestructureRange, loc);
                },
                else => {
                    try self.writePattern(loc_node);
                    try self.emitOp(.Destructure, loc);
                },
            },
            .ElemNode => {
                try self.writePattern(loc_node);
                try self.emitOp(.Destructure, loc);
            },
            .UpperBoundedRange => |high_node_id| {
                const low_elem = self.placeholderVar();
                const low_id = try self.makeConstant(low_elem);
                try self.emitUnaryOp(.GetConstant, low_id, loc);
                try self.writePattern(high_node_id);
                try self.emitOp(.DestructureRange, loc);
            },
            .LowerBoundedRange => |low_node_id| {
                const high_elem = self.placeholderVar();
                try self.writePattern(low_node_id);
                const high_id = try self.makeConstant(high_elem);
                try self.emitUnaryOp(.GetConstant, high_id, loc);
                try self.emitOp(.DestructureRange, loc);
            },
            .Negation => {
                try self.writePattern(loc_node);
                try self.emitOp(.Destructure, loc);
            },
            .ValueLabel => return error.InvalidAst,
        }
    }

    fn writePattern(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead => {
                    try self.writePatternArray(infix.left, infix.right);
                },
                .ObjectCons => {
                    try self.writePatternObject(infix.left, infix.right);
                },
                .NumberSubtract,
                .StringTemplate,
                => {
                    @panic("todo");
                },
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, false);
                },
                .Merge,
                .ArrayCons,
                .ObjectPair,
                .StringTemplateCons,
                => @panic("Internal Error"),
                else => {
                    try self.printError("Invalid infix operator in pattern", loc);
                    return Error.InvalidAst;
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .ValueLabel,
            => @panic("todo"),
            .Negation => {
                if (simplifyNegatedNumberNode(loc_node)) |elem| {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                } else {
                    @panic("todo");
                }
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    try self.printError("parser is not valid in pattern", loc);
                    return Error.InvalidAst;
                },
                .ValueVar => |name| {
                    if (self.localSlot(name)) |slot| {
                        try self.emitUnaryOp(.GetLocal, slot, loc);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            try self.emitUnaryOp(.CallFunction, 0, loc);
                        }
                    } else {
                        try self.writers.err.print("{s}\n", .{self.vm.strings.get(name)});
                        return Error.UndefinedVariable;
                    }
                },
                .String,
                .NumberString,
                => {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
                .Boolean => |b| try self.emitOp(if (b) .True else .False, loc),
                .Null => {
                    try self.emitOp(.Null, loc);
                },
                .Failure,
                .Float,
                .InputSubstring,
                .Integer,
                => @panic("Internal Error"), // not produced by the parser
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Function,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
            },
        }
    }

    fn writePatternMerge(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const loc = loc_node.loc;

        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        const count = try self.writePrepareMergePattern(loc_node, 0);
        try self.emitUnaryOp(.PrepareMergePattern, count, loc);
        const failureJumpIndex = try self.emitJump(.JumpIfFailure, loc);

        try self.writeMergePattern(loc_node, &jumpList);

        const successJumpIndex = try self.emitJump(.JumpIfSuccess, loc);

        for (jumpList.items) |jumpIndex| {
            try self.patchJump(jumpIndex, loc);
        }

        try self.emitOp(.Swap, loc);
        try self.emitOp(.Pop, loc);

        try self.patchJump(failureJumpIndex, loc);
        try self.patchJump(successJumpIndex, loc);
    }

    fn writePrepareMergePattern(self: *Compiler, loc_node: *Ast.LocNode, count: u8) !u8 {
        switch (loc_node.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    const totalCount = try self.writePrepareMergePattern(infix.left, count + 1);
                    try self.writePrepareMergePatternPart(infix.right);
                    return totalCount;
                },
                else => {},
            },
            .ElemNode => {},
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
        }
        try self.writePrepareMergePatternPart(loc_node);
        return count + 1;
    }

    fn writePrepareMergePatternPart(self: *Compiler, loc_node: *Ast.LocNode) Error!void {
        switch (loc_node.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead, .ObjectCons => {
                    // At this point the array/object is empty, but in a
                    // later step we'll mutate to add elements.
                    const elem = infix.left.node.asElem() orelse @panic("Internal Error");
                    const loc = infix.left.loc;
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
                else => {
                    try self.writePattern(loc_node);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
            .ElemNode => {
                try self.writePattern(loc_node);
            },
        }
    }

    fn writeMergePattern(self: *Compiler, loc_node: *Ast.LocNode, jumpList: *ArrayList(usize)) Error!void {
        const loc = loc_node.loc;

        switch (loc_node.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writeMergePattern(infix.left, jumpList);
                    try self.writeDestructurePattern(infix.right);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.emitOp(.Pop, loc);
                    try jumpList.append(jumpIndex);
                    return;
                },
                else => {},
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
            .ElemNode => {},
        }

        try self.writeDestructurePattern(loc_node);
        const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
        try self.emitOp(.Pop, loc);
        try jumpList.append(jumpIndex);
    }

    fn addValueLocals(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| {
                try self.addValueLocals(infix.left);
                try self.addValueLocals(infix.right);
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => |inner| try self.addValueLocals(inner),
            .ElemNode => |elem| switch (elem) {
                .ValueVar => |varName| if (self.vm.globals.get(varName) == null) {
                    const newLocalId = try self.addLocalIfUndefined(elem, loc);
                    if (newLocalId) |_| {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    }
                },
                else => {},
            },
        }
    }

    fn addClosureLocals(self: *Compiler, loc_node: *Ast.LocNode) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| {
                try self.addClosureLocals(infix.left);
                try self.addClosureLocals(infix.right);
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => |inner| try self.addClosureLocals(inner),
            .ElemNode => |elem| {
                const varName = switch (elem) {
                    .ValueVar => |name| name,
                    .ParserVar => |name| name,
                    else => null,
                };

                if (varName) |name| {
                    if (self.parentFunction().localSlot(name) != null) {
                        const newLocalId = try self.addLocalIfUndefined(elem, loc);
                        if (newLocalId) |_| {
                            const constId = try self.makeConstant(elem);
                            try self.emitUnaryOp(.GetConstant, constId, loc);
                        }
                    }
                }
            },
        }
    }

    fn writeValueArgument(self: *Compiler, loc_node: *Ast.LocNode, isTailPosition: bool) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .StringTemplate => {
                    return error.UnlabeledStringValue;
                },
                .Backtrack => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, loc);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.Merge, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .NumberSubtract => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.NegateNumber, loc);
                    try self.emitOp(.Merge, loc);
                },
                .TakeLeft => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.TakeLeft, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeRight => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, loc);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseLoc = infix.right.loc;

                    // Get each part of `if ? then : else`
                    const if_loc_node = infix.left;
                    const then_loc_node = thenElseOp.left;
                    const else_loc_node = thenElseOp.right;

                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValueArgument(if_loc_node, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, loc);
                    try self.writeValueArgument(then_loc_node, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseLoc);
                    try self.patchJump(ifThenJumpIndex, loc);
                    try self.writeValueArgument(else_loc_node, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseLoc);
                },
                else => try writeValue(self, loc_node, isTailPosition),
            },
            .Negation => |inner| {
                try self.writeValueArgument(inner, false);
                try self.emitOp(.NegateNumber, loc);
            },
            .ValueLabel => |inner| {
                try self.writeValue(inner, isTailPosition);
            },
            .ElemNode => |elem| switch (elem) {
                .String => {
                    std.debug.print("{s}\n", .{self.vm.strings.get(elem.String)});
                    return error.UnlabeledStringValue;
                },
                .NumberString => {
                    std.debug.print("{s}\n", .{self.vm.strings.get(elem.NumberString.sId)});
                    return error.UnlabeledNumberValue;
                },
                .Boolean => return error.UnlabeledBooleanValue,
                .Null => return error.UnlabeledNullValue,
                else => try writeValue(self, loc_node, isTailPosition),
            },
            else => try writeValue(self, loc_node, isTailPosition),
        }
    }

    fn writeValue(self: *Compiler, loc_node: *Ast.LocNode, isTailPosition: bool) !void {
        const node = loc_node.node;
        const loc = loc_node.loc;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead => {
                    try self.writeValueArray(infix.left, infix.right);
                },
                .ObjectCons => {
                    try self.writeValueObject(infix.left, infix.right);
                },
                .StringTemplate => {
                    try self.writeStringTemplate(infix.left, infix.right, .Value);
                },
                .Backtrack => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, loc);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.Merge, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .NumberSubtract => {
                    try self.writeValue(infix.left, false);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.NegateNumber, loc);
                    try self.emitOp(.Merge, loc);
                },
                .TakeLeft => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.TakeLeft, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .TakeRight => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writeValue(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, loc);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, loc);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseLoc = infix.right.loc;

                    // Get each part of `if ? then : else`
                    const if_loc_node = infix.left;
                    const then_loc_node = thenElseOp.left;
                    const else_loc_node = thenElseOp.right;

                    try self.emitOp(.SetInputMark, loc);
                    try self.writeValue(if_loc_node, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, loc);
                    try self.writeValue(then_loc_node, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseLoc);
                    try self.patchJump(ifThenJumpIndex, loc);
                    try self.writeValue(else_loc_node, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseLoc);
                },
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .Range => {
                    try self.printError("Character and integer ranges are not valid in value", loc);
                    return Error.InvalidAst;
                },
                .ArrayCons, // handled by writeArray
                .ConditionalThenElse, // handled by ConditionalIfThen
                .DeclareGlobal, // handled by top-level compiler functions
                .ParamsOrArgs, // handled by CallOrDefineFunction
                .ObjectPair, // handled by ObjectCons
                .StringTemplateCons, // handled by StringTemplate
                => @panic("internal error"),
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            => @panic("Internal Error"),
            .Negation => |inner| {
                try self.writeValue(inner, false);
                try self.emitOp(.NegateNumber, loc);
            },
            .ValueLabel => |inner| {
                try self.writeValue(inner, isTailPosition);
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    try self.printError("Parser is not valid in value", loc);
                    return Error.InvalidAst;
                },
                .ValueVar => |name| {
                    if (self.localSlot(name)) |slot| {
                        // This local will either be a concrete value or
                        // unbound, it won't be a function. Value functions are
                        // all defined globally and called immediately. This
                        // means that if a function takes a value function as
                        // an arg then the value function will be called before
                        // the outer function, and the value used when calling
                        // the outer function will be concrete.
                        try self.emitUnaryOp(.GetBoundLocal, slot, loc);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            if (isTailPosition) {
                                try self.emitUnaryOp(.CallTailFunction, 0, loc);
                            } else {
                                try self.emitUnaryOp(.CallFunction, 0, loc);
                            }
                        }
                    } else {
                        try self.writers.err.print("{s}\n", .{self.vm.strings.get(name)});
                        return Error.UndefinedVariable;
                    }
                },
                .String,
                .NumberString,
                => {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, loc);
                },
                .Boolean => |b| try self.emitOp(if (b) .True else .False, loc),
                .Null => try self.emitOp(.Null, loc),
                .Failure,
                .InputSubstring,
                .Integer,
                .Float,
                => @panic("Internal Error"), // not produced by the parser
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Function,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, loc);
                    },
                },
            },
        }
    }

    fn writeValueFunctionCall(self: *Compiler, function_loc_node: *Ast.LocNode, args_loc_node: *Ast.LocNode, isTailPosition: bool) !void {
        const functionElem = function_loc_node.node.asElem() orelse @panic("internal error");
        const functionLoc = function_loc_node.loc;

        const functionName = switch (functionElem) {
            .ValueVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.Dyn.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, functionLoc);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, functionLoc);
            } else {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(functionName)});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(args_loc_node, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, functionLoc);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, functionLoc);
        }
    }

    fn writeValueFunctionArguments(self: *Compiler, first_arg: *Ast.LocNode, function: ?*Elem.Dyn.Function) Error!u8 {
        var argCount: u8 = 0;
        var arg = first_arg;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                try self.printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    arg.loc,
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (arg.node.asInfixOfType(.ParamsOrArgs)) |infix| {
                try self.writeValue(infix.left, false);
                arg = infix.right;
            } else {
                // This is the last arg
                try self.writeValue(arg, false);
                break;
            }
        }

        if (function) |f| {
            if (f.arity < argCount) return Error.FunctionCallTooManyArgs;
            if (f.arity > argCount) return Error.FunctionCallTooFewArgs;
        }

        return argCount;
    }

    const ArrayContext = union(enum) {
        Pattern: *ArrayList(usize),
        Value: void,

        pub fn emitPatternJumpIfFailure(self: ArrayContext, compiler: *Compiler, loc: Location) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    const index = try compiler.emitJump(.JumpIfFailure, loc);
                    try jumpList.append(index);
                },
                .Value => {},
            }
        }

        pub fn patchPatternJumps(self: ArrayContext, compiler: *Compiler, loc: Location) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    for (jumpList.items) |index| {
                        try compiler.patchJump(index, loc);
                    }
                },
                .Value => {},
            }
        }
    };

    fn writePatternArray(self: *Compiler, start_array: *Ast.LocNode, first_item: *Ast.LocNode) !void {
        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();
        try self.writeArray(start_array, first_item, ArrayContext{ .Pattern = &jumpList });
    }

    fn writeValueArray(self: *Compiler, start_array: *Ast.LocNode, first_item: *Ast.LocNode) !void {
        try self.writeArray(start_array, first_item, ArrayContext{ .Value = undefined });
    }

    fn writeArray(self: *Compiler, array_start: *Ast.LocNode, first_item: *Ast.LocNode, context: ArrayContext) !void {
        // The first left node is the empty array
        const arrayElem = array_start.node.asElem() orelse @panic("Internal Error");

        const array = arrayElem.asDyn().asArray();
        const constId = try self.makeConstant(arrayElem);

        try self.emitUnaryOp(.GetConstant, constId, array_start.loc);

        if (context == .Pattern) {
            try self.emitOp(.Destructure, array_start.loc);
            const failureJumpIndex = try self.emitJump(.JumpIfFailure, array_start.loc);

            try self.appendArrayElems(array, first_item, context);

            const successJumpIndex = try self.emitJump(.JumpIfSuccess, array_start.loc);

            try context.patchPatternJumps(self, array_start.loc);

            try self.emitOp(.Swap, array_start.loc);
            try self.emitOp(.Pop, array_start.loc);

            try self.patchJump(failureJumpIndex, array_start.loc);
            try self.patchJump(successJumpIndex, array_start.loc);
        } else {
            try self.appendArrayElems(array, first_item, context);
        }
    }

    fn appendArrayElems(self: *Compiler, array: *Elem.Dyn.Array, first_item: *Ast.LocNode, context: ArrayContext) !void {
        var item = first_item;
        var index: u8 = 0;

        while (true) {
            switch (item.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .ArrayCons => {
                        try self.appendArrayElem(array, infix.left, index, context);
                        item = infix.right;
                        index += 1;
                    },
                    else => break,
                },
                .ElemNode,
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => break,
            }
        }

        // The last array element
        try self.appendArrayElem(array, item, index, context);
    }

    fn appendArrayElem(self: *Compiler, array: *Elem.Dyn.Array, loc_node: *Ast.LocNode, index: u8, context: ArrayContext) Error!void {
        switch (loc_node.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ArrayHead => {
                    try self.writeArrayElem(loc_node, index, context);
                    try array.append(self.placeholderVar());
                },
                .ObjectCons,
                .Merge,
                .NumberSubtract,
                => {
                    try self.writeArrayElem(loc_node, index, context);
                    try array.append(self.placeholderVar());
                },
                .CallOrDefineFunction => {
                    if (context == .Value) {
                        try self.writeArrayElem(loc_node, index, context);
                        try array.append(self.placeholderVar());
                    } else {
                        @panic("todo");
                    }
                },
                else => {
                    @panic("Internal Error");
                },
            },
            .ElemNode => |elem| switch (elem) {
                .ValueVar => {
                    try self.writeArrayElem(loc_node, index, context);
                    try array.append(self.placeholderVar());
                },
                else => {
                    try array.append(elem);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
        }
    }

    fn writeArrayElem(self: *Compiler, loc_node: *Ast.LocNode, index: u8, context: ArrayContext) Error!void {
        switch (context) {
            .Value => {
                try self.writeValue(loc_node, false);
                try self.emitUnaryOp(.InsertAtIndex, index, loc_node.loc);
            },
            .Pattern => {
                try self.emitUnaryOp(.GetAtIndex, index, loc_node.loc);
                try self.writeDestructurePattern(loc_node);
                try context.emitPatternJumpIfFailure(self, loc_node.loc);
                try self.emitOp(.Pop, loc_node.loc);
            },
        }
    }

    const ObjectContext = union(enum) {
        Pattern: *ArrayList(usize),
        Value: void,

        pub fn emitPatternJumpIfFailure(self: ObjectContext, compiler: *Compiler, loc: Location) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    const index = try compiler.emitJump(.JumpIfFailure, loc);
                    try jumpList.append(index);
                },
                .Value => {},
            }
        }

        pub fn patchPatternJumps(self: ObjectContext, compiler: *Compiler, loc: Location) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    for (jumpList.items) |index| {
                        try compiler.patchJump(index, loc);
                    }
                },
                .Value => {},
            }
        }
    };

    fn writePatternObject(self: *Compiler, start_object: *Ast.LocNode, first_item: *Ast.LocNode) !void {
        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();
        try self.writeObject(start_object, first_item, ObjectContext{ .Pattern = &jumpList });
    }

    fn writeValueObject(self: *Compiler, start_object: *Ast.LocNode, first_item: *Ast.LocNode) !void {
        try self.writeObject(start_object, first_item, ObjectContext{ .Value = undefined });
    }

    fn writeObject(self: *Compiler, object_start: *Ast.LocNode, first_item: *Ast.LocNode, context: ObjectContext) !void {
        // The first left node is the empty object
        var object_elem = object_start.node.asElem() orelse @panic("Internal Error");

        const object = object_elem.asDyn().asObject();
        const constId = try self.makeConstant(object_elem);

        try self.emitUnaryOp(.GetConstant, constId, object_start.loc);

        if (context == .Pattern) {
            try self.emitOp(.Destructure, object_start.loc);
            const failureJumpIndex = try self.emitJump(.JumpIfFailure, object_start.loc);

            try self.appendObjectMembers(object, first_item, context);

            const successJumpIndex = try self.emitJump(.JumpIfSuccess, object_start.loc);

            try context.patchPatternJumps(self, object_start.loc);

            try self.emitOp(.Swap, object_start.loc);
            try self.emitOp(.Pop, object_start.loc);

            try self.patchJump(failureJumpIndex, object_start.loc);
            try self.patchJump(successJumpIndex, object_start.loc);
        } else {
            try self.appendObjectMembers(object, first_item, context);
        }
    }

    fn appendObjectMembers(self: *Compiler, object: *Elem.Dyn.Object, first_item: *Ast.LocNode, context: ObjectContext) !void {
        var loc_node = first_item;

        while (true) {
            switch (loc_node.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .ObjectCons => {
                        try self.appendObjectPair(object, infix.left, context);
                        loc_node = infix.right;
                    },
                    else => break,
                },
                .ElemNode,
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => break,
            }
        }

        try self.appendObjectPair(object, loc_node, context);
    }

    fn appendObjectPair(self: *Compiler, object: *Elem.Dyn.Object, pair_loc_node: *Ast.LocNode, context: ObjectContext) Error!void {
        const pair = pair_loc_node.node.asInfixOfType(.ObjectPair) orelse @panic("Internal Error");
        const pairLoc = pair_loc_node.loc;

        const keyLoc = pair.left.loc;
        const keyElem = pair.left.node.asElem().?;
        const loc_node = pair.right;

        if (context == .Value) {
            switch (loc_node.node) {
                .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                    .ArrayHead,
                    .ObjectCons,
                    .Merge,
                    .NumberSubtract,
                    .CallOrDefineFunction,
                    => {
                        switch (keyElem) {
                            .String => try self.writeObjectVal(loc_node, keyElem, context),
                            .ValueVar => {
                                try self.writeGetVar(keyElem, keyLoc, .Value);
                                try self.writeValue(loc_node, false);
                                try self.emitOp(.InsertKeyVal, pairLoc);
                            },
                            else => @panic("Internal Error"),
                        }
                    },
                    else => {
                        @panic("Internal Error");
                    },
                },
                .ElemNode => |elem| switch (elem) {
                    .ValueVar => {
                        switch (keyElem) {
                            .String => try self.writeObjectVal(loc_node, keyElem, context),
                            .ValueVar => {
                                try self.writeGetVar(keyElem, keyLoc, .Value);
                                try self.writeValue(loc_node, false);
                                try self.emitOp(.InsertKeyVal, pairLoc);
                            },
                            else => @panic("Internal Error"),
                        }
                    },
                    else => {
                        switch (keyElem) {
                            .String => |sId| try object.members.put(sId, elem),
                            .ValueVar => {
                                try self.writeGetVar(keyElem, keyLoc, .Value);
                                try self.writeValue(loc_node, false);
                                try self.emitOp(.InsertKeyVal, pairLoc);
                            },
                            else => @panic("Internal Error"),
                        }
                    },
                },
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => @panic("todo"),
            }
        } else {
            const key = switch (keyElem) {
                .String => |sId| sId,
                else => @panic("Internal Error"),
            };

            switch (loc_node.node) {
                .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                    .ArrayHead,
                    .ObjectCons,
                    .Merge,
                    .NumberSubtract,
                    => {
                        try self.writeObjectVal(loc_node, keyElem, context);
                        try object.members.put(key, self.placeholderVar());
                    },
                    .CallOrDefineFunction => {
                        @panic("todo");
                    },
                    else => {
                        @panic("Internal Error");
                    },
                },
                .ElemNode => |elem| switch (elem) {
                    .ValueVar => {
                        try self.writeObjectVal(loc_node, keyElem, context);
                        try object.members.put(key, self.placeholderVar());
                    },
                    else => {
                        try object.members.put(key, elem);
                    },
                },
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => @panic("todo"),
            }
        }
    }

    fn writeObjectVal(self: *Compiler, loc_node: *Ast.LocNode, key: Elem, context: ObjectContext) Error!void {
        const loc = loc_node.loc;
        const constId = try self.makeConstant(key);

        switch (context) {
            .Value => {
                try self.writeValue(loc_node, false);
                try self.emitUnaryOp(.InsertAtKey, constId, loc);
            },
            .Pattern => {
                try self.emitUnaryOp(.GetAtKey, constId, loc);
                try self.writeDestructurePattern(loc_node);
                try context.emitPatternJumpIfFailure(self, loc);
                try self.emitOp(.Pop, loc);
            },
        }
    }

    const StringTemplateContext = enum { Parser, Value };

    fn writeStringTemplate(self: *Compiler, string_start: *Ast.LocNode, string_rest: *Ast.LocNode, context: StringTemplateContext) Error!void {
        const loc = string_start.loc;

        try self.writeStringTemplatePart(string_start, context);

        var loc_node = string_rest;

        while (true) {
            switch (loc_node.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .StringTemplateCons => {
                        try self.writeStringTemplatePart(infix.left, context);
                        try self.emitOp(.MergeAsString, loc);

                        loc_node = infix.right;
                    },
                    else => {
                        try self.writeStringTemplatePart(loc_node, context);
                        try self.emitOp(.MergeAsString, loc);
                        break;
                    },
                },
                .ElemNode => {
                    try self.writeStringTemplatePart(loc_node, context);
                    try self.emitOp(.MergeAsString, loc);
                    break;
                },
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                => @panic("todo"),
            }
        }
    }

    fn writeStringTemplatePart(self: *Compiler, loc_node: *Ast.LocNode, context: StringTemplateContext) !void {
        switch (context) {
            .Parser => try self.writeParser(loc_node, false),
            .Value => try self.writeValue(loc_node, false),
        }
    }

    fn simplifyNegatedNumberNode(loc_node: *Ast.LocNode) ?Elem {
        switch (loc_node.node) {
            .Negation => |inner| {
                if (simplifyNegatedNumberNode(inner)) |num| {
                    return num.negateNumber() catch null;
                }
            },
            .ElemNode => |elem| return elem,
            else => {},
        }

        return null;
    }

    fn placeholderVar(self: *Compiler) Elem {
        const sId = self.vm.strings.getId("_");
        return Elem.valueVar(sId);
    }

    fn chunk(self: *Compiler) *Chunk {
        return &self.currentFunction().chunk;
    }

    fn currentFunction(self: *Compiler) *Elem.Dyn.Function {
        return self.functions.items[self.functions.items.len - 1];
    }

    fn parentFunction(self: *Compiler) *Elem.Dyn.Function {
        var parentIndex = self.functions.items.len - 2;
        while (true) {
            if (self.functions.items[parentIndex].functionType == .AnonParser) {
                parentIndex -= 1;
            } else {
                return self.functions.items[parentIndex];
            }
        }
    }

    fn addLocal(self: *Compiler, elem: Elem, loc: Location) !?u8 {
        const local: Elem.Dyn.Function.Local = switch (elem) {
            .ParserVar => |sId| .{ .ParserVar = sId },
            .ValueVar => |sId| .{ .ValueVar = sId },
            else => return Error.InvalidAst,
        };

        if (self.isMetaVar(local.name())) {
            return Error.InvalidAst;
        }

        if (self.currentFunction().functionType == .NamedValue and local.isParserVar()) {
            return Error.InvalidAst;
        }

        return self.currentFunction().addLocal(local) catch |err| switch (err) {
            error.MaxFunctionLocals => {
                try self.printError(
                    std.fmt.comptimePrint(
                        "Can't have more than {} parameters and local variables.",
                        .{std.math.maxInt(u8)},
                    ),
                    loc,
                );
                return err;
            },
            else => return err,
        };
    }

    fn addLocalIfUndefined(self: *Compiler, elem: Elem, loc: Location) !?u8 {
        return self.addLocal(elem, loc) catch |err| switch (err) {
            error.VariableNameUsedInScope => return null,
            else => return err,
        };
    }

    pub fn localSlot(self: *Compiler, name: StringTable.Id) ?u8 {
        return self.currentFunction().localSlot(name);
    }

    fn isMetaVar(self: *Compiler, sId: StringTable.Id) bool {
        return self.vm.strings.get(sId)[0] == '@';
    }

    fn emitJump(self: *Compiler, op: OpCode, loc: Location) !usize {
        try self.emitOp(op, loc);
        // Dummy operands that will be patched later
        try self.chunk().writeShort(0xffff, loc);
        return self.chunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Compiler, offset: usize, loc: Location) !void {
        const jump = self.chunk().nextByteIndex() - offset - 2;

        std.debug.assert(self.chunk().read(offset) == 0xff);
        std.debug.assert(self.chunk().read(offset + 1) == 0xff);

        self.chunk().updateShortAt(offset, @as(u16, @intCast(jump))) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                try self.printError("Too much code to jump over.", loc);
                return err;
            },
            else => return err,
        };
    }

    fn emitByte(self: *Compiler, byte: u8, loc: Location) !void {
        try self.chunk().write(byte, loc);
    }

    fn emitOp(self: *Compiler, op: OpCode, loc: Location) !void {
        try self.chunk().writeOp(op, loc);
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, loc: Location) !void {
        try self.emitOp(op, loc);
        try self.emitByte(byte, loc);
    }

    fn makeConstant(self: *Compiler, elem: Elem) !u8 {
        return self.chunk().addConstant(elem) catch |err| switch (err) {
            ChunkError.TooManyConstants => {
                try self.writers.err.print("Too many constants in one chunk.", .{});
                return err;
            },
            else => return err,
        };
    }

    fn printError(self: *Compiler, message: []const u8, loc: Location) !void {
        try loc.print(self.writers.err);
        try self.writers.err.print(" Error: {s}\n", .{message});
    }
};

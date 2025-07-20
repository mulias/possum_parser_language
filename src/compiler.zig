const std = @import("std");
const ArrayList = std.ArrayList;
const unicode = std.unicode;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("chunk.zig").Chunk;
const ChunkError = @import("chunk.zig").ChunkError;
const Elem = @import("elem.zig").Elem;
const Region = @import("region.zig").Region;
const OpCode = @import("op_code.zig").OpCode;
const Scanner = @import("scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const WriterError = @import("writer.zig").VMWriter.Error;
const Writers = @import("writer.zig").Writers;

pub const Compiler = struct {
    vm: *VM,
    ast: Ast,
    functions: ArrayList(*Elem.DynElem.Function),
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
        const main = try Elem.DynElem.Function.create(vm, .{
            .name = try vm.strings.insert("@main"),
            .functionType = .Main,
            .arity = 0,
        });

        var functions = ArrayList(*Elem.DynElem.Function).init(vm.allocator);
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

    pub fn compile(self: *Compiler) !?*Elem.DynElem.Function {
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

    fn compileMain(self: *Compiler) !?*Elem.DynElem.Function {
        var main: ?*Ast.RNode = null;

        for (self.ast.roots.items) |root| {
            if (root.node.asInfixOfType(.DeclareGlobal) == null) {
                if (main == null) {
                    main = root;
                } else {
                    return Error.MultipleMainParsers;
                }
            }
        }

        if (main) |main_rnode| {
            try self.addValueLocals(main_rnode);
            try self.writeParser(main_rnode, false);
            try self.emitEnd();

            const main_fn = self.functions.pop() orelse @panic("Internal Error: No Main Function");

            if (self.printBytecode) {
                try main_fn.disassemble(self.vm.*, self.writers.debug);
            }

            return main_fn;
        } else {
            return null;
        }
    }

    fn declareGlobal(self: *Compiler, head: *Ast.RNode, body: *Ast.RNode) !void {
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
                .ElemNode => |bodyElem| {
                    try self.declareGlobalAlias(nameElem, bodyElem);
                },
                else => {
                    // A function without params
                    try self.declareGlobalFunction(head, null);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            .Array,
            => return Error.InvalidAst,
        }
    }

    fn declareGlobalFunction(self: *Compiler, name: *Ast.RNode, params: ?*Ast.RNode) !void {
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
        const functionType: Elem.DynElem.FunctionType = switch (nameVar) {
            .ValueVar => .NamedValue,
            .ParserVar => .NamedParser,
            else => return Error.InvalidAst,
        };

        var function = try Elem.DynElem.Function.create(self.vm, .{
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
                                    infix.left.region,
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
                        _ = try self.addLocal(elem, param.region);
                        function.arity += 1;
                        break;
                    },
                    .UpperBoundedRange,
                    .LowerBoundedRange,
                    .Negation,
                    .ValueLabel,
                    .Array,
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

    fn validateGlobal(self: *Compiler, head: *Ast.RNode) !void {
        const nameElem = switch (head.node) {
            .InfixNode => |infix| infix.left.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            .Array,
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
                    .NativeCode,
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
                    .NativeCode,
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

    fn resolveGlobalAlias(self: *Compiler, head: *Ast.RNode) !void {
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

    fn compileGlobalFunction(self: *Compiler, head: *Ast.RNode, body: *Ast.RNode) !void {
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

            try self.emitEnd();

            if (self.printBytecode) {
                try function.disassemble(self.vm.*, self.writers.debug);
            }

            _ = self.functions.pop();
        }
    }

    fn getGlobalName(self: *Compiler, head: *Ast.RNode) !StringTable.Id {
        const nameElem = switch (head.node) {
            .InfixNode => |infix| infix.left.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            .Array,
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

    fn writeParser(self: *Compiler, rnode: *Ast.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, region);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Merge => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.Merge, region);
                    try self.patchJump(jumpIndex, region);
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
                            try self.emitOp(.ParseCharacter, region);
                        } else {
                            const low_id = try self.makeConstant(low_elem);
                            const high_id = try self.makeConstant(high_elem);
                            try self.emitOp(.ParseRange, region);
                            try self.emitByte(low_id, low.region);
                            try self.emitByte(high_id, high.region);
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
                                try self.emitOp(.ParseRange, region);
                                try self.emitByte(low_id, low.region);
                                try self.emitByte(high_id, high.region);
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
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.TakeLeft, region);
                    try self.patchJump(jumpIndex, region);
                },
                .TakeRight => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Destructure => {
                    try self.writeParser(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, region);
                    try self.writeParser(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Return => {
                    try self.writeParser(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, region);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseregion = infix.right.region;

                    // Get each part of `if ? then : else`
                    const if_rnode = infix.left;
                    const then_rnode = thenElseOp.left;
                    const else_rnode = thenElseOp.right;

                    try self.emitOp(.SetInputMark, region);
                    try self.writeParser(if_rnode, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                    try self.writeParser(then_rnode, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseregion);
                    try self.patchJump(ifThenJumpIndex, region);
                    try self.writeParser(else_rnode, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseregion);
                },
                .ConditionalThenElse => @panic("internal error"), // always handled via ConditionalIfThen
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => {
                    try self.writeParserFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
                .ObjectCons,
                .ObjectPair,
                .NumberSubtract,
                .StringTemplateCons,
                => return Error.InvalidAst,
            },
            .UpperBoundedRange => |high| {
                const high_elem = try getParserRangeElemNode(high);
                const high_region = high.region;

                if (high_elem == .String) {
                    const high_str = high_elem.String;
                    const high_bytes = self.vm.strings.get(high_str);
                    const high_codepoint = unicode.utf8Decode(high_bytes) catch return Error.RangeNotSingleCodepoint;

                    if (high_codepoint == 0x10ffff) {
                        try self.emitOp(.ParseCharacter, region);
                    } else {
                        const high_id = try self.makeConstant(high_elem);
                        try self.emitOp(.ParseUpperBoundedRange, region);
                        try self.emitByte(high_id, high_region);
                    }
                } else if (high_elem == .NumberString) {
                    const high_ns = high_elem.NumberString;

                    if (high_ns.format == .Integer) {
                        const high_int = high_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                        const high_id = try self.makeConstant(high_int);
                        try self.emitOp(.ParseUpperBoundedRange, region);
                        try self.emitByte(high_id, high_region);
                    } else {
                        return Error.RangeInvalidNumberFormat;
                    }
                } else {
                    return Error.InvalidAst;
                }
            },
            .LowerBoundedRange => |low| {
                const low_elem = try getParserRangeElemNode(low);
                const low_region = low.region;

                if (low_elem == .String) {
                    const low_str = low_elem.String;
                    const low_bytes = self.vm.strings.get(low_str);
                    const low_codepoint = unicode.utf8Decode(low_bytes) catch return Error.RangeNotSingleCodepoint;

                    if (low_codepoint == 0) {
                        try self.emitOp(.ParseCharacter, region);
                    } else {
                        const low_id = try self.makeConstant(low_elem);
                        try self.emitOp(.ParseLowerBoundedRange, region);
                        try self.emitByte(low_id, low_region);
                    }
                } else if (low_elem == .NumberString) {
                    const low_ns = low_elem.NumberString;

                    if (low_ns.format == .Integer) {
                        const low_int = low_ns.toNumberElem(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                        const low_id = try self.makeConstant(low_int);
                        try self.emitOp(.ParseLowerBoundedRange, region);
                        try self.emitByte(low_id, low_region);
                    } else {
                        return Error.RangeInvalidNumberFormat;
                    }
                } else {
                    return Error.InvalidAst;
                }
            },
            .Negation => |inner| {
                const negated = try negateParserNumber(inner);
                const constId = try self.makeConstant(negated);
                try self.emitUnaryOp(.GetConstant, constId, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .ElemNode => try self.writeParserElem(rnode),
            .ValueLabel,
            .Array,
            => return Error.InvalidAst,
        }
    }

    fn negateParserNumber(rnode: *Ast.RNode) !Elem {
        if (rnode.node.asElem()) |elem| {
            const negated = Elem.negateNumber(elem) catch |err| switch (err) {
                error.ExpectedNumber => return Error.InvalidAst,
            };
            return negated;
        } else {
            return Error.InvalidAst;
        }
    }

    fn getParserRangeElemNode(rnode: *Ast.RNode) !Elem {
        return switch (rnode.node) {
            .ElemNode => |elem| elem,
            .Negation => |inner| negateParserNumber(inner),
            else => Error.InvalidAst,
        };
    }

    fn writeParserFunctionCall(self: *Compiler, function_rnode: *Ast.RNode, args_rnode: *Ast.RNode, isTailPosition: bool) !void {
        const function_elem = function_rnode.node.asElem() orelse @panic("internal error");
        const function_region = function_rnode.region;

        const functionName = switch (function_elem) {
            .ParserVar => |sId| sId,
            .Boolean => |b| try self.vm.strings.insert(if (b) "true" else "false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, function_region);
            } else {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(functionName)});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeParserFunctionArguments(args_rnode, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, function_region);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, function_region);
        }
    }

    fn writeParserElem(self: *Compiler, rnode: *Ast.RNode) !void {
        const region = rnode.region;

        switch (rnode.node) {
            .ElemNode => |elem| {
                switch (elem) {
                    .ParserVar => {
                        try self.writeGetVar(elem, region, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .ValueVar => {
                        try self.printError("Variable is only valid as a pattern or value", region);
                        return Error.InvalidAst;
                    },
                    .String,
                    .NumberString,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .Boolean => {
                        // In this context `true`/`false` could be a zero-arg function call
                        try self.writeGetVar(elem, region, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .Null => {
                        // In this context `null` could be a zero-arg function call
                        try self.writeGetVar(elem, region, .Parser);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .Failure,
                    .Integer,
                    .Float,
                    .InputSubstring,
                    .Dyn,
                    => @panic("Internal Error"),
                }
            },
            else => @panic("Internal Error"),
        }
    }

    fn writeGetVar(self: *Compiler, elem: Elem, region: Region, context: enum { Parser, Pattern, Value }) !void {
        const varName = switch (elem) {
            .ParserVar => |sId| sId,
            .ValueVar => |sId| sId,
            .Boolean => |b| try self.vm.strings.insert(if (b) "true" else "false"),
            .Null => try self.vm.strings.insert("null"),
            else => return Error.InvalidAst,
        };

        if (self.localSlot(varName)) |slot| {
            if (context == .Pattern) {
                try self.emitUnaryOp(.GetLocal, slot, region);
            } else {
                try self.emitUnaryOp(.GetBoundLocal, slot, region);
            }
        } else {
            if (self.vm.globals.get(varName)) |globalElem| {
                const constId = try self.makeConstant(globalElem);
                try self.emitUnaryOp(.GetConstant, constId, region);
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

    fn writeParserFunctionArguments(self: *Compiler, first_arg: *Ast.RNode, function: ?*Elem.DynElem.Function) Error!u8 {
        var argCount: u8 = 0;
        var arg = first_arg;
        var argType: ArgType = .Unspecified;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                try self.printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    arg.region,
                );
                return Error.MaxFunctionArgs;
            }

            argCount += 1;

            if (function) |f| {
                if (f.arity < argCount) {
                    try self.writers.err.print("{s}\n", .{self.vm.strings.get(f.name)});
                    return Error.FunctionCallTooManyArgs;
                }

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
            if (f.arity != argCount) {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(f.name)});
                return Error.FunctionCallTooFewArgs;
            }
        }

        return argCount;
    }

    fn writeParserFunctionArgument(self: *Compiler, rnode: *Ast.RNode, argType: ArgType) !void {
        const region = rnode.region;

        switch (argType) {
            .Parser => switch (rnode.node) {
                .InfixNode,
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                => {
                    const function = try self.writeAnonymousFunction(rnode);
                    const constId = try self.makeConstant(function.dyn.elem());
                    try self.emitUnaryOp(.GetConstant, constId, region);
                    try self.writeCaptureLocals(function, region);
                },
                .ElemNode => |elem| switch (elem) {
                    .ParserVar => try self.writeGetVar(elem, region, .Value),
                    else => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    },
                },
                .ValueLabel => @panic("todo"),
                .Array => @panic("Internal Error: Array should never be a parser"),
            },
            .Value => try self.writeValueArgument(rnode, false),
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

    fn writeAnonymousFunction(self: *Compiler, rnode: *Ast.RNode) !*Elem.DynElem.Function {
        const region = rnode.region;

        const function = try Elem.DynElem.Function.createAnonParser(self.vm, .{ .arity = 0 });

        try self.functions.append(function);

        try self.addClosureLocals(rnode);

        if (function.locals.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, region);
        }

        try self.writeParser(rnode, true);
        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        return self.functions.pop() orelse @panic("Internal Error");
    }

    fn writeCaptureLocals(self: *Compiler, targetFunction: *Elem.DynElem.Function, region: Region) !void {
        for (self.currentFunction().locals.items, 0..) |local, fromSlot| {
            if (targetFunction.localSlot(local.name())) |toSlot| {
                try self.emitOp(.CaptureLocal, region);
                try self.emitByte(@as(u8, @intCast(fromSlot)), region);
                try self.emitByte(toSlot, region);
            }
        }
    }

    fn writeDestructurePattern(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ObjectCons => {
                    try self.writePatternObject(infix.left, infix.right);
                },
                .Merge => {
                    try self.writePatternMerge(rnode);
                },
                .NumberSubtract => {
                    @panic("TODO");
                },
                .Range => {
                    try self.writePattern(infix.left);
                    try self.writePattern(infix.right);
                    try self.emitOp(.DestructureRange, region);
                },
                else => {
                    try self.writePattern(rnode);
                    try self.emitOp(.Destructure, region);
                },
            },
            .ElemNode => {
                try self.writePattern(rnode);
                try self.emitOp(.Destructure, region);
            },
            .UpperBoundedRange => |high_node_id| {
                const low_elem = self.placeholderVar();
                const low_id = try self.makeConstant(low_elem);
                try self.emitUnaryOp(.GetConstant, low_id, region);
                try self.writePattern(high_node_id);
                try self.emitOp(.DestructureRange, region);
            },
            .LowerBoundedRange => |low_node_id| {
                const high_elem = self.placeholderVar();
                try self.writePattern(low_node_id);
                const high_id = try self.makeConstant(high_elem);
                try self.emitUnaryOp(.GetConstant, high_id, region);
                try self.emitOp(.DestructureRange, region);
            },
            .Negation => {
                try self.writePattern(rnode);
                try self.emitOp(.Destructure, region);
            },
            .ValueLabel => return error.InvalidAst,
            .Array => |elements| {
                try self.writeDestructurePatternArray(elements, region);
            },
        }
    }

    fn writePattern(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
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
                .ObjectPair,
                .StringTemplateCons,
                => @panic("Internal Error"),
                else => {
                    try self.printError("Invalid infix operator in pattern", region);
                    return Error.InvalidAst;
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .ValueLabel,
            => @panic("todo"),
            .Array => @panic("Internal Error"), // handled by writeDestructurePatternArray
            .Negation => {
                if (simplifyNegatedNumberNode(rnode)) |elem| {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, region);
                } else {
                    @panic("todo");
                }
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    try self.printError("parser is not valid in pattern", region);
                    return Error.InvalidAst;
                },
                .ValueVar => |name| {
                    if (self.localSlot(name)) |slot| {
                        try self.emitUnaryOp(.GetLocal, slot, region);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            try self.emitUnaryOp(.CallFunction, 0, region);
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
                    try self.emitUnaryOp(.GetConstant, constId, region);
                },
                .Boolean => |b| try self.emitOp(if (b) .True else .False, region),
                .Null => {
                    try self.emitOp(.Null, region);
                },
                .Failure,
                .Float,
                .InputSubstring,
                .Integer,
                => @panic("Internal Error"), // not produced by the parser
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Function,
                    .NativeCode,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    },
                },
            },
        }
    }

    fn writePatternMerge(self: *Compiler, rnode: *Ast.RNode) !void {
        const region = rnode.region;

        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        const count = try self.writePrepareMergePattern(rnode, 0);
        try self.emitUnaryOp(.PrepareMergePattern, count, region);
        const failureJumpIndex = try self.emitJump(.JumpIfFailure, region);

        try self.writeMergePattern(rnode, &jumpList);

        const successJumpIndex = try self.emitJump(.JumpIfSuccess, region);

        for (jumpList.items) |jumpIndex| {
            try self.patchJump(jumpIndex, region);
        }

        try self.emitOp(.Swap, region);
        try self.emitOp(.Pop, region);

        try self.patchJump(failureJumpIndex, region);
        try self.patchJump(successJumpIndex, region);
    }

    fn writePrepareMergePattern(self: *Compiler, rnode: *Ast.RNode, count: u8) !u8 {
        switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    const totalCount = try self.writePrepareMergePattern(infix.left, count + 1);
                    try self.writePrepareMergePatternPart(infix.right);
                    return totalCount;
                },
                else => {
                    // Default case
                },
            },
            .ElemNode,
            .Array,
            => {
                // Default case
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
        }

        // Default case
        try self.writePrepareMergePatternPart(rnode);
        return count + 1;
    }

    fn writePrepareMergePatternPart(self: *Compiler, rnode: *Ast.RNode) Error!void {
        switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ObjectCons => {
                    // At this point the array/object is empty, but in a
                    // later step we'll mutate to add elements.
                    const elem = infix.left.node.asElem() orelse @panic("Internal Error");
                    const region = infix.left.region;
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, region);
                    try self.writePatternObjectDynamicKeys(infix.right);
                },
                else => {
                    try self.writePattern(rnode);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
            .Array => |elements| {
                var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
                for (elements.items) |element| {
                    if (self.isLiteralPattern(element)) {
                        const elem = element.node.asElem() orelse @panic("Internal Error");
                        try array.append(elem);
                    } else {
                        try array.append(self.placeholderVar());
                    }
                }
                const constId = try self.makeConstant(array.dyn.elem());
                try self.emitUnaryOp(.GetConstant, constId, rnode.region);
            },
            .ElemNode => {
                try self.writePattern(rnode);
            },
        }
    }

    fn writeMergePattern(self: *Compiler, rnode: *Ast.RNode, jumpList: *ArrayList(usize)) Error!void {
        const region = rnode.region;

        switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.writeMergePattern(infix.left, jumpList);
                    try self.writeDestructurePattern(infix.right);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.emitOp(.Pop, region);
                    try jumpList.append(jumpIndex);
                    return;
                },
                else => {
                    // Default case
                },
            },
            .Array,
            .ElemNode,
            => {
                // Default case
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
        }

        // Default case
        try self.writeDestructurePattern(rnode);
        const jumpIndex = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.Pop, region);
        try jumpList.append(jumpIndex);
    }

    fn addValueLocals(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

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
            .Array => |elements| {
                for (elements.items) |element| {
                    try self.addValueLocals(element);
                }
            },
            .ElemNode => |elem| switch (elem) {
                .ValueVar => |varName| if (self.vm.globals.get(varName) == null) {
                    const newLocalId = try self.addLocalIfUndefined(elem, region);
                    if (newLocalId) |_| {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    }
                },
                else => {},
            },
        }
    }

    fn addClosureLocals(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

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
            .Array => |elements| {
                for (elements.items) |element| {
                    try self.addClosureLocals(element);
                }
            },
            .ElemNode => |elem| {
                const varName = switch (elem) {
                    .ValueVar => |name| name,
                    .ParserVar => |name| name,
                    else => null,
                };

                if (varName) |name| {
                    if (self.parentFunction().localSlot(name) != null) {
                        const newLocalId = try self.addLocalIfUndefined(elem, region);
                        if (newLocalId) |_| {
                            const constId = try self.makeConstant(elem);
                            try self.emitUnaryOp(.GetConstant, constId, region);
                        }
                    }
                }
            },
        }
    }

    fn writeValueArgument(self: *Compiler, rnode: *Ast.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .StringTemplate => {
                    return error.UnlabeledStringValue;
                },
                .Backtrack => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, region);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Merge => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.Merge, region);
                    try self.patchJump(jumpIndex, region);
                },
                .NumberSubtract => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.NegateNumber, region);
                    try self.emitOp(.Merge, region);
                },
                .TakeLeft => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.TakeLeft, region);
                    try self.patchJump(jumpIndex, region);
                },
                .TakeRight => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Destructure => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, region);
                    try self.writeValueArgument(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Return => {
                    try self.writeValueArgument(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, region);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseregion = infix.right.region;

                    // Get each part of `if ? then : else`
                    const if_rnode = infix.left;
                    const then_rnode = thenElseOp.left;
                    const else_rnode = thenElseOp.right;

                    try self.emitOp(.SetInputMark, region);
                    try self.writeValueArgument(if_rnode, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                    try self.writeValueArgument(then_rnode, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseregion);
                    try self.patchJump(ifThenJumpIndex, region);
                    try self.writeValueArgument(else_rnode, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseregion);
                },
                else => try writeValue(self, rnode, isTailPosition),
            },
            .Negation => |inner| {
                try self.writeValueArgument(inner, false);
                try self.emitOp(.NegateNumber, region);
            },
            .ValueLabel => |inner| {
                try self.writeValue(inner, isTailPosition);
            },
            .ElemNode => |elem| switch (elem) {
                .String => {
                    return error.UnlabeledStringValue;
                },
                .NumberString => {
                    return error.UnlabeledNumberValue;
                },
                .Boolean => return error.UnlabeledBooleanValue,
                .Null => return error.UnlabeledNullValue,
                else => try writeValue(self, rnode, isTailPosition),
            },
            else => try writeValue(self, rnode, isTailPosition),
        }
    }

    fn writeValue(self: *Compiler, rnode: *Ast.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .ObjectCons => {
                    try self.writeValueObject(infix.left, infix.right);
                },
                .StringTemplate => {
                    try self.writeStringTemplate(infix.left, infix.right, .Value);
                },
                .Backtrack => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.Backtrack, region);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Merge => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.Merge, region);
                    try self.patchJump(jumpIndex, region);
                },
                .NumberSubtract => {
                    try self.writeValue(infix.left, false);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.NegateNumber, region);
                    try self.emitOp(.Merge, region);
                },
                .TakeLeft => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.TakeLeft, region);
                    try self.patchJump(jumpIndex, region);
                },
                .TakeRight => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Destructure => {
                    try self.writeValue(infix.left, false);
                    try self.writeDestructurePattern(infix.right);
                },
                .Or => {
                    try self.emitOp(.SetInputMark, region);
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.Or, region);
                    try self.writeValue(infix.right, isTailPosition);
                    try self.patchJump(jumpIndex, region);
                },
                .Return => {
                    try self.writeValue(infix.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(infix.right, true);
                    try self.patchJump(jumpIndex, region);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = infix.right.node.asInfixOfType(.ConditionalThenElse) orelse return Error.InvalidAst;
                    const thenElseregion = infix.right.region;

                    // Get each part of `if ? then : else`
                    const if_rnode = infix.left;
                    const then_rnode = thenElseOp.left;
                    const else_rnode = thenElseOp.right;

                    try self.emitOp(.SetInputMark, region);
                    try self.writeValue(if_rnode, false);
                    const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                    try self.writeValue(then_rnode, isTailPosition);
                    const thenElseJumpIndex = try self.emitJump(.ConditionalElse, thenElseregion);
                    try self.patchJump(ifThenJumpIndex, region);
                    try self.writeValue(else_rnode, isTailPosition);
                    try self.patchJump(thenElseJumpIndex, thenElseregion);
                },
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .Range => {
                    try self.printError("Character and integer ranges are not valid in value", region);
                    return Error.InvalidAst;
                },
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
                try self.emitOp(.NegateNumber, region);
            },
            .ValueLabel => |inner| {
                try self.writeValue(inner, isTailPosition);
            },
            .Array => |elements| {
                try self.writeValueArray(elements, region);
            },
            .ElemNode => |elem| switch (elem) {
                .ParserVar => {
                    try self.printError("Parser is not valid in value", region);
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
                        try self.emitUnaryOp(.GetBoundLocal, slot, region);
                    } else if (self.vm.globals.get(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                        if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                            if (isTailPosition) {
                                try self.emitUnaryOp(.CallTailFunction, 0, region);
                            } else {
                                try self.emitUnaryOp(.CallFunction, 0, region);
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
                    try self.emitUnaryOp(.GetConstant, constId, region);
                },
                .Boolean => |b| try self.emitOp(if (b) .True else .False, region),
                .Null => try self.emitOp(.Null, region),
                .Failure,
                .InputSubstring,
                .Integer,
                .Float,
                => @panic("Internal Error"), // not produced by the parser
                .Dyn => |d| switch (d.dynType) {
                    .String,
                    .Function,
                    .NativeCode,
                    .Closure,
                    => @panic("Internal Error"), // not produced by the parser
                    .Array,
                    .Object,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    },
                },
            },
        }
    }

    fn writeValueFunctionCall(self: *Compiler, function_rnode: *Ast.RNode, args_rnode: *Ast.RNode, isTailPosition: bool) !void {
        const function_elem = function_rnode.node.asElem() orelse @panic("internal error");
        const function_region = function_rnode.region;

        const functionName = switch (function_elem) {
            .ValueVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.vm.globals.get(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, function_region);
            } else {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(functionName)});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(args_rnode, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, function_region);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, function_region);
        }
    }

    fn writeValueFunctionArguments(self: *Compiler, first_arg: *Ast.RNode, function: ?*Elem.DynElem.Function) Error!u8 {
        var argCount: u8 = 0;
        var arg = first_arg;

        while (true) {
            if (argCount == std.math.maxInt(u8)) {
                try self.printError(
                    std.fmt.comptimePrint("Can't have more than {} parameters.", .{std.math.maxInt(u8)}),
                    arg.region,
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
            if (f.arity < argCount) {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(f.name)});
                return Error.FunctionCallTooManyArgs;
            }
            if (f.arity > argCount) {
                try self.writers.err.print("{s}\n", .{self.vm.strings.get(f.name)});
                return Error.FunctionCallTooFewArgs;
            }
        }

        return argCount;
    }

    fn writeDestructurePatternArray(self: *Compiler, elements: std.ArrayListUnmanaged(*Ast.RNode), region: Region) Error!void {
        var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);

        for (elements.items) |element| {
            if (self.isLiteralPattern(element)) {
                const elem = element.node.asElem() orelse @panic("Internal Error");
                try array.append(elem);
            } else {
                try array.append(self.placeholderVar());
            }
        }

        const constId = try self.makeConstant(array.dyn.elem());
        try self.emitUnaryOp(.GetConstant, constId, region);
        try self.emitOp(.Destructure, region);

        // Note: This is an optimization which is probably incorrect.
        if (elements.items.len == 0) {
            return;
        }

        const failureJumpIndex = try self.emitJump(.JumpIfFailure, region);
        var jumpList = std.ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        for (elements.items, 0..) |element, index| {
            if (!self.isLiteralPattern(element)) {
                try self.emitUnaryOp(.GetAtIndex, @intCast(index), element.region);
                try self.writeDestructurePattern(element);
                const jumpIndex = try self.emitJump(.JumpIfFailure, element.region);
                try jumpList.append(jumpIndex);
                try self.emitOp(.Pop, element.region);
            }
        }

        const successJumpIndex = try self.emitJump(.JumpIfSuccess, region);

        for (jumpList.items) |jumpIndex| {
            try self.patchJump(jumpIndex, region);
        }

        try self.emitOp(.Swap, region);
        try self.emitOp(.Pop, region);

        try self.patchJump(failureJumpIndex, region);
        try self.patchJump(successJumpIndex, region);
    }

    fn writeValueArray(self: *Compiler, elements: std.ArrayListUnmanaged(*Ast.RNode), region: Region) Error!void {
        var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
        const constId = try self.makeConstant(array.dyn.elem());
        try self.emitUnaryOp(.GetConstant, constId, region);

        for (elements.items, 0..) |element, index| {
            try self.writeArrayElem(array, element, @intCast(index), region);
        }
    }

    fn appendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) !void {
        try self.writeValue(rnode, false);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.placeholderVar());
    }

    fn writeArrayElem(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) Error!void {
        switch (rnode.node) {
            .ElemNode => |elem| switch (elem) {
                .ValueVar => try self.appendDynamicValue(array, rnode, index, region),
                else => {
                    try array.append(elem);
                },
            },
            .InfixNode => try self.appendDynamicValue(array, rnode, index, region),
            .Array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(emptyArray.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index, region);
                }
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            => @panic("todo"),
        }
    }

    const ObjectContext = union(enum) {
        Pattern: *ArrayList(usize),
        Value: void,

        pub fn emitPatternJumpIfFailure(self: ObjectContext, compiler: *Compiler, region: Region) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    const index = try compiler.emitJump(.JumpIfFailure, region);
                    try jumpList.append(index);
                },
                .Value => {},
            }
        }

        pub fn patchPatternJumps(self: ObjectContext, compiler: *Compiler, region: Region) !void {
            switch (self) {
                .Pattern => |jumpList| {
                    for (jumpList.items) |index| {
                        try compiler.patchJump(index, region);
                    }
                },
                .Value => {},
            }
        }
    };

    fn writePatternObject(self: *Compiler, object_start: *Ast.RNode, first_item: *Ast.RNode) Error!void {
        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        var object_elem = object_start.node.asElem() orelse @panic("Internal Error");

        const object = object_elem.asDyn().asObject();
        const constId = try self.makeConstant(object_elem);

        try self.emitUnaryOp(.GetConstant, constId, object_start.region);

        try self.writePatternObjectDynamicKeys(first_item);

        try self.emitOp(.Destructure, object_start.region);
        const failureJumpIndex = try self.emitJump(.JumpIfFailure, object_start.region);

        try self.appendPatternObjectMembers(object, first_item, &jumpList);

        const successJumpIndex = try self.emitJump(.JumpIfSuccess, object_start.region);

        for (jumpList.items) |index| {
            try self.patchJump(index, object_start.region);
        }

        try self.emitOp(.Swap, object_start.region);
        try self.emitOp(.Pop, object_start.region);

        try self.patchJump(failureJumpIndex, object_start.region);
        try self.patchJump(successJumpIndex, object_start.region);
    }

    fn writeValueObject(self: *Compiler, object_start: *Ast.RNode, first_item: *Ast.RNode) !void {
        var object_elem = object_start.node.asElem() orelse @panic("Internal Error");

        const object = object_elem.asDyn().asObject();
        const constId = try self.makeConstant(object_elem);

        try self.emitUnaryOp(.GetConstant, constId, object_start.region);

        try self.appendValueObjectMembers(object, first_item);
    }

    fn writePatternObjectDynamicKeys(self: *Compiler, first_item: *Ast.RNode) !void {
        var rnode = first_item;

        while (true) {
            switch (rnode.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .ObjectCons => {
                        try self.writePatternObjectDynamicKey(infix.left);
                        rnode = infix.right;
                    },
                    else => break,
                },
                else => break,
            }
        }

        try self.writePatternObjectDynamicKey(rnode);
    }

    fn appendPatternObjectMembers(self: *Compiler, object: *Elem.DynElem.Object, first_item: *Ast.RNode, jump_list: *ArrayList(usize)) !void {
        var rnode = first_item;

        while (true) {
            switch (rnode.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .ObjectCons => {
                        try self.appendPatternObjectPair(object, infix.left, jump_list);
                        rnode = infix.right;
                    },
                    else => break,
                },
                else => break,
            }
        }

        try self.appendPatternObjectPair(object, rnode, jump_list);
    }

    fn appendValueObjectMembers(self: *Compiler, object: *Elem.DynElem.Object, first_item: *Ast.RNode) !void {
        var rnode = first_item;

        while (true) {
            switch (rnode.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .ObjectCons => {
                        try self.appendValueObjectPair(object, infix.left);
                        rnode = infix.right;
                    },
                    else => break,
                },
                else => break,
            }
        }

        try self.appendValueObjectPair(object, rnode);
    }

    fn writePatternObjectDynamicKey(self: *Compiler, pair_rnode: *Ast.RNode) !void {
        const pair_node = pair_rnode.node.asInfixOfType(.ObjectPair) orelse @panic("Internal Error");
        const pair_region = pair_rnode.region;

        const key_region = pair_node.left.region;
        const key_elem = pair_node.left.node.asElem().?;
        const val_rnode = pair_node.right;

        if (key_elem == .ValueVar) switch (val_rnode.node) {
            .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                .ObjectCons,
                .Merge,
                .NumberSubtract,
                => {
                    try self.writeGetVar(key_elem, key_region, .Pattern);
                    try self.writePattern(val_rnode);
                    try self.emitOp(.InsertKeyVal, pair_region);
                },
                .CallOrDefineFunction => @panic("todo"),
                else => @panic("Internal Error"),
            },
            .ElemNode => {
                try self.writeGetVar(key_elem, key_region, .Pattern);
                try self.writePattern(val_rnode);
                try self.emitOp(.InsertKeyVal, pair_region);
            },
            else => {},
        };
    }

    fn appendPatternObjectPair(self: *Compiler, object: *Elem.DynElem.Object, pair_rnode: *Ast.RNode, jump_list: *ArrayList(usize)) Error!void {
        const pair_node = pair_rnode.node.asInfixOfType(.ObjectPair) orelse @panic("Internal Error");

        const key_elem = pair_node.left.node.asElem().?;
        const val_rnode = pair_node.right;

        switch (val_rnode.node) {
            .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                .ObjectCons,
                .Merge,
                .NumberSubtract,
                => {
                    try self.writePatternObjectVal(val_rnode, key_elem, jump_list);

                    if (key_elem == .String) {
                        try object.members.put(key_elem.String, self.placeholderVar());
                    }
                },
                .CallOrDefineFunction => @panic("todo"),
                else => @panic("Internal Error"),
            },
            .ElemNode => |elem| switch (elem) {
                .ValueVar => {
                    try self.writePatternObjectVal(val_rnode, key_elem, jump_list);

                    if (key_elem == .String) {
                        try object.members.put(key_elem.String, self.placeholderVar());
                    }
                },
                else => {
                    if (key_elem == .String) {
                        try object.members.put(key_elem.String, elem);
                    }
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            .Negation,
            .ValueLabel,
            .Array,
            => @panic("todo"),
        }
    }

    fn appendValueObjectPair(self: *Compiler, object: *Elem.DynElem.Object, pair_rnode: *Ast.RNode) Error!void {
        const pair_node = pair_rnode.node.asInfixOfType(.ObjectPair) orelse @panic("Internal Error");
        const pair_region = pair_rnode.region;

        const key_region = pair_node.left.region;
        const key_elem = pair_node.left.node.asElem().?;
        const val_rnode = pair_node.right;

        switch (val_rnode.node) {
            .InfixNode => |nestedInfix| switch (nestedInfix.infixType) {
                .ObjectCons,
                .Merge,
                .NumberSubtract,
                .CallOrDefineFunction,
                => {
                    switch (key_elem) {
                        .String => try self.writeValueObjectVal(val_rnode, key_elem),
                        .ValueVar => {
                            try self.writeGetVar(key_elem, key_region, .Value);
                            try self.writeValue(val_rnode, false);
                            try self.emitOp(.InsertKeyVal, pair_region);
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
                    switch (key_elem) {
                        .String => try self.writeValueObjectVal(val_rnode, key_elem),
                        .ValueVar => {
                            try self.writeGetVar(key_elem, key_region, .Value);
                            try self.writeValue(val_rnode, false);
                            try self.emitOp(.InsertKeyVal, pair_region);
                        },
                        else => @panic("Internal Error"),
                    }
                },
                else => {
                    switch (key_elem) {
                        .String => |sId| try object.members.put(sId, elem),
                        .ValueVar => {
                            try self.writeGetVar(key_elem, key_region, .Value);
                            try self.writeValue(val_rnode, false);
                            try self.emitOp(.InsertKeyVal, pair_region);
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
            .Array => {
                switch (key_elem) {
                    .String => try self.writeValueObjectVal(val_rnode, key_elem),
                    .ValueVar => {
                        try self.writeGetVar(key_elem, key_region, .Value);
                        try self.writeValue(val_rnode, false);
                        try self.emitOp(.InsertKeyVal, pair_region);
                    },
                    else => @panic("Internal Error"),
                }
            },
        }
    }

    fn writePatternObjectVal(self: *Compiler, rnode: *Ast.RNode, key: Elem, jump_list: *ArrayList(usize)) Error!void {
        const region = rnode.region;

        switch (key) {
            .String => {
                const constId = try self.makeConstant(key);
                try self.emitUnaryOp(.GetConstant, constId, region);
            },
            .ValueVar => {
                try self.writeGetVar(key, region, .Pattern);
            },
            else => @panic("Internal Error"),
        }

        try self.emitOp(.GetAtKey, region);
        try self.writeDestructurePattern(rnode);

        const index = try self.emitJump(.JumpIfFailure, region);
        try jump_list.append(index);

        try self.emitOp(.Pop, region);
    }

    fn writeValueObjectVal(self: *Compiler, rnode: *Ast.RNode, key: Elem) Error!void {
        const region = rnode.region;
        const constId = try self.makeConstant(key);

        try self.writeValue(rnode, false);
        try self.emitUnaryOp(.InsertAtKey, constId, region);
    }

    const StringTemplateContext = enum { Parser, Value };

    fn writeStringTemplate(self: *Compiler, string_start: *Ast.RNode, string_rest: *Ast.RNode, context: StringTemplateContext) Error!void {
        const region = string_start.region;

        try self.writeStringTemplatePart(string_start, context);

        var rnode = string_rest;

        while (true) {
            switch (rnode.node) {
                .InfixNode => |infix| switch (infix.infixType) {
                    .StringTemplateCons => {
                        try self.writeStringTemplatePart(infix.left, context);
                        try self.emitOp(.MergeAsString, region);

                        rnode = infix.right;
                    },
                    else => {
                        try self.writeStringTemplatePart(rnode, context);
                        try self.emitOp(.MergeAsString, region);
                        break;
                    },
                },
                .ElemNode => {
                    try self.writeStringTemplatePart(rnode, context);
                    try self.emitOp(.MergeAsString, region);
                    break;
                },
                .UpperBoundedRange,
                .LowerBoundedRange,
                .Negation,
                .ValueLabel,
                .Array,
                => @panic("todo"),
            }
        }
    }

    fn writeStringTemplatePart(self: *Compiler, rnode: *Ast.RNode, context: StringTemplateContext) !void {
        switch (context) {
            .Parser => try self.writeParser(rnode, false),
            .Value => try self.writeValue(rnode, false),
        }
    }

    fn isLiteralPattern(self: *Compiler, rnode: *Ast.RNode) bool {
        _ = self;
        return switch (rnode.node) {
            .ElemNode => |elem| switch (elem) {
                .String, .InputSubstring, .NumberString, .Integer, .Float, .Boolean, .Null => true,
                else => false,
            },
            else => false,
        };
    }

    fn simplifyNegatedNumberNode(rnode: *Ast.RNode) ?Elem {
        switch (rnode.node) {
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

    fn currentFunction(self: *Compiler) *Elem.DynElem.Function {
        return self.functions.items[self.functions.items.len - 1];
    }

    fn parentFunction(self: *Compiler) *Elem.DynElem.Function {
        var parentIndex = self.functions.items.len - 2;
        while (true) {
            if (self.functions.items[parentIndex].functionType == .AnonParser) {
                parentIndex -= 1;
            } else {
                return self.functions.items[parentIndex];
            }
        }
    }

    fn addLocal(self: *Compiler, elem: Elem, region: Region) !?u8 {
        const local: Elem.DynElem.Function.Local = switch (elem) {
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
                    region,
                );
                return err;
            },
            else => return err,
        };
    }

    fn addLocalIfUndefined(self: *Compiler, elem: Elem, region: Region) !?u8 {
        return self.addLocal(elem, region) catch |err| switch (err) {
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

    fn emitJump(self: *Compiler, op: OpCode, region: Region) !usize {
        try self.emitOp(op, region);
        // Dummy operands that will be patched later
        try self.chunk().writeShort(0xffff, region);
        return self.chunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Compiler, offset: usize, region: Region) !void {
        const jump = self.chunk().nextByteIndex() - offset - 2;

        std.debug.assert(self.chunk().read(offset) == 0xff);
        std.debug.assert(self.chunk().read(offset + 1) == 0xff);

        self.chunk().updateShortAt(offset, @as(u16, @intCast(jump))) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                try self.printError("Too much code to jump over.", region);
                return err;
            },
            else => return err,
        };
    }

    fn emitByte(self: *Compiler, byte: u8, region: Region) !void {
        try self.chunk().write(byte, region);
    }

    fn emitOp(self: *Compiler, op: OpCode, region: Region) !void {
        try self.chunk().writeOp(op, region);
    }

    fn emitEnd(self: *Compiler) !void {
        const r = self.chunk().regions.getLast();
        try self.chunk().writeOp(.End, Region.new(r.end, r.end));
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, region: Region) !void {
        try self.emitOp(op, region);
        try self.emitByte(byte, region);
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

    fn printError(self: *Compiler, message: []const u8, region: Region) !void {
        try region.printLineRelative(self.vm.source, self.writers.err);
        try self.writers.err.print(" Error: {s}\n", .{message});
    }
};

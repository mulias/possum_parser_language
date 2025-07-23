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
        RangeNotValidInMergePattern,
        RangeNotValidInValueContext,
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
            .Object,
            .StringTemplate,
            .Conditional,
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
                    .Object,
                    .StringTemplate,
                    .Conditional,
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
            .Object,
            .StringTemplate,
            .Conditional,
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
            .Object,
            .StringTemplate,
            .Conditional,
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
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => {
                    try self.writeParserFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .ParamsOrArgs => @panic("internal error"), // always handled via CallOrDefineFunction
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
            .StringTemplate => |parts| {
                try self.writeStringTemplate(parts, region, .Parser);
            },
            .Conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeParser(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.ConditionalElse, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeParser(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
            },
            .ValueLabel,
            .Array,
            .Object,
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
                .Conditional,
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
                .Object => @panic("Internal Error: Object should never be a parser"),
                .StringTemplate => @panic("Internal Error: StringTemplate should be handled in main parser switch"),
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
                .Merge => {
                    try self.writePatternMerge(rnode);
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
            .Negation => |inner| {
                if (inner.node.asInfixOfType(.Merge)) |_| {
                    // Negated merge pattern - no extra destructure needed
                    try self.writePattern(rnode);
                } else {
                    try self.writePattern(rnode);
                    try self.emitOp(.Destructure, region);
                }
            },
            .ValueLabel => return error.InvalidAst,
            .Array => |elements| {
                try self.writeDestructurePatternArray(elements, region);
            },
            .Object => |pairs| {
                try self.writeDestructurePatternObject(pairs, region);
            },
            .StringTemplate => {
                try self.writePattern(rnode);
                try self.emitOp(.Destructure, region);
            },
            .Conditional => return error.InvalidAst,
        }
    }

    fn writePattern(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, false);
                },
                .Merge => {
                    try self.writePatternMerge(rnode);
                },
                else => {
                    try self.printError("Invalid infix operator in pattern", region);
                    return Error.InvalidAst;
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            => @panic("Internal Error: handled by writeDestructurePattern"),
            .ValueLabel,
            => @panic("todo"),
            .Array => @panic("Internal Error"), // handled by writeDestructurePatternArray
            .Object => @panic("Internal Error"), // handled by writeDestructurePatternObject
            .StringTemplate => |parts| {
                try self.writeStringTemplate(parts, region, .Value);
            },
            .Negation => |inner| {
                if (simplifyNegatedNumberNode(rnode)) |elem| {
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, region);
                } else {
                    try self.emitOp(.NegateNumber, region);
                    try self.writePattern(inner);
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
            .Conditional => {
                try self.printError("Conditional expressions not valid in patterns", region);
                return Error.InvalidAst;
            },
        }
    }

    const PatternPart = struct {
        node: *Ast.RNode,
        negated: bool,
    };

    fn writePatternMerge(self: *Compiler, rnode: *Ast.RNode) !void {
        const region = rnode.region;

        var jumpList = ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        const count = try self.writePrepareMergePattern(rnode);
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

    fn writePrepareMergePattern(self: *Compiler, rnode: *Ast.RNode) !u8 {
        // Collect all merge parts into a flat list before emitting any bytecode
        // Track if each part has been negated. At runtime negation is applied
        // to numbers, and throws an error for all other values.
        var parts = ArrayList(PatternPart).init(self.vm.allocator);
        defer parts.deinit();

        try self.collectMergePatternParts(rnode, &parts, false);

        for (parts.items) |part| {
            try self.writePrepareMergePatternPart(part.node);
            if (part.negated) {
                try self.emitOp(.NegateNumberPattern, part.node.region);
            }
        }

        return @intCast(parts.items.len);
    }

    fn collectMergePatternParts(self: *Compiler, rnode: *Ast.RNode, parts: *ArrayList(PatternPart), negated: bool) !void {
        switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    try self.collectMergePatternParts(infix.left, parts, negated);
                    try self.collectMergePatternParts(infix.right, parts, negated);
                },
                else => {
                    try parts.append(.{ .node = rnode, .negated = negated });
                },
            },
            .Negation => |inner| {
                try self.collectMergePatternParts(inner, parts, !negated);
            },
            else => {
                try parts.append(.{ .node = rnode, .negated = negated });
            },
        }
    }

    fn writePrepareMergePatternPart(self: *Compiler, rnode: *Ast.RNode) Error!void {
        switch (rnode.node) {
            .Object => |pairs| {
                var object = try Elem.DynElem.Object.create(self.vm, 0);
                const constId = try self.makeConstant(object.dyn.elem());
                try self.emitUnaryOp(.GetConstant, constId, rnode.region);

                for (pairs.items) |pair| {
                    if (try self.literalPatternToElem(pair.key)) |key_elem| {
                        if (try self.literalPatternToElem(pair.value)) |value_elem| {
                            const key_id = switch (key_elem) {
                                .String => |s| s,
                                else => @panic("Object key must be string"),
                            };
                            try object.members.put(key_id, value_elem);
                        } else {
                            const key_id = switch (key_elem) {
                                .String => |s| s,
                                else => @panic("Object key must be string"),
                            };
                            try object.members.put(key_id, self.placeholderVar());
                        }
                    } else {
                        try self.writePattern(pair.key);
                        try self.writePattern(pair.value);
                        try self.emitOp(.InsertKeyVal, rnode.region);
                    }
                }
            },
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    // Merge nodes within merge patterns should not generate separate merge bytecode
                    // This should not happen if collectMergePatternParts is working correctly
                    @panic("Unexpected merge node in writePrepareMergePatternPart");
                },
                else => {
                    try self.writePattern(rnode);
                },
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            => {
                try self.printError("Range is not valid in merge pattern", rnode.region);
                return Error.RangeNotValidInMergePattern;
            },
            .Negation => {
                // Negation is handled in pre-processing of the merge parts.
                @panic("Internal Error");
            },
            .ValueLabel => @panic("todo"),
            .Array => |elements| {
                var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
                for (elements.items) |element| {
                    if (try self.literalPatternToElem(element)) |elem| {
                        try array.append(elem);
                    } else {
                        try array.append(self.placeholderVar());
                    }
                }
                const constId = try self.makeConstant(array.dyn.elem());
                try self.emitUnaryOp(.GetConstant, constId, rnode.region);
            },
            .StringTemplate => {
                try self.writePattern(rnode);
            },
            .ElemNode => {
                try self.writePattern(rnode);
            },
            .Conditional => {
                try self.printError("Conditional expressions not valid in patterns", rnode.region);
                return Error.InvalidAst;
            },
        }
    }

    fn writeMergePattern(self: *Compiler, rnode: *Ast.RNode, jumpList: *ArrayList(usize)) Error!void {
        const region = rnode.region;

        var parts = ArrayList(PatternPart).init(self.vm.allocator);
        defer parts.deinit();
        try self.collectMergePatternParts(rnode, &parts, false);

        for (parts.items) |part| {
            if (part.negated) {
                try self.emitOp(.NegateNumberPattern, part.node.region);
            }
            try self.writeDestructurePattern(part.node);
            const jumpIndex = try self.emitJump(.JumpIfFailure, region);
            try self.emitOp(.Pop, region);
            try jumpList.append(jumpIndex);
        }
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
            .Object => |pairs| {
                for (pairs.items) |pair| {
                    try self.addValueLocals(pair.key);
                    try self.addValueLocals(pair.value);
                }
            },
            .StringTemplate => |parts| {
                for (parts.items) |part| {
                    try self.addValueLocals(part);
                }
            },
            .Conditional => |conditional| {
                try self.addValueLocals(conditional.condition);
                try self.addValueLocals(conditional.then_branch);
                try self.addValueLocals(conditional.else_branch);
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
            .Object => |pairs| {
                for (pairs.items) |pair| {
                    try self.addClosureLocals(pair.key);
                    try self.addClosureLocals(pair.value);
                }
            },
            .StringTemplate => |parts| {
                for (parts.items) |part| {
                    try self.addClosureLocals(part);
                }
            },
            .Conditional => |conditional| {
                try self.addClosureLocals(conditional.condition);
                try self.addClosureLocals(conditional.then_branch);
                try self.addClosureLocals(conditional.else_branch);
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
                else => try writeValue(self, rnode, isTailPosition),
            },
            .Negation => |inner| {
                try self.writeValueArgument(inner, false);
                try self.emitOp(.NegateNumber, region);
            },
            .ValueLabel => |inner| {
                try self.writeValue(inner, isTailPosition);
            },
            .StringTemplate => {
                return error.UnlabeledStringValue;
            },
            .Conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValueArgument(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeValueArgument(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.ConditionalElse, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeValueArgument(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
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
                .CallOrDefineFunction => {
                    try self.writeValueFunctionCall(infix.left, infix.right, isTailPosition);
                },
                .Range => {
                    try self.printError("Character and integer ranges are not valid in value", region);
                    return Error.InvalidAst;
                },
                .DeclareGlobal, // handled by top-level compiler functions
                .ParamsOrArgs, // handled by CallOrDefineFunction
                => @panic("internal error"),
            },
            .UpperBoundedRange,
            .LowerBoundedRange,
            => {
                try self.printError("Range is not valid in value context", region);
                return Error.RangeNotValidInValueContext;
            },
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
            .Object => |pairs| {
                try self.writeValueObject(pairs, region);
            },
            .StringTemplate => |parts| {
                try self.writeStringTemplate(parts, region, .Value);
            },
            .Conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeValue(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.ConditionalElse, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeValue(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
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
            if (try self.literalPatternToElem(element)) |elem| {
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

    fn writeDestructurePatternObject(self: *Compiler, pairs: std.ArrayListUnmanaged(Ast.ObjectPair), region: Region) Error!void {
        var object = try Elem.DynElem.Object.create(self.vm, 0);
        const constId = try self.makeConstant(object.dyn.elem());
        try self.emitUnaryOp(.GetConstant, constId, region);

        for (pairs.items) |pair| {
            if (try self.literalPatternToElem(pair.key)) |key_elem| {
                if (try self.literalPatternToElem(pair.value)) |value_elem| {
                    const key_id = switch (key_elem) {
                        .String => |s| s,
                        else => @panic("Object key must be string"),
                    };
                    try object.members.put(key_id, value_elem);
                } else {
                    const key_id = switch (key_elem) {
                        .String => |s| s,
                        else => @panic("Object key must be string"),
                    };
                    try object.members.put(key_id, self.placeholderVar());
                }
            } else {
                try self.writePattern(pair.key);
                try self.writePattern(pair.value);
                try self.emitOp(.InsertKeyVal, region);
            }
        }

        try self.emitOp(.Destructure, region);

        // Note: This is an optimization which is probably incorrect.
        if (pairs.items.len == 0) {
            return;
        }

        const failureJumpIndex = try self.emitJump(.JumpIfFailure, region);
        var jumpList = std.ArrayList(usize).init(self.vm.allocator);
        defer jumpList.deinit();

        for (pairs.items) |pair| {
            if (!self.isLiteralPattern(pair.value)) {
                if (try self.literalPatternToElem(pair.key)) |key_elem| {
                    const constId_key = try self.makeConstant(key_elem);
                    try self.emitUnaryOp(.GetConstant, constId_key, pair.key.region);
                } else {
                    // Dynamic key case
                    try self.writePattern(pair.key);
                }
                try self.emitOp(.GetAtKey, pair.key.region);
                try self.writeDestructurePattern(pair.value);
                const jumpIndex = try self.emitJump(.JumpIfFailure, pair.value.region);
                try jumpList.append(jumpIndex);
                try self.emitOp(.Pop, pair.value.region);
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

    fn negateAndAppendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) !void {
        try self.writeValue(rnode, false);
        try self.emitOp(.NegateNumber, region);
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
            .Object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(emptyObject.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index, region);
                }
            },
            .StringTemplate => try self.appendDynamicValue(array, rnode, index, region),
            .UpperBoundedRange,
            .LowerBoundedRange,
            => {
                try self.printError("Range is not valid in value context", region);
                return Error.RangeNotValidInValueContext;
            },
            .Conditional => try self.appendDynamicValue(array, rnode, index, region),
            .Negation => |inner| {
                if (simplifyNegatedNumberNode(rnode)) |elem| {
                    try array.append(elem);
                } else {
                    try self.negateAndAppendDynamicValue(array, inner, index, region);
                }
            },
            .ValueLabel => @panic("todo"),
        }
    }

    fn writeValueObject(self: *Compiler, pairs: std.ArrayListUnmanaged(Ast.ObjectPair), region: Region) Error!void {
        var object = try Elem.DynElem.Object.create(self.vm, 0);
        const constId = try self.makeConstant(object.dyn.elem());
        try self.emitUnaryOp(.GetConstant, constId, region);

        for (pairs.items) |pair| {
            if (try self.literalPatternToElem(pair.key)) |key_elem| {
                if (try self.literalPatternToElem(pair.value)) |val_elem| {
                    const key_sId = key_elem.String;
                    try object.members.put(key_sId, val_elem);
                } else {
                    try self.writeValueObjectVal(pair.value, key_elem);
                }
            } else {
                try self.writeValue(pair.key, false);
                try self.writeValue(pair.value, false);
                try self.emitOp(.InsertKeyVal, pair.key.region);
            }
        }
    }

    fn writeValueObjectVal(self: *Compiler, rnode: *Ast.RNode, key: Elem) Error!void {
        const region = rnode.region;
        const constId = try self.makeConstant(key);

        try self.writeValue(rnode, false);
        try self.emitUnaryOp(.InsertAtKey, constId, region);
    }

    const StringTemplateContext = enum { Parser, Value };

    fn writeStringTemplate(self: *Compiler, parts: std.ArrayListUnmanaged(*Ast.RNode), region: Region, context: StringTemplateContext) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];
        const firstPartIsString = firstPart.node.asElem() != null and firstPart.node.asElem().? == .String;

        if (!firstPartIsString) {
            const empty_string = try self.makeConstant(Elem.string(try self.vm.strings.insert("")));
            try self.emitUnaryOp(.GetConstant, empty_string, region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeStringTemplatePart(part, context);
            if (i > 0 or !firstPartIsString) {
                try self.emitOp(.MergeAsString, region);
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
            .Array => |elements| elements.items.len == 0,
            .Object => |pairs| pairs.items.len == 0,
            else => false,
        };
    }

    fn literalPatternToElem(self: *Compiler, rnode: *Ast.RNode) !?Elem {
        return switch (rnode.node) {
            .ElemNode => |elem| switch (elem) {
                .String, .InputSubstring, .NumberString, .Integer, .Float, .Boolean, .Null => elem,
                else => null,
            },
            .Array => |elements| if (elements.items.len == 0) blk: {
                var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                break :blk emptyArray.dyn.elem();
            } else null,
            .Object => |pairs| if (pairs.items.len == 0) blk: {
                var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                break :blk emptyObject.dyn.elem();
            } else null,
            else => null,
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

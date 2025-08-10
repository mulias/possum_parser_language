const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const unicode = std.unicode;
const AnyWriter = std.io.AnyWriter;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("chunk.zig").Chunk;
const ChunkError = @import("chunk.zig").ChunkError;
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const Region = @import("region.zig").Region;
const OpCode = @import("op_code.zig").OpCode;
const Scanner = @import("scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const Writers = @import("writer.zig").Writers;
const Module = @import("module.zig").Module;

pub const Compiler = struct {
    vm: *VM,
    targetModule: *Module,
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
        TooManyPatterns,
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
    } || AnyWriter.Error;

    pub fn init(vm: *VM, targetModule: *Module, ast: Ast, printBytecode: bool) !Compiler {
        const main = try Elem.DynElem.Function.create(vm, .{
            .name = try vm.strings.insert("@main"),
            .functionType = .Main,
            .arity = 0,
            .region = undefined,
        });

        var functions = ArrayList(*Elem.DynElem.Function){};
        try functions.append(vm.allocator, main);

        try targetModule.addGlobal(vm.allocator, main.name, main.dyn.elem());

        // Ensure that the strings table includes the placeholder var, which
        // might be used directly by the compiler.
        _ = try vm.strings.insert("_");

        return Compiler{
            .vm = vm,
            .targetModule = targetModule,
            .ast = ast,
            .functions = functions,
            .writers = vm.writers,
            .printBytecode = printBytecode,
        };
    }

    fn findGlobal(self: *Compiler, name: StringTable.Id) ?Elem {
        const targetModuleIndex = for (self.vm.modules.items, 0..) |*module, i| {
            if (module == self.targetModule) break i;
        } else return null;

        // Search backwards through modules up to and including the target module
        var i = targetModuleIndex + 1;
        while (i > 0) {
            i -= 1;
            if (self.vm.modules.items[i].getGlobal(name)) |elem| {
                return elem;
            }
        }
        return null;
    }

    pub fn deinit(self: *Compiler) void {
        self.functions.deinit(self.vm.allocator);
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
            if (root.node == .DeclareGlobal) {
                const global = root.node.DeclareGlobal;
                try self.declareGlobal(global.head, global.body, root.region);
            }
        }
    }

    fn validateGlobals(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node == .DeclareGlobal) {
                const global = root.node.DeclareGlobal;
                try self.validateGlobal(global.head);
            }
        }
    }

    fn resolveGlobalAliases(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node == .DeclareGlobal) {
                const global = root.node.DeclareGlobal;
                try self.resolveGlobalAlias(global.head);
            }
        }
    }

    fn compileGlobalFunctions(self: *Compiler) !void {
        for (self.ast.roots.items) |root| {
            if (root.node == .DeclareGlobal) {
                const global = root.node.DeclareGlobal;
                try self.compileGlobalFunction(global.head, global.body);
            }
        }
    }

    fn compileMain(self: *Compiler) !?*Elem.DynElem.Function {
        var main: ?*Ast.RNode = null;

        for (self.ast.roots.items) |root| {
            if (root.node != .DeclareGlobal) {
                if (main == null) {
                    main = root;
                } else {
                    try self.printError(root.region, "Only one main parser expression is allowed per module", .{});
                    return Error.MultipleMainParsers;
                }
            }
        }

        if (main) |main_rnode| {
            try self.addValueLocals(main_rnode);
            try self.writeParser(main_rnode, false);
            try self.emitEnd();

            const main_fn = self.functions.pop() orelse @panic("Internal Error: No Main Function");

            // Update the main function's source region with the actual main parser region
            main_fn.chunk.sourceRegion = main_rnode.region;

            if (self.printBytecode) {
                try main_fn.disassemble(self.vm.*, self.writers.debug, self.targetModule);
            }

            return main_fn;
        } else {
            return null;
        }
    }

    fn declareGlobal(self: *Compiler, head: *Ast.RNode, body: *Ast.RNode, region: Region) !void {
        switch (head.node) {
            .Function => |function| {
                try self.declareGlobalFunction(function.name, function.paramsOrArgs, region);
            },
            .ElemNode => |nameElem| switch (body.node) {
                .ElemNode => |bodyElem| {
                    try self.declareGlobalAlias(nameElem, bodyElem);
                },
                else => {
                    // A function without params
                    try self.declareGlobalFunction(head, ArrayList(*Ast.RNode){}, region);
                },
            },
            .InfixNode,
            .Range,
            .Negation,
            .ValueLabel,
            .Array,
            .Object,
            .StringTemplate,
            .Conditional,
            .DeclareGlobal,
            => return Error.InvalidAst,
        }
    }

    fn declareGlobalFunction(self: *Compiler, name: *Ast.RNode, params: ArrayList(*Ast.RNode), region: Region) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const nameElem = name.node.asElem() orelse return Error.InvalidAst;
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name_sid = switch (nameVar.getType()) {
            .ValueVar => nameVar.asValueVar(),
            .ParserVar => nameVar.asParserVar(),
            else => return Error.InvalidAst,
        };
        const functionType: Elem.DynElem.FunctionType = switch (nameVar.getType()) {
            .ValueVar => .NamedValue,
            .ParserVar => .NamedParser,
            else => return Error.InvalidAst,
        };

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .name = name_sid,
            .functionType = functionType,
            .arity = 0,
            .region = region,
        });

        try self.targetModule.addGlobal(self.vm.allocator, name_sid, function.dyn.elem());

        try self.functions.append(self.vm.allocator, function);

        for (params.items) |param| {
            if (param.node.asElem()) |elem| {
                _ = try self.addLocal(elem, param.region);
                function.arity += 1;
            } else {
                return Error.InvalidAst;
            }
        }

        _ = self.functions.pop();
    }

    fn declareGlobalAlias(self: *Compiler, nameElem: Elem, bodyElem: Elem) !void {
        // Add an alias to the global namespace. Set the given body element as the alias's value.
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar.getType()) {
            .ValueVar => nameVar.asValueVar(),
            .ParserVar => nameVar.asParserVar(),
            else => return Error.InvalidAst,
        };

        try self.targetModule.addGlobal(self.vm.allocator, name, bodyElem);
    }

    fn validateGlobal(self: *Compiler, head: *Ast.RNode) !void {
        const nameElem = switch (head.node) {
            .Function => |function| function.name.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .InfixNode,
            .Range,
            .Negation,
            .ValueLabel,
            .Array,
            .Object,
            .StringTemplate,
            .Conditional,
            .DeclareGlobal,
            => return Error.InvalidAst,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;

        switch (nameVar.getType()) {
            .ValueVar => {
                const name = nameVar.asValueVar();
                const global = self.findGlobal(name).?;
                switch (global.getType()) {
                    .ValueVar,
                    .String,
                    .NumberString,
                    .Const,
                    => {},
                    .ParserVar,
                    => return Error.InvalidGlobalValue,
                    .Dyn => switch (global.asDyn().dynType) {
                        .String,
                        .Array,
                        .Object,
                        .NativeCode,
                        => {},
                        .Function => {
                            if (global.asDyn().asFunction().functionType != .NamedValue) {
                                return Error.InvalidGlobalValue;
                            }
                        },
                        .Closure => @panic("Internal Error"),
                    },
                    .InputSubstring,
                    .NumberFloat,
                    => @panic("Internal Error"),
                }
            },
            .ParserVar => {
                const name = nameVar.asParserVar();
                const global = self.findGlobal(name).?;
                switch (global.getType()) {
                    .ParserVar,
                    .String,
                    .NumberString,
                    => {},
                    .ValueVar => return Error.InvalidGlobalParser,
                    .Dyn => switch (global.asDyn().dynType) {
                        .String,
                        .NativeCode,
                        => {},
                        .Array,
                        .Object,
                        => return Error.InvalidGlobalParser,
                        .Function => {
                            if (global.asDyn().asFunction().functionType != .NamedParser) {
                                return Error.InvalidGlobalParser;
                            }
                        },
                        .Closure => @panic("Internal Error"),
                    },
                    .InputSubstring,
                    .Const,
                    .NumberFloat,
                    => @panic("Internal Error"),
                }
            },
            else => @panic("Internal Error"),
        }
    }

    fn resolveGlobalAlias(self: *Compiler, head: *Ast.RNode) !void {
        const globalName = try self.getGlobalName(head);
        var aliasName = globalName;
        var value = self.findGlobal(aliasName);

        if (!value.?.isType(.ValueVar) and !value.?.isType(.ParserVar)) {
            return;
        }

        var path = ArrayList(StringTable.Id){};
        defer path.deinit(self.vm.allocator);

        while (true) {
            if (value) |foundValue| {
                try path.append(self.vm.allocator, aliasName);

                aliasName = switch (foundValue.getType()) {
                    .ValueVar => foundValue.asValueVar(),
                    .ParserVar => foundValue.asParserVar(),
                    else => {
                        try self.targetModule.addGlobal(self.vm.allocator, globalName, foundValue);
                        break;
                    },
                };

                for (path.items) |aliasVisited| {
                    if (aliasName == aliasVisited) {
                        const aliasNameStr = self.vm.strings.get(aliasName);
                        try self.printError(head.region, "Circular alias dependency detected for '{s}'", .{aliasNameStr});
                        return Error.AliasCycle;
                    }
                }

                value = self.findGlobal(aliasName);
            } else {
                const aliasNameStr = self.vm.strings.get(aliasName);
                try self.printError(head.region, "Unknown variable '{s}' in alias chain", .{aliasNameStr});
                return Error.UnknownVariable;
            }
        }
    }

    fn compileGlobalFunction(self: *Compiler, head: *Ast.RNode, body: *Ast.RNode) !void {
        const globalName = try self.getGlobalName(head);
        const globalVal = self.findGlobal(globalName).?;

        // Exit early if the node is an alias, not a function def
        if (head.node.asElem() != null and body.node.asElem() != null) {
            return;
        }

        if (globalVal.isDynType(.Function)) {
            const function = globalVal.asDyn().asFunction();

            try self.functions.append(self.vm.allocator, function);

            if (function.functionType == .NamedParser) {
                try self.addValueLocals(body);
                try self.writeParser(body, true);
            } else {
                try self.addValueLocals(body);
                try self.writeValue(body, true);
            }

            try self.emitEnd();

            if (self.printBytecode) {
                try function.disassemble(self.vm.*, self.writers.debug, self.targetModule);
            }

            _ = self.functions.pop();
        }
    }

    fn getGlobalName(self: *Compiler, head: *Ast.RNode) !StringTable.Id {
        const nameElem = switch (head.node) {
            .Function => |function| function.name.node.asElem() orelse return Error.InvalidAst,
            .ElemNode => |elem| elem,
            .InfixNode,
            .Range,
            .Negation,
            .ValueLabel,
            .Array,
            .Object,
            .StringTemplate,
            .Conditional,
            .DeclareGlobal,
            => return Error.InvalidAst,
        };
        const nameVar = try self.elemToVar(nameElem) orelse return Error.InvalidAst;
        const name = switch (nameVar.getType()) {
            .ValueVar => nameVar.asValueVar(),
            .ParserVar => nameVar.asParserVar(),
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
                    try self.writeParser(infix.right, false);
                    try self.emitOp(.Merge, region);
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
                    const patternId = try self.createPattern(infix.right);
                    try self.emitUnaryOp(.Destructure, patternId, region);
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
            },
            .DeclareGlobal => unreachable, // handled by top-level compiler functions
            .Range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    const low = bounds.lower.?;
                    const high = bounds.upper.?;
                    const low_elem = try getParserRangeElemNode(low);
                    const high_elem = try getParserRangeElemNode(high);

                    if (low_elem.isType(.String) and high_elem.isType(.String)) {
                        const low_str = low_elem.asString();
                        const high_str = high_elem.asString();
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
                    } else if (low_elem.isType(.NumberString) and high_elem.isType(.NumberString)) {
                        const low_ns = low_elem.asNumberString();
                        const high_ns = high_elem.asNumberString();

                        const low_num = low_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                        const high_num = high_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                        const low_f = low_num.asFloat();
                        const high_f = high_num.asFloat();

                        if (@trunc(low_f) != low_f) return Error.RangeInvalidNumberFormat;
                        if (@trunc(high_f) != high_f) return Error.RangeInvalidNumberFormat;

                        if (low_f > high_f) {
                            return Error.RangeIntegersUnordered;
                        } else {
                            const low_id = try self.makeConstant(low_num);
                            const high_id = try self.makeConstant(high_num);
                            try self.emitOp(.ParseRange, region);
                            try self.emitByte(low_id, low.region);
                            try self.emitByte(high_id, high.region);
                        }
                    } else {
                        return Error.InvalidAst;
                    }
                } else if (bounds.lower != null) {
                    const low = bounds.lower.?;
                    const low_elem = try getParserRangeElemNode(low);
                    const low_region = low.region;

                    if (low_elem.isType(.String)) {
                        const low_str = low_elem.asString();
                        const low_bytes = self.vm.strings.get(low_str);
                        const low_codepoint = unicode.utf8Decode(low_bytes) catch return Error.RangeNotSingleCodepoint;

                        if (low_codepoint == 0) {
                            try self.emitOp(.ParseCharacter, region);
                        } else {
                            const low_id = try self.makeConstant(low_elem);
                            try self.emitOp(.ParseLowerBoundedRange, region);
                            try self.emitByte(low_id, low_region);
                        }
                    } else if (low_elem.isType(.NumberString)) {
                        const low_ns = low_elem.asNumberString();
                        const low_num = low_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                        const low_f = low_num.asFloat();

                        if (@trunc(low_f) != low_f) return Error.RangeInvalidNumberFormat;

                        const low_id = try self.makeConstant(low_num);
                        try self.emitOp(.ParseLowerBoundedRange, region);
                        try self.emitByte(low_id, low_region);
                    } else {
                        return Error.InvalidAst;
                    }
                } else {
                    const high = bounds.upper.?;
                    const high_elem = try getParserRangeElemNode(high);
                    const high_region = high.region;

                    if (high_elem.isType(.String)) {
                        const high_str = high_elem.asString();
                        const high_bytes = self.vm.strings.get(high_str);
                        const high_codepoint = unicode.utf8Decode(high_bytes) catch return Error.RangeNotSingleCodepoint;

                        if (high_codepoint == 0x10ffff) {
                            try self.emitOp(.ParseCharacter, region);
                        } else {
                            const high_id = try self.makeConstant(high_elem);
                            try self.emitOp(.ParseUpperBoundedRange, region);
                            try self.emitByte(high_id, high_region);
                        }
                    } else if (high_elem.isType(.NumberString)) {
                        const high_ns = high_elem.asNumberString();
                        const high_num = high_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                        const high_f = high_num.asFloat();

                        if (@trunc(high_f) != high_f) return Error.RangeInvalidNumberFormat;

                        const high_id = try self.makeConstant(high_num);
                        try self.emitOp(.ParseUpperBoundedRange, region);
                        try self.emitByte(high_id, high_region);
                    } else {
                        return Error.InvalidAst;
                    }
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
            .Function => |function| {
                try self.writeParserFunctionCall(function.name, function.paramsOrArgs, region, isTailPosition);
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

    fn writeParserFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.RNode,
        arguments: ArrayList(*Ast.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        const function_elem = function_rnode.node.asElem() orelse @panic("internal error");
        const function_region = function_rnode.region;

        const functionName = switch (function_elem.getType()) {
            .ParserVar => function_elem.asParserVar(),
            .Const => try self.vm.strings.insert(function_elem.asConst().bytes()),
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.findGlobal(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, function_region);
            } else {
                const functionNameStr = self.vm.strings.get(functionName);
                try self.printError(function_region, "Undefined function '{s}'", .{functionNameStr});
                return Error.UndefinedVariable;
            }
        }

        const arg_count = try self.writeParserFunctionArguments(arguments, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, arg_count, call_region);
        } else {
            try self.emitUnaryOp(.CallFunction, arg_count, call_region);
        }
    }

    fn writeParserElem(self: *Compiler, rnode: *Ast.RNode) !void {
        const region = rnode.region;

        switch (rnode.node) {
            .ElemNode => |elem| {
                switch (elem.getType()) {
                    .ParserVar => {
                        try self.writeGetVar(elem, region);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .ValueVar => {
                        try self.printError(region, "Variable is only valid as a pattern or value", .{});
                        return Error.InvalidAst;
                    },
                    .String,
                    .NumberString,
                    => {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                    },
                    .Const => switch (elem.asConst()) {
                        .True, .False, .Null => {
                            // In this context `true`/`false`/`null` could be a zero-arg function call
                            try self.writeGetVar(elem, region);
                            try self.emitUnaryOp(.CallFunction, 0, region);
                        },
                        .Failure => return Error.InvalidAst,
                    },
                    .NumberFloat,
                    .InputSubstring,
                    .Dyn,
                    => @panic("Internal Error"),
                }
            },
            else => @panic("Internal Error"),
        }
    }

    fn writeGetVar(self: *Compiler, elem: Elem, region: Region) !void {
        const varName = switch (elem.getType()) {
            .ParserVar => elem.asParserVar(),
            .ValueVar => elem.asValueVar(),
            .Const => switch (elem.asConst()) {
                .True => try self.vm.strings.insert("true"),
                .False => try self.vm.strings.insert("false"),
                .Null => try self.vm.strings.insert("null"),
                .Failure => return Error.InvalidAst,
            },
            else => return Error.InvalidAst,
        };

        if (self.localSlot(varName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, region);
        } else {
            if (self.findGlobal(varName)) |globalElem| {
                const constId = try self.makeConstant(globalElem);
                try self.emitUnaryOp(.GetConstant, constId, region);
            } else {
                const varNameStr = self.vm.strings.get(varName);
                try self.printError(region, "Undefined variable '{s}'", .{varNameStr});
                return Error.UndefinedVariable;
            }
        }
    }

    fn elemToVar(self: *Compiler, elem: Elem) !?Elem {
        return switch (elem.getType()) {
            .ParserVar,
            .ValueVar,
            => elem,
            .Const => switch (elem.asConst()) {
                .True => Elem.parserVar(try self.vm.strings.insert("true")),
                .False => Elem.parserVar(try self.vm.strings.insert("false")),
                .Null => Elem.parserVar(try self.vm.strings.insert("null")),
                .Failure => null,
            },
            else => null,
        };
    }

    const ArgType = enum { Parser, Value, Unspecified };

    fn writeParserFunctionArguments(
        self: *Compiler,
        arguments: ArrayList(*Ast.RNode),
        function: ?*Elem.DynElem.Function,
    ) Error!u8 {
        const arg_count = arguments.items.len;

        if (arg_count > std.math.maxInt(u8)) {
            const first_arg = arguments.items[0];
            const last_arg = arguments.items[arg_count - 1];
            const region = first_arg.region.merge(last_arg.region);

            try self.printError(
                region,
                "Can't have more than {} parameters.",
                .{std.math.maxInt(u8)},
            );
            return Error.MaxFunctionArgs;
        }

        if (function) |f| {
            if (f.arity != arg_count) {
                const functionNameStr = self.vm.strings.get(f.name);
                const region = if (arguments.items.len > 0) blk: {
                    const first_arg = arguments.items[0];
                    const last_arg = arguments.items[arg_count - 1];
                    break :blk first_arg.region.merge(last_arg.region);
                } else blk: {
                    // For zero-argument functions, we don't have argument regions,
                    // so we'll need to handle this case differently
                    break :blk Region.new(0, 0);
                };

                if (f.arity < arg_count) {
                    try self.printError(region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooManyArgs;
                } else {
                    try self.printError(region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooFewArgs;
                }
            }
        }

        for (arguments.items, 0..) |arg, i| {
            const argType: ArgType = if (function) |f| blk: {
                switch (f.localVar(@intCast(i))) {
                    .ParserVar => break :blk .Parser,
                    .ValueVar => break :blk .Value,
                }
            } else .Unspecified;

            try self.writeParserFunctionArgument(arg, argType);
        }

        return @intCast(arg_count);
    }

    fn writeParserFunctionArgument(self: *Compiler, rnode: *Ast.RNode, argType: ArgType) !void {
        const region = rnode.region;

        switch (argType) {
            .Parser => switch (rnode.node) {
                .InfixNode,
                .Range,
                .Negation,
                .Conditional,
                .Function,
                .DeclareGlobal,
                => {
                    const function = try self.writeAnonymousFunction(rnode);
                    const constId = try self.makeConstant(function.dyn.elem());
                    try self.emitUnaryOp(.GetConstant, constId, region);
                    try self.writeCaptureLocals(function, region);
                },
                .ElemNode => |elem| {
                    if (elem.isType(.ParserVar)) {
                        try self.writeGetVar(elem, region);
                    } else {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    }
                },
                .ValueLabel => {
                    try self.printError(region, "Labeled value is not valid as parser function argument.", .{});
                    return Error.InvalidAst;
                },
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

        const function = try Elem.DynElem.Function.createAnonParser(
            self.vm,
            .{ .arity = 0, .region = region },
        );

        try self.functions.append(self.vm.allocator, function);

        try self.addClosureLocals(rnode);

        if (function.locals.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, region);
        }

        try self.writeParser(rnode, true);
        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug, self.targetModule);
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

    fn createPattern(self: *Compiler, rnode: *Ast.RNode) Error!u8 {
        const patternElem = try self.astToPattern(rnode, 0);
        return self.chunk().addPattern(patternElem);
    }

    fn astToPattern(self: *Compiler, rnode: *Ast.RNode, negation_count: u2) Error!Pattern {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .ElemNode => |elem| switch (elem.getType()) {
                .ValueVar => {
                    const name = elem.asValueVar();
                    if (self.findGlobal(name)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        return Pattern{ .Constant = .{
                            .sid = name,
                            .idx = constId,
                            .negation_count = negation_count,
                        } };
                    } else if (self.localSlot(name)) |slot| {
                        return Pattern{ .Local = .{
                            .sid = name,
                            .idx = slot,
                            .negation_count = negation_count,
                        } };
                    } else {
                        @panic("Internal Error");
                    }
                },
                .String => {
                    if (negation_count > 0) {
                        try self.printError(region, "Invalid pattern - unable to negate string", .{});
                        return Error.InvalidAst;
                    }
                    return Pattern{ .String = elem.asString() };
                },
                .NumberString => {
                    const ns = elem.asNumberString();
                    const number = if (negation_count % 2 == 1) ns.negate() else ns;
                    return Pattern{ .NumberString = number };
                },
                .Const => switch (elem.asConst()) {
                    .True => {
                        if (negation_count > 0) {
                            try self.printError(region, "Invalid pattern - unable to negate boolean", .{});
                            return Error.InvalidAst;
                        }
                        return Pattern{ .Boolean = true };
                    },
                    .False => {
                        if (negation_count > 0) {
                            try self.printError(region, "Invalid pattern - unable to negate boolean", .{});
                            return Error.InvalidAst;
                        }
                        return Pattern{ .Boolean = false };
                    },
                    .Null => {
                        if (negation_count > 0) {
                            try self.printError(region, "Invalid pattern - unable to negate null", .{});
                            return Error.InvalidAst;
                        }
                        return Pattern{ .Null = undefined };
                    },
                    .Failure => return Error.InvalidAst,
                },
                .ParserVar => {
                    try self.printError(region, "Parser variable not allowed in pattern", .{});
                    return Error.InvalidAst;
                },
                else => {
                    try self.printError(region, "Invalid AST in pattern", .{});
                    return Error.InvalidAst;
                },
            },
            .Array => |elements| {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate array", .{});
                    return Error.InvalidAst;
                }

                var patternElems = ArrayList(Pattern){};
                try patternElems.ensureTotalCapacity(self.vm.allocator, elements.items.len);

                for (elements.items) |elementNode| {
                    const elementPattern = try self.astToPattern(elementNode, 0);
                    try patternElems.append(self.vm.allocator, elementPattern);
                }

                return Pattern{ .Array = patternElems };
            },
            .Object => |pairs| {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate object", .{});
                    return Error.InvalidAst;
                }

                var objectPairs = ArrayList(Pattern.ObjectPair){};
                try objectPairs.ensureTotalCapacity(self.vm.allocator, pairs.items.len);

                for (pairs.items) |pair| {
                    try objectPairs.append(self.vm.allocator, .{
                        .key = try self.astToPattern(pair.key, 0),
                        .value = try self.astToPattern(pair.value, 0),
                    });
                }

                return Pattern{ .Object = objectPairs };
            },
            .StringTemplate => |segments| {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }

                var templateElems = ArrayList(Pattern){};
                try templateElems.ensureTotalCapacity(self.vm.allocator, segments.items.len);

                for (segments.items) |segmentNode| {
                    const segmentPattern = try self.astToPattern(segmentNode, 0);
                    try templateElems.append(self.vm.allocator, segmentPattern);
                }

                return Pattern{ .StringTemplate = templateElems };
            },
            .Range => |bounds| {
                var lowerPattern: ?*Pattern = null;
                var upperPattern: ?*Pattern = null;

                if (bounds.lower) |lower| {
                    lowerPattern = try self.vm.allocator.create(Pattern);
                    lowerPattern.?.* = try self.astToPattern(lower, negation_count);
                }

                if (bounds.upper) |upper| {
                    upperPattern = try self.vm.allocator.create(Pattern);
                    upperPattern.?.* = try self.astToPattern(upper, negation_count);
                }

                return Pattern{ .Range = .{
                    .lower = lowerPattern,
                    .upper = upperPattern,
                } };
            },
            .Negation => |inner| {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                return self.astToPattern(inner, new_negation_count);
            },
            .Function => |function| {
                const nameNode = function.name.node;

                const functionName = switch (nameNode) {
                    .ElemNode => |elem| switch (elem.getType()) {
                        .ValueVar => elem.asValueVar(),
                        else => return Error.InvalidAst,
                    },
                    else => return Error.InvalidAst,
                };

                const globalFunctionElem = self.findGlobal(functionName);

                const functionVar: Pattern.PatternVar = if (globalFunctionElem) |globalElem|
                    .{
                        .sid = functionName,
                        .idx = try self.makeConstant(globalElem),
                        .negation_count = negation_count,
                    }
                else if (self.localSlot(functionName)) |slot|
                    .{
                        .sid = functionName,
                        .idx = slot,
                        .negation_count = negation_count,
                    }
                else {
                    try self.printError(function.name.region, "Unknown function in pattern", .{});
                    return Error.InvalidAst;
                };

                var args = ArrayList(Pattern){};
                for (function.paramsOrArgs.items) |arg| {
                    const argPattern = try self.astToPattern(arg, 0);
                    try args.append(self.vm.allocator, argPattern);
                }

                return Pattern{ .FunctionCall = .{
                    .function = functionVar,
                    .kind = if (globalFunctionElem != null) .Constant else .Local,
                    .args = args,
                } };
            },
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => {
                    var mergeElems = ArrayList(Pattern){};
                    try self.collectPatternMergeElements(rnode, &mergeElems, negation_count);
                    return Pattern{ .Merge = mergeElems };
                },
                .Destructure => {
                    try self.printError(region, "Invalid AST: Nested destructure not allowed in pattern", .{});
                    return Error.InvalidAst;
                },
                else => {
                    try self.printError(region, "Invalid AST in pattern", .{});
                    return Error.InvalidAst;
                },
            },
            else => {
                try self.printError(region, "Invalid AST in pattern", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn collectPatternMergeElements(self: *Compiler, rnode: *Ast.RNode, elements: *ArrayList(Pattern), negation_count: u2) Error!void {
        const node = rnode.node;

        switch (node) {
            .InfixNode => |infix| {
                if (infix.infixType == .Merge) {
                    try self.collectPatternMergeElements(infix.left, elements, negation_count);
                    try self.collectPatternMergeElements(infix.right, elements, negation_count);
                    return;
                }
            },
            else => {},
        }

        // Merge pattern part
        const pattern = try self.astToPattern(rnode, negation_count);
        try elements.append(self.vm.allocator, pattern);
    }

    fn addValueLocals(self: *Compiler, rnode: *Ast.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .InfixNode => |infix| {
                try self.addValueLocals(infix.left);
                try self.addValueLocals(infix.right);
            },
            .Function => |function| {
                for (function.paramsOrArgs.items) |arg| {
                    try self.addValueLocals(arg);
                }
            },
            .Range => |bounds| {
                if (bounds.lower) |lower| try self.addValueLocals(lower);
                if (bounds.upper) |upper| try self.addValueLocals(upper);
            },
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
            .DeclareGlobal => |declaration| {
                try self.addValueLocals(declaration.head);
                try self.addValueLocals(declaration.body);
            },
            .ElemNode => |elem| switch (elem.getType()) {
                .ValueVar => if (self.findGlobal(elem.asValueVar()) == null) {
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
            .Function => |function| {
                for (function.paramsOrArgs.items) |arg| {
                    try self.addClosureLocals(arg);
                }
            },
            .Range => |bounds| {
                if (bounds.lower) |lower| try self.addClosureLocals(lower);
                if (bounds.upper) |upper| try self.addClosureLocals(upper);
            },
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
            .DeclareGlobal => @panic("internal error"),
            .ElemNode => |elem| {
                const varName = switch (elem.getType()) {
                    .ValueVar => elem.asValueVar(),
                    .ParserVar => elem.asParserVar(),
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
                    try self.writeValueArgument(infix.right, false);
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
                    const patternId = try self.createPattern(infix.right);
                    try self.emitUnaryOp(.Destructure, patternId, region);
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
            .ElemNode => |elem| switch (elem.getType()) {
                .String => {
                    return error.UnlabeledStringValue;
                },
                .NumberString => {
                    return error.UnlabeledNumberValue;
                },
                .Const => switch (elem.asConst()) {
                    .True, .False => return error.UnlabeledBooleanValue,
                    .Null => return error.UnlabeledNullValue,
                    .Failure => return Error.InvalidAst,
                },
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
                    try self.writeValue(infix.right, false);
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
                    const patternId = try self.createPattern(infix.right);
                    try self.emitUnaryOp(.Destructure, patternId, region);
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
            },
            .DeclareGlobal => @panic("internal error"),
            .Range => {
                try self.printError(region, "Range is not valid in value context", .{});
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
            .Function => |function| {
                try self.writeValueFunctionCall(function.name, function.paramsOrArgs, region, isTailPosition);
            },
            .ElemNode => |elem| switch (elem.getType()) {
                .ParserVar => {
                    try self.printError(region, "Parser is not valid in value", .{});
                    return Error.InvalidAst;
                },
                .ValueVar => {
                    const name = elem.asValueVar();
                    if (self.localSlot(name)) |slot| {
                        // This local will either be a concrete value or
                        // unbound, it won't be a function. Value functions are
                        // all defined globally and called immediately. This
                        // means that if a function takes a value function as
                        // an arg then the value function will be called before
                        // the outer function, and the value used when calling
                        // the outer function will be concrete.
                        try self.emitUnaryOp(.GetBoundLocal, slot, region);
                    } else if (self.findGlobal(name)) |globalElem| {
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
                .Const => switch (elem.asConst()) {
                    .True => try self.emitOp(.True, region),
                    .False => try self.emitOp(.False, region),
                    .Null => try self.emitOp(.Null, region),
                    .Failure => return Error.InvalidAst,
                },
                .InputSubstring,
                .NumberFloat,
                => @panic("Internal Error"), // not produced by the parser
                .Dyn => switch (elem.asDyn().dynType) {
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

    fn writeValueFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.RNode,
        arguments: ArrayList(*Ast.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        const function_elem = function_rnode.node.asElem() orelse @panic("internal error");
        const function_region = function_rnode.region;

        const functionName = switch (function_elem.getType()) {
            .ValueVar => function_elem.asValueVar(),
            else => return Error.InvalidAst,
        };

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.findGlobal(functionName)) |global| {
                function = global.asDyn().asFunction();
                const constId = try self.makeConstant(global);
                try self.emitUnaryOp(.GetConstant, constId, function_region);
            } else {
                const functionNameStr = self.vm.strings.get(functionName);
                try self.printError(function_region, "Undefined function '{s}'", .{functionNameStr});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(arguments, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, call_region);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, call_region);
        }
    }

    fn writeValueFunctionArguments(
        self: *Compiler,
        arguments: ArrayList(*Ast.RNode),
        function: ?*Elem.DynElem.Function,
    ) Error!u8 {
        const arg_count = arguments.items.len;

        if (arg_count > std.math.maxInt(u8)) {
            const first_arg = arguments.items[0];
            const last_arg = arguments.items[arg_count - 1];
            const region = first_arg.region.merge(last_arg.region);

            try self.printError(
                region,
                "Can't have more than {} parameters.",
                .{std.math.maxInt(u8)},
            );
            return Error.MaxFunctionArgs;
        }

        if (function) |f| {
            if (f.arity != arg_count) {
                const functionNameStr = self.vm.strings.get(f.name);
                const region = if (arguments.items.len > 0) blk: {
                    const first_arg = arguments.items[0];
                    const last_arg = arguments.items[arg_count - 1];
                    break :blk first_arg.region.merge(last_arg.region);
                } else blk: {
                    // For zero-argument functions, we don't have argument regions,
                    // so we'll need to handle this case differently
                    break :blk Region.new(0, 0);
                };

                if (f.arity < arg_count) {
                    try self.printError(region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooManyArgs;
                } else {
                    try self.printError(region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooFewArgs;
                }
            }
        }

        for (arguments.items) |arg| {
            try self.writeValue(arg, false);
        }

        return @intCast(arg_count);
    }

    fn writeValueArray(self: *Compiler, elements: ArrayList(*Ast.RNode), region: Region) Error!void {
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
        try array.append(self.vm.allocator, self.placeholderVar());
    }

    fn negateAndAppendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) !void {
        try self.writeValue(rnode, false);
        try self.emitOp(.NegateNumber, region);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.vm.allocator, self.placeholderVar());
    }

    fn writeArrayElem(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) Error!void {
        switch (rnode.node) {
            .ElemNode => |elem| switch (elem.getType()) {
                .ValueVar => try self.appendDynamicValue(array, rnode, index, region),
                else => {
                    try array.append(self.vm.allocator, elem);
                },
            },
            .InfixNode => try self.appendDynamicValue(array, rnode, index, region),
            .Function => try self.appendDynamicValue(array, rnode, index, region),
            .Array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(self.vm.allocator, emptyArray.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index, region);
                }
            },
            .Object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(self.vm.allocator, emptyObject.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index, region);
                }
            },
            .StringTemplate => try self.appendDynamicValue(array, rnode, index, region),
            .Range => {
                try self.printError(region, "Range is not valid in value context", .{});
                return Error.RangeNotValidInValueContext;
            },
            .Conditional => try self.appendDynamicValue(array, rnode, index, region),
            .Negation => |inner| {
                if (simplifyNegatedNumberNode(rnode)) |elem| {
                    try array.append(self.vm.allocator, elem);
                } else {
                    try self.negateAndAppendDynamicValue(array, inner, index, region);
                }
            },
            .ValueLabel => {
                try self.printError(region, "Value label `$` is not necessary inside array.", .{});
                return Error.InvalidAst;
            },
            .DeclareGlobal => {
                try self.printError(region, "Invlaid global assignment inside array.", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeValueObject(self: *Compiler, pairs: ArrayList(Ast.ObjectPair), region: Region) Error!void {
        var object = try Elem.DynElem.Object.create(self.vm, 0);
        const constId = try self.makeConstant(object.dyn.elem());
        try self.emitUnaryOp(.GetConstant, constId, region);

        for (pairs.items, 0..) |pair, index| {
            if (try self.literalPatternToElem(pair.key)) |key_elem| {
                if (try self.literalPatternToElem(pair.value)) |val_elem| {
                    const key_sid = key_elem.asString();
                    try object.members.put(self.vm.allocator, key_sid, val_elem);
                } else {
                    try self.writeValueObjectVal(pair.value, key_elem);
                }
            } else {
                const pos = @as(u8, @intCast(index));
                try object.putReservedId(self.vm.allocator, pos, self.placeholderVar());
                try self.writeValue(pair.key, false);
                try self.writeValue(pair.value, false);
                try self.emitUnaryOp(.InsertKeyVal, pos, pair.key.region);
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

    fn writeStringTemplate(self: *Compiler, parts: ArrayList(*Ast.RNode), region: Region, context: StringTemplateContext) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];
        const firstPartIsString = if (firstPart.node.asElem()) |elem| elem.isType(.String) else false;

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

    fn literalPatternToElem(self: *Compiler, rnode: *Ast.RNode) !?Elem {
        return switch (rnode.node) {
            .ElemNode => |elem| switch (elem.getType()) {
                .String, .InputSubstring, .NumberString, .NumberFloat, .Const => elem,
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
            .ElemNode => |elem| {
                switch (elem.getType()) {
                    .NumberString, .NumberFloat => return elem,
                    else => return null,
                }
            },
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
        const local: Elem.DynElem.Function.Local = switch (elem.getType()) {
            .ParserVar => .{ .ParserVar = elem.asParserVar() },
            .ValueVar => .{ .ValueVar = elem.asValueVar() },
            else => return Error.InvalidAst,
        };

        if (self.isMetaVar(local.name())) {
            return Error.InvalidAst;
        }

        if (self.currentFunction().functionType == .NamedValue and local.isParserVar()) {
            return Error.InvalidAst;
        }

        return self.currentFunction().addLocal(
            self.vm.allocator,
            local,
        ) catch |err| switch (err) {
            error.MaxFunctionLocals => {
                try self.printError(
                    region,
                    "Can't have more than {} parameters and local variables.",
                    .{std.math.maxInt(u8)},
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
                try self.printError(region, "Too much code to jump over.", .{});
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

    fn printError(self: *Compiler, region: Region, comptime message: []const u8, args: anytype) !void {
        try self.writers.err.print("\nProgram Error: ", .{});
        try self.writers.err.print(message, args);
        try self.writers.err.print("\n", .{});

        if (self.targetModule.name) |name| {
            try self.writers.err.print("{s}:", .{name});
        }

        try region.printLineRelative(self.targetModule.source, self.writers.err);
        try self.writers.err.print(":\n\n", .{});

        try self.targetModule.highlight(region, self.writers.err);
        try self.writers.err.print("\n", .{});
    }
};

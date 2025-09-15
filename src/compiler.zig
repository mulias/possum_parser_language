const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const StringHashMap = std.StringArrayHashMapUnmanaged;
const Writer = std.Io.Writer;
const Ast = @import("can_ast.zig");
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
const parsing = @import("parsing.zig");

pub const Compiler = struct {
    vm: *VM,
    targetModule: *Module,
    ast: Ast,
    functions: ArrayList(*Elem.DynElem.Function),
    writers: Writers,
    printBytecode: bool,
    parser_declarations: StringHashMap(Ast.Parser.Declaration),
    value_declarations: StringHashMap(Ast.Value.Declaration),

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
        InvalidCharacter,
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
    } || Writer.Error;

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
            .parser_declarations = StringHashMap(Ast.Parser.Declaration){},
            .value_declarations = StringHashMap(Ast.Value.Declaration){},
        };
    }

    fn findGlobal(self: *Compiler, sid: StringTable.Id) ?Elem {
        const targetModuleIndex = for (self.vm.modules.items, 0..) |*module, i| {
            if (module == self.targetModule) break i;
        } else return null;

        // Search backwards through modules up to and including the target module
        var i = targetModuleIndex + 1;
        while (i > 0) {
            i -= 1;
            if (self.vm.modules.items[i].getGlobal(sid)) |elem| {
                return elem;
            }
        }
        return null;
    }

    pub fn deinit(self: *Compiler) void {
        self.functions.deinit(self.vm.allocator);
        self.declarations.deinit(self.vm.allocator);
    }

    pub fn compile(self: *Compiler) !?*Elem.DynElem.Function {
        var main_rnode: ?*Ast.RNode = null;

        for (self.ast.roots.items) |root| {
            if (root.node == .DeclareGlobal) {
                const global = root.node.DeclareGlobal;
                if (self.globalIdent(global.head)) |ident| {
                    try self.declarations.put(self.vm.allocator, ident.name, root);
                }
            } else if (main_rnode == null) {
                main_rnode = root;
            } else {
                try self.printError(root.region, "Only one main parser expression is allowed per module", .{});
                return Error.MultipleMainParsers;
            }
        }

        try self.declareGlobals();
        try self.resolveAliaseChains();
        try self.compileFunctions();

        if (main_rnode) |rnode| {
            return self.compileMain(rnode);
        } else {
            return null;
        }
    }

    fn declareGlobals(self: *Compiler) !void {
        var iter = self.declarations.iterator();
        while (iter.next()) |entry| {
            const region = entry.value_ptr.*.region;
            const decl = entry.value_ptr.*.node.DeclareGlobal;
            switch (decl.head.node) {
                .Function => |function| {
                    try self.declareFunction(function.name, function.paramsOrArgs, region);
                },
                else => {
                    if (try self.nodeToElem(decl.body.node)) |body_elem| {
                        try self.declareAlias(decl.head, body_elem);
                    } else if (self.nodeToIdent(decl.body.node) == null) {
                        // A function without params. When the body is a single
                        // ident it's an alias which we'll resolve later.
                        try self.declareFunction(decl.head, ArrayList(*Ast.RNode){}, region);
                    }
                },
            }
        }
    }

    fn compileFunctions(self: *Compiler) !void {
        var iter = self.declarations.iterator();
        while (iter.next()) |entry| {
            const decl = entry.value_ptr.*.node.DeclareGlobal;
            if (decl.head.node == .Function or (try self.nodeToElem(decl.body.node) == null and self.nodeToIdent(decl.body.node) == null)) {
                try self.compileFunction(decl.head, decl.body);
            }
        }
    }

    fn resolveAliaseChains(self: *Compiler) !void {
        var iter = self.declarations.iterator();
        while (iter.next()) |entry| {
            const region = entry.value_ptr.*.region;
            const decl = entry.value_ptr.*.node.DeclareGlobal;
            if (decl.head.node != .Function) {
                if (self.nodeToIdent(decl.body.node) != null) {
                    const alias_ident = self.globalIdent(decl.head).?;
                    try self.resolveAliasChain(alias_ident, decl.body, region);
                }
            }
        }
    }

    fn compileMain(self: *Compiler, main_rnode: *Ast.RNode) !?*Elem.DynElem.Function {
        try self.addValueLocals(main_rnode);
        try self.writeParser(main_rnode, false);
        try self.emitEnd();

        const main_fn = self.functions.pop() orelse @panic("Internal Error: No Main Function");

        // Update the main function's source region with the actual main parser region
        main_fn.chunk.source_region = main_rnode.region;

        if (self.printBytecode) {
            try main_fn.disassemble(self.vm.*, self.writers.debug, self.targetModule);
        }

        return main_fn;
    }

    fn declareFunction(self: *Compiler, name: *Ast.RNode, params: ArrayList(*Ast.RNode), region: Region) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const name_ident = self.nodeToIdent(name.node) orelse {
            try self.printError(name.region, "function name must be parser or value varaible", .{});
            return Error.InvalidAst;
        };

        if (name_ident.builtin) {
            try self.printError(name.region, "unable to define builtin function", .{});
            return Error.InvalidAst;
        }

        const functionType: Elem.DynElem.FunctionType = switch (name_ident.kind) {
            .Parser => .NamedParser,
            .Value => .NamedValue,
            .Underscore => {
                try self.printError(name.region, "function name must be parser or value varaible", .{});
                return Error.InvalidAst;
            },
        };

        const name_sid = try self.vm.strings.insert(name_ident.name);

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .name = name_sid,
            .functionType = functionType,
            .arity = 0,
            .region = region,
        });

        try self.targetModule.addGlobal(self.vm.allocator, name_sid, function.dyn.elem());

        try self.functions.append(self.vm.allocator, function);

        for (params.items) |param| {
            if (self.nodeToIdent(param.node)) |ident| {
                _ = try self.addLocal(ident, param.region);
                function.arity += 1;
            } else {
                return Error.InvalidAst;
            }
        }

        _ = self.functions.pop();
    }

    fn declareAlias(self: *Compiler, head: *Ast.RNode, bodyElem: Elem) !void {
        // Add an alias to the global namespace. Set the given body element as the alias's value.
        const ident = self.nodeToIdent(head.node) orelse {
            try self.printError(head.region, "alias name must be parser or value varaible", .{});
            return Error.InvalidAst;
        };

        const sid = try self.vm.strings.insert(ident.name);
        try self.targetModule.addGlobal(self.vm.allocator, sid, bodyElem);
    }

    fn resolveAliasChain(self: *Compiler, alias_ident: Ast.IdentifierNode, body: *Ast.RNode, region: Region) !void {
        var path = StringHashMap(void){};
        defer path.deinit(self.vm.allocator);

        var target = body;
        var target_ident = self.nodeToIdent(body.node).?;

        while (true) {
            if (target.node == .Identifier) {
                if (alias_ident.kind == .Parser and target_ident.kind != .Parser) {
                    try self.printError(target.region, "Value is not valid as a parser", .{});
                    return Error.InvalidGlobalParser;
                }

                if (alias_ident.kind != .Parser and target_ident.kind == .Parser) {
                    try self.printError(target.region, "Parser is not valid as a value", .{});
                    return Error.InvalidGlobalValue;
                }
            }

            if (path.contains(target_ident.name)) {
                try self.printError(region, "Circular alias dependency detected for '{s}'", .{alias_ident.name});
                return Error.AliasCycle;
            } else {
                try path.put(self.vm.allocator, target_ident.name, undefined);
            }

            if (self.declarations.get(target_ident.name)) |new_target_decl| {
                const new_target = new_target_decl.node.DeclareGlobal.body;
                if (self.nodeToIdent(new_target.node)) |new_target_ident| {
                    target = new_target;
                    target_ident = new_target_ident;
                    continue;
                }
            }

            break;
        }

        const alias_sid = try self.vm.strings.insert(alias_ident.name);

        if (alias_ident.kind != .Parser) {
            if (try self.nodeToElem(target.node)) |target_elem| {
                if (target_elem.getType() != .ValueVar) {
                    try self.targetModule.addGlobal(self.vm.allocator, alias_sid, target_elem);
                    return;
                }
            }
        }

        if (self.declarations.get(target_ident.name)) |target_decl| {
            if (try self.nodeToElem(target_decl.node.DeclareGlobal.body.node)) |target_elem| {
                try self.targetModule.addGlobal(self.vm.allocator, alias_sid, target_elem);
                return;
            }
        }

        const target_sid = try self.vm.strings.insert(target_ident.name);
        if (self.findGlobal(target_sid)) |target_elem| {
            try self.targetModule.addGlobal(self.vm.allocator, alias_sid, target_elem);
            return;
        } else {
            try self.printError(region, "Unknown variable '{s}' in alias chain", .{target_ident.name});
            return Error.UnknownVariable;
        }

        try self.printError(region, "Unable to resolve alias chain", .{});
        return Error.UnknownVariable;
    }

    fn compileFunction(self: *Compiler, head: *Ast.RNode, body: *Ast.RNode) !void {
        const global_ident = self.globalIdent(head).?;
        const global_sid = try self.vm.strings.insert(global_ident.name);
        const globalVal = (self.findGlobal(global_sid)).?;

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

    fn globalIdent(self: *Compiler, head: *Ast.RNode) ?Ast.IdentifierNode {
        const name_node = switch (head.node) {
            .Function => |function| function.name.node,
            else => head.node,
        };
        return self.nodeToIdent(name_node);
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
                .Repeat => {
                    try self.writeParserRepeat(infix.left, infix.right, region);
                },
                .NumberSubtract => {
                    try self.printError(region, "Subtraction is only valid in patterns or values", .{});
                    return Error.InvalidAst;
                },
            },
            .DeclareGlobal => unreachable, // handled by top-level compiler functions
            .Range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    try self.writeRangeParser(bounds.lower.?, bounds.upper.?, region);
                } else if (bounds.lower != null) {
                    try self.writeLowerBoundedRangeParser(bounds.lower.?, region);
                } else {
                    try self.writeUpperBoundedRangeParser(bounds.upper.?, region);
                }
            },
            .Negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.writeGetVar(ident, region);
                    try self.emitUnaryOp(.CallFunction, 0, region);
                },
                .Value => {
                    try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
            },
            .False,
            .True,
            .Null,
            => {
                // In this context `true`/`false`/`null` could be a zero-arg function call
                const ident = self.nodeToIdent(rnode.node) orelse @panic("Internal Error");
                try self.writeGetVar(ident, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .NumberFloat,
            .NumberString,
            .String,
            => {
                const elem = try self.nodeToElem(rnode.node) orelse @panic("Internal Error");
                const constId = try self.makeConstant(elem);
                try self.emitUnaryOp(.GetConstant, constId, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .StringTemplate => |parts| {
                try self.writeStringTemplate(parts, region, .Parser);
            },
            .Conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeParser(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
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
            => {
                try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn negateParserNumber(self: *Compiler, rnode: *Ast.RNode) !Elem {
        if (try self.nodeToElem(rnode.node)) |elem| {
            const negated = Elem.negateNumber(elem) catch |err| switch (err) {
                error.ExpectedNumber => return Error.InvalidAst,
            };
            return negated;
        } else {
            return Error.InvalidAst;
        }
    }

    fn writeParserFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.RNode,
        arguments: ArrayList(*Ast.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        // TODO: handle curried function calls like `foo(a)(b)`
        const function_ident = self.nodeToIdent(function_rnode.node) orelse @panic("Internal Error");
        const function_region = function_rnode.region;

        const functionName = try self.vm.strings.insert(function_ident.name);

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

    fn writeRangeParser(self: *Compiler, low: *Ast.RNode, high: *Ast.RNode, region: Region) !void {
        const low_elem = try self.nodeToElem(low.node);
        const high_elem = try self.nodeToElem(high.node);

        if (low.node == .String and high.node == .String) {
            const low_str = low_elem.?.asString();
            const high_str = high_elem.?.asString();
            const low_bytes = self.vm.strings.get(low_str);
            const high_bytes = self.vm.strings.get(high_str);
            const low_codepoint = parsing.utf8Decode(low_bytes) orelse return Error.RangeNotSingleCodepoint;
            const high_codepoint = parsing.utf8Decode(high_bytes) orelse return Error.RangeNotSingleCodepoint;

            if (low_codepoint > high_codepoint) {
                return Error.RangeCodepointsUnordered;
            } else if (low_codepoint == 0 and high_codepoint == 0x10ffff) {
                try self.emitOp(.ParseCharacter, region);
            } else {
                const low_id = try self.makeConstant(low_elem.?);
                const high_id = try self.makeConstant(high_elem.?);
                try self.emitOp(.ParseFixedRange, region);
                try self.emitByte(low_id, low.region);
                try self.emitByte(high_id, high.region);
            }
        } else if (low.node == .NumberString and high.node == .NumberString) {
            const low_ns = low_elem.?.asNumberString();
            const high_ns = high_elem.?.asNumberString();

            const low_num = low_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
            const high_num = high_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;

            if (!low_num.isInteger(self.vm.strings)) return Error.RangeInvalidNumberFormat;
            if (!high_num.isInteger(self.vm.strings)) return Error.RangeInvalidNumberFormat;

            const low_int = try low_num.asInteger(self.vm.strings);
            const high_int = try high_num.asInteger(self.vm.strings);

            if (low_int > high_int) {
                return Error.RangeIntegersUnordered;
            } else {
                const low_id = try self.makeConstant(low_num);
                const high_id = try self.makeConstant(high_num);
                try self.emitOp(.ParseFixedRange, region);
                try self.emitByte(low_id, low.region);
                try self.emitByte(high_id, high.region);
            }
        } else {
            switch (low.node) {
                .String => {
                    const low_str = low_elem.?.asString();
                    const low_bytes = self.vm.strings.get(low_str);
                    _ = parsing.utf8Decode(low_bytes) orelse return Error.RangeNotSingleCodepoint;

                    const low_id = try self.makeConstant(low_elem.?);
                    try self.emitUnaryOp(.GetConstant, low_id, low.region);
                },
                .NumberString => {
                    const low_ns = low_elem.?.asNumberString();
                    const low_num = low_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                    if (!low_num.isInteger(self.vm.strings)) return Error.RangeInvalidNumberFormat;

                    const low_id = try self.makeConstant(low_num);
                    try self.emitUnaryOp(.GetConstant, low_id, low.region);
                },
                .Identifier => |ident| switch (ident.kind) {
                    .Parser => try self.writeGetVar(ident, region),
                    .Value => {
                        try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                        return Error.InvalidAst;
                    },
                    .Underscore => {
                        try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                        return Error.InvalidAst;
                    },
                },
                .Negation => |inner| {
                    try self.writeNegatedParserElem(inner, region);
                },
                else => return Error.InvalidAst,
            }

            switch (high.node) {
                .String => {
                    const high_str = high_elem.?.asString();
                    const high_bytes = self.vm.strings.get(high_str);
                    _ = parsing.utf8Decode(high_bytes) orelse return Error.RangeNotSingleCodepoint;

                    const high_id = try self.makeConstant(high_elem.?);
                    try self.emitUnaryOp(.GetConstant, high_id, high.region);
                },
                .NumberString => {
                    const high_ns = high_elem.?.asNumberString();
                    const high_num = high_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;

                    if (!high_num.isInteger(self.vm.strings)) return Error.RangeInvalidNumberFormat;

                    const high_id = try self.makeConstant(high_num);
                    try self.emitUnaryOp(.GetConstant, high_id, high.region);
                },
                .Identifier => |ident| switch (ident.kind) {
                    .Parser => try self.writeGetVar(ident, region),
                    .Value => {
                        try self.printError(region, "Uppercse variable is only valid as a pattern or value", .{});
                        return Error.InvalidAst;
                    },
                    .Underscore => {
                        try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                        return Error.InvalidAst;
                    },
                },
                .Negation => |inner| {
                    try self.writeNegatedParserElem(inner, region);
                },
                else => return Error.InvalidAst,
            }

            try self.emitOp(.ParseRange, region);
        }
    }

    fn writeLowerBoundedRangeParser(self: *Compiler, low: *Ast.RNode, region: Region) !void {
        const low_elem = try self.nodeToElem(low.node);
        const low_region = low.region;

        switch (low.node) {
            .String => {
                const low_str = low_elem.?.asString();
                const low_bytes = self.vm.strings.get(low_str);
                const low_codepoint = parsing.utf8Decode(low_bytes) orelse return Error.RangeNotSingleCodepoint;

                if (low_codepoint == 0) {
                    try self.emitOp(.ParseCharacter, region);
                } else {
                    const low_id = try self.makeConstant(low_elem.?);
                    try self.emitUnaryOp(.GetConstant, low_id, low_region);
                    try self.emitOp(.ParseLowerBoundedRange, region);
                }
            },
            .NumberString => {
                const low_ns = low_elem.?.asNumberString();
                const low_num = low_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                const low_f = low_num.asFloat();

                if (@trunc(low_f) != low_f) return Error.RangeInvalidNumberFormat;

                const low_id = try self.makeConstant(low_num);
                try self.emitUnaryOp(.GetConstant, low_id, low_region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.writeGetVar(ident, region);
                    try self.emitOp(.ParseLowerBoundedRange, region);
                },
                .Value => {
                    try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
            },
            .Negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            else => return Error.InvalidAst,
        }
    }

    fn writeUpperBoundedRangeParser(self: *Compiler, high: *Ast.RNode, region: Region) !void {
        const high_elem = try self.nodeToElem(high.node);
        const high_region = high.region;

        switch (high.node) {
            .String => {
                const high_str = high_elem.?.asString();
                const high_bytes = self.vm.strings.get(high_str);
                const high_codepoint = parsing.utf8Decode(high_bytes) orelse return Error.RangeNotSingleCodepoint;

                if (high_codepoint == 0x10ffff) {
                    try self.emitOp(.ParseCharacter, region);
                } else {
                    const high_id = try self.makeConstant(high_elem.?);
                    try self.emitUnaryOp(.GetConstant, high_id, high_region);
                    try self.emitOp(.ParseUpperBoundedRange, region);
                }
            },
            .NumberString => {
                const high_ns = high_elem.?.asNumberString();
                const high_num = high_ns.toNumberFloat(self.vm.strings) catch return Error.RangeIntegerTooLarge;
                const high_f = high_num.asFloat();

                if (@trunc(high_f) != high_f) return Error.RangeInvalidNumberFormat;

                const high_id = try self.makeConstant(high_num);
                try self.emitUnaryOp(.GetConstant, high_id, high_region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.writeGetVar(ident, region);
                    try self.emitOp(.ParseUpperBoundedRange, region);
                },
                .Value => {
                    try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
            },
            .Negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            else => return Error.InvalidAst,
        }
    }

    fn writeParserRepeat(self: *Compiler, parser: *Ast.RNode, repeat: *Ast.RNode, region: Region) !void {
        try self.simplifyPatternAst(repeat);

        switch (repeat.node) {
            .NumberFloat,
            .NumberString,
            => {
                return self.writeParserRepeatCount(parser, repeat, region);
            },
            .Range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    const lower = bounds.lower.?;
                    const upper = bounds.upper.?;

                    if (self.isBoundedRepeatCount(lower) and self.isBoundedRepeatCount(upper)) {
                        // Both bounds: repeat between min and max times
                        try self.writeParserRepeatRangeBounded(parser, lower, upper, region);
                    } else if (self.isBoundedRepeatCount(lower)) {
                        // Lower bound number, upper bound pattern
                        try self.writeParserRepeatRangeLowerBounded(parser, lower, upper, region);
                    } else if (self.isBoundedRepeatCount(upper)) {
                        // Upper bound number, lower bound pattern
                        try self.writeParserRepeatRangeUpperBounded(parser, lower, upper, region);
                    } else {
                        // Pattern matching fallback
                        try self.writeParserRepeatUnknownCount(parser, repeat, region);
                    }
                } else if (bounds.lower != null and self.isBoundedRepeatCount(bounds.lower.?)) {
                    // Lower bound only: repeat at least n times
                    try self.writeParserRepeatRangeLowerBounded(parser, bounds.lower.?, null, region);
                } else if (bounds.upper != null and self.isBoundedRepeatCount(bounds.upper.?)) {
                    // Upper bound only: repeat at most n times
                    try self.writeParserRepeatRangeUpperBounded(parser, null, bounds.upper.?, region);
                } else {
                    // Pattern matching fallback
                    try self.writeParserRepeatUnknownCount(parser, repeat, region);
                }
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.printError(repeat.region, "Repeat count must be an integer or range pattern, got a parser", .{});
                    return Error.InvalidAst;
                },
                .Value, .Underscore => {
                    const name = try self.vm.strings.insert(ident.name);
                    if (self.findGlobal(name)) |globalElem| {
                        if (globalElem.isNumber()) {
                            try self.writeParserRepeatCount(parser, repeat, region);
                        } else {
                            return Error.InvalidAst;
                        }
                    } else if (self.localSlot(name)) |slot| {
                        // The local var is a function arg, so we know it's bound
                        if (self.currentFunction().arity > slot) {
                            try self.writeParserRepeatCount(parser, repeat, region);
                        } else {
                            try self.emitUnaryOp(.GetLocal, slot, repeat.region);
                            const knownCountJump = try self.emitJump(.JumpIfBound, repeat.region);
                            try self.writeParserRepeatUnknownCount(parser, repeat, region);
                            const endJump = try self.emitJump(.Jump, repeat.region);
                            try self.patchJump(knownCountJump, region);
                            try self.writeParserRepeatCount(parser, repeat, region);
                            try self.patchJump(endJump, region);
                            try self.emitOp(.Swap, region);
                            try self.emitOp(.Drop, region);
                        }
                    } else {
                        @panic("Internal Error");
                    }
                },
            },
            else => {
                if (self.isBoundedRepeatCount(repeat)) {
                    try self.writeParserRepeatCount(parser, repeat, region);
                } else {
                    try self.writeParserRepeatUnknownCount(parser, repeat, region);
                }
            },
        }
    }

    fn writeParserRepeatCount(self: *Compiler, parser: *Ast.RNode, count: *Ast.RNode, repeat_region: Region) Error!void {
        // Value accumulator
        const nullId = try self.makeConstant(Elem.nullConst);
        try self.emitUnaryOp(.GetConstant, nullId, parser.region);

        // Create the counter, validate it, if it starts at zero
        // then skip to the end and return null
        try self.writeValue(count, false);
        try self.emitOp(.ValidateRepeatPattern, count.region);
        const nullJump = try self.emitJump(.JumpIfZero, repeat_region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, repeat_region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(parser, false);
        try self.emitOp(.Merge, parser.region);
        const failureJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, repeat_region);
        try self.emitOp(.Decrement, count.region);
        const doneJump = try self.emitJump(.JumpIfZero, repeat_region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStart, repeat_region);

        // For the failure case swap up the counter. The
        // non-failure case already has the counter on top.
        try self.patchJump(failureJump, parser.region);
        try self.emitOp(.Swap, repeat_region);

        // Cleanup: drop the counter
        try self.patchJump(nullJump, count.region);
        try self.patchJump(doneJump, repeat_region);
        try self.emitOp(.Drop, count.region);
    }

    fn writeParserRepeatUnknownCount(self: *Compiler, parser: *Ast.RNode, count: *Ast.RNode, repeat_region: Region) Error!void {
        // Count accumulator
        const zero_id = try self.makeConstant(Elem.numberFloat(0));
        try self.emitUnaryOp(.GetConstant, zero_id, count.region);

        // Value accumulator
        const null_id = try self.makeConstant(Elem.nullConst);
        try self.emitUnaryOp(.GetConstant, null_id, parser.region);

        // Start of the parse loop
        const loopStart = self.chunk().code.items.len;

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(parser, false);
        const failureJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);

        // Increment count
        try self.emitOp(.Swap, repeat_region);
        try self.emitOp(.Increment, count.region);
        try self.emitOp(.Swap, repeat_region);

        // Parse again
        try self.emitJumpBack(.JumpBack, loopStart, repeat_region);

        // When we fail the stack has [..., count, acc, failure]
        // Drop the failure, destructure the count, return acc
        try self.patchJump(failureJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);
        try self.emitOp(.Swap, count.region);
        const patternId = try self.createPattern(count);
        try self.emitUnaryOp(.Destructure, patternId, repeat_region);

        // Cleanup: drop the counter
        try self.emitOp(.Drop, parser.region);
    }

    fn writeParserRepeatRangeBounded(self: *Compiler, parser: *Ast.RNode, lower: *Ast.RNode, upper: *Ast.RNode, region: Region) Error!void {
        // Value accumulator
        const nullId = try self.makeConstant(Elem.nullConst);
        try self.emitUnaryOp(.GetConstant, nullId, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writeValue(lower, false);
        try self.emitOp(.ValidateRepeatPattern, lower.region);
        const skipLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStartRequired = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(parser, false);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        try self.patchJump(skipLowerBoundJump, region);
        try self.patchJump(doneLowerBoundJump, region);

        // Drop the old counter (it's 0), create a new counter to parse up to
        // to `upper - lower` more times (optional)
        try self.emitOp(.Drop, region);
        try self.writeValue(upper, false);
        try self.writeValue(lower, false);
        try self.emitOp(.NegateNumber, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.ValidateRepeatPattern, upper.region);
        const skipUpperBoundJump = try self.emitJump(.JumpIfZero, region);

        // Optional iterations
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(parser, false);
        const failureUpperBoundJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        try self.patchJump(failureUpperBoundJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);

        // Got here by failing before reaching the minimum number of iters. The
        // stack is [..., count, failure] and we want to return failure
        try self.patchJump(failureLowerBoundJump, region);

        // Swap up the count
        try self.emitOp(.Swap, region);

        // Got here by matching against a zero count, stack is [..., acc, count]
        try self.patchJump(skipUpperBoundJump, region);
        try self.patchJump(doneJump, region);

        try self.emitOp(.Drop, region);
    }

    fn writeParserRepeatRangeLowerBounded(self: *Compiler, parser: *Ast.RNode, lower: *Ast.RNode, upper_pattern: ?*Ast.RNode, region: Region) Error!void {
        // Value accumulator
        const nullId = try self.makeConstant(Elem.nullConst);
        try self.emitUnaryOp(.GetConstant, nullId, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writeValue(lower, false);
        try self.emitOp(.ValidateRepeatPattern, lower.region);
        const skipLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStartRequired = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(parser, false);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        // Now continue parsing indefinitely (optional iterations)
        try self.patchJump(skipLowerBoundJump, region);
        try self.patchJump(doneLowerBoundJump, region);

        // Count under acc
        try self.emitOp(.Swap, region);

        // Unbounded loop
        const loopStartOptional = self.chunk().code.items.len;

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(parser, false);
        const failureJumpOptional = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);

        // If there's an upper bound to pattern match against then count iterations
        if (upper_pattern) |upper| {
            try self.emitOp(.Swap, region);
            try self.emitOp(.Increment, upper.region);
            try self.emitOp(.Swap, upper.region);
        }

        // Parse again
        try self.emitJumpBack(.JumpBack, loopStartOptional, region);

        // When we fail the stack has [..., count, acc, failure]
        // Drop the failure, maybe destructure the count, return acc
        try self.patchJump(failureJumpOptional, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);

        // Swap up the count, add the lower to get the total number of iters, destructure
        if (upper_pattern) |upper| {
            try self.emitOp(.Swap, upper.region);
            try self.writeValue(lower, false);
            try self.emitOp(.Merge, parser.region);
            const patternId = try self.createPattern(upper);
            try self.emitUnaryOp(.Destructure, patternId, upper.region);
            try self.emitOp(.Swap, region);
        }

        try self.patchJump(failureLowerBoundJump, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Drop, region);
    }

    fn writeParserRepeatRangeUpperBounded(self: *Compiler, parser: *Ast.RNode, lower_pattern: ?*Ast.RNode, upper: *Ast.RNode, region: Region) Error!void {
        // Value accumulator
        const nullId = try self.makeConstant(Elem.nullConst);
        try self.emitUnaryOp(.GetConstant, nullId, region);

        // Create the counter, validate it, if it starts at zero
        // then skip to end and return null
        try self.writeValue(upper, false);
        try self.emitOp(.ValidateRepeatPattern, upper.region);
        const nullJump = try self.emitJump(.JumpIfZero, region);

        // Loop for up to `upper` iterations (all optional)
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(parser, false);
        const failureJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        // Drop the failure and swap up the count so we can pattern match/cleanup
        try self.patchJump(failureJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);
        try self.emitOp(.Swap, region);

        try self.patchJump(nullJump, region);
        try self.patchJump(doneJump, region);

        if (lower_pattern) |lower| {
            // Use the remaining count to figure out the number of successful iters
            //   upper - count = completed
            // But since the count is on the stack we do
            //   -count + upper = completed
            try self.emitOp(.NegateNumber, region);
            try self.writeValue(upper, false);
            try self.emitOp(.Merge, region);
            const patternId = try self.createPattern(lower);
            try self.emitUnaryOp(.Destructure, patternId, lower.region);
        }

        try self.emitOp(.Drop, region);
    }

    fn isBoundedRepeatCount(self: *Compiler, rnode: *Ast.RNode) bool {
        return switch (rnode.node) {
            .Function => true,
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .String,
            .True,
            => true,
            .Identifier => |ident| switch (ident.kind) {
                .Parser => true,
                .Underscore => false,
                .Value => {
                    if (self.vm.strings.findId(ident.name)) |name| {
                        if (self.findGlobal(name) != null) return true;

                        if (self.localSlot(name)) |slot| {
                            return self.currentFunction().arity > slot;
                        } else {
                            return false;
                        }
                    } else {
                        return false;
                    }
                },
            },
            .InfixNode => |infix| self.isBoundedRepeatCount(infix.left) and self.isBoundedRepeatCount(infix.left),
            .Range => |range| {
                if (range.lower) |lower| {
                    const lower_good = self.isBoundedRepeatCount(lower);
                    if (!lower_good) return false;
                }
                if (range.upper) |upper| {
                    const upper_good = self.isBoundedRepeatCount(upper);
                    if (!upper_good) return false;
                }
                return true;
            },
            .Negation => |inner| self.isBoundedRepeatCount(inner),
            .ValueLabel => |inner| self.isBoundedRepeatCount(inner),
            .Array,
            .Object,
            .StringTemplate,
            .Conditional,
            .DeclareGlobal,
            => false,
        };
    }

    fn writeNegatedParserElem(self: *Compiler, negated: *Ast.RNode, region: Region) !void {
        switch (negated.node) {
            .Negation => return Error.InvalidAst,
            .NumberString => |ns| {
                if (ns.negated) {
                    return Error.InvalidAst;
                }
                const elem = try self.nodeToElem(negated.node) orelse return Error.InvalidAst;
                const negated_elem = elem.negateNumber() catch return Error.InvalidAst;
                const constId = try self.makeConstant(negated_elem);
                try self.emitUnaryOp(.GetConstant, constId, negated.region);
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.writeGetVar(ident, region);
                    try self.emitOp(.NegateParser, region);
                },
                .Value => {
                    try self.printError(region, "Uppercase variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(region, "Underscore variable is only valid as a pattern or value", .{});
                    return Error.InvalidAst;
                },
            },
            else => return Error.InvalidAst,
        }
    }

    fn writeGetVar(self: *Compiler, ident: Ast.IdentifierNode, region: Region) !void {
        const varName = try self.vm.strings.insert(ident.name);

        if (self.localSlot(varName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, region);
        } else {
            if (self.findGlobal(varName)) |globalElem| {
                const constId = try self.makeConstant(globalElem);
                try self.emitUnaryOp(.GetConstant, constId, region);
            } else {
                try self.printError(region, "undefined variable '{s}'", .{ident.name});
                return Error.UndefinedVariable;
            }
        }
    }

    fn nodeToElem(self: *Compiler, node: Ast.Node) !?Elem {
        const result = switch (node) {
            .False => Elem.boolean(false),
            .Null => Elem.nullConst,
            .NumberFloat => |f| Elem.numberFloat(f),
            .NumberString => |s| {
                var number_string_elem = try Elem.NumberStringElem.new(s.number, self.vm);
                number_string_elem.negated = s.negated;
                return number_string_elem.elem();
            },
            .Identifier => |ident| if (ident.kind == .Parser) {
                return null;
            } else {
                return Elem.valueVar(
                    try self.vm.strings.insert(ident.name),
                    ident.kind == .Underscore or ident.underscored,
                );
            },
            .String => |s| Elem.string(try self.vm.strings.insert(s)),
            .True => Elem.boolean(true),
            .Negation => |inner| {
                const inner_elem = try self.nodeToElem(inner.node);
                if (inner_elem) |elem| {
                    return elem.negateNumber() catch null;
                } else {
                    return null;
                }
            },
            else => null,
        };

        return result;
    }

    fn nodeToIdent(self: *Compiler, node: Ast.Node) ?Ast.IdentifierNode {
        _ = self;
        return switch (node) {
            .Identifier => |ident| ident,
            .True => .{
                .name = "true",
                .builtin = false,
                .underscored = false,
                .kind = .Parser,
            },
            .False => .{
                .name = "false",
                .builtin = false,
                .underscored = false,
                .kind = .Parser,
            },
            .Null => .{
                .name = "null",
                .builtin = false,
                .underscored = false,
                .kind = .Parser,
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
                const local = f.localVar(@intCast(i));
                switch (local.kind) {
                    .Parser => break :blk .Parser,
                    .Value, .Underscore => break :blk .Value,
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
                    try self.writeAnonymousFunction(rnode);
                },
                .False,
                .Null,
                .NumberFloat,
                .NumberString,
                .String,
                .True,
                => {
                    const elem = try self.nodeToElem(rnode.node) orelse return Error.InvalidAst;
                    const constId = try self.makeConstant(elem);
                    try self.emitUnaryOp(.GetConstant, constId, region);
                },
                .Identifier => |ident| switch (ident.kind) {
                    .Parser => {
                        try self.writeGetVar(ident, region);
                    },
                    .Value, .Underscore => @panic("Internal Error"),
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

    fn writeAnonymousFunction(self: *Compiler, rnode: *Ast.RNode) !void {
        const region = rnode.region;

        const function = try Elem.DynElem.Function.createAnonParser(
            self.vm,
            .{ .arity = 0, .region = region },
        );

        // Prevent GC
        const constId = try self.makeConstant(function.dyn.elem());

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

        _ = self.functions.pop() orelse @panic("Internal Error");

        try self.emitUnaryOp(.GetConstant, constId, region);
        try self.writeCaptureLocals(function, region);
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
        return self.chunk().addPattern(self.vm.allocator, patternElem);
    }

    fn astToPattern(self: *Compiler, rnode: *Ast.RNode, negation_count: u2) Error!Pattern {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .String,
            .True,
            => {
                const elem = try self.nodeToElem(node) orelse return Error.InvalidAst;
                switch (elem.getType()) {
                    .String => {
                        if (negation_count > 0) {
                            try self.printError(region, "Invalid pattern - unable to negate string", .{});
                            return Error.InvalidAst;
                        }
                        return Pattern{ .String = elem.asString() };
                    },
                    .NumberString => {
                        const ns = elem.asNumberString();
                        const maybe_negated = if (negation_count % 2 == 1) ns.negate() else ns;
                        const number = try maybe_negated.toNumberFloat(self.vm.strings);
                        return Pattern{ .Number = number.asFloat() };
                    },
                    .NumberFloat => {
                        return Pattern{ .Number = elem.asFloat() };
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
                    else => {
                        try self.printError(region, "Invalid AST in pattern", .{});
                        return Error.InvalidAst;
                    },
                }
            },
            .Identifier => |ident| {
                if (ident.kind == .Value or ident.kind == .Underscore) {
                    const sid = try self.vm.strings.insert(ident.name);
                    if (self.findGlobal(sid)) |globalElem| {
                        const constId = try self.makeConstant(globalElem);
                        return Pattern{ .Constant = .{
                            .sid = sid,
                            .idx = constId,
                            .negation_count = negation_count,
                        } };
                    } else if (self.localSlot(sid)) |slot| {
                        return Pattern{ .Local = .{
                            .sid = sid,
                            .idx = slot,
                            .negation_count = negation_count,
                        } };
                    } else {
                        @panic("Internal Error");
                    }
                } else {
                    try self.printError(region, "Parser variable not allowed in pattern", .{});
                    return Error.InvalidAst;
                }
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

                const function_ident = if (nameNode == .Identifier and nameNode.Identifier.kind == .Value)
                    nameNode.Identifier
                else {
                    try self.printError(region, "Parser is not valid in pattern", .{});
                    return Error.InvalidAst;
                };

                const function_name = try self.vm.strings.insert(function_ident.name);
                const globalFunctionElem = self.findGlobal(function_name);

                const functionVar: Pattern.PatternVar = if (globalFunctionElem) |globalElem|
                    .{
                        .sid = function_name,
                        .idx = try self.makeConstant(globalElem),
                        .negation_count = negation_count,
                    }
                else if (self.localSlot(function_name)) |slot|
                    .{
                        .sid = function_name,
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
                .Repeat => {
                    const pattern = try self.vm.allocator.create(Pattern);
                    pattern.* = try self.astToPattern(infix.left, negation_count);

                    const count = try self.vm.allocator.create(Pattern);
                    count.* = try self.astToPattern(infix.right, 0);
                    return Pattern{ .Repeat = .{ .pattern = pattern, .count = count } };
                },
                .Destructure => {
                    try self.printError(region, "Invalid AST: Nested destructure not allowed in pattern", .{});
                    return Error.InvalidAst;
                },
                .NumberSubtract => {
                    var mergeElems = ArrayList(Pattern){};
                    try self.collectPatternMergeElements(rnode, &mergeElems, negation_count);
                    return Pattern{ .Merge = mergeElems };
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
                } else if (infix.infixType == .NumberSubtract) {
                    try self.collectPatternMergeElements(infix.left, elements, negation_count);
                    try self.collectPatternMergeElements(infix.right, elements, negation_count + 1);
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
            .Identifier => |ident| {
                if (ident.kind == .Value or ident.kind == .Underscore) {
                    const sid = try self.vm.strings.insert(ident.name);
                    if (self.findGlobal(sid) == null) {
                        const newLocalId = try self.addLocalIfUndefined(ident, region);
                        if (newLocalId) |_| {
                            const elem = Elem.valueVar(
                                try self.vm.strings.insert(ident.name),
                                ident.underscored or ident.kind == .Underscore,
                            );
                            const constId = try self.makeConstant(elem);
                            try self.emitUnaryOp(.GetConstant, constId, region);
                        }
                    }
                }
            },
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .String,
            .True,
            => {},
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
            .Identifier => |ident| {
                const name = try self.vm.strings.insert(ident.name);
                const elem = Elem.valueVar(
                    name,
                    ident.kind == .Underscore or ident.underscored,
                );

                if (self.parentFunction().localSlot(name) != null) {
                    const newLocalId = try self.addLocalIfUndefined(ident, region);
                    if (newLocalId) |_| {
                        const constId = try self.makeConstant(elem);
                        try self.emitUnaryOp(.GetConstant, constId, region);
                    }
                }
            },
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .String,
            .True,
            => {},
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
                .Repeat => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.RepeatValue, region);
                },
                .NumberSubtract => {
                    try self.writeValueArgument(infix.left, false);
                    try self.writeValueArgument(infix.right, false);
                    try self.emitOp(.NegateNumber, region);
                    try self.emitOp(.Merge, region);
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
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeValueArgument(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
            },
            .String => {
                return error.UnlabeledStringValue;
            },
            .NumberString,
            .NumberFloat,
            => {
                return error.UnlabeledNumberValue;
            },
            .True, .False => return error.UnlabeledBooleanValue,
            .Null => return error.UnlabeledNullValue,
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
                .Repeat => {
                    try self.writeValue(infix.left, false);
                    try self.writeValue(infix.right, false);
                    try self.emitOp(.RepeatValue, region);
                },
                .NumberSubtract => {
                    if (infix.right.node == .NumberString) {
                        infix.right.node.NumberString.negated = !infix.right.node.NumberString.negated;
                        try self.writeValue(infix.left, false);
                        try self.writeValue(infix.right, false);
                        try self.emitOp(.Merge, region);
                    } else {
                        try self.writeValue(infix.left, false);
                        try self.writeValue(infix.right, false);
                        try self.emitOp(.NegateNumber, region);
                        try self.emitOp(.Merge, region);
                    }
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
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeValue(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
            },
            .Function => |function| {
                try self.writeValueFunctionCall(function.name, function.paramsOrArgs, region, isTailPosition);
            },
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.printError(region, "Parser is not valid in value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(region, "Underscore variable is only valid in patterns", .{});
                    return Error.InvalidAst;
                },
                .Value,
                => {
                    const name = try self.vm.strings.insert(ident.name);
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
                        // All value vars should already be local or global
                        @panic("Internal Error");
                    }
                },
            },
            .String,
            .NumberString,
            .NumberFloat,
            => {
                const elem = try self.nodeToElem(node) orelse return Error.InvalidAst;
                const constId = try self.makeConstant(elem);
                try self.emitUnaryOp(.GetConstant, constId, region);
            },
            .True => try self.emitOp(.True, region),
            .False => try self.emitOp(.False, region),
            .Null => try self.emitOp(.Null, region),
        }
    }

    fn writeValueFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.RNode,
        arguments: ArrayList(*Ast.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        // TODO: handle curried function calls like `Foo(A)(B)`
        // TODO: handle non-function with parens like `X = 1 ; "" $ X()`
        const function_ident = self.nodeToIdent(function_rnode.node) orelse @panic("Internal Error");
        const function_region = function_rnode.region;

        const functionName = try self.vm.strings.insert(function_ident.name);

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
        try array.append(self.vm, self.placeholderVar());
    }

    fn negateAndAppendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) !void {
        try self.writeValue(rnode, false);
        try self.emitOp(.NegateNumber, region);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.vm, self.placeholderVar());
    }

    fn writeArrayElem(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.RNode, index: u8, region: Region) Error!void {
        switch (rnode.node) {
            .Identifier => |ident| switch (ident.kind) {
                .Parser => {
                    try self.printError(rnode.region, "Parser is not valid in value", .{});
                    return Error.InvalidAst;
                },
                .Underscore => {
                    try self.printError(rnode.region, "Underscore variable is only valid in patterns", .{});
                    return Error.InvalidAst;
                },
                .Value => try self.appendDynamicValue(array, rnode, index, region),
            },
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .String,
            .True,
            => {
                const elem = try self.nodeToElem(rnode.node) orelse return Error.InvalidAst;
                try array.append(self.vm, elem);
            },
            .InfixNode => try self.appendDynamicValue(array, rnode, index, region),
            .Function => try self.appendDynamicValue(array, rnode, index, region),
            .Array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(self.vm, emptyArray.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index, region);
                }
            },
            .Object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(self.vm, emptyObject.dyn.elem());
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
                if (self.simplifyNegatedNumberNode(rnode)) |elem| {
                    try array.append(self.vm, elem);
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
                // Prevent GC before pair is inserted into object. The key
                // shouldn't be dynamically allocated, but just in case.
                if (key_elem.isType(.Dyn)) try self.vm.pushTempDyn(key_elem.asDyn());
                defer if (key_elem.isType(.Dyn)) self.vm.dropTempDyn();

                if (try self.literalPatternToElem(pair.value)) |val_elem| {
                    // Prevent GC before pair is inserted into object. The vale
                    // can be dynamically allocated.
                    if (val_elem.isType(.Dyn)) try self.vm.pushTempDyn(val_elem.asDyn());
                    defer if (val_elem.isType(.Dyn)) self.vm.dropTempDyn();

                    const key_sid = key_elem.asString();
                    try object.put(self.vm, key_sid, val_elem);
                } else {
                    try self.writeValueObjectVal(pair.value, key_elem);
                }
            } else {
                const pos = @as(u8, @intCast(index));
                try object.putReservedId(self.vm, pos, self.placeholderVar());
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

        if (firstPart.node != .String) {
            const empty_string = try self.makeConstant(Elem.string(try self.vm.strings.insert("")));
            try self.emitUnaryOp(.GetConstant, empty_string, region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeStringTemplatePart(part, context);
            if (i > 0 or firstPart.node != .String) {
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
            .String,
            .NumberString,
            .NumberFloat,
            .False,
            .True,
            .Null,
            => self.nodeToElem(rnode.node),
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

    fn simplifyPatternAst(self: *Compiler, rnode: *Ast.RNode) !void {
        switch (rnode.node) {
            .InfixNode => |infix| {
                try self.simplifyPatternAst(infix.left);
                try self.simplifyPatternAst(infix.right);

                switch (infix.infixType) {
                    .Merge => {
                        if (try self.ast.merge(infix.left, infix.right)) |merged| {
                            rnode.* = merged;
                        }
                    },
                    .TakeLeft => {
                        if (infix.left.node.isElem() and infix.right.node.isElem()) {
                            rnode.node = infix.left.node;
                        }
                    },
                    .TakeRight => {
                        if (infix.left.node.isElem() and infix.right.node.isElem()) {
                            rnode.node = infix.right.node;
                        }
                    },
                    .Or => {
                        if (infix.left.node.isElem()) {
                            rnode.node = infix.left.node;
                        }
                    },
                    .Return => {
                        if (infix.left.node.isElem() and infix.right.node.isElem()) {
                            rnode.node = infix.right.node;
                        }
                    },
                    .Repeat => {
                        if (try self.ast.repeat(infix.left, infix.right)) |repeated| {
                            rnode.* = repeated;
                        }
                    },
                    .Backtrack,
                    .Destructure,
                    .NumberSubtract,
                    => {},
                }
            },
            .Range => |range| {
                if (range.lower) |lower| try self.simplifyPatternAst(lower);
                if (range.upper) |upper| try self.simplifyPatternAst(upper);
            },
            .Negation => |inner| {
                try self.simplifyPatternAst(inner);

                switch (inner.node) {
                    .NumberString => |ns| {
                        rnode.node = Ast.Node{ .NumberString = .{ .number = ns.number, .negated = !ns.negated } };
                    },
                    .NumberFloat => |f| {
                        rnode.node = Ast.Node{ .NumberFloat = -f };
                    },
                    else => {},
                }
            },
            .ValueLabel => |inner| {
                try self.simplifyPatternAst(inner);
            },
            .Array => {},
            .Object => {},
            .StringTemplate => {},
            .Conditional => {},
            .Function,
            .DeclareGlobal,
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .Identifier,
            .String,
            .True,
            => {},
        }
    }

    fn simplifyNegatedNumberNode(self: *Compiler, rnode: *Ast.RNode) ?Elem {
        switch (rnode.node) {
            .Negation => |inner| {
                if (self.simplifyNegatedNumberNode(inner)) |num| {
                    return num.negateNumber() catch null;
                }
            },
            .NumberFloat => |f| return Elem.numberFloat(f),
            .NumberString => |s| {
                return Elem.numberStringFromBytes(s.number, self.vm) catch null;
            },
            else => {},
        }

        return null;
    }

    fn placeholderVar(self: *Compiler) Elem {
        const sId = self.vm.strings.getId("_");
        return Elem.valueVar(sId, true);
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

    fn addLocal(self: *Compiler, ident: Ast.IdentifierNode, region: Region) !?u8 {
        if (ident.builtin) {
            try self.printError(region, "Invalid function param, '@' is reserved for builtins", .{});
            return Error.InvalidAst;
        }

        if (self.currentFunction().functionType == .NamedValue and ident.kind == .Parser) {
            try self.printError(region, "Value function params must be values, found a parser", .{});
            return Error.InvalidAst;
        }

        const sid = try self.vm.strings.insert(ident.name);

        return self.currentFunction().addLocal(self.vm, .{
            .sid = sid,
            .kind = switch (ident.kind) {
                .Parser => .Parser,
                .Value => .Value,
                .Underscore => .Underscore,
            },
        }) catch |err| switch (err) {
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

    fn addLocalIfUndefined(self: *Compiler, ident: Ast.IdentifierNode, region: Region) !?u8 {
        return self.addLocal(ident, region) catch |err| switch (err) {
            error.VariableNameUsedInScope => return null,
            else => return err,
        };
    }

    pub fn localSlot(self: *Compiler, name: StringTable.Id) ?u8 {
        return self.currentFunction().localSlot(name);
    }

    fn emitJump(self: *Compiler, op: OpCode, region: Region) !usize {
        try self.emitOp(op, region);
        // Dummy operands that will be patched later
        try self.chunk().writeShort(self.vm.allocator, 0xffff, region);
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

    fn emitJumpBack(self: *Compiler, op: OpCode, targetOffset: usize, region: Region) !void {
        try self.emitOp(op, region);
        const currentOffset = self.chunk().nextByteIndex();
        const jump = (currentOffset + 2) - targetOffset;
        try self.chunk().writeShort(self.vm.allocator, @as(u16, @intCast(jump)), region);
    }

    fn emitByte(self: *Compiler, byte: u8, region: Region) !void {
        try self.chunk().write(self.vm.allocator, byte, region);
    }

    fn emitOp(self: *Compiler, op: OpCode, region: Region) !void {
        try self.chunk().writeOp(self.vm.allocator, op, region);
    }

    fn emitEnd(self: *Compiler) !void {
        const r = self.chunk().regions.getLast();
        try self.chunk().writeOp(self.vm.allocator, .End, Region.new(r.end, r.end));
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, region: Region) !void {
        try self.emitOp(op, region);
        try self.emitByte(byte, region);
    }

    fn makeConstant(self: *Compiler, elem: Elem) !u8 {
        return self.chunk().addConstant(self.vm.allocator, elem) catch |err| switch (err) {
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
        try self.writers.err.print("\n\n", .{});

        try self.writers.err.print("{s}:", .{self.targetModule.name});
        try region.printLineRelative(self.targetModule.source, self.writers.err);
        try self.writers.err.print(":\n", .{});

        try self.targetModule.highlight(region, self.writers.err);
        try self.writers.err.print("\n", .{});
    }
};

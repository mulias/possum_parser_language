const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
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
    constant_map: AutoHashMap(u64, usize),

    const Error = error{
        InvalidAst,
        MaxFunctionArgs,
        MaxFunctionLocals,
        OutOfMemory,
        TooManyConstants,
        TooManyPatterns,
        ShortOverflow,
        VariableNameUsedInScope,
        AliasCycle,
        UnknownVariable,
        UndefinedVariable,
        FunctionCallTooManyArgs,
        FunctionCallTooFewArgs,
        RangeNotSingleCodepoint,
        RangeCodepointsUnordered,
        RangeIntegersUnordered,
        RangeInvalidNumberFormat,
    } || Writer.Error;

    pub fn init(vm: *VM, targetModule: *Module, ast: Ast, printBytecode: bool) !Compiler {
        const main = try Elem.DynElem.Function.create(vm, .{
            .module = targetModule,
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
            .constant_map = AutoHashMap(u64, usize){},
        };
    }

    fn findGlobal(self: *Compiler, sid: StringTable.Id) ?Elem {
        const targetModuleIndex = for (self.vm.modules.items, 0..) |module, i| {
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
        self.constant_map.deinit(self.vm.allocator);
        self.functions.deinit(self.vm.allocator);
    }

    pub fn compile(self: *Compiler) !?*Elem.DynElem.Function {
        try self.declareGlobals();
        try self.resolveAliaseChains();
        try self.compileFunctions();

        if (self.ast.main) |main| {
            return self.compileMain(main);
        } else {
            return null;
        }
    }

    fn declareGlobals(self: *Compiler) !void {
        var decl_iter = self.ast.declarations.iterator();
        while (decl_iter.next()) |entry| {
            const decl = entry.value_ptr.*;
            if (self.isAliasChain(decl)) {
                // Wait to resolve until all globals are declared
                continue;
            } else if (try self.getAliasBody(decl)) |body_elem| {
                const sid = decl.identName();
                try self.targetModule.addGlobal(self.vm.allocator, sid, body_elem);
                try self.declareAlias(sid, body_elem);
            } else {
                try self.declareFunction(decl);
            }
        }
    }

    fn compileFunctions(self: *Compiler) !void {
        var decl_iter = self.ast.declarations.iterator();
        while (decl_iter.next()) |entry| {
            const decl = entry.value_ptr.*;
            if (!self.isAlias(decl) and !self.isAliasChain(decl)) {
                try self.compileFunction(decl);
            }
        }
    }

    fn resolveAliaseChains(self: *Compiler) !void {
        var decl_iter = self.ast.declarations.iterator();
        while (decl_iter.next()) |entry| {
            const decl = entry.value_ptr.*;

            if (self.isAliasChain(decl)) {
                try self.resolveAliasChain(decl);
            }
        }
    }

    fn compileMain(self: *Compiler, main_rnode: *Ast.Parser.RNode) !?*Elem.DynElem.Function {
        try self.addValueLocals(.{ .parser = main_rnode });
        try self.writeParser(main_rnode, false);
        try self.emitEnd();

        const main_fn = self.functions.pop().?;

        // Update the main function's source region with the actual main parser region
        main_fn.chunk.source_region = main_rnode.region;

        if (self.printBytecode) {
            try main_fn.disassemble(self.vm.*, self.writers.debug);
        }

        return main_fn;
    }

    fn declareFunction(self: *Compiler, decl: Ast.ParserOrValue.Declaration) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const function_name = decl.identName();

        if (decl.identBuiltin()) {
            try self.printError(decl.identRegion(), "unable to define builtin function", .{});
            return Error.InvalidAst;
        }

        const function_type: Elem.DynElem.FunctionType = switch (decl) {
            .parser => .NamedParser,
            .value => .NamedValue,
        };

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .module = self.targetModule,
            .name = function_name,
            .functionType = function_type,
            .arity = 0,
            .region = decl.region(),
        });

        try self.targetModule.addGlobal(self.vm.allocator, function_name, function.dyn.elem());
        try self.functions.append(self.vm.allocator, function);

        switch (decl) {
            .parser => |p_decl| {
                for (p_decl.node.params.items) |param_ident| {
                    _ = try self.addLocal(param_ident);
                }
                // addLocal will fail if the number of params is too large
                function.arity = @as(u8, @intCast(p_decl.node.params.items.len));
            },
            .value => |v_decl| {
                for (v_decl.node.params.items) |param_ident| {
                    _ = try self.addLocal(.{ .value = param_ident });
                }
                // addLocal will fail if the number of params is too large
                function.arity = @as(u8, @intCast(v_decl.node.params.items.len));
            },
        }

        _ = self.functions.pop();
    }

    fn declareAlias(self: *Compiler, sid: StringTable.Id, bodyElem: Elem) !void {
        // Add an alias to the global namespace. Set the given body element as the alias's value.
        try self.targetModule.addGlobal(self.vm.allocator, sid, bodyElem);
    }

    fn resolveAliasChain(self: *Compiler, decl: Ast.ParserOrValue.Declaration) !void {
        var path = AutoHashMap(StringTable.Id, void){};
        defer path.deinit(self.vm.allocator);

        var target_ident_name = decl.identName();

        while (true) {
            if (path.contains(target_ident_name)) {
                try self.printError(decl.region(), "Circular alias dependency detected for '{s}'", .{self.vm.strings.get(decl.identName())});
                return Error.AliasCycle;
            } else {
                try path.put(self.vm.allocator, target_ident_name, undefined);
            }

            if (self.ast.declarations.get(target_ident_name)) |next_decl| {
                if (self.getAliasChainName(next_decl)) |next_target_ident_name| {
                    target_ident_name = next_target_ident_name;
                    continue;
                }
            }

            break;
        }

        const alias_sid = decl.identName();
        const terminal_sid = target_ident_name;

        // Try to resolve to a direct alias
        if (self.ast.declarations.get(target_ident_name)) |terminal_decl| {
            if (try self.getAliasBody(terminal_decl)) |terminal_elem| {
                try self.targetModule.addGlobal(self.vm.allocator, alias_sid, terminal_elem);
                return;
            }
        }

        // Try to resolve to a compiled function
        if (self.findGlobal(terminal_sid)) |terminal_elem| {
            try self.targetModule.addGlobal(self.vm.allocator, alias_sid, terminal_elem);
            return;
        } else {
            try self.printError(decl.region(), "Could not resolve alias, unknown variable '{s}'", .{self.vm.strings.get(target_ident_name)});
            return Error.UnknownVariable;
        }
    }

    fn compileFunction(self: *Compiler, decl: Ast.ParserOrValue.Declaration) !void {
        const global_sid = decl.identName();
        const globalVal = (self.findGlobal(global_sid)).?;

        const function = globalVal.asDyn().asFunction();

        try self.functions.append(self.vm.allocator, function);

        switch (decl) {
            .parser => |p| {
                try self.addValueLocals(.{ .parser = p.node.body });
                try self.writeParser(p.node.body, true);
            },
            .value => |v| {
                try self.addValueLocals(.{ .value = v.node.body });
                try self.writeValue(v.node.body, true);
            },
        }

        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        _ = self.functions.pop();
    }

    fn writeParser(self: *Compiler, rnode: *Ast.Parser.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .backtrack => |backtrack| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(backtrack.left, false);
                const jumpIndex = try self.emitJump(.Backtrack, region);
                try self.writeParser(backtrack.right, isTailPosition);
                try self.patchJump(jumpIndex, region);
            },
            .merge => |merge| {
                try self.writeParser(merge.left, false);
                try self.writeParser(merge.right, false);
                try self.emitOp(.Merge, region);
            },
            .take_left => |take_left| {
                try self.writeParser(take_left.left, false);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeParser(take_left.right, false);
                try self.emitOp(.TakeLeft, region);
                try self.patchJump(jumpIndex, region);
            },
            .take_right => |take_right| {
                try self.writeParser(take_right.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeParser(take_right.right, isTailPosition);
                try self.patchJump(jumpIndex, region);
            },
            .destructure => |destructure| {
                try self.writeParser(destructure.left, false);
                const patternId = try self.createPattern(destructure.right);
                try self.emitPattern(patternId, region);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(or_node.left, false);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeParser(or_node.right, isTailPosition);
                try self.patchJump(jumpIndex, region);
            },
            .@"return" => |return_node| {
                try self.writeParser(return_node.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(return_node.right, true);
                try self.patchJump(jumpIndex, region);
            },
            .repeat => |repeat| {
                try self.writeParserRepeat(repeat.left, repeat.right, region);
            },
            .range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    try self.writeRangeParser(bounds.lower.?, bounds.upper.?, region);
                } else if (bounds.lower != null) {
                    try self.writeLowerBoundedRangeParser(bounds.lower.?, region);
                } else {
                    try self.writeUpperBoundedRangeParser(bounds.upper.?, region);
                }
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .identifier => |ident| {
                try self.writeGetVar(ident.name, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .function_call => |function_call| {
                try self.writeParserFunctionCall(function_call.function, function_call.args, region, isTailPosition);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                try self.writeConstant(elem, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .string => |string| {
                const sid = try self.vm.strings.insert(string);
                const elem = Elem.string(sid);
                try self.writeConstant(elem, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .string_template => |parts| {
                try self.writeStringTemplateParser(parts, region);
            },
            .conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeParser(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeParser(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
            },
        }
    }

    fn writeParserFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.Parser.RNode,
        arguments: ArrayList(Ast.ParserOrValue.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        // TODO: handle curried function calls like `foo(a)(b)`
        const function_ident = switch (function_rnode.node) {
            .identifier => |ident| ident,
            else => @panic("todo"),
        };
        const function_region = function_rnode.region;

        const functionName = function_ident.name;

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.findGlobal(functionName)) |global| {
                function = global.asDyn().asFunction();
                try self.writeConstant(global, function_region);
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

    fn writeRangeParser(self: *Compiler, low: *Ast.Parser.RNode, high: *Ast.Parser.RNode, region: Region) !void {
        const low_elem = try self.parserNodeToElem(low.node);
        const high_elem = try self.parserNodeToElem(high.node);

        if (low.node == .string and high.node == .string) {
            const low_str = low_elem.?.asString();
            const high_str = high_elem.?.asString();
            const low_bytes = self.vm.strings.get(low_str);
            const high_bytes = self.vm.strings.get(high_str);
            const low_codepoint = parsing.utf8Decode(low_bytes) orelse {
                try self.printError(high.region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };
            const high_codepoint = parsing.utf8Decode(high_bytes) orelse {
                try self.printError(high.region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };

            if (low_codepoint > high_codepoint) {
                try self.printError(low.region.merge(high.region), "Range upper bound codepoint is less than the lower bound", .{});
                return Error.RangeCodepointsUnordered;
            } else if (low_codepoint == 0 and high_codepoint == 0x10ffff) {
                try self.emitOp(.ParseCodepoint, region);
            } else if (low_codepoint <= 255 and high_codepoint <= 255) {
                try self.emitOp(.ParseCodepointRange, region);
                try self.emitByte(@as(u8, @intCast(low_codepoint)), low.region);
                try self.emitByte(@as(u8, @intCast(high_codepoint)), high.region);
            } else {
                try self.writeConstant(low_elem.?, low.region);
                try self.writeConstant(high_elem.?, high.region);
                try self.emitOp(.ParseRange, region);
            }
        } else if (low.node == .number_string and high.node == .number_string) {
            const low_ns = low_elem.?.asNumberString();
            const high_ns = high_elem.?.asNumberString();

            const low_num = low_ns.toNumberFloat(self.vm.strings);
            const high_num = high_ns.toNumberFloat(self.vm.strings);

            if (!low_num.isInteger(self.vm.strings)) {
                try self.printError(low.region, "Range bound must be an integer", .{});
                return Error.RangeInvalidNumberFormat;
            }
            if (!high_num.isInteger(self.vm.strings)) {
                try self.printError(high.region, "Range bound must be an integer", .{});
                return Error.RangeInvalidNumberFormat;
            }

            const low_int = try low_num.asInteger(self.vm.strings);
            const high_int = try high_num.asInteger(self.vm.strings);

            if (low_int > high_int) {
                try self.printError(low.region.merge(high.region), "Range upper bound is less than the lower bound", .{});
                return Error.RangeIntegersUnordered;
            } else if (0 <= low_int and low_int <= 255 and 0 <= high_int and high_int <= 255) {
                try self.emitOp(.ParseIntegerRange, region);
                try self.emitByte(@as(u8, @intCast(low_int)), low.region);
                try self.emitByte(@as(u8, @intCast(high_int)), high.region);
            } else {
                try self.writeConstant(low_elem.?, low.region);
                try self.writeConstant(high_elem.?, high.region);
                try self.emitOp(.ParseRange, region);
            }
        } else {
            switch (low.node) {
                .string => {
                    const low_str = low_elem.?.asString();
                    const low_bytes = self.vm.strings.get(low_str);
                    _ = parsing.utf8Decode(low_bytes) orelse {
                        try self.printError(high.region, "Character range bound must be a single codepoint", .{});
                        return Error.RangeNotSingleCodepoint;
                    };

                    try self.writeConstant(low_elem.?, low.region);
                },
                .number_string => {
                    const low_ns = low_elem.?.asNumberString();
                    const low_num = low_ns.toNumberFloat(self.vm.strings);

                    if (!low_num.isInteger(self.vm.strings)) {
                        try self.printError(low.region, "Range bound must be an integer", .{});
                        return Error.RangeInvalidNumberFormat;
                    }

                    try self.writeConstant(low_num, low.region);
                },
                .identifier => |ident| {
                    try self.writeGetVar(ident.name, low.region);
                },
                .negation => |inner| {
                    try self.writeNegatedParserElem(inner, region);
                },
                else => {
                    try self.printError(low.region, "Range bound must be an integer or codepoint", .{});
                    return Error.InvalidAst;
                },
            }

            switch (high.node) {
                .string => {
                    const high_str = high_elem.?.asString();
                    const high_bytes = self.vm.strings.get(high_str);
                    _ = parsing.utf8Decode(high_bytes) orelse {
                        try self.printError(high.region, "Character range bound must be a single codepoint", .{});
                        return Error.RangeNotSingleCodepoint;
                    };

                    try self.writeConstant(high_elem.?, high.region);
                },
                .number_string => {
                    const high_ns = high_elem.?.asNumberString();
                    const high_num = high_ns.toNumberFloat(self.vm.strings);

                    if (!high_num.isInteger(self.vm.strings)) {
                        try self.printError(high.region, "Range bound must be an integer", .{});
                        return Error.RangeInvalidNumberFormat;
                    }

                    try self.writeConstant(high_num, high.region);
                },
                .identifier => |ident| {
                    try self.writeGetVar(ident.name, high.region);
                },
                .negation => |inner| {
                    try self.writeNegatedParserElem(inner, region);
                },
                else => {
                    try self.printError(high.region, "Range bound must be an integer or codepoint", .{});
                    return Error.InvalidAst;
                },
            }

            try self.emitOp(.ParseRange, region);
        }
    }

    fn writeLowerBoundedRangeParser(self: *Compiler, low: *Ast.Parser.RNode, region: Region) !void {
        const low_elem = try self.parserNodeToElem(low.node);
        const low_region = low.region;

        switch (low.node) {
            .string => {
                const low_str = low_elem.?.asString();
                const low_bytes = self.vm.strings.get(low_str);
                const low_codepoint = parsing.utf8Decode(low_bytes) orelse {
                    try self.printError(low.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };

                if (low_codepoint == 0) {
                    try self.emitOp(.ParseCodepoint, region);
                } else {
                    try self.writeConstant(low_elem.?, low_region);
                    try self.emitOp(.ParseLowerBoundedRange, region);
                }
            },
            .number_string => {
                const low_ns = low_elem.?.asNumberString();
                const low_num = low_ns.toNumberFloat(self.vm.strings);
                const low_f = low_num.asFloat();

                if (@trunc(low_f) != low_f) {
                    try self.printError(low.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }

                try self.writeConstant(low_num, low_region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            .identifier => |ident| {
                try self.writeGetVar(ident.name, region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            else => {
                try self.printError(low.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeUpperBoundedRangeParser(self: *Compiler, high: *Ast.Parser.RNode, region: Region) !void {
        const high_elem = try self.parserNodeToElem(high.node);
        const high_region = high.region;

        switch (high.node) {
            .string => {
                const high_str = high_elem.?.asString();
                const high_bytes = self.vm.strings.get(high_str);
                const high_codepoint = parsing.utf8Decode(high_bytes) orelse {
                    try self.printError(high.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };

                if (high_codepoint == 0x10ffff) {
                    try self.emitOp(.ParseCodepoint, region);
                } else {
                    try self.writeConstant(high_elem.?, high_region);
                    try self.emitOp(.ParseUpperBoundedRange, region);
                }
            },
            .number_string => {
                const high_ns = high_elem.?.asNumberString();
                const high_num = high_ns.toNumberFloat(self.vm.strings);
                const high_f = high_num.asFloat();

                if (@trunc(high_f) != high_f) {
                    try self.printError(high.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }

                try self.writeConstant(high_num, high_region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            .identifier => |ident| {
                try self.writeGetVar(ident.name, region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(inner, region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            else => {
                try self.printError(high.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeParserRepeat(self: *Compiler, parser: *Ast.Parser.RNode, repeat: *Ast.Pattern.RNode, region: Region) !void {
        switch (repeat.node) {
            .number_float,
            .number_string,
            => {
                return self.writeParserRepeatCount(parser, repeat, region);
            },
            .range => |bounds| {
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
            .identifier => |ident| {
                if (self.findGlobal(ident.name) != null) {
                    // Globals are always bound to a concrete value
                    try self.writeParserRepeatCount(parser, repeat, region);
                } else {
                    const slot = self.localSlot(ident.name).?;
                    if (self.currentFunction().arity > slot) {
                        // The local var is a function arg, so we know it's bound
                        try self.writeParserRepeatCount(parser, repeat, region);
                    } else {
                        // The value may or may not be bound. Generate
                        // conditional code covering both cases.
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
                }
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

    fn writeParserRepeatCount(self: *Compiler, parser: *Ast.Parser.RNode, count: *Ast.Pattern.RNode, repeat_region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(Elem.nullConst, parser.region);

        // Create the counter, validate it, if it starts at zero
        // then skip to the end and return null
        try self.writePatternAsBoundRepeatValue(count);
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

    fn writeParserRepeatUnknownCount(self: *Compiler, parser: *Ast.Parser.RNode, count: *Ast.Pattern.RNode, repeat_region: Region) Error!void {
        // Count accumulator
        try self.writeConstant(Elem.numberFloat(0), count.region);

        // Value accumulator
        try self.writeConstant(Elem.nullConst, parser.region);

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
        try self.emitPattern(patternId, repeat_region);

        // Cleanup: drop the counter
        try self.emitOp(.Drop, parser.region);
    }

    fn writeParserRepeatRangeBounded(self: *Compiler, parser: *Ast.Parser.RNode, lower: *Ast.Pattern.RNode, upper: *Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writePatternAsBoundRepeatValue(lower);
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
        try self.writePatternAsBoundRepeatValue(upper);
        try self.writePatternAsBoundRepeatValue(lower);
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

    fn writeParserRepeatRangeLowerBounded(self: *Compiler, parser: *Ast.Parser.RNode, lower: *Ast.Pattern.RNode, upper_pattern: ?*Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writePatternAsBoundRepeatValue(lower);
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
            try self.writePatternAsBoundRepeatValue(lower);
            try self.emitOp(.Merge, parser.region);
            const patternId = try self.createPattern(upper);
            try self.emitPattern(patternId, upper.region);
            try self.emitOp(.Swap, region);
        }

        try self.patchJump(failureLowerBoundJump, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Drop, region);
    }

    fn writeParserRepeatRangeUpperBounded(self: *Compiler, parser: *Ast.Parser.RNode, lower_pattern: ?*Ast.Pattern.RNode, upper: *Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip to end and return null
        try self.writePatternAsBoundRepeatValue(upper);
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
            try self.writePatternAsBoundRepeatValue(upper);
            try self.emitOp(.Merge, region);
            const patternId = try self.createPattern(lower);
            try self.emitPattern(patternId, lower.region);
        }

        try self.emitOp(.Drop, region);
    }

    fn isBoundedRepeatCount(self: *Compiler, rnode: *Ast.Pattern.RNode) bool {
        return switch (rnode.node) {
            .function_call,
            .false,
            .null,
            .number_float,
            .number_string,
            .string,
            .true,
            => true,
            .identifier => |ident| {
                if (ident.builtin) {
                    return true;
                } else {
                    if (self.findGlobal(ident.name) != null) {
                        return true;
                    } else if (self.localSlot(ident.name)) |slot| {
                        return self.currentFunction().arity > slot;
                    } else {
                        return false;
                    }
                }
            },
            .range => |range| {
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
            .negation => |inner| self.isBoundedRepeatCount(inner),
            .merge => |merge| self.isBoundedRepeatCount(merge.left) and self.isBoundedRepeatCount(merge.right),
            .array,
            .object,
            .string_template,
            .repeat,
            => false,
        };
    }

    fn writeNegatedParserElem(self: *Compiler, negated: *Ast.Parser.RNode, region: Region) !void {
        switch (negated.node) {
            .negation => {
                try self.printError(region, "Double-negated parser", .{});
                return Error.InvalidAst;
            },
            .number_string => |ns| {
                if (ns.negated) {
                    try self.printError(region, "Double-negated parser", .{});
                    return Error.InvalidAst;
                }
                const elem = try self.numberStringNodeToElem(ns.number, true);
                try self.writeConstant(elem, negated.region);
            },
            .identifier => |ident| {
                // Determine at runtime if negating the parser is valid
                try self.writeGetVar(ident.name, region);
                try self.emitOp(.NegateParser, region);
            },
            else => {
                try self.printError(region, "Negated parser must be a number or named number parser", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeGetVar(self: *Compiler, name: StringTable.Id, region: Region) !void {
        if (self.localSlot(name)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, region);
        } else {
            if (self.findGlobal(name)) |globalElem| {
                try self.writeConstant(globalElem, region);
            } else {
                try self.printError(region, "undefined variable '{s}'", .{self.vm.strings.get(name)});
                return Error.UndefinedVariable;
            }
        }
    }

    fn parserNodeToElem(self: *Compiler, node: Ast.Parser.Node) !?Elem {
        const result = switch (node) {
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
            .identifier => {
                return null;
            },
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            else => null,
        };

        return result;
    }

    fn valueNodeToElem(self: *Compiler, node: Ast.Value.Node) !?Elem {
        const result = switch (node) {
            .false => Elem.boolean(false),
            .null => Elem.nullConst,
            .number_float => |f| Elem.numberFloat(f),
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
            .identifier => return null,
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            .true => Elem.boolean(true),
            else => null,
        };

        return result;
    }

    const ArgType = enum { Parser, Value, Unspecified };

    fn writeParserFunctionArguments(
        self: *Compiler,
        arguments: ArrayList(Ast.ParserOrValue.RNode),
        function: ?*Elem.DynElem.Function,
    ) Error!u8 {
        const arg_count = arguments.items.len;

        if (arg_count > std.math.maxInt(u8)) {
            const first_arg = arguments.items[0];
            const last_arg = arguments.items[arg_count - 1];
            const region = first_arg.region().merge(last_arg.region());

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
                    break :blk first_arg.region().merge(last_arg.region());
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

    fn writeParserFunctionArgument(self: *Compiler, rnode: Ast.ParserOrValue.RNode, argType: ArgType) !void {
        const region = rnode.region();

        switch (argType) {
            .Parser => switch (rnode) {
                .parser => |p| switch (p.node) {
                    .number_string => |ns| {
                        const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                        try self.writeConstant(elem, region);
                    },
                    .string => |string| {
                        const sid = try self.vm.strings.insert(string);
                        const elem = Elem.string(sid);
                        try self.writeConstant(elem, region);
                    },
                    .identifier => |ident| {
                        try self.writeGetVar(ident.name, region);
                    },
                    else => {
                        try self.writeParserAnonymousFunction(p);
                    },
                },
                .value => |v| {
                    try self.printError(v.region, "Expected parser but got value", .{});
                    return Error.InvalidAst;
                },
            },
            .Value => switch (rnode) {
                .value => |v| try self.writeValue(v, false),
                .parser => |p| {
                    try self.printError(p.region, "Expected value but got parser", .{});
                    return Error.InvalidAst;
                },
            },
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

    fn writeParserAnonymousFunction(self: *Compiler, rnode: *Ast.Parser.RNode) !void {
        const region = rnode.region;

        const function = try Elem.DynElem.Function.createAnonParser(
            self.vm,
            .{ .module = self.targetModule, .arity = 0, .region = region },
        );

        // Prevent GC
        const constId = try self.makeConstant(function.dyn.elem());

        try self.functions.append(self.vm.allocator, function);

        try self.addClosureLocals(.{ .parser = rnode });

        if (function.locals.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, region);
        }

        try self.writeParser(rnode, true);
        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        _ = self.functions.pop();

        try self.emitConstant(constId, region);
        try self.writeCaptureLocals(function, region);
    }

    fn writeCaptureLocals(self: *Compiler, targetFunction: *Elem.DynElem.Function, region: Region) !void {
        var captureCount: u8 = 0;
        for (self.currentFunction().locals.items) |local| {
            if (targetFunction.localSlot(local.name())) |_| {
                captureCount += 1;
            }
        }

        if (captureCount > 0) {
            const localCount = @as(u8, @intCast(targetFunction.locals.items.len));
            try self.emitUnaryOp(.CreateClosure, localCount, region);

            for (targetFunction.locals.items) |targetLocal| {
                if (self.localSlot(targetLocal.name())) |fromSlot| {
                    try self.emitUnaryOp(.CaptureLocal, @as(u8, @intCast(fromSlot)), region);
                }
            }
        }
    }

    fn createPattern(self: *Compiler, rnode: *Ast.Pattern.RNode) Error!u24 {
        const patternElem = try self.astToPattern(rnode, 0);
        return @intCast(try self.targetModule.addPattern(self.vm.allocator, patternElem));
    }

    fn astToPattern(self: *Compiler, rnode: *Ast.Pattern.RNode, negation_count: u2) Error!Pattern {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .false => {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate boolean", .{});
                    return Error.InvalidAst;
                }
                return Pattern{ .Boolean = false };
            },
            .true => {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate boolean", .{});
                    return Error.InvalidAst;
                }
                return Pattern{ .Boolean = true };
            },
            .null => {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate null", .{});
                    return Error.InvalidAst;
                }
                return Pattern{ .Null = {} };
            },
            .number_float => |f| {
                if (negation_count % 2 == 1) {
                    return Pattern{ .Number = -f };
                } else {
                    return Pattern{ .Number = f };
                }
            },
            .number_string => |ns| {
                const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const maybe_negated = if (negation_count % 2 == 1) ns_elem.asNumberString().negate() else ns_elem.asNumberString();
                const number = maybe_negated.toNumberFloat(self.vm.strings);
                return Pattern{ .Number = number.asFloat() };
            },
            .string => |s| {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }
                const sid = try self.vm.strings.insert(s);
                return Pattern{ .String = sid };
            },
            .identifier => |ident| {
                const sid = ident.name;
                if (self.findGlobal(sid)) |globalElem| {
                    const constId = try self.makeConstant(globalElem);
                    return Pattern{ .Constant = .{
                        .sid = sid,
                        .idx = constId,
                        .negation_count = negation_count,
                    } };
                } else {
                    const slot = self.localSlot(sid).?;
                    return Pattern{ .Local = .{
                        .sid = sid,
                        .idx = slot,
                        .negation_count = negation_count,
                    } };
                }
            },
            .array => |elements| {
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
            .object => |pairs| {
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
            .string_template => |segments| {
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
            .range => |bounds| {
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
            .negation => |inner| {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                return self.astToPattern(inner, new_negation_count);
            },
            .function_call => |function_call| {
                const nameNode = function_call.function.node;

                const function_ident = if (nameNode == .identifier and !nameNode.identifier.underscored)
                    nameNode.identifier
                else {
                    try self.printError(region, "Parser is not valid in pattern", .{});
                    return Error.InvalidAst;
                };

                const globalFunctionElem = self.findGlobal(function_ident.name);

                const functionVar: Pattern.PatternVar = if (globalFunctionElem) |globalElem|
                    .{
                        .sid = function_ident.name,
                        .idx = try self.makeConstant(globalElem),
                        .negation_count = negation_count,
                    }
                else if (self.localSlot(function_ident.name)) |slot|
                    .{
                        .sid = function_ident.name,
                        .idx = slot,
                        .negation_count = negation_count,
                    }
                else {
                    try self.printError(function_call.function.region, "Unknown function in pattern", .{});
                    return Error.InvalidAst;
                };

                var args = ArrayList(Pattern){};
                for (function_call.args.items) |arg| {
                    const argPattern = try self.astToValueInPattern(arg, 0);
                    try args.append(self.vm.allocator, argPattern);
                }

                return Pattern{ .FunctionCall = .{
                    .function = functionVar,
                    .kind = if (globalFunctionElem != null) .Constant else .Local,
                    .args = args,
                } };
            },
            .merge => {
                var mergeElems = ArrayList(Pattern){};
                try self.collectPatternMergeElements(rnode, &mergeElems, negation_count);
                return Pattern{ .Merge = mergeElems };
            },
            .repeat => |infix| {
                const pattern = try self.vm.allocator.create(Pattern);
                pattern.* = try self.astToPattern(infix.left, negation_count);

                const count = try self.vm.allocator.create(Pattern);
                count.* = try self.astToPattern(infix.right, 0);
                return Pattern{ .Repeat = .{ .pattern = pattern, .count = count } };
            },
        }
    }

    fn collectPatternMergeElements(self: *Compiler, rnode: *Ast.Pattern.RNode, elements: *ArrayList(Pattern), negation_count: u2) Error!void {
        const node = rnode.node;

        switch (node) {
            .merge => |merge| {
                try self.collectPatternMergeElements(merge.left, elements, negation_count);
                try self.collectPatternMergeElements(merge.right, elements, negation_count);
                return;
            },
            else => {},
        }

        // Merge pattern part
        const pattern = try self.astToPattern(rnode, negation_count);
        try elements.append(self.vm.allocator, pattern);
    }

    fn astToValueInPattern(self: *Compiler, rnode: *Ast.Value.RNode, negation_count: u2) Error!Pattern {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .false => {
                return Pattern{ .Boolean = false };
            },
            .true => {
                return Pattern{ .Boolean = true };
            },
            .null => {
                return Pattern{ .Null = {} };
            },
            .number_float => |f| {
                if (negation_count % 2 == 1) {
                    return Pattern{ .Number = -f };
                } else {
                    return Pattern{ .Number = f };
                }
            },
            .number_string => |ns| {
                const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const maybe_negated = if (negation_count % 2 == 1) ns_elem.asNumberString().negate() else ns_elem.asNumberString();
                const number = maybe_negated.toNumberFloat(self.vm.strings);
                return Pattern{ .Number = number.asFloat() };
            },
            .string => |s| {
                if (negation_count > 0) {
                    try self.printError(region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }
                const sid = try self.vm.strings.insert(s);
                return Pattern{ .String = sid };
            },
            .negation => |inner| {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                return self.astToValueInPattern(inner, new_negation_count);
            },
            .identifier => |ident| {
                if (self.findGlobal(ident.name)) |elem| {
                    return Pattern{ .Constant = .{
                        .sid = ident.name,
                        .idx = try self.makeConstant(elem),
                        .negation_count = negation_count,
                    } };
                } else {
                    const slot = self.localSlot(ident.name).?;
                    return Pattern{ .Local = .{
                        .sid = ident.name,
                        .idx = slot,
                        .negation_count = negation_count,
                    } };
                }
            },
            else => {
                try self.printError(region, "Unsupported value node in pattern", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn addValueLocals(self: *Compiler, rnode: Ast.ParserOrValueOrPattern.RNode) !void {
        const region = rnode.region();

        switch (rnode) {
            .parser => |p| {
                switch (p.node) {
                    .@"return" => |ret| {
                        try self.addValueLocals(.{ .parser = ret.left });
                        try self.addValueLocals(.{ .value = ret.right });
                    },
                    .function_call => |func| {
                        try self.addValueLocals(.{ .parser = func.function });
                        for (func.args.items) |arg| {
                            switch (arg) {
                                .parser => |p_arg| try self.addValueLocals(.{ .parser = p_arg }),
                                .value => |v_arg| try self.addValueLocals(.{ .value = v_arg }),
                            }
                        }
                    },
                    .@"or" => |or_node| {
                        try self.addValueLocals(.{ .parser = or_node.left });
                        try self.addValueLocals(.{ .parser = or_node.right });
                    },
                    .backtrack => |bt_node| {
                        try self.addValueLocals(.{ .parser = bt_node.left });
                        try self.addValueLocals(.{ .parser = bt_node.right });
                    },
                    .merge => |merge_node| {
                        try self.addValueLocals(.{ .parser = merge_node.left });
                        try self.addValueLocals(.{ .parser = merge_node.right });
                    },
                    .take_left => |take_node| {
                        try self.addValueLocals(.{ .parser = take_node.left });
                        try self.addValueLocals(.{ .parser = take_node.right });
                    },
                    .take_right => |take_node| {
                        try self.addValueLocals(.{ .parser = take_node.left });
                        try self.addValueLocals(.{ .parser = take_node.right });
                    },
                    .conditional => |cond| {
                        try self.addValueLocals(.{ .parser = cond.condition });
                        try self.addValueLocals(.{ .parser = cond.then_branch });
                        try self.addValueLocals(.{ .parser = cond.else_branch });
                    },
                    .destructure => |dest| {
                        try self.addValueLocals(.{ .parser = dest.left });
                        try self.addValueLocals(.{ .pattern = dest.right });
                    },
                    .negation => |neg| {
                        try self.addValueLocals(.{ .parser = neg });
                    },
                    .range => |range| {
                        if (range.lower) |lower| try self.addValueLocals(.{ .parser = lower });
                        if (range.upper) |upper| try self.addValueLocals(.{ .parser = upper });
                    },
                    .repeat => |rep| {
                        try self.addValueLocals(.{ .parser = rep.left });
                        try self.addValueLocals(.{ .pattern = rep.right });
                    },
                    .string_template => |tmpl| {
                        for (tmpl.items) |item| {
                            try self.addValueLocals(.{ .parser = item });
                        }
                    },
                    .identifier, .number_string, .string => {},
                }
            },
            .value => |v| {
                switch (v.node) {
                    .@"return" => |ret| {
                        try self.addValueLocals(.{ .value = ret.left });
                        try self.addValueLocals(.{ .value = ret.right });
                    },
                    .function_call => |func| {
                        try self.addValueLocals(.{ .value = func.function });
                        for (func.args.items) |arg| {
                            try self.addValueLocals(.{ .value = arg });
                        }
                    },
                    .@"or" => |or_node| {
                        try self.addValueLocals(.{ .value = or_node.left });
                        try self.addValueLocals(.{ .value = or_node.right });
                    },
                    .merge => |merge_node| {
                        try self.addValueLocals(.{ .value = merge_node.left });
                        try self.addValueLocals(.{ .value = merge_node.right });
                    },
                    .take_left => |take_node| {
                        try self.addValueLocals(.{ .value = take_node.left });
                        try self.addValueLocals(.{ .value = take_node.right });
                    },
                    .take_right => |take_node| {
                        try self.addValueLocals(.{ .value = take_node.left });
                        try self.addValueLocals(.{ .value = take_node.right });
                    },
                    .conditional => |cond| {
                        try self.addValueLocals(.{ .value = cond.condition });
                        try self.addValueLocals(.{ .value = cond.then_branch });
                        try self.addValueLocals(.{ .value = cond.else_branch });
                    },
                    .destructure => |dest| {
                        try self.addValueLocals(.{ .value = dest.left });
                        try self.addValueLocals(.{ .pattern = dest.right });
                    },
                    .negation => |neg| {
                        try self.addValueLocals(.{ .value = neg });
                    },
                    .array => |arr| {
                        for (arr.items) |item| {
                            try self.addValueLocals(.{ .value = item });
                        }
                    },
                    .object => |obj| {
                        for (obj.items) |pair| {
                            try self.addValueLocals(.{ .value = pair.key });
                            try self.addValueLocals(.{ .value = pair.value });
                        }
                    },
                    .string_template => |tmpl| {
                        for (tmpl.items) |item| {
                            try self.addValueLocals(.{ .value = item });
                        }
                    },
                    .repeat => |rep| {
                        try self.addValueLocals(.{ .value = rep.left });
                        try self.addValueLocals(.{ .value = rep.right });
                    },
                    .identifier => |ident| {
                        if (self.findGlobal(ident.name) == null) {
                            var ident_rnode: Ast.RNode(Ast.Value.Identifier) = .{ .node = ident, .region = region };
                            const newLocalId = try self.addLocalIfUndefined(.{ .value = &ident_rnode });
                            if (newLocalId) |_| {
                                const elem = Elem.valueVar(
                                    ident.name,
                                    ident.underscored,
                                );
                                try self.writeConstant(elem, region);
                            }
                        }
                    },
                    .false,
                    .null,
                    .number_float,
                    .number_string,
                    .string,
                    .true,
                    => {},
                }
            },
            .pattern => |pat| {
                switch (pat.node) {
                    .merge => |merge_node| {
                        try self.addValueLocals(.{ .pattern = merge_node.left });
                        try self.addValueLocals(.{ .pattern = merge_node.right });
                    },
                    .function_call => |func| {
                        try self.addValueLocals(.{ .value = func.function });
                        for (func.args.items) |arg| {
                            try self.addValueLocals(.{ .value = arg });
                        }
                    },
                    .range => |range| {
                        if (range.lower) |lower| try self.addValueLocals(.{ .pattern = lower });
                        if (range.upper) |upper| try self.addValueLocals(.{ .pattern = upper });
                    },
                    .repeat => |rep| {
                        try self.addValueLocals(.{ .pattern = rep.left });
                        try self.addValueLocals(.{ .pattern = rep.right });
                    },
                    .negation => |neg| {
                        try self.addValueLocals(.{ .pattern = neg });
                    },
                    .array => |arr| {
                        for (arr.items) |item| {
                            try self.addValueLocals(.{ .pattern = item });
                        }
                    },
                    .object => |obj| {
                        for (obj.items) |pair| {
                            try self.addValueLocals(.{ .pattern = pair.key });
                            try self.addValueLocals(.{ .pattern = pair.value });
                        }
                    },
                    .string_template => |tmpl| {
                        for (tmpl.items) |item| {
                            try self.addValueLocals(.{ .pattern = item });
                        }
                    },
                    .identifier => |ident| {
                        if (self.findGlobal(ident.name) == null) {
                            const value_ident = Ast.Value.Identifier{
                                .name = ident.name,
                                .builtin = ident.builtin,
                                .underscored = ident.underscored,
                            };
                            var ident_rnode: Ast.RNode(Ast.Value.Identifier) = .{ .node = value_ident, .region = region };
                            const newLocalId = try self.addLocalIfUndefined(.{ .value = &ident_rnode });
                            if (newLocalId) |_| {
                                const elem = Elem.valueVar(
                                    ident.name,
                                    ident.underscored,
                                );
                                try self.writeConstant(elem, region);
                            }
                        }
                    },
                    .false,
                    .null,
                    .number_float,
                    .number_string,
                    .string,
                    .true,
                    => {},
                }
            },
        }
    }

    fn addClosureLocals(self: *Compiler, rnode: Ast.ParserOrValueOrPattern.RNode) !void {
        const region = rnode.region();

        switch (rnode) {
            .parser => |p| {
                switch (p.node) {
                    .@"or" => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .parser = infix.right });
                    },
                    .@"return" => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .backtrack => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .parser = infix.right });
                    },
                    .conditional => |conditional| {
                        try self.addClosureLocals(.{ .parser = conditional.condition });
                        try self.addClosureLocals(.{ .parser = conditional.then_branch });
                        try self.addClosureLocals(.{ .parser = conditional.else_branch });
                    },
                    .destructure => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .pattern = infix.right });
                    },
                    .function_call => |fc| {
                        for (fc.args.items) |arg| {
                            switch (arg) {
                                .parser => |parser_arg| try self.addClosureLocals(.{ .parser = parser_arg }),
                                .value => |value_arg| try self.addClosureLocals(.{ .value = value_arg }),
                            }
                        }
                    },
                    .identifier => |ident| {
                        const elem = Elem.valueVar(ident.name, ident.underscored);

                        if (self.parentFunction().localSlot(ident.name) != null) {
                            var ident_rnode: Ast.RNode(Ast.Parser.Identifier) = .{ .node = ident, .region = region };
                            const newLocalId = try self.addLocalIfUndefined(.{ .parser = &ident_rnode });
                            if (newLocalId) |_| {
                                try self.writeConstant(elem, region);
                            }
                        }
                    },
                    .merge => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .parser = infix.right });
                    },
                    .negation => |inner| try self.addClosureLocals(.{ .parser = inner }),
                    .range => |bounds| {
                        if (bounds.lower) |lower| try self.addClosureLocals(.{ .parser = lower });
                        if (bounds.upper) |upper| try self.addClosureLocals(.{ .parser = upper });
                    },
                    .repeat => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .pattern = infix.right });
                    },
                    .string_template => |parts| {
                        for (parts.items) |part| {
                            try self.addClosureLocals(.{ .parser = part });
                        }
                    },
                    .take_left => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .parser = infix.right });
                    },
                    .take_right => |infix| {
                        try self.addClosureLocals(.{ .parser = infix.left });
                        try self.addClosureLocals(.{ .parser = infix.right });
                    },
                    .number_string,
                    .string,
                    => {},
                }
            },
            .value => |v| {
                switch (v.node) {
                    .@"or" => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .@"return" => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .merge => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .take_left => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .take_right => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .repeat => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .value = infix.right });
                    },
                    .destructure => |infix| {
                        try self.addClosureLocals(.{ .value = infix.left });
                        try self.addClosureLocals(.{ .pattern = infix.right });
                    },
                    .function_call => |fc| {
                        try self.addClosureLocals(.{ .value = fc.function });
                        for (fc.args.items) |arg| {
                            try self.addClosureLocals(.{ .value = arg });
                        }
                    },
                    .negation => |inner| try self.addClosureLocals(.{ .value = inner }),
                    .array => |elements| {
                        for (elements.items) |element| {
                            try self.addClosureLocals(.{ .value = element });
                        }
                    },
                    .object => |pairs| {
                        for (pairs.items) |pair| {
                            try self.addClosureLocals(.{ .value = pair.key });
                            try self.addClosureLocals(.{ .value = pair.value });
                        }
                    },
                    .string_template => |parts| {
                        for (parts.items) |part| {
                            try self.addClosureLocals(.{ .value = part });
                        }
                    },
                    .conditional => |conditional| {
                        try self.addClosureLocals(.{ .value = conditional.condition });
                        try self.addClosureLocals(.{ .value = conditional.then_branch });
                        try self.addClosureLocals(.{ .value = conditional.else_branch });
                    },
                    .identifier => |ident| {
                        const elem = Elem.valueVar(ident.name, ident.underscored);

                        if (self.parentFunction().localSlot(ident.name) != null) {
                            var ident_rnode: Ast.RNode(Ast.Value.Identifier) = .{ .node = ident, .region = region };
                            const newLocalId = try self.addLocalIfUndefined(.{ .value = &ident_rnode });
                            if (newLocalId) |_| {
                                try self.writeConstant(elem, region);
                            }
                        }
                    },
                    .false,
                    .null,
                    .number_float,
                    .number_string,
                    .string,
                    .true,
                    => {},
                }
            },
            .pattern => |pat| {
                switch (pat.node) {
                    .merge => |infix| {
                        try self.addClosureLocals(.{ .pattern = infix.left });
                        try self.addClosureLocals(.{ .pattern = infix.right });
                    },
                    .repeat => |infix| {
                        try self.addClosureLocals(.{ .pattern = infix.left });
                        try self.addClosureLocals(.{ .pattern = infix.right });
                    },
                    .function_call => |fc| {
                        try self.addClosureLocals(.{ .value = fc.function });
                        for (fc.args.items) |arg| {
                            try self.addClosureLocals(.{ .value = arg });
                        }
                    },
                    .range => |bounds| {
                        if (bounds.lower) |lower| try self.addClosureLocals(.{ .pattern = lower });
                        if (bounds.upper) |upper| try self.addClosureLocals(.{ .pattern = upper });
                    },
                    .negation => |inner| try self.addClosureLocals(.{ .pattern = inner }),
                    .array => |elements| {
                        for (elements.items) |element| {
                            try self.addClosureLocals(.{ .pattern = element });
                        }
                    },
                    .object => |pairs| {
                        for (pairs.items) |pair| {
                            try self.addClosureLocals(.{ .pattern = pair.key });
                            try self.addClosureLocals(.{ .pattern = pair.value });
                        }
                    },
                    .string_template => |parts| {
                        for (parts.items) |part| {
                            try self.addClosureLocals(.{ .pattern = part });
                        }
                    },
                    .identifier => |ident| {
                        const elem = Elem.valueVar(ident.name, ident.underscored);

                        if (self.parentFunction().localSlot(ident.name) != null) {
                            const value_ident = Ast.Value.Identifier{
                                .name = ident.name,
                                .builtin = ident.builtin,
                                .underscored = ident.underscored,
                            };
                            var ident_rnode: Ast.RNode(Ast.Value.Identifier) = .{ .node = value_ident, .region = region };
                            const newLocalId = try self.addLocalIfUndefined(.{ .value = &ident_rnode });
                            if (newLocalId) |_| {
                                try self.writeConstant(elem, region);
                            }
                        }
                    },
                    .false,
                    .null,
                    .number_float,
                    .number_string,
                    .string,
                    .true,
                    => {},
                }
            },
        }
    }

    fn writePatternAsBoundRepeatValue(self: *Compiler, rnode: *Ast.Pattern.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .number_float => |f| {
                const elem = Elem.numberFloat(f);
                try self.writeConstant(elem, region);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                try self.writeConstant(elem, region);
            },
            .identifier => |ident| {
                if (self.localSlot(ident.name)) |slot| {
                    try self.emitUnaryOp(.GetBoundLocal, slot, region);
                } else {
                    const global = self.findGlobal(ident.name).?;
                    try self.writeConstant(global, region);
                }
            },
            .merge => |merge| {
                try self.writePatternAsBoundRepeatValue(merge.left);
                try self.writePatternAsBoundRepeatValue(merge.right);
                try self.emitOp(.Merge, region);
            },
            .negation => |inner| {
                try self.writePatternAsBoundRepeatValue(inner);
                try self.emitOp(.NegateNumber, region);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(function_call.function, function_call.args, region, false);
            },
            .null => {
                const elem = Elem.numberFloat(0);
                try self.writeConstant(elem, region);
            },
            .array,
            .false,
            .object,
            .range,
            .repeat,
            .string,
            .string_template,
            .true,
            => {
                try self.printError(region, "Invalid pattern type for parser repeat", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeValue(self: *Compiler, rnode: *Ast.Value.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .merge => |merge| {
                try self.writeValue(merge.left, false);
                try self.writeValue(merge.right, false);
                try self.emitOp(.Merge, region);
            },
            .take_left => |take_left| {
                try self.writeValue(take_left.left, false);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeValue(take_left.right, false);
                try self.emitOp(.TakeLeft, region);
                try self.patchJump(jumpIndex, region);
            },
            .take_right => |take_right| {
                try self.writeValue(take_right.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(take_right.right, isTailPosition);
                try self.patchJump(jumpIndex, region);
            },
            .destructure => |destructure| {
                try self.writeValue(destructure.left, false);
                const patternId = try self.createPattern(destructure.right);
                try self.emitPattern(patternId, region);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(or_node.left, false);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeValue(or_node.right, isTailPosition);
                try self.patchJump(jumpIndex, region);
            },
            .@"return" => |return_node| {
                try self.writeValue(return_node.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(return_node.right, true);
                try self.patchJump(jumpIndex, region);
            },
            .repeat => |repeat| {
                try self.writeValue(repeat.left, false);
                try self.writeValue(repeat.right, false);
                try self.emitOp(.RepeatValue, region);
            },
            .negation => |inner| {
                try self.writeValue(inner, false);
                try self.emitOp(.NegateNumber, region);
            },
            .array => |elements| {
                try self.writeValueArray(elements, region);
            },
            .object => |pairs| {
                try self.writeValueObject(pairs, region);
            },
            .string_template => |parts| {
                try self.writeStringTemplateValue(parts, region);
            },
            .conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeValue(conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(ifThenJumpIndex, region);
                try self.writeValue(conditional.else_branch, isTailPosition);
                try self.patchJump(thenElseJumpIndex, region);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(function_call.function, function_call.args, region, isTailPosition);
            },
            .identifier => |ident| {
                if (self.localSlot(ident.name)) |slot| {
                    // This local will either be a concrete value or
                    // unbound, it won't be a function. Value functions are
                    // all defined globally and called immediately. This
                    // means that if a function takes a value function as
                    // an arg then the value function will be called before
                    // the outer function, and the value used when calling
                    // the outer function will be concrete.
                    try self.emitUnaryOp(.GetBoundLocal, slot, region);
                } else {
                    const globalElem = self.findGlobal(ident.name).?;
                    try self.writeConstant(globalElem, region);
                    if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                        if (isTailPosition) {
                            try self.emitUnaryOp(.CallTailFunction, 0, region);
                        } else {
                            try self.emitUnaryOp(.CallFunction, 0, region);
                        }
                    }
                }
            },
            .string => |string| {
                const sid = try self.vm.strings.insert(string);
                const elem = Elem.string(sid);
                try self.writeConstant(elem, region);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                try self.writeConstant(elem, region);
            },
            .number_float => |number_float| {
                const elem = Elem.numberFloat(number_float);
                try self.writeConstant(elem, region);
            },
            .true => try self.emitOp(.True, region),
            .false => try self.emitOp(.False, region),
            .null => try self.emitOp(.Null, region),
        }
    }

    fn writeValueFunctionCall(
        self: *Compiler,
        function_rnode: *Ast.Value.RNode,
        arguments: ArrayList(*Ast.Value.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        // TODO: handle curried function calls like `Foo(A)(B)`
        // TODO: handle non-function with parens like `X = 1 ; "" $ X()`
        const function_ident = if (function_rnode.node == .identifier)
            function_rnode.node.identifier
        else
            @panic("todo");
        const function_region = function_rnode.region;

        const functionName = function_ident.name;

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.findGlobal(functionName)) |global| {
                function = global.asDyn().asFunction();
                try self.writeConstant(global, function_region);
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
        arguments: ArrayList(*Ast.Value.RNode),
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

    fn writeValueArray(self: *Compiler, elements: ArrayList(*Ast.Value.RNode), region: Region) Error!void {
        if (elements.items.len == 0) {
            return try self.emitOp(.PushEmptyArray, region);
        }

        var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
        try self.writeConstant(array.dyn.elem(), region);

        for (elements.items, 0..) |element, index| {
            try self.writeArrayElem(array, element, @intCast(index), region);
        }
    }

    fn appendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8) !void {
        try self.writeValue(rnode, false);
        try self.emitUnaryOp(.InsertAtIndex, index, rnode.region);
        try array.append(self.vm, self.placeholderVar());
    }

    fn negateAndAppendDynamicValue(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) !void {
        try self.writeValue(rnode, false);
        try self.emitOp(.NegateNumber, region);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.vm, self.placeholderVar());
    }

    fn writeArrayElem(self: *Compiler, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) Error!void {
        switch (rnode.node) {
            .false => {
                try array.append(self.vm, Elem.boolean(false));
            },
            .true => {
                try array.append(self.vm, Elem.boolean(true));
            },
            .null => {
                try array.append(self.vm, Elem.nullConst);
            },
            .number_float => |f| {
                try array.append(self.vm, Elem.numberFloat(f));
            },
            .number_string => |ns| {
                try array.append(self.vm, try self.numberStringNodeToElem(ns.number, ns.negated));
            },
            .string => |s| {
                const sid = try self.vm.strings.insert(s);
                try array.append(self.vm, Elem.string(sid));
            },
            .identifier => |ident| {
                // Try to resolve as a global constant
                if (self.localSlot(ident.name) == null) {
                    if (self.findGlobal(ident.name)) |globalElem| {
                        // If it's not a function, we can inline the constant value
                        if (!globalElem.isDynType(.Function)) {
                            try array.append(self.vm, globalElem);
                            return;
                        }
                    }
                }
                // Fall back to dynamic value for locals and functions
                try self.appendDynamicValue(array, rnode, index);
            },
            .function_call,
            .merge,
            .@"or",
            .@"return",
            .take_left,
            .take_right,
            .repeat,
            .destructure,
            => try self.appendDynamicValue(array, rnode, index),
            .array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(self.vm, emptyArray.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index);
                }
            },
            .object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(self.vm, emptyObject.dyn.elem());
                } else {
                    try self.appendDynamicValue(array, rnode, index);
                }
            },
            .string_template => try self.appendDynamicValue(array, rnode, index),
            .conditional => try self.appendDynamicValue(array, rnode, index),
            .negation => |inner| {
                try self.negateAndAppendDynamicValue(array, inner, index, region);
            },
        }
    }

    fn writeValueObject(self: *Compiler, pairs: ArrayList(Ast.Value.ObjectPair), region: Region) Error!void {
        if (pairs.items.len == 0) {
            return try self.emitOp(.PushEmptyObject, region);
        }

        var object = try Elem.DynElem.Object.create(self.vm, 0);
        try self.writeConstant(object.dyn.elem(), region);

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
                    try self.writeInsertObjectPiar(pair, object, index);
                }
            } else {
                try self.writeInsertObjectPiar(pair, object, index);
            }
        }
    }

    fn writeInsertObjectPiar(self: *Compiler, pair: Ast.Value.ObjectPair, object: *Elem.DynElem.Object, index: usize) !void {
        std.debug.assert(index <= 255);
        const pos = @as(u8, @intCast(index));
        try object.putReservedId(self.vm, pos, self.placeholderVar());
        try self.writeValue(pair.key, false);
        try self.writeValue(pair.value, false);
        try self.emitUnaryOp(.InsertKeyVal, pos, pair.key.region);
    }

    fn writeStringTemplateParser(self: *Compiler, parts: ArrayList(*Ast.Parser.RNode), region: Region) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];

        if (firstPart.node != .string) {
            try self.writeConstant(Elem.string(try self.vm.strings.insert("")), region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeParser(part, false);
            if (i > 0 or firstPart.node != .string) {
                try self.emitOp(.MergeAsString, region);
            }
        }
    }

    fn writeStringTemplateValue(self: *Compiler, parts: ArrayList(*Ast.Value.RNode), region: Region) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];

        if (firstPart.node != .string) {
            try self.writeConstant(Elem.string(try self.vm.strings.insert("")), region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeValue(part, false);
            if (i > 0 or firstPart.node != .string) {
                try self.emitOp(.MergeAsString, region);
            }
        }
    }

    fn writeConstant(self: *Compiler, elem: Elem, region: Region) !void {
        switch (elem.getType()) {
            .Const => switch (elem.asConst()) {
                .True => return try self.emitOp(.True, region),
                .False => return try self.emitOp(.False, region),
                .Null => return try self.emitOp(.Null, region),
                .Failure => {},
            },
            .Dyn => {
                // Arrays and objects are created as constants before adding
                // elements, so we can't check here if it's empty because it
                // will always appear empty. Instead emit `PushEmptyArray` or
                // `PushEmptyObject` manually in cases where we know it's
                // empty.
            },
            .InputSubstring => {},
            .NumberString => {
                const ns = elem.asNumberString();
                const bytes = ns.toBytes(self.vm.strings);

                if (std.mem.eql(u8, bytes, "-1")) {
                    return try self.emitOp(.PushNumberStringNegOne, region);
                } else if (bytes.len == 1) {
                    switch (bytes[0]) {
                        '0' => return try self.emitOp(.PushNumberStringZero, region),
                        '1' => return try self.emitOp(.PushNumberStringOne, region),
                        '2' => return try self.emitOp(.PushNumberStringTwo, region),
                        '3' => return try self.emitOp(.PushNumberStringThree, region),
                        else => {},
                    }
                }
            },
            .ValueVar => {
                const sid = elem.asValueVar().sid;
                const bytes = self.vm.strings.get(sid);
                if (bytes.len == 1 and bytes[0] == '_') {
                    return try self.emitOp(.PushUnderscoreVar, region);
                } else if (bytes.len == 1) {
                    return try self.emitUnaryOp(.PushCharVar, bytes[0], region);
                }
            },
            .String => {
                const sid = elem.asString();
                const bytes = self.vm.strings.get(sid);
                if (bytes.len == 0) {
                    return try self.emitOp(.PushEmptyString, region);
                } else if (bytes.len == 1) {
                    return try self.emitUnaryOp(.PushChar, bytes[0], region);
                }
            },
            .NumberFloat => {
                const n = elem.asFloat();
                if (n == @floor(n)) {
                    if (n == -1) {
                        return try self.emitOp(.PushNumberNegOne, region);
                    } else if (0 <= n and n <= 255) {
                        const byte: u8 = @intFromFloat(n);
                        switch (byte) {
                            0 => return try self.emitOp(.PushNumberZero, region),
                            1 => return try self.emitOp(.PushNumberOne, region),
                            2 => return try self.emitOp(.PushNumberTwo, region),
                            3 => return try self.emitOp(.PushNumberThree, region),
                            else => return try self.emitUnaryOp(.PushNumber, byte, region),
                        }
                    } else if (-255 <= n and n <= -1) {
                        const byte_val: u8 = @intFromFloat(-n);
                        return try self.emitUnaryOp(.PushNegNumber, byte_val, region);
                    }
                }
            },
        }

        const constId = try self.makeConstant(elem);
        return try self.emitConstant(constId, region);
    }

    fn numberStringNodeToElem(self: *Compiler, number: []const u8, negated: bool) !Elem {
        const elem = try Elem.numberStringFromBytes(number, self.vm);
        if (negated) {
            return elem.asNumberString().negate().elem();
        } else {
            return elem;
        }
    }

    fn literalPatternToElem(self: *Compiler, rnode: *Ast.Value.RNode) !?Elem {
        return switch (rnode.node) {
            .string => |s| {
                const sid = try self.vm.strings.insert(s);
                return Elem.string(sid);
            },
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
            .number_float => |f| Elem.numberFloat(f),
            .false => Elem.boolean(false),
            .true => Elem.boolean(true),
            .null => Elem.nullConst,
            .array => |elements| if (elements.items.len == 0) blk: {
                var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                break :blk emptyArray.dyn.elem();
            } else null,
            .object => |pairs| if (pairs.items.len == 0) blk: {
                var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                break :blk emptyObject.dyn.elem();
            } else null,
            else => null,
        };
    }

    fn declHasNoParams(self: *Compiler, decl: Ast.ParserOrValue.Declaration) bool {
        _ = self;
        return switch (decl) {
            .parser => |p_decl| p_decl.node.params.items.len == 0,
            .value => |v_decl| v_decl.node.params.items.len == 0,
        };
    }

    fn isAlias(self: *Compiler, decl: Ast.ParserOrValue.Declaration) bool {
        return self.getAliasBody(decl) catch null != null;
    }

    fn getAliasBody(self: *Compiler, decl: Ast.ParserOrValue.Declaration) !?Elem {
        if (self.declHasNoParams(decl)) {
            return switch (decl) {
                .parser => |p_decl| self.parserNodeToElem(p_decl.node.body.node),
                .value => |v_decl| self.valueNodeToElem(v_decl.node.body.node),
            };
        } else {
            return null;
        }
    }

    fn isAliasChain(self: *Compiler, decl: Ast.ParserOrValue.Declaration) bool {
        return self.getAliasChainName(decl) != null;
    }

    fn getAliasChainName(self: *Compiler, decl: Ast.ParserOrValue.Declaration) ?StringTable.Id {
        if (self.declHasNoParams(decl)) {
            return switch (decl) {
                .parser => |p_decl| if (p_decl.node.body.node == .identifier)
                    p_decl.node.body.node.identifier.name
                else
                    null,
                .value => |v_decl| if (v_decl.node.body.node == .identifier)
                    v_decl.node.body.node.identifier.name
                else
                    null,
            };
        } else {
            return null;
        }
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

    fn addLocal(self: *Compiler, ident: Ast.ParserOrValue.Identifier) !?u8 {
        if (ident.builtin()) {
            try self.printError(ident.region(), "Invalid function param, '@' is reserved for builtins", .{});
            return Error.InvalidAst;
        }

        return self.currentFunction().addLocal(self.vm, .{
            .sid = ident.name(),
            .kind = if (ident == .parser) .Parser else if (ident.underscored()) .Underscore else .Value,
        }) catch |err| switch (err) {
            error.MaxFunctionLocals => {
                try self.printError(
                    ident.region(),
                    "Can't have more than {} parameters and local variables.",
                    .{std.math.maxInt(u8)},
                );
                return err;
            },
            else => return err,
        };
    }

    fn addLocalIfUndefined(self: *Compiler, ident: Ast.ParserOrValue.Identifier) !?u8 {
        return self.addLocal(ident) catch |err| switch (err) {
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
        try self.emitShort(0xffff, region);
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
        try self.emitShort(@as(u16, @intCast(jump)), region);
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

    fn emitShort(self: *Compiler, short: u16, region: Region) !void {
        try self.chunk().writeShort(self.vm.allocator, short, region);
    }

    fn emitMedium(self: *Compiler, medium: u24, region: Region) !void {
        try self.chunk().writeMedium(self.vm.allocator, medium, region);
    }

    fn makeConstant(self: *Compiler, elem: Elem) !u24 {
        if (self.constant_map.get(elem.bits)) |idx| {
            return @as(u24, @intCast(idx));
        }
        const idx = try self.targetModule.addConstant(self.vm.allocator, elem);
        if (idx > 0xFFFFFF) {
            try self.writers.err.print("Too many constants in module.", .{});
            return Error.TooManyConstants;
        }
        try self.constant_map.put(self.vm.allocator, elem.bits, idx);
        return @as(u24, @intCast(idx));
    }

    fn emitConstant(self: *Compiler, idx: usize, region: Region) !void {
        if (idx <= 0xFF) {
            try self.emitUnaryOp(.GetConstant, @intCast(idx), region);
        } else if (idx <= 0xFFFF) {
            try self.emitOp(.GetConstant2, region);
            try self.emitShort(@intCast(idx), region);
        } else {
            try self.emitOp(.GetConstant3, region);
            try self.emitMedium(@intCast(idx), region);
        }
    }

    fn emitPattern(self: *Compiler, idx: usize, region: Region) !void {
        if (idx <= 0xFF) {
            try self.emitUnaryOp(.Destructure, @intCast(idx), region);
        } else if (idx <= 0xFFFF) {
            try self.emitOp(.Destructure2, region);
            try self.emitShort(@intCast(idx), region);
        } else {
            try self.emitOp(.Destructure3, region);
            try self.emitMedium(@intCast(idx), region);
        }
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

const ArrayList = std.ArrayListUnmanaged;
const Ast = @import("frontend/can_ast.zig");
const AutoHashMap = std.AutoHashMapUnmanaged;
const Chunk = @import("chunk.zig").Chunk;
const ChunkError = @import("chunk.zig").ChunkError;
const DependencyGraph = @import("frontend/dependency_graph.zig");
const Elem = @import("elem.zig").Elem;
const Frontend = @import("frontend.zig");
const GlobalKey = @import("frontend.zig").GlobalKey;
const Module = @import("module.zig").Module;
const OpCode = @import("op_code.zig").OpCode;
const Pattern = @import("pattern.zig").Pattern;
const Region = @import("region.zig").Region;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const Writer = std.Io.Writer;
const Writers = @import("writer.zig").Writers;
const parsing = @import("parsing.zig");
const std = @import("std");

pub const Compiler = struct {
    vm: *VM,
    frontend: *Frontend,
    functions: ArrayList(*Elem.DynElem.Function) = .{},
    graph_keys: ArrayList(GlobalKey) = .{},
    writers: Writers,
    printBytecode: bool = false,
    global_map: AutoHashMap(GlobalKey, Elem) = .{},
    constant_map: AutoHashMap(ConstantMapKey, usize) = .{},
    main: ?*Elem.DynElem.Function = null,

    const ConstantMapKey = struct {
        module_id: u32,
        elem_bits: u64,
    };

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
        FunctionCallTypeMismatch,
        RangeNotSingleCodepoint,
        RangeCodepointsUnordered,
        RangeIntegersUnordered,
        RangeInvalidNumberFormat,
    } || Writer.Error;

    pub fn init(vm: *VM) !Compiler {
        return Compiler{
            .vm = vm,
            .frontend = try Frontend.init(vm.allocator, &vm.strings, vm.writers),
            .writers = vm.writers,
            .printBytecode = vm.config.printCompiledBytecode,
            .constant_map = .{},
        };
    }

    pub fn deinit(self: *Compiler) void {
        self.frontend.deinit();
        self.constant_map.deinit(self.vm.allocator);
        self.global_map.deinit(self.vm.allocator);
        self.functions.deinit(self.vm.allocator);
        self.graph_keys.deinit(self.vm.allocator);
    }

    pub fn addTargetModule(self: *Compiler, module: Module, opts: Frontend.AddModuleOpts) !void {
        try self.frontend.addTargetModule(module, opts);
    }

    pub fn addModule(self: *Compiler, module: Module, opts: Frontend.AddModuleOpts) !void {
        try self.frontend.addModule(module, opts);

        // Add precompiled functions to function map so that they're
        // discoverable during compilation
        for (module.constants.items) |elem| {
            if (elem.isDynType(.Function)) {
                const func = elem.asDyn().asFunction();
                try self.global_map.put(
                    self.vm.allocator,
                    .{ .module_id = module.id, .name = func.name },
                    elem,
                );
            }
        }
    }

    pub fn addModuleDependency(self: *Compiler, module_id: Module.Id, dependendency_id: Module.Id) !void {
        try self.frontend.addModuleDependency(module_id, dependendency_id);
    }

    pub fn compile(self: *Compiler) !void {
        try self.frontend.finalize();
        // try self.frontend.resolver.graph.print(self.vm.strings, self.writers.debug);

        if (self.frontend.target_module_id) |target_module_id| {
            try self.compileModule(target_module_id);

            if (self.frontend.main) |main_ast| {
                try self.compileMainParser(target_module_id, main_ast);
            }
        } else {
            @panic("Internal Error: Can't compile without target module");
        }
    }

    fn compileModule(self: *Compiler, module_id: Module.Id) !void {
        var iter = self.frontend.declarationsIterator(module_id);

        while (iter.next()) |decl_key| {
            try self.compileDeclaration(decl_key);
        }
    }

    fn compileMainParser(self: *Compiler, module_id: Module.Id, main_ast: *Ast.RNode(Ast.Parser.AnonymousFunction)) !void {
        for (self.frontend.getDependencyKeys(module_id, main_ast.node.name)) |dep_key| {
            try self.compileDeclaration(dep_key);
        }

        const function = try Elem.DynElem.Function.createAnonParser(
            self.vm,
            .{ .module_id = module_id, .arity = 0, .region = main_ast.region },
        );
        function.name = main_ast.node.name;

        try self.functions.append(self.vm.allocator, function);
        try self.graph_keys.append(self.vm.allocator, .{ .module_id = module_id, .name = main_ast.node.name });

        try self.pushLocalPlaceholders(module_id, 0, main_ast.region);

        const graph_node = self.frontend.getGraphNode(module_id, main_ast.node.name);
        if (graph_node) |node| {
            if (node.* == .anonymous_function) {
                const anon_node = node.anonymous_function;
                if (anon_node.closure_captures.items.len > 0) {
                    try self.emitOp(.SetClosureCaptures, main_ast.region);
                }
            }
        }

        try self.writeParser(module_id, main_ast.node.body, true);
        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        _ = self.functions.pop();
        _ = self.graph_keys.pop();

        self.main = function;
    }

    fn compileDeclaration(self: *Compiler, decl_key: GlobalKey) !void {
        // Check if already fully compiled
        if (self.findGlobal(decl_key.module_id, decl_key.name)) |elem| {
            if (!elem.isDynType(.Function) or !elem.asDyn().asFunction().hasEmptyBytecode()) {
                return;
            }
        }

        const node = self.frontend.getNode(decl_key);

        // Get dependencies based on node type
        const dependencies = switch (node.*) {
            .precompiled => &[_]DependencyGraph.NodeKey{},
            .declaration => |*n| n.dependencies.items,
            .anonymous_function => |*n| n.dependencies.items,
        };

        // Make sure all dependencies are declared first
        for (dependencies) |dep_key| {
            try self.ensureDeclared(dep_key);
        }

        // Only compile if this is actually a declaration
        switch (node.*) {
            .precompiled => {},
            .declaration => |*n| {
                const decl = n.ast;

                try self.ensureDeclared(decl_key);

                // Aliases share their target's function elem, and the
                // bytecode is filled in when the target's own declaration is
                // compiled.
                const is_alias = (try self.getAliasBody(decl)) != null or
                    self.getAliasChainName(decl) != null;

                if (!is_alias) {
                    if (self.findGlobal(decl_key.module_id, decl_key.name)) |elem| {
                        if (elem.isDynType(.Function) and elem.asDyn().asFunction().hasEmptyBytecode()) {
                            try self.compileFunction(decl_key.module_id, decl);
                        }
                    }
                }
            },
            .anonymous_function => {
                // Anonymous functions should not be compiled through this path
            },
        }

        // Now compile all dependencies
        for (dependencies) |dep_key| {
            try self.compileDeclaration(dep_key);
        }
    }

    fn ensureDeclared(self: *Compiler, dep_key: GlobalKey) !void {
        if (self.findGlobal(dep_key.module_id, dep_key.name) != null) {
            return;
        }

        switch (self.frontend.getNode(dep_key).*) {
            .precompiled => {},
            .declaration => |*n| {
                const decl = n.ast;
                if (try self.getAliasBody(decl)) |alias_elem| {
                    try self.addGlobal(dep_key.module_id, dep_key.name, alias_elem);
                } else if (self.getAliasChainName(decl) != null) {
                    try self.denormalizeAlias(dep_key, decl);
                } else {
                    try self.declareFunction(dep_key.module_id, decl);
                }
            },
            .anonymous_function => {
                // Anonymous functions are compiled inline where they appear.
            },
        }
    }

    fn declareFunction(self: *Compiler, module_id: Module.Id, decl: Ast.ParserOrValue.Declaration) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const function_name = decl.identName();

        if (decl.identBuiltin()) {
            try self.printError(module_id, decl.identRegion(), "unable to define builtin function", .{});
            return Error.InvalidAst;
        }

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .module_id = module_id,
            .name = function_name,
            .arity = 0,
            .region = decl.region(),
        });

        try self.addGlobal(module_id, function_name, function.dyn.elem());

        if (decl.param_count() > std.math.maxInt(u5)) {
            try self.printError(
                module_id,
                decl.identRegion(),
                "Can't have more than {} parameters.",
                .{std.math.maxInt(u5)},
            );
            return Error.MaxFunctionLocals;
        }

        switch (decl) {
            .parser => |p_decl| {
                for (p_decl.node.params.items, 0..) |param_ident, i| {
                    function.param_types.set(
                        @intCast(i),
                        if (param_ident == .parser) .Parser else .Value,
                    );
                }
                function.arity = @intCast(p_decl.node.params.items.len);
            },
            .value => |v_decl| {
                for (v_decl.node.params.items, 0..) |param_ident, i| {
                    _ = param_ident;
                    function.param_types.set(@intCast(i), .Value);
                }
                function.arity = @intCast(v_decl.node.params.items.len);
            },
        }
    }

    fn denormalizeAlias(self: *Compiler, decl_key: GlobalKey, decl: Ast.ParserOrValue.Declaration) !void {
        var path = AutoHashMap(GlobalKey, void){};
        defer path.deinit(self.vm.allocator);

        var target_key = decl_key;
        var target_elem: ?Elem = null;

        while (true) {
            if (self.getGlobal(target_key)) |elem| {
                target_elem = elem;
                break;
            }

            if (path.contains(target_key)) {
                try self.printError(decl_key.module_id, decl.region(), "Circular alias dependency detected for '{s}'", .{self.vm.strings.get(decl_key.name)});
                return Error.AliasCycle;
            }
            try path.put(self.vm.allocator, target_key, undefined);

            const target_decl = self.frontend.getDeclaration(target_key);

            if (try self.getAliasDependency(target_key, target_decl)) |next_key| {
                target_key = next_key;
                continue;
            }

            if (try self.getAliasBody(target_decl)) |elem| {
                target_elem = elem;
                break;
            }

            // The chain ends at a function declaration that hasn't been
            // declared yet. Its bytecode is filled in when the target's own
            // declaration is compiled.
            try self.declareFunction(target_key.module_id, target_decl);
            target_elem = self.getGlobal(target_key);
            break;
        }

        if (target_elem) |elem| {
            var key_iter = path.keyIterator();
            while (key_iter.next()) |key| {
                try self.addGlobal(key.module_id, key.name, elem);
            }
            try self.addGlobal(decl_key.module_id, decl_key.name, elem);
        } else {
            unreachable;
        }
    }

    fn getAliasDependency(self: *Compiler, decl_key: GlobalKey, decl: Ast.ParserOrValue.Declaration) !?GlobalKey {
        if (!self.declHasNoParams(decl)) {
            return null;
        }

        const ident_name = self.getAliasChainName(decl) orelse return null;

        const node = self.frontend.getGraphNode(decl_key.module_id, decl.identName()) orelse return null;
        const deps = switch (node.*) {
            .precompiled => return null,
            .declaration => |n| n.dependencies.items,
            .anonymous_function => return null,
        };

        for (deps) |dep| {
            if (dep.name == ident_name) {
                return dep;
            }
        }

        return null;
    }

    fn getGlobal(self: *Compiler, key: GlobalKey) ?Elem {
        return self.global_map.get(key);
    }

    fn compileFunction(self: *Compiler, module_id: Module.Id, decl: Ast.ParserOrValue.Declaration) !void {
        const global_sid = decl.identName();
        const globalVal = self.getGlobal(.{ .module_id = module_id, .name = global_sid }).?;

        const function = globalVal.asDyn().asFunction();

        try self.functions.append(self.vm.allocator, function);
        try self.graph_keys.append(self.vm.allocator, .{ .module_id = module_id, .name = global_sid });

        try self.pushLocalPlaceholders(module_id, function.arity, decl.region());

        switch (decl) {
            .parser => |p| {
                try self.writeParser(module_id, p.node.body, true);
            },
            .value => |v| {
                try self.writeValue(module_id, v.node.body, true);
            },
        }

        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        _ = self.functions.pop();
        _ = self.graph_keys.pop();
    }

    // Function params get stack slots from the arguments pushed by the
    // caller. All other locals need a placeholder pushed at function entry so
    // that pattern bindings and closure captures can assign into their slots.
    fn pushLocalPlaceholders(self: *Compiler, module_id: Module.Id, param_count: usize, region: Region) !void {
        const key = self.currentGraphKey() orelse return;
        const node = self.frontend.getGraphNode(key.module_id, key.name) orelse return;
        const locals = switch (node.*) {
            .precompiled => return,
            .declaration => |n| n.locals.items,
            .anonymous_function => |n| n.locals.items,
        };

        if (locals.len <= param_count) {
            return;
        }

        for (locals[param_count..]) |sid| {
            const bytes = self.vm.strings.get(sid);
            const underscored = bytes.len > 0 and bytes[0] == '_';
            try self.writeConstant(module_id, Elem.valueVar(sid, underscored), region);
        }
    }

    fn writeParser(self: *Compiler, module_id: Module.Id, rnode: *Ast.Parser.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .backtrack => |backtrack| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(module_id, backtrack.left, false);
                const jumpIndex = try self.emitJump(.Backtrack, region);
                try self.writeParser(module_id, backtrack.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .merge => |merge| {
                try self.writeParser(module_id, merge.left, false);
                try self.writeParser(module_id, merge.right, false);
                try self.emitOp(.Merge, region);
            },
            .take_left => |take_left| {
                try self.writeParser(module_id, take_left.left, false);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeParser(module_id, take_left.right, false);
                try self.emitOp(.TakeLeft, region);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .take_right => |take_right| {
                try self.writeParser(module_id, take_right.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeParser(module_id, take_right.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .destructure => |destructure| {
                try self.writeParser(module_id, destructure.left, false);
                const patternId = try self.createPattern(module_id, destructure.right);
                try self.emitPattern(patternId, region);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(module_id, or_node.left, false);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeParser(module_id, or_node.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .@"return" => |return_node| {
                // Special case: `"" $ Foo` will always succeed and push `Foo` on the stack
                if (return_node.left.node == .string and return_node.left.node.string.len == 0) {
                    try self.writeValue(module_id, return_node.right, isTailPosition);
                } else {
                    try self.writeParser(module_id, return_node.left, false);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(module_id, return_node.right, isTailPosition);
                    try self.patchJump(module_id, jumpIndex, region);
                }
            },
            .repeat => |repeat| {
                try self.writeParserRepeat(module_id, repeat.left, repeat.right, region);
            },
            .range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    try self.writeRangeParser(module_id, bounds.lower.?, bounds.upper.?, region);
                } else if (bounds.lower != null) {
                    try self.writeLowerBoundedRangeParser(module_id, bounds.lower.?, region);
                } else {
                    try self.writeUpperBoundedRangeParser(module_id, bounds.upper.?, region);
                }
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(module_id, inner, region);
                if (isTailPosition) {
                    try self.emitUnaryOp(.CallTailFunction, 0, region);
                } else {
                    try self.emitUnaryOp(.CallFunction, 0, region);
                }
            },
            .identifier => |ident| {
                if (self.localSlot(ident.name)) |slot| {
                    if (isTailPosition) {
                        try self.emitUnaryOp(.CallTailFunctionLocal, slot, region);
                    } else {
                        try self.emitUnaryOp(.CallFunctionLocal, slot, region);
                    }
                } else {
                    if (self.resolveGlobal(module_id, ident.name)) |globalElem| {
                        try self.writeCallFunctionConstant(module_id, globalElem, region, isTailPosition);
                    } else {
                        try self.printError(module_id, region, "undefined variable '{s}'", .{self.vm.strings.get(ident.name)});
                        return Error.UndefinedVariable;
                    }
                }
            },
            .function_call => |function_call| {
                try self.writeParserFunctionCall(module_id, function_call.function, function_call.args, region, isTailPosition);
            },
            .number_string => |ns| {
                const bytes = ns.number;

                if (std.mem.eql(u8, bytes, "-1")) {
                    return try self.emitOp(.ParseNegOne, region);
                } else if (bytes.len == 1) {
                    switch (bytes[0]) {
                        '0' => try self.emitOp(.ParseZero, region),
                        '1' => try self.emitOp(.ParseOne, region),
                        '2' => try self.emitOp(.ParseTwo, region),
                        '3' => try self.emitOp(.ParseThree, region),
                        else => try self.emitUnaryOp(.ParseNumberStringChar, bytes[0], region),
                    }
                } else {
                    const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                    try self.writeCallFunctionConstant(module_id, elem, region, isTailPosition);
                }
            },
            .string => |string| {
                if (string.len == 0) {
                    return try self.emitOp(.PushEmptyString, region);
                } else if (string.len == 1) {
                    return try self.emitUnaryOp(.ParseChar, string[0], region);
                } else {
                    const sid = try self.vm.strings.insert(string);
                    const elem = Elem.string(sid);
                    try self.writeCallFunctionConstant(module_id, elem, region, isTailPosition);
                }
            },
            .string_template => |parts| {
                try self.writeStringTemplateParser(module_id, parts, region);
            },
            .conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(module_id, conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeParser(module_id, conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(module_id, ifThenJumpIndex, region);
                try self.writeParser(module_id, conditional.else_branch, isTailPosition);
                try self.patchJump(module_id, thenElseJumpIndex, region);
            },
            .anonymous_function => {
                try self.writeParserAnonymousFunction(module_id, rnode);
            },
        }
    }

    fn writeParserFunctionCall(
        self: *Compiler,
        module_id: Module.Id,
        function: *Ast.Parser.RNode,
        arguments: ArrayList(Ast.ParserOrValue.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        const function_ident = switch (function.node) {
            .identifier => |ident| ident,
            else => {
                try self.printError(module_id, function.region, "Only named functions can be called", .{});
                return Error.InvalidAst;
            },
        };
        const function_id = function_ident.name;
        const arg_count = arguments.items.len;

        var function_elem: ?*Elem.DynElem.Function = null;

        // Try to get the function elem. The function might be passed in as a
        // param to another function, in which case we would only now the exact
        // elem at runtime.
        if (self.localSlot(function_id)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function.region);
        } else if (self.resolveGlobal(module_id, function_id)) |global| {
            function_elem = global.asDyn().asFunction();
            try self.writeConstant(module_id, global, function.region);
        } else {
            const function_name = self.vm.strings.get(function_id);
            try self.printError(module_id, function.region, "Undefined function '{s}'", .{function_name});
            return Error.UndefinedVariable;
        }

        // If we know the function elem now then we can validate that the
        // function is getting called with the correct number of args and that
        // the args all match the expected param types. If the function elem is
        // only runtime known then we need to emit a runtime version of this
        // check.
        if (function_elem) |f| {
            if (f.arity != arg_count) {
                const function_elem_name = self.vm.strings.get(f.name);
                const region = if (arguments.items.len > 0) blk: {
                    const first_arg = arguments.items[0];
                    const last_arg = arguments.items[arg_count - 1];
                    break :blk first_arg.region().merge(last_arg.region());
                } else blk: {
                    break :blk function.region;
                };

                if (f.arity < arg_count) {
                    try self.printError(module_id, region, "Function '{s}' expects {d} arguments but got {d}", .{ function_elem_name, f.arity, arg_count });
                    return Error.FunctionCallTooManyArgs;
                } else {
                    try self.printError(module_id, region, "Function '{s}' expects {d} arguments but got {d}", .{ function_elem_name, f.arity, arg_count });
                    return Error.FunctionCallTooFewArgs;
                }
            }

            for (arguments.items, 0..) |arg, i| {
                const expected_type = f.param_types.get(@intCast(i));
                const is_parser_arg = switch (arg) {
                    .parser => true,
                    .value => false,
                };

                const expected_is_parser = expected_type == .Parser;
                if (is_parser_arg != expected_is_parser) {
                    if (expected_is_parser) {
                        try self.printError(module_id, arg.region(), "Expected parser but got value", .{});
                    } else {
                        try self.printError(module_id, arg.region(), "Expected value but got parser", .{});
                    }
                    return Error.FunctionCallTypeMismatch;
                }
            }
        } else {
            // No matter what we know the max param count
            if (arg_count > std.math.maxInt(u5)) {
                const first_arg = arguments.items[0];
                const last_arg = arguments.items[arg_count - 1];
                const region = first_arg.region().merge(last_arg.region());

                try self.printError(
                    module_id,
                    region,
                    "Can't have more than {} arguments.",
                    .{std.math.maxInt(u5)},
                );
                return Error.MaxFunctionArgs;
            }

            try self.emitUnaryOp(.AssertFunctionArity, @intCast(arg_count), call_region);

            var expected_param_types = Elem.DynElem.Function.ParamTypes{};
            for (arguments.items, 0..) |arg, i| {
                switch (arg) {
                    .parser => expected_param_types.set(@intCast(i), .Parser),
                    .value => expected_param_types.set(@intCast(i), .Value),
                }
            }

            if (arg_count < 8) {
                // We can fit the expected params in a single byte
                try self.emitUnaryOp(.AssertParamTypes, @intCast(expected_param_types.bitset & 0x7F), call_region);
            } else {
                try self.emitOp(.AssertParamTypes4, call_region);
                try self.emitLong(expected_param_types.bitset, call_region);
            }
        }

        for (arguments.items) |arg| {
            try self.writeParserFunctionArgument(module_id, arg);
        }

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, @intCast(arg_count), call_region);
        } else {
            try self.emitUnaryOp(.CallFunction, @intCast(arg_count), call_region);
        }
    }

    fn writeRangeParser(self: *Compiler, module_id: Module.Id, low: *Ast.Parser.RNode, high: *Ast.Parser.RNode, region: Region) !void {
        const low_elem = try self.parserNodeToElem(low.node);
        const high_elem = try self.parserNodeToElem(high.node);

        if (low.node == .string and high.node == .string) {
            const low_str = low_elem.?.asString();
            const high_str = high_elem.?.asString();
            const low_bytes = self.vm.strings.get(low_str);
            const high_bytes = self.vm.strings.get(high_str);
            const low_codepoint = parsing.utf8Decode(low_bytes) orelse {
                try self.printError(module_id, high.region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };
            const high_codepoint = parsing.utf8Decode(high_bytes) orelse {
                try self.printError(module_id, high.region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };

            if (low_codepoint > high_codepoint) {
                try self.printError(module_id, low.region.merge(high.region), "Range upper bound codepoint is less than the lower bound", .{});
                return Error.RangeCodepointsUnordered;
            } else if (low_codepoint == 0 and high_codepoint == 0x10ffff) {
                try self.emitOp(.ParseCodepoint, region);
            } else if (low_codepoint <= 255 and high_codepoint <= 255) {
                try self.emitOp(.ParseCodepointRange, region);
                try self.emitByte(@as(u8, @intCast(low_codepoint)), low.region);
                try self.emitByte(@as(u8, @intCast(high_codepoint)), high.region);
            } else {
                try self.writeConstant(module_id, low_elem.?, low.region);
                try self.writeConstant(module_id, high_elem.?, high.region);
                try self.emitOp(.ParseRange, region);
            }
        } else if (low.node == .number_string and high.node == .number_string) {
            const low_ns = low_elem.?.asNumberString();
            const high_ns = high_elem.?.asNumberString();

            const low_num = low_ns.toNumberFloat(self.vm.strings);
            const high_num = high_ns.toNumberFloat(self.vm.strings);

            if (!low_num.isInteger(self.vm.strings)) {
                try self.printError(module_id, low.region, "Range bound must be an integer", .{});
                return Error.RangeInvalidNumberFormat;
            }
            if (!high_num.isInteger(self.vm.strings)) {
                try self.printError(module_id, high.region, "Range bound must be an integer", .{});
                return Error.RangeInvalidNumberFormat;
            }

            const low_int = try low_num.asInteger(self.vm.strings);
            const high_int = try high_num.asInteger(self.vm.strings);

            if (low_int > high_int) {
                try self.printError(module_id, low.region.merge(high.region), "Range upper bound is less than the lower bound", .{});
                return Error.RangeIntegersUnordered;
            } else if (0 <= low_int and low_int <= 255 and 0 <= high_int and high_int <= 255) {
                try self.emitOp(.ParseIntegerRange, region);
                try self.emitByte(@as(u8, @intCast(low_int)), low.region);
                try self.emitByte(@as(u8, @intCast(high_int)), high.region);
            } else {
                try self.writeConstant(module_id, low_elem.?, low.region);
                try self.writeConstant(module_id, high_elem.?, high.region);
                try self.emitOp(.ParseRange, region);
            }
        } else {
            switch (low.node) {
                .string => {
                    const low_str = low_elem.?.asString();
                    const low_bytes = self.vm.strings.get(low_str);
                    _ = parsing.utf8Decode(low_bytes) orelse {
                        try self.printError(module_id, high.region, "Character range bound must be a single codepoint", .{});
                        return Error.RangeNotSingleCodepoint;
                    };

                    try self.writeConstant(module_id, low_elem.?, low.region);
                },
                .number_string => {
                    const low_ns = low_elem.?.asNumberString();
                    const low_num = low_ns.toNumberFloat(self.vm.strings);

                    if (!low_num.isInteger(self.vm.strings)) {
                        try self.printError(module_id, low.region, "Range bound must be an integer", .{});
                        return Error.RangeInvalidNumberFormat;
                    }

                    try self.writeConstant(module_id, low_num, low.region);
                },
                .identifier => |ident| {
                    try self.writeGetVar(module_id, ident.name, low.region);
                },
                .negation => |inner| {
                    try self.writeNegatedParserElem(module_id, inner, region);
                },
                else => {
                    try self.printError(module_id, low.region, "Range bound must be an integer or codepoint", .{});
                    return Error.InvalidAst;
                },
            }

            switch (high.node) {
                .string => {
                    const high_str = high_elem.?.asString();
                    const high_bytes = self.vm.strings.get(high_str);
                    _ = parsing.utf8Decode(high_bytes) orelse {
                        try self.printError(module_id, high.region, "Character range bound must be a single codepoint", .{});
                        return Error.RangeNotSingleCodepoint;
                    };

                    try self.writeConstant(module_id, high_elem.?, high.region);
                },
                .number_string => {
                    const high_ns = high_elem.?.asNumberString();
                    const high_num = high_ns.toNumberFloat(self.vm.strings);

                    if (!high_num.isInteger(self.vm.strings)) {
                        try self.printError(module_id, high.region, "Range bound must be an integer", .{});
                        return Error.RangeInvalidNumberFormat;
                    }

                    try self.writeConstant(module_id, high_num, high.region);
                },
                .identifier => |ident| {
                    try self.writeGetVar(module_id, ident.name, high.region);
                },
                .negation => |inner| {
                    try self.writeNegatedParserElem(module_id, inner, region);
                },
                else => {
                    try self.printError(module_id, high.region, "Range bound must be an integer or codepoint", .{});
                    return Error.InvalidAst;
                },
            }

            try self.emitOp(.ParseRange, region);
        }
    }

    fn writeLowerBoundedRangeParser(self: *Compiler, module_id: Module.Id, low: *Ast.Parser.RNode, region: Region) !void {
        const low_elem = try self.parserNodeToElem(low.node);
        const low_region = low.region;

        switch (low.node) {
            .string => {
                const low_str = low_elem.?.asString();
                const low_bytes = self.vm.strings.get(low_str);
                const low_codepoint = parsing.utf8Decode(low_bytes) orelse {
                    try self.printError(module_id, low.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };

                if (low_codepoint == 0) {
                    try self.emitOp(.ParseCodepoint, region);
                } else {
                    try self.writeConstant(module_id, low_elem.?, low_region);
                    try self.emitOp(.ParseLowerBoundedRange, region);
                }
            },
            .number_string => {
                const low_ns = low_elem.?.asNumberString();
                const low_num = low_ns.toNumberFloat(self.vm.strings);
                const low_f = low_num.asFloat();

                if (@trunc(low_f) != low_f) {
                    try self.printError(module_id, low.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }

                try self.writeConstant(module_id, low_num, low_region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            .identifier => |ident| {
                try self.writeGetVar(module_id, ident.name, region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(module_id, inner, region);
                try self.emitOp(.ParseLowerBoundedRange, region);
            },
            else => {
                try self.printError(module_id, low.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeUpperBoundedRangeParser(self: *Compiler, module_id: Module.Id, high: *Ast.Parser.RNode, region: Region) !void {
        const high_elem = try self.parserNodeToElem(high.node);
        const high_region = high.region;

        switch (high.node) {
            .string => {
                const high_str = high_elem.?.asString();
                const high_bytes = self.vm.strings.get(high_str);
                const high_codepoint = parsing.utf8Decode(high_bytes) orelse {
                    try self.printError(module_id, high.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };

                if (high_codepoint == 0x10ffff) {
                    try self.emitOp(.ParseCodepoint, region);
                } else {
                    try self.writeConstant(module_id, high_elem.?, high_region);
                    try self.emitOp(.ParseUpperBoundedRange, region);
                }
            },
            .number_string => {
                const high_ns = high_elem.?.asNumberString();
                const high_num = high_ns.toNumberFloat(self.vm.strings);
                const high_f = high_num.asFloat();

                if (@trunc(high_f) != high_f) {
                    try self.printError(module_id, high.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }

                try self.writeConstant(module_id, high_num, high_region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            .identifier => |ident| {
                try self.writeGetVar(module_id, ident.name, region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            .negation => |inner| {
                try self.writeNegatedParserElem(module_id, inner, region);
                try self.emitOp(.ParseUpperBoundedRange, region);
            },
            else => {
                try self.printError(module_id, high.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeParserRepeat(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, repeat: *Ast.Pattern.RNode, region: Region) !void {
        switch (repeat.node) {
            .number_float,
            .number_string,
            => {
                return self.writeParserRepeatCount(module_id, parser, repeat, region);
            },
            .range => |bounds| {
                if (bounds.lower != null and bounds.upper != null) {
                    const lower = bounds.lower.?;
                    const upper = bounds.upper.?;

                    if (self.isBoundedRepeatCount(module_id, lower) and self.isBoundedRepeatCount(module_id, upper)) {
                        // Both bounds: repeat between min and max times
                        try self.writeParserRepeatRangeBounded(module_id, parser, lower, upper, region);
                    } else if (self.isBoundedRepeatCount(module_id, lower)) {
                        // Lower bound number, upper bound pattern
                        try self.writeParserRepeatRangeLowerBounded(module_id, parser, lower, upper, region);
                    } else if (self.isBoundedRepeatCount(module_id, upper)) {
                        // Upper bound number, lower bound pattern
                        try self.writeParserRepeatRangeUpperBounded(module_id, parser, lower, upper, region);
                    } else {
                        // Pattern matching fallback
                        try self.writeParserRepeatUnknownCount(module_id, parser, repeat, region);
                    }
                } else if (bounds.lower != null and self.isBoundedRepeatCount(module_id, bounds.lower.?)) {
                    // Lower bound only: repeat at least n times
                    try self.writeParserRepeatRangeLowerBounded(module_id, parser, bounds.lower.?, null, region);
                } else if (bounds.upper != null and self.isBoundedRepeatCount(module_id, bounds.upper.?)) {
                    // Upper bound only: repeat at most n times
                    try self.writeParserRepeatRangeUpperBounded(module_id, parser, null, bounds.upper.?, region);
                } else {
                    // Pattern matching fallback
                    try self.writeParserRepeatUnknownCount(module_id, parser, repeat, region);
                }
            },
            .identifier => |ident| {
                if (self.resolveGlobal(module_id, ident.name) != null) {
                    // Globals are always bound to a concrete value
                    try self.writeParserRepeatCount(module_id, parser, repeat, region);
                } else {
                    const slot = self.localSlot(ident.name).?;
                    if (self.currentFunction().arity > slot) {
                        // The local var is a function arg, so we know it's bound
                        try self.writeParserRepeatCount(module_id, parser, repeat, region);
                    } else {
                        // The value may or may not be bound. Generate
                        // conditional code covering both cases.
                        try self.emitUnaryOp(.GetLocal, slot, repeat.region);
                        const knownCountJump = try self.emitJump(.JumpIfBound, repeat.region);
                        try self.writeParserRepeatUnknownCount(module_id, parser, repeat, region);
                        const endJump = try self.emitJump(.Jump, repeat.region);
                        try self.patchJump(module_id, knownCountJump, region);
                        try self.writeParserRepeatCount(module_id, parser, repeat, region);
                        try self.patchJump(module_id, endJump, region);
                        try self.emitOp(.Swap, region);
                        try self.emitOp(.Drop, region);
                    }
                }
            },
            else => {
                if (self.isBoundedRepeatCount(module_id, repeat)) {
                    try self.writeParserRepeatCount(module_id, parser, repeat, region);
                } else {
                    try self.writeParserRepeatUnknownCount(module_id, parser, repeat, region);
                }
            },
        }
    }

    fn writeParserRepeatCount(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, count: *Ast.Pattern.RNode, repeat_region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, parser.region);

        // Create the counter, validate it, if it starts at zero
        // then skip to the end and return null
        try self.writePatternAsBoundRepeatValue(module_id, count);
        try self.emitOp(.ValidateRepeatPattern, count.region);
        const nullJump = try self.emitJump(.JumpIfZero, repeat_region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, repeat_region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser, false);
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
        try self.patchJump(module_id, failureJump, parser.region);
        try self.emitOp(.Swap, repeat_region);

        // Cleanup: drop the counter
        try self.patchJump(module_id, nullJump, count.region);
        try self.patchJump(module_id, doneJump, repeat_region);
        try self.emitOp(.Drop, count.region);
    }

    fn writeParserRepeatUnknownCount(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, count: *Ast.Pattern.RNode, repeat_region: Region) Error!void {
        // Count accumulator
        try self.writeConstant(module_id, Elem.numberFloat(0), count.region);

        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, parser.region);

        // Start of the parse loop
        const loopStart = self.chunk().code.items.len;

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser, false);
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
        try self.patchJump(module_id, failureJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);
        try self.emitOp(.Swap, count.region);
        const patternId = try self.createPattern(module_id, count);
        try self.emitPattern(patternId, repeat_region);

        // Cleanup: drop the counter
        try self.emitOp(.Drop, parser.region);
    }

    fn writeParserRepeatRangeBounded(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, lower: *Ast.Pattern.RNode, upper: *Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writePatternAsBoundRepeatValue(module_id, lower);
        try self.emitOp(.ValidateRepeatPattern, lower.region);
        const skipLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStartRequired = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser, false);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        try self.patchJump(module_id, skipLowerBoundJump, region);
        try self.patchJump(module_id, doneLowerBoundJump, region);

        // Drop the old counter (it's 0), create a new counter to parse up to
        // to `upper - lower` more times (optional)
        try self.emitOp(.Drop, region);
        try self.writePatternAsBoundRepeatValue(module_id, upper);
        try self.writePatternAsBoundRepeatValue(module_id, lower);
        try self.emitOp(.NegateNumber, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.ValidateRepeatPattern, upper.region);
        const skipUpperBoundJump = try self.emitJump(.JumpIfZero, region);

        // Optional iterations
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser, false);
        const failureUpperBoundJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        try self.patchJump(module_id, failureUpperBoundJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);

        // Got here by failing before reaching the minimum number of iters. The
        // stack is [..., count, failure] and we want to return failure
        try self.patchJump(module_id, failureLowerBoundJump, region);

        // Swap up the count
        try self.emitOp(.Swap, region);

        // Got here by matching against a zero count, stack is [..., acc, count]
        try self.patchJump(module_id, skipUpperBoundJump, region);
        try self.patchJump(module_id, doneJump, region);

        try self.emitOp(.Drop, region);
    }

    fn writeParserRepeatRangeLowerBounded(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, lower: *Ast.Pattern.RNode, upper_pattern: ?*Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip the lower bound loop
        try self.writePatternAsBoundRepeatValue(module_id, lower);
        try self.emitOp(.ValidateRepeatPattern, lower.region);
        const skipLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // At the start of each loop swap the accumulator back to
        // the top of the stack
        const loopStartRequired = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser, false);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        // Now continue parsing indefinitely (optional iterations)
        try self.patchJump(module_id, skipLowerBoundJump, region);
        try self.patchJump(module_id, doneLowerBoundJump, region);

        // Count under acc
        try self.emitOp(.Swap, region);

        // Unbounded loop
        const loopStartOptional = self.chunk().code.items.len;

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser, false);
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
        try self.patchJump(module_id, failureJumpOptional, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);

        // Swap up the count, add the lower to get the total number of iters, destructure
        if (upper_pattern) |upper| {
            try self.emitOp(.Swap, upper.region);
            try self.writePatternAsBoundRepeatValue(module_id, lower);
            try self.emitOp(.Merge, parser.region);
            const patternId = try self.createPattern(module_id, upper);
            try self.emitPattern(patternId, upper.region);
            try self.emitOp(.Swap, region);
        }

        try self.patchJump(module_id, failureLowerBoundJump, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Drop, region);
    }

    fn writeParserRepeatRangeUpperBounded(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, lower_pattern: ?*Ast.Pattern.RNode, upper: *Ast.Pattern.RNode, region: Region) Error!void {
        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, region);

        // Create the counter, validate it, if it starts at zero
        // then skip to end and return null
        try self.writePatternAsBoundRepeatValue(module_id, upper);
        try self.emitOp(.ValidateRepeatPattern, upper.region);
        const nullJump = try self.emitJump(.JumpIfZero, region);

        // Loop for up to `upper` iterations (all optional)
        const loopStart = self.chunk().code.items.len;
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser, false);
        const failureJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        // Drop the failure and swap up the count so we can pattern match/cleanup
        try self.patchJump(module_id, failureJump, parser.region);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);
        try self.emitOp(.Swap, region);

        try self.patchJump(module_id, nullJump, region);
        try self.patchJump(module_id, doneJump, region);

        if (lower_pattern) |lower| {
            // Use the remaining count to figure out the number of successful iters
            //   upper - count = completed
            // But since the count is on the stack we do
            //   -count + upper = completed
            try self.emitOp(.NegateNumber, region);
            try self.writePatternAsBoundRepeatValue(module_id, upper);
            try self.emitOp(.Merge, region);
            const patternId = try self.createPattern(module_id, lower);
            try self.emitPattern(patternId, lower.region);
        }

        try self.emitOp(.Drop, region);
    }

    fn isBoundedRepeatCount(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) bool {
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
                    if (self.resolveGlobal(module_id, ident.name) != null) {
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
                    const lower_good = self.isBoundedRepeatCount(module_id, lower);
                    if (!lower_good) return false;
                }
                if (range.upper) |upper| {
                    const upper_good = self.isBoundedRepeatCount(module_id, upper);
                    if (!upper_good) return false;
                }
                return true;
            },
            .negation => |inner| self.isBoundedRepeatCount(module_id, inner),
            .merge => |merge| self.isBoundedRepeatCount(module_id, merge.left) and self.isBoundedRepeatCount(module_id, merge.right),
            .array,
            .object,
            .string_template,
            .repeat,
            => false,
        };
    }

    fn writeNegatedParserElem(self: *Compiler, module_id: Module.Id, negated: *Ast.Parser.RNode, region: Region) !void {
        switch (negated.node) {
            .negation => {
                try self.printError(module_id, region, "Double-negated parser", .{});
                return Error.InvalidAst;
            },
            .number_string => |ns| {
                if (ns.negated) {
                    try self.printError(module_id, region, "Double-negated parser", .{});
                    return Error.InvalidAst;
                }
                const elem = try self.numberStringNodeToElem(ns.number, true);
                try self.writeConstant(module_id, elem, negated.region);
            },
            .identifier => |ident| {
                // Determine at runtime if negating the parser is valid
                try self.writeGetVar(module_id, ident.name, region);
                try self.emitOp(.NegateParser, region);
            },
            else => {
                try self.printError(module_id, region, "Negated parser must be a number or named number parser", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeGetVar(self: *Compiler, module_id: Module.Id, name: StringTable.Id, region: Region) !void {
        if (self.localSlot(name)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, region);
        } else {
            if (self.resolveGlobal(module_id, name)) |globalElem| {
                try self.writeConstant(module_id, globalElem, region);
            } else {
                try self.printError(module_id, region, "undefined variable '{s}'", .{self.vm.strings.get(name)});
                return Error.UndefinedVariable;
            }
        }
    }

    fn parserNodeToElem(self: *Compiler, node: Ast.Parser.Node) !?Elem {
        const result = switch (node) {
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
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
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            .true => Elem.boolean(true),
            else => null,
        };

        return result;
    }

    fn writeParserFunctionArgument(self: *Compiler, module_id: Module.Id, rnode: Ast.ParserOrValue.RNode) !void {
        const region = rnode.region();

        switch (rnode) {
            .parser => |p| switch (p.node) {
                .number_string => |ns| {
                    const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                    try self.writeConstant(module_id, elem, region);
                },
                .string => |string| {
                    const sid = try self.vm.strings.insert(string);
                    const elem = Elem.string(sid);
                    try self.writeConstant(module_id, elem, region);
                },
                .identifier => |ident| {
                    try self.writeGetVar(module_id, ident.name, region);
                },
                .anonymous_function => {
                    try self.writeParserAnonymousFunction(module_id, p);
                },
                else => @panic("Internal Error: compound parser in function args must be wrapped in an anonymous function."),
            },
            .value => |v| try self.writeValue(module_id, v, false),
        }
    }

    fn writeParserAnonymousFunction(self: *Compiler, module_id: Module.Id, rnode: *Ast.Parser.RNode) Error!void {
        const region = rnode.region;
        const anon = rnode.node.anonymous_function;

        const function = try Elem.DynElem.Function.createAnonParser(
            self.vm,
            .{ .module_id = module_id, .arity = 0, .region = region },
        );

        const constId = try self.makeConstant(module_id, function.dyn.elem());

        try self.functions.append(self.vm.allocator, function);
        try self.graph_keys.append(self.vm.allocator, .{ .module_id = module_id, .name = anon.name });

        for (self.frontend.getDependencyKeys(module_id, anon.name)) |dep_key| {
            try self.ensureDeclared(dep_key);
        }

        try self.pushLocalPlaceholders(module_id, 0, region);

        const graph_node = self.frontend.getGraphNode(module_id, anon.name);
        if (graph_node) |node| {
            if (node.* == .anonymous_function) {
                const anon_node = node.anonymous_function;
                if (anon_node.closure_captures.items.len > 0) {
                    try self.emitOp(.SetClosureCaptures, region);
                }
            }
        }

        try self.writeParser(module_id, anon.body, true);
        try self.emitEnd();

        if (self.printBytecode) {
            try function.disassemble(self.vm.*, self.writers.debug);
        }

        _ = self.functions.pop();
        _ = self.graph_keys.pop();

        try self.emitConstant(constId, region);

        if (graph_node) |node| {
            if (node.* == .anonymous_function) {
                const anon_node = node.anonymous_function;

                if (anon_node.closure_captures.items.len == 0) {
                    return;
                }

                const local_count = @as(u8, @intCast(anon_node.locals.items.len));
                try self.emitUnaryOp(.CreateClosure, local_count, region);

                for (anon_node.closure_captures.items) |capture| {
                    if (self.localSlot(capture.local)) |fromSlot| {
                        try self.emitUnaryOp(.CaptureLocal, @as(u8, @intCast(fromSlot)), region);
                    }
                }
            }
        }
    }

    fn createPattern(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) Error!u24 {
        const patternElem = try self.astToPattern(module_id, rnode, 0);
        const module = self.vm.getModule(module_id);
        return @intCast(try module.addPattern(self.vm.allocator, patternElem));
    }

    fn astToPattern(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode, negation_count: u2) Error!Pattern {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .false => {
                if (negation_count > 0) {
                    try self.printError(module_id, region, "Invalid pattern - unable to negate boolean", .{});
                    return Error.InvalidAst;
                }
                return Pattern{ .Boolean = false };
            },
            .true => {
                if (negation_count > 0) {
                    try self.printError(module_id, region, "Invalid pattern - unable to negate boolean", .{});
                    return Error.InvalidAst;
                }
                return Pattern{ .Boolean = true };
            },
            .null => {
                if (negation_count > 0) {
                    try self.printError(module_id, region, "Invalid pattern - unable to negate null", .{});
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
                    try self.printError(module_id, region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }
                const sid = try self.vm.strings.insert(s);
                return Pattern{ .String = sid };
            },
            .identifier => |ident| {
                const sid = ident.name;
                if (self.resolveGlobal(module_id, sid)) |globalElem| {
                    const constId = try self.makeConstant(module_id, globalElem);
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
                    try self.printError(module_id, region, "Invalid pattern - unable to negate array", .{});
                    return Error.InvalidAst;
                }

                var patternElems = ArrayList(Pattern){};
                try patternElems.ensureTotalCapacity(self.vm.allocator, elements.items.len);

                for (elements.items) |elementNode| {
                    const elementPattern = try self.astToPattern(module_id, elementNode, 0);
                    try patternElems.append(self.vm.allocator, elementPattern);
                }

                return Pattern{ .Array = patternElems };
            },
            .object => |pairs| {
                if (negation_count > 0) {
                    try self.printError(module_id, region, "Invalid pattern - unable to negate object", .{});
                    return Error.InvalidAst;
                }

                var objectPairs = ArrayList(Pattern.ObjectPair){};
                try objectPairs.ensureTotalCapacity(self.vm.allocator, pairs.items.len);

                for (pairs.items) |pair| {
                    try objectPairs.append(self.vm.allocator, .{
                        .key = try self.astToPattern(module_id, pair.key, 0),
                        .value = try self.astToPattern(module_id, pair.value, 0),
                    });
                }

                return Pattern{ .Object = objectPairs };
            },
            .string_template => |segments| {
                if (negation_count > 0) {
                    try self.printError(module_id, region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }

                var templateElems = ArrayList(Pattern){};
                try templateElems.ensureTotalCapacity(self.vm.allocator, segments.items.len);

                for (segments.items) |segmentNode| {
                    const segmentPattern = try self.astToPattern(module_id, segmentNode, 0);
                    try templateElems.append(self.vm.allocator, segmentPattern);
                }

                return Pattern{ .StringTemplate = templateElems };
            },
            .range => |bounds| {
                var lowerPattern: ?*Pattern = null;
                var upperPattern: ?*Pattern = null;

                if (bounds.lower) |lower| {
                    lowerPattern = try self.vm.allocator.create(Pattern);
                    lowerPattern.?.* = try self.astToPattern(module_id, lower, negation_count);
                }

                if (bounds.upper) |upper| {
                    upperPattern = try self.vm.allocator.create(Pattern);
                    upperPattern.?.* = try self.astToPattern(module_id, upper, negation_count);
                }

                return Pattern{ .Range = .{
                    .lower = lowerPattern,
                    .upper = upperPattern,
                } };
            },
            .negation => |inner| {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                return self.astToPattern(module_id, inner, new_negation_count);
            },
            .function_call => |function_call| {
                const nameNode = function_call.function.node;

                const function_ident = if (nameNode == .identifier and !nameNode.identifier.underscored)
                    nameNode.identifier
                else {
                    try self.printError(module_id, region, "Parser is not valid in pattern", .{});
                    return Error.InvalidAst;
                };

                const globalFunctionElem = self.resolveGlobal(module_id, function_ident.name);

                const functionVar: Pattern.PatternVar = if (globalFunctionElem) |globalElem|
                    .{
                        .sid = function_ident.name,
                        .idx = try self.makeConstant(module_id, globalElem),
                        .negation_count = negation_count,
                    }
                else if (self.localSlot(function_ident.name)) |slot|
                    .{
                        .sid = function_ident.name,
                        .idx = slot,
                        .negation_count = negation_count,
                    }
                else {
                    try self.printError(module_id, function_call.function.region, "Unknown function in pattern", .{});
                    return Error.InvalidAst;
                };

                var args = ArrayList(Pattern){};
                for (function_call.args.items) |arg| {
                    const argPattern = try self.astToValueInPattern(module_id, arg, 0);
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
                try self.collectPatternMergeElements(module_id, rnode, &mergeElems, negation_count);
                return Pattern{ .Merge = mergeElems };
            },
            .repeat => |infix| {
                const pattern = try self.vm.allocator.create(Pattern);
                pattern.* = try self.astToPattern(module_id, infix.left, negation_count);

                const count = try self.vm.allocator.create(Pattern);
                count.* = try self.astToPattern(module_id, infix.right, 0);
                return Pattern{ .Repeat = .{ .pattern = pattern, .count = count } };
            },
        }
    }

    fn collectPatternMergeElements(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode, elements: *ArrayList(Pattern), negation_count: u2) Error!void {
        const node = rnode.node;

        switch (node) {
            .merge => |merge| {
                try self.collectPatternMergeElements(module_id, merge.left, elements, negation_count);
                try self.collectPatternMergeElements(module_id, merge.right, elements, negation_count);
                return;
            },
            else => {},
        }

        // Merge pattern part
        const pattern = try self.astToPattern(module_id, rnode, negation_count);
        try elements.append(self.vm.allocator, pattern);
    }

    fn astToValueInPattern(self: *Compiler, module_id: Module.Id, rnode: *Ast.Value.RNode, negation_count: u2) Error!Pattern {
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
                    try self.printError(module_id, region, "Invalid pattern - unable to negate string", .{});
                    return Error.InvalidAst;
                }
                const sid = try self.vm.strings.insert(s);
                return Pattern{ .String = sid };
            },
            .negation => |inner| {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                return self.astToValueInPattern(module_id, inner, new_negation_count);
            },
            .identifier => |ident| {
                if (self.resolveGlobal(module_id, ident.name)) |elem| {
                    return Pattern{ .Constant = .{
                        .sid = ident.name,
                        .idx = try self.makeConstant(module_id, elem),
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
                try self.printError(module_id, region, "Unsupported value node in pattern", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writePatternAsBoundRepeatValue(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .number_float => |f| {
                const elem = Elem.numberFloat(f);
                try self.writeConstant(module_id, elem, region);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                try self.writeConstant(module_id, elem, region);
            },
            .identifier => |ident| {
                if (self.localSlot(ident.name)) |slot| {
                    try self.emitUnaryOp(.GetBoundLocal, slot, region);
                } else {
                    const global = self.resolveGlobal(module_id, ident.name).?;
                    try self.writeConstant(module_id, global, region);
                }
            },
            .merge => |merge| {
                try self.writePatternAsBoundRepeatValue(module_id, merge.left);
                try self.writePatternAsBoundRepeatValue(module_id, merge.right);
                try self.emitOp(.Merge, region);
            },
            .negation => |inner| {
                try self.writePatternAsBoundRepeatValue(module_id, inner);
                try self.emitOp(.NegateNumber, region);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(module_id, function_call.function, function_call.args, region, false);
            },
            .null => {
                const elem = Elem.numberFloat(0);
                try self.writeConstant(module_id, elem, region);
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
                try self.printError(module_id, region, "Invalid pattern type for parser repeat", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeValue(self: *Compiler, module_id: Module.Id, rnode: *Ast.Value.RNode, isTailPosition: bool) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .merge => |merge| {
                try self.writeValue(module_id, merge.left, false);
                try self.writeValue(module_id, merge.right, false);
                try self.emitOp(.Merge, region);
            },
            .take_left => |take_left| {
                try self.writeValue(module_id, take_left.left, false);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeValue(module_id, take_left.right, false);
                try self.emitOp(.TakeLeft, region);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .take_right => |take_right| {
                try self.writeValue(module_id, take_right.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(module_id, take_right.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .destructure => |destructure| {
                try self.writeValue(module_id, destructure.left, false);
                const patternId = try self.createPattern(module_id, destructure.right);
                try self.emitPattern(patternId, region);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(module_id, or_node.left, false);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeValue(module_id, or_node.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .@"return" => |return_node| {
                try self.writeValue(module_id, return_node.left, false);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(module_id, return_node.right, isTailPosition);
                try self.patchJump(module_id, jumpIndex, region);
            },
            .repeat => |repeat| {
                try self.writeValue(module_id, repeat.left, false);
                try self.writeValue(module_id, repeat.right, false);
                try self.emitOp(.RepeatValue, region);
            },
            .negation => |inner| {
                try self.writeValue(module_id, inner, false);
                try self.emitOp(.NegateNumber, region);
            },
            .array => |elements| {
                try self.writeValueArray(module_id, elements, region);
            },
            .object => |pairs| {
                try self.writeValueObject(module_id, pairs, region);
            },
            .string_template => |parts| {
                try self.writeStringTemplateValue(module_id, parts, region);
            },
            .conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(module_id, conditional.condition, false);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeValue(module_id, conditional.then_branch, isTailPosition);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                try self.patchJump(module_id, ifThenJumpIndex, region);
                try self.writeValue(module_id, conditional.else_branch, isTailPosition);
                try self.patchJump(module_id, thenElseJumpIndex, region);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(module_id, function_call.function, function_call.args, region, isTailPosition);
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
                    const globalElem = self.resolveGlobal(module_id, ident.name).?;
                    if (globalElem.isDynType(.Function) and globalElem.asDyn().asFunction().arity == 0) {
                        try self.writeCallFunctionConstant(module_id, globalElem, region, isTailPosition);
                    } else {
                        try self.writeConstant(module_id, globalElem, region);
                    }
                }
            },
            .string => |string| {
                const sid = try self.vm.strings.insert(string);
                const elem = Elem.string(sid);
                try self.writeConstant(module_id, elem, region);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                try self.writeConstant(module_id, elem, region);
            },
            .number_float => |number_float| {
                const elem = Elem.numberFloat(number_float);
                try self.writeConstant(module_id, elem, region);
            },
            .true => try self.emitOp(.PushTrue, region),
            .false => try self.emitOp(.PushFalse, region),
            .null => try self.emitOp(.PushNull, region),
        }
    }

    fn writeValueFunctionCall(
        self: *Compiler,
        module_id: Module.Id,
        function_rnode: *Ast.Value.RNode,
        arguments: ArrayList(*Ast.Value.RNode),
        call_region: Region,
        isTailPosition: bool,
    ) !void {
        // TODO: handle curried function calls like `Foo(A)(B)`
        // TODO: handle non-function with parens like `X = 1 ; "" $ X()`
        const function_ident = switch (function_rnode.node) {
            .identifier => |ident| ident,
            else => {
                try self.printError(module_id, function_rnode.region, "Only named functions can be called", .{});
                return Error.InvalidAst;
            },
        };
        const function_region = function_rnode.region;

        const functionName = function_ident.name;

        var function: ?*Elem.DynElem.Function = null;

        if (self.localSlot(functionName)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, function_region);
        } else {
            if (self.resolveGlobal(module_id, functionName)) |global| {
                function = global.asDyn().asFunction();
                try self.writeConstant(module_id, global, function_region);
            } else {
                const functionNameStr = self.vm.strings.get(functionName);
                try self.printError(module_id, function_region, "Undefined function '{s}'", .{functionNameStr});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(module_id, arguments, function);

        if (isTailPosition) {
            try self.emitUnaryOp(.CallTailFunction, argCount, call_region);
        } else {
            try self.emitUnaryOp(.CallFunction, argCount, call_region);
        }
    }

    fn writeValueFunctionArguments(
        self: *Compiler,
        module_id: Module.Id,
        arguments: ArrayList(*Ast.Value.RNode),
        function: ?*Elem.DynElem.Function,
    ) Error!u8 {
        const arg_count = arguments.items.len;

        if (arg_count > std.math.maxInt(u8)) {
            const first_arg = arguments.items[0];
            const last_arg = arguments.items[arg_count - 1];
            const region = first_arg.region.merge(last_arg.region);

            try self.printError(
                module_id,
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
                    try self.printError(module_id, region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooManyArgs;
                } else {
                    try self.printError(module_id, region, "Function '{s}' expects {d} arguments but got {d}", .{ functionNameStr, f.arity, arg_count });
                    return Error.FunctionCallTooFewArgs;
                }
            }
        }

        for (arguments.items) |arg| {
            try self.writeValue(module_id, arg, false);
        }

        return @intCast(arg_count);
    }

    fn writeValueArray(self: *Compiler, module_id: Module.Id, elements: ArrayList(*Ast.Value.RNode), region: Region) Error!void {
        if (elements.items.len == 0) {
            return try self.emitOp(.PushEmptyArray, region);
        }

        var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
        try self.writeConstant(module_id, array.dyn.elem(), region);

        for (elements.items, 0..) |element, index| {
            try self.writeArrayElem(module_id, array, element, @intCast(index), region);
        }
    }

    fn appendDynamicValue(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8) !void {
        try self.writeValue(module_id, rnode, false);
        try self.emitUnaryOp(.InsertAtIndex, index, rnode.region);
        try array.append(self.vm, try self.placeholderVar());
    }

    fn negateAndAppendDynamicValue(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) !void {
        try self.writeValue(module_id, rnode, false);
        try self.emitOp(.NegateNumber, region);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.vm, try self.placeholderVar());
    }

    fn writeArrayElem(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) Error!void {
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
                    if (self.resolveGlobal(module_id, ident.name)) |globalElem| {
                        // If it's not a function, we can inline the constant value
                        if (!globalElem.isDynType(.Function)) {
                            try array.append(self.vm, globalElem);
                            return;
                        }
                    }
                }
                // Fall back to dynamic value for locals and functions
                try self.appendDynamicValue(module_id, array, rnode, index);
            },
            .function_call,
            .merge,
            .@"or",
            .@"return",
            .take_left,
            .take_right,
            .repeat,
            .destructure,
            => try self.appendDynamicValue(module_id, array, rnode, index),
            .array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(self.vm, emptyArray.dyn.elem());
                } else {
                    try self.appendDynamicValue(module_id, array, rnode, index);
                }
            },
            .object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(self.vm, emptyObject.dyn.elem());
                } else {
                    try self.appendDynamicValue(module_id, array, rnode, index);
                }
            },
            .string_template => try self.appendDynamicValue(module_id, array, rnode, index),
            .conditional => try self.appendDynamicValue(module_id, array, rnode, index),
            .negation => |inner| {
                try self.negateAndAppendDynamicValue(module_id, array, inner, index, region);
            },
        }
    }

    fn writeValueObject(self: *Compiler, module_id: Module.Id, pairs: ArrayList(Ast.Value.ObjectPair), region: Region) Error!void {
        if (pairs.items.len == 0) {
            return try self.emitOp(.PushEmptyObject, region);
        }

        var object = try Elem.DynElem.Object.create(self.vm, 0);
        try self.writeConstant(module_id, object.dyn.elem(), region);

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
                    try self.writeInsertObjectPair(module_id, pair, object, index);
                }
            } else {
                try self.writeInsertObjectPair(module_id, pair, object, index);
            }
        }
    }

    fn writeInsertObjectPair(self: *Compiler, module_id: Module.Id, pair: Ast.Value.ObjectPair, object: *Elem.DynElem.Object, index: usize) !void {
        std.debug.assert(index <= 255);
        const pos = @as(u8, @intCast(index));
        try object.putReservedId(self.vm, pos, try self.placeholderVar());
        try self.writeValue(module_id, pair.key, false);
        try self.writeValue(module_id, pair.value, false);
        try self.emitUnaryOp(.InsertKeyVal, pos, pair.key.region);
    }

    fn writeStringTemplateParser(self: *Compiler, module_id: Module.Id, parts: ArrayList(*Ast.Parser.RNode), region: Region) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];

        if (firstPart.node != .string) {
            try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert("")), region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeParser(module_id, part, false);
            if (i > 0 or firstPart.node != .string) {
                try self.emitOp(.MergeAsString, region);
            }
        }
    }

    fn writeStringTemplateValue(self: *Compiler, module_id: Module.Id, parts: ArrayList(*Ast.Value.RNode), region: Region) Error!void {
        // String template should not be empty
        std.debug.assert(parts.items.len > 0);

        // Check if the first part is a string - if not, we need an empty
        // string on the stack for `MergeAsString`
        const firstPart = parts.items[0];

        if (firstPart.node != .string) {
            try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert("")), region);
        }

        // Write all parts with MergeAsString between each part after the first two
        for (parts.items, 0..) |part, i| {
            try self.writeValue(module_id, part, false);
            if (i > 0 or firstPart.node != .string) {
                try self.emitOp(.MergeAsString, region);
            }
        }
    }

    fn writeConstant(self: *Compiler, module_id: Module.Id, elem: Elem, region: Region) !void {
        switch (elem.getType()) {
            .Const => switch (elem.asConst()) {
                .True => return try self.emitOp(.PushTrue, region),
                .False => return try self.emitOp(.PushFalse, region),
                .Null => return try self.emitOp(.PushNull, region),
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

        const constId = try self.makeConstant(module_id, elem);
        return try self.emitConstant(constId, region);
    }

    fn writeCallFunctionConstant(self: *Compiler, module_id: Module.Id, elem: Elem, region: Region, isTailPosition: bool) !void {
        const constId = try self.makeConstant(module_id, elem);
        if (isTailPosition) {
            return try self.emitCallTailFunctionConstant(constId, region);
        } else {
            return try self.emitCallFunctionConstant(constId, region);
        }
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

    fn placeholderVar(self: *Compiler) !Elem {
        const sid = try self.vm.strings.insert("_");
        return Elem.valueVar(sid, true);
    }

    fn chunk(self: *Compiler) *Chunk {
        return &self.currentFunction().chunk;
    }

    fn findGlobal(self: *Compiler, module_id: Module.Id, sid: StringTable.Id) ?Elem {
        if (self.global_map.get(.{ .module_id = module_id, .name = sid })) |elem| {
            return elem;
        }
        return null;
    }

    // Resolve an identifier in the body of the function currently being
    // compiled. Names that refer to declarations in other modules are found
    // through the function's dependency graph node, where the resolver
    // recorded the target module.
    fn resolveGlobal(self: *Compiler, module_id: Module.Id, sid: StringTable.Id) ?Elem {
        if (self.findGlobal(module_id, sid)) |elem| {
            return elem;
        }

        if (self.currentGraphKey()) |key| {
            for (self.frontend.getDependencyKeys(key.module_id, key.name)) |dep_key| {
                if (dep_key.name == sid) {
                    return self.findGlobal(dep_key.module_id, dep_key.name);
                }
            }
        }

        return null;
    }

    fn currentGraphKey(self: *Compiler) ?GlobalKey {
        if (self.graph_keys.items.len == 0) {
            return null;
        }
        return self.graph_keys.items[self.graph_keys.items.len - 1];
    }

    fn addGlobal(self: *Compiler, module_id: Module.Id, sid: StringTable.Id, elem: Elem) !void {
        try self.global_map.put(
            self.vm.allocator,
            .{ .module_id = module_id, .name = sid },
            elem,
        );
    }

    pub fn localSlot(self: *Compiler, name: StringTable.Id) ?u8 {
        const key = self.currentGraphKey() orelse return null;
        if (self.frontend.getGraphNode(key.module_id, key.name)) |node| {
            const locals = switch (node.*) {
                .precompiled => &[_]StringTable.Id{},
                .declaration => |n| n.locals.items,
                .anonymous_function => |n| n.locals.items,
            };
            for (locals, 0..) |local, i| {
                if (local == name) return @intCast(i);
            }
        }
        return null;
    }

    fn getConstant(self: *Compiler, module_id: Module.Id, elem: Elem) ?usize {
        return self.constant_map.get(.{ .module_id = module_id, .elem_bits = elem.bits });
    }

    fn currentFunction(self: *Compiler) *Elem.DynElem.Function {
        return self.functions.items[self.functions.items.len - 1];
    }

    fn putConstant(self: *Compiler, module_id: Module.Id, elem: Elem, const_id: usize) !void {
        try self.constant_map.put(
            self.vm.allocator,
            .{ .module_id = module_id, .elem_bits = elem.bits },
            const_id,
        );
    }

    fn emitJump(self: *Compiler, op: OpCode, region: Region) !usize {
        return try self.chunk().writeJump(self.vm.allocator, op, region);
    }

    fn patchJump(self: *Compiler, module_id: Module.Id, offset: usize, region: Region) !void {
        self.chunk().patchJump(offset) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                try self.printError(module_id, region, "Too much code to jump over.", .{});
                return err;
            },
            else => return err,
        };
    }

    fn emitJumpBack(self: *Compiler, op: OpCode, targetOffset: usize, region: Region) !void {
        return try self.chunk().writeJumpBack(self.vm.allocator, op, targetOffset, region);
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

    fn emitLong(self: *Compiler, long: u32, region: Region) !void {
        try self.chunk().writeLong(self.vm.allocator, long, region);
    }

    fn makeConstant(self: *Compiler, module_id: Module.Id, elem: Elem) !u24 {
        if (self.getConstant(module_id, elem)) |idx| {
            return @as(u24, @intCast(idx));
        }
        const module = self.vm.getModule(module_id);
        const idx = try module.addConstant(self.vm.allocator, elem);
        if (idx > 0xFFFFFF) {
            try self.writers.err.print("Too many constants in module.", .{});
            return Error.TooManyConstants;
        }
        try self.putConstant(module_id, elem, idx);
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

    fn emitCallFunctionConstant(self: *Compiler, idx: usize, region: Region) !void {
        if (idx <= 0xFF) {
            try self.emitUnaryOp(.CallFunctionConstant, @intCast(idx), region);
        } else if (idx <= 0xFFFF) {
            try self.emitOp(.CallFunctionConstant2, region);
            try self.emitShort(@intCast(idx), region);
        } else {
            try self.emitOp(.CallFunctionConstant3, region);
            try self.emitMedium(@intCast(idx), region);
        }
    }

    fn emitCallTailFunctionConstant(self: *Compiler, idx: usize, region: Region) !void {
        if (idx <= 0xFF) {
            try self.emitUnaryOp(.CallTailFunctionConstant, @intCast(idx), region);
        } else if (idx <= 0xFFFF) {
            try self.emitOp(.CallTailFunctionConstant2, region);
            try self.emitShort(@intCast(idx), region);
        } else {
            try self.emitOp(.CallTailFunctionConstant3, region);
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

    fn printError(self: *Compiler, module_id: Module.Id, region: Region, comptime message: []const u8, args: anytype) !void {
        const module = self.vm.getModule(module_id);

        try self.writers.err.print("\nProgram Error: ", .{});
        try self.writers.err.print(message, args);
        try self.writers.err.print("\n\n", .{});

        try self.writers.err.print("{s}:", .{module.name});
        try region.printLineRelative(module.source, self.writers.err);
        try self.writers.err.print(":\n", .{});

        try module.highlight(region, self.writers.err);
        try self.writers.err.print("\n", .{});
    }
};

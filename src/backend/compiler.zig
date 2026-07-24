const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const runtime = @import("../runtime.zig");
const ChunkError = runtime.ChunkError;
const Elem = runtime.Elem;
const Frontend = @import("../frontend.zig");
const Ast = Frontend.Ast;
const GlobalKey = Frontend.GlobalKey;
const DependencyGraphNode = Frontend.DependencyGraphNode;
const goal_pattern = @import("goal_pattern.zig");
const Ir = @import("ir.zig").Ir;
const liveness = @import("liveness.zig");
const Module = runtime.Module;
const name_resolver = @import("name_resolver.zig");
const NameResolver = name_resolver.NameResolver;
const OpCode = runtime.OpCode;
const RangeLimitKind = runtime.RangeLimitKind;
const MatchCmpKind = runtime.MatchCmpKind;
const MatchCastKind = runtime.MatchCastKind;
const pattern = @import("pattern.zig");
const Region = @import("../region.zig").Region;
const FrontendStrings = Frontend.StringTable;
const RuntimeStrings = runtime.StringTable;
const VM = runtime.VM;
const Writer = std.Io.Writer;
const Writers = @import("../writer.zig").Writers;
const builtin = @import("builtin");
const builtins = @import("builtin.zig");
const parsing = @import("../parsing.zig");
const std = @import("std");

pub const Compiler = struct {
    vm: *VM,
    frontend: *Frontend,
    functions: ArrayList(*Elem.DynElem.Function) = .{},
    scopes: ArrayList(Scope) = .{},
    irs: ArrayList(Ir) = .{},
    writers: Writers,
    printBytecode: bool = false,
    global_map: name_resolver.GlobalMap = .{},
    constant_map: AutoHashMap(ConstantMapKey, usize) = .{},
    // The slots each module match plan references, computed once at lowering
    // and indexed to match the module's `match_plans`. Compile-time only
    // (feeds liveness), so it lives here rather than on the runtime Module.
    plan_slots: AutoHashMap(Module.Id, ArrayList(liveness.PlanSlots)) = .{},
    main: ?*Elem.DynElem.Function = null,
    // The search-key claim layout for the match arm currently being
    // stepped. Each object place that a search pair matches against gets a
    // contiguous block of claim registers holding the keys already taken;
    // ensureGoalPlace reads it to exclude those keys from a members_rest.
    arm_search_groups: []SearchGroup = &.{},

    const SearchGroup = struct {
        src: Ast.PlaceId,
        base: u8,
        count: u8,
        emitted: u8 = 0,
    };

    const ConstantMapKey = struct {
        module_id: u32,
        elem_bits: u64,
    };

    // The graph node is cached alongside the key so that identifier
    // resolution reads locals and dependencies through a field access rather
    // than a hash lookup on every identifier emitted.
    const Scope = *Frontend.DependencyGraphNode;

    // How a parameterless declaration resolves: to an inlined value, to
    // another named declaration (an alias chain), or to a function with its
    // own bytecode. Computed once by classifyDecl and reused.
    const DeclKind = union(enum) {
        alias_value: Elem,
        alias_ident,
        function,
    };

    const Error = pattern.Error || error{
        InvalidAst,
        MaxFunctionArgs,
        MaxFunctionLocals,
        OutOfMemory,
        TooManyConstants,
        TooManyPatterns,
        ShortOverflow,
        UndefinedVariable,
        FunctionCallTooManyArgs,
        FunctionCallTooFewArgs,
        RangeNotSingleCodepoint,
        RangeCodepointsUnordered,
        RangeIntegersUnordered,
        RangeInvalidNumberFormat,
    } || Writer.Error;

    pub fn init(vm: *VM) !Compiler {
        return Compiler{
            .vm = vm,
            .frontend = try Frontend.init(vm),
            .writers = vm.writers,
            .printBytecode = vm.config.printCompiledBytecode,
            .constant_map = .{},
        };
    }

    // Copy a frontend-interned string into the VM string table. This is the
    // only place strings cross from the frontend table to the runtime table,
    // so the VM only holds strings that compiled code references.
    fn internForRuntime(self: *Compiler, sid: FrontendStrings.Id) !RuntimeStrings.Id {
        return self.vm.strings.insert(self.frontend.strings.get(sid));
    }

    fn internPathForRuntime(self: *Compiler, name: Frontend.PathTable.Id) !RuntimeStrings.Id {
        return self.internForRuntime(self.frontend.paths.flat(name));
    }

    pub fn deinit(self: *Compiler) void {
        self.frontend.deinit();
        self.constant_map.deinit(self.vm.allocator);
        self.global_map.deinit(self.vm.allocator);
        var plan_slots = self.plan_slots.valueIterator();
        while (plan_slots.next()) |list| list.deinit(self.vm.allocator);
        self.plan_slots.deinit(self.vm.allocator);
        self.functions.deinit(self.vm.allocator);
        self.scopes.deinit(self.vm.allocator);
        for (self.irs.items) |*function_ir| function_ir.deinit(self.vm.allocator);
        self.irs.deinit(self.vm.allocator);
    }

    pub fn addTargetModule(self: *Compiler, module: Module, opts: Frontend.AddModuleOpts) !void {
        try self.frontend.addTargetModule(module, opts);
    }

    pub fn addModule(self: *Compiler, module: Module, opts: Frontend.AddModuleOpts) !void {
        try self.frontend.addModule(module, opts);
    }

    // Register the builtin functions as precompiled dependency graph nodes.
    // The function elems are only created when a program uses them, in
    // createBuiltin.
    pub fn addBuiltinsModule(self: *Compiler, module: Module) !void {
        for (builtins.functions) |bf| {
            try self.frontend.addPrecompiled(module.id, bf.name);
        }
    }

    pub fn addModuleDump(self: *Compiler, module_id: Module.Id, target_module: Module.Id, private: bool) !void {
        try self.frontend.addModuleDump(module_id, target_module, private);
    }

    pub fn addImplicitDump(self: *Compiler, module_id: Module.Id) !void {
        try self.frontend.addImplicitDump(module_id);
    }

    pub fn addModuleAlias(
        self: *Compiler,
        module_id: Module.Id,
        alias: []const u8,
        target_module: Module.Id,
        selector: ?[]const u8,
        region: Region,
    ) !void {
        try self.frontend.addModuleAlias(module_id, alias, target_module, selector, region);
    }

    pub fn compile(self: *Compiler) !void {
        try self.frontend.finalize();

        if (self.frontend.target_module_id) |target_module_id| {
            try self.compileModule(target_module_id);

            if (self.frontend.main) |main_name| {
                try self.compileMainParser(target_module_id, main_name);
            }

            if (self.printBytecode) try self.printCompiled();
        } else {
            @panic("Internal Error: Can't compile without target module");
        }
    }

    fn compileModule(self: *Compiler, module_id: Module.Id) !void {
        var iter = self.frontend.dependenciesIterator();

        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const node = entry.value_ptr.*;
            if (key.module_id == module_id and node.* == .declaration) {
                try self.compileDeclaration(key);
            }
        }
    }

    fn printCompiled(self: Compiler) !void {
        var iter = self.frontend.dependenciesIterator();

        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            if (self.findGlobal(key.module_id, key.name)) |elem| {
                if (elem.isDynType(.Function)) {
                    try elem.asDyn().asFunction().disassemble(self.vm.*, self.writers.debug);
                }
            }
        }
    }

    fn compileMainParser(self: *Compiler, module_id: Module.Id, main_name: Frontend.PathTable.Id) !void {
        const main_node = self.frontend.getNode(.{ .module_id = module_id, .name = main_name });

        for (main_node.dependencies()) |edge| {
            try self.compileDeclaration(edge.target);
        }

        const function = try self.declareAnonFunction(.{ .module_id = module_id, .name = main_name });

        try self.emitAnonFunctionBody(module_id, main_node, function, main_node.anonymous_function.region);

        self.main = function;
    }

    // Shared bytecode shape for an anonymous function, including `main`.
    fn emitAnonFunctionBody(
        self: *Compiler,
        module_id: Module.Id,
        node: *DependencyGraphNode,
        function: *Elem.DynElem.Function,
        region: Region,
    ) !void {
        const name = node.anonymous_function.name;
        const ast = self.goalAst(module_id);
        const goal_body = goalFunctionBody(ast, name) orelse
            @panic("Internal Error: no goal body for anonymous function");
        const captures = goalLambdaCaptures(ast, name);
        return self.emitGoalFunctionBody(module_id, node, function, ast, goal_body, captures, region);
    }

    fn isFullyCompiled(self: *Compiler, decl_key: GlobalKey) bool {
        const elem = self.findGlobal(decl_key.module_id, decl_key.name) orelse return false;
        return !elem.isDynType(.Function) or !elem.asDyn().asFunction().hasEmptyBytecode();
    }

    fn compileDeclaration(self: *Compiler, decl_key: GlobalKey) !void {
        if (self.isFullyCompiled(decl_key)) return;

        const node = self.frontend.getNode(decl_key);
        const dependencies = node.dependencies();

        for (dependencies) |edge| {
            try self.ensureDeclared(edge.target);
        }

        // Only compile if this is actually a declaration
        switch (node.*) {
            .precompiled => try self.createBuiltin(decl_key),
            .declaration => {
                const ast = self.goalAst(decl_key.module_id);
                const goal_decl = goalDeclaration(ast, decl_key.name);
                const kind = try self.classifyDecl(ast, goal_decl);

                if (self.findGlobal(decl_key.module_id, decl_key.name) == null) {
                    try self.declareFromKind(decl_key, goal_decl, kind);
                }

                // Aliases share their target's function elem, whose bytecode is
                // filled in when the target's own declaration is compiled; only
                // a function declaration is compiled here.
                switch (kind) {
                    .function => {
                        if (self.findGlobal(decl_key.module_id, decl_key.name)) |elem| {
                            if (elem.isDynType(.Function) and elem.asDyn().asFunction().hasEmptyBytecode()) {
                                try self.compileFunction(node, decl_key);
                            }
                        }
                    },
                    .alias_value, .alias_ident => {},
                }
            },
            .anonymous_function => |*anon| {
                const function = try self.declareAnonFunction(decl_key);
                if (function.hasEmptyBytecode()) {
                    try self.emitAnonFunctionBody(
                        decl_key.module_id,
                        node,
                        function,
                        anon.region,
                    );
                }
            },
        }

        // Now compile all dependencies
        for (dependencies) |edge| {
            try self.compileDeclaration(edge.target);
        }
    }

    fn ensureDeclared(self: *Compiler, dep_key: GlobalKey) Error!void {
        if (self.findGlobal(dep_key.module_id, dep_key.name) != null) {
            return;
        }

        switch (self.frontend.getNode(dep_key).*) {
            .precompiled => try self.createBuiltin(dep_key),
            .declaration => {
                const ast = self.goalAst(dep_key.module_id);
                const goal_decl = goalDeclaration(ast, dep_key.name);
                try self.declareFromKind(dep_key, goal_decl, try self.classifyDecl(ast, goal_decl));
            },
            .anonymous_function => {
                _ = try self.declareAnonFunction(dep_key);
            },
        }
    }

    fn declareAnonFunction(self: *Compiler, key: GlobalKey) !*Elem.DynElem.Function {
        if (self.findGlobal(key.module_id, key.name)) |elem| {
            return elem.asDyn().asFunction();
        }

        const anon = self.frontend.getNode(key).anonymous_function;

        const function = try Elem.DynElem.Function.create(self.vm, .{
            .module_id = key.module_id,
            .name = try self.internPathForRuntime(key.name),
            .arity = 0,
            .region = anon.region,
            .is_anonymous = true,
        });

        try self.addGlobal(key.module_id, key.name, function.dyn.elem());

        return function;
    }

    fn createBuiltin(self: *Compiler, key: GlobalKey) !void {
        if (self.findGlobal(key.module_id, key.name) != null) return;

        const name = self.frontend.pathString(key.name);
        const module = self.vm.getModule(key.module_id);
        const maybe_function = try builtins.create(self.vm, module, name);
        const function = maybe_function orelse
            @panic("Internal Error: precompiled node has no builtin implementation");
        try self.addGlobal(key.module_id, key.name, function.dyn.elem());
    }

    // A parameterless alias body inlines to a value elem; a bare-identifier
    // body is an alias to another declaration; everything else is a function.
    fn classifyDecl(self: *Compiler, ast: *const Ast, decl: *const Ast.Declaration) !DeclKind {
        if (try self.getAliasBody(ast, decl)) |elem| {
            return .{ .alias_value = elem };
        }
        if (ast.aliasTargetName(decl) != null) {
            return .alias_ident;
        }
        return .function;
    }

    fn declareFromKind(self: *Compiler, key: GlobalKey, decl: *const Ast.Declaration, kind: DeclKind) Error!void {
        switch (kind) {
            .alias_value => |alias_elem| try self.addGlobal(key.module_id, key.name, alias_elem),
            // The frontend resolved the chain (and already rejected any
            // cycle). A terminal shares its elem, whose bytecode fills in
            // when it compiles; a dangling reference is reported now that
            // this alias is actually being compiled.
            .alias_ident => switch (self.frontend.aliasResolution(key).?) {
                .terminal => |terminal| {
                    try self.ensureDeclared(terminal);
                    try self.addGlobal(key.module_id, key.name, self.getGlobal(terminal));
                },
                .undefined => |u| {
                    const link_decl = self.frontend.getNode(u.key).declaration.decl;
                    try self.printError(u.key.module_id, link_decl.region, "undefined variable '{s}'", .{self.frontend.pathString(u.name)});
                    return Error.UndefinedVariable;
                },
            },
            .function => try self.declareFunction(key.module_id, decl),
        }
    }

    fn declareFunction(self: *Compiler, module_id: Module.Id, decl: *const Ast.Declaration) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const function_name = decl.name;

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .module_id = module_id,
            .name = try self.internPathForRuntime(function_name),
            .arity = 0,
            .region = decl.region,
            .is_anonymous = false,
        });

        try self.addGlobal(module_id, function_name, function.dyn.elem());

        if (decl.params.items.len > std.math.maxInt(u5)) {
            try self.printError(
                module_id,
                decl.ident_region,
                "Can't have more than {} parameters.",
                .{std.math.maxInt(u5)},
            );
            return Error.MaxFunctionLocals;
        }

        function.arity = @intCast(decl.params.items.len);
        function.param_types.bitset = decl.param_types;
    }

    fn compileFunction(self: *Compiler, node: *DependencyGraphNode, decl_key: GlobalKey) !void {
        const module_id = decl_key.module_id;
        const globalVal = self.getGlobal(decl_key);

        const function = globalVal.asDyn().asFunction();

        try self.functions.append(self.vm.allocator, function);
        try self.pushScope(node);
        try self.irs.append(self.vm.allocator, Ir{});

        const ast = self.goalAst(module_id);
        const goal_decl = goalDeclaration(ast, decl_key.name);

        try self.pushLocalPlaceholders(module_id, function.arity, goal_decl.region);

        try self.writeGoal(module_id, ast, goal_decl.body);

        try self.finishFunctionIr(module_id);

        _ = self.functions.pop();
        _ = self.scopes.pop();
    }

    // Function params get stack slots from the arguments pushed by the
    // caller. All other locals need a placeholder pushed at function entry so
    // that pattern bindings and closure captures can assign into their slots.
    fn pushLocalPlaceholders(self: *Compiler, module_id: Module.Id, param_count: usize, region: Region) !void {
        const scope = self.currentScope();
        const locals = scope.locals();

        if (locals.len <= param_count) {
            return;
        }

        for (locals[param_count..]) |sid| {
            const bytes = self.frontend.strings.get(sid);
            const underscored = bytes.len > 0 and bytes[0] == '_';
            try self.writeConstant(module_id, Elem.valueVar(try self.internForRuntime(sid), underscored), region);
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
                const value_var = elem.asValueVar();
                const bytes = self.vm.strings.get(value_var.sid);
                if (bytes.len == 1 and bytes[0] == '_') {
                    return try self.emitOp(.PushUnderscoreVar, region);
                } else if (!value_var.placeholder) {
                    return try self.emitPushVar(value_var.sid, region);
                }
            },
            .String => {
                const sid = elem.asString();
                const bytes = self.vm.strings.get(sid);
                if (bytes.len == 0) {
                    return try self.emitOp(.PushEmptyString, region);
                }
                return try self.emitPushString(sid, region);
            },
            .NumberFloat => {
                const n = elem.asFloat();
                if (n == @floor(n)) {
                    if (0 <= n and n <= 255) {
                        const byte: u8 = @intFromFloat(n);
                        return try self.emitUnaryOp(.PushInteger, byte, region);
                    } else if (-255 <= n and n <= -1) {
                        const byte_val: u8 = @intFromFloat(-n);
                        return try self.emitUnaryOp(.PushNegInteger, byte_val, region);
                    }
                }
            },
        }

        const constId = try self.makeConstant(module_id, elem);
        return try self.emitConstant(constId, region);
    }

    fn writeCallFunctionConstant(self: *Compiler, module_id: Module.Id, elem: Elem, region: Region) !void {
        const constId = try self.makeConstant(module_id, elem);
        return try self.emitCallFunctionConstant(constId, region);
    }

    // Compile-time split of an eq_global pattern comparand. A plain value
    // global compares directly (MatchCmp const). A zero-arity function
    // global evaluates per match: emit its call, then a MatchEval that
    // pops the result and compares it against the place register. Returns
    // the failing semidet step for the caller to patch.
    fn emitEqGlobalStep(self: *Compiler, module_id: Module.Id, name: Frontend.PathTable.Id, reg: u8, region: Region) Error!Ir.Index {
        const global = self.resolveGlobal(module_id, name) orelse {
            try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.pathString(name)});
            return Error.UndefinedVariable;
        };
        if (global.isDynType(.Function)) {
            if (global.asDyn().asFunction().arity != 0) return error.UnsupportedPattern;
            try self.writeCallFunctionConstant(module_id, global, region);
            return try self.ir().push(self.vm.allocator, .{ .match_test = .{
                .op = .MatchEval,
                .byte1 = reg,
                .byte2 = 0,
                .target = Ir.unpatched_jump,
            } }, region);
        }
        const constant = try self.makeConstantU16(module_id, global, region);
        return try self.ir().push(self.vm.allocator, .{ .match_cmp = .{
            .reg = reg,
            .kind = .constant,
            .arg = constant,
            .target = Ir.unpatched_jump,
        } }, region);
    }

    fn numberStringNodeToElem(self: *Compiler, number: []const u8, negated: bool) !Elem {
        const elem = try Elem.numberStringFromBytes(number, self.vm);
        if (negated) {
            return elem.asNumberString().negate().elem();
        } else {
            return elem;
        }
    }

    // A parameterless declaration whose body is a constant literal inlines to
    // that value elem. Parser-position literals are wrapped in an invoking
    // call in the goal ast; value-position literals stand bare.
    fn getAliasBody(self: *Compiler, ast: *const Ast, decl: *const Ast.Declaration) !?Elem {
        if (decl.params.items.len != 0) return null;
        return self.goalLiteralElem(ast, decl.body);
    }

    fn goalLiteralElem(self: *Compiler, ast: *const Ast, id: Ast.NodeId) !?Elem {
        return switch (ast.goals.items[id].node) {
            .true => Elem.boolean(true),
            .false => Elem.boolean(false),
            .null => Elem.nullConst,
            .number_float => |f| Elem.numberFloat(f),
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            .call => |call| if (call.args.len == 0)
                try self.goalLiteralElem(ast, call.callee)
            else
                null,
            else => null,
        };
    }

    fn placeholderVar(self: *Compiler) !Elem {
        const sid = try self.vm.strings.insert("_");
        return Elem.valueVar(sid, true);
    }

    fn ir(self: *Compiler) *Ir {
        return &self.irs.items[self.irs.items.len - 1];
    }

    fn finishFunctionIr(self: *Compiler, module_id: Module.Id) !void {
        try self.emitEnd();

        var function_ir = self.irs.pop().?;
        defer function_ir.deinit(self.vm.allocator);

        function_ir.markTailCalls();

        // A verification failure is a compiler bug, not a user error. Gated
        // to debug builds, which is what `zig build` and the test suites use.
        if (comptime builtin.mode == .Debug) {
            const entry_depth = @as(u32, self.currentFunction().arity) + 1;
            function_ir.verify(self.vm.allocator, entry_depth) catch |err| switch (err) {
                error.OutOfMemory => return error.OutOfMemory,
                else => std.debug.panic(
                    "IR verification of function '{s}' failed: {s} at instruction {d}",
                    .{
                        self.vm.strings.get(self.currentFunction().name),
                        @errorName(err),
                        function_ir.verify_failure.?,
                    },
                ),
            };
        }

        try self.rewriteLastReadsAsMoves(module_id, &function_ir);

        const chunk = &self.currentFunction().chunk;
        function_ir.writeTo(self.vm.allocator, chunk) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                const region = function_ir.overflow_region orelse chunk.source_region;
                try self.printError(module_id, region, "Too much code to jump over.", .{});
                return err;
            },
            else => |other_error| return other_error,
        };
    }

    // Replace each local read that liveness proves is the slot's last read
    // on every path with its move variant: the slot's reference transfers
    // to the stack instead of duplicating, so values used once (the common
    // case for params and pattern bindings) stay unique and eligible for
    // in-place mutation.
    fn rewriteLastReadsAsMoves(self: *Compiler, module_id: Module.Id, function_ir: *Ir) !void {
        const plan_slots: []const liveness.PlanSlots =
            if (self.plan_slots.get(module_id)) |list| list.items else &.{};

        var last_reads = try liveness.Liveness.analyze(self.vm.allocator, function_ir, plan_slots);
        defer last_reads.deinit(self.vm.allocator);

        for (function_ir.instructions.items, 0..) |*insn, i| {
            switch (insn.operand) {
                .byte => |*b| {
                    const move_op: OpCode = switch (b.op) {
                        .GetLocal => .GetLocalMove,
                        else => continue,
                    };
                    if (last_reads.diesAt(@intCast(i), b.byte)) b.op = move_op;
                },
                else => {},
            }
        }
    }

    fn resolver(self: *const Compiler) NameResolver {
        return .{
            .scope = self.currentScope(),
            .global_map = &self.global_map,
            .paths = &self.frontend.paths,
        };
    }

    fn findGlobal(self: *const Compiler, module_id: Module.Id, name: Frontend.PathTable.Id) ?Elem {
        return self.global_map.get(.{ .module_id = module_id, .name = name });
    }

    fn getGlobal(self: *Compiler, key: GlobalKey) Elem {
        return self.global_map.get(key).?;
    }

    // Resolve an identifier in the body of the function currently being
    // compiled. Names that refer to declarations in other modules are found
    // through the function's dependency graph node, where the resolver
    // recorded the target module.
    // Resolve an identifier written in source. Anonymous functions are in
    // the globals map but can't be invoked by name, so they are hidden here.
    fn resolveGlobal(self: *Compiler, module_id: Module.Id, name: Frontend.PathTable.Id) ?Elem {
        return self.resolver().resolveGlobal(module_id, name);
    }

    fn currentScope(self: *const Compiler) Scope {
        return self.scopes.items[self.scopes.items.len - 1];
    }

    fn pushScope(self: *Compiler, node: *DependencyGraphNode) !void {
        try self.scopes.append(self.vm.allocator, node);
    }

    fn addGlobal(self: *Compiler, module_id: Module.Id, name: Frontend.PathTable.Id, elem: Elem) !void {
        try self.global_map.put(
            self.vm.allocator,
            .{ .module_id = module_id, .name = name },
            elem,
        );
    }

    fn localSlot(self: *Compiler, name: Frontend.PathTable.Id) ?u8 {
        return self.resolver().localSlot(name);
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

    fn emitJump(self: *Compiler, op: OpCode, region: Region) !Ir.Index {
        return self.ir().push(self.vm.allocator, .{ .jump = .{ .op = op, .target = Ir.unpatched_jump } }, region);
    }

    fn patchJump(self: *Compiler, index: Ir.Index) void {
        self.ir().patchJumpTarget(index);
    }

    fn emitJumpBack(self: *Compiler, op: OpCode, target: Ir.Index, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .jump_back = .{ .op = op, .target = target } }, region);
    }

    fn emitOp(self: *Compiler, op: OpCode, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .none = op }, region);
    }

    fn emitEnd(self: *Compiler) !void {
        const r = self.ir().lastByteRegion();
        try self.emitOp(.End, Region.new(r.end, r.end));
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .byte = .{ .op = op, .byte = byte } }, region);
    }

    fn emitBytePair(self: *Compiler, op: OpCode, byte1: u8, region1: Region, byte2: u8, region2: Region, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .byte_pair = .{
            .op = op,
            .byte1 = byte1,
            .region1 = region1,
            .byte2 = byte2,
            .region2 = region2,
        } }, region);
    }

    fn emitLongOp(self: *Compiler, op: OpCode, value: u32, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .long = .{ .op = op, .value = value } }, region);
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

    fn emitConstant(self: *Compiler, idx: u24, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .get_constant = idx }, region);
    }

    fn emitPushString(self: *Compiler, sid: RuntimeStrings.Id, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .push_string = sid }, region);
    }

    fn emitPushVar(self: *Compiler, sid: RuntimeStrings.Id, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .push_var = sid }, region);
    }

    fn emitCallFunctionConstant(self: *Compiler, idx: u24, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .call_function_constant = idx }, region);
    }

    fn emitMatchPlan(self: *Compiler, idx: u24, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .destructure_plan = idx }, region);
    }

    // ===================================================================
    // Goal compilation: function bodies emitted from the goal ast. The
    // driver layers above (declaration ordering, aliases, builtins) are
    // shared with the can path; binding facts come from the goal (slot
    // classifications, lambda captures), and the dependency graph is
    // consulted only for global resolution and frame local layouts.
    // ===================================================================

    fn goalAst(self: *Compiler, module_id: Module.Id) *const Ast {
        const goal = self.frontend.goals.get(module_id) orelse
            @panic("Internal Error: no goal ast for module");
        return &goal.ast;
    }

    // The goal declaration matching a dependency graph declaration node.
    // Callers reach this from a can declaration's key, swapping the can ast
    // for the goal ast that shares its module and name.
    fn goalDeclaration(ast: *const Ast, name: Frontend.PathTable.Id) *const Ast.Declaration {
        for (ast.declarations.items) |*decl| {
            if (decl.name == name) return decl;
        }
        @panic("Internal Error: no goal declaration for name");
    }

    fn goalFunctionBody(ast: *const Ast, name: Frontend.PathTable.Id) ?Ast.NodeId {
        if (ast.main_name == name) return ast.main;
        for (ast.declarations.items) |decl| {
            if (decl.name == name) return decl.body;
        }
        for (ast.goals.items) |rnode| {
            switch (rnode.node) {
                .lambda => |lambda| if (lambda.name == name) return lambda.body,
                else => {},
            }
        }
        return null;
    }

    fn goalLambdaCaptures(ast: *const Ast, name: Frontend.PathTable.Id) usize {
        for (ast.goals.items) |rnode| {
            switch (rnode.node) {
                .lambda => |lambda| if (lambda.name == name) return lambda.captures.items.len,
                else => {},
            }
        }
        return 0;
    }

    fn emitGoalFunctionBody(
        self: *Compiler,
        module_id: Module.Id,
        node: *DependencyGraphNode,
        function: *Elem.DynElem.Function,
        ast: *const Ast,
        body: Ast.NodeId,
        captures_count: usize,
        region: Region,
    ) !void {
        try self.functions.append(self.vm.allocator, function);
        try self.pushScope(node);
        try self.irs.append(self.vm.allocator, Ir{});

        try self.pushLocalPlaceholders(module_id, function.arity, region);

        if (captures_count > 0) {
            try self.emitOp(.SetClosureCaptures, region);
        }

        try self.writeGoal(module_id, ast, body);
        try self.finishFunctionIr(module_id);

        _ = self.functions.pop();
        _ = self.scopes.pop();
    }

    // Whether matches compile through plans for debug visibility: the
    // plan interpreter carries the destructure printing and --explain
    // step events, which inline steps do not yet emit.
    fn goalMatchDebugging(self: *Compiler) bool {
        return self.vm.config.explain;
    }

    // The scratch register count one stepable arm's match steps use:
    // places, the dead register, one claim register per search pair, a
    // shared value + cursor register when the arm searches at all, a
    // shared repeat block when it repeats at all (the count register,
    // plus loop base and element registers for array-chunk repeats), and
    // the cursor-template block (front, end, rest dst, char). A pure-place
    // arm — no search/repeat/cursor-template pool — is exactly
    // places.len + 1.
    fn armStepScratchWidth(self: *Compiler, ast: *const Ast, places: []const Ast.PlaceDef, constraints: []const Ast.Constraint) u32 {
        var searches: u32 = 0;
        var repeats: u32 = 0;
        var templates: u32 = 0;
        for (constraints) |constraint| switch (constraint.kind) {
            .search_key => searches += 1,
            .solve_repeat => |c| {
                const shape = self.repeatShape(ast, c.pattern, c.count).?;
                repeats = @max(repeats, @as(u32, if (shape == .array) 3 else 1));
            },
            .match_template => |c| {
                if (self.templateStepable(ast, c.segments.items) == .cursor) templates = 4;
            },
            else => {},
        };
        const extra: u32 = if (searches > 0) searches + 2 else 0;
        return @as(u32, @intCast(places.len + 1)) + extra + repeats + templates;
    }

    fn writeGoal(self: *Compiler, module_id: Module.Id, ast: *const Ast, id: Ast.NodeId) Error!void {
        const rnode = ast.goals.items[id];
        const region = rnode.region;
        switch (rnode.node) {
            .true => try self.writeConstant(module_id, Elem.boolean(true), region),
            .false => try self.writeConstant(module_id, Elem.boolean(false), region),
            .null => try self.writeConstant(module_id, Elem.nullConst, region),
            .string => |s| try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert(s)), region),
            .number_string => |ns| try self.writeConstant(module_id, try self.numberStringNodeToElem(ns.number, ns.negated), region),
            .number_float => |f| try self.writeConstant(module_id, Elem.numberFloat(f), region),
            .ident => |ident| try self.writeGoalIdentValue(module_id, ident, true, region),
            .call => |call| try self.writeGoalCall(module_id, ast, call, region),
            .lambda => |*lambda| try self.writeGoalLambda(module_id, lambda, region),
            .seq => |seq| try self.writeGoalSeq(module_id, ast, seq, region),
            .alt => |arms| try self.writeGoalAlt(module_id, ast, arms.items, region),
            .merge => |merge| {
                try self.writeGoal(module_id, ast, merge.left);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeGoal(module_id, ast, merge.right);
                try self.emitOp(.Merge, region);
                self.patchJump(jumpIndex);
            },
            .mult => |mult| {
                try self.writeGoal(module_id, ast, mult.left);
                try self.writeGoal(module_id, ast, mult.right);
                try self.emitOp(.RepeatValue, region);
            },
            .neg => |inner| {
                // Negation of a parser invocation negates the parser
                // itself (a negated number parser matches the negated
                // literal), matching the can parser path; negation of a
                // value negates the result.
                const inner_node = ast.goals.items[inner].node;
                if (inner_node == .call) {
                    const callee = ast.goals.items[inner_node.call.callee];
                    const negatable = switch (callee.node) {
                        .number_string => true,
                        .ident => |i| !self.goalNameIsValueCase(i.name),
                        else => false,
                    };
                    if (negatable) {
                        try self.writeGoalNegatedParser(module_id, ast, inner_node.call.callee, region);
                        try self.emitUnaryOp(.CallFunction, 0, region);
                        return;
                    }
                }
                try self.writeGoal(module_id, ast, inner);
                try self.emitOp(.NegateNumber, region);
            },
            .to_string => |inner| {
                try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert("")), region);
                try self.writeGoal(module_id, ast, inner);
                try self.emitOp(.MergeAsString, region);
            },
            .array => |elems| try self.writeGoalArray(module_id, ast, elems.items, region),
            .object => |pairs| try self.writeGoalObject(module_id, ast, pairs.items, region),
            .repeat => |*repeat| try self.writeGoalRepeat(module_id, ast, repeat, region),
            .range => @panic("Internal Error: bare range goal outside call position"),
            .match => |*match| try self.writeGoalMatch(module_id, ast, match, region),
        }
    }

    // A bare ident evaluates to its value. Value positions mirror the can
    // compiler's writeValue: a zero-arity value function global is
    // invoked. Argument positions for parser params (and unknown callees)
    // pass the function elem itself.
    fn writeGoalIdentValue(self: *Compiler, module_id: Module.Id, ident: Ast.Ident, invoke_functions: bool, region: Region) Error!void {
        switch (ident.resolution) {
            .local => |slot| try self.emitUnaryOp(.GetLocal, slot, region),
            .placeholder => try self.emitOp(.PushUnderscoreVar, region),
            .global => {
                const global = self.resolveGlobal(module_id, ident.name) orelse {
                    try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.pathString(ident.name)});
                    return Error.UndefinedVariable;
                };
                if (invoke_functions and global.isDynType(.Function) and global.asDyn().asFunction().arity == 0) {
                    try self.writeCallFunctionConstant(module_id, global, region);
                } else {
                    try self.writeConstant(module_id, global, region);
                }
            },
            .unresolved => @panic("Internal Error: unresolved ident survived binding"),
        }
    }

    fn writeGoalCall(self: *Compiler, module_id: Module.Id, ast: *const Ast, call: Ast.Call, region: Region) Error!void {
        const callee = ast.goals.items[call.callee];
        switch (callee.node) {
            .ident => |ident| try self.writeGoalFunctionCall(module_id, ast, ident, call, region, callee.region),
            .string => |string| {
                std.debug.assert(call.args.len == 0);
                if (string.len == 0) {
                    try self.emitOp(.PushEmptyString, region);
                } else if (string.len == 1) {
                    try self.emitUnaryOp(.ParseChar, string[0], region);
                } else {
                    const sid = try self.vm.strings.insert(string);
                    try self.writeCallFunctionConstant(module_id, Elem.string(sid), region);
                }
            },
            .number_string => |ns| {
                std.debug.assert(call.args.len == 0);
                if (ns.number.len == 1 and !ns.negated) {
                    try self.emitUnaryOp(.ParseNumberStringChar, ns.number[0], region);
                } else {
                    const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                    try self.writeCallFunctionConstant(module_id, elem, region);
                }
            },
            .range => |range| try self.writeGoalRangeParser(module_id, ast, range, region),
            .neg => |inner| {
                try self.writeGoalNegatedParser(module_id, ast, inner, region);
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            else => {
                // A computed callee: evaluate it, then invoke.
                try self.writeGoal(module_id, ast, call.callee);
                try self.emitUnaryOp(.CallFunction, @intCast(call.args.len), region);
            },
        }
    }

    fn writeGoalNegatedParser(self: *Compiler, module_id: Module.Id, ast: *const Ast, inner: Ast.NodeId, region: Region) Error!void {
        const rnode = ast.goals.items[inner];
        switch (rnode.node) {
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, !ns.negated);
                try self.writeConstant(module_id, elem, rnode.region);
            },
            .ident => |ident| {
                try self.writeGoalIdentValue(module_id, ident, false, region);
                try self.emitOp(.NegateParser, region);
            },
            else => {
                try self.printError(module_id, region, "Negated parser must be a number or named number parser", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeGoalFunctionCall(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        ident: Ast.Ident,
        call: Ast.Call,
        call_region: Region,
        callee_region: Region,
    ) Error!void {
        const args = call.args;
        var function_elem: ?*Elem.DynElem.Function = null;

        switch (ident.resolution) {
            .local => |slot| {
                if (args.len == 0) {
                    try self.emitUnaryOp(.CallFunctionLocal, slot, call_region);
                    return;
                }
                try self.emitUnaryOp(.GetLocal, slot, callee_region);
            },
            .global => {
                const global = self.resolveGlobal(module_id, ident.name) orelse {
                    if (args.len == 0) {
                        try self.printError(module_id, callee_region, "undefined variable '{s}'", .{self.frontend.pathString(ident.name)});
                    } else {
                        try self.printError(module_id, callee_region, "Undefined function '{s}'", .{self.frontend.pathString(ident.name)});
                    }
                    return Error.UndefinedVariable;
                };
                if (args.len == 0) {
                    try self.writeCallFunctionConstant(module_id, global, call_region);
                    return;
                }
                if (!global.isDynType(.Function)) {
                    try self.printError(module_id, callee_region, "Only named functions can be called", .{});
                    return Error.InvalidAst;
                }
                function_elem = global.asDyn().asFunction();
                try self.writeConstant(module_id, global, callee_region);
            },
            .placeholder, .unresolved => @panic("Internal Error: uncallable ident resolution"),
        }

        if (function_elem) |f| {
            if (f.arity != args.len) {
                const name = self.vm.strings.get(f.name);
                try self.printError(module_id, call_region, "Function '{s}' expects {d} arguments but got {d}", .{ name, f.arity, args.len });
                return if (f.arity < args.len) Error.FunctionCallTooManyArgs else Error.FunctionCallTooFewArgs;
            }
        } else if (!self.goalNameIsValueCase(ident.name)) {
            // A parser-named local callee gets the runtime arity and
            // param-kind asserts the can parser path emits; value-named
            // local callees mirror the value path, which emits none.
            if (args.len > std.math.maxInt(u5)) {
                try self.printError(module_id, call_region, "Can't have more than {} arguments.", .{std.math.maxInt(u5)});
                return Error.MaxFunctionArgs;
            }
            try self.emitUnaryOp(.AssertFunctionArity, @intCast(args.len), call_region);

            if (args.len < 8) {
                try self.emitUnaryOp(.AssertParamTypes, @intCast(call.value_args & 0x7F), call_region);
            } else {
                try self.emitLongOp(.AssertParamTypes4, call.value_args, call_region);
            }
        }

        for (args) |arg| {
            try self.writeGoalArg(module_id, ast, arg);
        }

        try self.emitUnaryOp(.CallFunction, @intCast(args.len), call_region);
    }

    // Surface naming determines an identifier's kind: parsers are
    // lowercase, values uppercase, with `_` and `@` prefixes skipped.
    // Whether an eval_eq expression lowers to inline steps without risking
    // a runtime panic. writeGoal compiles a call with the value path's
    // guards, which omit the function-ness assert for a value-cased local
    // callee; calling a non-function there panics in callFunction, where
    // the plan interpreter's evalCall returns a graceful RuntimeError.
    // Keep any expression that calls such a callee, or that has a shape the
    // step path does not lower, on the plan path.
    fn evalExprStepable(self: *Compiler, ast: *const Ast, id: Ast.NodeId) bool {
        return switch (ast.goals.items[id].node) {
            .true, .false, .null, .string, .number_string, .number_float, .ident => true,
            .neg => |inner| self.evalExprStepable(ast, inner),
            .to_string => |inner| self.evalExprStepable(ast, inner),
            .merge => |m| self.evalExprStepable(ast, m.left) and self.evalExprStepable(ast, m.right),
            .mult => |m| self.evalExprStepable(ast, m.left) and self.evalExprStepable(ast, m.right),
            .array => |elems| {
                for (elems.items) |elem| if (!self.evalExprStepable(ast, elem)) return false;
                return true;
            },
            .object => |pairs| {
                for (pairs.items) |pair| {
                    if (!self.evalExprStepable(ast, pair.key)) return false;
                    if (!self.evalExprStepable(ast, pair.value)) return false;
                }
                return true;
            },
            .call => |call| {
                const callee = ast.goals.items[call.callee].node;
                if (callee != .ident) return false;
                if (callee.ident.resolution == .local and self.goalNameIsValueCase(callee.ident.name)) return false;
                for (call.args) |arg| if (!self.evalExprStepable(ast, arg)) return false;
                return true;
            },
            .alt, .seq, .match, .lambda, .repeat, .range => false,
        };
    }

    fn goalNameIsValueCase(self: *Compiler, name: Frontend.PathTable.Id) bool {
        const bytes = self.frontend.pathString(name);
        var i: usize = 0;
        while (i < bytes.len and (bytes[i] == '_' or bytes[i] == '@')) i += 1;
        return i < bytes.len and std.ascii.isUpper(bytes[i]);
    }

    // A parser-named ident argument passes its function elem; a
    // value-named argument evaluates like any value position (invoking a
    // zero-arity value function), mirroring the can arg-kind split.
    fn writeGoalArg(self: *Compiler, module_id: Module.Id, ast: *const Ast, id: Ast.NodeId) Error!void {
        const rnode = ast.goals.items[id];
        switch (rnode.node) {
            .ident => |ident| {
                const invoke = self.goalNameIsValueCase(ident.name);
                try self.writeGoalIdentValue(module_id, ident, invoke, rnode.region);
            },
            else => try self.writeGoal(module_id, ast, id),
        }
    }

    fn writeGoalLambda(self: *Compiler, module_id: Module.Id, lambda: *const Ast.Lambda, region: Region) Error!void {
        const key = GlobalKey{ .module_id = module_id, .name = lambda.name };
        const function = try self.declareAnonFunction(key);

        const constId = try self.makeConstant(module_id, function.dyn.elem());
        try self.emitConstant(constId, region);

        const captures = lambda.captures.items;
        if (captures.len == 0) return;

        const anon_node = self.frontend.getNode(key);
        const local_count: u8 = @intCast(anon_node.anonymous_function.locals.items.len);
        try self.emitUnaryOp(.CreateClosure, local_count, region);

        // Capture slots are the lambda frame's first locals; emit
        // CaptureLocal in that order so SetClosureCaptures fills the
        // right slots.
        const lambda_locals = anon_node.locals();
        for (lambda_locals[0..captures.len]) |sid| {
            const fromSlot = self.resolver().localSlotSid(sid) orelse
                @panic("Internal Error: capture source slot missing");
            try self.emitUnaryOp(.CaptureLocal, @intCast(fromSlot), region);
        }
    }

    fn writeGoalSeq(self: *Compiler, module_id: Module.Id, ast: *const Ast, seq: Ast.Seq, region: Region) Error!void {
        const goals = seq.goals.items;
        var end_jumps = ArrayList(Ir.Index){};
        defer end_jumps.deinit(self.vm.allocator);

        for (goals[0..seq.result]) |g| {
            // `"" $ x` and `"" & x`: the empty-string parse always
            // succeeds with nothing consumed, so skip it, matching the
            // can path's `$` special case.
            const g_node = ast.goals.items[g].node;
            if (g_node == .call) {
                const callee = ast.goals.items[g_node.call.callee].node;
                if (callee == .string and callee.string.len == 0) continue;
            }
            try self.writeGoal(module_id, ast, g);
            try end_jumps.append(self.vm.allocator, try self.emitJump(.TakeRight, region));
        }
        try self.writeGoal(module_id, ast, goals[seq.result]);
        for (goals[seq.result + 1 ..]) |g| {
            const jumpIndex = try self.emitJump(.JumpIfFailure, region);
            try self.writeGoal(module_id, ast, g);
            try self.emitOp(.TakeLeft, region);
            self.patchJump(jumpIndex);
        }
        for (end_jumps.items) |jumpIndex| self.patchJump(jumpIndex);
    }

    fn writeGoalAlt(self: *Compiler, module_id: Module.Id, ast: *const Ast, arms: []const Ast.AltArm, region: Region) Error!void {
        var end_jumps = ArrayList(Ir.Index){};
        defer end_jumps.deinit(self.vm.allocator);

        for (arms, 0..) |arm, i| {
            const last = i == arms.len - 1;
            if (arm.guard) |guard| {
                try self.emitOp(.SetInputMark, region);
                try self.writeGoal(module_id, ast, guard);
                if (arm.body) |body| {
                    const next = try self.emitJump(.ConditionalThen, region);
                    try self.writeGoal(module_id, ast, body);
                    if (!last) {
                        try end_jumps.append(self.vm.allocator, try self.emitJump(.Jump, region));
                        self.patchJump(next);
                    } else {
                        // A guarded last arm has no fallthrough arm: the
                        // failed guard is the alt's failure.
                        try end_jumps.append(self.vm.allocator, try self.emitJump(.Jump, region));
                        self.patchJump(next);
                        try self.emitOp(.PushFail, region);
                    }
                } else {
                    try end_jumps.append(self.vm.allocator, try self.emitJump(.Or, region));
                    if (last) try self.emitOp(.PushFail, region);
                }
            } else {
                // A body-only arm commits the alt: success or failure, no
                // later arm runs.
                try self.writeGoal(module_id, ast, arm.body.?);
                if (!last) {
                    try end_jumps.append(self.vm.allocator, try self.emitJump(.Jump, region));
                }
            }
        }
        for (end_jumps.items) |jumpIndex| self.patchJump(jumpIndex);
    }

    fn goalValueToElem(self: *Compiler, ast: *const Ast, id: Ast.NodeId) !?Elem {
        return switch (ast.goals.items[id].node) {
            .false => Elem.boolean(false),
            .true => Elem.boolean(true),
            .null => Elem.nullConst,
            .number_float => |f| Elem.numberFloat(f),
            .number_string => |ns| try self.numberStringNodeToElem(ns.number, ns.negated),
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            .array => |elems| if (elems.items.len == 0) blk: {
                var empty = try Elem.DynElem.Array.create(self.vm, 0);
                break :blk empty.dyn.elem();
            } else null,
            .object => |pairs| if (pairs.items.len == 0) blk: {
                var empty = try Elem.DynElem.Object.create(self.vm, 0);
                break :blk empty.dyn.elem();
            } else null,
            else => null,
        };
    }

    fn writeGoalArray(self: *Compiler, module_id: Module.Id, ast: *const Ast, elems: []const Ast.NodeId, region: Region) Error!void {
        if (elems.len == 0) {
            return try self.emitOp(.PushEmptyArray, region);
        }

        var array = try Elem.DynElem.Array.create(self.vm, elems.len);
        const constant_index = self.ir().nextIndex();
        try self.writeConstant(module_id, array.dyn.elem(), region);

        var mutated = false;
        for (elems, 0..) |elem_id, index| {
            var literal = try self.goalValueToElem(ast, elem_id);
            if (literal == null) {
                // Global constants inline like literals.
                const node = ast.goals.items[elem_id].node;
                if (node == .ident and node.ident.resolution == .global) {
                    if (self.resolveGlobal(module_id, node.ident.name)) |global| {
                        if (!global.isDynType(.Function)) literal = global;
                    }
                }
            }
            if (literal) |elem| {
                try array.append(self.vm, elem);
            } else {
                try self.writeGoal(module_id, ast, elem_id);
                try self.emitUnaryOp(.InsertAtIndex, @intCast(index), ast.goals.items[elem_id].region);
                try array.append(self.vm, try self.placeholderVar());
                mutated = true;
            }
        }
        if (mutated) self.ir().patchConstantMutable(constant_index);
    }

    fn writeGoalObject(self: *Compiler, module_id: Module.Id, ast: *const Ast, pairs: []const Ast.ObjectPair, region: Region) Error!void {
        if (pairs.len == 0) {
            return try self.emitOp(.PushEmptyObject, region);
        }

        var object = try Elem.DynElem.Object.create(self.vm, 0);
        const constant_index = self.ir().nextIndex();
        try self.writeConstant(module_id, object.dyn.elem(), region);

        var mutated = false;
        for (pairs, 0..) |pair, index| {
            const key_literal = try self.goalValueToElem(ast, pair.key);
            const value_literal = try self.goalValueToElem(ast, pair.value);
            if (key_literal != null and value_literal != null and key_literal.?.isType(.String)) {
                if (key_literal.?.isType(.Dyn)) try self.vm.pushTempDyn(key_literal.?.asDyn());
                defer if (key_literal.?.isType(.Dyn)) self.vm.dropTempDyn();
                if (value_literal.?.isType(.Dyn)) try self.vm.pushTempDyn(value_literal.?.asDyn());
                defer if (value_literal.?.isType(.Dyn)) self.vm.dropTempDyn();

                try object.put(self.vm, key_literal.?.asString(), value_literal.?);
            } else {
                std.debug.assert(index <= 255);
                const pos: u8 = @intCast(index);
                try object.putReservedId(self.vm, pos, try self.placeholderVar());
                try self.writeGoal(module_id, ast, pair.key);
                try self.writeGoal(module_id, ast, pair.value);
                try self.emitUnaryOp(.InsertKeyVal, pos, ast.goals.items[pair.key].region);
                mutated = true;
            }
        }
        if (mutated) self.ir().patchConstantMutable(constant_index);
    }

    fn writeGoalRangeParser(self: *Compiler, module_id: Module.Id, ast: *const Ast, range: Ast.Range, region: Region) Error!void {
        if (range.lower != null and range.upper != null) {
            try self.writeGoalBoundedRange(module_id, ast, range.lower.?, range.upper.?, region);
        } else if (range.lower) |lower| {
            try self.writeGoalHalfRange(module_id, ast, lower, .ParseLowerBoundedRange, 0, 0x10ffff, region);
        } else {
            try self.writeGoalHalfRange(module_id, ast, range.upper.?, .ParseUpperBoundedRange, 0x10ffff, 0x10ffff, region);
        }
    }

    fn writeGoalBoundedRange(self: *Compiler, module_id: Module.Id, ast: *const Ast, low: Ast.NodeId, high: Ast.NodeId, region: Region) Error!void {
        const low_node = ast.goals.items[low].node;
        const high_node = ast.goals.items[high].node;

        if (low_node == .string and high_node == .string) {
            const low_codepoint = parsing.utf8Decode(low_node.string) orelse {
                try self.printError(module_id, ast.goals.items[low].region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };
            const high_codepoint = parsing.utf8Decode(high_node.string) orelse {
                try self.printError(module_id, ast.goals.items[high].region, "Character range bound must be a single codepoint", .{});
                return Error.RangeNotSingleCodepoint;
            };
            if (low_codepoint > high_codepoint) {
                try self.printError(module_id, region, "Range upper bound codepoint is less than the lower bound", .{});
                return Error.RangeCodepointsUnordered;
            } else if (low_codepoint == 0 and high_codepoint == 0x10ffff) {
                try self.emitOp(.ParseCodepoint, region);
            } else if (low_codepoint <= 255 and high_codepoint <= 255) {
                try self.emitBytePair(
                    .ParseCodepointRange,
                    @intCast(low_codepoint),
                    ast.goals.items[low].region,
                    @intCast(high_codepoint),
                    ast.goals.items[high].region,
                    region,
                );
            } else {
                try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert(low_node.string)), ast.goals.items[low].region);
                try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert(high_node.string)), ast.goals.items[high].region);
                try self.emitOp(.ParseRange, region);
            }
            return;
        }

        if (low_node == .number_string and high_node == .number_string) {
            const low_elem = try self.numberStringNodeToElem(low_node.number_string.number, low_node.number_string.negated);
            const high_elem = try self.numberStringNodeToElem(high_node.number_string.number, high_node.number_string.negated);
            const low_num = low_elem.asNumberString().toNumberFloat(self.vm.strings);
            const high_num = high_elem.asNumberString().toNumberFloat(self.vm.strings);
            if (!low_num.isInteger(self.vm.strings) or !high_num.isInteger(self.vm.strings)) {
                try self.printError(module_id, region, "Range bound must be an integer", .{});
                return Error.RangeInvalidNumberFormat;
            }
            const low_int = try low_num.asInteger(self.vm.strings);
            const high_int = try high_num.asInteger(self.vm.strings);
            if (low_int > high_int) {
                try self.printError(module_id, region, "Range upper bound is less than the lower bound", .{});
                return Error.RangeIntegersUnordered;
            } else if (0 <= low_int and low_int <= 255 and 0 <= high_int and high_int <= 255) {
                try self.emitBytePair(
                    .ParseIntegerRange,
                    @intCast(low_int),
                    ast.goals.items[low].region,
                    @intCast(high_int),
                    ast.goals.items[high].region,
                    region,
                );
            } else {
                try self.writeConstant(module_id, low_num, ast.goals.items[low].region);
                try self.writeConstant(module_id, high_num, ast.goals.items[high].region);
                try self.emitOp(.ParseRange, region);
            }
            return;
        }

        try self.writeGoalRangeBound(module_id, ast, low, region);
        try self.writeGoalRangeBound(module_id, ast, high, region);
        try self.emitOp(.ParseRange, region);
    }

    fn writeGoalRangeBound(self: *Compiler, module_id: Module.Id, ast: *const Ast, id: Ast.NodeId, region: Region) Error!void {
        const rnode = ast.goals.items[id];
        switch (rnode.node) {
            .string => |s| {
                _ = parsing.utf8Decode(s) orelse {
                    try self.printError(module_id, rnode.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };
                try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert(s)), rnode.region);
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const num = elem.asNumberString().toNumberFloat(self.vm.strings);
                if (!num.isInteger(self.vm.strings)) {
                    try self.printError(module_id, rnode.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }
                try self.writeConstant(module_id, num, rnode.region);
            },
            .ident => |ident| try self.writeGoalIdentValue(module_id, ident, false, rnode.region),
            .neg => |inner| try self.writeGoalNegatedParser(module_id, ast, inner, region),
            else => {
                try self.printError(module_id, rnode.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn writeGoalHalfRange(self: *Compiler, module_id: Module.Id, ast: *const Ast, bound: Ast.NodeId, op: OpCode, full_low: u21, full_high: u21, region: Region) Error!void {
        const rnode = ast.goals.items[bound];
        switch (rnode.node) {
            .string => |s| {
                const codepoint = parsing.utf8Decode(s) orelse {
                    try self.printError(module_id, rnode.region, "Character range bound must be a single codepoint", .{});
                    return Error.RangeNotSingleCodepoint;
                };
                const full = if (op == .ParseLowerBoundedRange) codepoint == full_low else codepoint == full_high;
                if (full) {
                    try self.emitOp(.ParseCodepoint, region);
                } else {
                    try self.writeConstant(module_id, Elem.string(try self.vm.strings.insert(s)), rnode.region);
                    try self.emitOp(op, region);
                }
            },
            .number_string => |ns| {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const num = elem.asNumberString().toNumberFloat(self.vm.strings);
                const f = num.asFloat();
                if (@trunc(f) != f) {
                    try self.printError(module_id, rnode.region, "Range bound must be an integer", .{});
                    return Error.RangeInvalidNumberFormat;
                }
                try self.writeConstant(module_id, num, rnode.region);
                try self.emitOp(op, region);
            },
            .ident => |ident| {
                try self.writeGoalIdentValue(module_id, ident, false, region);
                try self.emitOp(op, region);
            },
            .neg => |inner| {
                try self.writeGoalNegatedParser(module_id, ast, inner, region);
                try self.emitOp(op, region);
            },
            else => {
                try self.printError(module_id, rnode.region, "Range bound must be an integer or codepoint", .{});
                return Error.InvalidAst;
            },
        }
    }

    // How a repeat count test constrains the loop: an exact evaluable
    // count, a range, a plain binder, or a compound set that only a
    // count destructure can decide.
    const CountShape = union(enum) {
        none,
        exact,
        range: Ast.Constraint.Kind,
        destructure,
    };

    fn goalCountShape(ast: *const Ast, count_test: ?Ast.SetId) CountShape {
        const set_id = count_test orelse return .none;
        const constraints = ast.constraint_sets.items[set_id].constraints.items;
        if (constraints.len != 1) return .destructure;
        return switch (constraints[0].kind) {
            .eq_const, .eq_slot, .eq_global, .eval_eq => .exact,
            .in_range => .{ .range = constraints[0].kind },
            else => .destructure,
        };
    }

    fn writeGoalLimitValue(self: *Compiler, module_id: Module.Id, ast: *const Ast, limit: Ast.Limit, region: Region) Error!void {
        switch (limit) {
            .read => |local| try self.emitUnaryOp(.GetLocal, local.slot, region),
            .global => |name| {
                const global = self.resolveGlobal(module_id, name) orelse {
                    try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.pathString(name)});
                    return Error.UndefinedVariable;
                };
                try self.writeConstant(module_id, global, region);
            },
            .expr => |expr| try self.writeGoal(module_id, ast, expr),
            .none, .bind, .local => @panic("Internal Error: repeat cap is not evaluable"),
        }
    }

    fn writeGoalRepeat(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, region: Region) Error!void {
        switch (goalCountShape(ast, repeat.count_test)) {
            .exact => {
                std.debug.assert(repeat.cap != .none);
                try self.writeGoalRepeatCounted(module_id, ast, repeat, region);
            },
            .none => {
                if (repeat.cap != .none) {
                    try self.writeGoalRepeatOptional(module_id, ast, repeat, null, region);
                } else {
                    try self.writeGoalRepeatGreedy(module_id, ast, repeat.body, region);
                }
            },
            .range => |kind| {
                const lower = kind.in_range.lower;
                const lower_evaluable = switch (lower) {
                    .read, .global, .expr => true,
                    else => false,
                };
                if (lower_evaluable and repeat.cap != .none) {
                    try self.writeGoalRepeatRangeBounded(module_id, ast, repeat, lower, region);
                } else if (lower_evaluable) {
                    try self.writeGoalRepeatRequired(module_id, ast, repeat, lower, region);
                } else if (repeat.cap != .none) {
                    try self.writeGoalRepeatOptional(module_id, ast, repeat, repeat.count_test, region);
                } else {
                    try self.writeGoalRepeatUnknown(module_id, ast, repeat, region);
                }
            },
            .destructure => {
                if (repeat.cap != .none) {
                    try self.writeGoalRepeatOptional(module_id, ast, repeat, repeat.count_test, region);
                } else {
                    try self.writeGoalRepeatUnknown(module_id, ast, repeat, region);
                }
            },
        }
    }

    // Exactly-n repetitions: every iteration is required, failure aborts
    // the repeat with the failure. Port of writeParserRepeatCount.
    fn writeGoalRepeatCounted(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, region: Region) Error!void {
        const count_region: Region = if (repeat.count_test) |set_id|
            ast.constraint_sets.items[set_id].region
        else
            region;
        try self.writeConstant(module_id, Elem.nullConst, region);

        try self.writeGoalLimitValue(module_id, ast, repeat.cap, count_region);
        try self.emitOp(.ValidateRepeatPattern, count_region);
        const nullJump = try self.emitJump(.JumpIfZero, region);

        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.writeGoal(module_id, ast, repeat.body);
        try self.emitOp(.Merge, region);
        const failureJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        self.patchJump(failureJump);
        try self.emitOp(.Swap, region);

        self.patchJump(nullJump);
        self.patchJump(doneJump);
        try self.emitOp(.Drop, region);
    }

    // Up-to-cap optional repetitions, optionally destructuring the
    // achieved count against the count test. Port of
    // writeParserRepeatRangeUpperBounded.
    fn writeGoalRepeatOptional(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, count_set: ?Ast.SetId, region: Region) Error!void {
        try self.writeConstant(module_id, Elem.nullConst, region);

        try self.writeGoalLimitValue(module_id, ast, repeat.cap, region);
        try self.emitOp(.ValidateRepeatPattern, region);
        const nullJump = try self.emitJump(.JumpIfZero, region);

        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, region);
        try self.writeGoal(module_id, ast, repeat.body);
        const failureJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.PopInputMark, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        self.patchJump(failureJump);
        try self.emitOp(.ResetInput, region);
        try self.emitOp(.Drop, region);
        try self.emitOp(.Swap, region);

        self.patchJump(nullJump);
        self.patchJump(doneJump);

        if (count_set) |set_id| {
            // remaining -> achieved: -remaining + cap
            try self.emitOp(.NegateNumber, region);
            try self.writeGoalLimitValue(module_id, ast, repeat.cap, region);
            try self.emitOp(.Merge, region);
            try self.writeGoalCountDestructure(module_id, ast, set_id, region);
        }

        try self.emitOp(.Drop, region);
    }

    // A required lower bound, then greedy optional iterations; the count
    // test destructures against the total when the range has an upper
    // binder. Port of writeParserRepeatRangeLowerBounded.
    fn writeGoalRepeatRequired(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, lower: Ast.Limit, region: Region) Error!void {
        const count_set = repeat.count_test.?;
        const upper_binds = blk: {
            const constraints = ast.constraint_sets.items[count_set].constraints.items;
            break :blk constraints[0].kind.in_range.upper == .bind;
        };

        try self.writeConstant(module_id, Elem.nullConst, region);

        try self.writeGoalLimitValue(module_id, ast, lower, region);
        try self.emitOp(.ValidateRepeatPattern, region);
        const skipLowerJump = try self.emitJump(.JumpIfZero, region);

        const loopStartRequired = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.writeGoal(module_id, ast, repeat.body);
        try self.emitOp(.Merge, region);
        const failureLowerJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, region);
        const doneLowerJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        self.patchJump(skipLowerJump);
        self.patchJump(doneLowerJump);

        // Count under acc.
        try self.emitOp(.Swap, region);

        const loopStartOptional = self.ir().nextIndex();
        try self.emitOp(.SetInputMark, region);
        try self.writeGoal(module_id, ast, repeat.body);
        const failureOptionalJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.PopInputMark, region);
        try self.emitOp(.Merge, region);
        if (upper_binds) {
            try self.emitOp(.Swap, region);
            try self.emitOp(.Increment, region);
            try self.emitOp(.Swap, region);
        }
        try self.emitJumpBack(.JumpBack, loopStartOptional, region);

        self.patchJump(failureOptionalJump);
        try self.emitOp(.ResetInput, region);
        try self.emitOp(.Drop, region);

        if (upper_binds) {
            // optional count -> total: optional + lower
            try self.emitOp(.Swap, region);
            try self.writeGoalLimitValue(module_id, ast, lower, region);
            try self.emitOp(.Merge, region);
            try self.writeGoalCountDestructure(module_id, ast, count_set, region);
            try self.emitOp(.Swap, region);
        }

        self.patchJump(failureLowerJump);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Drop, region);
    }

    // A required lower bound then up to cap-minus-lower optional
    // iterations. Port of writeParserRepeatRangeBounded.
    fn writeGoalRepeatRangeBounded(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, lower: Ast.Limit, region: Region) Error!void {
        try self.writeConstant(module_id, Elem.nullConst, region);

        try self.writeGoalLimitValue(module_id, ast, lower, region);
        try self.emitOp(.ValidateRepeatPattern, region);
        const skipLowerJump = try self.emitJump(.JumpIfZero, region);

        const loopStartRequired = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.writeGoal(module_id, ast, repeat.body);
        try self.emitOp(.Merge, region);
        const failureLowerJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, region);
        const doneLowerJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        self.patchJump(skipLowerJump);
        self.patchJump(doneLowerJump);

        try self.emitOp(.Drop, region);
        try self.writeGoalLimitValue(module_id, ast, repeat.cap, region);
        try self.writeGoalLimitValue(module_id, ast, lower, region);
        try self.emitOp(.NegateNumber, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.ValidateRepeatPattern, region);
        const skipUpperJump = try self.emitJump(.JumpIfZero, region);

        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, region);
        try self.writeGoal(module_id, ast, repeat.body);
        const failureUpperJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.PopInputMark, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        self.patchJump(failureUpperJump);
        try self.emitOp(.ResetInput, region);
        try self.emitOp(.Drop, region);

        self.patchJump(failureLowerJump);
        try self.emitOp(.Swap, region);

        self.patchJump(skipUpperJump);
        self.patchJump(doneJump);
        try self.emitOp(.Drop, region);
    }

    // Unbounded optional iterations with a counted total destructured
    // against the count test. Port of writeParserRepeatUnknownCount.
    fn writeGoalRepeatUnknown(self: *Compiler, module_id: Module.Id, ast: *const Ast, repeat: *const Ast.Repeat, region: Region) Error!void {
        try self.writeConstant(module_id, Elem.numberFloat(0), region);
        try self.writeConstant(module_id, Elem.nullConst, region);

        const loopStart = self.ir().nextIndex();
        try self.emitOp(.SetInputMark, region);
        try self.writeGoal(module_id, ast, repeat.body);
        const failureJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.PopInputMark, region);
        try self.emitOp(.Merge, region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Increment, region);
        try self.emitOp(.Swap, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        self.patchJump(failureJump);
        try self.emitOp(.ResetInput, region);
        try self.emitOp(.Drop, region);
        try self.emitOp(.Swap, region);
        try self.writeGoalCountDestructure(module_id, ast, repeat.count_test.?, region);
        try self.emitOp(.Drop, region);
    }

    // Iterate until the body fails; no count constraints at all.
    fn writeGoalRepeatGreedy(self: *Compiler, module_id: Module.Id, ast: *const Ast, body: Ast.NodeId, region: Region) Error!void {
        try self.writeConstant(module_id, Elem.nullConst, region);

        const loopStart = self.ir().nextIndex();
        try self.emitOp(.SetInputMark, region);
        try self.writeGoal(module_id, ast, body);
        const failureJump = try self.emitJump(.JumpIfFailure, region);
        try self.emitOp(.PopInputMark, region);
        try self.emitOp(.Merge, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        self.patchJump(failureJump);
        try self.emitOp(.ResetInput, region);
        try self.emitOp(.Drop, region);
    }

    fn writeGoalCountDestructure(self: *Compiler, module_id: Module.Id, ast: *const Ast, set_id: Ast.SetId, region: Region) Error!void {
        const set = &ast.constraint_sets.items[set_id];
        if (!self.goalMatchDebugging() and self.constraintsStepable(ast, set.constraints.items)) {
            try self.writeMatchSteps(module_id, ast, set.places.items, set.constraints.items, .input, region);
            return;
        }
        var lowerer = pattern.Lowerer{
            .vm = self.vm,
            .frontend = self.frontend,
            .resolver = self.resolver(),
            .plan_slots = &self.plan_slots,
        };
        const planId = try goal_pattern.createMatchPlanFromSet(&lowerer, module_id, ast, set_id);
        try self.emitMatchPlan(planId, region);
    }

    // ===== Match lowering =====

    fn writeGoalMatch(self: *Compiler, module_id: Module.Id, ast: *const Ast, match: *const Ast.Match, match_region: Region) Error!void {
        _ = match_region;
        try self.writeGoal(module_id, ast, match.scrutinee);

        if (match.arms.items.len != 1) @panic("Internal Error: multi-arm match lowering not implemented");
        const arm = &match.arms.items[0];
        if (arm.guard != null or arm.body != null) @panic("Internal Error: match arm guard/body lowering not implemented");

        // The pattern's own region drives failure attribution and debug
        // rendering, matching the can path's DestructurePlan region.
        const region = arm.region;

        // The plan interpreter carries the destructure debug printing and
        // the --explain step events; inline steps have neither yet, so
        // those modes take the plan path for every arm.
        if (!self.goalMatchDebugging() and self.armStepable(ast, arm)) {
            try self.writeMatchSteps(module_id, ast, match.places.items, arm.constraints.items, .input, region);
        } else {
            var lowerer = pattern.Lowerer{
                .vm = self.vm,
                .frontend = self.frontend,
                .resolver = self.resolver(),
                .plan_slots = &self.plan_slots,
            };
            const planId = try goal_pattern.createMatchPlanFromArm(&lowerer, module_id, ast, match, arm);
            try self.emitMatchPlan(planId, region);
        }
    }

    // Whether every constraint and place lowers to an inline step op: the
    // fast path for fixed arrays and constant-key objects of binds and
    // constant tests. Everything else goes through a match plan.
    fn armStepable(self: *Compiler, ast: *const Ast, arm: *const Ast.MatchArm) bool {
        return self.constraintsStepable(ast, arm.constraints.items);
    }

    // Whether every constraint in a set lowers to inline steps. Serves both
    // a root arm and a nested sub-pattern's ConstraintSet (both have the
    // same scrutinee-rooted shape), so it recurses through searchable
    // structural values.
    fn constraintsStepable(self: *Compiler, ast: *const Ast, constraints: []const Ast.Constraint) bool {
        for (constraints) |constraint| switch (constraint.kind) {
            .is_type => {},
            .len_eq, .len_min, .keys_exact, .keys_min => {},
            .has_key, .str_prefix, .str_suffix, .bind, .eq_slot, .eq_global => {},
            .eq_const => {},
            .eval_eq => {},
            .in_range => {},
            .negated => |c| {
                if (!self.negatedStepable(ast, c.part)) return false;
            },
            // A template lowers either to the static prefix/suffix/slice
            // layout (path A) or to the cursor-chomp path (path B).
            // Structural-cast solvables, globals, and repeat segments keep
            // the plan interpreter's resolution.
            .match_template => |c| {
                if (self.templateStepable(ast, c.segments.items) == null) return false;
            },
            // A search pair steps when its key sub-pattern is a shallow
            // leaf (bind, ignore, or bound-local probe) and its value is
            // either a shallow leaf or, for an unbound (scanning) key, a
            // structural sub-pattern matched in a nested window. A
            // structural value under a bound key keeps the plan path.
            .search_key => |c| {
                if (!self.searchSetStepable(ast, c.key, true)) return false;
                if (self.searchSetStepable(ast, c.value, false)) continue;
                if (self.searchKeyBound(ast, c.key)) return false;
                if (!self.searchValueStructuralStepable(ast, c.value)) return false;
            },
            .solve_merge => |c| {
                if (self.classifyNumMergeStep(ast, c.ty, c.parts.items) == null and
                    self.classifyBoolMergeStep(ast, c.ty, c.parts.items) == null and
                    !self.mergeNegatedNonNumber(ast, c.ty, c.parts.items)) return false;
            },
            .solve_repeat => |c| {
                if (self.repeatShape(ast, c.pattern, c.count) == null) return false;
            },
            else => return false,
        };
        return true;
    }

    // A search key is bound when it compares against an existing local
    // (eq_slot) — a direct member probe rather than an unclaimed-member
    // scan.
    fn searchKeyBound(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) bool {
        _ = self;
        const kc = singleSetConstraint(ast, set_id) orelse return false;
        return kc.kind == .eq_slot;
    }

    // A search value that is not a shallow leaf lowers to inline steps when
    // it is a genuine container destructure (more than the scrutinee place)
    // whose whole ConstraintSet steps. It matches in a nested window whose
    // scrutinee is the found member. Evaluated members are excluded: an
    // eval in the value may read this pair's key, which the window path
    // binds only after the value matches (the plan path binds the key
    // first, so `{A: Id(A)}` stays there).
    fn searchValueStructuralStepable(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) bool {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len < 2) return false;
        for (set.constraints.items) |constraint| {
            if (constraint.kind == .eval_eq) return false;
        }
        return self.constraintsStepable(ast, set.constraints.items);
    }

    const RepeatShape = enum { value, chunk, range, array };

    // How a solve_repeat lowers to inline steps. `value`: the pattern
    // operand evaluates at match time (a constant, a bound read, or any
    // evaluable expression — a call, merge, or literal container), the
    // count is derived from the scrutinee's value in place, and the count
    // operand is tested against it. `chunk`: the pattern is a bare binder
    // or placeholder solved from a known count. `range`: the pattern is a
    // codepoint range scanned over a string value, the count is the
    // codepoint count. `array`: the pattern is a fixed-length array of
    // leaf-tested elements, matched chunk by chunk in a loop. Null keeps
    // the plan path — deeper structural sub-patterns, globals (which may
    // be zero-arity functions), non-evaluable pattern operands (alts,
    // sequences, nested matches, value-cased local callees), and
    // both-unresolved shapes (a runtime error the plan preserves).
    fn repeatShape(self: *Compiler, ast: *const Ast, pattern_part: Ast.Part, count: Ast.Part) ?RepeatShape {
        switch (pattern_part) {
            .expr => |id| if (self.evalExprStepable(ast, id) and self.repeatCountStepable(ast, count)) {
                return .value;
            },
            .read => if (self.repeatCountStepable(ast, count)) return .value,
            .bind, .placeholder => if (self.repeatKnownCount(ast, count)) return .chunk,
            .sub => |set_id| if (self.repeatCountStepable(ast, count)) {
                if (self.repeatRangeConstraint(ast, set_id) != null) return .range;
                if (repeatArrayLen(ast, set_id) != null) return .array;
            },
            .local, .global => {},
        }
        return null;
    }

    // The chunk element length of a repeat's fixed-length array
    // sub-pattern, or null when the sub-pattern doesn't lower to the chunk
    // loop. The root must be a fixed-length array (is_type + len_eq on
    // place 0); its interior may nest arrays and constant-key objects of
    // leaf tests and binds, matched per chunk in a nested window. Rests
    // (variable length), ranges, searches, nested repeats, merges, and
    // templates inside a chunk keep the plan path.
    fn repeatArrayLen(ast: *const Ast, set_id: Ast.SetId) ?u32 {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len == 0) return null;

        var root_array = false;
        var len: ?u32 = null;
        for (set.constraints.items) |constraint| switch (constraint.kind) {
            .is_type => |c| if (c.place == 0) {
                if (c.ty != .array) return null;
                root_array = true;
            },
            .len_eq => |c| if (c.place == 0) {
                if (c.len == 0) return null;
                len = c.len;
            },
            // Interior structure tests and leaf tests/binds; a bind
            // compares against the first chunk's value in later chunks.
            // (A range's own bind is not identity-checked across chunks —
            // a pre-existing limitation carried from the leaf-chunk path.)
            .keys_exact, .has_key, .bind, .eq_slot, .eq_const, .eq_global, .str_prefix, .str_suffix, .in_range => {},
            else => return null,
        };
        if (!root_array or len == null) return null;

        // Only fixed projections: the materialized chunk slice is
        // destructured like any array/object pattern. Rests and slices
        // would make the chunk variable-length.
        for (set.places.items) |def| switch (def) {
            .scrutinee, .elem, .key => {},
            else => return null,
        };
        return len;
    }

    // Whether a repeat chunk constrains anything beyond the root array's
    // type and length — i.e. needs the per-chunk matching loop. A chunk of
    // bare placeholders (Array.length's `[_] * L`) does not.
    fn repeatChunkNeedsLoop(ast: *const Ast, set_id: Ast.SetId) bool {
        const set = &ast.constraint_sets.items[set_id];
        for (set.constraints.items) |constraint| {
            if (constraintPrimaryPlace(constraint.kind)) |place| {
                if (place != 0) return true;
            }
        }
        return false;
    }

    // The place a constraint primarily tests or binds, across the kinds a
    // repeat chunk admits (repeatArrayLen); null for kinds it never
    // contains.
    fn constraintPrimaryPlace(kind: Ast.Constraint.Kind) ?Ast.PlaceId {
        return switch (kind) {
            .is_type => |c| c.place,
            .len_eq => |c| c.place,
            .keys_exact => |c| c.place,
            .has_key => |c| c.place,
            .str_prefix => |c| c.place,
            .str_suffix => |c| c.place,
            .bind => |c| c.place,
            .eq_slot => |c| c.place,
            .eq_const => |c| c.place,
            .eq_global => |c| c.place,
            .in_range => |c| c.place,
            else => null,
        };
    }

    // The single range constraint of a repeat's range sub-pattern, or
    // null: exactly one place constrained by one in_range whose bounds
    // are open, bound reads, or constants — the kinds the scan op
    // encodes. Bind and evaluated bounds keep the plan path.
    fn repeatRangeConstraint(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) ?*const Ast.Constraint {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len != 1) return null;
        if (set.constraints.items.len != 1) return null;
        const constraint = &set.constraints.items[0];
        switch (constraint.kind) {
            .in_range => |c| {
                if (!self.repeatRangeLimitStepable(ast, c.lower)) return null;
                if (!self.repeatRangeLimitStepable(ast, c.upper)) return null;
                return constraint;
            },
            else => return null,
        }
    }

    fn repeatRangeLimitStepable(self: *Compiler, ast: *const Ast, limit: Ast.Limit) bool {
        return switch (limit) {
            .none, .read => true,
            .expr => |id| self.constPatternNode(ast, id),
            .bind, .local, .global => false,
        };
    }

    // Whether a count operand lowers to inline tests against the derived
    // count register.
    fn repeatCountStepable(self: *Compiler, ast: *const Ast, count: Ast.Part) bool {
        return switch (count) {
            .placeholder, .bind, .read => true,
            .expr => |id| self.constPatternNode(ast, id),
            .sub => |set_id| repeatCountSetStepable(ast, set_id),
            .local, .global => false,
        };
    }

    // A count sub-set steps when it is a single place constrained by
    // leaf tests: constant equality, ranges with stepable bounds, binds,
    // and bound reads. Merges, negations, and nested composites keep the
    // plan path.
    fn repeatCountSetStepable(ast: *const Ast, set_id: Ast.SetId) bool {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len != 1) return false;
        for (set.constraints.items) |constraint| switch (constraint.kind) {
            .eq_const, .bind, .eq_slot => {},
            .in_range => {},
            else => return false,
        };
        return true;
    }

    // Whether a count operand is a known value usable as a chunk-solve
    // input: a constant or a bound read.
    fn repeatKnownCount(self: *Compiler, ast: *const Ast, count: Ast.Part) bool {
        return switch (count) {
            .read => true,
            .expr => |id| self.constPatternNode(ast, id),
            else => false,
        };
    }

    // Whether a search pair's key or value sub-pattern lowers to inline
    // steps: exactly one place (the found key or value) constrained by at
    // most one leaf. A key may bind, be ignored, or compare against a
    // bound local (a direct member probe); const and global keys keep the
    // plan path until a constant-comparand probe exists. A value may also
    // compare against constants and globals.
    fn searchSetStepable(self: *Compiler, ast: *const Ast, set_id: Ast.SetId, is_key: bool) bool {
        _ = self;
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len != 1) return false;
        if (set.constraints.items.len > 1) return false;
        if (set.constraints.items.len == 0) return true;
        return switch (set.constraints.items[0].kind) {
            .bind, .eq_slot => true,
            .eq_const, .eq_global => !is_key,
            else => false,
        };
    }

    const NumMergeStep = struct {
        part_index: usize,
        negate: bool,
        kind: enum { bind, read, placeholder },
        slot: u8,
        // A non-leftover part evaluates at match time (a bound read,
        // global, or call) rather than folding to a compile-time constant,
        // so the residual subtracts it with a MatchSubtractEval step.
        has_runtime_part: bool,
    };

    // A number merge steps when exactly one part is the leftover — a bind,
    // bound read, or placeholder, possibly under negations — and every
    // other part is a value the residual subtracts: a constant number
    // (folded), or a bound read, global, or call (evaluated per match). The
    // leftover is the residual after subtracting the rest. A negated
    // non-leftover part, a negated leftover paired with a runtime part, two
    // unknowns, or a non-numeric part keeps the plan path.
    fn classifyNumMergeStep(
        self: *Compiler,
        ast: *const Ast,
        ty: ?Ast.ValueType,
        parts: []const Ast.Part,
    ) ?NumMergeStep {
        _ = self;
        if ((ty orelse return null) != .number) return null;
        var found: ?NumMergeStep = null;
        var has_runtime = false;
        for (parts, 0..) |part, i| {
            var negate = false;
            const inner = switch (part) {
                .sub => |set_id| blk: {
                    const set = &ast.constraint_sets.items[set_id];
                    if (set.constraints.items.len != 1) return null;
                    switch (set.constraints.items[0].kind) {
                        .negated => |n| {
                            negate = n.count % 2 == 1;
                            break :blk n.part;
                        },
                        else => return null,
                    }
                },
                else => part,
            };
            switch (inner) {
                // Unbound parts must be the single leftover.
                .bind, .placeholder => {
                    if (found) |f| {
                        // A read already taken as the leftover demotes to a
                        // summed part when a genuine unbound appears.
                        if (f.kind != .read or f.negate) return null;
                        has_runtime = true;
                    }
                    found = switch (inner) {
                        .bind => |l| .{ .part_index = i, .negate = negate, .kind = .bind, .slot = l.slot, .has_runtime_part = false },
                        .placeholder => .{ .part_index = i, .negate = negate, .kind = .placeholder, .slot = 0, .has_runtime_part = false },
                        else => unreachable,
                    };
                },
                // A read is the leftover only until a genuine unbound part
                // claims that role; otherwise it is a summed runtime value.
                .read => |l| {
                    if (found == null) {
                        found = .{ .part_index = i, .negate = negate, .kind = .read, .slot = l.slot, .has_runtime_part = false };
                    } else {
                        if (negate) return null;
                        has_runtime = true;
                    }
                },
                // Summed value parts: constants fold, everything else
                // (calls, globals) evaluates at match time. Negation of a
                // summed part is unsupported inline.
                .expr => |node| {
                    if (negate) return null;
                    if (!constNumberNode(ast, node)) has_runtime = true;
                },
                .global => {
                    if (negate) return null;
                    has_runtime = true;
                },
                else => return null,
            }
        }
        var step = found orelse return null;
        // Negating the leftover flips the residual sign, which the runtime
        // subtraction chain does not express; keep it on the plan path.
        if (step.negate and has_runtime) return null;
        step.has_runtime_part = has_runtime;
        return step;
    }

    fn constNumberNode(ast: *const Ast, id: Ast.NodeId) bool {
        return switch (ast.goals.items[id].node) {
            .number_float, .number_string => true,
            .neg => |inner| constNumberNode(ast, inner),
            else => false,
        };
    }

    const BoolMergeStep = struct {
        part_index: usize,
        kind: enum { bind, read, placeholder },
        slot: u8,
        // The logical OR of every literal-bool part but the leftover.
        static_true: bool,
    };

    // A boolean merge steps when every part but one is a literal `true` or
    // `false` and the leftover is a bind, bound read, or placeholder.
    // Booleans merge by OR, so the leftover claims the residual
    // `scrutinee AND NOT static` (parts to its left claim first). Evaluated
    // parts, globals, and second unknowns keep the plan path, which folds
    // their runtime values into the claimed truth the same way.
    fn classifyBoolMergeStep(
        self: *Compiler,
        ast: *const Ast,
        ty: ?Ast.ValueType,
        parts: []const Ast.Part,
    ) ?BoolMergeStep {
        _ = self;
        if ((ty orelse return null) != .boolean) return null;
        var static_true = false;
        var found: ?BoolMergeStep = null;
        for (parts, 0..) |part, i| {
            switch (part) {
                .expr => |node| {
                    if (constBoolNode(ast, node)) |b| {
                        if (b) static_true = true;
                    } else return null;
                },
                .bind => |l| {
                    if (found != null) return null;
                    found = .{ .part_index = i, .kind = .bind, .slot = l.slot, .static_true = false };
                },
                .read => |l| {
                    if (found != null) return null;
                    found = .{ .part_index = i, .kind = .read, .slot = l.slot, .static_true = false };
                },
                .placeholder => {
                    if (found != null) return null;
                    found = .{ .part_index = i, .kind = .placeholder, .slot = 0, .static_true = false };
                },
                else => return null,
            }
        }
        if (found) |f| {
            return .{ .part_index = f.part_index, .kind = f.kind, .slot = f.slot, .static_true = static_true };
        }
        return null;
    }

    fn constBoolNode(ast: *const Ast, id: Ast.NodeId) ?bool {
        return switch (ast.goals.items[id].node) {
            .true => true,
            .false => false,
            else => null,
        };
    }

    // Whether any constraint is statically false: a negated part under a
    // non-number merge. Such an arm lowers to the bare fail tail.
    fn armAlwaysFails(self: *Compiler, ast: *const Ast, constraints: []const Ast.Constraint) bool {
        for (constraints) |constraint| switch (constraint.kind) {
            .solve_merge => |c| {
                if (self.mergeNegatedNonNumber(ast, c.ty, c.parts.items)) return true;
            },
            else => {},
        };
        return false;
    }

    // A negated part under a merge whose static type isn't number can
    // never match — negation only produces numbers — so the arm lowers
    // to an unconditional fail step.
    fn mergeNegatedNonNumber(self: *Compiler, ast: *const Ast, ty: ?Ast.ValueType, parts: []const Ast.Part) bool {
        _ = self;
        const merge_ty = ty orelse return false;
        if (merge_ty == .number) return false;
        for (parts) |part| switch (part) {
            .sub => |set_id| {
                const set = &ast.constraint_sets.items[set_id];
                if (set.constraints.items.len == 1 and set.constraints.items[0].kind == .negated) return true;
            },
            else => {},
        };
        return false;
    }

    // A pattern constant folded for step comparison: numbers fold to
    // floats the way the can plan lowering folds them.
    fn goalPatternConstElem(self: *Compiler, ast: *const Ast, id: Ast.NodeId) Error!Elem {
        return switch (ast.goals.items[id].node) {
            .string => |s| Elem.string(try self.vm.strings.insert(s)),
            .number_float => |f| Elem.numberFloat(f),
            .number_string => |ns| blk: {
                const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                break :blk elem.asNumberString().toNumberFloat(self.vm.strings);
            },
            .true => Elem.boolean(true),
            .false => Elem.boolean(false),
            .null => Elem.nullConst,
            .neg => |inner| blk: {
                const folded = try self.goalPatternConstElem(ast, inner);
                break :blk folded.negateNumber() catch return Error.NegatedNonNumber;
            },
            else => error.UnsupportedPattern,
        };
    }

    // A goal node that `goalPatternConstElem` folds to a constant elem.
    fn constPatternNode(self: *Compiler, ast: *const Ast, id: Ast.NodeId) bool {
        return switch (ast.goals.items[id].node) {
            .string, .number_float, .number_string, .true, .false, .null => true,
            .neg => |inner| self.constPatternNode(ast, inner),
            else => false,
        };
    }

    const TemplateKind = enum {
        // Path A: literals around exactly one bind/placeholder, ≤255
        // literal bytes — the static prefix/suffix/slice layout, no cursor
        // registers.
        static,
        // Path B: cursor registers chomp each segment; handles const-fold,
        // value, range, no-solvable, and structural-cast shapes.
        cursor,
    };

    // How one template segment part lowers to cursor-path steps.
    const TemplatePartKind = enum {
        // A constant expression: folds into the adjacent literal bytes.
        literal_fold,
        // A bound read or an evaluable call: evaluated, stringified, and
        // byte-compared (MatchStrVal). Never the solvable.
        value,
        // A character range sub-pattern: MatchStrChar + range test. Never
        // the solvable.
        char_range,
        // A bare binder or placeholder: the raw substring solvable.
        solvable_raw,
        // A structural sub-pattern cast from the byte range by its root
        // type. Handled in the cast phase; gated until then.
        solvable_cast,
        // Keeps the whole template on the plan path.
        gate,
    };

    fn templatePartKind(self: *Compiler, ast: *const Ast, part: Ast.Part) TemplatePartKind {
        return switch (part) {
            .placeholder, .bind => .solvable_raw,
            .read => .value,
            .expr => |id| if (self.constPatternNode(ast, id))
                .literal_fold
            else if (self.evalExprStepable(ast, id))
                .value
            else
                .gate,
            .sub => |set_id| if (templateRangeLimits(ast, set_id) != null)
                // A codepoint range compares one character in place; a
                // numeric range spans an unknown number of digits (and an
                // optional sign), so it casts the whole substring — the
                // solvable's byte range — to a number before the range test.
                (if (self.templateRangeNumeric(ast, set_id)) .solvable_cast else .char_range)
            else if (self.templateMergeSolvable(ast, set_id) != null)
                .solvable_cast
            else if (self.templateCastStepable(ast, set_id))
                .solvable_cast
            else
                // String-typed merges, object merges, and repeat segments
                // keep the plan path.
                .gate,
            // A global hole evaluates at match time (invoking a zero-arity
            // function) and compares like a bound read; a multi-arity
            // function global is rejected at emit, as the plan path does.
            .global => .value,
            .local => .gate,
        };
    }

    // Whether a template solvable sub-pattern is a number or boolean merge
    // castable to inline steps — a single solve_merge on place 0 accepted
    // by the merge-step classifier. Structural and untyped merges are null.
    fn templateMergeSolvable(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) ?enum { number, boolean } {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len != 1) return null;
        if (set.constraints.items.len != 1) return null;
        switch (set.constraints.items[0].kind) {
            .solve_merge => |c| {
                if (self.classifyNumMergeStep(ast, c.ty, c.parts.items) != null) return .number;
                if (self.classifyBoolMergeStep(ast, c.ty, c.parts.items) != null) return .boolean;
                return null;
            },
            else => return null,
        }
    }

    // Whether a template solvable sub-pattern is a structural array/object
    // cast lowerable to inline steps: the byte range parses as JSON by the
    // pattern's root type (an is_type array/object on place 0), and the
    // whole ConstraintSet steps. The parsed container feeds a child window
    // as its scrutinee, so the recursion is exactly a root arm's. Merges
    // (no root is_type), repeats, and non-stepable interiors stay null.
    fn templateCastStepable(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) bool {
        const set = &ast.constraint_sets.items[set_id];
        var root_container = false;
        for (set.constraints.items) |constraint| switch (constraint.kind) {
            .is_type => |c| if (c.place == 0 and (c.ty == .array or c.ty == .object)) {
                root_container = true;
            },
            else => {},
        };
        if (!root_container) return false;
        return self.constraintsStepable(ast, set.constraints.items);
    }

    // The lower/upper bounds of a template character-range sub-pattern —
    // exactly one place constrained by one in_range with step-encodable
    // bounds — or null when the sub-pattern isn't a plain range.
    fn templateRangeLimits(ast: *const Ast, set_id: Ast.SetId) ?struct { lower: Ast.Limit, upper: Ast.Limit } {
        const set = &ast.constraint_sets.items[set_id];
        if (set.places.items.len != 1) return null;
        if (set.constraints.items.len != 1) return null;
        switch (set.constraints.items[0].kind) {
            .in_range => |c| {
                if (c.place != 0) return null;
                return .{ .lower = c.lower, .upper = c.upper };
            },
            else => return null,
        }
    }

    // Whether a template range sub-pattern is a numeric range (integer
    // bounds) rather than a codepoint range (character bounds). A template
    // hole is always a substring, so a numeric range casts its decoded
    // codepoint to a number before the range test; a codepoint range
    // compares the character directly. Detected from a numeric literal
    // bound; a range with only runtime-valued bounds defaults to codepoint.
    fn templateRangeNumeric(self: *Compiler, ast: *const Ast, set_id: Ast.SetId) bool {
        const limits = templateRangeLimits(ast, set_id) orelse return false;
        return self.limitNumericLiteral(ast, limits.lower) or self.limitNumericLiteral(ast, limits.upper);
    }

    fn limitNumericLiteral(self: *Compiler, ast: *const Ast, limit: Ast.Limit) bool {
        const id = switch (limit) {
            .expr => |id| id,
            else => return false,
        };
        return switch (ast.goals.items[id].node) {
            .number_float, .number_string => true,
            .neg => |inner| self.limitNumericLiteral(ast, .{ .expr = inner }),
            else => false,
        };
    }

    // Whether a template destructure lowers to inline steps, and by which
    // strategy. Null keeps the plan path.
    fn templateStepable(self: *Compiler, ast: *const Ast, segments: []const Ast.Segment) ?TemplateKind {
        // Path A: the static layout — only literals plus exactly one
        // bind/placeholder, within the 255-byte literal cap.
        var specials: u32 = 0;
        var literal_bytes: usize = 0;
        var only_static = true;
        for (segments) |segment| switch (segment) {
            .literal => |s| literal_bytes += s.len,
            .part => |part| switch (part) {
                .bind, .placeholder => specials += 1,
                else => only_static = false,
            },
        };
        if (only_static and specials == 1 and literal_bytes <= 255) return .static;

        // Path B: every segment must be a fixed step or the single
        // solvable.
        var solvable_count: u32 = 0;
        for (segments) |segment| switch (segment) {
            .literal => {},
            .part => |part| switch (self.templatePartKind(ast, part)) {
                .literal_fold, .value, .char_range => {},
                .solvable_raw, .solvable_cast => solvable_count += 1,
                .gate => return null,
            },
        };
        if (solvable_count > 1) return null;
        return .cursor;
    }

    const RangeDescriptor = struct { kind: u8, arg: u16 };

    // Encode one range bound for the MatchInRange operand. A constant bound
    // is validated as a range bound at compile time; an evaluable bound is
    // reported through `eval_out` (its descriptor stays `.none`) so the
    // caller emits a MatchRangeBound step for it.
    fn rangeDescriptor(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        limit: Ast.Limit,
        region: Region,
        eval_out: *?Ast.NodeId,
    ) Error!RangeDescriptor {
        switch (limit) {
            .none => return .{ .kind = @intFromEnum(RangeLimitKind.none), .arg = 0 },
            .bind => |ls| return .{ .kind = @intFromEnum(RangeLimitKind.bind), .arg = ls.slot },
            .read => |ls| return .{ .kind = @intFromEnum(RangeLimitKind.read), .arg = ls.slot },
            .global => |name| {
                const global = self.resolveGlobal(module_id, name) orelse {
                    try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.pathString(name)});
                    return Error.UndefinedVariable;
                };
                if (global.isDynType(.Function) and global.asDyn().asFunction().arity != 0) {
                    return error.UnsupportedPattern;
                }
                const constant = try self.makeConstantU16(module_id, global, region);
                return .{ .kind = @intFromEnum(RangeLimitKind.global), .arg = constant };
            },
            .local => return error.UnsupportedPattern,
            .expr => |id| {
                if (self.constPatternNode(ast, id)) {
                    const elem = try self.goalPatternConstElem(ast, id);
                    if (!elem.isRangeBound(self.vm.*)) {
                        try self.printError(module_id, region, "Range bound must be an integer or codepoint", .{});
                        return Error.InvalidAst;
                    }
                    const constant = try self.makeConstantU16(module_id, elem, region);
                    return .{ .kind = @intFromEnum(RangeLimitKind.const_elem), .arg = constant };
                }
                eval_out.* = id;
                return .{ .kind = @intFromEnum(RangeLimitKind.none), .arg = 0 };
            },
        }
    }

    fn makeConstantU16(self: *Compiler, module_id: Module.Id, elem: Elem, region: Region) Error!u16 {
        const idx = try self.makeConstant(module_id, elem);
        if (idx > std.math.maxInt(u16)) {
            try self.printError(module_id, region, "Too many constants for match step.", .{});
            return Error.TooManyConstants;
        }
        return @intCast(idx);
    }

    // How a match's window slot 0 is loaded and where a mismatch goes.
    const StepScrutinee = union(enum) {
        // Root arm: the value under test is the value-stack top; an already
        // failed scrutinee skips the whole match, and a mismatch converges
        // on the arm's MatchFail tail.
        input,
        // Nested sub-pattern: slot 0 is copied from a register in the
        // enclosing window (MatchSubScrutinee) and matched in its own
        // window.
        sub: SubStep,
    };

    const SubStep = struct {
        // The enclosing-window register holding the value to match.
        src_reg: u8,
        // Where a mismatch goes after the window closes.
        on_fail: SubFail,
        // Whether the sub-pattern's binds bind fresh or compare against
        // already-bound locals (repeat chunks after the first).
        bind_mode: BindMode = .bind,
    };

    const SubFail = union(enum) {
        // Exit the window and loop back to a search's retry point to try
        // the next candidate.
        retry: Ir.Index,
        // Exit the window and fail the whole match: a forward jump is
        // appended to the arm's fail-jump list so it lands on MatchFail.
        arm: *ArrayList(Ir.Index),
    };

    const BindMode = enum { bind, compare };

    // Emit inline match steps for a lowered pattern: an already-open
    // scrutinee in window slot 0, tested and destructured by the
    // constraints against their places. Keyed on (places, constraints) so
    // the same code emits a root arm (match.places / arm.constraints) or a
    // nested sub-pattern's ConstraintSet.
    fn writeMatchSteps(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        places: []const Ast.PlaceDef,
        constraints: []const Ast.Constraint,
        scrutinee: StepScrutinee,
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        // Match scratch is addressed relative to the per-match window: each
        // place id is its own window slot (base 0), with the search, repeat,
        // and template pools allocated above.
        const scratch_base: u8 = 0;
        const dead_reg: u8 = @intCast(scratch_base + places.len);

        const materialized = try allocator.alloc(bool, places.len);
        defer allocator.free(materialized);
        @memset(materialized, false);

        // Lay out the search claim registers above the dead register: one
        // contiguous block per object place the arm searches, then a shared
        // value register and cursor register reused across pairs.
        var search_groups = ArrayList(SearchGroup){};
        defer search_groups.deinit(allocator);
        for (constraints) |constraint| switch (constraint.kind) {
            .search_key => |c| {
                if (self.findSearchGroup(search_groups.items, c.place)) |g| {
                    g.count += 1;
                } else {
                    try search_groups.append(allocator, .{ .src = c.place, .base = 0, .count = 1 });
                }
            },
            else => {},
        };
        var claim_next: u8 = dead_reg + 1;
        for (search_groups.items) |*group| {
            group.base = claim_next;
            claim_next += group.count;
        }
        const value_reg = claim_next;
        const cursor_reg = claim_next + 1;
        // The repeat block holds a repeat's derived count or solved chunk
        // while its tests and binds run, plus the loop base and the
        // materialized-chunk register for array-chunk repeats; repeats in
        // one arm reuse it sequentially. It sits above the search block
        // when one exists.
        const repeat_reg: u8 = if (search_groups.items.len > 0) cursor_reg + 1 else claim_next;
        const repeat_base_reg = repeat_reg + 1;
        const repeat_chunk_reg = repeat_reg + 2;
        // Save/restore rather than clear: a nested sub-pattern's
        // writeMatchSteps runs mid-emission of the parent, whose later rest
        // ops still need the parent's groups.
        const prev_search_groups = self.arm_search_groups;
        self.arm_search_groups = search_groups.items;
        defer self.arm_search_groups = prev_search_groups;

        // The template block sits above the repeat block: front and end
        // cursors, the rest destination, and a character register for
        // range segments. Its size mirrors armStepScratchWidth's accounting.
        var repeat_block: u8 = 0;
        for (constraints) |constraint| switch (constraint.kind) {
            .solve_repeat => |c| {
                const shape = self.repeatShape(ast, c.pattern, c.count).?;
                repeat_block = @max(repeat_block, @as(u8, if (shape == .array) 3 else 1));
            },
            else => {},
        };
        const template_front = repeat_reg + repeat_block;
        const template_end = template_front + 1;
        const template_rest = template_front + 2;
        const template_char = template_front + 3;

        var fail_jumps = ArrayList(Ir.Index){};
        defer fail_jumps.deinit(allocator);

        // An already-failed scrutinee skips the steps and stays the result,
        // like DestructurePlan's success check. Only a root arm sees the
        // value-stack input; a nested sub-pattern's scrutinee is a member
        // register that a prior test already accepted.
        const skipJump: ?Ir.Index = switch (scrutinee) {
            .input => try self.emitJump(.JumpIfFailure, region),
            .sub => null,
        };

        // A statically false constraint is just the fail path; emitting
        // steps after an unconditional fail jump would leave them
        // unreachable. No window is open here, so the fail path needs no
        // window exit.
        if (self.armAlwaysFails(ast, constraints)) {
            switch (scrutinee) {
                .input => {
                    try self.emitOp(.MatchFail, region);
                    self.patchJump(skipJump.?);
                },
                .sub => |s| switch (s.on_fail) {
                    .retry => |target| try self.emitJumpBack(.JumpBack, target, region),
                    .arm => |arm_fails| try arm_fails.append(allocator, try self.emitJump(.Jump, region)),
                },
            }
            return;
        }

        // Open the per-match window sized to this arm's scratch. A root
        // arm's skip path jumps past the whole match, so no window is open
        // there; success and failure both converge on the MatchWindowExit
        // emitted after the steps.
        const width = self.armStepScratchWidth(ast, places, constraints);
        if (width > 255) {
            try self.printError(module_id, region, "Pattern too large to compile.", .{});
            return Error.MaxFunctionLocals;
        }
        try self.emitUnaryOp(.MatchWindowEnter, @intCast(width), region);

        switch (scrutinee) {
            .input => try self.emitUnaryOp(.MatchScrutinee, scratch_base, region),
            .sub => |s| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchSubScrutinee,
                .byte1 = scratch_base,
                .byte2 = s.src_reg,
            } }, region),
        }
        materialized[0] = true;

        // In compare mode a bind reuses an already-bound local as a test
        // (repeat chunks after the first must agree with the first).
        const bind_mode: BindMode = switch (scrutinee) {
            .input => .bind,
            .sub => |s| s.bind_mode,
        };

        for (constraints) |constraint| {
            const step_region = constraint.region;
            switch (constraint.kind) {
                .is_type => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const ty: u8 = switch (c.ty) {
                        .array => 0,
                        .object => 1,
                        .string => 2,
                        else => unreachable,
                    };
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                        .op = .MatchType,
                        .byte1 = scratch_base + @as(u8, @intCast(c.place)),
                        .byte2 = ty,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .len_eq => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_count = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .n = @intCast(c.len),
                        .mode = 0,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .len_min => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_count = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .n = @intCast(c.len),
                        .mode = 1,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .str_prefix => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const sid = try self.vm.strings.insert(c.literal);
                    const constant = try self.makeConstantU16(module_id, Elem.string(sid), step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                        .op = .MatchStrPrefix,
                        .byte1 = scratch_base + @as(u8, @intCast(c.place)),
                        .constant = constant,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .str_suffix => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const sid = try self.vm.strings.insert(c.literal);
                    const constant = try self.makeConstantU16(module_id, Elem.string(sid), step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                        .op = .MatchStrSuffix,
                        .byte1 = scratch_base + @as(u8, @intCast(c.place)),
                        .constant = constant,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .keys_exact => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_count = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .n = @intCast(c.count),
                        .mode = 0,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .keys_min => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_count = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .n = @intCast(c.count),
                        .mode = 1,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .has_key => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const sid = try self.vm.strings.insert(self.frontend.strings.get(c.sid));
                    const constant = try self.makeConstantU16(module_id, Elem.string(sid), step_region);
                    var dst = dead_reg;
                    for (places, 0..) |def, i| switch (def) {
                        .key => |k| if (k.src == c.place and k.sid == c.sid) {
                            dst = scratch_base + @as(u8, @intCast(i));
                            materialized[i] = true;
                        },
                        else => {},
                    };
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                        .op = .MatchKey,
                        .byte1 = dst,
                        .byte2 = scratch_base + @as(u8, @intCast(c.place)),
                        .constant = constant,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .eq_const => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const elem = try self.goalPatternConstElem(ast, c.value);
                    const constant = try self.makeConstantU16(module_id, elem, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .kind = .constant,
                        .arg = constant,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .eq_global => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const reg = scratch_base + @as(u8, @intCast(c.place));
                    try fail_jumps.append(allocator, try self.emitEqGlobalStep(module_id, c.name, reg, step_region));
                },
                .bind => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    switch (bind_mode) {
                        .bind => _ = try self.ir().push(allocator, .{ .match_bytes = .{
                            .op = .MatchBind,
                            .byte1 = c.slot,
                            .byte2 = scratch_base + @as(u8, @intCast(c.place)),
                        } }, step_region),
                        // Compare against the value the first chunk bound.
                        .compare => try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                            .reg = scratch_base + @as(u8, @intCast(c.place)),
                            .kind = .slot,
                            .arg = c.slot,
                            .target = Ir.unpatched_jump,
                        } }, step_region)),
                    }
                },
                .eq_slot => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                        .reg = scratch_base + @as(u8, @intCast(c.place)),
                        .kind = .slot,
                        .arg = c.slot,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                // Evaluate the expression (a call, mirroring the plan's
                // eval_eq) and compare its result against the place. Every
                // read in the expression is bound by an earlier scheduled
                // step, so the value compiles like any value position.
                .eval_eq => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try self.writeGoal(module_id, ast, c.expr);
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                        .op = .MatchEval,
                        .byte1 = scratch_base + @as(u8, @intCast(c.place)),
                        .byte2 = 0,
                        .target = Ir.unpatched_jump,
                    } }, step_region));
                },
                .in_range => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const reg = scratch_base + @as(u8, @intCast(c.place));
                    try self.emitInRangeStep(module_id, ast, reg, c.lower, c.upper, &fail_jumps, step_region);
                },
                .negated => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const reg = scratch_base + @as(u8, @intCast(c.place));
                    try self.emitNegatedStep(module_id, ast, c.count, c.part, reg, dead_reg, &fail_jumps, step_region);
                },
                .match_template => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const reg = scratch_base + @as(u8, @intCast(c.place));
                    switch (self.templateStepable(ast, c.segments.items).?) {
                        .static => try self.emitTemplateStatic(module_id, c.segments.items, reg, dead_reg, &fail_jumps, step_region),
                        .cursor => try self.emitTemplateCursor(
                            module_id,
                            ast,
                            c.segments.items,
                            reg,
                            .{ .front = template_front, .end = template_end, .rest = template_rest, .char = template_char },
                            dead_reg,
                            &fail_jumps,
                            step_region,
                        ),
                    }
                },
                .solve_merge => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    try self.emitMergeSolve(module_id, ast, c.ty, c.parts.items, scratch_base + @as(u8, @intCast(c.place)), dead_reg, false, &fail_jumps, step_region);
                },
                .search_key => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const src_reg = scratch_base + @as(u8, @intCast(c.place));
                    const group = self.findSearchGroup(search_groups.items, c.place).?;
                    const my_index = group.emitted;
                    group.emitted += 1;
                    const key_dst = group.base + my_index;

                    // Members matched by const-key pairs are claimed via
                    // the key-list constant, whichever order the pairs
                    // were written in; pairs claim their found keys into
                    // the claim registers for later pairs and the rest.
                    const constant = try self.hasKeyListConstant(module_id, constraints, c.place, step_region);

                    const bound_key: ?u8 = if (singleSetConstraint(ast, c.key)) |kc| switch (kc.kind) {
                        .eq_slot => |s| s.slot,
                        else => null,
                    } else null;

                    if (bound_key) |slot| {
                        // A known key probes its member directly; a value
                        // test failure fails the arm since no other
                        // member can carry this key.
                        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_key_bound = .{
                            .op = .MatchKeyBound,
                            .key_dst = key_dst,
                            .val_dst = value_reg,
                            .src = src_reg,
                            .slot = slot,
                            .claim_count = my_index,
                            .constant = constant,
                            .target = Ir.unpatched_jump,
                        } }, step_region));
                        if (try self.emitSearchTest(module_id, ast, c.value, value_reg, step_region)) |fail_idx| {
                            try fail_jumps.append(allocator, fail_idx);
                        }
                        try self.emitSearchBind(ast, c.value, value_reg, step_region);
                        continue;
                    }

                    // An unknown key scans for the first unclaimed member
                    // the value pattern accepts; a value that can fail
                    // loops back to try the next member.
                    try self.emitUnaryOp(.MatchSearchInit, cursor_reg, step_region);
                    const loop = self.ir().nextIndex();
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_search = .{
                        .op = .MatchNextUnclaimed,
                        .key_dst = key_dst,
                        .val_dst = value_reg,
                        .src = src_reg,
                        .cursor = cursor_reg,
                        .claim_count = my_index,
                        .constant = constant,
                        .target = Ir.unpatched_jump,
                    } }, step_region));

                    if (!self.searchSetStepable(ast, c.value, false)) {
                        // A structural value matches in a nested window
                        // scrutinized by the found member; a rejected
                        // candidate exits that window and loops back. The
                        // key binds only once the value matched.
                        const value_set = &ast.constraint_sets.items[c.value];
                        try self.writeMatchSteps(module_id, ast, value_set.places.items, value_set.constraints.items, .{ .sub = .{ .src_reg = value_reg, .on_fail = .{ .retry = loop } } }, step_region);
                        try self.emitSearchBind(ast, c.key, key_dst, step_region);
                        continue;
                    }

                    // Tests before binds: a member the pair rejects loops
                    // to the next candidate without touching any slot.
                    const value_fail = try self.emitSearchTest(module_id, ast, c.value, value_reg, step_region);
                    try self.emitSearchBind(ast, c.key, key_dst, step_region);
                    try self.emitSearchBind(ast, c.value, value_reg, step_region);

                    if (value_fail) |fail_idx| {
                        const okJump = try self.emitJump(.Jump, step_region);
                        self.patchJump(fail_idx);
                        try self.emitJumpBack(.JumpBack, loop, step_region);
                        self.patchJump(okJump);
                    }
                },
                .solve_repeat => |c| {
                    try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, c.place, step_region);
                    const src_reg = scratch_base + @as(u8, @intCast(c.place));
                    switch (self.repeatShape(ast, c.pattern, c.count).?) {
                        // A known pattern: push its value, derive the
                        // count from the place's value, and test the
                        // count operand against the derived count.
                        .value => {
                            try self.writeRepeatOperand(module_id, ast, c.pattern, step_region);
                            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                                .op = .MatchRepeatValue,
                                .byte1 = src_reg,
                                .byte2 = repeat_reg,
                                .target = Ir.unpatched_jump,
                            } }, step_region));
                            try self.emitRepeatCountSteps(module_id, ast, c.count, repeat_reg, &fail_jumps, step_region);
                        },
                        // A codepoint range: scan the string, derive the
                        // codepoint count, and test the count operand
                        // against it.
                        .range => {
                            const range_constraint = self.repeatRangeConstraint(ast, c.pattern.sub).?;
                            const rc = range_constraint.kind.in_range;
                            var lower_eval: ?Ast.NodeId = null;
                            var upper_eval: ?Ast.NodeId = null;
                            const lower_desc = try self.rangeDescriptor(module_id, ast, rc.lower, step_region, &lower_eval);
                            const upper_desc = try self.rangeDescriptor(module_id, ast, rc.upper, step_region, &upper_eval);
                            std.debug.assert(lower_eval == null and upper_eval == null);
                            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_repeat_range = .{
                                .op = .MatchRepeatRange,
                                .src = src_reg,
                                .dst = repeat_reg,
                                .lower_kind = lower_desc.kind,
                                .lower_arg = lower_desc.arg,
                                .upper_kind = upper_desc.kind,
                                .upper_arg = upper_desc.arg,
                                .target = Ir.unpatched_jump,
                            } }, step_region));
                            try self.emitRepeatCountSteps(module_id, ast, c.count, repeat_reg, &fail_jumps, step_region);
                        },
                        // A fixed-length array sub-pattern: derive the
                        // chunk count from the length, test the count
                        // operand, then match each chunk in a loop. Each
                        // chunk is materialized and matched in its own
                        // window like any array/object pattern; the first
                        // iteration binds and later iterations compare
                        // against those binds (the static form of the
                        // plan's has_rebound_pattern re-lowering), enforcing
                        // that every chunk is identical.
                        .array => {
                            const chunk_set = &ast.constraint_sets.items[c.pattern.sub];
                            const sub_len = repeatArrayLen(ast, c.pattern.sub).?;
                            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_repeat_init = .{
                                .op = .MatchRepeatInit,
                                .src = src_reg,
                                .len = @intCast(sub_len),
                                .count_dst = repeat_reg,
                                .base = repeat_base_reg,
                                .target = Ir.unpatched_jump,
                            } }, step_region));
                            try self.emitRepeatCountSteps(module_id, ast, c.count, repeat_reg, &fail_jumps, step_region);

                            // A chunk with no constrained elements (all
                            // placeholders, like Array.length's [_] * L)
                            // needs no loop: the length check is the
                            // whole match.
                            if (!repeatChunkNeedsLoop(ast, c.pattern.sub)) continue;

                            const first_next = try self.ir().push(allocator, .{ .match_repeat_next = .{
                                .op = .MatchRepeatNext,
                                .src = src_reg,
                                .base = repeat_base_reg,
                                .len = @intCast(sub_len),
                                .chunk_dst = repeat_chunk_reg,
                                .target = Ir.unpatched_jump,
                            } }, step_region);
                            try self.writeMatchSteps(module_id, ast, chunk_set.places.items, chunk_set.constraints.items, .{ .sub = .{ .src_reg = repeat_chunk_reg, .on_fail = .{ .arm = &fail_jumps }, .bind_mode = .bind } }, step_region);

                            const loop_head = self.ir().nextIndex();
                            const loop_next = try self.ir().push(allocator, .{ .match_repeat_next = .{
                                .op = .MatchRepeatNext,
                                .src = src_reg,
                                .base = repeat_base_reg,
                                .len = @intCast(sub_len),
                                .chunk_dst = repeat_chunk_reg,
                                .target = Ir.unpatched_jump,
                            } }, step_region);
                            try self.writeMatchSteps(module_id, ast, chunk_set.places.items, chunk_set.constraints.items, .{ .sub = .{ .src_reg = repeat_chunk_reg, .on_fail = .{ .arm = &fail_jumps }, .bind_mode = .compare } }, step_region);
                            try self.emitJumpBack(.JumpBack, loop_head, step_region);

                            self.patchJump(first_next);
                            self.patchJump(loop_next);
                        },
                        // A bare binder: push the known count, solve the
                        // representative chunk, and bind it.
                        .chunk => {
                            try self.writeRepeatOperand(module_id, ast, c.count, step_region);
                            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                                .op = .MatchRepeatChunk,
                                .byte1 = src_reg,
                                .byte2 = repeat_reg,
                                .target = Ir.unpatched_jump,
                            } }, step_region));
                            switch (c.pattern) {
                                .bind => |ls| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                                    .op = .MatchBind,
                                    .byte1 = ls.slot,
                                    .byte2 = repeat_reg,
                                } }, step_region),
                                .placeholder => {},
                                else => unreachable,
                            }
                        },
                    }
                },
                else => unreachable,
            }
        }

        if (fail_jumps.items.len == 0) {
            // Every step was deterministic; there is no failure path.
            // Success falls through to the window exit.
            try self.emitOp(.MatchWindowExit, region);
            if (skipJump) |j| self.patchJump(j);
            return;
        }
        const okJump = try self.emitJump(.Jump, region);
        for (fail_jumps.items) |jumpIndex| self.patchJump(jumpIndex);
        switch (scrutinee) {
            .input => {
                try self.emitOp(.MatchFail, region);
                // Both success (okJump) and failure (fall-through from
                // MatchFail) run the window exit; the skip lands past it
                // with no window open.
                self.patchJump(okJump);
                try self.emitOp(.MatchWindowExit, region);
                self.patchJump(skipJump.?);
            },
            .sub => |s| {
                // Failure closes this window then routes per the fail
                // disposition; success closes it and falls through to the
                // parent's continuation.
                try self.emitOp(.MatchWindowExit, region);
                switch (s.on_fail) {
                    // A rejected search candidate loops back for the next
                    // member.
                    .retry => |target| try self.emitJumpBack(.JumpBack, target, region),
                    // A rejected chunk fails the whole match: jump to the
                    // arm's shared fail tail.
                    .arm => |arm_fails| try arm_fails.append(allocator, try self.emitJump(.Jump, region)),
                }
                self.patchJump(okJump);
                try self.emitOp(.MatchWindowExit, region);
            },
        }
    }

    fn findSearchGroup(self: *Compiler, groups: []SearchGroup, src: Ast.PlaceId) ?*SearchGroup {
        _ = self;
        for (groups) |*group| {
            if (group.src == src) return group;
        }
        return null;
    }

    // The statically matched keys of an object place — every has_key on
    // the place — as an array constant for the ops that treat those
    // members as claimed: MatchNextUnclaimed skips them and the rest ops
    // subtract them.
    fn hasKeyListConstant(
        self: *Compiler,
        module_id: Module.Id,
        constraints: []const Ast.Constraint,
        place: Ast.PlaceId,
        region: Region,
    ) Error!u16 {
        var key_count: usize = 0;
        for (constraints) |constraint| switch (constraint.kind) {
            .has_key => |c| if (c.place == place) {
                key_count += 1;
            },
            else => {},
        };
        const keys = try Elem.DynElem.Array.create(self.vm, key_count);
        try self.vm.pushTempDyn(&keys.dyn);
        for (constraints) |constraint| switch (constraint.kind) {
            .has_key => |c| if (c.place == place) {
                const sid = try self.vm.strings.insert(self.frontend.strings.get(c.sid));
                keys.elems.appendAssumeCapacity(Elem.string(sid));
            },
            else => {},
        };
        const constant = try self.makeConstantU16(module_id, keys.dyn.elem(), region);
        self.vm.dropTempDyn();
        return constant;
    }

    fn singleSetConstraint(ast: *const Ast, set_id: Ast.SetId) ?*const Ast.Constraint {
        const set = &ast.constraint_sets.items[set_id];
        if (set.constraints.items.len == 0) return null;
        return &set.constraints.items[0];
    }

    // Emit a search sub-pattern's leaf test against reg. Returns the
    // fail-jump index for a semidet test, or null when the sub-pattern
    // always matches (a bind or placeholder). armStepable admits only
    // these kinds.
    fn emitSearchTest(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        set_id: Ast.SetId,
        reg: u8,
        region: Region,
    ) Error!?Ir.Index {
        const allocator = self.vm.allocator;
        const constraint = singleSetConstraint(ast, set_id) orelse return null;
        switch (constraint.kind) {
            .bind => return null,
            .eq_const => |c| {
                const elem = try self.goalPatternConstElem(ast, c.value);
                const constant = try self.makeConstantU16(module_id, elem, region);
                return try self.ir().push(allocator, .{ .match_cmp = .{
                    .reg = reg,
                    .kind = .constant,
                    .arg = constant,
                    .target = Ir.unpatched_jump,
                } }, region);
            },
            .eq_slot => |c| {
                return try self.ir().push(allocator, .{ .match_cmp = .{
                    .reg = reg,
                    .kind = .slot,
                    .arg = c.slot,
                    .target = Ir.unpatched_jump,
                } }, region);
            },
            .eq_global => |c| {
                return try self.emitEqGlobalStep(module_id, c.name, reg, region);
            },
            else => unreachable,
        }
    }

    // Bind a search sub-pattern's slot from reg (or nothing for a test or
    // placeholder). The register already holds the found key or value.
    fn emitSearchBind(
        self: *Compiler,
        ast: *const Ast,
        set_id: Ast.SetId,
        reg: u8,
        region: Region,
    ) Error!void {
        const constraint = singleSetConstraint(ast, set_id) orelse return;
        switch (constraint.kind) {
            .bind => |c| _ = try self.ir().push(self.vm.allocator, .{ .match_bytes = .{
                .op = .MatchBind,
                .byte1 = c.slot,
                .byte2 = reg,
            } }, region),
            else => {},
        }
    }

    // Push a repeat operand's value onto the stack for the repeat step
    // to pop: a constant expression or a bound local read. repeatShape
    // admits only these.
    fn writeRepeatOperand(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        part: Ast.Part,
        region: Region,
    ) Error!void {
        switch (part) {
            .expr => |id| try self.writeGoal(module_id, ast, id),
            .read => |ls| try self.emitUnaryOp(.GetLocal, ls.slot, region),
            else => unreachable,
        }
    }

    // Test the derived repeat count in `reg` against the count operand:
    // nothing for a placeholder, a bind or comparison for locals,
    // constant equality, or a single-place count sub-set of leaf tests.
    // repeatCountStepable admits exactly these shapes.
    fn emitRepeatCountSteps(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        count: Ast.Part,
        reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        switch (count) {
            .placeholder => {},
            .bind => |ls| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchBind,
                .byte1 = ls.slot,
                .byte2 = reg,
            } }, region),
            .read => |ls| try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                .reg = reg,
                .kind = .slot,
                .arg = ls.slot,
                .target = Ir.unpatched_jump,
            } }, region)),
            .expr => |id| try self.emitRepeatCountConst(module_id, ast, id, reg, fail_jumps, region),
            .sub => |set_id| {
                const set = &ast.constraint_sets.items[set_id];
                for (set.constraints.items) |constraint| switch (constraint.kind) {
                    .eq_const => |c| try self.emitRepeatCountConst(module_id, ast, c.value, reg, fail_jumps, region),
                    .bind => |c| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                        .op = .MatchBind,
                        .byte1 = c.slot,
                        .byte2 = reg,
                    } }, region),
                    .eq_slot => |c| try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                        .reg = reg,
                        .kind = .slot,
                        .arg = c.slot,
                        .target = Ir.unpatched_jump,
                    } }, region)),
                    .in_range => |c| try self.emitInRangeStep(module_id, ast, reg, c.lower, c.upper, fail_jumps, region),
                    else => unreachable,
                };
            },
            .local, .global => unreachable,
        }
    }

    fn emitRepeatCountConst(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        id: Ast.NodeId,
        reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const elem = try self.goalPatternConstElem(ast, id);
        const constant = try self.makeConstantU16(module_id, elem, region);
        try fail_jumps.append(self.vm.allocator, try self.ir().push(self.vm.allocator, .{ .match_cmp = .{
            .reg = reg,
            .kind = .constant,
            .arg = constant,
            .target = Ir.unpatched_jump,
        } }, region));
    }

    // Emit the residual steps of a number or boolean merge rooted at
    // `src_reg`: the leftover part claims `src_reg` minus the folded
    // constants (MatchMergeNum/Bool into dead_reg), then binds or compares.
    // Shared by arm-level solve_merge and template number/boolean casts.
    fn emitMergeSolve(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        ty: ?Ast.ValueType,
        parts: []const Ast.Part,
        src_reg: u8,
        dead_reg: u8,
        // The source register is a proven number (a template MatchCast to
        // number ran first). Enables the `0 + leftover` identity shortcut, which
        // otherwise would skip the number-type check MatchMergeNum performs.
        src_is_number: bool,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        if (self.classifyBoolMergeStep(ast, ty, parts)) |step| {
            const constant = try self.makeConstantU16(module_id, Elem.boolean(step.static_true), region);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                .op = .MatchMergeBool,
                .byte1 = dead_reg,
                .byte2 = src_reg,
                .constant = constant,
                .target = Ir.unpatched_jump,
            } }, region));
            switch (step.kind) {
                .bind => _ = try self.ir().push(allocator, .{ .match_bytes = .{
                    .op = .MatchBind,
                    .byte1 = step.slot,
                    .byte2 = dead_reg,
                } }, region),
                // A static-true claim already forced the scrutinee true and
                // leaves the read unconstrained (`true OR L` holds for any
                // L); only a static-false claim verifies L equals the
                // residual scrutinee.
                .read => if (!step.static_true) {
                    try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                        .reg = dead_reg,
                        .kind = .slot,
                        .arg = step.slot,
                        .target = Ir.unpatched_jump,
                    } }, region));
                },
                .placeholder => {},
            }
            return;
        }
        const step = self.classifyNumMergeStep(ast, ty, parts).?;
        if (step.has_runtime_part) {
            try self.emitNumMergeRuntime(module_id, ast, parts, step, src_reg, dead_reg, fail_jumps, region);
            return;
        }
        var sum: f64 = 0;
        for (parts, 0..) |part, i| {
            if (i == step.part_index) continue;
            const elem = try self.goalPatternConstElem(ast, part.expr);
            sum += elem.asFloat();
        }
        // `0 + leftover` (no negation) is the identity: the leftover equals
        // the scrutinee. Bind or compare it directly instead of recomputing
        // a float, so a NumberString keeps its exact text (json numbers like
        // "123e65" round-trip). This mirrors the plan's value.merge(-0).
        if (src_is_number and sum == 0 and !step.negate) {
            switch (step.kind) {
                .bind => _ = try self.ir().push(allocator, .{ .match_bytes = .{
                    .op = .MatchBind,
                    .byte1 = step.slot,
                    .byte2 = src_reg,
                } }, region),
                .read => try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                    .reg = src_reg,
                    .kind = .slot,
                    .arg = step.slot,
                    .target = Ir.unpatched_jump,
                } }, region)),
                .placeholder => {},
            }
            return;
        }
        const constant = try self.makeConstantU16(module_id, Elem.numberFloat(sum), region);
        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
            .op = if (step.negate) OpCode.MatchMergeNumNeg else OpCode.MatchMergeNum,
            .byte1 = dead_reg,
            .byte2 = src_reg,
            .constant = constant,
            .target = Ir.unpatched_jump,
        } }, region));
        switch (step.kind) {
            .bind => _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchBind,
                .byte1 = step.slot,
                .byte2 = dead_reg,
            } }, region),
            .read => try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                .reg = dead_reg,
                .kind = .slot,
                .arg = step.slot,
                .target = Ir.unpatched_jump,
            } }, region)),
            .placeholder => {},
        }
    }

    // The residual of a number merge whose non-leftover parts include a
    // runtime value (a bound read, global, or call): fold the constant
    // parts and subtract them (MatchMergeNum, which also gates src as a
    // number), then subtract each runtime part in turn (MatchSubtractEval)
    // into dead_reg, and bind or compare the leftover against it.
    fn emitNumMergeRuntime(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        parts: []const Ast.Part,
        step: NumMergeStep,
        src_reg: u8,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        var const_sum: f64 = 0;
        for (parts, 0..) |part, i| {
            if (i == step.part_index) continue;
            switch (part) {
                .expr => |id| if (constNumberNode(ast, id)) {
                    const elem = try self.goalPatternConstElem(ast, id);
                    const_sum += elem.asFloat();
                },
                else => {},
            }
        }
        const constant = try self.makeConstantU16(module_id, Elem.numberFloat(const_sum), region);
        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
            .op = .MatchMergeNum,
            .byte1 = dead_reg,
            .byte2 = src_reg,
            .constant = constant,
            .target = Ir.unpatched_jump,
        } }, region));
        for (parts, 0..) |part, i| {
            if (i == step.part_index) continue;
            const is_const = switch (part) {
                .expr => |id| constNumberNode(ast, id),
                else => false,
            };
            if (is_const) continue;
            try self.emitEvaluablePartValue(module_id, ast, part, region);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                .op = .MatchSubtractEval,
                .byte1 = dead_reg,
                .byte2 = dead_reg,
                .target = Ir.unpatched_jump,
            } }, region));
        }
        switch (step.kind) {
            .bind => _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchBind,
                .byte1 = step.slot,
                .byte2 = dead_reg,
            } }, region),
            .read => try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                .reg = dead_reg,
                .kind = .slot,
                .arg = step.slot,
                .target = Ir.unpatched_jump,
            } }, region)),
            .placeholder => {},
        }
    }

    const TemplateRegs = struct { front: u8, end: u8, rest: u8, char: u8 };

    // Path A: the static prefix/suffix/slice layout — literals around
    // exactly one bind/placeholder within the 255-byte cap. No cursors.
    fn emitTemplateStatic(
        self: *Compiler,
        module_id: Module.Id,
        segments: []const Ast.Segment,
        reg: u8,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        var prefix = ArrayList(u8){};
        defer prefix.deinit(allocator);
        var suffix = ArrayList(u8){};
        defer suffix.deinit(allocator);
        var special: ?Ast.Part = null;
        for (segments) |segment| switch (segment) {
            .literal => |s| if (special == null)
                try prefix.appendSlice(allocator, s)
            else
                try suffix.appendSlice(allocator, s),
            .part => |part| special = part,
        };

        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
            .op = .MatchType,
            .byte1 = reg,
            .byte2 = 2,
            .target = Ir.unpatched_jump,
        } }, region));
        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_count = .{
            .reg = reg,
            .n = @intCast(prefix.items.len + suffix.items.len),
            .mode = 1,
            .target = Ir.unpatched_jump,
        } }, region));
        if (prefix.items.len > 0) {
            const sid = try self.vm.strings.insert(prefix.items);
            const constant = try self.makeConstantU16(module_id, Elem.string(sid), region);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                .op = .MatchStrPrefix,
                .byte1 = reg,
                .constant = constant,
                .target = Ir.unpatched_jump,
            } }, region));
        }
        if (suffix.items.len > 0) {
            const sid = try self.vm.strings.insert(suffix.items);
            const constant = try self.makeConstantU16(module_id, Elem.string(sid), region);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                .op = .MatchStrSuffix,
                .byte1 = reg,
                .constant = constant,
                .target = Ir.unpatched_jump,
            } }, region));
        }
        if (special.? == .bind) {
            _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchSlice,
                .byte1 = dead_reg,
                .byte2 = reg,
                .byte3 = @intCast(prefix.items.len),
                .byte4 = @intCast(suffix.items.len),
            } }, region);
            _ = try self.ir().push(allocator, .{ .match_bytes = .{
                .op = .MatchBind,
                .byte1 = special.?.bind.slot,
                .byte2 = dead_reg,
            } }, region);
        }
    }

    const EffSeg = union(enum) {
        // A run of literal bytes (adjacent literals and folded constants),
        // already interned as a string constant.
        lit: u16,
        // An evaluated value segment: a bound read or a call.
        value: Ast.Part,
        // A character-range segment: the sub-set holding the in_range.
        char_range: Ast.SetId,
        // The one bind/placeholder solvable.
        solvable: Ast.Part,
    };

    // Path B: cursor-register chomping. `front`/`end` cursors bound each
    // segment; before-segments chomp the front forward, after-segments the
    // end backward (reverse order), and the gap between them is the
    // solvable's raw substring (or the whole coverage check when there is
    // no solvable). Parity with matchStringTemplate.
    fn emitTemplateCursor(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        segments: []const Ast.Segment,
        reg: u8,
        regs: TemplateRegs,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;

        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
            .op = .MatchType,
            .byte1 = reg,
            .byte2 = 2,
            .target = Ir.unpatched_jump,
        } }, region));

        // Normalize segments: fold constants into adjacent literal runs
        // (interned eagerly) and classify the rest.
        var effs = ArrayList(EffSeg){};
        defer effs.deinit(allocator);
        var lit = ArrayList(u8){};
        defer lit.deinit(allocator);
        var solvable_index: ?usize = null;

        for (segments) |segment| switch (segment) {
            .literal => |s| try lit.appendSlice(allocator, s),
            .part => |part| switch (self.templatePartKind(ast, part)) {
                .literal_fold => {
                    const elem = try self.goalPatternConstElem(ast, part.expr);
                    const str = try elem.toString(self.vm);
                    const bytes = (try str.stringBytes(self.vm)).?;
                    try lit.appendSlice(allocator, bytes);
                },
                .value => {
                    try self.flushTemplateLit(module_id, &effs, &lit, region);
                    try effs.append(allocator, .{ .value = part });
                },
                .char_range => {
                    try self.flushTemplateLit(module_id, &effs, &lit, region);
                    try effs.append(allocator, .{ .char_range = part.sub });
                },
                .solvable_raw, .solvable_cast => {
                    try self.flushTemplateLit(module_id, &effs, &lit, region);
                    solvable_index = effs.items.len;
                    try effs.append(allocator, .{ .solvable = part });
                },
                .gate => unreachable,
            },
        };
        try self.flushTemplateLit(module_id, &effs, &lit, region);

        // Whole-string template: the solvable is the only segment, so front
        // is 0 and end is the byte length by construction. The cursors and
        // the rest substring are pure overhead — the source value is the
        // rest — so skip MatchStrInit/MatchStrRest and act on reg directly.
        if (solvable_index != null and solvable_index.? == 0 and effs.items.len == 1) {
            switch (effs.items[0].solvable) {
                .bind => |ls| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                    .op = .MatchBind,
                    .byte1 = ls.slot,
                    .byte2 = reg,
                } }, region),
                .placeholder => {},
                .sub => |set_id| try self.emitTemplateSubCast(module_id, ast, set_id, reg, regs.rest, dead_reg, fail_jumps, region),
                else => unreachable,
            }
            return;
        }

        _ = try self.ir().push(allocator, .{ .match_str_init = .{
            .op = .MatchStrInit,
            .src = reg,
            .front = regs.front,
            .end = regs.end,
        } }, region);

        const before_end = solvable_index orelse effs.items.len;

        // Before-segments: chomp the front cursor forward, in source order.
        for (effs.items[0..before_end]) |seg| {
            try self.emitTemplateSegment(module_id, ast, seg, reg, regs, false, fail_jumps, region);
        }

        // After-segments: chomp the end cursor backward, in reverse order.
        if (solvable_index) |si| {
            var i = effs.items.len;
            while (i > si + 1) {
                i -= 1;
                try self.emitTemplateSegment(module_id, ast, effs.items[i], reg, regs, true, fail_jumps, region);
            }

            switch (effs.items[si].solvable) {
                .bind => |ls| {
                    try self.emitTemplateRest(reg, regs, region);
                    _ = try self.ir().push(allocator, .{ .match_bytes = .{
                        .op = .MatchBind,
                        .byte1 = ls.slot,
                        .byte2 = regs.rest,
                    } }, region);
                },
                // A placeholder absorbs the gap between the cursors; no
                // step needed.
                .placeholder => {},
                // A merge or structural cast solvable: take the raw
                // substring, cast it in place, and run the residual (a
                // merge residual, or a child window for a structural cast)
                // against it.
                .sub => |set_id| {
                    try self.emitTemplateRest(reg, regs, region);
                    try self.emitTemplateSubCast(module_id, ast, set_id, regs.rest, regs.rest, dead_reg, fail_jumps, region);
                },
                else => unreachable,
            }
        } else {
            // No solvable: the fixed segments must cover the whole string.
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cmp = .{
                .reg = regs.front,
                .kind = .reg,
                .arg = regs.end,
                .target = Ir.unpatched_jump,
            } }, region));
        }
    }

    // A template solvable sub-pattern cast: a number/boolean merge casts
    // to its resolved type and runs the merge residual (emitTemplateCast);
    // a structural array/object cast parses JSON and matches the parsed
    // container in a child window (emitTemplateStructuralCast).
    fn emitTemplateSubCast(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        set_id: Ast.SetId,
        cast_src: u8,
        cast_dst: u8,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        if (templateRangeLimits(ast, set_id) != null) {
            try self.emitTemplateRangeCast(module_id, ast, set_id, cast_src, cast_dst, fail_jumps, region);
        } else if (self.templateMergeSolvable(ast, set_id) != null) {
            try self.emitTemplateCast(module_id, ast, set_id, cast_src, cast_dst, dead_reg, fail_jumps, region);
        } else {
            try self.emitTemplateStructuralCast(module_id, ast, set_id, cast_src, cast_dst, fail_jumps, region);
        }
    }

    // Cast a numeric-range solvable's byte range (cast_src) to a number
    // into cast_dst, then range-test it. cast_src == cast_dst is the
    // in-place form used after MatchStrRest; the whole-string path casts
    // the source value directly. A non-numeric byte range fails the cast.
    fn emitTemplateRangeCast(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        set_id: Ast.SetId,
        cast_src: u8,
        cast_dst: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        try fail_jumps.append(self.vm.allocator, try self.ir().push(self.vm.allocator, .{ .match_cast = .{
            .dst = cast_dst,
            .src = cast_src,
            .ty = .number,
            .target = Ir.unpatched_jump,
        } }, region));
        const limits = templateRangeLimits(ast, set_id).?;
        try self.emitInRangeStep(module_id, ast, cast_dst, limits.lower, limits.upper, fail_jumps, region);
    }

    // Parse the solvable's byte range (cast_src) as JSON into cast_dst,
    // then match the parsed container against the sub-pattern in a child
    // window scrutinized by cast_dst. A parse failure or a rejected match
    // fails the whole template (a forward jump to the arm's fail tail).
    // cast_src == cast_dst is the in-place form used after MatchStrRest;
    // the whole-string path casts the source value directly.
    fn emitTemplateStructuralCast(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        set_id: Ast.SetId,
        cast_src: u8,
        cast_dst: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        try fail_jumps.append(self.vm.allocator, try self.ir().push(self.vm.allocator, .{ .match_cast = .{
            .dst = cast_dst,
            .src = cast_src,
            .ty = .json,
            .target = Ir.unpatched_jump,
        } }, region));
        const set = &ast.constraint_sets.items[set_id];
        try self.writeMatchSteps(module_id, ast, set.places.items, set.constraints.items, .{ .sub = .{
            .src_reg = cast_dst,
            .on_fail = .{ .arm = fail_jumps },
            .bind_mode = .bind,
        } }, region);
    }

    // Cast a merge solvable's byte range (cast_src) to its resolved type
    // into cast_dst, then run the merge residual against cast_dst.
    // cast_src == cast_dst is the in-place form used after MatchStrRest;
    // the whole-string path casts the source value directly.
    fn emitTemplateCast(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        set_id: Ast.SetId,
        cast_src: u8,
        cast_dst: u8,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        const set = &ast.constraint_sets.items[set_id];
        const merge = set.constraints.items[0].kind.solve_merge;
        const cast_ty: MatchCastKind = switch (self.templateMergeSolvable(ast, set_id).?) {
            .number => .number,
            .boolean => .boolean,
        };
        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_cast = .{
            .dst = cast_dst,
            .src = cast_src,
            .ty = cast_ty,
            .target = Ir.unpatched_jump,
        } }, region));
        try self.emitMergeSolve(module_id, ast, merge.ty, merge.parts.items, cast_dst, dead_reg, cast_ty == .number, fail_jumps, region);
    }

    fn emitTemplateRest(self: *Compiler, reg: u8, regs: TemplateRegs, region: Region) Error!void {
        _ = try self.ir().push(self.vm.allocator, .{ .match_str_rest = .{
            .op = .MatchStrRest,
            .dst = regs.rest,
            .src = reg,
            .front = regs.front,
            .end = regs.end,
        } }, region);
    }

    fn flushTemplateLit(
        self: *Compiler,
        module_id: Module.Id,
        effs: *ArrayList(EffSeg),
        lit: *ArrayList(u8),
        region: Region,
    ) Error!void {
        if (lit.items.len == 0) return;
        const sid = try self.vm.strings.insert(lit.items);
        const constant = try self.makeConstantU16(module_id, Elem.string(sid), region);
        try effs.append(self.vm.allocator, .{ .lit = constant });
        lit.clearRetainingCapacity();
    }

    // One cursor-path segment chomp. `back` selects the end cursor (chomp
    // backward) over the front cursor (chomp forward); the opposite cursor
    // bounds the chomp.
    fn emitTemplateSegment(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        seg: EffSeg,
        reg: u8,
        regs: TemplateRegs,
        back: bool,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        const cursor = if (back) regs.end else regs.front;
        const opp = if (back) regs.front else regs.end;
        const back_byte: u8 = if (back) 1 else 0;
        switch (seg) {
            .lit => |constant| try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_str_lit = .{
                .op = .MatchStrLit,
                .src = reg,
                .cursor = cursor,
                .opp = opp,
                .back = back_byte,
                .constant = constant,
                .target = Ir.unpatched_jump,
            } }, region)),
            .value => |part| {
                try self.emitEvaluablePartValue(module_id, ast, part, region);
                try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_str_val = .{
                    .op = .MatchStrVal,
                    .src = reg,
                    .cursor = cursor,
                    .opp = opp,
                    .back = back_byte,
                    .target = Ir.unpatched_jump,
                } }, region));
            },
            .char_range => |set_id| {
                try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_str_char = .{
                    .op = .MatchStrChar,
                    .dst = regs.char,
                    .src = reg,
                    .cursor = cursor,
                    .opp = opp,
                    .back = back_byte,
                    .target = Ir.unpatched_jump,
                } }, region));
                // A codepoint range compares the decoded character directly;
                // numeric ranges take the whole-substring cast path
                // (emitTemplateRangeCast), not this per-codepoint one.
                const limits = templateRangeLimits(ast, set_id).?;
                try self.emitInRangeStep(module_id, ast, regs.char, limits.lower, limits.upper, fail_jumps, region);
            },
            .solvable => unreachable,
        }
    }

    // A range test rooted at a register: constant/slot bounds ride in
    // the MatchInRange operand, evaluated bounds follow as
    // MatchRangeBound steps that pop their evaluated value.
    fn emitInRangeStep(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        reg: u8,
        lower: Ast.Limit,
        upper: Ast.Limit,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        var lower_eval: ?Ast.NodeId = null;
        var upper_eval: ?Ast.NodeId = null;
        const lower_desc = try self.rangeDescriptor(module_id, ast, lower, region, &lower_eval);
        const upper_desc = try self.rangeDescriptor(module_id, ast, upper, region, &upper_eval);

        try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_range = .{
            .op = .MatchInRange,
            .slot = reg,
            .lower_kind = lower_desc.kind,
            .lower_arg = lower_desc.arg,
            .upper_kind = upper_desc.kind,
            .upper_arg = upper_desc.arg,
            .target = Ir.unpatched_jump,
        } }, region));

        if (lower_eval) |id| {
            try self.writeGoal(module_id, ast, id);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                .op = .MatchRangeBound,
                .byte1 = reg,
                .byte2 = 0,
                .target = Ir.unpatched_jump,
            } }, region));
        }
        if (upper_eval) |id| {
            try self.writeGoal(module_id, ast, id);
            try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                .op = .MatchRangeBound,
                .byte1 = reg,
                .byte2 = 1,
                .target = Ir.unpatched_jump,
            } }, region));
        }
    }

    // A bare negation composes with any stepable inner. An evaluable
    // inner (read, global, expr) negates its own evaluated result; a
    // structural inner (bind, placeholder, sub) negates the scrutinee and
    // matches against it, so a sub-pattern steps when its own set does.
    fn negatedStepable(self: *Compiler, ast: *const Ast, part: Ast.Part) bool {
        return switch (part) {
            .bind, .placeholder, .read, .global, .expr => true,
            .sub => |set_id| self.constraintsStepable(ast, ast.constraint_sets.items[set_id].constraints.items),
            .local => false,
        };
    }

    // Match a negated inner against its place. An evaluable inner mirrors
    // the plan's negated-eval path: evaluate the pattern, negate the
    // result (NegateNumber errors on a non-number, like the interpreter),
    // then compare against the scrutinee. A structural inner negates the
    // scrutinee in place — an odd count flips the sign (MatchMergeNumNeg),
    // an even count is the identity but still number-gates via a zero
    // constant — then binds or matches the inner against the negated value.
    fn emitNegatedStep(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        count: u32,
        part: Ast.Part,
        reg: u8,
        dead_reg: u8,
        fail_jumps: *ArrayList(Ir.Index),
        region: Region,
    ) Error!void {
        const allocator = self.vm.allocator;
        switch (part) {
            .read, .global, .expr => {
                try self.emitEvaluablePartValue(module_id, ast, part, region);
                var i: u32 = 0;
                while (i < count) : (i += 1) try self.emitOp(.NegateNumber, region);
                try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_test = .{
                    .op = .MatchEval,
                    .byte1 = reg,
                    .byte2 = 0,
                    .target = Ir.unpatched_jump,
                } }, region));
            },
            .bind, .placeholder, .sub => {
                const constant = try self.makeConstantU16(module_id, Elem.numberFloat(0), region);
                try fail_jumps.append(allocator, try self.ir().push(allocator, .{ .match_const = .{
                    .op = if (count % 2 == 1) OpCode.MatchMergeNumNeg else OpCode.MatchMergeNum,
                    .byte1 = dead_reg,
                    .byte2 = reg,
                    .constant = constant,
                    .target = Ir.unpatched_jump,
                } }, region));
                switch (part) {
                    .bind => |ls| _ = try self.ir().push(allocator, .{ .match_bytes = .{
                        .op = .MatchBind,
                        .byte1 = ls.slot,
                        .byte2 = dead_reg,
                    } }, region),
                    .placeholder => {},
                    .sub => |set_id| {
                        const set = &ast.constraint_sets.items[set_id];
                        try self.writeMatchSteps(module_id, ast, set.places.items, set.constraints.items, .{ .sub = .{ .src_reg = dead_reg, .on_fail = .{ .arm = fail_jumps } } }, region);
                    },
                    else => unreachable,
                }
            },
            .local => unreachable,
        }
    }

    // Push an evaluable part's value onto the stack: a bound local, a
    // global (invoking a zero-arity function like the plan's const_fn), or
    // an expression goal (a constant or a call). Shared by negation and
    // template value holes.
    fn emitEvaluablePartValue(
        self: *Compiler,
        module_id: Module.Id,
        ast: *const Ast,
        part: Ast.Part,
        region: Region,
    ) Error!void {
        switch (part) {
            .read => |ls| try self.emitUnaryOp(.GetLocal, ls.slot, region),
            .global => |name| {
                const global = self.resolveGlobal(module_id, name) orelse {
                    try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.pathString(name)});
                    return Error.UndefinedVariable;
                };
                // Only zero-arity functions evaluate per match; the plan
                // path rejects the rest at compile time too.
                if (global.isDynType(.Function)) {
                    if (global.asDyn().asFunction().arity != 0) return error.UnsupportedPattern;
                    try self.writeCallFunctionConstant(module_id, global, region);
                } else {
                    try self.writeConstant(module_id, global, region);
                }
            },
            .expr => |id| try self.writeGoal(module_id, ast, id),
            else => unreachable,
        }
    }

    fn ensureGoalPlace(
        self: *Compiler,
        module_id: Module.Id,
        constraints: []const Ast.Constraint,
        places: []const Ast.PlaceDef,
        materialized: []bool,
        scratch_base: u8,
        place: Ast.PlaceId,
        region: Region,
    ) Error!void {
        if (materialized[place]) return;
        switch (places[place]) {
            .scrutinee => unreachable,
            .elem => |e| {
                try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, e.src, region);
                _ = try self.ir().push(self.vm.allocator, .{ .match_bytes = .{
                    .op = .MatchElem,
                    .byte1 = scratch_base + @as(u8, @intCast(place)),
                    .byte2 = scratch_base + @as(u8, @intCast(e.src)),
                    .byte3 = @intCast(e.index),
                    .byte4 = 0,
                } }, region);
            },
            .elem_back => |e| {
                try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, e.src, region);
                _ = try self.ir().push(self.vm.allocator, .{ .match_bytes = .{
                    .op = .MatchElem,
                    .byte1 = scratch_base + @as(u8, @intCast(place)),
                    .byte2 = scratch_base + @as(u8, @intCast(e.src)),
                    .byte3 = @intCast(e.index),
                    .byte4 = 1,
                } }, region);
            },
            .slice => |s| {
                try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, s.src, region);
                _ = try self.ir().push(self.vm.allocator, .{ .match_bytes = .{
                    .op = .MatchSlice,
                    .byte1 = scratch_base + @as(u8, @intCast(place)),
                    .byte2 = scratch_base + @as(u8, @intCast(s.src)),
                    .byte3 = @intCast(s.front),
                    .byte4 = @intCast(s.back),
                } }, region);
            },
            .members_rest => |r| {
                try self.ensureGoalPlace(module_id, constraints, places, materialized, scratch_base, r.src, region);
                const constant = try self.hasKeyListConstant(module_id, constraints, r.src, region);
                // Search pairs on the same object claimed keys into the
                // claim registers; the rest must exclude those too.
                if (self.findSearchGroup(self.arm_search_groups, r.src)) |group| {
                    _ = try self.ir().push(self.vm.allocator, .{ .match_rest_search = .{
                        .op = .MatchObjectRestSearch,
                        .dst = scratch_base + @as(u8, @intCast(place)),
                        .src = scratch_base + @as(u8, @intCast(r.src)),
                        .constant = constant,
                        .claim_base = group.base,
                        .claim_count = group.count,
                    } }, region);
                } else {
                    _ = try self.ir().push(self.vm.allocator, .{ .match_rest = .{
                        .op = .MatchObjectRest,
                        .byte1 = scratch_base + @as(u8, @intCast(place)),
                        .byte2 = scratch_base + @as(u8, @intCast(r.src)),
                        .constant = constant,
                    } }, region);
                }
            },
            // Key places materialize at their has_key constraint.
            .key => @panic("Internal Error: key place used before its has_key constraint"),
        }
        materialized[place] = true;
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

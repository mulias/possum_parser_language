const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const ChunkError = @import("chunk.zig").ChunkError;
const Elem = @import("elem.zig").Elem;
const Frontend = @import("frontend.zig");
const Ast = Frontend.Ast;
const GlobalKey = Frontend.GlobalKey;
const DependencyGraphNode = Frontend.DependencyGraphNode;
const Ir = @import("ir.zig").Ir;
const liveness = @import("liveness.zig");
const Module = @import("module.zig").Module;
const match_plan = @import("match_plan.zig");
const OpCode = @import("op_code.zig").OpCode;
const Pattern = @import("pattern.zig").Pattern;
const Region = @import("region.zig").Region;
const FrontendStrings = @import("string_table.zig").StringTable(.frontend);
const RuntimeStrings = @import("string_table.zig").StringTable(.runtime);
const VM = @import("vm.zig").VM;
const Writer = std.Io.Writer;
const Writers = @import("writer.zig").Writers;
const binding = @import("binding.zig");
const builtin = @import("builtin");
const builtins = @import("builtin.zig");
const parsing = @import("parsing.zig");
const std = @import("std");

pub const Compiler = struct {
    vm: *VM,
    frontend: *Frontend,
    functions: ArrayList(*Elem.DynElem.Function) = .{},
    scopes: ArrayList(Scope) = .{},
    irs: ArrayList(Ir) = .{},
    writers: Writers,
    printBytecode: bool = false,
    global_map: AutoHashMap(GlobalKey, Elem) = .{},
    constant_map: AutoHashMap(ConstantMapKey, usize) = .{},
    // The slots each module pattern references, computed once when the
    // pattern is created and indexed to match the module's `patterns`.
    // Compile-time only (feeds liveness), so it lives here rather than on
    // the runtime Module.
    pattern_reads: AutoHashMap(Module.Id, ArrayList(liveness.SlotSet)) = .{},
    // Same, for match plans, indexed to match the module's `match_plans`.
    plan_reads: AutoHashMap(Module.Id, ArrayList(liveness.SlotSet)) = .{},
    main: ?*Elem.DynElem.Function = null,
    // Memoizes internForRuntime so repeated names hash their bytes once.
    sid_map: AutoHashMap(FrontendStrings.Id, RuntimeStrings.Id) = .{},
    // Per-function binding analysis results, populated before each function
    // body is emitted and consulted during emission.
    binding_maps: binding.Maps = .{},

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
        alias_ident: FrontendStrings.Id,
        function,
    };

    const Error = error{
        InvalidAst,
        MaxFunctionArgs,
        MaxFunctionLocals,
        OutOfMemory,
        TooManyConstants,
        TooManyPatterns,
        ShortOverflow,
        AliasCycle,
        UnboundVariable,
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
            .frontend = try Frontend.init(vm.allocator, vm.writers),
            .writers = vm.writers,
            .printBytecode = vm.config.printCompiledBytecode,
            .constant_map = .{},
        };
    }

    // Copy a frontend-interned string into the VM string table. This is the
    // only place strings cross from the frontend table to the runtime table,
    // so the VM only holds strings that compiled code references.
    fn internForRuntime(self: *Compiler, sid: FrontendStrings.Id) !RuntimeStrings.Id {
        const gop = try self.sid_map.getOrPut(self.vm.allocator, sid);
        if (!gop.found_existing) {
            gop.value_ptr.* = try self.vm.strings.insert(self.frontend.strings.get(sid));
        }
        return gop.value_ptr.*;
    }

    pub fn deinit(self: *Compiler) void {
        self.frontend.deinit();
        self.constant_map.deinit(self.vm.allocator);
        self.global_map.deinit(self.vm.allocator);
        var pattern_reads = self.pattern_reads.valueIterator();
        while (pattern_reads.next()) |list| list.deinit(self.vm.allocator);
        self.pattern_reads.deinit(self.vm.allocator);
        var plan_reads = self.plan_reads.valueIterator();
        while (plan_reads.next()) |list| list.deinit(self.vm.allocator);
        self.plan_reads.deinit(self.vm.allocator);
        self.binding_maps.deinit(self.vm.allocator);
        self.sid_map.deinit(self.vm.allocator);
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

    pub fn addModuleDependency(self: *Compiler, module_id: Module.Id, dependendency_id: Module.Id) !void {
        try self.frontend.addModuleDependency(module_id, dependendency_id);
    }

    pub fn compile(self: *Compiler) !void {
        try self.frontend.finalize();

        if (self.frontend.target_module_id) |target_module_id| {
            try self.compileModule(target_module_id);

            if (self.frontend.main) |main_ast| {
                try self.compileMainParser(target_module_id, main_ast);
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

    fn compileMainParser(self: *Compiler, module_id: Module.Id, main_ast: *Ast.RNode(Ast.Parser.AnonymousFunction)) !void {
        const main_node = self.frontend.getNode(.{ .module_id = module_id, .name = main_ast.node.name });

        for (main_node.dependencies()) |dep_key| {
            try self.compileDeclaration(dep_key);
        }

        const function = try self.declareAnonFunction(.{ .module_id = module_id, .name = main_ast.node.name });

        try self.emitAnonFunctionBody(module_id, main_node, function, main_ast.node.body, main_ast.region);

        self.main = function;
    }

    // Shared bytecode shape for an anonymous function, including `main`.
    fn emitAnonFunctionBody(
        self: *Compiler,
        module_id: Module.Id,
        node: *DependencyGraphNode,
        function: *Elem.DynElem.Function,
        body: *Ast.Parser.RNode,
        region: Region,
    ) !void {
        try self.functions.append(self.vm.allocator, function);
        try self.pushScope(node);
        try self.irs.append(self.vm.allocator, Ir{});

        try self.pushLocalPlaceholders(module_id, 0, region);

        if (node.anonymous_function.closure_captures.items.len > 0) {
            try self.emitOp(.SetClosureCaptures, region);
        }

        try self.analyzeParserBindings(
            module_id,
            body,
            function.arity,
            node.anonymous_function.closure_captures.items,
        );
        try self.writeParser(module_id, body);
        try self.finishFunctionIr(module_id);

        _ = self.functions.pop();
        _ = self.scopes.pop();
    }

    fn isFullyCompiled(self: *Compiler, decl_key: GlobalKey) bool {
        const elem = self.findGlobal(decl_key.module_id, decl_key.name) orelse return false;
        return !elem.isDynType(.Function) or !elem.asDyn().asFunction().hasEmptyBytecode();
    }

    fn compileDeclaration(self: *Compiler, decl_key: GlobalKey) !void {
        if (self.isFullyCompiled(decl_key)) return;

        const node = self.frontend.getNode(decl_key);
        const dependencies = node.dependencies();

        for (dependencies) |dep_key| {
            try self.ensureDeclared(dep_key);
        }

        // Only compile if this is actually a declaration
        switch (node.*) {
            .precompiled => try self.createBuiltin(decl_key),
            .declaration => |*n| {
                const decl = n.ast;
                const kind = try self.classifyDecl(decl);

                if (self.findGlobal(decl_key.module_id, decl_key.name) == null) {
                    try self.declareFromKind(decl_key, decl, kind);
                }

                // Aliases share their target's function elem, whose bytecode is
                // filled in when the target's own declaration is compiled; only
                // a function declaration is compiled here.
                switch (kind) {
                    .function => {
                        if (self.findGlobal(decl_key.module_id, decl_key.name)) |elem| {
                            if (elem.isDynType(.Function) and elem.asDyn().asFunction().hasEmptyBytecode()) {
                                try self.compileFunction(node, decl_key.module_id, decl);
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
                        anon.ast.node.body,
                        anon.ast.region,
                    );
                }
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
            .precompiled => try self.createBuiltin(dep_key),
            .declaration => |*n| {
                try self.declareFromKind(dep_key, n.ast, try self.classifyDecl(n.ast));
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

        const ast = self.frontend.getNode(key).anonymous_function.ast;

        const function = try Elem.DynElem.Function.create(self.vm, .{
            .module_id = key.module_id,
            .name = try self.internForRuntime(key.name),
            .arity = 0,
            .region = ast.region,
            .is_anonymous = true,
        });

        try self.addGlobal(key.module_id, key.name, function.dyn.elem());

        return function;
    }

    fn createBuiltin(self: *Compiler, key: GlobalKey) !void {
        if (self.findGlobal(key.module_id, key.name) != null) return;

        const name = self.frontend.strings.get(key.name);
        const module = self.vm.getModule(key.module_id);
        const maybe_function = try builtins.create(self.vm, module, name);
        const function = maybe_function orelse
            @panic("Internal Error: precompiled node has no builtin implementation");
        try self.addGlobal(key.module_id, key.name, function.dyn.elem());
    }

    // A parameterless alias body inlines to a value elem; a bare-identifier
    // body is an alias to another declaration; everything else is a function.
    fn classifyDecl(self: *Compiler, decl: Ast.ParserOrValue.Declaration) !DeclKind {
        if (try self.getAliasBody(decl)) |elem| {
            return .{ .alias_value = elem };
        }
        if (self.getAliasChainName(decl)) |name| {
            return .{ .alias_ident = name };
        }
        return .function;
    }

    fn declareFromKind(self: *Compiler, key: GlobalKey, decl: Ast.ParserOrValue.Declaration, kind: DeclKind) !void {
        switch (kind) {
            .alias_value => |alias_elem| try self.addGlobal(key.module_id, key.name, alias_elem),
            .alias_ident => try self.denormalizeAlias(key, decl),
            .function => try self.declareFunction(key.module_id, decl),
        }
    }

    fn declareFunction(self: *Compiler, module_id: Module.Id, decl: Ast.ParserOrValue.Declaration) !void {
        // Create a new function and add the params to the function struct.
        // Leave the function's bytecode chunk empty for now.
        // Add the function to the globals namespace.

        const function_name = decl.identName();

        var function = try Elem.DynElem.Function.create(self.vm, .{
            .module_id = module_id,
            .name = try self.internForRuntime(function_name),
            .arity = 0,
            .region = decl.region(),
            .is_anonymous = false,
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
            if (self.findGlobal(target_key.module_id, target_key.name)) |elem| {
                target_elem = elem;
                break;
            }

            if (path.contains(target_key)) {
                try self.printError(decl_key.module_id, decl.region(), "Circular alias dependency detected for '{s}'", .{self.frontend.strings.get(decl_key.name)});
                return Error.AliasCycle;
            }
            try path.put(self.vm.allocator, target_key, undefined);

            const target_node = self.frontend.getNode(target_key);

            if (target_node.* == .precompiled) {
                try self.createBuiltin(target_key);
                target_elem = self.getGlobal(target_key);
                break;
            }

            const target_decl = target_node.declaration.ast;

            if (try self.getAliasDependency(target_key, target_decl)) |next_key| {
                target_key = next_key;
                continue;
            }

            if (try self.getAliasBody(target_decl)) |elem| {
                target_elem = elem;
                break;
            }

            // The target is itself an alias to a bare identifier, but the
            // resolver recorded no dependency edge for it, so that identifier
            // names nothing.
            if (self.getAliasChainName(target_decl)) |unresolved_name| {
                try self.printError(target_key.module_id, target_decl.region(), "undefined variable '{s}'", .{self.frontend.strings.get(unresolved_name)});
                return Error.UndefinedVariable;
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

        const node = self.frontend.findNode(decl_key.module_id, decl.identName()) orelse return null;

        return node.dependencyNamed(ident_name);
    }

    fn compileFunction(self: *Compiler, node: *DependencyGraphNode, module_id: Module.Id, decl: Ast.ParserOrValue.Declaration) !void {
        const global_sid = decl.identName();
        const globalVal = self.getGlobal(.{ .module_id = module_id, .name = global_sid });

        const function = globalVal.asDyn().asFunction();

        try self.functions.append(self.vm.allocator, function);
        try self.pushScope(node);
        try self.irs.append(self.vm.allocator, Ir{});

        try self.pushLocalPlaceholders(module_id, function.arity, decl.region());

        switch (decl) {
            .parser => |p| {
                try self.analyzeParserBindings(module_id, p.node.body, function.arity, &.{});
                try self.writeParser(module_id, p.node.body);
            },
            .value => |v| {
                try self.analyzeValueBindings(module_id, v.node.body, function.arity);
                try self.writeValue(module_id, v.node.body);
            },
        }

        try self.finishFunctionIr(module_id);

        _ = self.functions.pop();
        _ = self.scopes.pop();
    }

    fn analyzeParserBindings(
        self: *Compiler,
        module_id: Module.Id,
        body: *Ast.Parser.RNode,
        arity: usize,
        captures: []const Frontend.ClosureCapture,
    ) !void {
        var result = try binding.analyzeParserFunction(self, module_id, body, arity, captures);
        defer result.deinit(self.vm.allocator);
        try self.reportBindingDiagnostics(module_id, result.diagnostics.items);
    }

    fn analyzeValueBindings(self: *Compiler, module_id: Module.Id, body: *Ast.Value.RNode, arity: usize) !void {
        var result = try binding.analyzeValueFunction(self, module_id, body, arity);
        defer result.deinit(self.vm.allocator);
        try self.reportBindingDiagnostics(module_id, result.diagnostics.items);
    }

    fn reportBindingDiagnostics(self: *Compiler, module_id: Module.Id, diagnostics: []const binding.Diagnostic) !void {
        for (diagnostics) |diagnostic| {
            switch (diagnostic.kind) {
                .unbound => try self.printError(
                    module_id,
                    diagnostic.region,
                    "variable '{s}' is unbound here",
                    .{self.frontend.strings.get(diagnostic.name.?)},
                ),
                .out_of_scope => try self.printError(
                    module_id,
                    diagnostic.region,
                    "variable '{s}' is unbound here: its binding is out of scope",
                    .{self.frontend.strings.get(diagnostic.name.?)},
                ),
                .split => try self.printError(
                    module_id,
                    diagnostic.region,
                    "variable '{s}' may be unbound here: it is not bound on every path",
                    .{self.frontend.strings.get(diagnostic.name.?)},
                ),
                .unbound_function_var => try self.printError(
                    module_id,
                    diagnostic.region,
                    "variable '{s}' is unbound here: variables in pattern function calls must be bound",
                    .{self.frontend.strings.get(diagnostic.name.?)},
                ),
                .extra_unbound_part => if (diagnostic.name) |name| try self.printError(
                    module_id,
                    diagnostic.region,
                    "variable '{s}' is unbound here: a merge can solve at most one unbound part",
                    .{self.frontend.strings.get(name)},
                ) else try self.printError(
                    module_id,
                    diagnostic.region,
                    "pattern part is unbound here: a merge can solve at most one unbound part",
                    .{},
                ),
            }
        }

        if (diagnostics.len > 0) return Error.UnboundVariable;
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

    fn writeParser(self: *Compiler, module_id: Module.Id, rnode: *Ast.Parser.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .merge => |merge| {
                try self.writeParser(module_id, merge.left);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeParser(module_id, merge.right);
                try self.emitOp(.Merge, region);
                self.patchJump(jumpIndex);
            },
            .take_left => |take_left| {
                try self.writeParser(module_id, take_left.left);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeParser(module_id, take_left.right);
                try self.emitOp(.TakeLeft, region);
                self.patchJump(jumpIndex);
            },
            .take_right => |take_right| {
                try self.writeParser(module_id, take_right.left);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeParser(module_id, take_right.right);
                self.patchJump(jumpIndex);
            },
            .destructure => |destructure| {
                try self.writeParser(module_id, destructure.left);
                try self.writeDestructurePattern(module_id, destructure.right);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(module_id, or_node.left);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeParser(module_id, or_node.right);
                self.patchJump(jumpIndex);
            },
            .@"return" => |return_node| {
                // Special case: `"" $ Foo` will always succeed and push `Foo` on the stack
                if (return_node.left.node == .string and return_node.left.node.string.len == 0) {
                    try self.writeValue(module_id, return_node.right);
                } else {
                    try self.writeParser(module_id, return_node.left);
                    const jumpIndex = try self.emitJump(.TakeRight, region);
                    try self.writeValue(module_id, return_node.right);
                    self.patchJump(jumpIndex);
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
                try self.emitUnaryOp(.CallFunction, 0, region);
            },
            .identifier => |ident| {
                if (self.localSlot(ident.name)) |slot| {
                    try self.emitUnaryOp(.CallFunctionLocal, slot, region);
                } else {
                    if (self.resolveGlobal(module_id, ident.name)) |globalElem| {
                        try self.writeCallFunctionConstant(module_id, globalElem, region);
                    } else {
                        try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.strings.get(ident.name)});
                        return Error.UndefinedVariable;
                    }
                }
            },
            .function_call => |function_call| {
                try self.writeParserFunctionCall(module_id, function_call.function, function_call.args, region);
            },
            .number_string => |ns| {
                const bytes = ns.number;

                if (bytes.len == 1) {
                    try self.emitUnaryOp(.ParseNumberStringChar, bytes[0], region);
                } else {
                    const elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                    try self.writeCallFunctionConstant(module_id, elem, region);
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
                    try self.writeCallFunctionConstant(module_id, elem, region);
                }
            },
            .string_template => |parts| {
                try self.writeStringTemplateParser(module_id, parts, region);
            },
            .conditional => |conditional| {
                try self.emitOp(.SetInputMark, region);
                try self.writeParser(module_id, conditional.condition);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeParser(module_id, conditional.then_branch);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                self.patchJump(ifThenJumpIndex);
                try self.writeParser(module_id, conditional.else_branch);
                self.patchJump(thenElseJumpIndex);
            },
            .anonymous_function => |anon| {
                try self.writeParserAnonymousFunction(module_id, anon, region);
            },
        }
    }

    fn writeParserFunctionCall(
        self: *Compiler,
        module_id: Module.Id,
        function: *Ast.Parser.RNode,
        arguments: ArrayList(Ast.ParserOrValue.RNode),
        call_region: Region,
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
            const function_name = self.frontend.strings.get(function_id);
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
                try self.emitLongOp(.AssertParamTypes4, expected_param_types.bitset, call_region);
            }
        }

        for (arguments.items) |arg| {
            try self.writeParserFunctionArgument(module_id, arg);
        }

        try self.emitUnaryOp(.CallFunction, @intCast(arg_count), call_region);
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
                try self.emitBytePair(
                    .ParseCodepointRange,
                    @as(u8, @intCast(low_codepoint)),
                    low.region,
                    @as(u8, @intCast(high_codepoint)),
                    high.region,
                    region,
                );
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
                try self.emitBytePair(
                    .ParseIntegerRange,
                    @as(u8, @intCast(low_int)),
                    low.region,
                    @as(u8, @intCast(high_int)),
                    high.region,
                    region,
                );
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
                } else if (self.repeatCountIsBound(repeat)) {
                    try self.writeParserRepeatCount(module_id, parser, repeat, region);
                } else {
                    try self.writeParserRepeatUnknownCount(module_id, parser, repeat, region);
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
        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, repeat_region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser);
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
        self.patchJump(failureJump);
        try self.emitOp(.Swap, repeat_region);

        // Cleanup: drop the counter
        self.patchJump(nullJump);
        self.patchJump(doneJump);
        try self.emitOp(.Drop, count.region);
    }

    fn writeParserRepeatUnknownCount(self: *Compiler, module_id: Module.Id, parser: *Ast.Parser.RNode, count: *Ast.Pattern.RNode, repeat_region: Region) Error!void {
        // Count accumulator
        try self.writeConstant(module_id, Elem.numberFloat(0), count.region);

        // Value accumulator
        try self.writeConstant(module_id, Elem.nullConst, parser.region);

        // Start of the parse loop
        const loopStart = self.ir().nextIndex();

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser);
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
        self.patchJump(failureJump);
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
        const loopStartRequired = self.ir().nextIndex();
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        self.patchJump(skipLowerBoundJump);
        self.patchJump(doneLowerBoundJump);

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
        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser);
        const failureUpperBoundJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        self.patchJump(failureUpperBoundJump);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);

        // Got here by failing before reaching the minimum number of iters. The
        // stack is [..., count, failure] and we want to return failure
        self.patchJump(failureLowerBoundJump);

        // Swap up the count
        try self.emitOp(.Swap, region);

        // Got here by matching against a zero count, stack is [..., acc, count]
        self.patchJump(skipUpperBoundJump);
        self.patchJump(doneJump);

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
        const loopStartRequired = self.ir().nextIndex();
        try self.emitOp(.Swap, region);

        // Run parser, accumulate, end loop if failure
        try self.writeParser(module_id, parser);
        try self.emitOp(.Merge, parser.region);
        const failureLowerBoundJump = try self.emitJump(.JumpIfFailure, parser.region);

        // If count is zero end loop
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, lower.region);
        const doneLowerBoundJump = try self.emitJump(.JumpIfZero, region);

        // Otherwise return to loop start
        try self.emitJumpBack(.JumpBack, loopStartRequired, region);

        // Now continue parsing indefinitely (optional iterations)
        self.patchJump(skipLowerBoundJump);
        self.patchJump(doneLowerBoundJump);

        // Count under acc
        try self.emitOp(.Swap, region);

        // Unbounded loop
        const loopStartOptional = self.ir().nextIndex();

        // Run parser, end loop if failure, otherwise accumulate
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser);
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
        self.patchJump(failureJumpOptional);
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

        self.patchJump(failureLowerBoundJump);
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
        const loopStart = self.ir().nextIndex();
        try self.emitOp(.Swap, region);
        try self.emitOp(.SetInputMark, parser.region);
        try self.writeParser(module_id, parser);
        const failureJump = try self.emitJump(.JumpIfFailure, parser.region);
        try self.emitOp(.PopInputMark, parser.region);
        try self.emitOp(.Merge, parser.region);
        try self.emitOp(.Swap, region);
        try self.emitOp(.Decrement, upper.region);
        const doneJump = try self.emitJump(.JumpIfZero, region);
        try self.emitJumpBack(.JumpBack, loopStart, region);

        // Parser failed, stack is [..., count, acc, failure]
        // Drop the failure and swap up the count so we can pattern match/cleanup
        self.patchJump(failureJump);
        try self.emitOp(.ResetInput, parser.region);
        try self.emitOp(.Drop, parser.region);
        try self.emitOp(.Swap, region);

        self.patchJump(nullJump);
        self.patchJump(doneJump);

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
                    } else if (self.localSlot(ident.name) != null) {
                        return self.repeatCountIsBound(rnode);
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

    // Whether a repeat-count local is bound at the repeat, per the binding
    // analysis. Falls back to the param check for identifiers the analysis
    // does not classify (builtins).
    fn repeatCountIsBound(self: *Compiler, rnode: *Ast.Pattern.RNode) bool {
        if (self.binding_maps.repeat_count_bound.get(rnode)) |bound| {
            return bound;
        }
        const slot = self.localSlot(rnode.node.identifier.name) orelse return false;
        return self.currentFunction().arity > slot;
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

    fn writeGetVar(self: *Compiler, module_id: Module.Id, name: FrontendStrings.Id, region: Region) !void {
        if (self.localSlot(name)) |slot| {
            try self.emitUnaryOp(.GetBoundLocal, slot, region);
        } else {
            if (self.resolveGlobal(module_id, name)) |globalElem| {
                try self.writeConstant(module_id, globalElem, region);
            } else {
                try self.printError(module_id, region, "undefined variable '{s}'", .{self.frontend.strings.get(name)});
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
                .anonymous_function => |anon| {
                    try self.writeParserAnonymousFunction(module_id, anon, region);
                },
                else => @panic("Internal Error: compound parser in function args must be wrapped in an anonymous function."),
            },
            .value => |v| try self.writeValue(module_id, v),
        }
    }

    fn writeParserAnonymousFunction(self: *Compiler, module_id: Module.Id, anon: Ast.Parser.AnonymousFunction, region: Region) Error!void {
        const key = GlobalKey{ .module_id = module_id, .name = anon.name };
        const function = try self.declareAnonFunction(key);

        const constId = try self.makeConstant(module_id, function.dyn.elem());

        const anon_node = self.frontend.getNode(key).anonymous_function;

        try self.emitConstant(constId, region);

        if (anon_node.closure_captures.items.len == 0) {
            return;
        }

        const local_count = @as(u8, @intCast(anon_node.locals.items.len));
        try self.emitUnaryOp(.CreateClosure, local_count, region);

        for (anon_node.closure_captures.items) |capture| {
            // The resolver guarantees the enclosing scope holds every
            // captured local. A miss here would misalign later
            // captures with SetClosureCaptures slots.
            const fromSlot = self.localSlot(capture.local) orelse unreachable;
            try self.emitUnaryOp(.CaptureLocal, @as(u8, @intCast(fromSlot)), region);
        }
    }

    // Compile a destructure's pattern, preferring the match plan IR. Lowering
    // supports a subset of patterns; the rest fall back to the Pattern tree.
    fn writeDestructurePattern(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) Error!void {
        if (self.tryCreateMatchPlan(module_id, rnode)) |planId| {
            try self.emitMatchPlan(planId, rnode.region);
        } else |err| switch (err) {
            error.UnsupportedPattern => {
                const patternId = try self.createPattern(module_id, rnode);
                try self.emitPattern(patternId, rnode.region);
            },
            else => |e| return e,
        }
    }

    // Scratch state for lowering one pattern to a MatchPlan. Everything
    // accumulates here so an UnsupportedPattern deep in the tree abandons
    // cleanly, before any module or plan state mutation.
    const PlanBuilder = struct {
        nodes: ArrayList(match_plan.Node) = .{},
        vars: ArrayList(match_plan.LocalVar) = .{},
        elems: ArrayList(Elem) = .{},
        sids: ArrayList(RuntimeStrings.Id) = .{},
        ranges: ArrayList(match_plan.RangePlan) = .{},
        merges: ArrayList(match_plan.MergePlan) = .{},
        reads: liveness.SlotSet = liveness.SlotSet.initEmpty(),

        fn deinit(self: *PlanBuilder, allocator: std.mem.Allocator) void {
            self.nodes.deinit(allocator);
            self.vars.deinit(allocator);
            self.elems.deinit(allocator);
            self.sids.deinit(allocator);
            self.ranges.deinit(allocator);
            self.merges.deinit(allocator);
        }

        fn appendLeaf(self: *PlanBuilder, allocator: std.mem.Allocator, tag: match_plan.Tag, payload: u32) !void {
            try self.nodes.append(allocator, .{ .tag = tag, .subtree_len = 1, .payload = payload });
        }

        fn addElem(self: *PlanBuilder, allocator: std.mem.Allocator, elem: Elem) !u32 {
            // The plan holds the elem across matches, like a module
            // constant: shared by construction, never unique.
            if (elem.isType(.Dyn)) elem.asDyn().makeImmortal();
            const idx: u32 = @intCast(self.elems.items.len);
            try self.elems.append(allocator, elem);
            return idx;
        }

        fn addVar(self: *PlanBuilder, allocator: std.mem.Allocator, local_var: match_plan.LocalVar) !u32 {
            const idx: u32 = @intCast(self.vars.items.len);
            try self.vars.append(allocator, local_var);
            self.reads.set(local_var.idx);
            return idx;
        }

        fn appendEquality(self: *PlanBuilder, allocator: std.mem.Allocator, elem: Elem) !void {
            try self.appendLeaf(allocator, .equality, try self.addElem(allocator, elem));
        }

        fn appendVar(self: *PlanBuilder, allocator: std.mem.Allocator, tag: match_plan.Tag, local_var: match_plan.LocalVar) !void {
            try self.appendLeaf(allocator, tag, try self.addVar(allocator, local_var));
        }
    };

    // Lower a pattern to a MatchPlan. Unsupported patterns (and the explain
    // and destructure-printing modes, which report through the Pattern tree)
    // return UnsupportedPattern so the caller falls back to createPattern.
    fn tryCreateMatchPlan(
        self: *Compiler,
        module_id: Module.Id,
        rnode: *Ast.Pattern.RNode,
    ) (Error || error{UnsupportedPattern})!u24 {
        if (self.vm.config.explain or self.vm.config.printVM or self.vm.config.printDestructure) {
            return error.UnsupportedPattern;
        }

        const allocator = self.vm.allocator;
        var builder = PlanBuilder{};
        defer builder.deinit(allocator);

        try self.lowerPatternNode(module_id, rnode, &builder);

        try self.emitPatternPreclears(module_id, rnode);

        const nodes = try builder.nodes.toOwnedSlice(allocator);
        errdefer allocator.free(nodes);
        const vars = try builder.vars.toOwnedSlice(allocator);
        errdefer allocator.free(vars);
        const elems = try builder.elems.toOwnedSlice(allocator);
        errdefer allocator.free(elems);
        const sids = try builder.sids.toOwnedSlice(allocator);
        errdefer allocator.free(sids);
        const ranges = try builder.ranges.toOwnedSlice(allocator);
        errdefer allocator.free(ranges);
        const merges = try builder.merges.toOwnedSlice(allocator);
        errdefer allocator.free(merges);

        const module = self.vm.getModule(module_id);
        const idx = try module.addMatchPlan(allocator, .{
            .nodes = nodes,
            .vars = vars,
            .elems = elems,
            .sids = sids,
            .ranges = ranges,
            .merges = merges,
        });

        const gop = try self.plan_reads.getOrPut(allocator, module_id);
        if (!gop.found_existing) gop.value_ptr.* = .{};
        try gop.value_ptr.append(allocator, builder.reads);

        return @intCast(idx);
    }

    // Append one pattern subtree to the builder in preorder. Mirrors
    // astToPattern's constant conversions exactly so plan and tree compare
    // identically. Negation falls back: negating a non-number literal is a
    // compile error the tree path reports, and a negated non-number constant
    // is a runtime error that pre-folding would turn into a compile error.
    fn lowerPatternNode(
        self: *Compiler,
        module_id: Module.Id,
        rnode: *Ast.Pattern.RNode,
        builder: *PlanBuilder,
    ) (Error || error{UnsupportedPattern})!void {
        const allocator = self.vm.allocator;

        switch (rnode.node) {
            .identifier => |ident| {
                const name = ident.name;
                if (std.mem.eql(u8, self.frontend.strings.get(name), "_")) {
                    return builder.appendLeaf(allocator, .placeholder, 0);
                }
                if (self.resolveGlobal(module_id, name)) |global| {
                    // Zero-arity function constants are evaluated per match
                    // (const_fn is deferred).
                    if (global.isDynType(.Function) or
                        global.isDynType(.NativeCode) or
                        global.isDynType(.Closure))
                    {
                        return error.UnsupportedPattern;
                    }
                    return builder.appendEquality(allocator, global);
                }
                const slot = self.localSlot(name) orelse return error.UnsupportedPattern;
                const bound = self.binding_maps.pattern_local_bound.get(rnode) orelse
                    return error.UnsupportedPattern;
                return builder.appendVar(allocator, if (bound) .bound_eq else .bind, .{
                    .sid = try self.internForRuntime(name),
                    .idx = slot,
                    .negation_count = 0,
                });
            },
            .number_float => |f| return builder.appendEquality(allocator, Elem.numberFloat(f)),
            .number_string => |ns| {
                const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const number = ns_elem.asNumberString().toNumberFloat(self.vm.strings);
                return builder.appendEquality(allocator, number);
            },
            .string => |s| {
                const sid = try self.vm.strings.insert(s);
                return builder.appendEquality(allocator, Elem.string(sid));
            },
            .true => return builder.appendEquality(allocator, Elem.boolean(true)),
            .false => return builder.appendEquality(allocator, Elem.boolean(false)),
            .null => return builder.appendEquality(allocator, Elem.nullConst),
            .array => |elements| {
                // Fixed-length arrays only: spread/rest and merge parts are
                // `.merge` nodes, which fall back below when recursed into.
                const start = builder.nodes.items.len;
                try builder.nodes.append(allocator, .{
                    .tag = .array,
                    .subtree_len = undefined,
                    .payload = @intCast(elements.items.len),
                });
                for (elements.items) |element| {
                    try self.lowerPatternNode(module_id, element, builder);
                }
                builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
            },
            .object => |pairs| {
                // Constant string keys only: any other key form keeps the
                // tree path's unbound-key linear search and backtracking.
                const start = builder.nodes.items.len;
                try builder.nodes.append(allocator, .{
                    .tag = .object,
                    .subtree_len = undefined,
                    .payload = @intCast(pairs.items.len),
                });
                for (pairs.items) |pair| {
                    if (pair.key.node != .string) return error.UnsupportedPattern;
                    const sid = try self.vm.strings.insert(pair.key.node.string);
                    const key_start = builder.nodes.items.len;
                    try builder.nodes.append(allocator, .{
                        .tag = .const_key,
                        .subtree_len = undefined,
                        .payload = @intCast(builder.sids.items.len),
                    });
                    try builder.sids.append(allocator, sid);
                    try self.lowerPatternNode(module_id, pair.value, builder);
                    builder.nodes.items[key_start].subtree_len = @intCast(builder.nodes.items.len - key_start);
                }
                builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
            },
            .range => |bounds| {
                std.debug.assert(bounds.lower != null or bounds.upper != null);
                const lower = try self.lowerRangeLimit(module_id, bounds.lower, builder);
                const upper = try self.lowerRangeLimit(module_id, bounds.upper, builder);
                try builder.appendLeaf(allocator, .range, @intCast(builder.ranges.items.len));
                try builder.ranges.append(allocator, .{ .lower = lower, .upper = upper });
            },
            .merge => {
                // Nested merges flatten into one part list, the way
                // collectPatternMergeElements flattens the Pattern tree.
                const start = builder.nodes.items.len;
                const merge_idx: u32 = @intCast(builder.merges.items.len);
                try builder.nodes.append(allocator, .{
                    .tag = .merge,
                    .subtree_len = undefined,
                    .payload = merge_idx,
                });
                try builder.merges.append(allocator, .{
                    .part_count = 0,
                    .solvable_index = null,
                });
                var merge_plan = match_plan.MergePlan{ .part_count = 0, .solvable_index = null };
                try self.lowerMergeParts(module_id, rnode, builder, &merge_plan);
                builder.merges.items[merge_idx] = merge_plan;
                builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
            },
            else => return error.UnsupportedPattern,
        }
    }

    fn lowerMergeParts(
        self: *Compiler,
        module_id: Module.Id,
        rnode: *Ast.Pattern.RNode,
        builder: *PlanBuilder,
        merge_plan: *match_plan.MergePlan,
    ) (Error || error{UnsupportedPattern})!void {
        switch (rnode.node) {
            .merge => |merge| {
                try self.lowerMergeParts(module_id, merge.left, builder, merge_plan);
                try self.lowerMergeParts(module_id, merge.right, builder, merge_plan);
            },
            else => {
                // Binding analysis records solvability per part; a part it
                // never visited means the pattern shape diverged from the
                // analysis walk, so fall back rather than guess.
                const unbound = self.binding_maps.merge_part_unbound.get(rnode) orelse
                    return error.UnsupportedPattern;
                if (unbound) merge_plan.solvable_index = merge_plan.part_count;
                try self.lowerPatternNode(module_id, rnode, builder);
                merge_plan.part_count += 1;
            },
        }
    }

    // A range bound folds when it is absent, a number/string literal, or a
    // statically-bound local. An unbound local in a bound is matched as a
    // pattern by the tree path, so it falls back.
    fn lowerRangeLimit(
        self: *Compiler,
        module_id: Module.Id,
        maybe_rnode: ?*Ast.Pattern.RNode,
        builder: *PlanBuilder,
    ) (Error || error{UnsupportedPattern})!match_plan.RangePlan.Limit {
        const allocator = self.vm.allocator;
        const rnode = maybe_rnode orelse return .none;

        switch (rnode.node) {
            .number_float => |f| {
                return .{ .const_elem = try builder.addElem(allocator, Elem.numberFloat(f)) };
            },
            .number_string => |ns| {
                const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
                const number = ns_elem.asNumberString().toNumberFloat(self.vm.strings);
                return .{ .const_elem = try builder.addElem(allocator, number) };
            },
            .string => |s| {
                const sid = try self.vm.strings.insert(s);
                return .{ .const_elem = try builder.addElem(allocator, Elem.string(sid)) };
            },
            .identifier => |ident| {
                const name = ident.name;
                if (std.mem.eql(u8, self.frontend.strings.get(name), "_")) {
                    return error.UnsupportedPattern;
                }
                if (self.resolveGlobal(module_id, name) != null) return error.UnsupportedPattern;
                const slot = self.localSlot(name) orelse return error.UnsupportedPattern;
                const bound = self.binding_maps.pattern_local_bound.get(rnode) orelse
                    return error.UnsupportedPattern;
                if (!bound) return error.UnsupportedPattern;
                return .{ .bound_local = try builder.addVar(allocator, .{
                    .sid = try self.internForRuntime(name),
                    .idx = slot,
                    .negation_count = 0,
                }) };
            },
            else => return error.UnsupportedPattern,
        }
    }

    fn createPattern(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) Error!u24 {
        try self.emitPatternPreclears(module_id, rnode);
        const patternElem = try self.astToPattern(module_id, rnode, 0);
        const module = self.vm.getModule(module_id);
        const idx = try module.addPattern(self.vm.allocator, patternElem);

        const gop = try self.pattern_reads.getOrPut(self.vm.allocator, module_id);
        if (!gop.found_existing) gop.value_ptr.* = .{};
        try gop.value_ptr.append(self.vm.allocator, liveness.patternReads(patternElem));

        return @intCast(idx);
    }

    // The binding analysis lists slots this pattern may bind while the slot
    // still holds a value whose binding is out of scope. Restore their
    // placeholders so the solver's bind-if-unbound check sees them as
    // unbound. Stack-neutral, so it can run any time before the Destructure.
    fn emitPatternPreclears(self: *Compiler, module_id: Module.Id, rnode: *Ast.Pattern.RNode) !void {
        const preclears = self.binding_maps.preclears.get(rnode) orelse return;

        for (preclears.items) |preclear| {
            const bytes = self.frontend.strings.get(preclear.name);
            const underscored = bytes.len > 0 and bytes[0] == '_';
            const placeholder = Elem.valueVar(try self.internForRuntime(preclear.name), underscored);
            try self.writeConstant(module_id, placeholder, rnode.region);
            try self.emitUnaryOp(.SetLocal, preclear.slot, rnode.region);
        }
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
                const name = ident.name;
                if (self.resolveGlobal(module_id, name)) |globalElem| {
                    const constId = try self.makeConstant(module_id, globalElem);
                    return Pattern{ .Constant = .{
                        .sid = try self.internForRuntime(name),
                        .idx = constId,
                        .negation_count = negation_count,
                    } };
                } else {
                    const slot = self.localSlot(name).?;
                    return Pattern{ .Local = .{
                        .sid = try self.internForRuntime(name),
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
                        .sid = try self.internForRuntime(function_ident.name),
                        .idx = try self.makeConstant(module_id, globalElem),
                        .negation_count = negation_count,
                    }
                else if (self.localSlot(function_ident.name)) |slot|
                    .{
                        .sid = try self.internForRuntime(function_ident.name),
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
                        .sid = try self.internForRuntime(ident.name),
                        .idx = try self.makeConstant(module_id, elem),
                        .negation_count = negation_count,
                    } };
                } else {
                    const slot = self.localSlot(ident.name).?;
                    return Pattern{ .Local = .{
                        .sid = try self.internForRuntime(ident.name),
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
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writePatternAsBoundRepeatValue(module_id, merge.right);
                try self.emitOp(.Merge, region);
                self.patchJump(jumpIndex);
            },
            .negation => |inner| {
                try self.writePatternAsBoundRepeatValue(module_id, inner);
                try self.emitOp(.NegateNumber, region);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(module_id, function_call.function, function_call.args, region);
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

    fn writeValue(self: *Compiler, module_id: Module.Id, rnode: *Ast.Value.RNode) !void {
        const node = rnode.node;
        const region = rnode.region;

        switch (node) {
            .merge => |merge| {
                try self.writeValue(module_id, merge.left);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeValue(module_id, merge.right);
                try self.emitOp(.Merge, region);
                self.patchJump(jumpIndex);
            },
            .take_left => |take_left| {
                try self.writeValue(module_id, take_left.left);
                const jumpIndex = try self.emitJump(.JumpIfFailure, region);
                try self.writeValue(module_id, take_left.right);
                try self.emitOp(.TakeLeft, region);
                self.patchJump(jumpIndex);
            },
            .take_right => |take_right| {
                try self.writeValue(module_id, take_right.left);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(module_id, take_right.right);
                self.patchJump(jumpIndex);
            },
            .destructure => |destructure| {
                try self.writeValue(module_id, destructure.left);
                try self.writeDestructurePattern(module_id, destructure.right);
            },
            .@"or" => |or_node| {
                try self.emitOp(.SetInputMark, region);
                try self.writeValue(module_id, or_node.left);
                const jumpIndex = try self.emitJump(.Or, region);
                try self.writeValue(module_id, or_node.right);
                self.patchJump(jumpIndex);
            },
            .@"return" => |return_node| {
                try self.writeValue(module_id, return_node.left);
                const jumpIndex = try self.emitJump(.TakeRight, region);
                try self.writeValue(module_id, return_node.right);
                self.patchJump(jumpIndex);
            },
            .repeat => |repeat| {
                try self.writeValue(module_id, repeat.left);
                try self.writeValue(module_id, repeat.right);
                try self.emitOp(.RepeatValue, region);
            },
            .negation => |inner| {
                try self.writeValue(module_id, inner);
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
                try self.writeValue(module_id, conditional.condition);
                const ifThenJumpIndex = try self.emitJump(.ConditionalThen, region);
                try self.writeValue(module_id, conditional.then_branch);
                const thenElseJumpIndex = try self.emitJump(.Jump, region);
                self.patchJump(ifThenJumpIndex);
                try self.writeValue(module_id, conditional.else_branch);
                self.patchJump(thenElseJumpIndex);
            },
            .function_call => |function_call| {
                try self.writeValueFunctionCall(module_id, function_call.function, function_call.args, region);
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
                        try self.writeCallFunctionConstant(module_id, globalElem, region);
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
                const functionNameStr = self.frontend.strings.get(functionName);
                try self.printError(module_id, function_region, "Undefined function '{s}'", .{functionNameStr});
                return Error.UndefinedVariable;
            }
        }

        const argCount = try self.writeValueFunctionArguments(module_id, arguments, function);

        try self.emitUnaryOp(.CallFunction, argCount, call_region);
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
            try self.writeValue(module_id, arg);
        }

        return @intCast(arg_count);
    }

    fn writeValueArray(self: *Compiler, module_id: Module.Id, elements: ArrayList(*Ast.Value.RNode), region: Region) Error!void {
        if (elements.items.len == 0) {
            return try self.emitOp(.PushEmptyArray, region);
        }

        var array = try Elem.DynElem.Array.create(self.vm, elements.items.len);
        const constant_index = self.ir().nextIndex();
        try self.writeConstant(module_id, array.dyn.elem(), region);

        var mutated = false;
        for (elements.items, 0..) |element, index| {
            if (try self.writeArrayElem(module_id, array, element, @intCast(index), region)) {
                mutated = true;
            }
        }
        if (mutated) self.ir().patchConstantMutable(constant_index);
    }

    fn appendDynamicValue(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8) !void {
        try self.writeValue(module_id, rnode);
        try self.emitUnaryOp(.InsertAtIndex, index, rnode.region);
        try array.append(self.vm, try self.placeholderVar());
    }

    fn negateAndAppendDynamicValue(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) !void {
        try self.writeValue(module_id, rnode);
        try self.emitOp(.NegateNumber, region);
        try self.emitUnaryOp(.InsertAtIndex, index, region);
        try array.append(self.vm, try self.placeholderVar());
    }

    // Returns true when the element is dynamic: an InsertAtIndex was
    // emitted for it, so the constant array will be mutated at runtime.
    fn writeArrayElem(self: *Compiler, module_id: Module.Id, array: *Elem.DynElem.Array, rnode: *Ast.Value.RNode, index: u8, region: Region) Error!bool {
        switch (rnode.node) {
            .false => {
                try array.append(self.vm, Elem.boolean(false));
                return false;
            },
            .true => {
                try array.append(self.vm, Elem.boolean(true));
                return false;
            },
            .null => {
                try array.append(self.vm, Elem.nullConst);
                return false;
            },
            .number_float => |f| {
                try array.append(self.vm, Elem.numberFloat(f));
                return false;
            },
            .number_string => |ns| {
                try array.append(self.vm, try self.numberStringNodeToElem(ns.number, ns.negated));
                return false;
            },
            .string => |s| {
                const sid = try self.vm.strings.insert(s);
                try array.append(self.vm, Elem.string(sid));
                return false;
            },
            .identifier => |ident| {
                // Try to resolve as a global constant
                if (self.localSlot(ident.name) == null) {
                    if (self.resolveGlobal(module_id, ident.name)) |globalElem| {
                        // If it's not a function, we can inline the constant value
                        if (!globalElem.isDynType(.Function)) {
                            try array.append(self.vm, globalElem);
                            return false;
                        }
                    }
                }
                // Fall back to dynamic value for locals and functions
                try self.appendDynamicValue(module_id, array, rnode, index);
                return true;
            },
            .function_call,
            .merge,
            .@"or",
            .@"return",
            .take_left,
            .take_right,
            .repeat,
            .destructure,
            => {
                try self.appendDynamicValue(module_id, array, rnode, index);
                return true;
            },
            .array => |elements| {
                // Special case: empty arrays should be treated as literals
                if (elements.items.len == 0) {
                    var emptyArray = try Elem.DynElem.Array.create(self.vm, 0);
                    try array.append(self.vm, emptyArray.dyn.elem());
                    return false;
                } else {
                    try self.appendDynamicValue(module_id, array, rnode, index);
                    return true;
                }
            },
            .object => |pairs| {
                // Special case: empty objects should be treated as literals
                if (pairs.items.len == 0) {
                    var emptyObject = try Elem.DynElem.Object.create(self.vm, 0);
                    try array.append(self.vm, emptyObject.dyn.elem());
                    return false;
                } else {
                    try self.appendDynamicValue(module_id, array, rnode, index);
                    return true;
                }
            },
            .string_template, .conditional => {
                try self.appendDynamicValue(module_id, array, rnode, index);
                return true;
            },
            .negation => |inner| {
                try self.negateAndAppendDynamicValue(module_id, array, inner, index, region);
                return true;
            },
        }
    }

    fn writeValueObject(self: *Compiler, module_id: Module.Id, pairs: ArrayList(Ast.Value.ObjectPair), region: Region) Error!void {
        if (pairs.items.len == 0) {
            return try self.emitOp(.PushEmptyObject, region);
        }

        var object = try Elem.DynElem.Object.create(self.vm, 0);
        const constant_index = self.ir().nextIndex();
        try self.writeConstant(module_id, object.dyn.elem(), region);

        var mutated = false;
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
                    mutated = true;
                }
            } else {
                try self.writeInsertObjectPair(module_id, pair, object, index);
                mutated = true;
            }
        }
        if (mutated) self.ir().patchConstantMutable(constant_index);
    }

    fn writeInsertObjectPair(self: *Compiler, module_id: Module.Id, pair: Ast.Value.ObjectPair, object: *Elem.DynElem.Object, index: usize) !void {
        std.debug.assert(index <= 255);
        const pos = @as(u8, @intCast(index));
        try object.putReservedId(self.vm, pos, try self.placeholderVar());
        try self.writeValue(module_id, pair.key);
        try self.writeValue(module_id, pair.value);
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
            try self.writeParser(module_id, part);
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
            try self.writeValue(module_id, part);
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

    fn getAliasChainName(self: *Compiler, decl: Ast.ParserOrValue.Declaration) ?FrontendStrings.Id {
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
        const pattern_reads: []const liveness.SlotSet =
            if (self.pattern_reads.get(module_id)) |list| list.items else &.{};
        const plan_reads: []const liveness.SlotSet =
            if (self.plan_reads.get(module_id)) |list| list.items else &.{};

        var last_reads = try liveness.Liveness.analyze(
            self.vm.allocator,
            function_ir,
            pattern_reads,
            plan_reads,
        );
        defer last_reads.deinit(self.vm.allocator);

        for (function_ir.instructions.items, 0..) |*insn, i| {
            switch (insn.operand) {
                .byte => |*b| {
                    const move_op: OpCode = switch (b.op) {
                        .GetLocal => .GetLocalMove,
                        .GetBoundLocal => .GetBoundLocalMove,
                        else => continue,
                    };
                    if (last_reads.diesAt(@intCast(i), b.byte)) b.op = move_op;
                },
                else => {},
            }
        }
    }

    fn findGlobal(self: Compiler, module_id: Module.Id, sid: FrontendStrings.Id) ?Elem {
        if (self.global_map.get(.{ .module_id = module_id, .name = sid })) |elem| {
            return elem;
        }
        return null;
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
    pub fn resolveGlobal(self: *Compiler, module_id: Module.Id, sid: FrontendStrings.Id) ?Elem {
        if (self.findGlobal(module_id, sid)) |elem| {
            return visibleGlobal(elem);
        }

        const node = self.currentScope();
        for (node.dependencies()) |dep_key| {
            if (dep_key.name == sid) {
                const elem = self.findGlobal(dep_key.module_id, dep_key.name) orelse return null;
                return visibleGlobal(elem);
            }
        }

        return null;
    }

    fn visibleGlobal(elem: Elem) ?Elem {
        if (elem.isDynType(.Function) and elem.asDyn().asFunction().is_anonymous) {
            return null;
        }
        return elem;
    }

    fn currentScope(self: *Compiler) Scope {
        return self.scopes.items[self.scopes.items.len - 1];
    }

    fn pushScope(self: *Compiler, node: *DependencyGraphNode) !void {
        try self.scopes.append(self.vm.allocator, node);
    }

    fn addGlobal(self: *Compiler, module_id: Module.Id, sid: FrontendStrings.Id, elem: Elem) !void {
        try self.global_map.put(
            self.vm.allocator,
            .{ .module_id = module_id, .name = sid },
            elem,
        );
    }

    pub fn localSlot(self: *Compiler, name: FrontendStrings.Id) ?u8 {
        const scope = self.currentScope();
        for (scope.locals(), 0..) |local, i| {
            if (local == name) return @intCast(i);
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

    fn emitPattern(self: *Compiler, idx: u24, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .destructure = idx }, region);
    }

    fn emitMatchPlan(self: *Compiler, idx: u24, region: Region) !void {
        _ = try self.ir().push(self.vm.allocator, .{ .destructure_plan = idx }, region);
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

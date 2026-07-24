const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const HashMap = std.AutoArrayHashMapUnmanaged;
const Goal = @import("frontend/goal.zig");
pub const Ast = @import("frontend/goal_ast.zig");
const DependencyGraph = @import("frontend/dependency_graph.zig");
const DependencyResolver = @import("frontend/dependency_resolver.zig");
const Module = @import("runtime.zig").Module;
const Parser = @import("frontend/parser.zig").Parser;
pub const StringTable = @import("frontend/string_table.zig").FrontendStringTable;
pub const PathTable = @import("frontend/path_table.zig").PathTable;
const VM = @import("runtime.zig").VM;
const Writers = @import("writer.zig").Writers;
const Region = @import("region.zig").Region;
const std = @import("std");
const call_check = @import("frontend/call_check.zig");
const binding = @import("frontend/goal_binding.zig");

vm: *VM,
allocator: Allocator,
arena: ArenaAllocator,
writers: Writers,
strings: StringTable,
paths: PathTable,
target_module_id: ?Module.Id = null,
resolver: DependencyResolver.Resolver,
// The target module's main anonymous-function graph-node name, if it has
// one. Its body compiles from the module's goal ast like any other
// anonymous function.
main: ?PathTable.Id = null,
// Per-module goal asts, built from the parsed ast during parse; folded
// and classified by the goal binding pass in finalize, once the
// dependency graph is resolved.
goals: std.AutoArrayHashMapUnmanaged(Module.Id, *Goal) = .{},
// Each alias declaration mapped to how its chain resolves. A
// reachable cycle is rejected during resolution; a terminal or dangling
// reference is recorded for the backend. An unused alias in an imported
// module is never compiled, so its cycle is never reported.
alias_resolutions: std.AutoHashMapUnmanaged(GlobalKey, AliasResolution) = .{},
// Diagnostics collected by the goal binding pass, reported as compile
// errors in finalize.
goal_diagnostics: std.ArrayListUnmanaged(binding.Diagnostic) = .{},
// The target module's requested goal print stage; the bound stage can
// only print from finalize.
print_goal_stage: ?Ast.Stage = null,
// Modules every added module implicitly dumps (builtins, then stdlib).
// Registered before a module's own imports so user imports shadow them.
implicit_dumps: std.ArrayListUnmanaged(Module.Id) = .{},
// The imports currently being recursed through, outermost first. A load
// failure reports the failing path literal plus these frames.
import_chain: std.ArrayListUnmanaged(ImportChainEntry) = .{},

pub const AddModuleOpts = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
    printGoalAst: ?Ast.Stage = null,
};

pub const Frontend = @This();

pub const GlobalKey = DependencyGraph.NodeKey;

pub const DependencyGraphNode = DependencyGraph.Node;

pub const ClosureCapture = DependencyGraph.ClosureCapture;

pub const Error = error{
    UnboundVariable,
    NamespacedLocal,
    ImportResolution,
    UnknownModule,
    FunctionCallTypeMismatch,
    AliasCycle,
};

pub const AliasResolution = union(enum) {
    terminal: GlobalKey,
    undefined: DanglingAlias,
};

// A chain link whose body names nothing: the link's key and the name.
pub const DanglingAlias = struct { key: GlobalKey, name: PathTable.Id };

const AliasOutcome = union(enum) {
    terminal: GlobalKey,
    cycle,
    undefined: DanglingAlias,
};

const ImportChainEntry = struct {
    module_id: Module.Id,
    region: Region,
};

// Spelled out (not inferred) because module loading recurses through
// addModule -> registerImports -> addModule. InvalidCharacter and
// Overflow surface from number parsing during goal build.
pub const AddModuleError = Error || Parser.Error || Goal.Error ||
    error{ InvalidCharacter, Overflow };

pub fn init(vm: *VM) !*Frontend {
    const allocator = vm.allocator;
    const frontend = try allocator.create(Frontend);
    frontend.vm = vm;
    frontend.allocator = allocator;
    frontend.arena = ArenaAllocator.init(allocator);
    frontend.writers = vm.writers;
    frontend.strings = StringTable.init(allocator);
    frontend.paths = PathTable.init(allocator);
    frontend.target_module_id = null;
    frontend.main = null;
    frontend.goals = .{};
    frontend.alias_resolutions = .{};
    frontend.goal_diagnostics = .{};
    frontend.print_goal_stage = null;
    frontend.implicit_dumps = .{};
    frontend.import_chain = .{};
    frontend.resolver = DependencyResolver.Resolver.init(&frontend.arena, &frontend.paths, &frontend.strings);
    return frontend;
}

pub fn deinit(self: *Frontend) void {
    self.paths.deinit();
    self.strings.deinit();
    self.arena.deinit();
    self.allocator.destroy(self);
}

pub fn addTargetModule(self: *Frontend, module: Module, opts: AddModuleOpts) AddModuleError!void {
    if (self.target_module_id == null) {
        self.target_module_id = module.id;
    } else {
        @panic("addTargetModule called more than once during compilation");
    }

    self.print_goal_stage = opts.printGoalAst;
    const ast = try self.parse(module, opts);

    try self.resolver.addModule(module, ast);
    try self.applyImplicitDumps(module.id);
    try self.registerImports(module, ast);

    self.main = ast.main_name;
}

pub fn addModule(self: *Frontend, module: Module, opts: AddModuleOpts) AddModuleError!void {
    const ast = try self.parse(module, opts);
    try self.resolver.addModule(module, ast);
    try self.applyImplicitDumps(module.id);
    try self.registerImports(module, ast);
}

// Every module added from here on implicitly dumps `module_id`, before
// its own imports so that user imports shadow the implicit dumps. Implicit
// dumps are private: they grant every module use of builtins and stdlib,
// not the right to re-export them.
pub fn addImplicitDump(self: *Frontend, module_id: Module.Id) !void {
    try self.implicit_dumps.append(self.arena.allocator(), module_id);
}

fn applyImplicitDumps(self: *Frontend, module_id: Module.Id) !void {
    for (self.implicit_dumps.items) |dump_id| {
        try self.resolver.addDump(module_id, dump_id, true);
    }
}

// Load each imported module and wire the import into the resolver. A
// newly loaded module is parsed and registered recursively, depth-first,
// so its own imports load before the importer's next import.
fn registerImports(self: *Frontend, module: Module, ast: *const Ast) AddModuleError!void {
    for (ast.imports.items) |import| {
        const result = switch (import.path) {
            .file => |p| self.vm.loader.getOrLoadFile(p, module.id),
            .stdlib => |p| self.vm.loader.getOrLoadEmbedded(p),
        } catch |err| switch (err) {
            error.OutOfMemory => return error.OutOfMemory,
            error.FileImportUnsupported => {
                try self.printError(module.id, import.region, "file imports are not supported in this build", .{});
                try self.printImportChain();
                return Error.UnknownModule;
            },
            error.ModuleNotFound => {
                const path = switch (import.path) {
                    .file, .stdlib => |p| p,
                };
                try self.printError(module.id, import.region, "cannot find module '{s}'", .{path});
                try self.printImportChain();
                return Error.UnknownModule;
            },
        };

        if (result.newly_loaded) {
            try self.import_chain.append(self.arena.allocator(), .{
                .module_id = module.id,
                .region = import.region,
            });
            try self.addModule(result.module.*, .{});
            _ = self.import_chain.pop();
        }

        switch (import.target) {
            .dump => |dump| try self.resolver.addDump(module.id, result.module.id, dump.private),
            .alias => |alias| try self.resolver.addAlias(
                module.id,
                alias.name,
                result.module.id,
                alias.selector,
                import.region,
            ),
        }
    }
}

// Print the imports that led to the failing one, nearest importer first.
fn printImportChain(self: *Frontend) !void {
    var i = self.import_chain.items.len;
    while (i > 0) {
        i -= 1;
        const entry = self.import_chain.items[i];
        const module = self.vm.getModule(entry.module_id);

        try self.writers.err.print("imported from {s}:", .{module.name});
        try entry.region.printLineRelative(module.source, self.writers.err);
        try self.writers.err.print(":\n", .{});
        try module.highlight(entry.region, self.writers.err);
        try self.writers.err.print("\n", .{});
    }
}

// Register a function that the backend can compile on demand, without a
// source declaration. The name becomes a precompiled node in the dependency
// graph so that identifiers can resolve to it.
pub fn addPrecompiled(self: *Frontend, module_id: Module.Id, name: []const u8) !void {
    const path_id = try self.paths.insert(&self.strings, name);
    try self.resolver.graph.addPrecompiled(self.arena.allocator(), module_id, path_id);
}

// The flat dotted spelling of a path, for messages and runtime interning.
pub fn pathString(self: *const Frontend, path: PathTable.Id) [:0]const u8 {
    return self.strings.get(self.paths.flat(path));
}

// Register an unqualified dump: every public export of the dumped module is
// visible bare in the dumping module. A private dump is not re-exported.
pub fn addModuleDump(
    self: *Frontend,
    module_id: Module.Id,
    target_module: Module.Id,
    private: bool,
) !void {
    try self.resolver.addDump(module_id, target_module, private);
}

// Register a qualified import: names prefixed with the alias resolve among
// the target module's public exports, optionally re-rooted on a selector
// path inside the target.
pub fn addModuleAlias(
    self: *Frontend,
    module_id: Module.Id,
    alias: []const u8,
    target_module: Module.Id,
    selector: ?[]const u8,
    region: Region,
) !void {
    const alias_path = try self.paths.insert(&self.strings, alias);
    const selector_path = if (selector) |s| try self.paths.insert(&self.strings, s) else null;
    try self.resolver.addAlias(module_id, alias_path, target_module, selector_path, region);
}

pub fn finalize(self: *Frontend) !void {
    try self.resolver.resolve();
    try self.reportResolverDiagnostics();
    try self.resolveAliases();
    // Value folding runs after resolution: it can drop an identifier
    // operand the resolver must have already recorded.
    try self.foldGoals();
    try self.lowerGoals();
    try self.analyzeGoalBindings();
    // Print the bound goal (when requested) ahead of any binding error, so
    // a rejected pattern's bound goal is visible above the diagnostic.
    try self.printBoundGoal();
    try self.reportGoalDiagnostics();
    try self.checkFunctionCalls();
}

// Fold every graph node's body, inlining scalar globals. Driven per node
// (not per module) so each fold sees the owning node's dependency edges,
// which distinguish a global reference from a frame local. A referenced
// declaration is folded on demand so its scalar is ready regardless of
// source or module order; the recursion stack guards value self-reference
// (`A = A + 1`), which is not an alias and so escapes resolveAliases.
const FoldStack = std.AutoHashMapUnmanaged(GlobalKey, void);

fn foldGoals(self: *Frontend) !void {
    var stack = FoldStack{};
    defer stack.deinit(self.arena.allocator());
    var iter = self.dependenciesIterator();
    while (iter.next()) |entry| {
        try self.foldNode(entry.key_ptr.*, entry.value_ptr.*, &stack);
    }
}

fn foldNode(self: *Frontend, key: GlobalKey, node: *DependencyGraph.Node, stack: *FoldStack) Goal.FoldError!void {
    // On the stack: currently folding, so a reference back to it leaves
    // the identifier and reads whatever the body holds so far (non-scalar).
    if (stack.contains(key)) return;
    const goal = self.goals.get(key.module_id) orelse return;
    const body: Goal.NodeId = switch (node.*) {
        .precompiled => return,
        .declaration => |*d| d.decl.body,
        .anonymous_function => |*a| a.body,
    };

    try stack.put(self.arena.allocator(), key, {});
    defer _ = stack.remove(key);

    var ctx = FoldCtx{ .frontend = self, .owner = node, .stack = stack };
    try goal.foldBody(body, .{ .ctx = &ctx, .scalarFn = scalarCallback });
}

const FoldCtx = struct {
    frontend: *Frontend,
    owner: *DependencyGraph.Node,
    stack: *FoldStack,
};

fn scalarCallback(ctx_opaque: *anyopaque, name: PathTable.Id) Goal.FoldError!?Goal.ScalarValue {
    const ctx: *FoldCtx = @ptrCast(@alignCast(ctx_opaque));
    return ctx.frontend.scalarGlobal(ctx.owner, name, ctx.stack);
}

// The constant scalar the reference `name` folds to when it resolves to a
// value declaration with a scalar body, else null. Follows alias
// terminals and folds the target on demand before reading its body.
fn scalarGlobal(self: *Frontend, owner: *DependencyGraph.Node, name: PathTable.Id, stack: *FoldStack) Goal.FoldError!?Goal.ScalarValue {
    const target = owner.dependencyNamed(name) orelse return null;
    const terminal = self.foldTerminalKey(target) orelse return null;
    const tnode = self.getNode(terminal);
    if (tnode.* != .declaration) return null;
    const decl = tnode.declaration.decl;
    // A function global (any parameters) is not a value.
    if (decl.params.items.len != 0) return null;

    try self.foldNode(terminal, tnode, stack);
    const tgoal = self.goals.get(terminal.module_id) orelse return null;
    return tgoal.scalarOfBody(decl.body);
}

// Follow an alias declaration to the terminal it names; a non-alias key
// is its own terminal, a dangling alias resolves to nothing.
fn foldTerminalKey(self: *Frontend, key: GlobalKey) ?GlobalKey {
    return switch (self.aliasResolution(key) orelse return key) {
        .terminal => |terminal| terminal,
        .undefined => null,
    };
}

fn lowerGoals(self: *Frontend) !void {
    var iter = self.goals.iterator();
    while (iter.next()) |entry| {
        try entry.value_ptr.*.lowerGoals();
    }

    if (self.print_goal_stage) |stage| {
        if (stage == .folded) {
            if (self.target_module_id) |target| {
                if (self.goals.get(target)) |goal| try goal.print(self.writers.debug, .folded);
            }
        }
    }
}

// Check function calls against callee param kinds on the goal ast: a
// `call` records which arguments are values, a declaration which params
// are, and only parser-invoked callees can mismatch.
fn checkFunctionCalls(self: *Frontend) !void {
    var iter = self.dependenciesIterator();

    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        const Target = struct { ast: *const Ast, body: Ast.NodeId };
        const target: Target = switch (node.*) {
            .precompiled => continue,
            .declaration => |*decl_node| .{ .ast = decl_node.module_ast, .body = decl_node.decl.body },
            .anonymous_function => |*anon| .{ .ast = anon.module_ast, .body = anon.body },
        };

        if (try call_check.checkFunction(self, node, target.ast, target.body)) |diagnostic| {
            switch (diagnostic.expected) {
                .parser => try self.printError(key.module_id, diagnostic.region, "Expected parser but got value", .{}),
                .value => try self.printError(key.module_id, diagnostic.region, "Expected value but got parser", .{}),
            }
            return Error.FunctionCallTypeMismatch;
        }
    }
}

fn analyzeGoalBindings(self: *Frontend) !void {
    var iter = self.goals.iterator();
    while (iter.next()) |entry| {
        try binding.analyzeModule(
            self,
            entry.key_ptr.*,
            &entry.value_ptr.*.ast,
            &self.goal_diagnostics,
        );
        binding.verifyModule(self, entry.key_ptr.*, &entry.value_ptr.*.ast);
    }
}

// Report the binding diagnostics collected by goal binding as compile
// errors. Each diagnostic carries its own module and region.
fn reportGoalDiagnostics(self: *Frontend) !void {
    for (self.goal_diagnostics.items) |diagnostic| {
        const module_id = diagnostic.module_id;
        const region = diagnostic.region;
        switch (diagnostic.kind) {
            .unbound => try self.printError(
                module_id,
                region,
                "variable '{s}' is unbound here",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .out_of_scope => try self.printError(
                module_id,
                region,
                "variable '{s}' is unbound here: its binding is out of scope",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .split => try self.printError(
                module_id,
                region,
                "variable '{s}' may be unbound here: it is not bound on every path",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .unbound_function_var => try self.printError(
                module_id,
                region,
                "variable '{s}' is unbound here: variables in pattern function calls must be bound",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .extra_unbound_part => if (diagnostic.name) |name| try self.printError(
                module_id,
                region,
                "variable '{s}' is unbound here: a merge can solve at most one unbound part",
                .{self.strings.get(name)},
            ) else try self.printError(
                module_id,
                region,
                "pattern part is unbound here: a merge can solve at most one unbound part",
                .{},
            ),
        }
    }

    if (self.goal_diagnostics.items.len > 0) return Error.UnboundVariable;
}

fn printBoundGoal(self: *Frontend) !void {
    const stage = self.print_goal_stage orelse return;
    if (stage != .bound) return;
    const target = self.target_module_id orelse return;
    const goal = self.goals.get(target) orelse return;
    try goal.print(self.writers.debug, .bound);
}

fn reportResolverDiagnostics(self: *Frontend) !void {
    for (self.resolver.diagnostics.items) |diagnostic| {
        switch (diagnostic.tag) {
            .namespaced_local => try self.printError(
                diagnostic.module_id,
                diagnostic.region,
                "'{s}' is undefined: namespaced names cannot be local variables",
                .{self.pathString(diagnostic.name)},
            ),
            .alias_kind_mismatch => try self.printError(
                diagnostic.module_id,
                diagnostic.region,
                "alias '{s}' does not match the kind of '{s}': a lowercase alias imports parsers, an uppercase alias imports values",
                .{ self.pathString(diagnostic.alias.?), self.pathString(diagnostic.name) },
            ),
            .member_kind_mismatch => try self.printError(
                diagnostic.module_id,
                diagnostic.region,
                "'{s}' does not match the kind of alias '{s}': a lowercase alias imports parsers, an uppercase alias imports values",
                .{ self.pathString(diagnostic.name), self.pathString(diagnostic.alias.?) },
            ),
            .no_such_member => try self.printError(
                diagnostic.module_id,
                diagnostic.region,
                "'{s}' is not exported by the module imported as '{s}'",
                .{ self.pathString(diagnostic.name), self.pathString(diagnostic.alias.?) },
            ),
            .private_member => try self.printError(
                diagnostic.module_id,
                diagnostic.region,
                "'{s}' is private to the module imported as '{s}'",
                .{ self.pathString(diagnostic.name), self.pathString(diagnostic.alias.?) },
            ),
        }
    }

    const diagnostics = self.resolver.diagnostics.items;
    if (diagnostics.len > 0) {
        return switch (diagnostics[0].tag) {
            .namespaced_local => Error.NamespacedLocal,
            else => Error.ImportResolution,
        };
    }
}

// Walk every alias declaration's chain to its terminal — the first
// declaration on the chain that is not itself a bare-identifier alias: a
// function, an inlinable value, or a precompiled builtin. A cycle or
// dangling reference is a compile error, but only for a reachable alias:
// an unused alias in an imported module is never compiled and so never fails.
fn resolveAliases(self: *Frontend) !void {
    var reachable = try self.reachableNodes();
    defer reachable.deinit(self.arena.allocator());

    var iter = self.dependenciesIterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        if (node.* != .declaration) continue;
        const ast = &self.goals.get(key.module_id).?.ast;
        if (ast.aliasTargetName(node.declaration.decl) == null) continue;

        switch (try self.aliasOutcomeFor(key)) {
            .terminal => |terminal| try self.alias_resolutions.put(self.arena.allocator(), key, .{ .terminal = terminal }),
            .undefined => |u| try self.alias_resolutions.put(self.arena.allocator(), key, .{ .undefined = u }),
            // A cycle is a hard error, but only for a reachable alias: an
            // unused cyclic alias in an imported module never compiles.
            .cycle => {
                if (!reachable.contains(key)) continue;
                const decl = node.declaration.decl;
                try self.printError(key.module_id, decl.region, "Circular alias dependency detected for '{s}'", .{self.pathString(key.name)});
                return Error.AliasCycle;
            },
        }
    }
}

fn aliasOutcomeFor(self: *Frontend, alias_key: GlobalKey) !AliasOutcome {
    var path = std.AutoHashMapUnmanaged(GlobalKey, void){};
    defer path.deinit(self.arena.allocator());

    var key = alias_key;
    while (true) {
        const node = self.getNode(key);
        if (node.* != .declaration) return .{ .terminal = key };

        const ast = &self.goals.get(key.module_id).?.ast;
        const chain_name = ast.aliasTargetName(node.declaration.decl) orelse
            return .{ .terminal = key };

        const next = node.dependencyNamed(chain_name) orelse
            return .{ .undefined = .{ .key = key, .name = chain_name } };

        if (try path.fetchPut(self.arena.allocator(), key, {})) |_| return .cycle;
        key = next;
    }
}

// The set of graph nodes the backend will compile: every declaration in
// the target module (compiled whether or not it is used), plus main, plus
// everything reachable from those through dependency edges.
fn reachableNodes(self: *Frontend) !std.AutoHashMapUnmanaged(GlobalKey, void) {
    var reachable = std.AutoHashMapUnmanaged(GlobalKey, void){};
    var stack = std.ArrayListUnmanaged(GlobalKey){};
    defer stack.deinit(self.arena.allocator());

    const target = self.target_module_id orelse return reachable;

    var iter = self.dependenciesIterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        if (key.module_id == target and entry.value_ptr.*.* == .declaration) {
            try stack.append(self.arena.allocator(), key);
        }
    }
    if (self.main) |main_name| {
        try stack.append(self.arena.allocator(), .{ .module_id = target, .name = main_name });
    }

    while (stack.pop()) |key| {
        if ((try reachable.fetchPut(self.arena.allocator(), key, {})) != null) continue;
        for (self.getNode(key).dependencies()) |edge| {
            try stack.append(self.arena.allocator(), edge.target);
        }
    }
    return reachable;
}

// How an alias declaration's chain resolves, or null if the key is not an
// alias. A cyclic alias has no entry: a reachable one aborted compilation,
// and an unreachable one is never queried.
pub fn aliasResolution(self: *Frontend, key: GlobalKey) ?AliasResolution {
    return self.alias_resolutions.get(key);
}

pub fn getNode(self: *Frontend, key: GlobalKey) *DependencyGraph.Node {
    return self.resolver.graph.nodes.get(key).?;
}

pub fn findNode(self: *Frontend, module_id: Module.Id, name: PathTable.Id) ?*DependencyGraph.Node {
    const key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };
    return self.resolver.graph.nodes.get(key);
}

pub fn dependenciesIterator(self: *Frontend) HashMap(DependencyGraph.NodeKey, *DependencyGraph.Node).Iterator {
    return self.resolver.graph.nodes.iterator();
}

fn parse(self: *Frontend, module: Module, opts: AddModuleOpts) !*const Ast {
    // The goal ast is built directly from the parsed ast and feeds the
    // dependency resolver, call check, and backend. Folding is deferred to
    // finalize, after resolution: value folding can drop an identifier
    // operand (`_ * X`) that the resolver must first see. Binding then
    // classifies the folded goal in finalize.
    const goal = try self.arena.allocator().create(Goal);
    goal.* = Goal.init(&self.arena, self.writers, &self.strings, &self.paths, module);

    if (module.source.len > 0) {
        var parser = Parser.init(&self.arena, module, self.writers, .{
            .printScanner = opts.printScanner,
            .printParser = opts.printParser,
        });
        try parser.parse();

        if (opts.printAst) {
            try parser.ast.print(
                self.writers.debug,
                module.source,
            );
        }

        try goal.build(parser.ast);
        if (opts.printGoalAst) |stage| {
            if (stage == .created) try goal.print(self.writers.debug, .created);
        }
    }

    try self.goals.put(self.arena.allocator(), module.id, goal);
    return &goal.ast;
}

fn printError(self: *Frontend, module_id: Module.Id, region: Region, comptime message: []const u8, args: anytype) !void {
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

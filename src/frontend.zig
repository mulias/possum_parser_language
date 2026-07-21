const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const HashMap = std.AutoArrayHashMapUnmanaged;
const Can = @import("frontend/can.zig");
pub const Ast = @import("frontend/can_ast.zig");
const DependencyGraph = @import("frontend/dependency_graph.zig");
const DependencyResolver = @import("frontend/dependency_resolver.zig");
const Goal = @import("frontend/goal.zig");
const GoalAst = @import("frontend/goal_ast.zig");
const Module = @import("runtime.zig").Module;
const Parser = @import("frontend/parser.zig").Parser;
pub const StringTable = @import("frontend/string_table.zig").FrontendStringTable;
pub const PathTable = @import("frontend/path_table.zig").PathTable;
const VM = @import("runtime.zig").VM;
const Writers = @import("writer.zig").Writers;
const Region = @import("region.zig").Region;
const std = @import("std");
const binding = @import("frontend/binding.zig");
const call_check = @import("frontend/call_check.zig");
const goal_binding = @import("frontend/goal_binding.zig");

vm: *VM,
allocator: Allocator,
arena: ArenaAllocator,
writers: Writers,
strings: StringTable,
paths: PathTable,
target_module_id: ?Module.Id = null,
resolver: DependencyResolver.Resolver,
main: ?*Ast.RNode(Ast.Parser.AnonymousFunction) = null,
binding_maps: binding.Maps = .{},
// Per-module goal asts, built from unfolded can during parse and folded
// immediately; the goal binding pass classifies them in finalize, once
// the dependency graph is resolved.
goals: std.AutoArrayHashMapUnmanaged(Module.Id, *Goal) = .{},
// Diagnostics from the goal binding pass. Not reported as errors:
// can-binding remains the reporter until the compiler consumes goal, and
// finalize asserts these are empty whenever can-binding succeeds. They
// print to the debug writer with the bound goal so cram tests can see
// them.
goal_diagnostics: std.ArrayListUnmanaged(goal_binding.Diagnostic) = .{},
// The target module's requested goal print stage; the bound stage can
// only print from finalize.
print_goal_stage: ?GoalAst.Stage = null,
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
    printGoalAst: ?GoalAst.Stage = null,
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
};

const ImportChainEntry = struct {
    module_id: Module.Id,
    region: Region,
};

// Spelled out (not inferred) because module loading recurses through
// addModule -> registerImports -> addModule. InvalidCharacter and
// Overflow surface from number parsing during canonicalization.
pub const AddModuleError = Error || Can.Error || Parser.Error || Goal.Error ||
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
    frontend.binding_maps = .{};
    frontend.goals = .{};
    frontend.goal_diagnostics = .{};
    frontend.print_goal_stage = null;
    frontend.implicit_dumps = .{};
    frontend.import_chain = .{};
    frontend.resolver = DependencyResolver.Resolver.init(&frontend.arena, &frontend.paths, &frontend.strings);
    return frontend;
}

pub fn deinit(self: *Frontend) void {
    self.binding_maps.deinit(self.allocator);
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

    if (ast.main) |main_ast| {
        self.main = main_ast;
    }
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
fn registerImports(self: *Frontend, module: Module, ast: Ast) AddModuleError!void {
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
    // try self.resolver.prune();
    try self.analyzeGoalBindings();
    // Before can-binding, so newly-schedulable patterns can-binding
    // still rejects (fixpoint-ordered constraints) print their bound
    // goal ahead of the can error.
    try self.printBoundGoal();
    try self.analyzeBindings();
    self.checkGoalBindingParity();
    try self.checkFunctionCalls();
    // try self.analyzeLiveness();
}

// Check parser function calls against callee param kinds on the can ast,
// where arguments still carry their surface parser-or-value kind; the goal
// ast the backend compiles from has erased it.
fn checkFunctionCalls(self: *Frontend) !void {
    var iter = self.dependenciesIterator();

    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        const body = switch (node.*) {
            .precompiled => continue,
            .declaration => |*decl_node| switch (decl_node.ast) {
                .parser => |p| p.node.body,
                .value => continue,
            },
            .anonymous_function => |*anon| anon.ast.node.body,
        };

        if (try call_check.checkParserFunction(self, node, body)) |diagnostic| {
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
        try goal_binding.analyzeModule(
            self,
            entry.key_ptr.*,
            &entry.value_ptr.*.ast,
            &self.goal_diagnostics,
        );
        goal_binding.verifyModule(self, entry.key_ptr.*, &entry.value_ptr.*.ast);
    }
}

// Differential check while both binding passes coexist: can-binding
// succeeded (analyzeBindings returned without error), so any goal
// diagnostic is a bug in the goal pass.
fn checkGoalBindingParity(self: *Frontend) void {
    if (!std.debug.runtime_safety) return;
    if (self.goal_diagnostics.items.len == 0) return;
    for (self.goal_diagnostics.items) |diagnostic| {
        std.debug.print("goal binding diagnostic without can counterpart: {s} '{s}'\n", .{
            @tagName(diagnostic.kind),
            if (diagnostic.name) |name| self.strings.get(name) else "?",
        });
    }
    @panic("goal binding diagnostics diverge from can binding");
}

fn printBoundGoal(self: *Frontend) !void {
    const stage = self.print_goal_stage orelse return;
    if (stage != .bound) return;
    const target = self.target_module_id orelse return;
    const goal = self.goals.get(target) orelse return;
    try goal.print(self.writers.debug);
    try self.printGoalDiagnostics();
}

// Goal binding diagnostics print with the bound goal, mirroring
// reportBindingDiagnostics' messages, so cram tests can see what goal
// binding diagnosed while can-binding remains the error reporter.
fn printGoalDiagnostics(self: *Frontend) !void {
    const writer = self.writers.debug;
    for (self.goal_diagnostics.items) |diagnostic| {
        const name: []const u8 = if (diagnostic.name) |n| self.strings.get(n) else "";
        try writer.print("\ngoal diagnostic: ", .{});
        switch (diagnostic.kind) {
            .unbound => try writer.print(
                "variable '{s}' is unbound here",
                .{name},
            ),
            .out_of_scope => try writer.print(
                "variable '{s}' is unbound here: its binding is out of scope",
                .{name},
            ),
            .split => try writer.print(
                "variable '{s}' may be unbound here: it is not bound on every path",
                .{name},
            ),
            .unbound_function_var => try writer.print(
                "variable '{s}' is unbound here: variables in pattern function calls must be bound",
                .{name},
            ),
            .extra_unbound_part => if (diagnostic.name != null) try writer.print(
                "variable '{s}' is unbound here: a merge can solve at most one unbound part",
                .{name},
            ) else try writer.print(
                "pattern part is unbound here: a merge can solve at most one unbound part",
                .{},
            ),
        }
        const module = self.vm.getModule(diagnostic.module_id);
        try writer.print("\n{s}:", .{module.name});
        try diagnostic.region.printLineRelative(module.source, writer);
        try writer.print(":\n", .{});
        try module.highlight(diagnostic.region, writer);
        try writer.print("\n", .{});
    }
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

pub fn getNode(self: *Frontend, key: GlobalKey) *DependencyGraph.Node {
    return self.resolver.graph.nodes.get(key).?;
}

pub fn getDeclaration(self: *Frontend, key: GlobalKey) Ast.ParserOrValue.Declaration {
    return self.getNode(key).declaration.ast;
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

fn parse(self: *Frontend, module: Module, opts: AddModuleOpts) !Ast {
    var can = Can.init(&self.arena, self.writers, &self.strings, &self.paths, module);

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

        _ = try can.canonicalize(parser.ast);

        // The goal ast is built from unfolded can; folding is a separate
        // pass on each representation. Binding classifies the goal in
        // finalize, once the dependency graph is resolved.
        const goal = try self.arena.allocator().create(Goal);
        goal.* = Goal.init(&self.arena, self.writers, &self.strings, &self.paths, module);
        try goal.actualize(can);
        if (opts.printGoalAst) |stage| {
            if (stage == .created) try goal.print(self.writers.debug);
        }
        try goal.fold();
        if (opts.printGoalAst) |stage| {
            if (stage == .folded) try goal.print(self.writers.debug);
        }
        try self.goals.put(self.arena.allocator(), module.id, goal);

        try can.foldConstants();
    }

    return can.ast;
}

fn analyzeBindings(self: *Frontend) !void {
    var iter = self.dependenciesIterator();

    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        switch (node.*) {
            .precompiled => {},
            .declaration => |*decl_node| switch (decl_node.ast) {
                .parser => |p| try self.analyzeParserBindings(
                    key.module_id,
                    node,
                    p.node.body,
                    p.node.params.items.len,
                    &.{},
                ),
                .value => |v| try self.analyzeValueBindings(
                    key.module_id,
                    node,
                    v.node.body,
                    v.node.params.items.len,
                ),
            },
            .anonymous_function => |*anon| try self.analyzeParserBindings(
                key.module_id,
                node,
                anon.ast.node.body,
                0,
                anon.closure_captures.items,
            ),
        }
    }
}

fn analyzeParserBindings(
    self: *Frontend,
    module_id: Module.Id,
    node: *DependencyGraphNode,
    body: *Ast.Parser.RNode,
    arity: usize,
    captures: []const Frontend.ClosureCapture,
) !void {
    var result = try binding.analyzeParserFunction(self, module_id, node, body, arity, captures);
    defer result.deinit(self.vm.allocator);
    try self.reportBindingDiagnostics(module_id, result.diagnostics.items);
}

fn analyzeValueBindings(
    self: *Frontend,
    module_id: Module.Id,
    node: *DependencyGraphNode,
    body: *Ast.Value.RNode,
    arity: usize,
) !void {
    var result = try binding.analyzeValueFunction(self, module_id, node, body, arity);
    defer result.deinit(self.vm.allocator);
    try self.reportBindingDiagnostics(module_id, result.diagnostics.items);
}

fn reportBindingDiagnostics(self: *Frontend, module_id: Module.Id, diagnostics: []const binding.Diagnostic) !void {
    for (diagnostics) |diagnostic| {
        switch (diagnostic.kind) {
            .unbound => try self.printError(
                module_id,
                diagnostic.region,
                "variable '{s}' is unbound here",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .out_of_scope => try self.printError(
                module_id,
                diagnostic.region,
                "variable '{s}' is unbound here: its binding is out of scope",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .split => try self.printError(
                module_id,
                diagnostic.region,
                "variable '{s}' may be unbound here: it is not bound on every path",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .unbound_function_var => try self.printError(
                module_id,
                diagnostic.region,
                "variable '{s}' is unbound here: variables in pattern function calls must be bound",
                .{self.strings.get(diagnostic.name.?)},
            ),
            .extra_unbound_part => if (diagnostic.name) |name| try self.printError(
                module_id,
                diagnostic.region,
                "variable '{s}' is unbound here: a merge can solve at most one unbound part",
                .{self.strings.get(name)},
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

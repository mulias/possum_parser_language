const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const HashMap = std.AutoArrayHashMapUnmanaged;
const Can = @import("frontend/can.zig");
pub const Ast = @import("frontend/can_ast.zig");
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
const binding = @import("frontend/binding.zig");

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

pub const AddModuleOpts = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
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
};

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

pub fn addTargetModule(self: *Frontend, module: Module, opts: AddModuleOpts) !void {
    if (self.target_module_id == null) {
        self.target_module_id = module.id;
    } else {
        @panic("addTargetModule called more than once during compilation");
    }

    const ast = try self.parse(module, opts);

    try self.resolver.addModule(module, ast);
    try self.registerImports(module, ast);

    if (ast.main) |main_ast| {
        self.main = main_ast;
    }
}

pub fn addModule(self: *Frontend, module: Module, opts: AddModuleOpts) !void {
    const ast = try self.parse(module, opts);
    try self.resolver.addModule(module, ast);
    try self.registerImports(module, ast);
}

// Wire the module's import declarations into the resolver. Import paths
// resolve against modules the embedder has already created; the module
// loader will later create modules on demand.
fn registerImports(self: *Frontend, module: Module, ast: Ast) !void {
    for (ast.imports.items) |import| {
        const path = switch (import.path) {
            .file, .stdlib => |p| p,
        };
        const target = self.vm.findModule(path) orelse {
            try self.printError(module.id, import.region, "cannot find module '{s}'", .{path});
            return Error.UnknownModule;
        };
        switch (import.target) {
            .dump => try self.resolver.addDump(module.id, target.id),
            .alias => |alias| try self.resolver.addAlias(
                module.id,
                alias.name,
                target.id,
                alias.selector,
                import.region,
            ),
        }
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
// visible bare in the dumping module.
pub fn addModuleDump(
    self: *Frontend,
    module_id: Module.Id,
    target_module: Module.Id,
) !void {
    try self.resolver.addDump(module_id, target_module);
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
    try self.analyzeBindings();
    // try self.analyzeLiveness();
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

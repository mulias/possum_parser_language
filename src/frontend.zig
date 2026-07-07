const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const HashMap = std.AutoArrayHashMapUnmanaged;
const Can = @import("frontend/can.zig");
const CanAst = @import("frontend/can_ast.zig");
const DependencyGraph = @import("frontend/dependency_graph.zig");
const DependencyResolver = @import("frontend/dependency_resolver.zig");
const Module = @import("module.zig").Module;
const Parser = @import("frontend/parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable(.frontend);
const Writers = @import("writer.zig").Writers;
const std = @import("std");

allocator: Allocator,
arena: ArenaAllocator,
writers: Writers,
strings: StringTable,
target_module_id: ?Module.Id = null,
resolver: DependencyResolver.Resolver,
main: ?*Ast.RNode(Ast.Parser.AnonymousFunction) = null,

pub const AddModuleOpts = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
};

pub const Frontend = @This();

pub const Ast = CanAst;

pub const GlobalKey = DependencyGraph.NodeKey;

pub const DependencyGraphNode = DependencyGraph.Node;

pub const ClosureCapture = DependencyGraph.ClosureCapture;

pub fn init(allocator: Allocator, writers: Writers) !*Frontend {
    const frontend = try allocator.create(Frontend);
    frontend.allocator = allocator;
    frontend.arena = ArenaAllocator.init(allocator);
    frontend.writers = writers;
    frontend.strings = StringTable.init(allocator);
    frontend.target_module_id = null;
    frontend.main = null;
    frontend.resolver = DependencyResolver.Resolver.init(&frontend.arena);
    return frontend;
}

pub fn deinit(self: *Frontend) void {
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

    if (ast.main) |main_ast| {
        self.main = main_ast;
    }
}

pub fn addModule(self: *Frontend, module: Module, opts: AddModuleOpts) !void {
    const ast = try self.parse(module, opts);
    try self.resolver.addModule(module, ast);
}

// Register a function that the backend can compile on demand, without a
// source declaration. The name becomes a precompiled node in the dependency
// graph so that identifiers can resolve to it.
pub fn addPrecompiled(self: *Frontend, module_id: Module.Id, name: []const u8) !void {
    const sid = try self.strings.insert(name);
    try self.resolver.graph.addPrecompiled(self.arena.allocator(), module_id, sid);
}

pub fn addModuleDependency(
    self: *Frontend,
    module_id: Module.Id,
    dependency_id: Module.Id,
) !void {
    try self.resolver.addModuleDependency(module_id, dependency_id);
}

pub fn finalize(self: *Frontend) !void {
    try self.resolver.resolve();
}

pub fn getNode(self: *Frontend, key: GlobalKey) *DependencyGraph.Node {
    return self.resolver.graph.nodes.get(key).?;
}

pub fn getDeclaration(self: *Frontend, key: GlobalKey) Ast.ParserOrValue.Declaration {
    return self.getNode(key).declaration.ast;
}

pub fn findNode(self: *Frontend, module_id: Module.Id, name: StringTable.Id) ?*DependencyGraph.Node {
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
    var can = Can.init(&self.arena, self.writers, &self.strings, module);

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

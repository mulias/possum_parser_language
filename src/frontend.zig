const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const Can = @import("frontend/can.zig");
const Ast = @import("frontend/can_ast.zig");
const DependencyGraph = @import("frontend/dependency_graph.zig");
const DependencyResolver = @import("frontend/dependency_resolver.zig");
const HashMap = std.AutoHashMapUnmanaged;
const Module = @import("module.zig").Module;
const Parser = @import("frontend/parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const Writers = @import("writer.zig").Writers;
const std = @import("std");

allocator: Allocator,
arena: ArenaAllocator,
writers: Writers,
strings: *StringTable,
target_module_id: ?Module.Id = null,
resolver: DependencyResolver.Resolver,
main: ?*Ast.RNode(Ast.Parser.AnonymousFunction) = null,

pub const AddModuleOpts = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
};

pub const Frontend = @This();

pub const GlobalKey = DependencyGraph.NodeKey;

pub fn init(allocator: Allocator, strings: *StringTable, writers: Writers) !*Frontend {
    const frontend = try allocator.create(Frontend);
    frontend.allocator = allocator;
    frontend.arena = ArenaAllocator.init(allocator);
    frontend.writers = writers;
    frontend.strings = strings;
    frontend.target_module_id = null;
    frontend.main = null;
    frontend.resolver = DependencyResolver.Resolver.init(&frontend.arena);
    return frontend;
}

pub fn deinit(self: *Frontend) void {
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

pub const DeclarationsIterator = struct {
    module_id: Module.Id,
    iter: HashMap(DependencyGraph.NodeKey, *DependencyGraph.Node).Iterator,

    pub fn next(self: *DeclarationsIterator) ?GlobalKey {
        while (self.iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const node = entry.value_ptr.*;
            if (key.module_id == self.module_id and node.* == .declaration) {
                return key;
            }
        }
        return null;
    }
};

pub fn declarationsIterator(self: *Frontend, module_id: Module.Id) DeclarationsIterator {
    return DeclarationsIterator{
        .module_id = module_id,
        .iter = self.resolver.graph.nodes.iterator(),
    };
}

pub fn getNode(self: *Frontend, key: GlobalKey) *DependencyGraph.Node {
    return self.resolver.graph.nodes.get(key).?;
}

pub fn getDeclaration(self: *Frontend, key: GlobalKey) Ast.ParserOrValue.Declaration {
    return self.getNode(key).declaration.ast;
}

pub fn getDependency(self: *Frontend, key: GlobalKey, dep_name: StringTable.Id) DependencyGraph.Node {
    switch (self.resolver.graph.get(key)) {
        .precompiled => unreachable,
        .declaration => |decl_node| {
            for (decl_node.dependencies) |dep| {
                if (dep.name == dep_name) {
                    return self.resolver.graph.get(dep);
                }
            }
            unreachable;
        },
        .anonymous_function => |anon_node| {
            for (anon_node.dependencies) |dep| {
                if (dep.name == dep_name) {
                    return self.resolver.graph.get(dep);
                }
            }
            unreachable;
        },
    }
}

pub fn getDependencyKeys(self: *Frontend, module_id: Module.Id, name: StringTable.Id) []const DependencyGraph.NodeKey {
    const key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };
    if (self.resolver.graph.nodes.get(key)) |node| {
        return switch (node.*) {
            .precompiled => &[_]DependencyGraph.NodeKey{},
            .declaration => |n| n.dependencies.items,
            .anonymous_function => |n| n.dependencies.items,
        };
    }
    return &[_]DependencyGraph.NodeKey{};
}

pub fn getGraphNode(self: *Frontend, module_id: Module.Id, name: StringTable.Id) ?*DependencyGraph.Node {
    const key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };
    return self.resolver.graph.nodes.get(key);
}

fn parse(self: *Frontend, module: Module, opts: AddModuleOpts) !Ast {
    var can = Can.init(&self.arena, self.writers, self.strings, module);

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

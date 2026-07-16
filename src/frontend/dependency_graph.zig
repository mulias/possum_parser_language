const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoArrayHashMapUnmanaged;
const StringTable = @import("string_table.zig").FrontendStringTable;
const PathTable = @import("path_table.zig").PathTable;
const Ast = @import("can_ast.zig");
const Writer = std.Io.Writer;
const Module = @import("../runtime.zig").Module;

nodes: HashMap(NodeKey, *Node) = .{},

const Graph = @This();

pub const NodeKey = struct {
    module_id: Module.Id,
    name: PathTable.Id,
};

// A dependency edge records both the name as written at the use site and the
// declaration it resolved to. The two differ when resolution rewrites the
// name, e.g. a qualified import's alias prefix.
pub const Edge = struct {
    ref: PathTable.Id,
    target: NodeKey,
};

pub const ClosureCapture = struct {
    parent_name: PathTable.Id,
    local: StringTable.Id,
};

pub const Node = union(enum) {
    precompiled,
    declaration: DeclarationNode,
    anonymous_function: AnonymousFunctionNode,

    pub fn locals(self: *const Node) []const StringTable.Id {
        return switch (self.*) {
            .precompiled => &.{},
            .declaration => |*n| n.locals.items,
            .anonymous_function => |*n| n.locals.items,
        };
    }

    pub fn dependencies(self: *const Node) []const Edge {
        return switch (self.*) {
            .precompiled => &.{},
            .declaration => |*n| n.dependencies.items,
            .anonymous_function => |*n| n.dependencies.items,
        };
    }

    pub fn dependencyNamed(self: *const Node, ref: PathTable.Id) ?NodeKey {
        for (self.dependencies()) |edge| {
            if (edge.ref == ref) return edge.target;
        }
        return null;
    }

    // Whether the declaration is private to its module: an underscored name
    // is never visible through an import. Precompiled builtins are public;
    // anonymous functions are unreachable by name regardless.
    pub fn isPrivate(self: *const Node) bool {
        return switch (self.*) {
            .precompiled => false,
            .declaration => |*n| n.ast.identUnderscored(),
            .anonymous_function => false,
        };
    }

    pub fn localsList(self: *Node) *ArrayList(StringTable.Id) {
        return switch (self.*) {
            .precompiled => unreachable,
            .declaration => |*n| &n.locals,
            .anonymous_function => |*n| &n.locals,
        };
    }

    pub fn dependenciesList(self: *Node) *ArrayList(Edge) {
        return switch (self.*) {
            .precompiled => unreachable,
            .declaration => |*n| &n.dependencies,
            .anonymous_function => |*n| &n.dependencies,
        };
    }
};

pub const DeclarationNode = struct {
    ast: Ast.ParserOrValue.Declaration,
    dependencies: ArrayList(Edge) = .{},
    locals: ArrayList(StringTable.Id) = .{},
};

pub const AnonymousFunctionNode = struct {
    ast: *Ast.RNode(Ast.Parser.AnonymousFunction),
    dependencies: ArrayList(Edge) = .{},
    locals: ArrayList(StringTable.Id) = .{},
    closure_captures: ArrayList(ClosureCapture) = .{},

    pub fn parent(self: *const AnonymousFunctionNode) ?PathTable.Id {
        return self.ast.node.parent_name;
    }
};

pub fn addModule(self: *Graph, allocator: Allocator, module: Module, ast: Ast) !void {
    for (ast.declarations.items) |decl| {
        try self.addNode(
            allocator,
            module.id,
            decl.identName(),
            .{ .declaration = .{
                .ast = decl,
            } },
        );
    }

    // `main` is included here too: the canonicalizer appends it to
    // anonymous_functions, so it is added as a regular anonymous function
    // node (with a null parent).
    for (ast.anonymous_functions.items) |anon| {
        try self.addNode(
            allocator,
            module.id,
            anon.node.name,
            .{ .anonymous_function = .{
                .ast = anon,
            } },
        );
    }
}

pub fn addPrecompiled(self: *Graph, allocator: Allocator, module_id: Module.Id, name: PathTable.Id) !void {
    try self.addNode(allocator, module_id, name, .precompiled);
}

fn addNode(self: *Graph, allocator: Allocator, module_id: Module.Id, name: PathTable.Id, fields: Node) !void {
    const key = NodeKey{ .module_id = module_id, .name = name };

    const node = try allocator.create(Node);
    node.* = fields;

    const entry = try self.nodes.getOrPut(allocator, key);
    // The canonicalizer rejects duplicate declarations and user-written
    // @-names, and generated anonymous function names are unique, so a
    // key can never be added twice.
    std.debug.assert(!entry.found_existing);
    entry.value_ptr.* = node;
}

pub fn print(self: *const Graph, strings: StringTable, paths: PathTable, writer: *Writer) !void {
    try writer.print("\n=== Dependency Graph ===\n", .{});
    try writer.print("Total nodes: {}\n\n", .{self.nodes.count()});

    var iter = self.nodes.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        const name_str = strings.get(paths.flat(key.name));
        try writer.print("{}:{s}", .{ key.module_id, name_str });

        try writer.print(" locals=[", .{});
        for (node.locals(), 0..) |local, i| {
            const local_name = strings.get(local);
            if (i > 0) try writer.print(", ", .{});
            try writer.print("{s}", .{local_name});
        }
        try writer.print("]", .{});

        try writer.print(" deps=[", .{});
        for (node.dependencies(), 0..) |edge, i| {
            const ref_name = strings.get(paths.flat(edge.ref));
            const target_name = strings.get(paths.flat(edge.target.name));
            if (i > 0) try writer.print(", ", .{});
            try writer.print("{s}->{}:{s}", .{ ref_name, edge.target.module_id, target_name });
        }
        try writer.print("]", .{});

        if (node.* == .anonymous_function) {
            const anon = node.anonymous_function;

            try writer.print(" captures=[", .{});
            for (anon.closure_captures.items, 0..) |capture, i| {
                if (i > 0) try writer.print(", ", .{});
                const parent_name = strings.get(paths.flat(capture.parent_name));
                const local_name = strings.get(capture.local);
                try writer.print("{}:{s}:{s}", .{ key.module_id, parent_name, local_name });
            }
            try writer.print("]", .{});

            try writer.print(" parent=", .{});
            if (anon.parent()) |parent_name| {
                const parent_name_str = strings.get(paths.flat(parent_name));
                try writer.print("{}:{s}", .{ key.module_id, parent_name_str });
            } else {
                try writer.print("null", .{});
            }
        }

        try writer.print("\n", .{});
    }

    try writer.print("\n", .{});
}

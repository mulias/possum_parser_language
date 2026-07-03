const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoHashMapUnmanaged;
const StringTable = @import("../string_table.zig").StringTable;
const Ast = @import("can_ast.zig");
const Writer = std.Io.Writer;
const Module = @import("../module.zig").Module;

nodes: HashMap(NodeKey, *Node) = .{},

const Graph = @This();

pub const NodeKey = struct {
    module_id: Module.Id,
    name: StringTable.Id,
};

pub const ClosureCapture = struct {
    parent_name: StringTable.Id,
    local: StringTable.Id,
};

pub const Node = union(enum) {
    precompiled,
    declaration: DeclarationNode,
    anonymous_function: AnonymousFunctionNode,
};

pub const DeclarationNode = struct {
    ast: Ast.ParserOrValue.Declaration,
    dependencies: ArrayList(NodeKey) = .{},
    locals: ArrayList(StringTable.Id) = .{},
};

pub const AnonymousFunctionNode = struct {
    ast: *Ast.RNode(Ast.Parser.AnonymousFunction),
    dependencies: ArrayList(NodeKey) = .{},
    locals: ArrayList(StringTable.Id) = .{},
    closure_captures: ArrayList(ClosureCapture) = .{},
    parent: ?StringTable.Id = null,
};

pub fn addModule(self: *Graph, allocator: Allocator, module: Module, ast: Ast) !void {
    // Include precompiled functions
    for (module.constants.items) |compiled_elem| {
        if (compiled_elem.isDynType(.Function)) {
            try self.addNode(
                allocator,
                module.id,
                compiled_elem.asDyn().asFunction().name,
                .{ .precompiled = undefined },
            );
        }
    }

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

    for (ast.anonymous_functions.items) |anon| {
        try self.addNode(
            allocator,
            module.id,
            anon.node.name,
            .{ .anonymous_function = .{
                .ast = anon,
                .parent = anon.node.parent_name,
            } },
        );
    }

    if (ast.main) |main| {
        try self.addNode(
            allocator,
            module.id,
            main.node.name,
            .{ .anonymous_function = .{
                .ast = main,
            } },
        );
    }
}

fn addNode(self: *Graph, allocator: Allocator, module_id: Module.Id, name: StringTable.Id, fields: Node) !void {
    const key = NodeKey{ .module_id = module_id, .name = name };

    const node = try allocator.create(Node);
    node.* = fields;

    try self.nodes.put(allocator, key, node);
}

pub fn print(self: *const Graph, strings: StringTable, writer: *Writer) !void {
    try writer.print("\n=== Dependency Graph ===\n", .{});
    try writer.print("Total nodes: {}\n\n", .{self.nodes.count()});

    var iter = self.nodes.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;
        const name_str = strings.get(key.name);
        try writer.print("{}:{s}", .{ key.module_id, name_str });

        const locals = switch (node.*) {
            .precompiled => &[_]StringTable.Id{},
            .declaration => |n| n.locals.items,
            .anonymous_function => |n| n.locals.items,
        };
        const dependencies = switch (node.*) {
            .precompiled => &[_]NodeKey{},
            .declaration => |n| n.dependencies.items,
            .anonymous_function => |n| n.dependencies.items,
        };

        try writer.print(" locals=[", .{});
        for (locals, 0..) |local, i| {
            const local_name = strings.get(local);
            if (i > 0) try writer.print(", ", .{});
            try writer.print("{s}", .{local_name});
        }
        try writer.print("]", .{});

        try writer.print(" deps=[", .{});
        for (dependencies, 0..) |dep, i| {
            const dep_name = strings.get(dep.name);
            if (i > 0) try writer.print(", ", .{});
            try writer.print("{}:{s}", .{ dep.module_id, dep_name });
        }
        try writer.print("]", .{});

        if (node.* == .anonymous_function) {
            const anon = node.anonymous_function;

            try writer.print(" captures=[", .{});
            for (anon.closure_captures.items, 0..) |capture, i| {
                if (i > 0) try writer.print(", ", .{});
                const parent_name = strings.get(capture.parent_name);
                const local_name = strings.get(capture.local);
                try writer.print("{}:{s}:{s}", .{ key.module_id, parent_name, local_name });
            }
            try writer.print("]", .{});

            try writer.print(" parent=", .{});
            if (anon.parent) |parent_name| {
                const parent_name_str = strings.get(parent_name);
                try writer.print("{}:{s}", .{ key.module_id, parent_name_str });
            } else {
                try writer.print("null", .{});
            }
        }

        try writer.print("\n", .{});
    }

    try writer.print("\n", .{});
}

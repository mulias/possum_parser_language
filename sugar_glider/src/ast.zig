const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Elem = @import("elem.zig").Elem;
const Location = @import("location.zig").Location;

pub const Ast = struct {
    nodes: ArrayList(Node),
    locations: ArrayList(Location),
    endLocation: Location,

    pub const NodeType = enum { OpNode, ElemNode };

    pub const Node = union(NodeType) {
        OpNode: Op,
        ElemNode: Elem,
    };

    pub const OpType = enum {
        Backtrack,
        Destructure,
        Merge,
        Or,
        Return,
        Sequence,
        TakeLeft,
        TakeRight,
        ConditionalIfThen,
        ConditionalThenElse,
    };

    pub const Op = struct {
        opType: OpType,
        left: usize,
        right: usize,
    };

    pub fn init(allocator: Allocator) Ast {
        return Ast{
            .nodes = ArrayList(Node).init(allocator),
            .locations = ArrayList(Location).init(allocator),
            .endLocation = undefined,
        };
    }

    pub fn deinit(self: *Ast) void {
        self.nodes.deinit();
        self.locations.deinit();
    }

    pub fn getNode(self: Ast, index: usize) Node {
        return self.nodes.items[index];
    }

    pub fn getLocation(self: Ast, index: usize) Location {
        return self.locations.items[index];
    }

    pub fn getConditionalThenElseOp(self: Ast, index: usize) Op {
        switch (self.getNode(index)) {
            .OpNode => |op| {
                std.debug.assert(op.opType == .ConditionalThenElse);
                return op;
            },
            .ElemNode => unreachable,
        }
    }

    pub fn pushElem(self: *Ast, elem: Elem, loc: Location) !usize {
        try self.nodes.append(.{ .ElemNode = elem });
        try self.locations.append(loc);
        return self.nodes.items.len - 1;
    }

    pub fn pushOp(self: *Ast, opType: OpType, left: usize, right: usize, loc: Location) !usize {
        try self.nodes.append(.{ .OpNode = .{
            .opType = opType,
            .left = left,
            .right = right,
        } });
        try self.locations.append(loc);
        return self.nodes.items.len - 1;
    }
};

test "struct size" {
    try std.testing.expectEqual(32, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Op));
}

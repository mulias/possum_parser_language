const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Elem = @import("elem.zig").Elem;
const Location = @import("location.zig").Location;

pub const Ast = struct {
    roots: ArrayList(usize),
    nodes: ArrayList(Node),
    locations: ArrayList(Location),
    endLocation: Location,

    pub const NodeType = enum { InfixNode, ElemNode };

    pub const Node = union(NodeType) {
        InfixNode: Infix,
        ElemNode: Elem,
    };

    pub const InfixType = enum {
        ArrayCons,
        Backtrack,
        CallOrDefineFunction,
        ConditionalIfThen,
        ConditionalThenElse,
        DeclareGlobal,
        Destructure,
        Merge,
        NumberSubtract,
        Or,
        ParamsOrArgs,
        Return,
        TakeLeft,
        TakeRight,
    };

    pub const Infix = struct {
        infixType: InfixType,
        left: usize,
        right: usize,
    };

    pub fn init(allocator: Allocator) Ast {
        return Ast{
            .roots = ArrayList(usize).init(allocator),
            .nodes = ArrayList(Node).init(allocator),
            .locations = ArrayList(Location).init(allocator),
            .endLocation = undefined,
        };
    }

    pub fn deinit(self: *Ast) void {
        self.roots.deinit();
        self.nodes.deinit();
        self.locations.deinit();
    }

    pub fn getNode(self: Ast, index: usize) Node {
        return self.nodes.items[index];
    }

    pub fn getLocation(self: Ast, index: usize) Location {
        return self.locations.items[index];
    }

    pub fn getInfix(self: Ast, index: usize) ?Infix {
        return switch (self.getNode(index)) {
            .InfixNode => |infix| infix,
            .ElemNode => null,
        };
    }

    pub fn getInfixOfType(self: Ast, index: usize, infixType: InfixType) ?Infix {
        if (self.getInfix(index)) |infix| if (infix.infixType == infixType) return infix;
        return null;
    }

    pub fn getElem(self: Ast, index: usize) ?Elem {
        return switch (self.getNode(index)) {
            .InfixNode => null,
            .ElemNode => |elem| elem,
        };
    }

    pub fn pushRoot(self: *Ast, rootNodeId: usize) !void {
        try self.roots.append(rootNodeId);
    }

    pub fn pushElem(self: *Ast, elem: Elem, loc: Location) !usize {
        try self.nodes.append(.{ .ElemNode = elem });
        try self.locations.append(loc);
        return self.nodes.items.len - 1;
    }

    pub fn pushInfix(self: *Ast, infixType: InfixType, left: usize, right: usize, loc: Location) !usize {
        try self.nodes.append(.{ .InfixNode = .{
            .infixType = infixType,
            .left = left,
            .right = right,
        } });
        try self.locations.append(loc);
        return self.nodes.items.len - 1;
    }
};

test "struct size" {
    try std.testing.expectEqual(32, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

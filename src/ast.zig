const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const Region = @import("region.zig").Region;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const VMWriter = @import("writer.zig").VMWriter;
const prettyPrint = @import("pretty.zig").print;

pub const Ast = struct {
    arena: ArenaAllocator,
    roots: ArrayList(*RNode),

    pub const RNode = struct {
        region: Region,
        node: Node,
    };

    pub const NodeType = enum {
        InfixNode,
        ElemNode,
        UpperBoundedRange,
        LowerBoundedRange,
        Negation,
        ValueLabel,
        Array,
        Object,
        StringTemplate,
        Conditional,
    };

    pub const ObjectPair = struct {
        key: *RNode,
        value: *RNode,
    };

    pub const ConditionalNode = struct {
        condition: *RNode,
        then_branch: *RNode,
        else_branch: *RNode,
    };

    pub const Node = union(NodeType) {
        InfixNode: Infix,
        ElemNode: Elem,
        UpperBoundedRange: *RNode,
        LowerBoundedRange: *RNode,
        Negation: *RNode,
        ValueLabel: *RNode,
        Array: ArrayList(*RNode),
        Object: ArrayList(ObjectPair),
        StringTemplate: ArrayList(*RNode),
        Conditional: ConditionalNode,

        pub fn asInfixOfType(self: Node, t: InfixType) ?Infix {
            return switch (self) {
                .InfixNode => |infix| if (infix.infixType == t) infix else null,
                else => null,
            };
        }

        pub fn asElem(self: Node) ?Elem {
            return switch (self) {
                .ElemNode => |elem| elem,
                else => null,
            };
        }
    };

    pub const InfixType = enum {
        Backtrack,
        CallOrDefineFunction,
        Range,
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
        left: *RNode,
        right: *RNode,
    };

    pub fn init(allocator: Allocator) Ast {
        return Ast{
            .arena = ArenaAllocator.init(allocator),
            .roots = .{},
        };
    }

    pub fn deinit(self: *Ast) void {
        self.arena.deinit();
    }

    pub fn pushRoot(self: *Ast, root: *RNode) !void {
        try self.roots.append(self.arena.allocator(), root);
    }

    pub fn create(self: *Ast, node: Node, region: Region) !*RNode {
        const ptr = try self.arena.allocator().create(RNode);

        ptr.* = RNode{ .region = region, .node = node };

        return ptr;
    }

    pub fn createElem(self: *Ast, elem: Elem, loc: Region) !*RNode {
        return self.create(.{ .ElemNode = elem }, loc);
    }

    pub fn createInfix(self: *Ast, infixType: InfixType, left: *RNode, right: *RNode, loc: Region) !*RNode {
        return self.create(.{ .InfixNode = .{
            .infixType = infixType,
            .left = left,
            .right = right,
        } }, loc);
    }

    pub fn createArray(self: *Ast, elements: ArrayList(*RNode), loc: Region) !*RNode {
        return self.create(.{ .Array = elements }, loc);
    }

    pub fn createObject(self: *Ast, pairs: ArrayList(ObjectPair), loc: Region) !*RNode {
        return self.create(.{ .Object = pairs }, loc);
    }

    pub fn createStringTemplate(self: *Ast, parts: ArrayList(*RNode), loc: Region) !*RNode {
        return self.create(.{ .StringTemplate = parts }, loc);
    }

    pub fn createConditional(self: *Ast, condition: *RNode, then_branch: *RNode, else_branch: *RNode, loc: Region) !*RNode {
        return self.create(.{ .Conditional = .{
            .condition = condition,
            .then_branch = then_branch,
            .else_branch = else_branch,
        } }, loc);
    }

    pub fn print(self: *Ast, vm: VM) !void {
        try prettyPrint(vm.allocator, vm.writers.debug, self.roots.items, .{
            .array_show_item_idx = false,
            .max_depth = 0,
            .array_max_len = 0,
        });
    }
};

test "struct size" {
    try std.testing.expectEqual(32, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

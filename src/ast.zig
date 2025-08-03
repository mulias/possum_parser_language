const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const Region = @import("region.zig").Region;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const VMWriter = @import("writer.zig").VMWriter;

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
        Range,
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

    pub const RangeNode = struct {
        lower: ?*RNode,
        upper: ?*RNode,
    };

    pub const Node = union(NodeType) {
        InfixNode: Infix,
        ElemNode: Elem,
        Range: RangeNode,
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
        DeclareGlobal,
        Destructure,
        Merge,
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

    pub fn printSexpr(self: *Ast, vm: VM) VMWriter.Error!void {
        for (self.roots.items) |root| {
            try self.printRNodeSexpr(root, vm.writers.debug, vm, 0);
            try vm.writers.debug.print("\n", .{});
        }
    }

    fn printRNodeSexpr(self: *Ast, rnode: *RNode, writer: VMWriter, vm: VM, indent: u32) VMWriter.Error!void {
        try self.printNodeSexpr(rnode.node, writer, vm, indent, rnode.region);
    }

    fn printIndent(self: *Ast, writer: VMWriter, indent: u32) VMWriter.Error!void {
        _ = self;
        var i: u32 = 0;
        while (i < indent * 2) : (i += 1) {
            try writer.print(" ", .{});
        }
    }

    fn shouldBeMultiline(self: *Ast, node: Node, vm: VM) bool {
        return switch (node) {
            .InfixNode => true, // InfixNodes have 2 children, so always multiline
            .Array => |array| {
                // Always multiline if more than 3 members
                if (array.items.len > 3) return true;
                // Otherwise multiline if any child is multiline
                for (array.items) |item| {
                    if (self.shouldBeMultiline(item.node, vm)) return true;
                }
                return false;
            },
            .Object => |obj| {
                // Always multiline if more than 3 members or if non-empty
                if (obj.items.len > 3) return true;
                return obj.items.len > 0;
            },
            .StringTemplate => |template| template.items.len > 1,
            .Conditional => true, // Conditionals have 3 children, so always multiline
            .Range => |range| {
                const lower_multiline = if (range.lower) |lower| self.shouldBeMultiline(lower.node, vm) else false;
                const upper_multiline = if (range.upper) |upper| self.shouldBeMultiline(upper.node, vm) else false;
                return lower_multiline or upper_multiline;
            },
            .Negation => |child| self.shouldBeMultiline(child.node, vm),
            .ValueLabel => |child| self.shouldBeMultiline(child.node, vm),
            .ElemNode => false,
        };
    }

    fn printNodeSexpr(self: *Ast, node: Node, writer: VMWriter, vm: VM, indent: u32, region: Region) VMWriter.Error!void {
        const multiline = self.shouldBeMultiline(node, vm);

        switch (node) {
            .InfixNode => |infix| {
                try writer.print("({s} {}-{}\n", .{ @tagName(infix.infixType), region.start, region.end });
                try self.printIndent(writer, indent + 1);
                try self.printRNodeSexpr(infix.left, writer, vm, indent + 1);
                try writer.print("\n", .{});
                try self.printIndent(writer, indent + 1);
                try self.printRNodeSexpr(infix.right, writer, vm, indent + 1);
                try writer.print(")", .{});
            },
            .ElemNode => |elem| {
                try writer.print("({s} {}-{} ", .{ @tagName(elem), region.start, region.end });
                try elem.print(vm, writer);
                try writer.print(")", .{});
            },
            .Range => |range| {
                if (multiline) {
                    try writer.print("(Range {}-{}\n", .{ region.start, region.end });
                    try self.printIndent(writer, indent + 1);
                    if (range.lower) |lower| try self.printRNodeSexpr(lower, writer, vm, indent + 1) else try writer.print("()", .{});
                    try writer.print("\n", .{});
                    try self.printIndent(writer, indent + 1);
                    if (range.upper) |upper| try self.printRNodeSexpr(upper, writer, vm, indent + 1) else try writer.print("()", .{});
                    try writer.print(")", .{});
                } else {
                    try writer.print("(Range {}-{} ", .{ region.start, region.end });
                    if (range.lower) |lower| try self.printRNodeSexpr(lower, writer, vm, indent + 1) else try writer.print("()", .{});
                    try writer.print(" ", .{});
                    if (range.upper) |upper| try self.printRNodeSexpr(upper, writer, vm, indent + 1) else try writer.print("()", .{});
                    try writer.print(")", .{});
                }
            },
            .Negation => |child| {
                if (multiline) {
                    try writer.print("(Negation {}-{}\n", .{ region.start, region.end });
                    try self.printIndent(writer, indent + 1);
                    try self.printRNodeSexpr(child, writer, vm, indent + 1);
                    try writer.print(")", .{});
                } else {
                    try writer.print("(Negation {}-{} ", .{ region.start, region.end });
                    try self.printRNodeSexpr(child, writer, vm, indent);
                    try writer.print(")", .{});
                }
            },
            .ValueLabel => |child| {
                if (multiline) {
                    try writer.print("(ValueLabel {}-{}\n", .{ region.start, region.end });
                    try self.printIndent(writer, indent + 1);
                    try self.printRNodeSexpr(child, writer, vm, indent + 1);
                    try writer.print(")", .{});
                } else {
                    try writer.print("(ValueLabel {}-{} ", .{ region.start, region.end });
                    try self.printRNodeSexpr(child, writer, vm, indent);
                    try writer.print(")", .{});
                }
            },
            .Array => |array| {
                if (multiline) {
                    try writer.print("(Array {}-{} (\n", .{ region.start, region.end });
                    for (array.items, 0..) |item, i| {
                        try self.printIndent(writer, indent + 1);
                        try self.printRNodeSexpr(item, writer, vm, indent + 1);
                        if (i < array.items.len - 1) try writer.print("\n", .{});
                    }
                    if (array.items.len > 0) {
                        try writer.print("\n", .{});
                        try self.printIndent(writer, indent);
                    }
                    try writer.print("))", .{});
                } else {
                    try writer.print("(Array {}-{} (", .{ region.start, region.end });
                    for (array.items, 0..) |item, i| {
                        if (i > 0) try writer.print(" ", .{});
                        try self.printRNodeSexpr(item, writer, vm, indent);
                    }
                    try writer.print("))", .{});
                }
            },
            .Object => |obj| {
                if (obj.items.len == 0) {
                    try writer.print("(Object {}-{})", .{ region.start, region.end });
                } else {
                    try writer.print("(Object {}-{}\n", .{ region.start, region.end });
                    for (obj.items, 0..) |pair, i| {
                        try self.printIndent(writer, indent + 1);
                        try writer.print("(", .{});
                        try self.printRNodeSexpr(pair.key, writer, vm, indent + 2);
                        try writer.print(" ", .{});
                        try self.printRNodeSexpr(pair.value, writer, vm, indent + 2);
                        try writer.print(")", .{});
                        if (i < obj.items.len - 1) try writer.print("\n", .{});
                    }
                    try writer.print(")", .{});
                }
            },
            .StringTemplate => |template| {
                if (template.items.len <= 1) {
                    try writer.print("(StringTemplate {}-{} ", .{ region.start, region.end });
                    if (template.items.len == 1) {
                        try self.printRNodeSexpr(template.items[0], writer, vm, indent);
                    }
                    try writer.print(")", .{});
                } else {
                    try writer.print("(StringTemplate {}-{}\n", .{ region.start, region.end });
                    for (template.items, 0..) |part, i| {
                        try self.printIndent(writer, indent + 1);
                        try self.printRNodeSexpr(part, writer, vm, indent + 1);
                        if (i < template.items.len - 1) try writer.print("\n", .{});
                    }
                    try writer.print(")", .{});
                }
            },
            .Conditional => |cond| {
                try writer.print("(Conditional {}-{}\n", .{ region.start, region.end });
                try self.printIndent(writer, indent + 1);
                try writer.print("(condition ", .{});
                try self.printRNodeSexpr(cond.condition, writer, vm, indent + 2);
                try writer.print(")\n", .{});
                try self.printIndent(writer, indent + 1);
                try writer.print("(then ", .{});
                try self.printRNodeSexpr(cond.then_branch, writer, vm, indent + 2);
                try writer.print(")\n", .{});
                try self.printIndent(writer, indent + 1);
                try writer.print("(else ", .{});
                try self.printRNodeSexpr(cond.else_branch, writer, vm, indent + 2);
                try writer.print("))", .{});
            },
        }
    }

    pub fn print(self: *Ast, vm: VM) VMWriter.Error!void {
        try self.printSexpr(vm);
    }
};

test "struct size" {
    try std.testing.expectEqual(32, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

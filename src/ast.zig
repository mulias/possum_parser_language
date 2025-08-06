const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const Region = @import("region.zig").Region;
const LineRelativeRegion = @import("region.zig").LineRelativeRegion;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;

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
        Function,
        DeclareGlobal,
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

    pub const FunctionNode = struct {
        name: *RNode,
        paramsOrArgs: ArrayList(*RNode),
    };

    pub const DeclareGlobalNode = struct {
        head: *RNode,
        body: *RNode,
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
        Function: FunctionNode,
        DeclareGlobal: DeclareGlobalNode,

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
        Destructure,
        Merge,
        Or,
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

    pub fn createFunction(self: *Ast, name: *RNode, paramsOrArgs: ArrayList(*RNode), loc: Region) !*RNode {
        return self.create(.{ .Function = .{
            .name = name,
            .paramsOrArgs = paramsOrArgs,
        } }, loc);
    }

    pub fn createDeclareGlobal(self: *Ast, head: *RNode, body: *RNode, loc: Region) !*RNode {
        return self.create(.{ .DeclareGlobal = .{
            .head = head,
            .body = body,
        } }, loc);
    }

    pub fn print(self: *Ast, writer: anytype, vm: VM, source: []const u8) !void {
        var last_region: ?Region = null;
        var last_relative: ?LineRelativeRegion = null;

        const last_index = self.roots.items.len - 1;

        for (self.roots.items, 0..) |root, i| {
            try self.printSexpr(root, writer, vm, source, 0, &last_region, &last_relative);

            if (i == last_index) {
                try writer.print("\n", .{});
            } else {
                try writer.print("\n\n", .{});
            }
        }
    }

    fn printIndent(self: *Ast, writer: anytype, indent: u32) !void {
        _ = self;
        var i: u32 = 0;
        while (i < indent * 2) : (i += 1) {
            try writer.print(" ", .{});
        }
    }

    fn shouldBeMultiline(self: *Ast, node: Node) bool {
        return switch (node) {
            .InfixNode => true, // InfixNodes have 2 children, so always multiline
            .Array => |array| {
                // Always multiline if more than 3 members
                if (array.items.len > 3) return true;
                // Otherwise multiline if any child is multiline
                for (array.items) |item| {
                    if (self.shouldBeMultiline(item.node)) return true;
                }
                return false;
            },
            .Object => |obj| {
                // Always multiline if more than 3 members or if non-empty
                if (obj.items.len > 3) return true;
                return obj.items.len > 0;
            },
            .StringTemplate => |template| template.items.len > 1,
            .Conditional => true,
            .Function => |function| {
                if (function.paramsOrArgs.items.len > 2) return true;
                if (self.shouldBeMultiline(function.name.node)) return true;
                for (function.paramsOrArgs.items) |arg| {
                    if (self.shouldBeMultiline(arg.node)) return true;
                }
                return false;
            },
            .DeclareGlobal => |declaration| {
                return self.shouldBeMultiline(declaration.head.node) or
                    self.shouldBeMultiline(declaration.body.node);
            },
            .Range => |range| {
                const lower_multiline = if (range.lower) |lower| self.shouldBeMultiline(lower.node) else false;
                const upper_multiline = if (range.upper) |upper| self.shouldBeMultiline(upper.node) else false;
                return lower_multiline or upper_multiline;
            },
            .Negation => |child| self.shouldBeMultiline(child.node),
            .ValueLabel => |child| self.shouldBeMultiline(child.node),
            .ElemNode => false,
        };
    }

    fn nextLineRelativeRegion(self: *Ast, region: Region, source: []const u8, last_region: *?Region, last_relative: *?LineRelativeRegion) LineRelativeRegion {
        _ = self;

        const start_opt = if (last_region.*) |last_reg|
            if (last_relative.*) |last_rel|
                .{ last_reg, last_rel }
            else
                null
        else
            null;

        const line_relative = LineRelativeRegion.fromRegion(region, source, start_opt);

        last_region.* = region;
        last_relative.* = line_relative;

        return line_relative;
    }

    fn printSexpr(
        self: *Ast,
        rnode: *RNode,
        writer: anytype,
        vm: VM,
        source: []const u8,
        indent: u32,
        last_region: *?Region,
        last_relative: *?LineRelativeRegion,
    ) @TypeOf(writer).Error!void {
        const multiline = self.shouldBeMultiline(rnode.node);
        const line_relative = self.nextLineRelativeRegion(rnode.region, source, last_region, last_relative);

        switch (rnode.node) {
            .InfixNode => |infix| {
                try writer.print("({s} {}:{}-{}\n", .{ @tagName(infix.infixType), line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(infix.left, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print("\n", .{});
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(infix.right, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print(")", .{});
            },
            .ElemNode => |elem| {
                try writer.print("({s} {}:{}-{} ", .{ @tagName(elem), line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try elem.print(vm, writer);
                try writer.print(")", .{});
            },
            .Range => |range| {
                if (multiline) {
                    try writer.print("(Range {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printIndent(writer, indent + 1);
                    if (range.lower) |lower| try self.printSexpr(lower, writer, vm, source, indent + 1, last_region, last_relative) else try writer.print("()", .{});
                    try writer.print("\n", .{});
                    try self.printIndent(writer, indent + 1);
                    if (range.upper) |upper| try self.printSexpr(upper, writer, vm, source, indent + 1, last_region, last_relative) else try writer.print("()", .{});
                    try writer.print(")", .{});
                } else {
                    try writer.print("(Range {}:{}-{} ", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    if (range.lower) |lower| try self.printSexpr(lower, writer, vm, source, indent + 1, last_region, last_relative) else try writer.print("()", .{});
                    try writer.print(" ", .{});
                    if (range.upper) |upper| try self.printSexpr(upper, writer, vm, source, indent + 1, last_region, last_relative) else try writer.print("()", .{});
                    try writer.print(")", .{});
                }
            },
            .Negation => |child| {
                if (multiline) {
                    try writer.print("(Negation {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printIndent(writer, indent + 1);
                    try self.printSexpr(child, writer, vm, source, indent + 1, last_region, last_relative);
                    try writer.print(")", .{});
                } else {
                    try writer.print("(Negation {}:{}-{} ", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printSexpr(child, writer, vm, source, indent, last_region, last_relative);
                    try writer.print(")", .{});
                }
            },
            .ValueLabel => |child| {
                if (multiline) {
                    try writer.print("(ValueLabel {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printIndent(writer, indent + 1);
                    try self.printSexpr(child, writer, vm, source, indent + 1, last_region, last_relative);
                    try writer.print(")", .{});
                } else {
                    try writer.print("(ValueLabel {}:{}-{} ", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printSexpr(child, writer, vm, source, indent, last_region, last_relative);
                    try writer.print(")", .{});
                }
            },
            .Array => |array| {
                if (multiline) {
                    try writer.print("(Array {}:{}-{} (\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (array.items, 0..) |item, i| {
                        try self.printIndent(writer, indent + 1);
                        try self.printSexpr(item, writer, vm, source, indent + 1, last_region, last_relative);
                        if (i < array.items.len - 1) try writer.print("\n", .{});
                    }
                    if (array.items.len > 0) {
                        try writer.print("\n", .{});
                        try self.printIndent(writer, indent);
                    }
                    try writer.print("))", .{});
                } else {
                    try writer.print("(Array {}:{}-{} (", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (array.items, 0..) |item, i| {
                        if (i > 0) try writer.print(" ", .{});
                        try self.printSexpr(item, writer, vm, source, indent, last_region, last_relative);
                    }
                    try writer.print("))", .{});
                }
            },
            .Object => |obj| {
                if (obj.items.len == 0) {
                    try writer.print("(Object {}:{}-{})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                } else {
                    try writer.print("(Object {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (obj.items, 0..) |pair, i| {
                        try self.printIndent(writer, indent + 1);
                        try writer.print("(", .{});
                        try self.printSexpr(pair.key, writer, vm, source, indent + 2, last_region, last_relative);
                        try writer.print(" ", .{});
                        try self.printSexpr(pair.value, writer, vm, source, indent + 2, last_region, last_relative);
                        try writer.print(")", .{});
                        if (i < obj.items.len - 1) try writer.print("\n", .{});
                    }
                    try writer.print(")", .{});
                }
            },
            .StringTemplate => |template| {
                if (template.items.len <= 1) {
                    try writer.print("(StringTemplate {}:{}-{} ", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    if (template.items.len == 1) {
                        try self.printSexpr(template.items[0], writer, vm, source, indent, last_region, last_relative);
                    }
                    try writer.print(")", .{});
                } else {
                    try writer.print("(StringTemplate {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (template.items, 0..) |part, i| {
                        try self.printIndent(writer, indent + 1);
                        try self.printSexpr(part, writer, vm, source, indent + 1, last_region, last_relative);
                        if (i < template.items.len - 1) try writer.print("\n", .{});
                    }
                    try writer.print(")", .{});
                }
            },
            .Conditional => |cond| {
                try writer.print("(Conditional {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try self.printIndent(writer, indent + 1);
                try writer.print("(condition ", .{});
                try self.printSexpr(cond.condition, writer, vm, source, indent + 2, last_region, last_relative);
                try writer.print(")\n", .{});
                try self.printIndent(writer, indent + 1);
                try writer.print("(then ", .{});
                try self.printSexpr(cond.then_branch, writer, vm, source, indent + 2, last_region, last_relative);
                try writer.print(")\n", .{});
                try self.printIndent(writer, indent + 1);
                try writer.print("(else ", .{});
                try self.printSexpr(cond.else_branch, writer, vm, source, indent + 2, last_region, last_relative);
                try writer.print("))", .{});
            },
            .Function => |function| {
                if (multiline) {
                    try writer.print("(Function {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printIndent(writer, indent + 1);
                    try self.printSexpr(function.name, writer, vm, source, indent + 1, last_region, last_relative);
                    try writer.print("\n", .{});
                    try self.printIndent(writer, indent + 1);
                    try writer.print("(", .{});
                    for (function.paramsOrArgs.items, 0..) |arg, i| {
                        if (i > 0) {
                            try writer.print("\n", .{});
                            try self.printIndent(writer, indent + 1);
                            try writer.print(" ", .{});
                        }
                        try self.printSexpr(arg, writer, vm, source, indent + 2, last_region, last_relative);
                    }
                    try writer.print("))", .{});
                } else {
                    try writer.print("(Function {}:{}-{} ", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    try self.printSexpr(function.name, writer, vm, source, indent, last_region, last_relative);
                    try writer.print(" (", .{});
                    for (function.paramsOrArgs.items, 0..) |arg, i| {
                        if (i > 0) try writer.print(" ", .{});
                        try self.printSexpr(arg, writer, vm, source, indent, last_region, last_relative);
                    }
                    try writer.print("))", .{});
                }
            },
            .DeclareGlobal => |global| {
                try writer.print("(DeclareGlobal {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(global.head, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print("\n", .{});
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(global.body, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print(")", .{});
            },
        }
    }
};

test "struct size" {
    try std.testing.expectEqual(40, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

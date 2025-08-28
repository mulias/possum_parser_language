const std = @import("std");
const Writer = std.Io.Writer;
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
        Range,
        Negation,
        ValueLabel,
        Array,
        Object,
        StringTemplate,
        Conditional,
        Function,
        DeclareGlobal,
        False,
        Null,
        NumberFloat,
        NumberString,
        ParserVar,
        String,
        True,
        ValueVar,
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

    pub const NumberStringNode = struct {
        number: []const u8,
        negated: bool,

        pub fn toFloat(self: NumberStringNode) !f64 {
            const f = try std.fmt.parseFloat(f64, self.number);
            return if (self.negated) -f else f;
        }
    };

    pub const Node = union(NodeType) {
        InfixNode: Infix,
        Range: RangeNode,
        Negation: *RNode,
        ValueLabel: *RNode,
        Array: ArrayList(*RNode),
        Object: ArrayList(ObjectPair),
        StringTemplate: ArrayList(*RNode),
        Conditional: ConditionalNode,
        Function: FunctionNode,
        DeclareGlobal: DeclareGlobalNode,
        False,
        Null,
        NumberFloat: f64,
        NumberString: NumberStringNode,
        ParserVar: []const u8,
        String: []const u8,
        True,
        ValueVar: []const u8,

        pub fn asInfixOfType(self: Node, t: InfixType) ?Infix {
            return switch (self) {
                .InfixNode => |infix| if (infix.infixType == t) infix else null,
                else => null,
            };
        }

        pub fn isElem(self: Node) bool {
            return switch (self) {
                .False,
                .Null,
                .NumberFloat,
                .NumberString,
                .ParserVar,
                .String,
                .True,
                .ValueVar,
                => true,
                else => false,
            };
        }

        pub fn isNumberElem(self: Node) bool {
            return self == .NumberFloat or self == .NumberString;
        }
    };

    pub const InfixType = enum {
        Backtrack,
        Destructure,
        Merge,
        Or,
        Repeat,
        Return,
        TakeLeft,
        TakeRight,
        NumberSubtract,
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

    pub fn merge(self: *Ast, nodeA: Node, nodeB: Node) !?Node {
        if (nodeA == .Null) return nodeB;
        if (nodeB == .Null) return nodeA;

        return switch (nodeA) {
            .False => switch (nodeB) {
                .False => Node.False,
                .True => Node.True,
                else => null,
            },
            .True => switch (nodeB) {
                .False, .True => Node.True,
                else => null,
            },
            .NumberFloat => |a| switch (nodeB) {
                .NumberFloat => |b| Node{ .NumberFloat = a + b },
                .NumberString => |ns| {
                    const b_float = try ns.toFloat();
                    return Node{ .NumberFloat = a + b_float };
                },
                else => null,
            },
            .NumberString => |nsa| switch (nodeB) {
                .NumberFloat => |b| {
                    const a_float = try nsa.toFloat();
                    return Node{ .NumberFloat = a_float + b };
                },
                .NumberString => |nsb| {
                    const a_float = try nsa.toFloat();
                    const b_float = try nsb.toFloat();
                    return Node{ .NumberFloat = a_float + b_float };
                },
                else => null,
            },
            .String => |a| switch (nodeB) {
                .String => |b| {
                    const total_len = a.len + b.len;
                    const buffer = try self.arena.allocator().alloc(u8, total_len);
                    @memcpy(buffer[0..a.len], a);
                    @memcpy(buffer[a.len..], b);
                    return Node{ .String = buffer };
                },
                else => null,
            },
            else => null,
        };
    }

    pub fn repeat(self: *Ast, nodeA: Node, nodeB: Node) !?Node {
        return switch (nodeA) {
            .NumberFloat => |a| switch (nodeB) {
                .NumberFloat => |b| Node{ .NumberFloat = a * b },
                .NumberString => |ns| {
                    const b_float = try ns.toFloat();
                    return Node{ .NumberFloat = a * b_float };
                },
                else => null,
            },
            .NumberString => |nsa| switch (nodeB) {
                .NumberFloat => |b| {
                    const a_float = try nsa.toFloat();
                    return Node{ .NumberFloat = a_float * b };
                },
                .NumberString => |nsb| blk: {
                    const a_float = try nsa.toFloat();
                    const b_float = try nsb.toFloat();
                    break :blk Node{ .NumberFloat = a_float * b_float };
                },
                else => null,
            },
            // For non-numbers, nodeB must be a non-negative integer
            .Null, .True, .False => switch (nodeB) {
                .NumberFloat => |b| if (b >= 0 and b == @floor(b)) nodeA else null,
                .NumberString => |ns| {
                    const count = try ns.toFloat();
                    if (count < 0 or count != @floor(count)) return null;
                    return nodeA;
                },
                else => null,
            },
            .String => |str| if (nodeB == .NumberFloat or nodeB == .NumberString) {
                const count_float = if (nodeB == .NumberFloat)
                    nodeB.NumberFloat
                else
                    try nodeB.NumberString.toFloat();

                if (count_float < 0 or count_float != @floor(count_float)) return null;
                const count = @as(usize, @intFromFloat(count_float));
                if (count == 0) return null;
                if (count == 1) return nodeA;

                // Allocate buffer for repeated string
                const total_len = str.len * count;
                const buffer = try self.arena.allocator().alloc(u8, total_len);
                for (0..count) |i| {
                    const start = i * str.len;
                    @memcpy(buffer[start .. start + str.len], str);
                }
                return Node{ .String = buffer };
            } else {
                return null;
            },
            .ValueVar, .ParserVar => null, // Variables can't be repeated at compile time
            else => null, // Other types not supported
        };
    }

    pub fn print(self: *Ast, writer: *Writer, vm: VM, source: []const u8) Writer.Error!void {
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
            .InfixNode => true,
            .Array => |array| array.items.len > 0,
            .Object => |obj| obj.items.len > 0,
            .StringTemplate => true,
            .Conditional => true,
            .Function => true,
            .DeclareGlobal => true,
            .Range => |range| {
                const lower_multiline = if (range.lower) |lower| self.shouldBeMultiline(lower.node) else false;
                const upper_multiline = if (range.upper) |upper| self.shouldBeMultiline(upper.node) else false;
                return lower_multiline or upper_multiline;
            },
            .Negation => |child| self.shouldBeMultiline(child.node),
            .ValueLabel => |child| self.shouldBeMultiline(child.node),
            .False,
            .Null,
            .NumberFloat,
            .NumberString,
            .ParserVar,
            .String,
            .True,
            .ValueVar,
            => false,
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
    ) !void {
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
                    try writer.print("(Array {}:{}-{} [\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (array.items, 0..) |item, i| {
                        try self.printIndent(writer, indent + 1);
                        try self.printSexpr(item, writer, vm, source, indent + 1, last_region, last_relative);
                        if (i < array.items.len - 1) try writer.print("\n", .{});
                    }
                    if (array.items.len > 0) {
                        try writer.print("\n", .{});
                        try self.printIndent(writer, indent);
                    }
                    try writer.print("])", .{});
                } else {
                    try writer.print("(Array {}:{}-{} [", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (array.items, 0..) |item, i| {
                        if (i > 0) try writer.print(" ", .{});
                        try self.printSexpr(item, writer, vm, source, indent, last_region, last_relative);
                    }
                    try writer.print("])", .{});
                }
            },
            .Object => |obj| {
                if (multiline) {
                    try writer.print("(Object {}:{}-{} [\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                    for (obj.items) |pair| {
                        if (self.shouldBeMultiline(pair.key.node) or self.shouldBeMultiline(pair.value.node)) {
                            try self.printIndent(writer, indent + 1);
                            try writer.print("(ObjectPair\n", .{});
                            try self.printIndent(writer, indent + 2);
                            try self.printSexpr(pair.key, writer, vm, source, indent + 2, last_region, last_relative);
                            try writer.print("\n", .{});
                            try self.printIndent(writer, indent + 2);
                            try self.printSexpr(pair.value, writer, vm, source, indent + 2, last_region, last_relative);
                            try writer.print(")", .{});
                        } else {
                            try self.printIndent(writer, indent + 1);
                            try writer.print("(ObjectPair ", .{});
                            try self.printSexpr(pair.key, writer, vm, source, indent + 2, last_region, last_relative);
                            try writer.print(" ", .{});
                            try self.printSexpr(pair.value, writer, vm, source, indent + 2, last_region, last_relative);
                            try writer.print(")", .{});
                        }
                        try writer.print("\n", .{});
                    }
                    try self.printIndent(writer, indent);
                    try writer.print("])", .{});
                } else {
                    try writer.print("(Object {}:{}-{} [])", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                }
            },
            .StringTemplate => |template| {
                try writer.print("(StringTemplate {}:{}-{} [\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                for (template.items) |part| {
                    try self.printIndent(writer, indent + 1);
                    try self.printSexpr(part, writer, vm, source, indent + 1, last_region, last_relative);
                    try writer.print("\n", .{});
                }
                try self.printIndent(writer, indent);
                try writer.print("])", .{});
            },
            .Conditional => |cond| {
                try writer.print("(Conditional {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(cond.condition, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print("\n", .{});
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(cond.then_branch, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print("\n", .{});
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(cond.else_branch, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print(")", .{});
            },
            .Function => |function| {
                try writer.print("(Function {}:{}-{}\n", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
                try self.printIndent(writer, indent + 1);
                try self.printSexpr(function.name, writer, vm, source, indent + 1, last_region, last_relative);
                try writer.print(" [\n", .{});
                for (function.paramsOrArgs.items) |arg| {
                    try self.printIndent(writer, indent + 2);
                    try self.printSexpr(arg, writer, vm, source, indent + 2, last_region, last_relative);
                    try writer.print("\n", .{});
                }
                try self.printIndent(writer, indent + 1);
                try writer.print("])", .{});
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
            .False => {
                try writer.print("(False {}:{}-{})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
            },
            .Null => {
                try writer.print("(Null {}:{}-{})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
            },
            .NumberFloat => |f| {
                try writer.print("(NumberFloat {}:{}-{} {d})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, f });
            },
            .NumberString => |ns| {
                if (ns.negated) {
                    try writer.print("(NumberString {}:{}-{} -{s})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, ns.number });
                } else {
                    try writer.print("(NumberString {}:{}-{} {s})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, ns.number });
                }
            },
            .ParserVar => |s| {
                try writer.print("(ParserVar {}:{}-{} {s})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, s });
            },
            .String => |s| {
                try writer.print("(String {}:{}-{} \"{s}\")", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, s });
            },
            .True => {
                try writer.print("(True {}:{}-{})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
            },
            .ValueVar => |s| {
                try writer.print("(ValueVar {}:{}-{} {s})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, s });
            },
        }
    }
};

test "struct size" {
    try std.testing.expectEqual(40, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

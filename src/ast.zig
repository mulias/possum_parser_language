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

    pub const Error = error{
        OutOfMemory,
        InvalidCharacter,
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
        String,
        True,
        Identifier,
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

    pub const IdentifierNode = struct {
        name: []const u8,
        builtin: bool,
        underscored: bool,
        kind: enum { Parser, Value, Underscore },
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
        String: []const u8,
        True,
        Identifier: IdentifierNode,

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
                .String,
                .True,
                .Identifier,
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

    pub fn merge(self: *Ast, a: *RNode, b: *RNode) Error!?RNode {
        if (a.node == .Null) return b.*;
        if (b.node == .Null) return a.*;

        const merged_region = a.region.merge(b.region);

        return switch (a.node) {
            .False => switch (b.node) {
                .False, .True => b.*,
                else => null,
            },
            .True => switch (b.node) {
                .False, .True => a.*,
                else => null,
            },
            .String => |a_str| switch (b.node) {
                .String => |b_str| {
                    const total_len = a_str.len + b_str.len;
                    const buffer = try self.arena.allocator().alloc(u8, total_len);
                    @memcpy(buffer[0..a_str.len], a_str);
                    @memcpy(buffer[a_str.len..], b_str);
                    return RNode{ .node = Node{ .String = buffer }, .region = merged_region };
                },
                else => null,
            },
            .Range => |a_range| switch (b.node) {
                .Range => |b_range| {
                    const a_lower_val = if (a_range.lower) |lower|
                        if (lower.node == .NumberFloat)
                            lower.node.NumberFloat
                        else if (lower.node == .NumberString)
                            try lower.node.NumberString.toFloat()
                        else
                            return null
                    else
                        0;

                    const b_lower_val = if (b_range.lower) |lower|
                        if (lower.node == .NumberFloat)
                            lower.node.NumberFloat
                        else if (lower.node == .NumberString)
                            try lower.node.NumberString.toFloat()
                        else
                            return null
                    else
                        0;

                    const lower_val = a_lower_val + b_lower_val;

                    var lower: ?*RNode = undefined;
                    var upper: ?*RNode = undefined;

                    if (a_range.upper) |a_upper| {
                        if (!a_upper.node.isNumberElem()) return null;

                        const a_upper_val = if (a_upper.node == .NumberFloat)
                            a_upper.node.NumberFloat
                        else if (a_upper.node == .NumberString)
                            try a_upper.node.NumberString.toFloat()
                        else
                            return null;

                        if (b_range.upper) |b_upper| {
                            const b_upper_val = if (b_upper.node == .NumberFloat)
                                b_upper.node.NumberFloat
                            else if (b_upper.node == .NumberString)
                                try b_upper.node.NumberString.toFloat()
                            else
                                return null;

                            const upper_val = a_upper_val + b_upper_val;

                            lower = try self.create(.{ .NumberFloat = lower_val }, merged_region);
                            upper = try self.create(.{ .NumberFloat = upper_val }, merged_region);
                        } else {
                            lower = try self.create(.{ .NumberFloat = lower_val }, merged_region);
                            upper = a_upper;
                        }
                    } else if (b_range.upper) |b_upper| {
                        if (!b_upper.node.isNumberElem()) return null;
                        lower = try self.create(.{ .NumberFloat = lower_val }, merged_region);
                        upper = b_upper;
                    } else {
                        lower = try self.create(.{ .NumberFloat = lower_val }, merged_region);
                        upper = null;
                    }

                    return RNode{
                        .node = .{ .Range = .{ .lower = lower, .upper = upper } },
                        .region = merged_region,
                    };
                },
                .NumberFloat,
                .NumberString,
                => {
                    return try self.mergeRangeAndNumberNodes(a_range, b.node, merged_region);
                },
                else => null,
            },
            .NumberFloat => |a_float| switch (b.node) {
                .NumberFloat => |b_float| RNode{
                    .node = .{ .NumberFloat = a_float + b_float },
                    .region = merged_region,
                },
                .NumberString => |ns| {
                    const b_float = try ns.toFloat();
                    return RNode{
                        .node = .{ .NumberFloat = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .Range => |b_range| {
                    return try self.mergeRangeAndNumberNodes(b_range, a.node, merged_region);
                },
                else => null,
            },
            .NumberString => |a_nstr| switch (b.node) {
                .NumberFloat => |b_float| {
                    const a_float = try a_nstr.toFloat();
                    return RNode{
                        .node = .{ .NumberFloat = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .NumberString => |b_nstr| {
                    const a_float = try a_nstr.toFloat();
                    const b_float = try b_nstr.toFloat();
                    return RNode{
                        .node = .{ .NumberFloat = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .Range => |b_range| {
                    return try self.mergeRangeAndNumberNodes(b_range, a.node, merged_region);
                },
                else => null,
            },
            else => null,
        };
    }

    fn mergeRangeAndNumberNodes(self: *Ast, range: RangeNode, number: Node, region: Region) Error!?RNode {
        const float = if (number == .NumberFloat)
            number.NumberFloat
        else if (number == .NumberString)
            try number.NumberString.toFloat()
        else
            return null;

        const lower_val = if (range.lower) |lower|
            if (lower.node == .NumberFloat)
                lower.node.NumberFloat
            else if (lower.node == .NumberString)
                try lower.node.NumberString.toFloat()
            else
                return null
        else
            0;

        const new_lower = Node{ .NumberFloat = float + lower_val };

        if (range.upper) |upper| {
            const upper_val = if (upper.node == .NumberFloat)
                upper.node.NumberFloat
            else if (upper.node == .NumberString)
                try upper.node.NumberString.toFloat()
            else
                return null;

            const new_upper = Node{ .NumberFloat = float + upper_val };

            const lower_rnode = try self.create(new_lower, region);
            const upper_rnode = try self.create(new_upper, region);
            return RNode{
                .node = .{ .Range = .{ .lower = lower_rnode, .upper = upper_rnode } },
                .region = region,
            };
        } else {
            const lower_rnode = try self.create(new_lower, region);
            return RNode{
                .node = .{ .Range = .{ .lower = lower_rnode, .upper = null } },
                .region = region,
            };
        }
    }

    pub fn repeat(self: *Ast, a: *RNode, b: *RNode) Error!?RNode {
        const merged_region = a.region.merge(b.region);
        
        return switch (a.node) {
            .Range => |a_range| switch (b.node) {
                .Range => |b_range| {
                    // Both ranges must be number ranges
                    const a_lower_val = if (a_range.lower) |lower| blk: {
                        if (!lower.node.isNumberElem()) return null;
                        const val = if (lower.node == .NumberFloat)
                            lower.node.NumberFloat
                        else
                            try lower.node.NumberString.toFloat();
                        break :blk val;
                    } else 0;

                    const b_lower_val = if (b_range.lower) |lower| blk: {
                        if (!lower.node.isNumberElem()) return null;
                        const val = if (lower.node == .NumberFloat)
                            lower.node.NumberFloat
                        else
                            try lower.node.NumberString.toFloat();
                        break :blk val;
                    } else 0;

                    const new_lower = a_lower_val * b_lower_val;
                    const new_lower_node = try self.create(.{ .NumberFloat = new_lower }, merged_region);

                    // Handle upper bounds
                    if (a_range.upper) |a_upper| {
                        if (!a_upper.node.isNumberElem()) return null;
                        const a_upper_val = if (a_upper.node == .NumberFloat)
                            a_upper.node.NumberFloat
                        else
                            try a_upper.node.NumberString.toFloat();

                        if (b_range.upper) |b_upper| {
                            if (!b_upper.node.isNumberElem()) return null;
                            const b_upper_val = if (b_upper.node == .NumberFloat)
                                b_upper.node.NumberFloat
                            else
                                try b_upper.node.NumberString.toFloat();
                            const new_upper = a_upper_val * b_upper_val;
                            const new_upper_node = try self.create(.{ .NumberFloat = new_upper }, merged_region);
                            return RNode{ 
                                .node = .{ .Range = .{ .lower = new_lower_node, .upper = new_upper_node } },
                                .region = merged_region,
                            };
                        } else {
                            // b is open range, result is open
                            return RNode{ 
                                .node = .{ .Range = .{ .lower = new_lower_node, .upper = null } },
                                .region = merged_region,
                            };
                        }
                    } else if (b_range.upper) |_| {
                        // a is open range, result is open
                        return RNode{ 
                            .node = .{ .Range = .{ .lower = new_lower_node, .upper = null } },
                            .region = merged_region,
                        };
                    } else {
                        // Both open ranges
                        return RNode{ 
                            .node = .{ .Range = .{ .lower = new_lower_node, .upper = null } },
                            .region = merged_region,
                        };
                    }
                },
                .NumberFloat => |b_float| self.repeatRangeAndNumber(a_range, b_float, merged_region),
                .NumberString => |ns| blk: {
                    const b_float = try ns.toFloat();
                    break :blk self.repeatRangeAndNumber(a_range, b_float, merged_region);
                },
                else => null,
            },
            .NumberFloat => |a_float| switch (b.node) {
                .NumberFloat => |b_float| RNode{ 
                    .node = .{ .NumberFloat = a_float * b_float },
                    .region = merged_region,
                },
                .NumberString => |ns| {
                    const b_float = try ns.toFloat();
                    return RNode{ 
                        .node = .{ .NumberFloat = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .Range => |b_range| self.repeatRangeAndNumber(b_range, a_float, merged_region),
                else => null,
            },
            .NumberString => |nsa| switch (b.node) {
                .NumberFloat => |b_float| {
                    const a_float = try nsa.toFloat();
                    return RNode{ 
                        .node = .{ .NumberFloat = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .NumberString => |nsb| blk: {
                    const a_float = try nsa.toFloat();
                    const b_float = try nsb.toFloat();
                    break :blk RNode{ 
                        .node = .{ .NumberFloat = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .Range => |b_range| blk: {
                    const a_float = try nsa.toFloat();
                    break :blk self.repeatRangeAndNumber(b_range, a_float, merged_region);
                },
                else => null,
            },
            // For non-numbers, nodeB must be a non-negative integer
            .Null, .True, .False => switch (b.node) {
                .NumberFloat => |b_float| if (b_float >= 0 and b_float == @floor(b_float)) a.* else null,
                .NumberString => |ns| {
                    const count = try ns.toFloat();
                    if (count < 0 or count != @floor(count)) return null;
                    return a.*;
                },
                else => null,
            },
            .String => |str| if (b.node == .NumberFloat or b.node == .NumberString) {
                const count_float = if (b.node == .NumberFloat)
                    b.node.NumberFloat
                else
                    try b.node.NumberString.toFloat();

                if (count_float < 0 or count_float != @floor(count_float)) return null;
                const count = @as(usize, @intFromFloat(count_float));
                if (count == 0) return null;
                if (count == 1) return a.*;

                // Allocate buffer for repeated string
                const total_len = str.len * count;
                const buffer = try self.arena.allocator().alloc(u8, total_len);
                for (0..count) |i| {
                    const start = i * str.len;
                    @memcpy(buffer[start .. start + str.len], str);
                }
                return RNode{ 
                    .node = .{ .String = buffer },
                    .region = merged_region,
                };
            } else {
                return null;
            },
            .Identifier => null,
            else => null, // Other types not supported
        };
    }

    fn repeatRangeAndNumber(self: *Ast, range: RangeNode, multiplier: f64, region: Region) Error!?RNode {
        // multiplier must be non-negative
        if (multiplier < 0) return null;

        // Extract lower bound (default to 0)
        const lower_val = if (range.lower) |lower| blk: {
            if (!lower.node.isNumberElem()) return null;
            const val = if (lower.node == .NumberFloat)
                lower.node.NumberFloat
            else
                try lower.node.NumberString.toFloat();
            break :blk val;
        } else 0;

        // Multiply lower bound
        const new_lower = lower_val * multiplier;
        const new_lower_node = try self.create(.{ .NumberFloat = new_lower }, region);

        // Handle upper bound if present
        if (range.upper) |upper| {
            if (!upper.node.isNumberElem()) return null;
            const upper_val = if (upper.node == .NumberFloat)
                upper.node.NumberFloat
            else
                try upper.node.NumberString.toFloat();
            const new_upper = upper_val * multiplier;
            const new_upper_node = try self.create(.{ .NumberFloat = new_upper }, region);
            return RNode{ 
                .node = .{ .Range = .{ .lower = new_lower_node, .upper = new_upper_node } },
                .region = region,
            };
        } else {
            // Open range: lower..
            return RNode{ 
                .node = .{ .Range = .{ .lower = new_lower_node, .upper = null } },
                .region = region,
            };
        }
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
            .String,
            .True,
            .Identifier,
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
            .String => |s| {
                try writer.print("(String {}:{}-{} \"{s}\")", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end, s });
            },
            .True => {
                try writer.print("(True {}:{}-{})", .{ line_relative.line, line_relative.relative_start, line_relative.relative_end });
            },
            .Identifier => |ident| {
                try writer.print("(Identifier {}:{}-{} {s})", .{
                    line_relative.line,
                    line_relative.relative_start,
                    line_relative.relative_end,
                    ident.name,
                });
            },
        }
    }
};

test "struct size" {
    try std.testing.expectEqual(40, @sizeOf(Ast.Node));
    try std.testing.expectEqual(24, @sizeOf(Ast.Infix));
}

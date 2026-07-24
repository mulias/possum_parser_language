const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Region = @import("../region.zig").Region;
const PathTable = @import("path_table.zig").PathTable;
const ParsedAst = @import("parsed_ast.zig").Ast;

// The pattern tree goal builds from the parsed ast and folds before
// lowering to places and constraints. Structurally the surface pattern
// language: merges, repeats, ranges, negations, arrays, objects,
// templates, identifiers, calls, and literals. Function-call parts keep
// the parsed function node so lowering can value-convert their operands
// with goal's own value converter.

pub const Pattern = @This();

pub const RNode = struct {
    region: Region,
    node: Node,
};

pub const NodeType = enum {
    array,
    false,
    function_call,
    identifier,
    merge,
    negation,
    null,
    number_float,
    number_string,
    object,
    range,
    repeat,
    string,
    string_template,
    true,
};

pub const Node = union(NodeType) {
    array: ArrayList(*RNode),
    false,
    function_call: ParsedAst.FunctionNode,
    identifier: Identifier,
    merge: struct { left: *RNode, right: *RNode },
    negation: *RNode,
    null,
    number_float: f64,
    number_string: NumberString,
    object: ArrayList(ObjectPair),
    range: Range,
    repeat: struct { left: *RNode, right: *RNode },
    string: []const u8,
    string_template: ArrayList(*RNode),
    true,

    pub fn isNumberElem(self: Node) bool {
        return self == .number_float or self == .number_string;
    }
};

pub const NumberString = struct {
    number: []const u8,
    negated: bool,

    pub fn toFloat(self: NumberString) !f64 {
        const f = try std.fmt.parseFloat(f64, self.number);
        return if (self.negated) -f else f;
    }

    pub fn negate(self: NumberString) NumberString {
        return .{
            .number = self.number,
            .negated = !self.negated,
        };
    }
};

pub const ObjectPair = struct {
    key: *RNode,
    value: *RNode,
};

pub const Range = struct {
    lower: ?*RNode,
    upper: ?*RNode,
};

pub const Identifier = struct {
    name: PathTable.Id,
    builtin: bool,
    underscored: bool,
};

pub fn create(allocator: Allocator, node: Node, region: Region) !*RNode {
    const ptr = try allocator.create(RNode);
    ptr.* = RNode{ .region = region, .node = node };
    return ptr;
}

pub fn merge(allocator: Allocator, a: RNode, b: RNode) error{ OutOfMemory, InvalidCharacter }!?RNode {
    if (a.node == .null) return b;
    if (b.node == .null) return a;

    const merged_region = a.region.merge(b.region);

    return switch (a.node) {
        .false => switch (b.node) {
            .false, .true => b,
            else => null,
        },
        .true => switch (b.node) {
            .false, .true => a,
            else => null,
        },
        .string => |a_str| switch (b.node) {
            .string => |b_str| {
                const total_len = a_str.len + b_str.len;
                const buffer = try allocator.alloc(u8, total_len);
                @memcpy(buffer[0..a_str.len], a_str);
                @memcpy(buffer[a_str.len..], b_str);
                return RNode{ .node = Node{ .string = buffer }, .region = merged_region };
            },
            else => null,
        },
        .range => |a_range| switch (b.node) {
            .range => |b_range| {
                var lower: ?*RNode = undefined;
                var upper: ?*RNode = undefined;

                if (a_range.lower) |a_lower| {
                    const a_lower_val = if (a_lower.node == .number_float)
                        a_lower.node.number_float
                    else if (a_lower.node == .number_string)
                        try a_lower.node.number_string.toFloat()
                    else
                        return null;

                    const b_lower_val = if (b_range.lower) |b_lower|
                        if (b_lower.node == .number_float)
                            b_lower.node.number_float
                        else if (b_lower.node == .number_string)
                            try b_lower.node.number_string.toFloat()
                        else
                            return null
                    else
                        0;

                    const lower_val = a_lower_val + b_lower_val;

                    lower = try create(allocator, .{ .number_float = lower_val }, merged_region);
                } else if (b_range.lower) |b_lower| {
                    if (!b_lower.node.isNumberElem()) return null;
                    lower = b_lower;
                } else {
                    lower = null;
                }

                if (a_range.upper) |a_upper| {
                    const a_upper_val = if (a_upper.node == .number_float)
                        a_upper.node.number_float
                    else if (a_upper.node == .number_string)
                        try a_upper.node.number_string.toFloat()
                    else
                        return null;

                    const b_upper_val = if (b_range.upper) |b_upper|
                        if (b_upper.node == .number_float)
                            b_upper.node.number_float
                        else if (b_upper.node == .number_string)
                            try b_upper.node.number_string.toFloat()
                        else
                            return null
                    else
                        0;

                    const upper_val = a_upper_val + b_upper_val;

                    upper = try create(allocator, .{ .number_float = upper_val }, merged_region);
                } else if (b_range.upper) |b_upper| {
                    if (!b_upper.node.isNumberElem()) return null;
                    upper = b_upper;
                } else {
                    upper = null;
                }

                return RNode{
                    .node = .{ .range = .{ .lower = lower, .upper = upper } },
                    .region = merged_region,
                };
            },
            .number_float,
            .number_string,
            => {
                return try mergeRangeAndNumberNodes(allocator, a_range, b.node, merged_region);
            },
            else => null,
        },
        .number_float => |a_float| switch (b.node) {
            .number_float => |b_float| RNode{
                .node = .{ .number_float = a_float + b_float },
                .region = merged_region,
            },
            .number_string => |ns| {
                const b_float = try ns.toFloat();
                return RNode{
                    .node = .{ .number_float = a_float + b_float },
                    .region = merged_region,
                };
            },
            .range => |b_range| {
                return try mergeRangeAndNumberNodes(allocator, b_range, a.node, merged_region);
            },
            else => null,
        },
        .number_string => |a_nstr| switch (b.node) {
            .number_float => |b_float| {
                const a_float = try a_nstr.toFloat();
                return RNode{
                    .node = .{ .number_float = a_float + b_float },
                    .region = merged_region,
                };
            },
            .number_string => |b_nstr| {
                const a_float = try a_nstr.toFloat();
                const b_float = try b_nstr.toFloat();
                return RNode{
                    .node = .{ .number_float = a_float + b_float },
                    .region = merged_region,
                };
            },
            .range => |b_range| {
                return try mergeRangeAndNumberNodes(allocator, b_range, a.node, merged_region);
            },
            else => null,
        },
        .array => |a_arr| switch (b.node) {
            .array => |b_arr| {
                var merged_array = a_arr;
                try merged_array.ensureTotalCapacity(allocator, a_arr.items.len + b_arr.items.len);
                merged_array.appendSliceAssumeCapacity(b_arr.items);
                return RNode{
                    .node = .{ .array = merged_array },
                    .region = merged_region,
                };
            },
            else => null,
        },
        else => null,
    };
}

fn mergeRangeAndNumberNodes(
    allocator: Allocator,
    range: Range,
    number: Node,
    region: Region,
) error{ OutOfMemory, InvalidCharacter }!?RNode {
    const float = if (number == .number_float)
        number.number_float
    else if (number == .number_string)
        try number.number_string.toFloat()
    else
        return null;

    var new_lower: ?*RNode = null;
    var new_upper: ?*RNode = null;

    if (range.lower) |lower| {
        const lower_val = if (lower.node == .number_float)
            lower.node.number_float
        else if (lower.node == .number_string)
            try lower.node.number_string.toFloat()
        else
            return null;

        new_lower = try create(allocator, .{ .number_float = float + lower_val }, region);
    }

    if (range.upper) |upper| {
        const upper_val = if (upper.node == .number_float)
            upper.node.number_float
        else if (upper.node == .number_string)
            try upper.node.number_string.toFloat()
        else
            return null;

        new_upper = try create(allocator, .{ .number_float = float + upper_val }, region);
    }

    return RNode{
        .node = .{ .range = .{ .lower = new_lower, .upper = new_upper } },
        .region = region,
    };
}

pub fn negate(allocator: Allocator, node: RNode, region: Region) !?RNode {
    return switch (node.node) {
        .number_float => |f| RNode{
            .node = .{ .number_float = -f },
            .region = region,
        },
        .number_string => |ns| RNode{
            .node = .{ .number_string = ns.negate() },
            .region = region,
        },
        .negation => |inner| negate(allocator, inner.*, region),
        .range => |range| {
            var neg_lower: ?*RNode = null;
            var neg_upper: ?*RNode = null;

            if (range.lower) |lower| {
                const neg = try negate(allocator, lower.*, lower.region) orelse return null;
                // negating flips range, lower is now upper
                neg_upper = try create(allocator, neg.node, neg.region);
            }

            if (range.upper) |upper| {
                const neg = try negate(allocator, upper.*, upper.region) orelse return null;
                // negating flips range, upper is now lower
                neg_lower = try create(allocator, neg.node, neg.region);
            }

            return RNode{
                .node = .{ .range = .{
                    .lower = neg_lower,
                    .upper = neg_upper,
                } },
                .region = region,
            };
        },
        else => null,
    };
}

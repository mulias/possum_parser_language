const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoArrayHashMap = std.AutoArrayHashMapUnmanaged;
const Region = @import("region.zig").Region;
const StringTable = @import("string_table.zig").StringTable;

arena: ArenaAllocator,
declarations: AutoArrayHashMap(StringTable.Id, ParserOrValue.Declaration),
main: ?*Parser.RNode,

pub const Ast = @This();

pub fn init(allocator: Allocator) Ast {
    return Ast{
        .arena = ArenaAllocator.init(allocator),
        .declarations = .{},
        .main = null,
    };
}

pub fn deinit(self: *Ast) void {
    self.arena.deinit();
}

pub fn addParserDeclaration(self: *Ast, decl: *RNode(Parser.Declaration)) !void {
    try self.declarations.put(self.arena.allocator(), decl.node.ident.node.name, .{ .parser = decl });
}

pub fn addValueDeclaration(self: *Ast, decl: *RNode(Value.Declaration)) !void {
    try self.declarations.put(self.arena.allocator(), decl.node.ident.node.name, .{ .value = decl });
}

pub fn RNode(comptime Node: type) type {
    return struct {
        region: Region,
        node: Node,
    };
}

pub const ParserOrValueOrPattern = struct {
    pub const RNode = union(enum) {
        parser: *Parser.RNode,
        value: *Value.RNode,
        pattern: *Pattern.RNode,

        pub fn region(self: ParserOrValueOrPattern.RNode) Region {
            return switch (self) {
                .parser => |p| p.region,
                .value => |v| v.region,
                .pattern => |p| p.region,
            };
        }
    };
};

pub const ParserOrValue = struct {
    pub const RNode = union(enum) {
        parser: *Parser.RNode,
        value: *Value.RNode,

        pub fn region(self: ParserOrValue.RNode) Region {
            return switch (self) {
                .parser => |p| p.region,
                .value => |v| v.region,
            };
        }
    };

    pub const Identifier = union(enum) {
        parser: *Ast.RNode(Parser.Identifier),
        value: *Ast.RNode(Value.Identifier),

        pub fn name(self: ParserOrValue.Identifier) StringTable.Id {
            return switch (self) {
                .parser => |p| p.node.name,
                .value => |v| v.node.name,
            };
        }

        pub fn builtin(self: ParserOrValue.Identifier) bool {
            return switch (self) {
                .parser => |p| p.node.builtin,
                .value => |v| v.node.builtin,
            };
        }

        pub fn underscored(self: ParserOrValue.Identifier) bool {
            return switch (self) {
                .parser => |p| p.node.underscored,
                .value => |v| v.node.underscored,
            };
        }

        pub fn region(self: ParserOrValue.Identifier) Region {
            return switch (self) {
                .parser => |p| p.region,
                .value => |v| v.region,
            };
        }
    };

    pub const Declaration = union(enum) {
        parser: *Ast.RNode(Parser.Declaration),
        value: *Ast.RNode(Value.Declaration),

        pub fn identName(self: ParserOrValue.Declaration) StringTable.Id {
            return switch (self) {
                .parser => |p| p.node.ident.node.name,
                .value => |v| v.node.ident.node.name,
            };
        }

        pub fn identBuiltin(self: ParserOrValue.Declaration) bool {
            return switch (self) {
                .parser => |p| p.node.ident.node.builtin,
                .value => |v| v.node.ident.node.builtin,
            };
        }

        pub fn identRegion(self: ParserOrValue.Declaration) Region {
            return switch (self) {
                .parser => |p| p.node.ident.region,
                .value => |v| v.node.ident.region,
            };
        }

        pub fn region(self: ParserOrValue.Declaration) Region {
            return switch (self) {
                .parser => |p| p.region,
                .value => |v| v.region,
            };
        }
    };
};

pub const Parser = struct {
    pub const RNode = Ast.RNode(Node);

    pub const NodeType = enum {
        @"or",
        @"return",
        backtrack,
        conditional,
        destructure,
        function_call,
        identifier,
        merge,
        negation,
        number_string,
        range,
        repeat,
        string,
        string_template,
        take_left,
        take_right,
    };

    pub const Node = union(NodeType) {
        @"or": struct { left: *Parser.RNode, right: *Parser.RNode },
        @"return": struct { left: *Parser.RNode, right: *Value.RNode },
        backtrack: struct { left: *Parser.RNode, right: *Parser.RNode },
        conditional: Conditional,
        destructure: struct { left: *Parser.RNode, right: *Pattern.RNode },
        function_call: FunctionCall,
        identifier: Identifier,
        merge: struct { left: *Parser.RNode, right: *Parser.RNode },
        negation: *Parser.RNode,
        number_string: NumberString,
        range: Range,
        repeat: struct { left: *Parser.RNode, right: *Pattern.RNode },
        string: []const u8,
        string_template: ArrayList(*Parser.RNode),
        take_left: struct { left: *Parser.RNode, right: *Parser.RNode },
        take_right: struct { left: *Parser.RNode, right: *Parser.RNode },
    };

    pub const Declaration = struct {
        ident: *Ast.RNode(Identifier),
        params: ArrayList(ParserOrValue.Identifier),
        body: *Parser.RNode,
    };

    pub const NumberString = struct {
        number: []const u8,
        negated: bool,

        pub fn toFloat(self: NumberString) !f64 {
            const f = try std.fmt.parseFloat(f64, self.number);
            return if (self.negated) -f else f;
        }
    };

    pub const Range = struct {
        lower: ?*Parser.RNode,
        upper: ?*Parser.RNode,
    };

    pub const FunctionCall = struct {
        function: *Parser.RNode,
        args: ArrayList(ParserOrValue.RNode),
    };

    pub const Conditional = struct {
        condition: *Parser.RNode,
        then_branch: *Parser.RNode,
        else_branch: *Parser.RNode,
    };

    pub const Identifier = struct {
        name: StringTable.Id,
        builtin: bool,
        underscored: bool,
    };

    pub fn create(ast: *Ast, node: Node, region: Region) !*Parser.RNode {
        const ptr = try ast.arena.allocator().create(Parser.RNode);
        ptr.* = Parser.RNode{ .region = region, .node = node };
        return ptr;
    }

    pub fn createDeclaration(ast: *Ast, node: Declaration, region: Region) !*Ast.RNode(Declaration) {
        const ptr = try ast.arena.allocator().create(Ast.RNode(Declaration));
        ptr.* = Ast.RNode(Declaration){ .region = region, .node = node };
        return ptr;
    }

    pub fn createIdent(ast: *Ast, node: Identifier, region: Region) !*Ast.RNode(Identifier) {
        const ptr = try ast.arena.allocator().create(Ast.RNode(Identifier));
        ptr.* = Ast.RNode(Identifier){ .region = region, .node = node };
        return ptr;
    }
};

pub const Value = struct {
    pub const RNode = Ast.RNode(Node);

    pub const NodeType = enum {
        @"or",
        @"return",
        array,
        conditional,
        destructure,
        false,
        function_call,
        identifier,
        merge,
        negation,
        null,
        number_float,
        number_string,
        object,
        repeat,
        string,
        string_template,
        take_left,
        take_right,
        true,
    };

    pub const Node = union(NodeType) {
        @"or": struct { left: *Value.RNode, right: *Value.RNode },
        @"return": struct { left: *Value.RNode, right: *Value.RNode },
        array: ArrayList(*Value.RNode),
        conditional: Conditional,
        destructure: struct { left: *Value.RNode, right: *Pattern.RNode },
        false,
        function_call: FunctionCall,
        identifier: Identifier,
        merge: struct { left: *Value.RNode, right: *Value.RNode },
        negation: *Value.RNode,
        null,
        number_float: f64,
        number_string: NumberString,
        object: ArrayList(ObjectPair),
        repeat: struct { left: *Value.RNode, right: *Value.RNode },
        string: []const u8,
        string_template: ArrayList(*Value.RNode),
        take_left: struct { left: *Value.RNode, right: *Value.RNode },
        take_right: struct { left: *Value.RNode, right: *Value.RNode },
        true,
    };

    pub const Declaration = struct {
        ident: *Ast.RNode(Identifier),
        params: ArrayList(*Ast.RNode(Identifier)),
        body: *Value.RNode,
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
        key: *Value.RNode,
        value: *Value.RNode,
    };

    pub const Conditional = struct {
        condition: *Value.RNode,
        then_branch: *Value.RNode,
        else_branch: *Value.RNode,
    };

    pub const FunctionCall = struct {
        function: *Value.RNode,
        args: ArrayList(*Value.RNode),
    };

    pub const Identifier = struct {
        name: StringTable.Id,
        builtin: bool,
        underscored: bool,
    };

    pub fn create(ast: *Ast, node: Node, region: Region) !*Value.RNode {
        const ptr = try ast.arena.allocator().create(Value.RNode);
        ptr.* = Value.RNode{ .region = region, .node = node };
        return ptr;
    }

    pub fn createDeclaration(ast: *Ast, node: Declaration, region: Region) !*Ast.RNode(Declaration) {
        const ptr = try ast.arena.allocator().create(Ast.RNode(Declaration));
        ptr.* = Ast.RNode(Declaration){ .region = region, .node = node };
        return ptr;
    }

    pub fn createIdent(ast: *Ast, node: Identifier, region: Region) !*Ast.RNode(Identifier) {
        const ptr = try ast.arena.allocator().create(Ast.RNode(Identifier));
        ptr.* = Ast.RNode(Identifier){ .region = region, .node = node };
        return ptr;
    }

    pub fn negate(node: Value.RNode, region: Region) ?Value.RNode {
        return switch (node.node) {
            .number_float => |f| Value.RNode{
                .node = .{ .number_float = -f },
                .region = region,
            },
            .number_string => |ns| Value.RNode{
                .node = .{ .number_string = ns.negate() },
                .region = region,
            },
            .negation => |inner| negate(inner.*, region),
            else => null,
        };
    }

    pub fn merge(ast: *Ast, a: Value.RNode, b: Value.RNode) error{ OutOfMemory, InvalidCharacter }!?Value.RNode {
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
                    const buffer = try ast.arena.allocator().alloc(u8, total_len);
                    @memcpy(buffer[0..a_str.len], a_str);
                    @memcpy(buffer[a_str.len..], b_str);
                    return Value.RNode{ .node = Node{ .string = buffer }, .region = merged_region };
                },
                else => null,
            },
            .number_float => |a_float| switch (b.node) {
                .number_float => |b_float| Value.RNode{
                    .node = .{ .number_float = a_float + b_float },
                    .region = merged_region,
                },
                .number_string => |ns| {
                    const b_float = try ns.toFloat();
                    return Value.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                else => null,
            },
            .number_string => |a_nstr| switch (b.node) {
                .number_float => |b_float| {
                    const a_float = try a_nstr.toFloat();
                    return Value.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .number_string => |b_nstr| {
                    const a_float = try a_nstr.toFloat();
                    const b_float = try b_nstr.toFloat();
                    return Value.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                else => null,
            },
            else => null,
        };
    }
};

pub const Pattern = struct {
    pub const RNode = Ast.RNode(Node);

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
        array: ArrayList(*Pattern.RNode),
        false,
        function_call: Value.FunctionCall,
        identifier: Identifier,
        merge: struct { left: *Pattern.RNode, right: *Pattern.RNode },
        negation: *Pattern.RNode,
        null,
        number_float: f64,
        number_string: NumberString,
        object: ArrayList(ObjectPair),
        range: Range,
        repeat: struct { left: *Pattern.RNode, right: *Pattern.RNode },
        string: []const u8,
        string_template: ArrayList(*Pattern.RNode),
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
        key: *Pattern.RNode,
        value: *Pattern.RNode,
    };

    pub const Range = struct {
        lower: ?*Pattern.RNode,
        upper: ?*Pattern.RNode,
    };

    pub const Identifier = struct {
        name: StringTable.Id,
        builtin: bool,
        underscored: bool,
    };

    pub fn create(ast: *Ast, node: Node, region: Region) !*Pattern.RNode {
        const ptr = try ast.arena.allocator().create(Pattern.RNode);
        ptr.* = Pattern.RNode{ .region = region, .node = node };
        return ptr;
    }

    pub fn merge(ast: *Ast, a: Pattern.RNode, b: Pattern.RNode) error{ OutOfMemory, InvalidCharacter }!?Pattern.RNode {
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
                    const buffer = try ast.arena.allocator().alloc(u8, total_len);
                    @memcpy(buffer[0..a_str.len], a_str);
                    @memcpy(buffer[a_str.len..], b_str);
                    return Pattern.RNode{ .node = Node{ .string = buffer }, .region = merged_region };
                },
                else => null,
            },
            .range => |a_range| switch (b.node) {
                .range => |b_range| {
                    var lower: ?*Pattern.RNode = undefined;
                    var upper: ?*Pattern.RNode = undefined;

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

                        lower = try create(ast, .{ .number_float = lower_val }, merged_region);
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

                        upper = try create(ast, .{ .number_float = upper_val }, merged_region);
                    } else if (b_range.upper) |b_upper| {
                        if (!b_upper.node.isNumberElem()) return null;
                        upper = b_upper;
                    } else {
                        upper = null;
                    }

                    return Pattern.RNode{
                        .node = .{ .range = .{ .lower = lower, .upper = upper } },
                        .region = merged_region,
                    };
                },
                .number_float,
                .number_string,
                => {
                    return try mergeRangeAndNumberNodes(ast, a_range, b.node, merged_region);
                },
                else => null,
            },
            .number_float => |a_float| switch (b.node) {
                .number_float => |b_float| Pattern.RNode{
                    .node = .{ .number_float = a_float + b_float },
                    .region = merged_region,
                },
                .number_string => |ns| {
                    const b_float = try ns.toFloat();
                    return Pattern.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .range => |b_range| {
                    return try mergeRangeAndNumberNodes(ast, b_range, a.node, merged_region);
                },
                else => null,
            },
            .number_string => |a_nstr| switch (b.node) {
                .number_float => |b_float| {
                    const a_float = try a_nstr.toFloat();
                    return Pattern.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .number_string => |b_nstr| {
                    const a_float = try a_nstr.toFloat();
                    const b_float = try b_nstr.toFloat();
                    return Pattern.RNode{
                        .node = .{ .number_float = a_float + b_float },
                        .region = merged_region,
                    };
                },
                .range => |b_range| {
                    return try mergeRangeAndNumberNodes(ast, b_range, a.node, merged_region);
                },
                else => null,
            },
            else => null,
        };
    }

    fn mergeRangeAndNumberNodes(ast: *Ast, range: Range, number: Node, region: Region) error{ OutOfMemory, InvalidCharacter }!?Pattern.RNode {
        const float = if (number == .number_float)
            number.number_float
        else if (number == .number_string)
            try number.number_string.toFloat()
        else
            return null;

        var new_lower: ?*Pattern.RNode = null;
        var new_upper: ?*Pattern.RNode = null;

        if (range.lower) |lower| {
            const lower_val = if (lower.node == .number_float)
                lower.node.number_float
            else if (lower.node == .number_string)
                try lower.node.number_string.toFloat()
            else
                return null;

            new_lower = try create(ast, .{ .number_float = float + lower_val }, region);
        }

        if (range.upper) |upper| {
            const upper_val = if (upper.node == .number_float)
                upper.node.number_float
            else if (upper.node == .number_string)
                try upper.node.number_string.toFloat()
            else
                return null;

            new_upper = try create(ast, .{ .number_float = float + upper_val }, region);
        }

        return Pattern.RNode{
            .node = .{ .range = .{ .lower = new_lower, .upper = new_upper } },
            .region = region,
        };
    }

    pub fn negate(node: Pattern.RNode, region: Region) ?Pattern.RNode {
        return switch (node.node) {
            .number_float => |f| Pattern.RNode{
                .node = .{ .number_float = -f },
                .region = region,
            },
            .number_string => |ns| Pattern.RNode{
                .node = .{ .number_string = ns.negate() },
                .region = region,
            },
            .negation => |inner| negate(inner.*, region),
            else => null,
        };
    }

    pub fn repeat(ast: *Ast, a: Pattern.RNode, b: Pattern.RNode) error{ OutOfMemory, InvalidCharacter }!?Pattern.RNode {
        const merged_region = a.region.merge(b.region);

        return switch (a.node) {
            .range => |a_range| switch (b.node) {
                .range => |b_range| {
                    // Both ranges must be number ranges
                    const a_lower_val = if (a_range.lower) |lower| blk: {
                        if (!lower.node.isNumberElem()) return null;
                        const val = if (lower.node == .number_float)
                            lower.node.number_float
                        else
                            try lower.node.number_string.toFloat();
                        break :blk val;
                    } else 0;

                    const b_lower_val = if (b_range.lower) |lower| blk: {
                        if (!lower.node.isNumberElem()) return null;
                        const val = if (lower.node == .number_float)
                            lower.node.number_float
                        else
                            try lower.node.number_string.toFloat();
                        break :blk val;
                    } else 0;

                    const new_lower = a_lower_val * b_lower_val;
                    const new_lower_node = try create(ast, .{ .number_float = new_lower }, merged_region);

                    // Handle upper bounds
                    if (a_range.upper) |a_upper| {
                        if (!a_upper.node.isNumberElem()) return null;
                        const a_upper_val = if (a_upper.node == .number_float)
                            a_upper.node.number_float
                        else
                            try a_upper.node.number_string.toFloat();

                        if (b_range.upper) |b_upper| {
                            if (!b_upper.node.isNumberElem()) return null;
                            const b_upper_val = if (b_upper.node == .number_float)
                                b_upper.node.number_float
                            else
                                try b_upper.node.number_string.toFloat();
                            const new_upper = a_upper_val * b_upper_val;
                            const new_upper_node = try create(ast, .{ .number_float = new_upper }, merged_region);
                            return Pattern.RNode{
                                .node = .{ .range = .{ .lower = new_lower_node, .upper = new_upper_node } },
                                .region = merged_region,
                            };
                        } else {
                            // b is open range, result is open
                            return Pattern.RNode{
                                .node = .{ .range = .{ .lower = new_lower_node, .upper = null } },
                                .region = merged_region,
                            };
                        }
                    } else if (b_range.upper) |_| {
                        // a is open range, result is open
                        return Pattern.RNode{
                            .node = .{ .range = .{ .lower = new_lower_node, .upper = null } },
                            .region = merged_region,
                        };
                    } else {
                        // Both open ranges
                        return Pattern.RNode{
                            .node = .{ .range = .{ .lower = new_lower_node, .upper = null } },
                            .region = merged_region,
                        };
                    }
                },
                .number_float => |b_float| repeatRangeAndNumber(ast, a_range, b_float, merged_region),
                .number_string => |ns| blk: {
                    const b_float = try ns.toFloat();
                    break :blk repeatRangeAndNumber(ast, a_range, b_float, merged_region);
                },
                else => null,
            },
            .number_float => |a_float| switch (b.node) {
                .number_float => |b_float| Pattern.RNode{
                    .node = .{ .number_float = a_float * b_float },
                    .region = merged_region,
                },
                .number_string => |ns| {
                    const b_float = try ns.toFloat();
                    return Pattern.RNode{
                        .node = .{ .number_float = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .range => |b_range| repeatRangeAndNumber(ast, b_range, a_float, merged_region),
                else => null,
            },
            .number_string => |nsa| switch (b.node) {
                .number_float => |b_float| {
                    const a_float = try nsa.toFloat();
                    return Pattern.RNode{
                        .node = .{ .number_float = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .number_string => |nsb| blk: {
                    const a_float = try nsa.toFloat();
                    const b_float = try nsb.toFloat();
                    break :blk Pattern.RNode{
                        .node = .{ .number_float = a_float * b_float },
                        .region = merged_region,
                    };
                },
                .range => |b_range| blk: {
                    const a_float = try nsa.toFloat();
                    break :blk repeatRangeAndNumber(ast, b_range, a_float, merged_region);
                },
                else => null,
            },
            // For non-numbers, nodeB must be a non-negative integer
            .null, .true, .false => switch (b.node) {
                .number_float => |b_float| if (b_float >= 0 and b_float == @floor(b_float)) a else null,
                .number_string => |ns| {
                    const count = try ns.toFloat();
                    if (count < 0 or count != @floor(count)) return null;
                    return a;
                },
                else => null,
            },
            .string => |str| if (b.node == .number_float or b.node == .number_string) {
                const count_float = if (b.node == .number_float)
                    b.node.number_float
                else
                    try b.node.number_string.toFloat();

                if (count_float < 0 or count_float != @floor(count_float)) return null;
                const count = @as(usize, @intFromFloat(count_float));
                if (count == 0) return null;
                if (count == 1) return a;

                // Allocate buffer for repeated string
                const total_len = str.len * count;
                const buffer = try ast.arena.allocator().alloc(u8, total_len);
                for (0..count) |i| {
                    const start = i * str.len;
                    @memcpy(buffer[start .. start + str.len], str);
                }
                return Pattern.RNode{
                    .node = .{ .string = buffer },
                    .region = merged_region,
                };
            } else {
                return null;
            },
            .array => |arr| if (b.node == .number_float or b.node == .number_string) {
                const count_float = if (b.node == .number_float)
                    b.node.number_float
                else
                    try b.node.number_string.toFloat();

                if (count_float < 0 or count_float != @floor(count_float)) return null;
                const count = @as(usize, @intFromFloat(count_float));
                if (count == 0) return null;
                if (count == 1) return a;

                // Create new array with repeated elements
                var new_array = ArrayList(*Pattern.RNode){};
                try new_array.ensureTotalCapacity(ast.arena.allocator(), arr.items.len * count);
                for (0..count) |_| {
                    for (arr.items) |elem| {
                        new_array.appendAssumeCapacity(elem);
                    }
                }
                return Pattern.RNode{
                    .node = .{ .array = new_array },
                    .region = merged_region,
                };
            } else {
                return null;
            },
            .identifier => null,
            else => null, // Other types not supported
        };
    }

    fn repeatRangeAndNumber(ast: *Ast, range: Range, multiplier: f64, region: Region) error{ OutOfMemory, InvalidCharacter }!?Pattern.RNode {
        // multiplier must be non-negative
        if (multiplier < 0) return null;

        // Extract lower bound (default to 0)
        const lower_val = if (range.lower) |lower| blk: {
            if (!lower.node.isNumberElem()) return null;
            const val = if (lower.node == .number_float)
                lower.node.number_float
            else
                try lower.node.number_string.toFloat();
            break :blk val;
        } else 0;

        // Multiply lower bound
        const new_lower = lower_val * multiplier;
        const new_lower_node = try create(ast, .{ .number_float = new_lower }, region);

        // Handle upper bound if present
        if (range.upper) |upper| {
            if (!upper.node.isNumberElem()) return null;
            const upper_val = if (upper.node == .number_float)
                upper.node.number_float
            else
                try upper.node.number_string.toFloat();
            const new_upper = upper_val * multiplier;
            const new_upper_node = try create(ast, .{ .number_float = new_upper }, region);
            return Pattern.RNode{
                .node = .{ .range = .{ .lower = new_lower_node, .upper = new_upper_node } },
                .region = region,
            };
        } else {
            // Open range: lower..
            return Pattern.RNode{
                .node = .{ .range = .{ .lower = new_lower_node, .upper = null } },
                .region = region,
            };
        }
    }
};

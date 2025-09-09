const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Region = @import("region.zig").Region;

pub const Ast = struct {
    arena: ArenaAllocator,
    roots: ArrayList(*RNode),

    pub const RNode = union(enum) {
        parser: Parser.RNode,
        value: Value.RNode,
        pattern: Pattern.RNode,
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
};

pub const ParserOrValue = struct {
    pub const RNode = union(enum) {
        parser: Parser.RNode,
        value: Value.RNode,
    };

    pub const Identifier = union(enum) {
        parser: struct { region: *Region, node: *Parser.Identifier },
        value: struct { region: *Region, node: *Value.Identifier },
    };
};

pub const Parser = struct {
    pub const RNode = struct {
        region: Region,
        node: Node,
    };

    pub const NodeType = enum {
        string,
        number_string,
        string_template,
        range,
        function,
        alias_decl,
        function_decl,
        conditional,
        destructure,
        merge,
        @"or",
        backtrack,
        repeat,
        @"return",
        take_left,
        take_right,
        identifier,
        negation,
    };

    pub const Node = union(NodeType) {
        string: []const u8,
        number_string: NumberString,
        string_template: ArrayList(*RNode),
        range: Range,
        function_call: FunctionCall,
        alias_decl: AliasDecl,
        function_decl: FunctionDecl,
        conditional: Conditional,
        destructure: struct { left: *RNode, right: *RNode },
        merge: struct { left: *RNode, right: *RNode },
        @"or": struct { left: *RNode, right: *RNode },
        backtrack: struct { left: *RNode, right: *RNode },
        repeat: struct { left: *RNode, right: *Pattern.RNode },
        @"return": struct { left: *RNode, right: *Value.RNode },
        take_left: struct { left: *RNode, right: *RNode },
        take_right: struct { left: *RNode, right: *RNode },
        identifier: Identifier,
        negation: *RNode,
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
        lower: ?*RNode,
        upper: ?*RNode,
    };

    pub const FunctionCall = struct {
        function: *RNode,
        args: ArrayList(*ParserOrValue.RNode),
    };

    pub const AliasDecl = struct {
        name: *Identifier,
        name_region: *Region,
        body: *RNode,
    };

    pub const FunctionDecl = struct {
        name: *Identifier,
        name_region: *Region,
        params: ArrayList(ParserOrValue.Identifier),
        body: *RNode,
    };

    pub const Conditional = struct {
        condition: *RNode,
        then_branch: *RNode,
        else_branch: *RNode,
    };

    pub const Identifier = struct {
        name: []const u8,
        builtin: bool,
        underscored: bool,
    };
};

pub const Value = struct {
    pub const RNode = struct {
        region: Region,
        node: Node,
    };

    pub const NodeType = enum {
        string,
        number_string,
        number_float,
        true,
        false,
        null,
        array,
        object,
        string_template,
        conditional,
        function_call,
        alias_decl,
        function_decl,
        merge,
        repeat,
        @"or",
        take_left,
        take_right,
        @"return",
        number_subtract,
        identifier,
        negation,
    };

    pub const Node = union(NodeType) {
        string: []const u8,
        number_string: NumberString,
        number_float: f64,
        true,
        false,
        null,
        array: ArrayList(*RNode),
        object: ArrayList(ObjectPair),
        string_template: ArrayList(*RNode),
        conditional: Conditional,
        function_call: FunctionCall,
        alias_decl: AliasDecl,
        function_decl: FunctionDecl,
        destructure: struct { left: *RNode, right: *Pattern.RNode },
        merge: struct { left: *RNode, right: *RNode },
        repeat: struct { left: *RNode, right: *Pattern.RNode },
        @"or": struct { left: *RNode, right: *RNode },
        take_left: struct { left: *RNode, right: *RNode },
        take_right: struct { left: *RNode, right: *RNode },
        @"return": struct { left: *RNode, right: *RNode },
        number_subtract: struct { left: *RNode, right: *RNode },
        identifier: Identifier,
        negation: *RNode,
    };

    pub const NumberString = struct {
        number: []const u8,
        negated: bool,

        pub fn toFloat(self: NumberString) !f64 {
            const f = try std.fmt.parseFloat(f64, self.number);
            return if (self.negated) -f else f;
        }
    };

    pub const ObjectPair = struct {
        key: *RNode,
        value: *RNode,
    };

    pub const Conditional = struct {
        condition: *RNode,
        then_branch: *RNode,
        else_branch: *RNode,
    };

    pub const FunctionCall = struct {
        function: *RNode,
        args: ArrayList(*RNode),
    };

    pub const AliasDecl = struct {
        name: *Identifier,
        name_region: *Region,
        body: *RNode,
    };

    pub const FunctionDecl = struct {
        name: *Identifier,
        name_region: *Region,
        params: ArrayList(Identifier),
        body: *RNode,
    };

    pub const Identifier = struct {
        name: []const u8,
        builtin: bool,
        underscored: bool,
    };
};

pub const Pattern = struct {
    pub const RNode = struct {
        region: Region,
        node: Node,
    };

    pub const NodeType = enum {
        string,
        number_string,
        number_float,
        true,
        false,
        null,
        array,
        object,
        range,
        identifier,
        merge,
        repeat,
        number_subtract,
        function_call,
        negation,
    };

    pub const Node = union(NodeType) {
        string: []const u8,
        number_string: NumberString,
        number_float: f64,
        true,
        false,
        null,
        array: ArrayList(*RNode),
        object: ArrayList(ObjectPair),
        range: Range,
        identifier: Identifier,
        merge: struct { left: *RNode, right: *RNode },
        repeat: struct { left: *RNode, right: *RNode },
        number_subtract: struct { left: *RNode, right: *RNode },
        function_call: FunctionCall,
        negated: *RNode,
    };

    pub const NumberString = struct {
        number: []const u8,
        negated: bool,

        pub fn toFloat(self: NumberString) !f64 {
            const f = try std.fmt.parseFloat(f64, self.number);
            return if (self.negated) -f else f;
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
        name: []const u8,
        builtin: bool,
        underscored: bool,
    };

    pub const FunctionCall = struct {
        function: *RNode,
        args: ArrayList(*Value.RNode),
    };
};

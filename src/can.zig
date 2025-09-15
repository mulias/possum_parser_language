const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const StringHashMap = std.StringArrayHashMapUnmanaged;
const Writer = std.Io.Writer;
const Ast = @import("ast.zig").Ast;
const CanAst = @import("can_ast.zig");
const Module = @import("module.zig").Module;
const Region = @import("region.zig").Region;
const VM = @import("vm.zig").VM;
const Writers = @import("writer.zig").Writers;

pub const Can = struct {
    vm: *VM,
    module: Module,
    ast: Ast,
    can_ast: *CanAst.Ast,
    writers: Writers,

    const Error = error{
        OutOfMemory,
        InvalidGlobalValue,
        InvalidGlobalParser,
        UnlabeledStringValue,
        UnlabeledNumberValue,
        UnlabeledBooleanValue,
        UnlabeledNullValue,
        RangeNotValidInMergePattern,
        RangeNotValidInValueContext,
        InvalidAst,
        InvalidIdentifier,
        InvalidFunctionArgument,
        InvalidPatternNode,
        InvalidDestructurePattern,
        InvalidRepeatPattern,
    } || Writer.Error;

    pub fn canonicalize(self: *Can) !void {
        for (self.ast.roots.items) |root| {
            var can_root = try self.convertRoot(root);
            try self.foldConstants(&can_root);
            try self.can_ast.pushRoot(can_root);
        }
    }

    fn convertRoot(self: *Can, root: *Ast.RNode) !CanAst.Ast.RNode {
        if (root.node == .DeclareGlobal) {
            const global = root.node.DeclareGlobal;
            const head = global.head;
            const body = global.body;

            if (head.node == .Function) {
                // Function declaration
                const func = head.node.Function;

                const name_ident = switch (func.name.node) {
                    .Identifier => |ident| ident,
                    .False => Ast.IdentifierNode{
                        .name = "false",
                        .builtin = false,
                        .underscored = false,
                        .kind = .Parser,
                    },
                    .True => Ast.IdentifierNode{
                        .name = "true",
                        .builtin = false,
                        .underscored = false,
                        .kind = .Parser,
                    },
                    .Null => Ast.IdentifierNode{
                        .name = "null",
                        .builtin = false,
                        .underscored = false,
                        .kind = .Parser,
                    },
                    else => {
                        try self.printError(func.name.region, "Invalid function name", .{});
                        return Error.InvalidAst;
                    },
                };

                if (name_ident.kind == .Parser) {
                    const parser_func = try self.convertParserFunctionDecl(name_ident, func.name.region, func.paramsOrArgs, body, root.region);
                    return CanAst.Ast.RNode{ .parser = parser_func };
                } else {
                    const value_func = try self.convertValueFunctionDecl(name_ident, func.name.region, func.paramsOrArgs, body, root.region);
                    return CanAst.Ast.RNode{ .value = value_func };
                }
            } else if (head.node == .Identifier) {
                // Alias declaration
                const ident = head.node.Identifier;
                if (ident.kind == .Parser) {
                    const parser_alias = try self.convertParserAliasDecl(head, body);
                    return CanAst.Ast.RNode{ .parser = parser_alias };
                } else {
                    const value_alias = try self.convertValueAliasDecl(head, body);
                    return CanAst.Ast.RNode{ .value = value_alias };
                }
            } else {
                try self.printError(head.region, "Invalid global declaration head", .{});
                return Error.InvalidAst;
            }
        } else {
            // Top-level expression (main parser)
            const parser_node = try self.convertParser(root);
            return CanAst.Ast.RNode{ .parser = parser_node };
        }
    }

    fn convertParser(self: *Can, rnode: *Ast.RNode) Error!*CanAst.Parser.RNode {
        const region = rnode.region;
        const node = switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => CanAst.Parser.Node{ .backtrack = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertParser(infix.right),
                } },
                .Destructure => CanAst.Parser.Node{ .destructure = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .Merge => CanAst.Parser.Node{ .merge = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertParser(infix.right),
                } },
                .Or => CanAst.Parser.Node{ .@"or" = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertParser(infix.right),
                } },
                .Repeat => CanAst.Parser.Node{ .repeat = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .Return => CanAst.Parser.Node{ .@"return" = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .TakeLeft => CanAst.Parser.Node{ .take_left = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertParser(infix.right),
                } },
                .TakeRight => CanAst.Parser.Node{ .take_right = .{
                    .left = try self.convertParser(infix.left),
                    .right = try self.convertParser(infix.right),
                } },
                .NumberSubtract => {
                    try self.printError(region, "Number subtraction is not valid in parser context", .{});
                    return Error.InvalidAst;
                },
            },
            .Range => |range| CanAst.Parser.Node{ .range = .{
                .lower = if (range.lower) |l| try self.convertParser(l) else null,
                .upper = if (range.upper) |u| try self.convertParser(u) else null,
            } },
            .Negation => |inner| CanAst.Parser.Node{ .negation = try self.convertParser(inner) },
            .ValueLabel => {
                try self.printError(region, "Value label '$' is not valid in parser context", .{});
                return Error.InvalidAst;
            },
            .Array => {
                try self.printError(region, "Array literal is not valid in parser context", .{});
                return Error.InvalidAst;
            },
            .Object => {
                try self.printError(region, "Object literal is not valid in parser context", .{});
                return Error.InvalidAst;
            },
            .StringTemplate => |parts| CanAst.Parser.Node{ .string_template = try self.convertParserStringTemplate(parts) },
            .Conditional => |cond| CanAst.Parser.Node{ .conditional = .{
                .condition = try self.convertParser(cond.condition),
                .then_branch = try self.convertParser(cond.then_branch),
                .else_branch = try self.convertParser(cond.else_branch),
            } },
            .Function => |func| blk: {
                const name_node = func.name;
                const args = func.paramsOrArgs;

                const function = try self.convertParser(name_node);

                var converted_args = ArrayList(CanAst.ParserOrValue.RNode){};
                for (args.items) |arg| {
                    const converted = try self.convertParserFunctionCallArg(arg);
                    try converted_args.append(self.can_ast.arena.allocator(), converted);
                }

                break :blk CanAst.Parser.Node{ .function_call = .{
                    .function = function,
                    .args = converted_args,
                } };
            },
            .DeclareGlobal => {
                try self.printError(region, "Global declaration is not valid in expression context", .{});
                return Error.InvalidAst;
            },
            .False => CanAst.Parser.Node{ .identifier = .{
                .name = "false",
                .builtin = false,
                .underscored = false,
            } },
            .True => CanAst.Parser.Node{ .identifier = .{
                .name = "true",
                .builtin = false,
                .underscored = false,
            } },
            .Null => CanAst.Parser.Node{ .identifier = .{
                .name = "null",
                .builtin = false,
                .underscored = false,
            } },
            .NumberFloat => |f| CanAst.Parser.Node{ .number_string = .{
                .number = try std.fmt.allocPrint(self.can_ast.arena.allocator(), "{d}", .{f}),
                .negated = f < 0,
            } },
            .NumberString => |ns| CanAst.Parser.Node{ .number_string = .{
                .number = ns.number,
                .negated = ns.negated,
            } },
            .String => |s| CanAst.Parser.Node{ .string = s },
            .Identifier => |ident| blk: {
                if (ident.kind != .Parser) {
                    try self.printError(region, "Value identifier '{s}' is not valid in parser context", .{ident.name});
                    return Error.InvalidGlobalParser;
                }
                break :blk CanAst.Parser.Node{ .identifier = .{
                    .name = ident.name,
                    .builtin = ident.builtin,
                    .underscored = ident.underscored,
                } };
            },
        };

        return CanAst.Parser.create(self.can_ast, node, region);
    }

    fn convertValue(self: *Can, rnode: *Ast.RNode) Error!*CanAst.Value.RNode {
        const region = rnode.region;
        const node = switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Backtrack => {
                    try self.printError(region, "Backtrack ('<') is not valid in value context", .{});
                    return Error.InvalidAst;
                },
                .Destructure => CanAst.Value.Node{ .destructure = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .Merge => CanAst.Value.Node{ .merge = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .Or => CanAst.Value.Node{ .@"or" = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .Repeat => CanAst.Value.Node{ .repeat = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .Return => CanAst.Value.Node{ .@"return" = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .TakeLeft => CanAst.Value.Node{ .take_left = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .TakeRight => CanAst.Value.Node{ .take_right = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
                .NumberSubtract => CanAst.Value.Node{ .number_subtract = .{
                    .left = try self.convertValue(infix.left),
                    .right = try self.convertValue(infix.right),
                } },
            },
            .Range => {
                try self.printError(region, "Range is not valid in value context", .{});
                return Error.RangeNotValidInValueContext;
            },
            .Negation => |inner| CanAst.Value.Node{ .negation = try self.convertValue(inner) },
            .ValueLabel => |inner| {
                return self.convertValue(inner);
            },
            .Array => |elems| blk: {
                var converted = ArrayList(*CanAst.Value.RNode){};
                for (elems.items) |elem| {
                    const converted_elem = try self.convertValue(elem);
                    try converted.append(self.can_ast.arena.allocator(), converted_elem);
                }
                break :blk CanAst.Value.Node{ .array = converted };
            },
            .Object => |pairs| blk: {
                var converted = ArrayList(CanAst.Value.ObjectPair){};
                for (pairs.items) |pair| {
                    const converted_pair = CanAst.Value.ObjectPair{
                        .key = try self.convertValue(pair.key),
                        .value = try self.convertValue(pair.value),
                    };
                    try converted.append(self.can_ast.arena.allocator(), converted_pair);
                }
                break :blk CanAst.Value.Node{ .object = converted };
            },
            .StringTemplate => |parts| CanAst.Value.Node{ .string_template = try self.convertValueStringTemplate(parts) },
            .Conditional => |cond| CanAst.Value.Node{ .conditional = .{
                .condition = try self.convertValue(cond.condition),
                .then_branch = try self.convertValue(cond.then_branch),
                .else_branch = try self.convertValue(cond.else_branch),
            } },
            .Function => |func| CanAst.Value.Node{ .function_call = try self.convertValueFunctionCall(func) },
            .DeclareGlobal => {
                try self.printError(region, "Global declaration is not valid in expression context", .{});
                return Error.InvalidAst;
            },
            .False => CanAst.Value.Node.false,
            .True => CanAst.Value.Node.true,
            .Null => CanAst.Value.Node.null,
            .NumberFloat => |f| CanAst.Value.Node{ .number_float = f },
            .NumberString => |ns| blk: {
                // Try to convert to float for value context
                if (ns.toFloat()) |f| {
                    break :blk CanAst.Value.Node{ .number_float = f };
                } else |_| {
                    break :blk CanAst.Value.Node{ .number_string = .{
                        .number = ns.number,
                        .negated = ns.negated,
                    } };
                }
            },
            .String => |s| CanAst.Value.Node{ .string = s },
            .Identifier => |ident| blk: {
                if (ident.kind == .Parser) {
                    try self.printError(region, "Parser identifier '{s}' is not valid in value context", .{ident.name});
                    return Error.InvalidAst;
                }
                break :blk CanAst.Value.Node{ .identifier = .{
                    .name = ident.name,
                    .builtin = ident.builtin,
                    .underscored = ident.underscored,
                } };
            },
        };

        return CanAst.Value.create(self.can_ast, node, region);
    }

    fn convertLabeledValue(self: *Can, rnode: *Ast.RNode) Error!*CanAst.Value.RNode {
        const region = rnode.region;
        switch (rnode.node) {
            .InfixNode,
            .Range,
            .Negation,
            .ValueLabel,
            .Array,
            .Object,
            .Conditional,
            .Function,
            .DeclareGlobal,
            .Identifier,
            => return self.convertValue(rnode),
            .False => {
                try self.printError(region, "false must be labeled with $ to be treated as a value", .{});
                return Error.InvalidAst;
            },
            .True => {
                try self.printError(region, "true must be labeled with $ to be treated as a value", .{});
                return Error.InvalidAst;
            },
            .Null => {
                try self.printError(region, "null must be labeled with $ to be treated as a value", .{});
                return Error.InvalidAst;
            },
            .NumberFloat,
            .NumberString,
            => {
                try self.printError(region, "number must be labeled with $ to be treated as a value", .{});
                return Error.InvalidAst;
            },
            .String,
            .StringTemplate,
            => {
                try self.printError(region, "string must be labeled with $ to be treated as a value", .{});
                return Error.InvalidAst;
            },
        }
    }

    fn convertPattern(self: *Can, rnode: *Ast.RNode) Error!*CanAst.Pattern.RNode {
        const region = rnode.region;
        const node = switch (rnode.node) {
            .InfixNode => |infix| switch (infix.infixType) {
                .Merge => CanAst.Pattern.Node{ .merge = .{
                    .left = try self.convertPattern(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .Repeat => CanAst.Pattern.Node{ .repeat = .{
                    .left = try self.convertPattern(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                .NumberSubtract => CanAst.Pattern.Node{ .number_subtract = .{
                    .left = try self.convertPattern(infix.left),
                    .right = try self.convertPattern(infix.right),
                } },
                else => {
                    try self.printError(region, "Invalid operation in pattern context", .{});
                    return Error.InvalidPatternNode;
                },
            },
            .Range => |range| CanAst.Pattern.Node{ .range = .{
                .lower = if (range.lower) |l| try self.convertPattern(l) else null,
                .upper = if (range.upper) |u| try self.convertPattern(u) else null,
            } },
            .Negation => |inner| CanAst.Pattern.Node{ .negation = try self.convertPattern(inner) },
            .ValueLabel => {
                try self.printError(region, "Value label '$' is not valid in pattern context", .{});
                return Error.InvalidPatternNode;
            },
            .Array => |elems| blk: {
                var converted = ArrayList(*CanAst.Pattern.RNode){};
                for (elems.items) |elem| {
                    const converted_elem = try self.convertPattern(elem);
                    try converted.append(self.can_ast.arena.allocator(), converted_elem);
                }
                break :blk CanAst.Pattern.Node{ .array = converted };
            },
            .Object => |pairs| blk: {
                var converted = ArrayList(CanAst.Pattern.ObjectPair){};
                for (pairs.items) |pair| {
                    const converted_pair = CanAst.Pattern.ObjectPair{
                        .key = try self.convertPattern(pair.key),
                        .value = try self.convertPattern(pair.value),
                    };
                    try converted.append(self.can_ast.arena.allocator(), converted_pair);
                }
                break :blk CanAst.Pattern.Node{ .object = converted };
            },
            .StringTemplate => |parts| CanAst.Pattern.Node{ .string_template = try self.convertPatternStringTemplate(parts) },
            .Conditional => {
                try self.printError(region, "Conditional is not valid in pattern context", .{});
                return Error.InvalidPatternNode;
            },
            .Function => |func| CanAst.Pattern.Node{ .function_call = try self.convertValueFunctionCall(func) },
            .DeclareGlobal => {
                try self.printError(region, "Global declaration is not valid in pattern context", .{});
                return Error.InvalidPatternNode;
            },
            .False => CanAst.Pattern.Node.false,
            .True => CanAst.Pattern.Node.true,
            .Null => CanAst.Pattern.Node.null,
            .NumberFloat => |f| CanAst.Pattern.Node{ .number_float = f },
            .NumberString => |ns| blk: {
                // Try to convert to float for pattern context
                if (ns.toFloat()) |f| {
                    break :blk CanAst.Pattern.Node{ .number_float = f };
                } else |_| {
                    break :blk CanAst.Pattern.Node{ .number_string = .{
                        .number = ns.number,
                        .negated = ns.negated,
                    } };
                }
            },
            .String => |s| CanAst.Pattern.Node{ .string = s },
            .Identifier => |ident| CanAst.Pattern.Node{ .identifier = .{
                .name = ident.name,
                .builtin = ident.builtin,
                .underscored = ident.underscored,
            } },
        };

        return CanAst.Pattern.create(self.can_ast, node, region);
    }

    fn convertParserFunctionCallArg(self: *Can, rnode: *Ast.RNode) !CanAst.ParserOrValue.RNode {
        if (isParserArg(rnode.node)) {
            return CanAst.ParserOrValue.RNode{ .parser = try self.convertParser(rnode) };
        } else {
            return CanAst.ParserOrValue.RNode{ .value = try self.convertLabeledValue(rnode) };
        }
    }

    fn convertParserStringTemplate(self: *Can, parts: ArrayList(*Ast.RNode)) !ArrayList(*CanAst.Parser.RNode) {
        var converted = ArrayList(*CanAst.Parser.RNode){};
        try converted.ensureTotalCapacity(self.can_ast.arena.allocator(), parts.items.len);

        for (parts.items) |part| {
            const converted_part = try self.convertParser(part);
            converted.appendAssumeCapacity(converted_part);
        }

        return converted;
    }

    fn convertValueStringTemplate(self: *Can, parts: ArrayList(*Ast.RNode)) !ArrayList(*CanAst.Value.RNode) {
        var converted = ArrayList(*CanAst.Value.RNode){};
        try converted.ensureTotalCapacity(self.can_ast.arena.allocator(), parts.items.len);

        for (parts.items) |part| {
            const converted_part = try self.convertValue(part);
            converted.appendAssumeCapacity(converted_part);
        }

        return converted;
    }

    fn convertPatternStringTemplate(self: *Can, parts: ArrayList(*Ast.RNode)) !ArrayList(*CanAst.Pattern.RNode) {
        var converted = ArrayList(*CanAst.Pattern.RNode){};
        try converted.ensureTotalCapacity(self.can_ast.arena.allocator(), parts.items.len);

        for (parts.items) |part| {
            const converted_part = try self.convertPattern(part);
            converted.appendAssumeCapacity(converted_part);
        }

        return converted;
    }

    fn convertValueFunctionCall(self: *Can, func: Ast.FunctionNode) !CanAst.Value.FunctionCall {
        const name_node = func.name;
        const args = func.paramsOrArgs;

        const function = try self.convertValue(name_node);

        var converted_args = ArrayList(*CanAst.Value.RNode){};
        for (args.items) |arg| {
            const converted = try self.convertValue(arg);
            try converted_args.append(self.can_ast.arena.allocator(), converted);
        }

        return CanAst.Value.FunctionCall{
            .function = function,
            .args = converted_args,
        };
    }

    fn convertParserFunctionDecl(self: *Can, name_ident: Ast.IdentifierNode, name_region: Region, params: ArrayList(*Ast.RNode), body: *Ast.RNode, region: Region) !*CanAst.Parser.RNode {
        const can_name_ident = CanAst.Parser.Identifier{
            .name = name_ident.name,
            .builtin = name_ident.builtin,
            .underscored = name_ident.underscored,
        };

        var converted_params = ArrayList(CanAst.ParserOrValue.Identifier){};
        for (params.items) |param| {
            if (param.node != .Identifier) {
                try self.printError(param.region, "Invalid function parameter", .{});
                return Error.InvalidFunctionArgument;
            }

            const param_ident = param.node.Identifier;

            const pov_ident = if (param_ident.kind == .Parser)
                CanAst.ParserOrValue.Identifier{ .parser = .{
                    .region = param.region,
                    .node = .{
                        .name = param_ident.name,
                        .builtin = param_ident.builtin,
                        .underscored = param_ident.underscored,
                    },
                } }
            else
                CanAst.ParserOrValue.Identifier{ .value = .{
                    .region = param.region,
                    .node = .{
                        .name = param_ident.name,
                        .builtin = param_ident.builtin,
                        .underscored = param_ident.underscored,
                    },
                } };

            try converted_params.append(self.can_ast.arena.allocator(), pov_ident);
        }

        const decl_node = CanAst.Parser.Node{ .declaration = .{
            .name = can_name_ident,
            .name_region = name_region,
            .params = converted_params,
            .body = try self.convertParser(body),
        } };

        return CanAst.Parser.create(self.can_ast, decl_node, region);
    }

    fn convertValueFunctionDecl(self: *Can, name_ident: Ast.IdentifierNode, name_region: Region, params: ArrayList(*Ast.RNode), body: *Ast.RNode, region: Region) !*CanAst.Value.RNode {
        const can_name_ident = CanAst.Value.Identifier{
            .name = name_ident.name,
            .builtin = name_ident.builtin,
            .underscored = name_ident.underscored,
        };

        var converted_params = ArrayList(CanAst.Value.Identifier){};
        for (params.items) |param| {
            if (param.node != .Identifier) {
                try self.printError(param.region, "Invalid function parameter", .{});
                return Error.InvalidFunctionArgument;
            }

            const param_ident = param.node.Identifier;

            const value_ident = CanAst.Value.Identifier{
                .name = param_ident.name,
                .builtin = param_ident.builtin,
                .underscored = param_ident.underscored,
            };

            try converted_params.append(self.can_ast.arena.allocator(), value_ident);
        }

        const decl_node = CanAst.Value.Node{ .declaration = .{
            .name = can_name_ident,
            .name_region = name_region,
            .params = converted_params,
            .body = try self.convertValue(body),
        } };

        return CanAst.Value.create(self.can_ast, decl_node, region);
    }

    fn convertParserAliasDecl(self: *Can, name: *Ast.RNode, body: *Ast.RNode) !*CanAst.Parser.RNode {
        const name_ident = name.node.Identifier;
        const name_id = CanAst.Parser.Identifier{
            .name = name_ident.name,
            .builtin = name_ident.builtin,
            .underscored = name_ident.underscored,
        };

        const decl_node = CanAst.Parser.Node{ .declaration = .{
            .name = name_id,
            .name_region = name.region,
            .params = ArrayList(CanAst.ParserOrValue.Identifier){},
            .body = try self.convertParser(body),
        } };

        return CanAst.Parser.create(self.can_ast, decl_node, name.region);
    }

    fn convertValueAliasDecl(self: *Can, name: *Ast.RNode, body: *Ast.RNode) !*CanAst.Value.RNode {
        const name_ident = name.node.Identifier;
        const name_id = CanAst.Value.Identifier{
            .name = name_ident.name,
            .builtin = name_ident.builtin,
            .underscored = name_ident.underscored,
        };

        const decl_node = CanAst.Value.Node{ .declaration = .{
            .name = name_id,
            .name_region = name.region,
            .params = ArrayList(CanAst.Value.Identifier){},
            .body = try self.convertValue(body),
        } };

        return CanAst.Value.create(self.can_ast, decl_node, name.region);
    }

    fn foldConstants(self: *Can, rnode: *CanAst.Ast.RNode) !void {
        switch (rnode.*) {
            .parser => {},
            .value => {},
            .pattern => |pattern| {
                try self.foldPatternConstants(pattern);
            },
        }
    }

    fn foldPatternConstants(self: *Can, rnode: *CanAst.Pattern.RNode) !void {
        switch (rnode.node) {
            .array => |items| {
                for (items.items) |item| {
                    try self.foldPatternConstants(item);
                }
            },
            .merge => |merge| {
                try self.foldPatternConstants(merge.left);
                try self.foldPatternConstants(merge.right);
                if (try CanAst.Pattern.merge(self.can_ast, merge.left.*, merge.right.*)) |merged| {
                    rnode.* = merged;
                }
            },
            .repeat => |repeat| {
                try self.foldPatternConstants(repeat.left);
                try self.foldPatternConstants(repeat.right);
                if (try CanAst.Pattern.repeat(self.can_ast, repeat.left.*, repeat.right.*)) |repeated| {
                    rnode.* = repeated;
                }
            },
            .number_subtract => |subtract| {
                try self.foldPatternConstants(subtract.left);
                try self.foldPatternConstants(subtract.right);
                if (CanAst.Pattern.negate(subtract.right.*, rnode.region)) |neg_right| {
                    if (try CanAst.Pattern.merge(self.can_ast, subtract.left.*, neg_right)) |dif| {
                        rnode.* = dif;
                    }
                }
            },
            .range => |range| {
                if (range.lower) |lower| try self.foldPatternConstants(lower);
                if (range.upper) |upper| try self.foldPatternConstants(upper);
            },
            .negation => |inner| {
                try self.foldPatternConstants(inner);
                if (CanAst.Pattern.negate(inner.*, rnode.region)) |neg| {
                    rnode.* = neg;
                }
            },
            .object => |pairs| {
                for (pairs.items) |*pair| {
                    try self.foldPatternConstants(pair.key);
                    try self.foldPatternConstants(pair.value);
                }
            },
            .string_template => |parts| {
                for (parts.items) |part| {
                    try self.foldPatternConstants(part);
                }
            },
            .false,
            .function_call,
            .identifier,
            .null,
            .number_float,
            .number_string,
            .string,
            .true,
            => {},
        }
    }

    fn isParserArg(node: Ast.Node) bool {
        return switch (node) {
            .NumberFloat,
            .NumberString,
            .False,
            .Null,
            .True,
            .String,
            .StringTemplate,
            .Range,
            => true,
            .ValueLabel,
            .Array,
            .Object,
            => false,
            .Identifier => |ident| ident.kind == .Parser,
            .InfixNode => |infix| isParserArg(infix.left.node),
            .Negation => |inner| isParserArg(inner.node),
            .Conditional => |cond| isParserArg(cond.condition.node),
            .Function => |func| isParserArg(func.name.node),
            .DeclareGlobal => |decl| isParserArg(decl.head.node),
        };
    }

    fn printError(self: *Can, region: Region, comptime format: []const u8, args: anytype) !void {
        try self.writers.err.print("\nValidation Error: ", .{});
        try self.writers.err.print(format, args);
        try self.writers.err.print("\n\n", .{});

        try self.writers.err.print("{s}:", .{self.module.name});
        try region.printLineRelative(self.module.source, self.writers.err);
        try self.writers.err.print(":\n", .{});

        try self.module.highlight(region, self.writers.err);
        try self.writers.err.print("\n", .{});
    }
};

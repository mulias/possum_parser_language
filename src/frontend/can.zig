const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Ast = @import("can_ast.zig");
const Module = @import("../module.zig").Module;
const ParsedAst = @import("parsed_ast.zig").Ast;
const Region = @import("../region.zig").Region;
const StringTable = @import("../string_table.zig").StringTable;
const Writer = std.Io.Writer;
const Writers = @import("../writer.zig").Writers;
const std = @import("std");

arena: *ArenaAllocator,
writers: Writers,
module: Module,
strings: *StringTable,
ast: Ast = .{},
anonymous_function_count: u64 = 0,
current_parent_function_name: ?StringTable.Id = null,

pub const Can = @This();

const Error = error{
    OutOfMemory,
    InvalidGlobalParser,
    RangeNotValidInMergePattern,
    RangeNotValidInValueContext,
    InvalidAst,
    InvalidFunctionArgument,
    InvalidPatternNode,
    MultipleMainParsers,
} || Writer.Error;

pub fn init(
    arena: *ArenaAllocator,
    writers: Writers,
    strings: *StringTable,
    module: Module,
) Can {
    return Can{
        .arena = arena,
        .writers = writers,
        .strings = strings,
        .module = module,
    };
}

pub fn canonicalize(self: *Can, ast: ParsedAst) !void {
    for (ast.roots.items) |root| try self.convertRoot(root);
    try self.foldConstants();
}

fn addParserDeclaration(self: *Can, decl: *Ast.RNode(Ast.Parser.Declaration)) !void {
    try self.ast.declarations.append(self.arena.allocator(), .{ .parser = decl });
}

fn addAnonymousFunction(self: *Can, anon: *Ast.RNode(Ast.Parser.AnonymousFunction)) !void {
    try self.ast.anonymous_functions.append(self.arena.allocator(), anon);
}

fn addValueDeclaration(self: *Can, decl: *Ast.RNode(Ast.Value.Declaration)) !void {
    try self.ast.declarations.append(self.arena.allocator(), .{ .value = decl });
}

fn convertRoot(self: *Can, root: *ParsedAst.RNode) !void {
    self.current_parent_function_name = null;

    if (root.node == .DeclareGlobal) {
        const global = root.node.DeclareGlobal;
        const head = global.head;
        const body = global.body;

        if (head.node == .Function) {
            // Function declaration
            const func = head.node.Function;

            const name_ident = switch (func.name.node) {
                .Identifier => |ident| ident,
                .False => ParsedAst.IdentifierNode{
                    .name = "false",
                    .builtin = false,
                    .underscored = false,
                    .kind = .Parser,
                },
                .True => ParsedAst.IdentifierNode{
                    .name = "true",
                    .builtin = false,
                    .underscored = false,
                    .kind = .Parser,
                },
                .Null => ParsedAst.IdentifierNode{
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
                const parser_decl = try self.convertParserDecl(name_ident, func.name.region, func.paramsOrArgs, body, root.region);
                try self.addParserDeclaration(parser_decl);
            } else {
                const value_decl = try self.convertValueDecl(name_ident, func.name.region, func.paramsOrArgs, body, root.region);
                try self.addValueDeclaration(value_decl);
            }
        } else if (head.node == .Identifier) {
            // Alias declaration
            const name_ident = head.node.Identifier;
            if (name_ident.kind == .Parser) {
                const parser_decl = try self.convertParserDecl(name_ident, head.region, .{}, body, root.region);
                try self.addParserDeclaration(parser_decl);
            } else {
                const value_decl = try self.convertValueDecl(name_ident, head.region, .{}, body, root.region);
                try self.addValueDeclaration(value_decl);
            }
        } else {
            try self.printError(head.region, "Invalid global declaration head", .{});
            return Error.InvalidAst;
        }
    } else {
        if (self.ast.main == null) {
            const name = try self.strings.insert("@main");

            self.current_parent_function_name = name;
            const function_body = try self.convertParser(root);

            const main = try Ast.Parser.createAnonymousFunction(
                self.arena.allocator(),
                .{
                    .parent_name = null,
                    .name = name,
                    .body = function_body,
                },
                root.region,
            );

            self.ast.main = main;
            try self.addAnonymousFunction(main);
        } else {
            try self.printError(root.region, "Only one main parser expression is allowed per module", .{});
            return Error.MultipleMainParsers;
        }
    }
}

fn convertParser(self: *Can, rnode: *ParsedAst.RNode) Error!*Ast.Parser.RNode {
    const region = rnode.region;
    const node = switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Destructure => Ast.Parser.Node{ .destructure = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .Merge => Ast.Parser.Node{ .merge = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertParser(infix.right),
            } },
            .Or => Ast.Parser.Node{ .@"or" = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertParser(infix.right),
            } },
            .Repeat => Ast.Parser.Node{ .repeat = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .Return => Ast.Parser.Node{ .@"return" = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .TakeLeft => Ast.Parser.Node{ .take_left = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertParser(infix.right),
            } },
            .TakeRight => Ast.Parser.Node{ .take_right = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertParser(infix.right),
            } },
            .NumberSubtract => {
                try self.printError(region, "Number subtraction is not valid in parser context", .{});
                return Error.InvalidAst;
            },
        },
        .Range => |range| Ast.Parser.Node{ .range = .{
            .lower = if (range.lower) |l| try self.convertParser(l) else null,
            .upper = if (range.upper) |u| try self.convertParser(u) else null,
        } },
        .Negation => |inner| Ast.Parser.Node{ .negation = try self.convertParser(inner) },
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
        .StringTemplate => |parts| Ast.Parser.Node{ .string_template = try self.convertParserStringTemplate(parts) },
        .Conditional => |cond| Ast.Parser.Node{ .conditional = .{
            .condition = try self.convertParser(cond.condition),
            .then_branch = try self.convertParser(cond.then_branch),
            .else_branch = try self.convertParser(cond.else_branch),
        } },
        .Function => |func| blk: {
            const name_node = func.name;
            const args = func.paramsOrArgs;

            const function = try self.convertParser(name_node);

            var converted_args = ArrayList(Ast.ParserOrValue.RNode){};
            for (args.items) |arg| {
                const converted = try self.convertParserFunctionCallArg(arg);
                try converted_args.append(self.arena.allocator(), converted);
            }

            break :blk Ast.Parser.Node{ .function_call = .{
                .function = function,
                .args = converted_args,
            } };
        },
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in expression context", .{});
            return Error.InvalidAst;
        },
        .False => Ast.Parser.Node{ .identifier = .{
            .name = try self.strings.insert("false"),
            .builtin = false,
            .underscored = false,
        } },
        .True => Ast.Parser.Node{ .identifier = .{
            .name = try self.strings.insert("true"),
            .builtin = false,
            .underscored = false,
        } },
        .Null => Ast.Parser.Node{ .identifier = .{
            .name = try self.strings.insert("null"),
            .builtin = false,
            .underscored = false,
        } },
        .NumberFloat => |f| Ast.Parser.Node{ .number_string = .{
            .number = try std.fmt.allocPrint(self.arena.allocator(), "{d}", .{f}),
            .negated = f < 0,
        } },
        .NumberString => |ns| Ast.Parser.Node{ .number_string = .{
            .number = try self.arena.allocator().dupe(u8, ns.number),
            .negated = ns.negated,
        } },
        .String => |s| Ast.Parser.Node{ .string = try self.arena.allocator().dupe(u8, s) },
        .Identifier => |ident| blk: {
            if (ident.kind != .Parser) {
                try self.printError(region, "Value identifier '{s}' is not valid in parser context", .{ident.name});
                return Error.InvalidGlobalParser;
            }
            break :blk Ast.Parser.Node{ .identifier = .{
                .name = try self.strings.insert(ident.name),
                .builtin = ident.builtin,
                .underscored = ident.underscored,
            } };
        },
    };

    return Ast.Parser.create(self.arena.allocator(), node, region);
}

fn convertValue(self: *Can, rnode: *ParsedAst.RNode) Error!*Ast.Value.RNode {
    const region = rnode.region;
    const node = switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Destructure => Ast.Value.Node{ .destructure = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .Merge => Ast.Value.Node{ .merge = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .Or => Ast.Value.Node{ .@"or" = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .Repeat => Ast.Value.Node{ .repeat = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .Return => Ast.Value.Node{ .@"return" = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .TakeLeft => Ast.Value.Node{ .take_left = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .TakeRight => Ast.Value.Node{ .take_right = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } },
            .NumberSubtract => Ast.Value.Node{ .merge = .{
                .left = try self.convertValue(infix.left),
                .right = try Ast.Value.create(
                    self.arena.allocator(),
                    .{ .negation = try self.convertValue(infix.right) },
                    infix.right.region,
                ),
            } },
        },
        .Range => {
            try self.printError(region, "Range is not valid in value context", .{});
            return Error.RangeNotValidInValueContext;
        },
        .Negation => |inner| Ast.Value.Node{ .negation = try self.convertValue(inner) },
        .ValueLabel => |inner| {
            return self.convertValue(inner);
        },
        .Array => |elems| blk: {
            var converted = ArrayList(*Ast.Value.RNode){};
            for (elems.items) |elem| {
                const converted_elem = try self.convertValue(elem);
                try converted.append(self.arena.allocator(), converted_elem);
            }
            break :blk Ast.Value.Node{ .array = converted };
        },
        .Object => |pairs| blk: {
            var converted = ArrayList(Ast.Value.ObjectPair){};
            for (pairs.items) |pair| {
                const converted_pair = Ast.Value.ObjectPair{
                    .key = try self.convertValue(pair.key),
                    .value = try self.convertValue(pair.value),
                };
                try converted.append(self.arena.allocator(), converted_pair);
            }
            break :blk Ast.Value.Node{ .object = converted };
        },
        .StringTemplate => |parts| Ast.Value.Node{ .string_template = try self.convertValueStringTemplate(parts) },
        .Conditional => |cond| Ast.Value.Node{ .conditional = .{
            .condition = try self.convertValue(cond.condition),
            .then_branch = try self.convertValue(cond.then_branch),
            .else_branch = try self.convertValue(cond.else_branch),
        } },
        .Function => |func| Ast.Value.Node{ .function_call = try self.convertValueFunctionCall(func) },
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in expression context", .{});
            return Error.InvalidAst;
        },
        .False => Ast.Value.Node.false,
        .True => Ast.Value.Node.true,
        .Null => Ast.Value.Node.null,
        .NumberFloat => |f| Ast.Value.Node{ .number_float = f },
        .NumberString => |ns| blk: {
            // Try to convert to float for value context
            if (ns.toFloat()) |f| {
                break :blk Ast.Value.Node{ .number_float = f };
            } else |_| {
                break :blk Ast.Value.Node{ .number_string = .{
                    .number = try self.arena.allocator().dupe(u8, ns.number),
                    .negated = ns.negated,
                } };
            }
        },
        .String => |s| Ast.Value.Node{ .string = try self.arena.allocator().dupe(u8, s) },
        .Identifier => |ident| blk: {
            if (ident.kind == .Parser) {
                try self.printError(region, "Parser identifier '{s}' is not valid in value context", .{ident.name});
                return Error.InvalidAst;
            }
            break :blk Ast.Value.Node{ .identifier = .{
                .name = try self.strings.insert(ident.name),
                .builtin = ident.builtin,
                .underscored = ident.underscored,
            } };
        },
    };

    return Ast.Value.create(self.arena.allocator(), node, region);
}

fn convertLabeledValue(self: *Can, rnode: *ParsedAst.RNode) Error!*Ast.Value.RNode {
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

fn convertPattern(self: *Can, rnode: *ParsedAst.RNode) Error!*Ast.Pattern.RNode {
    const region = rnode.region;
    const node = switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Merge => Ast.Pattern.Node{ .merge = .{
                .left = try self.convertPattern(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .Repeat => Ast.Pattern.Node{ .repeat = .{
                .left = try self.convertPattern(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .NumberSubtract => Ast.Pattern.Node{ .merge = .{
                .left = try self.convertPattern(infix.left),
                .right = try Ast.Pattern.create(
                    self.arena.allocator(),
                    .{ .negation = try self.convertPattern(infix.right) },
                    infix.right.region,
                ),
            } },
            else => {
                try self.printError(region, "Invalid operation in pattern context", .{});
                return Error.InvalidPatternNode;
            },
        },
        .Range => |range| Ast.Pattern.Node{ .range = .{
            .lower = if (range.lower) |l| try self.convertPattern(l) else null,
            .upper = if (range.upper) |u| try self.convertPattern(u) else null,
        } },
        .Negation => |inner| Ast.Pattern.Node{ .negation = try self.convertPattern(inner) },
        .ValueLabel => {
            try self.printError(region, "Value label '$' is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .Array => |elems| blk: {
            var converted = ArrayList(*Ast.Pattern.RNode){};
            for (elems.items) |elem| {
                const converted_elem = try self.convertPattern(elem);
                try converted.append(self.arena.allocator(), converted_elem);
            }
            break :blk Ast.Pattern.Node{ .array = converted };
        },
        .Object => |pairs| blk: {
            var converted = ArrayList(Ast.Pattern.ObjectPair){};
            for (pairs.items) |pair| {
                const converted_pair = Ast.Pattern.ObjectPair{
                    .key = try self.convertPattern(pair.key),
                    .value = try self.convertPattern(pair.value),
                };
                try converted.append(self.arena.allocator(), converted_pair);
            }
            break :blk Ast.Pattern.Node{ .object = converted };
        },
        .StringTemplate => |parts| Ast.Pattern.Node{ .string_template = try self.convertPatternStringTemplate(parts) },
        .Conditional => {
            try self.printError(region, "Conditional is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .Function => |func| Ast.Pattern.Node{ .function_call = try self.convertValueFunctionCall(func) },
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .False => Ast.Pattern.Node.false,
        .True => Ast.Pattern.Node.true,
        .Null => Ast.Pattern.Node.null,
        .NumberFloat => |f| Ast.Pattern.Node{ .number_float = f },
        .NumberString => |ns| blk: {
            // Try to convert to float for pattern context
            if (ns.toFloat()) |f| {
                break :blk Ast.Pattern.Node{ .number_float = f };
            } else |_| {
                break :blk Ast.Pattern.Node{ .number_string = .{
                    .number = try self.arena.allocator().dupe(u8, ns.number),
                    .negated = ns.negated,
                } };
            }
        },
        .String => |s| Ast.Pattern.Node{ .string = try self.arena.allocator().dupe(u8, s) },
        .Identifier => |ident| blk: {
            if (ident.kind == .Parser) {
                try self.printError(region, "Parser variable not allowed in pattern", .{});
                return Error.InvalidPatternNode;
            }
            break :blk Ast.Pattern.Node{ .identifier = .{
                .name = try self.strings.insert(ident.name),
                .builtin = ident.builtin,
                .underscored = ident.underscored,
            } };
        },
    };

    return Ast.Pattern.create(self.arena.allocator(), node, region);
}

fn convertParserFunctionCallArg(self: *Can, rnode: *ParsedAst.RNode) !Ast.ParserOrValue.RNode {
    if (isParserArg(rnode.node)) {
        // Numbers, strings, and identifiers are all single elems which can be
        // passed as args. Everything else requires a function for bytecode.
        switch (rnode.node) {
            .NumberFloat,
            .NumberString,
            .False,
            .Null,
            .True,
            .String,
            .Identifier,
            => {
                return Ast.ParserOrValue.RNode{ .parser = try self.convertParser(rnode) };
            },
            else => {
                const name = try self.nextAnonymousFunctionName();
                const parent_name = self.current_parent_function_name;

                self.current_parent_function_name = name;
                const function_body = try self.convertParser(rnode);
                self.current_parent_function_name = parent_name;

                const anon = try Ast.Parser.createAnonymousFunction(
                    self.arena.allocator(),
                    .{
                        .parent_name = parent_name,
                        .name = name,
                        .body = function_body,
                    },
                    rnode.region,
                );

                try self.addAnonymousFunction(anon);

                return Ast.ParserOrValue.RNode{
                    .parser = try Ast.Parser.create(
                        self.arena.allocator(),
                        .{ .anonymous_function = anon.node },
                        rnode.region,
                    ),
                };
            },
        }
    } else {
        return Ast.ParserOrValue.RNode{ .value = try self.convertLabeledValue(rnode) };
    }
}

fn convertParserStringTemplate(self: *Can, parts: ArrayList(*ParsedAst.RNode)) !ArrayList(*Ast.Parser.RNode) {
    var converted = ArrayList(*Ast.Parser.RNode){};
    try converted.ensureTotalCapacity(self.arena.allocator(), parts.items.len);

    for (parts.items) |part| {
        const converted_part = try self.convertParser(part);
        converted.appendAssumeCapacity(converted_part);
    }

    return converted;
}

fn convertValueStringTemplate(self: *Can, parts: ArrayList(*ParsedAst.RNode)) !ArrayList(*Ast.Value.RNode) {
    var converted = ArrayList(*Ast.Value.RNode){};
    try converted.ensureTotalCapacity(self.arena.allocator(), parts.items.len);

    for (parts.items) |part| {
        const converted_part = try self.convertValue(part);
        converted.appendAssumeCapacity(converted_part);
    }

    return converted;
}

fn convertPatternStringTemplate(self: *Can, parts: ArrayList(*ParsedAst.RNode)) !ArrayList(*Ast.Pattern.RNode) {
    var converted = ArrayList(*Ast.Pattern.RNode){};
    try converted.ensureTotalCapacity(self.arena.allocator(), parts.items.len);

    for (parts.items) |part| {
        const converted_part = try self.convertPattern(part);
        converted.appendAssumeCapacity(converted_part);
    }

    return converted;
}

fn convertValueFunctionCall(self: *Can, func: ParsedAst.FunctionNode) !Ast.Value.FunctionCall {
    const name_node = func.name;
    const args = func.paramsOrArgs;

    const function = try self.convertValue(name_node);

    var converted_args = ArrayList(*Ast.Value.RNode){};
    for (args.items) |arg| {
        const converted = try self.convertValue(arg);
        try converted_args.append(self.arena.allocator(), converted);
    }

    return Ast.Value.FunctionCall{
        .function = function,
        .args = converted_args,
    };
}

fn convertParserDecl(
    self: *Can,
    name_ident: ParsedAst.IdentifierNode,
    name_region: Region,
    params: ArrayList(*ParsedAst.RNode),
    body: *ParsedAst.RNode,
    region: Region,
) !*Ast.RNode(Ast.Parser.Declaration) {
    const can_name_ident = Ast.Parser.Identifier{
        .name = try self.strings.insert(name_ident.name),
        .builtin = name_ident.builtin,
        .underscored = name_ident.underscored,
    };

    self.current_parent_function_name = can_name_ident.name;

    var converted_params = ArrayList(Ast.ParserOrValue.Identifier){};
    for (params.items) |param| {
        if (param.node != .Identifier) {
            try self.printError(param.region, "Invalid function parameter", .{});
            return Error.InvalidFunctionArgument;
        }

        const param_ident = param.node.Identifier;

        const pov_ident = if (param_ident.kind == .Parser)
            Ast.ParserOrValue.Identifier{ .parser = try Ast.Parser.createIdent(
                self.arena.allocator(),
                .{
                    .name = try self.strings.insert(param_ident.name),
                    .builtin = param_ident.builtin,
                    .underscored = param_ident.underscored,
                },
                param.region,
            ) }
        else
            Ast.ParserOrValue.Identifier{ .value = try Ast.Value.createIdent(
                self.arena.allocator(),
                .{
                    .name = try self.strings.insert(param_ident.name),
                    .builtin = param_ident.builtin,
                    .underscored = param_ident.underscored,
                },
                param.region,
            ) };

        try converted_params.append(self.arena.allocator(), pov_ident);
    }

    const decl_node = Ast.Parser.Declaration{
        .ident = try Ast.Parser.createIdent(self.arena.allocator(), can_name_ident, name_region),
        .params = converted_params,
        .body = try self.convertParser(body),
    };

    return Ast.Parser.createDeclaration(self.arena.allocator(), decl_node, region);
}

fn convertValueDecl(
    self: *Can,
    name_ident: ParsedAst.IdentifierNode,
    name_region: Region,
    params: ArrayList(*ParsedAst.RNode),
    body: *ParsedAst.RNode,
    region: Region,
) !*Ast.RNode(Ast.Value.Declaration) {
    const can_name_ident = Ast.Value.Identifier{
        .name = try self.strings.insert(name_ident.name),
        .builtin = name_ident.builtin,
        .underscored = name_ident.underscored,
    };

    self.current_parent_function_name = can_name_ident.name;

    var converted_params = ArrayList(*Ast.RNode(Ast.Value.Identifier)){};
    for (params.items) |param| {
        if (param.node != .Identifier) {
            try self.printError(param.region, "Invalid function parameter", .{});
            return Error.InvalidFunctionArgument;
        }

        const param_ident = param.node.Identifier;

        const value_ident = try Ast.Value.createIdent(
            self.arena.allocator(),
            .{
                .name = try self.strings.insert(param_ident.name),
                .builtin = param_ident.builtin,
                .underscored = param_ident.underscored,
            },
            param.region,
        );

        try converted_params.append(self.arena.allocator(), value_ident);
    }

    const decl_node = Ast.Value.Declaration{
        .ident = try Ast.Value.createIdent(self.arena.allocator(), can_name_ident, name_region),
        .params = converted_params,
        .body = try self.convertValue(body),
    };

    return Ast.Value.createDeclaration(self.arena.allocator(), decl_node, region);
}

fn foldConstants(self: *Can) !void {
    if (self.ast.main) |main| {
        try self.foldParserConstants(main.node.body);
    }

    for (self.ast.declarations.items) |decl| {
        switch (decl) {
            .parser => |parser_decl| {
                try self.foldParserConstants(parser_decl.node.body);
            },
            .value => |value_decl| {
                try self.foldValueConstants(value_decl.node.body);
            },
        }
    }
}

fn foldParserConstants(self: *Can, node: *Ast.Parser.RNode) !void {
    switch (node.node) {
        .@"or" => |or_node| {
            try self.foldParserConstants(or_node.left);
            try self.foldParserConstants(or_node.right);
        },
        .@"return" => |ret_node| {
            try self.foldParserConstants(ret_node.left);
            try self.foldValueConstants(ret_node.right);
        },
        .anonymous_function => |anon| {
            try self.foldParserConstants(anon.body);
        },
        .backtrack => |bt_node| {
            try self.foldParserConstants(bt_node.left);
            try self.foldParserConstants(bt_node.right);
        },
        .conditional => |cond| {
            try self.foldParserConstants(cond.condition);
            try self.foldParserConstants(cond.then_branch);
            try self.foldParserConstants(cond.else_branch);
        },
        .destructure => |dest| {
            try self.foldParserConstants(dest.left);
            try self.foldPatternConstants(dest.right);
        },
        .function_call => |func| {
            try self.foldParserConstants(func.function);
            for (func.args.items) |arg| {
                switch (arg) {
                    .parser => |p| try self.foldParserConstants(p),
                    .value => |v| try self.foldValueConstants(v),
                }
            }
        },
        .merge => |merge| {
            try self.foldParserConstants(merge.left);
            try self.foldParserConstants(merge.right);
        },
        .negation => |neg| {
            try self.foldParserConstants(neg);
        },
        .range => |range| {
            if (range.lower) |lower| try self.foldParserConstants(lower);
            if (range.upper) |upper| try self.foldParserConstants(upper);
        },
        .repeat => |rep| {
            try self.foldParserConstants(rep.left);
            try self.foldPatternConstants(rep.right);
        },
        .string_template => |tmpl| {
            for (tmpl.items) |item| {
                try self.foldParserConstants(item);
            }
        },
        .take_left => |take| {
            try self.foldParserConstants(take.left);
            try self.foldParserConstants(take.right);
        },
        .take_right => |take| {
            try self.foldParserConstants(take.left);
            try self.foldParserConstants(take.right);
        },
        .identifier, .number_string, .string => {},
    }
}

fn foldValueConstants(self: *Can, rnode: *Ast.Value.RNode) !void {
    switch (rnode.node) {
        .@"or" => |or_node| {
            try self.foldValueConstants(or_node.left);
            try self.foldValueConstants(or_node.right);
        },
        .@"return" => |ret_node| {
            try self.foldValueConstants(ret_node.left);
            try self.foldValueConstants(ret_node.right);
        },
        .array => |arr| {
            for (arr.items) |item| {
                try self.foldValueConstants(item);
            }
        },
        .conditional => |cond| {
            try self.foldValueConstants(cond.condition);
            try self.foldValueConstants(cond.then_branch);
            try self.foldValueConstants(cond.else_branch);
        },
        .destructure => |dest| {
            try self.foldValueConstants(dest.left);
            try self.foldPatternConstants(dest.right);
        },
        .function_call => |func| {
            try self.foldValueConstants(func.function);
            for (func.args.items) |arg| {
                try self.foldValueConstants(arg);
            }
        },
        .merge => |merge| {
            try self.foldValueConstants(merge.left);
            try self.foldValueConstants(merge.right);
            if (try Ast.Value.merge(self.arena.allocator(), merge.left.*, merge.right.*)) |merged| {
                rnode.* = merged;
            }
        },
        .negation => |inner| {
            try self.foldValueConstants(inner);
            if (Ast.Value.negate(inner.*, rnode.region)) |neg| {
                rnode.* = neg;
            }
        },
        .object => |obj| {
            for (obj.items) |pair| {
                try self.foldValueConstants(pair.key);
                try self.foldValueConstants(pair.value);
            }
        },
        .repeat => |rep| {
            try self.foldValueConstants(rep.left);
            try self.foldValueConstants(rep.right);
        },
        .string_template => |tmpl| {
            for (tmpl.items) |item| {
                try self.foldValueConstants(item);
            }
        },
        .take_left => |take| {
            try self.foldValueConstants(take.left);
            try self.foldValueConstants(take.right);
        },
        .take_right => |take| {
            try self.foldValueConstants(take.left);
            try self.foldValueConstants(take.right);
        },
        .identifier, .number_float, .number_string, .string, .false, .true, .null => {},
    }
}

fn foldPatternConstants(self: *Can, rnode: *Ast.Pattern.RNode) !void {
    switch (rnode.node) {
        .array => |items| {
            for (items.items) |item| {
                try self.foldPatternConstants(item);
            }
        },
        .merge => |merge| {
            try self.foldPatternConstants(merge.left);
            try self.foldPatternConstants(merge.right);
            if (try Ast.Pattern.merge(self.arena.allocator(), merge.left.*, merge.right.*)) |merged| {
                rnode.* = merged;
            }
        },
        .repeat => |repeat| {
            try self.foldPatternConstants(repeat.left);
            try self.foldPatternConstants(repeat.right);
            if (try Ast.Pattern.repeat(self.arena.allocator(), repeat.left.*, repeat.right.*)) |repeated| {
                rnode.* = repeated;
            }
        },
        .range => |range| {
            if (range.lower) |lower| try self.foldPatternConstants(lower);
            if (range.upper) |upper| try self.foldPatternConstants(upper);
        },
        .negation => |inner| {
            try self.foldPatternConstants(inner);
            if (Ast.Pattern.negate(inner.*, rnode.region)) |neg| {
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

fn isParserArg(node: ParsedAst.Node) bool {
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

fn nextAnonymousFunctionName(self: *Can) !StringTable.Id {
    const name_str = try std.fmt.allocPrint(
        self.arena.allocator(),
        "@fn{d}",
        .{self.anonymous_function_count},
    );
    self.anonymous_function_count += 1;
    return try self.strings.insert(name_str);
}

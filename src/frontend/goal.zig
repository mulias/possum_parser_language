const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Writer = std.Io.Writer;
const Ast = @import("goal_ast.zig");
const ParsedAst = @import("parsed_ast.zig").Ast;
const Pattern = @import("pattern_tree.zig");
const Module = @import("../runtime.zig").Module;
const StringTable = @import("string_table.zig").FrontendStringTable;
const PathTable = @import("path_table.zig").PathTable;
const Region = @import("../region.zig").Region;
const Writers = @import("../writer.zig").Writers;

arena: *ArenaAllocator,
writers: Writers,
module: Module,
strings: *StringTable,
paths: *PathTable,
ast: Ast = .{},
// Counters for generated names. They must run in lockstep with the
// canonicalizer's during the dual-build window so goal lambda names and
// import-alias references match the dependency graph the resolver builds
// from can.
anonymous_function_count: u64 = 0,
import_alias_count: u64 = 0,
current_parent_function_name: ?PathTable.Id = null,
// Declaration and alias names already bound in this module, for the
// duplicate-declaration check.
declared_names: std.AutoHashMapUnmanaged(PathTable.Id, void) = .{},
// The pipeline stage a print was requested at. At the created stage
// (before lowering) matches and repeats print their pattern; at the
// folded and bound stages they print the lowered constraints. Set at the
// start of print.
print_stage: Ast.Stage = .bound,
// Set for the duration of a foldBody call: the frontend-supplied resolver
// that answers "does this identifier name a constant scalar global?", for
// inlining. Null outside folding, so the idempotent re-folds run during
// lowering never inline.
inline_resolver: ?InlineResolver = null,

pub const Goal = @This();
pub const NodeId = Ast.NodeId;
pub const SetId = Ast.SetId;
pub const PlaceId = Ast.PlaceId;

// GoalAstGap: a construct the goal ast cannot express yet.
// PatternTooLarge: a place index, length, or key count exceeds what the
// match-step byte encoding admits.
// InvalidAst and the context/import/param variants: context violations
// build rejects, each printed with a message before the error is raised.
pub const Error = error{
    OutOfMemory,
    GoalAstGap,
    MergeTypeConflict,
    PatternTooLarge,
    InvalidCharacter,
    InvalidAst,
    InvalidGlobalParser,
    InvalidImport,
    InvalidPatternNode,
    InvalidFunctionArgument,
    MultipleMainParsers,
    DuplicateParameterName,
    NamespacedParameterName,
    DuplicateDeclaration,
    ReservedBuiltinName,
    RangeNotValidInValueContext,
} || Writer.Error;

pub fn init(
    arena: *ArenaAllocator,
    writers: Writers,
    strings: *StringTable,
    paths: *PathTable,
    module: Module,
) Goal {
    return Goal{
        .arena = arena,
        .writers = writers,
        .strings = strings,
        .paths = paths,
        .module = module,
    };
}

// Build the goal ast directly from the parsed ast: the same context
// validation, thunking, and alt/seq/template desugaring the canonicalizer
// performs, emitting goal nodes and pattern trees. Context violations the
// canonicalizer rejects are unreachable here — it runs first and aborts —
// so their branches return InvalidAst without a message.
pub fn build(self: *Goal, parsed: ParsedAst) Error!void {
    for (parsed.roots.items) |root| try self.convertRoot(root);
}

fn convertRoot(self: *Goal, root: *ParsedAst.RNode) Error!void {
    self.current_parent_function_name = null;

    if (root.node == .Import and root.node.Import.selector == null) {
        // An unqualified dump: the module's public exports bind bare.
        try self.ast.imports.append(self.alloc(), .{
            .path = importPath(root.node.Import.path),
            .target = .{ .dump = .{ .private = root.node.Import.private } },
            .region = root.region,
        });
        return;
    }

    if (root.node == .DeclareGlobal) {
        const global = root.node.DeclareGlobal;
        const head = global.head;
        const body = global.body;

        if (head.node == .Function) {
            const func = head.node.Function;
            const name_ident = try self.declName(func.name, "Invalid function name");
            if (name_ident.kind == .Parser) {
                try self.addParserDeclaration(name_ident, func.name.region, func.paramsOrArgs.items, body, root.region);
            } else {
                try self.addValueDeclaration(name_ident, func.name.region, func.paramsOrArgs.items, body, root.region);
            }
        } else {
            const name_ident = try self.declName(head, "Invalid alias name");
            if (body.node == .Import) {
                return self.addImportAlias(name_ident, head.region, body.node.Import.*, root.region);
            }
            if (name_ident.kind == .Parser) {
                try self.addParserDeclaration(name_ident, head.region, &.{}, body, root.region);
            } else {
                try self.addValueDeclaration(name_ident, head.region, &.{}, body, root.region);
            }
        }
    } else if (self.ast.main == null) {
        const name = try self.paths.insert(self.strings, "@main");
        self.current_parent_function_name = name;
        self.ast.main = try self.convertParser(root);
        self.ast.main_name = name;
        self.ast.main_region = root.region;
        self.ast.main_order = self.anonymous_function_count;
    } else {
        try self.printError(root.region, "Only one main parser expression is allowed per module", .{});
        return Error.MultipleMainParsers;
    }
}

// The declared name for a function head, synthesizing an identifier for
// the reserved-word declarations `false`, `true`, and `null`, and
// rejecting `@`-prefixed builtin names.
fn declName(self: *Goal, name_node: *ParsedAst.RNode, comptime invalid_message: []const u8) Error!ParsedAst.IdentifierNode {
    const name_ident: ParsedAst.IdentifierNode = switch (name_node.node) {
        .Identifier => |ident| ident,
        .False => .{ .name = "false", .builtin = false, .underscored = false, .kind = .Parser },
        .True => .{ .name = "true", .builtin = false, .underscored = false, .kind = .Parser },
        .Null => .{ .name = "null", .builtin = false, .underscored = false, .kind = .Parser },
        else => {
            try self.printError(name_node.region, invalid_message, .{});
            return Error.InvalidAst;
        },
    };
    if (name_ident.builtin) {
        try self.printError(name_node.region, "Unable to declare '{s}', '@' is reserved for builtins", .{name_ident.name});
        return Error.ReservedBuiltinName;
    }
    return name_ident;
}

fn addImportAlias(
    self: *Goal,
    name_ident: ParsedAst.IdentifierNode,
    name_region: Region,
    import: ParsedAst.ImportNode,
    region: Region,
) Error!void {
    if (import.private) {
        try self.printError(region, "'_!' cannot be aliased; a '_'-prefixed alias is already private: '_name = !...'", .{});
        return Error.InvalidImport;
    }

    const alias_name = try self.paths.insert(self.strings, name_ident.name);
    try self.checkDuplicateDeclaration(alias_name, name_region);

    const selector = if (import.selector) |s|
        try self.paths.insert(self.strings, s)
    else
        null;

    try self.ast.imports.append(self.alloc(), .{
        .path = importPath(import.path),
        .target = .{ .alias = .{ .name = alias_name, .selector = selector } },
        .region = region,
    });
}

fn checkDuplicateDeclaration(self: *Goal, name: PathTable.Id, region: Region) Error!void {
    const gop = try self.declared_names.getOrPut(self.alloc(), name);
    if (gop.found_existing) {
        try self.printError(region, "'{s}' is already declared in this module", .{self.strings.get(self.paths.flat(name))});
        return Error.DuplicateDeclaration;
    }
}

fn addParserDeclaration(
    self: *Goal,
    name_ident: ParsedAst.IdentifierNode,
    name_region: Region,
    params: []const *ParsedAst.RNode,
    body: *ParsedAst.RNode,
    region: Region,
) Error!void {
    const name = try self.paths.insert(self.strings, name_ident.name);
    self.current_parent_function_name = name;

    var param_ids = ArrayList(PathTable.Id){};
    try param_ids.ensureTotalCapacity(self.alloc(), params.len);
    var param_types: u32 = 0;
    for (params, 0..) |param, i| {
        const pident = try self.appendParam(param, &param_ids);
        if (pident.kind == .Value and i < 32) param_types |= @as(u32, 1) << @intCast(i);
    }

    const body_id = try self.convertParser(body);
    try self.checkDuplicateDeclaration(name, name_region);

    try self.ast.declarations.append(self.alloc(), .{
        .name = name,
        .underscored = name_ident.underscored,
        .params = param_ids,
        .param_types = param_types,
        .body = body_id,
        .region = region,
        .ident_region = name_region,
    });
}

// Validate one declaration parameter and append its interned name. A
// parameter must be a bare, non-builtin, non-namespaced identifier, unique
// within the parameter list.
fn appendParam(self: *Goal, param: *ParsedAst.RNode, param_ids: *ArrayList(PathTable.Id)) Error!ParsedAst.IdentifierNode {
    if (param.node != .Identifier) {
        try self.printError(param.region, "Invalid function parameter", .{});
        return Error.InvalidFunctionArgument;
    }
    const pident = param.node.Identifier;
    if (pident.builtin) {
        try self.printError(param.region, "Invalid function param, '@' is reserved for builtins", .{});
        return Error.ReservedBuiltinName;
    }
    if (std.mem.indexOfScalar(u8, pident.name, '.') != null) {
        try self.printError(param.region, "Invalid function param, '.' is reserved for namespaces", .{});
        return Error.NamespacedParameterName;
    }
    const id = try self.paths.insert(self.strings, pident.name);
    for (param_ids.items) |existing| {
        if (existing == id) {
            try self.printError(param.region, "Duplicate parameter '{s}'", .{pident.name});
            return Error.DuplicateParameterName;
        }
    }
    try param_ids.append(self.alloc(), id);
    return pident;
}

fn addValueDeclaration(
    self: *Goal,
    name_ident: ParsedAst.IdentifierNode,
    name_region: Region,
    params: []const *ParsedAst.RNode,
    body: *ParsedAst.RNode,
    region: Region,
) Error!void {
    const name = try self.paths.insert(self.strings, name_ident.name);

    var param_ids = ArrayList(PathTable.Id){};
    try param_ids.ensureTotalCapacity(self.alloc(), params.len);
    var param_types: u32 = 0;
    for (params, 0..) |param, i| {
        _ = try self.appendParam(param, &param_ids);
        if (i < 32) param_types |= @as(u32, 1) << @intCast(i);
    }

    const body_id = try self.convertValue(body);
    try self.checkDuplicateDeclaration(name, name_region);

    try self.ast.declarations.append(self.alloc(), .{
        .name = name,
        .underscored = name_ident.underscored,
        .params = param_ids,
        .param_types = param_types,
        .body = body_id,
        .region = region,
        .ident_region = name_region,
    });
}

fn alloc(self: *Goal) Allocator {
    return self.arena.allocator();
}

fn nextAnonymousFunctionName(self: *Goal) Error!PathTable.Id {
    const name_str = try std.fmt.allocPrint(
        self.alloc(),
        "@fn{d}",
        .{self.anonymous_function_count},
    );
    self.anonymous_function_count += 1;
    return try self.paths.insert(self.strings, name_str);
}

// The synthesized private alias an import expression mounts on: the member
// is mounted on a '_@'-prefixed alias and the expression becomes a bare
// reference to it. The counter runs in lockstep with the canonicalizer so
// the referencing ident matches the dependency graph, and the import is
// recorded so the resolver mounts the alias.
fn importExpressionAlias(self: *Goal, import: ParsedAst.ImportNode, kind: enum { parser, value }, region: Region) Error!PathTable.Id {
    if (import.private) {
        try self.printError(region, "'_!' is not an expression; an import expression is already private: '!...'", .{});
        return Error.InvalidImport;
    }
    const alias_str = switch (kind) {
        .parser => try std.fmt.allocPrint(self.alloc(), "_@import{d}", .{self.import_alias_count}),
        .value => try std.fmt.allocPrint(self.alloc(), "_@Import{d}", .{self.import_alias_count}),
    };
    self.import_alias_count += 1;
    const alias_name = try self.paths.insert(self.strings, alias_str);
    try self.ast.imports.append(self.alloc(), .{
        .path = importPath(import.path),
        .target = .{ .alias = .{
            .name = alias_name,
            .selector = try self.paths.insert(self.strings, import.selector.?),
        } },
        .region = region,
    });
    return alias_name;
}

fn importPath(path: ParsedAst.ImportNode.Path) Ast.Import.Path {
    return switch (path) {
        .file => |p| .{ .file = p },
        .stdlib => |p| .{ .stdlib = p },
    };
}

fn importSelectorKind(selector: []const u8) enum { parser, value } {
    for (selector) |c| {
        if (c == '_' or c == '@') continue;
        return if (std.ascii.isUpper(c)) .value else .parser;
    }
    return .parser;
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
        .Import => |import| if (import.selector) |selector|
            importSelectorKind(selector) == .parser
        else
            true,
        .InfixNode => |infix| isParserArg(infix.left.node),
        .Negation => |inner| isParserArg(inner.node),
        .Conditional => |cond| isParserArg(cond.condition.node),
        .Function => |func| isParserArg(func.name.node),
        .DeclareGlobal => |decl| isParserArg(decl.head.node),
    };
}

// Operand position: the parser runs here. Bare identifiers and literal
// parsers are invoked, so they lower to zero-arg calls; their value forms
// appear only in argument, callee, and range-bound positions
// (convertParserValue).
fn convertParser(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Destructure => self.convertDestructure(
                try self.convertParser(infix.left),
                try self.convertPattern(infix.right),
                region,
            ),
            .Merge => self.addGoal(.{ .merge = .{
                .left = try self.convertParser(infix.left),
                .right = try self.convertParser(infix.right),
            } }, region),
            .Or => self.convertParserAlt(rnode),
            .Repeat => blk: {
                const body = try self.convertParser(infix.left);
                const count_pattern = try self.convertPattern(infix.right);
                try self.validateRepeatCountPattern(count_pattern);
                break :blk self.addGoal(.{ .repeat = .{
                    .body = body,
                    .count_pattern = count_pattern,
                    .cap = .none,
                    .count_test = null,
                } }, region);
            },
            .Return => self.seqPair(
                try self.convertParser(infix.left),
                try self.convertValue(infix.right),
                1,
                region,
            ),
            .TakeLeft => self.seqPair(
                try self.convertParser(infix.left),
                try self.convertParser(infix.right),
                0,
                region,
            ),
            .TakeRight => self.seqPair(
                try self.convertParser(infix.left),
                try self.convertParser(infix.right),
                1,
                region,
            ),
            .NumberSubtract => {
                try self.printError(region, "Number subtraction is not valid in parser context", .{});
                return Error.InvalidAst;
            },
        },
        .Range => |r| self.invoked(try self.addGoal(.{ .range = .{
            .lower = if (r.lower) |lower| try self.convertParserValue(lower) else null,
            .upper = if (r.upper) |upper| try self.convertParserValue(upper) else null,
        } }, region), region),
        .Negation => self.invoked(try self.addGoal(.{
            .number_string = try self.parserNumberFields(rnode),
        }, region), region),
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
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in expression context", .{});
            return Error.InvalidAst;
        },
        .StringTemplate => |parts| self.convertParserTemplate(parts, region),
        .Conditional => self.convertParserAlt(rnode),
        .Function => |func| self.convertParserCall(func, region),
        .False => self.invoked(try self.nameIdentGoal(try self.paths.insert(self.strings, "false"), .parser, region), region),
        .True => self.invoked(try self.nameIdentGoal(try self.paths.insert(self.strings, "true"), .parser, region), region),
        .Null => self.invoked(try self.nameIdentGoal(try self.paths.insert(self.strings, "null"), .parser, region), region),
        .NumberFloat, .NumberString => self.invoked(try self.addGoal(.{
            .number_string = try self.parserNumberFields(rnode),
        }, region), region),
        .String => |s| self.invoked(try self.addGoal(.{ .string = try self.alloc().dupe(u8, s) }, region), region),
        .Identifier => |ident| if (ident.kind != .Parser) {
            try self.printError(region, "Value identifier '{s}' is not valid in parser context", .{ident.name});
            return Error.InvalidGlobalParser;
        } else self.invoked(try self.parsedIdentGoal(ident, .parser, region), region),
        .Import => |import| blk: {
            const selector = import.selector orelse {
                try self.printError(region, "A module import is not an expression; bind it with 'name = !...' first", .{});
                return Error.InvalidImport;
            };
            if (importSelectorKind(selector) != .parser) {
                try self.printError(region, "Value member '{s}' is not valid in parser context", .{selector});
                return Error.InvalidImport;
            }
            const name = try self.importExpressionAlias(import.*, .parser, region);
            break :blk self.invoked(try self.nameIdentGoal(name, .parser, region), region);
        },
    };
}

// The number_string fields for a parser-context number literal or its
// negation, mirroring the canonicalizer: a NumberFloat prints to a
// string tagged negative when below zero, a bare negation flips a
// non-negated literal, and a double negation is rejected.
fn parserNumberFields(self: *Goal, rnode: *ParsedAst.RNode) Error!Ast.NumberString {
    return switch (rnode.node) {
        .NumberFloat => |f| .{
            .number = try std.fmt.allocPrint(self.alloc(), "{d}", .{f}),
            .negated = f < 0,
        },
        .NumberString => |ns| .{
            .number = try self.alloc().dupe(u8, ns.number),
            .negated = ns.negated,
        },
        .Negation => |inner| blk: {
            const fields = try self.parserNumberFields(inner);
            if (fields.negated) break :blk Error.InvalidAst;
            break :blk .{ .number = fields.number, .negated = true };
        },
        else => Error.InvalidAst,
    };
}

fn convertParserCall(self: *Goal, func: ParsedAst.FunctionNode, region: Region) Error!NodeId {
    const callee = try self.convertParserValue(func.name);
    const args = try self.alloc().alloc(NodeId, func.paramsOrArgs.items.len);
    var value_args: u32 = 0;
    for (func.paramsOrArgs.items, 0..) |arg, i| {
        const converted = try self.convertParserFunctionCallArg(arg);
        args[i] = converted.id;
        if (converted.is_value and i < 32) value_args |= @as(u32, 1) << @intCast(i);
    }
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = value_args,
    } }, region);
}

// One argument to a parser function call. A simple parser elem (number,
// string, bare identifier) passes as itself; a composite parser thunks
// into an anonymous function; a value argument (label, array, object)
// evaluates eagerly.
const ConvertedArg = struct { id: NodeId, is_value: bool };

fn convertParserFunctionCallArg(self: *Goal, rnode: *ParsedAst.RNode) Error!ConvertedArg {
    if (isParserArg(rnode.node)) {
        switch (rnode.node) {
            .NumberFloat,
            .NumberString,
            .False,
            .Null,
            .True,
            .String,
            .Identifier,
            => return .{ .id = try self.convertParserValue(rnode), .is_value = false },
            else => {
                const name = try self.nextAnonymousFunctionName();
                const parent = self.current_parent_function_name;

                self.current_parent_function_name = name;
                const body = try self.convertParser(rnode);
                self.current_parent_function_name = parent;

                return .{ .id = try self.addGoal(.{ .lambda = .{
                    .parent_name = parent,
                    .name = name,
                    .body = body,
                } }, rnode.region), .is_value = false };
            },
        }
    } else {
        return .{ .id = try self.convertLabeledValue(rnode), .is_value = true };
    }
}

// Value position within a parser context: arguments, callees, range
// bounds. Parsers are passed, never invoked. Identifiers pass the
// function, literals pass the literal parser elem.
fn convertParserValue(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .Identifier => |ident| self.parsedIdentGoal(ident, .parser, region),
        .False => self.nameIdentGoal(try self.paths.insert(self.strings, "false"), .parser, region),
        .True => self.nameIdentGoal(try self.paths.insert(self.strings, "true"), .parser, region),
        .Null => self.nameIdentGoal(try self.paths.insert(self.strings, "null"), .parser, region),
        .String => |s| self.addGoal(.{ .string = try self.alloc().dupe(u8, s) }, region),
        .NumberFloat, .NumberString, .Negation => self.addGoal(.{
            .number_string = try self.parserNumberFields(rnode),
        }, region),
        .Import => |import| blk: {
            const selector = import.selector orelse {
                try self.printError(region, "A module import is not an expression; bind it with 'name = !...' first", .{});
                return Error.InvalidImport;
            };
            if (importSelectorKind(selector) != .parser) {
                try self.printError(region, "Value member '{s}' is not valid in parser context", .{selector});
                return Error.InvalidImport;
            }
            const name = try self.importExpressionAlias(import.*, .parser, region);
            break :blk self.nameIdentGoal(name, .parser, region);
        },
        else => self.convertParser(rnode),
    };
}

// "Hello %(name)" as a parser is `call("Hello") + to_string(call(name))`:
// a merge fold over the segments, stringifying interpolations.
fn convertParserTemplate(
    self: *Goal,
    parts: ArrayList(*ParsedAst.RNode),
    region: Region,
) Error!NodeId {
    var acc: ?NodeId = null;
    for (parts.items) |part| {
        const parsed = try self.convertParser(part);
        const segment = switch (part.node) {
            .String => parsed,
            else => try self.addGoal(.{ .to_string = parsed }, part.region),
        };
        acc = if (acc) |left|
            try self.addGoal(.{ .merge = .{ .left = left, .right = segment } }, region)
        else
            segment;
    }
    return acc orelse self.invoked(try self.addGoal(.{ .string = "" }, region), region);
}

fn convertParserAlt(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    var arms = ArrayList(Ast.AltArm){};
    try self.collectParserAltArms(rnode, &arms);
    return self.addGoal(.{ .alt = arms }, rnode.region);
}

// Flattens `|` and `?:` chains into one ordered arm list. The guard/body
// split is the commit point: guard failure tries the next arm, body
// failure fails the whole alt. The final operand is always a body-only
// arm; nested chains in final position splice, so no pass downstream sees
// a right-nested alt.
fn collectParserAltArms(
    self: *Goal,
    rnode: *ParsedAst.RNode,
    arms: *ArrayList(Ast.AltArm),
) Error!void {
    switch (rnode.node) {
        .InfixNode => |infix| if (infix.infixType == .Or) {
            try arms.append(self.alloc(), .{
                .guard = try self.convertParser(infix.left),
                .body = null,
            });
            try self.collectParserAltArms(infix.right, arms);
        } else {
            try arms.append(self.alloc(), .{
                .guard = null,
                .body = try self.convertParser(rnode),
            });
        },
        .Conditional => |cond| {
            try arms.append(self.alloc(), .{
                .guard = try self.convertParser(cond.condition),
                .body = try self.convertParser(cond.then_branch),
            });
            try self.collectParserAltArms(cond.else_branch, arms);
        },
        else => try arms.append(self.alloc(), .{
            .guard = null,
            .body = try self.convertParser(rnode),
        }),
    }
}

// A value argument to a parser function, or a `$`-labeled value. Bare
// literals must be labeled to read as values; the canonicalizer reports
// an unlabeled one first.
fn convertLabeledValue(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    return switch (rnode.node) {
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
        .Import,
        => self.convertValue(rnode),
        .False => {
            try self.printError(rnode.region, "false must be labeled with $ to be treated as a value", .{});
            return Error.InvalidAst;
        },
        .True => {
            try self.printError(rnode.region, "true must be labeled with $ to be treated as a value", .{});
            return Error.InvalidAst;
        },
        .Null => {
            try self.printError(rnode.region, "null must be labeled with $ to be treated as a value", .{});
            return Error.InvalidAst;
        },
        .NumberFloat, .NumberString => {
            try self.printError(rnode.region, "number must be labeled with $ to be treated as a value", .{});
            return Error.InvalidAst;
        },
        .String, .StringTemplate => {
            try self.printError(rnode.region, "string must be labeled with $ to be treated as a value", .{});
            return Error.InvalidAst;
        },
    };
}

// Value position: everything is eager, arguments included. A bare
// identifier stays a value; a zero-arg value function is an alias for its
// value, so no call is inserted.
fn convertValue(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Destructure => self.convertDestructure(
                try self.convertValue(infix.left),
                try self.convertPattern(infix.right),
                region,
            ),
            .Merge => self.addGoal(.{ .merge = .{
                .left = try self.convertValue(infix.left),
                .right = try self.convertValue(infix.right),
            } }, region),
            .Or => self.convertValueAlt(rnode),
            .Repeat => blk: {
                const left = try self.convertValue(infix.left);
                const right = try self.convertValue(infix.right);
                try self.validateRepeatCountValue(infix.right);
                break :blk self.addGoal(.{ .mult = .{ .left = left, .right = right } }, region);
            },
            .Return => self.seqPair(
                try self.convertValue(infix.left),
                try self.convertValue(infix.right),
                1,
                region,
            ),
            .TakeLeft => self.seqPair(
                try self.convertValue(infix.left),
                try self.convertValue(infix.right),
                0,
                region,
            ),
            .TakeRight => self.seqPair(
                try self.convertValue(infix.left),
                try self.convertValue(infix.right),
                1,
                region,
            ),
            .NumberSubtract => self.addGoal(.{ .merge = .{
                .left = try self.convertValue(infix.left),
                .right = try self.addGoal(.{
                    .neg = try self.convertValue(infix.right),
                }, infix.right.region),
            } }, region),
        },
        .Range => {
            try self.printError(region, "Range is not valid in value context", .{});
            return Error.RangeNotValidInValueContext;
        },
        .Negation => |inner| self.addGoal(.{ .neg = try self.convertValue(inner) }, region),
        .ValueLabel => |inner| self.convertValue(inner),
        .Array => |elems| blk: {
            var items = ArrayList(NodeId){};
            try items.ensureTotalCapacity(self.alloc(), elems.items.len);
            for (elems.items) |elem| items.appendAssumeCapacity(try self.convertValue(elem));
            break :blk self.addGoal(.{ .array = items }, region);
        },
        .Object => |pairs| blk: {
            var converted = ArrayList(Ast.ObjectPair){};
            try converted.ensureTotalCapacity(self.alloc(), pairs.items.len);
            for (pairs.items) |pair| converted.appendAssumeCapacity(.{
                .key = try self.convertValue(pair.key),
                .value = try self.convertValue(pair.value),
            });
            break :blk self.addGoal(.{ .object = converted }, region);
        },
        .StringTemplate => |parts| self.convertValueTemplate(parts, region),
        .Conditional => self.convertValueAlt(rnode),
        .Function => |func| self.convertValueCall(func, region),
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in expression context", .{});
            return Error.InvalidAst;
        },
        .False => self.addGoal(.false, region),
        .True => self.addGoal(.true, region),
        .Null => self.addGoal(.null, region),
        .NumberFloat => |f| self.addGoal(.{ .number_float = f }, region),
        .NumberString => |ns| if (ns.toFloat()) |f|
            self.addGoal(.{ .number_float = f }, region)
        else |_|
            self.addGoal(.{ .number_string = .{
                .number = try self.alloc().dupe(u8, ns.number),
                .negated = ns.negated,
            } }, region),
        .String => |s| self.addGoal(.{ .string = try self.alloc().dupe(u8, s) }, region),
        .Identifier => |ident| if (ident.kind == .Parser) {
            try self.printError(region, "Parser identifier '{s}' is not valid in value context", .{ident.name});
            return Error.InvalidAst;
        } else self.parsedIdentGoal(ident, .value, region),
        .Import => |import| blk: {
            const selector = import.selector orelse {
                try self.printError(region, "A module import is not an expression; bind it with 'Name = !...' first", .{});
                return Error.InvalidImport;
            };
            if (importSelectorKind(selector) != .value) {
                try self.printError(region, "Parser member '{s}' is not valid in value context", .{selector});
                return Error.InvalidImport;
            }
            const name = try self.importExpressionAlias(import.*, .value, region);
            break :blk self.nameIdentGoal(name, .value, region);
        },
    };
}

fn convertValueCall(self: *Goal, func: ParsedAst.FunctionNode, region: Region) Error!NodeId {
    const callee = try self.convertValue(func.name);
    const args = try self.alloc().alloc(NodeId, func.paramsOrArgs.items.len);
    for (func.paramsOrArgs.items, 0..) |arg, i| args[i] = try self.convertValue(arg);
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = allValueArgs(args.len),
    } }, region);
}

fn convertValueTemplate(
    self: *Goal,
    parts: ArrayList(*ParsedAst.RNode),
    region: Region,
) Error!NodeId {
    var acc: ?NodeId = null;
    for (parts.items) |part| {
        const value = try self.convertValue(part);
        const segment = switch (part.node) {
            .String => value,
            else => try self.addGoal(.{ .to_string = value }, part.region),
        };
        acc = if (acc) |left|
            try self.addGoal(.{ .merge = .{ .left = left, .right = segment } }, region)
        else
            segment;
    }
    return acc orelse self.addGoal(.{ .string = "" }, region);
}

fn convertValueAlt(self: *Goal, rnode: *ParsedAst.RNode) Error!NodeId {
    var arms = ArrayList(Ast.AltArm){};
    try self.collectValueAltArms(rnode, &arms);
    return self.addGoal(.{ .alt = arms }, rnode.region);
}

fn collectValueAltArms(
    self: *Goal,
    rnode: *ParsedAst.RNode,
    arms: *ArrayList(Ast.AltArm),
) Error!void {
    switch (rnode.node) {
        .InfixNode => |infix| if (infix.infixType == .Or) {
            try arms.append(self.alloc(), .{
                .guard = try self.convertValue(infix.left),
                .body = null,
            });
            try self.collectValueAltArms(infix.right, arms);
        } else {
            try arms.append(self.alloc(), .{
                .guard = null,
                .body = try self.convertValue(rnode),
            });
        },
        .Conditional => |cond| {
            try arms.append(self.alloc(), .{
                .guard = try self.convertValue(cond.condition),
                .body = try self.convertValue(cond.then_branch),
            });
            try self.collectValueAltArms(cond.else_branch, arms);
        },
        else => try arms.append(self.alloc(), .{
            .guard = null,
            .body = try self.convertValue(rnode),
        }),
    }
}

// A pattern tree built from the parsed ast, folded before lowering.
// Context violations are unreachable — the canonicalizer rejects them
// first.
fn convertPattern(self: *Goal, rnode: *ParsedAst.RNode) Error!*Pattern.RNode {
    const region = rnode.region;
    const node: Pattern.Node = switch (rnode.node) {
        .InfixNode => |infix| switch (infix.infixType) {
            .Merge => .{ .merge = .{
                .left = try self.convertPattern(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .Repeat => .{ .repeat = .{
                .left = try self.convertPattern(infix.left),
                .right = try self.convertPattern(infix.right),
            } },
            .NumberSubtract => .{ .merge = .{
                .left = try self.convertPattern(infix.left),
                .right = try Pattern.create(
                    self.alloc(),
                    .{ .negation = try self.convertPattern(infix.right) },
                    infix.right.region,
                ),
            } },
            else => {
                try self.printError(region, "Invalid operation in pattern context", .{});
                return Error.InvalidPatternNode;
            },
        },
        .Range => |range| .{ .range = .{
            .lower = if (range.lower) |l| try self.convertPattern(l) else null,
            .upper = if (range.upper) |u| try self.convertPattern(u) else null,
        } },
        .Negation => |inner| .{ .negation = try self.convertPattern(inner) },
        .ValueLabel => {
            try self.printError(region, "Value label '$' is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .Conditional => {
            try self.printError(region, "Conditional is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .DeclareGlobal => {
            try self.printError(region, "Global declaration is not valid in pattern context", .{});
            return Error.InvalidPatternNode;
        },
        .Array => |elems| blk: {
            var converted = ArrayList(*Pattern.RNode){};
            try converted.ensureTotalCapacity(self.alloc(), elems.items.len);
            for (elems.items) |elem| converted.appendAssumeCapacity(try self.convertPattern(elem));
            break :blk .{ .array = converted };
        },
        .Object => |pairs| blk: {
            var converted = ArrayList(Pattern.ObjectPair){};
            try converted.ensureTotalCapacity(self.alloc(), pairs.items.len);
            for (pairs.items) |pair| converted.appendAssumeCapacity(.{
                .key = try self.convertPattern(pair.key),
                .value = try self.convertPattern(pair.value),
            });
            break :blk .{ .object = converted };
        },
        .StringTemplate => |parts| blk: {
            var converted = ArrayList(*Pattern.RNode){};
            try converted.ensureTotalCapacity(self.alloc(), parts.items.len);
            for (parts.items) |part| converted.appendAssumeCapacity(try self.convertPattern(part));
            break :blk .{ .string_template = converted };
        },
        .Function => |func| .{ .function_call = try self.convertValueCall(func, region) },
        .False => .false,
        .True => .true,
        .Null => .null,
        .NumberFloat => |f| .{ .number_float = f },
        .NumberString => |ns| if (ns.toFloat()) |f|
            Pattern.Node{ .number_float = f }
        else |_|
            Pattern.Node{ .number_string = .{
                .number = try self.alloc().dupe(u8, ns.number),
                .negated = ns.negated,
            } },
        .String => |s| .{ .string = try self.alloc().dupe(u8, s) },
        .Identifier => |ident| if (ident.kind == .Parser) {
            try self.printError(region, "Parser variable not allowed in pattern", .{});
            return Error.InvalidPatternNode;
        } else .{ .identifier = .{
            .name = try self.paths.insert(self.strings, ident.name),
            .builtin = ident.builtin,
            .underscored = ident.underscored,
        } },
        .Import => |import| blk: {
            const selector = import.selector orelse {
                try self.printError(region, "A module import is not an expression", .{});
                return Error.InvalidImport;
            };
            if (importSelectorKind(selector) != .value) {
                try self.printError(region, "Parser member '{s}' not allowed in pattern", .{selector});
                return Error.InvalidPatternNode;
            }
            break :blk .{ .identifier = .{
                .name = try self.importExpressionAlias(import.*, .value, region),
                .builtin = false,
                .underscored = false,
            } };
        },
    };
    return Pattern.create(self.alloc(), node, region);
}

// A repeat count must be numeric at runtime, so its expression is
// restricted to shapes that can produce a number: numbers, variables,
// function calls, ranges of those (pattern counts only), and merges,
// negations, and repeats of those.
fn validateRepeatCountPattern(self: *Goal, pattern: *Pattern.RNode) Error!void {
    switch (pattern.node) {
        .number_float, .number_string, .identifier, .function_call => {},
        .merge => |m| {
            try self.validateRepeatCountPattern(m.left);
            try self.validateRepeatCountPattern(m.right);
        },
        .repeat => |r| {
            try self.validateRepeatCountPattern(r.left);
            try self.validateRepeatCountPattern(r.right);
        },
        .negation => |inner| try self.validateRepeatCountPattern(inner),
        .range => |range| {
            if (range.lower) |lower| try self.validateRepeatCountPattern(lower);
            if (range.upper) |upper| try self.validateRepeatCountPattern(upper);
        },
        .array, .object, .string, .string_template, .true, .false, .null => try self.repeatCountInvalid(pattern.region),
    }
}

// A value-context repeat count, checked on the parsed node. Value context
// admits no range, so a range count falls through to the error.
fn validateRepeatCountValue(self: *Goal, rnode: *ParsedAst.RNode) Error!void {
    switch (rnode.node) {
        .NumberFloat, .NumberString, .Identifier, .Function => {},
        .Negation => |inner| try self.validateRepeatCountValue(inner),
        .ValueLabel => |inner| try self.validateRepeatCountValue(inner),
        .InfixNode => |infix| switch (infix.infixType) {
            .Merge, .NumberSubtract, .Repeat => {
                try self.validateRepeatCountValue(infix.left);
                try self.validateRepeatCountValue(infix.right);
            },
            else => try self.repeatCountInvalid(rnode.region),
        },
        else => try self.repeatCountInvalid(rnode.region),
    }
}

fn repeatCountInvalid(self: *Goal, region: Region) Error!void {
    try self.printError(region, "Repeat count must be a number, variable, function call, or a compound of those", .{});
    return Error.InvalidAst;
}

fn parsedIdentGoal(self: *Goal, ident: ParsedAst.IdentifierNode, kind: Ast.Ident.Kind, region: Region) Error!NodeId {
    return self.addGoal(.{ .ident = .{
        .name = try self.paths.insert(self.strings, ident.name),
        .builtin = ident.builtin,
        .underscored = ident.underscored,
        .kind = kind,
    } }, region);
}

fn nameIdentGoal(self: *Goal, name: PathTable.Id, kind: Ast.Ident.Kind, region: Region) Error!NodeId {
    return self.addGoal(.{ .ident = .{
        .name = name,
        .builtin = false,
        .underscored = false,
        .kind = kind,
    } }, region);
}

fn printError(self: *Goal, region: Region, comptime format: []const u8, args: anytype) !void {
    try self.writers.err.print("\nValidation Error: ", .{});
    try self.writers.err.print(format, args);
    try self.writers.err.print("\n\n", .{});

    try self.writers.err.print("{s}:", .{self.module.name});
    try region.printLineRelative(self.module.source, self.writers.err);
    try self.writers.err.print(":\n", .{});

    try self.module.highlight(region, self.writers.err);
    try self.writers.err.print("\n", .{});
}

fn addGoal(self: *Goal, node: Ast.GoalNode, region: Region) error{OutOfMemory}!NodeId {
    const id: NodeId = @intCast(self.ast.goals.items.len);
    try self.ast.goals.append(self.alloc(), .{ .node = node, .region = region });
    return id;
}

fn isPlaceholder(self: *Goal, name: PathTable.Id) bool {
    return self.strings.equal(self.paths.flat(name), "_");
}

fn seqPair(self: *Goal, first: NodeId, second: NodeId, result: u32, region: Region) Error!NodeId {
    var goals = ArrayList(NodeId){};
    try goals.ensureTotalCapacity(self.alloc(), 2);
    goals.appendAssumeCapacity(first);
    goals.appendAssumeCapacity(second);
    return self.addGoal(.{ .seq = .{ .goals = goals, .result = result } }, region);
}

// Pattern-expression identifiers (range limits, repeat caps, compound
// merge exprs) evaluate in value semantics, so they carry the value kind.
fn identGoal(self: *Goal, ident: anytype, region: Region) Error!NodeId {
    return self.addGoal(.{ .ident = .{
        .name = ident.name,
        .builtin = ident.builtin,
        .underscored = ident.underscored,
        .kind = .value,
    } }, region);
}

fn invoked(self: *Goal, callee: NodeId, region: Region) Error!NodeId {
    const args = try self.alloc().alloc(NodeId, 0);
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = 0,
    } }, region);
}

fn allValueArgs(count: usize) u32 {
    if (count >= 32) return std.math.maxInt(u32);
    return (@as(u32, 1) << @intCast(count)) - 1;
}

// Pattern decomposition: places + constraints.

// Build stores the pattern; the fold folds it in place and the lowering
// sweep decomposes it into places and arms.
fn convertDestructure(
    self: *Goal,
    scrutinee: NodeId,
    pattern: *Pattern.RNode,
    region: Region,
) Error!NodeId {
    return self.addGoal(.{ .match = .{
        .scrutinee = scrutinee,
        .pattern = pattern,
        .places = .{},
        .arms = .{},
    } }, region);
}

// Decompose a match's folded pattern into places and a single arm.
fn lowerMatch(self: *Goal, match: *Ast.Match) Error!void {
    try match.places.append(self.alloc(), .scrutinee);
    var constraints = ArrayList(Ast.Constraint){};
    try self.lowerPattern(match.pattern, 0, &match.places, &constraints);
    try match.arms.append(self.alloc(), .{
        .constraints = constraints,
        .guard = null,
        .body = null,
        .region = match.pattern.region,
    });
}

// Derive a repeat's cap and count test from its folded count pattern.
fn lowerRepeat(self: *Goal, rep: *Ast.Repeat) Error!void {
    rep.cap = try self.repeatCap(rep.count_pattern);
    rep.count_test = try self.patternSet(rep.count_pattern);
}

// A ConstraintSet rooted at a synthetic scrutinee: repeat counts and
// composite sub-patterns.
fn patternSet(self: *Goal, pattern: *Pattern.RNode) Error!SetId {
    var set = Ast.ConstraintSet{
        .places = .{},
        .constraints = .{},
        .region = pattern.region,
    };
    try set.places.append(self.alloc(), .scrutinee);
    try self.lowerPattern(pattern, 0, &set.places, &set.constraints);
    return self.addSet(set);
}

fn addSet(self: *Goal, set: Ast.ConstraintSet) Error!SetId {
    const id: SetId = @intCast(self.ast.constraint_sets.items.len);
    try self.ast.constraint_sets.append(self.alloc(), set);
    return id;
}

fn internPlace(
    self: *Goal,
    places: *ArrayList(Ast.PlaceDef),
    def: Ast.PlaceDef,
) Error!PlaceId {
    for (places.items, 0..) |existing, i| {
        if (std.meta.eql(existing, def)) return @intCast(i);
    }
    try places.append(self.alloc(), def);
    return @intCast(places.items.len - 1);
}

fn pushConstraint(
    self: *Goal,
    constraints: *ArrayList(Ast.Constraint),
    kind: Ast.Constraint.Kind,
    region: Region,
) Error!void {
    try constraints.append(self.alloc(), .{ .kind = kind, .region = region });
}

// Narrow a place index, length, or key count to the byte the match-step
// ops encode it in, reporting a compile error when the pattern needs a
// larger number.
fn boundedByte(self: *Goal, value: usize, region: Region, comptime what: []const u8) Error!u8 {
    if (value > 255) {
        try self.printError(region, what ++ " ({d}) exceeds the maximum of 255", .{value});
        return Error.PatternTooLarge;
    }
    return @intCast(value);
}

// Bottom-up constant folding of a pattern tree, run before lowering to
// places and constraints. Constant merges, repeats, and negations fold
// by interval/numeric arithmetic (Pattern.merge/repeat/negate);
// negation distributes over a number merge (`-(X + 3)` is `-X + -3`) so
// the merge's sole variable part stays solvable. Folding before lowering
// keeps the constraint form free of the fold machinery it would
// otherwise need on places and sub-sets.
fn foldPattern(self: *Goal, pattern: *Pattern.RNode) FoldError!*Pattern.RNode {
    switch (pattern.node) {
        .merge => |op| {
            const left = try self.foldPattern(op.left);
            const right = try self.foldPattern(op.right);
            if (try Pattern.merge(self.alloc(), left.*, right.*)) |folded| {
                return try Pattern.create(self.alloc(), folded.node, folded.region);
            }
            pattern.node = .{ .merge = .{ .left = left, .right = right } };
            return pattern;
        },
        .repeat => |op| {
            const left = try self.foldPattern(op.left);
            const right = try self.foldPattern(op.right);
            // Only constant-size results fold, matching the goal fold's
            // deliberate exclusions: `2 * 3` is one number and a range
            // scales by a constant count, but `"ab" * N`, `[A] * N`, and
            // `2..3 * 2..3` (the discrete set {4,6,9}, not `4..9`) all
            // stay unfolded to avoid materializing or mistyping.
            if (try self.foldedPatternRepeat(left, right, pattern.region)) |folded| {
                return folded;
            }
            pattern.node = .{ .repeat = .{ .left = left, .right = right } };
            return pattern;
        },
        .negation => |inner| {
            const folded_inner = try self.foldPattern(inner);
            if (try Pattern.negate(self.arena.allocator(), folded_inner.*, pattern.region)) |neg| {
                return try Pattern.create(self.alloc(), neg.node, neg.region);
            }
            if (folded_inner.node == .merge and self.mergeTypeOf(folded_inner) == .number) {
                const m = folded_inner.node.merge;
                const nl = try self.foldPattern(try Pattern.create(
                    self.alloc(),
                    .{ .negation = m.left },
                    m.left.region,
                ));
                const nr = try self.foldPattern(try Pattern.create(
                    self.alloc(),
                    .{ .negation = m.right },
                    m.right.region,
                ));
                if (try Pattern.merge(self.alloc(), nl.*, nr.*)) |folded| {
                    return try Pattern.create(self.alloc(), folded.node, folded.region);
                }
                pattern.node = .{ .merge = .{ .left = nl, .right = nr } };
                return pattern;
            }
            pattern.node = .{ .negation = folded_inner };
            return pattern;
        },
        .array => |elems| {
            for (elems.items) |*elem| elem.* = try self.foldPattern(elem.*);
            return pattern;
        },
        .object => |pairs| {
            for (pairs.items) |*pair| {
                pair.key = try self.foldPattern(pair.key);
                pair.value = try self.foldPattern(pair.value);
            }
            return pattern;
        },
        .range => |*r| {
            if (r.lower) |l| r.lower = try self.foldPattern(l);
            if (r.upper) |u| r.upper = try self.foldPattern(u);
            return pattern;
        },
        .string_template => |parts| {
            for (parts.items) |*p| p.* = try self.foldPattern(p.*);
            return pattern;
        },
        // A bare identifier naming a constant scalar global inlines to the
        // constant, so a surrounding merge/repeat/negation folds it. Frame
        // locals and non-scalar globals resolve to null and stay identifiers.
        .identifier => |ident| {
            if (!self.isPlaceholder(ident.name)) {
                if (self.inline_resolver) |resolver| {
                    if (try resolver.scalar(ident.name)) |value| {
                        pattern.node = value.toPatternNode();
                    }
                }
            }
            return pattern;
        },
        // The leaf holds a goal expression; fold it so nested scalar
        // globals inline there too.
        .function_call => |expr| {
            try self.foldNodeRec(expr);
            return pattern;
        },
        .true, .false, .null, .number_float, .number_string, .string => return pattern,
    }
}

// Fold a pattern repeat whose result is constant-size: number * number,
// null/true/false * non-negative integer (zero repetitions is null), and
// a constant-number range scaled by a non-negative count (open bounds
// stay open). Everything else — variable counts, `string * N`, `[A] * N`,
// range * range — returns null and keeps the repeat node.
fn foldedPatternRepeat(
    self: *Goal,
    left: *Pattern.RNode,
    right: *Pattern.RNode,
    region: Region,
) FoldError!?*Pattern.RNode {
    const count = constPatternNumber(right) orelse return null;
    switch (left.node) {
        .number_float, .number_string => {
            const v = constPatternNumber(left).?;
            return try Pattern.create(self.alloc(), .{ .number_float = v * count }, region);
        },
        .null, .true, .false => {
            if (count < 0 or count != @floor(count)) return null;
            if (count == 0) return try Pattern.create(self.alloc(), .null, region);
            return left;
        },
        .range => |r| {
            if (count < 0) return null;
            var new_lower: ?*Pattern.RNode = null;
            if (r.lower) |l| {
                const lv = constPatternNumber(l) orelse return null;
                new_lower = try Pattern.create(self.alloc(), .{ .number_float = lv * count }, region);
            }
            var new_upper: ?*Pattern.RNode = null;
            if (r.upper) |u| {
                const uv = constPatternNumber(u) orelse return null;
                new_upper = try Pattern.create(self.alloc(), .{ .number_float = uv * count }, region);
            }
            return try Pattern.create(self.alloc(), .{ .range = .{
                .lower = new_lower,
                .upper = new_upper,
            } }, region);
        },
        else => {
            if (count == 1) return left;
            return null;
        },
    }
}

// Fold a flattened merge part list in place: adjacent constants fuse
// (Pattern.merge), null identities drop, and adjacent placeholders
// collapse (`_ + _` is one absorption). Mirrors what the constraint-level
// foldMergeParts did, but on the pattern tree before lowering.
fn foldMergePartPatterns(self: *Goal, parts: *ArrayList(*Pattern.RNode)) FoldError!void {
    var write: usize = 0;
    for (parts.items) |part| {
        if (write > 0) {
            if (self.isPatternPlaceholder(part) and self.isPatternPlaceholder(parts.items[write - 1])) {
                continue;
            }
            if (try Pattern.merge(self.alloc(), parts.items[write - 1].*, part.*)) |folded| {
                parts.items[write - 1] = try Pattern.create(self.alloc(), folded.node, folded.region);
                continue;
            }
        }
        parts.items[write] = part;
        write += 1;
    }
    parts.shrinkRetainingCapacity(write);
}

fn isPatternPlaceholder(self: *Goal, pattern: *const Pattern.RNode) bool {
    return pattern.node == .identifier and self.isPlaceholder(pattern.node.identifier.name);
}

fn constPatternNumber(pattern: *const Pattern.RNode) ?f64 {
    return switch (pattern.node) {
        .number_float => |f| f,
        .number_string => |ns| ns.toFloat() catch null,
        else => null,
    };
}

// The static merge type a pattern merge imposes: the first structurally
// typed leaf, ignoring conflicts (they surface at lowering). Used only
// to decide whether negation distributes.
fn mergeTypeOf(self: *Goal, pattern: *const Pattern.RNode) ?Ast.ValueType {
    return switch (pattern.node) {
        .merge => |op| self.mergeTypeOf(op.left) orelse self.mergeTypeOf(op.right),
        else => mergePartStaticType(pattern),
    };
}

fn lowerPattern(
    self: *Goal,
    pattern: *Pattern.RNode,
    place: PlaceId,
    places: *ArrayList(Ast.PlaceDef),
    constraints: *ArrayList(Ast.Constraint),
) Error!void {
    const region = pattern.region;
    switch (pattern.node) {
        .true, .false, .null, .number_float, .number_string, .string => {
            const value = try self.patternLiteralGoal(pattern);
            try self.pushConstraint(constraints, .{ .eq_const = .{
                .place = place,
                .value = value,
            } }, region);
        },
        .identifier => |ident| {
            if (self.isPlaceholder(ident.name)) return;
            try self.pushConstraint(constraints, .{ .local = .{
                .place = place,
                .name = ident.name,
            } }, region);
        },
        .function_call => |expr| {
            try self.pushConstraint(constraints, .{ .eval_eq = .{
                .place = place,
                .expr = expr,
            } }, region);
        },
        .negation => {
            var count: u32 = 0;
            var inner = pattern;
            while (inner.node == .negation) : (inner = inner.node.negation) count += 1;
            try self.pushConstraint(constraints, .{ .negated = .{
                .place = place,
                .count = count,
                .part = try self.patternPart(inner),
            } }, region);
        },
        .array => |elems| {
            try self.pushConstraint(constraints, .{ .is_type = .{
                .place = place,
                .ty = .array,
            } }, region);
            try self.pushConstraint(constraints, .{ .len_eq = .{
                .place = place,
                .len = try self.boundedByte(elems.items.len, region, "array pattern length"),
            } }, region);
            for (elems.items, 0..) |elem, i| {
                const elem_place = try self.internPlace(places, .{ .elem = .{
                    .src = place,
                    .index = try self.boundedByte(i, region, "array element index"),
                } });
                try self.lowerPattern(elem, elem_place, places, constraints);
            }
        },
        .object => |pairs| {
            try self.pushConstraint(constraints, .{ .is_type = .{
                .place = place,
                .ty = .object,
            } }, region);
            try self.pushConstraint(constraints, .{ .keys_exact = .{
                .place = place,
                .count = try self.boundedByte(pairs.items.len, region, "object pattern key count"),
            } }, region);
            for (pairs.items) |pair| {
                switch (pair.key.node) {
                    .string => |key_str| {
                        const sid = try self.strings.insert(key_str);
                        try self.pushConstraint(constraints, .{ .has_key = .{
                            .place = place,
                            .sid = sid,
                        } }, pair.key.region);
                        const key_place = try self.internPlace(places, .{ .key = .{
                            .src = place,
                            .sid = sid,
                        } });
                        try self.lowerPattern(pair.value, key_place, places, constraints);
                    },
                    else => {
                        try self.pushConstraint(constraints, .{ .search_key = .{
                            .place = place,
                            .key = try self.patternSet(pair.key),
                            .value = try self.patternSet(pair.value),
                        } }, pair.key.region);
                    },
                }
            }
        },
        .range => |r| {
            try self.pushConstraint(constraints, .{ .in_range = .{
                .place = place,
                .lower = try self.patternLimit(r.lower),
                .upper = try self.patternLimit(r.upper),
            } }, region);
        },
        .merge => {
            var part_patterns = ArrayList(*Pattern.RNode){};
            var ty: ?Ast.ValueType = null;
            try self.collectMergePatterns(pattern, &part_patterns, &ty);
            if (ty == .array) {
                if (try self.lowerArrayMerge(part_patterns.items, place, places, constraints, region)) {
                    return;
                }
            }
            if (ty == .string) {
                if (try self.lowerStringMerge(part_patterns.items, place, places, constraints, region)) {
                    return;
                }
            }
            if (ty == .object) {
                if (try self.lowerObjectMerge(part_patterns.items, place, places, constraints, region)) {
                    return;
                }
            }
            // Fold adjacent constant parts and drop null identities on the
            // flattened list (leading literals of a typed merge already
            // fused in the array/string/object lowerings above; this is the
            // solve_merge fallback). A merge that collapses to one part is
            // that part's pattern.
            try self.foldMergePartPatterns(&part_patterns);
            if (part_patterns.items.len == 1) {
                return self.lowerPattern(part_patterns.items[0], place, places, constraints);
            }
            var parts = ArrayList(Ast.Part){};
            try parts.ensureTotalCapacity(self.alloc(), part_patterns.items.len);
            for (part_patterns.items) |part| {
                parts.appendAssumeCapacity(try self.patternPart(part));
            }
            try self.pushConstraint(constraints, .{ .solve_merge = .{
                .place = place,
                .parts = parts,
                .solvable_index = null,
                .ty = ty,
            } }, region);
        },
        .repeat => |op| {
            try self.pushConstraint(constraints, .{ .solve_repeat = .{
                .place = place,
                .pattern = try self.patternPart(op.left),
                .count = try self.patternPart(op.right),
            } }, region);
        },
        .string_template => |parts| {
            var segments = ArrayList(Ast.Segment){};
            try segments.ensureTotalCapacity(self.alloc(), parts.items.len);
            for (parts.items) |part| {
                segments.appendAssumeCapacity(switch (part.node) {
                    .string => |s| .{ .literal = s },
                    else => .{ .part = try self.patternPart(part) },
                });
            }
            try self.pushConstraint(constraints, .{ .match_template = .{
                .place = place,
                .segments = segments,
            } }, region);
        },
    }
}

fn collectMergePatterns(
    self: *Goal,
    pattern: *Pattern.RNode,
    parts: *ArrayList(*Pattern.RNode),
    ty: *?Ast.ValueType,
) Error!void {
    switch (pattern.node) {
        .merge => |op| {
            try self.collectMergePatterns(op.left, parts, ty);
            try self.collectMergePatterns(op.right, parts, ty);
        },
        else => {
            if (mergePartStaticType(pattern)) |part_ty| {
                if (ty.*) |merge_ty| {
                    if (part_ty != merge_ty) {
                        try self.printError(
                            pattern.region,
                            "cannot merge {s} {s} into {s} {s} merge",
                            .{ article(part_ty), @tagName(part_ty), article(merge_ty), @tagName(merge_ty) },
                        );
                        return Error.MergeTypeConflict;
                    }
                } else {
                    ty.* = part_ty;
                }
            }
            try parts.append(self.alloc(), pattern);
        },
    }
}

// Flatten an array merge with a static layout into constraints on the
// merge's own place: array-pattern parts pin every offset, so their
// elements land at elem/elem_back places and the at-most-one
// unknown-length part takes the middle slice. The layout is
// boundness-agnostic — a bound value at the slice place enforces the
// total length implicitly — so at most one unknown-length part is the
// only condition. Returns false to fall back to solve_merge (repeats,
// negations, and second unknown-length parts keep the runtime solve).
fn lowerArrayMerge(
    self: *Goal,
    parts: []const *Pattern.RNode,
    place: PlaceId,
    places: *ArrayList(Ast.PlaceDef),
    constraints: *ArrayList(Ast.Constraint),
    region: Region,
) Error!bool {
    var slack: ?usize = null;
    var front_len: u32 = 0;
    var back_len: u32 = 0;
    for (parts, 0..) |part, i| {
        switch (part.node) {
            .array => |elems| {
                const len: u32 = @intCast(elems.items.len);
                if (slack == null) front_len += len else back_len += len;
            },
            .null => {},
            .identifier, .function_call => {
                if (slack != null) return false;
                slack = i;
            },
            else => return false,
        }
    }

    try self.pushConstraint(constraints, .{ .is_type = .{
        .place = place,
        .ty = .array,
    } }, region);
    if (slack == null) {
        try self.pushConstraint(constraints, .{ .len_eq = .{
            .place = place,
            .len = try self.boundedByte(front_len + back_len, region, "array pattern length"),
        } }, region);
    } else {
        try self.pushConstraint(constraints, .{ .len_min = .{
            .place = place,
            .len = try self.boundedByte(front_len + back_len, region, "array pattern length"),
        } }, region);
    }

    var front_index: u32 = 0;
    var back_remaining: u32 = back_len;
    for (parts, 0..) |part, i| {
        switch (part.node) {
            .array => |elems| for (elems.items) |elem| {
                const elem_place = if (slack == null or i < slack.?) blk: {
                    defer front_index += 1;
                    break :blk try self.internPlace(places, .{ .elem = .{
                        .src = place,
                        .index = try self.boundedByte(front_index, region, "array element index"),
                    } });
                } else blk: {
                    back_remaining -= 1;
                    break :blk try self.internPlace(places, .{ .elem_back = .{
                        .src = place,
                        .index = try self.boundedByte(back_remaining, region, "array element index"),
                    } });
                };
                try self.lowerPattern(elem, elem_place, places, constraints);
            },
            .null => {},
            .identifier => |ident| {
                const slice_place = try self.internPlace(places, .{ .slice = .{
                    .src = place,
                    .front = try self.boundedByte(front_len, region, "array pattern length"),
                    .back = try self.boundedByte(back_len, region, "array pattern length"),
                } });
                if (!self.isPlaceholder(ident.name)) {
                    try self.pushConstraint(constraints, .{ .local = .{
                        .place = slice_place,
                        .name = ident.name,
                    } }, part.region);
                }
            },
            .function_call => |expr| {
                const slice_place = try self.internPlace(places, .{ .slice = .{
                    .src = place,
                    .front = try self.boundedByte(front_len, region, "array pattern length"),
                    .back = try self.boundedByte(back_len, region, "array pattern length"),
                } });
                try self.pushConstraint(constraints, .{ .eval_eq = .{
                    .place = slice_place,
                    .expr = expr,
                } }, part.region);
            },
            else => unreachable,
        }
    }
    return true;
}

fn article(ty: Ast.ValueType) []const u8 {
    return switch (ty) {
        .array, .object => "an",
        .string, .number, .boolean, .null => "a",
    };
}

// The merge type a part imposes structurally, or null when only its
// match-time value can type it (locals, placeholders, calls) or when it
// is the merge identity (null). Ranges type as number: constant number
// ranges fold by interval arithmetic, and a surviving range part in a
// merge is invalid for every type. Negation only ever produces numbers;
// a negated local stays untyped so the match fails instead of the merge
// typing, mirroring the interpreter's mergePartType.
fn mergePartStaticType(pattern: *const Pattern.RNode) ?Ast.ValueType {
    return switch (pattern.node) {
        .array => .array,
        .object => .object,
        .string, .string_template => .string,
        .number_float, .number_string, .range => .number,
        .true, .false => .boolean,
        .negation => |inner| if (mergePartStaticType(inner)) |t|
            (if (t == .number) t else null)
        else
            null,
        .repeat => |op| mergePartStaticType(op.left),
        .null, .identifier, .function_call, .merge => null,
    };
}

// Flatten a string merge with a static byte layout: literal parts pin
// the byte offsets, so leading literals become a prefix test, trailing
// literals a suffix test, and the at-most-one unknown-length part takes
// the byte slice between them. All-literal merges are left to constant
// folding, and templates never reach here — a bound template
// interpolation stringifies its value before comparing, which only the
// backend (post-classification) can decide.
fn lowerStringMerge(
    self: *Goal,
    parts: []const *Pattern.RNode,
    place: PlaceId,
    places: *ArrayList(Ast.PlaceDef),
    constraints: *ArrayList(Ast.Constraint),
    region: Region,
) Error!bool {
    var slack: ?usize = null;
    var front_len: u32 = 0;
    var back_len: u32 = 0;
    for (parts, 0..) |part, i| {
        switch (part.node) {
            .string => |s| {
                const len: u32 = @intCast(s.len);
                if (slack == null) front_len += len else back_len += len;
            },
            .null => {},
            .identifier, .function_call => {
                if (slack != null) return false;
                slack = i;
            },
            else => return false,
        }
    }
    const slack_index = slack orelse return false;

    try self.pushConstraint(constraints, .{ .is_type = .{
        .place = place,
        .ty = .string,
    } }, region);
    try self.pushConstraint(constraints, .{ .len_min = .{
        .place = place,
        .len = try self.boundedByte(front_len + back_len, region, "string pattern length"),
    } }, region);
    if (front_len > 0) {
        try self.pushConstraint(constraints, .{ .str_prefix = .{
            .place = place,
            .literal = try self.concatLiterals(parts[0..slack_index]),
        } }, region);
    }
    if (back_len > 0) {
        try self.pushConstraint(constraints, .{ .str_suffix = .{
            .place = place,
            .literal = try self.concatLiterals(parts[slack_index + 1 ..]),
        } }, region);
    }

    const slack_pattern = parts[slack_index];
    const slice_place = try self.internPlace(places, .{ .slice = .{
        .src = place,
        .front = try self.boundedByte(front_len, region, "string pattern length"),
        .back = try self.boundedByte(back_len, region, "string pattern length"),
    } });
    switch (slack_pattern.node) {
        .identifier => |ident| if (!self.isPlaceholder(ident.name)) {
            try self.pushConstraint(constraints, .{ .local = .{
                .place = slice_place,
                .name = ident.name,
            } }, slack_pattern.region);
        },
        .function_call => |expr| try self.pushConstraint(constraints, .{ .eval_eq = .{
            .place = slice_place,
            .expr = expr,
        } }, slack_pattern.region),
        else => unreachable,
    }
    return true;
}

// Flatten an object merge whose object parts have only constant string
// keys: every pair lands as a has_key test plus key place on the merge's
// own place, exactly like a plain object pattern, except the member
// count is only exact when there is no slack part — the slack takes the
// unclaimed members at a members_rest place. Duplicate keys across
// parts and computed keys keep the runtime solve.
fn lowerObjectMerge(
    self: *Goal,
    parts: []const *Pattern.RNode,
    place: PlaceId,
    places: *ArrayList(Ast.PlaceDef),
    constraints: *ArrayList(Ast.Constraint),
    region: Region,
) Error!bool {
    var slack: ?usize = null;
    var key_count: u32 = 0;
    var seen_keys = ArrayList([]const u8){};
    defer seen_keys.deinit(self.alloc());
    for (parts, 0..) |part, i| {
        switch (part.node) {
            .object => |pairs| for (pairs.items) |pair| {
                switch (pair.key.node) {
                    .string => |key_str| {
                        for (seen_keys.items) |seen| {
                            if (std.mem.eql(u8, seen, key_str)) return false;
                        }
                        try seen_keys.append(self.alloc(), key_str);
                        key_count += 1;
                    },
                    // A variable or computed key is a search pair: it claims
                    // one member the const keys didn't. It counts toward the
                    // member minimum but can't be deduped statically.
                    else => key_count += 1,
                }
            },
            .null => {},
            .identifier, .function_call => {
                if (slack != null) return false;
                slack = i;
            },
            else => return false,
        }
    }

    try self.pushConstraint(constraints, .{ .is_type = .{
        .place = place,
        .ty = .object,
    } }, region);
    if (slack == null) {
        try self.pushConstraint(constraints, .{ .keys_exact = .{
            .place = place,
            .count = try self.boundedByte(key_count, region, "object pattern key count"),
        } }, region);
    } else if (key_count > 0) {
        try self.pushConstraint(constraints, .{ .keys_min = .{
            .place = place,
            .count = try self.boundedByte(key_count, region, "object pattern key count"),
        } }, region);
    }

    for (parts) |part| {
        switch (part.node) {
            .object => |pairs| for (pairs.items) |pair| {
                switch (pair.key.node) {
                    .string => |key_str| {
                        const sid = try self.strings.insert(key_str);
                        try self.pushConstraint(constraints, .{ .has_key = .{
                            .place = place,
                            .sid = sid,
                        } }, pair.key.region);
                        const key_place = try self.internPlace(places, .{ .key = .{
                            .src = place,
                            .sid = sid,
                        } });
                        try self.lowerPattern(pair.value, key_place, places, constraints);
                    },
                    else => try self.pushConstraint(constraints, .{ .search_key = .{
                        .place = place,
                        .key = try self.patternSet(pair.key),
                        .value = try self.patternSet(pair.value),
                    } }, pair.key.region),
                }
            },
            .null => {},
            .identifier => |ident| {
                const rest_place = try self.internPlace(places, .{ .members_rest = .{
                    .src = place,
                } });
                if (!self.isPlaceholder(ident.name)) {
                    try self.pushConstraint(constraints, .{ .local = .{
                        .place = rest_place,
                        .name = ident.name,
                    } }, part.region);
                }
            },
            .function_call => |expr| {
                const rest_place = try self.internPlace(places, .{ .members_rest = .{
                    .src = place,
                } });
                try self.pushConstraint(constraints, .{ .eval_eq = .{
                    .place = rest_place,
                    .expr = expr,
                } }, part.region);
            },
            else => unreachable,
        }
    }
    return true;
}

fn concatLiterals(self: *Goal, parts: []const *Pattern.RNode) Error![]const u8 {
    var total: usize = 0;
    for (parts) |part| total += switch (part.node) {
        .string => |s| s.len,
        else => 0,
    };
    const bytes = try self.alloc().alloc(u8, total);
    var offset: usize = 0;
    for (parts) |part| switch (part.node) {
        .string => |s| {
            @memcpy(bytes[offset .. offset + s.len], s);
            offset += s.len;
        },
        else => {},
    };
    return bytes;
}

fn patternPart(self: *Goal, pattern: *Pattern.RNode) Error!Ast.Part {
    return switch (pattern.node) {
        .identifier => |ident| if (self.isPlaceholder(ident.name))
            .placeholder
        else
            .{ .local = ident.name },
        .true, .false, .null, .number_float, .number_string, .string => .{
            .expr = try self.patternLiteralGoal(pattern),
        },
        .function_call => |expr| .{ .expr = expr },
        // Structural: array, object, merge, repeat, range, template,
        // negation. The set is rooted at the part's portion of the value.
        else => .{ .sub = try self.patternSet(pattern) },
    };
}

fn patternLimit(self: *Goal, bound: ?*Pattern.RNode) Error!Ast.Limit {
    const pattern = bound orelse return .none;
    return switch (pattern.node) {
        .identifier => |ident| if (self.isPlaceholder(ident.name))
            .none
        else
            .{ .local = ident.name },
        else => .{ .expr = try self.patternExprGoal(pattern) },
    };
}

// The loop cap implied by a repeat count pattern, when one is
// recognizable at creation: an exact count, a bare local, an upper range
// limit, or an evaluable expression. Unrecognized shapes impose no cap;
// binding analysis clears caps whose reads are unbound.
fn repeatCap(self: *Goal, pattern: *Pattern.RNode) Error!Ast.Limit {
    return switch (pattern.node) {
        .number_string, .number_float => .{
            .expr = try self.patternLiteralGoal(pattern),
        },
        .identifier => |ident| if (self.isPlaceholder(ident.name))
            .none
        else
            .{ .local = ident.name },
        .range => |r| self.patternLimit(r.upper),
        .function_call, .merge, .negation => blk: {
            const expr = self.patternExprGoal(pattern) catch |err| switch (err) {
                error.GoalAstGap => break :blk .none,
                else => |e| return e,
            };
            break :blk .{ .expr = expr };
        },
        else => .none,
    };
}

fn patternLiteralGoal(self: *Goal, pattern: *Pattern.RNode) Error!NodeId {
    const region = pattern.region;
    return switch (pattern.node) {
        .true => self.addGoal(.true, region),
        .false => self.addGoal(.false, region),
        .null => self.addGoal(.null, region),
        .number_float => |f| self.addGoal(.{ .number_float = f }, region),
        .number_string => |ns| self.addGoal(.{ .number_string = .{
            .number = ns.number,
            .negated = ns.negated,
        } }, region),
        .string => |s| self.addGoal(.{ .string = s }, region),
        else => error.GoalAstGap,
    };
}

// Evaluable pattern expressions: range limits and other positions where
// every read must be bound at match time.
fn patternExprGoal(self: *Goal, pattern: *Pattern.RNode) Error!NodeId {
    const region = pattern.region;
    return switch (pattern.node) {
        .true, .false, .null, .number_float, .number_string, .string => self.patternLiteralGoal(pattern),
        .identifier => |ident| self.identGoal(ident, region),
        .function_call => |expr| expr,
        .merge => |op| self.addGoal(.{ .merge = .{
            .left = try self.patternExprGoal(op.left),
            .right = try self.patternExprGoal(op.right),
        } }, region),
        .negation => |inner| self.addGoal(.{ .neg = try self.patternExprGoal(inner) }, region),
        else => error.GoalAstGap,
    };
}

// Goal→goal constant folding: constant merges, multiplications, and
// negations fold bottom-up on the goals array, and each match/repeat's
// pattern folds in place. Lowering (lowerGoals) runs afterward, so no
// constraint-level folding is needed. Nodes rewrite in place; ids stay
// stable.
// Fold one graph node's body subtree, inlining scalar globals through
// `resolver`. The frontend drives this per node so each fold sees the
// owning node's dependency edges. foldPattern reads inline_resolver for
// the same inlining; it is scoped to this call and restored on return so
// the resolver-free re-folds during lowering never inline.
pub fn foldBody(self: *Goal, body: NodeId, resolver: InlineResolver) FoldError!void {
    const prev = self.inline_resolver;
    self.inline_resolver = resolver;
    defer self.inline_resolver = prev;
    try self.foldNodeRec(body);
}

// Post-order fold of a goal subtree: children fold first, then the
// operator combines them. A scalar-global reference inlines in place, so
// a parent merge/mult/neg/pattern sees the constant. foldPattern
// allocates only pattern nodes and folding never appends goals, so the
// goals array stays put and index-based mutation is stable. Lambda bodies
// are separate graph nodes, folded when the frontend reaches them.
fn foldNodeRec(self: *Goal, id: NodeId) FoldError!void {
    switch (self.ast.goals.items[id].node) {
        .ident => |ident| {
            if (ident.kind != .value or self.isPlaceholder(ident.name)) return;
            const resolver = self.inline_resolver orelse return;
            if (try resolver.scalar(ident.name)) |value| {
                self.ast.goals.items[id].node = value.toGoalNode();
            }
        },
        .merge => |op| {
            try self.foldNodeRec(op.left);
            try self.foldNodeRec(op.right);
            if (try self.foldedMerge(self.goalNode(op.left), self.goalNode(op.right))) |folded| {
                self.ast.goals.items[id].node = folded;
            }
        },
        .mult => |op| {
            try self.foldNodeRec(op.left);
            try self.foldNodeRec(op.right);
            if (try self.foldedMult(self.goalNode(op.left), self.goalNode(op.right))) |folded| {
                self.ast.goals.items[id].node = folded;
            }
        },
        .neg => |inner| {
            try self.foldNodeRec(inner);
            if (foldedNeg(self.goalNode(inner))) |folded| {
                self.ast.goals.items[id].node = folded;
            }
        },
        .to_string => |inner| try self.foldNodeRec(inner),
        .seq => |seq| for (seq.goals.items) |g| try self.foldNodeRec(g),
        .alt => |arms| for (arms.items) |arm| {
            if (arm.guard) |g| try self.foldNodeRec(g);
            if (arm.body) |b| try self.foldNodeRec(b);
        },
        // The callee names the function to invoke; it is never a foldable
        // value, and inlining a scalar into it would turn a call-of-a-value
        // error into malformed IR. Only the arguments fold.
        .call => |call| for (call.args) |arg| try self.foldNodeRec(arg),
        .array => |items| for (items.items) |item| try self.foldNodeRec(item),
        .object => |pairs| for (pairs.items) |pair| {
            try self.foldNodeRec(pair.key);
            try self.foldNodeRec(pair.value);
        },
        .range => |range| {
            if (range.lower) |l| try self.foldNodeRec(l);
            if (range.upper) |u| try self.foldNodeRec(u);
        },
        // Fold the pattern but keep its original region: diagnostics
        // point at the whole written pattern, not the narrower span a
        // folded merge would carry.
        .match => |*match| {
            try self.foldNodeRec(match.scrutinee);
            match.pattern = try self.foldPatternKeepingRegion(match.pattern);
        },
        .repeat => |*rep| {
            try self.foldNodeRec(rep.body);
            rep.count_pattern = try self.foldPatternKeepingRegion(rep.count_pattern);
        },
        .lambda => {},
        .number_string, .number_float, .string, .true, .false, .null => {},
    }
}

// The constant scalar a (folded) declaration body evaluates to, or null
// when the body is a function, a runtime value, or a structural literal.
// Read by the frontend to resolve a scalar-global reference.
pub fn scalarOfBody(self: *Goal, id: NodeId) ?ScalarValue {
    return switch (self.ast.goals.items[id].node) {
        .number_float => |f| .{ .number_float = f },
        .number_string => |ns| .{ .number_string = ns },
        .string => |s| .{ .string = s },
        .true => .true,
        .false => .false,
        .null => .null,
        else => null,
    };
}

// Fold a top-level pattern, preserving the source region it was written
// with. A folded merge otherwise reports the span of its operands, which
// drops surrounding parentheses from failure diagnostics.
fn foldPatternKeepingRegion(self: *Goal, pattern: *Pattern.RNode) FoldError!*Pattern.RNode {
    const region = pattern.region;
    const folded = try self.foldPattern(pattern);
    folded.region = region;
    return folded;
}

// Decompose every match and repeat's folded pattern into places, arms,
// caps, and count tests, then simplify. Runs after fold so patterns are
// fully reduced. Lowering appends literal and expression goals, so only
// the goals present before the sweep are visited, and each node is
// lowered by value then written back by index — addGoal may reallocate
// the goals list and invalidate a held pointer.
pub fn lowerGoals(self: *Goal) Error!void {
    const original_len = self.ast.goals.items.len;
    var i: usize = 0;
    while (i < original_len) : (i += 1) {
        switch (self.ast.goals.items[i].node) {
            .match => |m| {
                var match = m;
                try self.lowerMatch(&match);
                self.ast.goals.items[i].node = .{ .match = match };
            },
            .repeat => |r| {
                var rep = r;
                try self.lowerRepeat(&rep);
                self.ast.goals.items[i].node = .{ .repeat = rep };
            },
            else => {},
        }
    }

    try self.simplifyPatterns();
}

// Post-folding pattern simplification: places no surviving constraint
// reaches are pruned (a placeholder element interns its place at
// creation but lowers to no constraints), then identity shells
// collapse — an unconstrained single-arm match becomes its scrutinee,
// an empty repeat count test drops.
fn simplifyPatterns(self: *Goal) FoldError!void {
    for (self.ast.constraint_sets.items) |*set| {
        var lists = [_][]Ast.Constraint{set.constraints.items};
        try self.prunePlaces(&set.places, &lists);
    }
    for (self.ast.goals.items) |*rnode| {
        switch (rnode.node) {
            .match => |*match| {
                const lists = try self.alloc().alloc([]Ast.Constraint, match.arms.items.len);
                for (match.arms.items, 0..) |arm, i| lists[i] = arm.constraints.items;
                try self.prunePlaces(&match.places, lists);
                if (identityMatch(match.*)) |scrutinee| rnode.node = self.goalNode(scrutinee);
            },
            .repeat => |*rep| {
                if (rep.count_test) |set_id| {
                    const constraints = self.ast.constraint_sets.items[set_id].constraints.items;
                    if (constraints.len == 0) rep.count_test = null;
                }
            },
            else => {},
        }
    }
}

// A single-arm match whose constraints all folded away, with no guard
// and no body, is the identity on its scrutinee.
fn identityMatch(match: Ast.Match) ?NodeId {
    if (match.arms.items.len != 1) return null;
    const arm = match.arms.items[0];
    if (arm.constraints.items.len > 0 or arm.guard != null or arm.body != null) return null;
    return match.scrutinee;
}

fn prunePlaces(
    self: *Goal,
    places: *ArrayList(Ast.PlaceDef),
    constraint_lists: []const []Ast.Constraint,
) FoldError!void {
    const used = try self.alloc().alloc(bool, places.items.len);
    @memset(used, false);
    used[0] = true;
    for (constraint_lists) |list| markUsedPlaces(list, used);

    // Derivations intern parents before children, so one downward pass
    // closes the src chains.
    var i = places.items.len;
    while (i > 0) {
        i -= 1;
        if (used[i]) {
            if (placeSrc(places.items[i])) |src| used[src] = true;
        }
    }

    const map = try self.alloc().alloc(Ast.PlaceId, places.items.len);
    var write: usize = 0;
    for (places.items, 0..) |def, idx| {
        if (!used[idx]) continue;
        map[idx] = @intCast(write);
        places.items[write] = def;
        write += 1;
    }
    if (write == places.items.len) return;
    places.shrinkRetainingCapacity(write);

    for (places.items) |*def| {
        switch (def.*) {
            .scrutinee => {},
            .elem => |*e| e.src = map[e.src],
            .elem_back => |*e| e.src = map[e.src],
            .slice => |*s| s.src = map[s.src],
            .key => |*k| k.src = map[k.src],
            .members_rest => |*r| r.src = map[r.src],
        }
    }
    for (constraint_lists) |list| remapPlaces(list, map);
}

fn placeSrc(def: Ast.PlaceDef) ?Ast.PlaceId {
    return switch (def) {
        .scrutinee => null,
        .elem => |e| e.src,
        .elem_back => |e| e.src,
        .slice => |s| s.src,
        .key => |k| k.src,
        .members_rest => |r| r.src,
    };
}

fn markUsedPlaces(constraints: []const Ast.Constraint, used: []bool) void {
    for (constraints) |c| {
        switch (c.kind) {
            inline else => |x| used[x.place] = true,
        }
    }
}

fn remapPlaces(constraints: []Ast.Constraint, map: []const Ast.PlaceId) void {
    for (constraints) |*c| {
        switch (c.kind) {
            inline else => |*x| x.place = map[x.place],
        }
    }
}

pub const FoldError = error{ OutOfMemory, InvalidCharacter };

// A constant scalar a global reference folds to. Strings and number
// digits are arena slices shared across modules, so a value extracted
// from one module inlines safely into another. Structural values
// (arrays, objects) are deliberately excluded.
pub const ScalarValue = union(enum) {
    number_float: f64,
    number_string: Ast.NumberString,
    string: []const u8,
    true,
    false,
    null,

    fn toGoalNode(self: ScalarValue) Ast.GoalNode {
        return switch (self) {
            .number_float => |f| .{ .number_float = f },
            .number_string => |ns| .{ .number_string = ns },
            .string => |s| .{ .string = s },
            .true => .true,
            .false => .false,
            .null => .null,
        };
    }

    fn toPatternNode(self: ScalarValue) Pattern.Node {
        return switch (self) {
            .number_float => |f| .{ .number_float = f },
            .number_string => |ns| .{ .number_string = .{
                .number = ns.number,
                .negated = ns.negated,
            } },
            .string => |s| .{ .string = s },
            .true => .true,
            .false => .false,
            .null => .null,
        };
    }
};

// Supplied by the frontend for the duration of a foldBody call: it holds
// the graph context a scalar-global lookup needs (the owning node's
// dependency edges, alias terminals, cross-module goals) that Goal cannot
// reach on its own.
pub const InlineResolver = struct {
    ctx: *anyopaque,
    scalarFn: *const fn (ctx: *anyopaque, name: PathTable.Id) FoldError!?ScalarValue,

    fn scalar(self: InlineResolver, name: PathTable.Id) FoldError!?ScalarValue {
        return self.scalarFn(self.ctx, name);
    }
};

fn foldedMerge(self: *Goal, a: Ast.GoalNode, b: Ast.GoalNode) FoldError!?Ast.GoalNode {
    if (a == .null) return b;
    if (b == .null) return a;

    return switch (a) {
        .false => switch (b) {
            .false, .true => b,
            else => null,
        },
        .true => switch (b) {
            .false, .true => a,
            else => null,
        },
        .string => |a_str| switch (b) {
            .string => |b_str| blk: {
                const buffer = try self.alloc().alloc(u8, a_str.len + b_str.len);
                @memcpy(buffer[0..a_str.len], a_str);
                @memcpy(buffer[a_str.len..], b_str);
                break :blk .{ .string = buffer };
            },
            else => null,
        },
        .number_float, .number_string => switch (b) {
            .number_float, .number_string => .{
                .number_float = try numberValue(a) + try numberValue(b),
            },
            else => null,
        },
        .array => |a_arr| switch (b) {
            .array => |b_arr| blk: {
                var merged = a_arr;
                try merged.ensureTotalCapacity(self.alloc(), a_arr.items.len + b_arr.items.len);
                merged.appendSliceAssumeCapacity(b_arr.items);
                break :blk .{ .array = merged };
            },
            else => null,
        },
        else => null,
    };
}

// Value multiplication follows Elem.repeat, folding only constant-size
// results like foldedRepeat. A placeholder left side absorbs any count
// and stays a placeholder; a placeholder count never folds.
fn foldedMult(self: *Goal, a: Ast.GoalNode, b: Ast.GoalNode) FoldError!?Ast.GoalNode {
    if (self.isPlaceholderNode(b)) return null;
    if (self.isPlaceholderNode(a)) return a;
    return foldedRepeat(a, b);
}

fn isPlaceholderNode(self: *Goal, node: Ast.GoalNode) bool {
    return node == .ident and self.isPlaceholder(node.ident.name);
}

fn foldedNeg(inner: Ast.GoalNode) ?Ast.GoalNode {
    return switch (inner) {
        .number_float => |f| .{ .number_float = -f },
        .number_string => |ns| .{ .number_string = ns.negate() },
        else => null,
    };
}

fn foldedRepeat(pattern: Ast.GoalNode, count: Ast.GoalNode) error{InvalidCharacter}!?Ast.GoalNode {
    const count_float = switch (count) {
        .number_float, .number_string => try numberValue(count),
        else => return null,
    };
    return switch (pattern) {
        .number_float, .number_string => .{
            .number_float = try numberValue(pattern) * count_float,
        },
        .null, .true, .false => if (count_float >= 0 and count_float == @floor(count_float))
            // Zero repetitions merge nothing: the result is null.
            (if (count_float == 0) .null else pattern)
        else
            null,
        else => null,
    };
}

fn numberValue(node: Ast.GoalNode) error{InvalidCharacter}!f64 {
    return switch (node) {
        .number_float => |f| f,
        .number_string => |ns| try ns.toFloat(),
        else => unreachable,
    };
}

pub fn print(self: *Goal, writer: *Writer, stage: Ast.Stage) Writer.Error!void {
    self.print_stage = stage;
    for (self.ast.declarations.items) |decl| {
        try writer.print("{s}", .{self.pathName(decl.name)});
        if (decl.params.items.len > 0) {
            try writer.writeAll("(");
            for (decl.params.items, 0..) |param, i| {
                if (i > 0) try writer.writeAll(", ");
                try writer.print("{s}", .{self.pathName(param)});
            }
            try writer.writeAll(")");
        }
        try writer.writeAll(" =\n");
        try self.printChild(writer, decl.body, 1);
        try writer.writeAll("\n\n");
    }
    if (self.ast.main) |main_id| {
        try writer.writeAll("main =\n");
        try self.printChild(writer, main_id, 1);
        try writer.writeAll("\n");
    }
}

fn pathName(self: *Goal, id: PathTable.Id) [:0]const u8 {
    return self.strings.get(self.paths.flat(id));
}

fn goalNode(self: *Goal, id: NodeId) Ast.GoalNode {
    return self.ast.goals.items[id].node;
}

fn printIndent(writer: *Writer, indent: u32) Writer.Error!void {
    var i: u32 = 0;
    while (i < indent * 2) : (i += 1) try writer.writeAll(" ");
}

fn printChild(self: *Goal, writer: *Writer, id: NodeId, indent: u32) Writer.Error!void {
    try printIndent(writer, indent);
    try self.printGoal(writer, id, indent);
}

fn isInlineGoal(self: *Goal, id: NodeId) bool {
    return switch (self.goalNode(id)) {
        .true, .false, .null, .string, .number_string, .number_float, .ident => true,
        .neg, .to_string => |inner| self.isInlineGoal(inner),
        .merge => |m| self.isInlineGoal(m.left) and self.isInlineGoal(m.right),
        .mult => |m| self.isInlineGoal(m.left) and self.isInlineGoal(m.right),
        .range => |r| (r.lower == null or self.isInlineGoal(r.lower.?)) and
            (r.upper == null or self.isInlineGoal(r.upper.?)),
        .call => |c| blk: {
            if (!self.isInlineGoal(c.callee)) break :blk false;
            for (c.args) |arg| if (!self.isInlineGoal(arg)) break :blk false;
            break :blk true;
        },
        else => false,
    };
}

fn printGoal(self: *Goal, writer: *Writer, id: NodeId, indent: u32) Writer.Error!void {
    switch (self.goalNode(id)) {
        .true => try writer.writeAll("true"),
        .false => try writer.writeAll("false"),
        .null => try writer.writeAll("null"),
        .string => |s| try writer.print("\"{s}\"", .{s}),
        .number_string => |ns| try writer.print("{s}{s}", .{
            if (ns.negated) "-" else "",
            ns.number,
        }),
        .number_float => |f| try writer.print("{d}", .{f}),
        .ident => |ident| switch (ident.resolution) {
            .local => |slot| try writer.print("{s}~{d}", .{ self.pathName(ident.name), slot }),
            .unresolved, .global, .placeholder => try writer.print("{s}", .{self.pathName(ident.name)}),
        },
        .call => |c| try self.printCall(writer, c, indent),
        .neg => |inner| try self.printUnary(writer, "neg", inner, indent),
        .to_string => |inner| try self.printUnary(writer, "to_string", inner, indent),
        .merge => |m| try self.printBinary(writer, "merge", m.left, m.right, indent),
        .mult => |m| try self.printBinary(writer, "mult", m.left, m.right, indent),
        .range => |r| {
            try writer.writeAll("(range ");
            try self.printOptGoal(writer, r.lower, indent);
            try writer.writeAll(" ");
            try self.printOptGoal(writer, r.upper, indent);
            try writer.writeAll(")");
        },
        .seq => |seq| {
            try writer.print("(seq result={d}", .{seq.result});
            for (seq.goals.items) |goal| {
                try writer.writeAll("\n");
                try self.printChild(writer, goal, indent + 1);
            }
            try writer.writeAll(")");
        },
        .alt => |arms| {
            try writer.writeAll("(alt");
            for (arms.items) |arm| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try writer.writeAll("(arm");
                if (arm.guard) |guard| {
                    try writer.writeAll("\n");
                    try self.printField(writer, "guard", guard, indent + 2);
                }
                if (arm.body) |body| {
                    try writer.writeAll("\n");
                    try self.printField(writer, "body", body, indent + 2);
                }
                try writer.writeAll(")");
            }
            try writer.writeAll(")");
        },
        .lambda => |lambda| {
            try writer.print("(lambda {s}", .{self.pathName(lambda.name)});
            if (lambda.captures.items.len > 0) {
                try writer.writeAll(" captures=[");
                for (lambda.captures.items, 0..) |segment, i| {
                    if (i > 0) try writer.writeAll(" ");
                    try writer.print("{s}", .{self.strings.get(segment)});
                }
                try writer.writeAll("]");
            }
            try writer.writeAll("\n");
            try self.printChild(writer, lambda.body, indent + 1);
            try writer.writeAll(")");
        },
        .array => |elems| {
            try writer.writeAll("(array [");
            for (elems.items) |elem| {
                try writer.writeAll("\n");
                try self.printChild(writer, elem, indent + 1);
            }
            if (elems.items.len > 0) {
                try writer.writeAll("\n");
                try printIndent(writer, indent);
            }
            try writer.writeAll("])");
        },
        .object => |pairs| {
            try writer.writeAll("(object [");
            for (pairs.items) |pair| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try self.printBinary(writer, "pair", pair.key, pair.value, indent + 1);
            }
            if (pairs.items.len > 0) {
                try writer.writeAll("\n");
                try printIndent(writer, indent);
            }
            try writer.writeAll("])");
        },
        .repeat => |rep| {
            try writer.writeAll("(repeat\n");
            try self.printField(writer, "body", rep.body, indent + 1);
            if (self.print_stage != .created) {
                if (rep.cap != .none) {
                    try writer.writeAll("\n");
                    try printIndent(writer, indent + 1);
                    try writer.writeAll("cap: ");
                    try self.printLimit(writer, rep.cap, indent + 1);
                }
                if (rep.count_test) |set_id| {
                    try writer.writeAll("\n");
                    try printIndent(writer, indent + 1);
                    try writer.writeAll("count: ");
                    try self.printSet(writer, set_id, indent + 1);
                }
            } else {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try writer.writeAll("count: ");
                try self.printPattern(writer, rep.count_pattern, indent + 1);
            }
            try writer.writeAll(")");
        },
        .match => |match| {
            try writer.writeAll("(match\n");
            try self.printField(writer, "scrutinee", match.scrutinee, indent + 1);
            if (self.print_stage == .created) {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try writer.writeAll("pattern: ");
                try self.printPattern(writer, match.pattern, indent + 1);
                try writer.writeAll(")");
                return;
            }
            try self.printPlaces(writer, match.places.items, indent + 1);
            for (match.arms.items) |arm| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try writer.writeAll("(arm");
                try self.printConstraints(writer, arm.constraints.items, indent + 2);
                if (arm.guard) |guard| {
                    try writer.writeAll("\n");
                    try self.printField(writer, "guard", guard, indent + 2);
                }
                if (arm.body) |body| {
                    try writer.writeAll("\n");
                    try self.printField(writer, "body", body, indent + 2);
                }
                try writer.writeAll(")");
            }
            try writer.writeAll(")");
        },
    }
}

// Print an unlowered pattern tree (created and folded stages). A
// function-call leaf is already a goal node, printed through printGoal.
fn printPattern(self: *Goal, writer: *Writer, pattern: *Pattern.RNode, indent: u32) Writer.Error!void {
    switch (pattern.node) {
        .true => try writer.writeAll("true"),
        .false => try writer.writeAll("false"),
        .null => try writer.writeAll("null"),
        .string => |s| try writer.print("\"{s}\"", .{s}),
        .number_string => |ns| try writer.print("{s}{s}", .{
            if (ns.negated) "-" else "",
            ns.number,
        }),
        .number_float => |f| try writer.print("{d}", .{f}),
        .identifier => |ident| try writer.print("{s}", .{self.pathName(ident.name)}),
        .function_call => |expr| try self.printGoal(writer, expr, indent),
        .merge => |op| {
            try writer.writeAll("(merge ");
            try self.printPattern(writer, op.left, indent);
            try writer.writeAll(" ");
            try self.printPattern(writer, op.right, indent);
            try writer.writeAll(")");
        },
        .repeat => |op| {
            try writer.writeAll("(repeat ");
            try self.printPattern(writer, op.left, indent);
            try writer.writeAll(" ");
            try self.printPattern(writer, op.right, indent);
            try writer.writeAll(")");
        },
        .negation => |inner| {
            try writer.writeAll("(neg ");
            try self.printPattern(writer, inner, indent);
            try writer.writeAll(")");
        },
        .range => |r| {
            try writer.writeAll("(range ");
            if (r.lower) |lower| try self.printPattern(writer, lower, indent) else try writer.writeAll("_");
            try writer.writeAll(" ");
            if (r.upper) |upper| try self.printPattern(writer, upper, indent) else try writer.writeAll("_");
            try writer.writeAll(")");
        },
        .array => |elems| {
            try writer.writeAll("(array [");
            for (elems.items) |elem| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try self.printPattern(writer, elem, indent + 1);
            }
            if (elems.items.len > 0) {
                try writer.writeAll("\n");
                try printIndent(writer, indent);
            }
            try writer.writeAll("])");
        },
        .object => |pairs| {
            try writer.writeAll("(object {");
            for (pairs.items) |pair| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try self.printPattern(writer, pair.key, indent + 1);
                try writer.writeAll(": ");
                try self.printPattern(writer, pair.value, indent + 1);
            }
            if (pairs.items.len > 0) {
                try writer.writeAll("\n");
                try printIndent(writer, indent);
            }
            try writer.writeAll("})");
        },
        .string_template => |parts| {
            try writer.writeAll("(template");
            for (parts.items) |part| {
                try writer.writeAll(" ");
                try self.printPattern(writer, part, indent);
            }
            try writer.writeAll(")");
        },
    }
}

fn printCall(self: *Goal, writer: *Writer, call: Ast.Call, indent: u32) Writer.Error!void {
    const inline_args = blk: {
        if (!self.isInlineGoal(call.callee)) break :blk false;
        for (call.args) |arg| if (!self.isInlineGoal(arg)) break :blk false;
        break :blk true;
    };
    if (inline_args) {
        try writer.writeAll("(call ");
        try self.printGoal(writer, call.callee, indent);
        if (call.args.len > 0) {
            try writer.writeAll(" [");
            for (call.args, 0..) |arg, i| {
                try self.printGoal(writer, arg, indent);
                if (i < call.args.len - 1) try writer.writeAll(" ");
            }
            try writer.writeAll("]");
        }
        try writer.writeAll(")");
    } else {
        try writer.writeAll("(call ");
        try self.printGoal(writer, call.callee, indent);
        if (call.args.len > 0) {
            try writer.writeAll(" [\n");
            for (call.args) |arg| {
                try self.printChild(writer, arg, indent + 1);
                try writer.writeAll("\n");
            }
            try printIndent(writer, indent);
            try writer.writeAll("]");
        }
        try writer.writeAll(")");
    }
}

fn printUnary(
    self: *Goal,
    writer: *Writer,
    tag: []const u8,
    inner: NodeId,
    indent: u32,
) Writer.Error!void {
    if (self.isInlineGoal(inner)) {
        try writer.print("({s} ", .{tag});
        try self.printGoal(writer, inner, indent);
    } else {
        try writer.print("({s}\n", .{tag});
        try self.printChild(writer, inner, indent + 1);
    }
    try writer.writeAll(")");
}

fn printBinary(
    self: *Goal,
    writer: *Writer,
    tag: []const u8,
    left: NodeId,
    right: NodeId,
    indent: u32,
) Writer.Error!void {
    if (self.isInlineGoal(left) and self.isInlineGoal(right)) {
        try writer.print("({s} ", .{tag});
        try self.printGoal(writer, left, indent);
        try writer.writeAll(" ");
        try self.printGoal(writer, right, indent);
    } else {
        try writer.print("({s}\n", .{tag});
        try self.printChild(writer, left, indent + 1);
        try writer.writeAll("\n");
        try self.printChild(writer, right, indent + 1);
    }
    try writer.writeAll(")");
}

fn printOptGoal(self: *Goal, writer: *Writer, id: ?NodeId, indent: u32) Writer.Error!void {
    if (id) |bound| try self.printGoal(writer, bound, indent) else try writer.writeAll("_");
}

// `label: <goal>`; a block goal continues with children indented one
// deeper than the label.
fn printField(
    self: *Goal,
    writer: *Writer,
    label: []const u8,
    id: NodeId,
    indent: u32,
) Writer.Error!void {
    try printIndent(writer, indent);
    try writer.print("{s}: ", .{label});
    try self.printGoal(writer, id, indent);
}

fn printSet(self: *Goal, writer: *Writer, set_id: SetId, indent: u32) Writer.Error!void {
    const set = self.ast.constraint_sets.items[set_id];
    try writer.writeAll("(set");
    try self.printPlaces(writer, set.places.items, indent + 1);
    try self.printConstraints(writer, set.constraints.items, indent + 1);
    try writer.writeAll(")");
}

fn printPlaces(
    self: *Goal,
    writer: *Writer,
    places: []const Ast.PlaceDef,
    indent: u32,
) Writer.Error!void {
    for (places, 0..) |place, i| {
        try writer.writeAll("\n");
        try printIndent(writer, indent);
        try writer.print("%{d} = ", .{i});
        switch (place) {
            .scrutinee => try writer.writeAll("scrutinee"),
            .elem => |e| try writer.print("elem %{d} {d}", .{ e.src, e.index }),
            .elem_back => |e| try writer.print("elem_back %{d} {d}", .{ e.src, e.index }),
            .slice => |s| try writer.print("slice %{d} {d} {d}", .{ s.src, s.front, s.back }),
            .key => |k| try writer.print("key %{d} \"{s}\"", .{ k.src, self.strings.get(k.sid) }),
            .members_rest => |r| try writer.print("members_rest %{d}", .{r.src}),
        }
    }
}

fn printConstraints(
    self: *Goal,
    writer: *Writer,
    constraints: []const Ast.Constraint,
    indent: u32,
) Writer.Error!void {
    for (constraints) |constraint| {
        try writer.writeAll("\n");
        try printIndent(writer, indent);
        try self.printConstraint(writer, constraint, indent);
    }
}

fn printConstraint(
    self: *Goal,
    writer: *Writer,
    constraint: Ast.Constraint,
    indent: u32,
) Writer.Error!void {
    switch (constraint.kind) {
        .is_type => |c| try writer.print("(is_type %{d} {s})", .{ c.place, @tagName(c.ty) }),
        .len_eq => |c| try writer.print("(len_eq %{d} {d})", .{ c.place, c.len }),
        .len_min => |c| try writer.print("(len_min %{d} {d})", .{ c.place, c.len }),
        .str_prefix => |c| try writer.print("(str_prefix %{d} \"{s}\")", .{ c.place, c.literal }),
        .str_suffix => |c| try writer.print("(str_suffix %{d} \"{s}\")", .{ c.place, c.literal }),
        .keys_exact => |c| try writer.print("(keys_exact %{d} {d})", .{ c.place, c.count }),
        .keys_min => |c| try writer.print("(keys_min %{d} {d})", .{ c.place, c.count }),
        .has_key => |c| try writer.print("(has_key %{d} \"{s}\")", .{
            c.place,
            self.strings.get(c.sid),
        }),
        .eq_const => |c| {
            try writer.print("(eq_const %{d} ", .{c.place});
            try self.printGoal(writer, c.value, indent);
            try writer.writeAll(")");
        },
        .in_range => |c| {
            try writer.print("(in_range %{d} ", .{c.place});
            try self.printLimit(writer, c.lower, indent);
            try writer.writeAll(" ");
            try self.printLimit(writer, c.upper, indent);
            try writer.writeAll(")");
        },
        .local => |c| try writer.print("(local %{d} {s})", .{ c.place, self.pathName(c.name) }),
        .bind => |c| try writer.print("(bind %{d} {s}~{d})", .{ c.place, self.pathName(c.name), c.slot }),
        .eq_slot => |c| try writer.print("(eq_slot %{d} {s}~{d})", .{ c.place, self.pathName(c.name), c.slot }),
        .eq_global => |c| try writer.print("(eq_global %{d} {s})", .{ c.place, self.pathName(c.name) }),
        .eval_eq => |c| {
            try writer.print("(eval_eq %{d} ", .{c.place});
            try self.printGoal(writer, c.expr, indent);
            try writer.writeAll(")");
        },
        .negated => |c| {
            try writer.print("(negated %{d} {d} ", .{ c.place, c.count });
            try self.printPart(writer, c.part, indent);
            try writer.writeAll(")");
        },
        .solve_merge => |c| {
            try writer.print("(solve_merge %{d}", .{c.place});
            if (c.ty) |ty| try writer.print(" ty={s}", .{@tagName(ty)});
            if (c.solvable_index) |index| try writer.print(" solvable={d}", .{index});
            for (c.parts.items) |part| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                try self.printPart(writer, part, indent + 1);
            }
            try writer.writeAll(")");
        },
        .match_template => |c| {
            try writer.print("(match_template %{d}", .{c.place});
            for (c.segments.items) |segment| {
                try writer.writeAll("\n");
                try printIndent(writer, indent + 1);
                switch (segment) {
                    .literal => |s| try writer.print("\"{s}\"", .{s}),
                    .part => |part| try self.printPart(writer, part, indent + 1),
                }
            }
            try writer.writeAll(")");
        },
        .solve_repeat => |c| {
            try writer.print("(solve_repeat %{d}\n", .{c.place});
            try printIndent(writer, indent + 1);
            try writer.writeAll("pattern: ");
            try self.printPart(writer, c.pattern, indent + 1);
            try writer.writeAll("\n");
            try printIndent(writer, indent + 1);
            try writer.writeAll("count: ");
            try self.printPart(writer, c.count, indent + 1);
            try writer.writeAll(")");
        },
        .search_key => |c| {
            try writer.print("(search_key %{d}\n", .{c.place});
            try printIndent(writer, indent + 1);
            try writer.writeAll("key: ");
            try self.printSet(writer, c.key, indent + 1);
            try writer.writeAll("\n");
            try printIndent(writer, indent + 1);
            try writer.writeAll("value: ");
            try self.printSet(writer, c.value, indent + 1);
            try writer.writeAll(")");
        },
    }
}

fn printPart(self: *Goal, writer: *Writer, part: Ast.Part, indent: u32) Writer.Error!void {
    switch (part) {
        .placeholder => try writer.writeAll("_"),
        .local => |name| try writer.print("(local {s})", .{self.pathName(name)}),
        .bind => |ls| try writer.print("(bind {s}~{d})", .{ self.pathName(ls.name), ls.slot }),
        .read => |ls| try writer.print("(read {s}~{d})", .{ self.pathName(ls.name), ls.slot }),
        .global => |name| try writer.print("(global {s})", .{self.pathName(name)}),
        .expr => |id| try self.printGoal(writer, id, indent),
        .sub => |set_id| try self.printSet(writer, set_id, indent),
    }
}

fn printLimit(self: *Goal, writer: *Writer, limit: Ast.Limit, indent: u32) Writer.Error!void {
    switch (limit) {
        .none => try writer.writeAll("_"),
        .local => |name| try writer.print("(local {s})", .{self.pathName(name)}),
        .bind => |ls| try writer.print("(bind {s}~{d})", .{ self.pathName(ls.name), ls.slot }),
        .read => |ls| try writer.print("(read {s}~{d})", .{ self.pathName(ls.name), ls.slot }),
        .global => |name| try writer.print("(global {s})", .{self.pathName(name)}),
        .expr => |id| try self.printGoal(writer, id, indent),
    }
}

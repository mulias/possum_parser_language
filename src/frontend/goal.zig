const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Writer = std.Io.Writer;
const Ast = @import("goal_ast.zig");
const Can = @import("can.zig");
const CanAst = @import("can_ast.zig");
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

pub const Goal = @This();
pub const NodeId = Ast.NodeId;
pub const SetId = Ast.SetId;
pub const PlaceId = Ast.PlaceId;

// GoalAstGap: a can construct the goal ast cannot express yet.
// PatternTooLarge: a place index, length, or key count exceeds what the
// match-step byte encoding admits.
pub const Error = error{ OutOfMemory, GoalAstGap, MergeTypeConflict, PatternTooLarge } || Writer.Error;

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

pub fn actualize(self: *Goal, can: Can) Error!void {
    for (can.ast.declarations.items) |decl| {
        switch (decl) {
            .parser => |p| {
                var params = ArrayList(PathTable.Id){};
                try params.ensureTotalCapacity(self.alloc(), p.node.params.items.len);
                var param_types: u32 = 0;
                for (p.node.params.items, 0..) |param, i| {
                    params.appendAssumeCapacity(param.name());
                    if (param == .value and i < 32) param_types |= @as(u32, 1) << @intCast(i);
                }
                try self.ast.declarations.append(self.alloc(), .{
                    .name = p.node.ident.node.name,
                    .underscored = p.node.ident.node.underscored,
                    .params = params,
                    .param_types = param_types,
                    .body = try self.convertParser(p.node.body),
                    .region = p.region,
                    .ident_region = p.node.ident.region,
                });
            },
            .value => |v| {
                var params = ArrayList(PathTable.Id){};
                try params.ensureTotalCapacity(self.alloc(), v.node.params.items.len);
                var param_types: u32 = 0;
                for (v.node.params.items, 0..) |param, i| {
                    params.appendAssumeCapacity(param.node.name);
                    if (i < 32) param_types |= @as(u32, 1) << @intCast(i);
                }
                try self.ast.declarations.append(self.alloc(), .{
                    .name = v.node.ident.node.name,
                    .underscored = v.node.ident.node.underscored,
                    .params = params,
                    .param_types = param_types,
                    .body = try self.convertValue(v.node.body),
                    .region = v.region,
                    .ident_region = v.node.ident.region,
                });
            },
        }
    }

    if (can.ast.main) |main_fn| {
        self.ast.main = try self.convertParser(main_fn.node.body);
        self.ast.main_name = main_fn.node.name;
    }
}

fn alloc(self: *Goal) Allocator {
    return self.arena.allocator();
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

fn identGoal(self: *Goal, ident: anytype, region: Region) Error!NodeId {
    return self.addGoal(.{ .ident = .{
        .name = ident.name,
        .builtin = ident.builtin,
        .underscored = ident.underscored,
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

// Operand position: the parser runs here. Bare identifiers and literal
// parsers are invoked, so they lower to zero-arg calls; their value forms
// appear only in argument, callee, and range-bound positions
// (convertParserValue).
fn convertParser(self: *Goal, rnode: *CanAst.Parser.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .@"or", .conditional => self.convertParserAlt(rnode),
        .@"return" => |op| self.seqPair(
            try self.convertParser(op.left),
            try self.convertValue(op.right),
            1,
            region,
        ),
        .take_right => |op| self.seqPair(
            try self.convertParser(op.left),
            try self.convertParser(op.right),
            1,
            region,
        ),
        .take_left => |op| self.seqPair(
            try self.convertParser(op.left),
            try self.convertParser(op.right),
            0,
            region,
        ),
        .merge => |op| self.addGoal(.{ .merge = .{
            .left = try self.convertParser(op.left),
            .right = try self.convertParser(op.right),
        } }, region),
        .number_string => |ns| self.invoked(try self.addGoal(.{ .number_string = .{
            .number = ns.number,
            .negated = ns.negated,
        } }, region), region),
        .string => |s| self.invoked(try self.addGoal(.{ .string = s }, region), region),
        .range => |r| self.invoked(try self.addGoal(.{ .range = .{
            .lower = if (r.lower) |lower| try self.convertParserValue(lower) else null,
            .upper = if (r.upper) |upper| try self.convertParserValue(upper) else null,
        } }, region), region),
        .string_template => |parts| self.convertParserTemplate(parts, region),
        .identifier => |ident| self.invoked(try self.identGoal(ident, region), region),
        .function_call => |fc| self.convertParserCall(fc, region),
        .anonymous_function => |anon| self.convertAnonymousFunction(anon, region),
        .destructure => |op| self.convertDestructure(
            try self.convertParser(op.left),
            op.right,
            region,
        ),
        .repeat => |op| self.addGoal(.{ .repeat = .{
            .body = try self.convertParser(op.left),
            .cap = try self.repeatCap(op.right),
            .count_test = try self.patternSet(op.right),
        } }, region),
    };
}

fn convertParserCall(self: *Goal, fc: CanAst.Parser.FunctionCall, region: Region) Error!NodeId {
    const callee = try self.convertParserValue(fc.function);
    const args = try self.alloc().alloc(NodeId, fc.args.items.len);
    var value_args: u32 = 0;
    for (fc.args.items, 0..) |arg, i| {
        args[i] = switch (arg) {
            .parser => |p| try self.convertParserValue(p),
            .value => |v| blk: {
                if (i < 32) value_args |= @as(u32, 1) << @intCast(i);
                break :blk try self.convertValue(v);
            },
        };
    }
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = value_args,
    } }, region);
}

// Value position within a parser context: arguments, callees, range
// bounds. Parsers are passed, never invoked. Can has already thunked
// composite arguments into anonymous functions, so what remains is
// identifiers (pass the function), the thunks themselves, and literals
// (pass the literal parser elem).
fn convertParserValue(self: *Goal, rnode: *CanAst.Parser.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .identifier => |ident| self.identGoal(ident, region),
        .anonymous_function => |anon| self.convertAnonymousFunction(anon, region),
        .string => |s| self.addGoal(.{ .string = s }, region),
        .number_string => |ns| self.addGoal(.{ .number_string = .{
            .number = ns.number,
            .negated = ns.negated,
        } }, region),
        else => self.convertParser(rnode),
    };
}

// "Hello %(name)" as a parser is `call("Hello") + to_string(call(name))`:
// a merge fold over the segments, stringifying interpolations.
fn convertParserTemplate(
    self: *Goal,
    parts: ArrayList(*CanAst.Parser.RNode),
    region: Region,
) Error!NodeId {
    var acc: ?NodeId = null;
    for (parts.items) |part| {
        const parsed = try self.convertParser(part);
        const segment = switch (part.node) {
            .string => parsed,
            else => try self.addGoal(.{ .to_string = parsed }, part.region),
        };
        acc = if (acc) |left|
            try self.addGoal(.{ .merge = .{ .left = left, .right = segment } }, region)
        else
            segment;
    }
    return acc orelse self.invoked(try self.addGoal(.{ .string = "" }, region), region);
}

fn convertAnonymousFunction(
    self: *Goal,
    anon: CanAst.Parser.AnonymousFunction,
    region: Region,
) Error!NodeId {
    return self.addGoal(.{ .lambda = .{
        .parent_name = anon.parent_name,
        .name = anon.name,
        .body = try self.convertParser(anon.body),
    } }, region);
}

fn convertParserAlt(self: *Goal, rnode: *CanAst.Parser.RNode) Error!NodeId {
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
    rnode: *CanAst.Parser.RNode,
    arms: *ArrayList(Ast.AltArm),
) Error!void {
    switch (rnode.node) {
        .@"or" => |op| {
            try arms.append(self.alloc(), .{
                .guard = try self.convertParser(op.left),
                .body = null,
            });
            try self.collectParserAltArms(op.right, arms);
        },
        .conditional => |cond| {
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

// Value position: everything is eager, arguments included. A bare
// identifier stays a value; a zero-arg value function is an alias for its
// value, so no call is inserted.
fn convertValue(self: *Goal, rnode: *CanAst.Value.RNode) Error!NodeId {
    const region = rnode.region;
    return switch (rnode.node) {
        .@"or", .conditional => self.convertValueAlt(rnode),
        .@"return" => |op| self.seqPair(
            try self.convertValue(op.left),
            try self.convertValue(op.right),
            1,
            region,
        ),
        .take_right => |op| self.seqPair(
            try self.convertValue(op.left),
            try self.convertValue(op.right),
            1,
            region,
        ),
        .take_left => |op| self.seqPair(
            try self.convertValue(op.left),
            try self.convertValue(op.right),
            0,
            region,
        ),
        .merge => |op| self.addGoal(.{ .merge = .{
            .left = try self.convertValue(op.left),
            .right = try self.convertValue(op.right),
        } }, region),
        .negation => |inner| self.addGoal(.{ .neg = try self.convertValue(inner) }, region),
        .true => self.addGoal(.true, region),
        .false => self.addGoal(.false, region),
        .null => self.addGoal(.null, region),
        .number_float => |f| self.addGoal(.{ .number_float = f }, region),
        .number_string => |ns| self.addGoal(.{ .number_string = .{
            .number = ns.number,
            .negated = ns.negated,
        } }, region),
        .string => |s| self.addGoal(.{ .string = s }, region),
        .string_template => |parts| self.convertValueTemplate(parts, region),
        .array => |items| blk: {
            var elems = ArrayList(NodeId){};
            try elems.ensureTotalCapacity(self.alloc(), items.items.len);
            for (items.items) |item| elems.appendAssumeCapacity(try self.convertValue(item));
            break :blk self.addGoal(.{ .array = elems }, region);
        },
        .object => |pairs| blk: {
            var converted = ArrayList(Ast.ObjectPair){};
            try converted.ensureTotalCapacity(self.alloc(), pairs.items.len);
            for (pairs.items) |pair| converted.appendAssumeCapacity(.{
                .key = try self.convertValue(pair.key),
                .value = try self.convertValue(pair.value),
            });
            break :blk self.addGoal(.{ .object = converted }, region);
        },
        .identifier => |ident| self.identGoal(ident, region),
        .function_call => |fc| self.convertValueCall(fc, region),
        .destructure => |op| self.convertDestructure(
            try self.convertValue(op.left),
            op.right,
            region,
        ),
        .repeat => |op| self.addGoal(.{ .mult = .{
            .left = try self.convertValue(op.left),
            .right = try self.convertValue(op.right),
        } }, region),
    };
}

fn convertValueCall(self: *Goal, fc: CanAst.Value.FunctionCall, region: Region) Error!NodeId {
    const callee = try self.convertValue(fc.function);
    const args = try self.alloc().alloc(NodeId, fc.args.items.len);
    for (fc.args.items, 0..) |arg, i| args[i] = try self.convertValue(arg);
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = allValueArgs(args.len),
    } }, region);
}

fn allValueArgs(count: usize) u32 {
    if (count >= 32) return std.math.maxInt(u32);
    return (@as(u32, 1) << @intCast(count)) - 1;
}

fn convertValueTemplate(
    self: *Goal,
    parts: ArrayList(*CanAst.Value.RNode),
    region: Region,
) Error!NodeId {
    var acc: ?NodeId = null;
    for (parts.items) |part| {
        const value = try self.convertValue(part);
        const segment = switch (part.node) {
            .string => value,
            else => try self.addGoal(.{ .to_string = value }, part.region),
        };
        acc = if (acc) |left|
            try self.addGoal(.{ .merge = .{ .left = left, .right = segment } }, region)
        else
            segment;
    }
    return acc orelse self.addGoal(.{ .string = "" }, region);
}

fn convertValueAlt(self: *Goal, rnode: *CanAst.Value.RNode) Error!NodeId {
    var arms = ArrayList(Ast.AltArm){};
    try self.collectValueAltArms(rnode, &arms);
    return self.addGoal(.{ .alt = arms }, rnode.region);
}

fn collectValueAltArms(
    self: *Goal,
    rnode: *CanAst.Value.RNode,
    arms: *ArrayList(Ast.AltArm),
) Error!void {
    switch (rnode.node) {
        .@"or" => |op| {
            try arms.append(self.alloc(), .{
                .guard = try self.convertValue(op.left),
                .body = null,
            });
            try self.collectValueAltArms(op.right, arms);
        },
        .conditional => |cond| {
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

// Pattern decomposition: places + constraints.

fn convertDestructure(
    self: *Goal,
    scrutinee: NodeId,
    pattern: *CanAst.Pattern.RNode,
    region: Region,
) Error!NodeId {
    var match = Ast.Match{
        .scrutinee = scrutinee,
        .places = .{},
        .arms = .{},
    };
    try match.places.append(self.alloc(), .scrutinee);
    var constraints = ArrayList(Ast.Constraint){};
    try self.lowerPattern(pattern, 0, &match.places, &constraints);
    try match.arms.append(self.alloc(), .{
        .constraints = constraints,
        .guard = null,
        .body = null,
        .region = pattern.region,
    });
    return self.addGoal(.{ .match = match }, region);
}

// A ConstraintSet rooted at a synthetic scrutinee: repeat counts and
// composite sub-patterns.
fn patternSet(self: *Goal, pattern: *CanAst.Pattern.RNode) Error!SetId {
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

fn lowerPattern(
    self: *Goal,
    pattern: *CanAst.Pattern.RNode,
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
        .function_call => |fc| {
            const expr = try self.patternCallGoal(fc, region);
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
            var part_patterns = ArrayList(*CanAst.Pattern.RNode){};
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
    pattern: *CanAst.Pattern.RNode,
    parts: *ArrayList(*CanAst.Pattern.RNode),
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
    parts: []const *CanAst.Pattern.RNode,
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
            .function_call => |fc| {
                const slice_place = try self.internPlace(places, .{ .slice = .{
                    .src = place,
                    .front = try self.boundedByte(front_len, region, "array pattern length"),
                    .back = try self.boundedByte(back_len, region, "array pattern length"),
                } });
                try self.pushConstraint(constraints, .{ .eval_eq = .{
                    .place = slice_place,
                    .expr = try self.patternCallGoal(fc, part.region),
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
fn mergePartStaticType(pattern: *const CanAst.Pattern.RNode) ?Ast.ValueType {
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
    parts: []const *CanAst.Pattern.RNode,
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
        .function_call => |fc| try self.pushConstraint(constraints, .{ .eval_eq = .{
            .place = slice_place,
            .expr = try self.patternCallGoal(fc, slack_pattern.region),
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
    parts: []const *CanAst.Pattern.RNode,
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
            .function_call => |fc| {
                const rest_place = try self.internPlace(places, .{ .members_rest = .{
                    .src = place,
                } });
                try self.pushConstraint(constraints, .{ .eval_eq = .{
                    .place = rest_place,
                    .expr = try self.patternCallGoal(fc, part.region),
                } }, part.region);
            },
            else => unreachable,
        }
    }
    return true;
}

fn concatLiterals(self: *Goal, parts: []const *CanAst.Pattern.RNode) Error![]const u8 {
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

fn patternPart(self: *Goal, pattern: *CanAst.Pattern.RNode) Error!Ast.Part {
    return switch (pattern.node) {
        .identifier => |ident| if (self.isPlaceholder(ident.name))
            .placeholder
        else
            .{ .local = ident.name },
        .true, .false, .null, .number_float, .number_string, .string => .{
            .expr = try self.patternLiteralGoal(pattern),
        },
        .function_call => |fc| .{
            .expr = try self.patternCallGoal(fc, pattern.region),
        },
        // Structural: array, object, merge, repeat, range, template,
        // negation. The set is rooted at the part's portion of the value.
        else => .{ .sub = try self.patternSet(pattern) },
    };
}

fn patternLimit(self: *Goal, bound: ?*CanAst.Pattern.RNode) Error!Ast.Limit {
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
fn repeatCap(self: *Goal, pattern: *CanAst.Pattern.RNode) Error!Ast.Limit {
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

fn patternLiteralGoal(self: *Goal, pattern: *CanAst.Pattern.RNode) Error!NodeId {
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

fn patternCallGoal(
    self: *Goal,
    fc: CanAst.Value.FunctionCall,
    region: Region,
) Error!NodeId {
    const callee = try self.convertValue(fc.function);
    const args = try self.alloc().alloc(NodeId, fc.args.items.len);
    for (fc.args.items, 0..) |arg, i| args[i] = try self.convertValue(arg);
    return self.addGoal(.{ .call = .{
        .callee = callee,
        .args = args,
        .value_args = allValueArgs(args.len),
    } }, region);
}

// Evaluable pattern expressions: range limits and other positions where
// every read must be bound at match time.
fn patternExprGoal(self: *Goal, pattern: *CanAst.Pattern.RNode) Error!NodeId {
    const region = pattern.region;
    return switch (pattern.node) {
        .true, .false, .null, .number_float, .number_string, .string => self.patternLiteralGoal(pattern),
        .identifier => |ident| self.identGoal(ident, region),
        .function_call => |fc| self.patternCallGoal(fc, region),
        .merge => |op| self.addGoal(.{ .merge = .{
            .left = try self.patternExprGoal(op.left),
            .right = try self.patternExprGoal(op.right),
        } }, region),
        .negation => |inner| self.addGoal(.{ .neg = try self.patternExprGoal(inner) }, region),
        else => error.GoalAstGap,
    };
}

// Goal→goal constant folding. The goal ast is built from unfolded can,
// so this pass recovers what can-level folding produces there: constant
// merges and negations fold on the goals array, then constraints whose
// parts became constants collapse (solve_merge/negated/solve_repeat →
// eq_const). Nodes rewrite in place; ids stay stable.
pub fn fold(self: *Goal) FoldError!void {
    // Children are appended before parents, so one forward pass folds
    // bottom-up.
    for (self.ast.goals.items) |*rnode| {
        switch (rnode.node) {
            .merge => |op| {
                if (try self.foldedMerge(self.goalNode(op.left), self.goalNode(op.right))) |folded| {
                    rnode.node = folded;
                }
            },
            .mult => |op| {
                if (try self.foldedMult(self.goalNode(op.left), self.goalNode(op.right))) |folded| {
                    rnode.node = folded;
                }
            },
            .neg => |inner| {
                if (foldedNeg(self.goalNode(inner))) |folded| {
                    rnode.node = folded;
                }
            },
            else => {},
        }
    }

    try self.distributeNegatedMerges();

    for (self.ast.constraint_sets.items) |*set| {
        try self.foldConstraints(&set.constraints);
    }
    for (self.ast.goals.items) |*rnode| {
        switch (rnode.node) {
            .match => |*match| {
                for (match.arms.items) |*arm| try self.foldConstraints(&arm.constraints);
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
                    if (constraints.len == 0) {
                        rep.count_test = null;
                    } else if (rep.cap == .none and constraints.len == 1) {
                        // Folding can leave count shapes whose cap was not
                        // recognizable at creation: `(2 * 2)` folds to an
                        // exact count, `(0..1 + 1)` to a range.
                        switch (constraints[0].kind) {
                            .eq_const => |c| if (self.constNumber(c.value) != null) {
                                rep.cap = .{ .expr = c.value };
                            },
                            .in_range => |c| if (c.upper != .none) {
                                rep.cap = c.upper;
                            },
                            else => {},
                        }
                    }
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
            .eq_places => |x| {
                used[x.a] = true;
                used[x.b] = true;
            },
            inline else => |x| used[x.place] = true,
        }
    }
}

fn remapPlaces(constraints: []Ast.Constraint, map: []const Ast.PlaceId) void {
    for (constraints) |*c| {
        switch (c.kind) {
            .eq_places => |*x| {
                x.a = map[x.a];
                x.b = map[x.b];
            },
            inline else => |*x| x.place = map[x.place],
        }
    }
}

pub const FoldError = error{ OutOfMemory, InvalidCharacter };

fn foldConstraints(self: *Goal, constraints: *ArrayList(Ast.Constraint)) FoldError!void {
    var i: usize = 0;
    while (i < constraints.items.len) {
        var remove = false;
        const kind = &constraints.items[i].kind;
        switch (kind.*) {
            .negated => |*c| {
                c.part = self.simplifiedPart(c.part);
                if (c.part == .expr) {
                    if (negatedConst(self.goalNode(c.part.expr), c.count)) |folded| {
                        self.ast.goals.items[c.part.expr].node = folded;
                        kind.* = .{ .eq_const = .{ .place = c.place, .value = c.part.expr } };
                    }
                }
            },
            .solve_merge => |*c| {
                const last_null = try self.foldMergeParts(&c.parts);
                if (c.parts.items.len == 0) {
                    // Every part was a constant null; their merge is null.
                    kind.* = .{ .eq_const = .{ .place = c.place, .value = last_null.? } };
                } else if (c.parts.items.len == 1) {
                    switch (c.parts.items[0]) {
                        .expr => |value| kind.* = .{ .eq_const = .{
                            .place = c.place,
                            .value = value,
                        } },
                        .local => |name| kind.* = .{ .local = .{
                            .place = c.place,
                            .name = name,
                        } },
                        .placeholder => remove = true,
                        // A lone structural part keeps its merge wrapper —
                        // splicing the sub-set would rebase its places —
                        // except a bare in_range, whose limits reference
                        // no places and lift to the merged place directly.
                        .sub => |set_id| {
                            if (self.loneInRange(set_id)) |range| {
                                kind.* = .{ .in_range = .{
                                    .place = c.place,
                                    .lower = range.lower,
                                    .upper = range.upper,
                                } };
                            }
                        },
                        // Folding runs before binding; classified parts
                        // cannot occur here.
                        .bind, .read, .global => unreachable,
                    }
                }
            },
            // Only constant-size results fold: `2 * 3` is one number,
            // but expanding `[A] * N` or `"ab" * N` materializes output
            // proportional to the count. A range pattern scales by a
            // constant non-negative count; range * range stays unfolded
            // because `2..3 * 2..3` is the discrete set {4, 6, 9}, not
            // `4..9`.
            .solve_repeat => |*c| {
                c.pattern = self.simplifiedPart(c.pattern);
                c.count = self.simplifiedPart(c.count);
                if (c.pattern == .expr and c.count == .expr) {
                    if (try foldedRepeat(
                        self.goalNode(c.pattern.expr),
                        self.goalNode(c.count.expr),
                    )) |folded| {
                        self.ast.goals.items[c.pattern.expr].node = folded;
                        kind.* = .{ .eq_const = .{ .place = c.place, .value = c.pattern.expr } };
                    }
                } else if (c.count == .expr) {
                    if (self.rangePart(c.pattern)) |range| {
                        if (self.constNumber(c.count.expr)) |n| {
                            if (n >= 0) {
                                const region = constraints.items[i].region;
                                kind.* = .{ .in_range = .{
                                    .place = c.place,
                                    .lower = try self.boundLimit(scaledBound(range.lower, n), region),
                                    .upper = try self.boundLimit(scaledBound(range.upper, n), region),
                                } };
                            }
                        }
                    }
                }
            },
            .match_template => |*c| {
                for (c.segments.items) |*segment| {
                    switch (segment.*) {
                        .part => |part| segment.* = .{ .part = self.simplifiedPart(part) },
                        .literal => {},
                    }
                }
            },
            else => {},
        }
        if (remove) {
            _ = constraints.orderedRemove(i);
        } else {
            i += 1;
        }
    }
}

// Drops constant-null parts (merge identity), folds runs of adjacent
// constant parts into their merged value (mutating the surviving part's
// goal node), and collapses runs of adjacent placeholders — `_ + _` is
// "whatever plus whatever", one absorption. Returns the last dropped
// null, for the all-null case.
fn foldMergeParts(self: *Goal, parts: *ArrayList(Ast.Part)) FoldError!?NodeId {
    var last_null: ?NodeId = null;
    var write: usize = 0;
    for (parts.items) |raw_part| {
        const part = self.simplifiedPart(raw_part);
        if (part == .expr and self.goalNode(part.expr) == .null) {
            last_null = part.expr;
            continue;
        }
        if (write > 0 and part == .placeholder and parts.items[write - 1] == .placeholder) {
            continue;
        }
        if (write > 0) {
            if (try self.foldedMergePair(&parts.items[write - 1], part)) continue;
        }
        parts.items[write] = part;
        write += 1;
    }
    parts.shrinkRetainingCapacity(write);
    return last_null;
}

const NegatedLeaf = struct { part: Ast.Part, negated: bool };

// Negation distributes over a number merge — `-(X + 3)` is `-X + -3` —
// so a merge part that negates a nested number merge splices its parts
// (each with the enclosing negations composed in) into the merge. Runs
// before part folding so distributed constants merge with their
// neighbours and the sole non-constant part becomes the leftover;
// otherwise a negated sub-merge keeps the plan path, which cannot solve
// a negated structural part.
fn distributeNegatedMerges(self: *Goal) FoldError!void {
    var si: usize = 0;
    while (si < self.ast.constraint_sets.items.len) : (si += 1) {
        var ci: usize = 0;
        while (ci < self.ast.constraint_sets.items[si].constraints.items.len) : (ci += 1) {
            const constraint = self.ast.constraint_sets.items[si].constraints.items[ci];
            if (constraint.kind != .solve_merge or constraint.kind.solve_merge.ty != .number) continue;
            const distributed = try self.distributedMergeParts(constraint.kind.solve_merge.parts, constraint.region) orelse continue;
            // Appending wrapper sets above may have moved the set array.
            const merge = &self.ast.constraint_sets.items[si].constraints.items[ci].kind.solve_merge;
            merge.parts.deinit(self.alloc());
            merge.parts = distributed;
        }
    }
    // Index-based: distributing appends fresh constant nodes to the goal
    // array, which may move the match node holding these constraints.
    var gi: usize = 0;
    while (gi < self.ast.goals.items.len) : (gi += 1) {
        if (self.ast.goals.items[gi].node != .match) continue;
        const arms = self.ast.goals.items[gi].node.match.arms.items;
        for (arms) |*arm| {
            var ci: usize = 0;
            while (ci < arm.constraints.items.len) : (ci += 1) {
                const constraint = arm.constraints.items[ci];
                if (constraint.kind != .solve_merge or constraint.kind.solve_merge.ty != .number) continue;
                const distributed = try self.distributedMergeParts(constraint.kind.solve_merge.parts, constraint.region) orelse continue;
                const merge = &arm.constraints.items[ci].kind.solve_merge;
                merge.parts.deinit(self.alloc());
                merge.parts = distributed;
            }
        }
    }
}

// The parts of `parts` with every negated number sub-merge flattened, or
// null when none needs it. Match-arm merges live outside constraint_sets,
// so wrapper-set appends never move them; set-merge callers re-fetch.
fn distributedMergeParts(self: *Goal, parts: ArrayList(Ast.Part), region: Region) FoldError!?ArrayList(Ast.Part) {
    var needs = false;
    for (parts.items) |part| {
        if (self.negatesNumberMerge(part)) {
            needs = true;
            break;
        }
    }
    if (!needs) return null;

    var leaves = ArrayList(NegatedLeaf){};
    defer leaves.deinit(self.alloc());
    for (parts.items) |part| try self.collectMergeLeaves(part, false, &leaves);

    var out = ArrayList(Ast.Part){};
    for (leaves.items) |leaf| {
        try out.append(self.alloc(), try self.negatedLeafPart(leaf.part, leaf.negated, region));
    }
    return out;
}

// Whether a merge part is a negation wrapping (through further negations)
// a number sub-merge — the shape distribution flattens.
fn negatesNumberMerge(self: *Goal, part: Ast.Part) bool {
    if (part != .sub) return false;
    const set = self.ast.constraint_sets.items[part.sub];
    if (set.constraints.items.len != 1) return false;
    return switch (set.constraints.items[0].kind) {
        .negated => |n| self.wrapsNumberMerge(n.part),
        else => false,
    };
}

fn wrapsNumberMerge(self: *Goal, part: Ast.Part) bool {
    if (part != .sub) return false;
    const set = self.ast.constraint_sets.items[part.sub];
    if (set.constraints.items.len != 1) return false;
    return switch (set.constraints.items[0].kind) {
        .solve_merge => |m| m.ty == .number,
        .negated => |n| self.wrapsNumberMerge(n.part),
        else => false,
    };
}

// Flatten a part into merge leaves, composing negation parity through
// nested negations and number sub-merges. A leaf is anything else — a
// constant, a local, a placeholder, or a non-number structural part.
fn collectMergeLeaves(self: *Goal, part: Ast.Part, negated: bool, leaves: *ArrayList(NegatedLeaf)) FoldError!void {
    if (part == .sub) {
        const set = &self.ast.constraint_sets.items[part.sub];
        if (set.constraints.items.len == 1) {
            switch (set.constraints.items[0].kind) {
                .negated => |n| return self.collectMergeLeaves(n.part, negated != (n.count % 2 == 1), leaves),
                .solve_merge => |m| if (m.ty == .number) {
                    for (m.parts.items) |mp| try self.collectMergeLeaves(mp, negated, leaves);
                    return;
                },
                else => {},
            }
        }
    }
    try leaves.append(self.alloc(), .{ .part = part, .negated = negated });
}

// A leaf carrying its accumulated negation: a constant becomes a fresh
// signed node, anything else negated is wrapped in a single-negation
// sub-set mirroring how `-X` lowers at creation. Constants get a fresh
// node rather than reusing the leaf's — folding still visits the now-dead
// constraint the leaf came from and would negate a shared node.
fn negatedLeafPart(self: *Goal, part: Ast.Part, negated: bool, region: Region) FoldError!Ast.Part {
    if (part == .expr) {
        const node = self.goalNode(part.expr);
        if (node == .number_float or node == .number_string) {
            return .{ .expr = try self.addGoal(negatedConst(node, @intFromBool(negated)).?, region) };
        }
    }
    if (!negated) return part;
    var set = Ast.ConstraintSet{ .places = .{}, .constraints = .{}, .region = region };
    try set.places.append(self.alloc(), .scrutinee);
    try set.constraints.append(self.alloc(), .{
        .kind = .{ .negated = .{ .place = 0, .count = 1, .part = part } },
        .region = region,
    });
    const id: SetId = @intCast(self.ast.constraint_sets.items.len);
    try self.ast.constraint_sets.append(self.alloc(), set);
    return .{ .sub = id };
}

// Folds `part` into `prev` when both are constants or constant ranges.
// Constant pairs fold through foldedMerge; a range merges by interval
// addition — a number is a range with that value as both bounds, so
// `0..1 + 1` is `0..1 + 1..1` = `1..2` — and an open bound absorbs
// (`0.. + 1` is `1..`).
fn foldedMergePair(self: *Goal, prev: *Ast.Part, part: Ast.Part) FoldError!bool {
    if (prev.* == .expr and part == .expr) {
        if (try self.foldedMerge(self.goalNode(prev.expr), self.goalNode(part.expr))) |folded| {
            self.ast.goals.items[prev.expr].node = folded;
            return true;
        }
        return false;
    }
    const prev_range = self.rangePart(prev.*);
    const part_range = self.rangePart(part);
    if (prev_range) |a| {
        const b = part_range orelse (if (part == .expr) self.numberRange(part.expr) else null) orelse
            return false;
        try self.writeRangeSet(a.set, addedBound(a.lower, b.lower), addedBound(a.upper, b.upper));
        return true;
    }
    if (part_range) |b| {
        if (prev.* != .expr) return false;
        const a = self.numberRange(prev.expr) orelse return false;
        try self.writeRangeSet(b.set, addedBound(a.lower, b.lower), addedBound(a.upper, b.upper));
        prev.* = part;
        return true;
    }
    return false;
}

// A range bound folding can compute with: open or a constant number.
// A range with any other bound shape does not fold.
const Bound = union(enum) {
    open,
    value: f64,
};

const RangeBounds = struct {
    // The sub-set holding the in_range constraint, for foldable parts;
    // unused for a number's degenerate range.
    set: SetId = 0,
    lower: Bound,
    upper: Bound,
};

// The in_range constraint of a set that contains nothing else. Its
// limits reference no places, so it can lift out of the set.
fn loneInRange(self: *Goal, set_id: SetId) ?struct { lower: Ast.Limit, upper: Ast.Limit } {
    const set = self.ast.constraint_sets.items[set_id];
    if (set.places.items.len != 1 or set.constraints.items.len != 1) return null;
    return switch (set.constraints.items[0].kind) {
        .in_range => |range| .{ .lower = range.lower, .upper = range.upper },
        else => null,
    };
}

// A structural part that is exactly one in_range constraint with
// foldable bounds: a range sub-pattern like `0..1`.
fn rangePart(self: *Goal, part: Ast.Part) ?RangeBounds {
    if (part != .sub) return null;
    const set = self.ast.constraint_sets.items[part.sub];
    if (set.places.items.len != 1 or set.constraints.items.len != 1) return null;
    if (set.constraints.items[0].kind != .in_range) return null;
    const range = set.constraints.items[0].kind.in_range;
    return .{
        .set = part.sub,
        .lower = self.foldableBound(range.lower) orelse return null,
        .upper = self.foldableBound(range.upper) orelse return null,
    };
}

fn numberRange(self: *Goal, id: NodeId) ?RangeBounds {
    const n = self.constNumber(id) orelse return null;
    return .{ .lower = .{ .value = n }, .upper = .{ .value = n } };
}

fn foldableBound(self: *Goal, limit: Ast.Limit) ?Bound {
    return switch (limit) {
        .none => .open,
        .expr => |id| if (self.constNumber(id)) |n| .{ .value = n } else null,
        else => null,
    };
}

fn constNumber(self: *Goal, id: NodeId) ?f64 {
    return switch (self.goalNode(id)) {
        .number_float => |f| f,
        .number_string => |ns| ns.toFloat() catch null,
        else => null,
    };
}

fn addedBound(a: Bound, b: Bound) Bound {
    if (a == .open or b == .open) return .open;
    return .{ .value = a.value + b.value };
}

fn scaledBound(bound: Bound, n: f64) Bound {
    return switch (bound) {
        .open => .open,
        .value => |v| .{ .value = v * n },
    };
}

fn writeRangeSet(self: *Goal, set_id: SetId, lower: Bound, upper: Bound) FoldError!void {
    const region = self.ast.constraint_sets.items[set_id].region;
    const limits = .{
        .lower = try self.boundLimit(lower, region),
        .upper = try self.boundLimit(upper, region),
    };
    const kind = &self.ast.constraint_sets.items[set_id].constraints.items[0].kind;
    kind.in_range.lower = limits.lower;
    kind.in_range.upper = limits.upper;
}

fn boundLimit(self: *Goal, bound: Bound, region: Region) FoldError!Ast.Limit {
    return switch (bound) {
        .open => .none,
        .value => |v| .{ .expr = try self.addGoal(.{ .number_float = v }, region) },
    };
}

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

// A negated pattern constraint chain applied to a constant: numbers fold
// for any count, everything else stays a runtime negation.
fn negatedConst(node: Ast.GoalNode, count: u32) ?Ast.GoalNode {
    if (node != .number_float and node != .number_string) return null;
    if (count % 2 == 0) return node;
    return foldedNeg(node);
}

// A structural sub-pattern whose set folded to nothing constrains
// nothing — a placeholder; one that folded to a single constant
// comparison collapses back to an expression part.
fn simplifiedPart(self: *Goal, part: Ast.Part) Ast.Part {
    if (part != .sub) return part;
    const set = self.ast.constraint_sets.items[part.sub];
    if (set.constraints.items.len == 0) return .placeholder;
    if (set.places.items.len != 1 or set.constraints.items.len != 1) return part;
    return switch (set.constraints.items[0].kind) {
        .eq_const => |c| .{ .expr = c.value },
        else => part,
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

pub fn print(self: *Goal, writer: *Writer) Writer.Error!void {
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
            try writer.writeAll(")");
        },
        .match => |match| {
            try writer.writeAll("(match\n");
            try self.printField(writer, "scrutinee", match.scrutinee, indent + 1);
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
        .eq_places => |c| try writer.print("(eq_places %{d} %{d})", .{ c.a, c.b }),
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

const std = @import("std");
const runtime = @import("../runtime.zig");
const match_plan = runtime.match_plan;
const pattern = @import("pattern.zig");
const Lowerer = pattern.Lowerer;
const PlanBuilder = pattern.PlanBuilder;
const Frontend = @import("../frontend.zig");
const GoalAst = @import("../frontend/goal_ast.zig");
const Elem = runtime.Elem;
const Module = runtime.Module;

pub const Error = pattern.Error;

// Lower a goal match arm (or a nested constraint set) to a MatchPlan the
// existing plan interpreter runs. This is the composite path of the goal
// compiler: arms whose constraints all lower to inline step ops never get
// here; everything else — merges, templates, repeats, ranges, searches,
// negation, evals — is reconstructed into the tree shape the interpreter
// expects, place group by place group. The scheduler's classification is
// authoritative: bind parts become .bind, reads .bound_eq, and each
// solve_merge's solvable_index transfers directly.
const Ctx = struct {
    lower: *Lowerer,
    module_id: Module.Id,
    ast: *const GoalAst,
    builder: *PlanBuilder,

    fn allocator(self: *const Ctx) std.mem.Allocator {
        return self.lower.vm.allocator;
    }
};

// One constraint scope: a match arm (places shared at the match level) or
// a nested ConstraintSet.
const Scope = struct {
    places: []const GoalAst.PlaceDef,
    constraints: []const GoalAst.Constraint,
};

pub fn createMatchPlanFromArm(
    lower: *Lowerer,
    module_id: Module.Id,
    ast: *const GoalAst,
    match: *const GoalAst.Match,
    arm: *const GoalAst.MatchArm,
) Error!u24 {
    var builder = PlanBuilder{};
    defer builder.deinit(lower.vm.allocator);

    var ctx = Ctx{ .lower = lower, .module_id = module_id, .ast = ast, .builder = &builder };
    try lowerPlaceGroup(&ctx, .{
        .places = match.places.items,
        .constraints = arm.constraints.items,
    }, 0, false);

    return pattern.finishPlan(lower, module_id, &builder);
}

// A repeat count test: the set's root place is the iteration count value.
pub fn createMatchPlanFromSet(
    lower: *Lowerer,
    module_id: Module.Id,
    ast: *const GoalAst,
    set_id: GoalAst.SetId,
) Error!u24 {
    var builder = PlanBuilder{};
    defer builder.deinit(lower.vm.allocator);

    var ctx = Ctx{ .lower = lower, .module_id = module_id, .ast = ast, .builder = &builder };
    try lowerSet(&ctx, set_id, false);

    return pattern.finishPlan(lower, module_id, &builder);
}

fn lowerSet(ctx: *Ctx, set_id: GoalAst.SetId, all_bound: bool) Error!void {
    const set = &ctx.ast.constraint_sets.items[set_id];
    try lowerPlaceGroup(ctx, .{
        .places = set.places.items,
        .constraints = set.constraints.items,
    }, 0, all_bound);
}

fn constraintPlace(kind: GoalAst.Constraint.Kind) ?GoalAst.PlaceId {
    return switch (kind) {
        .is_type => |c| c.place,
        .len_eq => |c| c.place,
        .len_min => |c| c.place,
        .str_prefix => |c| c.place,
        .str_suffix => |c| c.place,
        .keys_exact => |c| c.place,
        .keys_min => |c| c.place,
        .has_key => |c| c.place,
        .eq_const => |c| c.place,
        .in_range => |c| c.place,
        .local => |c| c.place,
        .bind => |c| c.place,
        .eq_slot => |c| c.place,
        .eq_global => |c| c.place,
        .eval_eq => |c| c.place,
        .negated => |c| c.place,
        .solve_merge => |c| c.place,
        .match_template => |c| c.place,
        .solve_repeat => |c| c.place,
        .search_key => |c| c.place,
    };
}

// Emit the plan subtree for one place: its shape constraints pick the node
// (array, object) and its content constraint supplies leaves and
// composites. A place with no surviving constraints is a placeholder.
fn lowerPlaceGroup(ctx: *Ctx, scope: Scope, place: GoalAst.PlaceId, all_bound: bool) Error!void {
    var is_array = false;
    var is_object = false;
    var is_string = false;
    var keys_exact = false;
    var len: ?u32 = null;
    var len_min: ?u32 = null;
    var prefix: ?[]const u8 = null;
    var suffix: ?[]const u8 = null;
    var content: ?*const GoalAst.Constraint = null;

    for (scope.constraints) |*constraint| {
        if (constraintPlace(constraint.kind) != place) continue;
        switch (constraint.kind) {
            .is_type => |c| switch (c.ty) {
                .array => is_array = true,
                .object => is_object = true,
                // Only creation-flattened string merges emit a string
                // is_type; numbers/bools have no structural node.
                .string => is_string = true,
                else => return error.UnsupportedPattern,
            },
            .len_eq => |c| len = c.len,
            .len_min => |c| len_min = c.len,
            .str_prefix => |c| prefix = c.literal,
            .str_suffix => |c| suffix = c.literal,
            .keys_exact => keys_exact = true,
            .keys_min, .has_key, .search_key => {},
            else => {
                if (content != null) return error.UnsupportedPattern;
                content = constraint;
            },
        }
    }

    if (is_array) {
        if (content != null) return error.UnsupportedPattern;
        // A len_min array group is a creation-flattened merge; rebuild
        // the interpreter's merge node from the place layout.
        if (len_min) |min| return lowerFlattenedArrayMerge(ctx, scope, place, min, all_bound);
        return lowerArray(ctx, scope, place, len orelse return error.UnsupportedPattern, all_bound);
    }
    if (is_object) {
        if (content != null) return error.UnsupportedPattern;
        // A creation-flattened object merge has no keys_exact: the
        // unclaimed members go to the rest (a members_rest place, or a
        // pruned `_`).
        if (!keys_exact) return lowerFlattenedObjectMerge(ctx, scope, place, all_bound);
        return lowerObject(ctx, scope, place, all_bound);
    }
    if (is_string) {
        if (content != null or len_min == null) return error.UnsupportedPattern;
        return lowerFlattenedStringMerge(ctx, scope, place, prefix, suffix, all_bound);
    }
    if (content) |constraint| return lowerContent(ctx, scope, constraint, all_bound);
    return ctx.builder.appendLeaf(ctx.allocator(), .placeholder, 0);
}

fn elemPlace(scope: Scope, src: GoalAst.PlaceId, index: u32) ?GoalAst.PlaceId {
    for (scope.places, 0..) |def, i| {
        switch (def) {
            .elem => |e| if (e.src == src and e.index == index) return @intCast(i),
            else => {},
        }
    }
    return null;
}

fn elemBackPlace(scope: Scope, src: GoalAst.PlaceId, index: u32) ?GoalAst.PlaceId {
    for (scope.places, 0..) |def, i| {
        switch (def) {
            .elem_back => |e| if (e.src == src and e.index == index) return @intCast(i),
            else => {},
        }
    }
    return null;
}

// Rebuild the interpreter's merge node from a creation-flattened array
// merge: elem places are the before-part elements, elem_back places the
// after-part elements, and the slice place (when its constraint
// survived) is the rest. A pruned slice place means a `_` rest: any
// front/back split consistent with len_min and the surviving element
// indexes is sound, since a placeholder rest tests nothing.
fn lowerFlattenedArrayMerge(
    ctx: *Ctx,
    scope: Scope,
    place: GoalAst.PlaceId,
    min_len: u32,
    all_bound: bool,
) Error!void {
    const allocator = ctx.allocator();

    var slice_place: ?GoalAst.PlaceId = null;
    var front: u32 = 0;
    var back: u32 = 0;
    for (scope.places, 0..) |def, i| switch (def) {
        .slice => |s| if (s.src == place) {
            slice_place = @intCast(i);
            front = s.front;
            back = s.back;
        },
        else => {},
    };
    if (slice_place == null) {
        for (scope.places) |def| switch (def) {
            .elem_back => |e| if (e.src == place and @as(u32, e.index) + 1 > back) {
                back = @as(u32, e.index) + 1;
            },
            else => {},
        };
        front = min_len - back;
    }

    // The front array part is kept even when empty if no other part
    // would type the merge: the interpreter resolves the merge type from
    // its parts, and a template rest cast needs the array type to
    // JSON-parse the rest bytes.
    const with_front = front > 0 or back == 0;
    const start = ctx.builder.nodes.items.len;
    const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
    const part_count: u32 = 1 + @as(u32, @intFromBool(with_front)) + @intFromBool(back > 0);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .merge,
        .subtree_len = undefined,
        .payload = merge_idx,
    });
    try ctx.builder.merges.append(allocator, .{
        .part_count = part_count,
        .solvable_index = null,
    });

    if (with_front) try lowerArray(ctx, scope, place, front, all_bound);

    const rest_index: u32 = @intFromBool(with_front);
    const rest_start = ctx.builder.nodes.items.len;
    if (slice_place) |sub| {
        try lowerPlaceGroup(ctx, scope, sub, all_bound);
    } else {
        try ctx.builder.appendLeaf(allocator, .placeholder, 0);
    }
    const rest_tag = ctx.builder.nodes.items[rest_start].tag;
    if (!all_bound and (rest_tag == .bind or rest_tag == .placeholder)) {
        ctx.builder.merges.items[merge_idx].solvable_index = rest_index;
    }

    if (back > 0) try lowerArrayBack(ctx, scope, place, back, all_bound);

    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

// Rebuild the interpreter's object merge node from a creation-flattened
// object merge: the has_key pairs form one object part and the
// members_rest place (or a pruned `_`) the rest.
fn lowerFlattenedObjectMerge(
    ctx: *Ctx,
    scope: Scope,
    place: GoalAst.PlaceId,
    all_bound: bool,
) Error!void {
    const allocator = ctx.allocator();

    var rest_place: ?GoalAst.PlaceId = null;
    for (scope.places, 0..) |def, i| switch (def) {
        .members_rest => |r| if (r.src == place) {
            rest_place = @intCast(i);
        },
        else => {},
    };

    const start = ctx.builder.nodes.items.len;
    const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .merge,
        .subtree_len = undefined,
        .payload = merge_idx,
    });
    try ctx.builder.merges.append(allocator, .{
        .part_count = 2,
        .solvable_index = null,
    });

    try lowerObject(ctx, scope, place, all_bound);

    const rest_start = ctx.builder.nodes.items.len;
    if (rest_place) |sub| {
        try lowerPlaceGroup(ctx, scope, sub, all_bound);
    } else {
        try ctx.builder.appendLeaf(allocator, .placeholder, 0);
    }
    const rest_tag = ctx.builder.nodes.items[rest_start].tag;
    if (!all_bound and (rest_tag == .bind or rest_tag == .placeholder)) {
        ctx.builder.merges.items[merge_idx].solvable_index = 1;
    }

    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

// Rebuild the interpreter's string merge node from a creation-flattened
// string merge: the prefix and suffix literals become constant string
// parts and the slice place the rest. An empty prefix part is kept when
// no literal would otherwise type the merge, mirroring the array
// reconstruction.
fn lowerFlattenedStringMerge(
    ctx: *Ctx,
    scope: Scope,
    place: GoalAst.PlaceId,
    prefix: ?[]const u8,
    suffix: ?[]const u8,
    all_bound: bool,
) Error!void {
    const allocator = ctx.allocator();

    var slice_place: ?GoalAst.PlaceId = null;
    for (scope.places, 0..) |def, i| switch (def) {
        .slice => |s| if (s.src == place) {
            slice_place = @intCast(i);
        },
        else => {},
    };

    const with_front = prefix != null or suffix == null;
    const start = ctx.builder.nodes.items.len;
    const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
    const part_count: u32 = 1 + @as(u32, @intFromBool(with_front)) + @intFromBool(suffix != null);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .merge,
        .subtree_len = undefined,
        .payload = merge_idx,
    });
    try ctx.builder.merges.append(allocator, .{
        .part_count = part_count,
        .solvable_index = null,
    });

    if (with_front) {
        const sid = try ctx.lower.vm.strings.insert(prefix orelse "");
        try ctx.builder.appendEquality(allocator, Elem.string(sid));
    }

    const rest_index: u32 = @intFromBool(with_front);
    const rest_start = ctx.builder.nodes.items.len;
    if (slice_place) |sub| {
        try lowerPlaceGroup(ctx, scope, sub, all_bound);
    } else {
        try ctx.builder.appendLeaf(allocator, .placeholder, 0);
    }
    const rest_tag = ctx.builder.nodes.items[rest_start].tag;
    if (!all_bound and (rest_tag == .bind or rest_tag == .placeholder)) {
        ctx.builder.merges.items[merge_idx].solvable_index = rest_index;
    }

    if (suffix) |bytes| {
        const sid = try ctx.lower.vm.strings.insert(bytes);
        try ctx.builder.appendEquality(allocator, Elem.string(sid));
    }

    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

// The after-part array of a flattened merge: child j matches the value
// slice's j-th element, which is elem_back index back_len - 1 - j.
fn lowerArrayBack(ctx: *Ctx, scope: Scope, place: GoalAst.PlaceId, back_len: u32, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    try ctx.builder.nodes.append(allocator, .{
        .tag = .array,
        .subtree_len = undefined,
        .payload = back_len,
    });
    for (0..back_len) |j| {
        if (elemBackPlace(scope, place, back_len - 1 - @as(u32, @intCast(j)))) |child| {
            try lowerPlaceGroup(ctx, scope, child, all_bound);
        } else {
            try ctx.builder.appendLeaf(allocator, .placeholder, 0);
        }
    }
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn keyPlace(scope: Scope, src: GoalAst.PlaceId, sid: anytype) ?GoalAst.PlaceId {
    for (scope.places, 0..) |def, i| {
        switch (def) {
            .key => |k| if (k.src == src and k.sid == sid) return @intCast(i),
            else => {},
        }
    }
    return null;
}

fn lowerArray(ctx: *Ctx, scope: Scope, place: GoalAst.PlaceId, len: u32, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    try ctx.builder.nodes.append(allocator, .{
        .tag = .array,
        .subtree_len = undefined,
        .payload = len,
    });
    for (0..len) |index| {
        if (elemPlace(scope, place, @intCast(index))) |child| {
            try lowerPlaceGroup(ctx, scope, child, all_bound);
        } else {
            try ctx.builder.appendLeaf(allocator, .placeholder, 0);
        }
    }
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn lowerObject(ctx: *Ctx, scope: Scope, place: GoalAst.PlaceId, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    try ctx.builder.nodes.append(allocator, .{
        .tag = .object,
        .subtree_len = undefined,
        .payload = 0,
    });

    var pair_count: u32 = 0;
    for (scope.constraints) |constraint| {
        if (constraintPlace(constraint.kind) != place) continue;
        switch (constraint.kind) {
            .has_key => |c| {
                pair_count += 1;
                const pair_start = ctx.builder.nodes.items.len;
                try ctx.builder.nodes.append(allocator, .{
                    .tag = .const_key,
                    .subtree_len = undefined,
                    .payload = @intCast(ctx.builder.sids.items.len),
                });
                const sid = try ctx.lower.vm.strings.insert(
                    ctx.lower.frontend.strings.get(c.sid),
                );
                try ctx.builder.sids.append(allocator, sid);
                if (keyPlace(scope, place, c.sid)) |value_place| {
                    try lowerPlaceGroup(ctx, scope, value_place, all_bound);
                } else {
                    try ctx.builder.appendLeaf(allocator, .placeholder, 0);
                }
                ctx.builder.nodes.items[pair_start].subtree_len = @intCast(ctx.builder.nodes.items.len - pair_start);
            },
            .search_key => |c| {
                pair_count += 1;
                try lowerSearchPair(ctx, c.key, c.value, all_bound);
            },
            else => {},
        }
    }

    ctx.builder.nodes.items[start].payload = pair_count;
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

// A non-constant-key pair: lower the key scope, then classify the pair the
// way the can lowering classifies pattern keys — a key folded to an
// interned string collapses to const_key, a leaf evaluation is eval_key,
// everything else keeps the runtime eval-or-search dispatch.
fn lowerSearchPair(ctx: *Ctx, key_set: GoalAst.SetId, value_set: GoalAst.SetId, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const pair_start = ctx.builder.nodes.items.len;
    try ctx.builder.nodes.append(allocator, .{
        .tag = .pattern_key,
        .subtree_len = undefined,
        .payload = 0,
    });

    const key_start = ctx.builder.nodes.items.len;
    try lowerSet(ctx, key_set, all_bound);
    const key_node = ctx.builder.nodes.items[key_start];
    switch (key_node.tag) {
        .equality => if (ctx.builder.elems.items[key_node.payload].isType(.String)) {
            ctx.builder.nodes.items[pair_start] = .{
                .tag = .const_key,
                .subtree_len = undefined,
                .payload = @intCast(ctx.builder.sids.items.len),
            };
            try ctx.builder.sids.append(allocator, ctx.builder.elems.items[key_node.payload].asString());
            std.debug.assert(key_node.payload == ctx.builder.elems.items.len - 1);
            ctx.builder.nodes.shrinkRetainingCapacity(key_start);
            _ = ctx.builder.elems.pop();
        } else {
            ctx.builder.nodes.items[pair_start].tag = .eval_key;
        },
        .bound_eq, .const_fn, .call => {
            ctx.builder.nodes.items[pair_start].tag = .eval_key;
        },
        else => {},
    }

    try lowerSet(ctx, value_set, all_bound);
    ctx.builder.nodes.items[pair_start].subtree_len = @intCast(ctx.builder.nodes.items.len - pair_start);
}

fn lowerContent(ctx: *Ctx, scope: Scope, constraint: *const GoalAst.Constraint, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    switch (constraint.kind) {
        .bind => |c| try appendLocal(ctx, if (all_bound) .bound_eq else .bind, c.slot, c.name),
        .eq_slot => |c| try appendLocal(ctx, .bound_eq, c.slot, c.name),
        .eq_global => |c| try lowerGlobal(ctx, c.name),
        .eq_const => |c| try ctx.builder.appendEquality(allocator, try foldConstValue(ctx, c.value)),
        .eval_eq => |c| _ = try lowerEvalExpr(ctx, c.expr, 0),
        .in_range => |c| try lowerRange(ctx, c.lower, c.upper, all_bound),
        .negated => |c| {
            const start = ctx.builder.nodes.items.len;
            try ctx.builder.nodes.append(allocator, .{
                .tag = .negated,
                .subtree_len = undefined,
                .payload = c.count,
            });
            try lowerPart(ctx, c.part, all_bound);
            ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
        },
        .solve_merge => |c| try lowerMerge(ctx, .merge, c.parts.items, c.solvable_index, all_bound),
        .match_template => |c| try lowerTemplate(ctx, c.segments.items, all_bound),
        .solve_repeat => |c| try lowerRepeat(ctx, c.pattern, c.count, all_bound),
        .local => @panic("Internal Error: neutral local constraint survived binding"),
        else => return error.UnsupportedPattern,
    }
    _ = scope;
}

fn appendLocal(ctx: *Ctx, tag: match_plan.Tag, slot: u8, name: Frontend.PathTable.Id) Error!void {
    try ctx.builder.appendVar(ctx.allocator(), tag, .{
        .sid = try ctx.lower.internForRuntime(name),
        .idx = slot,
    });
}

// A global in pattern position, mirroring the can lowering: a zero-arity
// Function evaluates per match (const_fn); other functions are
// unsupported; plain values compare directly.
fn lowerGlobal(ctx: *Ctx, name: Frontend.PathTable.Id) Error!void {
    const allocator = ctx.allocator();
    const global = ctx.lower.resolver.resolveGlobal(ctx.module_id, name) orelse
        return error.UnsupportedPattern;
    if (global.isDynType(.Function)) {
        if (global.asDyn().asFunction().arity != 0) return error.UnsupportedPattern;
        return ctx.builder.appendLeaf(allocator, .const_fn, try ctx.builder.addElem(allocator, global));
    }
    return ctx.builder.appendEquality(allocator, global);
}

// Fold an eq_const's value goal to an Elem. Constant folding ran on the
// goal, so only literals arrive; pattern numbers fold to floats the way
// the can lowering folds them, so plan equality compares numerically.
fn foldConstValue(ctx: *Ctx, id: GoalAst.NodeId) Error!Elem {
    const node = ctx.ast.goals.items[id].node;
    return switch (node) {
        .string => |s| Elem.string(try ctx.lower.vm.strings.insert(s)),
        .number_float => |f| Elem.numberFloat(f),
        .number_string => |ns| blk: {
            const elem = try ctx.lower.numberStringNodeToElem(ns.number, ns.negated);
            break :blk elem.asNumberString().toNumberFloat(ctx.lower.vm.strings);
        },
        .true => Elem.boolean(true),
        .false => Elem.boolean(false),
        .null => Elem.nullConst,
        .neg => |inner| blk: {
            const folded = try foldConstValue(ctx, inner);
            break :blk folded.negateNumber() catch return error.NegatedNonNumber;
        },
        else => error.UnsupportedPattern,
    };
}

// An evaluated expression in pattern position: idents read slots or
// globals, calls become call plans, merges of evaluables stay merges the
// interpreter resolves per match. Returns the index of the lowered node.
fn lowerEvalExpr(ctx: *Ctx, id: GoalAst.NodeId, negation_count: u32) Error!u32 {
    const allocator = ctx.allocator();
    const rnode = ctx.ast.goals.items[id];
    const start: u32 = @intCast(ctx.builder.nodes.items.len);
    switch (rnode.node) {
        .string, .number_float, .number_string, .true, .false, .null => {
            var elem = try foldConstValue(ctx, id);
            if (negation_count % 2 == 1) {
                elem = elem.negateNumber() catch return error.NegatedNonNumber;
            }
            try ctx.builder.appendEquality(allocator, elem);
        },
        .neg => |inner| {
            _ = try lowerEvalExpr(ctx, inner, negation_count + 1);
        },
        .ident => |ident| switch (ident.resolution) {
            .local => |slot| {
                if (negation_count != 0) {
                    try ctx.builder.nodes.append(allocator, .{
                        .tag = .negated,
                        .subtree_len = undefined,
                        .payload = negation_count,
                    });
                    try appendLocal(ctx, .bound_eq, slot, ident.name);
                    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
                } else {
                    try appendLocal(ctx, .bound_eq, slot, ident.name);
                }
            },
            .global => {
                if (negation_count != 0) {
                    const global = ctx.lower.resolver.resolveGlobal(ctx.module_id, ident.name) orelse
                        return error.UnsupportedPattern;
                    if (global.isDynType(.Function)) {
                        try ctx.builder.nodes.append(allocator, .{
                            .tag = .negated,
                            .subtree_len = undefined,
                            .payload = negation_count,
                        });
                        try lowerGlobal(ctx, ident.name);
                        ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
                    } else {
                        var folded = global;
                        if (!folded.isNumber()) return error.NegatedNonNumber;
                        if (negation_count % 2 == 1) {
                            folded = folded.negateNumber() catch return error.NegatedNonNumber;
                        }
                        try ctx.builder.appendEquality(allocator, folded);
                    }
                } else {
                    try lowerGlobal(ctx, ident.name);
                }
            },
            .placeholder => try ctx.builder.appendLeaf(allocator, .placeholder, 0),
            .unresolved => @panic("Internal Error: unresolved ident survived binding"),
        },
        .call => |call| {
            if (negation_count != 0) {
                try ctx.builder.nodes.append(allocator, .{
                    .tag = .negated,
                    .subtree_len = undefined,
                    .payload = negation_count,
                });
                _ = try lowerCall(ctx, call);
                ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
            } else {
                _ = try lowerCall(ctx, call);
            }
        },
        .merge => |merge| {
            if (negation_count != 0) return error.UnsupportedPattern;
            const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
            try ctx.builder.nodes.append(allocator, .{
                .tag = .merge,
                .subtree_len = undefined,
                .payload = merge_idx,
            });
            try ctx.builder.merges.append(allocator, .{ .part_count = 0, .solvable_index = null });
            var count: u32 = 0;
            try lowerEvalMergeParts(ctx, merge.left, &count);
            try lowerEvalMergeParts(ctx, merge.right, &count);
            ctx.builder.merges.items[merge_idx].part_count = count;
            ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
        },
        else => return error.UnsupportedPattern,
    }
    return start;
}

fn lowerEvalMergeParts(ctx: *Ctx, id: GoalAst.NodeId, count: *u32) Error!void {
    switch (ctx.ast.goals.items[id].node) {
        .merge => |merge| {
            try lowerEvalMergeParts(ctx, merge.left, count);
            try lowerEvalMergeParts(ctx, merge.right, count);
        },
        else => {
            _ = try lowerEvalExpr(ctx, id, 0);
            count.* += 1;
        },
    }
}

fn lowerCall(ctx: *Ctx, call: GoalAst.Call) Error!u32 {
    const allocator = ctx.allocator();
    const callee = ctx.ast.goals.items[call.callee].node;
    if (callee != .ident) return error.UnsupportedPattern;
    const ident = callee.ident;
    if (ident.underscored) return error.UnsupportedPattern;

    const plan_callee: match_plan.CallPlan.Callee = switch (ident.resolution) {
        .global => blk: {
            const global = ctx.lower.resolver.resolveGlobal(ctx.module_id, ident.name) orelse
                return error.UnsupportedPattern;
            if (!global.isDynType(.Function)) return error.UnsupportedPattern;
            if (global.asDyn().asFunction().arity != call.args.len) return error.UnsupportedPattern;
            break :blk .{ .constant = try ctx.builder.addElem(allocator, global) };
        },
        .local => |slot| .{ .local = try ctx.builder.addVar(allocator, .{
            .sid = try ctx.lower.internForRuntime(ident.name),
            .idx = slot,
        }, .read) },
        else => return error.UnsupportedPattern,
    };

    const start: u32 = @intCast(ctx.builder.nodes.items.len);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .call,
        .subtree_len = undefined,
        .payload = @intCast(ctx.builder.calls.items.len),
    });
    try ctx.builder.calls.append(allocator, .{
        .callee = plan_callee,
        .arg_count = @intCast(call.args.len),
    });
    for (call.args) |arg| {
        _ = try lowerEvalExpr(ctx, arg, 0);
    }
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
    return start;
}

fn lowerRange(ctx: *Ctx, lower_limit: GoalAst.Limit, upper_limit: GoalAst.Limit, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    const range_idx: u32 = @intCast(ctx.builder.ranges.items.len);
    try ctx.builder.nodes.append(allocator, .{ .tag = .range, .subtree_len = 1, .payload = range_idx });
    try ctx.builder.ranges.append(allocator, .{ .lower = .none, .upper = .none });
    const lower = try lowerRangeLimit(ctx, lower_limit, all_bound);
    const upper = try lowerRangeLimit(ctx, upper_limit, all_bound);
    ctx.builder.ranges.items[range_idx] = .{ .lower = lower, .upper = upper };
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn lowerRangeLimit(ctx: *Ctx, limit: GoalAst.Limit, all_bound: bool) Error!match_plan.RangePlan.Limit {
    const allocator = ctx.allocator();
    switch (limit) {
        .none => return .none,
        .bind => |local| {
            const access: PlanBuilder.VarAccess = if (all_bound) .read else .bind;
            const var_idx = try ctx.builder.addVar(allocator, .{
                .sid = try ctx.lower.internForRuntime(local.name),
                .idx = local.slot,
            }, access);
            return if (all_bound) .{ .bound_local = var_idx } else .{ .bind_local = var_idx };
        },
        .read => |local| {
            const var_idx = try ctx.builder.addVar(allocator, .{
                .sid = try ctx.lower.internForRuntime(local.name),
                .idx = local.slot,
            }, .read);
            return .{ .bound_local = var_idx };
        },
        .global => |name| {
            const global = ctx.lower.resolver.resolveGlobal(ctx.module_id, name) orelse
                return error.UnsupportedPattern;
            if (global.isDynType(.Function)) return error.UnsupportedPattern;
            return .{ .const_elem = try ctx.builder.addElem(allocator, global) };
        },
        .expr => |expr| {
            _ = try lowerEvalExpr(ctx, expr, 0);
            return .eval;
        },
        .local => @panic("Internal Error: neutral local limit survived binding"),
    }
}

fn lowerMerge(
    ctx: *Ctx,
    tag: match_plan.Tag,
    parts: []const GoalAst.Part,
    solvable_index: ?u32,
    all_bound: bool,
) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
    try ctx.builder.nodes.append(allocator, .{
        .tag = tag,
        .subtree_len = undefined,
        .payload = merge_idx,
    });
    try ctx.builder.merges.append(allocator, .{
        .part_count = @intCast(parts.len),
        .solvable_index = if (all_bound) null else solvable_index,
    });
    for (parts, 0..) |part, i| {
        const part_start: u32 = @intCast(ctx.builder.nodes.items.len);
        try lowerPart(ctx, part, all_bound);
        // Repeat merge parts keep the can lowering's restrictions: a
        // counted structural repeat is matched in place only for object
        // patterns, and a solvable repeat's count must be a bare binder.
        // Anything else is a shape the interpreter cannot resolve.
        if (ctx.builder.nodes.items[part_start].tag == .repeat) {
            const solvable = !all_bound and solvable_index != null and solvable_index.? == i;
            const pattern_idx = part_start + 1;
            const count_idx = pattern_idx + ctx.builder.nodes.items[pattern_idx].subtree_len;
            const count_tag = ctx.builder.nodes.items[count_idx].tag;
            if (solvable) {
                if (count_tag != .bind) return error.UnsupportedPattern;
            } else {
                if (ctx.builder.nodes.items[pattern_idx].tag != .object) return error.UnsupportedPattern;
                switch (count_tag) {
                    .equality, .bound_eq, .const_fn, .call => {},
                    .negated => if (pattern.classifyPlanSubtree(ctx.lower, ctx.builder, count_idx) != .eval) {
                        return error.UnsupportedPattern;
                    },
                    else => return error.UnsupportedPattern,
                }
            }
        }
    }
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn lowerTemplate(ctx: *Ctx, segments: []const GoalAst.Segment, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    const merge_idx: u32 = @intCast(ctx.builder.merges.items.len);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .str_template,
        .subtree_len = undefined,
        .payload = merge_idx,
    });
    try ctx.builder.merges.append(allocator, .{
        .part_count = @intCast(segments.len),
        .solvable_index = null,
    });
    for (segments, 0..) |segment, i| {
        const segment_start: u32 = @intCast(ctx.builder.nodes.items.len);
        switch (segment) {
            .literal => |bytes| {
                const sid = try ctx.lower.vm.strings.insert(bytes);
                try ctx.builder.appendEquality(allocator, Elem.string(sid));
            },
            .part => |part| try lowerPart(ctx, part, all_bound),
        }
        // The solvable segment is the one the solver casts from the
        // unmatched byte range: any structural (non-evaluable) segment
        // except a range, which matches exactly one character. The
        // scheduler enforced at most one. Constant segments stringify at
        // lowering, the way the can path folds them.
        const node = ctx.builder.nodes.items[segment_start];
        const structural = pattern.classifyPlanSubtree(ctx.lower, ctx.builder, segment_start) == .subtree;
        if (!all_bound and structural and node.tag != .range) {
            ctx.builder.merges.items[merge_idx].solvable_index = @intCast(i);
        } else if (node.tag == .equality) {
            const elem_idx = node.payload;
            const stringified = try ctx.builder.elems.items[elem_idx].toString(ctx.lower.vm);
            if (stringified.isType(.Dyn)) stringified.asDyn().makeImmortal();
            ctx.builder.elems.items[elem_idx] = stringified;
        }
    }
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn lowerRepeat(ctx: *Ctx, repeat_pattern: GoalAst.Part, count: GoalAst.Part, all_bound: bool) Error!void {
    const allocator = ctx.allocator();
    const start = ctx.builder.nodes.items.len;
    const repeat_idx: u32 = @intCast(ctx.builder.repeats.items.len);
    try ctx.builder.nodes.append(allocator, .{
        .tag = .repeat,
        .subtree_len = undefined,
        .payload = repeat_idx,
    });
    try ctx.builder.repeats.append(allocator, .{
        .pattern = .subtree,
        .count = .subtree,
        .has_rebound_pattern = false,
    });

    const pattern_start: u32 = @intCast(ctx.builder.nodes.items.len);
    try lowerPart(ctx, repeat_pattern, all_bound);
    const count_start: u32 = @intCast(ctx.builder.nodes.items.len);
    try lowerPart(ctx, count, all_bound);

    const pattern_op = try pattern.lowerRepeatOperand(ctx.lower, ctx.builder, pattern_start);
    const count_op = try pattern.lowerRepeatOperand(ctx.lower, ctx.builder, count_start);

    var has_rebound = false;
    for (ctx.builder.nodes.items[pattern_start..count_start]) |n| {
        if (n.tag == .bind) {
            has_rebound = true;
            break;
        }
    }
    if (has_rebound) {
        try lowerPart(ctx, repeat_pattern, true);
    }

    ctx.builder.repeats.items[repeat_idx] = .{
        .pattern = pattern_op,
        .count = count_op,
        .has_rebound_pattern = has_rebound,
    };
    ctx.builder.nodes.items[start].subtree_len = @intCast(ctx.builder.nodes.items.len - start);
}

fn lowerPart(ctx: *Ctx, part: GoalAst.Part, all_bound: bool) Error!void {
    switch (part) {
        .placeholder => try ctx.builder.appendLeaf(ctx.allocator(), .placeholder, 0),
        .bind => |local| try appendLocal(ctx, if (all_bound) .bound_eq else .bind, local.slot, local.name),
        .read => |local| try appendLocal(ctx, .bound_eq, local.slot, local.name),
        .global => |name| try lowerGlobal(ctx, name),
        .expr => |expr| _ = try lowerEvalExpr(ctx, expr, 0),
        .sub => |set_id| try lowerSet(ctx, set_id, all_bound),
        .local => @panic("Internal Error: neutral local part survived binding"),
    }
}

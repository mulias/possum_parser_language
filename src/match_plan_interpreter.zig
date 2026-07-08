const std = @import("std");
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const match_plan = @import("match_plan.zig");
const MatchPlan = match_plan.MatchPlan;
const LocalVar = match_plan.LocalVar;
const ResolvedPart = match_plan.ResolvedPart;
const StringTable = @import("string_table.zig").StringTable(.runtime);
const isValidNumberString = @import("parsing.zig").isValidNumberString;

pub const Error = error{
    RuntimeError,
    OutOfMemory,
} || VM.Error;

// Interpreter for compiled match plans. Runs directly against the VM with no
// PatternSolver bookkeeping: bind-vs-equality is decided statically, so there
// is no runtime boundness probing, and a failed match leaves its binds in
// place. Binding analysis guarantees stale slots are never read and emits
// preclears before any pattern that may re-bind them.
//
// value_discarded: the VM will pop the match result without looking inside
// it, so an object rest may take over a uniquely-referenced value in place.
pub fn match(vm: *VM, value: Elem, plan: MatchPlan, value_discarded: bool) Error!bool {
    // Prevent GC of dyns created while the match evaluates a zero-arity
    // function on the VM or materializes a rest value.
    const temp_dyns_start = vm.temp_dyns.items.len;
    defer vm.clearTempDyns(temp_dyns_start);

    const discardable_root: ?*Elem.DynElem =
        if (value_discarded and value.isType(.Dyn)) value.asDyn() else null;

    return matchNode(vm, value, plan, 0, discardable_root);
}

// discardable is the root value dyn when the VM discards the match result;
// it is only consulted by an object merge matching that dyn directly, so
// recursive calls (which match sub-values) pass null.
fn matchNode(vm: *VM, value: Elem, plan: MatchPlan, idx: u32, discardable: ?*Elem.DynElem) Error!bool {
    const node = plan.nodes[idx];

    switch (node.tag) {
        .placeholder => return true,
        .equality => return value.isEql(plan.elems[node.payload], vm.*),
        .bind => {
            bindLocal(vm, plan.vars[node.payload], value);
            return true;
        },
        .bound_eq => {
            const pattern_value = try resolveBoundLocal(vm, plan.vars[node.payload]);
            return value.isEql(pattern_value, vm.*);
        },
        .array => {
            if (!value.isDynType(.Array)) return false;
            const value_array = value.asDyn().asArray();
            if (value_array.elems.items.len != node.payload) return false;
            return matchArrayElems(vm, plan, idx, value_array.elems.items);
        },
        .object => {
            if (!value.isDynType(.Object)) return false;
            const value_object = value.asDyn().asObject();
            if (value_object.members.count() != node.payload) return false;
            return matchObjectPairs(vm, plan, idx, value_object, null);
        },
        // Only reachable through its object node.
        .const_key => unreachable,
        .range => {
            const range = plan.ranges[node.payload];
            if (try resolveRangeLimit(vm, plan, range.lower)) |lower| {
                if (!(try lower.isLessThanOrEqualInRangePattern(value, vm.*))) return false;
            }
            if (try resolveRangeLimit(vm, plan, range.upper)) |upper| {
                if (!(try value.isLessThanOrEqualInRangePattern(upper, vm.*))) return false;
            }
            return true;
        },
        .merge => {
            const merge_plan = plan.merges[node.payload];
            const parts_base = vm.plan_merge_parts.items.len;
            defer vm.plan_merge_parts.shrinkRetainingCapacity(parts_base);

            try resolveMergeParts(vm, plan, idx);
            const count = merge_plan.part_count;
            const merge_type = try resolveMergeType(vm, plan, parts_base, count);
            return matchMergeOfType(vm, plan, value, parts_base, count, merge_type, discardable);
        },
        .str_template => {
            const template_plan = plan.merges[node.payload];
            const parts_base = vm.plan_merge_parts.items.len;
            defer vm.plan_merge_parts.shrinkRetainingCapacity(parts_base);

            // Resolve value segments up front, the way the solver
            // simplifies and toStrings every segment before matching any.
            // Constant segments were stringified at compile time.
            var child = idx + 1;
            for (0..template_plan.part_count) |i| {
                const child_node = plan.nodes[child];
                const solvable = template_plan.solvable_index != null and template_plan.solvable_index.? == i;
                const part: ResolvedPart = if (solvable)
                    .{ .subtree = child }
                else switch (child_node.tag) {
                    .equality => .{ .value = plan.elems[child_node.payload] },
                    .bound_eq => .{ .value = try stringifyBoundLocal(vm, plan.vars[child_node.payload]) },
                    .range => .{ .subtree = child },
                    // Lowering rejects other non-solvable segment shapes.
                    else => unreachable,
                };
                try vm.plan_merge_parts.append(vm.allocator, part);
                child += child_node.subtree_len;
            }

            return matchStringTemplate(vm, plan, value, parts_base, template_plan.part_count);
        },
    }
}

// Resolve the parts of a merge node into vm.plan_merge_parts, the way the
// solver simplifies every part before matching any. The solvable part
// stays a subtree even when it is a sequentially-bound local: it is only
// bound by an earlier part of this merge, so its slot must be read at its
// match position, not here. Bound locals may run a zero-arity function on
// the VM here.
fn resolveMergeParts(vm: *VM, plan: MatchPlan, merge_node_idx: u32) Error!void {
    const merge_plan = plan.merges[plan.nodes[merge_node_idx].payload];
    var child = merge_node_idx + 1;
    for (0..merge_plan.part_count) |i| {
        const child_node = plan.nodes[child];
        const solvable = merge_plan.solvable_index != null and merge_plan.solvable_index.? == i;
        const part: ResolvedPart = if (solvable)
            .{ .subtree = child }
        else switch (child_node.tag) {
            .equality => .{ .value = plan.elems[child_node.payload] },
            .bound_eq => .{ .value = try resolveBoundLocal(vm, plan.vars[child_node.payload]) },
            else => .{ .subtree = child },
        };
        try vm.plan_merge_parts.append(vm.allocator, part);
        child += child_node.subtree_len;
    }
}

fn matchMergeOfType(
    vm: *VM,
    plan: MatchPlan,
    value: Elem,
    base: usize,
    count: u32,
    merge_type: MergeType,
    discardable: ?*Elem.DynElem,
) Error!bool {
    return switch (merge_type) {
        .array => matchArrayMerge(vm, plan, value, base, count),
        .boolean => matchBooleanMerge(vm, plan, value, base, count),
        .number => matchNumberMerge(vm, plan, value, base, count),
        .object => matchObjectMerge(vm, plan, value, base, count, discardable),
        .string => matchStringMerge(vm, plan, value, base, count),
        .untyped => matchUntypedMerge(vm, plan, value, base, count),
    };
}

// Match consecutive element subtrees of an array node against a value
// slice, without the node's own dyn-type or length checks: the merge
// matchers match structural array parts against a slice of the value.
fn matchArrayElems(vm: *VM, plan: MatchPlan, array_node_idx: u32, value_slice: []Elem) Error!bool {
    var child = array_node_idx + 1;
    for (value_slice) |element| {
        if (!(try matchNode(vm, element, plan, child, null))) return false;
        child += plan.nodes[child].subtree_len;
    }
    return true;
}

// Match the const_key pairs of an object node against a value object,
// without the node's own member-count check. When matched_base is set, each
// matched key is recorded for the enclosing object merge's rest.
fn matchObjectPairs(
    vm: *VM,
    plan: MatchPlan,
    object_node_idx: u32,
    value_object: *Elem.DynElem.Object,
    matched_base: ?usize,
) Error!bool {
    var pair = object_node_idx + 1;
    for (0..plan.nodes[object_node_idx].payload) |_| {
        const key_node = plan.nodes[pair];
        std.debug.assert(key_node.tag == .const_key);
        const sid = plan.sids[key_node.payload];
        // No matched-key claim check: parts of a single merge share
        // members, and duplicate literal keys just re-probe, the same
        // members the tree path tolerates re-matching.
        const member = value_object.members.get(sid) orelse return false;
        if (!(try matchNode(vm, member, plan, pair + 1, null))) return false;
        if (matched_base) |base| try markKeyMatched(vm, base, sid);
        pair += key_node.subtree_len;
    }
    return true;
}

const MergeType = enum { array, boolean, number, object, string, untyped };

fn mergePart(vm: *VM, base: usize, i: usize) ResolvedPart {
    return vm.plan_merge_parts.items[base + i];
}

// The merge type of resolved parts, mirroring the solver's getMergeType:
// the first typed part decides, later parts must agree or be untyped.
fn resolveMergeType(vm: *VM, plan: MatchPlan, base: usize, count: u32) Error!MergeType {
    var merge_type: MergeType = .untyped;
    for (0..count) |i| {
        const part_type = try mergePartType(plan, mergePart(vm, base, i));
        if (merge_type == .untyped) {
            merge_type = part_type;
        } else if (part_type != merge_type and part_type != .untyped) {
            return error.RuntimeError;
        }
    }
    return merge_type;
}

fn mergePartType(plan: MatchPlan, part: ResolvedPart) Error!MergeType {
    return switch (part) {
        .value => |elem| switch (elem.getType()) {
            .String, .InputSubstring => .string,
            .NumberString, .NumberFloat => .number,
            .Const => switch (elem.asConst()) {
                .True, .False => .boolean,
                .Null, .Failure => .untyped,
            },
            .ValueVar => .untyped,
            .Dyn => switch (elem.asDyn().dynType) {
                .String => .string,
                .Array => .array,
                .Object => .object,
                .Function, .NativeCode, .Closure => .untyped,
            },
        },
        .subtree => |idx| switch (plan.nodes[idx].tag) {
            .array => .array,
            .object => .object,
            .str_template => .string,
            // A bound_eq subtree is the solvable part: a local this merge
            // binds before its position. The solver's simplify sees it
            // unbound, so its type contribution is untyped.
            .bind, .bound_eq, .placeholder => .untyped,
            // Ranges are not mergeable; mirrors mergePatternType.
            .range => error.RuntimeError,
            // Value parts were resolved, nested merges were flattened at
            // compile time, and const_key only appears under an object.
            .equality, .const_key, .merge => unreachable,
        },
    };
}

fn matchArrayMerge(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var before_unbound_range: usize = 0;
    var after_unbound_range: usize = 0;
    var unbound_index: ?usize = null;

    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (elem.isDynType(.Array)) {
                    const array_len = elem.asDyn().asArray().len();
                    if (unbound_index == null) {
                        before_unbound_range += array_len;
                    } else {
                        after_unbound_range += array_len;
                    }
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => |part_idx| {
                if (plan.nodes[part_idx].tag == .array) {
                    const array_len = plan.nodes[part_idx].payload;
                    if (unbound_index == null) {
                        before_unbound_range += array_len;
                    } else {
                        after_unbound_range += array_len;
                    }
                } else if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // Array merge can only have one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    if (!value.isDynType(.Array)) return false;
    const value_array = value.asDyn().asArray();
    if (value_array.elems.items.len < before_unbound_range + after_unbound_range) return false;

    var value_index: usize = 0;

    // Match the before parts
    for (0..count) |i| {
        if (unbound_index != null and unbound_index.? == i) break;
        if (!(try matchArrayMergeFixedPart(vm, plan, value_array, &value_index, mergePart(vm, base, i)))) {
            return false;
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_index) |ui| {
        const unbound_start = value_index;
        const unbound_end = value_array.elems.items.len - after_unbound_range;

        std.debug.assert(unbound_start <= unbound_end);

        const sub = mergePart(vm, base, ui).subtree;
        // A bare `_` rest matches any range without binding; skip
        // materializing it.
        if (plan.nodes[sub].tag != .placeholder) {
            const unbound_elems = value_array.elems.items[unbound_start..unbound_end];
            const unbound_array = try Elem.DynElem.Array.create(vm, unbound_elems.len);
            try vm.pushTempDyn(&unbound_array.dyn);

            for (unbound_elems) |unbound_item| unbound_item.retain();
            try unbound_array.elems.appendSlice(vm.gc.allocator(), unbound_elems);

            const rest_matched = try matchNode(vm, unbound_array.dyn.elem(), plan, sub, null);

            // Hand the creator handle to whatever the match bound; see
            // matchObjectMerge.
            unbound_array.dyn.release();

            if (!rest_matched) return false;
        }

        value_index = unbound_end;

        // Match the after parts
        for (ui + 1..count) |i| {
            if (!(try matchArrayMergeFixedPart(vm, plan, value_array, &value_index, mergePart(vm, base, i)))) {
                return false;
            }
        }
    }

    return true;
}

// One fixed-size part of an array merge: a constant array compared
// elementwise or a structural array subtree matched against the next slice
// of the value.
fn matchArrayMergeFixedPart(
    vm: *VM,
    plan: MatchPlan,
    value_array: *Elem.DynElem.Array,
    value_index: *usize,
    part: ResolvedPart,
) Error!bool {
    switch (part) {
        .value => |elem| {
            if (elem.isDynType(.Array)) {
                const array = elem.asDyn().asArray();
                const end_index = value_index.* + array.elems.items.len;
                if (end_index > value_array.elems.items.len) return false;

                for (array.elems.items, 0..) |expected_elem, i| {
                    if (!value_array.elems.items[value_index.* + i].isEql(expected_elem, vm.*)) {
                        return false;
                    }
                }
                value_index.* = end_index;
            } else if (elem.isConst(.Null)) {
                // Skip null
            } else {
                @panic("Internal Error");
            }
        },
        .subtree => |part_idx| {
            // The callers stop at the unbound part, so only structural
            // array parts reach here.
            std.debug.assert(plan.nodes[part_idx].tag == .array);
            const end_index = value_index.* + plan.nodes[part_idx].payload;
            if (end_index > value_array.elems.items.len) return false;

            if (!(try matchArrayElems(vm, plan, part_idx, value_array.elems.items[value_index.*..end_index]))) {
                return false;
            }
            value_index.* = end_index;
        },
    }
    return true;
}

fn matchBooleanMerge(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var bound_truth = Elem.boolean(false);
    var unbound_index: ?usize = null;

    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (try bound_truth.merge(elem, vm)) |new_truth| {
                    bound_truth = new_truth;
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => {
                if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // Boolean merge can only have one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    if (unbound_index) |ui| {
        const sub = mergePart(vm, base, ui).subtree;
        if (bound_truth.isConst(.True)) {
            if (value.isEql(bound_truth, vm.*)) {
                // `true -> (true + X)`
                return (try matchNode(vm, Elem.boolean(false), plan, sub, null)) or
                    (try matchNode(vm, Elem.boolean(true), plan, sub, null));
            } else {
                // `false -> (true + X)`
                return false;
            }
        } else {
            // `value -> (false + X)`
            return matchNode(vm, value, plan, sub, null);
        }
    }
    // `value -> true` / `value -> false`
    return value.isEql(bound_truth, vm.*);
}

fn matchNumberMerge(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var bound_sum = Elem.numberFloat(0);
    var unbound_index: ?usize = null;

    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (try bound_sum.merge(elem, vm)) |new_sum| {
                    bound_sum = new_sum;
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => {
                if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // Number merge can only have one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    if (!value.isNumber()) {
        return false;
    } else if (unbound_index) |ui| {
        const diff = (try value.merge(try bound_sum.negateNumber(), vm)).?;
        return matchNode(vm, diff, plan, mergePart(vm, base, ui).subtree, null);
    } else {
        return value.isEql(bound_sum, vm.*);
    }
}

fn matchObjectMerge(
    vm: *VM,
    plan: MatchPlan,
    value: Elem,
    base: usize,
    count: u32,
    discardable: ?*Elem.DynElem,
) Error!bool {
    if (!value.isDynType(.Object)) return false;
    var value_object = value.asDyn().asObject();

    const matched_base = vm.plan_matched_keys.items.len;
    defer vm.plan_matched_keys.shrinkRetainingCapacity(matched_base);

    var unbound_index: ?usize = null;

    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (elem.isDynType(.Object)) {
                    const object = elem.asDyn().asObject();
                    var iter = object.members.iterator();
                    while (iter.next()) |pair| {
                        const key_sid = pair.key_ptr.*;
                        if (value_object.members.get(key_sid)) |member_value| {
                            if (!member_value.isEql(pair.value_ptr.*, vm.*)) return false;
                            try markKeyMatched(vm, matched_base, key_sid);
                        } else {
                            // Value object doesn't have this key
                            return false;
                        }
                    }
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => |part_idx| switch (plan.nodes[part_idx].tag) {
                .object => {
                    if (!(try matchObjectPairs(vm, plan, part_idx, value_object, matched_base))) {
                        return false;
                    }
                },
                else => {
                    if (unbound_index == null) {
                        unbound_index = i;
                    } else {
                        // Object merge can only have one unbound part
                        return error.RuntimeError;
                    }
                },
            },
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_index) |ui| {
        const sub = mergePart(vm, base, ui).subtree;
        const sub_node = plan.nodes[sub];
        // A bare `_` rest matches any remaining members without binding, so
        // the rest object is never observed.
        if (sub_node.tag != .placeholder) {
            if (canBindRestInPlace(vm, plan, value, sub_node, discardable)) {
                // Every part before the rest has matched and binding an
                // unbound var cannot fail, so the match is already a
                // success. Give up the matched members and bind the rest
                // var to the value object itself instead of copying the
                // remaining members into a fresh object.
                for (vm.plan_matched_keys.items[matched_base..]) |sid| {
                    const removed = value_object.members.fetchOrderedRemove(sid);
                    removed.?.value.release();
                }
                bindLocal(vm, plan.vars[sub_node.payload], value);
            } else {
                // Create an object with only the unmatched keys, preserving
                // the value object's member order
                const matched_count = vm.plan_matched_keys.items.len - matched_base;
                const unbound_object = try Elem.DynElem.Object.create(vm, value_object.members.count() - matched_count);
                try vm.pushTempDyn(&unbound_object.dyn);

                var member_iterator = value_object.members.iterator();
                while (member_iterator.next()) |entry| {
                    const key_sid = entry.key_ptr.*;
                    if (keyMatched(vm, matched_base, key_sid)) continue;
                    try unbound_object.put(vm, key_sid, entry.value_ptr.*);
                }

                const rest_matched = try matchNode(vm, unbound_object.dyn.elem(), plan, sub, null);

                // Hand the creator handle over: after this the object is
                // owned by the local slot the match bound (or by no one, if
                // the rest matched against an already-bound value). Keeping
                // the extra count would make every rest binding look shared
                // and defeat downstream unique-value fast paths.
                unbound_object.dyn.release();

                if (!rest_matched) return false;
            }
        }
    }

    return true;
}

// The rest of a root-level object destructure can take over the value
// object when the VM will discard the match result and the stack holds the
// only handle: nothing else can observe the removed members. Restricted to
// a bind so the binding cannot fail after the mutation. Unlike the solver
// there is no runtime is-the-slot-unbound probe: a bind tag is statically
// unbound, and a stale value left in the slot by an earlier failed match is
// released by the bind either way.
fn canBindRestInPlace(
    vm: *VM,
    plan: MatchPlan,
    value: Elem,
    rest_node: match_plan.Node,
    discardable: ?*Elem.DynElem,
) bool {
    if (!vm.config.rc_fast_paths) return false;
    if (discardable == null or discardable.? != value.asDyn()) return false;
    if (!value.asDyn().isUnique()) return false;
    if (rest_node.tag != .bind) return false;
    return !plan.vars[rest_node.payload].hasBeenNegated();
}

fn matchStringMerge(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var before_unbound_length: usize = 0;
    var after_unbound_length: usize = 0;
    var unbound_index: ?usize = null;

    // Calculate lengths and find the unbound part
    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (try elem.stringBytes(vm)) |part_str| {
                    if (unbound_index == null) {
                        before_unbound_length += part_str.len;
                    } else {
                        after_unbound_length += part_str.len;
                    }
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => {
                if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // String merge can only have one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    const value_str = (try value.stringBytes(vm)) orelse return false;
    if (value_str.len < before_unbound_length + after_unbound_length) return false;

    var value_index: usize = 0;

    // Match the before parts
    for (0..count) |i| {
        if (unbound_index != null and unbound_index.? == i) break;
        if (!(try matchStringMergeFixedPart(vm, value_str, &value_index, mergePart(vm, base, i)))) {
            return false;
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_index) |ui| {
        const unbound_start = value_index;
        const unbound_end = value_str.len - after_unbound_length;

        std.debug.assert(unbound_start <= unbound_end);

        const sub = mergePart(vm, base, ui).subtree;
        // A bare `_` rest matches any substring without binding; skip
        // materializing it.
        if (plan.nodes[sub].tag != .placeholder) {
            const unbound_value = value_str[unbound_start..unbound_end];
            const unbound_elem = if (value.isType(.InputSubstring)) blk: {
                const start = value.asInputSubstring().start;
                if (try Elem.inputSubstringFromRange(start + unbound_start, start + unbound_end)) |elem| {
                    break :blk elem;
                } else {
                    const str = try Elem.DynElem.String.copy(vm, unbound_value);
                    try vm.pushTempDyn(&str.dyn);
                    break :blk str.dyn.elem();
                }
            } else blk: {
                // Allocate a dynamic string
                const dyn_str = try Elem.DynElem.String.create(vm, unbound_value.len);
                try vm.pushTempDyn(&dyn_str.dyn);
                try dyn_str.concatBytes(unbound_value);
                break :blk dyn_str.dyn.elem();
            };

            const rest_matched = try matchNode(vm, unbound_elem, plan, sub, null);

            // Hand the creator handle to whatever the match bound; see
            // matchObjectMerge.
            if (unbound_elem.isType(.Dyn)) unbound_elem.asDyn().release();

            if (!rest_matched) return false;
        }

        value_index = unbound_end;

        // Match the after parts. Only value parts can follow the unbound
        // part: range parts fail merge type resolution.
        for (ui + 1..count) |i| {
            if (!(try matchStringMergeFixedPart(vm, value_str, &value_index, mergePart(vm, base, i)))) {
                return false;
            }
        }
    }

    return true;
}

fn matchStringMergeFixedPart(
    vm: *VM,
    value_str: []const u8,
    value_index: *usize,
    part: ResolvedPart,
) Error!bool {
    switch (part) {
        .value => |elem| {
            if (try elem.stringBytes(vm)) |part_str| {
                const end_index = value_index.* + part_str.len;
                if (end_index > value_str.len) return false;

                if (!std.mem.eql(u8, value_str[value_index.*..end_index], part_str)) {
                    return false;
                }
                value_index.* = end_index;
            } else if (elem.isConst(.Null)) {
                // Skip null
            } else {
                return false;
            }
        },
        // The callers stop at the unbound part and range parts fail merge
        // type resolution.
        .subtree => unreachable,
    }
    return true;
}

fn matchUntypedMerge(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var unbound_index: ?usize = null;

    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                std.debug.assert(elem.isConst(.Null));
            },
            .subtree => {
                if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // More than one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    if (unbound_index) |ui| {
        return matchNode(vm, value, plan, mergePart(vm, base, ui).subtree, null);
    }
    return value.isEql(Elem.nullConst, vm.*);
}

fn matchStringTemplate(vm: *VM, plan: MatchPlan, value: Elem, base: usize, count: u32) Error!bool {
    var before_unbound_length: usize = 0;
    var after_unbound_length: usize = 0;
    var unbound_index: ?usize = null;

    // Calculate lengths and find the unbound segment. Character ranges
    // always match exactly one character.
    for (0..count) |i| {
        switch (mergePart(vm, base, i)) {
            .value => |elem| {
                if (try elem.stringBytes(vm)) |part_str| {
                    if (unbound_index == null) {
                        before_unbound_length += part_str.len;
                    } else {
                        after_unbound_length += part_str.len;
                    }
                } else {
                    @panic("Internal Error");
                }
            },
            .subtree => |n| {
                if (plan.nodes[n].tag == .range) {
                    if (unbound_index == null) {
                        before_unbound_length += 1;
                    } else {
                        after_unbound_length += 1;
                    }
                } else if (unbound_index == null) {
                    unbound_index = i;
                } else {
                    // String merge can only have one unbound part
                    return error.RuntimeError;
                }
            },
        }
    }

    const value_str = (try value.stringBytes(vm)) orelse return false;
    if (value_str.len < before_unbound_length + after_unbound_length) return false;

    var value_index: usize = 0;

    // Match the before segments
    for (0..count) |i| {
        if (unbound_index != null and unbound_index.? == i) break;
        if (!(try matchTemplateFixedSegment(vm, plan, value_str, &value_index, mergePart(vm, base, i)))) {
            return false;
        }
    }

    // Handle the unbound segment if it exists
    if (unbound_index) |ui| {
        const unbound_start = value_index;
        const unbound_end = value_str.len - after_unbound_length;

        std.debug.assert(unbound_start <= unbound_end);

        if (!(try matchTemplateUnboundSegment(
            vm,
            plan,
            value,
            value_str,
            unbound_start,
            unbound_end,
            mergePart(vm, base, ui).subtree,
        ))) {
            return false;
        }

        value_index = unbound_end;

        // Match the after segments
        for (ui + 1..count) |i| {
            if (!(try matchTemplateFixedSegment(vm, plan, value_str, &value_index, mergePart(vm, base, i)))) {
                return false;
            }
        }
    }

    return true;
}

// A constant segment compared bytewise or a character range matching
// exactly one character.
fn matchTemplateFixedSegment(
    vm: *VM,
    plan: MatchPlan,
    value_str: []const u8,
    value_index: *usize,
    part: ResolvedPart,
) Error!bool {
    switch (part) {
        .value => |elem| {
            if (try elem.stringBytes(vm)) |part_str| {
                const end_index = value_index.* + part_str.len;
                if (end_index > value_str.len) return false;

                if (!std.mem.eql(u8, value_str[value_index.*..end_index], part_str)) {
                    return false;
                }
                value_index.* = end_index;
            } else {
                @panic("Internal Error");
            }
        },
        .subtree => |n| {
            std.debug.assert(plan.nodes[n].tag == .range);
            if (value_index.* >= value_str.len) return false;
            const char_byte = value_str[value_index.*];
            const char_elem = Elem.string(try vm.strings.insert(&[_]u8{char_byte}));
            if (!(try matchNode(vm, char_elem, plan, n, null))) return false;
            value_index.* += 1;
        },
    }
    return true;
}

// Cast the unbound byte range by the solvable segment's pattern kind, the
// way matchStringTemplate does, then match the cast value against it.
fn matchTemplateUnboundSegment(
    vm: *VM,
    plan: MatchPlan,
    value: Elem,
    value_str: []const u8,
    unbound_start: usize,
    unbound_end: usize,
    sub: u32,
) Error!bool {
    const unbound_bytes = value_str[unbound_start..unbound_end];

    var unbound_elem: ?Elem = null;
    var merge_cast: ?struct { base: usize, count: u32, merge_type: MergeType } = null;

    const scratch_base = vm.plan_merge_parts.items.len;
    defer vm.plan_merge_parts.shrinkRetainingCapacity(scratch_base);

    if (unbound_bytes.len == 0) {
        // If the unbound part is empty then the pattern must match an
        // empty string.
        unbound_elem = Elem.string(try vm.strings.insert(""));
    } else switch (plan.nodes[sub].tag) {
        .array => if (unbound_bytes[0] == '[') {
            unbound_elem = try parseBytesAsJsonElem(vm, unbound_bytes);
        },
        .object => if (unbound_bytes[0] == '{') {
            unbound_elem = try parseBytesAsJsonElem(vm, unbound_bytes);
        },
        .merge => {
            const merge_plan = plan.merges[plan.nodes[sub].payload];
            try resolveMergeParts(vm, plan, sub);
            const merge_type = try resolveMergeType(vm, plan, scratch_base, merge_plan.part_count);
            merge_cast = .{
                .base = scratch_base,
                .count = merge_plan.part_count,
                .merge_type = merge_type,
            };

            switch (merge_type) {
                .array => if (unbound_bytes[0] == '[') {
                    unbound_elem = try parseBytesAsJsonElem(vm, unbound_bytes);
                },
                .object => if (unbound_bytes[0] == '{') {
                    unbound_elem = try parseBytesAsJsonElem(vm, unbound_bytes);
                },
                .boolean => if (std.mem.eql(u8, unbound_bytes, "true")) {
                    unbound_elem = Elem.boolean(true);
                } else if (std.mem.eql(u8, unbound_bytes, "false")) {
                    unbound_elem = Elem.boolean(false);
                },
                .number => if (isValidNumberString(unbound_bytes)) {
                    unbound_elem = try Elem.numberStringFromBytes(unbound_bytes, vm);
                },
                .string, .untyped => {
                    var all_null = true;
                    for (0..merge_plan.part_count) |i| {
                        const part = mergePart(vm, scratch_base, i);
                        if (part == .value and !part.value.isConst(.Null)) {
                            all_null = false;
                        }
                    }

                    if (all_null and std.mem.eql(u8, unbound_bytes, "null")) {
                        unbound_elem = Elem.nullConst;
                    } else {
                        unbound_elem = try substringElem(vm, value, value_str, unbound_start, unbound_end);
                    }
                },
            }
        },
        // When the pattern is an unbound local default to string. Try to
        // use a subset of an existing substring if possible.
        .bind, .bound_eq, .placeholder, .str_template => {
            unbound_elem = try substringElem(vm, value, value_str, unbound_start, unbound_end);
        },
        // Constants evaluate to value segments, ranges are fixed-length
        // segments, and const_key only appears under an object.
        .equality, .const_key, .range => unreachable,
    }

    if (unbound_elem) |cast_elem| {
        if (merge_cast) |mc| {
            return matchMergeOfType(vm, plan, cast_elem, mc.base, mc.count, mc.merge_type, null);
        }
        return matchNode(vm, cast_elem, plan, sub, null);
    }
    return false;
}

fn substringElem(vm: *VM, value: Elem, value_str: []const u8, start: usize, end: usize) Error!Elem {
    if (value.isType(.InputSubstring)) {
        const value_start = value.asInputSubstring().start;
        if (try Elem.inputSubstringFromRange(value_start + start, value_start + end)) |elem| {
            return elem;
        }
    }
    const str = try Elem.DynElem.String.copy(vm, value_str[start..end]);
    try vm.pushTempDyn(&str.dyn);
    return str.dyn.elem();
}

fn parseBytesAsJsonElem(vm: *VM, bytes: []const u8) Error!?Elem {
    const json_parsed = std.json.parseFromSlice(
        std.json.Value,
        vm.allocator,
        bytes,
        .{ .parse_numbers = false },
    ) catch |e| switch (e) {
        error.OutOfMemory => |oom| return oom,
        else => return null,
    };
    defer json_parsed.deinit();

    const elem = try Elem.fromJson(json_parsed.value, vm);
    if (elem.isType(.Dyn)) try vm.pushTempDyn(elem.asDyn());

    return elem;
}

// Read a bound local and render it to a string, the way the solver
// toStrings every simplified template segment.
fn stringifyBoundLocal(vm: *VM, local_var: LocalVar) Error!Elem {
    const resolved = try resolveBoundLocal(vm, local_var);
    const str = try resolved.toString(vm);
    if (str.isType(.Dyn)) try vm.pushTempDyn(str.asDyn());
    return str;
}

fn keyMatched(vm: *VM, base: usize, sid: StringTable.Id) bool {
    return std.mem.indexOfScalar(StringTable.Id, vm.plan_matched_keys.items[base..], sid) != null;
}

fn markKeyMatched(vm: *VM, base: usize, sid: StringTable.Id) !void {
    if (keyMatched(vm, base, sid)) return;
    try vm.plan_matched_keys.append(vm.allocator, sid);
}

// The slot takes a second handle; the value also stays on the stack. The
// slot's previous handle dies: usually a placeholder var, but possibly a
// stale value left by an earlier failed match.
fn bindLocal(vm: *VM, local_var: LocalVar, value: Elem) void {
    const previous = vm.getLocal(local_var.idx);
    value.retain();
    vm.setLocal(local_var.idx, value);
    previous.release();
}

fn resolveRangeLimit(vm: *VM, plan: MatchPlan, limit: match_plan.RangePlan.Limit) Error!?Elem {
    return switch (limit) {
        .none => null,
        .const_elem => |idx| plan.elems[idx],
        .bound_local => |idx| try resolveBoundLocal(vm, plan.vars[idx]),
    };
}

// Read a statically-bound local for comparison, evaluating a zero-arity
// function value the way the tree path's attemptEval does.
fn resolveBoundLocal(vm: *VM, local_var: LocalVar) Error!Elem {
    var pattern_value = vm.getLocal(local_var.idx);

    if (pattern_value.isDynType(.Function)) {
        const function = pattern_value.asDyn().asFunction();
        // Must be zero-arity, since it was not called with args.
        if (function.arity != 0) return error.RuntimeError;
        pattern_value = try executeFunctionOnVM(vm, pattern_value);
        // Root the result: it may be held across allocations (a merge's
        // resolved-part list, rest materialization) with no other handle.
        if (pattern_value.isType(.Dyn)) try vm.pushTempDyn(pattern_value.asDyn());
    }

    return pattern_value;
}

// Evaluate a zero-arity function bound to a pattern local. Plans never run
// under the debug print modes (those compile the tree path), so this is
// PatternSolver.executeFunctionOnVM minus the print hooks.
fn executeFunctionOnVM(vm: *VM, function: Elem) Error!Elem {
    try vm.push(function);
    try vm.callFunction(function, 0, false);
    try vm.runFunction();
    return vm.pop();
}

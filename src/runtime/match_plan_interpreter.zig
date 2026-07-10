const std = @import("std");
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const match_plan = @import("match_plan.zig");
const MatchPlan = match_plan.MatchPlan;
const LocalVar = match_plan.LocalVar;
const ResolvedPart = match_plan.ResolvedPart;
const StringTable = @import("string_table.zig").RuntimeStringTable;
const explain = @import("explain.zig");
const parsing = @import("../parsing.zig");
const isValidNumberString = parsing.isValidNumberString;
const unicode = std.unicode;

pub const Error = error{
    RuntimeError,
    OutOfMemory,
} || VM.Error;

// The debug print modes (PRINT_VM / PRINT_DESTRUCTURE) trace each match step
// as an indented `value -> pattern` line, mirroring PatternSolver.printSteps.
// The flag is config-derived and constant for the run.
inline fn printSteps(vm: *VM) bool {
    return vm.config.printVM or vm.config.printDestructure;
}

// --explain records a step/bind event per match node instead of printing.
inline fn tracing(vm: *VM) bool {
    return vm.config.explain;
}

fn printIndentation(vm: *VM) Error!void {
    for (0..vm.plan_debug_depth) |_| {
        try vm.writers.debug.print("    ", .{});
    }
}

// `value -> pattern`, mirroring PatternSolver.printDestructure. noinline so
// the never-taken print branch costs the interpreter only a test.
noinline fn emitStep(vm: *VM, value: Elem, plan: MatchPlan, idx: u32) Error!void {
    try printIndentation(vm);
    try value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(" -> ", .{});
    _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, idx);
    try vm.writers.debug.print("\n", .{});
}

// `value -> value`, mirroring PatternSolver.printDestructureEquality: the
// checkEquality line printed after a leaf compare resolves its value.
noinline fn emitEquality(vm: *VM, value: Elem, pattern_value: Elem) Error!void {
    try printIndentation(vm);
    try value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(" -> ", .{});
    try pattern_value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print("\n", .{});
}

// The pattern rendered in the `Eval Pattern Function:` banner: either a plan
// subtree (const_fn / call node) or a bare bound local (mirrors `.Local`).
const EvalBanner = union(enum) {
    subtree: struct { plan: MatchPlan, idx: u32 },
    local: LocalVar,
};

noinline fn emitEvalBanner(vm: *VM, banner: EvalBanner) Error!void {
    try vm.writers.debug.print("\nEval Pattern Function: ", .{});
    switch (banner) {
        .subtree => |s| _ = try s.plan.printPatternSubtree(vm.*, vm.writers.debug, s.idx),
        .local => |lv| try vm.writers.debug.print("{s}", .{vm.strings.get(lv.sid)}),
    }
    try vm.writers.debug.print("\n", .{});
}

// A byte-slice comparison printed as `"value" -> "pattern"` with its own
// depth bump, mirroring PatternSolver.matchStringBytes.
fn matchStringBytesStep(vm: *VM, value_bytes: []const u8, pattern_bytes: []const u8) Error!bool {
    vm.plan_debug_depth +|= 1;
    defer vm.plan_debug_depth -|= 1;
    if (printSteps(vm)) try emitStringBytes(vm, value_bytes, pattern_bytes);
    return std.mem.eql(u8, value_bytes, pattern_bytes);
}

noinline fn emitStringBytes(vm: *VM, value_bytes: []const u8, pattern_bytes: []const u8) Error!void {
    try printIndentation(vm);
    try vm.writers.debug.print("\"{s}\" -> \"{s}\"\n", .{ value_bytes, pattern_bytes });
}

// The plain-object match banners, mirroring matchObject's inline prints. The
// merge/repeat object pair path (matchObjectPair) prints no banner.
noinline fn emitObjectBoundKey(vm: *VM, plan: MatchPlan, key: Elem, member: Elem, value_idx: u32) Error!void {
    try printIndentation(vm);
    try vm.writers.debug.print("{{", .{});
    try key.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(": ", .{});
    try member.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print("}} -> {{", .{});
    try key.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(": ", .{});
    _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, value_idx);
    try vm.writers.debug.print("}}\n", .{});
}

noinline fn emitObjectSearchAttempt(vm: *VM, plan: MatchPlan, obj_key: Elem, obj_value: Elem, key_idx: u32, value_idx: u32) Error!void {
    try printIndentation(vm);
    try vm.writers.debug.print("{{", .{});
    try obj_key.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(": ", .{});
    try obj_value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print("}} -> {{", .{});
    _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, key_idx);
    try vm.writers.debug.print(": ", .{});
    _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, value_idx);
    try vm.writers.debug.print("}}\n", .{});
}

// Interpreter for compiled match plans. Runs directly against the VM with no
// PatternSolver bookkeeping: bind-vs-equality is decided statically, so there
// is no runtime boundness probing, and a failed match leaves its binds in
// place. Binding analysis guarantees stale slots are never read, and a bind
// releases whatever the slot held (a placeholder or a stale value) as it
// overwrites it.
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

    // Depth is reset per destructure and restored on exit: a pattern
    // function re-enters the VM and can nest another match.
    const prev_depth = vm.plan_debug_depth;
    vm.plan_debug_depth = 0;
    defer vm.plan_debug_depth = prev_depth;

    if (printSteps(vm)) try vm.writers.debug.print("\nDestructure:\n", .{});

    const success = try matchNode(vm, value, plan, 0, discardable_root);

    if (printSteps(vm)) {
        if (success) {
            try vm.writers.debug.print("Destructure Success: ", .{});
        } else {
            try vm.writers.debug.print("Destructure Failure: ", .{});
        }
        try value.print(vm.*, vm.writers.debug);
        try vm.writers.debug.print(" -> ", .{});
        _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, 0);
        try vm.writers.debug.print("\n", .{});
    }

    return success;
}

// discardable is the root value dyn when the VM discards the match result;
// it is only consulted by an object merge matching that dyn directly, so
// recursive calls (which match sub-values) pass null.
//
// One match step per recursion mirrors PatternSolver.matchPattern: bump the
// depth, print the `value -> pattern` line, then dispatch on the node tag.
fn matchNode(vm: *VM, value: Elem, plan: MatchPlan, idx: u32, discardable: ?*Elem.DynElem) Error!bool {
    vm.plan_debug_depth +|= 1;
    defer vm.plan_debug_depth -|= 1;

    if (printSteps(vm)) try emitStep(vm, value, plan, idx);

    if (tracing(vm)) return matchNodeTraced(vm, value, plan, idx, discardable);

    return dispatchNode(vm, value, plan, idx, discardable);
}

// Emit the step before dispatch so nested steps order after it, then patch
// the result in. Nested matching may grow the event list, so re-index at
// patch time rather than holding a pointer. Mirrors matchPatternTraced.
noinline fn matchNodeTraced(vm: *VM, value: Elem, plan: MatchPlan, idx: u32, discardable: ?*Elem.DynElem) Error!bool {
    try vm.explain_events.append(vm.allocator, .{ .step = .{
        .depth = vm.plan_debug_depth,
        .value = explain.snapshot(vm, value),
        .pattern = explain.snapshot(vm, match_plan.SubtreePrintable{ .plan = &plan, .idx = idx }),
        .matched = false,
    } });
    const step_idx = vm.explain_events.items.len - 1;

    const result = try dispatchNode(vm, value, plan, idx, discardable);

    vm.explain_events.items[step_idx].step.matched = result;

    return result;
}

fn dispatchNode(vm: *VM, value: Elem, plan: MatchPlan, idx: u32, discardable: ?*Elem.DynElem) Error!bool {
    const node = plan.nodes[idx];

    switch (node.tag) {
        .placeholder => return true,
        .equality => {
            const pattern_value = plan.elems[node.payload];
            if (printSteps(vm)) try emitEquality(vm, value, pattern_value);
            return value.isEql(pattern_value, vm.*);
        },
        .const_fn => {
            const pattern_value = try evalConstFn(vm, plan, idx);
            if (printSteps(vm)) try emitEquality(vm, value, pattern_value);
            return value.isEql(pattern_value, vm.*);
        },
        .call => {
            const pattern_value = try evalCall(vm, plan, idx);
            if (printSteps(vm)) try emitEquality(vm, value, pattern_value);
            return value.isEql(pattern_value, vm.*);
        },
        .bind => {
            try bindLocal(vm, plan.vars[node.payload], value);
            return true;
        },
        .bound_eq => {
            const pattern_value = try resolveBoundLocal(vm, plan.vars[node.payload]);
            if (printSteps(vm)) try emitEquality(vm, value, pattern_value);
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
            return matchObjectNode(vm, plan, idx, value_object);
        },
        // Only reachable through their object node.
        .const_key, .eval_key, .pattern_key => unreachable,
        .range => {
            const range = plan.ranges[node.payload];
            // Evaluable limits are child subtrees in lower-before-upper
            // preorder; track the child index across both.
            var child = idx + 1;
            switch (range.lower) {
                .none => {},
                .bind_local => |vi| try bindLocal(vm, plan.vars[vi], value),
                .eval => {
                    const limit = (try evalNode(vm, plan, child)) orelse return error.RuntimeError;
                    child += plan.nodes[child].subtree_len;
                    if (!(try limit.isLessThanOrEqualInRangePattern(value, vm.*))) return false;
                },
                .const_elem, .bound_local => {
                    const limit = (try resolveRangeLimit(vm, plan, range.lower)).?;
                    if (!(try limit.isLessThanOrEqualInRangePattern(value, vm.*))) return false;
                },
            }
            switch (range.upper) {
                .none => {},
                .bind_local => |vi| try bindLocal(vm, plan.vars[vi], value),
                .eval => {
                    const limit = (try evalNode(vm, plan, child)) orelse return error.RuntimeError;
                    child += plan.nodes[child].subtree_len;
                    if (!(try value.isLessThanOrEqualInRangePattern(limit, vm.*))) return false;
                },
                .const_elem, .bound_local => {
                    const limit = (try resolveRangeLimit(vm, plan, range.upper)).?;
                    if (!(try value.isLessThanOrEqualInRangePattern(limit, vm.*))) return false;
                },
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
                    .const_fn => .{ .value = try stringifyElem(vm, try evalConstFn(vm, plan, child)) },
                    .call => .{ .value = try stringifyElem(vm, try evalCall(vm, plan, child)) },
                    // Lowering only accepts eval-class negated segments,
                    // so the evaluation cannot come up empty.
                    .negated => .{ .value = try stringifyElem(vm, (try evalNode(vm, plan, child)).?) },
                    .range => .{ .subtree = child },
                    // Lowering rejects other non-solvable segment shapes.
                    else => unreachable,
                };
                try vm.plan_merge_parts.append(vm.allocator, part);
                child += child_node.subtree_len;
            }

            return matchStringTemplate(vm, plan, value, parts_base, template_plan.part_count);
        },
        .repeat => return matchRepeat(vm, plan, value, idx),
        .negated => {
            // An evaluable inner (call, const_fn) negates its per-match
            // result, erroring on a non-number the way negating a
            // non-number literal errors at compile time. A structural
            // inner (a range) matches the negated value instead, so
            // -(a..b) behaves as -b..-a; a non-number value fails the
            // match, mirroring the bind and placeholder checks.
            if (try evalNode(vm, plan, idx + 1)) |pattern_value| {
                const negated = try negateEvaluated(pattern_value, node.payload);
                if (printSteps(vm)) try emitEquality(vm, value, negated);
                return value.isEql(negated, vm.*);
            }
            if (node.payload != 0 and !value.isNumber()) return false;
            const inner_value = if (node.payload % 2 == 1)
                value.negateNumber() catch return error.RuntimeError
            else
                value;
            return matchNode(vm, inner_value, plan, idx + 1, null);
        },
    }
}

// Negate a pattern-side value resolved at match time. Negation of a
// non-number is an error, mirroring the compile-time NegatedNonNumber;
// even negation counts cancel but still require a number.
fn negateEvaluated(pattern_value: Elem, negation_count: u32) Error!Elem {
    if (negation_count == 0) return pattern_value;
    if (!pattern_value.isNumber()) return error.RuntimeError;
    if (negation_count % 2 == 0) return pattern_value;
    return pattern_value.negateNumber() catch error.RuntimeError;
}

// Port of the solver's matchRepeat. The three-way dispatch — pattern
// evaluates, count evaluates, neither — mirrors the solver's attemptEval
// probing: a statically-eval operand that comes up empty at match time (a
// nested repeat or merge failing to fold) falls through to the next branch
// the same way attemptEval returning null does.
fn matchRepeat(vm: *VM, plan: MatchPlan, value: Elem, idx: u32) Error!bool {
    const repeat_plan = plan.repeats[plan.nodes[idx].payload];
    const pattern_idx = idx + 1;
    const count_idx = pattern_idx + plan.nodes[pattern_idx].subtree_len;
    // Iterations after the first match the rebound variant: their binds
    // were bound by the first iteration, so they compare instead.
    const later_pattern_idx = if (repeat_plan.has_rebound_pattern)
        count_idx + plan.nodes[count_idx].subtree_len
    else
        pattern_idx;

    if (try resolveRepeatOperand(vm, plan, repeat_plan.pattern, pattern_idx)) |pattern_value| {
        // The pattern is a value: derive the count from the value.

        if (try pattern_value.stringBytes(vm)) |pattern_str| {
            const value_str = (try value.stringBytes(vm)) orelse return false;

            // Special case: empty string (identity element)
            if (pattern_str.len == 0) {
                if (value_str.len == 0) {
                    // "" * N = "" for any N >= 1
                    // Choose N = 1 as the canonical answer
                    return matchNode(vm, Elem.numberFloat(1), plan, count_idx, null);
                } else {
                    // Non-empty value can't be made from repeating empty pattern
                    return false;
                }
            }

            // Check if value length is divisible by pattern length
            if (value_str.len % pattern_str.len != 0) return false;

            const count = value_str.len / pattern_str.len;

            // Verify value is pattern repeated count times
            var i: usize = 0;
            while (i < count) : (i += 1) {
                const start = i * pattern_str.len;
                const end = start + pattern_str.len;
                if (!std.mem.eql(u8, value_str[start..end], pattern_str)) {
                    return false;
                }
            }

            const count_elem = Elem.numberFloat(@as(f64, @floatFromInt(count)));
            return matchNode(vm, count_elem, plan, count_idx, null);
        }

        if (pattern_value.isDynType(.Array)) {
            if (!value.isDynType(.Array)) return false;

            const pattern_array = pattern_value.asDyn().asArray();
            const value_array = value.asDyn().asArray();

            const pattern_len = pattern_array.len();
            if (pattern_len == 0) return false;
            if (value_array.len() % pattern_len != 0) return false;

            const count = value_array.len() / pattern_len;

            // Verify value is pattern array repeated count times
            var i: usize = 0;
            while (i < count) : (i += 1) {
                const start = i * pattern_len;
                for (0..pattern_len) |j| {
                    const value_elem = value_array.elems.items[start + j];
                    const pattern_elem_at_j = pattern_array.elems.items[j];
                    if (printSteps(vm)) try emitEquality(vm, value_elem, pattern_elem_at_j);
                    if (!value_elem.isEql(pattern_elem_at_j, vm.*)) {
                        return false;
                    }
                }
            }

            const count_elem = Elem.numberFloat(@as(f64, @floatFromInt(count)));
            return matchNode(vm, count_elem, plan, count_idx, null);
        }

        // Object repetition: merging an object with itself is the
        // identity, so like booleans the canonical count is 1
        if (pattern_value.isDynType(.Object)) {
            if (!value.isDynType(.Object)) return false;

            const pattern_members = pattern_value.asDyn().asObject().members.count();
            const value_members = value.asDyn().asObject().members.count();

            if (value_members == 0) {
                // {} is P * 0 for non-empty P, and {} * N for any N >= 1
                const count_elem = Elem.numberFloat(if (pattern_members == 0) 1 else 0);
                return matchNode(vm, count_elem, plan, count_idx, null);
            }

            if (printSteps(vm)) try emitEquality(vm, value, pattern_value);
            if (!value.isEql(pattern_value, vm.*)) return false;
            return matchNode(vm, Elem.numberFloat(1), plan, count_idx, null);
        }

        // Number repetition (multiplication)
        if (pattern_value.isNumber() and value.isNumber()) {
            const pattern_float = numberAsFloat(pattern_value, vm);
            const value_float = numberAsFloat(value, vm);

            // Special case: zero (identity element)
            if (pattern_float == 0) {
                if (value_float == 0) {
                    // 0 * N = 0 for any N >= 1
                    // Choose N = 1 as the canonical answer
                    return matchNode(vm, Elem.numberFloat(1), plan, count_idx, null);
                } else {
                    // Non-zero value can't be made from repeating zero
                    return false;
                }
            }

            const count_elem = Elem.numberFloat(value_float / pattern_float);
            return matchNode(vm, count_elem, plan, count_idx, null);
        }

        // Boolean repetition (OR)
        if (pattern_value.isType(.Const)) {
            const pattern_const = pattern_value.asConst();
            if (pattern_const == .True or pattern_const == .False) {
                if (!value.isType(.Const)) return false;
                const value_const = value.asConst();
                if (value_const != .True and value_const != .False) return false;

                if (pattern_value.isEql(value, vm.*)) {
                    // true * N = true and false * N = false for any N >= 1
                    // Choose N = 1 as the canonical answer
                    return matchNode(vm, Elem.numberFloat(1), plan, count_idx, null);
                } else {
                    // false can't produce true, and true can't produce false
                    return false;
                }
            }
        }

        // Other types not supported
        return false;
    } else if (try resolveRepeatOperand(vm, plan, repeat_plan.count, count_idx)) |count_elem| {
        // The count is a value: match by iterating.
        if (!count_elem.isNumber()) return error.RuntimeError;

        const count_float = numberAsFloat(count_elem, vm);

        // Count must be a non-negative integer
        if (count_float < 0 or count_float != @floor(count_float)) return false;
        const count = @as(usize, @intFromFloat(count_float));

        if (try value.stringBytes(vm)) |value_str| {
            // Special case: count is 0
            if (count == 0) {
                // Pattern * 0 = "" for any pattern (empty string identity)
                return value_str.len == 0;
            }

            // Range patterns match codepoint-by-codepoint
            if (plan.nodes[pattern_idx].tag == .range) {
                const codepoint_count = (try countRangeCodepoints(vm, plan, pattern_idx, value_str)) orelse
                    return false;
                return codepoint_count == count;
            }

            // For other patterns (like unbound variables), compute repeated
            // chunks. Check if value length is divisible by count.
            if (value_str.len % count != 0) return false;

            const chunk_len = value_str.len / count;

            // Verify all chunks are equal
            var i: usize = 1;
            while (i < count) : (i += 1) {
                const start = i * chunk_len;
                const end = start + chunk_len;
                if (!std.mem.eql(u8, value_str[0..chunk_len], value_str[start..end])) {
                    return false;
                }
            }

            // Match the first chunk against the pattern to bind variables
            const chunk_elem = try substringElem(vm, value, value_str, 0, chunk_len);
            return matchNode(vm, chunk_elem, plan, pattern_idx, null);
        }

        if (value.isDynType(.Array)) {
            const value_array = value.asDyn().asArray();

            // Value must have exactly count elements
            if (value_array.len() != count) return false;

            // Match each element against the pattern
            for (value_array.elems.items, 0..) |elem, i| {
                const sub = if (i == 0) pattern_idx else later_pattern_idx;
                if (!(try matchNode(vm, elem, plan, sub, null))) return false;
            }
            return true;
        }

        // Object pattern matching: the members partition into `count`
        // disjoint groups, each matching the pattern
        if (value.isDynType(.Object)) {
            if (plan.nodes[pattern_idx].tag != .object) return false;

            const pair_count = plan.nodes[pattern_idx].payload;
            const value_object = value.asDyn().asObject();
            const member_count = value_object.members.count();

            if (count == 0 or pair_count == 0) {
                return member_count == 0;
            }
            if (member_count != count * pair_count) return false;

            const matched_base = vm.plan_matched_keys.items.len;
            defer vm.plan_matched_keys.shrinkRetainingCapacity(matched_base);

            return matchObjectRepeat(vm, plan, pattern_idx, later_pattern_idx, value_object, count, matched_base);
        }

        // Number pattern matching (pattern * count = value)
        if (value.isNumber()) {
            if (count_float == 0) return false;

            const value_float = numberAsFloat(value, vm);
            const computed_pattern = Elem.numberFloat(value_float / count_float);
            return matchNode(vm, computed_pattern, plan, pattern_idx, null);
        }

        // Other value types not supported
        return false;
    } else {
        // Neither pattern nor count evaluates.
        // Special case: Range pattern with unbound count
        if (plan.nodes[pattern_idx].tag == .range) {
            // This only works for string values
            const value_str = (try value.stringBytes(vm)) orelse return false;

            const codepoint_count = (try countRangeCodepoints(vm, plan, pattern_idx, value_str)) orelse
                return false;

            const count_elem = Elem.numberFloat(@as(f64, @floatFromInt(codepoint_count)));
            return matchNode(vm, count_elem, plan, count_idx, null);
        }

        // Object pattern with unbound count: the count is however many
        // disjoint groups of members the pattern claims
        if (plan.nodes[pattern_idx].tag == .object) {
            if (!value.isDynType(.Object)) return false;

            const pair_count = plan.nodes[pattern_idx].payload;
            const value_object = value.asDyn().asObject();
            const member_count = value_object.members.count();

            if (pair_count == 0) {
                // {} * N = {} for any N >= 1; choose N = 1 as canonical
                if (member_count != 0) return false;
                return matchNode(vm, Elem.numberFloat(1), plan, count_idx, null);
            }
            if (member_count % pair_count != 0) return false;

            const count = member_count / pair_count;

            const matched_base = vm.plan_matched_keys.items.len;
            defer vm.plan_matched_keys.shrinkRetainingCapacity(matched_base);

            if (!(try matchObjectRepeat(vm, plan, pattern_idx, later_pattern_idx, value_object, count, matched_base))) {
                return false;
            }

            const count_elem = Elem.numberFloat(@as(f64, @floatFromInt(count)));
            return matchNode(vm, count_elem, plan, count_idx, null);
        }

        // Array with a fixed-length pattern but unbound elements and count
        if (try fixedArrayLength(vm, plan, pattern_idx)) |pattern_len| {
            if (!value.isDynType(.Array)) return false;

            const value_array = value.asDyn().asArray();
            if (pattern_len == 0) return false;
            if (value_array.len() % pattern_len != 0) return false;

            const count = value_array.len() / pattern_len;

            // Match each chunk against the pattern
            var i: usize = 0;
            while (i < count) : (i += 1) {
                const start = i * pattern_len;
                const end = start + pattern_len;

                const chunk_array = try Elem.DynElem.Array.create(vm, pattern_len);
                try vm.pushTempDyn(&chunk_array.dyn);
                for (value_array.elems.items[start..end]) |chunk_item| chunk_item.retain();
                try chunk_array.elems.appendSlice(vm.gc.allocator(), value_array.elems.items[start..end]);

                const sub = if (i == 0) pattern_idx else later_pattern_idx;
                if (!(try matchNode(vm, chunk_array.dyn.elem(), plan, sub, null))) {
                    return false;
                }
            }

            // Bind the count
            const count_elem = Elem.numberFloat(@as(f64, @floatFromInt(count)));
            return matchNode(vm, count_elem, plan, count_idx, null);
        } else {
            return error.RuntimeError;
        }
    }
}

fn resolveRepeatOperand(
    vm: *VM,
    plan: MatchPlan,
    operand: match_plan.RepeatPlan.Operand,
    subtree_idx: u32,
) Error!?Elem {
    return switch (operand) {
        .constant => |elem_idx| plan.elems[elem_idx],
        .eval => try evalNode(vm, plan, subtree_idx),
        .subtree => null,
    };
}

// Evaluate a plan subtree to a value, mirroring the solver's attemptEval.
// Null means the subtree does not evaluate (or a merge or repeat of values
// fails to fold) and must be matched structurally instead.
fn evalNode(vm: *VM, plan: MatchPlan, idx: u32) Error!?Elem {
    const node = plan.nodes[idx];
    switch (node.tag) {
        .equality => return plan.elems[node.payload],
        .bound_eq => return try resolveBoundLocal(vm, plan.vars[node.payload]),
        .const_fn => return try evalConstFn(vm, plan, idx),
        .call => return try evalCall(vm, plan, idx),
        .bind, .placeholder, .object, .range, .str_template => return null,
        .array => {
            // Try to evaluate all elements first, the way attemptEval does.
            const elems = try vm.allocator.alloc(Elem, node.payload);
            defer vm.allocator.free(elems);

            var child = idx + 1;
            for (elems) |*elem| {
                elem.* = (try evalNode(vm, plan, child)) orelse return null;
                child += plan.nodes[child].subtree_len;
            }

            const dyn_array = try Elem.DynElem.Array.create(vm, node.payload);
            try vm.pushTempDyn(&dyn_array.dyn);
            for (elems) |elem| {
                try dyn_array.append(vm, elem);
            }
            return dyn_array.dyn.elem();
        },
        .merge => {
            var result: ?Elem = null;
            var child = idx + 1;
            for (0..plan.merges[node.payload].part_count) |_| {
                const part_value = (try evalNode(vm, plan, child)) orelse return null;
                if (result) |current| {
                    result = (try current.merge(part_value, vm)) orelse return null;
                    // Root the intermediate across the next part's
                    // evaluation, which may allocate.
                    if (result.?.isType(.Dyn)) try vm.pushTempDyn(result.?.asDyn());
                } else {
                    result = part_value;
                }
                child += plan.nodes[child].subtree_len;
            }
            return result;
        },
        .repeat => {
            const repeat_plan = plan.repeats[node.payload];
            const pattern_idx = idx + 1;
            const count_idx = pattern_idx + plan.nodes[pattern_idx].subtree_len;
            const pattern_value = (try resolveRepeatOperand(vm, plan, repeat_plan.pattern, pattern_idx)) orelse
                return null;
            const count_value = (try resolveRepeatOperand(vm, plan, repeat_plan.count, count_idx)) orelse
                return null;
            const result = try Elem.repeat(pattern_value, count_value, vm);
            if (result) |elem| {
                if (elem.isType(.Dyn)) try vm.pushTempDyn(elem.asDyn());
            }
            return result;
        },
        .negated => {
            const inner = (try evalNode(vm, plan, idx + 1)) orelse return null;
            return try negateEvaluated(inner, node.payload);
        },
        .const_key, .eval_key, .pattern_key => unreachable,
    }
}

// The fixed element count of an array-shaped repeat pattern, mirroring the
// solver's getFixedArrayLength: an array subtree has its own length, and a
// merge has a fixed length when every part is an array value or subtree.
fn fixedArrayLength(vm: *VM, plan: MatchPlan, idx: u32) Error!?usize {
    const node = plan.nodes[idx];
    switch (node.tag) {
        .array => return node.payload,
        .merge => {
            var total_length: usize = 0;
            var child = idx + 1;
            for (0..plan.merges[node.payload].part_count) |_| {
                if (try evalNode(vm, plan, child)) |elem| {
                    if (elem.isDynType(.Array)) {
                        total_length += elem.asDyn().asArray().len();
                    } else if (elem.isConst(.Null)) {
                        // Null has no length, skip it
                    } else {
                        // Part is not an array
                        return null;
                    }
                } else if (plan.nodes[child].tag == .array) {
                    total_length += plan.nodes[child].payload;
                } else {
                    // Part has unknown length
                    return null;
                }
                child += plan.nodes[child].subtree_len;
            }
            return total_length;
        },
        else => return null,
    }
}

// Scan a string codepoint by codepoint, validating each against a range
// node's bounds. Null means the string is not valid for the range; a count
// means every codepoint was in range. Mirrors the solver's range-repeat
// scanning branches.
fn countRangeCodepoints(vm: *VM, plan: MatchPlan, range_node_idx: u32, value_str: []const u8) Error!?usize {
    const range = plan.ranges[plan.nodes[range_node_idx].payload];

    const lower_codepoint = try rangeLimitCodepoint(vm, plan, range.lower);
    const upper_codepoint = try rangeLimitCodepoint(vm, plan, range.upper);

    var codepoint_count: usize = 0;
    var byte_index: usize = 0;
    while (byte_index < value_str.len) {
        const byte_len = unicode.utf8ByteSequenceLength(value_str[byte_index]) catch return null;
        if (byte_index + byte_len > value_str.len) return null;

        const codepoint = parsing.utf8Decode(value_str[byte_index .. byte_index + byte_len]) orelse return null;

        if (lower_codepoint) |lower| {
            if (codepoint < lower) return null;
        }
        if (upper_codepoint) |upper| {
            if (codepoint > upper) return null;
        }

        if (printSteps(vm)) try emitRangeCodepointStep(vm, plan, range_node_idx, value_str[byte_index .. byte_index + byte_len]);

        codepoint_count += 1;
        byte_index += byte_len;
    }

    return codepoint_count;
}

// One codepoint of a range-repeat scan printed as `"<char>" -> <range>`,
// mirroring the solver's per-codepoint step in its range-repeat branches.
noinline fn emitRangeCodepointStep(vm: *VM, plan: MatchPlan, range_node_idx: u32, char_bytes: []const u8) Error!void {
    vm.plan_debug_depth +|= 1;
    defer vm.plan_debug_depth -|= 1;
    try printIndentation(vm);
    try vm.writers.debug.print("\"", .{});
    try vm.writers.debug.writeAll(char_bytes);
    try vm.writers.debug.print("\" -> ", .{});
    _ = try plan.printPatternSubtree(vm.*, vm.writers.debug, range_node_idx);
    try vm.writers.debug.print("\n", .{});
}

fn rangeLimitCodepoint(vm: *VM, plan: MatchPlan, limit: match_plan.RangePlan.Limit) Error!?u21 {
    const limit_elem = (try resolveRangeLimit(vm, plan, limit)) orelse return null;
    if (try limit_elem.stringBytes(vm)) |bytes| {
        return parsing.utf8Decode(bytes);
    }
    // A non-string bound cannot limit codepoints
    return error.RuntimeError;
}

// Claim `count` repetitions of an object pattern from the value object's
// members, with exclusive claims: each repetition must claim members of its
// own. Repetitions after the first match the rebound variant, the way the
// solver's runtime boundness flip turns a searched key or bound value into
// an evaluated comparison on later repetitions (a rebound constant key
// always fails the exclusive claim; only placeholders match fresh members
// each time).
fn matchObjectRepeat(
    vm: *VM,
    plan: MatchPlan,
    pattern_idx: u32,
    later_pattern_idx: u32,
    value_object: *Elem.DynElem.Object,
    count: usize,
    matched_base: usize,
) Error!bool {
    for (0..count) |rep| {
        const object_idx = if (rep == 0) pattern_idx else later_pattern_idx;
        var pair = object_idx + 1;
        for (0..plan.nodes[object_idx].payload) |_| {
            if (!(try matchMergeObjectPair(vm, plan, pair, value_object, matched_base, .exclusive))) {
                return false;
            }
            pair += plan.nodes[pair].subtree_len;
        }
    }
    return true;
}

fn numberAsFloat(elem: Elem, vm: *VM) f64 {
    return if (elem.isFloat())
        elem.asFloat()
    else
        elem.asNumberString().toNumberFloat(vm.strings).asFloat();
}

// Null means the count is negative or not an integer, which fails the
// match; a non-number count is a runtime error.
fn repeatCount(vm: *VM, count_elem: Elem) Error!?usize {
    if (!count_elem.isNumber()) return error.RuntimeError;
    const count_float = numberAsFloat(count_elem, vm);
    if (count_float < 0 or count_float != @floor(count_float)) return null;
    return @intFromFloat(count_float);
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
            .const_fn => .{ .value = try evalConstFn(vm, plan, child) },
            .call => .{ .value = try evalCall(vm, plan, child) },
            // A negated call resolves to its negated result; a negated
            // range stays structural.
            .negated => if (try evalNode(vm, plan, child)) |part_value|
                ResolvedPart{ .value = part_value }
            else
                ResolvedPart{ .subtree = child },
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

// Match the pairs of a plain (non-merge) object node, mirroring
// matchObject: evaluated keys must be interned strings, and pattern keys
// search the unmatched members in order. Matched keys are only tracked
// when a pattern key will read them, keeping the all-constant-key path
// free of scratch bookkeeping (the marks are unobservable without a
// search).
fn matchObjectNode(
    vm: *VM,
    plan: MatchPlan,
    object_node_idx: u32,
    value_object: *Elem.DynElem.Object,
) Error!bool {
    // matchObject bumps depth for its inline banners, an extra level over the
    // object node's own match step.
    vm.plan_debug_depth +|= 1;
    defer vm.plan_debug_depth -|= 1;

    const pair_count = plan.nodes[object_node_idx].payload;

    var has_search_key = false;
    var scan = object_node_idx + 1;
    for (0..pair_count) |_| {
        if (plan.nodes[scan].tag == .pattern_key) {
            has_search_key = true;
            break;
        }
        scan += plan.nodes[scan].subtree_len;
    }

    const matched_base = vm.plan_matched_keys.items.len;
    defer vm.plan_matched_keys.shrinkRetainingCapacity(matched_base);
    const mark_base: ?usize = if (has_search_key) matched_base else null;

    var pair = object_node_idx + 1;
    for (0..pair_count) |_| {
        const pair_node = plan.nodes[pair];
        const matched = switch (pair_node.tag) {
            .const_key => try matchResolvedKeyPair(
                vm,
                plan,
                plan.sids[pair_node.payload],
                pair + 1,
                value_object,
                mark_base,
                .shared,
                true,
            ),
            .eval_key => blk: {
                const key_value = (try evalNode(vm, plan, pair + 1)).?;
                const value_idx = pair + 1 + plan.nodes[pair + 1].subtree_len;
                break :blk try matchResolvedKeyPair(
                    vm,
                    plan,
                    try plainObjectKeySid(key_value),
                    value_idx,
                    value_object,
                    mark_base,
                    .shared,
                    true,
                );
            },
            .pattern_key => blk: {
                const key_idx = pair + 1;
                const value_idx = key_idx + plan.nodes[key_idx].subtree_len;
                if (try evalNode(vm, plan, key_idx)) |key_value| {
                    break :blk try matchResolvedKeyPair(
                        vm,
                        plan,
                        try plainObjectKeySid(key_value),
                        value_idx,
                        value_object,
                        mark_base,
                        .shared,
                        true,
                    );
                }
                break :blk try searchObjectPair(vm, plan, key_idx, value_idx, value_object, matched_base, true);
            },
            else => unreachable,
        };
        if (!matched) return false;
        pair += pair_node.subtree_len;
    }
    return true;
}

// matchObject only accepts interned strings as evaluated keys; anything
// else — including dynamic strings — is a runtime error. Merge and repeat
// pairs are more lenient (getOrPutSid).
fn plainObjectKeySid(key_value: Elem) Error!StringTable.Id {
    if (!key_value.isType(.String)) return error.RuntimeError;
    return key_value.asString();
}

// Whether a resolved key may re-match a member an earlier pair already
// matched. Pairs of a plain object or a single merge share members; each
// repetition of a repeat pattern must claim members of its own.
const KeyClaim = enum { shared, exclusive };

// Match a pair whose key resolved to a sid: probe the member and match the
// value subtree. A null matched_base skips the bookkeeping (a plain object
// with no pattern keys).
fn matchResolvedKeyPair(
    vm: *VM,
    plan: MatchPlan,
    sid: StringTable.Id,
    value_idx: u32,
    value_object: *Elem.DynElem.Object,
    matched_base: ?usize,
    claim: KeyClaim,
    print_banner: bool,
) Error!bool {
    if (claim == .exclusive and keyMatched(vm, matched_base.?, sid)) return false;
    const member = value_object.members.get(sid) orelse return false;
    // The plain-object bound-key banner prints only once the member is found,
    // mirroring matchObject.
    if (print_banner and printSteps(vm)) try emitObjectBoundKey(vm, plan, Elem.string(sid), member, value_idx);
    if (!(try matchNode(vm, member, plan, value_idx, null))) return false;
    if (matched_base) |base| try markKeyMatched(vm, base, sid);
    return true;
}

// One pair of an object merge part or object repeat, mirroring
// matchObjectPair: evaluated keys intern any stringable (getOrPutSid),
// pattern keys that fail to evaluate fall back to the linear search.
fn matchMergeObjectPair(
    vm: *VM,
    plan: MatchPlan,
    pair_idx: u32,
    value_object: *Elem.DynElem.Object,
    matched_base: usize,
    claim: KeyClaim,
) Error!bool {
    const pair_node = plan.nodes[pair_idx];
    switch (pair_node.tag) {
        .const_key => return matchResolvedKeyPair(
            vm,
            plan,
            plan.sids[pair_node.payload],
            pair_idx + 1,
            value_object,
            matched_base,
            claim,
            false,
        ),
        .eval_key => {
            const key_value = (try evalNode(vm, plan, pair_idx + 1)).?;
            const sid = (try key_value.getOrPutSid(vm)) orelse return error.RuntimeError;
            const value_idx = pair_idx + 1 + plan.nodes[pair_idx + 1].subtree_len;
            return matchResolvedKeyPair(vm, plan, sid, value_idx, value_object, matched_base, claim, false);
        },
        .pattern_key => {
            const key_idx = pair_idx + 1;
            const value_idx = key_idx + plan.nodes[key_idx].subtree_len;
            if (try evalNode(vm, plan, key_idx)) |key_value| {
                const sid = (try key_value.getOrPutSid(vm)) orelse return error.RuntimeError;
                return matchResolvedKeyPair(vm, plan, sid, value_idx, value_object, matched_base, claim, false);
            }
            return searchObjectPair(vm, plan, key_idx, value_idx, value_object, matched_base, false);
        },
        else => unreachable,
    }
}

// Search the value object's members in order for one that matches the key
// pattern then the value pattern, skipping members already claimed. No
// reset between attempts, unlike the solver: every retry re-runs both
// subtrees from the top and bind nodes overwrite (see the file header).
fn searchObjectPair(
    vm: *VM,
    plan: MatchPlan,
    key_idx: u32,
    value_idx: u32,
    value_object: *Elem.DynElem.Object,
    matched_base: usize,
    print_banner: bool,
) Error!bool {
    var iterator = value_object.members.iterator();
    while (iterator.next()) |entry| {
        const obj_key_sid = entry.key_ptr.*;
        if (keyMatched(vm, matched_base, obj_key_sid)) continue;
        const key_elem = Elem.string(obj_key_sid);
        // The plain-object search banner prints per candidate member,
        // mirroring matchObject's search loop.
        if (print_banner and printSteps(vm)) try emitObjectSearchAttempt(vm, plan, key_elem, entry.value_ptr.*, key_idx, value_idx);
        if (try matchNode(vm, key_elem, plan, key_idx, null)) {
            if (try matchNode(vm, entry.value_ptr.*, plan, value_idx, null)) {
                try markKeyMatched(vm, matched_base, obj_key_sid);
                return true;
            }
        }
    }
    return false;
}

// Match the pairs of an object node as a structural part of an object
// merge: parts of a single merge share members, and each matched key is
// recorded for the merge's rest.
fn matchObjectPairs(
    vm: *VM,
    plan: MatchPlan,
    object_node_idx: u32,
    value_object: *Elem.DynElem.Object,
    matched_base: usize,
) Error!bool {
    var pair = object_node_idx + 1;
    for (0..plan.nodes[object_node_idx].payload) |_| {
        if (!(try matchMergeObjectPair(vm, plan, pair, value_object, matched_base, .shared))) {
            return false;
        }
        pair += plan.nodes[pair].subtree_len;
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
        .value => |elem| elemMergeType(elem),
        .subtree => |idx| switch (plan.nodes[idx].tag) {
            .array => .array,
            .object => .object,
            .str_template => .string,
            // A bound_eq subtree is the solvable part: a local this merge
            // binds before its position. The solver's simplify sees it
            // unbound, so its type contribution is untyped.
            .bind, .bound_eq, .placeholder => .untyped,
            // A repeat contributes its pattern's type, mirroring
            // mergePatternType's recursion into the raw repeat pattern.
            .repeat => try repeatPatternType(plan, idx + 1),
            // A structural negated part contributes its inner's type
            // (evaluable inners were resolved to values), so a negated
            // bind or placeholder stays untyped and fails the match
            // rather than the merge's type resolution.
            .negated => try mergePartType(plan, .{ .subtree = idx + 1 }),
            // Ranges are not mergeable; mirrors mergePatternType.
            .range => error.RuntimeError,
            // Value parts (including calls, which always evaluate) were
            // resolved, nested merges were flattened at compile time, and
            // pair nodes only appear under an object.
            .equality, .const_fn, .call, .const_key, .eval_key, .pattern_key, .merge => unreachable,
        },
    };
}

fn elemMergeType(elem: Elem) MergeType {
    return switch (elem.getType()) {
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
    };
}

// The merge type a repeat merge part contributes is its pattern's type,
// mirroring the tree solver's mergePatternType recursion into the raw
// repeat pattern. Unlike a resolved merge part, the repeat's pattern may be
// a value folded at compile time (an equality/const_fn/call node), so type
// those from their elem the way the solver types the raw pattern.
fn repeatPatternType(plan: MatchPlan, pattern_idx: u32) Error!MergeType {
    const node = plan.nodes[pattern_idx];
    return switch (node.tag) {
        .equality => elemMergeType(plan.elems[node.payload]),
        // Constant functions and calls evaluate at match time; the solver
        // types Constant and FunctionCall patterns as untyped.
        .const_fn, .call, .bind, .bound_eq, .placeholder => .untyped,
        .array => .array,
        .object => .object,
        .str_template => .string,
        // A negated pattern contributes its inner's type; see
        // mergePartType.
        .negated => repeatPatternType(plan, pattern_idx + 1),
        .range => error.RuntimeError,
        .repeat => repeatPatternType(plan, pattern_idx + 1),
        .merge, .const_key, .eval_key, .pattern_key => unreachable,
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
        // materializing it. A negated `-_` (a .negated node) still needs
        // the materialized rest so the match applies its number check.
        if (printSteps(vm) or plan.nodes[sub].tag != .placeholder) {
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
                    const value_elem = value_array.elems.items[value_index.* + i];
                    if (printSteps(vm)) try emitEquality(vm, value_elem, expected_elem);
                    if (!value_elem.isEql(expected_elem, vm.*)) {
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
    if (printSteps(vm)) try emitEquality(vm, value, bound_truth);
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
        if (printSteps(vm)) try emitEquality(vm, value, bound_sum);
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
                            if (printSteps(vm)) try emitEquality(vm, member_value, pair.value_ptr.*);
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
                .repeat => {
                    // A bound-count object repeat is counted-structural:
                    // claim exactly that many disjoint groups here. An
                    // unbound count is the solvable rest, deferred to the
                    // unbound handling below where the count is solved from
                    // the leftover members.
                    const repeat_plan = plan.repeats[plan.nodes[part_idx].payload];
                    const pattern_idx = part_idx + 1;
                    const count_idx = pattern_idx + plan.nodes[pattern_idx].subtree_len;
                    std.debug.assert(plan.nodes[pattern_idx].tag == .object);
                    if (try resolveRepeatOperand(vm, plan, repeat_plan.count, count_idx)) |count_elem| {
                        const later_pattern_idx = if (repeat_plan.has_rebound_pattern)
                            count_idx + plan.nodes[count_idx].subtree_len
                        else
                            pattern_idx;
                        const repetitions = (try repeatCount(vm, count_elem)) orelse return false;
                        if (!(try matchObjectRepeat(vm, plan, pattern_idx, later_pattern_idx, value_object, repetitions, matched_base))) {
                            return false;
                        }
                    } else if (unbound_index == null) {
                        unbound_index = i;
                    } else {
                        // Object merge can only have one unbound part
                        return error.RuntimeError;
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
        // the rest object is never observed. A negated `-_` (a .negated
        // node) still needs the materialized rest for its number check.
        if (printSteps(vm) or sub_node.tag != .placeholder) {
            if (canBindRestInPlace(vm, value, sub_node, discardable)) {
                // Every part before the rest has matched and binding an
                // unbound var cannot fail, so the match is already a
                // success. Give up the matched members and bind the rest
                // var to the value object itself instead of copying the
                // remaining members into a fresh object.
                for (vm.plan_matched_keys.items[matched_base..]) |sid| {
                    const removed = value_object.members.fetchOrderedRemove(sid);
                    removed.?.value.release();
                }
                try bindLocal(vm, plan.vars[sub_node.payload], value);
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
    value: Elem,
    rest_node: match_plan.Node,
    discardable: ?*Elem.DynElem,
) bool {
    // The slow path materializes and matches the rest so the debug output
    // shows it, mirroring the solver.
    if (printSteps(vm)) return false;
    if (!vm.config.rc_fast_paths) return false;
    if (discardable == null or discardable.? != value.asDyn()) return false;
    if (!value.asDyn().isUnique()) return false;
    return rest_node.tag == .bind;
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
        // materializing it. A negated `-_` (a .negated node) still needs
        // the materialized rest so the match applies its number check.
        if (printSteps(vm) or plan.nodes[sub].tag != .placeholder) {
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

                if (!(try matchStringBytesStep(vm, value_str[value_index.*..end_index], part_str))) {
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

                if (!(try matchStringBytesStep(vm, value_str[value_index.*..end_index], part_str))) {
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
        // When the pattern is an unbound local default to string. Repeats
        // also cast to string, mirroring matchStringTemplate's .Repeat
        // case. Try to use a subset of an existing substring if possible.
        .bind, .bound_eq, .placeholder, .str_template, .repeat => {
            unbound_elem = try substringElem(vm, value, value_str, unbound_start, unbound_end);
        },
        // A negated pattern only matches numbers, so cast number-shaped
        // bytes, mirroring the number-merge cast.
        .negated => if (isValidNumberString(unbound_bytes)) {
            unbound_elem = try Elem.numberStringFromBytes(unbound_bytes, vm);
        },
        // Constants and calls evaluate to value segments, ranges are
        // fixed-length segments, and pair nodes only appear under an object.
        .equality, .const_fn, .call, .const_key, .eval_key, .pattern_key, .range => unreachable,
    }

    if (unbound_elem) |cast_elem| {
        if (merge_cast) |mc| {
            // The merge cast matches through matchMergeOfType directly, so
            // emit the merge segment's step here, mirroring the solver's
            // manual depth bump and printDestructure.
            vm.plan_debug_depth +|= 1;
            defer vm.plan_debug_depth -|= 1;
            if (printSteps(vm)) try emitStep(vm, cast_elem, plan, sub);
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
    return stringifyElem(vm, try resolveBoundLocal(vm, local_var));
}

fn stringifyElem(vm: *VM, elem: Elem) Error!Elem {
    const str = try elem.toString(vm);
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
fn bindLocal(vm: *VM, local_var: LocalVar, value: Elem) Error!void {
    const previous = vm.getLocal(local_var.idx);
    value.retain();
    vm.setLocal(local_var.idx, value);
    previous.release();
    if (tracing(vm)) try emitBind(vm, local_var, value);
}

// The solver emits its bind event from setLocal, which the bind tag and the
// rest binds all route through here; mirror that single site.
noinline fn emitBind(vm: *VM, local_var: LocalVar, value: Elem) Error!void {
    try vm.explain_events.append(vm.allocator, .{ .bind = .{
        .name = local_var.sid,
        .value = explain.snapshot(vm, value),
    } });
}

// Resolve a limit to a value for the codepoint-scan path, which only ever
// sees constant or bound-local character-range limits. A binding or
// evaluable limit cannot be resolved without the value or the range node's
// child index, neither available here.
fn resolveRangeLimit(vm: *VM, plan: MatchPlan, limit: match_plan.RangePlan.Limit) Error!?Elem {
    return switch (limit) {
        .none => null,
        .const_elem => |idx| plan.elems[idx],
        .bound_local => |idx| try resolveBoundLocal(vm, plan.vars[idx]),
        .bind_local, .eval => error.RuntimeError,
    };
}

// Read a statically-bound local for comparison, evaluating a zero-arity
// function value the way the tree path's attemptEval does. A negated
// occurrence wraps in a .negated node, which negates the value this
// returns.
fn resolveBoundLocal(vm: *VM, local_var: LocalVar) Error!Elem {
    var pattern_value = vm.getLocal(local_var.idx);

    if (pattern_value.isDynType(.Function)) {
        const function = pattern_value.asDyn().asFunction();
        // Must be zero-arity, since it was not called with args.
        if (function.arity != 0) return error.RuntimeError;
        pattern_value = try executeFunctionOnVM(vm, pattern_value, &.{}, .{ .local = local_var });
        // Root the result: it may be held across allocations (a merge's
        // resolved-part list, rest materialization) with no other handle.
        if (pattern_value.isType(.Dyn)) try vm.pushTempDyn(pattern_value.asDyn());
    }

    return pattern_value;
}

// Execute a zero-arity Function global, mirroring the solver's
// matchConstant/evalConstant. Lowering only emits const_fn for Function
// dyns with arity zero, so there is no runtime type or arity check.
fn evalConstFn(vm: *VM, plan: MatchPlan, node_idx: u32) Error!Elem {
    const function = plan.elems[plan.nodes[node_idx].payload];
    std.debug.assert(function.isDynType(.Function));
    const result = try executeFunctionOnVM(vm, function, &.{}, .{ .subtree = .{ .plan = plan, .idx = node_idx } });
    // Root the result; see resolveBoundLocal.
    if (result.isType(.Dyn)) try vm.pushTempDyn(result.asDyn());
    return result;
}

// Evaluate a call node, mirroring the solver's evalFunctionCall. Constant
// callees were checked at lowering; a local callee holds an arbitrary
// runtime value, so its function-ness and arity are checked here.
fn evalCall(vm: *VM, plan: MatchPlan, call_node_idx: u32) Error!Elem {
    const call = plan.calls[plan.nodes[call_node_idx].payload];

    const function = switch (call.callee) {
        .local => |var_idx| blk: {
            const local_value = vm.getLocal(plan.vars[var_idx].idx);
            // Attempt to call non-function value
            if (!local_value.isDynType(.Function)) return error.RuntimeError;
            if (local_value.asDyn().asFunction().arity != call.arg_count) {
                // Function called with wrong number of arguments
                return error.RuntimeError;
            }
            break :blk local_value;
        },
        .constant => |elem_idx| plan.elems[elem_idx],
    };

    const args = try vm.allocator.alloc(Elem, call.arg_count);
    defer vm.allocator.free(args);

    var child = call_node_idx + 1;
    for (args) |*arg| {
        const child_node = plan.nodes[child];
        arg.* = switch (child_node.tag) {
            .equality => plan.elems[child_node.payload],
            .bound_eq => try evalArgLocal(vm, plan.vars[child_node.payload]),
            .const_fn => try evalConstFn(vm, plan, child),
            // A negated zero-arity function argument; always evaluates.
            .negated => (try evalNode(vm, plan, child)).?,
            // Lowering rejects other argument shapes.
            else => unreachable,
        };
        child += child_node.subtree_len;
    }

    const result = try executeFunctionOnVM(vm, function, args, .{ .subtree = .{ .plan = plan, .idx = call_node_idx } });
    // Root the result; see resolveBoundLocal.
    if (result.isType(.Dyn)) try vm.pushTempDyn(result.asDyn());
    return result;
}

// Read a local passed as a call argument, mirroring the solver's evalLocal:
// unlike a bound_eq occurrence the slot has no static boundness — the call
// may run before the pattern occurrence that binds it, and an unbound slot
// is a runtime error rather than a failed match.
fn evalArgLocal(vm: *VM, local_var: LocalVar) Error!Elem {
    // Patterns don't support unbound var in function call
    if (vm.getLocal(local_var.idx).isType(.ValueVar)) return error.RuntimeError;
    return resolveBoundLocal(vm, local_var);
}

// Evaluate a function bound or called in a pattern. Plans never run under
// the debug print modes (those compile the tree path), so this is
// PatternSolver.executeFunctionOnVM minus the print hooks. The VM stack
// roots the function and args while it runs.
fn executeFunctionOnVM(vm: *VM, function: Elem, args: []const Elem, banner: EvalBanner) Error!Elem {
    if (printSteps(vm)) try emitEvalBanner(vm, banner);
    try vm.push(function);
    for (args) |arg| try vm.push(arg);
    try vm.callFunction(function, @intCast(args.len), false);
    try vm.runFunction();
    if (printSteps(vm)) try vm.writers.debug.print("\n", .{});
    return vm.pop();
}

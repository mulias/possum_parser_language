const std = @import("std");
const runtime = @import("../runtime.zig");
const match_plan = runtime.match_plan;
const liveness = @import("liveness.zig");
const name_resolver = @import("name_resolver.zig");
const NameResolver = name_resolver.NameResolver;
const Frontend = @import("../frontend.zig");
const Ast = Frontend.Ast;
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const Elem = runtime.Elem;
const Module = runtime.Module;
const RuntimeStrings = runtime.StringTable;
const VM = runtime.VM;

pub const Error = error{
    UnsupportedPattern,
    NegatedNonNumber,
} || std.mem.Allocator.Error || std.Io.Writer.Error;

// Everything the match-plan lowering needs from the compiler, passed in so
// this module stays independent of Compiler and avoids an import cycle.
pub const Lowerer = struct {
    vm: *VM,
    frontend: *Frontend,
    resolver: NameResolver,
    plan_slots: *AutoHashMap(Module.Id, ArrayList(liveness.PlanSlots)),

    fn internForRuntime(self: *const Lowerer, name: Frontend.PathTable.Id) !RuntimeStrings.Id {
        return self.vm.strings.insert(self.frontend.pathString(name));
    }

    fn numberStringNodeToElem(self: *const Lowerer, number: []const u8, negated: bool) !Elem {
        const elem = try Elem.numberStringFromBytes(number, self.vm);
        if (negated) {
            return elem.asNumberString().negate().elem();
        } else {
            return elem;
        }
    }
};

// Scratch state for lowering one pattern to a MatchPlan. Everything
// accumulates here so an UnsupportedPattern deep in the tree abandons
// cleanly, before any module or plan state mutation.
const PlanBuilder = struct {
    nodes: ArrayList(match_plan.Node) = .{},
    vars: ArrayList(match_plan.LocalVar) = .{},
    elems: ArrayList(Elem) = .{},
    sids: ArrayList(RuntimeStrings.Id) = .{},
    ranges: ArrayList(match_plan.RangePlan) = .{},
    merges: ArrayList(match_plan.MergePlan) = .{},
    calls: ArrayList(match_plan.CallPlan) = .{},
    repeats: ArrayList(match_plan.RepeatPlan) = .{},
    reads: liveness.SlotSet = liveness.SlotSet.initEmpty(),
    defs: liveness.SlotSet = liveness.SlotSet.initEmpty(),

    fn deinit(self: *PlanBuilder, allocator: std.mem.Allocator) void {
        self.nodes.deinit(allocator);
        self.vars.deinit(allocator);
        self.elems.deinit(allocator);
        self.sids.deinit(allocator);
        self.ranges.deinit(allocator);
        self.merges.deinit(allocator);
        self.calls.deinit(allocator);
        self.repeats.deinit(allocator);
    }

    fn appendLeaf(self: *PlanBuilder, allocator: std.mem.Allocator, tag: match_plan.Tag, payload: u32) !void {
        try self.nodes.append(allocator, .{ .tag = tag, .subtree_len = 1, .payload = payload });
    }

    fn addElem(self: *PlanBuilder, allocator: std.mem.Allocator, elem: Elem) !u32 {
        // The plan holds the elem across matches, like a module
        // constant: shared by construction, never unique.
        if (elem.isType(.Dyn)) elem.asDyn().makeImmortal();
        const idx: u32 = @intCast(self.elems.items.len);
        try self.elems.append(allocator, elem);
        return idx;
    }

    // A compare/eval occurrence reads the slot at match time; a bind
    // occurrence overwrites it without reading, which liveness uses to end
    // the previous value's live range.
    const VarAccess = enum { read, bind };

    fn addVar(self: *PlanBuilder, allocator: std.mem.Allocator, local_var: match_plan.LocalVar, access: VarAccess) !u32 {
        const idx: u32 = @intCast(self.vars.items.len);
        try self.vars.append(allocator, local_var);
        switch (access) {
            .read => self.reads.set(local_var.idx),
            .bind => self.defs.set(local_var.idx),
        }
        return idx;
    }

    fn appendEquality(self: *PlanBuilder, allocator: std.mem.Allocator, elem: Elem) !void {
        try self.appendLeaf(allocator, .equality, try self.addElem(allocator, elem));
    }

    fn appendVar(self: *PlanBuilder, allocator: std.mem.Allocator, tag: match_plan.Tag, local_var: match_plan.LocalVar) !void {
        const access: VarAccess = if (tag == .bind) .bind else .read;
        try self.appendLeaf(allocator, tag, try self.addVar(allocator, local_var, access));
    }
};

pub fn createMatchPlan(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Pattern.RNode,
) Error!u24 {
    const allocator = self.vm.allocator;
    var builder = PlanBuilder{};
    defer builder.deinit(allocator);

    try lowerPatternNode(self,module_id, rnode, &builder, false, 0);

    const nodes = try builder.nodes.toOwnedSlice(allocator);
    errdefer allocator.free(nodes);
    const vars = try builder.vars.toOwnedSlice(allocator);
    errdefer allocator.free(vars);
    const elems = try builder.elems.toOwnedSlice(allocator);
    errdefer allocator.free(elems);
    const sids = try builder.sids.toOwnedSlice(allocator);
    errdefer allocator.free(sids);
    const ranges = try builder.ranges.toOwnedSlice(allocator);
    errdefer allocator.free(ranges);
    const merges = try builder.merges.toOwnedSlice(allocator);
    errdefer allocator.free(merges);
    const calls = try builder.calls.toOwnedSlice(allocator);
    errdefer allocator.free(calls);
    const repeats = try builder.repeats.toOwnedSlice(allocator);
    errdefer allocator.free(repeats);

    const module = self.vm.getModule(module_id);
    const idx = try module.addMatchPlan(allocator, .{
        .nodes = nodes,
        .vars = vars,
        .elems = elems,
        .sids = sids,
        .ranges = ranges,
        .merges = merges,
        .calls = calls,
        .repeats = repeats,
    });

    const gop = try self.plan_slots.getOrPut(allocator, module_id);
    if (!gop.found_existing) gop.value_ptr.* = .{};
    try gop.value_ptr.append(allocator, .{ .reads = builder.reads, .defs = builder.defs });

    return @intCast(idx);
}

// Append one pattern subtree to the builder in preorder. Mirrors
// astToPattern's constant conversions exactly so plan and tree compare
// identically.
//
// negation_count threads negation down to where it resolves: number
// literals and globals pre-fold it, non-number literals and compounds
// reject it at compile time, and everything that only resolves at match
// time (locals, placeholders, calls, function globals, ranges) wraps in
// a .negated node that applies it per match.
//
// all_locals_bound lowers a repeat's rebound pattern variant: every
// local is treated as bound, because the first repetition bound it.
fn lowerPatternNode(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Pattern.RNode,
    builder: *PlanBuilder,
    all_locals_bound: bool,
    negation_count: u2,
) Error!void {
    const allocator = self.vm.allocator;

    switch (rnode.node) {
        .negation => |inner| {
            const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
            return lowerPatternNode(self,module_id, inner, builder, all_locals_bound, new_negation_count);
        },
        .identifier => |ident| {
            const name = ident.name;
            if (std.mem.eql(u8, self.frontend.pathString(name), "_")) {
                if (negation_count != 0) {
                    return lowerNegated(self, module_id, rnode, builder, all_locals_bound, negation_count);
                }
                return builder.appendLeaf(allocator, .placeholder, 0);
            }
            if (self.resolver.resolveGlobal(module_id, name)) |global| {
                // A zero-arity Function global is executed per match and
                // its result compared. The solver never executes native
                // code or closures here (matchConstant only runs
                // Functions), so those compare directly. A Function with
                // nonzero arity is a runtime error on every match. A
                // negated function global negates its per-match result.
                if (global.isDynType(.Function)) {
                    if (global.asDyn().asFunction().arity != 0) {
                        return error.UnsupportedPattern;
                    }
                    if (negation_count != 0) {
                        return lowerNegated(self, module_id, rnode, builder, all_locals_bound, negation_count);
                    }
                    return builder.appendLeaf(allocator, .const_fn, try builder.addElem(allocator, global));
                }
                // A non-function global's value is known now, so negation
                // folds at compile time.
                return builder.appendEquality(allocator, try foldNegatedGlobal(global, negation_count));
            }
            if (negation_count != 0) {
                return lowerNegated(self, module_id, rnode, builder, all_locals_bound, negation_count);
            }
            const slot = self.resolver.localSlot(name) orelse @panic("Internal error");
            // Binding analysis visits every pattern local occurrence; a
            // miss is a compiler bug.
            const bound = all_locals_bound or
                (self.frontend.binding_maps.pattern_local_bound.get(rnode) orelse
                    @panic("Internal error"));
            return builder.appendVar(allocator, if (bound) .bound_eq else .bind, .{
                .sid = try self.internForRuntime(name),
                .idx = slot,
            });
        },
        .number_float => |f| {
            const number = if (negation_count % 2 == 1) -f else f;
            return builder.appendEquality(allocator, Elem.numberFloat(number));
        },
        .number_string => |ns| {
            const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
            const maybe_negated = if (negation_count % 2 == 1) ns_elem.asNumberString().negate() else ns_elem.asNumberString();
            const number = maybe_negated.toNumberFloat(self.vm.strings);
            return builder.appendEquality(allocator, number);
        },
        .string => |s| {
            if (negation_count != 0) return Error.NegatedNonNumber;
            const sid = try self.vm.strings.insert(s);
            return builder.appendEquality(allocator, Elem.string(sid));
        },
        .true => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.boolean(true));
        },
        .false => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.boolean(false));
        },
        .null => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.nullConst);
        },
        .array => |elements| {
            if (negation_count != 0) return Error.NegatedNonNumber;
            // Fixed-length arrays only: spread/rest and merge parts are
            // `.merge` nodes, which fall back below when recursed into.
            const start = builder.nodes.items.len;
            try builder.nodes.append(allocator, .{
                .tag = .array,
                .subtree_len = undefined,
                .payload = @intCast(elements.items.len),
            });
            // A constant-count array-literal repeat shares one element
            // node pointer across its copies; a re-seen pointer is a later
            // copy, so its locals must rebind as bound_eq the way the
            // solver's runtime probe re-binds second-occurrence locals.
            var seen = std.AutoHashMapUnmanaged(*const Ast.Pattern.RNode, void){};
            defer seen.deinit(allocator);
            for (elements.items) |element| {
                const gop = try seen.getOrPut(allocator, element);
                const rebound = all_locals_bound or gop.found_existing;
                try lowerPatternNode(self,module_id, element, builder, rebound, 0);
            }
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .object => |pairs| {
            if (negation_count != 0) return Error.NegatedNonNumber;
            const start = builder.nodes.items.len;
            try builder.nodes.append(allocator, .{
                .tag = .object,
                .subtree_len = undefined,
                .payload = @intCast(pairs.items.len),
            });
            for (pairs.items) |pair| {
                const pair_start = builder.nodes.items.len;
                try builder.nodes.append(allocator, .{
                    .tag = .pattern_key,
                    .subtree_len = undefined,
                    .payload = 0,
                });
                if (pair.key.node == .string) {
                    // Constant string keys carry their interned sid; no
                    // key subtree, no per-match evaluation.
                    builder.nodes.items[pair_start] = .{
                        .tag = .const_key,
                        .subtree_len = undefined,
                        .payload = @intCast(builder.sids.items.len),
                    };
                    try builder.sids.append(allocator, try self.vm.strings.insert(pair.key.node.string));
                } else {
                    const key_start = builder.nodes.items.len;
                    try lowerPatternNode(self,module_id, pair.key, builder, all_locals_bound, 0);
                    const key_node = builder.nodes.items[key_start];
                    switch (key_node.tag) {
                        // A key folded to an interned string (a string
                        // global) is a const_key: both sid-resolution
                        // contexts agree on interned strings, so the
                        // per-match evaluation folds away.
                        .equality => if (builder.elems.items[key_node.payload].isType(.String)) {
                            builder.nodes.items[pair_start] = .{
                                .tag = .const_key,
                                .subtree_len = undefined,
                                .payload = @intCast(builder.sids.items.len),
                            };
                            try builder.sids.append(allocator, builder.elems.items[key_node.payload].asString());
                            // The key lowered to a single fresh leaf;
                            // drop both the node and its elem.
                            std.debug.assert(key_node.payload == builder.elems.items.len - 1);
                            builder.nodes.shrinkRetainingCapacity(key_start);
                            _ = builder.elems.pop();
                        } else {
                            builder.nodes.items[pair_start].tag = .eval_key;
                        },
                        // Leaf evaluations cannot come up empty at match
                        // time; everything else keeps attemptEval's
                        // runtime eval-or-search dispatch.
                        .bound_eq, .const_fn, .call => {
                            builder.nodes.items[pair_start].tag = .eval_key;
                        },
                        else => {},
                    }
                }
                try lowerPatternNode(self,module_id, pair.value, builder, all_locals_bound, 0);
                builder.nodes.items[pair_start].subtree_len = @intCast(builder.nodes.items.len - pair_start);
            }
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .range => |bounds| {
            if (negation_count != 0) {
                return lowerNegated(self, module_id, rnode, builder, all_locals_bound, negation_count);
            }
            std.debug.assert(bounds.lower != null or bounds.upper != null);
            // Append the range node before its limits so an evaluable
            // compound limit's subtree lands as a child, in
            // lower-before-upper order.
            const start = builder.nodes.items.len;
            const range_idx: u32 = @intCast(builder.ranges.items.len);
            try builder.nodes.append(allocator, .{ .tag = .range, .subtree_len = 1, .payload = range_idx });
            try builder.ranges.append(allocator, .{ .lower = .none, .upper = .none });
            const lower = try lowerRangeLimit(self,module_id, bounds.lower, builder, all_locals_bound);
            const upper = try lowerRangeLimit(self,module_id, bounds.upper, builder, all_locals_bound);
            builder.ranges.items[range_idx] = .{ .lower = lower, .upper = upper };
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .string_template => |segments| {
            if (negation_count != 0) return Error.NegatedNonNumber;
            const start = builder.nodes.items.len;
            const merge_idx: u32 = @intCast(builder.merges.items.len);
            try builder.nodes.append(allocator, .{
                .tag = .str_template,
                .subtree_len = undefined,
                .payload = merge_idx,
            });
            try builder.merges.append(allocator, .{
                .part_count = @intCast(segments.items.len),
                .solvable_index = null,
            });
            for (segments.items, 0..) |segment, i| {
                // Binding analysis records solvability for every template
                // segment; a miss is a compiler bug.
                const unbound = self.frontend.binding_maps.merge_part_unbound.get(segment) orelse
                    @panic("Internal error");
                const segment_start = builder.nodes.items.len;
                try lowerPatternNode(self,module_id, segment, builder, all_locals_bound, 0);
                if (unbound) {
                    builder.merges.items[merge_idx].solvable_index = @intCast(i);
                } else switch (builder.nodes.items[segment_start].tag) {
                    // Constant segments fold to their string rendering
                    // at compile time, the way the solver toStrings
                    // every simplified segment per match.
                    .equality => {
                        const elem_idx = builder.nodes.items[segment_start].payload;
                        const stringified = try builder.elems.items[elem_idx].toString(self.vm);
                        if (stringified.isType(.Dyn)) stringified.asDyn().makeImmortal();
                        builder.elems.items[elem_idx] = stringified;
                    },
                    // Bound locals and evaluated calls stringify at
                    // match time; ranges match one character.
                    .bound_eq, .const_fn, .call, .range => {},
                    // A negated evaluable segment (a negated call)
                    // stringifies its negated result at match time; a
                    // negated range segment could never match a
                    // character, so it stays unsupported.
                    .negated => if (classifyPlanSubtree(self, builder, @intCast(segment_start)) != .eval) {
                        return error.UnsupportedPattern;
                    },
                    // An evaluable compound segment (an array or merge
                    // of bound values) would need runtime evaluation;
                    // those stay unsupported.
                    else => return error.UnsupportedPattern,
                }
            }
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .merge => {
            // Nested merges flatten into one part list
            const start = builder.nodes.items.len;
            const merge_idx: u32 = @intCast(builder.merges.items.len);
            try builder.nodes.append(allocator, .{
                .tag = .merge,
                .subtree_len = undefined,
                .payload = merge_idx,
            });
            try builder.merges.append(allocator, .{
                .part_count = 0,
                .solvable_index = null,
            });
            var merge_plan = match_plan.MergePlan{ .part_count = 0, .solvable_index = null };
            // Negations distributes across merge parts
            try lowerMergeParts(self,module_id, rnode, builder, &merge_plan, all_locals_bound, negation_count);
            builder.merges.items[merge_idx] = merge_plan;
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .repeat => |infix| {
            const start = builder.nodes.items.len;
            const repeat_idx: u32 = @intCast(builder.repeats.items.len);
            try builder.nodes.append(allocator, .{
                .tag = .repeat,
                .subtree_len = undefined,
                .payload = repeat_idx,
            });
            try builder.repeats.append(allocator, .{
                .pattern = .subtree,
                .count = .subtree,
                .has_rebound_pattern = false,
            });

            const pattern_start: u32 = @intCast(builder.nodes.items.len);
            try lowerPatternNode(self,module_id, infix.left, builder, all_locals_bound, negation_count);
            const count_start: u32 = @intCast(builder.nodes.items.len);
            try lowerPatternNode(self,module_id, infix.right, builder, all_locals_bound, 0);

            const pattern_op = try lowerRepeatOperand(self,builder, pattern_start);
            const count_op = try lowerRepeatOperand(self,builder, count_start);

            // Array repetitions re-match the pattern per element or
            // chunk; when it binds locals the later iterations must
            // compare instead, so emit the pattern again with every
            // local bound.
            var has_rebound = false;
            for (builder.nodes.items[pattern_start..count_start]) |n| {
                if (n.tag == .bind) {
                    has_rebound = true;
                    break;
                }
            }
            if (has_rebound) {
                try lowerPatternNode(self,module_id, infix.left, builder, true, negation_count);
            }

            builder.repeats.items[repeat_idx] = .{
                .pattern = pattern_op,
                .count = count_op,
                .has_rebound_pattern = has_rebound,
            };
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
        .function_call => |function_call| {
            if (negation_count != 0) {
                return lowerNegated(self, module_id, rnode, builder, all_locals_bound, negation_count);
            }
            // A call is evaluated at match time and its result compared.
            // Non-identifier callees and constant callees that are not
            // functions or take a different number of arguments are
            // compile errors.
            const nameNode = function_call.function.node;
            if (nameNode != .identifier or nameNode.identifier.underscored) {
                return error.UnsupportedPattern;
            }
            const name = nameNode.identifier.name;

            const callee: match_plan.CallPlan.Callee = if (self.resolver.resolveGlobal(module_id, name)) |global| blk: {
                if (!global.isDynType(.Function)) return error.UnsupportedPattern;
                if (global.asDyn().asFunction().arity != function_call.args.items.len) {
                    return error.UnsupportedPattern;
                }
                break :blk .{ .constant = try builder.addElem(allocator, global) };
            } else if (self.resolver.localSlot(name)) |slot|
                // The local's value is only known at match time; the
                // interpreter checks it is a function of the right arity.
                .{ .local = try builder.addVar(allocator, .{
                    .sid = try self.internForRuntime(name),
                    .idx = slot,
                }, .read) }
            else
                // Validation rejects parser identifiers in patterns and
                // binding analysis rejects unbound callees, so the name
                // always resolves.
                @panic("Internal error");

            const start = builder.nodes.items.len;
            try builder.nodes.append(allocator, .{
                .tag = .call,
                .subtree_len = undefined,
                .payload = @intCast(builder.calls.items.len),
            });
            try builder.calls.append(allocator, .{
                .callee = callee,
                .arg_count = @intCast(function_call.args.items.len),
            });
            for (function_call.args.items) |arg| {
                try lowerCallArg(self,module_id, arg, builder, 0);
            }
            builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
        },
    }
}

// Fold negation into a global whose value is known at compile time: a
// negated non-number is an error, an even negation count cancels, an odd
// one flips the sign.
fn foldNegatedGlobal(global: Elem, negation_count: u2) Error!Elem {
    if (negation_count == 0) return global;
    if (!global.isNumber()) return Error.NegatedNonNumber;
    if (negation_count % 2 == 0) return global;
    return global.negateNumber() catch Error.NegatedNonNumber;
}

// Wrap a subtree whose value only resolves at match time (a local,
// placeholder, call, function global, or range) in a .negated node, then
// lower the same pattern node without the negation.
fn lowerNegated(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Pattern.RNode,
    builder: *PlanBuilder,
    all_locals_bound: bool,
    negation_count: u2,
) Error!void {
    const start = builder.nodes.items.len;
    try builder.nodes.append(self.vm.allocator, .{
        .tag = .negated,
        .subtree_len = undefined,
        .payload = negation_count,
    });
    try lowerPatternNode(self, module_id, rnode, builder, all_locals_bound, 0);
    builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
}

// Lower one function-call argument. Arguments are evaluated, not
// matched: constants fold to elems here, mirroring attemptEval's
// results; locals and function constants resolve at match time.
// Negation folds into literals and globals at compile time and wraps
// locals and function globals in a .negated node; a negated non-number
// literal is a compile error.
fn lowerCallArg(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Value.RNode,
    builder: *PlanBuilder,
    negation_count: u2,
) Error!void {
    const allocator = self.vm.allocator;

    switch (rnode.node) {
        .negation => |inner| {
            const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
            return lowerCallArg(self,module_id, inner, builder, new_negation_count);
        },
        .true => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.boolean(true));
        },
        .false => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.boolean(false));
        },
        .null => {
            if (negation_count != 0) return Error.NegatedNonNumber;
            return builder.appendEquality(allocator, Elem.nullConst);
        },
        .number_float => |f| {
            const number = if (negation_count % 2 == 1) -f else f;
            return builder.appendEquality(allocator, Elem.numberFloat(number));
        },
        .number_string => |ns| {
            const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
            const maybe_negated = if (negation_count % 2 == 1) ns_elem.asNumberString().negate() else ns_elem.asNumberString();
            const number = maybe_negated.toNumberFloat(self.vm.strings);
            return builder.appendEquality(allocator, number);
        },
        .string => |s| {
            if (negation_count != 0) return Error.NegatedNonNumber;
            const sid = try self.vm.strings.insert(s);
            return builder.appendEquality(allocator, Elem.string(sid));
        },
        .identifier => |ident| {
            if (self.resolver.resolveGlobal(module_id, ident.name)) |global| {
                // A zero-arity Function argument is executed per match; a
                // nonzero arity always errors at match, so it stays
                // unsupported. Negation applies to the per-match result.
                if (global.isDynType(.Function)) {
                    if (global.asDyn().asFunction().arity != 0) {
                        return error.UnsupportedPattern;
                    }
                    if (negation_count != 0) {
                        return lowerNegatedCallArg(self, module_id, rnode, builder, negation_count);
                    }
                    return builder.appendLeaf(allocator, .const_fn, try builder.addElem(allocator, global));
                }
                return builder.appendEquality(allocator, try foldNegatedGlobal(global, negation_count));
            }
            // A local argument reads its slot at match time: it may be
            // bound by an earlier part of this same pattern, so there is
            // no static boundness to record. Negation applies to the
            // value read from the slot. Validation rejects parser
            // identifiers in value context, so the name always resolves.
            const slot = self.resolver.localSlot(ident.name) orelse @panic("Internal error");
            if (negation_count != 0) {
                return lowerNegatedCallArg(self, module_id, rnode, builder, negation_count);
            }
            return builder.appendVar(allocator, .bound_eq, .{
                .sid = try self.internForRuntime(ident.name),
                .idx = slot,
            });
        },
        else => return error.UnsupportedPattern,
    }
}

// The call-argument counterpart of lowerNegated.
fn lowerNegatedCallArg(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Value.RNode,
    builder: *PlanBuilder,
    negation_count: u2,
) Error!void {
    const start = builder.nodes.items.len;
    try builder.nodes.append(self.vm.allocator, .{
        .tag = .negated,
        .subtree_len = undefined,
        .payload = negation_count,
    });
    try lowerCallArg(self, module_id, rnode, builder, 0);
    builder.nodes.items[start].subtree_len = @intCast(builder.nodes.items.len - start);
}

// Negation distributes over merge parts the way astToPattern threads
// negation_count through collectPatternMergeElements. Negated nested
// merges flatten into the outer part list, mirroring the analyzer's
// collectMergeChain: after flattening, a part carries at most one
// .negation wrapper, and merge_part_unbound is keyed on that wrapper.
fn lowerMergeParts(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Pattern.RNode,
    builder: *PlanBuilder,
    merge_plan: *match_plan.MergePlan,
    all_locals_bound: bool,
    negation_count: u2,
) Error!void {
    switch (rnode.node) {
        .merge => |merge| {
            try lowerMergeParts(self,module_id, merge.left, builder, merge_plan, all_locals_bound, negation_count);
            try lowerMergeParts(self,module_id, merge.right, builder, merge_plan, all_locals_bound, negation_count);
        },
        .negation => |inner| switch (inner.node) {
            .merge, .negation => {
                const new_negation_count = if (negation_count == 3) (negation_count - 1) else (negation_count + 1);
                try lowerMergeParts(self,module_id, inner, builder, merge_plan, all_locals_bound, new_negation_count);
            },
            else => try lowerMergePart(self,module_id, rnode, builder, merge_plan, all_locals_bound, negation_count),
        },
        else => try lowerMergePart(self,module_id, rnode, builder, merge_plan, all_locals_bound, negation_count),
    }
}

fn lowerMergePart(
    self: *Lowerer,
    module_id: Module.Id,
    rnode: *Ast.Pattern.RNode,
    builder: *PlanBuilder,
    merge_plan: *match_plan.MergePlan,
    all_locals_bound: bool,
    negation_count: u2,
) Error!void {
    // Binding analysis records solvability for every merge part; a miss
    // is a compiler bug.
    const unbound = self.frontend.binding_maps.merge_part_unbound.get(rnode) orelse
        @panic("Internal error");
    // The part may carry one .negation wrapper (collectMergeChain keeps
    // it); look through it for the repeat guard.
    const part_node = if (rnode.node == .negation) rnode.node.negation.node else rnode.node;
    // A counted-structural repeat merge part (bound count) is matched in
    // place and only supported for object patterns. An unbound-count
    // repeat is the solvable rest: its count is solved from the leftover
    // value, so the pattern may be any shape the interpreter can derive a
    // count from.
    if (part_node == .repeat and !unbound and part_node.repeat.left.node != .object) {
        return error.UnsupportedPattern;
    }
    if (unbound) merge_plan.solvable_index = merge_plan.part_count;
    const part_start = builder.nodes.items.len;
    try lowerPatternNode(self,module_id, rnode, builder, all_locals_bound, negation_count);
    if (builder.nodes.items[part_start].tag == .repeat) {
        const count_idx = part_start + 1 + builder.nodes.items[part_start + 1].subtree_len;
        const count_tag = builder.nodes.items[count_idx].tag;
        if (unbound) {
            // The solvable repeat solves for its count, which must be a
            // bare unbound local. A count that instead evaluates but can
            // come up empty at match time (a nested repeat or merge)
            // would flip the rest-vs-structural classification, so keep
            // those unsupported.
            if (count_tag != .bind) return error.UnsupportedPattern;
        } else switch (count_tag) {
            .equality, .bound_eq, .const_fn, .call => {},
            .negated => if (classifyPlanSubtree(self, builder, @intCast(count_idx)) != .eval) {
                return error.UnsupportedPattern;
            },
            else => return error.UnsupportedPattern,
        }
    }
    merge_plan.part_count += 1;
}

// How a repeat operand subtree is obtained at match time, mirroring what
// the solver's attemptEval would discover dynamically. The split between
// constant and eval is the compile-time refinement: constants fold here.
const SubtreeClass = enum { constant, eval, subtree };

fn classifyPlanSubtree(self: *Lowerer, builder: *PlanBuilder, idx: u32) SubtreeClass {
    const node = builder.nodes.items[idx];
    return switch (node.tag) {
        .equality => .constant,
        .bound_eq, .const_fn, .call => .eval,
        .bind, .placeholder, .object, .range, .str_template => .subtree,
        .array, .merge => blk: {
            const child_count = if (node.tag == .array)
                node.payload
            else
                builder.merges.items[node.payload].part_count;
            var class = SubtreeClass.constant;
            var child = idx + 1;
            for (0..child_count) |_| {
                const child_class = classifyPlanSubtree(self,builder, child);
                if (@intFromEnum(child_class) > @intFromEnum(class)) class = child_class;
                child += builder.nodes.items[child].subtree_len;
            }
            break :blk class;
        },
        // A nested constant repeat could fold too, but folding it means
        // running Elem.repeat at compile time for a shape that is rare;
        // evaluate it per match instead.
        .repeat => blk: {
            const repeat_plan = builder.repeats.items[node.payload];
            const evaluates = repeat_plan.pattern != .subtree and repeat_plan.count != .subtree;
            break :blk if (evaluates) .eval else .subtree;
        },
        // The negation applies to the evaluated inner value; a constant
        // inner cannot occur (constants fold before a wrapper is emitted)
        // but would still evaluate.
        .negated => blk: {
            const inner = classifyPlanSubtree(self, builder, idx + 1);
            break :blk if (inner == .subtree) .subtree else .eval;
        },
        .const_key, .eval_key, .pattern_key => unreachable,
    };
}

// Fold a constant-classified subtree to an Elem, mirroring attemptEval.
// Null mirrors a merge that does not fold (mismatched part types); the
// operand then stays structural, the way attemptEval returns null for it
// on every match.
fn foldPlanSubtree(self: *Lowerer, builder: *PlanBuilder, idx: u32) Error!?Elem {
    const node = builder.nodes.items[idx];
    switch (node.tag) {
        .equality => return builder.elems.items[node.payload],
        .array => {
            const dyn_array = try Elem.DynElem.Array.create(self.vm, node.payload);
            try self.vm.pushTempDyn(&dyn_array.dyn);
            var child = idx + 1;
            for (0..node.payload) |_| {
                const child_elem = (try foldPlanSubtree(self,builder, child)) orelse return null;
                try dyn_array.append(self.vm, child_elem);
                child += builder.nodes.items[child].subtree_len;
            }
            return dyn_array.dyn.elem();
        },
        .merge => {
            var result: ?Elem = null;
            var child = idx + 1;
            for (0..builder.merges.items[node.payload].part_count) |_| {
                const part_elem = (try foldPlanSubtree(self,builder, child)) orelse return null;
                if (result) |current| {
                    result = (try current.merge(part_elem, self.vm)) orelse return null;
                    if (result.?.isType(.Dyn)) try self.vm.pushTempDyn(result.?.asDyn());
                } else {
                    result = part_elem;
                }
                child += builder.nodes.items[child].subtree_len;
            }
            return result;
        },
        // Only constant-classified subtrees are folded.
        else => unreachable,
    }
}

fn lowerRepeatOperand(
    self: *Lowerer,
    builder: *PlanBuilder,
    subtree_idx: u32,
) Error!match_plan.RepeatPlan.Operand {
    switch (classifyPlanSubtree(self,builder, subtree_idx)) {
        .constant => {
            const temp_dyns_base = self.vm.temp_dyns.items.len;
            defer self.vm.clearTempDyns(temp_dyns_base);
            if (try foldPlanSubtree(self,builder, subtree_idx)) |elem| {
                return .{ .constant = try builder.addElem(self.vm.allocator, elem) };
            }
            return .subtree;
        },
        .eval => return .eval,
        .subtree => return .subtree,
    }
}

// A range bound folds when it is absent, a number/string literal, or a
// statically-bound local. An unbound local in a bound is matched as a
// pattern by the tree path, so it falls back.
fn lowerRangeLimit(
    self: *Lowerer,
    module_id: Module.Id,
    maybe_rnode: ?*Ast.Pattern.RNode,
    builder: *PlanBuilder,
    all_locals_bound: bool,
) Error!match_plan.RangePlan.Limit {
    const allocator = self.vm.allocator;
    const rnode = maybe_rnode orelse return .none;

    switch (rnode.node) {
        .number_float => |f| {
            return .{ .const_elem = try builder.addElem(allocator, Elem.numberFloat(f)) };
        },
        .number_string => |ns| {
            const ns_elem = try self.numberStringNodeToElem(ns.number, ns.negated);
            const number = ns_elem.asNumberString().toNumberFloat(self.vm.strings);
            return .{ .const_elem = try builder.addElem(allocator, number) };
        },
        .string => |s| {
            const sid = try self.vm.strings.insert(s);
            return .{ .const_elem = try builder.addElem(allocator, Elem.string(sid)) };
        },
        .identifier => |ident| {
            const name = ident.name;
            if (std.mem.eql(u8, self.frontend.pathString(name), "_")) {
                return error.UnsupportedPattern;
            }
            if (self.resolver.resolveGlobal(module_id, name) != null) return error.UnsupportedPattern;
            // Validation rejects parser identifiers in patterns, so a
            // non-global name is always a local, and binding analysis
            // visits every range-limit local.
            const slot = self.resolver.localSlot(name) orelse @panic("Internal error");
            const bound = all_locals_bound or
                (self.frontend.binding_maps.pattern_local_bound.get(rnode) orelse
                    @panic("Internal error"));
            const var_idx = try builder.addVar(allocator, .{
                .sid = try self.internForRuntime(name),
                .idx = slot,
            }, if (bound) .read else .bind);
            // An unbound limit binds the matched value, the way the solver
            // matches an unbound limit as a pattern.
            return if (bound) .{ .bound_local = var_idx } else .{ .bind_local = var_idx };
        },
        else => {
            // A compound limit (e.g. arithmetic on bound locals) lowers
            // to a child subtree evaluated at match time. Only evaluable
            // shapes are supported; a structural or unbound compound
            // limit is a runtime error the tree path reports.
            const child_start: u32 = @intCast(builder.nodes.items.len);
            try lowerPatternNode(self,module_id, rnode, builder, all_locals_bound, 0);
            switch (classifyPlanSubtree(self,builder, child_start)) {
                .constant, .eval => return .eval,
                .subtree => return error.UnsupportedPattern,
            }
        },
    }
}

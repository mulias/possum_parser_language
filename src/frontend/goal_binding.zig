const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Frontend = @import("../frontend.zig");
const Ast = @import("goal_ast.zig");
const Module = @import("../runtime.zig").Module;
const Region = @import("../region.zig").Region;
const Strings = @import("string_table.zig").FrontendStringTable;
const Paths = @import("path_table.zig").PathTable;

// Where a local stands on the control paths reaching a program point:
// bound on every path, on none, or only on some.
pub const State = enum { unbound, bound, split };

pub const Slot = struct {
    state: State = .unbound,
    // The frame slot may still physically hold a value from a binding that
    // is out of scope: a failed alternative or an earlier loop iteration.
    // Only meaningful while state is not .bound.
    stale: bool = false,
};

pub const Env = struct {
    slots: [max_locals]Slot = [_]Slot{.{}} ** max_locals,
};

pub const max_locals = 256;
pub const SlotSet = std.bit_set.StaticBitSet(max_locals);

pub const Diagnostic = struct {
    module_id: Module.Id,
    region: Region,
    name: ?Strings.Id,
    kind: Kind,

    pub const Kind = enum {
        // No path reaching this point binds the local.
        unbound,
        // Only bound by a failed alternative or an earlier loop iteration.
        out_of_scope,
        // Bound on some paths but not others.
        split,
        // A second unbound part in a single merge or string template.
        extra_unbound_part,
        // A function callee or argument with no binding in scope and no
        // binding occurrence anywhere in the pattern.
        unbound_function_var,
    };
};

// Mark slots that `after` may have bound or dirtied relative to `base`
// as stale in `target`: the values may physically remain in the frame
// while the bindings are out of scope.
pub fn markStaleBinds(target: *Env, base: *const Env, after: *const Env) void {
    for (&target.slots, base.slots, after.slots) |*t, b, a| {
        if (a.stale or (b.state == .unbound and a.state != .unbound)) {
            t.stale = true;
        }
    }
}

pub fn joinEnv(a: *const Env, b: *const Env) Env {
    var out = Env{};
    for (&out.slots, a.slots, b.slots) |*o, x, y| {
        if (x.state == .bound and y.state == .bound) {
            o.* = .{ .state = .bound, .stale = false };
        } else if (x.state == .unbound and y.state == .unbound) {
            o.* = .{ .state = .unbound, .stale = x.stale or y.stale };
        } else {
            o.* = .{ .state = .split, .stale = x.stale or y.stale };
        }
    }
    return out;
}

// Binding analysis on the goal ast: the same forward walk and binding
// rules as binding.zig, but instead of producing side tables for the can
// compiler it rewrites the goal in place. Every neutral occurrence —
// constraint `local`, `Part.local`, `Limit.local`, unresolved eval
// `ident` — is classified as a binder, a bound read, or a global
// reference; repeat caps whose reads are unbound are cleared; lambda
// capture sets are computed as a free-variable byproduct of
// classification and written onto the lambda nodes.
//
// Lambdas are analyzed inline at their creation site under a scope
// stack, mirroring binding.zig's captureSite semantics: a name owned by
// an enclosing scope is a capture on every lambda between the owner and
// the reader, its boundness is judged in the owner's env as frozen at
// the creation point, and an unbound capture reports at the chain's
// outermost lambda.
//
// Constraint classification runs through a fixpoint scheduler
// (scheduleConstraints): binder selection is an output of readiness, not
// textual first sight, so `[[...A, ...B], [...B]]` schedules element 1's
// bind of B before element 0's merge and becomes solvable. The
// one-unbound-part rule (extra_unbound_part) is enforced here, judged
// pre-classification like can-binding's checkOneUnboundPart, and each
// solve_merge's solvable_index is filled. Constraint lists are reordered
// in place to the schedule.
//
// Deliberate deviations from binding.zig:
// - Constraints can-binding rejects but the fixpoint can order
//   (delayed merges, evals after their binder) classify with the
//   scheduled binder sites; visible only on programs can-binding
//   rejects, until goal binding becomes the reporter.
// - Value-context repeats get the same per-iteration binding scope as
//   parser repeats (the goal node is context-free), and their count
//   reads diagnose as unbound_function_var rather than unbound.

pub fn analyzeModule(
    frontend: *Frontend,
    module_id: Module.Id,
    ast: *Ast,
    diagnostics: *ArrayList(Diagnostic),
) Allocator.Error!void {
    var analyzer = Analyzer{
        .frontend = frontend,
        .module_id = module_id,
        .ast = ast,
        .allocator = frontend.arena.allocator(),
        .diagnostics = diagnostics,
    };

    for (ast.declarations.items) |decl| {
        const node = frontend.findNode(module_id, decl.name).?;
        try analyzer.analyzeFunction(node, decl.body, decl.params.items.len, decl.region);
    }
    if (ast.main) |main_id| {
        const node = frontend.findNode(module_id, ast.main_name.?).?;
        const region = ast.goals.items[main_id].region;
        try analyzer.analyzeFunction(node, main_id, 0, region);
    }
}

const Analyzer = struct {
    frontend: *Frontend,
    module_id: Module.Id,
    ast: *Ast,
    allocator: Allocator,
    diagnostics: *ArrayList(Diagnostic),
    scopes: ArrayList(Scope) = .{},

    // One function frame on the lexical chain. `env` points at the env
    // live in that scope's walk when it descended into a child lambda,
    // so capture boundness is judged at the creation point.
    const Scope = struct {
        node: *Frontend.DependencyGraphNode,
        env: *Env,
        lambda: ?*Ast.Lambda,
        region: Region,
    };

    fn analyzeFunction(
        self: *Analyzer,
        node: *Frontend.DependencyGraphNode,
        body: Ast.NodeId,
        arity: usize,
        region: Region,
    ) Allocator.Error!void {
        var env = Env{};
        for (0..arity) |slot| env.slots[slot].state = .bound;

        try self.scopes.append(self.allocator, .{
            .node = node,
            .env = &env,
            .lambda = null,
            .region = region,
        });
        defer _ = self.scopes.pop();

        try self.analyzeGoal(&env, body);
    }

    fn currentScope(self: *Analyzer) *Scope {
        return &self.scopes.items[self.scopes.items.len - 1];
    }

    fn diagnose(self: *Analyzer, region: Region, name: ?Strings.Id, kind: Diagnostic.Kind) !void {
        try self.diagnostics.append(self.allocator, .{
            .module_id = self.module_id,
            .region = region,
            .name = name,
            .kind = kind,
        });
    }

    fn isPlaceholder(self: *Analyzer, name: Paths.Id) bool {
        return std.mem.eql(u8, self.frontend.pathString(name), "_");
    }

    fn localSlot(node: *const Frontend.DependencyGraphNode, segment: Strings.Id) ?u8 {
        for (node.locals(), 0..) |local, i| {
            if (local == segment) return @intCast(i);
        }
        return null;
    }

    // Whether a name in pattern position is a global reference. A global
    // with the same name wins over a local, matching astToPattern.
    fn patternGlobal(self: *Analyzer, name: Paths.Id) bool {
        return self.currentScope().node.dependencyNamed(name) != null;
    }

    // The current frame's slot for a name in pattern position, without
    // capture side effects: bindable-set collection and staleness
    // collection resolve through this.
    fn patternSlot(self: *Analyzer, name: Paths.Id) ?u8 {
        if (self.isPlaceholder(name)) return null;
        if (self.patternGlobal(name)) return null;
        const segment = self.frontend.paths.single(name) orelse return null;
        return localSlot(self.currentScope().node, segment);
    }

    // The current frame's slot for a segment, resolving captures: a name
    // owned by an enclosing scope is recorded on every lambda between
    // the owner and this scope and bound in each frame on the way in.
    fn resolveLocal(self: *Analyzer, env: *Env, segment: Strings.Id) !?u8 {
        const slot = localSlot(self.currentScope().node, segment) orelse return null;
        if (self.captureOwner(segment)) |owner| {
            try self.recordCapture(env, owner, segment);
        }
        return slot;
    }

    // The outermost enclosing scope whose frame holds the segment; null
    // when the segment is the current scope's own local. Enclosing
    // scopes always win: the resolver never lets a lambda shadow a name
    // visible in its parent chain.
    fn captureOwner(self: *Analyzer, segment: Strings.Id) ?usize {
        const last = self.scopes.items.len - 1;
        for (self.scopes.items[0..last], 0..) |scope, i| {
            if (localSlot(scope.node, segment) != null) return i;
        }
        return null;
    }

    fn recordCapture(self: *Analyzer, env: *Env, owner: usize, segment: Strings.Id) !void {
        const scopes = self.scopes.items;
        var i = owner + 1;
        while (i < scopes.len) : (i += 1) {
            const scope = scopes[i];
            const lambda = scope.lambda.?;

            var recorded = false;
            for (lambda.captures.items) |existing| {
                if (existing == segment) {
                    recorded = true;
                    break;
                }
            }
            if (!recorded) {
                try lambda.captures.append(self.allocator, segment);
                if (i == owner + 1) {
                    // The chain's outermost lambda reads the owner's
                    // frame at creation; unbound there is the error.
                    const owner_slot = localSlot(scopes[owner].node, segment).?;
                    try self.readLocal(scopes[owner].env, owner_slot, segment, scope.region);
                }
            }

            const slot = localSlot(scope.node, segment).?;
            const scope_env = if (i == scopes.len - 1) env else scope.env;
            scope_env.slots[slot] = .{ .state = .bound, .stale = false };
        }
    }

    fn readLocal(self: *Analyzer, env: *Env, slot: u8, name: Strings.Id, region: Region) !void {
        switch (env.slots[slot].state) {
            .bound => {},
            .unbound => try self.diagnose(
                region,
                name,
                if (env.slots[slot].stale) .out_of_scope else .unbound,
            ),
            .split => try self.diagnose(region, name, .split),
        }
    }

    // Eval position: a bare ident is a local read when the current frame
    // holds the segment, a global reference otherwise.
    fn readIdent(self: *Analyzer, env: *Env, ident: *Ast.Ident, region: Region) !void {
        if (self.isPlaceholder(ident.name)) {
            ident.resolution = .placeholder;
            return;
        }
        const segment = self.frontend.paths.single(ident.name) orelse {
            ident.resolution = .global;
            return;
        };
        if (try self.resolveLocal(env, segment)) |slot| {
            try self.readLocal(env, slot, segment, region);
            ident.resolution = .{ .local = slot };
        } else {
            ident.resolution = .global;
        }
    }

    fn analyzeGoal(self: *Analyzer, env: *Env, id: Ast.NodeId) Allocator.Error!void {
        const rnode = &self.ast.goals.items[id];
        switch (rnode.node) {
            .true, .false, .null, .string, .number_string, .number_float => {},
            .ident => |*ident| try self.readIdent(env, ident, rnode.region),
            .call => |call| {
                try self.analyzeGoal(env, call.callee);
                for (call.args) |arg| try self.analyzeGoal(env, arg);
            },
            .lambda => |*lambda| try self.analyzeLambda(env, lambda, rnode.region),
            .seq => |seq| for (seq.goals.items) |goal| try self.analyzeGoal(env, goal),
            .merge => |merge| {
                try self.analyzeGoal(env, merge.left);
                try self.analyzeGoal(env, merge.right);
            },
            .mult => |mult| {
                try self.analyzeGoal(env, mult.left);
                try self.analyzeGoal(env, mult.right);
            },
            .neg, .to_string => |inner| try self.analyzeGoal(env, inner),
            .range => |range| {
                if (range.lower) |lower| try self.analyzeGoal(env, lower);
                if (range.upper) |upper| try self.analyzeGoal(env, upper);
            },
            .array => |elems| for (elems.items) |elem| try self.analyzeGoal(env, elem),
            .object => |pairs| for (pairs.items) |pair| {
                try self.analyzeGoal(env, pair.key);
                try self.analyzeGoal(env, pair.value);
            },
            .alt => |arms| try self.analyzeAlt(env, arms.items),
            .match => |*match| try self.analyzeMatch(env, match),
            .repeat => |*repeat| try self.analyzeRepeat(env, repeat),
        }
    }

    fn analyzeLambda(self: *Analyzer, env: *Env, lambda: *Ast.Lambda, region: Region) !void {
        const node = self.frontend.findNode(self.module_id, lambda.name).?;
        self.currentScope().env = env;

        var lambda_env = Env{};
        try self.scopes.append(self.allocator, .{
            .node = node,
            .env = &lambda_env,
            .lambda = lambda,
            .region = region,
        });
        defer _ = self.scopes.pop();

        try self.analyzeGoal(&lambda_env, lambda.body);
    }

    // Ordered committed choice. An arm's guard failure falls to the next
    // arm, so later arms see earlier guards' bindings as out of scope; a
    // body runs committed, so its bindings never leak to later arms. The
    // result env is the join over every arm's exit.
    fn analyzeAlt(self: *Analyzer, env: *Env, arms: []const Ast.AltArm) !void {
        var acc = env.*;
        var joined: ?Env = null;
        for (arms) |arm| {
            var arm_env = acc;
            if (arm.guard) |guard| {
                try self.analyzeGoal(&arm_env, guard);
                const pre = acc;
                markStaleBinds(&acc, &pre, &arm_env);
            }
            if (arm.body) |body| try self.analyzeGoal(&arm_env, body);
            joined = if (joined) |prev| joinEnv(&prev, &arm_env) else arm_env;
        }
        if (joined) |result| env.* = result;
    }

    // Match arms commit like alt arms with the constraint set as part of
    // the guard: constraint or guard failure falls to the next arm.
    fn analyzeMatch(self: *Analyzer, env: *Env, match: *Ast.Match) !void {
        try self.analyzeGoal(env, match.scrutinee);

        var acc = env.*;
        var joined: ?Env = null;
        for (match.arms.items) |*arm| {
            var arm_env = acc;
            try self.destructure(&arm_env, arm.constraints.items);
            if (arm.guard) |guard| try self.analyzeGoal(&arm_env, guard);
            const pre = acc;
            markStaleBinds(&acc, &pre, &arm_env);
            if (arm.body) |body| try self.analyzeGoal(&arm_env, body);
            joined = if (joined) |prev| joinEnv(&prev, &arm_env) else arm_env;
        }
        if (joined) |result| env.* = result;
    }

    // A repeat body binds fresh each iteration: the body is analyzed
    // with its own bindings out of scope, and they stay out of scope
    // after the loop. The cap is judged before the count test binds.
    fn analyzeRepeat(self: *Analyzer, env: *Env, repeat: *Ast.Repeat) !void {
        var binds = SlotSet.initEmpty();
        self.collectGoalBinds(repeat.body, &binds);

        var body_env = env.*;
        staleUnbound(&body_env, &binds);
        try self.analyzeGoal(&body_env, repeat.body);

        var out = env.*;
        staleUnbound(&out, &binds);

        try self.classifyCap(&out, &repeat.cap);
        if (repeat.count_test) |set_id| {
            try self.destructure(&out, self.ast.constraint_sets.items[set_id].constraints.items);
        }
        env.* = out;
    }

    fn staleUnbound(env: *Env, binds: *const SlotSet) void {
        var iter = binds.iterator(.{});
        while (iter.next()) |slot| {
            if (env.slots[slot].state == .unbound) {
                env.slots[slot].stale = true;
            }
        }
    }

    // A repeat cap survives only when every read is bound at the loop:
    // an unbound cap clears, and the count test binds instead.
    fn classifyCap(self: *Analyzer, env: *Env, cap: *Ast.Limit) !void {
        switch (cap.*) {
            .none, .bind, .read, .global => {},
            .local => |name| {
                if (self.patternGlobal(name)) {
                    cap.* = .{ .global = name };
                    return;
                }
                const segment = self.frontend.paths.single(name) orelse {
                    cap.* = .{ .global = name };
                    return;
                };
                const slot = (try self.resolveLocal(env, segment)) orelse {
                    cap.* = .{ .global = name };
                    return;
                };
                cap.* = if (env.slots[slot].state == .bound)
                    .{ .read = .{ .slot = slot, .name = name } }
                else
                    .none;
            },
            .expr => |expr| if (!(try self.capExprBound(env, expr))) {
                cap.* = .none;
            },
        }
    }

    // Whether every read in a cap expression is bound, silently: an
    // unbound read is not an error here, it just clears the cap. Kept
    // caps get their idents resolved on the way through.
    fn capExprBound(self: *Analyzer, env: *Env, id: Ast.NodeId) Allocator.Error!bool {
        const rnode = &self.ast.goals.items[id];
        switch (rnode.node) {
            .true, .false, .null, .string, .number_string, .number_float => return true,
            .ident => |*ident| {
                if (self.isPlaceholder(ident.name)) {
                    ident.resolution = .placeholder;
                    return false;
                }
                if (self.patternGlobal(ident.name)) {
                    ident.resolution = .global;
                    return true;
                }
                const segment = self.frontend.paths.single(ident.name) orelse {
                    ident.resolution = .global;
                    return true;
                };
                const slot = (try self.resolveLocal(env, segment)) orelse {
                    ident.resolution = .global;
                    return true;
                };
                ident.resolution = .{ .local = slot };
                return env.slots[slot].state == .bound;
            },
            .merge => |merge| {
                const left = try self.capExprBound(env, merge.left);
                const right = try self.capExprBound(env, merge.right);
                return left and right;
            },
            .mult => |mult| {
                const left = try self.capExprBound(env, mult.left);
                const right = try self.capExprBound(env, mult.right);
                return left and right;
            },
            .neg, .to_string => |inner| return self.capExprBound(env, inner),
            .call => |call| {
                var all = try self.capExprBound(env, call.callee);
                for (call.args) |arg| {
                    const arg_bound = try self.capExprBound(env, arg);
                    all = all and arg_bound;
                }
                return all;
            },
            else => return false,
        }
    }

    // A destructure site. After a successful match every local the
    // pattern references is bound; evaluated positions (call callees and
    // arguments) must be bound elsewhere.
    fn destructure(self: *Analyzer, env: *Env, constraints: []Ast.Constraint) Allocator.Error!void {
        var bindable = SlotSet.initEmpty();
        self.collectBindable(constraints, &bindable);
        try self.scheduleConstraints(env, &bindable, constraints);
    }

    // Worklist fixpoint over one constraint list: repeatedly classify the
    // earliest pending constraint that is ready — it can solve for at
    // most one unknown part, and no eval read of an unbound slot that
    // another pending constraint could still bind. A constraint that
    // cannot run yet waits; binding is monotone, so a ready constraint
    // never becomes unready and the greedy pick is safe. When nothing is
    // ready the earliest pending constraint is classified anyway, which
    // reproduces the textual walk and its diagnostics for
    // underdetermined sets (`[...A, ...B]`: extra_unbound_part) and
    // cyclic sets (`[A + Inc(B), B + Inc(A)]`: accepted, a runtime
    // error, matching can-binding; cycles become compile errors when
    // goal binding becomes the reporter). The list is reordered in place
    // to the schedule; for every constraint set the textual walk
    // accepts, the earliest-ready tie-break reproduces source order
    // exactly. Producers are only visible within one list: a read
    // satisfiable only by an outer or sibling scope's constraint does
    // not delay, which is never wrong, only conservative.
    fn scheduleConstraints(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        constraints: []Ast.Constraint,
    ) Allocator.Error!void {
        if (constraints.len <= 1) {
            for (constraints) |*constraint| try self.classifyConstraint(env, bindable, constraint);
            return;
        }

        const n = constraints.len;
        const producers = try self.allocator.alloc(SlotSet, n);
        for (producers, 0..) |*set, i| {
            set.* = SlotSet.initEmpty();
            self.collectBindable(constraints[i .. i + 1], set);
        }
        const scheduled = try self.allocator.alloc(bool, n);
        @memset(scheduled, false);
        const order = try self.allocator.alloc(u32, n);

        var count: usize = 0;
        while (count < n) : (count += 1) {
            var pick: ?usize = null;
            for (constraints, 0..) |constraint, i| {
                if (scheduled[i]) continue;
                if (self.constraintReady(env, constraints, producers, scheduled, i, constraint)) {
                    pick = i;
                    break;
                }
            }
            if (pick == null) {
                for (scheduled, 0..) |done, i| {
                    if (!done) {
                        pick = i;
                        break;
                    }
                }
            }
            const index = pick.?;
            scheduled[index] = true;
            order[count] = @intCast(index);
            try self.classifyConstraint(env, bindable, &constraints[index]);
        }

        for (order, 0..) |src, dst| {
            if (src != dst) break;
        } else return;
        const temp = try self.allocator.alloc(Ast.Constraint, n);
        for (order, 0..) |src, dst| temp[dst] = constraints[src];
        @memcpy(constraints, temp);
    }

    fn constraintReady(
        self: *Analyzer,
        env: *const Env,
        constraints: []const Ast.Constraint,
        producers: []const SlotSet,
        scheduled: []const bool,
        index: usize,
        constraint: Ast.Constraint,
    ) bool {
        // Evals that run, run in source order relative to each other.
        if (constraint.kind == .eval_eq) {
            for (constraints[0..index], 0..) |earlier, i| {
                if (!scheduled[i] and earlier.kind == .eval_eq) return false;
            }
        }

        var reads = SlotSet.initEmpty();
        self.collectEvalReads(constraint, &reads);
        var iter = reads.iterator(.{});
        while (iter.next()) |slot| {
            if (env.slots[slot].state != .unbound) continue;
            for (producers, 0..) |producer, i| {
                if (i != index and !scheduled[i] and producer.isSet(slot)) return false;
            }
        }

        return self.countSolvableParts(env, constraint) <= 1;
    }

    // How many parts the constraint would have to solve for, judged
    // against the current env the same way can-binding's
    // checkOneUnboundPart judges parts before classifying them: an
    // unbound bare local or a placeholder needs solving; evaluable
    // expressions and structural sub-patterns never do.
    fn countSolvableParts(self: *Analyzer, env: *const Env, constraint: Ast.Constraint) u32 {
        var count: u32 = 0;
        switch (constraint.kind) {
            .solve_merge => |merge| for (merge.parts.items) |part| {
                if (self.partIsSolvable(env, part)) count += 1;
            },
            .match_template => |template| for (template.segments.items) |segment| switch (segment) {
                .literal => {},
                .part => |part| if (self.partIsSolvable(env, part)) {
                    count += 1;
                },
            },
            else => {},
        }
        return count;
    }

    fn partIsSolvable(self: *Analyzer, env: *const Env, part: Ast.Part) bool {
        return switch (part) {
            .placeholder, .bind => true,
            .read, .global, .expr, .sub => false,
            .local => |name| blk: {
                const slot = self.patternSlot(name) orelse break :blk false;
                break :blk env.slots[slot].state != .bound;
            },
        };
    }

    fn partUnboundName(self: *Analyzer, part: Ast.Part) ?Strings.Id {
        return switch (part) {
            .local => |name| self.frontend.paths.single(name),
            .bind => |local| self.frontend.paths.single(local.name),
            else => null,
        };
    }

    // The one-unbound-part rule, judged pre-classification like
    // can-binding: the first solvable part is the one the solver will
    // solve for; every further solvable part is a compile error. Returns
    // the solvable index for solve_merge to record.
    fn checkSolvableParts(
        self: *Analyzer,
        env: *const Env,
        constraint: Ast.Constraint,
        region: Region,
    ) !?u32 {
        var solvable: ?u32 = null;
        switch (constraint.kind) {
            .solve_merge => |merge| for (merge.parts.items, 0..) |part, index| {
                if (!self.partIsSolvable(env, part)) continue;
                if (solvable == null) {
                    solvable = @intCast(index);
                } else {
                    try self.diagnose(region, self.partUnboundName(part), .extra_unbound_part);
                }
            },
            .match_template => |template| for (template.segments.items) |segment| switch (segment) {
                .literal => {},
                .part => |part| {
                    if (!self.partIsSolvable(env, part)) continue;
                    if (solvable == null) {
                        solvable = 0;
                    } else {
                        try self.diagnose(region, self.partUnboundName(part), .extra_unbound_part);
                    }
                },
            },
            else => unreachable,
        }
        return solvable;
    }

    // Slots a constraint reads in evaluated positions: eval_eq
    // expressions, expression parts, and the evaluated interior of
    // compound range limits (whose bare locals bind rather than read).
    fn collectEvalReads(self: *Analyzer, constraint: Ast.Constraint, set: *SlotSet) void {
        switch (constraint.kind) {
            .is_type, .len_eq, .len_min, .str_prefix, .str_suffix, .keys_exact, .keys_min, .has_key => {},
            .eq_const, .eq_places, .local, .bind, .eq_slot, .eq_global => {},
            .eval_eq => |eval| self.collectExprSlots(eval.expr, set),
            .in_range => |range| {
                self.collectLimitEvalReads(range.lower, set);
                self.collectLimitEvalReads(range.upper, set);
            },
            .negated => |negated| self.collectPartEvalReads(negated.part, set),
            .solve_merge => |merge| for (merge.parts.items) |part| {
                self.collectPartEvalReads(part, set);
            },
            .match_template => |template| for (template.segments.items) |segment| switch (segment) {
                .literal => {},
                .part => |part| self.collectPartEvalReads(part, set),
            },
            .solve_repeat => |repeat| {
                self.collectPartEvalReads(repeat.pattern, set);
                self.collectPartEvalReads(repeat.count, set);
            },
            .search_key => |search| {
                for (self.ast.constraint_sets.items[search.key].constraints.items) |sub| {
                    self.collectEvalReads(sub, set);
                }
                for (self.ast.constraint_sets.items[search.value].constraints.items) |sub| {
                    self.collectEvalReads(sub, set);
                }
            },
        }
    }

    fn collectPartEvalReads(self: *Analyzer, part: Ast.Part, set: *SlotSet) void {
        switch (part) {
            .placeholder, .local, .bind, .read, .global => {},
            .expr => |expr| self.collectExprSlots(expr, set),
            .sub => |set_id| for (self.ast.constraint_sets.items[set_id].constraints.items) |sub| {
                self.collectEvalReads(sub, set);
            },
        }
    }

    fn collectLimitEvalReads(self: *Analyzer, limit: Ast.Limit, set: *SlotSet) void {
        switch (limit) {
            .none, .local, .bind, .read, .global => {},
            .expr => |expr| self.collectLimitExprEvalReads(expr, set),
        }
    }

    fn collectLimitExprEvalReads(self: *Analyzer, id: Ast.NodeId, set: *SlotSet) void {
        switch (self.ast.goals.items[id].node) {
            // A bare local in a compound limit binds (the limit solves
            // for it), so it is not a read.
            .ident => {},
            .merge => |merge| {
                self.collectLimitExprEvalReads(merge.left, set);
                self.collectLimitExprEvalReads(merge.right, set);
            },
            .neg => |inner| self.collectLimitExprEvalReads(inner, set),
            else => self.collectExprSlots(id, set),
        }
    }

    fn classifyConstraint(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        constraint: *Ast.Constraint,
    ) Allocator.Error!void {
        const region = constraint.region;
        switch (constraint.kind) {
            .is_type, .len_eq, .len_min, .str_prefix, .str_suffix, .keys_exact, .keys_min, .has_key, .eq_const, .eq_places => {},
            .bind, .eq_slot, .eq_global => unreachable,
            .local => |occ| try self.classifyLocalConstraint(env, constraint, occ, region),
            .eval_eq => |eval| try self.walkPatternExpr(env, bindable, eval.expr),
            .in_range => |*range| {
                try self.classifyLimit(env, bindable, &range.lower, region);
                try self.classifyLimit(env, bindable, &range.upper, region);
            },
            .negated => |*negated| try self.classifyPart(env, bindable, &negated.part, region),
            .solve_merge => |*merge| {
                merge.solvable_index = try self.checkSolvableParts(env, constraint.*, region);
                for (merge.parts.items) |*part| {
                    try self.classifyPart(env, bindable, part, region);
                }
            },
            .match_template => |*template| {
                _ = try self.checkSolvableParts(env, constraint.*, region);
                for (template.segments.items) |*segment| {
                    switch (segment.*) {
                        .literal => {},
                        .part => |*part| try self.classifyPart(env, bindable, part, region),
                    }
                }
            },
            .solve_repeat => |*repeat| {
                try self.classifyPart(env, bindable, &repeat.pattern, region);
                try self.classifyPart(env, bindable, &repeat.count, region);
            },
            .search_key => |search| {
                try self.scheduleConstraints(
                    env,
                    bindable,
                    self.ast.constraint_sets.items[search.key].constraints.items,
                );
                try self.scheduleConstraints(
                    env,
                    bindable,
                    self.ast.constraint_sets.items[search.value].constraints.items,
                );
            },
        }
    }

    fn classifyLocalConstraint(
        self: *Analyzer,
        env: *Env,
        constraint: *Ast.Constraint,
        occ: anytype,
        region: Region,
    ) !void {
        if (try self.classifyOccurrence(env, occ.name, region)) |classified| {
            constraint.kind = switch (classified) {
                .bind => |slot| .{ .bind = .{ .place = occ.place, .slot = slot, .name = occ.name } },
                .read => |slot| .{ .eq_slot = .{ .place = occ.place, .slot = slot, .name = occ.name } },
            };
        } else {
            constraint.kind = .{ .eq_global = .{ .place = occ.place, .name = occ.name } };
        }
    }

    const Occurrence = union(enum) { bind: u8, read: u8 };

    // A bare-variable pattern occurrence: null means a global reference
    // (or a dotted name, which is never a local); otherwise the
    // occurrence binds when unbound and compares when bound. A split
    // variable is a compile error and rebinds to stop the cascade.
    fn classifyOccurrence(
        self: *Analyzer,
        env: *Env,
        name: Paths.Id,
        region: Region,
    ) !?Occurrence {
        if (self.patternGlobal(name)) return null;
        const segment = self.frontend.paths.single(name) orelse return null;
        const slot = (try self.resolveLocal(env, segment)) orelse return null;
        const state = &env.slots[slot];
        switch (state.state) {
            .bound => return .{ .read = slot },
            .unbound => {
                state.* = .{ .state = .bound, .stale = false };
                return .{ .bind = slot };
            },
            .split => {
                try self.diagnose(region, segment, .split);
                state.* = .{ .state = .bound, .stale = false };
                return .{ .bind = slot };
            },
        }
    }

    fn classifyPart(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        part: *Ast.Part,
        region: Region,
    ) Allocator.Error!void {
        switch (part.*) {
            .placeholder, .bind, .read, .global => {},
            .local => |name| {
                part.* = if (try self.classifyOccurrence(env, name, region)) |classified|
                    switch (classified) {
                        .bind => |slot| .{ .bind = .{ .slot = slot, .name = name } },
                        .read => |slot| .{ .read = .{ .slot = slot, .name = name } },
                    }
                else
                    .{ .global = name };
            },
            .expr => |expr| try self.walkPatternExpr(env, bindable, expr),
            .sub => |set_id| try self.scheduleConstraints(
                env,
                bindable,
                self.ast.constraint_sets.items[set_id].constraints.items,
            ),
        }
    }

    fn classifyLimit(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        limit: *Ast.Limit,
        region: Region,
    ) Allocator.Error!void {
        switch (limit.*) {
            .none, .bind, .read, .global => {},
            .local => |name| {
                limit.* = if (try self.classifyOccurrence(env, name, region)) |classified|
                    switch (classified) {
                        .bind => |slot| .{ .bind = .{ .slot = slot, .name = name } },
                        .read => |slot| .{ .read = .{ .slot = slot, .name = name } },
                    }
                else
                    .{ .global = name };
            },
            .expr => |expr| try self.walkLimitExpr(env, bindable, expr),
        }
    }

    // A compound range limit is a pattern position: its bare locals are
    // occurrences that bind when unbound (the decided semantics solve
    // the limit for them), while calls inside it stay evaluated.
    fn walkLimitExpr(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        id: Ast.NodeId,
    ) Allocator.Error!void {
        const rnode = &self.ast.goals.items[id];
        switch (rnode.node) {
            .ident => |*ident| {
                if (self.isPlaceholder(ident.name)) {
                    ident.resolution = .placeholder;
                    return;
                }
                if (try self.classifyOccurrence(env, ident.name, rnode.region)) |classified| {
                    ident.resolution = .{ .local = switch (classified) {
                        .bind, .read => |slot| slot,
                    } };
                } else {
                    ident.resolution = .global;
                }
            },
            .merge => |merge| {
                try self.walkLimitExpr(env, bindable, merge.left);
                try self.walkLimitExpr(env, bindable, merge.right);
            },
            .neg => |inner| try self.walkLimitExpr(env, bindable, inner),
            else => try self.walkPatternExpr(env, bindable, id),
        }
    }

    // Evaluated expressions inside patterns: call callees, call
    // arguments, and range limits. Their variables are never solved for,
    // so each must be bound already or have a binding occurrence
    // elsewhere in the pattern.
    fn walkPatternExpr(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        id: Ast.NodeId,
    ) Allocator.Error!void {
        const rnode = &self.ast.goals.items[id];
        switch (rnode.node) {
            .true, .false, .null, .string, .number_string, .number_float => {},
            .ident => |*ident| try self.patternExprIdent(env, bindable, ident, rnode.region),
            .call => |call| {
                try self.walkPatternExpr(env, bindable, call.callee);
                for (call.args) |arg| try self.walkPatternExpr(env, bindable, arg);
            },
            .neg, .to_string => |inner| try self.walkPatternExpr(env, bindable, inner),
            .merge => |merge| {
                try self.walkPatternExpr(env, bindable, merge.left);
                try self.walkPatternExpr(env, bindable, merge.right);
            },
            .mult => |mult| {
                try self.walkPatternExpr(env, bindable, mult.left);
                try self.walkPatternExpr(env, bindable, mult.right);
            },
            .array => |elems| for (elems.items) |elem| try self.walkPatternExpr(env, bindable, elem),
            .object => |pairs| for (pairs.items) |pair| {
                try self.walkPatternExpr(env, bindable, pair.key);
                try self.walkPatternExpr(env, bindable, pair.value);
            },
            .range => |range| {
                if (range.lower) |lower| try self.walkPatternExpr(env, bindable, lower);
                if (range.upper) |upper| try self.walkPatternExpr(env, bindable, upper);
            },
            .lambda => |*lambda| try self.analyzeLambda(env, lambda, rnode.region),
            .seq, .alt, .match, .repeat => try self.analyzeGoal(env, id),
        }
    }

    fn patternExprIdent(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        ident: *Ast.Ident,
        region: Region,
    ) !void {
        if (self.isPlaceholder(ident.name)) {
            ident.resolution = .placeholder;
            return self.diagnose(region, self.frontend.paths.single(ident.name), .unbound_function_var);
        }
        if (self.patternGlobal(ident.name)) {
            ident.resolution = .global;
            return;
        }
        const segment = self.frontend.paths.single(ident.name) orelse {
            ident.resolution = .global;
            return;
        };
        const slot = (try self.resolveLocal(env, segment)) orelse {
            ident.resolution = .global;
            return;
        };

        const state = &env.slots[slot];
        switch (state.state) {
            .bound => {},
            .unbound => if (!bindable.isSet(slot)) {
                try self.diagnose(region, segment, .unbound_function_var);
            },
            .split => if (bindable.isSet(slot)) {
                try self.diagnose(region, segment, .split);
            } else {
                try self.diagnose(region, segment, .unbound_function_var);
            },
        }

        // Treat as bound afterward: either another occurrence binds it
        // or compilation already failed.
        state.* = .{ .state = .bound, .stale = false };
        ident.resolution = .{ .local = slot };
    }

    // Every slot an occurrence in this constraint list can bind: all
    // local occurrences except evaluated positions.
    fn collectBindable(self: *Analyzer, constraints: []const Ast.Constraint, set: *SlotSet) void {
        for (constraints) |constraint| {
            switch (constraint.kind) {
                .is_type, .len_eq, .len_min, .str_prefix, .str_suffix, .keys_exact, .keys_min, .has_key => {},
                .eq_const, .eq_places, .eval_eq => {},
                .bind, .eq_slot, .eq_global => {},
                .local => |occ| if (self.patternSlot(occ.name)) |slot| set.set(slot),
                .in_range => |range| {
                    self.collectBindableLimit(range.lower, set);
                    self.collectBindableLimit(range.upper, set);
                },
                .negated => |negated| self.collectBindablePart(negated.part, set),
                .solve_merge => |merge| for (merge.parts.items) |part| {
                    self.collectBindablePart(part, set);
                },
                .match_template => |template| for (template.segments.items) |segment| {
                    switch (segment) {
                        .literal => {},
                        .part => |part| self.collectBindablePart(part, set),
                    }
                },
                .solve_repeat => |repeat| {
                    self.collectBindablePart(repeat.pattern, set);
                    self.collectBindablePart(repeat.count, set);
                },
                .search_key => |search| {
                    self.collectBindable(self.ast.constraint_sets.items[search.key].constraints.items, set);
                    self.collectBindable(self.ast.constraint_sets.items[search.value].constraints.items, set);
                },
            }
        }
    }

    fn collectBindablePart(self: *Analyzer, part: Ast.Part, set: *SlotSet) void {
        switch (part) {
            .placeholder, .expr, .bind, .read, .global => {},
            .local => |name| if (self.patternSlot(name)) |slot| set.set(slot),
            .sub => |set_id| self.collectBindable(
                self.ast.constraint_sets.items[set_id].constraints.items,
                set,
            ),
        }
    }

    fn collectBindableLimit(self: *Analyzer, limit: Ast.Limit, set: *SlotSet) void {
        switch (limit) {
            .none, .bind, .read, .global => {},
            .local => |name| if (self.patternSlot(name)) |slot| set.set(slot),
            .expr => |expr| self.collectBindableLimitExpr(expr, set),
        }
    }

    fn collectBindableLimitExpr(self: *Analyzer, id: Ast.NodeId, set: *SlotSet) void {
        switch (self.ast.goals.items[id].node) {
            .ident => |ident| if (self.patternSlot(ident.name)) |slot| set.set(slot),
            .merge => |merge| {
                self.collectBindableLimitExpr(merge.left, set);
                self.collectBindableLimitExpr(merge.right, set);
            },
            .neg => |inner| self.collectBindableLimitExpr(inner, set),
            else => {},
        }
    }

    // Every slot the subtree's destructures may write, evaluated
    // positions included (they mark their variables bound), for repeat
    // body scoping. Lambdas are separate frames and are skipped.
    fn collectGoalBinds(self: *Analyzer, id: Ast.NodeId, set: *SlotSet) void {
        switch (self.ast.goals.items[id].node) {
            .true, .false, .null, .string, .number_string, .number_float, .ident, .lambda => {},
            .call => |call| {
                self.collectGoalBinds(call.callee, set);
                for (call.args) |arg| self.collectGoalBinds(arg, set);
            },
            .seq => |seq| for (seq.goals.items) |goal| self.collectGoalBinds(goal, set),
            .merge => |merge| {
                self.collectGoalBinds(merge.left, set);
                self.collectGoalBinds(merge.right, set);
            },
            .mult => |mult| {
                self.collectGoalBinds(mult.left, set);
                self.collectGoalBinds(mult.right, set);
            },
            .neg, .to_string => |inner| self.collectGoalBinds(inner, set),
            .range => |range| {
                if (range.lower) |lower| self.collectGoalBinds(lower, set);
                if (range.upper) |upper| self.collectGoalBinds(upper, set);
            },
            .array => |elems| for (elems.items) |elem| self.collectGoalBinds(elem, set),
            .object => |pairs| for (pairs.items) |pair| {
                self.collectGoalBinds(pair.key, set);
                self.collectGoalBinds(pair.value, set);
            },
            .alt => |arms| for (arms.items) |arm| {
                if (arm.guard) |guard| self.collectGoalBinds(guard, set);
                if (arm.body) |body| self.collectGoalBinds(body, set);
            },
            .match => |match| {
                self.collectGoalBinds(match.scrutinee, set);
                for (match.arms.items) |arm| {
                    self.collectPatternSlots(arm.constraints.items, set);
                    if (arm.guard) |guard| self.collectGoalBinds(guard, set);
                    if (arm.body) |body| self.collectGoalBinds(body, set);
                }
            },
            .repeat => |repeat| {
                self.collectGoalBinds(repeat.body, set);
                if (repeat.count_test) |set_id| {
                    self.collectPatternSlots(
                        self.ast.constraint_sets.items[set_id].constraints.items,
                        set,
                    );
                }
            },
        }
    }

    fn collectPatternSlots(self: *Analyzer, constraints: []const Ast.Constraint, set: *SlotSet) void {
        for (constraints) |constraint| {
            switch (constraint.kind) {
                .is_type, .len_eq, .len_min, .str_prefix, .str_suffix, .keys_exact, .keys_min, .has_key => {},
                .eq_const, .eq_places => {},
                .bind, .eq_slot, .eq_global => {},
                .local => |occ| if (self.patternSlot(occ.name)) |slot| set.set(slot),
                .eval_eq => |eval| self.collectExprSlots(eval.expr, set),
                .in_range => |range| {
                    self.collectPatternLimitSlots(range.lower, set);
                    self.collectPatternLimitSlots(range.upper, set);
                },
                .negated => |negated| self.collectPatternPartSlots(negated.part, set),
                .solve_merge => |merge| for (merge.parts.items) |part| {
                    self.collectPatternPartSlots(part, set);
                },
                .match_template => |template| for (template.segments.items) |segment| {
                    switch (segment) {
                        .literal => {},
                        .part => |part| self.collectPatternPartSlots(part, set),
                    }
                },
                .solve_repeat => |repeat| {
                    self.collectPatternPartSlots(repeat.pattern, set);
                    self.collectPatternPartSlots(repeat.count, set);
                },
                .search_key => |search| {
                    self.collectPatternSlots(self.ast.constraint_sets.items[search.key].constraints.items, set);
                    self.collectPatternSlots(self.ast.constraint_sets.items[search.value].constraints.items, set);
                },
            }
        }
    }

    fn collectPatternPartSlots(self: *Analyzer, part: Ast.Part, set: *SlotSet) void {
        switch (part) {
            .placeholder, .bind, .read, .global => {},
            .local => |name| if (self.patternSlot(name)) |slot| set.set(slot),
            .expr => |expr| self.collectExprSlots(expr, set),
            .sub => |set_id| self.collectPatternSlots(
                self.ast.constraint_sets.items[set_id].constraints.items,
                set,
            ),
        }
    }

    fn collectPatternLimitSlots(self: *Analyzer, limit: Ast.Limit, set: *SlotSet) void {
        switch (limit) {
            .none, .bind, .read, .global => {},
            .local => |name| if (self.patternSlot(name)) |slot| set.set(slot),
            .expr => |expr| self.collectExprSlots(expr, set),
        }
    }

    fn collectExprSlots(self: *Analyzer, id: Ast.NodeId, set: *SlotSet) void {
        switch (self.ast.goals.items[id].node) {
            .ident => |ident| if (self.patternSlot(ident.name)) |slot| set.set(slot),
            .call => |call| {
                self.collectExprSlots(call.callee, set);
                for (call.args) |arg| self.collectExprSlots(arg, set);
            },
            .neg, .to_string => |inner| self.collectExprSlots(inner, set),
            .merge => |merge| {
                self.collectExprSlots(merge.left, set);
                self.collectExprSlots(merge.right, set);
            },
            .mult => |mult| {
                self.collectExprSlots(mult.left, set);
                self.collectExprSlots(mult.right, set);
            },
            .array => |elems| for (elems.items) |elem| self.collectExprSlots(elem, set),
            .object => |pairs| for (pairs.items) |pair| {
                self.collectExprSlots(pair.key, set);
                self.collectExprSlots(pair.value, set);
            },
            .range => |range| {
                if (range.lower) |lower| self.collectExprSlots(lower, set);
                if (range.upper) |upper| self.collectExprSlots(upper, set);
            },
            else => {},
        }
    }
};

// Debug-only post-conditions: no neutral occurrence survives the bound
// stage on any reachable goal, and every lambda's computed capture set
// matches the dependency graph's.
pub fn verifyModule(frontend: *Frontend, module_id: Module.Id, ast: *const Ast) void {
    if (!std.debug.runtime_safety) return;
    var verifier = Verifier{ .frontend = frontend, .module_id = module_id, .ast = ast };
    for (ast.declarations.items) |decl| verifier.verifyGoal(decl.body);
    if (ast.main) |main_id| verifier.verifyGoal(main_id);
}

const Verifier = struct {
    frontend: *Frontend,
    module_id: Module.Id,
    ast: *const Ast,

    fn fail(self: *const Verifier, comptime message: []const u8, name: Paths.Id) noreturn {
        std.debug.print("goal binding: " ++ message ++ ": {s}\n", .{self.frontend.pathString(name)});
        @panic("goal binding post-condition failed");
    }

    fn verifyGoal(self: *const Verifier, id: Ast.NodeId) void {
        switch (self.ast.goals.items[id].node) {
            .true, .false, .null, .string, .number_string, .number_float => {},
            .ident => |ident| if (ident.resolution == .unresolved) {
                self.fail("unresolved ident survived binding", ident.name);
            },
            .call => |call| {
                self.verifyGoal(call.callee);
                for (call.args) |arg| self.verifyGoal(arg);
            },
            .lambda => |lambda| {
                self.verifyCaptures(lambda);
                self.verifyGoal(lambda.body);
            },
            .seq => |seq| for (seq.goals.items) |goal| self.verifyGoal(goal),
            .merge => |merge| {
                self.verifyGoal(merge.left);
                self.verifyGoal(merge.right);
            },
            .mult => |mult| {
                self.verifyGoal(mult.left);
                self.verifyGoal(mult.right);
            },
            .neg, .to_string => |inner| self.verifyGoal(inner),
            .range => |range| {
                if (range.lower) |lower| self.verifyGoal(lower);
                if (range.upper) |upper| self.verifyGoal(upper);
            },
            .array => |elems| for (elems.items) |elem| self.verifyGoal(elem),
            .object => |pairs| for (pairs.items) |pair| {
                self.verifyGoal(pair.key);
                self.verifyGoal(pair.value);
            },
            .alt => |arms| for (arms.items) |arm| {
                if (arm.guard) |guard| self.verifyGoal(guard);
                if (arm.body) |body| self.verifyGoal(body);
            },
            .match => |match| {
                self.verifyGoal(match.scrutinee);
                for (match.arms.items) |arm| {
                    self.verifyConstraints(arm.constraints.items);
                    if (arm.guard) |guard| self.verifyGoal(guard);
                    if (arm.body) |body| self.verifyGoal(body);
                }
            },
            .repeat => |repeat| {
                self.verifyGoal(repeat.body);
                self.verifyLimit(repeat.cap);
                if (repeat.count_test) |set_id| {
                    self.verifyConstraints(self.ast.constraint_sets.items[set_id].constraints.items);
                }
            },
        }
    }

    fn verifyCaptures(self: *const Verifier, lambda: Ast.Lambda) void {
        const node = self.frontend.findNode(self.module_id, lambda.name).?;
        const graph_captures = node.anonymous_function.closure_captures.items;

        var mismatch = lambda.captures.items.len != graph_captures.len;
        if (!mismatch) {
            for (graph_captures) |capture| {
                var found = false;
                for (lambda.captures.items) |segment| {
                    if (segment == capture.local) {
                        found = true;
                        break;
                    }
                }
                if (!found) mismatch = true;
            }
        }
        if (mismatch) {
            self.fail("capture set diverges from dependency graph", lambda.name);
        }
    }

    fn verifyConstraints(self: *const Verifier, constraints: []const Ast.Constraint) void {
        for (constraints) |constraint| {
            switch (constraint.kind) {
                .is_type, .len_eq, .len_min, .str_prefix, .str_suffix, .keys_exact, .keys_min, .has_key, .eq_places => {},
                .bind, .eq_slot, .eq_global => {},
                .eq_const => |eq| self.verifyGoal(eq.value),
                .local => |occ| self.fail("neutral local survived binding", occ.name),
                .eval_eq => |eval| self.verifyGoal(eval.expr),
                .in_range => |range| {
                    self.verifyLimit(range.lower);
                    self.verifyLimit(range.upper);
                },
                .negated => |negated| self.verifyPart(negated.part),
                .solve_merge => |merge| for (merge.parts.items) |part| {
                    self.verifyPart(part);
                    if (part == .bind and merge.solvable_index == null) {
                        self.fail("merge binds a part but has no solvable_index", part.bind.name);
                    }
                },
                .match_template => |template| for (template.segments.items) |segment| {
                    switch (segment) {
                        .literal => {},
                        .part => |part| self.verifyPart(part),
                    }
                },
                .solve_repeat => |repeat| {
                    self.verifyPart(repeat.pattern);
                    self.verifyPart(repeat.count);
                },
                .search_key => |search| {
                    self.verifyConstraints(self.ast.constraint_sets.items[search.key].constraints.items);
                    self.verifyConstraints(self.ast.constraint_sets.items[search.value].constraints.items);
                },
            }
        }
    }

    fn verifyPart(self: *const Verifier, part: Ast.Part) void {
        switch (part) {
            .placeholder, .bind, .read, .global => {},
            .local => |name| self.fail("neutral local part survived binding", name),
            .expr => |expr| self.verifyGoal(expr),
            .sub => |set_id| self.verifyConstraints(self.ast.constraint_sets.items[set_id].constraints.items),
        }
    }

    fn verifyLimit(self: *const Verifier, limit: Ast.Limit) void {
        switch (limit) {
            .none, .bind, .read, .global => {},
            .local => |name| self.fail("neutral local limit survived binding", name),
            .expr => |expr| self.verifyGoal(expr),
        }
    }
};

const std = @import("std");
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const match_plan = @import("match_plan.zig");
const MatchPlan = match_plan.MatchPlan;
const LocalVar = match_plan.LocalVar;

pub const Error = error{
    RuntimeError,
    OutOfMemory,
} || VM.Error;

// Interpreter for compiled match plans. Runs directly against the VM with no
// PatternSolver bookkeeping: bind-vs-equality is decided statically, so there
// is no runtime boundness probing, and a failed match leaves its binds in
// place. Binding analysis guarantees stale slots are never read and emits
// preclears before any pattern that may re-bind them.
pub fn match(vm: *VM, value: Elem, plan: MatchPlan) Error!bool {
    // Prevent GC of dyns created while a bound_eq evaluates a zero-arity
    // function on the VM.
    const temp_dyns_start = vm.temp_dyns.items.len;
    defer vm.clearTempDyns(temp_dyns_start);

    return matchNode(vm, value, plan, 0);
}

fn matchNode(vm: *VM, value: Elem, plan: MatchPlan, idx: u32) Error!bool {
    const node = plan.nodes[idx];

    switch (node.tag) {
        .placeholder => return true,
        .equality => return value.isEql(plan.elems[node.payload], vm.*),
        .bind => {
            const local_idx = plan.vars[node.payload].idx;
            // The slot takes a second handle; the value also stays on the
            // stack. The slot's previous handle dies: usually a placeholder
            // var, but possibly a stale value left by an earlier failed
            // match.
            const previous = vm.getLocal(local_idx);
            value.retain();
            vm.setLocal(local_idx, value);
            previous.release();
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

            var child = idx + 1;
            for (value_array.elems.items) |element| {
                if (!(try matchNode(vm, element, plan, child))) return false;
                child += plan.nodes[child].subtree_len;
            }
            return true;
        },
        .object => {
            if (!value.isDynType(.Object)) return false;
            const value_object = value.asDyn().asObject();
            if (value_object.members.count() != node.payload) return false;

            // No matched-key bookkeeping: it only guards the tree path's
            // unbound-key search. Duplicate literal keys just re-probe, the
            // same members the tree path tolerates re-matching.
            var pair = idx + 1;
            for (0..node.payload) |_| {
                const key_node = plan.nodes[pair];
                std.debug.assert(key_node.tag == .const_key);
                const member = value_object.members.get(plan.sids[key_node.payload]) orelse
                    return false;
                if (!(try matchNode(vm, member, plan, pair + 1))) return false;
                pair += key_node.subtree_len;
            }
            return true;
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
    }
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

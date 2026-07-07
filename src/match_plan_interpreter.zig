const std = @import("std");
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const MatchPlan = @import("match_plan.zig").MatchPlan;

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
            const pattern_var = plan.vars[node.payload];
            // The slot takes a second handle; the value also stays on the
            // stack. The slot's previous handle dies: usually a placeholder
            // var, but possibly a stale value left by an earlier failed
            // match.
            const previous = vm.getLocal(pattern_var.idx);
            value.retain();
            vm.setLocal(pattern_var.idx, value);
            previous.release();
            return true;
        },
        .bound_eq => {
            const pattern_var = plan.vars[node.payload];
            var pattern_value = vm.getLocal(pattern_var.idx);

            if (pattern_value.isDynType(.Function)) {
                const function = pattern_value.asDyn().asFunction();
                // Must be zero-arity, since it was not called with args.
                if (function.arity != 0) return error.RuntimeError;
                pattern_value = try executeFunctionOnVM(vm, pattern_value);
            }

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
    }
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

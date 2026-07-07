const std = @import("std");
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const PatternSolver = @import("pattern_solver.zig");
const MatchPlan = @import("match_plan.zig").MatchPlan;

// Interpreter for compiled match plans. Mirrors PatternSolver.match's
// bookkeeping: binds route through solver.setLocal so a failure after a
// bind resets the touched slots and releases their handles.
pub fn match(solver: *PatternSolver, value: Elem, plan: MatchPlan) PatternSolver.Error!bool {
    const vm = solver.vm;

    // Prevent GC of dyns created while a bound_eq evaluates a zero-arity
    // function on the VM.
    const temp_dyns_start = vm.temp_dyns.items.len;
    defer vm.clearTempDyns(temp_dyns_start);

    // Function evaluation re-enters the VM and can nest another match, so
    // restore rather than clear.
    const bound_locals_base = solver.bound_locals.items.len;
    defer solver.bound_locals.shrinkRetainingCapacity(bound_locals_base);

    const success = try matchNode(solver, value, plan, 0);

    if (!success) {
        try solver.resetLocals(bound_locals_base);
    }

    return success;
}

fn matchNode(solver: *PatternSolver, value: Elem, plan: MatchPlan, idx: u32) PatternSolver.Error!bool {
    const vm = solver.vm;
    const node = plan.nodes[idx];

    switch (node.tag) {
        .placeholder => return true,
        .equality => return solver.checkEquality(value, plan.elems[node.payload]),
        .bind => {
            const pattern_var = plan.vars[node.payload];
            std.debug.assert(vm.getLocal(pattern_var.idx).isType(.ValueVar));
            try solver.setLocal(pattern_var, value);
            return true;
        },
        .bound_eq => {
            const pattern_var = plan.vars[node.payload];
            var pattern_value = vm.getLocal(pattern_var.idx);

            if (pattern_value.isDynType(.Function)) {
                const function = pattern_value.asDyn().asFunction();
                if (function.arity != 0) return error.RuntimeError;
                pattern_value = try solver.executeFunctionOnVM(
                    Pattern{ .Local = pattern_var },
                    pattern_value,
                    null,
                );
            }

            return solver.checkEquality(value, pattern_value);
        },
        .array => {
            if (!value.isDynType(.Array)) return false;
            const value_array = value.asDyn().asArray();
            if (value_array.elems.items.len != node.payload) return false;

            var child = idx + 1;
            for (value_array.elems.items) |element| {
                if (!(try matchNode(solver, element, plan, child))) return false;
                child += plan.nodes[child].subtree_len;
            }
            return true;
        },
    }
}

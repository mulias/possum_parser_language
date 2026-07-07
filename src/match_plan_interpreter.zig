const std = @import("std");
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const PatternSolver = @import("pattern_solver.zig");
const MatchPlan = @import("match_plan.zig").MatchPlan;

// Interpreter for compiled match plans. No bound_locals, discardable_root,
// or depth bookkeeping: a single-node plan has no intra-match backtracking,
// since a bind cannot be followed by a failure.
pub fn match(solver: *PatternSolver, value: Elem, plan: MatchPlan) PatternSolver.Error!bool {
    const vm = solver.vm;

    // Prevent GC of dyns created while a bound_eq evaluates a zero-arity
    // function on the VM.
    const temp_dyns_start = vm.temp_dyns.items.len;
    defer vm.clearTempDyns(temp_dyns_start);

    const root = plan.nodes[0];
    switch (root.tag) {
        .placeholder => return true,
        .equality => return solver.checkEquality(value, plan.elems[root.payload]),
        .bind => {
            const pattern_var = plan.vars[root.payload];
            std.debug.assert(vm.getLocal(pattern_var.idx).isType(.ValueVar));
            // The slot takes a second handle; the value also stays on the
            // stack.
            value.retain();
            vm.setLocal(pattern_var.idx, value);
            return true;
        },
        .bound_eq => {
            const pattern_var = plan.vars[root.payload];
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
    }
}

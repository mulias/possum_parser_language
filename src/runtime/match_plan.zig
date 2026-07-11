const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").RuntimeStringTable;
const VM = @import("vm.zig").VM;

// Compiled destructure plan: a flat preorder node array plus interned side
// tables, produced when a pattern's binding-time work is folded at compile
// time. Patterns the lowering does not support yet stay on the Pattern tree
// path (see Compiler.tryCreateMatchPlan).
pub const MatchPlan = struct {
    nodes: []Node,
    vars: []LocalVar,
    // Constant elems compared with checkEquality. Dyn elems are immortal,
    // like module constants.
    elems: []Elem,
    // Constant object keys, interned at compile time.
    sids: []StringTable.Id,
    ranges: []RangePlan,
    merges: []MergePlan,
    calls: []CallPlan,
    repeats: []RepeatPlan,

    pub fn deinit(self: *MatchPlan, allocator: Allocator) void {
        allocator.free(self.nodes);
        allocator.free(self.vars);
        allocator.free(self.elems);
        allocator.free(self.sids);
        allocator.free(self.ranges);
        allocator.free(self.merges);
        allocator.free(self.calls);
        allocator.free(self.repeats);
    }

    pub fn print(self: MatchPlan, vm: VM, writer: *Writer) Writer.Error!void {
        _ = try self.printNode(vm, writer, 0);
    }

    // Returns the index one past the printed subtree.
    fn printNode(self: MatchPlan, vm: VM, writer: *Writer, idx: u32) Writer.Error!u32 {
        const node = self.nodes[idx];
        switch (node.tag) {
            .placeholder => try writer.print("_", .{}),
            .bind => try writer.print("bind {s}", .{
                vm.strings.get(self.vars[node.payload].sid),
            }),
            .bound_eq => try writer.print("bound_eq {s}", .{
                vm.strings.get(self.vars[node.payload].sid),
            }),
            .equality => {
                try writer.print("eq ", .{});
                try self.elems[node.payload].print(vm, writer);
            },
            .const_fn => {
                try writer.print("const_fn ", .{});
                try self.elems[node.payload].print(vm, writer);
            },
            .call => {
                const call = self.calls[node.payload];
                switch (call.callee) {
                    .constant => |elem_idx| try self.elems[elem_idx].print(vm, writer),
                    .local => |var_idx| try writer.print("{s}", .{vm.strings.get(self.vars[var_idx].sid)}),
                }
                try writer.print("(", .{});
                var arg = idx + 1;
                for (0..call.arg_count) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    arg = try self.printNode(vm, writer, arg);
                }
                try writer.print(")", .{});
                return arg;
            },
            .repeat => {
                try writer.print("(", .{});
                const pattern_idx = idx + 1;
                const count_idx = try self.printNode(vm, writer, pattern_idx);
                try writer.print(" * ", .{});
                _ = try self.printNode(vm, writer, count_idx);
                try writer.print(")", .{});
                // Skip the rebound pattern variant, if any.
                return idx + node.subtree_len;
            },
            .array => {
                try writer.print("[", .{});
                var child = idx + 1;
                for (0..node.payload) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    child = try self.printNode(vm, writer, child);
                }
                try writer.print("]", .{});
                return child;
            },
            .object => {
                try writer.print("{{", .{});
                var pair = idx + 1;
                for (0..node.payload) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    pair = try self.printNode(vm, writer, pair);
                }
                try writer.print("}}", .{});
                return pair;
            },
            .const_key => {
                try writer.print("\"{s}\": ", .{vm.strings.get(self.sids[node.payload])});
                return self.printNode(vm, writer, idx + 1);
            },
            .eval_key, .pattern_key => {
                const value_idx = try self.printNode(vm, writer, idx + 1);
                try writer.print(": ", .{});
                return self.printNode(vm, writer, value_idx);
            },
            .range => {
                const range = self.ranges[node.payload];
                var child = idx + 1;
                switch (range.lower) {
                    .eval => child = try self.printNode(vm, writer, child),
                    else => try self.printLimit(vm, writer, range.lower),
                }
                try writer.print("..", .{});
                switch (range.upper) {
                    .eval => child = try self.printNode(vm, writer, child),
                    else => try self.printLimit(vm, writer, range.upper),
                }
                return child;
            },
            .merge => {
                try writer.print("(", .{});
                var part = idx + 1;
                for (0..self.merges[node.payload].part_count) |i| {
                    if (i > 0) try writer.print(" + ", .{});
                    part = try self.printNode(vm, writer, part);
                }
                try writer.print(")", .{});
                return part;
            },
            .str_template => {
                try writer.print("tmpl(", .{});
                var segment = idx + 1;
                for (0..self.merges[node.payload].part_count) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    segment = try self.printNode(vm, writer, segment);
                }
                try writer.print(")", .{});
                return segment;
            },
            .negated => {
                if (node.payload == 1) {
                    try writer.print("negated ", .{});
                } else {
                    try writer.print("negated({d}) ", .{node.payload});
                }
                return self.printNode(vm, writer, idx + 1);
            },
        }
        return idx + 1;
    }

    fn printLimit(self: MatchPlan, vm: VM, writer: *Writer, limit: RangePlan.Limit) Writer.Error!void {
        switch (limit) {
            .none => {},
            .const_elem => |i| try self.elems[i].print(vm, writer),
            .bound_local, .bind_local => |i| try writer.print("{s}", .{vm.strings.get(self.vars[i].sid)}),
            // Rendered by the caller, which holds the child subtree index.
            .eval => unreachable,
        }
    }

    fn negativeSigns(count: u2) []const u8 {
        return switch (count) {
            0 => "",
            1 => "-",
            2 => "--",
            3 => "-",
        };
    }

    // Render a plan subtree in pattern syntax for the debug/explain reports,
    // mirroring Pattern.print case by case. Distinct from printNode above
    // (which disassembles the plan as `eq 1` / `bind A`). Returns the index
    // one past the printed subtree. Divergences from the tree rendering are
    // deliberate and documented in match_plan_reporting_plan.md: equality
    // nodes hold folded values (not source names), constant template segments
    // were stringified at lowering, and negated nested merges are flattened.
    pub fn printPatternSubtree(self: MatchPlan, vm: VM, writer: *Writer, idx: u32) Writer.Error!u32 {
        const node = self.nodes[idx];
        switch (node.tag) {
            .placeholder => try writer.print("_", .{}),
            .bind, .bound_eq => try writer.print("{s}", .{
                vm.strings.get(self.vars[node.payload].sid),
            }),
            .equality, .const_fn => try self.elems[node.payload].print(vm, writer),
            .call => {
                const call = self.calls[node.payload];
                switch (call.callee) {
                    .constant => |elem_idx| try self.elems[elem_idx].print(vm, writer),
                    .local => |var_idx| try writer.print("{s}", .{vm.strings.get(self.vars[var_idx].sid)}),
                }
                try writer.print("(", .{});
                var arg = idx + 1;
                for (0..call.arg_count) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    arg = try self.printPatternSubtree(vm, writer, arg);
                }
                try writer.print(")", .{});
                return arg;
            },
            .array => {
                try writer.print("[", .{});
                var child = idx + 1;
                for (0..node.payload) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    child = try self.printPatternSubtree(vm, writer, child);
                }
                try writer.print("]", .{});
                return child;
            },
            .object => {
                try writer.print("{{", .{});
                var pair = idx + 1;
                for (0..node.payload) |i| {
                    if (i > 0) try writer.print(", ", .{});
                    pair = try self.printPatternSubtree(vm, writer, pair);
                }
                try writer.print("}}", .{});
                return pair;
            },
            .const_key => {
                try writer.print("\"{s}\": ", .{vm.strings.get(self.sids[node.payload])});
                return self.printPatternSubtree(vm, writer, idx + 1);
            },
            .eval_key, .pattern_key => {
                const value_idx = try self.printPatternSubtree(vm, writer, idx + 1);
                try writer.print(": ", .{});
                return self.printPatternSubtree(vm, writer, value_idx);
            },
            .range => {
                const range = self.ranges[node.payload];
                var child = idx + 1;
                switch (range.lower) {
                    .eval => child = try self.printPatternSubtree(vm, writer, child),
                    else => try self.printLimit(vm, writer, range.lower),
                }
                try writer.print("..", .{});
                switch (range.upper) {
                    .eval => child = try self.printPatternSubtree(vm, writer, child),
                    else => try self.printLimit(vm, writer, range.upper),
                }
                return child;
            },
            .merge => {
                try writer.print("(", .{});
                var part = idx + 1;
                for (0..self.merges[node.payload].part_count) |i| {
                    if (i > 0) try writer.print(" + ", .{});
                    part = try self.printPatternSubtree(vm, writer, part);
                }
                try writer.print(")", .{});
                return part;
            },
            .str_template => {
                try writer.print("\"", .{});
                var segment = idx + 1;
                for (0..self.merges[node.payload].part_count) |_| {
                    const segment_node = self.nodes[segment];
                    // A folded constant segment renders its content inline,
                    // mirroring a `.String` template item; a merge segment
                    // renders `%(...)` via the merge's own parens, mirroring a
                    // `.Merge` template item; everything else wraps in `%(...)`.
                    if (segment_node.tag == .equality) {
                        try printRawString(self.elems[segment_node.payload], vm, writer);
                        segment += segment_node.subtree_len;
                    } else if (segment_node.tag == .merge) {
                        try writer.print("%", .{});
                        segment = try self.printPatternSubtree(vm, writer, segment);
                    } else {
                        try writer.print("%(", .{});
                        segment = try self.printPatternSubtree(vm, writer, segment);
                        try writer.print(")", .{});
                    }
                }
                try writer.print("\"", .{});
                return segment;
            },
            .repeat => {
                try writer.print("(", .{});
                const pattern_idx = idx + 1;
                const count_idx = try self.printPatternSubtree(vm, writer, pattern_idx);
                try writer.print(" * ", .{});
                _ = try self.printPatternSubtree(vm, writer, count_idx);
                try writer.print(")", .{});
                // Skip the rebound pattern variant, if any.
                return idx + node.subtree_len;
            },
            .negated => {
                try writer.print("{s}", .{negativeSigns(@intCast(node.payload))});
                // A range renders without its own parens, so add them:
                // `-(..5)`, not `-..5`.
                if (self.nodes[idx + 1].tag == .range) {
                    try writer.print("(", .{});
                    const end = try self.printPatternSubtree(vm, writer, idx + 1);
                    try writer.print(")", .{});
                    return end;
                }
                return self.printPatternSubtree(vm, writer, idx + 1);
            },
        }
        return idx + 1;
    }

    // The raw content of a folded string constant, without surrounding
    // quotes, for template segment rendering.
    fn printRawString(elem: Elem, vm: VM, writer: *Writer) Writer.Error!void {
        switch (elem.getType()) {
            .String => try writer.print("{s}", .{vm.strings.get(elem.asString())}),
            .InputSubstring => try writer.print("{s}", .{elem.asInputSubstring().bytes(vm)}),
            else => try elem.print(vm, writer),
        }
    }
};

// A plan subtree rendered in pattern syntax, for explain.snapshot: a value
// type whose print(vm, writer) mirrors Pattern.print's shape.
pub const SubtreePrintable = struct {
    plan: *const MatchPlan,
    idx: u32,

    pub fn print(self: SubtreePrintable, vm: VM, writer: *Writer) Writer.Error!void {
        _ = try self.plan.printPatternSubtree(vm, writer, self.idx);
    }
};

pub const Node = struct {
    tag: Tag,
    // Nodes covered by this subtree including itself, for O(1) skip.
    subtree_len: u32,
    payload: u32,
};

pub const Tag = enum(u8) {
    // A statically-unbound local: bind the value. vars[payload].
    bind,
    // A statically-bound local: compare the value against the slot's value.
    // vars[payload].
    bound_eq,
    // A constant folded at compile time: compare the value against it.
    // elems[payload].
    equality,
    // A global that may hold a function, mirroring the solver's
    // matchConstant: a zero-arity Function is executed per match and its
    // result compared; native code, closures, and non-function values
    // compare directly. elems[payload].
    const_fn,
    // A function call: calls[payload], argument subtrees follow in
    // preorder. The callee and arguments are evaluated, not matched; the
    // call result is compared against the value.
    call,
    // `_`: always matches, binds nothing. No payload.
    placeholder,
    // A fixed-length array: payload = element count, element subtrees follow
    // in preorder.
    array,
    // An object: payload = pair count; const_key/eval_key/pattern_key pair
    // subtrees follow in preorder.
    object,
    // One object pair: payload = the key's sids index, the value subtree
    // follows. subtree_len covers the value, so skipping a pair is O(1).
    const_key,
    // An object pair whose key evaluates at match time: the key subtree (a
    // leaf that cannot fail to evaluate — equality, bound_eq, const_fn, or
    // call) precedes the value subtree. The key value's sid resolution is
    // context-dependent, mirroring the solver: a plain object accepts only
    // interned strings (matchObject), a merge or repeat pair interns any
    // stringable (matchObjectPair's getOrPutSid).
    eval_key,
    // An object pair whose key is matched structurally: the key subtree
    // precedes the value subtree. The interpreter first attempts to
    // evaluate the key (a compound key of bound values evaluates, the way
    // attemptEval discovers) and otherwise searches the value object's
    // unmatched members in order, matching key then value per member.
    pattern_key,
    // A range with statically-resolvable bounds. ranges[payload].
    range,
    // A merge, flattened at compile time: merges[payload], part subtrees
    // follow in preorder. The interpreter resolves value parts (equality,
    // bound_eq) and derives the merge type from the resolved parts,
    // mirroring the solver's getMergeType.
    merge,
    // A string template: merges[payload], segment subtrees follow in
    // preorder. Constant segments are stringified at compile time; bound
    // locals stringify at match time; ranges match one character; the
    // solvable segment casts the unbound byte range by its pattern kind.
    str_template,
    // A repeat: repeats[payload]. Children in preorder: the pattern
    // subtree, the count subtree, and (when the pattern binds locals) the
    // pattern re-lowered with every local bound. Array repetitions match
    // the rebound variant from the second element or chunk on, the way
    // the solver's runtime boundness probe turns second-iteration binds
    // into equality checks.
    repeat,
    // Negation applied at match time; the sole carrier of runtime
    // negation. payload = negation count; the inner subtree follows. An
    // evaluable inner (call, const_fn, bound_eq) is evaluated and its
    // result negated (a non-number result is a runtime error); a
    // structural inner (bind, placeholder, range) matches against the
    // negated value, which must be a number.
    negated,
};

// Shared by merge and str_template nodes: both are a part list with at
// most one solvable part.
pub const MergePlan = struct {
    part_count: u32,
    // Index of the one part the solver has to solve for: the part that is
    // not a value at merge entry. Binding analysis guarantees at most one.
    // A bare local bound within the same merge by an earlier part is the
    // solvable part with a bound_eq subtree: it matches as an equality at
    // its position, after the earlier parts have bound it.
    solvable_index: ?u32,
};

// A function call in pattern position. Constant callees are verified to be
// functions with matching arity at lowering; local callees hold arbitrary
// runtime values, so both checks happen at match time.
pub const CallPlan = struct {
    callee: Callee,
    arg_count: u32,

    pub const Callee = union(enum) {
        // vars index; the local's value must be a Function at match time.
        local: u32,
        // elems index; always a Function.
        constant: u32,
    };
};

// A repeat in pattern position. The solver probes at match time whether the
// pattern or the count evaluates; the plan classifies each operand
// statically. A runtime evaluation that comes up empty (a nested repeat or
// merge failing to fold) falls through to the next branch, the same way the
// solver's attemptEval does.
pub const RepeatPlan = struct {
    pattern: Operand,
    count: Operand,
    // Whether the pattern subtree binds locals, and so a rebound variant
    // follows the count subtree.
    has_rebound_pattern: bool,

    pub const Operand = union(enum) {
        // elems index: the subtree folded at compile time. The subtree is
        // still emitted; a folded count is also matched against.
        constant: u32,
        // The subtree evaluates at match time: bound locals, calls, and
        // arrays, merges, or repeats of evaluable parts.
        eval,
        // The subtree does not evaluate; it is matched structurally.
        subtree,
    };
};

// A merge part after the interpreter's resolution pass.
pub const ResolvedPart = union(enum) {
    // A folded constant or a bound local read (and possibly evaluated) at
    // match time.
    value: Elem,
    // A structural part matched in place: the node index of its subtree.
    // Always a fixed-shape part (an array, an object, a counted object
    // repeat, or a fixed-length template range).
    subtree: u32,
    // The one solvable part (the merge's solvable_index): the node index
    // of the subtree solved from whatever the other parts leave over.
    rest: u32,
};

pub const LocalVar = struct {
    sid: StringTable.Id,
    idx: u24, // stack index/module constant id
};

pub const RangePlan = struct {
    lower: Limit,
    upper: Limit,

    pub const Limit = union(enum) {
        none,
        // elems index.
        const_elem: u32,
        // vars index; the local is statically bound.
        bound_local: u32,
        // vars index; a statically-unbound local. The matched value is bound
        // to the slot and the limit imposes no comparison, mirroring the
        // solver matching an unbound limit as a pattern.
        bind_local: u32,
        // A compound limit expression (e.g. arithmetic on bound locals)
        // evaluated at match time. Its subtree is a child of the range node,
        // in lower-before-upper preorder; the interpreter derives the child
        // index from the limits' presence. Mirrors the solver's attemptEval
        // of a non-trivial limit.
        eval,
    };
};

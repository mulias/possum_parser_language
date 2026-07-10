const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const Frontend = @import("../frontend.zig");
const Ast = Frontend.Ast;
const ClosureCapture = Frontend.ClosureCapture;
const Module = @import("../runtime.zig").Module;
const Region = @import("../region.zig").Region;
const Strings = @import("string_table.zig").FrontendStringTable;

// Compile-time analysis of local value variables. A forward walk over a
// function body's AST tracks, for every local slot, whether the local is
// bound on all, some, or none of the control paths reaching each point.
//
// A binding made inside a parser that then fails is out of scope afterward:
// the rhs of `|` and the else branch of `?:` are analyzed as if the lhs and
// condition never ran, and repeat bodies are analyzed with their own
// bindings out of scope, since each iteration starts fresh and the final
// iteration may have failed after binding.
//
// The results enforce and enable the static binding rules:
// - Reading a local that is unbound, out of scope, or bound on only some
//   paths is a compile error (a Diagnostic).
// - A pattern occurrence of a local bound on only some paths is a compile
//   error: it would have to be a fresh binding on one path and an equality
//   check on the other.
// - Repeat counts that are a bare local are recorded in
//   Maps.repeat_count_bound so codegen picks the bound or count-collecting
//   loop without a runtime bound check.
// - A merge pattern (or string template) with more than one part the
//   solver would have to solve for is a compile error: the solver
//   supports at most one unbound part per merge.
// - Function calls in patterns are evaluated, not solved: the callee and
//   every argument must hold bound values when the call runs. A variable
//   with no binding occurrence anywhere in the pattern is a compile
//   error. A variable another occurrence can bind is accepted; the solver
//   matches in order, so when the call is reached first the match is
//   still a runtime error.

pub const max_locals = 256;
const SlotSet = std.bit_set.StaticBitSet(max_locals);

// Where a local stands on the control paths reaching a program point:
// bound on every path, on none, or only on some.
const State = enum { unbound, bound, split };

const Slot = struct {
    state: State = .unbound,
    // The frame slot may still physically hold a value from a binding that
    // is out of scope: a failed alternative or an earlier loop iteration.
    // Only meaningful while state is not .bound.
    stale: bool = false,
};

const Env = struct {
    slots: [max_locals]Slot = [_]Slot{.{}} ** max_locals,
};

pub const Diagnostic = struct {
    region: Region,
    // Null only for extra_unbound_part, when the part contains no local
    // to name (a placeholder or a fully bound template segment).
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

// Analysis results the frontend consults while emitting bytecode, keyed by
// AST pattern nodes (each destructure site has a distinct pattern node).
pub const Maps = struct {
    repeat_count_bound: AutoHashMap(*const Ast.Pattern.RNode, bool) = .{},
    // Whether each pattern-local occurrence is bound on the paths reaching
    // its destructure, keyed by the identifier node. Lets codegen lower an
    // occurrence to a bind or an equality check without a runtime probe.
    pattern_local_bound: AutoHashMap(*const Ast.Pattern.RNode, bool) = .{},
    // Whether each merge part (or string template segment) is one the
    // solver has to solve for, keyed by the part node. The solver
    // simplifies every part before matching any, so a local bound within
    // the same merge by an earlier part is still unbound here even though
    // its occurrence is sequentially bound.
    merge_part_unbound: AutoHashMap(*const Ast.Pattern.RNode, bool) = .{},

    pub fn deinit(self: *Maps, allocator: Allocator) void {
        self.repeat_count_bound.deinit(allocator);
        self.pattern_local_bound.deinit(allocator);
        self.merge_part_unbound.deinit(allocator);
    }
};

pub const Result = struct {
    diagnostics: ArrayList(Diagnostic) = .{},

    pub fn deinit(self: *Result, allocator: Allocator) void {
        self.diagnostics.deinit(allocator);
    }
};

pub fn analyzeParserFunction(
    frontend: *Frontend,
    module_id: Module.Id,
    node: *Frontend.DependencyGraphNode,
    body: *Ast.Parser.RNode,
    arity: usize,
    captures: []const ClosureCapture,
) Allocator.Error!Result {
    var analyzer = Analyzer.init(frontend, module_id, node);
    var env = analyzer.entryEnv(arity, captures);
    try analyzer.analyzeParser(&env, body);
    return .{ .diagnostics = analyzer.diagnostics };
}

pub fn analyzeValueFunction(
    frontend: *Frontend,
    module_id: Module.Id,
    node: *Frontend.DependencyGraphNode,
    body: *Ast.Value.RNode,
    arity: usize,
) Allocator.Error!Result {
    var analyzer = Analyzer.init(frontend, module_id, node);
    var env = analyzer.entryEnv(arity, &.{});
    try analyzer.analyzeValue(&env, body);
    return .{ .diagnostics = analyzer.diagnostics };
}

const Analyzer = struct {
    frontend: *Frontend,
    module_id: Module.Id,
    // The dependency-graph node whose body is being analyzed. Its locals and
    // dependencies stand in for the compiler's per-function scope stack.
    node: *Frontend.DependencyGraphNode,
    allocator: Allocator,
    diagnostics: ArrayList(Diagnostic) = .{},

    fn init(frontend: *Frontend, module_id: Module.Id, node: *Frontend.DependencyGraphNode) Analyzer {
        return .{
            .frontend = frontend,
            .module_id = module_id,
            .node = node,
            .allocator = frontend.vm.allocator,
        };
    }

    // The frame slot of a local by name, resolved against the node being
    // analyzed. Replaces the compiler's scope-stack localSlot.
    fn localSlot(self: *const Analyzer, name: Strings.Id) ?u8 {
        for (self.node.locals(), 0..) |local, i| {
            if (local == name) return @intCast(i);
        }
        return null;
    }

    // Whether a name resolves to a global rather than a local. The resolver
    // records a dependency edge for every identifier that resolves to a
    // global, so a matching dependency is equivalent to the compiler's
    // resolveGlobal for the local-vs-global test. User-written names never
    // resolve to anonymous-function nodes, matching visibleGlobal.
    fn resolvesToGlobal(self: *const Analyzer, name: Strings.Id) bool {
        return self.node.dependencyNamed(name) != null;
    }

    fn entryEnv(self: *Analyzer, arity: usize, captures: []const ClosureCapture) Env {
        var env = Env{};

        for (0..arity) |slot| {
            env.slots[slot].state = .bound;
        }

        for (captures) |capture| {
            if (self.localSlot(capture.local)) |slot| {
                env.slots[slot].state = .bound;
            }
        }

        return env;
    }

    fn diagnose(self: *Analyzer, region: Region, name: ?Strings.Id, kind: Diagnostic.Kind) !void {
        try self.diagnostics.append(self.allocator, .{
            .region = region,
            .name = name,
            .kind = kind,
        });
    }

    fn isPlaceholder(self: *Analyzer, name: Strings.Id) bool {
        return std.mem.eql(u8, self.frontend.strings.get(name), "_");
    }

    // Whether an identifier in pattern position is a local occurrence.
    // Mirrors astToPattern/astToValueInPattern: a global with the same name
    // wins over a local.
    fn patternLocalSlot(self: *Analyzer, name: Strings.Id) ?u8 {
        if (self.isPlaceholder(name)) return null;
        if (self.resolvesToGlobal(name)) return null;
        return self.localSlot(name);
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

    // A read of an identifier resolved the way writeParser/writeValue
    // resolve them: local slot first, then global.
    fn readIdentifier(self: *Analyzer, env: *Env, name: Strings.Id, region: Region) !void {
        if (self.isPlaceholder(name)) return;
        if (self.localSlot(name)) |slot| {
            try self.readLocal(env, slot, name, region);
        }
    }

    // A destructure of a value against a pattern. After a successful match
    // every local the pattern references is bound: either it already was,
    // or the match bound it. Function callees and arguments are the
    // exception: the solver evaluates them rather than binding through
    // them, so their variables must be bound elsewhere.
    fn destructureSite(self: *Analyzer, env: *Env, pattern: *const Ast.Pattern.RNode) Allocator.Error!void {
        var bindable = SlotSet.initEmpty();
        self.collectBindingOccurrences(pattern, &bindable);
        try self.visitPatternLocals(env, &bindable, pattern);
    }

    fn visitPatternLocals(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        rnode: *const Ast.Pattern.RNode,
    ) Allocator.Error!void {
        switch (rnode.node) {
            .identifier => |ident| try self.patternLocalOccurrence(env, rnode, ident.name, rnode.region),
            .array => |elems| for (elems.items) |elem| {
                try self.visitPatternLocals(env, bindable, elem);
            },
            .object => |pairs| for (pairs.items) |pair| {
                try self.visitPatternLocals(env, bindable, pair.key);
                try self.visitPatternLocals(env, bindable, pair.value);
            },
            .string_template => |segments| {
                try self.checkOneUnboundPart(env, segments.items, .template_segments);
                for (segments.items) |segment| {
                    try self.visitPatternLocals(env, bindable, segment);
                }
            },
            .merge => {
                var parts = ArrayList(*const Ast.Pattern.RNode){};
                defer parts.deinit(self.allocator);
                try self.collectMergeChain(rnode, &parts);

                try self.checkOneUnboundPart(env, parts.items, .merge_parts);
                for (parts.items) |part| {
                    try self.visitPatternLocals(env, bindable, part);
                }
            },
            .negation => |inner| try self.visitPatternLocals(env, bindable, inner),
            .range => |bounds| {
                if (bounds.lower) |lower| try self.visitPatternLocals(env, bindable, lower);
                if (bounds.upper) |upper| try self.visitPatternLocals(env, bindable, upper);
            },
            .repeat => |repeat| {
                try self.visitPatternLocals(env, bindable, repeat.left);
                try self.visitPatternLocals(env, bindable, repeat.right);
            },
            .function_call => |function_call| {
                if (function_call.function.node == .identifier) {
                    const ident = function_call.function.node.identifier;
                    try self.functionVarOccurrence(env, bindable, ident.name, function_call.function.region);
                }
                for (function_call.args.items) |arg| {
                    try self.visitValueInPatternLocals(env, bindable, arg);
                }
            },
            .false, .true, .null, .number_float, .number_string, .string => {},
        }
    }

    fn visitValueInPatternLocals(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        rnode: *const Ast.Value.RNode,
    ) Allocator.Error!void {
        switch (rnode.node) {
            .identifier => |ident| try self.functionVarOccurrence(env, bindable, ident.name, rnode.region),
            .negation => |inner| try self.visitValueInPatternLocals(env, bindable, inner),
            // astToValueInPattern rejects every other compound node.
            else => {},
        }
    }

    // A function callee or argument occurrence. The variable must already
    // be bound or have a binding occurrence elsewhere in the pattern;
    // otherwise no match can succeed and the use is a compile error.
    // Bindable variables are treated as bound afterward: when the binding
    // occurrence is matched before the call the value is available, and
    // when it isn't the mismatch stays a runtime error.
    fn functionVarOccurrence(
        self: *Analyzer,
        env: *Env,
        bindable: *const SlotSet,
        name: Strings.Id,
        region: Region,
    ) !void {
        if (self.isPlaceholder(name)) {
            return self.diagnose(region, name, .unbound_function_var);
        }
        const slot = self.patternLocalSlot(name) orelse return;
        const state = &env.slots[slot];

        switch (state.state) {
            .bound => return,
            .unbound => {
                if (!bindable.isSet(slot)) {
                    try self.diagnose(region, name, .unbound_function_var);
                }
            },
            .split => if (bindable.isSet(slot)) {
                // The binding occurrence of a split variable is an error;
                // report it here in case this call is visited first.
                try self.diagnose(region, name, .split);
            } else {
                try self.diagnose(region, name, .unbound_function_var);
            },
        }

        // Treat as bound afterward: either another occurrence binds it or
        // compilation already failed.
        state.* = .{ .state = .bound, .stale = false };
    }

    // Every local slot an occurrence in this pattern can bind: all local
    // occurrences except function callees and arguments, which the solver
    // evaluates rather than solves.
    fn collectBindingOccurrences(self: *Analyzer, rnode: *const Ast.Pattern.RNode, set: *SlotSet) void {
        switch (rnode.node) {
            .identifier => |ident| {
                if (self.patternLocalSlot(ident.name)) |slot| set.set(slot);
            },
            .array => |elems| for (elems.items) |elem| {
                self.collectBindingOccurrences(elem, set);
            },
            .object => |pairs| for (pairs.items) |pair| {
                self.collectBindingOccurrences(pair.key, set);
                self.collectBindingOccurrences(pair.value, set);
            },
            .string_template => |segments| for (segments.items) |segment| {
                self.collectBindingOccurrences(segment, set);
            },
            .merge => |merge| {
                self.collectBindingOccurrences(merge.left, set);
                self.collectBindingOccurrences(merge.right, set);
            },
            .negation => |inner| self.collectBindingOccurrences(inner, set),
            .range => |bounds| {
                if (bounds.lower) |lower| self.collectBindingOccurrences(lower, set);
                if (bounds.upper) |upper| self.collectBindingOccurrences(upper, set);
            },
            .repeat => |repeat| {
                self.collectBindingOccurrences(repeat.left, set);
                self.collectBindingOccurrences(repeat.right, set);
            },
            .function_call, .false, .true, .null, .number_float, .number_string, .string => {},
        }
    }

    // Flatten a chain of merges into its parts, the way the frontend and
    // the solver flatten nested Merge patterns into a single part list.
    fn collectMergeChain(
        self: *Analyzer,
        rnode: *const Ast.Pattern.RNode,
        parts: *ArrayList(*const Ast.Pattern.RNode),
    ) Allocator.Error!void {
        switch (rnode.node) {
            .merge => |merge| {
                try self.collectMergeChain(merge.left, parts);
                try self.collectMergeChain(merge.right, parts);
            },
            .negation => |inner| switch (inner.node) {
                .merge, .negation => try self.collectMergeChain(inner, parts),
                else => try parts.append(self.allocator, rnode),
            },
            else => try parts.append(self.allocator, rnode),
        }
    }

    const PartContext = enum { merge_parts, template_segments };

    // The solver simplifies every part of a merge (or segment of a string
    // template) before matching any of them, and can solve for at most one
    // part that does not evaluate to a value. Later parts that also need
    // solving are a runtime error whenever the destructure runs, so reject
    // them at compile time.
    fn checkOneUnboundPart(
        self: *Analyzer,
        env: *const Env,
        parts: []const *const Ast.Pattern.RNode,
        context: PartContext,
    ) Allocator.Error!void {
        var solvable_part_found = false;
        for (parts) |part| {
            const unbound = switch (context) {
                .merge_parts => self.mergePartIsUnbound(env, part),
                .template_segments => self.templateSegmentIsUnbound(env, part),
            };
            try self.frontend.binding_maps.merge_part_unbound.put(self.allocator, part, unbound);
            if (!unbound) continue;
            if (solvable_part_found) {
                try self.diagnose(part.region, self.firstUnboundLocal(env, part), .extra_unbound_part);
            }
            solvable_part_found = true;
        }
    }

    // Whether the solver would have to solve for this merge part. Parts
    // that evaluate are compared directly. Arrays and objects are matched
    // structurally — by length or by member — whatever their contents, and
    // an object repeat with a bound count claims counted members, so none
    // of them consume the one solvable slot.
    fn mergePartIsUnbound(self: *Analyzer, env: *const Env, rnode: *const Ast.Pattern.RNode) bool {
        if (self.patternEvaluates(env, rnode)) return false;
        return switch (rnode.node) {
            .array, .object => false,
            .negation => |inner| self.mergePartIsUnbound(env, inner),
            .repeat => |repeat| !(repeat.left.node == .object and
                self.patternEvaluates(env, repeat.right)),
            else => true,
        };
    }

    // Template segments have no structural parts except character ranges,
    // which always match exactly one character.
    fn templateSegmentIsUnbound(self: *Analyzer, env: *const Env, rnode: *const Ast.Pattern.RNode) bool {
        return rnode.node != .range and !self.patternEvaluates(env, rnode);
    }

    // Whether the solver's attemptEval would produce a value for this
    // pattern without solving anything, given the bindings in env.
    // Objects, ranges, and string templates never evaluate; arrays,
    // merges, and repeats evaluate when their contents do. Function calls
    // never become solvable parts: an unbound argument is a runtime error
    // instead.
    fn patternEvaluates(self: *Analyzer, env: *const Env, rnode: *const Ast.Pattern.RNode) bool {
        return switch (rnode.node) {
            .identifier => |ident| blk: {
                if (self.isPlaceholder(ident.name)) break :blk false;
                if (self.resolvesToGlobal(ident.name)) break :blk true;
                const slot = self.localSlot(ident.name) orelse break :blk true;
                break :blk env.slots[slot].state == .bound;
            },
            .negation => |inner| self.patternEvaluates(env, inner),
            .array => |elems| blk: {
                for (elems.items) |elem| {
                    if (!self.patternEvaluates(env, elem)) break :blk false;
                }
                break :blk true;
            },
            .merge => |merge| self.patternEvaluates(env, merge.left) and
                self.patternEvaluates(env, merge.right),
            .repeat => |repeat| self.patternEvaluates(env, repeat.left) and
                self.patternEvaluates(env, repeat.right),
            .function_call, .false, .true, .null, .number_float, .number_string, .string => true,
            .object, .range, .string_template => false,
        };
    }

    fn firstUnboundLocal(self: *Analyzer, env: *const Env, rnode: *const Ast.Pattern.RNode) ?Strings.Id {
        switch (rnode.node) {
            .identifier => |ident| {
                const slot = self.patternLocalSlot(ident.name) orelse return null;
                return if (env.slots[slot].state == .bound) null else ident.name;
            },
            .negation => |inner| return self.firstUnboundLocal(env, inner),
            .array => |elems| for (elems.items) |elem| {
                if (self.firstUnboundLocal(env, elem)) |name| return name;
            },
            .object => |pairs| for (pairs.items) |pair| {
                if (self.firstUnboundLocal(env, pair.key)) |name| return name;
                if (self.firstUnboundLocal(env, pair.value)) |name| return name;
            },
            .string_template => |segments| for (segments.items) |segment| {
                if (self.firstUnboundLocal(env, segment)) |name| return name;
            },
            .merge => |merge| {
                if (self.firstUnboundLocal(env, merge.left)) |name| return name;
                return self.firstUnboundLocal(env, merge.right);
            },
            .repeat => |repeat| {
                if (self.firstUnboundLocal(env, repeat.left)) |name| return name;
                return self.firstUnboundLocal(env, repeat.right);
            },
            .range => |bounds| {
                if (bounds.lower) |lower| {
                    if (self.firstUnboundLocal(env, lower)) |name| return name;
                }
                if (bounds.upper) |upper| {
                    if (self.firstUnboundLocal(env, upper)) |name| return name;
                }
            },
            .function_call, .false, .true, .null, .number_float, .number_string, .string => {},
        }
        return null;
    }

    fn patternLocalOccurrence(
        self: *Analyzer,
        env: *Env,
        rnode: *const Ast.Pattern.RNode,
        name: Strings.Id,
        region: Region,
    ) !void {
        const slot = self.patternLocalSlot(name) orelse return;
        const state = &env.slots[slot];

        // A constant-count array-literal repeat is pre-expanded by sharing the
        // same element node pointer across copies (`[A] * 3` → `[A, A, A]`
        // with one `A` node). This map is keyed by node pointer, so record the
        // first occurrence's boundness; lowering forces later copies to
        // rebind (see the array case in lowerPatternNode).
        const gop = try self.frontend.binding_maps.pattern_local_bound.getOrPut(
            self.allocator,
            rnode,
        );
        if (!gop.found_existing) gop.value_ptr.* = (state.state == .bound);

        switch (state.state) {
            .bound => {},
            .unbound => {
                state.* = .{ .state = .bound, .stale = false };
            },
            .split => {
                try self.diagnose(region, name, .split);
                // Treat as bound afterward to avoid cascading diagnostics.
                state.* = .{ .state = .bound, .stale = false };
            },
        }
    }

    // Mark slots that `after` may have bound or dirtied relative to `base`
    // as stale in `target`: the values may physically remain in the frame
    // while the bindings are out of scope.
    fn markStaleBinds(target: *Env, base: *const Env, after: *const Env) void {
        for (&target.slots, base.slots, after.slots) |*t, b, a| {
            if (a.stale or (b.state == .unbound and a.state != .unbound)) {
                t.stale = true;
            }
        }
    }

    fn joinEnv(a: *const Env, b: *const Env) Env {
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

    fn analyzeParser(self: *Analyzer, env: *Env, rnode: *Ast.Parser.RNode) Allocator.Error!void {
        switch (rnode.node) {
            .merge => |merge| {
                try self.analyzeParser(env, merge.left);
                try self.analyzeParser(env, merge.right);
            },
            .take_left => |take_left| {
                try self.analyzeParser(env, take_left.left);
                try self.analyzeParser(env, take_left.right);
            },
            .take_right => |take_right| {
                try self.analyzeParser(env, take_right.left);
                try self.analyzeParser(env, take_right.right);
            },
            .@"return" => |return_node| {
                try self.analyzeParser(env, return_node.left);
                try self.analyzeValue(env, return_node.right);
            },
            .destructure => |destructure| {
                try self.analyzeParser(env, destructure.left);
                try self.destructureSite(env, destructure.right);
            },
            .@"or" => |or_node| {
                var lhs = env.*;
                try self.analyzeParser(&lhs, or_node.left);

                var rhs = env.*;
                markStaleBinds(&rhs, env, &lhs);
                try self.analyzeParser(&rhs, or_node.right);

                env.* = joinEnv(&lhs, &rhs);
            },
            .conditional => |conditional| {
                var then_env = env.*;
                try self.analyzeParser(&then_env, conditional.condition);

                var else_env = env.*;
                markStaleBinds(&else_env, env, &then_env);

                try self.analyzeParser(&then_env, conditional.then_branch);
                try self.analyzeParser(&else_env, conditional.else_branch);

                env.* = joinEnv(&then_env, &else_env);
            },
            .repeat => |repeat| {
                try self.analyzeRepeat(env, repeat.left, repeat.right);
            },
            .range => |bounds| {
                if (bounds.lower) |lower| try self.analyzeParser(env, lower);
                if (bounds.upper) |upper| try self.analyzeParser(env, upper);
            },
            .negation => |inner| try self.analyzeParser(env, inner),
            .identifier => |ident| try self.readIdentifier(env, ident.name, rnode.region),
            .function_call => |function_call| {
                if (function_call.function.node == .identifier) {
                    const ident = function_call.function.node.identifier;
                    try self.readIdentifier(env, ident.name, function_call.function.region);
                }
                for (function_call.args.items) |arg| {
                    try self.analyzeParserFunctionArgument(env, arg);
                }
            },
            .anonymous_function => |anon| try self.captureSite(env, anon, rnode.region),
            .string_template => |parts| for (parts.items) |part| {
                try self.analyzeParser(env, part);
            },
            .number_string, .string => {},
        }
    }

    fn analyzeParserFunctionArgument(self: *Analyzer, env: *Env, rnode: Ast.ParserOrValue.RNode) Allocator.Error!void {
        switch (rnode) {
            .parser => |p| switch (p.node) {
                .identifier => |ident| try self.readIdentifier(env, ident.name, p.region),
                .anonymous_function => |anon| try self.captureSite(env, anon, p.region),
                // Literal arguments read no locals; the canonicalizer wraps
                // every compound parser argument in an anonymous function.
                else => {},
            },
            .value => |v| try self.analyzeValue(env, v),
        }
    }

    fn captureSite(self: *Analyzer, env: *Env, anon: Ast.Parser.AnonymousFunction, region: Region) !void {
        const node = self.frontend.getNode(.{
            .module_id = self.module_id,
            .name = anon.name,
        });

        for (node.anonymous_function.closure_captures.items) |capture| {
            if (self.localSlot(capture.local)) |slot| {
                try self.readLocal(env, slot, capture.local, region);
            }
        }
    }

    // A repeat loop's body binds fresh each iteration: the analysis enters
    // the body with the body's own bindings out of scope (a prior iteration
    // bound them), and leaves them out of scope after the loop (the final
    // iteration may have bound them and then failed). The count pattern is
    // destructured after the loop.
    fn analyzeRepeat(self: *Analyzer, env: *Env, body: *Ast.Parser.RNode, count: *Ast.Pattern.RNode) Allocator.Error!void {
        var bindables = SlotSet.initEmpty();
        self.collectParserBinds(body, &bindables);

        var body_env = env.*;
        var iter = bindables.iterator(.{});
        while (iter.next()) |slot| {
            if (body_env.slots[slot].state == .unbound) {
                body_env.slots[slot].stale = true;
            }
        }

        try self.analyzeParser(&body_env, body);

        var out = env.*;
        iter = bindables.iterator(.{});
        while (iter.next()) |slot| {
            if (out.slots[slot].state == .unbound) {
                out.slots[slot].stale = true;
            }
        }

        try self.recordCountBoundness(&out, count);
        try self.destructureSite(&out, count);

        env.* = out;
    }

    // Record whether a repeat-count local is bound at the loop, so codegen
    // can pick the fixed-count or count-collecting loop statically. Bare
    // locals, range bounds, and merge parts mirror writeParserRepeat and
    // writePatternAsBoundRepeatValue.
    fn recordCountBoundness(self: *Analyzer, env: *const Env, rnode: *const Ast.Pattern.RNode) Allocator.Error!void {
        switch (rnode.node) {
            .identifier => |ident| {
                const slot = self.patternLocalSlot(ident.name) orelse return;
                try self.frontend.binding_maps.repeat_count_bound.put(
                    self.allocator,
                    rnode,
                    env.slots[slot].state == .bound,
                );
            },
            .range => |bounds| {
                if (bounds.lower) |lower| try self.recordCountBoundness(env, lower);
                if (bounds.upper) |upper| try self.recordCountBoundness(env, upper);
            },
            .merge => |merge| {
                try self.recordCountBoundness(env, merge.left);
                try self.recordCountBoundness(env, merge.right);
            },
            .negation => |inner| try self.recordCountBoundness(env, inner),
            else => {},
        }
    }

    // Every local slot the subtree's destructure patterns reference,
    // including patterns in nested value expressions. Anonymous functions
    // are separate scopes with their own slots and are skipped.
    fn collectParserBinds(self: *Analyzer, rnode: *const Ast.Parser.RNode, set: *SlotSet) void {
        switch (rnode.node) {
            .merge => |n| {
                self.collectParserBinds(n.left, set);
                self.collectParserBinds(n.right, set);
            },
            .take_left => |n| {
                self.collectParserBinds(n.left, set);
                self.collectParserBinds(n.right, set);
            },
            .take_right => |n| {
                self.collectParserBinds(n.left, set);
                self.collectParserBinds(n.right, set);
            },
            .@"or" => |n| {
                self.collectParserBinds(n.left, set);
                self.collectParserBinds(n.right, set);
            },
            .@"return" => |n| {
                self.collectParserBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .destructure => |n| {
                self.collectParserBinds(n.left, set);
                self.collectPatternSlots(n.right, set);
            },
            .conditional => |n| {
                self.collectParserBinds(n.condition, set);
                self.collectParserBinds(n.then_branch, set);
                self.collectParserBinds(n.else_branch, set);
            },
            .repeat => |n| {
                self.collectParserBinds(n.left, set);
                self.collectPatternSlots(n.right, set);
            },
            .range => |bounds| {
                if (bounds.lower) |lower| self.collectParserBinds(lower, set);
                if (bounds.upper) |upper| self.collectParserBinds(upper, set);
            },
            .negation => |inner| self.collectParserBinds(inner, set),
            .string_template => |parts| for (parts.items) |part| {
                self.collectParserBinds(part, set);
            },
            .function_call => |function_call| for (function_call.args.items) |arg| {
                switch (arg) {
                    .parser => {},
                    .value => |v| self.collectValueBinds(v, set),
                }
            },
            .anonymous_function, .identifier, .number_string, .string => {},
        }
    }

    fn collectValueBinds(self: *Analyzer, rnode: *const Ast.Value.RNode, set: *SlotSet) void {
        switch (rnode.node) {
            .merge => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .take_left => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .take_right => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .@"or" => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .@"return" => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .repeat => |n| {
                self.collectValueBinds(n.left, set);
                self.collectValueBinds(n.right, set);
            },
            .destructure => |n| {
                self.collectValueBinds(n.left, set);
                self.collectPatternSlots(n.right, set);
            },
            .conditional => |n| {
                self.collectValueBinds(n.condition, set);
                self.collectValueBinds(n.then_branch, set);
                self.collectValueBinds(n.else_branch, set);
            },
            .negation => |inner| self.collectValueBinds(inner, set),
            .array => |elems| for (elems.items) |elem| {
                self.collectValueBinds(elem, set);
            },
            .object => |pairs| for (pairs.items) |pair| {
                self.collectValueBinds(pair.key, set);
                self.collectValueBinds(pair.value, set);
            },
            .string_template => |parts| for (parts.items) |part| {
                self.collectValueBinds(part, set);
            },
            .function_call => |function_call| for (function_call.args.items) |arg| {
                self.collectValueBinds(arg, set);
            },
            .identifier, .string, .number_string, .number_float, .true, .false, .null => {},
        }
    }

    fn collectPatternSlots(self: *Analyzer, rnode: *const Ast.Pattern.RNode, set: *SlotSet) void {
        switch (rnode.node) {
            .identifier => |ident| {
                if (self.patternLocalSlot(ident.name)) |slot| set.set(slot);
            },
            .array => |elems| for (elems.items) |elem| {
                self.collectPatternSlots(elem, set);
            },
            .object => |pairs| for (pairs.items) |pair| {
                self.collectPatternSlots(pair.key, set);
                self.collectPatternSlots(pair.value, set);
            },
            .string_template => |segments| for (segments.items) |segment| {
                self.collectPatternSlots(segment, set);
            },
            .merge => |merge| {
                self.collectPatternSlots(merge.left, set);
                self.collectPatternSlots(merge.right, set);
            },
            .negation => |inner| self.collectPatternSlots(inner, set),
            .range => |bounds| {
                if (bounds.lower) |lower| self.collectPatternSlots(lower, set);
                if (bounds.upper) |upper| self.collectPatternSlots(upper, set);
            },
            .repeat => |repeat| {
                self.collectPatternSlots(repeat.left, set);
                self.collectPatternSlots(repeat.right, set);
            },
            .function_call => |function_call| {
                if (function_call.function.node == .identifier) {
                    const ident = function_call.function.node.identifier;
                    if (self.patternLocalSlot(ident.name)) |slot| set.set(slot);
                }
                for (function_call.args.items) |arg| {
                    self.collectValueInPatternSlots(arg, set);
                }
            },
            .false, .true, .null, .number_float, .number_string, .string => {},
        }
    }

    fn collectValueInPatternSlots(self: *Analyzer, rnode: *const Ast.Value.RNode, set: *SlotSet) void {
        switch (rnode.node) {
            .identifier => |ident| {
                if (self.patternLocalSlot(ident.name)) |slot| set.set(slot);
            },
            .negation => |inner| self.collectValueInPatternSlots(inner, set),
            else => {},
        }
    }

    fn analyzeValue(self: *Analyzer, env: *Env, rnode: *Ast.Value.RNode) Allocator.Error!void {
        switch (rnode.node) {
            .merge => |merge| {
                try self.analyzeValue(env, merge.left);
                try self.analyzeValue(env, merge.right);
            },
            .take_left => |take_left| {
                try self.analyzeValue(env, take_left.left);
                try self.analyzeValue(env, take_left.right);
            },
            .take_right => |take_right| {
                try self.analyzeValue(env, take_right.left);
                try self.analyzeValue(env, take_right.right);
            },
            .@"return" => |return_node| {
                try self.analyzeValue(env, return_node.left);
                try self.analyzeValue(env, return_node.right);
            },
            .repeat => |repeat| {
                try self.analyzeValue(env, repeat.left);
                try self.analyzeValue(env, repeat.right);
            },
            .destructure => |destructure| {
                try self.analyzeValue(env, destructure.left);
                try self.destructureSite(env, destructure.right);
            },
            .@"or" => |or_node| {
                var lhs = env.*;
                try self.analyzeValue(&lhs, or_node.left);

                var rhs = env.*;
                markStaleBinds(&rhs, env, &lhs);
                try self.analyzeValue(&rhs, or_node.right);

                env.* = joinEnv(&lhs, &rhs);
            },
            .conditional => |conditional| {
                var then_env = env.*;
                try self.analyzeValue(&then_env, conditional.condition);

                var else_env = env.*;
                markStaleBinds(&else_env, env, &then_env);

                try self.analyzeValue(&then_env, conditional.then_branch);
                try self.analyzeValue(&else_env, conditional.else_branch);

                env.* = joinEnv(&then_env, &else_env);
            },
            .negation => |inner| try self.analyzeValue(env, inner),
            .array => |elems| for (elems.items) |elem| {
                try self.analyzeValue(env, elem);
            },
            .object => |pairs| for (pairs.items) |pair| {
                try self.analyzeValue(env, pair.key);
                try self.analyzeValue(env, pair.value);
            },
            .string_template => |parts| for (parts.items) |part| {
                try self.analyzeValue(env, part);
            },
            .function_call => |function_call| {
                if (function_call.function.node == .identifier) {
                    const ident = function_call.function.node.identifier;
                    try self.readIdentifier(env, ident.name, function_call.function.region);
                }
                for (function_call.args.items) |arg| {
                    try self.analyzeValue(env, arg);
                }
            },
            .identifier => |ident| try self.readIdentifier(env, ident.name, rnode.region),
            .string, .number_string, .number_float, .true, .false, .null => {},
        }
    }
};

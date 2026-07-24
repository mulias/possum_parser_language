const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const StringTable = @import("string_table.zig").FrontendStringTable;
const PathTable = @import("path_table.zig").PathTable;
const Region = @import("../region.zig").Region;

goals: ArrayList(RNode) = .{},
// Nested constraint scopes referenced by SetId: composite constraint
// sub-patterns and repeat count tests.
constraint_sets: ArrayList(ConstraintSet) = .{},
declarations: ArrayList(Declaration) = .{},
main: ?NodeId = null,
// The generated name of main's anonymous-function node in the dependency
// graph; binding analysis resolves main's locals against it.
main_name: ?PathTable.Id = null,
// The source region of main's bare expression, for main's function elem
// and diagnostics. The body node's own region can be narrower (a template
// interpolation, say), so the whole-expression region is kept separately.
main_region: ?Region = null,
// The number of anonymous functions created before main was finalized.
// main is inserted into the dependency graph at this point in
// anonymous-function creation order, matching where its body's lambdas and
// any later declarations' lambdas fall.
main_order: u64 = 0,
// Module imports, in source-traversal order: top-level dumps and alias
// declarations, plus the private aliases synthesized for inline import
// expressions. The frontend wires each into the dependency resolver; the
// list is consumed building the graph and ignored afterward.
imports: ArrayList(Import) = .{},

pub const Import = struct {
    path: Path,
    target: Target,
    region: Region,

    pub const Path = union(enum) {
        // A disk path from a string literal.
        file: []const u8,
        // A logical embedded-module name like "stdlib/json".
        stdlib: []const u8,
    };

    pub const Target = union(enum) {
        // Unqualified: every public export of the module is visible bare.
        // A private dump ('_!') is not re-exported to importing modules.
        dump: Dump,
        // Qualified: names prefixed with the alias resolve among the
        // module's public exports, optionally re-rooted on a selector.
        alias: Alias,
    };

    pub const Dump = struct {
        private: bool,
    };

    pub const Alias = struct {
        name: PathTable.Id,
        selector: ?PathTable.Id,
    };
};

pub const Goal = @This();
pub const NodeId = u32;
pub const SetId = u32;

// Pipeline stages the goal ast moves through; printing is parameterized
// by the stage reached before the dump.
pub const Stage = enum { created, folded, bound };

pub const RNode = struct {
    region: Region,
    node: GoalNode,
};

pub const Declaration = struct {
    name: PathTable.Id,
    underscored: bool,
    params: ArrayList(PathTable.Id) = .{},
    // Per-parameter parser/value kinds, matching the backend
    // Function.ParamTypes bitset: bit i set means params[i] is a value, unset
    // a parser. Value declarations have every param bit set.
    param_types: u32 = 0,
    body: NodeId,
    region: Region,
    ident_region: Region,
};

pub const GoalType = enum {
    alt,
    seq,
    call,
    match,
    ident,
    neg,
    merge,
    mult,
    to_string,
    number_string,
    number_float,
    array,
    object,
    repeat,
    range,
    string,
    true,
    false,
    null,
    lambda,
};

// `call` is the only invoking construct: functions are applied, literal
// parser elems parse themselves. A bare `ident` always evaluates to its
// value, never invokes — the inverse of the surface reading, where a bare
// parser name in operand position runs. `lambda` is the only deferring
// construct.
pub const GoalNode = union(GoalType) {
    alt: ArrayList(AltArm),
    seq: Seq,
    call: Call,
    match: Match,
    ident: Ident,
    neg: NodeId,
    merge: Merge,
    // Value multiplication `V1 * V2`: merge the left value with itself
    // right times, per Elem.repeat. Parser repetition stays `repeat`.
    mult: Mult,
    // Stringify the result: identity on strings, JSON encoding otherwise.
    // String templates desugar to merge chains of literal segments and
    // to_string-wrapped interpolations; there is no template goal node.
    to_string: NodeId,
    number_string: NumberString,
    number_float: f64,
    array: ArrayList(NodeId),
    object: ArrayList(ObjectPair),
    repeat: Repeat,
    range: Range,
    string: []const u8,
    true,
    false,
    null,
    lambda: Lambda,
};

pub const AltArm = struct {
    guard: ?NodeId,
    body: ?NodeId,
};

// Run goals in order; any failure propagates. The result is
// goals.items[result]: take-right and `$` use the last index, take-left
// index 0. Goals after the result position still run (and can still fail)
// before the seq yields.
pub const Seq = struct {
    goals: ArrayList(NodeId),
    result: u32,
};

pub const Call = struct {
    callee: NodeId,
    args: []NodeId,
    // Bit i set means args[i] is a value, unset a parser, matching the
    // Function.ParamTypes bitset the backend asserts against. Args past
    // bit 31 are unrepresentable; the compiler rejects such calls.
    value_args: u32,
};

pub const Ident = struct {
    name: PathTable.Id,
    builtin: bool,
    underscored: bool,
    // The surface kind of the identifier's position: a parser name is
    // invoked and never becomes a local, a value name evaluates and an
    // unresolved one becomes a frame local. The dependency resolver keys
    // its parser-vs-value resolution on this.
    kind: Kind,
    // Filled by binding analysis: an eval-position ident is a frame-local
    // read or a module-level constant/function reference. No resolution
    // survives the bound stage except placeholder (`_` never reads).
    resolution: Resolution = .unresolved,

    pub const Kind = enum { parser, value };

    pub const Resolution = union(enum) {
        unresolved,
        local: u8,
        global,
        placeholder,
    };
};

// A classified local-variable occurrence: the frame slot (index into the
// owning function's locals, captures first for lambdas) plus the name for
// printing and diagnostics.
pub const LocalSlot = struct {
    slot: u8,
    name: PathTable.Id,
};

pub const Match = struct {
    scrutinee: NodeId,
    // Interned per match and shared by all arms, so cross-arm factoring is
    // place-id comparison.
    places: ArrayList(PlaceDef),
    arms: ArrayList(MatchArm),
};

pub const PlaceId = u32; // index into the owning places list; 0 = root

// A compile-time address for a value statically reachable from the root.
// Values discovered by search or produced by solving are not places; they
// live in the nested ConstraintSet of the composite that discovers them.
// Evaluation results are not places either: eval_eq compares in place.
pub const PlaceDef = union(enum) {
    // The tested value: a match scrutinee or a ConstraintSet's root.
    scrutinee,
    // `First` in `[First, ...Rest]`. Index is u8: the match-step ops
    // encode it in one byte, and goal creation rejects larger patterns.
    elem: struct { src: PlaceId, index: u8 },
    // `Last` in `[...Front, Last]`
    elem_back: struct { src: PlaceId, index: u8 },
    // `Middle` in `[First, ...Middle, Last]`
    slice: struct { src: PlaceId, front: u8, back: u8 },
    // "foo" in `{"foo": Bar}`
    key: struct { src: PlaceId, sid: StringTable.Id },
    // `Rest` in `{"foo": Bar, ...Rest}`: the object minus the members
    // the arm's has_key constraints on src claim.
    members_rest: struct { src: PlaceId },
};

pub const MatchArm = struct {
    constraints: ArrayList(Constraint),
    guard: ?NodeId, // residual guard after head-test extraction
    body: ?NodeId, // null: result is the scrutinee value
    region: Region,
};

// A constraint scope rooted at one tested value: place 0 is the value
// under test. Used wherever a pattern applies to a synthetic scrutinee
// (repeat counts, composite sub-patterns). Match does not use this: its
// places list lives at the match level because arms share it.
pub const ConstraintSet = struct {
    places: ArrayList(PlaceDef),
    constraints: ArrayList(Constraint),
    region: Region,
};

pub const ValueType = enum {
    array,
    object,
    string,
    number,
    boolean,
    null,
};

// One part of a solvable composite: a merge part, a template
// interpolation, or a repeat operand.
pub const Part = union(enum) {
    // `_`: constrains nothing, absorbs the leftover.
    placeholder,
    // A bare variable; binding analysis decides binder vs read. As a
    // merge part, an unbound local is the solvable rest. Does not
    // survive the bound stage.
    local: PathTable.Id,
    // Classified by binding analysis: an unbound local the match solves
    // for and binds.
    bind: LocalSlot,
    // Classified by binding analysis: a bound local compared by value.
    read: LocalSlot,
    // Classified by binding analysis: a module-level constant compared
    // by value.
    global: PathTable.Id,
    // A constant or evaluable expression goal, compared by value.
    expr: NodeId,
    // A structural sub-pattern; the set is rooted at the part's portion
    // of the composite value.
    sub: SetId,
};

pub const Limit = union(enum) {
    none,
    // A bare local: bound compares, unbound binds the matched value and
    // imposes no limit. Does not survive the bound stage.
    local: PathTable.Id,
    // Classified by binding analysis: an unbound range limit binds the
    // matched value. Never appears as a repeat cap (unbound caps clear).
    bind: LocalSlot,
    // Classified by binding analysis: a bound local compared by value.
    read: LocalSlot,
    // Classified by binding analysis: a module-level constant.
    global: PathTable.Id,
    // Evaluated at match time; every read must be bound.
    expr: NodeId,
};

pub const Constraint = struct {
    kind: Kind,
    region: Region,

    // Semantically a set: execution order is an analysis result, not an
    // IR property. Only eval_eq order relative to other eval_eq
    // constraints is preserved from source.
    pub const Kind = union(enum) {
        // shape tests. len_eq/len_min measure array elements or string
        // bytes, directed by the place's is_type. str_prefix/str_suffix
        // compare literal bytes at a string place's ends without
        // materializing a substring. len/count are u8: the match-step ops
        // encode them in one byte, and goal creation rejects larger
        // patterns.
        is_type: struct { place: PlaceId, ty: ValueType },
        len_eq: struct { place: PlaceId, len: u8 },
        len_min: struct { place: PlaceId, len: u8 },
        str_prefix: struct { place: PlaceId, literal: []const u8 },
        str_suffix: struct { place: PlaceId, literal: []const u8 },
        keys_exact: struct { place: PlaceId, count: u8 },
        keys_min: struct { place: PlaceId, count: u8 },
        has_key: struct { place: PlaceId, sid: StringTable.Id },
        // point tests
        eq_const: struct { place: PlaceId, value: NodeId },
        eq_places: struct { a: PlaceId, b: PlaceId },
        in_range: struct { place: PlaceId, lower: Limit, upper: Limit },
        // A variable occurrence. Binding analysis classifies each as
        // binder, bound read, or global reference (a zero-arity function
        // global evaluates per match, mirroring the solver's const_fn).
        // Does not survive the bound stage.
        local: struct { place: PlaceId, name: PathTable.Id },
        // Classified occurrences: bind writes the place's value into the
        // slot; eq_slot compares against the bound slot; eq_global
        // compares against the resolved module-level constant.
        bind: struct { place: PlaceId, slot: u8, name: PathTable.Id },
        eq_slot: struct { place: PlaceId, slot: u8, name: PathTable.Id },
        eq_global: struct { place: PlaceId, name: PathTable.Id },
        // Evaluate expr (a call or evaluable expression goal) and compare
        // the result against the place.
        eval_eq: struct { place: PlaceId, expr: NodeId },
        // Numeric negation applied count times before matching part.
        negated: struct { place: PlaceId, count: u32, part: Part },
        // composites: nested constraint scopes, never factored.
        // solvable_index is filled by binding analysis; a second
        // solvable part is the one-unbound-part compile error.
        solve_merge: struct {
            place: PlaceId,
            parts: ArrayList(Part),
            solvable_index: ?u32,
            // The merge's static type: the first structurally typed part
            // names it at creation, and conflicting static part types are
            // creation-time errors. Null = no structural part, resolved
            // from part values at match time.
            ty: ?ValueType,
        },
        match_template: struct { place: PlaceId, segments: ArrayList(Segment) },
        solve_repeat: struct { place: PlaceId, pattern: Part, count: Part },
        // Search the object's unmatched members for one whose key and
        // value match the nested scopes; commit to the first success.
        search_key: struct { place: PlaceId, key: SetId, value: SetId },
    };
};

pub const Segment = union(enum) {
    literal: []const u8,
    part: Part,
};

pub const Merge = struct {
    left: NodeId,
    right: NodeId,
};

pub const Mult = struct {
    left: NodeId,
    right: NodeId,
};

pub const ObjectPair = struct {
    key: NodeId,
    value: NodeId,
};

pub const Lambda = struct {
    parent_name: ?PathTable.Id,
    name: PathTable.Id,
    body: NodeId,
    captures: ArrayList(StringTable.Id) = .{},
};

// Greedy loop up to an optional cap, then an ordinary pattern test of the
// iteration count. Exactness, minimums, and count binding all live in
// count_test; cap only bounds how many attempts run. Populated at
// creation whenever the count pattern implies one (exact counts, bare
// locals, upper range limits, evaluable expressions); binding analysis
// keeps a cap whose reads are all bound and clears it otherwise.
pub const Repeat = struct {
    body: NodeId,
    cap: Limit,
    count_test: ?SetId,
};

pub const Range = struct {
    lower: ?NodeId,
    upper: ?NodeId,
};

pub const NumberString = struct {
    number: []const u8,
    negated: bool,

    pub fn toFloat(self: NumberString) error{InvalidCharacter}!f64 {
        const f = try std.fmt.parseFloat(f64, self.number);
        return if (self.negated) -f else f;
    }

    pub fn negate(self: NumberString) NumberString {
        return .{
            .number = self.number,
            .negated = !self.negated,
        };
    }
};

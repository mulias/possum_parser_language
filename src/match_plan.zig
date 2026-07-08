const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable(.runtime);
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

    pub fn deinit(self: *MatchPlan, allocator: Allocator) void {
        allocator.free(self.nodes);
        allocator.free(self.vars);
        allocator.free(self.elems);
        allocator.free(self.sids);
        allocator.free(self.ranges);
        allocator.free(self.merges);
    }

    pub fn print(self: MatchPlan, vm: VM, writer: *Writer) Writer.Error!void {
        _ = try self.printNode(vm, writer, 0);
    }

    // Returns the index one past the printed subtree.
    fn printNode(self: MatchPlan, vm: VM, writer: *Writer, idx: u32) Writer.Error!u32 {
        const node = self.nodes[idx];
        switch (node.tag) {
            .placeholder => try writer.print("placeholder", .{}),
            .bind => try writer.print("bind {s}", .{vm.strings.get(self.vars[node.payload].sid)}),
            .bound_eq => try writer.print("bound_eq {s}", .{vm.strings.get(self.vars[node.payload].sid)}),
            .equality => {
                try writer.print("eq ", .{});
                try self.elems[node.payload].print(vm, writer);
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
            .range => {
                const range = self.ranges[node.payload];
                try self.printLimit(vm, writer, range.lower);
                try writer.print("..", .{});
                try self.printLimit(vm, writer, range.upper);
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
        }
        return idx + 1;
    }

    fn printLimit(self: MatchPlan, vm: VM, writer: *Writer, limit: RangePlan.Limit) Writer.Error!void {
        switch (limit) {
            .none => {},
            .const_elem => |i| try self.elems[i].print(vm, writer),
            .bound_local => |i| try writer.print("{s}", .{vm.strings.get(self.vars[i].sid)}),
        }
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
    // `_`: always matches, binds nothing.
    placeholder,
    // A fixed-length array: payload = element count, element subtrees follow
    // in preorder.
    array,
    // An object with all-constant keys: payload = pair count, const_key
    // subtrees follow in preorder.
    object,
    // One object pair: payload = the key's sids index, the value subtree
    // follows. subtree_len covers the value, so skipping a pair is O(1).
    const_key,
    // A range with statically-resolvable bounds. ranges[payload].
    range,
    // A merge, flattened at compile time: merges[payload], part subtrees
    // follow in preorder. The interpreter resolves value parts (equality,
    // bound_eq) and derives the merge type from the resolved parts,
    // mirroring the solver's getMergeType.
    merge,
};

pub const MergePlan = struct {
    part_count: u32,
    // Index of the one part the solver has to solve for: the part that is
    // not a value at merge entry. Binding analysis guarantees at most one.
    // A bare local bound within the same merge by an earlier part is the
    // solvable part with a bound_eq subtree: it matches as an equality at
    // its position, after the earlier parts have bound it.
    solvable_index: ?u32,
};

// A merge part after the interpreter's resolution pass.
pub const ResolvedPart = union(enum) {
    // A folded constant or a bound local read (and possibly evaluated) at
    // match time.
    value: Elem,
    // A structural or solvable part: the node index of its subtree.
    subtree: u32,
};

pub const LocalVar = struct {
    sid: StringTable.Id,
    idx: u24, // stack index/module constant id
    negation_count: u2,

    pub fn isNegated(self: LocalVar) bool {
        return self.negation_count % 2 == 1;
    }

    pub fn hasBeenNegated(self: LocalVar) bool {
        return self.negation_count != 0;
    }
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
    };
};

const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const StringTable = @import("string_table.zig").StringTable(.runtime);
const VM = @import("vm.zig").VM;

// Compiled destructure plan: a flat preorder node array plus interned side
// tables, produced when a pattern's binding-time work is folded at compile
// time. Patterns the lowering does not support yet stay on the Pattern tree
// path (see Compiler.tryCreateMatchPlan).
pub const MatchPlan = struct {
    nodes: []Node,
    vars: []Pattern.PatternVar,
    // Constant elems compared with checkEquality. Dyn elems are immortal,
    // like module constants.
    elems: []Elem,
    // Constant object keys, interned at compile time.
    sids: []StringTable.Id,

    pub fn deinit(self: *MatchPlan, allocator: Allocator) void {
        allocator.free(self.nodes);
        allocator.free(self.vars);
        allocator.free(self.elems);
        allocator.free(self.sids);
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
        }
        return idx + 1;
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
};

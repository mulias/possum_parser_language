const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
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

    pub fn deinit(self: *MatchPlan, allocator: Allocator) void {
        allocator.free(self.nodes);
        allocator.free(self.vars);
        allocator.free(self.elems);
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
};

const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;
const Pattern = @import("pattern.zig").Pattern;
const VM = @import("vm.zig").VM;

// Compiled destructure plan: a flat preorder node array plus interned side
// tables, produced when a pattern's binding-time work is folded at compile
// time. Patterns the lowering does not support yet stay on the Pattern tree
// path (see Compiler.tryCreateMatchPlan).
pub const MatchPlan = struct {
    nodes: []Node,
    vars: []Pattern.PatternVar,

    pub fn deinit(self: *MatchPlan, allocator: Allocator) void {
        allocator.free(self.nodes);
        allocator.free(self.vars);
    }

    pub fn print(self: MatchPlan, vm: VM, writer: *Writer) Writer.Error!void {
        const root = self.nodes[0];
        switch (root.tag) {
            .placeholder => try writer.print("placeholder", .{}),
            .bind => try writer.print("bind {s}", .{vm.strings.get(self.vars[root.payload].sid)}),
            .bound_eq => try writer.print("bound_eq {s}", .{vm.strings.get(self.vars[root.payload].sid)}),
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
    // `_`: always matches, binds nothing.
    placeholder,
};

// Explain mode: `--explain` traces every parser call, tail call, return,
// and destructure attempt during the run, then renders the logical call
// tree pruned to the attempts that reached the farthest failure position.
//
// The VM only appends to `explain_events`; everything here runs at report
// time, after the parse has failed. Tail calls replace VM frames, so the
// event stream is the sole record of the logical call tree — a `call` with
// `is_tail` extends the current node's label chain instead of opening a
// child, and the single `ret` from the end of the chain closes the whole
// merged node.

const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Writer = std.Io.Writer;
const vm_mod = @import("vm.zig");
const VM = vm_mod.VM;
const Module = @import("module.zig").Module;
const Region = @import("../region.zig").Region;
const LineRelativeRegion = @import("../region.zig").LineRelativeRegion;
const StringTable = @import("string_table.zig").RuntimeStringTable;

// Values and patterns are rendered into fixed buffers at emit time: the
// husk pools reclaim consumed values, so an event can never hold an Elem.
pub const Snapshot = struct {
    buf: [capacity]u8 = undefined,
    len: u8 = 0,
    truncated: bool = false,

    pub const capacity = 64;

    pub fn slice(self: *const Snapshot) []const u8 {
        return self.buf[0..self.len];
    }
};

pub fn snapshot(vm: *const VM, printable: anytype) Snapshot {
    var snap = Snapshot{};
    var writer = Writer.fixed(&snap.buf);
    printable.print(vm.*, &writer) catch {
        snap.truncated = true;
    };
    var len = writer.end;
    if (snap.truncated) {
        // Drop any codepoint the cutoff split in half.
        while (len > 0 and snap.buf[len - 1] & 0xC0 == 0x80) len -= 1;
        if (len > 0 and snap.buf[len - 1] >= 0xC0) len -= 1;
    }
    snap.len = @intCast(len);
    return snap;
}

pub const Event = union(enum) {
    call: Call,
    ret: Ret,
    destructure_begin: DestructureBegin,
    destructure_end: DestructureEnd,
    step: Step,
    bind: Bind,

    pub const Call = struct {
        function_name: StringTable.Id,
        module_id: Module.Id,
        offset: usize,
        is_tail: bool,
    };

    pub const Ret = struct {
        failed: bool,
        offset: usize,
    };

    pub const DestructureBegin = struct {
        region: Region,
        module_id: Module.Id,
        offset: usize,
        value: Snapshot,
        pattern: Snapshot,
    };

    pub const DestructureEnd = struct {
        failed: bool,
    };

    pub const Step = struct {
        depth: u8,
        value: Snapshot,
        pattern: Snapshot,
        matched: bool,
    };

    pub const Bind = struct {
        name: StringTable.Id,
        value: Snapshot,
    };
};

const Label = struct {
    name: StringTable.Id,
    module_id: Module.Id,
};

const Child = union(enum) {
    node: usize,
    destructure: usize,
};

const Node = struct {
    labels: ArrayList(Label) = .{},
    start: usize,
    end: usize,
    failed: bool = false,
    children: ArrayList(Child) = .{},
    // Farthest input position touched anywhere in the subtree.
    reach: usize,
    // Farthest position of any failed attempt in the subtree. A successful
    // node can still contain the decisive failure: a repetition consumes
    // what it can and backtracks the last, failing iteration into success.
    fail_reach: ?usize = null,
};

const StepEntry = struct {
    depth: u8,
    value: Snapshot,
    pattern: Snapshot,
    matched: bool,
    binds: ArrayList(Event.Bind) = .{},
    children: ArrayList(usize) = .{},
};

const DestructureNode = struct {
    region: Region,
    module_id: Module.Id,
    offset: usize,
    value: Snapshot,
    pattern: Snapshot,
    failed: bool = false,
    steps: ArrayList(StepEntry) = .{},
};

const Tree = struct {
    nodes: ArrayList(Node) = .{},
    destructures: ArrayList(DestructureNode) = .{},

    const root: usize = 0;
};

fn build(allocator: Allocator, events: []const Event) !Tree {
    var tree = Tree{};

    try tree.nodes.append(allocator, Node{
        .start = 0,
        .end = 0,
        .reach = 0,
    });

    var open_nodes: ArrayList(usize) = .{};
    defer open_nodes.deinit(allocator);
    try open_nodes.append(allocator, Tree.root);

    var open_destructures: ArrayList(usize) = .{};
    defer open_destructures.deinit(allocator);

    for (events) |event| {
        const cur = open_nodes.items[open_nodes.items.len - 1];
        switch (event) {
            .call => |c| {
                const label = Label{ .name = c.function_name, .module_id = c.module_id };
                if (c.is_tail and cur != Tree.root) {
                    // The VM replaced the caller's frame: the callee's
                    // result is the caller's result, so the chain renders
                    // as one node.
                    try tree.nodes.items[cur].labels.append(allocator, label);
                } else {
                    const idx = tree.nodes.items.len;
                    try tree.nodes.append(allocator, Node{
                        .start = c.offset,
                        .end = c.offset,
                        .reach = c.offset,
                    });
                    try tree.nodes.items[idx].labels.append(allocator, label);
                    try tree.nodes.items[cur].children.append(allocator, .{ .node = idx });
                    try open_nodes.append(allocator, idx);
                }
            },
            .ret => |r| {
                if (open_nodes.items.len > 1) {
                    const idx = open_nodes.pop().?;
                    tree.nodes.items[idx].end = r.offset;
                    tree.nodes.items[idx].failed = r.failed;
                }
            },
            .destructure_begin => |d| {
                const idx = tree.destructures.items.len;
                try tree.destructures.append(allocator, DestructureNode{
                    .region = d.region,
                    .module_id = d.module_id,
                    .offset = d.offset,
                    .value = d.value,
                    .pattern = d.pattern,
                });
                try tree.nodes.items[cur].children.append(allocator, .{ .destructure = idx });
                try open_destructures.append(allocator, idx);
            },
            .destructure_end => |e| {
                if (open_destructures.items.len > 0) {
                    const idx = open_destructures.pop().?;
                    tree.destructures.items[idx].failed = e.failed;
                }
            },
            .step => |s| {
                if (open_destructures.items.len > 0) {
                    const idx = open_destructures.items[open_destructures.items.len - 1];
                    const dest = &tree.destructures.items[idx];
                    const step_idx = dest.steps.items.len;
                    try dest.steps.append(allocator, StepEntry{
                        .depth = s.depth,
                        .value = s.value,
                        .pattern = s.pattern,
                        .matched = s.matched,
                    });
                    // Attach to the most recent shallower step, making the
                    // flat depth-tagged stream a tree.
                    var parent: ?usize = null;
                    var i = step_idx;
                    while (i > 0) {
                        i -= 1;
                        if (dest.steps.items[i].depth < s.depth) {
                            parent = i;
                            break;
                        }
                    }
                    if (parent) |p| {
                        try dest.steps.items[p].children.append(allocator, step_idx);
                    }
                }
            },
            .bind => |b| {
                if (open_destructures.items.len > 0) {
                    const idx = open_destructures.items[open_destructures.items.len - 1];
                    const dest = &tree.destructures.items[idx];
                    if (dest.steps.items.len > 0) {
                        const last = dest.steps.items.len - 1;
                        try dest.steps.items[last].binds.append(allocator, b);
                    }
                }
            },
        }
    }

    computeReach(&tree, Tree.root);

    return tree;
}

fn computeReach(tree: *Tree, idx: usize) void {
    const node = &tree.nodes.items[idx];
    var reach = node.end;
    if (node.start > reach) reach = node.start;

    var fail_reach: ?usize = if (node.failed) node.end else null;

    for (node.children.items) |child| {
        switch (child) {
            .node => |n| {
                computeReach(tree, n);
                const child_reach = tree.nodes.items[n].reach;
                if (child_reach > reach) reach = child_reach;
                if (tree.nodes.items[n].fail_reach) |child_fail| {
                    if (fail_reach == null or child_fail > fail_reach.?) {
                        fail_reach = child_fail;
                    }
                }
            },
            .destructure => |d| {
                const dest = tree.destructures.items[d];
                if (dest.failed) {
                    if (fail_reach == null or dest.offset > fail_reach.?) {
                        fail_reach = dest.offset;
                    }
                }
            },
        }
    }
    node.reach = reach;
    node.fail_reach = fail_reach;
}

const max_render_depth = 32;
const max_children = 16;
const max_step_children = 8;

const Renderer = struct {
    vm: *VM,
    tree: *Tree,
    writer: *Writer,
    farthest: usize,
    pruned_successful: usize = 0,
    pruned_failed: usize = 0,

    fn posFmt(self: *Renderer, offset: usize) struct { line: usize, col: usize } {
        const pos = self.vm.materializePos(offset);
        return .{ .line = pos.line, .col = pos.lineOffset() };
    }

    fn printLabels(self: *Renderer, node: *const Node) !void {
        for (node.labels.items, 0..) |label, i| {
            if (i > 0) try self.writer.print(" \u{00BB} ", .{});
            const name = self.vm.strings.get(label.name);
            if (name.len > 0) {
                try self.writer.print("{s}", .{name});
            } else {
                try self.writer.print("(fn)", .{});
            }
        }
    }

    fn renderNode(self: *Renderer, idx: usize, prefix: []const u8, connector: []const u8, child_prefix: []const u8, depth: usize) Writer.Error!void {
        const node = &self.tree.nodes.items[idx];

        try self.writer.print("{s}{s}", .{ prefix, connector });
        try self.printLabels(node);

        // A node expands when a failed attempt somewhere in its subtree
        // reached the farthest position — successful nodes included, since
        // a repetition backtracks its decisive failing iteration away.
        const expand = node.fail_reach != null and
            node.fail_reach.? >= self.farthest and
            node.children.items.len > 0 and
            depth < max_render_depth;

        if (!node.failed) {
            const a = self.posFmt(node.start);
            const b = self.posFmt(node.end);
            try self.writer.print("  \u{2713} consumed {d}:{d}..{d}:{d}\n", .{ a.line, a.col, b.line, b.col });
            if (expand) {
                try self.renderChildren(node, child_prefix, depth);
            } else if (node.children.items.len > 0) {
                self.pruned_successful += 1;
            }
            return;
        }

        const at_farthest = node.fail_reach != null and node.fail_reach.? >= self.farthest;

        if (at_farthest) {
            // The frame's return position reflects backtracking resets;
            // the deepest failed attempt is where the node really died.
            const at = self.posFmt(node.fail_reach.?);
            try self.writer.print("  \u{2717} at {d}:{d}\n", .{ at.line, at.col });
            if (expand) {
                try self.renderChildren(node, child_prefix, depth);
            } else if (node.children.items.len > 0) {
                self.pruned_failed += 1;
            }
        } else {
            const reach = self.posFmt(node.reach);
            try self.writer.print("  \u{2717} reached {d}:{d}\n", .{ reach.line, reach.col });
            if (node.children.items.len > 0) self.pruned_failed += 1;
        }
    }

    fn renderChildren(self: *Renderer, node: *const Node, prefix: []const u8, depth: usize) Writer.Error!void {
        const children = node.children.items;
        const shown = @min(children.len, max_children);

        for (children[0..shown], 0..) |child, i| {
            const last = i == shown - 1 and children.len == shown;
            const connector: []const u8 = if (last) "\u{2514}\u{2500} " else "\u{251C}\u{2500} ";
            const bar: []const u8 = if (last) "   " else "\u{2502}  ";

            var child_prefix_buf: [256]u8 = undefined;
            const child_prefix = std.fmt.bufPrint(&child_prefix_buf, "{s}{s}", .{ prefix, bar }) catch prefix;

            switch (child) {
                .node => |n| try self.renderNode(n, prefix, connector, child_prefix, depth + 1),
                .destructure => |d| try self.renderDestructure(d, prefix, connector, child_prefix),
            }
        }

        if (children.len > shown) {
            try self.writer.print("{s}\u{2514}\u{2500} \u{2026} {d} more attempts\n", .{ prefix, children.len - shown });
            self.pruned_failed += children.len - shown;
        }
    }

    fn renderDestructure(self: *Renderer, idx: usize, prefix: []const u8, connector: []const u8, child_prefix: []const u8) Writer.Error!void {
        const dest = &self.tree.destructures.items[idx];

        if (!dest.failed) {
            // A successful destructure is not a parse attempt; skip it.
            return;
        }

        const module = self.vm.getModule(dest.module_id);
        const loc = LineRelativeRegion.fromRegion(dest.region, module.source, null);

        try self.writer.print("{s}{s}destructure at {s}:{d}:{d}  \u{2717} ", .{
            prefix,
            connector,
            module.name,
            loc.line,
            loc.relative_start,
        });
        try self.printSnapshot(&dest.value);
        try self.writer.print(" did not match ", .{});
        try self.printSnapshot(&dest.pattern);
        try self.writer.print("\n", .{});

        // The first step restates the top-level value and pattern; render
        // its children, following the failing spine.
        if (dest.steps.items.len > 0) {
            try self.renderStepChildren(dest, 0, child_prefix, 1);
        }
    }

    fn printSnapshot(self: *Renderer, snap: *const Snapshot) !void {
        try self.writer.print("{s}", .{snap.slice()});
        if (snap.truncated) try self.writer.print("\u{2026}", .{});
    }

    fn renderStepChildren(self: *Renderer, dest: *const DestructureNode, step_idx: usize, prefix: []const u8, depth: usize) Writer.Error!void {
        const children = dest.steps.items[step_idx].children.items;
        const shown = @min(children.len, max_step_children);
        const skipped = children.len - shown;

        // Show the final attempts: merge and repeat patterns retry many
        // splits, and the last ones are the ones that decided the result.
        const first = skipped;

        if (skipped > 0) {
            try self.writer.print("{s}\u{251C}\u{2500} \u{2026} {d} earlier attempts\n", .{ prefix, skipped });
        }

        // The failing spine continues through the last failed child.
        var last_failed: ?usize = null;
        for (children[first..]) |c| {
            if (!dest.steps.items[c].matched) last_failed = c;
        }

        for (children[first..], first..) |c, i| {
            const step = &dest.steps.items[c];
            const last = i == children.len - 1;
            const connector: []const u8 = if (last) "\u{2514}\u{2500} " else "\u{251C}\u{2500} ";
            const bar: []const u8 = if (last) "   " else "\u{2502}  ";

            try self.writer.print("{s}{s}", .{ prefix, connector });
            try self.printSnapshot(&step.value);
            try self.writer.print(" vs ", .{});
            try self.printSnapshot(&step.pattern);
            if (step.matched) {
                try self.writer.print("  \u{2713}", .{});
            } else {
                try self.writer.print("  \u{2717}", .{});
            }
            for (step.binds.items) |bind| {
                try self.writer.print("  {s} bound to ", .{self.vm.strings.get(bind.name)});
                try self.printSnapshot(&bind.value);
            }
            try self.writer.print("\n", .{});

            if (last_failed == c and step.children.items.len > 0 and depth < max_render_depth) {
                var child_prefix_buf: [256]u8 = undefined;
                const child_prefix = std.fmt.bufPrint(&child_prefix_buf, "{s}{s}", .{ prefix, bar }) catch prefix;
                try self.renderStepChildren(dest, c, child_prefix, depth + 1);
            }
        }
    }
};

pub fn render(vm: *VM, writer: *Writer) !void {
    if (vm.explain_events.items.len == 0) return;

    var arena = std.heap.ArenaAllocator.init(vm.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var tree = try build(allocator, vm.explain_events.items);

    const farthest_offset = if (vm.farthest) |record| record.offset else vm.inputOffset;
    const farthest_pos = vm.materializePos(farthest_offset);

    try writer.print("\nParse trace (pruned to attempts reaching {d}:{d}):\n\n", .{
        farthest_pos.line,
        farthest_pos.lineOffset(),
    });

    var renderer = Renderer{
        .vm = vm,
        .tree = &tree,
        .writer = writer,
        .farthest = farthest_offset,
    };

    const root = &tree.nodes.items[Tree.root];
    for (root.children.items, 0..) |child, i| {
        _ = i;
        switch (child) {
            .node => |n| try renderer.renderNode(n, "", "", "", 0),
            .destructure => |d| try renderer.renderDestructure(d, "", "", ""),
        }
    }

    if (renderer.pruned_successful > 0 or renderer.pruned_failed > 0) {
        try writer.print("\npruned: {d} successful subtrees, {d} failed attempts falling short of {d}:{d}\n", .{
            renderer.pruned_successful,
            renderer.pruned_failed,
            farthest_pos.line,
            farthest_pos.lineOffset(),
        });
    }
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Ir = @import("ir.zig").Ir;

// Local slot operands are a single byte.
pub const max_locals = 256;

pub const SlotSet = std.bit_set.StaticBitSet(max_locals);

// Last-use information for a function's local slots, computed by a backward
// dataflow walk over its IR. A slot is read by the local-slot ops (GetLocal,
// GetBoundLocal, CallFunctionLocal, CallTailFunctionLocal, CaptureLocal) and
// by DestructurePlan for every slot its match plan references: whether a
// plan variable compares against the slot or binds it is only known at
// runtime, so both count as reads.
//
// Deaths are recorded at read sites only: a slot dies at the instruction
// that reads it last on every path. A slot whose remaining reads are all on
// the other side of a branch has no death on the read-free path. That is
// enough for placing refcount decrements at last reads; it just leaves the
// count conservatively high on paths that never read the slot.
pub const Liveness = struct {
    // deaths[i] holds the slots read by instruction i and by nothing
    // reachable after it.
    deaths: []SlotSet,

    // Requires an IR that passes verify. `plan_reads` maps each match plan
    // id to the slots the plan references; entries for ids not used by this
    // function's DestructurePlan instructions are ignored.
    pub fn analyze(allocator: Allocator, ir: *const Ir, plan_reads: []const SlotSet) Allocator.Error!Liveness {
        const insns = ir.instructions.items;

        const reads = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(reads);
        for (insns, 0..) |insn, i| {
            reads[i] = instructionReads(insn.operand, plan_reads);
        }

        const live_in = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(live_in);
        @memset(live_in, SlotSet.initEmpty());

        // Loop back-edges make one backward pass insufficient: a read early
        // in a loop body keeps the slot live at the back-edge, which is only
        // seen after live_in of the loop start is known. Iterate until the
        // sets stabilize.
        var changed = true;
        while (changed) {
            changed = false;
            var i = insns.len;
            while (i > 0) {
                i -= 1;
                const in = liveOut(insns, live_in, i).unionWith(reads[i]);
                if (!in.eql(live_in[i])) {
                    live_in[i] = in;
                    changed = true;
                }
            }
        }

        const deaths = try allocator.alloc(SlotSet, insns.len);
        errdefer allocator.free(deaths);
        for (insns, 0..) |_, i| {
            deaths[i] = reads[i].differenceWith(liveOut(insns, live_in, i));
        }

        return .{ .deaths = deaths };
    }

    pub fn deinit(self: *Liveness, allocator: Allocator) void {
        allocator.free(self.deaths);
    }

    pub fn diesAt(self: Liveness, index: Ir.Index, slot: usize) bool {
        return self.deaths[index].isSet(slot);
    }
};

fn instructionReads(operand: Ir.Operand, plan_reads: []const SlotSet) SlotSet {
    switch (operand) {
        .destructure_plan => |idx| return plan_reads[idx],
        else => {
            var reads = SlotSet.initEmpty();
            const op = Ir.operandOp(operand);
            if (Ir.localSlotOperand(op, operand)) |slot| reads.set(slot);
            return reads;
        },
    }
}

// The four invariants relied on here are enforced by Ir.verify, which is
// gated to Debug builds. In Release a compiler emission bug bypasses that
// clean panic: without the guarantees this would index past the end, read
// an unpatched target, or hit an unreachable below, producing garbage death
// sets instead.
fn liveOut(insns: []const Ir.Insn, live_in: []const SlotSet, i: usize) SlotSet {
    const operand = insns[i].operand;
    switch (Ir.operandOp(operand).stackEffect()) {
        // Invariant: a fixed/call op is never the last instruction — a
        // terminal always follows on this path — so `i + 1` is in bounds.
        .fixed, .call => return live_in[i + 1],
        .branch => |branch| {
            // Invariant: only jump/jump_back operands carry a .branch stack
            // effect, so no other operand reaches this switch.
            const target = switch (operand) {
                .jump => |j| j.target,
                .jump_back => |j| j.target,
                else => unreachable,
            };
            // Invariant: every jump is patched before liveness runs, so its
            // target is a valid in-bounds instruction index.
            std.debug.assert(target != Ir.unpatched_jump);
            var out = live_in[target];
            if (branch.fallthrough != null) out.setUnion(live_in[i + 1]);
            return out;
        },
        .terminal => return SlotSet.initEmpty(),
        // Invariant: .unknown belongs only to NativeCode, which is
        // hand-written into builtin chunks and never emitted through the IR
        // this analysis walks.
        .unknown => unreachable,
    }
}

const testing = std.testing;
const Region = @import("region.zig").Region;

fn testRegion(n: usize) Region {
    return Region.new(n, n + 1);
}

fn slots(comptime indices: []const usize) SlotSet {
    var set = SlotSet.initEmpty();
    for (indices) |index| set.set(index);
    return set;
}

test "a slot dies at its last read" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(3));

    var liveness = try Liveness.analyze(allocator, &ir, &.{});
    defer liveness.deinit(allocator);

    try testing.expectEqual(slots(&.{}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{0}), liveness.deaths[1]);
    try testing.expectEqual(slots(&.{}), liveness.deaths[2]);
}

test "a read behind a branch keeps the slot live at the branch" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    const jump = try ir.push(allocator, .{ .jump = .{ .op = .JumpIfFailure, .target = Ir.unpatched_jump } }, testRegion(1));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(3));
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(4));

    var liveness = try Liveness.analyze(allocator, &ir, &.{});
    defer liveness.deinit(allocator);

    // The fallthrough path reads slot 0 again, so it survives the first
    // read and the branch, and dies at the read inside the branch.
    try testing.expectEqual(slots(&.{}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{0}), liveness.deaths[2]);
}

test "a loop back-edge keeps a slot read at the loop head alive" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    const loop_start = ir.nextIndex();
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    const done = try ir.push(allocator, .{ .jump = .{ .op = .JumpIfFailure, .target = Ir.unpatched_jump } }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .Drop }, testRegion(2));
    _ = try ir.push(allocator, .{ .jump_back = .{ .op = .JumpBack, .target = loop_start } }, testRegion(3));
    ir.patchJumpTarget(done);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(4));

    var liveness = try Liveness.analyze(allocator, &ir, &.{});
    defer liveness.deinit(allocator);

    // The read at the loop head is reachable from the back-edge, so the
    // slot never dies inside the loop, and the exit path never reads it.
    for (liveness.deaths) |death_set| {
        try testing.expectEqual(slots(&.{}), death_set);
    }
}

test "destructure plan reads its plan's slots" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .destructure_plan = 0 }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(2));

    var liveness = try Liveness.analyze(allocator, &ir, &.{slots(&.{ 0, 1 })});
    defer liveness.deinit(allocator);

    try testing.expectEqual(slots(&.{}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{ 0, 1 }), liveness.deaths[1]);
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Ir = @import("ir.zig").Ir;
const RangeLimitKind = @import("ir.zig").RangeLimitKind;

// Local slot operands are a single byte.
pub const max_locals = 256;

pub const SlotSet = std.bit_set.StaticBitSet(max_locals);

// Last-use information for a function's local slots, computed by a backward
// dataflow walk over its IR. A slot is read by the local-slot ops (GetLocal,
// CallFunctionLocal, CallTailFunctionLocal, CaptureLocal) and by the match
// ops that compare against a bound local (slot-kind MatchCmp, read-kind
// range bounds). A slot is defined — overwritten without reading — by
// SetLocal and MatchBind; a definition kills the slot's liveness above it.
// The bind kill is sound because binding analysis admits a bind occurrence
// only where the slot is unbound or out of scope on every reaching path, so
// nothing reachable from above can read the value the bind replaces, even
// when the match fails partway.
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

    // Requires an IR that passes verify.
    // Match steps address scratch through the match register stack rather
    // than frame slots. Those register operands share the frame-local
    // numbering (both start at 0) but name a separate address space, so
    // they are not treated as local reads/defs — only each match op's
    // genuine frame-local operands (bound-var binds, slot compares, range
    // bounds) count.
    pub fn analyze(allocator: Allocator, ir: *const Ir) Allocator.Error!Liveness {
        const insns = ir.instructions.items;

        // Semidet match ops carry no fail target in their operand: they
        // jump to the innermost open window's shared fail block. Recover
        // that successor for the control-flow walk below.
        const fail_targets = try ir.matchFailTargets(allocator);
        defer allocator.free(fail_targets);

        const reads = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(reads);
        const defs = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(defs);
        for (insns, 0..) |insn, i| {
            reads[i] = instructionReads(insn.operand);
            defs[i] = instructionDefs(insn.operand);
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
                const in = liveOut(insns, live_in, fail_targets, i).differenceWith(defs[i]).unionWith(reads[i]);
                if (!in.eql(live_in[i])) {
                    live_in[i] = in;
                    changed = true;
                }
            }
        }

        const deaths = try allocator.alloc(SlotSet, insns.len);
        errdefer allocator.free(deaths);
        for (insns, 0..) |_, i| {
            deaths[i] = reads[i].differenceWith(liveOut(insns, live_in, fail_targets, i));
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

fn instructionReads(operand: Ir.Operand) SlotSet {
    var reads = SlotSet.initEmpty();
    // Match scratch register operands live on the match register stack, a
    // separate address space from frame locals, so they are ignored here;
    // only each match op's genuine frame-local operands (bound-var slots,
    // range bounds) count.
    switch (operand) {
        // A slot-kind MatchCmp reads the bound local it compares against.
        .match_cmp => |m| if (m.kind == .slot) reads.set(@intCast(m.arg)),
        // A read-kind MatchBound reads the bound local it compares against.
        .match_bound => |m| if (m.kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.arg)),
        // MatchRepeatRange reads any bound-local range bounds.
        .match_repeat_range => |m| {
            if (m.lower_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.lower_arg));
            if (m.upper_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.upper_arg));
        },
        else => {
            const op = Ir.operandOp(operand);
            if (Ir.localSlotOperand(op, operand)) |slot| reads.set(slot);
        },
    }
    return reads;
}

fn instructionDefs(operand: Ir.Operand) SlotSet {
    var defs = SlotSet.initEmpty();
    // Match scratch register defs live on the match register stack; only
    // MatchBind's bound local and SetLocal slots are frame slots.
    switch (operand) {
        // MatchBind overwrites its bound local (an unbound-var range bound
        // now lowers to its own MatchBind, so it flows through here too).
        .match_bytes => |m| if (m.op == .MatchBind) defs.set(m.byte1),
        else => {
            const op = Ir.operandOp(operand);
            if (Ir.localSlotDefOperand(op, operand)) |slot| defs.set(slot);
        },
    }
    return defs;
}

// The four invariants relied on here are enforced by Ir.verify, which is
// gated to Debug builds. In Release a compiler emission bug bypasses that
// clean panic: without the guarantees this would index past the end, read
// an unpatched target, or hit an unreachable below, producing garbage death
// sets instead.
fn liveOut(insns: []const Ir.Insn, live_in: []const SlotSet, fail_targets: []const Ir.Index, i: usize) SlotSet {
    const operand = insns[i].operand;
    const op = Ir.operandOp(operand);
    // Semidet match ops fail to the innermost window's shared fail block.
    // Their fallthrough successor is `i + 1`; MatchRefail has no
    // fallthrough — it always cascades to the enclosing window.
    if (Ir.opFailsToWindow(op)) {
        const target = fail_targets[i];
        std.debug.assert(target != Ir.unpatched_jump);
        var out = live_in[target];
        if (op != .MatchRefail) out.setUnion(live_in[i + 1]);
        return out;
    }
    switch (op.stackEffect()) {
        // Invariant: a fixed/call op is never the last instruction — a
        // terminal always follows on this path — so `i + 1` is in bounds.
        .fixed, .call => return live_in[i + 1],
        .branch => |branch| {
            // Invariant: after the window-failing ops above, only
            // jump/jump_back, MatchWindowEnter, and MatchRepeatNext carry a
            // .branch stack effect, so no other operand reaches this switch.
            const target = switch (operand) {
                .jump => |j| j.target,
                .jump_back => |j| j.target,
                .w_enter => |m| m.target,
                .match_repeat_next => |m| m.target,
                .match_claim_done => |m| m.target,
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
const Region = @import("../region.zig").Region;

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

    var liveness = try Liveness.analyze(allocator, &ir);
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

    var liveness = try Liveness.analyze(allocator, &ir);
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

    var liveness = try Liveness.analyze(allocator, &ir);
    defer liveness.deinit(allocator);

    // The read at the loop head is reachable from the back-edge, so the
    // slot never dies inside the loop, and the exit path never reads it.
    for (liveness.deaths) |death_set| {
        try testing.expectEqual(slots(&.{}), death_set);
    }
}

test "a SetLocal definition ends the previous value's live range" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .SetLocal, .byte = 0 } }, testRegion(1));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(3));

    var liveness = try Liveness.analyze(allocator, &ir);
    defer liveness.deinit(allocator);

    // The value read at 0 dies there: SetLocal replaces it without reading.
    // The rebound value's last read is at 2.
    try testing.expectEqual(slots(&.{0}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{}), liveness.deaths[1]);
    try testing.expectEqual(slots(&.{0}), liveness.deaths[2]);
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Ir = @import("ir.zig").Ir;
const RangeLimitKind = @import("ir.zig").RangeLimitKind;

// Local slot operands are a single byte.
pub const max_locals = 256;

pub const SlotSet = std.bit_set.StaticBitSet(max_locals);

// The slots a match plan touches, recorded when the plan is lowered: a
// compare/eval occurrence reads its slot, a bind occurrence defines it. A
// slot both bound and compared within one plan appears in both sets.
pub const PlanSlots = struct {
    reads: SlotSet,
    defs: SlotSet,
};

// Last-use information for a function's local slots, computed by a backward
// dataflow walk over its IR. A slot is read by the local-slot ops (GetLocal,
// CallFunctionLocal, CallTailFunctionLocal, CaptureLocal) and by
// DestructurePlan for every slot its match plan compares against or
// evaluates. A slot is defined — overwritten without reading — by SetLocal
// and by DestructurePlan for every slot its plan binds; a definition kills
// the slot's liveness above it. The plan kill is sound because binding
// analysis admits a bind occurrence only where the slot is unbound or out
// of scope on every reaching path, so nothing reachable from above can read
// the value the bind replaces, even when the plan fails partway.
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

    // Requires an IR that passes verify. `plan_slots` maps each match plan
    // id to the slots the plan reads and defines; entries for ids not used
    // by this function's DestructurePlan instructions are ignored.
    // `window_mode` marks a function whose match steps address scratch
    // through the match register stack rather than frame slots. Those
    // register operands share the frame-local numbering (both start at 0)
    // but name a separate address space, so they must not be treated as
    // local reads/defs — only each match op's genuine frame-local operands
    // (bound-var binds, slot compares, range bounds) count.
    pub fn analyze(allocator: Allocator, ir: *const Ir, plan_slots: []const PlanSlots, window_mode: bool) Allocator.Error!Liveness {
        const insns = ir.instructions.items;

        const reads = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(reads);
        const defs = try allocator.alloc(SlotSet, insns.len);
        defer allocator.free(defs);
        for (insns, 0..) |insn, i| {
            reads[i] = instructionReads(insn.operand, plan_slots, window_mode);
            defs[i] = instructionDefs(insn.operand, plan_slots, window_mode);
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
                const in = liveOut(insns, live_in, i).differenceWith(defs[i]).unionWith(reads[i]);
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

fn instructionReads(operand: Ir.Operand, plan_slots: []const PlanSlots, window_mode: bool) SlotSet {
    var reads = SlotSet.initEmpty();
    // Match scratch register operands are frame slots only in frame mode;
    // in window mode they live on the match register stack and are ignored
    // here. Frame-local operands (bound-var slots, plan slots) count in
    // both modes.
    const regs = !window_mode;
    switch (operand) {
        .destructure_plan => |idx| return plan_slots[idx].reads,
        // MatchBind and MatchElem read their source register;
        // MatchElemDyn also reads the loop base register.
        .match_bytes => |m| if (regs) {
            reads.set(m.byte2);
            if (m.op == .MatchElemDyn) reads.set(m.byte3);
        },
        // Tests read the register under test; MatchSlot also reads the
        // local it compares against, and MatchStrCovered reads both the
        // front and end cursor registers. The cast steps read their src
        // register (byte2) and define dst (byte1); in the in-place form
        // src == dst.
        .match_test => |m| switch (m.op) {
            .MatchCastNum, .MatchCastBool => if (regs) reads.set(m.byte2),
            .MatchStrCovered => if (regs) {
                reads.set(m.byte1);
                reads.set(m.byte2);
            },
            // byte2 is the compared bound local — a frame slot in both
            // modes; byte1 is the tested register.
            .MatchSlot => {
                if (regs) reads.set(m.byte1);
                reads.set(m.byte2);
            },
            else => if (regs) reads.set(m.byte1),
        },
        // MatchConst/MatchGlobal read the tested register; MatchKey and
        // MatchMergeNum(Neg) read their source register.
        .match_const => |m| if (regs) reads.set(if (Ir.matchConstHasSrcReg(m.op)) m.byte2 else m.byte1),
        // MatchObjectRest reads its source register.
        .match_rest => |m| if (regs) reads.set(m.byte2),
        // The rest-with-search variant reads its source and the claimed
        // search-key registers it subtracts.
        .match_rest_search => |m| if (regs) {
            reads.set(m.src);
            var r = m.claim_base;
            while (r < m.claim_base + m.claim_count) : (r += 1) reads.set(r);
        },
        // MatchNextUnclaimed reads the searched object and the claim
        // registers below its key destination.
        .match_search => |m| if (regs) {
            reads.set(m.src);
            var r = m.key_dst - m.claim_count;
            while (r < m.key_dst) : (r += 1) reads.set(r);
        },
        // MatchKeyBound also reads the bound key local — a frame slot in
        // both modes.
        .match_key_bound => |m| {
            if (regs) {
                reads.set(m.src);
                var r = m.key_dst - m.claim_count;
                while (r < m.key_dst) : (r += 1) reads.set(r);
            }
            reads.set(m.slot);
        },
        // MatchInRange reads the tested register and any bound that reads
        // a bound local's slot; bind bounds define rather than read. The
        // read/bind bounds are frame slots in both modes.
        .match_range => |m| {
            if (regs) reads.set(m.slot);
            if (m.lower_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.lower_arg));
            if (m.upper_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.upper_arg));
        },
        // MatchRepeatRange reads the scanned string register and any
        // bound-local range bounds.
        .match_repeat_range => |m| {
            if (regs) reads.set(m.src);
            if (m.lower_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.lower_arg));
            if (m.upper_kind == @intFromEnum(RangeLimitKind.read)) reads.set(@intCast(m.upper_arg));
        },
        // The array-repeat loop entry reads the array; the loop head
        // reads the array and advances the base register.
        .match_repeat_init => |m| if (regs) reads.set(m.src),
        .match_repeat_next => |m| if (regs) {
            reads.set(m.src);
            reads.set(m.base);
        },
        // String-template steps read the source string and their cursor
        // registers; the opposite cursor bounds each chomp.
        .match_str_init => |m| if (regs) reads.set(m.src),
        .match_str_rest => |m| if (regs) {
            reads.set(m.src);
            reads.set(m.front);
            reads.set(m.end);
        },
        .match_str_lit => |m| if (regs) {
            reads.set(m.src);
            reads.set(m.cursor);
            reads.set(m.opp);
        },
        .match_str_val => |m| if (regs) {
            reads.set(m.src);
            reads.set(m.cursor);
            reads.set(m.opp);
        },
        .match_str_char => |m| if (regs) {
            reads.set(m.src);
            reads.set(m.cursor);
            reads.set(m.opp);
        },
        else => {
            const op = Ir.operandOp(operand);
            if (Ir.localSlotOperand(op, operand)) |slot| reads.set(slot);
        },
    }
    return reads;
}

fn instructionDefs(operand: Ir.Operand, plan_slots: []const PlanSlots, window_mode: bool) SlotSet {
    var defs = SlotSet.initEmpty();
    // See instructionReads: match scratch register defs are frame slots
    // only in frame mode. MatchBind's local and bind range bounds are
    // frame slots in both modes.
    const regs = !window_mode;
    switch (operand) {
        .destructure_plan => |idx| return plan_slots[idx].defs,
        // MatchBind overwrites its bound local (a frame slot in both
        // modes); MatchElem overwrites its destination register.
        .match_bytes => |m| if (m.op == .MatchBind) {
            defs.set(m.byte1);
        } else if (regs) {
            defs.set(m.byte1);
        },
        // The repeat steps overwrite their destination register (derived
        // count or representative chunk); the cast steps rewrite their
        // register in place with the parsed value. Straight defs, sound the
        // same way projection defs are.
        .match_test => |m| if (regs) switch (m.op) {
            .MatchRepeatValue, .MatchRepeatChunk => defs.set(m.byte2),
            .MatchCastNum, .MatchCastBool => defs.set(m.byte1),
            else => {},
        },
        // MatchKey and MatchMergeNum(Neg) overwrite their destination
        // register on the success path only; treating it as a straight
        // def is sound for the same reason plan binds are: nothing
        // reachable reads the previous value once a projection targets
        // the register.
        .match_const => |m| if (regs and Ir.matchConstHasSrcReg(m.op)) defs.set(m.byte1),
        .match_rest => |m| if (regs) defs.set(m.byte1),
        .match_rest_search => |m| if (regs) defs.set(m.dst),
        // MatchNextUnclaimed and MatchKeyBound overwrite the found key
        // and value registers.
        .match_search => |m| if (regs) {
            defs.set(m.key_dst);
            defs.set(m.val_dst);
        },
        .match_key_bound => |m| if (regs) {
            defs.set(m.key_dst);
            defs.set(m.val_dst);
        },
        // An unbound-var (bind) range bound overwrites its local slot — a
        // frame slot in both modes.
        .match_range => |m| {
            if (m.lower_kind == @intFromEnum(RangeLimitKind.bind)) defs.set(@intCast(m.lower_arg));
            if (m.upper_kind == @intFromEnum(RangeLimitKind.bind)) defs.set(@intCast(m.upper_arg));
        },
        // MatchRepeatRange overwrites its count destination register.
        .match_repeat_range => |m| if (regs) defs.set(m.dst),
        // The loop entry overwrites the count and base registers; the
        // loop head rewrites base from its previous value (a read, not
        // a def).
        .match_repeat_init => |m| if (regs) {
            defs.set(m.count_dst);
            defs.set(m.base);
        },
        // MatchStrInit primes both cursors; MatchStrRest and MatchStrChar
        // overwrite their destination register. The cursor rewrites in the
        // chomp steps are reads, not defs (like MatchRepeatNext's base).
        .match_str_init => |m| if (regs) {
            defs.set(m.front);
            defs.set(m.end);
        },
        .match_str_rest => |m| if (regs) defs.set(m.dst),
        .match_str_char => |m| if (regs) defs.set(m.dst),
        else => {
            const op = Ir.operandOp(operand);
            if (Ir.localSlotDefOperand(op, operand, window_mode)) |slot| defs.set(slot);
        },
    }
    return defs;
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
                .match_test => |m| m.target,
                .match_const => |m| m.target,
                .match_search => |m| m.target,
                .match_key_bound => |m| m.target,
                .match_range => |m| m.target,
                .match_repeat_range => |m| m.target,
                .match_repeat_init => |m| m.target,
                .match_repeat_next => |m| m.target,
                .match_str_lit => |m| m.target,
                .match_str_val => |m| m.target,
                .match_str_char => |m| m.target,
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

    var liveness = try Liveness.analyze(allocator, &ir, &.{}, false);
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

    var liveness = try Liveness.analyze(allocator, &ir, &.{}, false);
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

    var liveness = try Liveness.analyze(allocator, &ir, &.{}, false);
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

    var liveness = try Liveness.analyze(allocator, &ir, &.{
        .{ .reads = slots(&.{ 0, 1 }), .defs = slots(&.{}) },
    }, false);
    defer liveness.deinit(allocator);

    try testing.expectEqual(slots(&.{}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{ 0, 1 }), liveness.deaths[1]);
}

test "a plan bind kills liveness across a loop back-edge" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    const loop_start = ir.nextIndex();
    _ = try ir.push(allocator, .{ .destructure_plan = 0 }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(1));
    const done = try ir.push(allocator, .{ .jump = .{ .op = .JumpIfFailure, .target = Ir.unpatched_jump } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .Drop }, testRegion(3));
    _ = try ir.push(allocator, .{ .jump_back = .{ .op = .JumpBack, .target = loop_start } }, testRegion(4));
    ir.patchJumpTarget(done);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(5));

    var liveness = try Liveness.analyze(allocator, &ir, &.{
        .{ .reads = slots(&.{}), .defs = slots(&.{0}) },
    }, false);
    defer liveness.deinit(allocator);

    // The bind at the loop head overwrites slot 0 without reading it, so
    // the back-edge carries no liveness and the read below the bind is the
    // slot's last on every path.
    try testing.expectEqual(slots(&.{0}), liveness.deaths[1]);
}

test "a SetLocal definition ends the previous value's live range" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .SetLocal, .byte = 0 } }, testRegion(1));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(3));

    var liveness = try Liveness.analyze(allocator, &ir, &.{}, false);
    defer liveness.deinit(allocator);

    // The value read at 0 dies there: SetLocal replaces it without reading.
    // The rebound value's last read is at 2.
    try testing.expectEqual(slots(&.{0}), liveness.deaths[0]);
    try testing.expectEqual(slots(&.{}), liveness.deaths[1]);
    try testing.expectEqual(slots(&.{0}), liveness.deaths[2]);
}

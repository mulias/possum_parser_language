const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Chunk = @import("chunk.zig").Chunk;
const ChunkError = @import("chunk.zig").ChunkError;
const OpCode = @import("op_code.zig").OpCode;
const Region = @import("region.zig").Region;

// Linear instruction list emitted by the compiler for a single function.
// Jumps reference instruction indices. Byte offsets, jump distances, and
// variable-length operand encodings are resolved when the instructions are
// written to a Chunk.
pub const Ir = struct {
    instructions: ArrayList(Insn) = .{},
    // Set when writeTo fails with ShortOverflow, so the caller can report
    // where the oversized jump is.
    overflow_region: ?Region = null,
    // Set when verify fails, so the caller can report which instruction
    // failed.
    verify_failure: ?Index = null,

    pub const Index = u32;

    pub const unpatched_jump: Index = std.math.maxInt(Index);

    pub const Insn = struct {
        operand: Operand,
        region: Region,
    };

    pub const Operand = union(enum) {
        none: OpCode,
        byte: struct { op: OpCode, byte: u8 },
        byte_pair: struct { op: OpCode, byte1: u8, region1: Region, byte2: u8, region2: Region },
        long: struct { op: OpCode, value: u32 },
        get_constant: u24,
        get_constant_mutable: u24,
        call_function_constant: u24,
        call_tail_function_constant: u24,
        destructure: u24,
        jump: struct { op: OpCode, target: Index },
        jump_back: struct { op: OpCode, target: Index },
    };

    pub fn deinit(self: *Ir, allocator: Allocator) void {
        self.instructions.deinit(allocator);
    }

    pub fn nextIndex(self: *Ir) Index {
        return @intCast(self.instructions.items.len);
    }

    pub fn push(self: *Ir, allocator: Allocator, operand: Operand, region: Region) !Index {
        const index = self.nextIndex();
        try self.instructions.append(allocator, .{ .operand = operand, .region = region });
        return index;
    }

    // Rewrite the constant push at `index` to push a mutable copy. The
    // compiler only knows a container constant will be mutated by inserts
    // after the push is emitted.
    pub fn patchConstantMutable(self: *Ir, index: Index) void {
        const insn = &self.instructions.items[index];
        const idx = insn.operand.get_constant;
        insn.operand = .{ .get_constant_mutable = idx };
    }

    // Point the jump at `index` to the next instruction to be emitted.
    pub fn patchJumpTarget(self: *Ir, index: Index) void {
        const insn = &self.instructions.items[index];
        std.debug.assert(insn.operand.jump.target == unpatched_jump);
        insn.operand.jump.target = self.nextIndex();
    }

    pub fn lastByteRegion(self: *Ir) Region {
        const insn = self.instructions.getLast();
        return switch (insn.operand) {
            .byte_pair => |b| b.region2,
            else => insn.region,
        };
    }

    pub fn writeTo(self: *Ir, allocator: Allocator, chunk: *Chunk) !void {
        const insns = self.instructions.items;

        const offsets = try allocator.alloc(u32, insns.len + 1);
        defer allocator.free(offsets);

        var offset: u32 = 0;
        for (insns, 0..) |insn, i| {
            offsets[i] = offset;
            offset += byteLength(insn.operand);
        }
        offsets[insns.len] = offset;

        for (insns, 0..) |insn, i| {
            const region = insn.region;
            switch (insn.operand) {
                .none => |op| try chunk.writeOp(allocator, op, region),
                .byte => |b| {
                    try chunk.writeOp(allocator, b.op, region);
                    try chunk.write(allocator, b.byte, region);
                },
                .byte_pair => |b| {
                    try chunk.writeOp(allocator, b.op, region);
                    try chunk.write(allocator, b.byte1, b.region1);
                    try chunk.write(allocator, b.byte2, b.region2);
                },
                .long => |l| {
                    try chunk.writeOp(allocator, l.op, region);
                    try chunk.writeLong(allocator, l.value, region);
                },
                .get_constant => |idx| try writeIndexed(chunk, allocator, idx, .GetConstant, .GetConstant2, .GetConstant3, region),
                .get_constant_mutable => |idx| try writeIndexed(chunk, allocator, idx, .GetConstantMutable, .GetConstantMutable2, .GetConstantMutable3, region),
                .call_function_constant => |idx| try writeIndexed(chunk, allocator, idx, .CallFunctionConstant, .CallFunctionConstant2, .CallFunctionConstant3, region),
                .call_tail_function_constant => |idx| try writeIndexed(chunk, allocator, idx, .CallTailFunctionConstant, .CallTailFunctionConstant2, .CallTailFunctionConstant3, region),
                .destructure => |idx| try writeIndexed(chunk, allocator, idx, .Destructure, .Destructure2, .Destructure3, region),
                .jump => |j| {
                    std.debug.assert(j.target != unpatched_jump);
                    std.debug.assert(j.target > i);
                    const distance = offsets[j.target] - (offsets[i] + 3);
                    try self.writeJumpOperand(chunk, allocator, j.op, distance, region);
                },
                .jump_back => |j| {
                    std.debug.assert(j.target <= i);
                    const distance = (offsets[i] + 3) - offsets[j.target];
                    try self.writeJumpOperand(chunk, allocator, j.op, distance, region);
                },
            }
        }
    }

    fn writeJumpOperand(self: *Ir, chunk: *Chunk, allocator: Allocator, op: OpCode, distance: u32, region: Region) !void {
        if (distance > std.math.maxInt(u16)) {
            self.overflow_region = region;
            return ChunkError.ShortOverflow;
        }
        try chunk.writeOp(allocator, op, region);
        try chunk.writeShort(allocator, @intCast(distance), region);
    }

    fn writeIndexed(chunk: *Chunk, allocator: Allocator, idx: u24, op1: OpCode, op2: OpCode, op3: OpCode, region: Region) !void {
        if (idx <= 0xFF) {
            try chunk.writeOp(allocator, op1, region);
            try chunk.write(allocator, @intCast(idx), region);
        } else if (idx <= 0xFFFF) {
            try chunk.writeOp(allocator, op2, region);
            try chunk.writeShort(allocator, @intCast(idx), region);
        } else {
            try chunk.writeOp(allocator, op3, region);
            try chunk.writeMedium(allocator, idx, region);
        }
    }

    fn byteLength(operand: Operand) u32 {
        return switch (operand) {
            .none => 1,
            .byte => 2,
            .byte_pair => 3,
            .long => 5,
            .get_constant,
            .get_constant_mutable,
            .call_function_constant,
            .call_tail_function_constant,
            .destructure,
            => |idx| indexedByteLength(idx),
            .jump, .jump_back => 3,
        };
    }

    fn indexedByteLength(idx: u24) u32 {
        if (idx <= 0xFF) return 2;
        if (idx <= 0xFFFF) return 3;
        return 4;
    }

    pub const VerifyError = error{
        StackUnderflow,
        StackDepthMismatch,
        UnreachableInstruction,
        UnpatchedJumpTarget,
        InvalidJumpTarget,
        OperandKindMismatch,
        UnverifiableOp,
        LocalSlotOutOfRange,
        MissingEnd,
    };

    // Check that the instruction list is well formed before serializing it:
    // every instruction is reachable, jumps are patched and land in bounds,
    // no op pops more than the stack holds, stack depth agrees wherever two
    // paths join, local slot reads stay inside the frame, and no path falls
    // off the end of the function. `entry_depth` is the number of stack
    // values in the frame at entry: the function itself plus its arguments.
    // On failure `verify_failure` holds the offending instruction index.
    pub fn verify(self: *Ir, allocator: Allocator, entry_depth: u32) (Allocator.Error || VerifyError)!void {
        const insns = self.instructions.items;

        if (insns.len == 0) return self.verifyFail(0, VerifyError.MissingEnd);

        const depths = try allocator.alloc(?u32, insns.len);
        defer allocator.free(depths);
        @memset(depths, null);
        depths[0] = entry_depth;

        for (insns, 0..) |insn, i| {
            const index: Index = @intCast(i);
            const depth = depths[i] orelse return self.verifyFail(index, VerifyError.UnreachableInstruction);
            const op = operandOp(insn.operand);

            if (localSlotOperand(op, insn.operand)) |slot| {
                // The value for slot N sits N + 1 above the function elem.
                if (slot + 2 > depth) return self.verifyFail(index, VerifyError.LocalSlotOutOfRange);
            }

            switch (op.stackEffect()) {
                .fixed => |effect| {
                    switch (insn.operand) {
                        .jump, .jump_back => return self.verifyFail(index, VerifyError.OperandKindMismatch),
                        else => {},
                    }
                    const next = try self.applyEffect(index, depth, effect);
                    try self.flowTo(depths, index, i + 1, next);
                },
                .call => {
                    const arg_count: u32 = switch (insn.operand) {
                        .byte => |b| b.byte,
                        else => return self.verifyFail(index, VerifyError.OperandKindMismatch),
                    };
                    const next = try self.applyEffect(index, depth, .{ .pops = arg_count + 1, .pushes = 1 });
                    try self.flowTo(depths, index, i + 1, next);
                },
                .branch => |branch| {
                    const target: Index = switch (insn.operand) {
                        .jump => |j| target: {
                            if (j.target == unpatched_jump) return self.verifyFail(index, VerifyError.UnpatchedJumpTarget);
                            if (j.target <= index or j.target >= insns.len) return self.verifyFail(index, VerifyError.InvalidJumpTarget);
                            break :target j.target;
                        },
                        .jump_back => |j| target: {
                            if (j.target > index) return self.verifyFail(index, VerifyError.InvalidJumpTarget);
                            break :target j.target;
                        },
                        else => return self.verifyFail(index, VerifyError.OperandKindMismatch),
                    };
                    const jump_depth = try self.applyEffect(index, depth, branch.jump);
                    try self.flowTo(depths, index, target, jump_depth);
                    if (branch.fallthrough) |effect| {
                        const next = try self.applyEffect(index, depth, effect);
                        try self.flowTo(depths, index, i + 1, next);
                    }
                },
                .terminal => {
                    if (depth < 1) return self.verifyFail(index, VerifyError.StackUnderflow);
                },
                .unknown => return self.verifyFail(index, VerifyError.UnverifiableOp),
            }
        }
    }

    fn applyEffect(self: *Ir, index: Index, depth: u32, effect: OpCode.StackEffect.PopPush) VerifyError!u32 {
        if (depth < effect.pops) return self.verifyFail(index, VerifyError.StackUnderflow);
        return depth - effect.pops + effect.pushes;
    }

    fn flowTo(self: *Ir, depths: []?u32, from: Index, to: usize, depth: u32) VerifyError!void {
        if (to >= depths.len) return self.verifyFail(from, VerifyError.MissingEnd);
        if (depths[to]) |existing| {
            if (existing != depth) return self.verifyFail(from, VerifyError.StackDepthMismatch);
        } else {
            depths[to] = depth;
        }
    }

    fn verifyFail(self: *Ir, index: Index, err: VerifyError) VerifyError {
        self.verify_failure = index;
        return err;
    }

    pub fn operandOp(operand: Operand) OpCode {
        return switch (operand) {
            .none => |op| op,
            .byte => |b| b.op,
            .byte_pair => |b| b.op,
            .long => |l| l.op,
            .get_constant => .GetConstant,
            .get_constant_mutable => .GetConstantMutable,
            .call_function_constant => .CallFunctionConstant,
            .call_tail_function_constant => .CallTailFunctionConstant,
            .destructure => .Destructure,
            .jump => |j| j.op,
            .jump_back => |j| j.op,
        };
    }

    pub fn localSlotOperand(op: OpCode, operand: Operand) ?u32 {
        return switch (op) {
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .CaptureLocal,
            .GetBoundLocal,
            .GetBoundLocalMove,
            .GetLocal,
            .GetLocalMove,
            => switch (operand) {
                .byte => |b| b.byte,
                else => null,
            },
            else => null,
        };
    }
};

const testing = std.testing;

fn testRegion(n: usize) Region {
    return Region.new(n, n + 1);
}

test "simple ops and byte operands" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 7 } }, testRegion(1));
    _ = try ir.push(allocator, .{ .byte_pair = .{
        .op = .ParseCodepointRange,
        .byte1 = 'a',
        .region1 = testRegion(2),
        .byte2 = 'z',
        .region2 = testRegion(3),
    } }, testRegion(1));
    _ = try ir.push(allocator, .{ .long = .{ .op = .AssertParamTypes4, .value = 0x01020304 } }, testRegion(4));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(5));

    var chunk = Chunk{ .source_region = testRegion(0) };
    defer chunk.deinit(allocator);
    try ir.writeTo(allocator, &chunk);

    try testing.expectEqualSlices(u8, &[_]u8{
        @intFromEnum(OpCode.Merge),
        @intFromEnum(OpCode.GetLocal),
        7,
        @intFromEnum(OpCode.ParseCodepointRange),
        'a',
        'z',
        @intFromEnum(OpCode.AssertParamTypes4),
        0x01,
        0x02,
        0x03,
        0x04,
        @intFromEnum(OpCode.End),
    }, chunk.code.items);

    try testing.expectEqual(testRegion(2), chunk.regions.items[4]);
    try testing.expectEqual(testRegion(3), chunk.regions.items[5]);
}

test "indexed operands choose the shortest encoding" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .get_constant = 0x05 }, testRegion(0));
    _ = try ir.push(allocator, .{ .get_constant = 0x1234 }, testRegion(1));
    _ = try ir.push(allocator, .{ .get_constant = 0x123456 }, testRegion(2));
    _ = try ir.push(allocator, .{ .destructure = 0x1234 }, testRegion(3));
    _ = try ir.push(allocator, .{ .call_function_constant = 0x02 }, testRegion(4));
    _ = try ir.push(allocator, .{ .call_tail_function_constant = 0x123456 }, testRegion(5));

    var chunk = Chunk{ .source_region = testRegion(0) };
    defer chunk.deinit(allocator);
    try ir.writeTo(allocator, &chunk);

    try testing.expectEqualSlices(u8, &[_]u8{
        @intFromEnum(OpCode.GetConstant),
        0x05,
        @intFromEnum(OpCode.GetConstant2),
        0x12,
        0x34,
        @intFromEnum(OpCode.GetConstant3),
        0x12,
        0x34,
        0x56,
        @intFromEnum(OpCode.Destructure2),
        0x12,
        0x34,
        @intFromEnum(OpCode.CallFunctionConstant),
        0x02,
        @intFromEnum(OpCode.CallTailFunctionConstant3),
        0x12,
        0x34,
        0x56,
    }, chunk.code.items);
}

test "jump distances are resolved from instruction indices" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    // Mirror of the `or` emission pattern:
    //   SetInputMark; <left>; Or -> after; <right>; after:
    _ = try ir.push(allocator, .{ .none = .SetInputMark }, testRegion(0));
    const loop_start = ir.nextIndex();
    _ = try ir.push(allocator, .{ .get_constant = 0x1234 }, testRegion(1));
    const jump = try ir.push(allocator, .{ .jump = .{ .op = .Or, .target = Ir.unpatched_jump } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(3));
    _ = try ir.push(allocator, .{ .jump_back = .{ .op = .JumpBack, .target = loop_start } }, testRegion(4));
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(5));

    var chunk = Chunk{ .source_region = testRegion(0) };
    defer chunk.deinit(allocator);
    try ir.writeTo(allocator, &chunk);

    // Byte layout:
    //   0: SetInputMark
    //   1: GetConstant2 (3 bytes)
    //   4: Or +4 (target byte 11)
    //   7: Merge
    //   8: JumpBack -10 (target byte 1)
    //  11: End
    try testing.expectEqualSlices(u8, &[_]u8{
        @intFromEnum(OpCode.SetInputMark),
        @intFromEnum(OpCode.GetConstant2),
        0x12,
        0x34,
        @intFromEnum(OpCode.Or),
        0x00,
        0x04,
        @intFromEnum(OpCode.Merge),
        @intFromEnum(OpCode.JumpBack),
        0x00,
        0x0A,
        @intFromEnum(OpCode.End),
    }, chunk.code.items);
}

test "verify accepts a balanced function" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    // Mirror of the `or` emission pattern for a zero-arity function:
    //   SetInputMark; <left>; Or -> after; <right>; after: End
    _ = try ir.push(allocator, .{ .none = .SetInputMark }, testRegion(0));
    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(1));
    const jump = try ir.push(allocator, .{ .jump = .{ .op = .Or, .target = Ir.unpatched_jump } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .ParseCodepoint }, testRegion(3));
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(4));

    try ir.verify(allocator, 1);
}

test "verify accepts a loop with a balanced body" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    // Repeat shape: accumulator on the stack, then loop parsing and merging
    // until the parser fails, dropping the failure on the way out.
    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 0 } }, testRegion(0));
    const loop_start = ir.nextIndex();
    _ = try ir.push(allocator, .{ .none = .ParseCodepoint }, testRegion(1));
    const done = try ir.push(allocator, .{ .jump = .{ .op = .JumpIfFailure, .target = Ir.unpatched_jump } }, testRegion(2));
    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(3));
    _ = try ir.push(allocator, .{ .jump_back = .{ .op = .JumpBack, .target = loop_start } }, testRegion(4));
    ir.patchJumpTarget(done);
    _ = try ir.push(allocator, .{ .none = .Drop }, testRegion(5));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(6));

    // Entry: function + one arg holding the accumulator.
    try ir.verify(allocator, 2);
}

test "verify rejects popping past the frame" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .none = .Merge }, testRegion(0));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(1));

    try testing.expectError(Ir.VerifyError.StackUnderflow, ir.verify(allocator, 1));
    try testing.expectEqual(@as(Ir.Index, 0), ir.verify_failure.?);
}

test "verify rejects join points with mismatched depths" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    // The fallthrough path pushes one more value than the jump path.
    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(0));
    const jump = try ir.push(allocator, .{ .jump = .{ .op = .JumpIfFailure, .target = Ir.unpatched_jump } }, testRegion(1));
    _ = try ir.push(allocator, .{ .get_constant = 1 }, testRegion(2));
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(3));

    try testing.expectError(Ir.VerifyError.StackDepthMismatch, ir.verify(allocator, 1));
    try testing.expectEqual(@as(Ir.Index, 2), ir.verify_failure.?);
}

test "verify rejects a loop that grows the stack" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    const loop_start = ir.nextIndex();
    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(0));
    _ = try ir.push(allocator, .{ .jump_back = .{ .op = .JumpBack, .target = loop_start } }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(2));

    try testing.expectError(Ir.VerifyError.StackDepthMismatch, ir.verify(allocator, 1));
    try testing.expectEqual(@as(Ir.Index, 1), ir.verify_failure.?);
}

test "verify rejects an unpatched jump" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .jump = .{ .op = .Jump, .target = Ir.unpatched_jump } }, testRegion(0));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(1));

    try testing.expectError(Ir.VerifyError.UnpatchedJumpTarget, ir.verify(allocator, 1));
}

test "verify rejects unreachable instructions" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    const jump = try ir.push(allocator, .{ .jump = .{ .op = .Jump, .target = Ir.unpatched_jump } }, testRegion(0));
    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(1));
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(2));

    try testing.expectError(Ir.VerifyError.UnreachableInstruction, ir.verify(allocator, 1));
    try testing.expectEqual(@as(Ir.Index, 1), ir.verify_failure.?);
}

test "verify rejects falling off the end of the function" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(0));

    try testing.expectError(Ir.VerifyError.MissingEnd, ir.verify(allocator, 1));
}

test "verify rejects local slots outside the frame" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .GetLocal, .byte = 3 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(1));

    // Frame holds the function plus two args: slots 0 and 1 only.
    try testing.expectError(Ir.VerifyError.LocalSlotOutOfRange, ir.verify(allocator, 3));
}

test "verify rejects call args exceeding stack depth" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(0));
    _ = try ir.push(allocator, .{ .byte = .{ .op = .CallFunction, .byte = 3 } }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(2));

    try testing.expectError(Ir.VerifyError.StackUnderflow, ir.verify(allocator, 1));
    try testing.expectEqual(@as(Ir.Index, 1), ir.verify_failure.?);
}

test "verify rejects ops whose effect can't be modeled" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .byte = .{ .op = .NativeCode, .byte = 0 } }, testRegion(0));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(1));

    try testing.expectError(Ir.VerifyError.UnverifiableOp, ir.verify(allocator, 1));
}

test "verify rejects a branch op emitted without a jump operand" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    _ = try ir.push(allocator, .{ .get_constant = 0 }, testRegion(0));
    _ = try ir.push(allocator, .{ .none = .Or }, testRegion(1));
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(2));

    try testing.expectError(Ir.VerifyError.OperandKindMismatch, ir.verify(allocator, 1));
}

test "oversized jump reports overflow with the jump region" {
    const allocator = testing.allocator;
    var ir = Ir{};
    defer ir.deinit(allocator);

    const jump = try ir.push(allocator, .{ .jump = .{ .op = .Jump, .target = Ir.unpatched_jump } }, testRegion(9));
    var i: usize = 0;
    while (i < 22000) : (i += 1) {
        _ = try ir.push(allocator, .{ .byte_pair = .{
            .op = .ParseCodepointRange,
            .byte1 = 'a',
            .region1 = testRegion(0),
            .byte2 = 'z',
            .region2 = testRegion(0),
        } }, testRegion(0));
    }
    ir.patchJumpTarget(jump);
    _ = try ir.push(allocator, .{ .none = .End }, testRegion(0));

    var chunk = Chunk{ .source_region = testRegion(0) };
    defer chunk.deinit(allocator);
    try testing.expectError(ChunkError.ShortOverflow, ir.writeTo(allocator, &chunk));
    try testing.expectEqual(testRegion(9), ir.overflow_region.?);
}

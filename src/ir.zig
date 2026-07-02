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

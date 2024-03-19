const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const StringTable = @import("string_table.zig").StringTable;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Backtrack,
    CallParser,
    CallTailParser,
    CaptureLocal,
    ConditionalElse,
    ConditionalThen,
    Destructure,
    End,
    Fail,
    False,
    GetBoundLocal,
    GetConstant,
    GetLocal,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    Merge,
    Null,
    NumberOf,
    Or,
    ResolveUnboundVars,
    SetClosureCaptures,
    SetInputMark,
    Succeed,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize) usize {
        return switch (self) {
            .Destructure,
            .End,
            .Fail,
            .False,
            .Merge,
            .Null,
            .NumberOf,
            .ResolveUnboundVars,
            .SetClosureCaptures,
            .SetInputMark,
            .Succeed,
            .TakeLeft,
            .True,
            => self.simpleInstruction(offset),
            .GetConstant => self.constantInstruction(chunk, offset, strings),
            .CallParser,
            .CallTailParser,
            .GetLocal,
            .GetBoundLocal,
            => self.byteInstruciton(chunk, offset),
            .CaptureLocal => self.twoBytesInstruciton(chunk, offset),
            .Backtrack,
            .ConditionalElse,
            .ConditionalThen,
            .Jump,
            .JumpIfFailure,
            .JumpIfSuccess,
            .Or,
            .TakeRight,
            => self.jumpInstruction(chunk, offset),
        };
    }

    fn simpleInstruction(self: OpCode, offset: usize) usize {
        logger.debug("{s}\n", .{@tagName(self)});
        return offset + 1;
    }

    fn constantInstruction(self: OpCode, chunk: *Chunk, offset: usize, strings: StringTable) usize {
        var constantIdx = chunk.read(offset + 1);
        var constantElem = chunk.getConstant(constantIdx);
        logger.debug("{s} {}: ", .{ @tagName(self), constantIdx });
        constantElem.print(logger.debug, strings);
        logger.debug("\n", .{});
        return offset + 2;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, offset: usize) usize {
        const byte = chunk.read(offset + 1);
        logger.debug("{s} {d}\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn twoBytesInstruciton(self: OpCode, chunk: *Chunk, offset: usize) usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        logger.debug("{s} {d} {d}\n", .{ @tagName(self), byte1, byte2 });
        return offset + 3;
    }

    fn jumpInstruction(self: OpCode, chunk: *Chunk, offset: usize) usize {
        var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
        jump |= chunk.read(offset + 2);
        const target = @as(isize, @intCast(offset)) + 3 + jump;
        std.debug.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
        return offset + 3;
    }
};

const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const StringTable = @import("string_table.zig").StringTable;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Backtrack,
    CallParser,
    GetConstant,
    Destructure,
    End,
    False,
    GetGlobal,
    GetLocal,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    MergeElems,
    MergeParsed,
    Null,
    Or,
    Return,
    RunParser,
    SetGlobal,
    SubstituteValue,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize) usize {
        return switch (self) {
            .Backtrack,
            .Destructure,
            .End,
            .False,
            .MergeElems,
            .MergeParsed,
            .Null,
            .Or,
            .Return,
            .RunParser,
            .SubstituteValue,
            .TakeLeft,
            .TakeRight,
            .True,
            => self.simpleInstruction(offset),
            .GetConstant,
            .GetGlobal,
            .SetGlobal,
            => self.constantInstruction(chunk, offset, strings),
            .CallParser,
            .GetLocal,
            => self.byteInstruciton(chunk, offset),
            .Jump,
            .JumpIfFailure,
            .JumpIfSuccess,
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

    fn jumpInstruction(self: OpCode, chunk: *Chunk, offset: usize) usize {
        var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
        jump |= chunk.read(offset + 2);
        const target = @as(isize, @intCast(offset)) + 3 + jump;
        std.debug.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
        return offset + 3;
    }
};

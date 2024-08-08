const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const StringTable = @import("string_table.zig").StringTable;
const VMWriter = @import("writer.zig").VMWriter;

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunction,
    CallTailFunction,
    CaptureLocal,
    ConditionalElse,
    ConditionalThen,
    Destructure,
    End,
    Fail,
    False,
    GetAtIndex,
    GetAtKey,
    GetBoundLocal,
    GetConstant,
    GetLocal,
    InsertAtIndex,
    InsertAtKey,
    InsertKeyVal,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    Merge,
    MergeAsString,
    NegateNumber,
    Null,
    NumberOf,
    Or,
    ParseCharacter,
    ParseCharacterRange,
    ParseIntegerRange,
    Pop,
    PrepareMergePattern,
    SetClosureCaptures,
    SetInputMark,
    Swap,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize, writer: VMWriter) !usize {
        return switch (self) {
            .Destructure,
            .End,
            .Fail,
            .False,
            .InsertKeyVal,
            .Merge,
            .MergeAsString,
            .NegateNumber,
            .Null,
            .NumberOf,
            .ParseCharacter,
            .Pop,
            .SetClosureCaptures,
            .SetInputMark,
            .Swap,
            .TakeLeft,
            .True,
            => self.simpleInstruction(offset, writer),
            .GetAtKey,
            .GetConstant,
            .InsertAtKey,
            => self.constantInstruction(chunk, offset, strings, writer),
            .ParseCharacterRange,
            .ParseIntegerRange,
            => self.twoConstantsInstruction(chunk, offset, strings, writer),
            .CallFunction,
            .CallTailFunction,
            .GetAtIndex,
            .GetBoundLocal,
            .GetLocal,
            .InsertAtIndex,
            .PrepareMergePattern,
            => self.byteInstruciton(chunk, offset, writer),
            .CaptureLocal,
            => self.twoBytesInstruciton(chunk, offset, writer),
            .Backtrack,
            .ConditionalElse,
            .ConditionalThen,
            .Jump,
            .JumpIfFailure,
            .JumpIfSuccess,
            .Or,
            .TakeRight,
            => self.jumpInstruction(chunk, offset, writer),
        };
    }

    fn simpleInstruction(self: OpCode, offset: usize, writer: VMWriter) !usize {
        try writer.print("{s}\n", .{@tagName(self)});
        return offset + 1;
    }

    fn constantInstruction(self: OpCode, chunk: *Chunk, offset: usize, strings: StringTable, writer: VMWriter) !usize {
        const constantIdx = chunk.read(offset + 1);
        var constantElem = chunk.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(writer, strings);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn twoConstantsInstruction(self: OpCode, chunk: *Chunk, offset: usize, strings: StringTable, writer: VMWriter) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        var constant1 = chunk.getConstant(byte1);
        var constant2 = chunk.getConstant(byte2);
        try writer.print("{s} {} {}: ", .{ @tagName(self), byte1, byte2 });
        try constant1.print(writer, strings);
        try writer.print(" ", .{});
        try constant2.print(writer, strings);
        try writer.print("\n", .{});
        return offset + 3;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, offset: usize, writer: VMWriter) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn twoBytesInstruciton(self: OpCode, chunk: *Chunk, offset: usize, writer: VMWriter) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        try writer.print("{s} {d} {d}\n", .{ @tagName(self), byte1, byte2 });
        return offset + 3;
    }

    fn jumpInstruction(self: OpCode, chunk: *Chunk, offset: usize, writer: VMWriter) !usize {
        var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
        jump |= chunk.read(offset + 2);
        const target = @as(isize, @intCast(offset)) + 3 + jump;
        try writer.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
        return offset + 3;
    }
};

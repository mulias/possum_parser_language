const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const StringTable = @import("string_table.zig").StringTable;
const VMWriter = @import("./writer.zig").VMWriter;

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
    GetBoundLocal,
    GetConstant,
    GetLocal,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    Merge,
    Null,
    NumberOf,
    NumberSubtract,
    Or,
    ResolveUnboundVars,
    SetClosureCaptures,
    SetInputMark,
    Succeed,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize, writer: VMWriter) !usize {
        return switch (self) {
            .Destructure,
            .End,
            .Fail,
            .False,
            .Merge,
            .Null,
            .NumberOf,
            .NumberSubtract,
            .ResolveUnboundVars,
            .SetClosureCaptures,
            .SetInputMark,
            .Succeed,
            .TakeLeft,
            .True,
            => self.simpleInstruction(offset, writer),
            .GetConstant => self.constantInstruction(chunk, offset, strings, writer),
            .CallFunction,
            .CallTailFunction,
            .GetBoundLocal,
            .GetLocal,
            => self.byteInstruciton(chunk, offset, writer),
            .CaptureLocal => self.twoBytesInstruciton(chunk, offset, writer),
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
        var constantIdx = chunk.read(offset + 1);
        var constantElem = chunk.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(writer, strings);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, offset: usize, writer: VMWriter) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {d}\n", .{ @tagName(self), byte });
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

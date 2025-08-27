const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunction,
    CallTailFunction,
    CaptureLocal,
    ConditionalThen,
    Crash,
    Decrement,
    Destructure,
    Drop,
    End,
    Fail,
    False,
    GetAtIndex,
    GetBoundLocal,
    GetConstant,
    GetLocal,
    Increment,
    InsertAtIndex,
    InsertAtKey,
    InsertKeyVal,
    Jump,
    JumpBack,
    JumpIfFailure,
    JumpIfZero,
    JumpIfBound,
    Merge,
    MergeAsString,
    NativeCode,
    NegateNumber,
    Null,
    Or,
    ParseCharacter,
    ParseLowerBoundedRange,
    ParseFixedRange,
    ParseUpperBoundedRange,
    PopInputMark,
    RepeatValue,
    ResetInput,
    SetClosureCaptures,
    SetInputMark,
    Swap,
    ValidateRepeatPattern,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize) !usize {
        return switch (self) {
            .Crash,
            .Decrement,
            .Drop,
            .End,
            .Fail,
            .False,
            .Increment,
            .Merge,
            .MergeAsString,
            .NegateNumber,
            .Null,
            .ParseCharacter,
            .ParseLowerBoundedRange,
            .ParseUpperBoundedRange,
            .PopInputMark,
            .RepeatValue,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            .Swap,
            .ValidateRepeatPattern,
            .TakeLeft,
            .True,
            => self.simpleInstruction(writer, offset),
            .GetConstant,
            .InsertAtKey,
            .NativeCode,
            => self.constantInstruction(chunk, vm, writer, offset),
            .Destructure,
            => self.patternInstruction(chunk, vm, writer, offset),
            .ParseFixedRange,
            => self.twoConstantsInstruction(chunk, vm, writer, offset),
            .CallFunction,
            .CallTailFunction,
            .GetAtIndex,
            .GetBoundLocal,
            .GetLocal,
            .InsertAtIndex,
            .InsertKeyVal,
            => self.byteInstruciton(chunk, writer, offset),
            .CaptureLocal,
            => self.twoBytesInstruciton(chunk, writer, offset),
            .Backtrack,
            .ConditionalThen,
            .Jump,
            .JumpIfFailure,
            .JumpIfZero,
            .JumpIfBound,
            .Or,
            .TakeRight,
            => self.jumpInstruction(chunk, writer, offset),
            .JumpBack,
            => self.jumpBackInstruction(chunk, writer, offset),
        };
    }

    fn simpleInstruction(self: OpCode, writer: *Writer, offset: usize) !usize {
        try writer.print("{s}\n", .{@tagName(self)});
        return offset + 1;
    }

    fn constantInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize) !usize {
        const constantIdx = chunk.read(offset + 1);
        var constantElem = chunk.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn patternInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize) !usize {
        const patternIdx = chunk.read(offset + 1);
        var pattern = chunk.getPattern(patternIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), patternIdx });
        try pattern.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn twoConstantsInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        var constant1 = chunk.getConstant(byte1);
        var constant2 = chunk.getConstant(byte2);
        try writer.print("{s} {} {}: ", .{ @tagName(self), byte1, byte2 });
        try constant1.print(vm, writer);
        try writer.print(" ", .{});
        try constant2.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 3;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn twoBytesInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        try writer.print("{s} {d} {d}\n", .{ @tagName(self), byte1, byte2 });
        return offset + 3;
    }

    fn jumpInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
        jump |= chunk.read(offset + 2);
        const target = @as(isize, @intCast(offset)) + 3 + jump;
        try writer.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
        return offset + 3;
    }

    fn jumpBackInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
        jump |= chunk.read(offset + 2);
        const target = @as(isize, @intCast(offset)) + 3 - jump;
        try writer.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
        return offset + 3;
    }
};

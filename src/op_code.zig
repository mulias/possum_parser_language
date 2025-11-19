const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunction,
    CallTailFunction,
    CaptureLocal,
    ConditionalThen,
    CreateClosure,
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
    GetConstant2,
    GetConstant3,
    GetLocal,
    Increment,
    InsertAtIndex,
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
    NegateParser,
    Null,
    Or,
    ParseCodepoint,
    ParseCodepointRange,
    ParseIntegerRange,
    ParseLowerBoundedRange,
    ParseRange,
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

    pub fn disassemble(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
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
            .NegateParser,
            .Null,
            .ParseCodepoint,
            .ParseLowerBoundedRange,
            .ParseRange,
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
            .NativeCode,
            => self.constantInstruction(chunk, vm, module, writer, offset),
            .GetConstant2,
            => self.constant2Instruction(chunk, vm, module, writer, offset),
            .GetConstant3,
            => self.constant3Instruction(chunk, vm, module, writer, offset),
            .Destructure,
            => self.patternInstruction(chunk, vm, writer, offset),
            .CallFunction,
            .CallTailFunction,
            .CaptureLocal,
            .CreateClosure,
            .GetAtIndex,
            .GetBoundLocal,
            .GetLocal,
            .InsertAtIndex,
            .InsertKeyVal,
            => self.byteInstruciton(chunk, writer, offset),
            .ParseCodepointRange,
            => self.codepointRangeInstruction(chunk, writer, offset),
            .ParseIntegerRange,
            => self.integerRangeInstruction(chunk, writer, offset),
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

    fn constantInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const constantIdx = chunk.read(offset + 1);
        var constantElem = module.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn constant2Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var constantIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 8;
        constantIdx |= chunk.read(offset + 2);
        var constantElem = module.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 3;
    }

    fn constant3Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var constantIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 16;
        constantIdx |= @as(usize, @intCast(chunk.read(offset + 2))) << 8;
        constantIdx |= chunk.read(offset + 3);
        var constantElem = module.getConstant(constantIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), constantIdx });
        try constantElem.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 4;
    }

    fn patternInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize) !usize {
        const patternIdx = chunk.read(offset + 1);
        var pattern = chunk.getPattern(patternIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), patternIdx });
        try pattern.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn codepointRangeInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        try writer.print("{s} '{c}'..'{c}'\n", .{ @tagName(self), byte1, byte2 });
        return offset + 3;
    }

    fn integerRangeInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte1 = chunk.read(offset + 1);
        const byte2 = chunk.read(offset + 2);
        try writer.print("{s} {d}..{d}\n", .{ @tagName(self), byte1, byte2 });
        return offset + 3;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), byte });
        return offset + 2;
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

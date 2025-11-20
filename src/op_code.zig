const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunction,
    CallFunctionConstant,
    CallFunctionConstant2,
    CallFunctionConstant3,
    CallFunctionLocal,
    CallTailFunction,
    CallTailFunctionConstant,
    CallTailFunctionConstant2,
    CallTailFunctionConstant3,
    CallTailFunctionLocal,
    CaptureLocal,
    ConditionalThen,
    Crash,
    CreateClosure,
    Decrement,
    Destructure,
    Destructure2,
    Destructure3,
    Drop,
    End,
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
    JumpIfBound,
    JumpIfFailure,
    JumpIfZero,
    Merge,
    MergeAsString,
    NativeCode,
    NegateNumber,
    NegateParser,
    Or,
    ParseChar,
    ParseCodepoint,
    ParseCodepointRange,
    ParseIntegerRange,
    ParseLowerBoundedRange,
    ParseNegOne,
    ParseNumberStringChar,
    ParseOne,
    ParseRange,
    ParseThree,
    ParseTwo,
    ParseUpperBoundedRange,
    ParseZero,
    PopInputMark,
    PushChar,
    PushCharVar,
    PushEmptyArray,
    PushEmptyObject,
    PushEmptyString,
    PushFail,
    PushFalse,
    PushNegNumber,
    PushNull,
    PushNumber,
    PushNumberStringChar,
    PushNumberNegOne,
    PushNumberOne,
    PushNumberStringNegOne,
    PushNumberStringOne,
    PushNumberStringThree,
    PushNumberStringTwo,
    PushNumberStringZero,
    PushNumberThree,
    PushNumberTwo,
    PushNumberZero,
    PushUnderscoreVar,
    RepeatValue,
    ResetInput,
    SetClosureCaptures,
    SetInputMark,
    Swap,
    TakeLeft,
    TakeRight,
    PushTrue,
    ValidateRepeatPattern,

    pub fn disassemble(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        return switch (self) {
            .Crash,
            .Decrement,
            .Drop,
            .End,
            .Increment,
            .Merge,
            .MergeAsString,
            .NegateNumber,
            .NegateParser,
            .ParseCodepoint,
            .ParseLowerBoundedRange,
            .ParseRange,
            .ParseUpperBoundedRange,
            .PopInputMark,
            .PushEmptyArray,
            .PushEmptyObject,
            .PushEmptyString,
            .PushFail,
            .PushFalse,
            .PushNull,
            .PushNumberNegOne,
            .PushNumberOne,
            .PushNumberStringNegOne,
            .PushNumberStringOne,
            .PushNumberStringThree,
            .PushNumberStringTwo,
            .PushNumberStringZero,
            .PushNumberThree,
            .PushNumberTwo,
            .PushNumberZero,
            .PushTrue,
            .PushUnderscoreVar,
            .RepeatValue,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            .Swap,
            .TakeLeft,
            .ValidateRepeatPattern,
            .ParseNegOne,
            .ParseZero,
            .ParseOne,
            .ParseTwo,
            .ParseThree,
            => self.simpleInstruction(writer, offset),
            .CallFunctionConstant,
            .CallTailFunctionConstant,
            .GetConstant,
            .NativeCode,
            => self.constantInstruction(chunk, vm, module, writer, offset),
            .CallFunctionConstant2,
            .CallTailFunctionConstant2,
            .GetConstant2,
            => self.constant2Instruction(chunk, vm, module, writer, offset),
            .CallFunctionConstant3,
            .CallTailFunctionConstant3,
            .GetConstant3,
            => self.constant3Instruction(chunk, vm, module, writer, offset),
            .Destructure,
            => self.patternInstruction(chunk, vm, module, writer, offset),
            .Destructure2,
            => self.pattern2Instruction(chunk, vm, module, writer, offset),
            .Destructure3,
            => self.pattern3Instruction(chunk, vm, module, writer, offset),
            .CallFunction,
            .CallTailFunction,
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .CaptureLocal,
            .CreateClosure,
            .GetAtIndex,
            .GetBoundLocal,
            .GetLocal,
            .InsertAtIndex,
            .InsertKeyVal,
            => self.byteInstruciton(chunk, writer, offset),
            .ParseChar,
            .PushChar,
            => self.charInstruction(chunk, writer, offset),
            .PushNumber,
            => self.pushNumberInstruciton(chunk, writer, offset),
            .PushCharVar,
            => self.pushCharVarInstruciton(chunk, writer, offset),
            .PushNegNumber,
            => self.pushNegNumberInstruction(chunk, writer, offset),
            .PushNumberStringChar,
            .ParseNumberStringChar,
            => self.numberStringInstruction(chunk, writer, offset),
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

    fn patternInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const patternIdx = chunk.read(offset + 1);
        var pattern = module.getPattern(patternIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), patternIdx });
        try pattern.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn pattern2Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var patternIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 8;
        patternIdx |= chunk.read(offset + 2);
        var pattern = module.getPattern(patternIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), patternIdx });
        try pattern.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 3;
    }

    fn pattern3Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var patternIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 16;
        patternIdx |= @as(usize, @intCast(chunk.read(offset + 2))) << 8;
        patternIdx |= chunk.read(offset + 3);
        var pattern = module.getPattern(patternIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), patternIdx });
        try pattern.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 4;
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

    fn charInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} '{c}'\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn pushNumberInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), @as(f64, @floatFromInt(byte)) });
        return offset + 2;
    }

    fn pushCharVarInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {c}\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn pushNegNumberInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), -@as(f64, @floatFromInt(byte)) });
        return offset + 2;
    }

    fn numberStringInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {c}\n", .{ @tagName(self), byte });
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

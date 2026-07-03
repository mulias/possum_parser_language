const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;

pub const OpCode = enum(u8) {
    AssertFunctionArity,
    AssertParamTypes,
    AssertParamTypes4,
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

    // How executing an op changes the VM value stack. `pops` counts the
    // values an op requires on the stack, `pushes` the values it leaves;
    // ops that only inspect the stack count the inspected values in both.
    pub const StackEffect = union(enum) {
        // Same effect on every path.
        fixed: PopPush,
        // Pops the callee plus its byte-operand argument count, pushes the
        // call result. Tail calls included: when the callee is a builtin or
        // a string parser the call returns and execution falls through.
        call,
        // Ops with a jump operand. `fallthrough` is null when the jump is
        // unconditional.
        branch: struct { fallthrough: ?PopPush, jump: PopPush },
        // Ends the frame (End) or aborts with a runtime error (Crash).
        // Requires one value on the stack; nothing after it on this path
        // runs.
        terminal,
        // Effect depends on an opaque handler (NativeCode), which is
        // hand-written into builtin chunks and must never be emitted
        // through the IR.
        unknown,

        pub const PopPush = struct { pops: u32, pushes: u32 };
    };

    pub fn stackEffect(self: OpCode) StackEffect {
        return switch (self) {
            .Backtrack,
            .PopInputMark,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            => .{ .fixed = .{ .pops = 0, .pushes = 0 } },

            .CallFunctionConstant,
            .CallFunctionConstant2,
            .CallFunctionConstant3,
            .CallFunctionLocal,
            .CallTailFunctionConstant,
            .CallTailFunctionConstant2,
            .CallTailFunctionConstant3,
            .CallTailFunctionLocal,
            .GetBoundLocal,
            .GetConstant,
            .GetConstant2,
            .GetConstant3,
            .GetLocal,
            .ParseChar,
            .ParseCodepoint,
            .ParseCodepointRange,
            .ParseIntegerRange,
            .ParseNegOne,
            .ParseNumberStringChar,
            .ParseOne,
            .ParseThree,
            .ParseTwo,
            .ParseZero,
            .PushChar,
            .PushCharVar,
            .PushEmptyArray,
            .PushEmptyObject,
            .PushEmptyString,
            .PushFail,
            .PushFalse,
            .PushNegNumber,
            .PushNull,
            .PushNumber,
            .PushNumberNegOne,
            .PushNumberOne,
            .PushNumberStringChar,
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
            => .{ .fixed = .{ .pops = 0, .pushes = 1 } },

            .AssertFunctionArity,
            .AssertParamTypes,
            .AssertParamTypes4,
            .CaptureLocal,
            .CreateClosure,
            .Decrement,
            .Destructure,
            .Destructure2,
            .Destructure3,
            .Increment,
            .NegateNumber,
            .NegateParser,
            .ParseLowerBoundedRange,
            .ParseUpperBoundedRange,
            .ValidateRepeatPattern,
            => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            .Drop => .{ .fixed = .{ .pops = 1, .pushes = 0 } },

            .InsertAtIndex,
            .Merge,
            .MergeAsString,
            .ParseRange,
            .RepeatValue,
            .TakeLeft,
            => .{ .fixed = .{ .pops = 2, .pushes = 1 } },

            .InsertKeyVal => .{ .fixed = .{ .pops = 3, .pushes = 1 } },

            .Swap => .{ .fixed = .{ .pops = 2, .pushes = 2 } },

            .CallFunction,
            .CallTailFunction,
            => .call,

            .Jump,
            .JumpBack,
            => .{ .branch = .{
                .fallthrough = null,
                .jump = .{ .pops = 0, .pushes = 0 },
            } },

            .JumpIfBound,
            .JumpIfFailure,
            .JumpIfZero,
            => .{ .branch = .{
                .fallthrough = .{ .pops = 1, .pushes = 1 },
                .jump = .{ .pops = 1, .pushes = 1 },
            } },

            // Keeps the successful lhs and jumps, or drops the failure and
            // falls through into the rhs.
            .Or => .{ .branch = .{
                .fallthrough = .{ .pops = 1, .pushes = 0 },
                .jump = .{ .pops = 1, .pushes = 1 },
            } },

            // Drops the condition on both paths.
            .ConditionalThen => .{ .branch = .{
                .fallthrough = .{ .pops = 1, .pushes = 0 },
                .jump = .{ .pops = 1, .pushes = 0 },
            } },

            // Drops the successful lhs and falls through into the rhs, or
            // keeps the failure and jumps.
            .TakeRight => .{ .branch = .{
                .fallthrough = .{ .pops = 1, .pushes = 0 },
                .jump = .{ .pops = 1, .pushes = 1 },
            } },

            .Crash,
            .End,
            => .terminal,

            .NativeCode => .unknown,
        };
    }

    pub fn disassemble(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        return switch (self) {
            .Backtrack,
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
            .AssertFunctionArity,
            .CallFunction,
            .CallTailFunction,
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .CaptureLocal,
            .CreateClosure,
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
            .AssertParamTypes,
            => self.paramTypesInstruction(chunk, writer, offset),
            .AssertParamTypes4,
            => self.paramTypes4Instruction(chunk, writer, offset),
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

    fn paramTypesInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const param_types = chunk.read(offset + 1);
        try writer.print("{s} {b:0>8}\n", .{ @tagName(self), param_types });
        return offset + 2;
    }

    fn paramTypes4Instruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const param_types = (@as(u32, @intCast(chunk.read(offset + 1))) << 24) |
            (@as(u32, @intCast(chunk.read(offset + 2))) << 16) |
            (@as(u32, @intCast(chunk.read(offset + 3))) << 8) |
            chunk.read(offset + 4);
        try writer.print("{s} {b:0>32}\n", .{ @tagName(self), param_types });
        return offset + 5;
    }
};

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
    GetBoundLocalMove,
    GetConstant,
    GetConstant2,
    GetConstant3,
    GetConstantMutable,
    GetConstantMutable2,
    GetConstantMutable3,
    GetLocal,
    GetLocalMove,
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
    PushString,
    PushString2,
    PushString3,
    PushString4,
    PushVar,
    PushVar2,
    PushVar3,
    PushVar4,
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
            .GetBoundLocalMove,
            .GetConstant,
            .GetConstant2,
            .GetConstant3,
            .GetConstantMutable,
            .GetConstantMutable2,
            .GetConstantMutable3,
            .GetLocal,
            .GetLocalMove,
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
            .PushString,
            .PushString2,
            .PushString3,
            .PushString4,
            .PushVar,
            .PushVar2,
            .PushVar3,
            .PushVar4,
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

    // How executing an op changes reference counts, refining StackEffect's
    // pop/push counts. `operands` covers the values StackEffect counts as
    // popped; `result` covers the pushed value. Ops that also duplicate
    // handles outside the operand stack (into frame slots, closure captures,
    // or container children) note it in the dispatch: SetClosureCaptures,
    // CaptureLocal, Destructure bindings, and container construction inside
    // Merge/Insert/Repeat handlers.
    pub const RcEffect = struct {
        operands: Operands,
        result: Result,

        pub const Operands = enum {
            // Nothing popped, or popped values never carry a Dyn handle.
            none,
            // Popped handles leave the stack for good: moved into the
            // result, moved into the frame, or destroyed. Decrement
            // candidates, except when re-pushed as a `transferred` result.
            consumed,
            // Values are only inspected: they stay on the stack (peeks) or
            // are re-pushed unchanged (Swap). No handle count change.
            borrowed,
            // Branch ops that pop only when falling through (Or drops the
            // lhs failure, TakeRight drops the successful lhs) and leave
            // the value in place when the jump is taken.
            consumed_on_fallthrough,
            // Destructure: the matched value stays on the stack on
            // success, and is released and replaced by the failure const
            // when the match fails.
            consumed_on_failure,

            pub fn canConsume(self: Operands) bool {
                return switch (self) {
                    .consumed, .consumed_on_fallthrough, .consumed_on_failure => true,
                    .none, .borrowed => false,
                };
            }
        };

        pub const Result = enum {
            // No push, or the pushed value is never a Dyn handle.
            none,
            // Pushes a newly allocated value; the pushed handle is the
            // value's first reference. Born at ref_count 1.
            fresh,
            // Pushes an additional handle to a value that keeps its
            // existing handles (locals, constants, singletons). The push
            // increments.
            derived,
            // Re-pushes a handle the op consumed (TakeLeft's kept lhs,
            // End's function result). No count change.
            transferred,
            // The in-place fast paths re-push a consumed operand handle
            // (transferred); the copy paths push a new allocation
            // (fresh). Which one is decided at runtime, detected by
            // pointer equality in releaseConsumed.
            fresh_or_transferred,
        };
    };

    // Returns null for NativeCode, whose effect is opaque to the tables.
    pub fn rcEffect(self: OpCode) ?RcEffect {
        return switch (self) {
            // No stack traffic. SetClosureCaptures copies captures into
            // frame slots: +1 per capture in the dispatch.
            .Backtrack,
            .PopInputMark,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            => .{ .operands = .none, .result = .none },

            // Push a second handle to a local slot's value.
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .GetBoundLocal,
            .GetLocal,
            => .{ .operands = .none, .result = .derived },

            // Push a local slot's value at its last read: the slot's
            // handle transfers to the stack (no increment) and the slot
            // is nulled so End's frame release can't count it again.
            .GetBoundLocalMove,
            .GetLocalMove,
            => .{ .operands = .none, .result = .transferred },

            // Push a handle to a module constant (immortal) or a shared
            // singleton container (immortal).
            .CallFunctionConstant,
            .CallFunctionConstant2,
            .CallFunctionConstant3,
            .CallTailFunctionConstant,
            .CallTailFunctionConstant2,
            .CallTailFunctionConstant3,
            .GetConstant,
            .GetConstant2,
            .GetConstant3,
            .PushEmptyArray,
            .PushEmptyObject,
            => .{ .operands = .none, .result = .derived },

            // Push a mutable copy of a container constant: a second
            // handle to the reused cache entry, or a fresh copy whose
            // extra cache-slot handle is added in the dispatch. With
            // fast paths off, behaves exactly like GetConstant.
            .GetConstantMutable,
            .GetConstantMutable2,
            .GetConstantMutable3,
            => .{ .operands = .none, .result = .derived },

            // Parse results and pushed literals: value types or new Dyns
            // whose pushed handle is their first reference.
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
            .PushString,
            .PushString2,
            .PushString3,
            .PushString4,
            .PushVar,
            .PushVar2,
            .PushVar3,
            .PushVar4,
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
            => .{ .operands = .none, .result = .fresh },

            // Peeks: inspect and leave in place. CaptureLocal copies a
            // local into a closure: +1 in the dispatch.
            .AssertFunctionArity,
            .AssertParamTypes,
            .AssertParamTypes4,
            .CaptureLocal,
            .JumpIfBound,
            .JumpIfFailure,
            .JumpIfZero,
            .ValidateRepeatPattern,
            => .{ .operands = .borrowed, .result = .none },

            // The matched value stays on the stack on success (pattern
            // vars bound into frame slots add +1 per binding in the
            // pattern solver), or is released and replaced by the failure
            // const on failure.
            .Destructure,
            .Destructure2,
            .Destructure3,
            => .{ .operands = .consumed_on_failure, .result = .none },

            // Pure reorder of two handles already on the stack.
            .Swap => .{ .operands = .borrowed, .result = .none },

            // Args stay on the stack and become callee frame locals; the
            // call result is pushed later by the callee's End.
            .CallFunction,
            .CallTailFunction,
            => .{ .operands = .borrowed, .result = .none },

            // Number ops: operands and results are never Dyn handles.
            .Decrement,
            .Increment,
            .NegateNumber,
            .NegateParser,
            .ParseLowerBoundedRange,
            .ParseRange,
            .ParseUpperBoundedRange,
            => .{ .operands = .consumed, .result = .fresh },

            // Pops the function elem, pushes a closure holding it: a
            // second handle to the reused cache entry, or a fresh closure
            // whose extra cache-slot handle is added in the dispatch. With
            // fast paths off, always a fresh closure.
            .CreateClosure => .{ .operands = .consumed, .result = .derived },

            // The dropped handle dies.
            .Drop => .{ .operands = .consumed, .result = .none },

            // Operand handles move into the result (or die when the copy
            // path duplicates children instead).
            .InsertAtIndex,
            .InsertKeyVal,
            .Merge,
            .MergeAsString,
            .RepeatValue,
            => .{ .operands = .consumed, .result = .fresh_or_transferred },

            // Keeps lhs (re-pushed), drops rhs; or drops both on failure.
            .TakeLeft => .{ .operands = .consumed, .result = .transferred },

            // Unconditional jumps: no stack traffic.
            .Jump,
            .JumpBack,
            => .{ .operands = .none, .result = .none },

            // Or drops the lhs failure (never a Dyn) on fallthrough and
            // keeps the successful lhs when jumping; TakeRight drops the
            // successful lhs on fallthrough and keeps the failure when
            // jumping.
            .Or,
            .TakeRight,
            => .{ .operands = .consumed_on_fallthrough, .result = .none },

            // Drops the condition on both paths.
            .ConditionalThen => .{ .operands = .consumed, .result = .none },

            .Crash => .{ .operands = .consumed, .result = .none },

            // Pops the whole frame: the result handle transfers to the
            // caller's stack, every other truncated handle dies.
            .End => .{ .operands = .consumed, .result = .transferred },

            .NativeCode => null,
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
            .GetConstantMutable,
            .NativeCode,
            => self.constantInstruction(chunk, vm, module, writer, offset),
            .CallFunctionConstant2,
            .CallTailFunctionConstant2,
            .GetConstant2,
            .GetConstantMutable2,
            => self.constant2Instruction(chunk, vm, module, writer, offset),
            .CallFunctionConstant3,
            .CallTailFunctionConstant3,
            .GetConstant3,
            .GetConstantMutable3,
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
            .GetBoundLocalMove,
            .GetLocal,
            .GetLocalMove,
            .InsertAtIndex,
            .InsertKeyVal,
            => self.byteInstruciton(chunk, writer, offset),
            .ParseChar,
            => self.charInstruction(chunk, writer, offset),
            .PushString,
            => self.stringInstruction(chunk, vm, writer, offset, 1),
            .PushVar,
            => self.varInstruction(chunk, vm, writer, offset, 1),
            .PushString2,
            => self.stringInstruction(chunk, vm, writer, offset, 2),
            .PushVar2,
            => self.varInstruction(chunk, vm, writer, offset, 2),
            .PushString3,
            => self.stringInstruction(chunk, vm, writer, offset, 3),
            .PushVar3,
            => self.varInstruction(chunk, vm, writer, offset, 3),
            .PushString4,
            => self.stringInstruction(chunk, vm, writer, offset, 4),
            .PushVar4,
            => self.varInstruction(chunk, vm, writer, offset, 4),
            .PushNumber,
            => self.pushNumberInstruciton(chunk, writer, offset),
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

    fn stringInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize, width: usize) !usize {
        var sid: u32 = 0;
        for (1..width + 1) |i| {
            sid = (sid << 8) | chunk.read(offset + i);
        }
        const str = vm.strings.get(sid);
        try writer.print("{s} \"{s}\"\n", .{ @tagName(self), str });
        return offset + 1 + width;
    }

    fn varInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize, width: usize) !usize {
        var sid: u32 = 0;
        for (1..width + 1) |i| {
            sid = (sid << 8) | chunk.read(offset + i);
        }
        const str = vm.strings.get(sid);
        try writer.print("{s} {s}\n", .{ @tagName(self), str });
        return offset + 1 + width;
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

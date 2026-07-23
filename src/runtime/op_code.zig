const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;

// How each end of a MatchInRange step resolves its bound. `const_elem`
// and `global` carry a constant index; `read` and `bind` carry a local
// slot. Evaluated bounds are handled by a separate MatchRangeBound step,
// not encoded in MatchInRange, so they have no kind here.
pub const RangeLimitKind = enum(u8) {
    none,
    const_elem,
    global,
    read,
    bind,
};

pub const OpCode = enum(u8) {
    AssertFunctionArity,
    AssertParamTypes,
    AssertParamTypes4,
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
    DestructurePlan,
    DestructurePlan2,
    DestructurePlan3,
    Drop,
    End,
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
    JumpIfFailure,
    JumpIfZero,
    // Match step ops: pattern constraints compiled inline. Registers are
    // frame slots above the locals; semidet steps carry a fail-jump
    // offset like Or. MatchScrutinee copies the value under test (stack
    // top) into its register; projections copy container children into
    // registers; MatchBind copies a register into a local slot; MatchFail
    // is the shared failure tail that swaps the value for the failure
    // const and records the pattern mismatch.
    MatchBind,
    MatchCastBool,
    MatchCastNum,
    MatchConst,
    MatchElem,
    MatchElemBack,
    MatchElemDyn,
    MatchEval,
    MatchFail,
    MatchGlobal,
    MatchInRange,
    MatchKey,
    MatchKeyBound,
    MatchKeys,
    MatchKeysMin,
    MatchLen,
    MatchLenMin,
    MatchMergeBool,
    MatchMergeNum,
    MatchMergeNumNeg,
    MatchNextUnclaimed,
    MatchObjectRest,
    MatchObjectRestSearch,
    MatchRangeBound,
    MatchRepeatChunk,
    MatchRepeatInit,
    MatchRepeatNext,
    MatchRepeatRange,
    MatchRepeatValue,
    MatchScrutinee,
    MatchSearchInit,
    MatchSlice,
    MatchSlot,
    MatchStrChar,
    MatchStrCovered,
    MatchStrInit,
    MatchStrLit,
    MatchStrPrefix,
    MatchStrRest,
    MatchStrSuffix,
    MatchStrVal,
    MatchType,
    // Open a fresh match register window sized to the operand width
    // (placeholders), saving the current base; close it, releasing its
    // live handles and restoring the enclosing base. Window scratch lives
    // on the VM match register stack, not the value stack.
    MatchWindowEnter,
    MatchWindowExit,
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
    ParseNumberStringChar,
    ParseRange,
    ParseUpperBoundedRange,
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
    PushNegInteger,
    PushNull,
    PushInteger,
    PushNumberStringChar,
    PushNumberStringNegOne,
    PushNumberStringOne,
    PushNumberStringThree,
    PushNumberStringTwo,
    PushNumberStringZero,
    PushUnderscoreVar,
    RepeatValue,
    ResetInput,
    SetClosureCaptures,
    SetInputMark,
    SetLocal,
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
            .PopInputMark,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            // Window bookkeeping touches the match register stack only.
            .MatchWindowEnter,
            .MatchWindowExit,
            => .{ .fixed = .{ .pops = 0, .pushes = 0 } },

            .CallFunctionConstant,
            .CallFunctionConstant2,
            .CallFunctionConstant3,
            .CallFunctionLocal,
            .CallTailFunctionConstant,
            .CallTailFunctionConstant2,
            .CallTailFunctionConstant3,
            .CallTailFunctionLocal,
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
            .ParseNumberStringChar,
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
            .PushNegInteger,
            .PushNull,
            .PushInteger,
            .PushNumberStringChar,
            .PushNumberStringNegOne,
            .PushNumberStringOne,
            .PushNumberStringThree,
            .PushNumberStringTwo,
            .PushNumberStringZero,
            .PushTrue,
            .PushUnderscoreVar,
            => .{ .fixed = .{ .pops = 0, .pushes = 1 } },

            .AssertFunctionArity,
            .AssertParamTypes,
            .AssertParamTypes4,
            .CaptureLocal,
            .CreateClosure,
            .Decrement,
            .DestructurePlan,
            .DestructurePlan2,
            .DestructurePlan3,
            .Increment,
            .NegateNumber,
            .NegateParser,
            .ParseLowerBoundedRange,
            .ParseUpperBoundedRange,
            .ValidateRepeatPattern,
            => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            .Drop,
            .SetLocal,
            => .{ .fixed = .{ .pops = 1, .pushes = 0 } },

            // Register-to-register / register-to-slot moves and the det
            // projections: no stack traffic.
            .MatchBind,
            .MatchElem,
            .MatchElemBack,
            .MatchElemDyn,
            .MatchObjectRest,
            .MatchObjectRestSearch,
            .MatchSearchInit,
            .MatchSlice,
            .MatchStrInit,
            .MatchStrRest,
            => .{ .fixed = .{ .pops = 0, .pushes = 0 } },

            // Inspects the value under test on the stack top and copies it
            // into a register.
            .MatchScrutinee => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            // Pops the matched value and pushes the failure const.
            .MatchFail => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            // Semidet steps: no stack traffic on either path.
            .MatchCastBool,
            .MatchCastNum,
            .MatchConst,
            .MatchGlobal,
            .MatchInRange,
            .MatchKey,
            .MatchKeyBound,
            .MatchKeys,
            .MatchKeysMin,
            .MatchLen,
            .MatchLenMin,
            .MatchMergeBool,
            .MatchMergeNum,
            .MatchMergeNumNeg,
            .MatchNextUnclaimed,
            .MatchRepeatInit,
            .MatchRepeatNext,
            .MatchRepeatRange,
            .MatchSlot,
            .MatchStrChar,
            .MatchStrCovered,
            .MatchStrLit,
            .MatchStrPrefix,
            .MatchStrSuffix,
            .MatchType,
            => .{ .branch = .{
                .fallthrough = .{ .pops = 0, .pushes = 0 },
                .jump = .{ .pops = 0, .pushes = 0 },
            } },

            // Pops the value evaluated by the preceding expression and
            // compares it against the place register on both paths.
            .MatchEval,
            // Pops the evaluated range bound and compares it against the
            // value register as one end of the range.
            .MatchRangeBound,
            // Pop the evaluated repeat operand — the pattern value
            // (MatchRepeatValue derives the count from src) or the count
            // (MatchRepeatChunk derives src's repeated chunk) — on both
            // paths.
            .MatchRepeatChunk,
            .MatchRepeatValue,
            // Pops the evaluated segment value the preceding expression
            // left on the stack, stringifies it, and byte-compares it at
            // the cursor.
            .MatchStrVal,
            => .{ .branch = .{
                .fallthrough = .{ .pops = 1, .pushes = 0 },
                .jump = .{ .pops = 1, .pushes = 0 },
            } },

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
            .PopInputMark,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            // Window ops manage match-register handles directly (Enter
            // fills placeholders without retain, Exit releases), never the
            // value stack.
            .MatchWindowEnter,
            .MatchWindowExit,
            => .{ .operands = .none, .result = .none },

            // Push a second handle to a local slot's value.
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .GetLocal,
            => .{ .operands = .none, .result = .derived },

            // Push a local slot's value at its last read: the slot's
            // handle transfers to the stack (no increment) and the slot
            // is nulled so End's frame release can't count it again.
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

            // Push a mutable copy of a container constant, possibly in a
            // reused husk; the pushed handle is the copy's first. With
            // fast paths off, pushes the immortal constant itself, whose
            // pinned count makes the classification moot.
            .GetConstantMutable,
            .GetConstantMutable2,
            .GetConstantMutable3,
            => .{ .operands = .none, .result = .fresh },

            // Parse results and pushed literals: value types or new Dyns
            // whose pushed handle is their first reference.
            .ParseChar,
            .ParseCodepoint,
            .ParseCodepointRange,
            .ParseIntegerRange,
            .ParseNumberStringChar,
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
            .PushNegInteger,
            .PushNull,
            .PushInteger,
            .PushNumberStringChar,
            .PushNumberStringNegOne,
            .PushNumberStringOne,
            .PushNumberStringThree,
            .PushNumberStringTwo,
            .PushNumberStringZero,
            .PushTrue,
            .PushUnderscoreVar,
            => .{ .operands = .none, .result = .fresh },

            // Peeks: inspect and leave in place. CaptureLocal copies a
            // local into a closure: +1 in the dispatch.
            .AssertFunctionArity,
            .AssertParamTypes,
            .AssertParamTypes4,
            .CaptureLocal,
            .JumpIfFailure,
            .JumpIfZero,
            .ValidateRepeatPattern,
            => .{ .operands = .borrowed, .result = .none },

            // The popped handle moves into a frame slot; the slot's
            // previous handle is released in the dispatch.
            .SetLocal => .{ .operands = .consumed, .result = .none },

            // Match steps never pop handles: tests borrow, and the copy
            // steps (MatchScrutinee, MatchElem, MatchElemBack, MatchKey,
            // MatchBind) retain into their target slot and release the
            // slot's previous handle in the dispatch. MatchSlice stores a
            // fresh array's creator handle into its register the same
            // way.
            .MatchBind,
            .MatchCastBool,
            .MatchCastNum,
            .MatchConst,
            .MatchElem,
            .MatchElemBack,
            .MatchElemDyn,
            .MatchGlobal,
            .MatchInRange,
            .MatchKey,
            .MatchKeyBound,
            .MatchKeys,
            .MatchKeysMin,
            .MatchLen,
            .MatchLenMin,
            .MatchMergeBool,
            .MatchMergeNum,
            .MatchMergeNumNeg,
            .MatchNextUnclaimed,
            .MatchObjectRest,
            .MatchObjectRestSearch,
            .MatchRepeatInit,
            .MatchRepeatNext,
            .MatchRepeatRange,
            .MatchScrutinee,
            .MatchSearchInit,
            .MatchSlice,
            .MatchSlot,
            .MatchStrChar,
            .MatchStrCovered,
            .MatchStrInit,
            .MatchStrLit,
            .MatchStrPrefix,
            .MatchStrRest,
            .MatchStrSuffix,
            .MatchType,
            => .{ .operands = .borrowed, .result = .none },

            // The matched value's handle dies; the failure const is not a
            // Dyn.
            .MatchFail => .{ .operands = .consumed, .result = .none },

            // Pops and discards the evaluated expression result; the
            // scrutinee below it stays untouched.
            .MatchEval,
            // Pops and discards the evaluated range bound.
            .MatchRangeBound,
            // Pop and release the evaluated repeat operand; the derived
            // count or chunk is stored into the destination register in
            // the dispatch (release previous, fresh chunks move their
            // creator handle in).
            .MatchRepeatChunk,
            .MatchRepeatValue,
            // Pops and releases the evaluated segment value; the compare
            // reads its bytes before releasing.
            .MatchStrVal,
            => .{ .operands = .consumed, .result = .none },

            // The matched value stays on the stack on success (pattern
            // vars bound into frame slots add +1 per binding in the
            // pattern solver), or is released and replaced by the failure
            // const on failure.
            .DestructurePlan,
            .DestructurePlan2,
            .DestructurePlan3,
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

            // Pops the function elem, pushes a closure holding it,
            // possibly in a reused husk; the pushed handle is the
            // closure's first.
            .CreateClosure => .{ .operands = .consumed, .result = .fresh },

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
            .PushNumberStringNegOne,
            .PushNumberStringOne,
            .PushNumberStringThree,
            .PushNumberStringTwo,
            .PushNumberStringZero,
            .PushTrue,
            .PushUnderscoreVar,
            .RepeatValue,
            .ResetInput,
            .SetClosureCaptures,
            .SetInputMark,
            .Swap,
            .TakeLeft,
            .ValidateRepeatPattern,
            .MatchFail,
            .MatchWindowExit,
            => self.simpleInstruction(writer, offset),
            .MatchWindowEnter => self.byteInstruciton(chunk, writer, offset),
            .MatchScrutinee => self.registerInstruction(chunk, writer, offset),
            .MatchSearchInit => self.registerInstruction(chunk, writer, offset),
            .MatchNextUnclaimed => self.matchNextUnclaimedInstruction(chunk, vm, module, writer, offset),
            .MatchObjectRestSearch => self.matchObjectRestSearchInstruction(chunk, vm, module, writer, offset),
            .MatchBind => self.matchBindInstruction(chunk, writer, offset),
            .MatchElem => self.matchElemInstruction(chunk, writer, offset),
            .MatchElemBack => self.matchElemBackInstruction(chunk, writer, offset),
            .MatchElemDyn => self.matchElemDynInstruction(chunk, writer, offset),
            .MatchRepeatInit => self.matchRepeatInitInstruction(chunk, writer, offset),
            .MatchRepeatNext => self.matchRepeatNextInstruction(chunk, writer, offset),
            .MatchSlice => self.matchSliceInstruction(chunk, writer, offset),
            .MatchStrInit => self.matchStrInitInstruction(chunk, writer, offset),
            .MatchStrRest => self.matchStrRestInstruction(chunk, writer, offset),
            .MatchStrLit => self.matchStrLitInstruction(chunk, vm, module, writer, offset),
            .MatchStrVal => self.matchStrValInstruction(chunk, writer, offset),
            .MatchStrChar => self.matchStrCharInstruction(chunk, writer, offset),
            .MatchStrCovered => self.matchStrCoveredInstruction(chunk, writer, offset),
            .MatchCastNum,
            .MatchCastBool,
            => self.matchCastInstruction(chunk, writer, offset),
            .MatchType => self.matchTypeInstruction(chunk, writer, offset),
            .MatchLen,
            .MatchLenMin,
            .MatchKeys,
            .MatchKeysMin,
            => self.matchCountJumpInstruction(chunk, writer, offset),
            .MatchSlot => self.matchSlotInstruction(chunk, writer, offset),
            .MatchEval => self.matchEvalInstruction(chunk, writer, offset),
            .MatchRepeatChunk,
            .MatchRepeatValue,
            => self.matchRepeatInstruction(chunk, writer, offset),
            .MatchRepeatRange => self.matchRepeatRangeInstruction(chunk, vm, module, writer, offset),
            .MatchInRange => self.matchInRangeInstruction(chunk, vm, module, writer, offset),
            .MatchRangeBound => self.matchRangeBoundInstruction(chunk, writer, offset),
            .MatchConst,
            .MatchGlobal,
            .MatchStrPrefix,
            .MatchStrSuffix,
            => self.matchConstJumpInstruction(chunk, vm, module, writer, offset),
            .MatchKey => self.matchKeyInstruction(chunk, vm, module, writer, offset),
            .MatchKeyBound => self.matchKeyBoundInstruction(chunk, vm, module, writer, offset),
            .MatchMergeBool => self.matchMergeBoolInstruction(chunk, vm, module, writer, offset),
            .MatchMergeNum, .MatchMergeNumNeg => self.matchMergeNumInstruction(chunk, vm, module, writer, offset),
            .MatchObjectRest => self.matchObjectRestInstruction(chunk, vm, module, writer, offset),
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
            .DestructurePlan,
            => self.matchPlanInstruction(chunk, vm, module, writer, offset),
            .DestructurePlan2,
            => self.matchPlan2Instruction(chunk, vm, module, writer, offset),
            .DestructurePlan3,
            => self.matchPlan3Instruction(chunk, vm, module, writer, offset),
            .CallFunctionLocal,
            .CallTailFunctionLocal,
            .CaptureLocal,
            .GetLocal,
            .GetLocalMove,
            .SetLocal,
            => self.localInstruction(chunk, writer, offset),
            .AssertFunctionArity,
            .CallFunction,
            .CallTailFunction,
            .CreateClosure,
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
            .PushInteger,
            => self.pushNumberInstruciton(chunk, writer, offset),
            .PushNegInteger,
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

    fn matchPlanInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const planIdx = chunk.read(offset + 1);
        const plan = module.getMatchPlan(planIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), planIdx });
        try plan.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 2;
    }

    fn matchPlan2Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var planIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 8;
        planIdx |= chunk.read(offset + 2);
        const plan = module.getMatchPlan(planIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), planIdx });
        try plan.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 3;
    }

    fn matchPlan3Instruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        var planIdx = @as(usize, @intCast(chunk.read(offset + 1))) << 16;
        planIdx |= @as(usize, @intCast(chunk.read(offset + 2))) << 8;
        planIdx |= chunk.read(offset + 3);
        const plan = module.getMatchPlan(planIdx);
        try writer.print("{s} {}: ", .{ @tagName(self), planIdx });
        try plan.print(vm, writer);
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

    fn registerInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        try writer.print("{s} r{}\n", .{ @tagName(self), register });
        return offset + 2;
    }

    fn matchBindInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const local = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        try writer.print("{s} l{} r{}\n", .{ @tagName(self), local, src });
        return offset + 3;
    }

    fn matchElemInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const index = chunk.read(offset + 3);
        try writer.print("{s} r{} r{}[{}]\n", .{ @tagName(self), dst, src, index });
        return offset + 4;
    }

    fn matchObjectRestInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} r{} r{} \\ ", .{ @tagName(self), dst, src });
        try keys.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 5;
    }

    fn matchObjectRestSearchInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const claim_base = chunk.read(offset + 5);
        const claim_count = chunk.read(offset + 6);
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} r{} r{} \\ ", .{ @tagName(self), dst, src });
        try keys.print(vm, writer);
        try writer.print(" r{}..r{}\n", .{ claim_base, claim_base + claim_count });
        return offset + 7;
    }

    fn matchNextUnclaimedInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const key_dst = chunk.read(offset + 1);
        const val_dst = chunk.read(offset + 2);
        const src = chunk.read(offset + 3);
        const cursor = chunk.read(offset + 4);
        const claim_count = chunk.read(offset + 5);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 6))) << 8) | chunk.read(offset + 7);
        const jump = (@as(u16, @intCast(chunk.read(offset + 8))) << 8) | chunk.read(offset + 9);
        const target = offset + 10 + jump;
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} key=r{} val=r{} src=r{} cursor=r{} keys=r{}..r{} \\ ", .{
            @tagName(self), key_dst, val_dst, src, cursor, key_dst - claim_count, key_dst,
        });
        try keys.print(vm, writer);
        try writer.print(" loop->{}\n", .{target});
        return offset + 10;
    }

    fn matchKeyBoundInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const key_dst = chunk.read(offset + 1);
        const val_dst = chunk.read(offset + 2);
        const src = chunk.read(offset + 3);
        const slot = chunk.read(offset + 4);
        const claim_count = chunk.read(offset + 5);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 6))) << 8) | chunk.read(offset + 7);
        const jump = (@as(u16, @intCast(chunk.read(offset + 8))) << 8) | chunk.read(offset + 9);
        const target = offset + 10 + jump;
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} key=r{} val=r{} src=r{}[l{}] keys=r{}..r{} \\ ", .{
            @tagName(self), key_dst, val_dst, src, slot, key_dst - claim_count, key_dst,
        });
        try keys.print(vm, writer);
        try writer.print(" -> {}\n", .{target});
        return offset + 10;
    }

    fn matchElemBackInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const index = chunk.read(offset + 3);
        try writer.print("{s} r{} r{}[^{}]\n", .{ @tagName(self), dst, src, index });
        return offset + 4;
    }

    fn matchSliceInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const front = chunk.read(offset + 3);
        const back = chunk.read(offset + 4);
        try writer.print("{s} r{} r{}[{}..^{}]\n", .{ @tagName(self), dst, src, front, back });
        return offset + 5;
    }

    fn matchStrInitInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const front = chunk.read(offset + 2);
        const end = chunk.read(offset + 3);
        try writer.print("{s} r{} front=r{} end=r{}\n", .{ @tagName(self), src, front, end });
        return offset + 4;
    }

    fn matchStrRestInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const front = chunk.read(offset + 3);
        const end = chunk.read(offset + 4);
        try writer.print("{s} r{} r{}[r{}..r{}]\n", .{ @tagName(self), dst, src, front, end });
        return offset + 5;
    }

    fn strCursorDir(back: u8) []const u8 {
        return if (back != 0) "back" else "front";
    }

    fn matchStrLitInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const cursor = chunk.read(offset + 2);
        const opp = chunk.read(offset + 3);
        const back = chunk.read(offset + 4);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const jump = (@as(u16, @intCast(chunk.read(offset + 7))) << 8) | chunk.read(offset + 8);
        const target = offset + 9 + jump;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} cursor=r{} opp=r{} {s} ", .{ @tagName(self), src, cursor, opp, strCursorDir(back) });
        try constant.print(vm, writer);
        try writer.print(" -> {}\n", .{target});
        return offset + 9;
    }

    fn matchStrValInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const cursor = chunk.read(offset + 2);
        const opp = chunk.read(offset + 3);
        const back = chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        try writer.print("{s} r{} cursor=r{} opp=r{} {s} -> {}\n", .{ @tagName(self), src, cursor, opp, strCursorDir(back), target });
        return offset + 7;
    }

    fn matchStrCharInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const cursor = chunk.read(offset + 3);
        const opp = chunk.read(offset + 4);
        const back = chunk.read(offset + 5);
        const jump = (@as(u16, @intCast(chunk.read(offset + 6))) << 8) | chunk.read(offset + 7);
        const target = offset + 8 + jump;
        try writer.print("{s} r{} r{} cursor=r{} opp=r{} {s} -> {}\n", .{ @tagName(self), dst, src, cursor, opp, strCursorDir(back), target });
        return offset + 8;
    }

    fn matchCastInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} <- r{} -> {}\n", .{ @tagName(self), dst, src, target });
        return offset + 5;
    }

    fn matchStrCoveredInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const front = chunk.read(offset + 1);
        const end = chunk.read(offset + 2);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{}==r{} -> {}\n", .{ @tagName(self), front, end, target });
        return offset + 5;
    }

    fn matchTypeInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const ty: []const u8 = switch (chunk.read(offset + 2)) {
            0 => "array",
            1 => "object",
            2 => "string",
            else => "unknown",
        };
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} {s} -> {}\n", .{ @tagName(self), register, ty, target });
        return offset + 5;
    }

    fn matchCountJumpInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const count = chunk.read(offset + 2);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} {} -> {}\n", .{ @tagName(self), register, count, target });
        return offset + 5;
    }

    fn matchSlotInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const local = chunk.read(offset + 2);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} l{} -> {}\n", .{ @tagName(self), register, local, target });
        return offset + 5;
    }

    fn matchEvalInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} -> {}\n", .{ @tagName(self), register, target });
        return offset + 5;
    }

    fn matchElemDynInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const base = chunk.read(offset + 3);
        const index = chunk.read(offset + 4);
        try writer.print("{s} r{} r{}[r{}+{}]\n", .{ @tagName(self), dst, src, base, index });
        return offset + 5;
    }

    fn matchRepeatInitInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const len = chunk.read(offset + 2);
        const count_dst = chunk.read(offset + 3);
        const base = chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        try writer.print("{s} r{} /{} n=r{} base=r{} -> {}\n", .{ @tagName(self), src, len, count_dst, base, target });
        return offset + 7;
    }

    fn matchRepeatNextInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const base = chunk.read(offset + 2);
        const len = chunk.read(offset + 3);
        const jump = (@as(u16, @intCast(chunk.read(offset + 4))) << 8) | chunk.read(offset + 5);
        const target = offset + 6 + jump;
        try writer.print("{s} r{} base=r{}+{} done->{}\n", .{ @tagName(self), src, base, len, target });
        return offset + 6;
    }

    fn matchRepeatInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const dst = chunk.read(offset + 2);
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} r{} -> {}\n", .{ @tagName(self), src, dst, target });
        return offset + 5;
    }

    fn matchRepeatRangeInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const dst = chunk.read(offset + 2);
        const lower_kind = chunk.read(offset + 3);
        const lower_arg = (@as(u16, @intCast(chunk.read(offset + 4))) << 8) | chunk.read(offset + 5);
        const upper_kind = chunk.read(offset + 6);
        const upper_arg = (@as(u16, @intCast(chunk.read(offset + 7))) << 8) | chunk.read(offset + 8);
        const jump = (@as(u16, @intCast(chunk.read(offset + 9))) << 8) | chunk.read(offset + 10);
        const target = offset + 11 + jump;
        try writer.print("{s} r{} r{} ", .{ @tagName(self), src, dst });
        try printRangeLimit(vm, module, writer, lower_kind, lower_arg);
        try writer.writeAll("..");
        try printRangeLimit(vm, module, writer, upper_kind, upper_arg);
        try writer.print(" -> {}\n", .{target});
        return offset + 11;
    }

    fn matchInRangeInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const slot = chunk.read(offset + 1);
        const lower_kind = chunk.read(offset + 2);
        const lower_arg = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const upper_kind = chunk.read(offset + 5);
        const upper_arg = (@as(u16, @intCast(chunk.read(offset + 6))) << 8) | chunk.read(offset + 7);
        const jump = (@as(u16, @intCast(chunk.read(offset + 8))) << 8) | chunk.read(offset + 9);
        const target = offset + 10 + jump;
        try writer.print("{s} r{} ", .{ @tagName(self), slot });
        try printRangeLimit(vm, module, writer, lower_kind, lower_arg);
        try writer.writeAll("..");
        try printRangeLimit(vm, module, writer, upper_kind, upper_arg);
        try writer.print(" -> {}\n", .{target});
        return offset + 10;
    }

    fn printRangeLimit(vm: VM, module: Module, writer: *Writer, kind: u8, arg: u16) !void {
        switch (kind) {
            0 => {}, // none: open bound
            1, 2 => { // const / global
                var constant = module.getConstant(arg);
                try constant.print(vm, writer);
            },
            3 => try writer.print("s{}", .{arg}), // read: bound local slot
            4 => try writer.print("=s{}", .{arg}), // bind: unbound var slot
            else => try writer.writeAll("?"),
        }
    }

    fn matchRangeBoundInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const slot = chunk.read(offset + 1);
        const is_upper = chunk.read(offset + 2) != 0;
        const jump = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const target = offset + 5 + jump;
        try writer.print("{s} r{} {s} -> {}\n", .{ @tagName(self), slot, if (is_upper) "hi" else "lo", target });
        return offset + 5;
    }

    fn matchConstJumpInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 2))) << 8) | chunk.read(offset + 3);
        const jump = (@as(u16, @intCast(chunk.read(offset + 4))) << 8) | chunk.read(offset + 5);
        const target = offset + 6 + jump;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} ", .{ @tagName(self), register });
        try constant.print(vm, writer);
        try writer.print(" -> {}\n", .{target});
        return offset + 6;
    }

    fn matchKeyInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{}[", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        try writer.print("] -> {}\n", .{target});
        return offset + 7;
    }

    fn matchMergeBoolInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{} claim ", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        try writer.print(" -> {}\n", .{target});
        return offset + 7;
    }

    fn matchMergeNumInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{} - ", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        try writer.print(" -> {}\n", .{target});
        return offset + 7;
    }

    fn byteInstruciton(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const byte = chunk.read(offset + 1);
        try writer.print("{s} {}\n", .{ @tagName(self), byte });
        return offset + 2;
    }

    fn localInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const local = chunk.read(offset + 1);
        try writer.print("{s} l{}\n", .{ @tagName(self), local });
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
        const str = vm.strings.get(@enumFromInt(sid));
        try writer.print("{s} \"{s}\"\n", .{ @tagName(self), str });
        return offset + 1 + width;
    }

    fn varInstruction(self: OpCode, chunk: *Chunk, vm: VM, writer: *Writer, offset: usize, width: usize) !usize {
        var sid: u32 = 0;
        for (1..width + 1) |i| {
            sid = (sid << 8) | chunk.read(offset + i);
        }
        const str = vm.strings.get(@enumFromInt(sid));
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

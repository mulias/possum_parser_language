const std = @import("std");
const Writer = std.io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;

// How a range bound resolves. `const_elem` and `global` carry a constant
// index; `read` and `bind` carry a local slot. A MatchBound step only
// ever carries `const_elem`/`read` (bind and global bounds are split at
// compile time into a MatchBind / a constant or call); MatchRepeatRange
// carries `none`/`const_elem`/`read`. Evaluated bounds are handled by a
// separate MatchRangeBound step and have no kind here.
pub const RangeLimitKind = enum(u8) {
    none,
    const_elem,
    global,
    read,
    bind,
};

// The comparand a MatchCmp step tests its register against. `constant`
// carries a module constant index; `slot` a bound frame-local slot; `reg`
// another match scratch register in the same window.
pub const MatchCmpKind = enum(u8) {
    constant,
    slot,
    reg,
};

// The target type a MatchCast step parses its source register's string
// bytes into: a number, a boolean, or a JSON document (array/object).
pub const MatchCastKind = enum(u8) {
    number,
    boolean,
    json,
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
    MatchCast,
    MatchCmp,
    MatchCount,
    MatchBound,
    MatchDivideEval,
    MatchElem,
    MatchEval,
    MatchFail,
    MatchKey,
    MatchKeyClaim,
    MatchMergeBool,
    MatchMergeNum,
    MatchNextUnclaimed,
    MatchObjectRest,
    MatchRangeBound,
    // Cascade a just-closed child window's failure outward: jump to the
    // innermost still-open window's shared fail block. Emitted after a
    // child MatchWindowExit on the fail path.
    MatchRefail,
    MatchRepeatChunk,
    MatchRepeatInit,
    MatchRepeatNext,
    MatchRepeatRange,
    // Solve a range count factor in a count product: read the residual
    // count, find the greedy (largest) repetition count in the range that
    // divides it, and write the quotient (the trailing unbound factor's
    // value) back for a following MatchBind.
    MatchRepeatRangeDivide,
    MatchRepeatValue,
    MatchScrutinee,
    MatchSearchInit,
    MatchSlice,
    MatchStrChar,
    MatchStrEnd,
    MatchStrInit,
    MatchStrLit,
    MatchStrRest,
    MatchStrVal,
    MatchSubScrutinee,
    MatchSubtractEval,
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
            // MatchRefail jumps to the innermost window's fail block; its
            // successor is that block, resolved by the window walk, not the
            // value stack, so it moves no stack values.
            .MatchWindowExit,
            .MatchRefail,
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
            .MatchObjectRest,
            .MatchSearchInit,
            .MatchSlice,
            .MatchStrInit,
            .MatchStrRest,
            .MatchSubScrutinee,
            => .{ .fixed = .{ .pops = 0, .pushes = 0 } },

            // Inspects the value under test on the stack top and copies it
            // into a register.
            .MatchScrutinee => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            // Pops the matched value and pushes the failure const.
            .MatchFail => .{ .fixed = .{ .pops = 1, .pushes = 1 } },

            // Semidet steps: no stack traffic. Failure jumps to the
            // innermost window's shared fail block (a MatchWindowEnter
            // branch edge seeds that block's depth), so the step itself is
            // modeled as a plain fixed op — its fail edge changes no depth.
            .MatchBound,
            .MatchCast,
            .MatchCmp,
            .MatchCount,
            .MatchKey,
            .MatchMergeBool,
            .MatchMergeNum,
            .MatchNextUnclaimed,
            .MatchRepeatInit,
            .MatchRepeatRange,
            .MatchRepeatRangeDivide,
            .MatchStrChar,
            .MatchStrEnd,
            .MatchStrLit,
            .MatchType,
            => .{ .fixed = .{ .pops = 0, .pushes = 0 } },

            // Semidet steps that pop the value the preceding expression
            // evaluated before comparing (both paths pop, so a plain fixed
            // pop): MatchEval (compares against the place), MatchRangeBound
            // (a range end), MatchRepeatChunk/Value (the repeat operand),
            // MatchStrVal (a template segment), MatchSubtractEval (a merge
            // residual part), MatchKeyClaim (the probed object key).
            .MatchEval,
            .MatchKeyClaim,
            .MatchRangeBound,
            .MatchRepeatChunk,
            .MatchRepeatValue,
            .MatchStrVal,
            .MatchSubtractEval,
            .MatchDivideEval,
            => .{ .fixed = .{ .pops = 1, .pushes = 0 } },

            // Opens a window; the fail-target operand is a branch edge to
            // the window's shared fail block (same depth as the fallthrough
            // into the window body), seeding that block for the verifier.
            .MatchWindowEnter,
            // The loop-done exit is a genuine forward success branch.
            .MatchRepeatNext,
            => .{ .branch = .{
                .fallthrough = .{ .pops = 0, .pushes = 0 },
                .jump = .{ .pops = 0, .pushes = 0 },
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
            .MatchRefail,
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
            // steps (MatchScrutinee, MatchElem, MatchKey,
            // MatchBind) retain into their target slot and release the
            // slot's previous handle in the dispatch. MatchSlice stores a
            // fresh array's creator handle into its register the same
            // way.
            .MatchBind,
            .MatchBound,
            .MatchCast,
            .MatchCmp,
            .MatchCount,
            .MatchElem,
            .MatchKey,
            .MatchMergeBool,
            .MatchMergeNum,
            .MatchNextUnclaimed,
            .MatchObjectRest,
            .MatchRepeatInit,
            .MatchRepeatNext,
            .MatchRepeatRange,
            .MatchRepeatRangeDivide,
            .MatchScrutinee,
            .MatchSearchInit,
            .MatchSlice,
            .MatchStrChar,
            .MatchStrEnd,
            .MatchStrInit,
            .MatchStrLit,
            .MatchStrRest,
            .MatchSubScrutinee,
            .MatchType,
            => .{ .operands = .borrowed, .result = .none },

            // The matched value's handle dies; the failure const is not a
            // Dyn.
            .MatchFail => .{ .operands = .consumed, .result = .none },

            // Pops and releases the probed object key; the projected key
            // and value are retained into their registers in the dispatch.
            .MatchKeyClaim,
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
            // Pops and releases the evaluated summed part; the numeric
            // residual written into the destination is not a Dyn handle.
            .MatchSubtractEval,
            // Pops and releases the evaluated count factor; the numeric
            // residual written into the destination is not a Dyn handle.
            .MatchDivideEval,
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
            .MatchRefail,
            => self.simpleInstruction(writer, offset),
            .MatchWindowEnter => self.matchWindowEnterInstruction(chunk, writer, offset),
            .MatchScrutinee => self.registerInstruction(chunk, writer, offset),
            .MatchSearchInit => self.registerInstruction(chunk, writer, offset),
            .MatchNextUnclaimed => self.matchNextUnclaimedInstruction(chunk, vm, module, writer, offset),
            .MatchBind => self.matchBindInstruction(chunk, writer, offset),
            .MatchSubScrutinee => self.matchSubScrutineeInstruction(chunk, writer, offset),
            .MatchElem => self.matchElemInstruction(chunk, writer, offset),
            .MatchRepeatInit => self.matchRepeatInitInstruction(chunk, writer, offset),
            .MatchRepeatNext => self.matchRepeatNextInstruction(chunk, writer, offset),
            .MatchSlice => self.matchSliceInstruction(chunk, writer, offset),
            .MatchStrInit => self.matchStrInitInstruction(chunk, writer, offset),
            .MatchStrRest => self.matchStrRestInstruction(chunk, writer, offset),
            .MatchStrLit => self.matchStrLitInstruction(chunk, vm, module, writer, offset),
            .MatchStrVal => self.matchStrValInstruction(chunk, writer, offset),
            .MatchStrChar => self.matchStrCharInstruction(chunk, writer, offset),
            .MatchCmp => self.matchCmpInstruction(chunk, vm, module, writer, offset),
            .MatchCast => self.matchCastInstruction(chunk, writer, offset),
            .MatchType => self.matchTypeInstruction(chunk, writer, offset),
            .MatchCount => self.matchCountInstruction(chunk, writer, offset),
            .MatchEval => self.matchEvalInstruction(chunk, writer, offset),
            .MatchSubtractEval => self.matchSubtractEvalInstruction(chunk, writer, offset),
            .MatchDivideEval => self.matchDivideEvalInstruction(chunk, writer, offset),
            .MatchRepeatChunk,
            .MatchRepeatValue,
            => self.matchRepeatInstruction(chunk, writer, offset),
            .MatchRepeatRange,
            .MatchRepeatRangeDivide,
            => self.matchRepeatRangeInstruction(chunk, vm, module, writer, offset),
            .MatchBound => self.matchBoundInstruction(chunk, vm, module, writer, offset),
            .MatchRangeBound => self.matchRangeBoundInstruction(chunk, writer, offset),
            .MatchStrEnd => self.matchStrEndInstruction(chunk, vm, module, writer, offset),
            .MatchKey => self.matchKeyInstruction(chunk, vm, module, writer, offset),
            .MatchKeyClaim => self.matchKeyClaimInstruction(chunk, vm, module, writer, offset),
            .MatchMergeBool => self.matchMergeBoolInstruction(chunk, vm, module, writer, offset),
            .MatchMergeNum => self.matchMergeNumInstruction(chunk, vm, module, writer, offset),
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

    // Copies a register from the enclosing window (^r) into this window's
    // destination register.
    fn matchSubScrutineeInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        try writer.print("{s} r{} ^r{}\n", .{ @tagName(self), dst, src });
        return offset + 3;
    }

    fn matchElemInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const index = chunk.read(offset + 3);
        const back = chunk.read(offset + 4);
        if (back != 0) {
            try writer.print("{s} r{} r{}[^{}]\n", .{ @tagName(self), dst, src, index });
        } else {
            try writer.print("{s} r{} r{}[{}]\n", .{ @tagName(self), dst, src, index });
        }
        return offset + 5;
    }

    fn matchObjectRestInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const claim_base = chunk.read(offset + 5);
        const claim_count = chunk.read(offset + 6);
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} r{} r{} \\ ", .{ @tagName(self), dst, src });
        try keys.print(vm, writer);
        if (claim_count != 0) {
            try writer.print(" r{}..r{}", .{ claim_base, claim_base + claim_count });
        }
        try writer.print("\n", .{});
        return offset + 7;
    }

    fn matchNextUnclaimedInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const key_dst = chunk.read(offset + 1);
        const val_dst = chunk.read(offset + 2);
        const src = chunk.read(offset + 3);
        const cursor = chunk.read(offset + 4);
        const claim_count = chunk.read(offset + 5);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 6))) << 8) | chunk.read(offset + 7);
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} key=r{} val=r{} src=r{} cursor=r{} keys=r{}..r{} \\ ", .{
            @tagName(self), key_dst, val_dst, src, cursor, key_dst - claim_count, key_dst,
        });
        try keys.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 8;
    }

    fn matchKeyClaimInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const key_dst = chunk.read(offset + 1);
        const val_dst = chunk.read(offset + 2);
        const src = chunk.read(offset + 3);
        const claim_count = chunk.read(offset + 4);
        const constantIdx = (@as(usize, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        var keys = module.getConstant(constantIdx);
        try writer.print("{s} key=r{} val=r{} src=r{} keys=r{}..r{} \\ ", .{
            @tagName(self), key_dst, val_dst, src, key_dst - claim_count, key_dst,
        });
        try keys.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 7;
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
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} cursor=r{} opp=r{} {s} ", .{ @tagName(self), src, cursor, opp, strCursorDir(back) });
        try constant.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 7;
    }

    fn matchStrValInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const cursor = chunk.read(offset + 2);
        const opp = chunk.read(offset + 3);
        const back = chunk.read(offset + 4);
        try writer.print("{s} r{} cursor=r{} opp=r{} {s}\n", .{ @tagName(self), src, cursor, opp, strCursorDir(back) });
        return offset + 5;
    }

    fn matchStrCharInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const cursor = chunk.read(offset + 3);
        const opp = chunk.read(offset + 4);
        const back = chunk.read(offset + 5);
        try writer.print("{s} r{} r{} cursor=r{} opp=r{} {s}\n", .{ @tagName(self), dst, src, cursor, opp, strCursorDir(back) });
        return offset + 6;
    }

    fn matchCastInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const ty: []const u8 = switch (@as(MatchCastKind, @enumFromInt(chunk.read(offset + 3)))) {
            .number => "num",
            .boolean => "bool",
            .json => "json",
        };
        try writer.print("{s} r{} <- {s} r{}\n", .{ @tagName(self), dst, ty, src });
        return offset + 4;
    }

    fn matchCmpInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const reg = chunk.read(offset + 1);
        const kind = chunk.read(offset + 2);
        const arg = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        try writer.print("{s} r{} == ", .{ @tagName(self), reg });
        switch (@as(MatchCmpKind, @enumFromInt(kind))) {
            .constant => {
                var constant = module.getConstant(arg);
                try constant.print(vm, writer);
            },
            .slot => try writer.print("l{}", .{arg}),
            .reg => try writer.print("r{}", .{arg}),
        }
        try writer.print("\n", .{});
        return offset + 5;
    }

    fn matchTypeInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const ty: []const u8 = switch (chunk.read(offset + 2)) {
            0 => "array",
            1 => "object",
            2 => "string",
            3 => "num_or_codepoint",
            else => "unknown",
        };
        try writer.print("{s} r{} {s}\n", .{ @tagName(self), register, ty });
        return offset + 3;
    }

    fn matchCountInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const count = chunk.read(offset + 2);
        const mode = chunk.read(offset + 3);
        const cmp: []const u8 = if (mode != 0) ">=" else "==";
        try writer.print("{s} r{} {s}{}\n", .{ @tagName(self), register, cmp, count });
        return offset + 4;
    }

    fn matchEvalInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        try writer.print("{s} r{}\n", .{ @tagName(self), register });
        return offset + 3;
    }

    fn matchSubtractEvalInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        try writer.print("{s} r{} <- r{} - <pop>\n", .{ @tagName(self), dst, src });
        return offset + 3;
    }

    fn matchDivideEvalInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        try writer.print("{s} r{} <- r{} / <pop>\n", .{ @tagName(self), dst, src });
        return offset + 3;
    }

    fn matchRepeatInitInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const len = chunk.read(offset + 2);
        const count_dst = chunk.read(offset + 3);
        const base = chunk.read(offset + 4);
        try writer.print("{s} r{} /{} n=r{} base=r{}\n", .{ @tagName(self), src, len, count_dst, base });
        return offset + 5;
    }

    fn matchRepeatNextInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const base = chunk.read(offset + 2);
        const len = chunk.read(offset + 3);
        const chunk_dst = chunk.read(offset + 4);
        const jump = (@as(u16, @intCast(chunk.read(offset + 5))) << 8) | chunk.read(offset + 6);
        const target = offset + 7 + jump;
        try writer.print("{s} r{} base=r{}+{} chunk=r{} done->{}\n", .{ @tagName(self), src, base, len, chunk_dst, target });
        return offset + 7;
    }

    fn matchRepeatInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const dst = chunk.read(offset + 2);
        try writer.print("{s} r{} r{}\n", .{ @tagName(self), src, dst });
        return offset + 3;
    }

    fn matchRepeatRangeInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const src = chunk.read(offset + 1);
        const dst = chunk.read(offset + 2);
        const lower_kind = chunk.read(offset + 3);
        const lower_arg = (@as(u16, @intCast(chunk.read(offset + 4))) << 8) | chunk.read(offset + 5);
        const upper_kind = chunk.read(offset + 6);
        const upper_arg = (@as(u16, @intCast(chunk.read(offset + 7))) << 8) | chunk.read(offset + 8);
        try writer.print("{s} r{} r{} ", .{ @tagName(self), src, dst });
        try printRangeLimit(vm, module, writer, lower_kind, lower_arg);
        try writer.writeAll("..");
        try printRangeLimit(vm, module, writer, upper_kind, upper_arg);
        try writer.print("\n", .{});
        return offset + 9;
    }

    fn matchBoundInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const reg = chunk.read(offset + 1);
        const is_upper = chunk.read(offset + 2) != 0;
        const kind = chunk.read(offset + 3);
        const arg = (@as(u16, @intCast(chunk.read(offset + 4))) << 8) | chunk.read(offset + 5);
        try writer.print("{s} r{} {s} ", .{ @tagName(self), reg, if (is_upper) "hi" else "lo" });
        try printRangeLimit(vm, module, writer, kind, arg);
        try writer.print("\n", .{});
        return offset + 6;
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
        try writer.print("{s} r{} {s}\n", .{ @tagName(self), slot, if (is_upper) "hi" else "lo" });
        return offset + 3;
    }

    fn matchStrEndInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const register = chunk.read(offset + 1);
        const back = chunk.read(offset + 2) != 0;
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} {s} ", .{ @tagName(self), register, if (back) "suffix" else "prefix" });
        try constant.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 5;
    }

    fn matchKeyInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{}[", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        try writer.print("]\n", .{});
        return offset + 5;
    }

    fn matchMergeBoolInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{} claim ", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        try writer.print("\n", .{});
        return offset + 5;
    }

    fn matchMergeNumInstruction(self: OpCode, chunk: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        const dst = chunk.read(offset + 1);
        const src = chunk.read(offset + 2);
        const constant_idx = (@as(u16, @intCast(chunk.read(offset + 3))) << 8) | chunk.read(offset + 4);
        const negate = chunk.read(offset + 5) != 0;
        var constant = module.getConstant(constant_idx);
        try writer.print("{s} r{} r{} - ", .{ @tagName(self), dst, src });
        try constant.print(vm, writer);
        if (negate) try writer.writeAll(" neg");
        try writer.print("\n", .{});
        return offset + 6;
    }

    fn matchWindowEnterInstruction(self: OpCode, chunk: *Chunk, writer: *Writer, offset: usize) !usize {
        const width = chunk.read(offset + 1);
        const jump = (@as(u16, @intCast(chunk.read(offset + 2))) << 8) | chunk.read(offset + 3);
        const target = offset + 4 + jump;
        try writer.print("{s} {} fail->{}\n", .{ @tagName(self), width, target });
        return offset + 4;
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

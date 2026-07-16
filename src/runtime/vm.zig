const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const assert = std.debug.assert;
const unicode = std.unicode;
const Writer = std.Io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const Compiler = @import("../backend.zig").Compiler;
const Elem = @import("elem.zig").Elem;
const Env = @import("../env.zig").Env;
const GC = @import("gc.zig").GC;
const match_plan = @import("match_plan.zig");
const MatchPlan = match_plan.MatchPlan;
const match_plan_interpreter = @import("match_plan_interpreter.zig");
const Module = @import("module.zig").Module;
const ModuleLoader = @import("module_loader.zig").ModuleLoader;
const OpCode = @import("op_code.zig").OpCode;
const StringTable = @import("string_table.zig").RuntimeStringTable;
const Region = @import("../region.zig").Region;
const LineRelativeRegion = @import("../region.zig").LineRelativeRegion;
const hl = @import("../highlight.zig");
const explain = @import("explain.zig");
const Writers = @import("../writer.zig").Writers;
const parsing = @import("../parsing.zig");

const max_codepoint: u21 = 0x10FFFF;

pub const Config = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
    printCompiledBytecode: bool = false,
    printExecutedBytecode: bool = false,
    printVM: bool = false,
    printDestructure: bool = false,
    print_gc: bool = false,
    runVM: bool = true,
    includeStdlib: bool = true,
    gc_mode: GC.Mode = .GC,
    // Uniqueness fast paths mutate unique values in place at Merge and
    // Insert sites. Disabling forces the copy paths everywhere, so any
    // behavioral diff can be bisected to refcounting in one run.
    rc_fast_paths: bool = true,
    print_memory_report: bool = false,
    // Record call/return/destructure events for the --explain report.
    explain: bool = false,

    pub fn setEnv(self: *Config, env: Env) void {
        self.printScanner = env.printScanner;
        self.printParser = env.printParser;
        self.printAst = env.printAst;
        self.printCompiledBytecode = env.printCompiledBytecode;
        self.printExecutedBytecode = env.printExecutedBytecode;
        self.printVM = env.printVM;
        self.printDestructure = env.printDestructure;
        self.print_gc = env.printGC;
        self.runVM = env.runVM;
        self.gc_mode = if (env.stressTestGC) .StressTest else .GC;
        self.rc_fast_paths = !env.disableRcFastPaths;
        self.print_memory_report = env.printMemoryReport;
    }
};

// A materialized input position. The VM tracks only a byte offset while
// parsing; line data is derived on demand by materializePos, so the hot
// parse loops never scan for newlines.
pub const Pos = struct {
    offset: usize = 0,
    line: usize = 1,
    line_start: usize = 0,

    pub fn lineOffset(self: Pos) usize {
        return self.offset - self.line_start;
    }
};

// Snapshot of the failure that reached farthest into the input. Plain ids
// and values only — the record outlives backtracking and GC, so it must
// not hold anything that can dangle.
pub const FarthestFailure = struct {
    offset: usize,
    region: Region,
    function_name: StringTable.Id,
    module_id: Module.Id,
    kind: Kind,
    value_snapshot: [value_snapshot_capacity]u8,
    value_snapshot_len: u8,
    value_truncated: bool,

    pub const Kind = enum { input_mismatch, pattern_mismatch };
    pub const value_snapshot_capacity = 64;

    pub fn valueSnapshot(self: *const FarthestFailure) []const u8 {
        return self.value_snapshot[0..self.value_snapshot_len];
    }
};

// Every distinct grammar site that failed at the farthest position. A
// strict advance restarts the set at the new site; a tie appends. Fixed
// capacity for the same reason FarthestFailure is plain values: recording
// happens on the failure path and may not allocate.
pub const ExpectedSet = struct {
    entries: [capacity]Entry,
    len: u8,
    truncated: bool,

    pub const capacity = 32;

    pub const Entry = struct {
        region: Region,
        function_name: StringTable.Id,
        module_id: Module.Id,
    };

    pub const empty = ExpectedSet{
        .entries = undefined,
        .len = 0,
        .truncated = false,
    };

    fn reset(self: *ExpectedSet, entry: Entry) void {
        self.entries[0] = entry;
        self.len = 1;
        self.truncated = false;
    }

    fn append(self: *ExpectedSet, entry: Entry) void {
        for (self.entries[0..self.len]) |existing| {
            if (existing.module_id == entry.module_id and
                existing.region.start == entry.region.start and
                existing.region.end == entry.region.end) return;
        }
        if (self.len == capacity) {
            self.truncated = true;
            return;
        }
        self.entries[self.len] = entry;
        self.len += 1;
    }

    pub fn slice(self: *const ExpectedSet) []const Entry {
        return self.entries[0..self.len];
    }
};

// Print the source text of a region on one line for a report headline,
// clipped at the first newline or excerpt_max_len bytes.
fn printSourceExcerpt(source: []const u8, region: Region, writer: *Writer) !void {
    const excerpt_max_len = 40;

    const start = @min(region.start, source.len);
    var end = @min(region.end, source.len);
    var clipped = false;

    if (std.mem.indexOfScalar(u8, source[start..end], '\n')) |nl| {
        end = start + nl;
        clipped = true;
    }
    if (end - start > excerpt_max_len) {
        end = start + excerpt_max_len;
        while (end > start and source[end - 1] & 0xC0 == 0x80) end -= 1;
        if (end > start and source[end - 1] >= 0xC0) end -= 1;
        clipped = true;
    }

    try writer.print("{s}", .{source[start..end]});
    if (clipped) try writer.print("…", .{});
}

// How often the uniqueness fast paths fired. Counted only at the decision
// points: container merges with a Dyn lhs, string merges with a Dyn
// operand on either side, and the Insert opcodes. Pure value-type merges
// are not counted. A fresh rope referencing a shared Dyn operand counts
// as a copy: no existing value was mutated, even though no bytes were
// copied. The husk counters track the pools: parked at a consuming
// release of a last handle, reused at a create served from a pool.
pub const RcStats = struct {
    merge_in_place: u64 = 0,
    merge_copy: u64 = 0,
    insert_in_place: u64 = 0,
    insert_copy: u64 = 0,
    husks_parked: u64 = 0,
    husks_reused: u64 = 0,
};

pub const VM = struct {
    allocator: Allocator,
    gc: GC,
    strings: StringTable,
    modules: ArrayList(*Module),
    loader: ModuleLoader,
    compiler: ?*const Compiler,
    stack: ArrayList(Elem),
    frames: ArrayList(CallFrame),
    cur_frame: *CallFrame,
    cur_code: []const u8,
    temp_dyns: ArrayList(*Elem.DynElem),
    input: []const u8,
    inputMarks: ArrayList(usize),
    inputOffset: usize,
    farthest: ?FarthestFailure,
    expected: ExpectedSet,
    explain_events: ArrayList(explain.Event),
    uniqueIdCount: u64,
    rc_stats: RcStats,
    // Scratch state for the match plan interpreter, base/shrink managed per
    // merge so nested matches (VM re-entry, nested merges) compose.
    plan_merge_parts: ArrayList(match_plan.ResolvedPart),
    plan_matched_keys: ArrayList(StringTable.Id),
    // Match-step indentation for the plan interpreter under the debug print
    // modes, mirroring PatternSolver.depth. Saved and restored across the
    // nested VM executions a pattern function triggers.
    plan_debug_depth: u8,
    writers: Writers,
    config: Config,
    singleton_empty_array: ?Elem,
    singleton_empty_object: ?Elem,
    singleton_empty_string: Elem,
    singleton_underscore_var: Elem,
    singleton_neg_one: Elem,
    singleton_zero: Elem,
    singleton_one: Elem,
    singleton_two: Elem,
    singleton_three: Elem,
    // Last materialized position; materializePos scans from here so
    // repeated line queries are incremental. Valid for the current input.
    // Cold: read only when line info is reported, never while parsing.
    pos_memo: Pos,

    const CallFrame = struct {
        function: *Elem.DynElem.Function,
        ip: usize,
        elemsOffset: usize,
    };

    pub const Error = error{
        RuntimeError,
        OutOfMemory,
        Utf8ExpectedContinuation,
        Utf8OverlongEncoding,
        Utf8EncodesSurrogateHalf,
        CodepointTooLarge,
        Utf8CannotEncodeSurrogateHalf,
        InvalidRange,
        NoMainParser,
        IntegerOverflow,
        Overflow,
        ExpectedNumber,
        Utf8CodepointTooLarge,
    } || Writer.Error;

    pub fn create() VM {
        const self = VM{
            .allocator = undefined,
            .gc = undefined,
            .strings = undefined,
            .modules = undefined,
            .loader = undefined,
            .compiler = undefined,
            .stack = undefined,
            .frames = undefined,
            .cur_frame = undefined,
            .cur_code = undefined,
            .temp_dyns = undefined,
            .input = undefined,
            .inputMarks = undefined,
            .inputOffset = undefined,
            .farthest = null,
            .expected = ExpectedSet.empty,
            .explain_events = undefined,
            .uniqueIdCount = undefined,
            .rc_stats = undefined,
            .plan_merge_parts = undefined,
            .plan_matched_keys = undefined,
            .plan_debug_depth = undefined,
            .writers = undefined,
            .config = undefined,
            .singleton_empty_array = null,
            .singleton_empty_object = null,
            .singleton_empty_string = undefined,
            .singleton_underscore_var = undefined,
            .singleton_neg_one = undefined,
            .singleton_zero = undefined,
            .singleton_one = undefined,
            .singleton_two = undefined,
            .singleton_three = undefined,
            .pos_memo = undefined,
        };

        return self;
    }

    pub fn init(self: *VM, allocator: Allocator, writers: Writers, config: Config) !void {
        self.config = config;
        self.writers = writers;
        self.allocator = allocator;
        self.gc = GC.init(self, allocator);
        self.strings = StringTable.init(allocator);
        self.modules = ArrayList(*Module){};
        self.loader = ModuleLoader.init(self, allocator);
        self.compiler = null;
        self.stack = ArrayList(Elem){};
        self.frames = ArrayList(CallFrame){};
        self.cur_frame = undefined;
        self.cur_code = undefined;
        self.temp_dyns = ArrayList(*Elem.DynElem){};
        self.input = undefined;
        self.inputMarks = ArrayList(usize){};
        self.inputOffset = 0;
        self.pos_memo = Pos{};
        self.farthest = null;
        self.expected = ExpectedSet.empty;
        self.explain_events = ArrayList(explain.Event){};
        self.uniqueIdCount = 0;
        self.rc_stats = RcStats{};
        self.plan_merge_parts = ArrayList(match_plan.ResolvedPart){};
        self.plan_matched_keys = ArrayList(StringTable.Id){};
        self.plan_debug_depth = 0;
        self.singleton_empty_array = null;
        self.singleton_empty_object = null;
        self.singleton_empty_string = Elem.string(try self.strings.insert(""));
        self.singleton_underscore_var = Elem.valueVar(try self.strings.insert("_"), true);
        self.singleton_neg_one = try Elem.numberStringFromBytes("-1", self);
        self.singleton_zero = try Elem.numberStringFromBytes("0", self);
        self.singleton_one = try Elem.numberStringFromBytes("1", self);
        self.singleton_two = try Elem.numberStringFromBytes("2", self);
        self.singleton_three = try Elem.numberStringFromBytes("3", self);
        errdefer self.deinit();
    }

    pub fn deinit(self: *VM) void {
        self.gc.deinit();
        self.strings.deinit();
        for (self.modules.items) |module| {
            module.deinit(self.allocator);
            self.allocator.destroy(module);
        }
        self.modules.deinit(self.allocator);
        self.loader.deinit();
        self.stack.deinit(self.allocator);
        self.frames.deinit(self.allocator);
        self.temp_dyns.deinit(self.allocator);
        self.inputMarks.deinit(self.allocator);
        self.explain_events.deinit(self.allocator);
        self.plan_merge_parts.deinit(self.allocator);
        self.plan_matched_keys.deinit(self.allocator);
    }

    pub fn interpret(self: *VM, module_name: []const u8, source: []const u8, input: []const u8) !Elem {
        if (input.len > std.math.maxInt(u32)) return error.InputTooLong;

        self.input = input;
        self.pos_memo = Pos{};
        self.farthest = null;
        self.expected = ExpectedSet.empty;
        try self.compile(module_name, source);
        try self.run();
        assert(self.stack.items.len == 1);

        // Prevent GC
        return self.peek(0);
    }

    pub fn compile(self: *VM, module_name: []const u8, source: []const u8) !void {
        const builtin_module = try self.createModule("builtins", "");

        var maybe_stdlib_module: ?Module = null;
        if (self.config.includeStdlib) {
            const filename = "stdlib/core.possum";
            const stdlib_module = try self.createModule(
                filename,
                @embedFile(filename),
            );
            maybe_stdlib_module = stdlib_module.*;
        }

        const main_module = try self.createModule(module_name, source);

        var compiler = try Compiler.init(self);
        defer compiler.deinit();

        try compiler.addBuiltinsModule(builtin_module.*);

        // The implicit dumps are registered before the target module is
        // added so that every import written in the program shadows them.
        try compiler.addModuleDump(main_module.id, builtin_module.id);
        if (maybe_stdlib_module) |stdlib_module| {
            try compiler.addModule(stdlib_module, .{});
            try compiler.addModuleDump(stdlib_module.id, builtin_module.id);
            try compiler.addModuleDump(main_module.id, stdlib_module.id);
        }

        try compiler.addTargetModule(main_module.*, .{
            .printScanner = self.config.printScanner,
            .printParser = self.config.printParser,
            .printAst = self.config.printAst,
        });

        self.compiler = &compiler;
        defer self.compiler = null;

        try compiler.compile();

        if (compiler.main) |main| {
            try self.push(main.dyn.elem());
            if (self.config.explain) {
                try self.explain_events.append(self.allocator, .{ .call = .{
                    .function_name = main.name,
                    .module_id = main.mid,
                    .offset = self.inputOffset,
                    .is_tail = false,
                } });
            }
            try self.pushFrame(main);
        }
    }

    pub fn createModule(self: *VM, name: []const u8, source: []const u8) !*Module {
        const new_id = self.modules.items.len;
        if (new_id > std.math.maxInt(u16)) {
            @panic("todo");
        }

        const module = try self.allocator.create(Module);
        module.* = Module{
            .id = @intCast(new_id),
            .name = name,
            .source = source,
        };
        try self.modules.append(self.allocator, module);
        return module;
    }

    pub fn getModule(self: VM, mid: Module.Id) *Module {
        return self.modules.items[mid];
    }

    // Import paths resolve only to already-created modules until the module
    // loader lands.
    pub fn findModule(self: VM, name: []const u8) ?*Module {
        for (self.modules.items) |module| {
            if (std.mem.eql(u8, module.name, name)) return module;
        }
        return null;
    }

    pub fn currentFunctionModule(self: *VM) *Module {
        return self.getModule(self.cur_frame.function.mid);
    }

    pub fn run(self: *VM) !void {
        if (self.frames.items.len == 0) {
            return Error.NoMainParser;
        }

        if (self.config.printExecutedBytecode) {
            try self.cur_frame.function.disassemble(self.*, self.writers.debug);
        }

        while (true) {
            if (self.config.printVM) try self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
            if (self.frames.items.len == 0) break;
        }

        if (self.config.printVM) try self.printDebug();
    }

    pub fn runFunction(self: *VM) Error!void {
        if (self.frames.items.len == 0) {
            return Error.NoMainParser;
        }

        const initialFrameCount = self.frames.items.len;

        // Run until we return to the previous frame level (or have no frames left)
        while (self.frames.items.len >= initialFrameCount and self.frames.items.len > 0) {
            if (self.config.printVM) try self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
        }

        if (self.config.printVM) try self.printDebug();
    }

    inline fn runOp(self: *VM, opCode: OpCode) !void {
        switch (opCode) {
            .AssertFunctionArity => {
                const expected_arity = self.readByte();
                const function_elem = self.peek(0);
                if (function_elem.isDynType(.Function)) {
                    const function = function_elem.asDyn().asFunction();
                    if (function.arity != expected_arity) {
                        return self.runtimeError("Expected {} arguments but got {}.", .{ function.arity, expected_arity });
                    }
                } else {
                    return self.runtimeError("Expected function.", .{});
                }
            },
            .AssertParamTypes => {
                const expected_types = self.readByte();
                const function_elem = self.peek(0);
                if (function_elem.isDynType(.Function)) {
                    const function = function_elem.asDyn().asFunction();
                    const actual_types = @as(u8, @intCast(function.param_types.bitset & 0x7F));
                    if (actual_types != expected_types) {
                        return self.runtimeError("Function parameter types do not match expected types.", .{});
                    }
                } else {
                    return self.runtimeError("Expected function.", .{});
                }
            },
            .AssertParamTypes4 => {
                const expected_types = self.readLong();
                const function_elem = self.peek(0);
                if (function_elem.isDynType(.Function)) {
                    const function = function_elem.asDyn().asFunction();
                    if (function.param_types.bitset != expected_types) {
                        return self.runtimeError("Function parameter types do not match expected types.", .{});
                    }
                } else {
                    return self.runtimeError("Expected function.", .{});
                }
            },
            .CallFunction => {
                // Postfix, function and args on stack.
                // Create new stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callFunction(self.peek(argCount), argCount, false);
            },
            .CallFunctionConstant, .CallFunctionConstant2, .CallFunctionConstant3 => {
                const idx = self.readIndex(opCode);
                try self.push(self.getConstant(idx));
                try self.callFunction(self.peek(0), 0, false);
            },
            .CallTailFunction => {
                // Postfix, function and args on stack.
                // Reuse stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callFunction(self.peek(argCount), argCount, true);
            },
            .CallTailFunctionConstant, .CallTailFunctionConstant2, .CallTailFunctionConstant3 => {
                const idx = self.readIndex(opCode);
                try self.push(self.getConstant(idx));
                try self.callFunction(self.peek(0), 0, true);
            },
            .CallFunctionLocal => {
                const slot = self.readByte();
                const local = try self.getBoundLocal(slot);
                try self.pushDerived(.CallFunctionLocal, local);
                try self.callFunction(self.peek(0), 0, false);
            },
            .CallTailFunctionLocal => {
                const slot = self.readByte();
                const local = try self.getBoundLocal(slot);
                try self.pushDerived(.CallTailFunctionLocal, local);
                try self.callFunction(self.peek(0), 0, true);
            },
            .CaptureLocal => {
                // Capture a local variable into a closure.
                // Assumes top of stack is a Closure
                // Fills the next available null slot
                const fromSlot = self.readByte();
                const elem = self.peek(0);

                std.debug.assert(elem.isDynType(.Closure));
                var closure = elem.asDyn().asClosure();

                // Find first null slot
                var toSlot: usize = 0;
                while (toSlot < closure.captures.len) : (toSlot += 1) {
                    if (closure.captures[toSlot] == null) {
                        break;
                    }
                }
                std.debug.assert(toSlot < closure.captures.len);

                closure.capture(toSlot, self.getLocal(fromSlot));
            },
            .ConditionalThen => {
                // The `?` part of `condition ? then : else`
                // Infix, `condition` on stack.
                // If `condition` succeeded then continue to `then` branch.
                // If `condition` failed then jump to the start of `else` branch.
                const offset = self.readShort();
                const resetPos = self.popInputMark();
                const condition = self.popConsumed(.ConditionalThen);
                if (condition.isFailure()) {
                    self.inputOffset = resetPos;
                    self.cur_frame.ip += offset;
                }
            },
            .CreateClosure => {
                // Wraps a Function in a Closure with N capture slots.
                // Takes the local count as operand.
                const localCount = self.readByte();
                try self.pushClosure(localCount);
            },
            .Crash => {
                if (self.peekIsSuccess()) {
                    const value = self.peek(0);

                    const str = try value.toString(self);
                    const message = (try str.stringBytes(self)).?;
                    return self.runtimeError("{s}", .{message});
                } else {
                    return self.runtimeError("Crashed with no error message", .{});
                }
            },
            .Decrement => {
                const elem = self.peek(0);
                if (try elem.merge(Elem.numberFloat(-1), self)) |decremented| {
                    self.drop(1);
                    try self.push(decremented);
                } else {
                    @panic("Internal Error");
                }
            },
            .DestructurePlan, .DestructurePlan2, .DestructurePlan3 => {
                const planIdx = self.readIndex(opCode);
                const plan = self.getMatchPlan(planIdx);
                const value = self.peek(0);

                // Same criterion as Destructure: on these paths the value's
                // stack handle dies unobserved, so an object rest may take
                // over a uniquely-referenced value in place.
                const next_op: OpCode = @enumFromInt(self.cur_code[self.cur_frame.ip]);
                const value_discarded = next_op == .ConditionalThen or next_op == .TakeRight;

                const trace_match = self.config.explain and value.isSuccess();
                if (trace_match) {
                    try self.emitExplainDestructureBegin(value, match_plan.SubtreePrintable{ .plan = &plan, .idx = 0 });
                }

                const matched = value.isSuccess() and
                    (try match_plan_interpreter.match(self, value, plan, value_discarded));

                if (trace_match) {
                    try self.emitExplainDestructureEnd(!matched);
                }

                if (matched) {
                    // value is already on the stack
                } else {
                    if (value.isSuccess()) self.recordPatternFailure(value);
                    // RC semantics are the same for all destructure ops
                    _ = self.popConsumed(.DestructurePlan);
                    try self.pushFailure();
                }
            },
            .Drop => {
                _ = self.popConsumed(.Drop);
            },
            .End => {
                // End of function cleanup. Remove everything from the stack
                // frame except the final function result.
                const prevFrame = self.popFrame();
                const result = self.pop();

                if (self.config.explain) {
                    try self.emitExplainRet(result.isFailure());
                }

                // Every truncated handle dies: the function elem, locals
                // (already nulled where a move transferred them out), and
                // any operand leftovers. The result handle transfers to
                // the caller's stack.
                for (self.stack.items[prevFrame.elemsOffset..]) |item| {
                    self.reclaimElem(item);
                }

                try self.stack.resize(self.allocator, prevFrame.elemsOffset);
                try self.pushTransferred(.End, result);
            },
            .PushFail => {
                // Push singleton failure value.
                try self.pushFailure();
            },
            .PushFalse => {
                // Push singleton false value.
                try self.push(Elem.boolean(false));
            },
            .GetLocal => {
                const slot = self.readByte();
                const local = try self.getBoundLocal(slot);
                try self.pushDerived(.GetLocal, local);
            },
            .SetLocal => {
                // The popped handle moves into the slot; the slot's previous
                // handle dies.
                const slot = self.readByte();
                const previous = self.getLocal(slot);
                self.setLocal(slot, self.pop());
                previous.release();
            },
            .GetLocalMove => {
                // Emitted at the slot's last read on every path: the
                // slot's handle transfers to the stack without an
                // increment. The slot is nulled so End's frame release
                // doesn't count the stale handle a second time.
                const slot = self.readByte();
                const local = try self.getBoundLocal(slot);
                self.setLocal(slot, self.singleton_underscore_var);
                try self.pushTransferred(.GetLocalMove, local);
            },
            .Increment => {
                const elem = self.peek(0);
                if (try elem.merge(Elem.numberFloat(1), self)) |decremented| {
                    self.drop(1);
                    try self.push(decremented);
                } else {
                    @panic("Internal Error");
                }
            },
            .InsertAtIndex => {
                const index = self.readByte();
                const elem = self.peek(0);
                const array_elem = self.peek(1);

                if (elem.isFailure() or array_elem.isFailure()) {
                    _ = self.popConsumed(.InsertAtIndex);
                    _ = self.popConsumed(.InsertAtIndex);
                    try self.pushFailure();
                } else {
                    const array = array_elem.asDyn().asArray();

                    if (self.config.rc_fast_paths and array.dyn.isUnique()) {
                        self.rc_stats.insert_in_place += 1;
                        elem.retain();
                        array.elems.items[index].release();
                        array.elems.items[index] = elem;
                        self.releaseConsumed(.InsertAtIndex, elem, array_elem);
                        self.drop(2);
                        try self.pushFreshOrTransferred(.InsertAtIndex, array_elem);
                    } else {
                        self.rc_stats.insert_copy += 1;
                        var copy = try Elem.DynElem.Array.copy(self, array.elems.items);
                        elem.retain();
                        copy.elems.items[index].release();
                        copy.elems.items[index] = elem;

                        const result = copy.dyn.elem();
                        self.releaseConsumed(.InsertAtIndex, elem, result);
                        self.releaseConsumed(.InsertAtIndex, array_elem, result);
                        self.drop(2);
                        try self.pushFreshOrTransferred(.InsertAtIndex, result);
                    }
                }
            },
            .InsertKeyVal => {
                const placeholder_key = self.readByte();
                const val = self.peek(0);
                const key_elem = self.peek(1);
                const object_elem = self.peek(2);

                const placeholder_key_sid = StringTable.reservedSid(placeholder_key);

                if (val.isFailure() or key_elem.isFailure() or object_elem.isFailure()) {
                    _ = self.popConsumed(.InsertKeyVal);
                    _ = self.popConsumed(.InsertKeyVal);
                    _ = self.popConsumed(.InsertKeyVal);
                    try self.pushFailure();
                } else {
                    const object = object_elem.asDyn().asObject();
                    var key_sid: StringTable.Id = undefined;

                    if (try Elem.getOrPutSid(key_elem, self)) |sid| {
                        key_sid = sid;
                    } else {
                        return self.runtimeError("Insert key error: Object key must be a string", .{});
                    }

                    const placeholder_index = object.members.getIndex(placeholder_key_sid).?;
                    const calculated_index = object.members.getIndex(key_sid);

                    const in_place = self.config.rc_fast_paths and object.dyn.isUnique();
                    if (in_place) {
                        self.rc_stats.insert_in_place += 1;
                    } else {
                        self.rc_stats.insert_copy += 1;
                    }
                    const target = if (in_place)
                        object
                    else copy: {
                        const copy = try Elem.DynElem.Object.copy(self, object);
                        try self.pushTempDyn(&copy.dyn);
                        break :copy copy;
                    };
                    defer if (target != object) self.dropTempDyn();

                    if (calculated_index) |existing_key_index| {
                        if (existing_key_index < placeholder_index) {
                            // Key was already inserted, but before this new
                            // insertion. Replace both the placeholder and
                            // existing with the new pair, leaving the new pair
                            // in the placeholder position.
                            if (target.members.fetchOrderedRemove(key_sid)) |kv| kv.value.release();
                            try target.put(self, key_sid, val);
                            if (target.members.fetchSwapRemove(placeholder_key_sid)) |kv| kv.value.release();
                        } else {
                            // This key was inserted after the placeholder.
                            // Delete the placeholder and keep the existing
                            // key.
                            if (target.members.fetchOrderedRemove(placeholder_key_sid)) |kv| kv.value.release();
                        }
                    } else {
                        try target.put(self, key_sid, val);
                        if (target.members.fetchSwapRemove(placeholder_key_sid)) |kv| kv.value.release();
                    }

                    const result = target.dyn.elem();
                    self.releaseConsumed(.InsertKeyVal, val, result);
                    self.releaseConsumed(.InsertKeyVal, key_elem, result);
                    self.releaseConsumed(.InsertKeyVal, object_elem, result);
                    self.drop(3);
                    try self.pushFreshOrTransferred(.InsertKeyVal, result);
                }
            },
            .Jump => {
                const offset = self.readShort();
                self.cur_frame.ip += offset;
            },
            .JumpBack => {
                const offset = self.readShort();
                self.cur_frame.ip -= offset;
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekIsFailure()) self.cur_frame.ip += offset;
            },
            .JumpIfZero => {
                const offset = self.readShort();
                const elem = self.peek(0);
                if (elem.isEql(Elem.numberFloat(0), self.*)) {
                    self.cur_frame.ip += offset;
                }
            },
            .GetConstant, .GetConstant2, .GetConstant3 => {
                const idx = self.readIndex(opCode);
                try self.push(self.getConstant(idx));
            },
            .GetConstantMutable, .GetConstantMutable2, .GetConstantMutable3 => {
                const idx = self.readIndex(opCode);
                try self.pushMutableConstant(idx);
            },
            .SetClosureCaptures => {
                var function = self.getFunctionElem().asDyn();

                if (function.isType(.Closure)) {
                    const closure = function.asClosure();
                    for (closure.captures, 0..) |capture, slot| {
                        if (capture) |elem| {
                            elem.retain();
                            self.setLocal(slot, elem);
                        }
                    }
                }
            },
            .SetInputMark => {
                try self.pushInputMark();
            },
            .Swap => {
                const a = self.pop();
                const b = self.pop();
                try self.push(a);
                try self.push(b);
            },
            .ValidateRepeatPattern => {
                // Validate that top of stack is a valid repeat count (non-negative integer)
                const elem = self.peek(0);

                var valid = false;
                if (elem.isFloat()) {
                    const f = elem.asFloat();
                    valid = @trunc(f) == f and f >= 0 and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)));
                } else if (elem.isType(.NumberString)) {
                    const floatVal = elem.asNumberString().toNumberFloat(self.strings);
                    const f = floatVal.asFloat();
                    valid = @trunc(f) == f and f >= 0 and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)));
                }

                if (!valid) {
                    return self.runtimeError("Invalid repeat pattern", .{});
                }
            },
            .Merge => {
                const rhs = self.peek(0);
                const lhs = self.peek(1);

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    self.releaseConsumed(.Merge, lhs, value);
                    self.releaseConsumed(.Merge, rhs, value);
                    self.drop(2);
                    try self.pushFreshOrTransferred(.Merge, value);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .MergeAsString => {
                const rhs = self.peek(0);
                const lhs = self.peek(1);

                if (lhs.isSuccess() and rhs.isSuccess()) {
                    // Prevent GC if rhs/lhs is a non-string type that gets
                    // converted to a `DynElem.String` representation.
                    const lstr = try lhs.toString(self);
                    if (lstr.isType(.Dyn)) try self.pushTempDyn(lstr.asDyn());
                    defer if (lstr.isType(.Dyn)) self.dropTempDyn();

                    const rstr = try rhs.toString(self);
                    if (rstr.isType(.Dyn)) try self.pushTempDyn(rstr.asDyn());
                    defer if (rstr.isType(.Dyn)) self.dropTempDyn();

                    const merged = (try lstr.merge(rstr, self)).?;

                    self.releaseConsumed(.MergeAsString, lhs, merged);
                    self.releaseConsumed(.MergeAsString, rhs, merged);
                    self.drop(2);
                    try self.pushFreshOrTransferred(.MergeAsString, merged);
                } else {
                    self.releaseConsumed(.MergeAsString, lhs, Elem.failureConst);
                    self.releaseConsumed(.MergeAsString, rhs, Elem.failureConst);
                    self.drop(2);
                    try self.push(Elem.failureConst);
                }
            },
            .NativeCode => {
                const idx = self.readByte();
                const elem = self.getConstant(idx);

                if (elem.isDynType(.NativeCode)) {
                    const nc = elem.asDyn().asNativeCode();
                    try nc.handle(self);
                } else {
                    @panic("Internal Error");
                }
            },
            .NegateNumber => {
                const num = self.peek(0);

                const value = Elem.negateNumber(num) catch |err| switch (err) {
                    error.ExpectedNumber => return self.runtimeError("Negation and subtraction is only supported for numbers.", .{}),
                };

                self.drop(1);
                try self.push(value);
            },
            .NegateParser => {
                const num = self.peek(0);

                switch (num.getType()) {
                    .NumberString => {
                        const ns = num.asNumberString();
                        if (ns.negated) {
                            return self.runtimeError("Number parser can't be negated twice.", .{});
                        }
                    },
                    .NumberFloat => {
                        const f = num.asFloat();
                        if (f < 0) {
                            return self.runtimeError("Number parser can't be negated twice.", .{});
                        }
                    },
                    else => return self.runtimeError("Negation is only supported for numbers.", .{}),
                }

                const negated = num.negateNumber() catch @panic("Internal Error");
                self.drop(1);
                try self.push(negated);
            },
            .PushNull => {
                // Push singleton null value.
                try self.push(Elem.nullConst);
            },
            .Or => {
                // Infix, lhs on stack.
                // If lhs succeeded then jump to skip rhs ops.
                // If lhs failed then pop, return to prev input position.
                const offset = self.readShort();
                const resetPos = self.popInputMark();
                if (self.peekIsSuccess()) {
                    self.cur_frame.ip += offset;
                } else {
                    _ = self.popConsumed(.Or);
                    self.inputOffset = resetPos;
                }
            },
            .ParseNumberStringChar => {
                const char = self.readByte();
                try self.parseNumberStringCharacter(char);
            },
            .ParseChar => {
                const char = self.readByte();
                try self.parseCharacter(char);
            },
            .ParseCodepoint => {
                const start = self.inputOffset;

                if (start < self.input.len) {
                    const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
                    const end = start + bytes_length;

                    self.inputOffset = end;
                    try self.pushInputSubstring(start, end);
                } else {
                    try self.pushFailure();
                }
            },
            .ParseCodepointRange => {
                const low_codepoint = self.readByte();
                const high_codepoint = self.readByte();

                try self.parseCodepointRange(@as(u21, @intCast(low_codepoint)), @as(u21, @intCast(high_codepoint)));
            },
            .ParseIntegerRange => {
                const low_int = self.readByte();
                const high_int = self.readByte();
                try self.parseIntegerRange(@as(i64, @intCast(low_int)), @as(i64, @intCast(high_int)));
            },
            .ParseLowerBoundedRange => {
                const low_elem = self.peek(0);

                if (low_elem.isType(.String)) {
                    const bytes = self.strings.get(low_elem.asString());

                    if (parsing.utf8Decode(bytes)) |codepoint| {
                        self.drop(1);
                        try self.parseCodepointRange(codepoint, max_codepoint);
                    } else {
                        return self.runtimeError("Range parser lower bound string must be a single valid codepoint", .{});
                    }
                } else if (low_elem.isInteger(self.strings)) {
                    self.drop(1);
                    const low = try low_elem.asInteger(self.strings);
                    try self.parseIntegerLowerBounded(low);
                } else {
                    return self.runtimeError("Range parser lower bound must be a codepoint or integer", .{});
                }
            },
            .ParseRange => {
                const low_elem = self.peek(1);
                const high_elem = self.peek(0);

                if (low_elem.isType(.String) and high_elem.isType(.String)) {
                    const low_bytes = self.strings.get(low_elem.asString());
                    const high_bytes = self.strings.get(high_elem.asString());

                    if (parsing.utf8Decode(low_bytes)) |low_codepoint| {
                        if (parsing.utf8Decode(high_bytes)) |high_codepoint| {
                            if (low_codepoint <= high_codepoint) {
                                self.drop(2);
                                try self.parseCodepointRange(low_codepoint, high_codepoint);
                            } else {
                                return self.runtimeError("Range parser lower bound can't be larger than upper bound", .{});
                            }
                        } else {
                            return self.runtimeError("Range parser upper bound string must be a single valid codepoint", .{});
                        }
                    } else {
                        return self.runtimeError("Range parser lower bound string must be a single valid codepoint", .{});
                    }
                } else if (low_elem.isInteger(self.strings) and high_elem.isInteger(self.strings)) {
                    const low = try low_elem.asInteger(self.strings);
                    const high = try high_elem.asInteger(self.strings);
                    if (low <= high) {
                        self.drop(2);
                        try self.parseIntegerRange(low, high);
                    } else {
                        return self.runtimeError("Range parser lower bound can't be larger than upper bound", .{});
                    }
                } else {
                    return self.runtimeError("Range must parse codepoints or integers", .{});
                }
            },
            .ParseUpperBoundedRange => {
                const high_elem = self.peek(0);

                if (high_elem.isType(.String)) {
                    const bytes = self.strings.get(high_elem.asString());

                    if (parsing.utf8Decode(bytes)) |codepoint| {
                        self.drop(1);
                        try self.parseCodepointRange(0, codepoint);
                    } else {
                        return self.runtimeError("Range parser upper bound string must be a single valid codepoint", .{});
                    }
                } else if (high_elem.isInteger(self.strings)) {
                    self.drop(1);
                    const high = try high_elem.asInteger(self.strings);
                    try self.parseIntegerUpperBounded(high);
                } else {
                    return self.runtimeError("Range parser upper bound must be a codepoint or integer", .{});
                }
            },
            .PopInputMark => {
                _ = self.popInputMark();
            },
            .RepeatValue => {
                // Postfix, lhs and rhs on stack.
                // Perform repeat operation (multiplication for numbers, or repeated merge for non-numbers)
                const lhs = self.peek(1);
                const rhs = self.peek(0);

                if (try Elem.repeat(lhs, rhs, self)) |result| {
                    self.releaseConsumed(.RepeatValue, lhs, result);
                    self.releaseConsumed(.RepeatValue, rhs, result);
                    self.drop(2);
                    try self.pushFreshOrTransferred(.RepeatValue, result);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .ResetInput => {
                const resetPos = self.popInputMark();
                self.inputOffset = resetPos;
            },
            .TakeLeft => {
                // Postfix, lhs and rhs on stack.
                // If rhs succeeded then discard rhs, keep lhs.
                // If rhs failed then drop both and push failure.
                if (self.peekIsSuccess()) {
                    _ = self.popConsumed(.TakeLeft);
                } else {
                    _ = self.popConsumed(.TakeLeft);
                    _ = self.popConsumed(.TakeLeft);
                    try self.pushFailure();
                }
            },
            .TakeRight => {
                // Infix, lhs on stack.
                // If lhs succeeded then pop, to be replaced with rhs.
                // If lhs failed then keep it and jump to skip rhs ops.
                const offset = self.readShort();
                if (self.peekIsSuccess()) {
                    _ = self.popConsumed(.TakeRight);
                } else {
                    self.cur_frame.ip += offset;
                }
            },
            .PushTrue => {
                // Push singleton true value.
                try self.push(Elem.boolean(true));
            },
            .PushString, .PushString2, .PushString3, .PushString4 => {
                try self.push(Elem.string(self.readSid(opCode)));
            },
            .PushVar, .PushVar2, .PushVar3, .PushVar4 => {
                try self.push(Elem.valueVar(self.readSid(opCode), false));
            },
            .PushEmptyArray => {
                if (self.singleton_empty_array) |empty_array| {
                    try self.push(empty_array);
                } else {
                    const empty_array = (try Elem.DynElem.Array.create(self, 0)).dyn.elem();
                    empty_array.asDyn().makeImmortal();
                    self.singleton_empty_array = empty_array;
                    try self.push(empty_array);
                }
            },
            .PushEmptyObject => {
                if (self.singleton_empty_object) |empty_object| {
                    try self.push(empty_object);
                } else {
                    const empty_object = (try Elem.DynElem.Object.create(self, 0)).dyn.elem();
                    empty_object.asDyn().makeImmortal();
                    self.singleton_empty_object = empty_object;
                    try self.push(empty_object);
                }
            },
            .PushEmptyString => {
                try self.push(self.singleton_empty_string);
            },
            .PushInteger => {
                const byte = self.readByte();
                try self.push(Elem.numberFloat(@floatFromInt(byte)));
            },
            .PushNegInteger => {
                const byte = self.readByte();
                try self.push(Elem.numberFloat(-@as(f64, @floatFromInt(byte))));
            },
            .PushNumberStringNegOne => {
                try self.push(self.singleton_neg_one);
            },
            .PushNumberStringZero => {
                try self.push(self.singleton_zero);
            },
            .PushNumberStringOne => {
                try self.push(self.singleton_one);
            },
            .PushNumberStringTwo => {
                try self.push(self.singleton_two);
            },
            .PushNumberStringThree => {
                try self.push(self.singleton_three);
            },
            .PushNumberStringChar => {
                const char = self.readByte();
                const elem = try Elem.numberStringFromBytes(&[_]u8{char}, self);
                try self.push(elem);
            },
            .PushUnderscoreVar => {
                try self.push(self.singleton_underscore_var);
            },
        }
    }

    // Post-run memory report. Forces a collection first so the dyn chain
    // holds only reachable values. In Debug builds the collection also runs
    // the refcount audit.
    pub fn writeMemoryReport(self: *VM, writer: *Writer) !void {
        self.gc.collect();

        var live: u64 = 0;
        var strings: u64 = 0;
        var arrays: u64 = 0;
        var objects: u64 = 0;
        var functions: u64 = 0;
        var natives: u64 = 0;
        var closures: u64 = 0;
        var unique: u64 = 0;
        var shared: u64 = 0;
        var immortal: u64 = 0;

        var dyn = self.gc.nextDyn;
        while (dyn) |d| : (dyn = d.next) {
            live += 1;
            switch (d.dynType) {
                .String => strings += 1,
                .Array => arrays += 1,
                .Object => objects += 1,
                .Function => functions += 1,
                .NativeCode => natives += 1,
                .Closure => closures += 1,
            }
            if (d.ref_count == Elem.DynElem.immortal_ref_count) {
                immortal += 1;
            } else if (d.ref_count == 1) {
                unique += 1;
            } else {
                shared += 1;
            }
        }

        try writer.print("===== memory report =====\n", .{});
        try writer.print("dyns created:      {d}\n", .{self.uniqueIdCount});
        try writer.print(
            "dyns live:         {d} (string {d}, array {d}, object {d}, function {d}, native {d}, closure {d})\n",
            .{ live, strings, arrays, objects, functions, natives, closures },
        );
        try writer.print("live ref counts:   unique {d}, shared {d}, immortal {d}\n", .{ unique, shared, immortal });
        try writer.print("merges:            {d} in place, {d} copied\n", .{ self.rc_stats.merge_in_place, self.rc_stats.merge_copy });
        try writer.print("inserts:           {d} in place, {d} copied\n", .{ self.rc_stats.insert_in_place, self.rc_stats.insert_copy });
        try writer.print("husks:             {d} parked, {d} reused\n", .{ self.rc_stats.husks_parked, self.rc_stats.husks_reused });
        try writer.print("strings interned:  {d}\n", .{self.strings.count});
        try writer.print("strings size:      {d} chars\n", .{self.strings.buffer.items.len});
        try writer.print("bytes in use:      {d}\n", .{self.gc.bytesAllocated});
        // try self.strings.print(writer);
    }

    pub fn nextUniqueId(self: *VM) u64 {
        const id = self.uniqueIdCount;
        self.uniqueIdCount += 1;
        return id;
    }

    fn printDebug(self: *VM) !void {
        try self.writers.debug.print("\n", .{});
        try self.printInput();
        try self.printFrames();
        try self.printElems();

        if (self.frames.items.len > 0) {
            const module = self.currentFunctionModule();
            _ = try self.chunk().disassembleInstruction(self.*, module.*, self.writers.debug, self.cur_frame.ip);
        }
    }

    pub fn callFunction(self: *VM, elem: Elem, argCount: u8, isTailPosition: bool) Error!void {
        switch (elem.getType()) {
            .String => {
                const sid = elem.asString();
                assert(argCount == 0);
                self.drop(1);
                try self.parseString(sid);
            },
            .NumberString => {
                const ns = elem.asNumberString();
                assert(argCount == 0);
                self.drop(1);
                try self.parseNumberString(ns);
            },
            .Dyn => {
                const dyn = elem.asDyn();
                switch (dyn.dynType) {
                    .Function => {
                        var function = dyn.asFunction();

                        if (self.config.printExecutedBytecode) {
                            try function.disassemble(self.*, self.writers.debug);
                        }

                        if (function.arity == argCount) {
                            const reuses_frame = isTailPosition and !function.isBuiltin();
                            if (self.config.explain) {
                                try self.emitExplainCall(function, reuses_frame);
                            }
                            if (reuses_frame) {
                                // Remove the elements belonging to the previous call
                                // frame. This includes the function itself, its
                                // arguments, and any added local variables.
                                const frameStart = self.cur_frame.elemsOffset;
                                const frameEnd = self.stack.items.len - function.arity - 1;
                                const length = frameEnd - frameStart;
                                for (self.stack.items[frameStart..frameEnd]) |item| {
                                    self.reclaimElem(item);
                                }
                                try self.stack.replaceRange(self.allocator, frameStart, length, &[0]Elem{});
                                _ = self.frames.pop();
                            }
                            try self.pushFrame(function);
                        } else {
                            return self.runtimeError("Expected {} arguments but got {}.", .{ function.arity, argCount });
                        }
                    },
                    .Closure => {
                        const functionElem = dyn.asClosure().function.dyn.elem();
                        try self.callFunction(functionElem, argCount, isTailPosition);
                    },
                    else => @panic("Internal error"),
                }
            },
            else => @panic("Internal error"),
        }
    }

    pub fn parseString(self: *VM, sid: StringTable.Id) Error!void {
        const str = self.strings.get(sid);
        const start = self.inputOffset;
        const end = start + str.len;

        if (self.input.len >= end and std.mem.eql(u8, str, self.input[start..end])) {
            self.inputOffset = end;

            if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                try self.push(elem);
            } else {
                try self.push(Elem.string(sid));
            }

            return;
        }

        try self.pushFailure();
    }

    fn parseNumberString(self: *VM, number_string: Elem.NumberStringElem) Error!void {
        const bytes = number_string.toBytes(self.strings);
        const start = self.inputOffset;
        const end = start + bytes.len;

        if (self.input.len >= end and std.mem.eql(u8, bytes, self.input[start..end])) {
            self.inputOffset = end;
            try self.push(number_string.elem());
            return;
        }
        try self.pushFailure();
    }

    fn parseCharacter(self: *VM, char: u8) !void {
        const start = self.inputOffset;

        if (start < self.input.len and self.input[start] == char) {
            const end = start + 1;

            self.inputOffset = end;

            if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                try self.push(elem);
            } else {
                try self.push(Elem.string(try self.strings.insert(&[_]u8{char})));
            }

            return;
        }
        try self.pushFailure();
    }

    fn parseNumberStringCharacter(self: *VM, char: u8) !void {
        const start = self.inputOffset;

        if (start < self.input.len and self.input[start] == char) {
            self.inputOffset = start + 1;
            const ns = try Elem.numberStringFromBytes(&[_]u8{char}, self);
            try self.push(ns);

            return;
        }
        try self.pushFailure();
    }

    fn parseCodepointRange(self: *VM, low: u21, high: u21) !void {
        const low_length = unicode.utf8CodepointSequenceLength(low) catch 1;
        const high_length = unicode.utf8CodepointSequenceLength(high) catch 1;
        const start = self.inputOffset;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (low_length <= bytes_length and bytes_length <= high_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (low <= codepoint and codepoint <= high) {
                    self.inputOffset = end;
                    try self.pushInputSubstring(start, end);
                    return;
                }
            }
        }
        try self.pushFailure();
    }

    // Push the matched input range, as a packed substring elem when it
    // fits, a rope of packed segments when only the length overflows,
    // and a heap string otherwise.
    fn pushInputSubstring(self: *VM, start: usize, end: usize) !void {
        if (try Elem.inputSubstringFromRange(start, end)) |elem| {
            try self.push(elem);
        } else if (end <= std.math.maxInt(u32)) {
            const max_segment = std.math.maxInt(u16);
            const segment_count = std.math.divCeil(usize, end - start, max_segment) catch unreachable;
            const rope = try Elem.DynElem.String.createRope(self, segment_count);
            var pos = start;
            while (pos < end) {
                const seg_end = @min(pos + max_segment, end);
                try rope.appendSegment(self, Elem.inputSubstring(@intCast(pos), @intCast(seg_end - pos)));
                pos = seg_end;
            }
            try self.push(rope.dyn.elem());
        } else {
            const str = try Elem.DynElem.String.copy(self, self.input[start..end]);
            try self.push(str.dyn.elem());
        }
    }

    fn parseIntegerRange(self: *VM, low: i64, high: i64) !void {
        const lowIntLen = parsing.intAsStringLen(low);
        const highIntLen = parsing.intAsStringLen(high);
        const start = self.inputOffset;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);
        const longestMatchEnd = @min(start + highIntLen, self.input.len);

        var end = longestMatchEnd;

        // Find the longest substring from the start of the input which
        // parses as an integer, is greater than or equal to `low` and
        // less than or equal to `high`, and is at least one char long.
        while (end >= shortestMatchEnd and end > start) {
            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (low <= i and i <= high) {
                self.inputOffset = end;
                const int = Elem.numberFloat(@as(f64, @floatFromInt(i)));
                try self.push(int);
                return;
            };
            end -= 1;
        }
        try self.pushFailure();
    }

    fn parseIntegerLowerBounded(self: *VM, low: i64) !void {
        const lowIntLen = parsing.intAsStringLen(low);
        const start = self.inputOffset;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

        var end = shortestMatchEnd;

        // The integer has no upper bound, so keep eating digits
        while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
            end += 1;
        }

        const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

        if (inputInt) |i| if (low <= i) {
            self.inputOffset = end;
            const int = Elem.numberFloat(@as(f64, @floatFromInt(i)));
            try self.push(int);
            return;
        };

        try self.pushFailure();
    }

    fn parseIntegerUpperBounded(self: *VM, high: i64) !void {
        if (self.inputOffset < self.input.len and self.input[self.inputOffset] == '-') {
            // If it's a negative integer then the max number of digits is unbounded
            const lowIntLen = 2;
            const start = self.inputOffset;
            const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

            var end = shortestMatchEnd;

            // The negative integer has no lower bound, so keep eating digits
            while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
                end += 1;
            }

            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (i <= high) {
                self.inputOffset = end;
                const int = Elem.numberFloat(@as(f64, @floatFromInt(i)));
                try self.push(int);
                return;
            };

            try self.pushFailure();
        } else {
            // Since the integer is not negative we can assume it's between 0 and the upper bound
            try self.parseIntegerRange(0, high);
        }
    }

    pub fn varIdIsPlaceholder(self: *VM, var_id: StringTable.Id) bool {
        return var_id == self.strings.getId("_");
    }

    pub fn pushFrame(self: *VM, function: *Elem.DynElem.Function) !void {
        try self.frames.append(self.allocator, CallFrame{
            .function = function,
            .ip = 0,
            .elemsOffset = self.stack.items.len - function.arity - 1,
        });
        self.syncCurrentFrame();
    }

    fn popFrame(self: *VM) CallFrame {
        const frame = self.frames.pop().?;
        if (self.frames.items.len > 0) self.syncCurrentFrame();
        return frame;
    }

    // Refresh the cached current-frame pointer and code slice. Must be called
    // after any mutation of self.frames (append/pop), since frame() and the
    // operand readers read through the cache to avoid re-deriving the top
    // frame and its chunk on every instruction.
    fn syncCurrentFrame(self: *VM) void {
        self.cur_frame = &self.frames.items[self.frames.items.len - 1];
        self.cur_code = self.cur_frame.function.chunk.code.items;
    }

    fn parentFrame(self: *VM) ?*CallFrame {
        if (self.frames.items.len > 1) {
            return &self.frames.items[self.frames.items.len - 2];
        } else {
            return null;
        }
    }

    fn chunk(self: *VM) *Chunk {
        return &self.cur_frame.function.chunk;
    }

    pub fn getConstant(self: *VM, idx: usize) Elem {
        return self.currentFunctionModule().getConstant(idx);
    }

    // Push a mutable copy of a container constant that later Insert ops
    // fill in. The copy lands in a pooled husk whenever the constant's
    // previous incarnation was consumed and parked, so a loop body reuses
    // one allocation.
    fn pushMutableConstant(self: *VM, idx: usize) !void {
        const constant = self.getConstant(idx);

        if (!self.config.rc_fast_paths) {
            // Baseline: push the immortal constant and let the mutating
            // op copy it, exactly as GetConstant behaves.
            return self.push(constant);
        }

        const template = constant.asDyn();
        const copy: *Elem.DynElem = switch (template.dynType) {
            .Array => &(try Elem.DynElem.Array.copy(self, template.asArray().elems.items)).dyn,
            .Object => &(try Elem.DynElem.Object.copy(self, template.asObject())).dyn,
            else => unreachable,
        };
        try self.push(copy.elem());
    }

    // Pop the function on top of the stack and push a closure over it
    // that later CaptureLocal ops fill in. Creation reuses a parked
    // closure husk when the last closure from this site was consumed.
    fn pushClosure(self: *VM, localCount: u8) !void {
        const elem = self.peek(0);
        std.debug.assert(elem.isDynType(.Function));
        const function = elem.asDyn().asFunction();

        const closure = try Elem.DynElem.Closure.create(self, function, localCount);
        // The closure retained the function; the function's stack
        // handle dies here.
        _ = self.popConsumed(.CreateClosure);
        try self.push(closure.dyn.elem());
    }

    pub fn getMatchPlan(self: *VM, idx: usize) MatchPlan {
        return self.currentFunctionModule().getMatchPlan(idx);
    }

    pub fn getFunctionElem(self: *VM) Elem {
        return self.stack.items[self.cur_frame.elemsOffset];
    }

    pub fn getLocal(self: *VM, slot: usize) Elem {
        // The local slot is at the start of the frame + 1, since the first
        // elem in the frame is the function getting called.
        return self.stack.items[self.cur_frame.elemsOffset + slot + 1];
    }

    pub fn getBoundLocal(self: *VM, slot: usize) !Elem {
        const local = self.getLocal(slot);
        switch (local.getType()) {
            .ValueVar => {
                const varName = local.asValueVar().sid;
                const nameStr = self.strings.get(varName);
                return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
            },
            else => return local,
        }
    }

    pub fn setLocal(self: *VM, slot: usize, elem: Elem) void {
        // The local slot is at the start of the frame + 1, since the first
        // elem in the frame is the function getting called.
        self.stack.items[self.cur_frame.elemsOffset + slot + 1] = elem;
    }

    fn readByte(self: *VM) u8 {
        const byte = self.cur_code[self.cur_frame.ip];
        self.cur_frame.ip += 1;
        return byte;
    }

    fn readOp(self: *VM) OpCode {
        const op: OpCode = @enumFromInt(self.cur_code[self.cur_frame.ip]);
        self.cur_frame.ip += 1;
        return op;
    }

    fn readShort(self: *VM) u16 {
        self.cur_frame.ip += 2;
        const items = self.cur_code;
        return (@as(u16, @intCast(items[self.cur_frame.ip - 2])) << 8) | items[self.cur_frame.ip - 1];
    }

    fn readMedium(self: *VM) u24 {
        self.cur_frame.ip += 3;
        const items = self.cur_code;
        return (@as(u24, @intCast(items[self.cur_frame.ip - 3])) << 16) |
            (@as(u24, @intCast(items[self.cur_frame.ip - 2])) << 8) |
            items[self.cur_frame.ip - 1];
    }

    fn readSid(self: *VM, opCode: OpCode) StringTable.Id {
        return @enumFromInt(switch (opCode) {
            .PushString, .PushVar => @as(u32, self.readByte()),
            .PushString2, .PushVar2 => @as(u32, self.readShort()),
            .PushString3, .PushVar3 => @as(u32, self.readMedium()),
            .PushString4, .PushVar4 => self.readLong(),
            else => unreachable,
        });
    }

    fn readIndex(self: *VM, opCode: OpCode) usize {
        return switch (opCode) {
            .CallFunctionConstant,
            .CallTailFunctionConstant,
            .GetConstant,
            .GetConstantMutable,
            .DestructurePlan,
            => self.readByte(),
            .CallFunctionConstant2,
            .CallTailFunctionConstant2,
            .GetConstant2,
            .GetConstantMutable2,
            .DestructurePlan2,
            => self.readShort(),
            .CallFunctionConstant3,
            .CallTailFunctionConstant3,
            .GetConstant3,
            .GetConstantMutable3,
            .DestructurePlan3,
            => self.readMedium(),
            else => unreachable,
        };
    }

    fn readLong(self: *VM) u32 {
        self.cur_frame.ip += 4;
        const items = self.cur_code;
        return (@as(u32, @intCast(items[self.cur_frame.ip - 4])) << 24) |
            (@as(u32, @intCast(items[self.cur_frame.ip - 3])) << 16) |
            (@as(u32, @intCast(items[self.cur_frame.ip - 2])) << 8) |
            items[self.cur_frame.ip - 1];
    }

    // Release a consumed operand's stack handle, unless the result is the
    // same value: then the handle transferred into the result push. The
    // op's effect table entry must admit consuming operands. A last
    // handle parks the husk, so the operand must not be read afterward.
    fn releaseConsumed(self: *VM, comptime op: OpCode, operand: Elem, result: Elem) void {
        comptime std.debug.assert(op.rcEffect().?.operands.canConsume());
        if (!operand.isType(.Dyn)) return;
        if (result.isType(.Dyn) and result.asDyn() == operand.asDyn()) return;
        self.gc.reclaim(operand.asDyn());
    }

    // Drop a handle to a value the op is done with; a last handle parks
    // the husk for reuse.
    fn reclaimElem(self: *VM, value: Elem) void {
        if (value.isType(.Dyn)) self.gc.reclaim(value.asDyn());
    }

    // Pop an operand whose handle leaves the stack for good, released
    // here. The op's effect table entry must admit consuming operands.
    // Callers may only inspect the returned Elem's value-type bits: a
    // last handle parked the husk.
    fn popConsumed(self: *VM, comptime op: OpCode) Elem {
        comptime std.debug.assert(op.rcEffect().?.operands.canConsume());
        const value = self.pop();
        self.reclaimElem(value);
        return value;
    }

    // Push an additional handle to a value that keeps its existing
    // handles: increments, per the op's effect table entry.
    fn pushDerived(self: *VM, comptime op: OpCode, elem: Elem) !void {
        comptime std.debug.assert(op.rcEffect().?.result == .derived);
        elem.retain();
        try self.push(elem);
    }

    // Push a handle transferred from a frame slot or a consumed operand:
    // no increment, per the op's effect table entry.
    fn pushTransferred(self: *VM, comptime op: OpCode, elem: Elem) !void {
        comptime std.debug.assert(op.rcEffect().?.result == .transferred);
        try self.push(elem);
    }

    // Push a result that is either fresh or a consumed operand re-pushed
    // by an in-place fast path; releaseConsumed told them apart by
    // pointer equality.
    fn pushFreshOrTransferred(self: *VM, comptime op: OpCode, elem: Elem) !void {
        comptime std.debug.assert(op.rcEffect().?.result == .fresh_or_transferred);
        try self.push(elem);
    }

    pub fn push(self: *VM, elem: Elem) !void {
        if (self.stack.items.len < self.stack.capacity) {
            self.stack.appendAssumeCapacity(elem);
        } else {
            try self.stack.append(self.allocator, elem);
        }
    }

    pub fn pushFailure(self: *VM) !void {
        if (self.failureReachesFarthest()) {
            self.recordFarthestFailure(.input_mismatch, null);
        }
        try self.push(Elem.failureConst);
    }

    fn failureReachesFarthest(self: *VM) bool {
        return self.farthest == null or self.inputOffset >= self.farthest.?.offset;
    }

    fn recordPatternFailure(self: *VM, value: Elem) void {
        if (self.failureReachesFarthest()) {
            self.recordFarthestFailure(.pattern_mismatch, value);
        }
    }

    // Cold: runs only when a failure reaches the farthest position. On a
    // strict advance the headline record and the expected set restart at
    // this site; on a tie the site joins the expected set. An input tie
    // keeps the first-recorded headline, but a pattern tie replaces it:
    // the rejected value parsed all the way to the farthest position,
    // which beats a speculative parse failure at the same offset. The
    // grammar site is resolved the same way runtimeError resolves it — a
    // builtin frame defers to its caller, never a deeper ancestry walk
    // (under tail call elimination the walk lies).
    noinline fn recordFarthestFailure(self: *VM, kind: FarthestFailure.Kind, value: ?Elem) void {
        const target_frame = if (self.cur_frame.function.isBuiltin())
            self.parentFrame() orelse self.cur_frame
        else
            self.cur_frame;

        const function = target_frame.function;
        const region = function.chunk.regions.items[target_frame.ip - 1];
        const advanced = self.farthest == null or self.inputOffset > self.farthest.?.offset;

        if (advanced or kind == .pattern_mismatch) {
            var record = FarthestFailure{
                .offset = self.inputOffset,
                .region = region,
                .function_name = function.name,
                .module_id = function.mid,
                .kind = kind,
                .value_snapshot = undefined,
                .value_snapshot_len = 0,
                .value_truncated = false,
            };

            // Render the rejected value eagerly: the destructure op reclaims
            // it right after this, so the record cannot hold the Elem itself.
            if (value) |v| {
                var writer = Writer.fixed(&record.value_snapshot);
                v.print(self.*, &writer) catch {
                    record.value_truncated = true;
                };
                var len = writer.end;
                if (record.value_truncated) {
                    // Drop any codepoint the cutoff split in half.
                    while (len > 0 and record.value_snapshot[len - 1] & 0xC0 == 0x80) len -= 1;
                    if (len > 0 and record.value_snapshot[len - 1] >= 0xC0) len -= 1;
                }
                record.value_snapshot_len = @intCast(len);
            }

            self.farthest = record;
        }

        const entry = ExpectedSet.Entry{
            .region = region,
            .function_name = function.name,
            .module_id = function.mid,
        };
        if (advanced) {
            self.expected.reset(entry);
        } else {
            self.expected.append(entry);
        }
    }

    // The explain emitters are noinline so the never-taken explain branch
    // costs the hot paths (call, return, destructure) only a test and a
    // skipped jump, not the inlined event construction.
    noinline fn emitExplainCall(self: *VM, function: *Elem.DynElem.Function, is_tail: bool) !void {
        try self.explain_events.append(self.allocator, .{ .call = .{
            .function_name = function.name,
            .module_id = function.mid,
            .offset = self.inputOffset,
            .is_tail = is_tail,
        } });
    }

    noinline fn emitExplainRet(self: *VM, failed: bool) !void {
        try self.explain_events.append(self.allocator, .{ .ret = .{
            .failed = failed,
            .offset = self.inputOffset,
        } });
    }

    noinline fn emitExplainDestructureBegin(self: *VM, value: Elem, pattern: anytype) !void {
        try self.explain_events.append(self.allocator, .{ .destructure_begin = .{
            .region = self.cur_frame.function.chunk.regions.items[self.cur_frame.ip - 1],
            .module_id = self.cur_frame.function.mid,
            .offset = self.inputOffset,
            .value = explain.snapshot(self, value),
            .pattern = explain.snapshot(self, pattern),
        } });
    }

    noinline fn emitExplainDestructureEnd(self: *VM, failed: bool) !void {
        try self.explain_events.append(self.allocator, .{ .destructure_end = .{
            .failed = failed,
        } });
    }

    pub fn pop(self: *VM) Elem {
        return self.stack.pop().?;
    }

    // Pop a stack argument that a native builtin consumes. The native owns
    // the handle retained for it by the argument-loading op and must
    // release it. Release with `defer` so every read of the value happens
    // while it is still rooted: releasing before the reads would leave the
    // value unrooted at ref_count 0, and any allocation through
    // gc.allocator() in that window could collect it mid-read.
    pub fn popArg(self: *VM) Elem {
        return self.pop();
    }

    pub fn drop(self: *VM, n: usize) void {
        for (0..n) |_| _ = self.pop();
    }

    pub fn peek(self: *VM, distance: usize) Elem {
        const len = self.stack.items.len;
        return self.stack.items[(len - 1) - distance];
    }

    fn peekIsFailure(self: *VM) bool {
        const elem = self.peek(0);
        return elem.isConst(.Failure);
    }

    fn peekIsSuccess(self: *VM) bool {
        return !self.peekIsFailure();
    }

    fn pushInputMark(self: *VM) !void {
        if (self.inputMarks.items.len < self.inputMarks.capacity) {
            self.inputMarks.appendAssumeCapacity(self.inputOffset);
        } else {
            try self.inputMarks.append(self.allocator, self.inputOffset);
        }
    }

    fn popInputMark(self: *VM) usize {
        return self.inputMarks.pop().?;
    }

    fn printInput(self: *VM) !void {
        const pos = self.materializePos(self.inputOffset);
        try self.writers.debug.print("input   | ", .{});
        try self.writers.debug.print("{s} @ Line {d} byte {d}\n", .{
            self.inputLine(pos.line_start),
            pos.line,
            pos.lineOffset(),
        });
    }

    fn printElems(self: *VM) !void {
        try self.writers.debug.print("Stack   | ", .{});
        for (self.stack.items, 0..) |e, idx| {
            e.print(self.*, self.writers.debug) catch {};
            if (idx < self.stack.items.len - 1) try self.writers.debug.print(", ", .{});
        }
        try self.writers.debug.print("\n", .{});
    }

    fn printFrames(self: VM) !void {
        try self.writers.debug.print("Frames  | ", .{});
        for (self.frames.items, 0..) |f, idx| {
            f.function.print(self, self.writers.debug) catch {};
            if (idx < self.frames.items.len - 1) try self.writers.debug.print(", ", .{});
        }
        try self.writers.debug.print("\n", .{});
    }

    fn inputLine(self: VM, line_start: usize) []const u8 {
        var line_end = line_start;
        while (true) {
            if (self.input.len == line_end or
                self.isNewlineChar(line_end, 1) or
                (self.input[line_end..].len >= 2 and self.isNewlineChar(line_end, 2)) or
                (self.input[line_end..].len >= 3 and self.isNewlineChar(line_end, 3)))
                break;

            line_end += 1;
        }

        return self.input[line_start..line_end];
    }

    pub fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const target_frame = if (self.cur_frame.function.isBuiltin())
            self.parentFrame() orelse self.cur_frame
        else
            self.cur_frame;

        const function = target_frame.function;
        const module = self.getModule(function.mid);
        const region = function.chunk.regions.items[target_frame.ip - 1];

        try self.writers.err.print("\nRuntime Error: ", .{});
        try self.writers.err.print(message, args);
        try self.writers.err.print("\n", .{});

        try self.writers.err.print("\n\n", .{});

        try self.writers.err.print("{s}:", .{module.name});
        try region.printLineRelative(module.source, self.writers.err);
        try self.writers.err.print(":\n\n", .{});

        try module.highlight(region, self.writers.err);
        try self.writers.err.print("\n", .{});

        return Error.RuntimeError;
    }

    pub fn printParseFailure(self: *VM, input_name: []const u8) !void {
        const writer = self.writers.err;

        const record = self.farthest orelse {
            try writer.print("\nParse Failure\n\n", .{});
            try self.printInputContext(self.inputOffset, input_name, writer);
            return;
        };

        const module = self.getModule(record.module_id);
        const multiple_expected = self.expected.len > 1;

        switch (record.kind) {
            .input_mismatch => if (multiple_expected) {
                // The expected list below names every attempted site, so
                // the headline carries only the position.
                const pos = self.materializePos(record.offset);
                try writer.print("\nParse Failure at input {d}:{d}\n\n", .{
                    pos.line,
                    pos.lineOffset(),
                });
            } else {
                try writer.print("\nParse Failure: expected ", .{});
                try printSourceExcerpt(module.source, record.region, writer);
                try writer.print("\n\n", .{});
            },
            .pattern_mismatch => {
                try writer.print("\nParse Failure: value {s}", .{record.valueSnapshot()});
                if (record.value_truncated) try writer.print("…", .{});
                try writer.print(" did not match pattern ", .{});
                try printSourceExcerpt(module.source, record.region, writer);
                try writer.print("\n\n", .{});
            },
        }

        try self.printInputContext(record.offset, input_name, writer);

        if (multiple_expected) {
            try self.printExpectedSet(writer);
            return;
        }

        const name = self.strings.get(record.function_name);
        if (name.len > 0) {
            try writer.print("\nwhile matching parser `{s}`\n\n", .{name});
        } else {
            try writer.print("\nwhile matching parser\n\n", .{});
        }

        try writer.print("{s}:", .{module.name});
        try record.region.printLineRelative(module.source, writer);
        try writer.print(":\n\n", .{});
        try module.highlight(record.region, writer);
        try writer.print("\n", .{});
    }

    fn printExpectedSet(self: *VM, writer: *Writer) !void {
        try writer.print("\nexpected one of:\n", .{});
        for (self.expected.slice()) |entry| {
            const module = self.getModule(entry.module_id);

            try writer.print("  ", .{});
            try printSourceExcerpt(module.source, entry.region, writer);

            const loc = LineRelativeRegion.fromRegion(entry.region, module.source, null);
            const name = self.strings.get(entry.function_name);
            if (name.len > 0) {
                try writer.print(" (parser `{s}`, {s}:{d}:{d})\n", .{
                    name,
                    module.name,
                    loc.line,
                    loc.relative_start,
                });
            } else {
                try writer.print(" ({s}:{d}:{d})\n", .{
                    module.name,
                    loc.line,
                    loc.relative_start,
                });
            }
        }
        if (self.expected.truncated) {
            try writer.print("  … and others\n", .{});
        }
    }

    fn printInputContext(self: *VM, offset: usize, input_name: []const u8, writer: *Writer) !void {
        const pos = self.materializePos(offset);
        try writer.print("{s}:{d}:{d}:\n\n", .{ input_name, pos.line, pos.lineOffset() });
        if (offset >= self.input.len) {
            try hl.highlightEndPosition(self.input, writer, .{});
            // The empty-source path of highlightEndPosition omits the
            // trailing newline the other paths print.
            if (self.input.len == 0) try writer.print("\n", .{});
        } else {
            try hl.highlightRegion(self.input, Region.new(offset, offset + 1), writer, .{});
        }
    }

    // Derive full position info for an offset by counting newlines between
    // the memoized position and the target, then advance the memo. Parsing
    // maintains only inputOffset; everything that needs a line number pays
    // for it here, proportional to the distance from the last query.
    pub fn materializePos(self: *VM, offset: usize) Pos {
        var memo = self.pos_memo;

        if (offset > memo.offset) {
            var i = memo.offset;
            while (i < offset) {
                const len = self.newlineSeqLen(i) orelse {
                    i += 1;
                    continue;
                };
                // A sequence straddling the target offset is not yet past.
                if (i + len > offset) break;
                memo.line += 1;
                memo.line_start = i + len;
                i += len;
            }
        } else if (offset < memo.offset) {
            var newlines: usize = 0;
            var i = offset;
            while (i < memo.offset) {
                const len = self.newlineSeqLen(i) orelse {
                    i += 1;
                    continue;
                };
                // Mirror the forward guard so counts stay symmetric.
                if (i + len > memo.offset) break;
                newlines += 1;
                i += len;
            }
            memo.line -= newlines;
            memo.line_start = self.lineStartBefore(offset);
        }

        memo.offset = offset;
        self.pos_memo = memo;
        return memo;
    }

    // Byte length of the newline sequence at offset, or null if none.
    fn newlineSeqLen(self: *const VM, offset: usize) ?usize {
        const remaining = self.input.len - offset;
        if (remaining >= 1 and self.isNewlineChar(offset, 1)) return 1;
        if (remaining >= 2 and self.isNewlineChar(offset, 2)) return 2;
        if (remaining >= 3 and self.isNewlineChar(offset, 3)) return 3;
        return null;
    }

    // Offset just past the last newline sequence ending at or before offset.
    fn lineStartBefore(self: *const VM, offset: usize) usize {
        var j = offset;
        while (j > 0) : (j -= 1) {
            if (self.isNewlineChar(j - 1, 1)) return j;
            if (j >= 2 and self.isNewlineChar(j - 2, 2)) return j;
            if (j >= 3 and self.isNewlineChar(j - 3, 3)) return j;
        }
        return 0;
    }

    fn isNewlineChar(self: VM, offset: usize, bytes_length: u3) bool {
        if (bytes_length == 1) {
            const b1 = self.input[offset];
            return b1 == 0x0A or b1 == 0x0B or b1 == 0x0C or b1 == 0x0D;
        } else if (bytes_length == 2) {
            const b1 = self.input[offset];
            const b2 = self.input[offset + 1];
            return b1 == 0xC2 and b2 == 0x85;
        } else if (bytes_length == 3) {
            const b1 = self.input[offset];
            const b2 = self.input[offset + 1];
            const b3 = self.input[offset + 2];
            return b1 == 0xE2 and b2 == 0x80 and (b3 == 0xA8 or b3 == 0xA9);
        } else {
            return false;
        }
    }

    pub fn pushTempDyn(self: *VM, dyn: *Elem.DynElem) !void {
        try self.temp_dyns.append(self.allocator, dyn);
    }

    pub fn dropTempDyn(self: *VM) void {
        _ = self.temp_dyns.pop();
    }

    pub fn clearTempDyns(self: *VM, len: usize) void {
        self.temp_dyns.shrinkRetainingCapacity(len);
    }
};

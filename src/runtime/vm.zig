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
const GoalStage = @import("../frontend/goal_ast.zig").Stage;
const GC = @import("gc.zig").GC;
const Module = @import("module.zig").Module;
const ModuleLoader = @import("module_loader.zig").ModuleLoader;
const OpCode = @import("op_code.zig").OpCode;
const RangeLimitKind = @import("op_code.zig").RangeLimitKind;
const MatchCmpKind = @import("op_code.zig").MatchCmpKind;
const MatchCastKind = @import("op_code.zig").MatchCastKind;
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
    printGoalAst: ?GoalStage = null,
    printCompiledBytecode: bool = false,
    printExecutedBytecode: bool = false,
    printVM: bool = false,
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
    // Required only for loading modules from disk (native CLI). Left null in
    // contexts that never touch the filesystem (wasm, unit tests).
    io: ?std.Io = null,
    // Used to expand `~/` in disk import paths. Left null when the filesystem
    // is never touched (wasm, unit tests).
    environ_map: ?*const std.process.Environ.Map = null,

    pub fn setEnv(self: *Config, env: Env) void {
        self.printScanner = env.printScanner;
        self.printParser = env.printParser;
        self.printAst = env.printAst;
        self.printGoalAst = env.printGoalAst;
        self.printCompiledBytecode = env.printCompiledBytecode;
        self.printExecutedBytecode = env.printExecutedBytecode;
        self.printVM = env.printVM;
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

// The f64 value of a number Elem (a float or a NumberString), or null when
// the Elem isn't a number.
fn numberFloatOf(elem: Elem, strings: StringTable) ?f64 {
    if (elem.isFloat()) return elem.asFloat();
    if (elem.isType(.NumberString)) return elem.asNumberString().toNumberFloat(strings).asFloat();
    return null;
}

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
    // Disk path of the target module's source when it came from a file.
    // Seeds the loader so imports naming the same file dedup against the
    // target module and its relative imports resolve against its
    // directory; null (a string or stdin parser) resolves against the
    // working directory.
    main_module_path: ?[]const u8,
    compiler: ?*const Compiler,
    stack: ArrayList(Elem),
    frames: ArrayList(CallFrame),
    // Match register stack: transient pattern-match scratch (places,
    // cursors, counters) for window-mode functions, held in nested LIFO
    // windows separate from the value stack. current_window_base caches
    // the base of the innermost open window; window_bases holds the saved
    // bases of enclosing windows. GC-rooted like the value stack.
    match_regs: ArrayList(Elem),
    window_bases: ArrayList(usize),
    current_window_base: usize,
    // Parallel to window_bases: the saved fail_ip of enclosing windows.
    // current_window_fail is the innermost open window's shared fail block,
    // where every semidet step and MatchRefail jumps on failure.
    window_fails: ArrayList(usize),
    current_window_fail: usize,
    cur_frame: *CallFrame,
    cur_code: []const u8,
    temp_dyns: ArrayList(*Elem.DynElem),
    input: []const u8,
    inputMarks: ArrayList(usize),
    inputOffset: usize,
    farthest: ?FarthestFailure,
    expected: ExpectedSet,
    explain_events: ArrayList(explain.Event),
    // --explain only: the window base of each open root destructure, so the
    // MatchWindowExit that closes a root (base == the base recorded at its
    // MatchScrutinee) pairs with its destructure_begin. Nested root matches
    // (the eval bridge) stack; child windows never match a recorded base.
    explain_open: ArrayList(usize),
    uniqueIdCount: u64,
    rc_stats: RcStats,
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
        // match_regs.items.len and current_window_base captured at frame
        // entry. End (and any error unwind) reclaims the registers above
        // match_regs_base and restores current_window_base, so a callee
        // that errors mid-match cannot corrupt a caller's open window.
        match_regs_base: usize,
        saved_window_base: usize,
        saved_window_fail: usize,
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
            .main_module_path = null,
            .compiler = undefined,
            .stack = undefined,
            .frames = undefined,
            .match_regs = undefined,
            .window_bases = undefined,
            .current_window_base = undefined,
            .window_fails = undefined,
            .current_window_fail = undefined,
            .cur_frame = undefined,
            .cur_code = undefined,
            .temp_dyns = undefined,
            .input = undefined,
            .inputMarks = undefined,
            .inputOffset = undefined,
            .farthest = null,
            .expected = ExpectedSet.empty,
            .explain_events = undefined,
            .explain_open = undefined,
            .uniqueIdCount = undefined,
            .rc_stats = undefined,
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
        self.modules = ArrayList(*Module).empty;
        self.loader = ModuleLoader.init(self, allocator);
        self.compiler = null;
        self.stack = ArrayList(Elem).empty;
        self.frames = ArrayList(CallFrame).empty;
        self.match_regs = ArrayList(Elem).empty;
        self.window_bases = ArrayList(usize).empty;
        self.current_window_base = 0;
        self.window_fails = ArrayList(usize).empty;
        self.current_window_fail = 0;
        self.cur_frame = undefined;
        self.cur_code = undefined;
        self.temp_dyns = ArrayList(*Elem.DynElem).empty;
        self.input = undefined;
        self.inputMarks = ArrayList(usize).empty;
        self.inputOffset = 0;
        self.pos_memo = Pos{};
        self.farthest = null;
        self.expected = ExpectedSet.empty;
        self.explain_events = ArrayList(explain.Event).empty;
        self.explain_open = ArrayList(usize).empty;
        self.uniqueIdCount = 0;
        self.rc_stats = RcStats{};
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
        self.match_regs.deinit(self.allocator);
        self.window_bases.deinit(self.allocator);
        self.window_fails.deinit(self.allocator);
        self.temp_dyns.deinit(self.allocator);
        self.inputMarks.deinit(self.allocator);
        self.explain_events.deinit(self.allocator);
        self.explain_open.deinit(self.allocator);
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

        var maybe_stdlib_module: ?*Module = null;
        if (self.config.includeStdlib) {
            const loaded = try self.loader.getOrLoadEmbedded("stdlib");
            maybe_stdlib_module = loaded.module;
        }

        const main_module = try self.createModule(module_name, source);
        if (self.main_module_path) |path| {
            try self.loader.registerFileModule(path, main_module.id);
        }

        var compiler = try Compiler.init(self);
        defer compiler.deinit();

        try compiler.addBuiltinsModule(builtin_module.*);

        // The implicit dumps are registered before the target module is
        // added so that every import written in the program shadows them.
        try compiler.addImplicitDump(builtin_module.id);
        if (maybe_stdlib_module) |stdlib_module| {
            try compiler.addModule(stdlib_module.*, .{});
            try compiler.addImplicitDump(stdlib_module.id);
        }

        try compiler.addTargetModule(main_module.*, .{
            .printScanner = self.config.printScanner,
            .printParser = self.config.printParser,
            .printAst = self.config.printAst,
            .printGoalAst = self.config.printGoalAst,
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

                // Reclaim any match scratch the frame left open (defensive:
                // a callee that errored mid-match) and restore the window
                // state it was entered with, so the caller's open window is
                // intact on return.
                for (self.match_regs.items[prevFrame.match_regs_base..]) |reg| {
                    self.reclaimElem(reg);
                }
                self.match_regs.shrinkRetainingCapacity(prevFrame.match_regs_base);
                self.current_window_base = prevFrame.saved_window_base;
                self.current_window_fail = prevFrame.saved_window_fail;

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
            .MatchScrutinee => {
                const region = self.cur_frame.function.chunk.regions.items[self.cur_frame.ip];
                const slot = self.readByte();
                const value = self.peek(0);
                const previous = self.getScratch(slot);
                value.retain();
                self.setScratch(slot, value);
                previous.release();
                // MatchScrutinee opens a root destructure (child windows load
                // via MatchSubScrutinee); trace it and record its window base
                // so the matching MatchWindowExit closes it.
                if (self.config.explain) {
                    try self.emitExplainDestructureBegin(region);
                    try self.explain_open.append(self.allocator, self.current_window_base);
                }
            },
            .MatchSubScrutinee => {
                // A nested sub-pattern's scrutinee: copy a register from
                // the enclosing window into this window's slot. The source
                // is addressed relative to the parent base saved when this
                // window opened (window_bases' top).
                const dst = self.readByte();
                const src = self.readByte();
                const value = self.match_regs.items[self.window_bases.getLast() + src];
                const previous = self.getScratch(dst);
                value.retain();
                self.setScratch(dst, value);
                previous.release();
            },
            .MatchType => {
                const slot = self.readByte();
                const ty = self.readByte();
                const value = self.getScratch(slot);
                const matches = switch (ty) {
                    0 => value.isDynType(.Array),
                    1 => value.isDynType(.Object),
                    2 => value.isType(.String) or value.isType(.InputSubstring) or value.isDynType(.String),
                    // Class 3 is the range-value gate (number or single
                    // codepoint) that a bound-less range needs; it is not a
                    // ValueType and does not round-trip to one.
                    3 => value.isRangeValue(self.*),
                    else => @panic("Internal Error: unsupported MatchType operand"),
                };
                if (!matches) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchCount => {
                // Count by runtime type — array elements, object members,
                // or string bytes — and compare against the immediate
                // (mode 0: equal; mode 1: at least). Any other type, or a
                // failed comparison, takes the fail jump. The emitted
                // is_type test usually pins the type first.
                const slot = self.readByte();
                const n = self.readByte();
                const mode = self.readByte();
                const value = self.getScratch(slot);
                const count: ?usize = if (value.isDynType(.Array))
                    value.asDyn().asArray().elems.items.len
                else if (value.isDynType(.Object))
                    value.asDyn().asObject().members.count()
                else if (try value.stringBytes(self)) |bytes|
                    bytes.len
                else
                    null;
                const ok = if (count) |c|
                    (if (mode != 0) c >= n else c == n)
                else
                    false;
                if (!ok) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchElem => {
                const dst = self.readByte();
                const src = self.readByte();
                const index = self.readByte();
                const back = self.readByte();
                const elems = self.getScratch(src).asDyn().asArray().elems.items;
                const value = if (back != 0) elems[elems.len - 1 - index] else elems[index];
                const previous = self.getScratch(dst);
                value.retain();
                self.setScratch(dst, value);
                previous.release();
            },
            .MatchRepeatInit => {
                // Array- or object-repeat loop entry: the value must be an
                // array (elements) or object (members) whose length is a
                // multiple of the chunk length. The chunk count goes into the
                // count register for the count steps; the base register is
                // primed to -L so the first MatchRepeatNext advances it to
                // chunk 0 (arrays only — the object shape is all-placeholder
                // and never loops).
                const src = self.readByte();
                const len: f64 = @floatFromInt(self.readByte());
                const count_dst = self.readByte();
                const base = self.readByte();
                const value = self.getScratch(src);
                const container_len: usize = if (value.isDynType(.Array))
                    value.asDyn().asArray().elems.items.len
                else if (value.isDynType(.Object))
                    value.asDyn().asObject().members.count()
                else {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                };
                const chunk_len: usize = @intFromFloat(len);
                if (container_len % chunk_len != 0) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const prev_count = self.getScratch(count_dst);
                self.setScratch(count_dst, Elem.numberFloat(@floatFromInt(container_len / chunk_len)));
                prev_count.release();
                const prev_base = self.getScratch(base);
                self.setScratch(base, Elem.numberFloat(-len));
                prev_base.release();
            },
            .MatchRepeatNext => {
                // Loop head: advance the base by the chunk element length,
                // exit to the done target once the array is exhausted, and
                // otherwise materialize the chunk slice src[base..base+L]
                // into chunk_dst for the chunk sub-pattern. The fresh
                // array's creator handle moves into chunk_dst.
                const src = self.readByte();
                const base = self.readByte();
                const len_byte = self.readByte();
                const chunk_dst = self.readByte();
                const offset = self.readShort();
                const len: usize = len_byte;
                const next_base = self.getScratch(base).asFloat() + @as(f64, @floatFromInt(len));
                self.setScratch(base, Elem.numberFloat(next_base));
                const elems = self.getScratch(src).asDyn().asArray().elems.items;
                if (next_base >= @as(f64, @floatFromInt(elems.len))) {
                    self.cur_frame.ip += offset;
                    return;
                }
                const start: usize = @intFromFloat(next_base);
                const chunk_arr = try Elem.DynElem.Array.create(self, len);
                try self.pushTempDyn(&chunk_arr.dyn);
                for (elems[start .. start + len]) |elem| elem.retain();
                try chunk_arr.elems.appendSlice(self.gc.allocator(), elems[start .. start + len]);
                self.dropTempDyn();
                const previous = self.getScratch(chunk_dst);
                self.setScratch(chunk_dst, chunk_arr.dyn.elem());
                previous.release();
            },
            .MatchSlice => {
                // The middle of an array (fresh Array) or string
                // (InputSubstring range when possible, else a copy); the
                // emitted is_type test pins which. The new value's
                // creator handle moves into the dst register.
                const dst = self.readByte();
                const src = self.readByte();
                const front = self.readByte();
                const back = self.readByte();
                const value = self.getScratch(src);
                const sliced: Elem = if (value.isDynType(.Array)) blk: {
                    const elems = value.asDyn().asArray().elems.items;
                    const slice = elems[front .. elems.len - back];
                    const array = try Elem.DynElem.Array.create(self, slice.len);
                    try self.pushTempDyn(&array.dyn);
                    for (slice) |elem| elem.retain();
                    try array.elems.appendSlice(self.gc.allocator(), slice);
                    self.dropTempDyn();
                    break :blk array.dyn.elem();
                } else blk: {
                    const bytes = (try value.stringBytes(self)).?;
                    const rest = bytes[front .. bytes.len - back];
                    if (value.isType(.InputSubstring)) {
                        const start = value.asInputSubstring().start;
                        if (try Elem.inputSubstringFromRange(start + front, start + bytes.len - back)) |elem| {
                            break :blk elem;
                        }
                    }
                    const str = try Elem.DynElem.String.copy(self, rest);
                    break :blk str.dyn.elem();
                };
                const previous = self.getScratch(dst);
                self.setScratch(dst, sliced);
                previous.release();
            },
            .MatchObjectRest => {
                // The src object minus the const keys named by the key-list
                // constant (which the preceding MatchKey steps claimed).
                // Fresh object; creator handle into dst. Search-claimed keys
                // live in a claim array, subtracted by MatchClaimRest.
                const dst = self.readByte();
                const src = self.readByte();
                const constant_idx = self.readShort();
                const keys = self.getConstant(constant_idx).asDyn().asArray().elems.items;
                const src_object = self.getScratch(src).asDyn().asObject();
                const rest = try Elem.DynElem.Object.create(self, src_object.members.count());
                try self.pushTempDyn(&rest.dyn);
                var iter = src_object.members.iterator();
                outer: while (iter.next()) |entry| {
                    const sid = entry.key_ptr.*;
                    for (keys) |key| {
                        if (key.asString() == sid) continue :outer;
                    }
                    try rest.put(self, sid, entry.value_ptr.*);
                }
                self.dropTempDyn();
                const previous = self.getScratch(dst);
                self.setScratch(dst, rest.dyn.elem());
                previous.release();
            },
            .MatchIterInit => {
                const cursor = self.readByte();
                const previous = self.getScratch(cursor);
                self.setScratch(cursor, Elem.numberFloat(0));
                previous.release();
            },
            .MatchStrEnd => {
                // The string under test must start (front) or end (back)
                // with the literal. Absorbs the former MatchStrPrefix and
                // MatchStrSuffix via the direction byte.
                const slot = self.readByte();
                const back = self.readByte() != 0;
                const constant_idx = self.readShort();
                const value = self.getScratch(slot);
                const literal = self.strings.get(self.getConstant(constant_idx).asString());
                const bytes = (try value.stringBytes(self)).?;
                const end = if (back) bytes[bytes.len -| literal.len..] else bytes[0..@min(literal.len, bytes.len)];
                if (bytes.len < literal.len or !std.mem.eql(u8, end, literal)) {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchSpanInit => {
                // Span-cursor loop entry: front = 0, end = the span length —
                // byte length for a string, element count for an array. The
                // preceding MatchType fixes src's type.
                const src = self.readByte();
                const front = self.readByte();
                const end = self.readByte();
                const value = self.getScratch(src);
                const len: usize = if (value.isDynType(.Array))
                    value.asDyn().asArray().elems.items.len
                else
                    (try value.stringBytes(self)).?.len;
                const prev_front = self.getScratch(front);
                self.setScratch(front, Elem.numberFloat(0));
                prev_front.release();
                const prev_end = self.getScratch(end);
                self.setScratch(end, Elem.numberFloat(@floatFromInt(len)));
                prev_end.release();
            },
            .MatchStrLit => {
                // Compare the literal at the cursor, bounded by the opposite
                // cursor, then advance (front, back=0) or retreat (end,
                // back=1) the cursor. A misfit or byte mismatch fails.
                const src = self.readByte();
                const cursor = self.readByte();
                const opp = self.readByte();
                const back = self.readByte() != 0;
                const constant_idx = self.readShort();
                const literal = self.strings.get(self.getConstant(constant_idx).asString());
                const bytes = (try self.getScratch(src).stringBytes(self)).?;
                const cur: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                const opp_v: usize = @intFromFloat(self.getScratch(opp).asFloat());
                const new_cursor = matchStrChomp(bytes, cur, opp_v, back, literal) orelse {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                };
                const prev = self.getScratch(cursor);
                self.setScratch(cursor, Elem.numberFloat(@floatFromInt(new_cursor)));
                prev.release();
            },
            .MatchSpanVal => {
                // The preceding expression left the segment value on the
                // stack; compare it at the cursor by the span's runtime type:
                // a string chomp of its stringified bytes (like MatchStrLit),
                // or an element-wise array compare, advancing the cursor by
                // the segment's length.
                const src = self.readByte();
                const cursor = self.readByte();
                const opp = self.readByte();
                const back = self.readByte() != 0;
                const evaluated = self.pop();
                const span = self.getScratch(src);
                if (span.isDynType(.Array)) {
                    const src_elems = span.asDyn().asArray().elems.items;
                    const seg: ?[]const Elem = if (evaluated.isDynType(.Array))
                        evaluated.asDyn().asArray().elems.items
                    else if (evaluated.isConst(.Null))
                        &[_]Elem{}
                    else
                        null;
                    const cur: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                    const opp_v: usize = @intFromFloat(self.getScratch(opp).asFloat());
                    const new_cursor = if (seg) |s| matchArrayChomp(self.*, src_elems, cur, opp_v, back, s) else null;
                    if (new_cursor) |nc| {
                        const prev = self.getScratch(cursor);
                        self.setScratch(cursor, Elem.numberFloat(@floatFromInt(nc)));
                        prev.release();
                    }
                    self.reclaimElem(evaluated);
                    if (new_cursor == null) self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const str_elem = try evaluated.toString(self);
                var rooted = false;
                if (str_elem.isType(.Dyn)) {
                    try self.pushTempDyn(str_elem.asDyn());
                    rooted = true;
                }
                const literal = (try str_elem.stringBytes(self)).?;
                const bytes = (try self.getScratch(src).stringBytes(self)).?;
                const cur: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                const opp_v: usize = @intFromFloat(self.getScratch(opp).asFloat());
                const new_cursor = matchStrChomp(bytes, cur, opp_v, back, literal);
                if (new_cursor) |nc| {
                    const prev = self.getScratch(cursor);
                    self.setScratch(cursor, Elem.numberFloat(@floatFromInt(nc)));
                    prev.release();
                }
                if (rooted) self.dropTempDyn();
                self.reclaimElem(evaluated);
                if (new_cursor == null) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchStrChar => {
                // Decode one codepoint at the cursor — forward by lead-byte
                // sequence length, backward by walking continuation bytes to
                // a lead byte that lands exactly on the cursor — materialize
                // it as a string into dst, and advance/retreat. Empty range
                // or malformed UTF-8 fails. The range test follows.
                const dst = self.readByte();
                const src = self.readByte();
                const cursor = self.readByte();
                const opp = self.readByte();
                const back = self.readByte() != 0;
                const bytes = (try self.getScratch(src).stringBytes(self)).?;
                const cur: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                const opp_v: usize = @intFromFloat(self.getScratch(opp).asFloat());
                const span = matchStrChar(bytes, cur, opp_v, back) orelse {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                };
                var buf: [4]u8 = undefined;
                const char_bytes = bytes[span.start..span.end];
                @memcpy(buf[0..char_bytes.len], char_bytes);
                const char_elem = Elem.string(try self.strings.insert(buf[0..char_bytes.len]));
                const prev_dst = self.getScratch(dst);
                self.setScratch(dst, char_elem);
                prev_dst.release();
                const prev_cursor = self.getScratch(cursor);
                self.setScratch(cursor, Elem.numberFloat(@floatFromInt(span.next_cursor)));
                prev_cursor.release();
            },
            .MatchSpanRest => {
                // The span [front..end) — the solvable's raw range — into
                // dst: a fresh array slice when src is an array, else the
                // string substring (an InputSubstring range when the source
                // is one, else a fresh copy).
                const dst = self.readByte();
                const src = self.readByte();
                const front = self.readByte();
                const end = self.readByte();
                const value = self.getScratch(src);
                const start: usize = @intFromFloat(self.getScratch(front).asFloat());
                const stop: usize = @intFromFloat(self.getScratch(end).asFloat());
                const rest: Elem = blk: {
                    if (value.isDynType(.Array)) {
                        const slice = try Elem.DynElem.Array.copy(self, value.asDyn().asArray().elems.items[start..stop]);
                        break :blk slice.dyn.elem();
                    }
                    const bytes = (try value.stringBytes(self)).?;
                    if (value.isType(.InputSubstring)) {
                        const base = value.asInputSubstring().start;
                        if (try Elem.inputSubstringFromRange(base + start, base + stop)) |elem| break :blk elem;
                    }
                    const str = try Elem.DynElem.String.copy(self, bytes[start..stop]);
                    break :blk str.dyn.elem();
                };
                const previous = self.getScratch(dst);
                self.setScratch(dst, rest);
                previous.release();
            },
            .MatchSpanChunk => {
                // Slice a fixed-length array chunk at the cursor — forward
                // [cur..cur+len) or backward [cur-len..cur) — failing if it
                // does not fit before the opposite cursor, materialize it as
                // a fresh array into dst, and advance/retreat the cursor. A
                // child window matches the chunk against the structural
                // array-merge part.
                const dst = self.readByte();
                const src = self.readByte();
                const cursor = self.readByte();
                const opp = self.readByte();
                const back = self.readByte() != 0;
                const len = self.readByte();
                const src_elems = self.getScratch(src).asDyn().asArray().elems.items;
                const cur: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                const opp_v: usize = @intFromFloat(self.getScratch(opp).asFloat());
                const start: usize = if (back) blk: {
                    if (cur < opp_v + len) {
                        self.cur_frame.ip = self.current_window_fail;
                        return;
                    }
                    break :blk cur - len;
                } else blk: {
                    if (cur + len > opp_v) {
                        self.cur_frame.ip = self.current_window_fail;
                        return;
                    }
                    break :blk cur;
                };
                const slice = try Elem.DynElem.Array.copy(self, src_elems[start .. start + len]);
                const prev_dst = self.getScratch(dst);
                self.setScratch(dst, slice.dyn.elem());
                prev_dst.release();
                const prev_cursor = self.getScratch(cursor);
                self.setScratch(cursor, Elem.numberFloat(@floatFromInt(if (back) start else start + len)));
                prev_cursor.release();
            },
            .MatchCmp => {
                // Compare the register against a comparand — a module
                // constant, a bound frame local, or another scratch
                // register — and take the fail jump when they differ.
                // Absorbs the former MatchConst (constant), MatchSlot
                // (slot), MatchStrCovered (reg: cursors meeting), and the
                // constant case of MatchGlobal.
                const reg = self.readByte();
                const kind = self.readByte();
                const arg = self.readShort();
                const value = self.getScratch(reg);
                const other = switch (@as(MatchCmpKind, @enumFromInt(kind))) {
                    .constant => self.getConstant(arg),
                    .slot => try self.getBoundLocal(arg),
                    .reg => self.getScratch(@intCast(arg)),
                };
                if (!value.isEql(other, self.*)) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchCast => {
                // Parse src's string bytes into dst as the target type — a
                // number/boolean-merge template solvable, or a JSON
                // document for a structural template solvable (whose parsed
                // container a following child window matches). Empty or
                // ill-typed bytes fail. src == dst is the in-place form
                // used after MatchSpanRest; a whole-string template casts
                // the source value directly.
                const dst = self.readByte();
                const src = self.readByte();
                const ty: MatchCastKind = @enumFromInt(self.readByte());
                const bytes = (try self.getScratch(src).stringBytes(self)).?;
                const cast: ?Elem = switch (ty) {
                    .number => if (bytes.len == 0 or !parsing.isValidNumberString(bytes))
                        null
                    else
                        try Elem.numberStringFromBytes(bytes, self),
                    .boolean => if (std.mem.eql(u8, bytes, "true"))
                        Elem.boolean(true)
                    else if (std.mem.eql(u8, bytes, "false"))
                        Elem.boolean(false)
                    else
                        null,
                    // The parsed dyn moves straight into the rooted match
                    // register; no allocation intervenes to trigger GC.
                    .json => try Elem.parseJson(self, bytes),
                };
                if (cast) |elem| {
                    const previous = self.getScratch(dst);
                    self.setScratch(dst, elem);
                    previous.release();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchKey => {
                const dst = self.readByte();
                const src = self.readByte();
                const constant_idx = self.readShort();
                const sid = self.getConstant(constant_idx).asString();
                const container = self.getScratch(src);
                if (container.isDynType(.Object)) {
                    if (container.asDyn().asObject().members.get(sid)) |value| {
                        const previous = self.getScratch(dst);
                        value.retain();
                        self.setScratch(dst, value);
                        previous.release();
                        return;
                    }
                }
                self.cur_frame.ip = self.current_window_fail;
            },
            .MatchClaimAdd => {
                // Claim a matched member: append its key (a string sid) to
                // the claim array. Later searches in this and following
                // groups skip it, giving both intra-group and cross-group
                // exclusivity.
                const claim = self.readByte();
                const key = self.readByte();
                const claims = self.getScratch(claim).asDyn().asArray();
                const key_elem = self.getScratch(key);
                key_elem.retain();
                try claims.elems.append(self.gc.allocator(), key_elem);
            },
            .MatchClaimScan => {
                // Member search: scan src's members from the
                // cursor for the first key not already in the claim array,
                // project its key and value, and advance the cursor. On
                // exhaustion take the window fail. The successful match is
                // claimed later by MatchClaimAdd, after the value window; a
                // value-rejected candidate stays unclaimed and the advanced
                // cursor skips it on retry.
                const key_dst = self.readByte();
                const val_dst = self.readByte();
                const src = self.readByte();
                const cursor = self.readByte();
                const claim = self.readByte();
                const object = self.getScratch(src).asDyn().asObject();
                const member_keys = object.members.keys();
                const member_values = object.members.values();
                const claims = self.getScratch(claim).asDyn().asArray().elems.items;
                var idx: usize = @intFromFloat(self.getScratch(cursor).asFloat());
                outer: while (idx < member_keys.len) : (idx += 1) {
                    const sid = member_keys[idx];
                    for (claims) |c| {
                        if (c.asString() == sid) continue :outer;
                    }
                    const key_elem = Elem.string(sid);
                    const prev_key = self.getScratch(key_dst);
                    key_elem.retain();
                    self.setScratch(key_dst, key_elem);
                    prev_key.release();

                    const val_elem = member_values[idx];
                    const prev_val = self.getScratch(val_dst);
                    val_elem.retain();
                    self.setScratch(val_dst, val_elem);
                    prev_val.release();

                    self.setScratch(cursor, Elem.numberFloat(@floatFromInt(idx + 1)));
                    break;
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchClaimKey => {
                // Member probe by the popped known key (a search pair's
                // bound local or global, a repeat group's const key, or the
                // rebound read of a binding key). Fails to the window when
                // the key is absent or already claimed — a re-probe of a
                // claimed key thus fails, mirroring the exclusive claim.
                const key_dst = self.readByte();
                const val_dst = self.readByte();
                const src = self.readByte();
                const claim = self.readByte();
                const key = self.pop();
                var rooted = false;
                if (key.isType(.Dyn)) {
                    try self.pushTempDyn(key.asDyn());
                    rooted = true;
                }
                const sid = (try key.getOrPutSid(self)) orelse {
                    if (rooted) self.dropTempDyn();
                    self.reclaimElem(key);
                    return self.runtimeError("Object key must be a string", .{});
                };
                const object = self.getScratch(src).asDyn().asObject();
                const claims = self.getScratch(claim).asDyn().asArray().elems.items;
                const claimed = for (claims) |c| {
                    if (c.asString() == sid) break true;
                } else false;
                const member = object.members.get(sid);
                if (rooted) self.dropTempDyn();
                self.reclaimElem(key);
                if (claimed or member == null) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const key_elem = Elem.string(sid);
                const prev_key = self.getScratch(key_dst);
                key_elem.retain();
                self.setScratch(key_dst, key_elem);
                prev_key.release();

                const val_elem = member.?;
                const prev_val = self.getScratch(val_dst);
                val_elem.retain();
                self.setScratch(val_dst, val_elem);
                prev_val.release();
            },
            .MatchClaimSeed => {
                // Start a claim array from the const-key list constant so
                // the searches skip those members and the rest excludes
                // them; an empty list starts an empty array. The register
                // holds the sole reference; frame unwind reclaims it.
                const dst = self.readByte();
                const constant_idx = self.readShort();
                const keys = self.getConstant(constant_idx).asDyn().asArray().elems.items;
                const claims = try Elem.DynElem.Array.create(self, keys.len);
                try self.pushTempDyn(&claims.dyn);
                for (keys) |key| key.retain();
                try claims.elems.appendSlice(self.gc.allocator(), keys);
                self.dropTempDyn();
                const previous = self.getScratch(dst);
                self.setScratch(dst, claims.dyn.elem());
                previous.release();
            },
            .MatchClaimObject => {
                // Claim an evaluated object part against src: every member
                // of the popped part must be an unclaimed member of src with
                // an equal value; each verified key joins the claim array.
                // Fails to the window on a non-object part, a missing or
                // unequal member, or an already-claimed key (parts claim
                // exclusively, like repeat groups). A failure's partial
                // claims are dead: every re-entry reseeds the array.
                const claim = self.readByte();
                const src = self.readByte();
                const part = self.pop();
                if (!part.isDynType(.Object)) {
                    part.release();
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                // Root the popped part: the claim-array appends below may
                // allocate and run the collector.
                try self.pushTempDyn(part.asDyn());
                const part_object = part.asDyn().asObject();
                const src_object = self.getScratch(src).asDyn().asObject();
                const claims = self.getScratch(claim).asDyn().asArray();
                var iter = part_object.members.iterator();
                while (iter.next()) |entry| {
                    const sid = entry.key_ptr.*;
                    const claimed = for (claims.elems.items) |c| {
                        if (c.asString() == sid) break true;
                    } else false;
                    const member = src_object.members.get(sid);
                    if (claimed or member == null or !member.?.isEql(entry.value_ptr.*, self.*)) {
                        self.dropTempDyn();
                        part.release();
                        self.cur_frame.ip = self.current_window_fail;
                        return;
                    }
                    const key_elem = Elem.string(sid);
                    key_elem.retain();
                    try claims.elems.append(self.gc.allocator(), key_elem);
                }
                self.dropTempDyn();
                part.release();
            },
            .MatchClaimCount => {
                // Object-merge repeat count: the group count is the object's
                // members past the seeded const keys divided by the chunk's
                // pair count. Fails to the window when src is not an object,
                // the seed exceeds the members, or the division is inexact.
                const src = self.readByte();
                const pair_len: usize = self.readByte();
                const seed: usize = self.readByte();
                const count_dst = self.readByte();
                const value = self.getScratch(src);
                if (!value.isDynType(.Object)) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const members = value.asDyn().asObject().members.count();
                if (members < seed or pair_len == 0 or (members - seed) % pair_len != 0) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const count = (members - seed) / pair_len;
                const previous = self.getScratch(count_dst);
                self.setScratch(count_dst, Elem.numberFloat(@floatFromInt(count)));
                previous.release();
            },
            .MatchCountLoad => {
                // Pop the evaluated count product and write the target claim
                // size (the claim array's current length + count * pair_len)
                // for MatchClaimDoneCount. The array reaches this size after
                // `count` further groups claim pair_len members each. A
                // non-integer or negative count fails.
                const dst = self.readByte();
                const pair_len: usize = self.readByte();
                const claim = self.readByte();
                const count_elem = self.pop();
                if (!count_elem.isNumber()) {
                    return self.runtimeError("Repeat count must be a number", .{});
                }
                const count_float = if (count_elem.isFloat())
                    count_elem.asFloat()
                else
                    count_elem.asNumberString().toNumberFloat(self.strings).asFloat();
                self.reclaimElem(count_elem);
                if (count_float < 0 or @trunc(count_float) != count_float) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const base = self.getScratch(claim).asDyn().asArray().elems.items.len;
                const target = base + @as(usize, @intFromFloat(count_float)) * pair_len;
                const previous = self.getScratch(dst);
                self.setScratch(dst, Elem.numberFloat(@floatFromInt(target)));
                previous.release();
            },
            .MatchClaimDoneCount => {
                // Count-driven group-loop head: exit once the claim array
                // reaches the target size in the count register. Every group
                // adds pair_len keys, so the array meets the target after the
                // scheduled count of groups.
                const claim = self.readByte();
                const count_reg = self.readByte();
                const offset = self.readShort();
                const claimed = self.getScratch(claim).asDyn().asArray().elems.items.len;
                const target: usize = @intFromFloat(self.getScratch(count_reg).asFloat());
                if (claimed >= target) {
                    self.cur_frame.ip += offset;
                }
            },
            .MatchClaimRest => {
                // The object-merge rest: a fresh object of src's members
                // whose keys the claim array does not hold. Creator handle
                // into dst.
                const dst = self.readByte();
                const src = self.readByte();
                const claim = self.readByte();
                const claims = self.getScratch(claim).asDyn().asArray().elems.items;
                const src_object = self.getScratch(src).asDyn().asObject();
                const rest = try Elem.DynElem.Object.create(self, src_object.members.count());
                try self.pushTempDyn(&rest.dyn);
                var iter = src_object.members.iterator();
                outer: while (iter.next()) |entry| {
                    const sid = entry.key_ptr.*;
                    for (claims) |c| {
                        if (c.asString() == sid) continue :outer;
                    }
                    try rest.put(self, sid, entry.value_ptr.*);
                }
                self.dropTempDyn();
                const previous = self.getScratch(dst);
                self.setScratch(dst, rest.dyn.elem());
                previous.release();
            },
            .MatchMergeNum => {
                // The residual of a number merge: src minus the folded
                // constant parts, into dst. The negate flag flips the sign
                // for a leftover part under an odd negation count. Fails
                // when src isn't a number.
                const dst = self.readByte();
                const src = self.readByte();
                const constant_idx = self.readShort();
                const negate = self.readByte() != 0;
                const value = self.getScratch(src);
                var src_float: f64 = undefined;
                if (value.isFloat()) {
                    src_float = value.asFloat();
                } else if (value.isType(.NumberString)) {
                    src_float = value.asNumberString().toNumberFloat(self.strings).asFloat();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const sum = self.getConstant(constant_idx).asFloat();
                const residual = if (negate) sum - src_float else src_float - sum;
                const previous = self.getScratch(dst);
                self.setScratch(dst, Elem.numberFloat(residual));
                previous.release();
            },
            .MatchSubtractEval => {
                // The residual of a number merge with runtime-evaluated
                // parts: the preceding expression left one summed part on
                // the stack; subtract it from src into dst. Chained once
                // per runtime part after MatchMergeNum folds the constants.
                // Fails when src or the popped part isn't a number.
                const dst = self.readByte();
                const src = self.readByte();
                const part = self.pop();
                const src_value = self.getScratch(src);
                if (numberFloatOf(src_value, self.strings)) |src_float| {
                    if (numberFloatOf(part, self.strings)) |part_float| {
                        const previous = self.getScratch(dst);
                        self.setScratch(dst, Elem.numberFloat(src_float - part_float));
                        previous.release();
                        part.release();
                    } else {
                        part.release();
                        self.cur_frame.ip = self.current_window_fail;
                    }
                } else {
                    part.release();
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchMergeEval => {
                // The residual of an untyped merge: the preceding expression
                // left the merged non-solvable parts on the stack; dispatch on
                // their runtime type (the merge type) to compute X such that
                // merge(part, X) == src, into dst. When back is 0 (`part + X`)
                // the parts are a prefix of src; when 1 (`X + part`) a suffix
                // stripped from the end (string/array; number/bool/object are
                // order-independent). Fails on a type or prefix/suffix mismatch.
                const dst = self.readByte();
                const src = self.readByte();
                const back = self.readByte() != 0;
                const part = self.pop();
                const value = self.getScratch(src);
                const residual = self.mergeResidual(value, part, back) catch |err| {
                    part.release();
                    return err;
                };
                part.release();
                if (residual) |r| {
                    const previous = self.getScratch(dst);
                    self.setScratch(dst, r);
                    previous.release();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchDivideEval => {
                // The residual of a repeat count factored as a product: the
                // preceding expression left one evaluable factor on the
                // stack; divide src (the derived count) by it into dst.
                // Chained once per scalar factor before the unbound factor
                // binds the leftover. Fails when src or the popped factor
                // isn't a number, when the factor is zero, or when the
                // division is not exact.
                const dst = self.readByte();
                const src = self.readByte();
                const factor = self.pop();
                const src_value = self.getScratch(src);
                if (numberFloatOf(src_value, self.strings)) |src_float| {
                    if (numberFloatOf(factor, self.strings)) |factor_float| {
                        factor.release();
                        if (factor_float != 0 and @rem(src_float, factor_float) == 0) {
                            const previous = self.getScratch(dst);
                            self.setScratch(dst, Elem.numberFloat(src_float / factor_float));
                            previous.release();
                        } else {
                            self.cur_frame.ip = self.current_window_fail;
                        }
                    } else {
                        factor.release();
                        self.cur_frame.ip = self.current_window_fail;
                    }
                } else {
                    factor.release();
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchMergeBool => {
                // Booleans merge by logical OR, so the residual of a merge
                // is the scrutinee with the folded static truth claimed
                // out: `scrutinee AND NOT static`, into dst. Fails when the
                // scrutinee isn't a bool, or when the static part claims a
                // truth the scrutinee lacks (static true, scrutinee false).
                const dst = self.readByte();
                const src = self.readByte();
                const constant_idx = self.readShort();
                const value = self.getScratch(src);
                const value_true = value.isConst(.True);
                if (!value_true and !value.isConst(.False)) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const static_true = self.getConstant(constant_idx).isConst(.True);
                if (static_true and !value_true) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const previous = self.getScratch(dst);
                self.setScratch(dst, Elem.boolean(value_true and !static_true));
                previous.release();
            },
            .MatchEval => {
                // The preceding expression left its result on the stack;
                // compare it against the place register, mirroring the plan
                // interpreter's eval_eq. Roots a Dyn result while comparing,
                // like MatchGlobal.
                const register = self.readByte();
                _ = self.readByte();
                const evaluated = self.pop();
                var rooted = false;
                if (evaluated.isType(.Dyn)) {
                    try self.pushTempDyn(evaluated.asDyn());
                    rooted = true;
                }
                const value = self.getScratch(register);
                const matched = value.isEql(evaluated, self.*);
                if (rooted) self.dropTempDyn();
                if (!matched) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchBind => {
                const local = self.readByte();
                const src = self.readByte();
                const value = self.getScratch(src);
                const previous = self.getLocal(local);
                value.retain();
                self.setLocal(local, value);
                previous.release();
            },
            .MatchBound => {
                // One end of a range: compare the value register against a
                // constant or bound-local bound. The range-value type gate
                // is carried by this comparison (compareRangeBound rejects
                // non-number, non-codepoint values); a bound-less range
                // gets an explicit MatchType class-3 gate instead.
                const reg = self.readByte();
                const is_upper = self.readByte() != 0;
                const kind: RangeLimitKind = @enumFromInt(self.readByte());
                const arg = self.readShort();
                const limit = switch (kind) {
                    .const_elem => self.getConstant(arg),
                    .read => try self.getBoundLocal(arg),
                    else => @panic("Internal Error: unsupported MatchBound kind"),
                };
                const value = self.getScratch(reg);
                const matched = try self.compareRangeBound(limit, value, is_upper);
                if (!matched) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchRangeBound => {
                // The preceding expression left the evaluated bound on the
                // stack; compare it against the value register as one end
                // of the range. Roots a Dyn result while comparing, like
                // MatchEval.
                const slot = self.readByte();
                const is_upper = self.readByte() != 0;
                const evaluated = self.pop();
                var rooted = false;
                if (evaluated.isType(.Dyn)) {
                    try self.pushTempDyn(evaluated.asDyn());
                    rooted = true;
                }
                const value = self.getScratch(slot);
                const matched = try self.compareRangeBound(evaluated, value, is_upper);
                if (rooted) self.dropTempDyn();
                if (!matched) self.cur_frame.ip = self.current_window_fail;
            },
            .MatchRepeatValue => {
                // The preceding expression left the repeat's pattern value
                // on the stack; derive how many times it repeats to make
                // src's value and write that count into the destination
                // register for the count steps that follow. Chunk checks
                // scan the value in place — nothing is materialized.
                const src = self.readByte();
                const count_dst = self.readByte();
                const pattern_value = self.pop();
                var rooted = false;
                if (pattern_value.isType(.Dyn)) {
                    try self.pushTempDyn(pattern_value.asDyn());
                    rooted = true;
                }
                const value = self.getScratch(src);
                const derived = try self.repeatValueCount(value, pattern_value);
                if (rooted) self.dropTempDyn();
                self.reclaimElem(pattern_value);
                if (derived) |count| {
                    const previous = self.getScratch(count_dst);
                    self.setScratch(count_dst, Elem.numberFloat(count));
                    previous.release();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchRepeatChunk => {
                // The preceding expression left the repeat count on the
                // stack; check src's value is one chunk repeated that many
                // times and write the representative — string substring,
                // fresh array, or number quotient — into the destination
                // register for the pattern steps that follow. A count of 0
                // matches the type's empty value, with the empty value as
                // the representative.
                const src = self.readByte();
                const chunk_dst = self.readByte();
                const count_elem = self.pop();
                if (!count_elem.isNumber()) {
                    return self.runtimeError("Repeat count must be a number", .{});
                }
                const count_float = if (count_elem.isFloat())
                    count_elem.asFloat()
                else
                    count_elem.asNumberString().toNumberFloat(self.strings).asFloat();
                self.reclaimElem(count_elem);
                if (count_float < 0 or @trunc(count_float) != count_float) {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                }
                const count: usize = @intFromFloat(count_float);
                const value = self.getScratch(src);
                const chunk_elem: Elem = if (try value.stringBytes(self)) |bytes| blk: {
                    const chunk_len = if (count == 0) 0 else bytes.len / count;
                    if (count == 0) {
                        if (bytes.len != 0) {
                            self.cur_frame.ip = self.current_window_fail;
                            return;
                        }
                    } else {
                        if (bytes.len % count != 0) {
                            self.cur_frame.ip = self.current_window_fail;
                            return;
                        }
                        var i: usize = 1;
                        while (i < count) : (i += 1) {
                            const start = i * chunk_len;
                            if (!std.mem.eql(u8, bytes[0..chunk_len], bytes[start .. start + chunk_len])) {
                                self.cur_frame.ip = self.current_window_fail;
                                return;
                            }
                        }
                    }
                    if (value.isType(.InputSubstring)) {
                        const start = value.asInputSubstring().start;
                        if (try Elem.inputSubstringFromRange(start, start + chunk_len)) |elem| {
                            break :blk elem;
                        }
                    }
                    const str = try Elem.DynElem.String.copy(self, bytes[0..chunk_len]);
                    break :blk str.dyn.elem();
                } else if (value.isDynType(.Array)) blk: {
                    const elems = value.asDyn().asArray().elems.items;
                    const chunk_len = if (count == 0) 0 else elems.len / count;
                    if (count == 0) {
                        if (elems.len != 0) {
                            self.cur_frame.ip = self.current_window_fail;
                            return;
                        }
                    } else {
                        if (elems.len % count != 0) {
                            self.cur_frame.ip = self.current_window_fail;
                            return;
                        }
                        var i: usize = 1;
                        while (i < count) : (i += 1) {
                            const start = i * chunk_len;
                            for (0..chunk_len) |j| {
                                if (!elems[start + j].isEql(elems[j], self.*)) {
                                    self.cur_frame.ip = self.current_window_fail;
                                    return;
                                }
                            }
                        }
                    }
                    const array = try Elem.DynElem.Array.create(self, chunk_len);
                    try self.pushTempDyn(&array.dyn);
                    for (elems[0..chunk_len]) |elem| elem.retain();
                    try array.elems.appendSlice(self.gc.allocator(), elems[0..chunk_len]);
                    self.dropTempDyn();
                    break :blk array.dyn.elem();
                } else if (value.isNumber()) blk: {
                    if (count == 0) {
                        self.cur_frame.ip = self.current_window_fail;
                        return;
                    }
                    const value_float = if (value.isFloat())
                        value.asFloat()
                    else
                        value.asNumberString().toNumberFloat(self.strings).asFloat();
                    break :blk Elem.numberFloat(value_float / count_float);
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                    return;
                };
                const previous = self.getScratch(chunk_dst);
                self.setScratch(chunk_dst, chunk_elem);
                previous.release();
            },
            .MatchRepeatRange => {
                // Scan src's string codepoint by codepoint against the
                // range bounds and write the codepoint count into the
                // destination register for the count steps that follow.
                // An invalid sequence or out-of-range codepoint takes the
                // fail jump. Bounds are the non-evaluated range-bound
                // subset (none/const/read).
                const src = self.readByte();
                const dst = self.readByte();
                const lower_kind: RangeLimitKind = @enumFromInt(self.readByte());
                const lower_arg = self.readShort();
                const upper_kind: RangeLimitKind = @enumFromInt(self.readByte());
                const upper_arg = self.readShort();
                const value = self.getScratch(src);
                const scanned: ?usize = blk: {
                    const bytes = (try value.stringBytes(self)) orelse break :blk null;
                    const lower = try self.repeatRangeCodepoint(lower_kind, lower_arg);
                    const upper = try self.repeatRangeCodepoint(upper_kind, upper_arg);
                    var count: usize = 0;
                    var byte_index: usize = 0;
                    while (byte_index < bytes.len) {
                        const byte_len = unicode.utf8ByteSequenceLength(bytes[byte_index]) catch break :blk null;
                        if (byte_index + byte_len > bytes.len) break :blk null;
                        const codepoint = parsing.utf8Decode(bytes[byte_index .. byte_index + byte_len]) orelse break :blk null;
                        if (lower) |l| if (codepoint < l) break :blk null;
                        if (upper) |u| if (codepoint > u) break :blk null;
                        count += 1;
                        byte_index += byte_len;
                    }
                    break :blk count;
                };
                if (scanned) |count| {
                    const previous = self.getScratch(dst);
                    self.setScratch(dst, Elem.numberFloat(@floatFromInt(count)));
                    previous.release();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchRepeatRangeDivide => {
                // Solve a range count factor in a count product: src holds
                // the residual count T (the scalar factors already divided
                // out). Find the greedy (largest) repetition count r in
                // [lo, min(hi, T)] that divides T, and write the quotient
                // N = T / r into dst for the following MatchBind. lo
                // defaults to the implicit 0 and hi may be open (unbounded
                // above). Fails the window when no such r exists.
                const src = self.readByte();
                const dst = self.readByte();
                const lower_kind: RangeLimitKind = @enumFromInt(self.readByte());
                const lower_arg = self.readShort();
                const upper_kind: RangeLimitKind = @enumFromInt(self.readByte());
                const upper_arg = self.readShort();
                const value = self.getScratch(src);
                const solved: ?f64 = blk: {
                    const t_float = numberFloatOf(value, self.strings) orelse break :blk null;
                    if (t_float < 0 or @trunc(t_float) != t_float) break :blk null;
                    const total: i64 = @intFromFloat(t_float);
                    const lo_bound = try self.repeatRangeCountBound(lower_kind, lower_arg);
                    const hi_bound = try self.repeatRangeCountBound(upper_kind, upper_arg);
                    // A zero residual is zero outer repetitions (N = 0); the
                    // inner unit is never instantiated.
                    if (total == 0) break :blk 0;
                    // r must be a positive integer that divides T; N = T / r
                    // is at least 1, so r is capped at T even when hi is
                    // open or huge.
                    var lo: i64 = if (lo_bound) |l| @intFromFloat(@ceil(l)) else 0;
                    if (lo < 1) lo = 1;
                    var hi: i64 = total;
                    if (hi_bound) |h| {
                        const floored: i64 = @intFromFloat(@floor(h));
                        if (floored < hi) hi = floored;
                    }
                    var r: i64 = hi;
                    while (r >= lo) : (r -= 1) {
                        if (@rem(total, r) == 0) break :blk @floatFromInt(@divExact(total, r));
                    }
                    break :blk null;
                };
                if (solved) |n| {
                    const previous = self.getScratch(dst);
                    self.setScratch(dst, Elem.numberFloat(n));
                    previous.release();
                } else {
                    self.cur_frame.ip = self.current_window_fail;
                }
            },
            .MatchFail => {
                const value = self.peek(0);
                if (value.isSuccess()) self.recordPatternFailure(value);
                _ = self.popConsumed(.MatchFail);
                try self.pushFailure();
            },
            .MatchWindowEnter => {
                // Open a fresh window: save the enclosing base and fail_ip,
                // record this window's shared fail block, then append
                // `width` placeholders (singleton underscore var, no
                // retain) for this match's places and scratch pool.
                const width = self.readByte();
                const fail_offset = self.readShort();
                const fail_ip = self.cur_frame.ip + fail_offset;
                try self.window_bases.append(self.allocator, self.current_window_base);
                try self.window_fails.append(self.allocator, self.current_window_fail);
                self.current_window_base = self.match_regs.items.len;
                self.current_window_fail = fail_ip;
                try self.match_regs.appendNTimes(self.allocator, self.singleton_underscore_var, width);
            },
            .MatchWindowExit => {
                // A root destructure closes when its own window (the base
                // recorded at MatchScrutinee) closes; the match result on the
                // value stack top gives the outcome.
                if (self.config.explain and
                    self.explain_open.items.len > 0 and
                    self.explain_open.getLast() == self.current_window_base)
                {
                    _ = self.explain_open.pop();
                    try self.emitExplainDestructureEnd(self.peek(0).isFailure());
                }
                // Close the innermost window: release its live handles, drop
                // its registers, and restore the enclosing base and fail_ip.
                for (self.match_regs.items[self.current_window_base..]) |reg| {
                    self.reclaimElem(reg);
                }
                self.match_regs.shrinkRetainingCapacity(self.current_window_base);
                self.current_window_base = self.window_bases.pop().?;
                self.current_window_fail = self.window_fails.pop().?;
            },
            .MatchRefail => {
                // Cascade a just-closed child window's failure outward to
                // the enclosing window's shared fail block.
                self.cur_frame.ip = self.current_window_fail;
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
        try self.printPattern();

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
            .match_regs_base = self.match_regs.items.len,
            .saved_window_base = self.current_window_base,
            .saved_window_fail = self.current_window_fail,
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

    // Read/write a match scratch (place/register) slot. Transitional
    // dual-mode: window-mode functions address the innermost match window;
    // frame-mode functions fall back to frame-local slots. Bound-variable
    // operands never route here — they stay frame locals via get/setLocal.
    pub fn getScratch(self: *VM, slot: usize) Elem {
        return self.match_regs.items[self.current_window_base + slot];
    }

    pub fn setScratch(self: *VM, slot: usize, elem: Elem) void {
        self.match_regs.items[self.current_window_base + slot] = elem;
    }

    // Compare `literal` at the cursor within a string template and return
    // the advanced cursor, or null when it doesn't fit before the opposite
    // cursor or the bytes differ. Forward (back=false) chomps from `cur`
    // toward higher indices; backward chomps toward lower indices.
    // Element-wise array analogue of matchStrChomp: compare the segment's
    // elements against src at the cursor (forward from `cur`, or backward
    // ending at `cur`), bounded by the opposite cursor, and return the
    // advanced cursor or null on a misfit or element mismatch.
    fn matchArrayChomp(vm: VM, src: []const Elem, cur: usize, opp: usize, back: bool, seg: []const Elem) ?usize {
        if (back) {
            if (cur < opp + seg.len) return null;
            for (seg, 0..) |elem, i| {
                if (!src[cur - seg.len + i].isEql(elem, vm)) return null;
            }
            return cur - seg.len;
        }
        if (cur + seg.len > opp) return null;
        for (seg, 0..) |elem, i| {
            if (!src[cur + i].isEql(elem, vm)) return null;
        }
        return cur + seg.len;
    }

    fn matchStrChomp(bytes: []const u8, cur: usize, opp: usize, back: bool, literal: []const u8) ?usize {
        if (back) {
            if (cur < opp + literal.len) return null;
            if (!std.mem.eql(u8, bytes[cur - literal.len .. cur], literal)) return null;
            return cur - literal.len;
        }
        if (cur + literal.len > opp) return null;
        if (!std.mem.eql(u8, bytes[cur .. cur + literal.len], literal)) return null;
        return cur + literal.len;
    }

    const CharSpan = struct { start: usize, end: usize, next_cursor: usize };

    // Locate one codepoint at the cursor. Forward: the lead byte at `cur`
    // determines the sequence length, bounded by the opposite cursor.
    // Backward: walk continuation bytes down from `cur` (the end) to a lead
    // byte whose sequence lands exactly on `cur`, mirroring the plan
    // interpreter's segmentStart. Malformed UTF-8 or an empty span is null.
    fn matchStrChar(bytes: []const u8, cur: usize, opp: usize, back: bool) ?CharSpan {
        if (back) {
            var start = cur;
            while (start > opp and cur - start < 4) {
                start -= 1;
                const byte = bytes[start];
                if (byte & 0b1100_0000 != 0b1000_0000) {
                    const len = unicode.utf8ByteSequenceLength(byte) catch return null;
                    if (start + len != cur) return null;
                    if (parsing.utf8Decode(bytes[start..cur]) == null) return null;
                    return .{ .start = start, .end = cur, .next_cursor = start };
                }
            }
            return null;
        }
        if (cur >= opp) return null;
        const len = unicode.utf8ByteSequenceLength(bytes[cur]) catch return null;
        if (cur + len > opp) return null;
        if (parsing.utf8Decode(bytes[cur .. cur + len]) == null) return null;
        return .{ .start = cur, .end = cur + len, .next_cursor = cur + len };
    }

    // A repeat range bound resolved to its codepoint: none is open, and
    // const and read bounds must be strings (runtime error otherwise). A
    // string that isn't a single codepoint imposes no limit.
    fn repeatRangeCountBound(self: *VM, kind: RangeLimitKind, arg: u16) !?f64 {
        const limit: Elem = switch (kind) {
            .none => return null,
            .read => try self.getBoundLocal(arg),
            .const_elem => self.getConstant(arg),
            .global, .bind => unreachable,
        };
        return numberFloatOf(limit, self.strings) orelse
            self.runtimeError("Repeat count range bound must be a number", .{});
    }

    fn repeatRangeCodepoint(self: *VM, kind: RangeLimitKind, arg: u16) !?u21 {
        const limit: Elem = switch (kind) {
            .none => return null,
            .read => try self.getBoundLocal(arg),
            .const_elem => self.getConstant(arg),
            .global, .bind => unreachable,
        };
        if (try limit.stringBytes(self)) |bytes| {
            return parsing.utf8Decode(bytes);
        }
        return self.runtimeError("Range bound must be a codepoint", .{});
    }

    // How many times pattern_value repeats (merges with itself) to make
    // value, or null when it can't. Strings and arrays divide by the
    // pattern's length and compare chunks in place; numbers divide (the
    // count may be fractional or negative); objects and booleans only
    // match themselves, with identity-element canonical counts.
    // The residual X of `part + X` (from_end false) or `X + part` (from_end
    // true) such that merging them equals value, dispatched on part's runtime
    // type (the merge type). For strings and arrays the side
    // matters: the known part is a prefix (from_end false) or a suffix
    // (from_end true), and X takes the other end. Numbers, booleans, and
    // objects merge order-independently, so from_end does not change them.
    // Null on a type mismatch or when part is not on the expected side of
    // value. A fresh string/array/object is created under a temp-dyn root so
    // an allocation mid-build cannot collect it.
    fn mergeResidual(self: *VM, value: Elem, part: Elem, from_end: bool) !?Elem {
        // A null part contributes nothing (the all-null untyped merge): the
        // residual is the whole value.
        if (part.isConst(.Null)) {
            value.retain();
            return value;
        }
        // Number: X = value - part.
        if (part.isNumber()) {
            if (!value.isNumber()) return null;
            return (try value.merge(try part.negateNumber(), self)).?;
        }
        // Boolean (OR merge): a true part forces a true value and leaves the
        // identity false; a false part leaves the whole value.
        if (part.isConst(.True) or part.isConst(.False)) {
            if (!value.isConst(.True) and !value.isConst(.False)) return null;
            if (part.isConst(.True)) {
                if (!value.isConst(.True)) return null;
                return Elem.boolean(false);
            }
            return value;
        }
        // String: part must be a prefix (or suffix); X is the other substring.
        if (try part.stringBytes(self)) |part_bytes| {
            const value_bytes = (try value.stringBytes(self)) orelse return null;
            if (part_bytes.len > value_bytes.len) return null;
            const split = if (from_end) value_bytes.len - part_bytes.len else part_bytes.len;
            const part_at = if (from_end) value_bytes[split..] else value_bytes[0..part_bytes.len];
            if (!std.mem.eql(u8, part_at, part_bytes)) return null;
            const rest_start: usize = if (from_end) 0 else split;
            const rest_end: usize = if (from_end) split else value_bytes.len;
            const rest = value_bytes[rest_start..rest_end];
            if (value.isType(.InputSubstring)) {
                const start = value.asInputSubstring().start;
                if (try Elem.inputSubstringFromRange(start + rest_start, start + rest_end)) |elem| {
                    return elem;
                }
            }
            const str = try Elem.DynElem.String.copy(self, rest);
            return str.dyn.elem();
        }
        // Array: part's elements must be a prefix (or suffix); X is the rest.
        if (value.isDynType(.Array) and part.isDynType(.Array)) {
            const part_elems = part.asDyn().asArray().elems.items;
            const value_elems = value.asDyn().asArray().elems.items;
            if (part_elems.len > value_elems.len) return null;
            const split = if (from_end) value_elems.len - part_elems.len else part_elems.len;
            const part_at = if (from_end) value_elems[split..] else value_elems[0..part_elems.len];
            for (part_elems, 0..) |pe, i| {
                if (!part_at[i].isEql(pe, self.*)) return null;
            }
            const rest = if (from_end) value_elems[0..split] else value_elems[split..];
            const array = try Elem.DynElem.Array.create(self, rest.len);
            try self.pushTempDyn(&array.dyn);
            for (rest) |elem| elem.retain();
            try array.elems.appendSlice(self.gc.allocator(), rest);
            self.dropTempDyn();
            return array.dyn.elem();
        }
        // Object: every key of part must match in value; X is value minus
        // those keys.
        if (value.isDynType(.Object) and part.isDynType(.Object)) {
            const part_object = part.asDyn().asObject();
            const value_object = value.asDyn().asObject();
            var iter = part_object.members.iterator();
            while (iter.next()) |entry| {
                const member = value_object.members.get(entry.key_ptr.*) orelse return null;
                if (!member.isEql(entry.value_ptr.*, self.*)) return null;
            }
            const rest = try Elem.DynElem.Object.create(self, value_object.members.count());
            try self.pushTempDyn(&rest.dyn);
            var value_iter = value_object.members.iterator();
            while (value_iter.next()) |entry| {
                if (part_object.members.get(entry.key_ptr.*) != null) continue;
                try rest.put(self, entry.key_ptr.*, entry.value_ptr.*);
            }
            self.dropTempDyn();
            return rest.dyn.elem();
        }
        return null;
    }

    fn repeatValueCount(self: *VM, value: Elem, pattern_value: Elem) !?f64 {
        if (try pattern_value.stringBytes(self)) |pattern_str| {
            const value_str = (try value.stringBytes(self)) orelse return null;
            if (pattern_str.len == 0) {
                // "" * N = "" for any N >= 1; 1 is the canonical answer
                return if (value_str.len == 0) 1 else null;
            }
            if (value_str.len % pattern_str.len != 0) return null;
            const count = value_str.len / pattern_str.len;
            var i: usize = 0;
            while (i < count) : (i += 1) {
                const start = i * pattern_str.len;
                if (!std.mem.eql(u8, value_str[start .. start + pattern_str.len], pattern_str)) {
                    return null;
                }
            }
            return @floatFromInt(count);
        }
        if (pattern_value.isDynType(.Array)) {
            if (!value.isDynType(.Array)) return null;
            const pattern_elems = pattern_value.asDyn().asArray().elems.items;
            const value_elems = value.asDyn().asArray().elems.items;
            if (pattern_elems.len == 0) return null;
            if (value_elems.len % pattern_elems.len != 0) return null;
            const count = value_elems.len / pattern_elems.len;
            var i: usize = 0;
            while (i < count) : (i += 1) {
                const start = i * pattern_elems.len;
                for (pattern_elems, 0..) |pattern_elem, j| {
                    if (!value_elems[start + j].isEql(pattern_elem, self.*)) return null;
                }
            }
            return @floatFromInt(count);
        }
        if (pattern_value.isDynType(.Object)) {
            if (!value.isDynType(.Object)) return null;
            const pattern_members = pattern_value.asDyn().asObject().members.count();
            const value_members = value.asDyn().asObject().members.count();
            // Merging an object with itself is the identity: {} is P * 0
            // for non-empty P, any other value is pattern * 1.
            if (value_members == 0) return if (pattern_members == 0) 1 else 0;
            return if (value.isEql(pattern_value, self.*)) 1 else null;
        }
        if (pattern_value.isNumber() and value.isNumber()) {
            const pattern_float = if (pattern_value.isFloat())
                pattern_value.asFloat()
            else
                pattern_value.asNumberString().toNumberFloat(self.strings).asFloat();
            const value_float = if (value.isFloat())
                value.asFloat()
            else
                value.asNumberString().toNumberFloat(self.strings).asFloat();
            if (pattern_float == 0) {
                // 0 * N = 0 for any N >= 1; 1 is the canonical answer
                return if (value_float == 0) 1 else null;
            }
            return value_float / pattern_float;
        }
        if (pattern_value.isType(.Const)) {
            const pattern_const = pattern_value.asConst();
            if (pattern_const == .True or pattern_const == .False) {
                // true * N = true and false * N = false for any N >= 1
                if (!value.isType(.Const)) return null;
                const value_const = value.asConst();
                if (value_const != .True and value_const != .False) return null;
                return if (pattern_value.isEql(value, self.*)) 1 else null;
            }
        }
        return null;
    }

    // A resolved bound must be a valid range bound. The comparison is
    // inclusive: lower bounds check `limit <= value`, upper bounds check
    // `value <= limit`.
    fn compareRangeBound(self: *VM, limit: Elem, value: Elem, is_upper: bool) !bool {
        return if (is_upper)
            value.isLessThanOrEqualInRangePattern(limit, self.*)
        else
            limit.isLessThanOrEqualInRangePattern(value, self.*);
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
            => self.readByte(),
            .CallFunctionConstant2,
            .CallTailFunctionConstant2,
            .GetConstant2,
            .GetConstantMutable2,
            => self.readShort(),
            .CallFunctionConstant3,
            .CallTailFunctionConstant3,
            .GetConstant3,
            .GetConstantMutable3,
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

    // Renders a pattern from its source span. Inline match steps carry no
    // runtime pattern value, so --explain shows the pattern as the text
    // between its region bounds.
    const RegionSource = struct {
        source: []const u8,
        region: Region,

        pub fn print(self: RegionSource, vm: VM, writer: *Writer) Writer.Error!void {
            _ = vm;
            try writer.writeAll(self.source[self.region.start..self.region.end]);
        }
    };

    noinline fn emitExplainDestructureBegin(self: *VM, region: Region) !void {
        const module = self.getModule(self.cur_frame.function.mid);
        try self.explain_events.append(self.allocator, .{ .destructure_begin = .{
            .region = region,
            .module_id = self.cur_frame.function.mid,
            .offset = self.inputOffset,
            .value = explain.snapshot(self, self.peek(0)),
            .pattern = explain.snapshot(self, RegionSource{ .source = module.source, .region = region }),
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

    fn printPattern(self: *VM) !void {
        try self.writers.debug.print("Pattern | ", .{});
        for (self.match_regs.items, 0..) |e, idx| {
            e.print(self.*, self.writers.debug) catch {};
            if (idx < self.match_regs.items.len - 1) try self.writers.debug.print(", ", .{});
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

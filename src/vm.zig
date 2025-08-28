const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const assert = std.debug.assert;
const unicode = std.unicode;
const Writer = std.Io.Writer;
const Chunk = @import("chunk.zig").Chunk;
const Compiler = @import("compiler.zig").Compiler;
const Elem = @import("elem.zig").Elem;
const Env = @import("env.zig").Env;
const GC = @import("gc.zig").GC;
const Module = @import("module.zig").Module;
const OpCode = @import("op_code.zig").OpCode;
const Parser = @import("parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const PatternSolver = @import("pattern_solver.zig");
const Writers = @import("writer.zig").Writers;
const builtin = @import("builtin.zig");
const parsing = @import("parsing.zig");

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
    }
};

pub const Pos = struct {
    offset: usize = 0,
    line: usize = 1,
    line_start: usize = 0,

    fn lineOffset(self: Pos) usize {
        return self.offset - self.line_start;
    }
};

pub const VM = struct {
    allocator: Allocator,
    gc: GC,
    strings: StringTable,
    modules: ArrayList(Module),
    active_compiler: ?*Compiler,
    stack: ArrayList(Elem),
    frames: ArrayList(CallFrame),
    temp_dyns: ArrayList(*Elem.DynElem),
    input: []const u8,
    inputMarks: ArrayList(Pos),
    inputPos: Pos,
    uniqueIdCount: u64,
    pattern_solver: PatternSolver,
    writers: Writers,
    config: Config,

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
            .active_compiler = undefined,
            .stack = undefined,
            .frames = undefined,
            .temp_dyns = undefined,
            .input = undefined,
            .inputMarks = undefined,
            .inputPos = undefined,
            .uniqueIdCount = undefined,
            .pattern_solver = undefined,
            .writers = undefined,
            .config = undefined,
        };

        return self;
    }

    pub fn init(self: *VM, allocator: Allocator, writers: Writers, config: Config) !void {
        self.config = config;
        self.writers = writers;
        self.allocator = allocator;
        self.gc = GC.init(self, allocator);
        self.strings = StringTable.init(allocator);
        self.modules = ArrayList(Module){};
        self.active_compiler = null;
        self.stack = ArrayList(Elem){};
        self.frames = ArrayList(CallFrame){};
        self.temp_dyns = ArrayList(*Elem.DynElem){};
        self.input = undefined;
        self.inputMarks = ArrayList(Pos){};
        self.inputPos = Pos{};
        self.uniqueIdCount = 0;
        self.pattern_solver = PatternSolver.init(self);
        errdefer self.deinit();

        try self.loadBuiltinFunctions();

        if (self.config.includeStdlib) {
            try self.loadStdlib();
        }
    }

    pub fn deinit(self: *VM) void {
        self.gc.deinit();
        self.strings.deinit();
        for (self.modules.items) |*module| {
            module.deinit(self.allocator);
        }
        self.modules.deinit(self.allocator);
        self.stack.deinit(self.allocator);
        self.frames.deinit(self.allocator);
        self.temp_dyns.deinit(self.allocator);
        self.inputMarks.deinit(self.allocator);
        self.pattern_solver.deinit();
    }

    fn findGlobal(self: *VM, name: StringTable.Id) ?Elem {
        // Search backwards through modules
        var i = self.modules.items.len;
        while (i > 0) {
            i -= 1;
            if (self.modules.items[i].getGlobal(name)) |elem| {
                return elem;
            }
        }
        return null;
    }

    pub fn interpret(self: *VM, module: Module, input: []const u8) !Elem {
        if (input.len > std.math.maxInt(u32)) return error.InputTooLong;

        self.input = input;
        try self.compile(module);
        try self.run();
        assert(self.stack.items.len == 1);

        // Prevent GC
        return self.peek(0);
    }

    pub fn compile(self: *VM, module: Module) !void {
        try self.modules.append(self.allocator, module);

        var parser = Parser.init(self, module);
        defer parser.deinit();

        try parser.parse();

        if (self.config.printAst) {
            try parser.ast.print(self.writers.debug, self.*, module.source);
        }

        const modulePtr = &self.modules.items[self.modules.items.len - 1];
        var compiler = try Compiler.init(
            self,
            modulePtr,
            parser.ast,
            self.config.printCompiledBytecode,
        );
        defer compiler.deinit();

        self.active_compiler = &compiler;
        defer self.active_compiler = null;

        const function = try compiler.compile();

        if (function) |main| {
            try self.push(main.dyn.elem());
            try self.addFrame(main);
        }
    }

    fn loadBuiltinFunctions(self: *VM) !void {
        const builtinModule = Module{ .source = "" };
        try self.modules.append(self.allocator, builtinModule);

        // Get a pointer to the Module in the modules list, not a local copy,
        // so modifications affect the VM-owned instance
        const modulePtr = &self.modules.items[self.modules.items.len - 1];
        try builtin.loadFunctions(self, modulePtr);
    }

    fn loadStdlib(self: *VM) !void {
        const filename = "stdlib/core.possum";
        const stdlibModule = Module{
            .name = filename,
            .source = @embedFile(filename),
            .showLineNumbers = true,
        };

        try self.modules.append(self.allocator, stdlibModule);

        var parser = Parser.init(self, stdlibModule);
        defer parser.deinit();

        try parser.parse();

        const modulePtr = &self.modules.items[self.modules.items.len - 1];
        var compiler = try Compiler.init(self, modulePtr, parser.ast, false);
        defer compiler.deinit();

        _ = try compiler.compile();
    }

    pub fn findModuleForFunction(self: *VM, function: *Elem.DynElem.Function) ?*Module {
        const function_name = function.name;

        // Search backwards through modules (most recent first)
        var i = self.modules.items.len;
        while (i > 0) {
            i -= 1;
            const module = &self.modules.items[i];

            if (module.getGlobal(function_name)) |stored_elem| {
                // Compare function pointers directly since they should be the same instance
                if (stored_elem.isType(.Dyn)) {
                    const dyn = stored_elem.asDyn();
                    if (dyn.isType(.Function)) {
                        const stored_function = dyn.asFunction();
                        if (stored_function == function) {
                            return module;
                        }
                    }
                }
            }
        }
        return null;
    }

    pub fn run(self: *VM) !void {
        if (self.frames.items.len == 0) {
            return Error.NoMainParser;
        }

        if (self.config.printExecutedBytecode) {
            const module = self.findModuleForFunction(self.frame().function);
            try self.frame().function.disassemble(self.*, self.writers.debug, module);
        }

        while (true) {
            try self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
            if (self.frames.items.len == 0) break;
        }

        try self.printDebug();
    }

    pub fn runFunction(self: *VM) Error!void {
        if (self.frames.items.len == 0) {
            return Error.NoMainParser;
        }

        const initialFrameCount = self.frames.items.len;

        // Run until we return to the previous frame level (or have no frames left)
        while (self.frames.items.len >= initialFrameCount and self.frames.items.len > 0) {
            try self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
        }

        try self.printDebug();
    }

    fn runOp(self: *VM, opCode: OpCode) !void {
        switch (opCode) {
            .Backtrack => {
                // Infix, lhs on stack.
                // If lhs succeeded then pop, return to prev input position.
                // If lhs failed then keep it and jump to skip rhs ops.
                const offset = self.readShort();
                const resetPos = self.popInputMark();
                if (self.peekIsSuccess()) {
                    self.drop(1);
                    self.inputPos = resetPos;
                } else {
                    self.frame().ip += offset;
                }
            },
            .CallFunction => {
                // Postfix, function and args on stack.
                // Create new stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callFunction(self.peek(argCount), argCount, false);
            },
            .CallTailFunction => {
                // Postfix, function and args on stack.
                // Reuse stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callFunction(self.peek(argCount), argCount, true);
            },
            .CaptureLocal => {
                // Create or extend a closure around a function.
                const fromSlot = self.readByte();
                const toSlot = self.readByte();
                const elem = self.peek(0);

                switch (elem.getType()) {
                    .Dyn => switch (elem.asDyn().dynType) {
                        .Function => {
                            const function = elem.asDyn().asFunction();
                            var closure = try Elem.DynElem.Closure.create(self, function);
                            closure.capture(toSlot, self.getLocal(fromSlot));

                            self.drop(1);
                            try self.push(closure.dyn.elem());
                        },
                        .Closure => {
                            var closure = elem.asDyn().asClosure();
                            closure.capture(toSlot, self.getLocal(fromSlot));

                            self.drop(1);
                            try self.push(closure.dyn.elem());
                        },
                        else => @panic("Internal error"),
                    },
                    else => @panic("Internal error"),
                }
            },
            .ConditionalThen => {
                // The `?` part of `condition ? then : else`
                // Infix, `condition` on stack.
                // If `condition` succeeded then continue to `then` branch.
                // If `condition` failed then jump to the start of `else` branch.
                const offset = self.readShort();
                const resetPos = self.popInputMark();
                if (self.peekIsSuccess()) {
                    self.drop(1);
                } else {
                    self.drop(1);
                    self.inputPos = resetPos;
                    self.frame().ip += offset;
                }
            },
            .Crash => {
                if (self.peekIsSuccess()) {
                    const value = self.peek(0);

                    const str = try value.toString(self);
                    const message = str.stringBytes(self.*).?;
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
            .Destructure => {
                const patternIdx = self.readByte();
                const pattern = self.chunk().getPattern(patternIdx);
                const value = self.peek(0);

                if (value.isSuccess() and (try self.pattern_solver.match(value, pattern))) {
                    // value is already on the stack
                } else {
                    self.drop(1);
                    try self.pushFailure();
                }
            },
            .Drop => {
                self.drop(1);
            },
            .End => {
                // End of function cleanup. Remove everything from the stack
                // frame except the final function result.
                const prevFrame = self.frames.pop() orelse @panic("VM frame underflow");
                const result = self.pop();

                try self.stack.resize(self.allocator, prevFrame.elemsOffset);
                try self.push(result);
            },
            .Fail => {
                // Push singleton failure value.
                try self.pushFailure();
            },
            .False => {
                // Push singleton false value.
                try self.push(Elem.boolean(false));
            },
            .GetAtIndex => {
                const index = self.readByte();
                const elem = self.peek(0);

                if (elem.isSuccess()) {
                    const array = elem.asDyn().asArray();
                    try self.push(array.elems.items[index]);
                }
            },
            .GetLocal => {
                const slot = self.readByte();
                try self.push(self.getLocal(slot));
            },
            .GetBoundLocal => {
                const slot = self.readByte();
                try self.push(try self.getBoundLocal(slot));
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
                    self.drop(2);
                    try self.pushFailure();
                } else {
                    const array = array_elem.asDyn().asArray();
                    var copy = try Elem.DynElem.Array.copy(self, array.elems.items);
                    copy.elems.items[index] = elem;

                    self.drop(2);
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertAtKey => {
                const idx = self.readByte();
                const keyElem = self.chunk().getConstant(idx);
                const val = self.peek(0);
                const object_elem = self.peek(1);

                if (val.isFailure() or object_elem.isFailure()) {
                    self.drop(2);
                    try self.pushFailure();
                } else {
                    const object = object_elem.asDyn().asObject();
                    const key = if (keyElem.isType(.String)) keyElem.asString() else @panic("Internal Error");

                    var copy = try Elem.DynElem.Object.create(self, object.members.count());
                    try self.pushTempDyn(&copy.dyn);
                    defer self.dropTempDyn();

                    try copy.concat(self, object);
                    try copy.put(self, key, val);

                    self.drop(2);
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertKeyVal => {
                const placeholder_key = self.readByte();
                const val = self.peek(0);
                const key_elem = self.peek(1);
                const object_elem = self.peek(2);

                const placeholder_key_sid = StringTable.reservedSid(placeholder_key);

                if (val.isFailure() or key_elem.isFailure() or object_elem.isFailure()) {
                    self.drop(3);
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

                    var copy = try Elem.DynElem.Object.create(self, object.members.count());
                    try self.pushTempDyn(&copy.dyn);
                    defer self.dropTempDyn();

                    try copy.concat(self, object);

                    if (calculated_index) |existing_key_index| {
                        if (existing_key_index < placeholder_index) {
                            // Key was already inserted, but before this new
                            // insertion. Replace both the placeholder and
                            // existing with the new pair, leaving the new pair
                            // in the placeholder position.
                            _ = copy.members.orderedRemove(key_sid);
                            try copy.put(self, key_sid, val);
                            _ = copy.members.swapRemove(placeholder_key_sid);
                        } else {
                            // This key was inserted after the placeholder.
                            // Delete the placeholder and keep the existing
                            // key.
                            _ = copy.members.orderedRemove(placeholder_key_sid);
                        }
                    } else {
                        try copy.put(self, key_sid, val);
                        _ = copy.members.swapRemove(placeholder_key_sid);
                    }

                    self.drop(3);
                    try self.push(copy.dyn.elem());
                }
            },
            .Jump => {
                const offset = self.readShort();
                self.frame().ip += offset;
            },
            .JumpBack => {
                const offset = self.readShort();
                self.frame().ip -= offset;
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekIsFailure()) self.frame().ip += offset;
            },
            .JumpIfZero => {
                const offset = self.readShort();
                const elem = self.peek(0);
                if (elem.isEql(Elem.numberFloat(0), self.*)) {
                    self.frame().ip += offset;
                }
            },
            .JumpIfBound => {
                const offset = self.readShort();
                const elem = self.peek(0);
                if (!elem.isType(.ValueVar)) {
                    self.frame().ip += offset;
                }
            },
            .GetConstant => {
                const idx = self.readByte();
                try self.push(self.chunk().getConstant(idx));
            },
            .SetClosureCaptures => {
                var function = self.getFunctionElem().asDyn();

                if (function.isType(.Closure)) {
                    const closure = function.asClosure();
                    for (closure.captures, 0..) |capture, slot| {
                        if (capture) |elem| {
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
                    const floatVal = elem.asNumberString().toNumberFloat(self.strings) catch {
                        try self.push(Elem.failureConst);
                        return;
                    };
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
                    self.drop(2);
                    try self.push(value);
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

                    self.drop(2);
                    try self.push(merged);
                } else {
                    self.drop(2);
                    try self.push(Elem.failureConst);
                }
            },
            .NativeCode => {
                const idx = self.readByte();
                const elem = self.chunk().getConstant(idx);

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
            .Null => {
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
                    self.frame().ip += offset;
                } else {
                    self.drop(1);
                    self.inputPos = resetPos;
                }
            },
            .ParseCharacter => {
                const start = self.inputPos.offset;

                if (start < self.input.len) {
                    const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
                    const end = start + bytes_length;

                    self.inputPos.offset = end;
                    if (self.isNewlineChar(start, bytes_length)) {
                        self.inputPos.line += 1;
                        self.inputPos.line_start = end;
                    }

                    if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                        try self.push(elem);
                    } else {
                        const str = try Elem.DynElem.String.copy(self, self.input[start..end]);
                        try self.push(str.dyn.elem());
                    }
                } else {
                    try self.pushFailure();
                }
            },
            .ParseFixedRange => {
                const low_idx = self.readByte();
                const high_idx = self.readByte();
                const low_elem = self.chunk().getConstant(low_idx);
                const high_elem = self.chunk().getConstant(high_idx);

                if (low_elem.isType(.String)) {
                    const low = self.strings.get(low_elem.asString());
                    const high = self.strings.get(high_elem.asString());
                    const low_codepoint = parsing.utf8Decode(low) orelse @panic("Internal Error");
                    const high_codepoint = parsing.utf8Decode(high) orelse @panic("Internal Error");
                    try self.parseCharacterRange(low_codepoint, high_codepoint);
                } else {
                    const low = try low_elem.asInteger(self.strings);
                    const high = try high_elem.asInteger(self.strings);
                    try self.parseIntegerRange(low, high);
                }
            },
            .ParseLowerBoundedRange => {
                const low_elem = self.peek(0);

                if (low_elem.isType(.String)) {
                    const bytes = self.strings.get(low_elem.asString());

                    if (parsing.utf8Decode(bytes)) |codepoint| {
                        self.drop(1);
                        try self.parseCharacterLowerBounded(codepoint);
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
                                try self.parseCharacterRange(low_codepoint, high_codepoint);
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
                        try self.parseCharacterUpperBounded(codepoint);
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
                    self.drop(2);
                    try self.push(result);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .ResetInput => {
                const resetPos = self.popInputMark();
                self.inputPos = resetPos;
            },
            .TakeLeft => {
                // Postfix, lhs and rhs on stack.
                // If rhs succeeded then discard rhs, keep lhs.
                // If rhs failed then drop both and push failure.
                if (self.peekIsSuccess()) {
                    self.drop(1);
                } else {
                    self.drop(2);
                    try self.pushFailure();
                }
            },
            .TakeRight => {
                // Infix, lhs on stack.
                // If lhs succeeded then pop, to be replaced with rhs.
                // If lhs failed then keep it and jump to skip rhs ops.
                const offset = self.readShort();
                if (self.peekIsSuccess()) {
                    self.drop(1);
                } else {
                    self.frame().ip += offset;
                }
            },
            .True => {
                // Push singleton true value.
                try self.push(Elem.boolean(true));
            },
        }
    }

    pub fn nextUniqueId(self: *VM) u64 {
        const id = self.uniqueIdCount;
        self.uniqueIdCount += 1;
        return id;
    }

    fn printDebug(self: *VM) !void {
        if (self.config.printVM) {
            try self.writers.debug.print("\n", .{});
            try self.printInput();
            try self.printFrames();
            try self.printElems();

            if (self.frames.items.len > 0) {
                _ = try self.chunk().disassembleInstruction(self.*, self.writers.debug, self.frame().ip);
            }
        }
    }

    pub fn callFunction(self: *VM, elem: Elem, argCount: u8, isTailPosition: bool) Error!void {
        switch (elem.getType()) {
            .ParserVar => {
                const varName = elem.asParserVar();
                if (self.findGlobal(varName)) |varElem| {
                    // Swap the var with the thing it's aliasing on the stack
                    self.stack.items[self.frame().elemsOffset] = varElem;
                    try self.callFunction(varElem, argCount, isTailPosition);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
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
                            const module = self.findModuleForFunction(function);
                            try function.disassemble(self.*, self.writers.debug, module);
                        }

                        if (function.arity == argCount) {
                            if (isTailPosition and !function.isBuiltin(self.*)) {
                                // Remove the elements belonging to the previous call
                                // frame. This includes the function itself, its
                                // arguments, and any added local variables.
                                const frameStart = self.frame().elemsOffset;
                                const frameEnd = self.stack.items.len - function.arity - 1;
                                const length = frameEnd - frameStart;
                                try self.stack.replaceRange(self.allocator, frameStart, length, &[0]Elem{});
                                _ = self.frames.pop();
                            }
                            try self.addFrame(function);
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
        const start = self.inputPos.offset;
        const end = start + str.len;

        var newlines: usize = 0;
        var line_start = self.inputPos.line_start;

        if (self.input.len >= end) {
            for (str, self.input[start..end], 0..) |sc, ic, idx| {
                if (self.isNewlineChar(start + idx, 1) or
                    (str[idx..].len >= 2 and self.isNewlineChar(start + idx, 2)) or
                    (str[idx..].len >= 3 and self.isNewlineChar(start + idx, 3)))
                {
                    newlines += 1;
                    line_start = start + idx;
                }

                if (sc != ic) {
                    try self.pushFailure();
                    return;
                }
            }

            self.inputPos.offset = end;
            self.inputPos.line += newlines;
            self.inputPos.line_start = line_start;

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
        const start = self.inputPos.offset;
        const end = start + bytes.len;

        if (self.input.len >= end and std.mem.eql(u8, bytes, self.input[start..end])) {
            self.inputPos.offset = end;
            try self.push(number_string.elem());
            return;
        }
        try self.pushFailure();
    }

    fn parseCharacterRange(self: *VM, low: u21, high: u21) !void {
        const low_length = unicode.utf8CodepointSequenceLength(low) catch 1;
        const high_length = unicode.utf8CodepointSequenceLength(high) catch 1;
        const start = self.inputPos.offset;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (low_length <= bytes_length and bytes_length <= high_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (low <= codepoint and codepoint <= high) {
                    if (self.isNewlineChar(start, bytes_length)) {
                        self.inputPos.line += 1;
                        self.inputPos.line_start = end;
                    }
                    self.inputPos.offset = end;

                    if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                        try self.push(elem);
                    } else {
                        const str = try Elem.DynElem.String.copy(self, self.input[start..end]);
                        try self.push(str.dyn.elem());
                    }

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseCharacterLowerBounded(self: *VM, low: u21) !void {
        const low_length = unicode.utf8CodepointSequenceLength(low) catch @panic("Internal Error");
        const start = self.inputPos.offset;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (low_length <= bytes_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (low <= codepoint) {
                    self.inputPos.offset = end;
                    if (self.isNewlineChar(start, bytes_length)) {
                        self.inputPos.line += 1;
                        self.inputPos.line_start = end;
                    }

                    if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                        try self.push(elem);
                    } else {
                        const str = try Elem.DynElem.String.copy(self, self.input[start..end]);
                        try self.push(str.dyn.elem());
                    }

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseCharacterUpperBounded(self: *VM, high: u21) !void {
        const high_length = unicode.utf8CodepointSequenceLength(high) catch @panic("Internal Error");
        const start = self.inputPos.offset;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (bytes_length <= high_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (codepoint <= high) {
                    self.inputPos.offset = end;

                    if (self.isNewlineChar(start, bytes_length)) {
                        self.inputPos.line += 1;
                        self.inputPos.line_start = end;
                    }

                    if (try Elem.inputSubstringFromRange(start, end)) |elem| {
                        try self.push(elem);
                    } else {
                        const str = try Elem.DynElem.String.copy(self, self.input[start..end]);
                        try self.push(str.dyn.elem());
                    }

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseIntegerRange(self: *VM, low: i64, high: i64) !void {
        const lowIntLen = parsing.intAsStringLen(low);
        const highIntLen = parsing.intAsStringLen(high);
        const start = self.inputPos.offset;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);
        const longestMatchEnd = @min(start + highIntLen, self.input.len);

        var end = longestMatchEnd;

        // Find the longest substring from the start of the input which
        // parses as an integer, is greater than or equal to `low` and
        // less than or equal to `high`, and is at least one char long.
        while (end >= shortestMatchEnd and end > start) {
            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (low <= i and i <= high) {
                self.inputPos.offset = end;
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
        const start = self.inputPos.offset;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

        var end = shortestMatchEnd;

        // The integer has no upper bound, so keep eating digits
        while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
            end += 1;
        }

        const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

        if (inputInt) |i| if (low <= i) {
            self.inputPos.offset = end;
            const int = Elem.numberFloat(@as(f64, @floatFromInt(i)));
            try self.push(int);
            return;
        };

        try self.pushFailure();
    }

    fn parseIntegerUpperBounded(self: *VM, high: i64) !void {
        if (self.input[self.inputPos.offset] == '-') {
            // If it's a negative integer then the max number of digits is unbounded
            const lowIntLen = 2;
            const start = self.inputPos.offset;
            const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

            var end = shortestMatchEnd;

            // The negative integer has no lower bound, so keep eating digits
            while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
                end += 1;
            }

            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (i <= high) {
                self.inputPos.offset = end;
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

    fn frame(self: *VM) *CallFrame {
        return &self.frames.items[self.frames.items.len - 1];
    }

    fn parentFrame(self: *VM) ?*CallFrame {
        if (self.frames.items.len > 1) {
            return &self.frames.items[self.frames.items.len - 2];
        } else {
            return null;
        }
    }

    fn chunk(self: *VM) *Chunk {
        return &self.frame().function.chunk;
    }

    pub fn getConstant(self: *VM, idx: u8) Elem {
        return self.chunk().getConstant(idx);
    }

    fn addFrame(self: *VM, function: *Elem.DynElem.Function) !void {
        try self.frames.append(self.allocator, CallFrame{
            .function = function,
            .ip = 0,
            .elemsOffset = self.stack.items.len - function.arity - 1,
        });
    }

    pub fn getFunctionElem(self: *VM) Elem {
        return self.stack.items[self.frame().elemsOffset];
    }

    pub fn getLocal(self: *VM, slot: usize) Elem {
        // The local slot is at the start of the frame + 1, since the first
        // elem in the frame is the function getting called.
        return self.stack.items[self.frame().elemsOffset + slot + 1];
    }

    pub fn getBoundLocal(self: *VM, slot: usize) !Elem {
        const local = self.getLocal(slot);
        switch (local.getType()) {
            .ValueVar => {
                const varName = local.asValueVar();
                const nameStr = self.strings.get(varName);
                return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
            },
            .ParserVar => {
                const varName = local.asParserVar();
                const nameStr = self.strings.get(varName);
                return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
            },
            else => return local,
        }
    }

    pub fn setLocal(self: *VM, slot: usize, elem: Elem) void {
        // The local slot is at the start of the frame + 1, since the first
        // elem in the frame is the function getting called.
        self.stack.items[self.frame().elemsOffset + slot + 1] = elem;
    }

    fn readByte(self: *VM) u8 {
        const byte = self.chunk().read(self.frame().ip);
        self.frame().ip += 1;
        return byte;
    }

    fn readOp(self: *VM) OpCode {
        const op = self.chunk().readOp(self.frame().ip);
        self.frame().ip += 1;
        return op;
    }

    fn readShort(self: *VM) u16 {
        self.frame().ip += 2;
        const items = self.chunk().code.items;
        return (@as(u16, @intCast(items[self.frame().ip - 2])) << 8) | items[self.frame().ip - 1];
    }

    pub fn push(self: *VM, elem: Elem) !void {
        try self.stack.append(self.allocator, elem);
    }

    pub fn pushFailure(self: *VM) !void {
        try self.push(Elem.failureConst);
    }

    pub fn pop(self: *VM) Elem {
        return self.stack.pop() orelse @panic("VM stack underflow");
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
        try self.inputMarks.append(self.allocator, self.inputPos);
    }

    fn popInputMark(self: *VM) Pos {
        return self.inputMarks.pop() orelse @panic("VM input marks underflow");
    }

    fn printInput(self: *VM) !void {
        try self.writers.debug.print("input   | ", .{});
        try self.writers.debug.print("{s} @ Line {d} byte {d}\n", .{
            self.inputLine(),
            self.inputPos.line,
            self.inputPos.lineOffset(),
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

    fn inputLine(self: VM) []const u8 {
        const line_start = self.inputPos.line_start;
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

    // Linear scan of module globals to find the module that contains the
    // target chunk. Intended for error reporting.
    fn findModuleForChunk(self: *VM, target_chunk: *Chunk) ?*Module {
        for (self.modules.items) |*module| {
            var iterator = module.globals.iterator();
            while (iterator.next()) |entry| {
                const elem = entry.value_ptr.*;
                if (elem.isType(.Dyn)) {
                    const dyn_elem = elem.asDyn();
                    if (dyn_elem.isType(.Function)) {
                        const function = dyn_elem.asFunction();
                        if (&function.chunk == target_chunk) {
                            return module;
                        }
                    }
                }
            }
        }
        return null;
    }

    pub fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const target_frame = if (self.frame().function.isBuiltin(self.*))
            self.parentFrame() orelse self.frame()
        else
            self.frame();

        const target_chunk = &target_frame.function.chunk;
        const target_region = target_chunk.regions.items[target_frame.ip - 1];

        try self.writers.err.print("\nRuntime Error: ", .{});
        try self.writers.err.print(message, args);
        try self.writers.err.print("\n", .{});

        if (self.findModuleForChunk(target_chunk)) |module| {
            try self.writers.err.print("\n", .{});

            if (module.name) |name| {
                try self.writers.err.print("{s}:", .{name});
            }

            try target_region.printLineRelative(module.source, self.writers.err);
            try self.writers.err.print(":\n\n", .{});

            try module.highlight(target_region, self.writers.err);
            try self.writers.err.print("\n", .{});
        }

        return Error.RuntimeError;
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

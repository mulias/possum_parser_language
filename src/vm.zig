const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const assert = std.debug.assert;
const unicode = std.unicode;
const Chunk = @import("chunk.zig").Chunk;
const Compiler = @import("compiler.zig").Compiler;
const Elem = @import("elem.zig").Elem;
const Env = @import("env.zig").Env;
const ErrorLog = @import("error_log.zig").ErrorLog;
const InputPosition = @import("error_log.zig").InputPosition;
const ParserType = @import("error_log.zig").ParserType;
const Module = @import("module.zig").Module;
const OpCode = @import("op_code.zig").OpCode;
const Parser = @import("parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const PatternSolver = @import("pattern_solver.zig");
const WriterError = @import("writer.zig").VMWriter.Error;
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
    runVM: bool = true,
    includeStdlib: bool = true,

    pub fn setEnv(self: *Config, env: Env) void {
        self.printScanner = env.printScanner;
        self.printParser = env.printParser;
        self.printAst = env.printAst;
        self.printCompiledBytecode = env.printCompiledBytecode;
        self.printExecutedBytecode = env.printExecutedBytecode;
        self.printVM = env.printVM;
        self.printDestructure = env.printDestructure;
        self.runVM = env.runVM;
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
    strings: StringTable,
    modules: ArrayList(Module),
    dynList: ?*Elem.DynElem,
    stack: ArrayList(Elem),
    frames: ArrayList(CallFrame),
    source: []const u8,
    input: []const u8,
    inputMarks: ArrayList(Pos),
    inputPos: Pos,
    uniqueIdCount: u64,
    pattern_solver: PatternSolver,
    writers: Writers,
    config: Config,
    error_log: *ErrorLog,

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
    } || WriterError;

    pub fn create() VM {
        const self = VM{
            .allocator = undefined,
            .strings = undefined,
            .modules = undefined,
            .dynList = undefined,
            .stack = undefined,
            .frames = undefined,
            .source = undefined,
            .input = undefined,
            .inputMarks = undefined,
            .inputPos = undefined,
            .uniqueIdCount = undefined,
            .pattern_solver = undefined,
            .writers = undefined,
            .config = undefined,
            .error_log = undefined,
        };

        return self;
    }

    pub fn init(self: *VM, allocator: Allocator, writers: Writers, config: Config) !void {
        self.allocator = allocator;
        self.strings = StringTable.init(allocator);
        self.modules = ArrayList(Module){};
        self.dynList = null;
        self.stack = ArrayList(Elem){};
        self.frames = ArrayList(CallFrame){};
        self.source = undefined;
        self.input = undefined;
        self.inputMarks = ArrayList(Pos){};
        self.inputPos = Pos{};
        self.uniqueIdCount = 0;
        self.writers = writers;
        self.config = config;
        self.pattern_solver = PatternSolver.init(self);
        self.error_log = try ErrorLog.init(allocator);
        errdefer self.deinit();

        try self.loadBuiltinFunctions();

        if (self.config.includeStdlib) {
            try self.loadStdlib();
        }
    }

    pub fn deinit(self: *VM) void {
        self.strings.deinit();
        for (self.modules.items) |*module| {
            module.deinit(self.allocator);
        }
        self.modules.deinit(self.allocator);
        self.freeDynList();
        self.stack.deinit(self.allocator);
        self.frames.deinit(self.allocator);
        self.inputMarks.deinit(self.allocator);
        self.pattern_solver.deinit();
        self.error_log.deinit();
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

        self.source = module.source;
        self.input = input;
        try self.compile(module);
        try self.run();
        assert(self.stack.items.len == 1);

        return self.pop();
    }

    pub fn compile(self: *VM, module: Module) !void {
        try self.modules.append(self.allocator, module);

        var parser = Parser.init(self, module);
        defer parser.deinit();

        try parser.parse();

        if (self.config.printAst) {
            try parser.ast.print(self.*);
        }

        const modulePtr = &self.modules.items[self.modules.items.len - 1];
        var compiler = try Compiler.init(
            self,
            modulePtr,
            parser.ast,
            self.config.printCompiledBytecode,
        );
        defer compiler.deinit();

        const function = try compiler.compile();

        if (function) |main| {
            try self.push(main.dyn.elem());
            try self.addFrame(main);
        }
    }

    fn loadBuiltinFunctions(self: *VM) !void {
        const builtinModule = Module{ .source = "" };

        try self.modules.append(self.allocator, builtinModule);
        const modulePtr = &self.modules.items[self.modules.items.len - 1];

        const functions = try builtin.functions(self);

        for (functions) |function| {
            try modulePtr.addGlobal(self.allocator, function.name, function.dyn.elem());
        }
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
                if (stored_elem == .Dyn and stored_elem.Dyn.isType(.Function)) {
                    const stored_function = stored_elem.Dyn.asFunction();
                    if (stored_function == function) {
                        return module;
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
                    _ = self.pop();
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
                switch (self.pop()) {
                    .Dyn => |dyn| switch (dyn.dynType) {
                        .Function => {
                            const function = dyn.asFunction();
                            var closure = try Elem.DynElem.Closure.create(self, function);
                            closure.capture(toSlot, self.getLocal(fromSlot));
                            try self.push(closure.dyn.elem());
                        },
                        .Closure => {
                            var closure = dyn.asClosure();
                            closure.capture(toSlot, self.getLocal(fromSlot));
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
                const condition = self.pop();
                const resetPos = self.popInputMark();
                if (condition.isFailure()) {
                    self.inputPos = resetPos;
                    self.frame().ip += offset;
                }
            },
            .ConditionalElse => {
                // The `:` part of `condition ? then : else`
                // Infix, `then` on stack.
                // Skip over the `else` branch. This opcode is placed at the
                // end of the `then` branch, so if the `then` branch was
                // skipped over to get to the `else` branch it will never be
                // encountered.
                const offset = self.readShort();
                self.frame().ip += offset;
            },
            .Crash => {
                if (self.peekIsSuccess()) {
                    const value = self.pop();
                    const str = try value.toString(self);
                    const message = str.stringBytes(self.*).?;
                    return self.runtimeError("{s}", .{message});
                } else {
                    return self.runtimeError("Crashed with no error message", .{});
                }
            },
            .Destructure => {
                const patternIdx = self.readByte();
                const pattern = self.chunk().getPattern(patternIdx);
                const value = self.pop();

                if (value.isSuccess() and (try self.pattern_solver.match(value, pattern))) {
                    try self.push(value);
                } else {
                    // Convert pattern to string representation with resolved variables
                    var pattern_buffer = ArrayList(u8){};
                    defer pattern_buffer.deinit(self.allocator);
                    
                    const writer = pattern_buffer.writer(self.allocator);
                    try pattern.printResolved(self, writer);
                    
                    const pattern_str = try pattern_buffer.toOwnedSlice(self.allocator);
                    defer self.allocator.free(pattern_str);
                    
                    try self.pushDestructureFailure(value, pattern_str);
                }
            },
            .End => {
                // End of function cleanup. Remove everything from the stack
                // frame except the final function result.
                const prevFrame = self.frames.pop() orelse @panic("VM frame underflow");
                const result = self.pop();

                // Pop from error log call stack when function ends normally (not tail call)
                self.error_log.popFunctionCall();

                try self.stack.resize(self.allocator, prevFrame.elemsOffset);
                try self.push(result);
            },
            .Fail => {
                // Push singleton failure value with named parser info.
                const current_function = self.frame().function.name;
                if (current_function != 0) { // 0 means unnamed function
                    const caller_name = self.strings.get(current_function);
                    try self.pushParserFailure(caller_name, .Named);
                } else {
                    try self.pushFailure();
                }
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
            .GetAtKey => {
                const key_elem = self.pop();
                const object_elem = self.peek(0);

                var key: StringTable.Id = undefined;

                if (key_elem.isType(.String)) {
                    key = key_elem.String;
                } else if (key_elem.stringBytes(self.*)) |bytes| {
                    key = try self.strings.insert(bytes);
                } else {
                    return self.runtimeError("Get key error: Object key must be a string", .{});
                }

                if (object_elem.isSuccess()) {
                    const object = object_elem.asDyn().asObject();
                    try self.push(object.members.get(key).?);
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
            .InsertAtIndex => {
                const index = self.readByte();
                const elem = self.pop();
                const array_elem = self.pop();

                if (elem.isFailure() or array_elem.isFailure()) {
                    try self.pushFailure();
                } else {
                    const array = array_elem.asDyn().asArray();
                    var copy = try Elem.DynElem.Array.copy(self, array.elems.items);
                    copy.elems.items[index] = elem;
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertAtKey => {
                const idx = self.readByte();
                const keyElem = self.chunk().getConstant(idx);
                const val = self.pop();
                const object_elem = self.pop();

                if (val.isFailure() or object_elem.isFailure()) {
                    try self.pushFailure();
                } else {
                    const object = object_elem.asDyn().asObject();
                    const key = switch (keyElem) {
                        .String => |sId| sId,
                        else => @panic("Internal Error"),
                    };
                    var copy = try Elem.DynElem.Object.create(self, object.members.count());
                    try copy.concat(self.allocator, object);
                    try copy.members.put(self.allocator, key, val);
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertKeyVal => {
                const val = self.pop();
                const key_elem = self.pop();
                const object_elem = self.pop();
                const placeholder_key = self.readByte();
                const placeholder_key_sid = StringTable.reservedSid(placeholder_key);

                if (val.isFailure() or key_elem.isFailure() or object_elem.isFailure()) {
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
                    try copy.concat(self.allocator, object);

                    if (calculated_index) |existing_key_index| {
                        if (existing_key_index < placeholder_index) {
                            // Key was already inserted, but before this new
                            // insertion. Replace both the placeholder and
                            // existing with the new pair, leaving the new pair
                            // in the placeholder position.
                            _ = copy.members.orderedRemove(key_sid);
                            try copy.members.put(self.allocator, key_sid, val);
                            _ = copy.members.swapRemove(placeholder_key_sid);
                        } else {
                            // This key was inserted after the placeholder.
                            // Delete the placeholder and keep the existing
                            // key.
                            _ = copy.members.orderedRemove(placeholder_key_sid);
                        }
                    } else {
                        try copy.members.put(self.allocator, key_sid, val);
                        _ = copy.members.swapRemove(placeholder_key_sid);
                    }

                    try self.push(copy.dyn.elem());
                }
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekIsFailure()) self.frame().ip += offset;
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
            .Merge => {
                // Postfix, lhs and rhs on stack.
                // Pop both and merge, push result. If the elems can't be
                // merged then halt with a runtime error.
                const rhs = self.pop();
                const lhs = self.pop();

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    try self.push(value);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .MergeAsString => {
                const rhs = self.pop();
                const lhs = self.pop();

                if (lhs.isSuccess() and rhs.isSuccess()) {
                    const lStr = try lhs.toString(self);
                    const rStr = try rhs.toString(self);
                    const merged = (try lStr.merge(rStr, self)).?;

                    try self.push(merged);
                } else {
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
                const num = self.pop();

                const value = Elem.negateNumber(num) catch |err| switch (err) {
                    error.ExpectedNumber => return self.runtimeError("Negation and subtraction is only supported for numbers.", .{}),
                };
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
                    _ = self.pop();
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

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);
                } else {
                    try self.pushFailure();
                }
            },
            .ParseRange => {
                const low_idx = self.readByte();
                const high_idx = self.readByte();
                const low_elem = self.chunk().getConstant(low_idx);
                const high_elem = self.chunk().getConstant(high_idx);

                assert(@intFromEnum(low_elem) == @intFromEnum(high_elem));

                switch (low_elem) {
                    .String => try self.parseCharacterRange(low_elem.String, high_elem.String),
                    .Integer => try self.parseIntegerRange(low_elem.Integer, high_elem.Integer),
                    else => @panic("Internal Error"),
                }
            },
            .ParseLowerBoundedRange => {
                const lowIdx = self.readByte();
                const low_elem = self.chunk().getConstant(lowIdx);
                switch (low_elem) {
                    .String => |sId| try self.parseCharacterLowerBounded(sId),
                    .Integer => |i| try self.parseIntegerLowerBounded(i),
                    else => @panic("Internal Error"),
                }
            },
            .ParseUpperBoundedRange => {
                const highIdx = self.readByte();
                const high_elem = self.chunk().getConstant(highIdx);
                switch (high_elem) {
                    .String => |sId| try self.parseCharacterUpperBounded(sId),
                    .Integer => |i| try self.parseIntegerUpperBounded(i),
                    else => @panic("Internal Error"),
                }
            },
            .TakeLeft => {
                // Postfix, lhs and rhs on stack.
                // If rhs succeeded then discard rhs, keep lhs.
                // If rhs failed then pop lhs and push failure.
                const rhs = self.pop();
                if (rhs.isFailure()) {
                    _ = self.pop();
                    try self.pushFailure();
                }
            },
            .TakeRight => {
                // Infix, lhs on stack.
                // If lhs succeeded then pop, to be replaced with rhs.
                // If lhs failed then keep it and jump to skip rhs ops.
                const offset = self.readShort();
                if (self.peekIsSuccess()) {
                    _ = self.pop();
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
        switch (elem) {
            .ParserVar => |varName| {
                if (self.findGlobal(varName)) |varElem| {
                    // Swap the var with the thing it's aliasing on the stack
                    self.stack.items[self.frame().elemsOffset] = varElem;
                    try self.callFunction(varElem, argCount, isTailPosition);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
            .String => |sid| {
                assert(argCount == 0);
                _ = self.pop();
                try self.parseString(sid);
            },
            .NumberString => |ns| {
                assert(argCount == 0);
                _ = self.pop();
                try self.parseNumberString(ns);
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .Function => {
                    var function = dyn.asFunction();

                    if (self.config.printExecutedBytecode) {
                        const module = self.findModuleForFunction(function);
                        try function.disassemble(self.*, self.writers.debug, module);
                    }

                    if (function.arity == argCount) {
                        // Track function calls for error reporting
                        if (function.name != 0) { // 0 means unnamed function
                            self.error_log.addFunctionCall(function.name, isTailPosition);
                        }
                        
                        if (isTailPosition) {
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
                    try self.pushParserFailure(str, .String);
                    return;
                }
            }

            self.inputPos.offset = end;
            self.inputPos.line += newlines;
            self.inputPos.line_start = line_start;

            const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
            try self.push(substring);

            return;
        }

        try self.pushParserFailure(str, .String);
    }

    fn parseNumberString(self: *VM, number_string: Elem.NumberStringElem) Error!void {
        const bytes = number_string.toString(self.strings);
        const start = self.inputPos.offset;
        const end = start + bytes.len;

        if (self.input.len >= end and std.mem.eql(u8, bytes, self.input[start..end])) {
            self.inputPos.offset = end;
            try self.push(.{ .NumberString = number_string });
            return;
        }
        try self.pushParserFailure(bytes, .Number);
    }

    fn parseCharacterRange(self: *VM, low_id: StringTable.Id, high_id: StringTable.Id) !void {
        const low = unicode.utf8Decode(self.strings.get(low_id)) catch @panic("Internal Error");
        const high = unicode.utf8Decode(self.strings.get(high_id)) catch @panic("Internal Error");
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

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        const expr = try std.fmt.allocPrint(self.allocator, "'{s}'..'{s}'", .{self.strings.get(low_id), self.strings.get(high_id)});
        defer self.allocator.free(expr);
        try self.pushParserFailure(expr, .CharacterRange);
    }

    fn parseCharacterLowerBounded(self: *VM, low_id: StringTable.Id) !void {
        const low = unicode.utf8Decode(self.strings.get(low_id)) catch @panic("Internal Error");
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

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        const expr = try std.fmt.allocPrint(self.allocator, "'{s}'..", .{self.strings.get(low_id)});
        defer self.allocator.free(expr);
        try self.pushParserFailure(expr, .CharacterRange);
    }

    fn parseCharacterUpperBounded(self: *VM, high_id: StringTable.Id) !void {
        const high = unicode.utf8Decode(self.strings.get(high_id)) catch @panic("Internal Error");
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

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        const expr = try std.fmt.allocPrint(self.allocator, "..'{s}'", .{self.strings.get(high_id)});
        defer self.allocator.free(expr);
        try self.pushParserFailure(expr, .CharacterRange);
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
                const int = Elem.integer(i);
                try self.push(int);
                return;
            };
            end -= 1;
        }
        const expr = try std.fmt.allocPrint(self.allocator, "{}..{}", .{low, high});
        defer self.allocator.free(expr);
        try self.pushParserFailure(expr, .IntegerRange);
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
            const int = Elem.integer(i);
            try self.push(int);
            return;
        };

        const expr = try std.fmt.allocPrint(self.allocator, "{}..", .{low});
        defer self.allocator.free(expr);
        try self.pushParserFailure(expr, .IntegerRange);
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
                const int = Elem.integer(i);
                try self.push(int);
                return;
            };

            const expr = try std.fmt.allocPrint(self.allocator, "..{}", .{high});
            defer self.allocator.free(expr);
            try self.pushParserFailure(expr, .IntegerRange);
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
        switch (local) {
            .ValueVar => |varName| {
                const nameStr = self.strings.get(varName);
                return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
            },
            .ParserVar => |varName| {
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

    pub fn pushParserFailure(self: *VM, parser_expr: []const u8, parser_type: ParserType) !void {
        try self.push(Elem.failureConst);
        
        const input_pos = InputPosition{
            .offset = self.inputPos.offset,
            .line = self.inputPos.line,
            .line_start = self.inputPos.line_start,
        };
        
        // Use logical call history from error log
        const call_stack = self.error_log.getCurrentCallStack();
        
        self.error_log.addParserFailure(input_pos, parser_expr, parser_type, call_stack) catch |err| {
            // Silent error collection failure to avoid spam  
            return err;
        };
    }

    pub fn pushDestructureFailure(self: *VM, value: Elem, pattern: []const u8) !void {
        try self.push(Elem.failureConst);
        
        const input_pos = InputPosition{
            .offset = self.inputPos.offset,
            .line = self.inputPos.line,
            .line_start = self.inputPos.line_start,
        };
        
        // Convert value to string representation
        const value_string = if (value.stringBytes(self.*)) |bytes|
            try self.allocator.dupe(u8, bytes)
        else blk: {
            // For non-string values, convert to JSON representation
            const value_elem = try value.toString(self);
            const bytes = value_elem.stringBytes(self.*) orelse "<complex_value>";
            break :blk try self.allocator.dupe(u8, bytes);
        };
        defer self.allocator.free(value_string);
        
        // Use logical call history from error log
        const call_stack = self.error_log.getCurrentCallStack();
        
        self.error_log.addDestructureFailure(input_pos, value_string, pattern, call_stack) catch |err| {
            // Silent error collection failure to avoid spam
            return err;
        };
    }

    pub fn pop(self: *VM) Elem {
        return self.stack.pop() orelse @panic("VM stack underflow");
    }

    pub fn peek(self: *VM, distance: usize) Elem {
        const len = self.stack.items.len;
        if (len == 0 or distance >= len) {
            @panic("VM stack underflow in peek");
        }
        return self.stack.items[(len - 1) - distance];
    }

    fn peekIsFailure(self: *VM) bool {
        return self.peek(0) == .Failure;
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

    pub fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const region = self.chunk().regions.items[self.frame().ip];
        try region.printLineRelative(self.source, self.writers.err);
        try self.writers.err.print("Error: ", .{});
        try self.writers.err.print(message, args);
        try self.writers.err.print("\n", .{});

        return Error.RuntimeError;
    }

    fn freeDynList(self: *VM) void {
        var dyn = self.dynList;
        while (dyn) |d| {
            const next = d.next;
            d.destroy(self);
            dyn = next;
        }
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

    fn escapeParserExpression(self: *VM, expr: []const u8) ![]const u8 {
        var result = std.ArrayList(u8).init(self.allocator);
        defer result.deinit();
        
        var i: usize = 0;
        while (i < expr.len) {
            const byte = expr[i];
            switch (byte) {
                '\n' => {
                    try result.appendSlice("\\n");
                    i += 1;
                },
                '\t' => {
                    try result.appendSlice("\\t");
                    i += 1;
                },
                '\r' => {
                    try result.appendSlice("\\r");
                    i += 1;
                },
                ' ' => {
                    try result.appendSlice("\\s"); // space as \s for clarity
                    i += 1;
                },
                0x00...0x08, 0x0B, 0x0C, 0x0E...0x1F, 0x7F => {
                    // Other control characters
                    try result.writer().print("\\u{X:0>4}", .{byte});
                    i += 1;
                },
                0x80...0xFF => {
                    // Try to decode as UTF-8
                    const len = std.unicode.utf8ByteSequenceLength(byte) catch {
                        // Invalid UTF-8 start byte
                        try result.writer().print("\\u{X:0>4}", .{byte});
                        i += 1;
                        continue;
                    };
                    
                    if (i + len > expr.len) {
                        // Incomplete UTF-8 sequence
                        try result.writer().print("\\u{X:0>4}", .{byte});
                        i += 1;
                        continue;
                    }
                    
                    const utf8_bytes = expr[i..i+len];
                    const codepoint = std.unicode.utf8Decode(utf8_bytes) catch {
                        // Invalid UTF-8 sequence
                        try result.writer().print("\\u{X:0>4}", .{byte});
                        i += 1;
                        continue;
                    };
                    
                    // Check if it's a printable character
                    if (codepoint >= 32 and codepoint <= 126) {
                        // Printable ASCII - add as-is
                        try result.appendSlice(utf8_bytes);
                    } else {
                        // Non-printable Unicode - escape it
                        try result.writer().print("\\u{X:0>4}", .{codepoint});
                    }
                    i += len;
                },
                else => {
                    try result.append(byte);
                    i += 1;
                },
            }
        }
        
        return result.toOwnedSlice();
    }

    pub fn reportErrors(self: *VM) !void {
        // Report errors if any were collected
        if (self.error_log.errors_by_position.count() > 0 or self.error_log.errors_by_function.count() > 0) {
            try self.writers.err.print("Parse failed:\n\n", .{});
            
            // First, report any high-frequency patterns from function tracking
            var function_iterator = self.error_log.errors_by_function.iterator();
            while (function_iterator.next()) |entry| {
                const data = entry.value_ptr;
                if (data.total_count > 6) {
                    try self.formatRepetitiveError(entry.key_ptr, data);
                }
            }
            
            // Then, find position with most errors for detailed breakdown
            var best_position: ?usize = null;
            var most_errors: usize = 0;
            
            var position_iterator = self.error_log.errors_by_position.iterator();
            while (position_iterator.next()) |entry| {
                const total_errors = entry.value_ptr.parser_failures.items.len + 
                                   entry.value_ptr.destructure_failures.items.len;
                if (total_errors > most_errors) {
                    most_errors = total_errors;
                    best_position = entry.key_ptr.*;
                }
            }
            
            if (best_position) |pos| {
                try self.formatErrorsAtPosition(pos);
            }
        }
    }
    
    fn formatRepetitiveError(self: *VM, key: *const @import("error_log.zig").FunctionErrorKey, data: *const @import("error_log.zig").FunctionErrorData) !void {
        const clean_stack = try self.cleanCallStack(data.first_call_stack);
        defer self.allocator.free(clean_stack);
        
        const escaped_parser = try self.escapeParserExpression(key.parser);
        defer self.allocator.free(escaped_parser);
        try self.writers.err.print("Expected {s}", .{escaped_parser});
        
        if (data.total_count <= 6) {
            // Show all positions
            try self.writers.err.print(" at positions ", .{});
            for (data.first_positions.constSlice(), 0..) |pos, i| {
                if (i > 0) try self.writers.err.print(", ", .{});
                try self.writers.err.print("{}", .{pos});
            }
        } else {
            // Show first few, last few, and total
            try self.writers.err.print(" at positions ", .{});
            for (data.first_positions.constSlice(), 0..) |pos, i| {
                if (i > 0) try self.writers.err.print(", ", .{});
                try self.writers.err.print("{}", .{pos});
            }
            try self.writers.err.print("...", .{});
            for (data.last_positions.constSlice(), 0..) |pos, i| {
                try self.writers.err.print(" {}", .{pos});
                if (i < data.last_positions.len - 1) try self.writers.err.print(",", .{});
            }
            try self.writers.err.print(" ({} total attempts)", .{data.total_count});
        }
        
        if (clean_stack.len > 0) {
            try self.writers.err.print("\n    in: ", .{});
            for (clean_stack, 0..) |name_id, i| {
                const name = self.strings.get(name_id);
                if (i > 0) try self.writers.err.print(" → ", .{});
                try self.writers.err.print("{s}", .{name});
            }
        }
        try self.writers.err.print("\n\n", .{});
    }
    
    fn formatErrorsAtPosition(self: *VM, position: usize) !void {
        const pos_errors = self.error_log.errors_by_position.get(position).?;
        
        // Calculate line and column for display
        const line = pos_errors.line;
        const column = position - pos_errors.line_start + 1;
        
        try self.writers.err.print("Error at line {}, column {}: parsing failed\n\n", .{line, column});
        
        if (pos_errors.parser_failures.items.len > 0) {
            // Group parser failures by call stack
            var grouped = std.StringHashMap(ArrayList(@import("error_log.zig").ParserFailure)).init(self.allocator);
            defer {
                var iter = grouped.iterator();
                while (iter.next()) |entry| {
                    self.allocator.free(entry.key_ptr.*);
                    entry.value_ptr.deinit(self.allocator);
                }
                grouped.deinit();
            }
            
            // Group failures by their call stack
            for (pos_errors.parser_failures.items) |failure| {
                const key = try self.callStackToKey(failure.call_stack);
                const result = try grouped.getOrPut(key);
                
                if (!result.found_existing) {
                    result.value_ptr.* = ArrayList(@import("error_log.zig").ParserFailure){};
                }
                
                try result.value_ptr.append(self.allocator, failure);
            }
            
            // Display grouped failures
            var iter = grouped.iterator();
            while (iter.next()) |entry| {
                const failures = entry.value_ptr.*;
                const key = entry.key_ptr.*;
                
                try self.writers.err.print("• ", .{});
                
                if (failures.items.len == 1) {
                    try self.writers.err.print("Expected ", .{});
                } else {
                    try self.writers.err.print("Expected one of ", .{});
                }
                
                // Print all parser expressions for this group
                for (failures.items, 0..) |failure, i| {
                    const escaped_parser = try self.escapeParserExpression(failure.parser);
                    defer self.allocator.free(escaped_parser);
                    
                    if (i > 0) try self.writers.err.print(", ", .{});
                    try self.writers.err.print("{s}", .{escaped_parser});
                }
                
                try self.writers.err.print("\n", .{});
                
                // Show call stack if not empty
                if (key.len > 0) {
                    try self.writers.err.print("  in: {s}\n", .{key});
                }
            }
            
            try self.writers.err.print("\n", .{});
        }
        
        // Show all destructure failures at this position  
        for (pos_errors.destructure_failures.items) |failure| {
            const clean_stack = try self.cleanCallStack(failure.call_stack);
            defer self.allocator.free(clean_stack);
            
            try self.writers.err.print("Value '{s}' did not match pattern '{s}'\n", 
                                      .{ failure.value, failure.pattern });
            if (clean_stack.len > 0) {
                try self.writers.err.print("  in: ", .{});
                for (clean_stack, 0..) |name_id, i| {
                    const name = self.strings.get(name_id);
                    if (i > 0) try self.writers.err.print(" → ", .{});
                    try self.writers.err.print("{s}", .{name});
                }
                try self.writers.err.print("\n", .{});
            }
        }
        
        // Show input context
        try self.showInputContext(position);
    }
    
    fn callStackToKey(self: *VM, call_stack: []StringTable.Id) ![]const u8 {
        var key_parts = ArrayList(u8){};
        defer key_parts.deinit(self.allocator);
        
        const cleaned = try self.cleanCallStack(call_stack);
        defer self.allocator.free(cleaned);
        
        for (cleaned, 0..) |name_id, i| {
            if (i > 0) try key_parts.appendSlice(self.allocator, "→");
            const name = self.strings.get(name_id);
            try key_parts.appendSlice(self.allocator, name);
        }
        
        return key_parts.toOwnedSlice(self.allocator);
    }

    fn cleanCallStack(self: *VM, call_stack: []StringTable.Id) ![]StringTable.Id {
        var cleaned = ArrayList(StringTable.Id){};
        
        for (call_stack) |name_id| {
            const name = self.strings.get(name_id);
            // Skip @ functions, _ prefixed functions, and @main
            if (!std.mem.startsWith(u8, name, "@") and 
                !std.mem.startsWith(u8, name, "_") and
                !std.mem.eql(u8, name, "@main")) {
                try cleaned.append(self.allocator, name_id);
            }
        }
        
        return cleaned.toOwnedSlice(self.allocator);
    }
    
    fn showInputContext(self: *VM, position: usize) !void {
        // Find the line containing the error
        var line_start: usize = 0;
        var current_line: usize = 1;
        var i: usize = 0;
        
        while (i < position and i < self.input.len) {
            if (self.isNewlineChar(i, 1) or 
                (i + 1 < self.input.len and self.isNewlineChar(i, 2)) or
                (i + 2 < self.input.len and self.isNewlineChar(i, 3))) {
                current_line += 1;
                line_start = i + 1;
            }
            i += 1;
        }
        
        // Find line end
        var line_end = line_start;
        while (line_end < self.input.len and 
               !self.isNewlineChar(line_end, 1) and
               !(line_end + 1 < self.input.len and self.isNewlineChar(line_end, 2)) and
               !(line_end + 2 < self.input.len and self.isNewlineChar(line_end, 3))) {
            line_end += 1;
        }
        
        try self.writers.err.print("Input:\n", .{});
        try self.writers.err.print("{} | {s}\n", .{current_line, self.input[line_start..line_end]});
        
        // Show position indicator
        const column = position - line_start;
        try self.writers.err.print("{}   ", .{current_line}); // Line number spaces
        var j: usize = 0;
        while (j < column) : (j += 1) {
            try self.writers.err.print(" ", .{});
        }
        try self.writers.err.print("^\n", .{});
    }
};

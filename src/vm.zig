const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const assert = std.debug.assert;
const unicode = std.unicode;
const Chunk = @import("chunk.zig").Chunk;
const Compiler = @import("compiler.zig").Compiler;
const Elem = @import("elem.zig").Elem;
const Env = @import("env.zig").Env;
const OpCode = @import("op_code.zig").OpCode;
const Parser = @import("parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const WriterError = @import("writer.zig").VMWriter.Error;
const Writers = @import("writer.zig").Writers;
const meta = @import("meta.zig");
const parsing = @import("parsing.zig");

pub const Config = struct {
    printScanner: bool = false,
    printParser: bool = false,
    printAst: bool = false,
    printCompiledBytecode: bool = false,
    printExecutedBytecode: bool = false,
    printVM: bool = false,
    runVM: bool = true,
    includeStdlib: bool = true,

    pub fn setEnv(self: *Config, env: Env) void {
        self.printScanner = env.printScanner;
        self.printParser = env.printParser;
        self.printAst = env.printAst;
        self.printCompiledBytecode = env.printCompiledBytecode;
        self.printExecutedBytecode = env.printExecutedBytecode;
        self.printVM = env.printVM;
        self.runVM = env.runVM;
    }
};

pub const VM = struct {
    allocator: Allocator,
    strings: StringTable,
    globals: AutoHashMap(StringTable.Id, Elem),
    dynList: ?*Elem.Dyn,
    stack: ArrayList(Elem),
    frames: ArrayList(CallFrame),
    input: []const u8,
    inputMarks: ArrayList(usize),
    inputPos: usize,
    uniqueIdCount: u64,
    writers: Writers,
    config: Config,

    const CallFrame = struct {
        function: *Elem.Dyn.Function,
        ip: usize,
        elemsOffset: usize,
    };
    const Error = error{
        RuntimeError,
        OutOfMemory,
        Utf8ExpectedContinuation,
        Utf8OverlongEncoding,
        Utf8EncodesSurrogateHalf,
        Utf8CodepointTooLarge,
        InvalidRange,
        NoMainParser,
    } || WriterError;

    pub fn create() VM {
        const self = VM{
            .allocator = undefined,
            .strings = undefined,
            .globals = undefined,
            .dynList = undefined,
            .stack = undefined,
            .frames = undefined,
            .input = undefined,
            .inputMarks = undefined,
            .inputPos = undefined,
            .uniqueIdCount = undefined,
            .writers = undefined,
            .config = undefined,
        };

        return self;
    }

    pub fn init(self: *VM, allocator: Allocator, writers: Writers, config: Config) !void {
        self.allocator = allocator;
        self.strings = StringTable.init(allocator);
        self.globals = AutoHashMap(StringTable.Id, Elem).init(allocator);
        self.dynList = null;
        self.stack = ArrayList(Elem).init(allocator);
        self.frames = ArrayList(CallFrame).init(allocator);
        self.input = undefined;
        self.inputMarks = ArrayList(usize).init(allocator);
        self.inputPos = 0;
        self.uniqueIdCount = 0;
        self.writers = writers;
        self.config = config;
        errdefer self.deinit();

        try self.loadMetaFunctions();

        if (self.config.includeStdlib) {
            try self.loadStdlib();
        }
    }

    pub fn deinit(self: *VM) void {
        self.strings.deinit();
        self.globals.deinit();
        self.freeDynList();
        self.stack.deinit();
        self.frames.deinit();
        self.inputMarks.deinit();
    }

    pub fn interpret(self: *VM, programSource: []const u8, input: []const u8) !Elem {
        if (input.len > std.math.maxInt(u32)) return error.InputTooLong;

        self.input = input;
        try self.compile(programSource);
        try self.run();
        assert(self.stack.items.len == 1);

        return self.pop();
    }

    pub fn compile(self: *VM, programSource: []const u8) !void {
        var parser = Parser.init(self);
        defer parser.deinit();

        try parser.parse(programSource);

        if (self.config.printAst) {
            try parser.ast.print(self.*, self.writers.debug);
        }

        var compiler = try Compiler.init(self, parser.ast, self.config.printCompiledBytecode);
        defer compiler.deinit();

        const function = try compiler.compile();

        if (function) |main| {
            try self.push(main.dyn.elem());
            try self.addFrame(main);
        }
    }

    fn loadMetaFunctions(self: *VM) !void {
        const functions = try meta.functions(self);

        for (functions) |function| {
            try self.globals.put(function.name, function.dyn.elem());
        }
    }

    fn loadStdlib(self: *VM) !void {
        const stdlibSource = @embedFile("./stdlib.possum");
        var parser = Parser.init(self);
        defer parser.deinit();

        try parser.parse(stdlibSource);

        var compiler = try Compiler.init(self, parser.ast, false);
        defer compiler.deinit();

        _ = try compiler.compile();
    }

    pub fn run(self: *VM) !void {
        if (self.frames.items.len == 0) {
            return Error.NoMainParser;
        }

        if (self.config.printExecutedBytecode) {
            try self.frame().function.disassemble(self.*, self.writers.debug);
        }

        while (true) {
            try self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
            if (self.frames.items.len == 0) break;
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
                            var closure = try Elem.Dyn.Closure.create(self, function);
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
                // Postfix, lhs pattern and rhs value on stack.
                const pattern = self.pop();
                const value = self.pop();

                if (value.isSuccess()) {
                    if (pattern == .ValueVar) {
                        self.bindLocalVariable(value, pattern);
                        try self.push(value);
                    } else if (Elem.isValueMatchingPattern(value, pattern, self.*)) {
                        try self.push(value);
                    } else {
                        try self.pushFailure();
                    }
                } else {
                    try self.pushFailure();
                }
            },
            .DestructureRange => {
                // Postfix, value, lower bound, and upper bound on stack
                const high = self.pop();
                const low = self.pop();
                const value = self.pop();

                // Unlike with range parsers, there are no compile-time
                // garentees that range patterns are correctly ordered or
                // typed.
                const low_is_valid_type = low == .ValueVar or low == .String or low.isNumber();
                const high_is_valid_type = high == .ValueVar or high == .String or high.isNumber();
                const range_is_ordered = try low.isLessThanOrEqualInRangePattern(high, self.*);

                if (!low_is_valid_type or !high_is_valid_type or !range_is_ordered) {
                    return self.runtimeError("Invalid range in pattern", .{});
                }

                if (try Elem.isValueInRangePattern(value, low, high, self.*)) {
                    if (low == .ValueVar) self.bindLocalVariable(value, low);
                    if (high == .ValueVar) self.bindLocalVariable(value, high);
                    try self.push(value);
                } else {
                    try self.pushFailure();
                }
            },
            .End => {
                // End of function cleanup. Remove everything from the stack
                // frame except the final function result.
                const prevFrame = self.frames.pop();
                const result = self.pop();

                try self.stack.resize(prevFrame.elemsOffset);
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
            .GetAtKey => {
                const idx = self.readByte();
                const key = switch (self.chunk().getConstant(idx)) {
                    .String => |sId| sId,
                    else => @panic("Internal Error"),
                };
                const elem = self.peek(0);

                if (elem.isSuccess()) {
                    const object = elem.asDyn().asObject();
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
                const array = self.pop().asDyn().asArray();

                if (elem.isFailure()) {
                    try self.pushFailure();
                } else {
                    var copy = try Elem.Dyn.Array.copy(self, array.elems.items);
                    copy.elems.items[index] = elem;
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertAtKey => {
                const idx = self.readByte();
                const keyElem = self.chunk().getConstant(idx);
                const val = self.pop();
                const object = self.pop().asDyn().asObject();

                if (val.isFailure()) {
                    try self.pushFailure();
                } else {
                    const key = switch (keyElem) {
                        .String => |sId| sId,
                        else => @panic("Internal Error"),
                    };
                    var copy = try Elem.Dyn.Object.create(self, object.members.count());
                    try copy.concat(object);
                    try copy.members.put(key, val);
                    try self.push(copy.dyn.elem());
                }
            },
            .InsertKeyVal => {
                const val = self.pop();
                const keyElem = self.pop();
                const object = self.pop().asDyn().asObject();

                if (val.isFailure() or keyElem.isFailure()) {
                    try self.pushFailure();
                } else {
                    var key: StringTable.Id = undefined;

                    if (keyElem.isType(.String)) {
                        key = keyElem.String;
                    } else if (keyElem.stringBytes(self.*)) |bytes| {
                        key = try self.strings.insert(bytes);
                    } else {
                        return self.runtimeError("Object key must be a string", .{});
                    }

                    var copy = try Elem.Dyn.Object.create(self, object.members.count());
                    try copy.concat(object);
                    try copy.members.put(key, val);
                    try self.push(copy.dyn.elem());
                }
            },
            .Jump => {
                const offset = self.readShort();
                self.frame().ip += offset;
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekIsFailure()) self.frame().ip += offset;
            },
            .JumpIfSuccess => {
                const offset = self.readShort();
                if (self.peekIsSuccess()) self.frame().ip += offset;
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
            .NumberOf => {
                if (self.peekIsSuccess()) {
                    const value = self.pop();
                    if (try value.toNumber(self)) |n| {
                        try self.push(n);
                    } else {
                        try self.pushFailure();
                    }
                }
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
                const start = self.inputPos;

                if (start < self.input.len) {
                    const bytesLength = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
                    const end = start + bytesLength;

                    self.inputPos = end;

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
            .Pop => {
                _ = self.pop();
            },
            .PrepareMergePattern => {
                // Set up the stack for destructuring each part of a merge pattern.
                // Pop `count` number of elems off the stack, these are the
                // pattern segments to destructure against. Do some analysis
                // and then push `count` new elements back onto the stack.
                // These elements are sub-values of the destructure value, which
                // will each get destructured separately.
                const count = self.readByte();

                try self.prepareMergePattern(count);
            },
            .Swap => {
                const a = self.pop();
                const b = self.pop();
                try self.push(a);
                try self.push(b);
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

    fn callFunction(self: *VM, elem: Elem, argCount: u8, isTailPosition: bool) Error!void {
        switch (elem) {
            .ParserVar => |varName| {
                if (self.globals.get(varName)) |varElem| {
                    // Swap the var with the thing it's aliasing on the stack
                    self.stack.items[self.frame().elemsOffset] = varElem;
                    try self.callFunction(varElem, argCount, isTailPosition);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
            .String => |sId| {
                assert(argCount == 0);
                _ = self.pop();
                const s = self.strings.get(sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
                try self.pushFailure();
            },
            .NumberString => |n| {
                assert(argCount == 0);
                _ = self.pop();
                const bytes = n.toString(self.strings);
                const start = self.inputPos;
                const end = start + bytes.len;

                if (self.input.len >= end and std.mem.eql(u8, bytes, self.input[start..end])) {
                    self.inputPos = end;
                    try self.push(elem);
                    return;
                }
                try self.pushFailure();
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .Function => {
                    var function = dyn.asFunction();

                    if (self.config.printExecutedBytecode) {
                        try function.disassemble(self.*, self.writers.debug);
                    }

                    if (function.arity == argCount) {
                        if (isTailPosition) {
                            // Remove the elements belonging to the previous call
                            // frame. This includes the function itself, its
                            // arguments, and any added local variables.
                            const frameStart = self.frame().elemsOffset;
                            const frameEnd = self.stack.items.len - function.arity - 1;
                            const length = frameEnd - frameStart;
                            try self.stack.replaceRange(frameStart, length, &[0]Elem{});
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

    fn parseCharacterRange(self: *VM, low_id: StringTable.Id, high_id: StringTable.Id) !void {
        const low = unicode.utf8Decode(self.strings.get(low_id)) catch @panic("Internal Error");
        const high = unicode.utf8Decode(self.strings.get(high_id)) catch @panic("Internal Error");
        const low_length = unicode.utf8CodepointSequenceLength(low) catch 1;
        const high_length = unicode.utf8CodepointSequenceLength(high) catch 1;
        const start = self.inputPos;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (low_length <= bytes_length and bytes_length <= high_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (low <= codepoint and codepoint <= high) {
                    self.inputPos = end;

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseCharacterLowerBounded(self: *VM, low_id: StringTable.Id) !void {
        const low = unicode.utf8Decode(self.strings.get(low_id)) catch @panic("Internal Error");
        const low_length = unicode.utf8CodepointSequenceLength(low) catch @panic("Internal Error");
        const start = self.inputPos;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (low_length <= bytes_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (low <= codepoint) {
                    self.inputPos = end;

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseCharacterUpperBounded(self: *VM, high_id: StringTable.Id) !void {
        const high = unicode.utf8Decode(self.strings.get(high_id)) catch @panic("Internal Error");
        const high_length = unicode.utf8CodepointSequenceLength(high) catch @panic("Internal Error");
        const start = self.inputPos;

        if (start < self.input.len) {
            const bytes_length = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
            const end = start + bytes_length;

            if (bytes_length <= high_length and end <= self.input.len) {
                const codepoint = try unicode.utf8Decode(self.input[start..end]);
                if (codepoint <= high) {
                    self.inputPos = end;

                    const substring = Elem.inputSubstring(@as(u32, @intCast(start)), @as(u32, @intCast(end)));
                    try self.push(substring);

                    return;
                }
            }
        }
        try self.pushFailure();
    }

    fn parseIntegerRange(self: *VM, low: i64, high: i64) !void {
        const lowIntLen = parsing.intAsStringLen(low);
        const highIntLen = parsing.intAsStringLen(high);
        const start = self.inputPos;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);
        const longestMatchEnd = @min(start + highIntLen, self.input.len);

        var end = longestMatchEnd;

        // Find the longest substring from the start of the input which
        // parses as an integer, is greater than or equal to `low` and
        // less than or equal to `high`, and is at least one char long.
        while (end >= shortestMatchEnd and end > start) {
            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (low <= i and i <= high) {
                self.inputPos = end;
                const int = Elem.integer(i);
                try self.push(int);
                return;
            };
            end -= 1;
        }
        try self.pushFailure();
    }

    fn parseIntegerLowerBounded(self: *VM, low: i64) !void {
        const lowIntLen = parsing.intAsStringLen(low);
        const start = self.inputPos;
        const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

        var end = shortestMatchEnd;

        // The integer has no upper bound, so keep eating digits
        while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
            end += 1;
        }

        const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

        if (inputInt) |i| if (low <= i) {
            self.inputPos = end;
            const int = Elem.integer(i);
            try self.push(int);
            return;
        };

        try self.pushFailure();
    }

    fn parseIntegerUpperBounded(self: *VM, high: i64) !void {
        if (self.input[self.inputPos] == '-') {
            // If it's a negative integer then the max number of digits is unbounded
            const lowIntLen = 2;
            const start = self.inputPos;
            const shortestMatchEnd = @min(start + lowIntLen, self.input.len);

            var end = shortestMatchEnd;

            // The negative integer has no lower bound, so keep eating digits
            while (end < self.input.len and self.input[end] >= '0' and self.input[end] <= '9') {
                end += 1;
            }

            const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

            if (inputInt) |i| if (i <= high) {
                self.inputPos = end;
                const int = Elem.integer(i);
                try self.push(int);
                return;
            };

            try self.pushFailure();
        } else {
            // Since the integer is not negative we can assume it's between 0 and the upper bound
            try self.parseIntegerRange(0, high);
        }
    }

    fn bindLocalVariable(self: *VM, value: Elem, pattern: Elem) void {
        switch (pattern) {
            .ValueVar => |varId| {
                if (varId == self.strings.getId("_")) return;

                const slot = self.frame().function.localSlot(varId).?;
                if (self.getLocal(slot).isType(.ValueVar)) {
                    self.setLocal(slot, value);
                }
            },
            else => @panic("Internal Error"),
        }
    }

    const PatternMergeContext = union(enum) {
        Array: struct {
            preVarLength: usize,
            postVarLength: usize,
        },
        Boolean: struct {
            acc: Elem,
        },
        Number: struct {
            acc: Elem,
        },
        Object: void,
        String: struct {
            preVarLength: usize,
            postVarLength: usize,
        },
        Unknown: void,
    };

    fn prepareMergePattern(self: *VM, count: u8) !void {
        var patternSegments = try self.allocator.alloc(Elem, count);
        defer self.allocator.free(patternSegments);

        var foundUnboundVar = false;
        var context = PatternMergeContext{ .Unknown = undefined };

        // Iterate BACKWARDS by poping pattern segments off the stack
        for (0..count) |offset| {
            const index = count - offset - 1;
            const segment = self.pop();
            patternSegments[index] = segment;

            switch (segment) {
                .ValueVar => {
                    if (foundUnboundVar) {
                        return self.runtimeError("Pattern may only contain one unbound variable.", .{});
                    } else {
                        foundUnboundVar = true;
                    }
                },
                .String => |sId| {
                    if (context == .Unknown) {
                        context = .{ .String = .{ .preVarLength = 0, .postVarLength = 0 } };
                    } else if (context != .String) {
                        return self.runtimeError("Merge type mismatch in pattern", .{});
                    }

                    // Post happends before pre because backwards
                    const strLen = self.strings.get(sId).len;
                    if (foundUnboundVar) {
                        context.String.preVarLength += strLen;
                    } else {
                        context.String.postVarLength += strLen;
                    }
                },
                .InputSubstring => |is| {
                    if (context == .Unknown) {
                        context = .{ .String = .{ .preVarLength = 0, .postVarLength = 0 } };
                    } else if (context != .String) {
                        return self.runtimeError("Merge type mismatch in pattern", .{});
                    }

                    // Post happends before pre because backwards
                    const strLen = is[1] - is[0];
                    if (foundUnboundVar) {
                        context.String.preVarLength += strLen;
                    } else {
                        context.String.postVarLength += strLen;
                    }
                },
                .NumberString,
                .Integer,
                .Float,
                => {
                    if (context == .Unknown) {
                        context = .{ .Number = .{ .acc = Elem.integer(0) } };
                    } else if (context != .Number) {
                        return self.runtimeError("Merge type mismatch in pattern", .{});
                    }

                    context.Number.acc = (try context.Number.acc.merge(segment, self)).?;
                },
                .Boolean => {
                    if (context == .Unknown) {
                        context = .{ .Boolean = .{ .acc = Elem.boolean(false) } };
                    } else if (context != .Boolean) {
                        return self.runtimeError("Merge type mismatch in pattern", .{});
                    }

                    context.Boolean.acc = (try context.Boolean.acc.merge(segment, self)).?;
                },
                .Null => {},
                .ParserVar,
                .Failure,
                => @panic("Internal Error"),
                .Dyn => |dyn| switch (dyn.dynType) {
                    .String => {
                        if (context == .Unknown) {
                            context = .{ .String = .{ .preVarLength = 0, .postVarLength = 0 } };
                        } else if (context != .String) {
                            return self.runtimeError("Merge type mismatch in pattern", .{});
                        }

                        // Post happends before pre because backwards
                        const strLen = dyn.asString().len();
                        if (foundUnboundVar) {
                            context.String.preVarLength += strLen;
                        } else {
                            context.String.postVarLength += strLen;
                        }
                    },
                    .Array => {
                        if (context == .Unknown) {
                            context = .{ .Array = .{ .preVarLength = 0, .postVarLength = 0 } };
                        } else if (context != .Array) {
                            return self.runtimeError("Merge type mismatch in pattern", .{});
                        }

                        // Post happends before pre because backwards
                        const len = dyn.asArray().elems.items.len;
                        if (foundUnboundVar) {
                            context.Array.preVarLength += len;
                        } else {
                            context.Array.postVarLength += len;
                        }
                    },
                    .Object => {
                        if (context == .Unknown) {
                            context = .{ .Object = undefined };
                        } else if (context != .Object) {
                            return self.runtimeError("Merge type mismatch in pattern", .{});
                        }
                    },
                    .Function,
                    .Closure,
                    => @panic("internal error"),
                },
            }
        }

        const value = self.peek(0);

        switch (context) {
            .Array => |ac| {
                if (value.isDynType(.Array)) {
                    const valueArray = value.asDyn().asArray();
                    const valueLength = valueArray.elems.items.len;
                    const patternMinLength = ac.preVarLength + ac.postVarLength;

                    if ((foundUnboundVar and valueLength >= patternMinLength) or valueLength == patternMinLength) {
                        var valueIndex: usize = 0;
                        for (patternSegments, 0..) |segment, i| {
                            if (segment == .ValueVar) {
                                assert(valueIndex == ac.preVarLength);

                                const length = valueLength - ac.preVarLength - ac.postVarLength;
                                const subarray = try valueArray.subarray(self, valueIndex, length);

                                valueIndex += length;
                                patternSegments[i] = subarray.dyn.elem();
                            } else {
                                const segmentArray = segment.asDyn().asArray();

                                const subarray = try valueArray.subarray(self, valueIndex, segmentArray.len());

                                valueIndex += subarray.len();
                                patternSegments[i] = subarray.dyn.elem();
                            }
                        }

                        var i = patternSegments.len;
                        while (i > 0) {
                            i -= 1;
                            try self.push(patternSegments[i]);
                        }
                    } else {
                        _ = self.pop();
                        try self.pushFailure();
                    }
                } else {
                    _ = self.pop();
                    try self.pushFailure();
                }
            },
            .Boolean => |bc| {
                if (value == .Boolean) {
                    if (value.Boolean) {
                        var i: usize = patternSegments.len;
                        while (i > 0) {
                            i -= 1;
                            if (patternSegments[i] == .ValueVar) {
                                // Only assign the unbound variable to true if it
                                // has to be true to make the pattern match.
                                // Otherwise default to false, the identity value.
                                if (bc.acc.Boolean) {
                                    try self.push(Elem.boolean(false));
                                } else {
                                    try self.push(Elem.boolean(true));
                                }
                            } else {
                                try self.push(patternSegments[i]);
                            }
                        }
                    } else {
                        // To successfully destructure, all pattern
                        // segments must be false.
                        for (patternSegments) |_| {
                            try self.push(Elem.boolean(false));
                        }
                    }
                } else {
                    _ = self.pop();
                    try self.pushFailure();
                }
            },
            .Number => |nc| {
                const subtrahend = nc.acc.negateNumber() catch @panic("Internal Error");
                if (try Elem.merge(value, subtrahend, self)) |diff| {
                    var i: usize = patternSegments.len;
                    while (i > 0) {
                        i -= 1;
                        if (patternSegments[i] == .ValueVar) {
                            try self.push(diff);
                        } else {
                            try self.push(patternSegments[i]);
                        }
                    }
                } else {
                    _ = self.pop();
                    try self.pushFailure();
                }
            },
            .Object => {},
            .String => |sc| {
                const valueString = value.stringBytes(self.*);

                if (valueString) |bytes| {
                    const valueLength = bytes.len;
                    const patternMinLength = sc.preVarLength + sc.postVarLength;

                    if ((foundUnboundVar and valueLength >= patternMinLength) or valueLength == patternMinLength) {
                        var valueIndex: usize = 0;
                        for (patternSegments, 0..) |segment, i| {
                            if (segment == .ValueVar) {
                                assert(valueIndex == sc.preVarLength);

                                const length = valueLength - sc.preVarLength - sc.postVarLength;
                                const substring = try Elem.Dyn.String.copy(self, bytes[valueIndex..(valueIndex + length)]);

                                valueIndex += length;
                                patternSegments[i] = substring.dyn.elem();
                            } else {
                                const segmentString = if (segment == .String)
                                    self.strings.get(segment.String)
                                else
                                    segment.asDyn().asString().bytes();

                                const substring = try Elem.Dyn.String.copy(self, bytes[valueIndex..(valueIndex + segmentString.len)]);

                                valueIndex += substring.len();
                                patternSegments[i] = substring.dyn.elem();
                            }
                        }

                        var i = patternSegments.len;
                        while (i > 0) {
                            i -= 1;
                            try self.push(patternSegments[i]);
                        }
                    } else {
                        _ = self.pop();
                        try self.pushFailure();
                    }
                } else {
                    _ = self.pop();
                    try self.pushFailure();
                }
            },
            .Unknown => {
                // This can only happen if the merge pattern is made up
                // of unbound variables and nulls. If there's an
                // unbound variable it should get bound to the full
                // value.
                var i: usize = patternSegments.len;
                while (i > 0) {
                    i -= 1;
                    if (patternSegments[i] == .ValueVar) {
                        try self.push(value);
                    } else {
                        try self.push(patternSegments[i]);
                    }
                }
            },
        }
    }

    fn frame(self: *VM) *CallFrame {
        return &self.frames.items[self.frames.items.len - 1];
    }

    fn chunk(self: *VM) *Chunk {
        return &self.frame().function.chunk;
    }

    fn addFrame(self: *VM, function: *Elem.Dyn.Function) !void {
        try self.frames.append(CallFrame{
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

    fn push(self: *VM, elem: Elem) !void {
        try self.stack.append(elem);
    }

    fn pushFailure(self: *VM) !void {
        try self.push(Elem.failureConst);
    }

    fn pop(self: *VM) Elem {
        return self.stack.pop();
    }

    fn peek(self: *VM, distance: usize) Elem {
        const len = self.stack.items.len;
        return self.stack.items[(len - 1) - distance];
    }

    fn peekIsFailure(self: *VM) bool {
        return self.peek(0) == .Failure;
    }

    fn peekIsSuccess(self: *VM) bool {
        return !self.peekIsFailure();
    }

    fn pushInputMark(self: *VM) !void {
        try self.inputMarks.append(self.inputPos);
    }

    fn popInputMark(self: *VM) usize {
        return self.inputMarks.pop();
    }

    fn printInput(self: *VM) !void {
        try self.writers.debug.print("input   | ", .{});
        try self.writers.debug.print("{s} @ {d}\n", .{ self.input, self.inputPos });
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

    fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const loc = self.chunk().locations.items[self.frame().ip];
        try loc.print(self.writers.err);
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
};

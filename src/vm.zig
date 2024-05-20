const std = @import("std");
const unicode = std.unicode;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const Elem = @import("./elem.zig").Elem;
const OpCode = @import("./op_code.zig").OpCode;
const Parser = @import("./parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const assert = std.debug.assert;
const Compiler = @import("./compiler.zig").Compiler;
const json = std.json;
const debug = @import("./debug.zig");
const meta = @import("meta.zig");
const VMWriter = @import("./writer.zig").VMWriter;
const Env = @import("env.zig").Env;

const CallFrame = struct {
    function: *Elem.Dyn.Function,
    ip: usize,
    elemsOffset: usize,
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
    errWriter: VMWriter,
    env: Env,

    const Error = error{
        RuntimeError,
        OutOfMemory,
        Utf8ExpectedContinuation,
        Utf8OverlongEncoding,
        Utf8EncodesSurrogateHalf,
        Utf8CodepointTooLarge,
        InvalidRange,
        NoMainParser,
    } || VMWriter.Error;

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
            .errWriter = undefined,
            .env = undefined,
        };

        return self;
    }

    pub fn init(self: *VM, allocator: Allocator, errWriter: VMWriter, env: Env) !void {
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
        self.errWriter = errWriter;
        self.env = env;

        try self.loadMetaFunctions();
        try self.loadStdlib();
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
        try parser.end();

        var compiler = try Compiler.init(self, parser.ast, self.env.printCompiledBytecode);
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

        if (self.env.printExecutedBytecode) {
            try self.frame().function.disassemble(self.strings, self.errWriter);
        }

        while (true) {
            self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
            if (self.frames.items.len == 0) break;
        }

        self.printDebug();
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
            .Destructure => {
                // Postfix, lhs pattern and rhs value on stack.
                //
                // Bind pattern variables: Check if the pattern contains any
                // variables that are now set in the local scope. If so update
                // the pattern to match the local's value.
                //
                // Pattern match:
                // If rhs succeeded then pattern match, drop lhs, keep rhs or fail.
                // If rhs failed then drop lhs, keep rhs.
                //
                // Bind local variables: Check if the pattern contains any
                // variables that are still unbound in the local scope. If so
                // update each local to match the corresponding part of the
                // matched value.
                const pattern = self.pop();
                const value = self.pop();

                if (value.isSuccess()) {
                    const boundPattern = try self.bindVars(pattern, false);

                    if (value.isValueMatchingPattern(boundPattern, self.strings)) {
                        try self.push(value);
                    } else {
                        try self.pushFailure();
                    }

                    self.bindLocalVariables(pattern, value);
                } else {
                    try self.push(value);
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
                try self.push(Elem.falseConst);
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
            .NegateNumber => {
                const num = self.pop();

                if (Elem.negateNumber(num)) |value| {
                    try self.push(value);
                } else {
                    return self.runtimeError("Subtraction is only supported for numbers.", .{});
                }
            },
            .Null => {
                // Push singleton null value.
                try self.push(Elem.nullConst);
            },
            .NumberOf => {
                if (self.peekIsSuccess()) {
                    const value = self.pop();
                    if (try value.toNumber(&self.strings)) |n| {
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
            .ResolveUnboundVars => {
                const value = self.pop();
                try self.push(try self.bindVars(value, true));
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
                try self.push(Elem.trueConst);
            },
        }
    }

    pub fn nextUniqueId(self: *VM) u64 {
        const id = self.uniqueIdCount;
        self.uniqueIdCount += 1;
        return id;
    }

    fn printDebug(self: *VM) void {
        if (self.env.printVM) {
            debug.print("\n", .{});
            self.printInput();
            self.printFrames();
            self.printElems();

            if (self.frames.items.len > 0) {
                _ = self.chunk().disassembleInstruction(self.frame().ip, self.strings, debug.writer) catch {};
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
                    try self.push(elem);
                    return;
                }
                try self.pushFailure();
            },
            .IntegerString => |n| {
                assert(argCount == 0);
                _ = self.pop();
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    try self.push(elem);
                    return;
                }
                try self.pushFailure();
            },
            .FloatString => |n| {
                assert(argCount == 0);
                _ = self.pop();
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    try self.push(elem);
                    return;
                }
                try self.pushFailure();
            },
            .IntegerRange => |r| {
                assert(argCount == 0);
                _ = self.pop();
                const lowIntLen = intLength(r[0]);
                const highIntLen = intLength(r[1]);
                const start = self.inputPos;
                const shortestMatchEnd = @min(start + lowIntLen, self.input.len);
                const longestMatchEnd = @min(start + highIntLen, self.input.len);

                var end = longestMatchEnd;

                // Find the longest substring from the start of the input which
                // parses as an integer, is greater than or equal to r.lowValue and
                // less than or equal to r.highValue.
                while (end >= shortestMatchEnd) {
                    const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

                    if (inputInt) |i| if (r[0] <= i and i <= r[1]) {
                        self.inputPos = end;
                        const int = Elem.integer(i);
                        try self.push(int);
                        return;
                    };
                    end -= 1;
                }
                try self.pushFailure();
            },
            .CharacterRange => |r| {
                assert(argCount == 0);
                _ = self.pop();
                const start = self.inputPos;

                if (start < self.input.len) {
                    const bytesLength = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
                    const end = start + bytesLength;

                    if (r.lowLength <= bytesLength and bytesLength <= r.highLength and end <= self.input.len) {
                        const codepoint = try unicode.utf8Decode(self.input[start..end]);
                        if (r.low <= codepoint and codepoint <= r.high) {
                            self.inputPos = end;
                            const string = try Elem.Dyn.String.copy(self, self.input[start..end]);
                            try self.push(string.dyn.elem());
                            return;
                        }
                    }
                }
                try self.pushFailure();
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .Function => {
                    var function = dyn.asFunction();

                    if (self.env.printExecutedBytecode) {
                        try function.disassemble(self.strings, debug.writer);
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

    fn bindVars(self: *VM, patternOrValue: Elem, failIfUnbound: bool) !Elem {
        switch (patternOrValue) {
            .ValueVar => |varName| {
                const slot = self.frame().function.localSlot(varName).?;
                const local = if (failIfUnbound) try self.getBoundLocal(slot) else self.getLocal(slot);
                return local;
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .Array => {
                    const array = dyn.asArray();
                    var boundArray = try Elem.Dyn.Array.copy(self, array.elems.items);

                    for (array.pattern.items) |patternElem| {
                        const slot = patternElem.slot;
                        const local = if (failIfUnbound) try self.getBoundLocal(slot) else self.getLocal(slot);
                        boundArray.elems.items[patternElem.index] = local;
                    }

                    for (boundArray.elems.items, 0..) |elem, index| {
                        boundArray.elems.items[index] = try self.bindVars(elem, failIfUnbound);
                    }

                    return boundArray.dyn.elem();
                },
                .Object => {
                    var object = dyn.asObject();
                    var boundObject = try Elem.Dyn.Object.create(self, object.members.count());
                    try boundObject.concat(object);

                    for (object.pattern.items) |patternElem| {
                        if (patternElem.replace == .Value) {
                            const slot = patternElem.slot;
                            const local = if (failIfUnbound) try self.getBoundLocal(slot) else self.getLocal(slot);

                            try boundObject.members.put(patternElem.key, local);
                        }
                    }

                    for (object.pattern.items) |patternElem| {
                        if (patternElem.replace == .Key) {
                            if (boundObject.members.fetchOrderedRemove(patternElem.key)) |kv| {
                                const slot = patternElem.slot;
                                const local = if (failIfUnbound) try self.getBoundLocal(slot) else self.getLocal(slot);
                                const newKey = switch (local) {
                                    .String => |sId| sId,
                                    .Dyn => |keyDyn| switch (keyDyn.dynType) {
                                        .String => blk: {
                                            const bytes = keyDyn.asString().buffer.str();
                                            const sId = try self.strings.insert(bytes);
                                            break :blk sId;
                                        },
                                        else => @panic("Internal Error"),
                                    },
                                    else => @panic("todo"),
                                };

                                try boundObject.members.put(newKey, kv.value);
                            }
                        }
                    }

                    var iterator = boundObject.members.iterator();
                    while (iterator.next()) |entry| {
                        entry.value_ptr.* = try self.bindVars(entry.value_ptr.*, failIfUnbound);
                    }

                    return boundObject.dyn.elem();
                },
                else => return patternOrValue,
            },
            else => return patternOrValue,
        }
    }

    fn bindLocalVariables(self: *VM, pattern: Elem, value: Elem) void {
        switch (pattern) {
            .ValueVar => |varName| {
                const slot = self.frame().function.localSlot(varName).?;
                if (self.getLocal(slot).isType(.ValueVar)) {
                    self.setLocal(slot, value);
                }
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .Array => {
                    const patternArray = dyn.asArray();
                    const valueArray = value.asDyn().asArray();

                    for (patternArray.elems.items, 0..) |elem, index| {
                        self.bindLocalVariables(elem, valueArray.elems.items[index]);
                    }

                    for (patternArray.pattern.items) |patternElem| {
                        if (self.getLocal(patternElem.slot).isType(.ValueVar)) {
                            self.setLocal(
                                patternElem.slot,
                                valueArray.elems.items[patternElem.index],
                            );
                        }
                    }
                },
                .Object => {
                    var patternObject = dyn.asObject();
                    var valueObject = value.asDyn().asObject();

                    var iterator = patternObject.members.iterator();
                    while (iterator.next()) |entry| {
                        self.bindLocalVariables(
                            entry.value_ptr.*,
                            valueObject.members.get(entry.key_ptr.*).?,
                        );
                    }
                },
                else => {},
            },
            else => {},
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
        return self.stack.items[len - 1 - distance];
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

    fn printInput(self: *VM) void {
        debug.print("input   | ", .{});
        debug.print("{s} @ {d}\n", .{ self.input, self.inputPos });
    }

    fn printElems(self: *VM) void {
        debug.print("Stack   | ", .{});
        for (self.stack.items, 0..) |e, idx| {
            e.print(debug.writer, self.strings) catch {};
            if (idx < self.stack.items.len - 1) debug.print(", ", .{});
        }
        debug.print("\n", .{});
    }

    fn printFrames(self: *VM) void {
        debug.print("Frames  | ", .{});
        for (self.frames.items, 0..) |f, idx| {
            f.function.print(debug.writer, self.strings) catch {};
            if (idx < self.frames.items.len - 1) debug.print(", ", .{});
        }
        debug.print("\n", .{});
    }

    fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const loc = self.chunk().locations.items[self.frame().ip];
        try loc.print(self.errWriter);
        try self.errWriter.print("Error: ", .{});
        try self.errWriter.print(message, args);
        try self.errWriter.print("\n", .{});

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

fn intLength(int: i64) usize {
    const digits = intLengthLoop(int);
    if (int < 0) {
        return digits + 1;
    } else {
        return digits;
    }
}

fn intLengthLoop(int: i64) usize {
    comptime var digits: usize = 1;

    inline while (digits < 19) : (digits += 1) {
        if (@abs(int) < std.math.pow(i64, 10, digits)) return digits;
    }
    return digits;
}

test "intLength" {
    try std.testing.expectEqual(@as(usize, 1), intLength(0));
    try std.testing.expectEqual(@as(usize, 1), intLength(5));
    try std.testing.expectEqual(@as(usize, 2), intLength(10));
    try std.testing.expectEqual(@as(usize, 3), intLength(-14));
    try std.testing.expectEqual(@as(usize, 3), intLength(104));
    try std.testing.expectEqual(@as(usize, 7), intLength(1041348));
    try std.testing.expectEqual(@as(usize, 8), intLength(-1041348));
    try std.testing.expectEqual(@as(usize, 19), intLength(std.math.maxInt(i64)));
    try std.testing.expectEqual(@as(usize, 20), intLength(std.math.minInt(i64)));
}

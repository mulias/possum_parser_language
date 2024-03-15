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
const logger = @import("./logger.zig");
const meta = @import("meta.zig");

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

    const Error = error{
        RuntimeError,
        OutOfMemory,
        Utf8ExpectedContinuation,
        Utf8OverlongEncoding,
        Utf8EncodesSurrogateHalf,
        Utf8CodepointTooLarge,
        InvalidRange,
    };

    pub fn init(allocator: Allocator) !VM {
        var self = VM{
            .allocator = allocator,
            .strings = StringTable.init(allocator),
            .globals = AutoHashMap(StringTable.Id, Elem).init(allocator),
            .dynList = null,
            .stack = ArrayList(Elem).init(allocator),
            .frames = ArrayList(CallFrame).init(allocator),
            .input = undefined,
            .inputMarks = ArrayList(usize).init(allocator),
            .inputPos = 0,
            .uniqueIdCount = 0,
        };

        try self.loadMetaFunctions();
        try self.loadStdlib();

        return self;
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
        var parser = Parser.init(self);
        defer parser.deinit();

        try parser.parse(programSource);
        try parser.end();

        var compiler = try Compiler.init(self, parser.ast);
        defer compiler.deinit();

        const function = try compiler.compile();
        try self.push(function.dyn.elem());
        try self.addFrame(function);

        self.input = input;

        try self.run();

        assert(self.stack.items.len == 1);

        return self.pop();
    }

    fn loadMetaFunctions(self: *VM) !void {
        var functions = try meta.functions(self);

        for (functions) |function| {
            try self.globals.put(function.name, function.dyn.elem());
        }
    }

    fn loadStdlib(self: *VM) !void {
        const stdlibSource = @embedFile("./stdlib.possum");
        var parser = Parser.init(self);
        defer parser.deinit();

        try parser.parse(stdlibSource);

        var compiler = try Compiler.init(self, parser.ast);
        defer compiler.deinit();

        try compiler.compileLib();
    }

    pub fn run(self: *VM) !void {
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
                if (self.peekIsSuccess()) {
                    _ = self.pop();
                    self.inputPos = self.popInputMark();
                } else {
                    self.frame().ip += offset;
                }
            },
            .BindPatternVar => {
                // Postfix, destructured value on stack.
                // If destructure succeeded then set local to part/all of value.
                // If destructure failed do nothing.
                const slot = self.readByte();
                const value = self.peek(0);
                if (value.isSuccess()) {
                    switch (self.getLocal(slot)) {
                        .ValueVar => self.setLocal(slot, value),
                        else => {},
                    }
                }
            },
            .CallParser => {
                // Postfix, function and args on stack.
                // Create new stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callParser(self.peek(argCount), argCount, false);
            },
            .CallTailParser => {
                // Postfix, function and args on stack.
                // Reuse stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callParser(self.peek(argCount), argCount, true);
            },
            .ConditionalThen => {
                // The `?` part of `condition ? then : else`
                // Infix, `condition` on stack.
                // If `condition` succeeded then continue to `then` branch.
                // If `condition` failed then jump to the start of `else` branch.
                const offset = self.readShort();
                const condition = self.pop();
                if (condition.isFailure()) {
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
                // If rhs succeeded then pattern match, drop lhs, keep rhs or fail.
                // If rhs failed then drop lhs, keep rhs.
                const value = self.pop();
                const pattern = self.pop();

                if (value.isSuccess()) {
                    if (value.isValueMatchingPattern(pattern, self.strings)) {
                        try self.push(value);
                    } else {
                        try self.pushFailure();
                    }
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
            .GetGlobal => {
                // Fetch an elem in the global scope.
                const idx = self.readByte();

                const varName = switch (self.chunk().getConstant(idx)) {
                    .ParserVar => |varName| varName,
                    .ValueVar => |varName| varName,
                    else => @panic("internal error"),
                };

                if (self.globals.get(varName)) |varElem| {
                    try self.push(varElem);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
            .GetLocal => {
                const slot = self.readByte();
                try self.push(self.getLocal(slot));
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
            .SetInputMark => {
                try self.pushInputMark();
            },
            .Succeed => {
                // Push singleton success value.
                try self.push(Elem.successConst);
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
            .Null => {
                // Push singleton null value.
                try self.push(Elem.nullConst);
            },
            .NumberOf => {
                if (self.peekIsSuccess()) {
                    const value = self.pop();
                    if (value.toNumber(self.strings)) |n| {
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
                if (self.peekIsSuccess()) {
                    self.frame().ip += offset;
                    _ = self.popInputMark();
                } else {
                    _ = self.pop();
                    self.inputPos = self.popInputMark();
                }
            },
            .Return => {
                // Postfix, lhs and rhs on stack.
                // If lhs succeeded then pop lhs and push rhs.
                // If lhs failed then discard rhs.
                const value = self.pop();
                if (self.peekIsSuccess()) {
                    _ = self.pop();
                    try self.push(value);
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
                try self.push(Elem.trueConst);
            },
            .TryResolveUnboundLocal => {
                // Get the local at `slot`, it should be unbound. Check to see
                // if there's a global with the same name, and if so set the
                // local to the same value as the global.
                const slot = self.readByte();

                const varName = switch (self.getLocal(slot)) {
                    .ValueVar => |varName| varName,
                    else => @panic("internal error"),
                };

                if (self.globals.get(varName)) |varElem| {
                    self.setLocal(slot, varElem);
                }
            },
        }
    }

    pub fn nextUniqueId(self: *VM) u64 {
        const id = self.uniqueIdCount;
        self.uniqueIdCount += 1;
        return id;
    }

    fn printDebug(self: *VM) void {
        if (logger.debugVM) {
            logger.debug("\n", .{});
            self.printInput();
            self.printFrames();
            self.printElems();

            if (self.frames.items.len > 0) {
                _ = self.chunk().disassembleInstruction(self.frame().ip, self.strings);
            }
        }
    }

    fn callParser(self: *VM, elem: Elem, argCount: u8, isTailPosition: bool) Error!void {
        switch (elem) {
            .ParserVar => |varName| {
                if (self.globals.get(varName)) |varElem| {
                    // Swap the var with the thing it's aliasing on the stack
                    self.stack.items[self.frame().elemsOffset] = varElem;
                    try self.callParser(varElem, argCount, isTailPosition);
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
                    } else {
                        end -= 1;
                    };
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
                else => @panic("Internal error"),
            },
            else => @panic("Internal error"),
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

    pub fn getLocal(self: *VM, slot: usize) Elem {
        return self.stack.items[self.frame().elemsOffset + slot];
    }

    pub fn setLocal(self: *VM, slot: usize, elem: Elem) void {
        self.stack.items[self.frame().elemsOffset + slot] = elem;
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
        var len = self.stack.items.len;
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
        logger.debug("input   | ", .{});
        logger.debug("{s} @ {d}\n", .{ self.input, self.inputPos });
    }

    fn printElems(self: *VM) void {
        logger.debug("Stack   | ", .{});
        for (self.stack.items, 0..) |e, idx| {
            e.print(logger.debug, self.strings);
            if (idx < self.stack.items.len - 1) logger.debug(", ", .{});
        }
        logger.debug("\n", .{});
    }

    fn printFrames(self: *VM) void {
        logger.debug("Frames  | ", .{});
        for (self.frames.items, 0..) |f, idx| {
            f.function.print(logger.debug, self.strings);
            if (idx < self.frames.items.len - 1) logger.debug(", ", .{});
        }
        logger.debug("\n", .{});
    }

    fn runtimeError(self: *VM, comptime message: []const u8, args: anytype) Error {
        const loc = self.chunk().locations.items[self.frame().ip];
        loc.print(logger.err);
        logger.err("Error: ", .{});
        logger.err(message, args);
        logger.err("\n", .{});

        return Error.RuntimeError;
    }

    fn freeDynList(self: *VM) void {
        var dyn = self.dynList;
        while (dyn) |d| {
            var next = d.next;
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
    const absInt = std.math.absCast(int);

    inline while (digits < 19) : (digits += 1) {
        if (absInt < std.math.pow(i64, 10, digits)) return digits;
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

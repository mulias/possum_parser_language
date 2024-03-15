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
    elems: ArrayList(Elem),
    parsed: ArrayList(Elem),
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
            .elems = ArrayList(Elem).init(allocator),
            .parsed = ArrayList(Elem).init(allocator),
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
        self.elems.deinit();
        self.parsed.deinit();
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
        try self.pushElem(function.dyn.elem());
        try self.addFrame(function);

        self.input = input;

        try self.run();

        assert(self.parsed.items.len == 0 or self.parsed.items.len == 1);

        if (self.parsed.items.len == 0) {
            return Elem.failureConst;
        } else {
            return self.popParsed();
        }
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
                // Infix, lhs on parsed stack.
                // If lhs succeeded then pop, return to prev input position.
                // If lhs failed then keep it and jump to skip rhs.
                const offset = self.readShort();
                if (self.peekParsedIsSuccess()) {
                    _ = self.popParsed();
                    self.inputPos = self.popInputMark();
                } else {
                    self.frame().ip += offset;
                }
            },
            .BindPatternVar => {
                // Postfix, destructured value on parsed stack.
                // If destructure succeeded then set local to part/all of value
                // If destructure failed do nothing.
                const slot = self.readByte();
                const value = self.peekParsed(0);
                if (value.isSuccess()) {
                    switch (self.getLocal(slot)) {
                        .ValueVar => self.setLocal(slot, value),
                        else => {},
                    }
                }
            },
            .CallParser => {
                // Postfix, function and args on elem stack.
                // Create new stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callParser(self.peekElem(argCount), argCount, false);
            },
            .CallTailParser => {
                // Postfix, function and args on elem stack.
                // Reuse stack frame and continue eval within new function.
                const argCount = self.readByte();
                try self.callParser(self.peekElem(argCount), argCount, true);
            },
            .ConditionalThen => {
                // The `?` part of `condition ? then : else`
                // Infix, `condition` on parsed stack.
                // If `condition` succeeded then continue to `then` branch.
                // If `condition` failed then jump to the start of `else` branch.
                const offset = self.readShort();
                const condition = self.popParsed();
                if (condition.isFailure()) {
                    self.frame().ip += offset;
                }
            },
            .ConditionalElse => {
                // The `:` part of `condition ? then : else`
                // Infix, `then` on parsed stack.
                // Skip over the `else` branch. This opcode is placed at the
                // end of the `then` branch, so if the `then` branch was
                // skipped over to get to the `else` branch it will never be
                // encountered.
                const offset = self.readShort();
                self.frame().ip += offset;
            },
            .Destructure => {
                // Postfix, lhs pattern on elem stack, rhs value on parsed stack.
                // If rhs succeeded then pattern match, either keep rhs or fail.
                // If rhs failed do nothing.
                const pattern = self.popElem();

                if (self.peekParsedIsSuccess()) {
                    const value = self.popParsed();

                    if (value.isValueMatchingPattern(pattern, self.strings)) {
                        try self.pushParsed(value);
                    } else {
                        try self.pushParsed(Elem.failureConst);
                    }
                }
            },
            .End => {
                // End of function cleanup.
                const prevFrame = self.frames.pop();

                try self.elems.resize(prevFrame.elemsOffset);
            },
            .Fail => {
                // Push singleton failure value onto elem stack.
                try self.pushParsed(Elem.failureConst);
            },
            .False => {
                // Push singleton false value onto elem stack.
                try self.pushElem(Elem.falseConst);
            },
            .GetGlobal => {
                const idx = self.readByte();

                const varName = switch (self.chunk().getConstant(idx)) {
                    .ParserVar => |varName| varName,
                    .ValueVar => |varName| varName,
                    else => @panic("internal error"),
                };

                if (self.globals.get(varName)) |varElem| {
                    try self.pushElem(varElem);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
            .GetLocal => {
                const slot = self.readByte();
                try self.pushElem(self.getLocal(slot));
            },
            .Jump => {
                const offset = self.readShort();
                self.frame().ip += offset;
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekParsedIsFailure()) self.frame().ip += offset;
            },
            .JumpIfSuccess => {
                const offset = self.readShort();
                if (self.peekParsedIsSuccess()) self.frame().ip += offset;
            },
            .GetConstant => {
                const idx = self.readByte();
                try self.pushElem(self.chunk().getConstant(idx));
            },
            .SetInputMark => {
                try self.pushInputMark();
            },
            .Succeed => {
                // Push singleton success value onto elem stack.
                try self.pushParsed(Elem.successConst);
            },
            .MergeElems => {
                // Postfix, lhs and rhs on elem stack.
                // Pop both elems and merge, push result. If the elems can't
                // be merged that's a runtime error.
                const rhs = self.popElem();
                const lhs = self.popElem();

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    try self.pushElem(value);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .MergeParsed => {
                // Postfix, lhs and rhs on parsed stack.
                // Pop both elems and merge, push result. If the elems can't
                // be merged that's a runtime error. If either operand failed
                // then the merged result will be a failure.
                const rhs = self.popParsed();
                const lhs = self.popParsed();

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    try self.pushParsed(value);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .Null => {
                // Push singleton null value onto elem stack.
                try self.pushElem(Elem.nullConst);
            },
            .NumberOf => {
                if (self.peekParsedIsSuccess()) {
                    const value = self.popParsed();
                    if (value.toNumber(self.strings)) |n| {
                        try self.pushParsed(n);
                    } else {
                        try self.pushParsed(Elem.failureConst);
                    }
                }
            },
            .Or => {
                // Infix, lhs on parsed stack.
                // - If lhs succeeded then jump to skip rhs.
                // - If lhs fialed then pop, return to prev input position.
                const offset = self.readShort();
                if (self.peekParsedIsSuccess()) {
                    self.frame().ip += offset;
                    _ = self.popInputMark();
                } else {
                    _ = self.popParsed();
                    self.inputPos = self.popInputMark();
                }
            },
            .Return => {
                // Postfix, lhs on parsed stack, rhs on elems stack.
                // If lhs succeeded then pop and push rhs onto parsed stack.
                // If lhs failed then discard rhs.
                const value = self.popElem();

                if (self.peekParsedIsSuccess()) {
                    _ = self.popParsed();
                    try self.pushParsed(value);
                }
            },
            .TakeLeft => {
                // Postfix, lhs and rhs on parsed stack.
                // - If rhs succeeded then keep lhs
                // - If rhs failed then pop lhs and fail.
                const rhs = self.popParsed();
                if (rhs.isFailure()) {
                    _ = self.popParsed();
                    try self.pushParsed(Elem.failureConst);
                }
            },
            .TakeRight => {
                // Infix, lhs on parsed stack.
                // - If lhs succeeded then pop, to be replaced with rhs.
                // - If lhs failed then keep it and jump to skip rhs.
                const offset = self.readShort();
                if (self.peekParsedIsSuccess()) {
                    _ = self.popParsed();
                } else {
                    self.frame().ip += offset;
                }
            },
            .True => {
                // Push singleton true value onto elem stack.
                try self.pushElem(Elem.trueConst);
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
            self.printParsed();
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
                    self.elems.items[self.frame().elemsOffset] = varElem;
                    try self.callParser(varElem, argCount, isTailPosition);
                } else {
                    const nameStr = self.strings.get(varName);
                    return self.runtimeError("Undefined variable '{s}'.", .{nameStr});
                }
            },
            .String => |sId| {
                assert(argCount == 0);
                _ = self.popElem();
                const s = self.strings.get(sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    try self.pushParsed(elem);
                    return;
                }
                try self.pushParsed(Elem.failureConst);
            },
            .IntegerString => |n| {
                assert(argCount == 0);
                _ = self.popElem();
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    try self.pushParsed(elem);
                    return;
                }
                try self.pushParsed(Elem.failureConst);
            },
            .FloatString => |n| {
                assert(argCount == 0);
                _ = self.popElem();
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    try self.pushParsed(elem);
                    return;
                }
                try self.pushParsed(Elem.failureConst);
            },
            .IntegerRange => |r| {
                assert(argCount == 0);
                _ = self.popElem();
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
                        try self.pushParsed(int);
                        return;
                    } else {
                        end -= 1;
                    };
                }
                try self.pushParsed(Elem.failureConst);
            },
            .CharacterRange => |r| {
                assert(argCount == 0);
                _ = self.popElem();
                const start = self.inputPos;

                if (start < self.input.len) {
                    const bytesLength = unicode.utf8ByteSequenceLength(self.input[start]) catch 1;
                    const end = start + bytesLength;

                    if (r.lowLength <= bytesLength and bytesLength <= r.highLength and end <= self.input.len) {
                        const codepoint = try unicode.utf8Decode(self.input[start..end]);
                        if (r.low <= codepoint and codepoint <= r.high) {
                            self.inputPos = end;
                            const string = try Elem.Dyn.String.copy(self, self.input[start..end]);
                            try self.pushParsed(string.dyn.elem());
                            return;
                        }
                    }
                }
                try self.pushParsed(Elem.failureConst);
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
                            const frameEnd = self.elems.items.len - function.arity - 1;
                            const length = frameEnd - frameStart;
                            try self.elems.replaceRange(frameStart, length, &[_]Elem{});
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
            .elemsOffset = self.elems.items.len - function.arity - 1,
        });
    }

    pub fn getLocal(self: *VM, slot: usize) Elem {
        return self.elems.items[self.frame().elemsOffset + slot];
    }

    pub fn setLocal(self: *VM, slot: usize, elem: Elem) void {
        self.elems.items[self.frame().elemsOffset + slot] = elem;
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

    fn pushElem(self: *VM, elem: Elem) !void {
        try self.elems.append(elem);
    }

    fn pushParsed(self: *VM, result: Elem) !void {
        try self.parsed.append(result);
    }

    fn popElem(self: *VM) Elem {
        return self.elems.pop();
    }

    fn popParsed(self: *VM) Elem {
        return self.parsed.pop();
    }

    fn peekElem(self: *VM, distance: usize) Elem {
        var len = self.elems.items.len;
        return self.elems.items[len - 1 - distance];
    }

    fn peekParsed(self: *VM, distance: usize) Elem {
        var len = self.parsed.items.len;
        return self.parsed.items[len - 1 - distance];
    }

    fn peekParsedIsFailure(self: *VM) bool {
        return self.peekParsed(0) == .Failure;
    }

    fn peekParsedIsSuccess(self: *VM) bool {
        return !self.peekParsedIsFailure();
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
        logger.debug("Elems   | ", .{});
        for (self.elems.items, 0..) |e, idx| {
            e.print(logger.debug, self.strings);
            if (idx < self.elems.items.len - 1) logger.debug(", ", .{});
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

    fn printParsed(self: *VM) void {
        logger.debug("Parsed  | ", .{});
        for (self.parsed.items, 0..) |p, idx| {
            p.print(logger.debug, self.strings);
            if (idx < self.parsed.items.len - 1) logger.debug(", ", .{});
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

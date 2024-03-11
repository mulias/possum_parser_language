const std = @import("std");
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const Elem = @import("./elem.zig").Elem;
const OpCode = @import("./op_code.zig").OpCode;
const ParseResult = @import("parse_result.zig").ParseResult;
const Parser = @import("./parser.zig").Parser;
const StringTable = @import("string_table.zig").StringTable;
const assert = std.debug.assert;
const Compiler = @import("./compiler.zig").Compiler;
const json = std.json;
const logger = @import("./logger.zig");

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
    parsed: ArrayList(ParseResult),
    frames: ArrayList(CallFrame),
    input: []const u8,
    inputMarks: ArrayList(usize),
    inputPos: usize,

    const Error = error{
        RuntimeError,
    };

    pub fn init(allocator: Allocator) !VM {
        var self = VM{
            .allocator = allocator,
            .strings = StringTable.init(allocator),
            .globals = AutoHashMap(StringTable.Id, Elem).init(allocator),
            .dynList = null,
            .elems = ArrayList(Elem).init(allocator),
            .parsed = ArrayList(ParseResult).init(allocator),
            .frames = ArrayList(CallFrame).init(allocator),
            .input = undefined,
            .inputMarks = ArrayList(usize).init(allocator),
            .inputPos = 0,
        };

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

    pub fn interpret(self: *VM, programSource: []const u8, input: []const u8) !ParseResult {
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

        assert(self.elems.items.len == 1);

        if (self.parsed.items.len > 0) {
            return self.peekParsed(0);
        } else {
            return ParseResult.failure;
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
                const offset = self.readShort();
                const lhs = self.popParsed();
                if (lhs.isFailure()) self.frame().ip += offset;
                self.inputPos = self.popInputMark();
            },
            .CallParser => {
                const argCount = self.readByte();
                try self.callParser(self.peekElem(argCount), argCount, false);
            },
            .CallTailParser => {
                const argCount = self.readByte();
                try self.callParser(self.peekElem(argCount), argCount, true);
            },
            .ConditionalThen => {
                const offset = self.readShort();
                const lhs = self.popParsed();
                if (lhs.isFailure()) self.frame().ip += offset;
            },
            .ConditionalElse => {
                const offset = self.readShort();
                const lhs = self.popParsed();
                if (lhs.isSuccess()) {
                    self.frame().ip += offset;
                    try self.pushParsed(lhs);
                }
            },
            .Destructure => {
                const pattern = self.popElem();
                const parsed = self.popParsed();

                if (parsed.isSuccess() and parsed.asSuccess().value.isEql(pattern, self.strings)) {
                    try self.pushParsed(parsed);
                } else {
                    try self.pushParsed(ParseResult.failure);
                }
            },
            .End => {
                const prevFrame = self.frames.pop();

                if (self.frames.items.len == 0) return;

                try self.elems.resize(prevFrame.elemsOffset);
            },
            .False => {
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
                if (self.peekParsed(0).isFailure()) self.frame().ip += offset;
            },
            .JumpIfSuccess => {
                const offset = self.readShort();
                if (self.peekParsed(0).isSuccess()) self.frame().ip += offset;
            },
            .GetConstant => {
                const idx = self.readByte();
                try self.pushElem(self.chunk().getConstant(idx));
            },
            .SetInputMark => {
                try self.pushInputMark();
            },
            .MergeElems => {
                const rhs = self.popElem();
                const lhs = self.popElem();

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    try self.pushElem(value);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .MergeParsed => {
                const rhs = self.popParsed().asSuccess();
                const lhs = self.popParsed().asSuccess();

                if (try Elem.merge(lhs.value, rhs.value, self)) |value| {
                    const result = ParseResult.success(value);
                    try self.pushParsed(result);
                } else {
                    return self.runtimeError("Merge type mismatch", .{});
                }
            },
            .Null => try self.pushElem(Elem.nullConst),
            .Or => {
                const offset = self.readShort();
                switch (self.peekParsed(0)) {
                    .Success => {
                        self.frame().ip += offset;
                        _ = self.popInputMark();
                    },
                    .Failure => {
                        self.inputPos = self.popInputMark();
                        _ = self.popParsed();
                    },
                }
            },
            .Return => {
                const value = self.popElem();
                const parsed = self.popParsed();

                switch (parsed) {
                    .Success => {
                        const result = ParseResult.success(value);
                        try self.pushParsed(result);
                    },
                    .Failure => try self.pushParsed(parsed),
                }
            },
            .RunParser => {
                const parser = self.popElem();
                const result = try self.runParser(parser);
                try self.pushParsed(result);
            },
            .SubstituteValue => {
                const varName = switch (self.popElem()) {
                    .ValueVar => |name| name,
                    else => @panic("internal error"),
                };

                const value = self.globals.get(varName);

                if (value) |elem| {
                    try self.pushElem(elem);
                } else {
                    const varNameStr = self.strings.get(varName);
                    return self.runtimeError("Unknown variable `{s}`", .{varNameStr});
                }
            },
            .TakeLeft => {
                _ = self.popParsed().asSuccess();
            },
            .TakeRight => {
                const offset = self.readShort();
                const lhs = self.popParsed();
                if (lhs.isFailure()) self.frame().ip += offset;
            },
            .True => try self.pushElem(Elem.trueConst),
        }
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

    fn callParser(self: *VM, callee: Elem, argCount: u8, isTailPosition: bool) !void {
        if (callee.isDynType(.Function)) {
            var function = callee.asDyn().asFunction();

            if (function.arity == argCount) {
                if (isTailPosition) {
                    // Remove the elements belonging to the previous call
                    // frame. This includes the function itself, and each
                    // argument the function was called with.
                    try self.elems.replaceRange(
                        self.frame().elemsOffset,
                        self.frame().function.arity + 1,
                        &[_]Elem{},
                    );
                    _ = self.frames.pop();
                }
                try self.addFrame(function);
            } else {
                return self.runtimeError("Expected {} arguments but got {}.", .{ function.arity, argCount });
            }
        } else {
            if (argCount == 0) {
                const result = try self.runParser(callee);
                try self.pushParsed(result);
                _ = self.popElem();
            } else {
                return self.runtimeError("Can only call functions.", .{});
            }
        }
    }

    fn runParser(self: *VM, elem: Elem) !ParseResult {
        switch (elem) {
            .ParserVar => @panic("Internal error"),
            .ValueVar => @panic("Internal error"),
            .Character => @panic("Internal error"),
            .String => |sId| {
                const s = self.strings.get(sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return ParseResult.success(elem);
                }
            },
            .Integer => @panic("Internal error"),
            .Float => @panic("Internal error"),
            .IntegerString => |n| {
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return ParseResult.success(elem);
                }
            },
            .FloatString => |n| {
                const s = self.strings.get(n.sId);
                const start = self.inputPos;
                const end = start + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return ParseResult.success(elem);
                }
            },
            .IntegerRange => |r| {
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
                        return ParseResult.success(int);
                    } else {
                        end -= 1;
                    };
                }
            },
            .CharacterRange => |r| {
                const start = self.inputPos;
                const end = start + 1;

                if (start < self.input.len) {
                    const c = self.input[start];

                    if (r[0] <= c and c <= r[1]) {
                        self.inputPos = end;
                        const character = Elem.character(c);
                        return ParseResult.success(character);
                    }
                }
            },
            .True => @panic("Internal error"),
            .False => @panic("Internal error"),
            .Null => @panic("Internal error"),
            .Dyn => @panic("Internal error"),
        }

        return ParseResult.failure;
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

    fn pushParsed(self: *VM, result: ParseResult) !void {
        try self.parsed.append(result);
    }

    fn popElem(self: *VM) Elem {
        return self.elems.pop();
    }

    fn popParsed(self: *VM) ParseResult {
        return self.parsed.pop();
    }

    fn peekElem(self: *VM, distance: usize) Elem {
        var len = self.elems.items.len;
        return self.elems.items[len - 1 - distance];
    }

    fn peekParsed(self: *VM, distance: usize) ParseResult {
        var len = self.parsed.items.len;
        return self.parsed.items[len - 1 - distance];
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

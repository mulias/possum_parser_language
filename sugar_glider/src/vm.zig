const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const Elem = @import("./elem.zig").Elem;
const OpCode = @import("./chunk.zig").OpCode;
const ParseResult = @import("parse_result.zig").ParseResult;
const StringTable = @import("string_table.zig").StringTable;
const assert = std.debug.assert;
const compiler = @import("./compiler.zig");
const json = std.json;
const logger = @import("./logger.zig");

pub const VM = struct {
    allocator: Allocator,
    chunk: Chunk,
    ip: usize,
    stringTable: StringTable,
    dynList: ?*Elem.Dyn,
    elems: ArrayList(Elem),
    parsed: ArrayList(ParseResult),
    input: []const u8,
    inputPos: usize,

    pub fn init(allocator: Allocator) VM {
        return VM{
            .allocator = allocator,
            .chunk = Chunk.init(allocator),
            .ip = 0,
            .stringTable = StringTable.init(allocator),
            .dynList = null,
            .elems = ArrayList(Elem).init(allocator),
            .parsed = ArrayList(ParseResult).init(allocator),
            .input = undefined,
            .inputPos = 0,
        };
    }

    pub fn deinit(self: *VM) void {
        self.chunk.deinit();
        self.stringTable.deinit();
        self.freeDynList();
        self.elems.deinit();
        self.parsed.deinit();
    }

    pub fn interpret(self: *VM, program: []const u8, input: []const u8) !ParseResult {
        try compiler.compile(self, program);

        self.input = input;

        try self.run();

        assert(self.parsed.items.len == 1);

        return self.parsed.pop();
    }

    pub fn run(self: *VM) !void {
        while (true) {
            self.printDebug();

            const opCode = self.readOp();
            try self.runOp(opCode);
            if (opCode == .End) break;
        }
    }

    fn runOp(self: *VM, opCode: OpCode) !void {
        switch (opCode) {
            .Backtrack => {
                const success = self.popParsed().asSuccess();
                self.inputPos = success.start;
            },
            .Constant => {
                const idx = self.readByte();
                try self.pushElem(self.chunk.getConstant(idx));
            },
            .Destructure => {
                const pattern = self.popElem();
                const parsed = self.popParsed();

                if (parsed.isSuccess() and parsed.asSuccess().value.isEql(pattern)) {
                    try self.pushParsed(parsed);
                } else {
                    try self.pushParsed(ParseResult.failure);
                }
            },
            .End => {
                switch (self.parsed.items.len) {
                    1 => {
                        // Done
                    },
                    0 => {
                        return self.runtimeError("No program");
                    },
                    else => unreachable,
                }
            },
            .False => {
                try self.pushElem(Elem.falseConst);
            },
            .Jump => {
                const offset = self.readShort();
                self.ip += offset;
            },
            .JumpIfFailure => {
                const offset = self.readShort();
                if (self.peekParsed(0).isFailure()) self.ip += offset;
            },
            .JumpIfSuccess => {
                const offset = self.readShort();
                if (self.peekParsed(0).isSuccess()) self.ip += offset;
            },
            .MergeElems => {
                const rhs = self.popElem();
                const lhs = self.popElem();

                if (try Elem.merge(lhs, rhs, self)) |value| {
                    try self.pushElem(value);
                } else {
                    return self.runtimeError("Merge type mismatch");
                }
            },
            .MergeParsed => {
                const rhs = self.popParsed().asSuccess();
                const lhs = self.popParsed().asSuccess();

                if (try Elem.merge(lhs.value, rhs.value, self)) |value| {
                    const result = ParseResult.success(value, lhs.start, rhs.end);
                    try self.pushParsed(result);
                } else {
                    return self.runtimeError("Merge type mismatch");
                }
            },
            .Null => try self.pushElem(Elem.nullConst),
            .Or => {
                const rhs = self.popParsed();
                _ = self.popParsed();

                try self.pushParsed(rhs);
            },
            .Return => {
                const value = self.popElem();
                const parsed = self.popParsed();

                switch (parsed) {
                    .Success => |s| {
                        const result = ParseResult.success(value, s.start, s.end);
                        try self.pushParsed(result);
                    },
                    .Failure => try self.pushParsed(parsed),
                }
            },
            .True => try self.pushElem(Elem.trueConst),
            .RunFunctionParser => {
                const argCount = self.readByte();

                self.runFunctionParser(argCount);
            },
            .RunLiteralParser => {
                const elem = self.popElem();

                const result = try self.runLiteralParser(elem);
                try self.pushParsed(result);
            },
            .Sequence => {
                const rhs = self.popParsed().asSuccess();
                const lhs = self.popParsed().asSuccess();

                const result = ParseResult.success(rhs.value, lhs.start, rhs.end);
                try self.pushParsed(result);
            },
            .TakeLeft => {
                const rhs = self.popParsed().asSuccess();
                const lhs = self.popParsed().asSuccess();

                const result = ParseResult.success(lhs.value, lhs.start, rhs.end);
                try self.pushParsed(result);
            },
            .TakeRight => {
                const rhs = self.popParsed();
                const lhs = self.popParsed().asSuccess();

                if (rhs.isSuccess()) {
                    const rhss = rhs.asSuccess();
                    const result = ParseResult.success(rhss.value, lhs.start, rhss.end);
                    try self.pushParsed(result);
                } else {
                    self.inputPos = lhs.start;
                    try self.pushParsed(rhs);
                }
            },
        }
    }

    pub fn addString(self: *VM, bytes: []const u8) !StringTable.Id {
        return try self.stringTable.insert(bytes);
    }

    pub fn getString(self: *VM, sId: StringTable.Id) []const u8 {
        return self.stringTable.getAssumeExists(sId);
    }

    pub fn getStringId(self: *VM, string: []const u8) ?StringTable.Id {
        return self.stringTable.getOffset(string);
    }

    fn printDebug(self: *VM) void {
        if (logger.debugVM) {
            logger.debug("\n", .{});
            self.printInput();
            self.printParsed();
            self.printElems();
            _ = self.chunk.disassembleInstruction(self.stringTable, self.ip);
        }
    }

    fn runFunctionParser(self: *VM, argCount: u8) void {
        _ = argCount;
        _ = self;
        unreachable;
    }

    fn runLiteralParser(self: *VM, elem: Elem) !ParseResult {
        switch (elem) {
            .Character => unreachable,
            .String => |sId| {
                const s = self.getString(sId);
                const start = self.inputPos;
                const end = self.inputPos + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return ParseResult.success(elem, start, end);
                }
            },
            .Integer => |n| {
                if (n.text) |sId| {
                    const s = self.getString(sId);
                    const start = self.inputPos;
                    const end = self.inputPos + s.len;

                    if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                        self.inputPos = end;
                        return ParseResult.success(elem, start, end);
                    }
                } else {
                    unreachable;
                }
            },
            .Float => |n| {
                if (n.text) |sId| {
                    const s = self.getString(sId);
                    const start = self.inputPos;
                    const end = self.inputPos + s.len;

                    if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                        self.inputPos = end;
                        return ParseResult.success(elem, start, end);
                    }
                } else {
                    unreachable;
                }
            },
            .IntegerRange => |r| {
                const lowText = self.getString(r.lowText);
                const highText = self.getString(r.highText);
                const start = self.inputPos;
                const shortestMatchEnd = @min(start + lowText.len, self.input.len);
                const longestMatchEnd = @min(start + highText.len, self.input.len);

                var end = longestMatchEnd;

                // Find the longest substring from the start of the input which
                // parses as an integer, is greater than or equal to r.lowValue and
                // less than or equal to r.highValue.
                while (end >= shortestMatchEnd) {
                    const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

                    if (inputInt) |i| if (r.lowValue <= i and i <= r.highValue) {
                        self.inputPos = end;
                        const int = Elem.integer(i, null);
                        return ParseResult.success(int, start, end);
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

                    if (r.low <= c and c <= r.high) {
                        self.inputPos = end;
                        const character = Elem.character(c);
                        return ParseResult.success(character, start, end);
                    }
                }
            },
            .True => unreachable,
            .False => unreachable,
            .Null => unreachable,
            .Dyn => unreachable,
        }

        return ParseResult.failure;
    }

    fn readByte(self: *VM) u8 {
        const byte = self.chunk.read(self.ip);
        self.ip += 1;
        return byte;
    }

    fn readOp(self: *VM) OpCode {
        const op = self.chunk.readOp(self.ip);
        self.ip += 1;
        return op;
    }

    fn readShort(self: *VM) u16 {
        self.ip += 2;
        const items = self.chunk.code.items;
        return (@as(u16, @intCast(items[self.ip - 2])) << 8) | items[self.ip - 1];
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

    fn printInput(self: *VM) void {
        logger.debug("input   | ", .{});
        logger.debug("{s} @ {d}\n", .{ self.input, self.inputPos });
    }

    fn printElems(self: *VM) void {
        logger.debug("Elems   | ", .{});
        for (self.elems.items, 0..) |e, idx| {
            e.print(logger.debug, self.stringTable);
            if (idx < self.elems.items.len - 1) logger.debug(", ", .{});
        }
        logger.debug("\n", .{});
    }

    fn printParsed(self: *VM) void {
        logger.debug("Parsed  | ", .{});
        for (self.parsed.items, 0..) |p, idx| {
            p.print(logger.debug, self.stringTable);
            if (idx < self.parsed.items.len - 1) logger.debug(", ", .{});
        }
        logger.debug("\n", .{});
    }

    fn runtimeError(self: *VM, message: []const u8) !void {
        const line = self.chunk.lines.items[self.ip];
        logger.err("{s}", .{message});
        logger.err("\n[line {d}] in script\n", .{line});

        return error.RuntimeError;
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

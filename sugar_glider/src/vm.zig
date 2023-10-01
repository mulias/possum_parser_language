const std = @import("std");
const json = std.json;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const value = @import("./value.zig");
const Value = @import("./value.zig").Value;
const Success = @import("./value.zig").Success;
const printValue = @import("./value.zig").print;
const logger = @import("./logger.zig");
const compiler = @import("./compiler.zig");

pub const InterpretResultType = enum {
    ParserSuccess,
    ParserFailure,
    CompileError,
    RuntimeError,
};

pub const InterpretResult = union(InterpretResultType) {
    ParserSuccess: Success,
    ParserFailure: void,
    CompileError: []const u8,
    RuntimeError: []const u8,
};

pub const VM = struct {
    arena: ArenaAllocator,
    chunk: *Chunk,
    ip: usize,
    stack: ArrayList(Value),
    input: []const u8,
    inputPos: usize,

    pub fn init(allocator: Allocator) VM {
        return VM{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .chunk = undefined,
            .ip = undefined,
            .stack = ArrayList(Value).init(allocator),
            .input = undefined,
            .inputPos = undefined,
        };
    }

    pub fn deinit(self: *VM) void {
        self.arena.deinit();
        self.stack.deinit();
    }

    pub fn interpret(self: *VM, parser: []const u8, input: []const u8) !InterpretResult {
        var chunk = Chunk.init(self.arena.allocator());
        defer chunk.deinit();

        const success = try compiler.compile(parser, &chunk);
        if (!success) return .{ .CompileError = "compiler error" };

        self.chunk = &chunk;
        self.ip = 0;
        self.input = input;
        self.inputPos = 0;

        return try self.run();
    }

    pub fn run(self: *VM) !InterpretResult {
        self.printDebug();

        switch (self.readOp()) {
            .Constant => {
                const idx = self.readByte();
                const parser = self.chunk.getConstant(idx);
                if (try self.maybeMatch(parser)) |success| {
                    try self.push(.{ .Success = success });
                } else {
                    try self.pushFailure();
                }
            },
            .Pattern => {
                const idx = self.readByte();
                const c = self.chunk.getConstant(idx);

                if (c.toJson()) |pattern| {
                    try self.push(.{ .Pattern = pattern });
                } else {
                    return InterpretResult{ .RuntimeError = "Invalid pattern" };
                }
            },
            else => unreachable,
        }

        while (true) {
            self.printDebug();

            switch (self.readOp()) {
                .Constant => {
                    const idx = self.readByte();
                    try self.push(self.chunk.getConstant(idx));
                },
                .Pattern => {
                    const idx = self.readByte();
                    const c = self.chunk.getConstant(idx);

                    if (c.toJson()) |pattern| {
                        try self.push(.{ .Pattern = pattern });
                    } else {
                        return InterpretResult{ .RuntimeError = "Invalid pattern" };
                    }
                },
                .ReturnValue => {
                    const idx = self.readByte();
                    const c = self.chunk.getConstant(idx);

                    if (c.toJson()) |val| {
                        try self.push(.{ .ReturnValue = val });
                    } else {
                        return InterpretResult{ .RuntimeError = "Invalid return value" };
                    }
                },
                .Jump => {
                    const offset = self.readShort();
                    self.ip += offset;
                },
                .JumpIfFailure => {
                    const offset = self.readShort();
                    const top = self.pop();

                    switch (top) {
                        .Pattern, .ReturnValue => try self.push(top),
                        else => if (try self.maybeMatch(top)) |success| {
                            try self.push(.{ .Success = success });
                        } else {
                            try self.pushFailure();
                            self.ip += offset;
                        },
                    }
                },
                .Or => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        try self.push(.{ .Success = leftSuccess });
                    } else if (try self.maybeMatch(rhs)) |rightSuccess| {
                        try self.push(.{ .Success = rightSuccess });
                    } else {
                        try self.pushFailure();
                    }
                },
                .TakeRight => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        if (try self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = rightSuccess.end,
                                    .value = rightSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
                },
                .TakeLeft => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        if (try self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = rightSuccess.end,
                                    .value = leftSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
                },
                .Merge => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    const maybeError =
                        switch (lhs) {
                        .Success => |s| try self.matchAndMerge(s, rhs),
                        .Pattern => |p| try self.patternMerge(p, rhs),
                        .ReturnValue => |v| try self.returnValueMerge(v, rhs),
                        else => unreachable,
                    };

                    if (maybeError) |message| return InterpretResult{ .RuntimeError = message };
                },
                .Backtrack => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        self.inputPos = leftSuccess.start;
                        if (try self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{ .Success = rightSuccess });
                        } else {
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
                },
                .Destructure => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(rhs)) |rightSuccess| {
                        if (value.isDeepEql(rightSuccess.value, lhs.Pattern)) {
                            try self.push(.{ .Success = rightSuccess });
                        } else {
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
                },
                .Return => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        try self.push(.{
                            .Success = .{
                                .start = leftSuccess.start,
                                .end = leftSuccess.end,
                                .value = rhs.ReturnValue,
                            },
                        });
                    } else {
                        try self.pushFailure();
                    }
                },
                .Sequence => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        if (try self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = rightSuccess.end,
                                    .value = rightSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
                },
                .Conditional => {
                    const jumpOffset = self.readShort();
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |testSuccess| {
                        if (try self.maybeMatch(rhs)) |matchBranchSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = testSuccess.start,
                                    .end = matchBranchSuccess.end,
                                    .value = matchBranchSuccess.value,
                                },
                            });
                        } else {
                            // test succeeded but branch failed
                            self.inputPos = testSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        // Test parser failed, jump to else branch
                        self.ip += jumpOffset;
                    }
                },
                .End => {
                    const last = self.pop();
                    var result: InterpretResult = undefined;

                    if (try self.maybeMatch(last)) |success| {
                        try self.push(.{ .Success = success });
                        result = InterpretResult{ .ParserSuccess = success };
                    } else {
                        try self.push(.{ .Failure = undefined });
                        result = InterpretResult{ .ParserFailure = undefined };
                    }

                    if (logger.debugVM) {
                        logger.debug("\n", .{});
                        self.printInput();
                        self.printStack();
                        logger.debug("\n", .{});
                    }

                    return result;
                },
            }
        }
    }

    fn printDebug(self: *VM) void {
        if (logger.debugVM) {
            logger.debug("\n", .{});
            self.printInput();
            self.printStack();
            _ = self.chunk.disassembleInstruction(self.ip);
        }
    }

    fn maybeMatch(self: *VM, parser: Value) !?Success {
        switch (parser) {
            .String => |s| {
                const start = self.inputPos;
                const end = self.inputPos + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return Success{
                        .start = start,
                        .end = end,
                        .value = json.Value{ .string = s },
                    };
                } else {
                    return null;
                }
            },
            .CharacterRange => |r| {
                const start = self.inputPos;
                const end = start + 1;
                const c = self.input[start];

                if (r[0] <= c and c <= r[1]) {
                    self.inputPos = end;
                    return Success{
                        .start = start,
                        .end = end,
                        .value = json.Value{
                            .string = try std.fmt.allocPrint(self.arena.allocator(), "{c}", .{c}),
                        },
                    };
                } else {
                    return null;
                }
            },
            .Integer => |i| {
                const s = try std.fmt.allocPrint(self.arena.allocator(), "{d}", .{i});
                const start = self.inputPos;
                const end = self.inputPos + s.len;

                if (self.input.len >= end and std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos = end;
                    return Success{
                        .start = start,
                        .end = end,
                        .value = json.Value{ .integer = i },
                    };
                } else {
                    return null;
                }
            },
            .IntegerRange => |r| {
                const lowStr = try std.fmt.allocPrint(self.arena.allocator(), "{d}", .{r[0]});
                const highStr = try std.fmt.allocPrint(self.arena.allocator(), "{d}", .{r[1]});

                const start = self.inputPos;
                const shortestMatchEnd = @min(start + lowStr.len, self.input.len);
                const longestMatchEnd = @min(start + highStr.len, self.input.len);

                var end = longestMatchEnd;

                // Find the longest substring from the start of the input which
                // parses as an integer, is greater than or equal to r[0] and
                // less than or equal to r[1].
                while (end >= shortestMatchEnd) {
                    const inputInt = std.fmt.parseInt(i64, self.input[start..end], 10) catch null;

                    if (inputInt) |i| if (r[0] <= i and i <= r[1]) {
                        self.inputPos = end;
                        return Success{
                            .start = start,
                            .end = end,
                            .value = json.Value{ .integer = i },
                        };
                    } else {
                        end -= 1;
                    };
                }
                return null;
            },
            .Float => |n| {
                const start = self.inputPos;
                const end = self.inputPos + n.len;

                if (self.input.len >= end and std.mem.eql(u8, n, self.input[start..end])) {
                    self.inputPos = end;
                    return Success{
                        .start = start,
                        .end = end,
                        .value = json.Value{ .number_string = n },
                    };
                } else {
                    return null;
                }
            },
            .Success => |s| return s,
            .Failure => return null,
            // JSON-only values should only show up in destructure patterns and
            // return values, so they should not be used as a parser
            .Pattern, .ReturnValue, .Array, .Object, .True, .False, .Null => unreachable,
        }
    }

    fn matchAndMerge(self: *VM, leftSuccess: Success, rhs: Value) !?[]const u8 {
        if (try self.maybeMatch(rhs)) |rightSuccess| {
            const merged = (value.mergeJson(self.arena.allocator(), leftSuccess.value, rightSuccess.value)) catch return "Unable to merge mismatched types";

            try self.push(.{
                .Success = .{
                    .start = leftSuccess.start,
                    .end = rightSuccess.end,
                    .value = merged,
                },
            });
        } else {
            try self.pushFailure();
        }

        return null;
    }

    fn patternMerge(self: *VM, leftPattern: json.Value, rhs: Value) !?[]const u8 {
        if (rhs.toJson()) |rightValue| {
            const merged = value.mergeJson(self.arena.allocator(), leftPattern, rightValue) catch return "Unable to merge mismatched types";
            try self.push(.{ .Pattern = merged });
        } else {
            return "Not a valid pattern";
        }

        return null;
    }

    fn returnValueMerge(self: *VM, leftReturnValue: json.Value, rhs: Value) !?[]const u8 {
        if (rhs.toJson()) |rightValue| {
            const merged = value.mergeJson(self.arena.allocator(), leftReturnValue, rightValue) catch return "Unable to merge mismatched types";
            try self.push(.{ .ReturnValue = merged });
        } else {
            return "Not a valid return value";
        }

        return null;
    }

    fn mergeStrings(self: *VM, left: []const u8, right: []const u8) ![]const u8 {
        return try std.fmt.allocPrint(self.arena.allocator(), "{s}{s}", .{ left, right });
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

    fn push(self: *VM, parserOrValue: Value) !void {
        try self.stack.append(parserOrValue);
    }

    fn pushFailure(self: *VM) !void {
        try self.stack.append(.{ .Failure = undefined });
    }

    fn pop(self: *VM) Value {
        return self.stack.pop();
    }

    fn peek(self: *VM, distance: usize) Value {
        var len = self.stack.items.len;
        return self.stack.items[len - 1 - distance];
    }

    fn resetStack(self: *VM) void {
        self.stack.shrinkAndFree(0);
    }

    fn printInput(self: *VM) void {
        logger.debug("input   | ", .{});
        logger.debug("{s} @ {d}\n", .{ self.input, self.inputPos });
    }

    fn printStack(self: *VM) void {
        logger.debug("stack   | ", .{});
        for (self.stack.items, 0..) |v, idx| {
            v.print();
            if (idx < self.stack.items.len - 1) logger.debug(" # ", .{});
        }
        logger.debug("\n", .{});
    }

    fn runtimeError(self: *VM, message: []const u8) InterpretResult {
        const line = self.chunk.lines.items[self.ip];
        logger.warn("{s}", .{message});
        logger.warn("\n[line {d}] in script\n", .{line});
        self.resetStack();
        return InterpretResult.RuntimeError;
    }
};

test "'a' > 'b' > 'c' | 'abz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'a' > 'b' > 'c' | 'abz'
    ;

    const result1 = try vm.interpret(parser, "abc");
    try std.testing.expect(result1.ParserSuccess.start == 0);
    try std.testing.expect(result1.ParserSuccess.end == 3);
    try expectJson(alloc, result1.ParserSuccess, "\"c\"");

    vm.resetStack();
    const result2 = try vm.interpret(parser, "abzsss");
    try std.testing.expect(result2.ParserSuccess.start == 0);
    try std.testing.expect(result2.ParserSuccess.end == 3);
    try expectJson(alloc, result2.ParserSuccess, "\"abz\"");

    vm.resetStack();
    const result3 = try vm.interpret(parser, "ababz");
    try expectFailure(result3);
}

test "1234 | 5678 | 910" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1234 | 5678 | 910
    ;

    const result = try vm.interpret(parser, "56789");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try expectJson(alloc, result.ParserSuccess, "5678");
}

test "'foo' + 'bar' + 'baz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'foo' + 'bar' + 'baz'
    ;

    const result = try vm.interpret(parser, "foobarbaz");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 9);
    try expectJson(alloc, result.ParserSuccess, "\"foobarbaz\"");
}

test "1 + 2 + 3" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1 + 2 + 3
    ;

    const result = try vm.interpret(parser, "123");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "6");
}

test "1.23 + 10" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1.23 + 10
    ;

    const result = try vm.interpret(parser, "1.2310");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 6);
    try expectJson(alloc, result.ParserSuccess, "1.123e+01");
}

test "0.1 + 0.2" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 0.1 + 0.2
    ;

    const result = try vm.interpret(parser, "0.10.2");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 6);
    try expectJson(alloc, result.ParserSuccess, "3.0000000000000004e-01");
}

test "1e57 + 3e-4" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1e57 + 3e-4
    ;

    const result = try vm.interpret(parser, "1e573e-4");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 8);
    try expectJson(alloc, result.ParserSuccess, "1.0e+57");
}

test "'foo' $ 'bar'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'foo' $ 'bar'
    ;

    const result1 = try vm.interpret(parser, "foo");
    try std.testing.expect(result1.ParserSuccess.start == 0);
    try std.testing.expect(result1.ParserSuccess.end == 3);
    try expectJson(alloc, result1.ParserSuccess, "\"bar\"");

    vm.resetStack();
    const result2 = try vm.interpret(parser, "f");
    try expectFailure(result2);
}

test "1 ! 12 ! 123" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1 ! 12 ! 123
    ;

    const result = try vm.interpret(parser, "123");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "123");
}

// test "'true' ? 'foo' + 'bar' : 'baz', first branch" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ 'true' ? 'foo' + 'bar' : 'baz'
//     ;

//     const result = try vm.interpret(parser, "truefoobar");

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 10);
//     try expectJson(alloc, result.ParserSuccess, "\"foobar\"");
// }

// test "'true' ? 'foo' + 'bar' : 'baz', second branch" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ 'true' ? 'foo' + 'bar' : 'baz'
//     ;

//     const result = try vm.interpret(parser, "baz");

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 3);
//     try expectJson(alloc, result.ParserSuccess, "\"baz\"");
// }

test "1000..10000 | 100..1000" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1000..10000 | 100..1000
    ;

    const result = try vm.interpret(parser, "888");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "888");
}

test "-100..-1" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ -100..-1
    ;

    const result = try vm.interpret(parser, "-5");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 2);
    try expectJson(alloc, result.ParserSuccess, "-5");
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;

    const result = try vm.interpret(parser, "foo");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "\"foo\"");
}

test "'true' $ true" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'true' $ true
    ;

    const result = try vm.interpret(parser, "true");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try expectJson(alloc, result.ParserSuccess, "true");
}

test "('' $ null) + ('' $ null)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ ('' $ null) + ('' $ null)
    ;

    const result = try vm.interpret(parser, "");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 0);
    try expectJson(alloc, result.ParserSuccess, "null");
}

// test "('a' $ [1, 2]) + ('b' $ [true, false])" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ ('a' $ [1, 2]) + ('b' $ [true, false])
//     ;

//     const result = try vm.interpret(parser, "abc");

//     var valueString = ArrayList(u8).init(alloc);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 2);
//     try expectJson(alloc, result.ParserSuccess, "[1,2,true,false]");
// }

// test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
//     ;

//     const result = try vm.interpret(parser, "123456");

//     var valueString = ArrayList(u8).init(alloc);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 6);
//     try expectJson(alloc, result.ParserSuccess, "{\"a\":false,\"b\":null}");
// }

test "'f' <- 'a'..'z' & 12 <- 0..100" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'f' <- 'a'..'z' & 12 <- 0..100
    ;

    const result = try vm.interpret(parser, "f12");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "12");
}

test "42 <- 42.0" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 42 <- 42.0
    ;

    const result = try vm.interpret(parser, "42.0");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try expectJson(alloc, result.ParserSuccess, "42.0");
}

test "false <- ('' $ true)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\  false <- ('' $ true)
    ;

    const result = try vm.interpret(parser, "42.0");

    try expectFailure(result);
}

test "('a' + 'b') <- 'ab'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ ('a' + 'b') <- 'ab'
    ;

    const result = try vm.interpret(parser, "ab");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 2);
    try expectJson(alloc, result.ParserSuccess, "\"ab\"");
}

test "123 & 456 | 789 $ true & 'xyz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 123 & 456 | 789 $ true & 'xyz'
    ;

    const result1 = try vm.interpret(parser, "123789xyz");
    try std.testing.expect(result1.ParserSuccess.start == 0);
    try std.testing.expect(result1.ParserSuccess.end == 9);
    try expectJson(alloc, result1.ParserSuccess, "\"xyz\"");

    vm.resetStack();
    const result2 = try vm.interpret(parser, "12378xyz");
    try expectFailure(result2);
}

fn expectJson(alloc: Allocator, actual: value.Success, expected: []const u8) !void {
    var valueString = ArrayList(u8).init(alloc);
    defer valueString.deinit();
    try std.testing.expectEqualStrings(expected, try actual.writeValueString(&valueString));
}

fn expectFailure(result: InterpretResult) !void {
    try std.testing.expectEqualStrings(@tagName(result), "ParserFailure");
}

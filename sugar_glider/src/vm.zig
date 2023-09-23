const std = @import("std");
const json = std.json;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Value = @import("./value.zig").Value;
const Success = @import("./value.zig").Success;
const printValue = @import("./value.zig").print;
const logger = @import("./logger.zig");

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

    pub fn interpret(self: *VM, chunk: *Chunk, input: []const u8) !InterpretResult {
        self.chunk = chunk;
        self.ip = 0;
        self.input = input;
        self.inputPos = 0;

        return try self.run();
    }

    pub fn run(self: *VM) !InterpretResult {
        while (true) {
            if (logger.debugVMStack) {
                logger.debug("\n", .{});
                self.printInput();
                self.printStack();
                _ = self.chunk.disassembleInstruction(self.ip);
            }

            const instruction = @as(OpCode, @enumFromInt(self.readByte()));
            switch (instruction) {
                .Constant => {
                    const constantIdx = self.readByte();
                    const value = self.chunk.constants.items[constantIdx];
                    try self.push(value);
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

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        if (try self.maybeMatch(rhs)) |rightSuccess| {
                            if (leftSuccess.isString() and rightSuccess.isString()) {
                                const leftString = leftSuccess.asString();
                                const rightString = rightSuccess.asString();
                                const mergedString = try self.mergeStrings(leftString.?, rightString.?);

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .string = mergedString },
                                    },
                                });
                            } else if (leftSuccess.isInteger() and rightSuccess.isInteger()) {
                                const leftInteger = leftSuccess.asInteger();
                                const rightInteger = rightSuccess.asInteger();
                                const mergedInteger = leftInteger.? + rightInteger.?;

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .integer = mergedInteger },
                                    },
                                });
                            } else if (leftSuccess.isNumber() and rightSuccess.isNumber()) {
                                const leftNumber = try leftSuccess.asFloat();
                                const rightNumber = try rightSuccess.asFloat();
                                const mergedNumber = leftNumber.? + rightNumber.?;

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .float = mergedNumber },
                                    },
                                });
                            } else if (leftSuccess.isTrue() and rightSuccess.isTrue()) {
                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .bool = true },
                                    },
                                });
                            } else if (leftSuccess.isFalse() and rightSuccess.isFalse()) {
                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .bool = false },
                                    },
                                });
                            } else if (leftSuccess.isNull() and rightSuccess.isNull()) {
                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .null = undefined },
                                    },
                                });
                            } else {
                                return InterpretResult{ .RuntimeError = "Unable to merge mismatching types" };
                            }
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        try self.pushFailure();
                    }
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
                .Return => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(lhs)) |leftSuccess| {
                        if (rhs.toJson()) |value| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = leftSuccess.end,
                                    .value = value,
                                },
                            });
                        } else {
                            // rhs should never be a success/failure value,
                            // since operator precedence means the return value
                            // is always resolved with the return
                            unreachable;
                        }
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
                    const whenNoMatch = self.pop();
                    const whenMatch = self.pop();
                    const testParser = self.pop();

                    if (try self.maybeMatch(testParser)) |testSuccess| {
                        if (try self.maybeMatch(whenMatch)) |whenMatchSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = testSuccess.start,
                                    .end = whenMatchSuccess.end,
                                    .value = whenMatchSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = testSuccess.start;
                            try self.pushFailure();
                        }
                    } else {
                        if (try self.maybeMatch(whenNoMatch)) |whenNoMatchSuccess| {
                            try self.push(.{ .Success = whenNoMatchSuccess });
                        } else {
                            try self.pushFailure();
                        }
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

                    if (logger.debugVMStack) {
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

    fn maybeMatch(self: *VM, value: Value) !?Success {
        switch (value) {
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
                        .value = json.Value{ .string = self.input[start..end] },
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
            .True, .False, .Null => unreachable,
        }
    }

    fn mergeStrings(self: *VM, left: []const u8, right: []const u8) ![]const u8 {
        var dynamic_string = std.ArrayList(u8).init(self.arena.allocator());
        defer dynamic_string.deinit();

        var writer = dynamic_string.writer();
        try writer.writeAll(left);
        try writer.writeAll(right);
        return try dynamic_string.toOwnedSlice();
    }

    fn readByte(self: *VM) u8 {
        const byte = self.chunk.code.items[self.ip];
        self.ip += 1;
        return byte;
    }

    fn push(self: *VM, value: Value) !void {
        try self.stack.append(value);
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
        for (self.stack.items) |value| {
            logger.debug("[", .{});
            value.print();
            logger.debug("]", .{});
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

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "a" }, 1);
    try chunk.writeConst(.{ .String = "b" }, 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeConst(.{ .String = "c" }, 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeConst(.{ .String = "abz" }, 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "abzsss");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expectEqualStrings(result.ParserSuccess.value.string, "abz");
}

test "1234 | 5678 | 910" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Integer = 1234 }, 1);
    try chunk.writeConst(.{ .Integer = 5678 }, 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeConst(.{ .Integer = 910 }, 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "56789");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try std.testing.expect(result.ParserSuccess.value.integer == 5678);
}

test "'foo' + 'bar' + 'baz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "foo" }, 1);
    try chunk.writeConst(.{ .String = "bar" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeConst(.{ .String = "baz" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "foobarbaz");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 9);
    try std.testing.expectEqualStrings(result.ParserSuccess.value.string, "foobarbaz");
}

test "1 + 2 + 3" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Integer = 1 }, 1);
    try chunk.writeConst(.{ .Integer = 2 }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeConst(.{ .Integer = 3 }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "123");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expect(result.ParserSuccess.value.integer == 6);
}

test "1.23 + 10" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Float = "1.23" }, 1);
    try chunk.writeConst(.{ .Integer = 10 }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "1.2310");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 6);
    try std.testing.expect(result.ParserSuccess.value.float == 11.23);
}

test "0.1 + 0.2" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Float = "0.1" }, 1);
    try chunk.writeConst(.{ .Float = "0.2" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "0.10.2");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 6);
    try std.testing.expectApproxEqAbs(result.ParserSuccess.value.float, 0.3, 0.0000000000000001);
}

test "1e57 + 3e-4" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Float = "1e57" }, 1);
    try chunk.writeConst(.{ .Float = "3e-4" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "1e573e-4");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 8);
    try std.testing.expect(result.ParserSuccess.value.float == 1e57);
}

test "'foo' $ 'bar'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "foo" }, 1);
    try chunk.writeConst(.{ .String = "bar" }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "foo");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expectEqualStrings(result.ParserSuccess.value.string, "bar");
}

test "1 ! 12 ! 123" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Integer = 1 }, 1);
    try chunk.writeConst(.{ .Integer = 12 }, 1);
    try chunk.writeOp(.Backtrack, 1);
    try chunk.writeConst(.{ .Integer = 123 }, 1);
    try chunk.writeOp(.Backtrack, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "123");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expect(result.ParserSuccess.value.integer == 123);
}

test "'true' ? 123 : 456, first branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "true" }, 1);
    try chunk.writeConst(.{ .Integer = 123 }, 1);
    try chunk.writeConst(.{ .Integer = 456 }, 1);
    try chunk.writeOp(.Conditional, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "true123");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 7);
    try std.testing.expect(result.ParserSuccess.value.integer == 123);
}

test "'true' ? 123 : 456, second branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "true" }, 1);
    try chunk.writeConst(.{ .Integer = 123 }, 1);
    try chunk.writeConst(.{ .Integer = 456 }, 1);
    try chunk.writeOp(.Conditional, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "456");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expect(result.ParserSuccess.value.integer == 456);
}

test "1000..10000 | 100..1000" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .IntegerRange = .{ 1000, 10000 } }, 1);
    try chunk.writeConst(.{ .IntegerRange = .{ 100, 1000 } }, 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "888");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expect(result.ParserSuccess.value.integer == 888);
}

test "-100..-1" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .IntegerRange = .{ -100, -1 } }, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "-5");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 2);
    try std.testing.expect(result.ParserSuccess.value.integer == -5);
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .CharacterRange = .{ 'a', 'z' } }, 1);
    try chunk.writeConst(.{ .CharacterRange = .{ 'o', 'o' } }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeConst(.{ .CharacterRange = .{ 'l', 'q' } }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "foo");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try std.testing.expectEqualStrings(result.ParserSuccess.value.string, "foo");
}

test "'true' $ true" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "true" }, 1);
    try chunk.writeConst(.{ .True = undefined }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "true");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try std.testing.expect(result.ParserSuccess.value.bool);
}

test "('' $ null) + ('' $ null)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "" }, 1);
    try chunk.writeConst(.{ .Null = undefined }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeConst(.{ .String = "" }, 1);
    try chunk.writeConst(.{ .Null = undefined }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 0);
    try std.testing.expectEqualStrings(@tagName(result.ParserSuccess.value), "null");
}

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

        self.ip = 0;
        self.input = input;
        self.inputPos = 0;

        return try self.run();
    }

    pub fn run(self: *VM) !InterpretResult {
        while (true) {
            if (logger.debugVM) {
                logger.debug("\n", .{});
                self.printInput();
                self.printStack();
                _ = self.chunk.disassembleInstruction(self.ip);
            }

            const instruction = self.readOp();
            switch (instruction) {
                .Constant => {
                    const idx = self.readByte();
                    try self.push(self.chunk.getConstant(idx));
                },
                .Jump => {
                    self.ip += self.readByte();
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
                                const leftString = leftSuccess.asString().?;
                                const rightString = rightSuccess.asString().?;
                                const mergedString = try self.mergeStrings(leftString, rightString);

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .string = mergedString },
                                    },
                                });
                            } else if (leftSuccess.isInteger() and rightSuccess.isInteger()) {
                                const leftInteger = leftSuccess.asInteger().?;
                                const rightInteger = rightSuccess.asInteger().?;
                                const mergedInteger = leftInteger + rightInteger;

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .integer = mergedInteger },
                                    },
                                });
                            } else if (leftSuccess.isNumber() and rightSuccess.isNumber()) {
                                const leftNumber = (try leftSuccess.asFloat()).?;
                                const rightNumber = (try rightSuccess.asFloat()).?;
                                const mergedNumber = leftNumber + rightNumber;

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .float = mergedNumber },
                                    },
                                });
                            } else if (leftSuccess.isArray() and rightSuccess.isArray()) {
                                var leftArray = leftSuccess.asArray().?;
                                var rightArray = rightSuccess.asArray().?;
                                try leftArray.appendSlice(rightArray.items);

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .array = leftArray },
                                    },
                                });
                            } else if (leftSuccess.isObject() and rightSuccess.isObject()) {
                                var leftObject = leftSuccess.asObject().?;
                                var rightObject = rightSuccess.asObject().?;

                                var iterator = rightObject.iterator();
                                while (iterator.next()) |entry| {
                                    try leftObject.put(entry.key_ptr.*, entry.value_ptr.*);
                                }

                                try self.push(.{
                                    .Success = .{
                                        .start = leftSuccess.start,
                                        .end = rightSuccess.end,
                                        .value = .{ .object = leftObject },
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
                .Destructure => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (try self.maybeMatch(rhs)) |rightSuccess| {
                        if (lhs.toJson()) |pattern| {
                            if (value.isDeepEql(rightSuccess.value, pattern)) {
                                try self.push(.{ .Success = rightSuccess });
                            } else {
                                try self.pushFailure();
                            }
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
                        if (rhs.toJson()) |rightValue| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = leftSuccess.end,
                                    .value = rightValue,
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
                    const jumpOffset = self.readByte();
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
            .Array, .Object, .True, .False, .Null => unreachable,
        }
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
    try expectJson(alloc, result.ParserSuccess, "\"abz\"");
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
    try expectJson(alloc, result.ParserSuccess, "5678");
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
    try expectJson(alloc, result.ParserSuccess, "\"foobarbaz\"");
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
    try expectJson(alloc, result.ParserSuccess, "6");
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
    try expectJson(alloc, result.ParserSuccess, "1.123e+01");
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
    try expectJson(alloc, result.ParserSuccess, "3.0000000000000004e-01");
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
    try expectJson(alloc, result.ParserSuccess, "1.0e+57");
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
    try expectJson(alloc, result.ParserSuccess, "\"bar\"");
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
    try expectJson(alloc, result.ParserSuccess, "123");
}

test "'true' ? 'foo' + 'bar' : 'baz', first branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "true" }, 1);
    try chunk.writeConst(.{ .String = "foo" }, 1);
    try chunk.writeJump(.Conditional, 5, 1);
    try chunk.writeConst(.{ .String = "bar" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeJump(.Jump, 3, 1);
    try chunk.writeConst(.{ .String = "baz" }, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "truefoobar");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 10);
    try expectJson(alloc, result.ParserSuccess, "\"foobar\"");
}

test "'true' ? 'foo' + 'bar' : 'baz', second branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "true" }, 1);
    try chunk.writeConst(.{ .String = "foo" }, 1);
    try chunk.writeJump(.Conditional, 5, 1);
    try chunk.writeConst(.{ .String = "bar" }, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeJump(.Jump, 3, 1);
    try chunk.writeConst(.{ .String = "baz" }, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "baz");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "\"baz\"");
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
    try expectJson(alloc, result.ParserSuccess, "888");
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
    try expectJson(alloc, result.ParserSuccess, "-5");
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
    try expectJson(alloc, result.ParserSuccess, "\"foo\"");
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
    try expectJson(alloc, result.ParserSuccess, "true");
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
    try expectJson(alloc, result.ParserSuccess, "null");
}

test "('a' $ [1, 2]) + ('b' $ [true, false])" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    var a1 = ArrayList(json.Value).init(alloc);
    defer a1.deinit();
    try a1.append(.{ .integer = 1 });
    try a1.append(.{ .integer = 2 });

    var a2 = ArrayList(json.Value).init(alloc);
    defer a2.deinit();
    try a2.append(.{ .bool = true });
    try a2.append(.{ .bool = false });

    try chunk.writeConst(.{ .String = "a" }, 1);
    try chunk.writeConst(.{ .Array = a1 }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeConst(.{ .String = "b" }, 1);
    try chunk.writeConst(.{ .Array = a2 }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "abc");

    var valueString = ArrayList(u8).init(alloc);
    defer valueString.deinit();

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 2);
    try expectJson(alloc, result.ParserSuccess, "[1,2,true,false]");
}

test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    var o1 = std.StringArrayHashMap(json.Value).init(alloc);
    defer o1.deinit();
    try o1.put("a", .{ .bool = true });

    var o2 = std.StringArrayHashMap(json.Value).init(alloc);
    defer o2.deinit();
    try o2.put("a", .{ .bool = false });
    try o2.put("b", .{ .null = undefined });

    try chunk.writeConst(.{ .Integer = 123 }, 1);
    try chunk.writeConst(.{ .Object = o1 }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeConst(.{ .Integer = 456 }, 1);
    try chunk.writeConst(.{ .Object = o2 }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.Merge, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "123456");

    var valueString = ArrayList(u8).init(alloc);
    defer valueString.deinit();

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 6);
    try expectJson(alloc, result.ParserSuccess, "{\"a\":false,\"b\":null}");
}

test "'f' <- 'a'..'z' & 12 <- 0..100" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "f" }, 1);
    try chunk.writeConst(.{ .CharacterRange = .{ 'a', 'z' } }, 1);
    try chunk.writeOp(.Destructure, 1);
    try chunk.writeConst(.{ .Integer = 12 }, 1);
    try chunk.writeConst(.{ .IntegerRange = .{ 0, 100 } }, 1);
    try chunk.writeOp(.Destructure, 1);
    try chunk.writeOp(.Sequence, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "f12");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 3);
    try expectJson(alloc, result.ParserSuccess, "12");
}

test "42 <- 42.0" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .Integer = 42 }, 1);
    try chunk.writeConst(.{ .Float = "42.0" }, 1);
    try chunk.writeOp(.Destructure, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "42.0");

    try std.testing.expect(result.ParserSuccess.start == 0);
    try std.testing.expect(result.ParserSuccess.end == 4);
    try expectJson(alloc, result.ParserSuccess, "42.0");
}

test "false <- ('' $ true)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .False = undefined }, 1);
    try chunk.writeConst(.{ .String = "" }, 1);
    try chunk.writeConst(.{ .True = undefined }, 1);
    try chunk.writeOp(.Return, 1);
    try chunk.writeOp(.Destructure, 1);
    try chunk.writeOp(.End, 2);

    const result = try vm.interpret(&chunk, "42.0");

    try expectFailure(result);
}

fn expectJson(alloc: Allocator, actual: value.Success, expected: []const u8) !void {
    var valueString = ArrayList(u8).init(alloc);
    defer valueString.deinit();
    try std.testing.expectEqualStrings(try actual.writeValueString(&valueString), expected);
}

fn expectFailure(result: InterpretResult) !void {
    try std.testing.expectEqualStrings(@tagName(result), "ParserFailure");
}

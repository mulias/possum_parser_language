const std = @import("std");
const json = std.json;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Value = @import("./value.zig").Value;
const Success = @import("./value.zig").Success;
const printValue = @import("./value.zig").print;
const logger = @import("./logger.zig");

pub const InterpretResult = enum {
    Ok,
    CompileError,
    RuntimeError,
};

pub const VM = struct {
    allocator: Allocator,
    chunk: *Chunk,
    ip: usize,
    stack: ArrayList(Value),
    input: []const u8,
    inputPos: usize,

    pub fn init(allocator: Allocator) VM {
        return VM{
            .allocator = allocator,
            .chunk = undefined,
            .ip = undefined,
            .stack = ArrayList(Value).init(allocator),
            .input = undefined,
            .inputPos = undefined,
        };
    }

    pub fn deinit(self: *VM) void {
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
                .String, .Number => {
                    const constantIdx = self.readByte();
                    const value = self.chunk.constants.items[constantIdx];
                    try self.push(value);
                },
                .Or => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (self.maybeMatch(lhs)) |leftSuccess| {
                        try self.push(.{ .Success = leftSuccess });
                    } else if (self.maybeMatch(rhs)) |rightSuccess| {
                        try self.push(.{ .Success = rightSuccess });
                    } else {
                        try self.push(.{ .Failure = undefined });
                    }
                },
                .TakeRight => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (self.maybeMatch(lhs)) |leftSuccess| {
                        if (self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = rightSuccess.end,
                                    .value = rightSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.push(.{ .Failure = undefined });
                        }
                    } else {
                        try self.push(.{ .Failure = undefined });
                    }
                },
                .TakeLeft => {
                    const rhs = self.pop();
                    const lhs = self.pop();

                    if (self.maybeMatch(lhs)) |leftSuccess| {
                        if (self.maybeMatch(rhs)) |rightSuccess| {
                            try self.push(.{
                                .Success = .{
                                    .start = leftSuccess.start,
                                    .end = rightSuccess.end,
                                    .value = leftSuccess.value,
                                },
                            });
                        } else {
                            self.inputPos = leftSuccess.start;
                            try self.push(.{ .Failure = undefined });
                        }
                    } else {
                        try self.push(.{ .Failure = undefined });
                    }
                },
                .Return => {
                    const last = self.pop();

                    if (self.maybeMatch(last)) |success| {
                        const value = Value{ .Success = success };
                        value.print();
                        logger.debug("\n\n", .{});
                    } else {
                        logger.debug("Failure\n\n", .{});
                    }

                    return InterpretResult.Ok;
                },
            }
        }
    }

    fn maybeMatch(self: *VM, value: Value) ?Success {
        switch (value) {
            .String => |s| {
                const start = self.inputPos;
                const end = self.inputPos + s.len;

                if (std.mem.eql(u8, s, self.input[start..end])) {
                    self.inputPos += s.len;
                    return Success{
                        .start = start,
                        .end = end,
                        .value = json.Value{ .string = s },
                    };
                } else {
                    return null;
                }
            },
            .Number => |n| {
                const start = self.inputPos;
                const end = self.inputPos + n.len;

                if (std.mem.eql(u8, n, self.input[start..end])) {
                    self.inputPos += n.len;
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
        }
    }

    fn readByte(self: *VM) u8 {
        const byte = self.chunk.code.items[self.ip];
        self.ip += 1;
        return byte;
    }

    fn push(self: *VM, value: Value) !void {
        try self.stack.append(value);
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

test "vm" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    var strA = try chunk.addConstant(.{ .String = "a" });
    var strB = try chunk.addConstant(.{ .String = "b" });
    var strC = try chunk.addConstant(.{ .String = "c" });
    var strABZ = try chunk.addConstant(.{ .String = "abz" });

    try chunk.writeOp(.String, 1);
    try chunk.write(strA, 1);
    try chunk.writeOp(.String, 1);
    try chunk.write(strB, 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeOp(.String, 1);
    try chunk.write(strC, 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeOp(.String, 1);
    try chunk.write(strABZ, 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeOp(.Return, 2);

    try std.testing.expect(try vm.interpret(&chunk, "abzsss") == .Ok);
}

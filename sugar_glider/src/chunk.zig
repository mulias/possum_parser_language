const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Value = @import("./value.zig").Value;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Constant,
    Jump,
    Or,
    TakeRight,
    TakeLeft,
    Merge,
    Backtrack,
    Destructure,
    Return,
    Sequence,
    Conditional,
    End,

    pub fn disassemble(self: OpCode, chunk: *Chunk, offset: usize) usize {
        switch (self) {
            .Constant => {
                var constantIdx = chunk.read(offset + 1);
                var constantValue = chunk.getConstant(constantIdx);
                logger.debug("{s} {}: ", .{ @tagName(self), constantIdx });
                constantValue.print();
                logger.debug("\n", .{});
                return offset + 2;
            },
            .Jump, .Conditional => {
                var jumpOffset = chunk.read(offset + 1);
                logger.debug("{s} {}", .{ @tagName(self), jumpOffset });
                logger.debug("\n", .{});
                return offset + 2;
            },
            .Or, .TakeRight, .TakeLeft, .Merge, .Backtrack, .Destructure, .Return, .Sequence, .End => {
                logger.debug("{s}\n", .{@tagName(self)});
                return offset + 1;
            },
        }
    }
};

pub const Chunk = struct {
    allocator: Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Value),
    lines: ArrayList(usize),

    pub fn init(allocator: Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Value).init(allocator),
            .lines = ArrayList(usize).init(allocator),
        };
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
        self.constants.deinit();
        self.lines.deinit();
    }

    pub fn read(self: *Chunk, pos: usize) u8 {
        return self.code.items[pos];
    }

    pub fn readOp(self: *Chunk, pos: usize) OpCode {
        return @as(OpCode, @enumFromInt(self.code.items[pos]));
    }

    pub fn getConstant(self: *Chunk, idx: u8) Value {
        return self.constants.items[idx];
    }

    pub fn write(self: *Chunk, byte: u8, line: usize) !void {
        try self.code.append(byte);
        try self.lines.append(line);
    }

    pub fn writeOp(self: *Chunk, op: OpCode, line: usize) !void {
        try self.write(@intFromEnum(op), line);
    }

    pub fn writeConst(self: *Chunk, v: Value, line: usize) !void {
        var idx = try self.addConstant(v);
        try self.writeOp(.Constant, line);
        try self.write(idx, line);
    }

    // TODO: use u16 jump and split into 2 u8
    pub fn writeJump(self: *Chunk, op: OpCode, jumpOffset: u8, line: usize) !void {
        try self.writeOp(op, line);
        try self.write(jumpOffset, line);
    }

    pub fn addConstant(self: *Chunk, value: Value) !u8 {
        const idx = @as(u8, @intCast(self.constants.items.len));
        try self.constants.append(value);
        return idx;
    }

    pub fn disassemble(self: *Chunk, name: []const u8) void {
        logger.debug("\n==== {s} ====\n", .{name});

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(offset);
        }
    }

    pub fn disassembleInstruction(self: *Chunk, offset: usize) usize {
        // print address
        logger.debug("{:0>4} ", .{offset});

        // print line
        if (offset > 0 and self.lines.items[offset] == self.lines.items[offset - 1]) {
            logger.debug("   | ", .{});
        } else {
            logger.debug("{: >4} ", .{self.lines.items[offset]});
        }

        const instruction = self.readOp(offset);

        return instruction.disassemble(self, offset);
    }
};

pub fn expectEqualChunks(expected: *Chunk, actual: *Chunk) !void {
    try std.testing.expect(std.mem.eql(u8, expected.code.items, actual.code.items));

    try std.testing.expect(expected.constants.items.len == actual.constants.items.len);

    for (expected.constants.items, actual.constants.items) |e, a| {
        try std.testing.expect(e.isEql(a));
    }

    try std.testing.expect(std.mem.eql(usize, expected.lines.items, actual.lines.items));
}

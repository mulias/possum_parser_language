const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Value = @import("./value.zig").Value;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    String,
    Number,
    Or,
    TakeRight,
    TakeLeft,
    Return,
};

pub const Chunk = struct {
    allocator: Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Value),
    lines: ArrayList(u32),

    pub fn init(allocator: Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Value).init(allocator),
            .lines = ArrayList(u32).init(allocator),
        };
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
        self.constants.deinit();
        self.lines.deinit();
    }

    pub fn write(self: *Chunk, byte: u8, line: u32) !void {
        try self.code.append(byte);
        try self.lines.append(line);
    }

    pub fn writeOp(self: *Chunk, op: OpCode, line: u32) !void {
        try self.write(@intFromEnum(op), line);
    }

    pub fn writeString(self: *Chunk, s: []const u8, line: u32) !void {
        var idx = try self.addConstant(.{ .String = s });
        try self.writeOp(.String, line);
        try self.write(idx, line);
    }

    pub fn writeNumber(self: *Chunk, n: []const u8, line: u32) !void {
        var idx = try self.addConstant(.{ .Number = n });
        try self.writeOp(.Number, line);
        try self.write(idx, line);
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

        const instruction = @as(OpCode, @enumFromInt(self.code.items[offset]));
        return switch (instruction) {
            .String => self.constantInstruction("String", offset),
            .Number => self.constantInstruction("Number", offset),
            .Or => self.simpleInstruction("Or", offset),
            .TakeRight => self.simpleInstruction("TakeRight", offset),
            .TakeLeft => self.simpleInstruction("TakeLeft", offset),
            .Return => self.simpleInstruction("Return", offset),
        };
    }

    pub fn simpleInstruction(self: *Chunk, name: []const u8, offset: usize) usize {
        _ = self;
        logger.debug("{s}\n", .{name});
        return offset + 1;
    }

    pub fn constantInstruction(self: *Chunk, name: []const u8, offset: usize) usize {
        var constantIdx = self.code.items[offset + 1];
        var constantValue = self.constants.items[constantIdx];
        logger.debug("{s} {} ", .{ name, constantIdx });
        constantValue.print();
        logger.debug("\n", .{});
        return offset + 2;
    }
};

test {
    var alloc = std.testing.allocator;
    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeString("a", 1);
    try chunk.writeString("b", 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeString("c", 1);
    try chunk.writeOp(.TakeRight, 1);
    try chunk.writeString("xyz", 1);
    try chunk.writeOp(.Or, 1);
    try chunk.writeOp(.Return, 2);

    chunk.disassemble("'a' > 'b' > 'v' | 'xyz'");
}

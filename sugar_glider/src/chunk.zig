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

    pub fn writeConst(self: *Chunk, v: Value, line: u32) !void {
        var idx = try self.addConstant(v);
        try self.writeOp(.Constant, line);
        try self.write(idx, line);
    }

    // TODO: use u16 jump and split into 2 u8
    pub fn writeConditional(self: *Chunk, jumpOffset: u8, line: u32) !void {
        try self.writeOp(.Conditional, line);
        try self.write(jumpOffset, line);
    }

    // TODO: use u16 jump and split into 2 u8
    pub fn writeJump(self: *Chunk, jumpOffset: u8, line: u32) !void {
        try self.writeOp(.Jump, line);
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

        const instruction = @as(OpCode, @enumFromInt(self.code.items[offset]));
        return switch (instruction) {
            .Constant => self.constantInstruction("Constant", offset),
            .Jump => self.jumpInstruction("Jump", offset),
            .Or => self.simpleInstruction("Or", offset),
            .TakeRight => self.simpleInstruction("TakeRight", offset),
            .TakeLeft => self.simpleInstruction("TakeLeft", offset),
            .Merge => self.simpleInstruction("Merge", offset),
            .Backtrack => self.simpleInstruction("Backtrack", offset),
            .Destructure => self.simpleInstruction("Destructure", offset),
            .Return => self.simpleInstruction("Return", offset),
            .Sequence => self.simpleInstruction("Sequence", offset),
            .Conditional => self.jumpInstruction("Conditional", offset),
            .End => self.simpleInstruction("End", offset),
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
        logger.debug("{s} {}: ", .{ name, constantIdx });
        constantValue.print();
        logger.debug("\n", .{});
        return offset + 2;
    }

    pub fn jumpInstruction(self: *Chunk, name: []const u8, offset: usize) usize {
        var jumpOffset = self.code.items[offset + 1];
        logger.debug("{s} {}", .{ name, jumpOffset });
        logger.debug("\n", .{});
        return offset + 2;
    }
};

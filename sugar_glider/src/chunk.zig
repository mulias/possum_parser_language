const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Elem = @import("./elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Backtrack,
    Constant,
    Destructure,
    End,
    False,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    MergeElems,
    MergeParsed,
    Null,
    Or,
    Return,
    RunFunctionParser,
    RunLiteralParser,
    Sequence,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, stringTable: StringTable, offset: usize) usize {
        switch (self) {
            .Backtrack,
            .Destructure,
            .End,
            .False,
            .MergeElems,
            .MergeParsed,
            .Null,
            .Or,
            .Return,
            .RunLiteralParser,
            .Sequence,
            .TakeLeft,
            .TakeRight,
            .True,
            => {
                logger.debug("{s}\n", .{@tagName(self)});
                return offset + 1;
            },
            .Constant => {
                var constantIdx = chunk.read(offset + 1);
                var constantElem = chunk.getConstant(constantIdx);
                logger.debug("{s} {}: ", .{ @tagName(self), constantIdx });
                constantElem.print(logger.debug, stringTable);
                logger.debug("\n", .{});
                return offset + 2;
            },
            .RunFunctionParser => {
                const argCount = chunk.read(offset + 1);
                logger.debug("{s} {d}\n", .{ @tagName(self), argCount });
                return offset + 2;
            },
            .Jump,
            .JumpIfFailure,
            .JumpIfSuccess,
            => {
                var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
                jump |= chunk.read(offset + 2);
                const target = @as(isize, @intCast(offset)) + 3 + jump;
                std.debug.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
                return offset + 3;
            },
        }
    }
};

pub const Chunk = struct {
    allocator: Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Elem),
    lines: ArrayList(usize),

    pub fn init(allocator: Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Elem).init(allocator),
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

    pub fn nextByteIndex(self: *Chunk) usize {
        return self.code.items.len;
    }

    pub fn getConstant(self: *Chunk, idx: u8) Elem {
        return self.constants.items[idx];
    }

    pub fn write(self: *Chunk, byte: u8, line: usize) !void {
        try self.code.append(byte);
        try self.lines.append(line);
    }

    pub fn writeOp(self: *Chunk, op: OpCode, line: usize) !void {
        try self.write(@intFromEnum(op), line);
    }

    pub fn updateAt(self: *Chunk, index: usize, value: u8) void {
        self.code.items[index] = value;
    }

    pub fn updateOpAt(self: *Chunk, opIndex: usize, op: OpCode) void {
        self.updateAt(opIndex, @intFromEnum(op));
    }

    pub fn addConstant(self: *Chunk, e: Elem) !u8 {
        const idx = @as(u8, @intCast(self.constants.items.len));
        try self.constants.append(e);
        return idx;
    }

    pub fn disassemble(self: *Chunk, stringTable: StringTable, name: []const u8) void {
        logger.debug("\n==== {s} ====\n", .{name});

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(stringTable, offset);
        }
    }

    pub fn disassembleInstruction(self: *Chunk, stringTable: StringTable, offset: usize) usize {
        // print address
        logger.debug("{:0>4} ", .{offset});

        // print line
        if (offset > 0 and self.lines.items[offset] == self.lines.items[offset - 1]) {
            logger.debug("   | ", .{});
        } else {
            logger.debug("{: >4} ", .{self.lines.items[offset]});
        }

        const instruction = self.readOp(offset);

        return instruction.disassemble(self, stringTable, offset);
    }
};

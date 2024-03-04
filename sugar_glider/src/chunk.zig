const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Elem = @import("./elem.zig").Elem;
const Location = @import("location.zig").Location;
const StringTable = @import("string_table.zig").StringTable;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunctionParser,
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
    RunParser,
    SetGlobal,
    Sequence,
    SubstituteValue,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize) usize {
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
            .Sequence,
            .SubstituteValue,
            .TakeLeft,
            .TakeRight,
            .True,
            => {
                logger.debug("{s}\n", .{@tagName(self)});
                return offset + 1;
            },
            .Constant,
            .RunParser,
            .SetGlobal,
            => {
                var constantIdx = chunk.read(offset + 1);
                var constantElem = chunk.getConstant(constantIdx);
                logger.debug("{s} {}: ", .{ @tagName(self), constantIdx });
                constantElem.print(logger.debug, strings);
                logger.debug("\n", .{});
                return offset + 2;
            },
            .CallFunctionParser => {
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

pub const ChunkError = error{
    TooManyConstants,
    ShortOverflow,
};

pub const Chunk = struct {
    allocator: Allocator,
    code: ArrayList(u8),
    constants: ArrayList(Elem),
    locations: ArrayList(Location),

    pub fn init(allocator: Allocator) Chunk {
        return Chunk{
            .allocator = allocator,
            .code = ArrayList(u8).init(allocator),
            .constants = ArrayList(Elem).init(allocator),
            .locations = ArrayList(Location).init(allocator),
        };
    }

    pub fn deinit(self: *Chunk) void {
        self.code.deinit();
        self.constants.deinit();
        self.locations.deinit();
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

    pub fn write(self: *Chunk, byte: u8, loc: Location) !void {
        try self.code.append(byte);
        try self.locations.append(loc);
    }

    pub fn writeOp(self: *Chunk, op: OpCode, loc: Location) !void {
        try self.write(@intFromEnum(op), loc);
    }

    pub fn writeShort(self: *Chunk, short: u16, loc: Location) !void {
        try self.write(shortUpperBytes(short), loc);
        try self.write(shortLowerBytes(short), loc);
    }

    pub fn updateAt(self: *Chunk, index: usize, value: u8) void {
        self.code.items[index] = value;
    }

    pub fn updateShortAt(self: *Chunk, index: usize, value: usize) !void {
        if (value > std.math.maxInt(u16)) {
            return ChunkError.ShortOverflow;
        }

        const short = @as(u16, @intCast(value));

        self.code.items[index] = shortUpperBytes(short);
        self.code.items[index + 1] = shortLowerBytes(short);
    }

    pub fn updateOpAt(self: *Chunk, opIndex: usize, op: OpCode) void {
        self.updateAt(opIndex, @intFromEnum(op));
    }

    pub fn addConstant(self: *Chunk, e: Elem) !u8 {
        const idx = self.constants.items.len;
        if (idx > std.math.maxInt(u8)) return ChunkError.TooManyConstants;
        try self.constants.append(e);
        return @as(u8, @intCast(idx));
    }

    pub fn disassemble(self: *Chunk, strings: StringTable, name: []const u8) void {
        logger.debug("\n==== {s} ====\n", .{name});

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(offset, strings);
        }
    }

    pub fn disassembleInstruction(self: *Chunk, offset: usize, strings: StringTable) usize {
        // print address
        logger.debug("{:0>4} ", .{offset});

        // print line
        if (offset > 0 and self.locations.items[offset].line == self.locations.items[offset - 1].line) {
            logger.debug("   | ", .{});
        } else {
            logger.debug("{: >4} ", .{self.locations.items[offset].line});
        }

        const instruction = self.readOp(offset);

        return instruction.disassemble(self, strings, offset);
    }

    fn shortLowerBytes(short: u16) u8 {
        return @as(u8, @intCast(short & 0xff));
    }

    fn shortUpperBytes(short: u16) u8 {
        return @as(u8, @intCast((short >> 8) & 0xff));
    }
};

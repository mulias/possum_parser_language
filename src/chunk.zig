const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const Module = @import("module.zig").Module;
const Region = @import("region.zig").Region;
const OpCode = @import("op_code.zig").OpCode;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;

pub const ChunkError = error{
    TooManyConstants,
    TooManyPatterns,
    ShortOverflow,
};

pub const Chunk = struct {
    code: ArrayList(u8) = ArrayList(u8){},
    constants: ArrayList(Elem) = ArrayList(Elem){},
    patterns: ArrayList(Pattern) = ArrayList(Pattern){},
    regions: ArrayList(Region) = ArrayList(Region){},
    source_region: Region,

    pub fn deinit(self: *Chunk, allocator: Allocator) void {
        self.code.deinit(allocator);
        self.constants.deinit(allocator);
        for (self.patterns.items) |*pattern| {
            pattern.deinit(allocator);
        }
        self.patterns.deinit(allocator);
        self.regions.deinit(allocator);
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

    pub fn getPattern(self: *Chunk, idx: u8) Pattern {
        return self.patterns.items[idx];
    }

    pub fn write(self: *Chunk, allocator: Allocator, byte: u8, loc: Region) !void {
        try self.code.append(allocator, byte);
        try self.regions.append(allocator, loc);
    }

    pub fn writeOp(self: *Chunk, allocator: Allocator, op: OpCode, loc: Region) !void {
        try self.write(allocator, @intFromEnum(op), loc);
    }

    pub fn writeShort(self: *Chunk, allocator: Allocator, short: u16, loc: Region) !void {
        try self.write(allocator, shortUpperBytes(short), loc);
        try self.write(allocator, shortLowerBytes(short), loc);
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

    pub fn addConstant(self: *Chunk, allocator: Allocator, e: Elem) !u8 {
        const idx = self.constants.items.len;
        if (idx > std.math.maxInt(u8)) return ChunkError.TooManyConstants;
        try self.constants.append(allocator, e);
        return @as(u8, @intCast(idx));
    }

    pub fn addPattern(self: *Chunk, allocator: Allocator, pattern: Pattern) !u8 {
        const idx = self.patterns.items.len;
        if (idx > std.math.maxInt(u8)) return ChunkError.TooManyPatterns;
        try self.patterns.append(allocator, pattern);
        return @as(u8, @intCast(idx));
    }

    pub fn disassemble(self: *Chunk, vm: VM, writer: anytype, name: []const u8, module: ?*Module) !void {
        try writer.print("\n{s:=^40}\n", .{name});

        if (module) |mod| {
            try mod.printSourceRange(self.source_region, writer);
            try writer.print("\n{s:=^40}\n", .{""});
        }

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = try self.disassembleInstruction(vm, writer, offset);
        }

        try writer.print("{s:=^40}\n", .{""});
    }

    pub fn disassembleInstruction(self: *Chunk, vm: VM, writer: anytype, offset: usize) !usize {
        // print address
        try writer.print("{:0>4} ", .{offset});

        try writer.print("   | ", .{});

        const instruction = self.readOp(offset);

        return instruction.disassemble(self, vm, writer, offset);
    }

    pub fn region(self: *Chunk) Region {
        const first_region = self.regions.items[0];
        const last_region = self.regions.getLast();
        return first_region.merge(last_region);
    }

    fn shortLowerBytes(short: u16) u8 {
        return @as(u8, @intCast(short & 0xff));
    }

    fn shortUpperBytes(short: u16) u8 {
        return @as(u8, @intCast((short >> 8) & 0xff));
    }
};

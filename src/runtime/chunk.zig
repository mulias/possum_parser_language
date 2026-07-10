const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Writer = std.Io.Writer;
const Module = @import("module.zig").Module;
const Region = @import("../region.zig").Region;
const OpCode = @import("op_code.zig").OpCode;
const VM = @import("vm.zig").VM;

pub const ChunkError = error{
    ShortOverflow,
};

pub const Chunk = struct {
    code: ArrayList(u8) = ArrayList(u8){},
    regions: ArrayList(Region) = ArrayList(Region){},
    source_region: Region,

    pub fn deinit(self: *Chunk, allocator: Allocator) void {
        self.code.deinit(allocator);
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

    pub fn writeMedium(self: *Chunk, allocator: Allocator, medium: u24, loc: Region) !void {
        try self.write(allocator, mediumUpperBytes(medium), loc);
        try self.write(allocator, mediumMiddleBytes(medium), loc);
        try self.write(allocator, mediumLowerBytes(medium), loc);
    }

    pub fn writeLong(self: *Chunk, allocator: Allocator, long: u32, loc: Region) !void {
        try self.write(allocator, longByte3(long), loc);
        try self.write(allocator, longByte2(long), loc);
        try self.write(allocator, longByte1(long), loc);
        try self.write(allocator, longByte0(long), loc);
    }

    pub fn writeJump(self: *Chunk, allocator: Allocator, op: OpCode, loc: Region) !usize {
        try self.writeOp(allocator, op, loc);
        // Dummy operands that will be patched later
        try self.writeShort(allocator, 0xffff, loc);
        return self.nextByteIndex() - 2;
    }

    pub fn patchJump(self: *Chunk, offset: usize) !void {
        const jump = self.nextByteIndex() - offset - 2;

        std.debug.assert(self.read(offset) == 0xff);
        std.debug.assert(self.read(offset + 1) == 0xff);

        try self.updateShortAt(offset, @as(u16, @intCast(jump)));
    }

    pub fn updateShortAt(self: *Chunk, index: usize, value: usize) !void {
        if (value > std.math.maxInt(u16)) {
            return ChunkError.ShortOverflow;
        }

        const short = @as(u16, @intCast(value));

        self.code.items[index] = shortUpperBytes(short);
        self.code.items[index + 1] = shortLowerBytes(short);
    }

    pub fn disassemble(self: *Chunk, vm: VM, module: Module, writer: *Writer, name: []const u8) !void {
        var buf: [128]u8 = undefined;
        const formatted_label = std.fmt.bufPrint(&buf, "{d}:{s}", .{ module.id, name });

        if (formatted_label) |label| {
            try writer.print("\n{s:=^40}\n", .{label});
        } else |_| {
            try writer.print("\n{d}:{s}\n", .{ module.id, name });
        }

        // builtin module has no source to print
        if (module.source.len > 0) {
            try module.printSourceRange(self.source_region, writer);
            try writer.print("\n{s:=^40}\n", .{""});
        }

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = try self.disassembleInstruction(vm, module, writer, offset);
        }

        try writer.print("{s:=^40}\n", .{""});
    }

    pub fn disassembleInstruction(self: *Chunk, vm: VM, module: Module, writer: *Writer, offset: usize) !usize {
        // print address
        try writer.print("{:0>4} ", .{offset});

        try writer.print("   | ", .{});

        const instruction = self.readOp(offset);

        return instruction.disassemble(self, vm, module, writer, offset);
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

    fn mediumLowerBytes(medium: u24) u8 {
        return @as(u8, @intCast(medium & 0xff));
    }

    fn mediumMiddleBytes(medium: u24) u8 {
        return @as(u8, @intCast((medium >> 8) & 0xff));
    }

    fn mediumUpperBytes(medium: u24) u8 {
        return @as(u8, @intCast((medium >> 16) & 0xff));
    }

    fn longByte0(long: u32) u8 {
        return @as(u8, @intCast(long & 0xff));
    }

    fn longByte1(long: u32) u8 {
        return @as(u8, @intCast((long >> 8) & 0xff));
    }

    fn longByte2(long: u32) u8 {
        return @as(u8, @intCast((long >> 16) & 0xff));
    }

    fn longByte3(long: u32) u8 {
        return @as(u8, @intCast((long >> 24) & 0xff));
    }
};

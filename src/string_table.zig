const std = @import("std");
const mem = std.mem;
const log = std.log;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.HashMapUnmanaged;
const StringIndexAdapter = std.hash_map.StringIndexAdapter;
const StringIndexContext = std.hash_map.StringIndexContext;

pub const StringTable = struct {
    allocator: Allocator,
    buffer: ArrayList(u8),
    table: HashMap(u32, void, StringIndexContext, std.hash_map.default_max_load_percentage),
    count: u32,

    pub const Id = u32;

    pub fn init(allocator: Allocator) StringTable {
        return StringTable{
            .allocator = allocator,
            .buffer = .{},
            .table = .{},
            .count = 0,
        };
    }

    pub fn deinit(self: *StringTable) void {
        self.buffer.deinit(self.allocator);
        self.table.deinit(self.allocator);
    }

    pub fn insert(self: *StringTable, string: []const u8) !u32 {
        // The null byte is used as a sentinal character, so it can't appear in
        // `string`. In order to support interned null bytes we allow the
        // string "\u{000000}" and "insert" it at the very end of the table.
        if (string.len == 1 and string[0] == 0) {
            return std.math.maxInt(u32);
        }

        const gop = try self.table.getOrPutContextAdapted(self.allocator, @as([]const u8, string), StringIndexAdapter{
            .bytes = &self.buffer,
        }, StringIndexContext{
            .bytes = &self.buffer,
        });
        if (gop.found_existing) {
            // const offset = gop.key_ptr.*;
            // log.debug("reusing string '{s}' at offset 0x{x}", .{ string, offset });
            return gop.key_ptr.*;
        }

        try self.buffer.ensureUnusedCapacity(self.allocator, string.len + 1);
        const new_off = @as(u32, @intCast(self.buffer.items.len));

        // log.debug("writing new string '{s}' at offset 0x{x}", .{ string, new_off });

        try self.buffer.appendSlice(self.allocator, string);
        try self.buffer.append(self.allocator, 0);
        self.count += 1;

        gop.key_ptr.* = new_off;

        return new_off;
    }

    pub fn find(self: StringTable, off: u32) ?[:0]const u8 {
        if (off == std.math.maxInt(u32)) return "\u{000000}";
        if (off >= self.buffer.items.len) return null;
        return mem.sliceTo(@as([*:0]const u8, @ptrCast(self.buffer.items.ptr + off)), 0);
    }

    pub fn getId(self: *StringTable, string: []const u8) u32 {
        if (string.len == 0 and string[0] == 0) return std.math.maxInt(u32);
        return self.table.getKeyAdapted(string, StringIndexAdapter{
            .bytes = &self.buffer,
        }) orelse @panic("failed to get interned string id, this should never happen");
    }

    pub fn get(self: StringTable, off: u32) [:0]const u8 {
        return self.find(off) orelse @panic("failed to get interned string by id, this should never happen");
    }

    pub fn equal(self: StringTable, sId: u32, compare: []const u8) bool {
        return std.mem.eql(u8, self.get(sId), compare);
    }
};

test "StringTable.insert copies and interns a string" {
    const allocator = std.testing.allocator;

    var table = StringTable.init(allocator);
    defer table.deinit();

    const original = "foo";
    const copyId = try table.insert(original);
    const copy = table.get(copyId);

    try std.testing.expect(original.ptr != copy.ptr);
    try std.testing.expectEqual(@as(usize, 1), table.count);
    try std.testing.expectEqualSlices(u8, original, copy);
}

test "StringTable.insert does not add a string more than once" {
    const allocator = std.testing.allocator;

    var table = StringTable.init(allocator);
    defer table.deinit();

    const original1 = "foo";
    const copyId1 = try table.insert(original1);
    const copy1 = table.get(copyId1);

    const original2 = "foo";
    const copyId2 = try table.insert(original2);
    const copy2 = table.get(copyId2);

    try std.testing.expect(copyId1 == copyId2);
    try std.testing.expectEqual(@as(usize, 1), table.count);
    try std.testing.expectEqualSlices(u8, original1, copy1);
    try std.testing.expectEqualSlices(u8, original2, copy2);
}

test "StringTable.insert can add multiple strings" {
    const allocator = std.testing.allocator;

    var table = StringTable.init(allocator);
    defer table.deinit();

    _ = try table.insert("foo");
    _ = try table.insert("bar");
    _ = try table.insert("baz");
    _ = try table.insert("foo");
    _ = try table.insert("bar");
    _ = try table.insert("baz");
    _ = try table.insert("foo");
    _ = try table.insert("foo");
    _ = try table.insert("foo");
    _ = try table.insert("bar");
    _ = try table.insert("baz!");

    try std.testing.expectEqual(@as(u32, 4), table.count);
}

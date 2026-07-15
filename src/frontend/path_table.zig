const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const StringTable = @import("string_table.zig").FrontendStringTable;

// Interns dotted names as segment sequences. Each distinct dotted name gets
// one id, so `Id` equality is name equality, exactly like StringTable.Id for
// strings. Each path also records the flat dotted string's sid, for display
// and for crossing into the runtime string table.
pub const PathTable = struct {
    allocator: Allocator,
    entries: ArrayList(Entry) = .{},
    ids_by_flat: std.AutoHashMapUnmanaged(StringTable.Id, Id) = .{},

    pub const Id = enum(u32) { _ };

    const Entry = struct {
        flat: StringTable.Id,
        segments: []const StringTable.Id,
    };

    pub fn init(allocator: Allocator) PathTable {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *PathTable) void {
        for (self.entries.items) |e| {
            self.allocator.free(e.segments);
        }
        self.entries.deinit(self.allocator);
        self.ids_by_flat.deinit(self.allocator);
    }

    pub fn insert(self: *PathTable, strings: *StringTable, name: []const u8) !Id {
        const flat_sid = try strings.insert(name);
        if (self.ids_by_flat.get(flat_sid)) |id| return id;

        var segment_list = ArrayList(StringTable.Id){};
        errdefer segment_list.deinit(self.allocator);
        var iter = std.mem.splitScalar(u8, name, '.');
        while (iter.next()) |segment| {
            try segment_list.append(self.allocator, try strings.insert(segment));
        }

        const id: Id = @enumFromInt(self.entries.items.len);
        try self.entries.append(self.allocator, .{
            .flat = flat_sid,
            .segments = try segment_list.toOwnedSlice(self.allocator),
        });
        try self.ids_by_flat.put(self.allocator, flat_sid, id);
        return id;
    }

    pub fn flat(self: PathTable, id: Id) StringTable.Id {
        return self.entry(id).flat;
    }

    pub fn segments(self: PathTable, id: Id) []const StringTable.Id {
        return self.entry(id).segments;
    }

    // The path's one segment, or null when the path is dotted. Locals and
    // params are always single-segment, so this is the bridge between a
    // use-site path and the segment lists that hold locals.
    pub fn single(self: PathTable, id: Id) ?StringTable.Id {
        const segs = self.segments(id);
        return if (segs.len == 1) segs[0] else null;
    }

    fn entry(self: PathTable, id: Id) Entry {
        return self.entries.items[@intFromEnum(id)];
    }
};

test "PathTable interns paths by name" {
    const allocator = std.testing.allocator;

    var strings = StringTable.init(allocator);
    defer strings.deinit();
    var paths = PathTable.init(allocator);
    defer paths.deinit();

    const a = try paths.insert(&strings, "json.array");
    const b = try paths.insert(&strings, "json.array");
    const c = try paths.insert(&strings, "json");

    try std.testing.expect(a == b);
    try std.testing.expect(a != c);
    try std.testing.expectEqual(@as(usize, 2), paths.segments(a).len);
    try std.testing.expectEqual(strings.getId("json"), paths.segments(a)[0]);
    try std.testing.expectEqual(strings.getId("array"), paths.segments(a)[1]);
    try std.testing.expectEqual(strings.getId("json.array"), paths.flat(a));
    try std.testing.expect(paths.single(a) == null);
    try std.testing.expectEqual(strings.getId("json"), paths.single(c).?);
}

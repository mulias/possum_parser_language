const std = @import("std");
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;

pub const Module = struct {
    filename: []const u8,
    source: []const u8,
    globals: AutoHashMap(StringTable.Id, Elem),
    allocator: Allocator,

    pub fn init(allocator: Allocator, filename: []const u8, source: []const u8) Module {
        return Module{
            .filename = filename,
            .source = source,
            .globals = AutoHashMap(StringTable.Id, Elem).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Module) void {
        self.globals.deinit();
    }

    pub fn addGlobal(self: *Module, name: StringTable.Id, elem: Elem) !void {
        try self.globals.put(name, elem);
    }

    pub fn getGlobal(self: *Module, name: StringTable.Id) ?Elem {
        return self.globals.get(name);
    }
};
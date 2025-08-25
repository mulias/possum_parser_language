const std = @import("std");
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMapUnmanaged;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;
const highlightRegion = @import("highlight.zig").highlightRegion;
const Region = @import("region.zig").Region;

pub const Module = struct {
    name: ?[]const u8 = null,
    source: []const u8,
    globals: AutoHashMap(StringTable.Id, Elem) = AutoHashMap(StringTable.Id, Elem){},
    showLineNumbers: bool = false,

    pub fn deinit(self: *Module, allocator: Allocator) void {
        self.globals.deinit(allocator);
    }

    pub fn addGlobal(self: *Module, allocator: Allocator, name: StringTable.Id, elem: Elem) !void {
        try self.globals.put(allocator, name, elem);
    }

    pub fn getGlobal(self: *Module, name: StringTable.Id) ?Elem {
        return self.globals.get(name);
    }

    /// Highlight this region in the module source code with context lines and underlines
    pub fn highlight(module: Module, region: Region, writer: *Writer) !void {
        return highlightRegion(module.source, region, writer, .{ .show_line_numbers = module.showLineNumbers });
    }

    /// Print raw source code for the given region
    pub fn printSourceRange(module: Module, region: Region, writer: *Writer) Writer.Error!void {
        const start = @min(region.start, module.source.len);
        const end = @min(region.end, module.source.len);
        if (start < end) {
            try writer.print("{s}", .{module.source[start..end]});
        }
    }
};

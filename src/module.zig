const std = @import("std");
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const Elem = @import("elem.zig").Elem;
const Pattern = @import("pattern.zig").Pattern;
const hl = @import("highlight.zig");
const Region = @import("region.zig").Region;

pub const Module = struct {
    id: Id,
    name: []const u8,
    source: []const u8,
    constants: ArrayList(Elem) = ArrayList(Elem){},
    // Cached mutable copies of container constants, keyed by constant
    // index. Only container constants that GetConstantMutable has copied
    // get an entry, so the map stays sparse where `constants` is dense.
    // Each entry owns one handle to the last copy made for that constant;
    // the copy is reusable again once that handle is the only one left.
    mutable_constants: AutoHashMap(usize, *Elem.DynElem) = .{},
    patterns: ArrayList(Pattern) = ArrayList(Pattern){},

    pub const Id = u16;

    pub fn deinit(self: *Module, allocator: Allocator) void {
        // Cached mutable copies are not released here: the GC destroys
        // every dyn before modules deinit, so the slots may already
        // dangle. The slot handles only matter while the VM is running.
        self.mutable_constants.deinit(allocator);
        self.constants.deinit(allocator);
        for (self.patterns.items) |*pattern| {
            pattern.deinit(allocator);
        }
        self.patterns.deinit(allocator);
    }

    pub fn addConstant(self: *Module, allocator: Allocator, elem: Elem) !usize {
        // Constant-table entries are pushed by GetConstant on every
        // execution: shared by construction, never unique.
        if (elem.isType(.Dyn)) elem.asDyn().makeImmortal();
        const idx = self.constants.items.len;
        try self.constants.append(allocator, elem);
        return idx;
    }

    pub fn getConstant(self: Module, idx: usize) Elem {
        return self.constants.items[idx];
    }

    pub fn addPattern(self: *Module, allocator: Allocator, pattern: Pattern) !usize {
        const idx = self.patterns.items.len;
        try self.patterns.append(allocator, pattern);
        return idx;
    }

    pub fn getPattern(self: Module, idx: usize) Pattern {
        return self.patterns.items[idx];
    }

    /// Highlight this region in the module source code with context lines and underlines
    pub fn highlight(module: Module, region: Region, writer: *Writer) !void {
        return hl.highlightRegion(module.source, region, writer, .{ .show_line_numbers = true });
    }

    /// Highlight the EOF position (one character after the end of source)
    pub fn highlightEnd(module: Module, writer: *Writer) !void {
        return hl.highlightEndPosition(module.source, writer, .{ .show_line_numbers = true });
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

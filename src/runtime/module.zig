const std = @import("std");
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const MatchPlan = @import("match_plan.zig").MatchPlan;
const hl = @import("../highlight.zig");
const Region = @import("../region.zig").Region;

pub const Module = struct {
    id: Id,
    name: []const u8,
    source: []const u8,
    constants: ArrayList(Elem) = ArrayList(Elem){},
    match_plans: ArrayList(MatchPlan) = ArrayList(MatchPlan){},

    pub const Id = u16;

    pub fn deinit(self: *Module, allocator: Allocator) void {
        self.constants.deinit(allocator);
        for (self.match_plans.items) |*plan| {
            plan.deinit(allocator);
        }
        self.match_plans.deinit(allocator);
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

    pub fn addMatchPlan(self: *Module, allocator: Allocator, plan: MatchPlan) !usize {
        const idx = self.match_plans.items.len;
        try self.match_plans.append(allocator, plan);
        return idx;
    }

    pub fn getMatchPlan(self: Module, idx: usize) MatchPlan {
        return self.match_plans.items[idx];
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

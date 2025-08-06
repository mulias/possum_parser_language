const std = @import("std");
const Tuple = std.meta.Tuple;

const highlightRegion = @import("highlight.zig").highlightRegion;
const Module = @import("module.zig").Module;

pub const Region = struct {
    start: usize,
    end: usize,

    pub fn new(start: usize, end: usize) Region {
        return Region{
            .start = start,
            .end = end,
        };
    }

    pub fn merge(r1: Region, r2: Region) Region {
        return new(r1.start, r2.end);
    }

    pub fn printLineRelative(region: Region, str: []const u8, writer: anytype) !void {
        return LineRelativeRegion.fromRegion(region, str, null).print(writer);
    }
};

pub const LineRelativeRegion = struct {
    line: usize,
    relative_start: usize,
    relative_end: usize,

    pub fn fromRegion(region: Region, str: []const u8, start: ?Tuple(&.{ Region, LineRelativeRegion })) LineRelativeRegion {
        if (start) |init| {
            std.debug.assert(init[0].start <= region.start);
        }

        var pos: usize = if (start) |init| init[0].start else 0;
        var line: usize = if (start) |init| init[1].line else 1;
        var line_start: usize = if (start) |init| pos - init[1].relative_start else 0;

        while (pos < region.start and pos < str.len) {
            if (str[pos] == '\n') {
                line += 1;
                line_start = pos + 1;
            }
            pos += 1;
        }

        const relative_start = pos - line_start;
        const relative_end = region.end - line_start;

        return LineRelativeRegion{
            .line = line,
            .relative_start = relative_start,
            .relative_end = relative_end,
        };
    }

    pub fn print(self: LineRelativeRegion, writer: anytype) !void {
        if (self.relative_start == self.relative_end) {
            try writer.print("{d}:{d}", .{ self.line, self.relative_start });
        } else {
            try writer.print("{d}:{d}-{d}", .{ self.line, self.relative_start, self.relative_end });
        }
    }
};

const testing = std.testing;

test "LineRelativeRegion.fromRegion basic functionality" {
    const input =
        \\Hello
        \\world
        \\this is
        \\a test
    ;

    // Test region at start of first line
    {
        const region = Region.new(0, 5); // "Hello"
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 1), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 5), result.relative_end);
    }

    // Test region in second line
    {
        const region = Region.new(6, 11); // "world"
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 2), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 5), result.relative_end);
    }

    // Test region spanning part of third line
    {
        const region = Region.new(12, 16); // "this"
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 3), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 4), result.relative_end);
    }

    // Test region in middle of a line
    {
        const region = Region.new(17, 19); // "is"
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 3), result.line);
        try testing.expectEqual(@as(usize, 5), result.relative_start);
        try testing.expectEqual(@as(usize, 7), result.relative_end);
    }

    // Test region in last line
    {
        const region = Region.new(22, 26); // "test"
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 4), result.line);
        try testing.expectEqual(@as(usize, 2), result.relative_start);
        try testing.expectEqual(@as(usize, 6), result.relative_end);
    }
}

test "LineRelativeRegion.fromRegion with optimization start parameter" {
    const input =
        \\line one
        \\line two
        \\line three
        \\line four
        \\line five
    ;

    // First, get a known region and its line relative region
    const known_region = Region.new(9, 13); // "line" from "line two"
    const known_relative = LineRelativeRegion.fromRegion(known_region, input, null);
    try testing.expectEqual(@as(usize, 2), known_relative.line);
    try testing.expectEqual(@as(usize, 0), known_relative.relative_start);
    try testing.expectEqual(@as(usize, 4), known_relative.relative_end);

    // Now test with optimization - get a region that comes after the known one
    const later_region = Region.new(29, 33); // "line" from "line four"
    const start_opt = .{ known_region, known_relative };
    const result = LineRelativeRegion.fromRegion(later_region, input, start_opt);

    try testing.expectEqual(@as(usize, 4), result.line);
    try testing.expectEqual(@as(usize, 0), result.relative_start);
    try testing.expectEqual(@as(usize, 4), result.relative_end);

    // Verify the result matches what we'd get without optimization
    const result_no_opt = LineRelativeRegion.fromRegion(later_region, input, null);
    try testing.expectEqual(result_no_opt.line, result.line);
    try testing.expectEqual(result_no_opt.relative_start, result.relative_start);
    try testing.expectEqual(result_no_opt.relative_end, result.relative_end);
}

test "LineRelativeRegion.fromRegion edge cases" {
    // Test with input that has a newline at the end
    const input =
        \\a
        \\
        \\b
        \\
    ;

    // Test empty line
    {
        const region = Region.new(2, 2); // Empty region at position where line 3 starts
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 2), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 0), result.relative_end);
    }

    // Test region pointing to 'b'
    {
        const region = Region.new(3, 4); // 'b'
        const result = LineRelativeRegion.fromRegion(region, input, null);
        try testing.expectEqual(@as(usize, 3), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 1), result.relative_end);
    }

    // Test single character input
    const single_input = "x";
    {
        const region = Region.new(0, 1);
        const result = LineRelativeRegion.fromRegion(region, single_input, null);
        try testing.expectEqual(@as(usize, 1), result.line);
        try testing.expectEqual(@as(usize, 0), result.relative_start);
        try testing.expectEqual(@as(usize, 1), result.relative_end);
    }
}

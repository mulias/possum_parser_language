const VMWriter = @import("writer.zig").VMWriter;

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

    pub fn print(region: Region, str: []const u8, writer: VMWriter) !void {
        _ = try writer.write(str[region.start..region.end]);
    }

    pub fn printLineRelative(region: Region, str: []const u8, writer: VMWriter) !void {
        var pos: usize = 0;
        var line: usize = 1;
        var line_start: usize = 0;

        while (pos < region.start and pos < str.len) {
            if (str[pos] == '\n') {
                line += 1;
                line_start = pos + 1;
            }
            pos += 1;
        }

        const relative_start = pos - line_start;
        const relative_end = region.end - line_start;

        try writer.print(
            "[Line {d}, {d}-{d}]",
            .{ line, relative_start, relative_end },
        );
    }
};

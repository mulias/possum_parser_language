const VMWriter = @import("./writer.zig").VMWriter;

pub const Location = struct {
    line: usize,
    start: usize,
    length: usize,

    pub fn new(line: usize, start: usize, length: usize) Location {
        return Location{
            .line = line,
            .start = start,
            .length = length,
        };
    }

    pub fn print(loc: Location, writer: VMWriter) !void {
        try writer.print(
            "[Line {d}, {d}-{d}]",
            .{ loc.line, loc.start, loc.start + loc.length },
        );
    }
};

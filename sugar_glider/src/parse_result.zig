const Elem = @import("./elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;

pub const ParseResultType = enum { Success, Failure };

pub const ParseResult = union(ParseResultType) {
    Success: Success,
    Failure: void,

    pub const Success = struct {
        value: Elem,
        start: usize,
        end: usize,
    };

    pub fn success(value: Elem, start: usize, end: usize) ParseResult {
        return .{ .Success = .{ .value = value, .start = start, .end = end } };
    }

    pub const failure = .{ .Failure = undefined };

    pub fn isSuccess(self: ParseResult) bool {
        return switch (self) {
            .Success => true,
            else => false,
        };
    }

    pub fn asSuccess(self: ParseResult) Success {
        return switch (self) {
            .Success => |s| return s,
            else => unreachable,
        };
    }

    pub fn isFailure(self: ParseResult) bool {
        return !self.isSuccess();
    }

    pub fn print(self: ParseResult, printer: anytype, strings: StringTable) void {
        switch (self) {
            .Success => |s| {
                printer("{d}-{d} ", .{ s.start, s.end });
                s.value.print(printer, strings);
            },
            .Failure => printer("Failure", .{}),
        }
    }
};

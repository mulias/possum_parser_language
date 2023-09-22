const std = @import("std");
const json = std.json;
const logger = @import("./logger.zig");

pub const ValueError = error{
    UnexpectedType,
};

pub const ValueType = enum {
    String,
    Number,
    Success,
    Failure,
};

pub const Success = struct {
    start: usize,
    end: usize,
    value: json.Value,

    pub fn isString(self: Success) bool {
        switch (self.value) {
            .string => return true,
            else => return false,
        }
    }

    pub fn asString(self: Success) ?[]const u8 {
        switch (self.value) {
            .string => |s| return s,
            else => return null,
        }
    }

    pub fn isNumber(self: Success) bool {
        switch (self.value) {
            .number_string => return true,
            else => return false,
        }
    }

    pub fn asNumber(self: Success) ?[]const u8 {
        switch (self) {
            .number_string => |n| return n,
            else => return null,
        }
    }
};

pub const Value = union(ValueType) {
    String: []const u8,
    Number: []const u8,
    Success: Success,
    Failure: void,

    pub fn print(value: Value) void {
        switch (value) {
            .String => |s| logger.debug("\"{s}\"", .{s}),
            .Number => |n| logger.debug("{s}", .{n}),
            .Success => |s| {
                logger.debug("Success {d}-{d} ", .{ s.start, s.end });
                logger.json_debug(s.value);
            },
            .Failure => logger.debug("Failure", .{}),
        }
    }
};

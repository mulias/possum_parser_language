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
};

pub const Value = union(ValueType) {
    String: []const u8,
    Number: []const u8,
    Success: Success,
    Failure: void,

    pub fn print(value: Value) void {
        switch (value) {
            .String => |s| logger.debug("\"{s}\"", .{s}),
            .Number => |n| logger.debug("{d}", .{n}),
            .Success => |s| {
                logger.debug("Success {d}-{d} ", .{ s.start, s.end });
                logger.json_debug(s.value);
            },
            .Failure => logger.debug("Failure", .{}),
        }
    }

    pub fn isString(self: Value) bool {
        switch (self) {
            .String => return true,
            else => return false,
        }
    }

    pub fn asString(self: Value) ?[]const u8 {
        switch (self) {
            .String => |s| return s,
            else => return null,
        }
    }

    pub fn isNumber(self: Value) bool {
        switch (self) {
            .Number => return true,
            else => return false,
        }
    }

    pub fn asNumber(self: Value) ?[]const u8 {
        switch (self) {
            .Number => |n| return n,
            else => return null,
        }
    }

    pub fn isSuccess(self: Value) bool {
        switch (self) {
            .Success => return true,
            else => return false,
        }
    }

    pub fn asSuccess(self: Value) ?json.Value {
        switch (self) {
            .Success => |s| return s,
            else => return null,
        }
    }

    pub fn isFailure(self: Value) bool {
        switch (self) {
            .Failure => return true,
            else => return false,
        }
    }

    pub fn asFailure(self: Value) ?u32 {
        switch (self) {
            .Failure => |f| return f,
            else => return null,
        }
    }
};

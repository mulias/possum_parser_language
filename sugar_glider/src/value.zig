const std = @import("std");
const json = std.json;
const logger = @import("./logger.zig");

pub const ValueError = error{
    UnexpectedType,
};

pub const ValueType = enum {
    String,
    Integer,
    IntegerRange,
    Float,
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

    pub fn isInteger(self: Success) bool {
        switch (self.value) {
            .integer => return true,
            else => return false,
        }
    }

    pub fn asInteger(self: Success) ?i64 {
        switch (self.value) {
            .integer => |i| return i,
            else => return null,
        }
    }

    pub fn isNumber(self: Success) bool {
        switch (self.value) {
            .integer, .float, .number_string => return true,
            else => return false,
        }
    }

    pub fn asFloat(self: Success) !?f64 {
        switch (self.value) {
            .integer => |i| return @as(f64, @floatFromInt(i)),
            .float => |f| return f,
            .number_string => |s| return try std.fmt.parseFloat(f64, s),
            else => return null,
        }
    }
};

pub const Value = union(ValueType) {
    String: []const u8,
    Integer: i64,
    IntegerRange: struct { i64, i64 },
    Float: []const u8,
    Success: Success,
    Failure: void,

    pub fn print(value: Value) void {
        switch (value) {
            .String => |s| logger.debug("\"{s}\"", .{s}),
            .Integer => |i| logger.debug("{d}", .{i}),
            .IntegerRange => |r| logger.debug("{d}..{d}", .{ r[0], r[1] }),
            .Float => |f| logger.debug("{s}", .{f}),
            .Success => |s| {
                logger.debug("{s} {d}-{d} ", .{ @tagName(value), s.start, s.end });
                logger.json_debug(s.value);
            },
            .Failure => logger.debug("{s}", .{@tagName(value)}),
        }
    }

    pub fn toJson(value: Value) ?json.Value {
        switch (value) {
            .String => |s| return .{ .string = s },
            .Integer => |i| return .{ .integer = i },
            .IntegerRange => return null,
            .Float => |f| return .{ .number_string = f },
            .Success => return null,
            .Failure => return null,
        }
    }
};

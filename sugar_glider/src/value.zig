const std = @import("std");
const json = std.json;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const logger = @import("./logger.zig");

pub const ValueError = error{
    UnexpectedType,
};

pub const ValueType = enum {
    String,
    CharacterRange,
    Integer,
    IntegerRange,
    Float,
    Array,
    Object,
    True,
    False,
    Null,
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

    pub fn isArray(self: Success) bool {
        switch (self.value) {
            .array => return true,
            else => return false,
        }
    }

    pub fn asArray(self: Success) ?json.Array {
        switch (self.value) {
            .array => |a| return a,
            else => return null,
        }
    }

    pub fn isObject(self: Success) bool {
        switch (self.value) {
            .object => return true,
            else => return false,
        }
    }

    pub fn asObject(self: Success) ?json.ObjectMap {
        switch (self.value) {
            .object => |o| return o,
            else => return null,
        }
    }

    pub fn isTrue(self: Success) bool {
        switch (self.value) {
            .bool => |b| return b == true,
            else => return false,
        }
    }

    pub fn isFalse(self: Success) bool {
        switch (self.value) {
            .bool => |b| return b == false,
            else => return false,
        }
    }

    pub fn isNull(self: Success) bool {
        switch (self.value) {
            .null => return true,
            else => return false,
        }
    }

    pub fn writeValueString(self: Success, str: *ArrayList(u8)) ![]const u8 {
        try std.json.stringify(self.value, .{}, str.writer());
        return str.items;
    }
};

pub const Value = union(ValueType) {
    String: []const u8,
    CharacterRange: struct { u8, u8 },
    Integer: i64,
    IntegerRange: struct { i64, i64 },
    Float: []const u8,
    Array: json.Array,
    Object: json.ObjectMap,
    True: void,
    False: void,
    Null: void,
    Success: Success,
    Failure: void,

    pub fn print(value: Value) void {
        switch (value) {
            .String => |s| logger.debug("\"{s}\"", .{s}),
            .CharacterRange => |r| logger.debug("\"{c}\"..\"{c}\"", .{ r[0], r[1] }),
            .Integer => |i| logger.debug("{d}", .{i}),
            .IntegerRange => |r| logger.debug("{d}..{d}", .{ r[0], r[1] }),
            .Float => |f| logger.debug("{s}", .{f}),
            .Array => |a| logger.json_debug(.{ .array = a }),
            .Object => |o| logger.json_debug(.{ .object = o }),
            .True => logger.debug("true", .{}),
            .False => logger.debug("false", .{}),
            .Null => logger.debug("null", .{}),
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
            .CharacterRange => return null,
            .Integer => |i| return .{ .integer = i },
            .IntegerRange => return null,
            .Float => |f| return .{ .number_string = f },
            .Array => |a| return .{ .array = a },
            .Object => |o| return .{ .object = o },
            .True => return .{ .bool = true },
            .False => return .{ .bool = false },
            .Null => return .{ .null = undefined },
            .Success => return null,
            .Failure => return null,
        }
    }
};

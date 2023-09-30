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
    Pattern,
    ReturnValue,
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
    Pattern: json.Value,
    ReturnValue: json.Value,
    Success: Success,
    Failure: void,

    pub fn print(value: Value) void {
        switch (value) {
            .String => |s| logger.debug("\"{s}\"", .{s}),
            .CharacterRange => |r| logger.debug("\"{c}\"..\"{c}\"", .{ r[0], r[1] }),
            .Integer => |i| logger.debug("{d}", .{i}),
            .IntegerRange => |r| logger.debug("{d}..{d}", .{ r[0], r[1] }),
            .Float => |f| logger.debug("{s}", .{f}),
            .Array => |a| logger.jsonDebug(.{ .array = a }),
            .Object => |o| logger.jsonDebug(.{ .object = o }),
            .True => logger.debug("true", .{}),
            .False => logger.debug("false", .{}),
            .Null => logger.debug("null", .{}),
            .Pattern => |p| {
                logger.debug("{s} ", .{@tagName(value)});
                logger.jsonDebug(p);
            },
            .ReturnValue => |v| {
                logger.debug("{s} ", .{@tagName(value)});
                logger.jsonDebug(v);
            },
            .Success => |s| {
                logger.debug("{s} {d}-{d} ", .{ @tagName(value), s.start, s.end });
                logger.jsonDebug(s.value);
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
            .Pattern => return null,
            .ReturnValue => return null,
            .Success => return null,
            .Failure => return null,
        }
    }

    pub fn isEql(self: Value, other: Value) bool {
        return switch (self) {
            .String => |s1| switch (other) {
                .String => |s2| std.mem.eql(u8, s1, s2),
                else => false,
            },
            .CharacterRange => |r1| switch (other) {
                .CharacterRange => |r2| r1[0] == r2[0] and r1[1] == r2[1],
                else => false,
            },
            .Integer => |int1| switch (other) {
                .Integer => |int2| int1 == int2,
                else => false,
            },
            .IntegerRange => |r1| switch (other) {
                .IntegerRange => |r2| r1[0] == r2[0] and r1[1] == r2[1],
                else => false,
            },
            .Float => |f1| switch (other) {
                .Float => |f2| std.mem.eql(u8, f1, f2),
                else => false,
            },
            .Array => |a1| switch (other) {
                .Array => |a2| isDeepEql(.{ .array = a1 }, .{ .array = a2 }),
                else => false,
            },
            .Object => |o1| switch (other) {
                .Object => |o2| isDeepEql(.{ .object = o1 }, .{ .object = o2 }),
                else => false,
            },
            .True => switch (other) {
                .True => true,
                else => false,
            },
            .False => switch (other) {
                .False => true,
                else => false,
            },
            .Null => switch (other) {
                .Null => true,
                else => false,
            },
            .Pattern => |p1| switch (other) {
                .Pattern => |p2| isDeepEql(p1, p2),
                else => false,
            },
            .ReturnValue => |v1| switch (other) {
                .ReturnValue => |v2| isDeepEql(v1, v2),
                else => false,
            },
            .Success => |s1| switch (other) {
                .Success => |s2| isDeepEql(s1.value, s2.value),
                else => false,
            },
            .Failure => switch (other) {
                .Failure => true,
                else => false,
            },
        };
    }
};

pub fn isDeepEql(v1: json.Value, v2: json.Value) bool {
    return switch (v1) {
        .string => |s1| switch (v2) {
            .string => |s2| std.mem.eql(u8, s1, s2),
            else => false,
        },
        .integer => |int1| switch (v2) {
            .integer => |int2| int1 == int2,
            .float => |f2| isIntAndFloatEql(int1, f2),
            .number_string => |n2| isIntAndNumberStringEql(int1, n2),
            else => false,
        },
        .float => |f1| switch (v2) {
            .integer => |int2| isIntAndFloatEql(int2, f1),
            .float => |f2| f1 == f2,
            .number_string => |n2| isFloatAndNumberStringEql(f1, n2),
            else => false,
        },
        .number_string => |n1| switch (v2) {
            .integer => |int2| isIntAndNumberStringEql(int2, n1),
            .float => |f2| isFloatAndNumberStringEql(f2, n1),
            .number_string => |n2| std.mem.eql(u8, n1, n2),
            else => false,
        },
        .null => switch (v2) {
            .null => true,
            else => false,
        },
        .bool => |b1| switch (v2) {
            .bool => |b2| b1 == b2,
            else => false,
        },
        .array => |a1| switch (v2) {
            .array => |a2| {
                if (a1.items.len != a2.items.len) return false;
                for (a1.items, a2.items) |elem1, elem2| {
                    if (!isDeepEql(elem1, elem2)) return false;
                }
                return true;
            },
            else => false,
        },
        .object => |o1| switch (v2) {
            .object => |o2| {
                const o1Vals = o1.values();
                const o2Vals = o2.values();
                if (o1Vals.len != o2Vals.len) return false;
                for (o1Vals, o2Vals) |elem1, elem2| {
                    if (!isDeepEql(elem1, elem2)) return false;
                }
                return true;
            },
            else => false,
        },
    };
}

pub const JsonError = error{
    MergeTypeMismatch,
};

pub fn mergeJson(alloc: Allocator, v1: json.Value, v2: json.Value) !json.Value {
    return switch (v1) {
        .string => |s1| switch (v2) {
            .string => |s2| {
                const merged = try std.fmt.allocPrint(alloc, "{s}{s}", .{ s1, s2 });
                return .{ .string = merged };
            },
            else => JsonError.MergeTypeMismatch,
        },
        .integer => |int1| switch (v2) {
            .integer => |int2| .{ .integer = int1 + int2 },
            .float => |f2| addIntAndFloat(int1, f2),
            .number_string => |n2| addIntAndNumberString(int1, n2),
            else => JsonError.MergeTypeMismatch,
        },
        .float => |f1| switch (v2) {
            .integer => |int2| addIntAndFloat(int2, f1),
            .float => |f2| .{ .float = f1 + f2 },
            .number_string => |n2| addFloatAndNumberString(f1, n2),
            else => JsonError.MergeTypeMismatch,
        },
        .number_string => |n1| switch (v2) {
            .integer => |int2| addIntAndNumberString(int2, n1),
            .float => |f2| addFloatAndNumberString(f2, n1),
            .number_string => |n2| addNumberStrings(n1, n2),
            else => JsonError.MergeTypeMismatch,
        },
        .null => switch (v2) {
            .null => v1,
            else => JsonError.MergeTypeMismatch,
        },
        .bool => |b1| switch (v2) {
            .bool => |b2| if (b1 == b2) {
                return v1;
            } else {
                return JsonError.MergeTypeMismatch;
            },
            else => JsonError.MergeTypeMismatch,
        },
        .array => |a1| switch (v2) {
            .array => |a2| {
                var a = json.Array.init(alloc);
                try a.appendSlice(a1.items);
                try a.appendSlice(a2.items);
                return .{ .array = a };
            },
            else => JsonError.MergeTypeMismatch,
        },
        .object => |o1| switch (v2) {
            .object => |o2| {
                var o = json.ObjectMap.init(alloc);

                var iterator1 = o1.iterator();
                while (iterator1.next()) |entry| {
                    try o.put(entry.key_ptr.*, entry.value_ptr.*);
                }

                var iterator2 = o2.iterator();
                while (iterator2.next()) |entry| {
                    try o.put(entry.key_ptr.*, entry.value_ptr.*);
                }

                return .{ .object = o };
            },
            else => JsonError.MergeTypeMismatch,
        },
    };
}

fn isIntAndNumberStringEql(int: i64, numberString: []const u8) bool {
    if (std.fmt.parseInt(i64, numberString, 10) catch null) |int2| {
        return int == int2;
    } else if (std.fmt.parseFloat(f64, numberString) catch null) |float| {
        return isIntAndFloatEql(int, float);
    } else {
        return false;
    }
}

fn isFloatAndNumberStringEql(float: f64, numberString: []const u8) bool {
    if (std.fmt.parseFloat(f64, numberString) catch null) |float2| {
        return float == float2;
    } else if (std.fmt.parseInt(i64, numberString, 10) catch null) |int| {
        return isIntAndFloatEql(int, float);
    } else {
        return false;
    }
}

fn isIntAndFloatEql(int: i64, float: f64) bool {
    const intOfFloat: i64 = @intFromFloat(float);
    const roundTrip: f64 = @floatFromInt(intOfFloat);
    return int == intOfFloat and roundTrip == float;
}

fn addIntAndNumberString(int: i64, numberString: []const u8) json.Value {
    if (std.fmt.parseInt(i64, numberString, 10) catch null) |int2| {
        return .{ .integer = int + int2 };
    } else if (std.fmt.parseFloat(f64, numberString) catch null) |float| {
        return addIntAndFloat(int, float);
    } else {
        unreachable;
    }
}

fn addIntAndFloat(int: i64, float: f64) json.Value {
    const f2: f64 = @floatFromInt(int);
    return .{ .float = float + f2 };
}

fn addFloatAndNumberString(float: f64, numberString: []const u8) json.Value {
    if (std.fmt.parseFloat(f64, numberString) catch null) |f2| {
        return .{ .float = float + f2 };
    } else {
        unreachable;
    }
}

fn addNumberStrings(n1: []const u8, n2: []const u8) json.Value {
    if (std.fmt.parseInt(i64, n1, 10) catch null) |int| {
        return addIntAndNumberString(int, n2);
    } else if (std.fmt.parseFloat(f64, n1) catch null) |float| {
        return addFloatAndNumberString(float, n2);
    } else {
        unreachable;
    }
}

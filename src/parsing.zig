const std = @import("std");
const unicode = std.unicode;
const NumberStringFormat = @import("elem.zig").NumberStringFormat;
const Scanner = @import("scanner.zig").Scanner;

pub fn parseCodepoint(bytes: []const u8) ?u21 {
    if (std.fmt.parseInt(u21, bytes, 16)) |value| {
        if (unicode.utf8ValidCodepoint(value)) {
            return value;
        } else {
            return null;
        }
    } else |_| {
        return null;
    }
}

pub fn numberStringFormat(bytes: []const u8) ?NumberStringFormat {
    var scanner = Scanner.initInternal(bytes);
    const token = scanner.scanNumber();

    if (!scanner.isAtEnd()) return null;

    return switch (token.tokenType) {
        .Integer => .Integer,
        .Float => .Float,
        .Scientific => .Scientific,
        else => null,
    };
}

pub fn parseInteger(bytes: []const u8) ?i64 {
    if (std.fmt.parseInt(i64, bytes, 10)) |value| {
        return value;
    } else |_| {
        return null;
    }
}

pub fn parseFloat(bytes: []const u8) ?f64 {
    if (std.fmt.parseFloat(f64, bytes)) |value| {
        return value;
    } else |_| {
        return null;
    }
}

pub fn intAsStringLen(int: i64) usize {
    const digits = intAsStringLenLoop(int);
    if (int < 0) {
        return digits + 1;
    } else {
        return digits;
    }
}

fn intAsStringLenLoop(int: i64) usize {
    comptime var digits: usize = 1;

    inline while (digits < 19) : (digits += 1) {
        if (@abs(int) < std.math.pow(i64, 10, digits)) return digits;
    }
    return digits;
}

test "intAsStringLen" {
    try std.testing.expectEqual(@as(usize, 1), intAsStringLen(0));
    try std.testing.expectEqual(@as(usize, 1), intAsStringLen(5));
    try std.testing.expectEqual(@as(usize, 2), intAsStringLen(10));
    try std.testing.expectEqual(@as(usize, 3), intAsStringLen(-14));
    try std.testing.expectEqual(@as(usize, 3), intAsStringLen(104));
    try std.testing.expectEqual(@as(usize, 7), intAsStringLen(1041348));
    try std.testing.expectEqual(@as(usize, 8), intAsStringLen(-1041348));
    try std.testing.expectEqual(@as(usize, 19), intAsStringLen(std.math.maxInt(i64)));
    try std.testing.expectEqual(@as(usize, 20), intAsStringLen(std.math.minInt(i64)));
}

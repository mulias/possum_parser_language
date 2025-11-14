const std = @import("std");
const unicode = std.unicode;
const NumberStringElem = @import("elem.zig").Elem.NumberStringElem;
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

pub fn parseSurrogatePair(highSurrogate: []const u8, lowSurrogate: []const u8) ?u21 {
    if (std.fmt.parseInt(u16, highSurrogate, 16)) |high| {
        if (std.fmt.parseInt(u16, lowSurrogate, 16)) |low| {
            if (unicode.utf16IsHighSurrogate(high) and unicode.utf16IsLowSurrogate(low)) {
                return unicode.utf16DecodeSurrogatePair(&[_]u16{ high, low }) catch return null;
            } else {
                return null;
            }
        } else |_| {
            return null;
        }
    } else |_| {
        return null;
    }
}

pub fn isValidNumberString(bytes: []const u8) bool {
    var scanner = Scanner.initInternal(bytes);
    const token = scanner.scanNumber();

    if (!scanner.isAtEnd()) return false;

    return token.tokenType == .Number;
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

pub fn utf8Decode(bytes: []const u8) ?u21 {
    if (bytes.len == 0) return null;

    const expected_len = unicode.utf8ByteSequenceLength(bytes[0]) catch return null;
    if (bytes.len != expected_len) return null;

    return switch (expected_len) {
        1 => bytes[0],
        2 => unicode.utf8Decode2(bytes[0..2].*) catch null,
        3 => unicode.utf8Decode3(bytes[0..3].*) catch null,
        4 => unicode.utf8Decode4(bytes[0..4].*) catch null,
        else => null,
    };
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

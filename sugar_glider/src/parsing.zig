const std = @import("std");
const unicode = std.unicode;

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

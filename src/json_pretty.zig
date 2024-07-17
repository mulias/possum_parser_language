const std = @import("std");
const json = std.json;
const assert = std.debug.assert;

pub const Format = enum { Pretty, Compact, Sparse };

pub fn stringify(j: json.Value, format: Format, out_stream: anytype) !void {
    var writer = WriteStream(@TypeOf(out_stream)).init(format, out_stream);
    try writer.write(j);
}

pub fn WriteStream(comptime OutStream: type) type {
    return struct {
        const Self = @This();

        pub const Stream = OutStream;
        pub const Error = Stream.Error || error{OutOfMemory};

        format: Format,
        stream: OutStream,
        indent_level: usize = 0,

        pub fn init(format: Format, stream: OutStream) Self {
            return .{
                .format = format,
                .stream = stream,
            };
        }

        pub fn write(self: *Self, value: json.Value) Error!void {
            switch (value) {
                .null => try self.stream.writeAll("null"),
                .bool => |b| try self.stream.writeAll(if (b) "true" else "false"),
                .integer => |i| try self.stream.print("{}", .{i}),
                .float => |f| try self.stream.print("{}", .{f}),
                .number_string => |ns| try self.stream.writeAll(ns),
                .string => |s| try encodeJsonString(s, self.stream),
                .array => |a| {
                    const use_indent = self.useIndentation(value);

                    try self.stream.writeByte('[');

                    self.indent_level += 1;

                    for (a.items, 0..) |item, index| {
                        if (use_indent) try self.writeIndentation();

                        try self.write(item);
                        if (index < a.items.len - 1) {
                            try self.stream.writeByte(',');
                            if (self.format == .Pretty and !use_indent) try self.stream.writeByte(' ');
                        }
                    }

                    self.indent_level -= 1;
                    if (use_indent and a.items.len > 0) try self.writeIndentation();

                    try self.stream.writeByte(']');
                },
                .object => |o| {
                    const use_indent = self.useIndentation(value);

                    try self.stream.writeByte('{');

                    self.indent_level += 1;

                    var it = o.iterator();
                    var index: usize = 0;
                    const count = o.count();
                    while (it.next()) |entry| {
                        if (use_indent) try self.writeIndentation();

                        try self.stream.print("\"{s}\"", .{entry.key_ptr.*});
                        try self.stream.writeByte(':');
                        if (self.format != .Compact) try self.stream.writeByte(' ');
                        try self.write(entry.value_ptr.*);
                        if (index < count - 1) {
                            try self.stream.writeByte(',');
                            if (self.format == .Pretty and !use_indent) try self.stream.writeByte(' ');
                        }

                        index += 1;
                    }

                    self.indent_level -= 1;
                    if (use_indent and count > 0) try self.writeIndentation();

                    try self.stream.writeByte('}');
                },
            }
        }

        fn writeIndentation(self: *Self) Error!void {
            const n_chars = 2 * self.indent_level;
            try self.stream.writeByte('\n');
            try self.stream.writeByteNTimes(' ', n_chars);
        }

        fn useIndentation(self: *Self, value: json.Value) bool {
            return self.format == .Sparse or (self.format == .Pretty and hasNestedCollection(value));
        }

        fn hasNestedCollection(value: json.Value) bool {
            switch (value) {
                .array => |inner| {
                    for (inner.items) |item| {
                        if (item == .array or item == .object) return true;
                    }
                    return false;
                },
                .object => |inner| {
                    var it = inner.iterator();
                    while (it.next()) |entry| {
                        const v = entry.value_ptr.*;
                        if (v == .array or v == .object) return true;
                    }
                },
                else => {},
            }
            return false;
        }
    };
}

fn outputUnicodeEscape(codepoint: u21, out_stream: anytype) !void {
    if (codepoint <= 0xFFFF) {
        // If the character is in the Basic Multilingual Plane (U+0000 through U+FFFF),
        // then it may be represented as a six-character sequence: a reverse solidus, followed
        // by the lowercase letter u, followed by four hexadecimal digits that encode the character's code point.
        try out_stream.writeAll("\\u");
        try std.fmt.formatIntValue(codepoint, "x", std.fmt.FormatOptions{ .width = 4, .fill = '0' }, out_stream);
    } else {
        assert(codepoint <= 0x10FFFF);
        // To escape an extended character that is not in the Basic Multilingual Plane,
        // the character is represented as a 12-character sequence, encoding the UTF-16 surrogate pair.
        const high = @as(u16, @intCast((codepoint - 0x10000) >> 10)) + 0xD800;
        const low = @as(u16, @intCast(codepoint & 0x3FF)) + 0xDC00;
        try out_stream.writeAll("\\u");
        try std.fmt.formatIntValue(high, "x", std.fmt.FormatOptions{ .width = 4, .fill = '0' }, out_stream);
        try out_stream.writeAll("\\u");
        try std.fmt.formatIntValue(low, "x", std.fmt.FormatOptions{ .width = 4, .fill = '0' }, out_stream);
    }
}

fn outputSpecialEscape(c: u8, writer: anytype) !void {
    switch (c) {
        '\\' => try writer.writeAll("\\\\"),
        '\"' => try writer.writeAll("\\\""),
        0x08 => try writer.writeAll("\\b"),
        0x0C => try writer.writeAll("\\f"),
        '\n' => try writer.writeAll("\\n"),
        '\r' => try writer.writeAll("\\r"),
        '\t' => try writer.writeAll("\\t"),
        else => try outputUnicodeEscape(c, writer),
    }
}

pub fn encodeJsonString(string: []const u8, writer: anytype) !void {
    try writer.writeByte('\"');
    try encodeJsonStringChars(string, writer);
    try writer.writeByte('\"');
}

/// Write `chars` to `writer` as JSON encoded string characters.
pub fn encodeJsonStringChars(chars: []const u8, writer: anytype) !void {
    var write_cursor: usize = 0;
    var i: usize = 0;
    while (i < chars.len) : (i += 1) {
        switch (chars[i]) {
            // normal bytes
            0x20...0x21, 0x23...0x5B, 0x5D...0xFF => {},
            0x00...0x1F, '\\', '\"' => {
                // Always must escape these.
                try writer.writeAll(chars[write_cursor..i]);
                try outputSpecialEscape(chars[i], writer);
                write_cursor = i + 1;
            },
        }
    }
    try writer.writeAll(chars[write_cursor..chars.len]);
}

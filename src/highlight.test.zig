const std = @import("std");
const testing = std.testing;
const Region = @import("region.zig").Region;
const highlight = @import("highlight.zig");

// Test helper to capture writer output
var test_buffer: std.ArrayList(u8) = undefined;

const TestWriter = struct {
    const Self = @This();

    pub const Error = error{OutOfMemory};

    pub fn write(self: Self, bytes: []const u8) Error!usize {
        _ = self;
        try test_buffer.appendSlice(bytes);
        return bytes.len;
    }

    pub fn print(self: Self, comptime format: []const u8, args: anytype) Error!void {
        _ = self;
        try test_buffer.writer().print(format, args);
    }
};

const TestWriterType = std.io.Writer(TestWriter, TestWriter.Error, TestWriter.write);

fn getTestWriter() TestWriterType {
    return TestWriterType{ .context = TestWriter{} };
}

fn initTestBuffer() void {
    test_buffer = std.ArrayList(u8).init(testing.allocator);
}

fn deinitTestBuffer() void {
    test_buffer.deinit();
}

fn clearTestBuffer() void {
    test_buffer.clearRetainingCapacity();
}

fn getTestOutput() []const u8 {
    return test_buffer.items;
}

test "highlight single line - no line numbers" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello world";
    const region = Region.new(6, 11); // "world"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\hello world
        \\      ^^^^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight single line - region at start" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello world";
    const region = Region.new(0, 5); // "hello"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\hello world
        \\^^^^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight single line - region at end" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello world";
    const region = Region.new(10, 11); // "d"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\hello world
        \\          ^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight multiline - with line numbers" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "line 1\nline 2\nline 3";
    const region = Region.new(7, 13); // "line 2"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\  ▏ ^^^^^^
        \\3 ▏ line 3
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight multiline - with context lines" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
        \\line 4
        \\line 5
        \\line 6
    ;
    const region = Region.new(14, 20); // "line 3"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\  ▏ ^^^^^^
        \\4 ▏ line 4
        \\5 ▏ line 5
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight multiline - region spans multiple lines" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
    ;
    const region = Region.new(4, 9); // " 1\nli"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\  ▏     ^^
        \\2 ▏ line 2
        \\  ▏ ^^
        \\3 ▏ line 3
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight with tabs" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello\tworld";
    const region = Region.new(6, 11); // "world"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected = "hello\tworld\n     \t^^^^^\n";
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight empty source" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "";
    const region = Region.new(0, 0);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected = "";
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight zero-length region in single line" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello world";
    const region = Region.new(5, 5); // position between "hello" and " world"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected = "hello world\n";
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight zero-length region in multi-line source" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
        \\line 4
        \\line 5
    ;
    const region = Region.new(14, 14); // position at start of "line 3"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\4 ▏ line 4
        \\5 ▏ line 5
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight region outside source bounds" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello";
    const region = Region.new(10, 15); // beyond source, clamped to (5, 5)

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected = "hello\n";
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight region partially outside bounds - clamps correctly" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "hello";
    const region = Region.new(3, 10);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\hello
        \\   ^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight at start of multiline" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "line 1\nline 2\nline 3";
    const region = Region.new(0, 4);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\  ▏ ^^^^
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight at end of multiline" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "line 1\nline 2\nline 3";
    const region = Region.new(18, 20);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\  ▏     ^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight with limited context at start" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
    ;
    const region = Region.new(0, 4); // "line" in first line

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\  ▏ ^^^^
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight with limited context at end" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
    ;
    const region = Region.new(14, 20); // "line 3"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\3 ▏ line 3
        \\  ▏ ^^^^^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight line numbers width calculation" {
    initTestBuffer();
    defer deinitTestBuffer();

    // Create source with many lines to test line number width
    var source_buffer = std.ArrayList(u8).init(testing.allocator);
    defer source_buffer.deinit();

    var i: usize = 1;
    while (i <= 100) {
        try source_buffer.writer().print("line {d}\n", .{i});
        i += 1;
    }

    const source = source_buffer.items;
    const region = Region.new(772, 774);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\ 96 ▏ line 96
        \\ 97 ▏ line 97
        \\ 98 ▏ line 98
        \\    ▏      ^^
        \\ 99 ▏ line 99
        \\100 ▏ line 100
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight unicode characters" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "héllo wörld";
    const region = Region.new(6, 11); // "wörld" (note: byte positions)

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\héllo wörld
        \\      ^^^^^
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight newline only source" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "\n";
    const region = Region.new(0, 0); // position at start of first line

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏
        \\2 ▏
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight source with only newlines" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source = "\n\n\n";
    const region = Region.new(1, 2); // middle newline - no visible underline expected

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected = "1 ▏\n2 ▏\n3 ▏\n4 ▏\n";
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight multi-line with indentation - leading whitespace handling" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\function foo() {
        \\    if (condition) {
        \\        return value;
        \\    }
        \\}
    ;
    const region = Region.new(21, 58);

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ function foo() {
        \\2 ▏     if (condition) {
        \\  ▏     ^^^^^^^^^^^^^^^^
        \\3 ▏         return value;
        \\  ▏         ^^^^^^^^^^^^
        \\4 ▏     }
        \\5 ▏ }
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight region spanning more than 4 lines - should truncate" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
        \\line 4
        \\line 5
        \\line 6
        \\line 7
    ;
    // Region spans from "line 2" to "line 6" (5 lines)
    const region = Region.new(7, 41); // "line 2\nline 3\nline 4\nline 5\nline 6"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\  ▏ ^^^^^^
        \\
        \\    ... 3 lines ...
        \\
        \\6 ▏ line 6
        \\  ▏ ^^^^^^
        \\7 ▏ line 7
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight region spanning exactly 4 lines - should not truncate" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 1
        \\line 2
        \\line 3
        \\line 4
        \\line 5
        \\line 6
    ;
    // Region spans from "line 2" to "line 5" (exactly 4 lines)
    const region = Region.new(7, 34); // "line 2\nline 3\nline 4\nline 5"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\1 ▏ line 1
        \\2 ▏ line 2
        \\  ▏ ^^^^^^
        \\3 ▏ line 3
        \\  ▏ ^^^^^^
        \\4 ▏ line 4
        \\  ▏ ^^^^^^
        \\5 ▏ line 5
        \\  ▏ ^^^^^^
        \\6 ▏ line 6
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

test "highlight very long region - truncates to first and last line" {
    initTestBuffer();
    defer deinitTestBuffer();

    const source =
        \\line 01
        \\line 02
        \\line 03
        \\line 04
        \\line 05
        \\line 06
        \\line 07
        \\line 08
        \\line 09
        \\line 10
    ;
    // Region spans from "line 02" to "line 09" (8 lines)
    const region = Region.new(8, 71); // "line 02\n...line 09"

    try highlight.highlightRegion(source, region, getTestWriter());

    const expected =
        \\ 1 ▏ line 01
        \\ 2 ▏ line 02
        \\   ▏ ^^^^^^^
        \\
        \\     ... 6 lines ...
        \\
        \\ 9 ▏ line 09
        \\   ▏ ^^^^^^^
        \\10 ▏ line 10
        \\
    ;
    try testing.expectEqualStrings(expected, getTestOutput());
}

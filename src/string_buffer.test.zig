const std = @import("std");
const StringBuffer = @import("./string_buffer.zig").StringBuffer;

test "concat grows the buffer and str returns the contents" {
    var buffer = StringBuffer.init(std.testing.allocator);
    defer buffer.deinit();

    try buffer.concat("🔥 Hello");
    try buffer.concat(", World 🔥");

    try std.testing.expectEqualStrings("🔥 Hello, World 🔥", buffer.str());
    try std.testing.expectEqual("🔥 Hello, World 🔥".len, buffer.size);
}

test "allocate pre-sizes so exact fills never regrow" {
    var buffer = StringBuffer.init(std.testing.allocator);
    defer buffer.deinit();

    try buffer.allocate(10);
    try buffer.concat("01234");
    try buffer.concat("56789");

    try std.testing.expectEqualStrings("0123456789", buffer.str());
    try std.testing.expectEqual(@as(usize, 10), buffer.buffer.?.len);
}

test "str on an unallocated buffer is empty" {
    var buffer = StringBuffer.init(std.testing.allocator);
    defer buffer.deinit();

    try std.testing.expectEqualStrings("", buffer.str());
}

const std = @import("std");
const Allocator = std.mem.Allocator;

/// An appendable byte buffer: the owned-bytes storage behind leaf
/// strings.
pub const StringBuffer = struct {
    /// The internal character buffer
    buffer: ?[]u8 = null,
    /// The total size of the StringBuffer
    size: usize = 0,

    /// Deallocates the internal buffer
    pub fn deinit(self: *StringBuffer, gpa: Allocator) void {
        if (self.buffer) |buffer| gpa.free(buffer);
    }

    /// Allocates space for the internal buffer
    pub fn allocate(self: *StringBuffer, gpa: Allocator, bytes: usize) !void {
        if (self.buffer) |buffer| {
            if (bytes < self.size) self.size = bytes; // Clamp size to capacity
            self.buffer = try gpa.realloc(buffer, bytes);
        } else {
            self.buffer = try gpa.alloc(u8, bytes);
        }
    }

    /// Appends bytes onto the end of the StringBuffer
    pub fn concat(self: *StringBuffer, gpa: Allocator, bytes: []const u8) !void {
        if (self.buffer) |buffer| {
            if (self.size + bytes.len > buffer.len) {
                try self.allocate(gpa, (self.size + bytes.len) * 2);
            }
        } else {
            try self.allocate(gpa, bytes.len * 2);
        }

        std.mem.copyForwards(u8, self.buffer.?[self.size..(self.size + bytes.len)], bytes);
        self.size += bytes.len;
    }

    /// Bytes the buffer can hold before reallocating
    pub fn capacity(self: StringBuffer) usize {
        if (self.buffer) |buffer| return buffer.len;
        return 0;
    }

    /// Forgets the contents, keeping the allocated buffer
    pub fn clearRetainingCapacity(self: *StringBuffer) void {
        self.size = 0;
    }

    /// Returns the StringBuffer as a string literal
    pub fn str(self: StringBuffer) []const u8 {
        if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }
};

test "concat grows the buffer and str returns the contents" {
    var buffer: StringBuffer = .{};
    defer buffer.deinit(std.testing.allocator);

    try buffer.concat(std.testing.allocator, "🔥 Hello");
    try buffer.concat(std.testing.allocator, ", World 🔥");

    try std.testing.expectEqualStrings("🔥 Hello, World 🔥", buffer.str());
    try std.testing.expectEqual("🔥 Hello, World 🔥".len, buffer.size);
}

test "allocate pre-sizes so exact fills never regrow" {
    var buffer: StringBuffer = .{};
    defer buffer.deinit(std.testing.allocator);

    try buffer.allocate(std.testing.allocator, 10);
    try buffer.concat(std.testing.allocator, "01234");
    try buffer.concat(std.testing.allocator, "56789");

    try std.testing.expectEqualStrings("0123456789", buffer.str());
    try std.testing.expectEqual(@as(usize, 10), buffer.buffer.?.len);
}

test "str on an unallocated buffer is empty" {
    var buffer: StringBuffer = .{};

    try std.testing.expectEqualStrings("", buffer.str());
}

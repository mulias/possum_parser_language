// Based on https://github.com/JakubSzark/zig-string/blob/master/LICENSE
//
// MIT License
//
// Copyright (c) 2020 Jakub Szarkowicz (JakubSzark)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

const std = @import("std");

/// A variable length collection of characters
pub const StringBuffer = struct {
    /// The internal character buffer
    buffer: ?[]u8,
    /// The allocator used for managing the buffer
    allocator: std.mem.Allocator,
    /// The total size of the StringBuffer
    size: usize,

    /// Errors that may occur when using StringBuffer
    pub const Error = error{
        OutOfMemory,
        InvalidRange,
    };

    /// Creates a StringBuffer with an Allocator
    /// User is responsible for managing the new StringBuffer
    pub fn init(allocator: std.mem.Allocator) StringBuffer {
        return .{
            .buffer = null,
            .allocator = allocator,
            .size = 0,
        };
    }

    pub fn init_with_contents(allocator: std.mem.Allocator, contents: []const u8) Error!StringBuffer {
        var string = init(allocator);

        try string.concat(contents);

        return string;
    }

    /// Deallocates the internal buffer
    pub fn deinit(self: *StringBuffer) void {
        if (self.buffer) |buffer| self.allocator.free(buffer);
    }

    /// Returns the size of the internal buffer
    pub fn capacity(self: StringBuffer) usize {
        if (self.buffer) |buffer| return buffer.len;
        return 0;
    }

    /// Allocates space for the internal buffer
    pub fn allocate(self: *StringBuffer, bytes: usize) Error!void {
        if (self.buffer) |buffer| {
            if (bytes < self.size) self.size = bytes; // Clamp size to capacity
            self.buffer = self.allocator.realloc(buffer, bytes) catch {
                return Error.OutOfMemory;
            };
        } else {
            self.buffer = self.allocator.alloc(u8, bytes) catch {
                return Error.OutOfMemory;
            };
        }
    }

    /// Reallocates the the internal buffer to size
    pub fn truncate(self: *StringBuffer) Error!void {
        try self.allocate(self.size);
    }

    /// Appends bytes onto the end of the StringBuffer
    pub fn concat(self: *StringBuffer, bytes: []const u8) Error!void {
        try self.insert(bytes, self.len());
    }

    /// Inserts a string literal into the StringBuffer at an index
    pub fn insert(self: *StringBuffer, literal: []const u8, index: usize) Error!void {
        // Make sure buffer has enough space
        if (self.buffer) |buffer| {
            if (self.size + literal.len > buffer.len) {
                try self.allocate((self.size + literal.len) * 2);
            }
        } else {
            try self.allocate((literal.len) * 2);
        }

        const buffer = self.buffer.?;

        // If the index is >= len, then simply push to the end.
        // If not, then copy contents over and insert literal.
        if (index == self.len()) {
            var i: usize = 0;
            while (i < literal.len) : (i += 1) {
                buffer[self.size + i] = literal[i];
            }
        } else {
            if (StringBuffer.getIndex(buffer, index, true)) |k| {
                // Move existing contents over
                var i: usize = buffer.len - 1;
                while (i >= k) : (i -= 1) {
                    if (i + literal.len < buffer.len) {
                        buffer[i + literal.len] = buffer[i];
                    }

                    if (i == 0) break;
                }

                i = 0;
                while (i < literal.len) : (i += 1) {
                    buffer[index + i] = literal[i];
                }
            }
        }

        self.size += literal.len;
    }

    /// Removes the last character from the StringBuffer
    pub fn pop(self: *StringBuffer) ?[]const u8 {
        if (self.size == 0) return null;

        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (i + size >= self.size) break;
                i += size;
            }

            const ret = buffer[i..self.size];
            self.size -= (self.size - i);
            return ret;
        }

        return null;
    }

    /// Compares this StringBuffer with a string literal
    pub fn cmp(self: StringBuffer, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            return std.mem.eql(u8, buffer[0..self.size], literal);
        }
        return false;
    }

    /// Returns the StringBuffer as a string literal
    pub fn str(self: StringBuffer) []const u8 {
        if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }

    /// Returns an owned slice of this string
    pub fn toOwned(self: StringBuffer) Error!?[]u8 {
        if (self.buffer != null) {
            const string = self.str();
            if (self.allocator.alloc(u8, string.len)) |newStr| {
                std.mem.copyForwards(u8, newStr, string);
                return newStr;
            } else |_| {
                return Error.OutOfMemory;
            }
        }

        return null;
    }

    /// Returns a character at the specified index
    pub fn charAt(self: StringBuffer, index: usize) ?[]const u8 {
        if (self.buffer) |buffer| {
            if (StringBuffer.getIndex(buffer, index, true)) |i| {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                return buffer[i..(i + size)];
            }
        }
        return null;
    }

    /// Returns amount of characters in the StringBuffer
    pub fn len(self: StringBuffer) usize {
        if (self.buffer) |buffer| {
            var length: usize = 0;
            var i: usize = 0;

            while (i < self.size) {
                i += StringBuffer.getUTF8Size(buffer[i]);
                length += 1;
            }

            return length;
        } else {
            return 0;
        }
    }

    /// Finds the first occurrence of the string literal
    pub fn find(self: StringBuffer, literal: []const u8) ?usize {
        if (self.buffer) |buffer| {
            const index = std.mem.indexOf(u8, buffer[0..self.size], literal);
            if (index) |i| {
                return StringBuffer.getIndex(buffer, i, false);
            }
        }

        return null;
    }

    /// Finds the last occurrence of the string literal
    pub fn rfind(self: StringBuffer, literal: []const u8) ?usize {
        if (self.buffer) |buffer| {
            const index = std.mem.lastIndexOf(u8, buffer[0..self.size], literal);
            if (index) |i| {
                return StringBuffer.getIndex(buffer, i, false);
            }
        }

        return null;
    }

    /// Removes a character at the specified index
    pub fn remove(self: *StringBuffer, index: usize) Error!void {
        try self.removeRange(index, index + 1);
    }

    /// Removes a range of character from the StringBuffer
    /// Start (inclusive) - End (Exclusive)
    pub fn removeRange(self: *StringBuffer, start: usize, end: usize) Error!void {
        const length = self.len();
        if (end < start or end > length) return Error.InvalidRange;

        if (self.buffer) |buffer| {
            const rStart = StringBuffer.getIndex(buffer, start, true).?;
            const rEnd = StringBuffer.getIndex(buffer, end, true).?;
            const difference = rEnd - rStart;

            var i: usize = rEnd;
            while (i < self.size) : (i += 1) {
                buffer[i - difference] = buffer[i];
            }

            self.size -= difference;
        }
    }

    /// Trims all whitelist characters at the start of the StringBuffer.
    pub fn trimStart(self: *StringBuffer, whitelist: []const u8) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) : (i += 1) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (size > 1 or !inWhitelist(buffer[i], whitelist)) break;
            }

            if (StringBuffer.getIndex(buffer, i, false)) |k| {
                self.removeRange(0, k) catch {};
            }
        }
    }

    /// Trims all whitelist characters at the end of the StringBuffer.
    pub fn trimEnd(self: *StringBuffer, whitelist: []const u8) void {
        self.reverse();
        self.trimStart(whitelist);
        self.reverse();
    }

    /// Trims all whitelist characters from both ends of the StringBuffer
    pub fn trim(self: *StringBuffer, whitelist: []const u8) void {
        self.trimStart(whitelist);
        self.trimEnd(whitelist);
    }

    /// Copies this StringBuffer into a new one
    /// User is responsible for managing the new StringBuffer
    pub fn clone(self: StringBuffer) Error!StringBuffer {
        var newString = StringBuffer.init(self.allocator);
        try newString.concat(self.str());
        return newString;
    }

    /// Reverses the characters in this StringBuffer
    pub fn reverse(self: *StringBuffer) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (size > 1) std.mem.reverse(u8, buffer[i..(i + size)]);
                i += size;
            }

            std.mem.reverse(u8, buffer[0..self.size]);
        }
    }

    /// Repeats this StringBuffer n times
    pub fn repeat(self: *StringBuffer, n: usize) Error!void {
        try self.allocate(self.size * (n + 1));
        if (self.buffer) |buffer| {
            var i: usize = 1;
            while (i <= n) : (i += 1) {
                var j: usize = 0;
                while (j < self.size) : (j += 1) {
                    buffer[((i * self.size) + j)] = buffer[j];
                }
            }

            self.size *= (n + 1);
        }
    }

    /// Checks the StringBuffer is empty
    pub inline fn isEmpty(self: StringBuffer) bool {
        return self.size == 0;
    }

    /// Splits the StringBuffer into a slice, based on a delimiter and an index
    pub fn split(self: *const StringBuffer, delimiters: []const u8, index: usize) ?[]const u8 {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            var block: usize = 0;
            var start: usize = 0;

            while (i < self.size) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (size == delimiters.len) {
                    if (std.mem.eql(u8, delimiters, buffer[i..(i + size)])) {
                        if (block == index) return buffer[start..i];
                        start = i + size;
                        block += 1;
                    }
                }

                i += size;
            }

            if (i >= self.size - 1 and block == index) {
                return buffer[start..self.size];
            }
        }

        return null;
    }

    /// Splits the StringBuffer into a new string, based on delimiters and an index
    /// The user of this function is in charge of the memory of the new StringBuffer.
    pub fn splitToStringBuffer(self: *const StringBuffer, delimiters: []const u8, index: usize) Error!?StringBuffer {
        if (self.split(delimiters, index)) |block| {
            var string = StringBuffer.init(self.allocator);
            try string.concat(block);
            return string;
        }

        return null;
    }

    /// Clears the contents of the StringBuffer but leaves the capacity
    pub fn clear(self: *StringBuffer) void {
        if (self.buffer) |buffer| {
            for (buffer) |*ch| ch.* = 0;
            self.size = 0;
        }
    }

    /// Converts all (ASCII) uppercase letters to lowercase
    pub fn toLowercase(self: *StringBuffer) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (size == 1) buffer[i] = std.ascii.toLower(buffer[i]);
                i += size;
            }
        }
    }

    /// Converts all (ASCII) uppercase letters to lowercase
    pub fn toUppercase(self: *StringBuffer) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = StringBuffer.getUTF8Size(buffer[i]);
                if (size == 1) buffer[i] = std.ascii.toUpper(buffer[i]);
                i += size;
            }
        }
    }

    /// Creates a StringBuffer from a given range
    /// User is responsible for managing the new StringBuffer
    pub fn substr(self: StringBuffer, start: usize, end: usize) Error!StringBuffer {
        var result = StringBuffer.init(self.allocator);

        if (self.buffer) |buffer| {
            if (StringBuffer.getIndex(buffer, start, true)) |rStart| {
                if (StringBuffer.getIndex(buffer, end, true)) |rEnd| {
                    if (rEnd < rStart or rEnd > self.size)
                        return Error.InvalidRange;
                    try result.concat(buffer[rStart..rEnd]);
                }
            }
        }

        return result;
    }

    // Writer functionality for the StringBuffer.
    pub const Writer = std.Io.GenericWriter(*StringBuffer, Error, appendWrite);

    pub fn writer(self: *StringBuffer) Writer {
        return .{ .context = self };
    }

    fn appendWrite(self: *StringBuffer, m: []const u8) !usize {
        try self.concat(m);
        return m.len;
    }

    // Iterator support
    pub const StringBufferIterator = struct {
        string: *const StringBuffer,
        index: usize,

        pub fn next(it: *StringBufferIterator) ?[]const u8 {
            if (it.string.buffer) |buffer| {
                if (it.index == it.string.size) return null;
                const i = it.index;
                it.index += StringBuffer.getUTF8Size(buffer[i]);
                return buffer[i..it.index];
            } else {
                return null;
            }
        }
    };

    pub fn iterator(self: *const StringBuffer) StringBufferIterator {
        return StringBufferIterator{
            .string = self,
            .index = 0,
        };
    }

    /// Returns whether or not a character is whitelisted
    fn inWhitelist(char: u8, whitelist: []const u8) bool {
        var i: usize = 0;
        while (i < whitelist.len) : (i += 1) {
            if (whitelist[i] == char) return true;
        }

        return false;
    }

    /// Checks if byte is part of UTF-8 character
    inline fn isUTF8Byte(byte: u8) bool {
        return ((byte & 0x80) > 0) and (((byte << 1) & 0x80) == 0);
    }

    /// Returns the real index of a unicode string literal
    fn getIndex(unicode: []const u8, index: usize, real: bool) ?usize {
        var i: usize = 0;
        var j: usize = 0;
        while (i < unicode.len) {
            if (real) {
                if (j == index) return i;
            } else {
                if (i == index) return j;
            }
            i += StringBuffer.getUTF8Size(unicode[i]);
            j += 1;
        }

        return null;
    }

    /// Returns the UTF-8 character's size
    inline fn getUTF8Size(char: u8) u3 {
        return std.unicode.utf8ByteSequenceLength(char) catch {
            return 1;
        };
    }

    pub fn starts_with(self: *StringBuffer, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            const index = std.mem.indexOf(u8, buffer[0..self.size], literal);
            return index == 0;
        }
        return false;
    }

    pub fn ends_with(self: *StringBuffer, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            const index = std.mem.lastIndexOf(u8, buffer[0..self.size], literal);
            const i: usize = self.size - literal.len;
            return index == i;
        }
        return false;
    }

    pub fn replace(self: *StringBuffer, needle: []const u8, replacement: []const u8) !bool {
        if (self.buffer) |buffer| {
            const InputSize = self.size;
            const size = std.mem.replacementSize(u8, buffer[0..InputSize], needle, replacement);
            self.buffer = self.allocator.alloc(u8, size) catch {
                return Error.OutOfMemory;
            };
            self.size = size;
            const changes = std.mem.replace(u8, buffer[0..InputSize], needle, replacement, self.buffer.?);
            if (changes > 0) {
                return true;
            }
        }
        return false;
    }
};

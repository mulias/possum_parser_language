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

/// An appendable byte buffer: the owned-bytes storage behind leaf
/// strings.
pub const StringBuffer = struct {
    /// The internal character buffer
    buffer: ?[]u8,
    /// The allocator used for managing the buffer
    allocator: std.mem.Allocator,
    /// The total size of the StringBuffer
    size: usize,

    pub const Error = error{
        OutOfMemory,
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

    /// Deallocates the internal buffer
    pub fn deinit(self: *StringBuffer) void {
        if (self.buffer) |buffer| self.allocator.free(buffer);
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

    /// Appends bytes onto the end of the StringBuffer
    pub fn concat(self: *StringBuffer, bytes: []const u8) Error!void {
        if (self.buffer) |buffer| {
            if (self.size + bytes.len > buffer.len) {
                try self.allocate((self.size + bytes.len) * 2);
            }
        } else {
            try self.allocate(bytes.len * 2);
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

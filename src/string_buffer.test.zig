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
const ArenaAllocator = std.heap.ArenaAllocator;
const assert = std.debug.assert;
const eql = std.mem.eql;
const string_buffer = @import("./string_buffer.zig");
const StringBuffer = string_buffer.StringBuffer;

test "Basic Usage" {
    // Use your favorite allocator
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Create your StringBuffer
    var myStringBuffer = StringBuffer.init(arena.allocator());
    defer myStringBuffer.deinit();

    // Use functions provided
    try myStringBuffer.concat("🔥 Hello!");
    _ = myStringBuffer.pop();
    try myStringBuffer.concat(", World 🔥");

    // Success!
    assert(myStringBuffer.cmp("🔥 Hello, World 🔥"));
}

test "StringBuffer Tests" {
    // Allocator for the StringBuffer
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    // This is how we create the StringBuffer
    var myStr = StringBuffer.init(arena.allocator());
    defer myStr.deinit();

    // allocate & capacity
    try myStr.allocate(16);
    assert(myStr.capacity() == 16);
    assert(myStr.size == 0);

    // truncate
    try myStr.truncate();
    assert(myStr.capacity() == myStr.size);
    assert(myStr.capacity() == 0);

    // concat
    try myStr.concat("A");
    try myStr.concat("\u{5360}");
    try myStr.concat("💯");
    try myStr.concat("Hello🔥");

    assert(myStr.size == 17);

    // pop & length
    assert(myStr.len() == 9);
    assert(eql(u8, myStr.pop().?, "🔥"));
    assert(myStr.len() == 8);
    assert(eql(u8, myStr.pop().?, "o"));
    assert(myStr.len() == 7);

    // str & cmp
    assert(myStr.cmp("A\u{5360}💯Hell"));
    assert(myStr.cmp(myStr.str()));

    // charAt
    assert(eql(u8, myStr.charAt(2).?, "💯"));
    assert(eql(u8, myStr.charAt(1).?, "\u{5360}"));
    assert(eql(u8, myStr.charAt(0).?, "A"));

    // insert
    try myStr.insert("🔥", 1);
    assert(eql(u8, myStr.charAt(1).?, "🔥"));
    assert(myStr.cmp("A🔥\u{5360}💯Hell"));

    // find
    assert(myStr.find("🔥").? == 1);
    assert(myStr.find("💯").? == 3);
    assert(myStr.find("Hell").? == 4);

    // remove & removeRange
    try myStr.removeRange(0, 3);
    assert(myStr.cmp("💯Hell"));
    try myStr.remove(myStr.len() - 1);
    assert(myStr.cmp("💯Hel"));

    const whitelist = [_]u8{ ' ', '\t', '\n', '\r' };

    // trimStart
    try myStr.insert("      ", 0);
    myStr.trimStart(whitelist[0..]);
    assert(myStr.cmp("💯Hel"));

    // trimEnd
    _ = try myStr.concat("lo💯\n      ");
    myStr.trimEnd(whitelist[0..]);
    assert(myStr.cmp("💯Hello💯"));

    // clone
    var testStr = try myStr.clone();
    defer testStr.deinit();
    assert(testStr.cmp(myStr.str()));

    // reverse
    myStr.reverse();
    assert(myStr.cmp("💯olleH💯"));
    myStr.reverse();
    assert(myStr.cmp("💯Hello💯"));

    // repeat
    try myStr.repeat(2);
    assert(myStr.cmp("💯Hello💯💯Hello💯💯Hello💯"));

    // isEmpty
    assert(!myStr.isEmpty());

    // split
    assert(eql(u8, myStr.split("💯", 0).?, ""));
    assert(eql(u8, myStr.split("💯", 1).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 2).?, ""));
    assert(eql(u8, myStr.split("💯", 3).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 5).?, "Hello"));
    assert(eql(u8, myStr.split("💯", 6).?, ""));

    var splitStr = StringBuffer.init(arena.allocator());
    defer splitStr.deinit();

    try splitStr.concat("variable='value'");
    assert(eql(u8, splitStr.split("=", 0).?, "variable"));
    assert(eql(u8, splitStr.split("=", 1).?, "'value'"));

    // splitToStringBuffer
    var newSplit = try splitStr.splitToStringBuffer("=", 0);
    assert(newSplit != null);
    defer newSplit.?.deinit();

    assert(eql(u8, newSplit.?.str(), "variable"));

    // toLowercase & toUppercase
    myStr.toUppercase();
    assert(myStr.cmp("💯HELLO💯💯HELLO💯💯HELLO💯"));
    myStr.toLowercase();
    assert(myStr.cmp("💯hello💯💯hello💯💯hello💯"));

    // substr
    var subStr = try myStr.substr(0, 7);
    defer subStr.deinit();
    assert(subStr.cmp("💯hello💯"));

    // clear
    myStr.clear();
    assert(myStr.len() == 0);
    assert(myStr.size == 0);

    // writer
    const writer = myStr.writer();
    const length = try writer.write("This is a Test!");
    assert(length == 15);

    // owned
    const mySlice = try myStr.toOwned();
    assert(eql(u8, mySlice.?, "This is a Test!"));
    arena.allocator().free(mySlice.?);

    // StringBufferIterator
    var i: usize = 0;
    var iter = myStr.iterator();
    while (iter.next()) |ch| {
        if (i == 0) {
            assert(eql(u8, "T", ch));
        }
        i += 1;
    }

    assert(i == myStr.len());
}

test "init with contents" {
    // Allocator for the StringBuffer
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    const initial_contents = "StringBuffer with initial contents!";

    // This is how we create the StringBuffer with contents at the start
    var myStr = try StringBuffer.init_with_contents(arena.allocator(), initial_contents);
    assert(eql(u8, myStr.str(), initial_contents));
}

test "starts_with Tests" {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var myStringBuffer = StringBuffer.init(arena.allocator());
    defer myStringBuffer.deinit();

    try myStringBuffer.concat("bananas");
    assert(myStringBuffer.starts_with("bana"));
    assert(!myStringBuffer.starts_with("abc"));
}

test "ends_with Tests" {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var myStringBuffer = StringBuffer.init(arena.allocator());
    defer myStringBuffer.deinit();

    try myStringBuffer.concat("asbananas");
    assert(myStringBuffer.ends_with("nas"));
    assert(!myStringBuffer.ends_with("abc"));

    try myStringBuffer.truncate();
    try myStringBuffer.concat("💯hello💯💯hello💯💯hello💯");
    std.debug.print("", .{});
    assert(myStringBuffer.ends_with("hello💯"));
}

test "replace Tests" {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // Create your StringBuffer
    var myStringBuffer = StringBuffer.init(arena.allocator());
    defer myStringBuffer.deinit();

    try myStringBuffer.concat("hi,how are you");
    var result = try myStringBuffer.replace("hi,", "");
    assert(result);
    assert(eql(u8, myStringBuffer.str(), "how are you"));

    result = try myStringBuffer.replace("abc", " ");
    assert(!result);

    myStringBuffer.clear();
    try myStringBuffer.concat("💯hello💯💯hello💯💯hello💯");
    _ = try myStringBuffer.replace("hello", "hi");
    assert(eql(u8, myStringBuffer.str(), "💯hi💯💯hi💯💯hi💯"));
}

test "rfind Tests" {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var myStringBuffer = try StringBuffer.init_with_contents(arena.allocator(), "💯hi💯💯hi💯💯hi💯");
    defer myStringBuffer.deinit();

    assert(myStringBuffer.rfind("hi") == 9);
}

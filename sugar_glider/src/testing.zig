const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Chunk = @import("chunk.zig").Chunk;
const InterpretResult = @import("vm.zig").InterpretResult;

pub fn expectEqualChunks(expected: *Chunk, actual: *Chunk) !void {
    try std.testing.expect(std.mem.eql(u8, expected.code.items, actual.code.items));

    try std.testing.expect(expected.constants.items.len == actual.constants.items.len);

    for (expected.constants.items, actual.constants.items) |e, a| {
        try std.testing.expect(e.isEql(a));
    }

    try std.testing.expect(std.mem.eql(usize, expected.lines.items, actual.lines.items));
}

pub fn expectJson(expected: []const u8, actual: std.json.Value) !void {
    var str = ArrayList(u8).init(std.testing.allocator);
    defer str.deinit();
    try std.json.stringify(actual, .{}, str.writer());
    try std.testing.expectEqualStrings(expected, str.items);
}

pub fn expectSuccess(result: InterpretResult, start: usize, end: usize, value: []const u8) !void {
    try std.testing.expectEqualStrings("ParserSuccess", @tagName(result));

    try std.testing.expect(result.ParserSuccess.start == start);
    try std.testing.expect(result.ParserSuccess.end == end);
    try expectJson(value, result.ParserSuccess.value);
}

pub fn expectFailure(result: InterpretResult) !void {
    try std.testing.expectEqualStrings("ParserFailure", @tagName(result));
}

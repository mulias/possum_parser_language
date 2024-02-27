const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Tuple = std.meta.Tuple;
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;
const Elem = @import("elem.zig").Elem;
const ParseResult = @import("parse_result.zig").ParseResult;

pub fn expectEqualChunks(expected: *Chunk, actual: *Chunk) !void {
    if (!std.mem.eql(u8, expected.code.items, actual.code.items)) {
        std.debug.print("Chunk code does not match.\n", .{});
        expected.disassemble("Expected");
        actual.disassemble("Actual");

        return error.TestExpectedEqualChunks;
    }

    var matchingConstants = expected.constants.items.len == actual.constants.items.len;

    if (matchingConstants) {
        for (expected.constants.items, actual.constants.items) |e, a| {
            if (!e.isEql(a)) {
                matchingConstants = false;
                break;
            }
        }
    }

    if (!matchingConstants) {
        std.debug.print("Chunk constant list does not match.\n", .{});

        std.debug.print("Expected: ", .{});
        for (expected.constants.items) |elem| {
            elem.print(std.debug.print);
            std.debug.print(" ", .{});
        }
        std.debug.print("\n", .{});

        std.debug.print("Actual: ", .{});
        for (actual.constants.items) |elem| {
            elem.print(std.debug.print);
            std.debug.print(" ", .{});
        }
        std.debug.print("\n", .{});

        return error.TestExpectedEqualChunks;
    }

    if (!std.mem.eql(usize, expected.lines.items, actual.lines.items)) {
        std.debug.print("Chunk code line numbers do not match.\n", .{});

        std.debug.print("Expected:\n", .{});
        for (expected.lines.items) |line| std.debug.print("{d} ", .{line});
        std.debug.print("\n", .{});

        std.debug.print("Actual:\n", .{});
        for (actual.lines.items) |line| std.debug.print("{d} ", .{line});
        std.debug.print("\n", .{});

        return error.TestExpectedEqualChunks;
    }
}

pub fn expectJson(expected: []const u8, actual: std.json.Value) !void {
    var str = ArrayList(u8).init(std.testing.allocator);
    defer str.deinit();
    try std.json.stringify(actual, .{}, str.writer());
    try std.testing.expectEqualStrings(expected, str.items);
}

pub fn expectSuccess(result: ParseResult, value: Elem, range: Tuple(&.{ usize, usize })) !void {
    try std.testing.expect(result.isSuccess());

    const success = result.asSuccess();

    try std.testing.expectEqual(success.start, range[0]);
    try std.testing.expectEqual(success.end, range[1]);
    try std.testing.expect(success.value.isEql(value));
}

pub fn expectFailure(result: ParseResult) !void {
    try std.testing.expect(result.isFailure());
}

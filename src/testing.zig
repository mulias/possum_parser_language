const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Tuple = std.meta.Tuple;
const Chunk = @import("chunk.zig").Chunk;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;

pub fn expectEqualChunks(expected: *Chunk, actual: *Chunk, strings: StringTable) !void {
    if (!std.mem.eql(u8, expected.code.items, actual.code.items)) {
        std.debug.print("Chunk code does not match.\n", .{});
        expected.disassemble("Expected");
        actual.disassemble("Actual");

        return error.TestExpectedEqualChunks;
    }

    var matchingConstants = expected.constants.items.len == actual.constants.items.len;

    if (matchingConstants) {
        for (expected.constants.items, actual.constants.items) |e, a| {
            if (!e.isEql(a, strings)) {
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

pub fn expectSuccess(actual: Elem, expected: Elem, vm: VM) !void {
    try std.testing.expect(actual.isEql(expected, vm));
}

pub fn expectFailure(result: Elem) !void {
    try std.testing.expect(result.isFailure());
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Tuple = std.meta.Tuple;
const Chunk = @import("chunk.zig").Chunk;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;

pub fn expectJson(expected: []const u8, actual: std.json.Value) !void {
    var str = ArrayList(u8){};
    defer str.deinit(std.testing.allocator);
    try std.json.stringify(actual, .{}, str.writer(std.testing.allocator));
    try std.testing.expectEqualStrings(expected, str.items);
}

pub fn expectSuccess(actual: Elem, expected: Elem, vm: VM) !void {
    if (!actual.isEql(expected, vm) or @intFromEnum(actual) != @intFromEnum(expected)) {
        std.debug.print("expectSuccess: returned elems were not equal.\n  expected elem: {s} ", .{@tagName(expected)});
        expected.print(vm, vm.debug_writer) catch {};
        std.debug.print("\n  actual elem: {s} ", .{@tagName(actual)});
        actual.print(vm, vm.debug_writer) catch {};
        std.debug.print("\n", .{});

        return error.TestExpectedEqual;
    }
}

pub fn expectFailure(result: Elem) !void {
    try std.testing.expect(result.isFailure());
}

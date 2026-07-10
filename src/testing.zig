const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const Elem = @import("runtime.zig").Elem;
const VM = @import("runtime.zig").VM;
const Writers = @import("writer.zig").Writers;

var null_buffer: [256]u8 = undefined;
var null_discarding = std.Io.Writer.Discarding.init(&null_buffer);

pub const writers = Writers{
    .out = &null_discarding.writer,
    .err = &null_discarding.writer,
    .debug = &null_discarding.writer,
};

pub fn expectJson(expected: []const u8, actual: std.json.Value) !void {
    var str = ArrayList(u8){};
    defer str.deinit(std.testing.allocator);
    try std.json.stringify(actual, .{}, str.writer(std.testing.allocator));
    try std.testing.expectEqualStrings(expected, str.items);
}

pub fn expectSuccess(actual: Elem, expected: Elem, vm: VM) !void {
    const stderr = std.fs.File.stderr();
    var buffer: [4096]u8 = undefined;
    const file_writer = stderr.writer(&buffer);
    var writer = file_writer.interface;

    if (!actual.isEql(expected, vm)) {
        std.debug.print("expectSuccess: returned elems were not equal.\n", .{});
        std.debug.print("  expected: {s}(", .{expected.tagName()});
        expected.print(vm, &writer) catch {};
        std.debug.print(")\n", .{});
        std.debug.print("  actual: {s}(", .{actual.tagName()});
        actual.print(vm, &writer) catch {};
        std.debug.print(")\n", .{});

        return error.TestExpectedEqual;
    }
}

pub fn expectFailure(result: Elem) !void {
    try std.testing.expect(result.isFailure());
}

const std = @import("std");
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
    const str = try std.json.Stringify.valueAlloc(std.testing.allocator, actual, .{});
    defer std.testing.allocator.free(str);
    try std.testing.expectEqualStrings(expected, str);
}

pub fn expectSuccess(actual: Elem, expected: Elem, vm: VM) !void {
    var io_threaded: std.Io.Threaded = .init_single_threaded;
    const io = io_threaded.io();
    const stderr = std.Io.File.stderr();
    var buffer: [4096]u8 = undefined;
    var file_writer = stderr.writer(io, &buffer);
    const writer = &file_writer.interface;

    if (!actual.isEql(expected, vm)) {
        std.debug.print("expectSuccess: returned elems were not equal.\n", .{});
        std.debug.print("  expected: {s}(", .{expected.tagName()});
        expected.print(vm, writer) catch {};
        writer.flush() catch {};
        std.debug.print(")\n", .{});
        std.debug.print("  actual: {s}(", .{actual.tagName()});
        actual.print(vm, writer) catch {};
        writer.flush() catch {};
        std.debug.print(")\n", .{});

        return error.TestExpectedEqual;
    }
}

pub fn expectFailure(result: Elem) !void {
    try std.testing.expect(result.isFailure());
}

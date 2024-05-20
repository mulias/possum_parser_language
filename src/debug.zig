const std = @import("std");

pub const scanner = false;
pub const parser = false;

pub const writer = std.io.getStdErr().writer();

pub fn print(comptime fmt: []const u8, args: anytype) void {
    writer.print(fmt, args) catch return;
}

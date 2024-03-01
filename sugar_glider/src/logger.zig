const std = @import("std");

pub const debugScanner = false;
pub const debugParser = true;
pub const debugCompiler = true;
pub const debugVM = true;

pub fn out(comptime fmt: []const u8, args: anytype) void {
    std.io.getStdOut().writer().print(fmt, args) catch return;
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    std.io.getStdErr().writer().print(fmt, args) catch return;
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    std.io.getStdErr().writer().print(fmt, args) catch return;
}

pub fn jsonOut(value: std.json.Value) void {
    std.json.stringify(value, .{}, std.io.getStdOut().writer()) catch return;
}

pub fn jsonDebug(value: std.json.Value) void {
    std.json.stringify(value, .{}, std.io.getStdErr().writer()) catch return;
}

const std = @import("std");
const OpCode = @import("./op_code.zig").OpCode;
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;
const Allocator = std.mem.Allocator;
const cli = @import("cli.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    switch (try cli.run()) {
        .Parse => |args| try parse(alloc, args.parser, args.input),
        .Docs => try stdout.print("Docs\n", .{}),
        .Help => try cli.printHelp(),
        .Usage => try cli.printUsage(),
    }
}

fn parse(allocator: Allocator, parserSource: cli.Source, inputSource: cli.Source) !void {
    const parser = try getBytes(allocator, parserSource);
    const input = try getBytes(allocator, inputSource);

    var vm = VM.create();
    try vm.init(allocator, stderr);
    defer vm.deinit();

    const parsed = try vm.interpret(parser, input);

    if (parsed == .Failure) {
        try stderr.print("Parser Failure\n", .{});
    } else {
        try parsed.printJson(.{ .whitespace = .indent_2 }, allocator, stdout, vm.strings);
        try stdout.print("\n", .{});
    }
}

fn getBytes(allocator: Allocator, source: cli.Source) ![]const u8 {
    return switch (source) {
        .String => |str| str,
        .Path => |path| try readFile(allocator, path),
        .Stdin => @panic("todo"),
    };
}

fn readFile(allocator: Allocator, path: []const u8) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(allocator, path, 1e10);
}

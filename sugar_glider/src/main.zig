const std = @import("std");
const OpCode = @import("./chunk.zig").OpCode;
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;
const Allocator = std.mem.Allocator;
const logger = @import("./logger.zig");
const cli = @import("cli.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    switch (try cli.run()) {
        .Parse => |args| try parse(alloc, args.parser, args.input),
        .Docs => logger.out("Docs\n", .{}),
        .Help => try cli.printHelp(),
        .Usage => try cli.printUsage(),
    }
}

fn parse(allocator: Allocator, parserSource: cli.Source, inputSource: cli.Source) !void {
    const parser = try getBytes(allocator, parserSource);
    const input = try getBytes(allocator, inputSource);

    var vm = VM.init(allocator);
    defer vm.deinit();

    const result = try vm.interpret(parser, input);

    switch (result) {
        .Success => |s| {
            s.value.print(logger.out, vm.strings);
            logger.out("\n", .{});
        },
        .Failure => logger.err("Parser Failure", .{}),
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

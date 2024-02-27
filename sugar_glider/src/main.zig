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
        .Help => logger.out("Help\n", .{}),
        .Usage => logger.out("Usage\n", .{}),
    }
}

fn parse(alloc: Allocator, parserSource: cli.Source, inputSource: cli.Source) !void {
    const parser = switch (parserSource) {
        .String => |str| str,
        .Path => |path| try readFile(alloc, path),
        .Stdin => unreachable,
    };
    const input = switch (inputSource) {
        .String => |str| str,
        .Path => |path| try readFile(alloc, path),
        .Stdin => unreachable,
    };

    var vm = VM.init(alloc);
    defer vm.deinit();

    vm.interpret(parser, input) catch |err| switch (err) {
        error.RuntimeError => logger.err("Runtime Error", .{}),
        error.CompileError => logger.err("Compiler Error", .{}),
        else => {},
    };

    switch (vm.parsed.pop()) {
        .Success => |s| s.value.print(logger.out),
        .Failure => logger.err("Parser Failure", .{}),
    }
}

fn readFile(alloc: Allocator, path: []const u8) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(alloc, path, 1e10);
}

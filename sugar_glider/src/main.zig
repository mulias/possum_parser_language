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

    switch (try vm.interpret(parser, input)) {
        .ParserSuccess => |s| logger.jsonOut(s.value),
        .ParserFailure => logger.err("Parser Failure", .{}),
        .CompileError => logger.err("Compiler Error", .{}),
        .RuntimeError => logger.err("Runtime Error", .{}),
    }
}

fn readFile(alloc: Allocator, path: []const u8) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(alloc, path, 1e10);
}

const std = @import("std");
const OpCode = @import("./op_code.zig").OpCode;
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;
const Allocator = std.mem.Allocator;
const cli_config = @import("cli_config.zig");
const Writer = std.fs.File.Writer;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const cli = CLI.init(
        gpa.allocator(),
        std.io.getStdOut().writer(),
        std.io.getStdErr().writer(),
    );

    return cli.run();
}

pub const CLI = struct {
    allocator: Allocator,
    outWriter: Writer,
    errWriter: Writer,

    pub fn init(allocator: Allocator, outWriter: Writer, errWriter: Writer) CLI {
        return CLI{
            .allocator = allocator,
            .outWriter = outWriter,
            .errWriter = errWriter,
        };
    }

    pub fn run(self: CLI) !void {
        switch (try cli_config.run(self.allocator)) {
            .Parse => |args| try self.parse(args.parser, args.input),
            .Docs => try self.outWriter.print("Docs\n", .{}),
            .Help => try cli_config.printHelp(),
            .Usage => try cli_config.printUsage(),
        }
    }

    fn parse(self: CLI, parserSource: cli_config.Source, inputSource: cli_config.Source) !void {
        const parser = switch (parserSource) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("parser"),
        };

        const input = switch (inputSource) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("input"),
        };

        var vm = VM.create();
        try vm.init(self.allocator, self.errWriter);
        defer vm.deinit();

        const parsed = try vm.interpret(parser, input);

        if (parsed == .Failure) {
            try self.errWriter.print("Parser Failure\n", .{});
        } else {
            try parsed.printJson(.{ .whitespace = .indent_2 }, self.allocator, self.outWriter, vm.strings);
            try self.outWriter.print("\n", .{});
        }
    }

    fn readFile(self: CLI, path: []const u8) ![]const u8 {
        return try std.fs.cwd().readFileAlloc(self.allocator, path, 1e10);
    }

    fn readStdin(self: CLI, argName: []const u8) ![]const u8 {
        const stdin = std.io.getStdIn();
        const stat = try stdin.stat();

        const isUserInput = stat.kind != std.fs.File.Kind.named_pipe;

        if (isUserInput) try self.outWriter.print("Reading {s} (press ctrl-d twice to end):\n", .{argName});

        const reader = stdin.reader();
        const input = self.readStreamAlloc(reader);

        if (isUserInput) try self.outWriter.print("\n\n", .{});

        return input;
    }

    pub fn readStreamAlloc(self: CLI, streamReader: anytype) anyerror![]u8 {
        var input = std.ArrayList(u8).init(self.allocator);

        streamReader.streamUntilDelimiter(input.writer(), 0, null) catch |err| switch (err) {
            error.EndOfStream => {
                // This is expected
            },
            else => |e| return e,
        };

        return input.items;
    }
};

const std = @import("std");
const OpCode = @import("./op_code.zig").OpCode;
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;
const Allocator = std.mem.Allocator;
const cli_config = @import("cli_config.zig");
const Env = @import("env.zig").Env;
const Writers = @import("writer.zig").Writers;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const writers = Writers.initStdIo();
    const cli = CLI.init(gpa.allocator(), writers);

    return cli.run();
}

pub const CLI = struct {
    allocator: Allocator,
    writers: Writers,

    pub fn init(allocator: Allocator, writers: Writers) CLI {
        return CLI{
            .allocator = allocator,
            .writers = writers,
        };
    }

    pub fn run(self: CLI) !void {
        switch (try cli_config.run(self.allocator)) {
            .Parse => |args| try self.parse(args.parser, args.input),
            .Docs => try self.writers.out.print("Docs\n", .{}),
            .Help => try cli_config.printHelp(),
            .Usage => try cli_config.printUsage(),
        }
    }

    fn parse(self: CLI, parserSource: cli_config.Source, inputSource: cli_config.Source) !void {
        const env = try Env.fromOS(self.allocator);

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
        try vm.init(self.allocator, self.writers, env);
        defer vm.deinit();

        if (env.runVM) {
            const parsed = try vm.interpret(parser, input);

            if (parsed == .Failure) {
                try self.writers.err.print("Parser Failure\n", .{});
            } else {
                try parsed.printJson(.{ .whitespace = .indent_2 }, self.allocator, self.writers.out, vm.strings);
                try self.writers.out.print("\n", .{});
            }
        } else {
            try vm.compile(parser);
        }
    }

    fn readFile(self: CLI, path: []const u8) ![]const u8 {
        return try std.fs.cwd().readFileAlloc(self.allocator, path, 1e10);
    }

    fn readStdin(self: CLI, argName: []const u8) ![]const u8 {
        const stdin = std.io.getStdIn();
        const stat = try stdin.stat();

        const isUserInput = stat.kind != std.fs.File.Kind.named_pipe;

        if (isUserInput) try self.writers.out.print("Reading {s} (press ctrl-d twice to end):\n", .{argName});

        const reader = stdin.reader();
        const input = self.readStreamAlloc(reader);

        if (isUserInput) try self.writers.out.print("\n\n", .{});

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

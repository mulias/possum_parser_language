const std = @import("std");
const Allocator = std.mem.Allocator;
const Chunk = @import("chunk.zig").Chunk;
const Env = @import("env.zig").Env;
const OpCode = @import("op_code.zig").OpCode;
const VM = @import("vm.zig").VM;
const VMConfig = @import("vm.zig").Config;
const Writers = @import("writer.zig").Writers;
const build_options = @import("build_options");
const cli_config = @import("cli_config.zig");

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
            .Parse => |args| try self.parse(args),
            .Docs => |doc| try self.printDocs(doc),
            .Help => try self.printHelp(),
            .Version => try self.printVersion(),
            .UsageError => |err| try self.printUsageError(err),
        }
    }

    fn parse(self: CLI, args: cli_config.ParseArgs) !void {
        const env = try Env.fromOS(self.allocator);
        var config = VMConfig.init();
        config.setEnv(env);
        config.includeStdlib = args.stdlib;

        const parser = switch (args.parser) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("parser"),
        };

        const input = switch (args.input) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("input"),
        };

        var vm = VM.create();
        try vm.init(self.allocator, self.writers, config);
        defer vm.deinit();

        if (config.runVM) {
            const parsed = try vm.interpret(parser, input);

            if (parsed == .Failure) {
                try self.writers.err.print("Parser Failure\n", .{});
            } else {
                try parsed.writeJson(.Pretty, self.allocator, vm.strings, self.writers.out);
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

    fn printHelp(self: CLI) !void {
        const helpDocs = @embedFile("docs/cli");
        try self.writers.out.print("{s}", .{helpDocs});
    }

    fn printVersion(self: CLI) !void {
        try self.writers.out.print("{s}\n", .{build_options.version});
    }

    fn printUsageError(self: CLI, err: cli_config.UsageErrorType) !void {
        const message = switch (err) {
            .TooManyArgs => "CLI Argument Error: expected one parser and one input arg, got more than expected.",
            .MissingArgs => "CLI Argument Error: expected one parser and one input arg, got fewer than expected.",
        };
        const usage = "Usage: possum [PARSER_FILE] [INPUT_FILE] [-p PARSER] [-i INPUT] [-hv]\n";

        try self.writers.err.print("{s}\n{s}\n", .{ message, usage });
    }

    fn printDocs(self: CLI, doc: cli_config.Docs) !void {
        const text = switch (doc) {
            .advanced => @embedFile("docs/advanced"),
            .cli => @embedFile("docs/cli"),
            .language => @embedFile("docs/language"),
            .overview => @embedFile("docs/overview"),
            .stdlib => @embedFile("docs/stdlib"),
        };

        printWithPager(text) catch self.writers.out.print("{s}", .{text}) catch |e| return e;
    }

    fn printWithPager(str: []const u8) !void {
        var pager = std.ChildProcess.init(&[_][]const u8{ "less", "-FIRXS" }, std.heap.page_allocator);

        pager.stdin_behavior = .Pipe;

        try pager.spawn();

        if (pager.stdin) |inputPipe| {
            defer {
                inputPipe.close();
                pager.stdin = null;
            }
            try inputPipe.writer().writeAll(str);
        }

        _ = try pager.wait();
    }
};

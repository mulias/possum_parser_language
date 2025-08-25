const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Chunk = @import("chunk.zig").Chunk;
const Env = @import("env.zig").Env;
const OpCode = @import("op_code.zig").OpCode;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;
const VMConfig = @import("vm.zig").Config;
const Writers = @import("writer.zig").Writers;
const build_options = @import("build_options");
const cli_config = @import("cli_config.zig");
const maxInt = std.math.maxInt;

pub fn main() void {
    const allocator = switch (builtin.mode) {
        .Debug => blk: {
            var gpa = std.heap.GeneralPurposeAllocator(.{}){};
            break :blk gpa.allocator();
        },
        else => std.heap.smp_allocator,
    };

    const stdout = std.fs.File.stdout();
    var out_buffer: [4096]u8 = undefined;
    var stdout_writer = stdout.writer(&out_buffer);

    const stderr = std.fs.File.stderr();
    var err_buffer: [4096]u8 = undefined;
    var stderr_writer = stderr.writer(&err_buffer);

    defer stdout_writer.interface.flush() catch {};
    defer stderr_writer.interface.flush() catch {};

    const writers = Writers{
        .out = &stdout_writer.interface,
        .err = &stderr_writer.interface,
        .debug = &stderr_writer.interface,
    };
    const cli = CLI.init(allocator, writers);

    cli.run() catch |e| {
        cli.writers.err.print("[{s}]\n", .{@errorName(e)}) catch {};
        stdout_writer.interface.flush() catch {};
        stderr_writer.interface.flush() catch {};
        std.process.exit(1);
    };
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
        var config = VMConfig{ .includeStdlib = args.stdlib };
        config.setEnv(env);

        const userModule = switch (args.parser) {
            .String => |str| Module{
                .source = str,
            },
            .Path => |path| Module{
                .source = try self.readFile(path),
                .name = path,
                .showLineNumbers = true,
            },
            .Stdin => Module{
                .source = try self.readStdin("parser"),
                .showLineNumbers = true,
            },
        };

        const input = switch (args.input) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("input"),
        };

        var vm = VM.create();
        try vm.init(self.allocator, self.writers, config);

        if (config.runVM) {
            const parsed = try vm.interpret(userModule, input);

            if (parsed.isFailure()) {
                return error.ParserFailure;
            } else {
                try parsed.writeJson(.Pretty, vm, self.writers.out);
                try self.writers.out.print("\n", .{});
            }
        } else {
            try vm.compile(userModule);
        }
    }

    fn readFile(self: CLI, path: []const u8) ![]const u8 {
        return try std.fs.cwd().readFileAlloc(self.allocator, path, maxInt(u32));
    }

    fn readStdin(self: CLI, argName: []const u8) ![]const u8 {
        const stdin = std.fs.File.stdin();
        const stat = try stdin.stat();

        const isUserInput = stat.kind != std.fs.File.Kind.named_pipe;

        if (isUserInput) try self.writers.out.print("Reading {s} (press ctrl-d twice to end):\n", .{argName});

        // TODO: Update Io
        const old_reader = stdin.deprecatedReader();
        const input = try old_reader.readAllAlloc(self.allocator, std.math.maxInt(usize));

        if (isUserInput) try self.writers.out.print("\n\n", .{});

        return input;
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
            .@"stdlib-ast" => @embedFile("docs/stdlib-ast"),
        };

        printWithPager(text) catch self.writers.out.print("{s}", .{text}) catch |e| return e;
    }

    fn printWithPager(str: []const u8) !void {
        var pager = std.process.Child.init(&[_][]const u8{ "less", "-FIRXS" }, std.heap.page_allocator);

        pager.stdin_behavior = .Pipe;

        try pager.spawn();

        if (pager.stdin) |inputPipe| {
            defer {
                inputPipe.close();
                pager.stdin = null;
            }
            var pipe_buffer: [4096]u8 = undefined;
            var pipe_writer = inputPipe.writer(&pipe_buffer);
            try pipe_writer.interface.writeAll(str);
            try pipe_writer.interface.flush();
        }

        _ = try pager.wait();
    }
};

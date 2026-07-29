const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const Env = @import("env.zig").Env;
const runtime = @import("runtime.zig");
const VM = runtime.VM;
const VMConfig = runtime.Config;
const Writers = @import("writer.zig").Writers;
const build_options = @import("build_options");
const cli_config = @import("cli_config.zig");
const explain = runtime.explain;

pub fn main(init: std.process.Init) void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator = switch (builtin.mode) {
        .Debug => debug_allocator.allocator(),
        else => std.heap.smp_allocator,
    };
    const io = init.io;

    const stdout = std.Io.File.stdout();
    var out_buffer: [4096]u8 = undefined;
    var stdout_writer = stdout.writer(io, &out_buffer);

    const stderr = std.Io.File.stderr();
    var err_buffer: [4096]u8 = undefined;
    var stderr_writer = stderr.writer(io, &err_buffer);

    defer stdout_writer.interface.flush() catch {};
    defer stderr_writer.interface.flush() catch {};

    const writers = Writers{
        .out = &stdout_writer.interface,
        .err = &stderr_writer.interface,
        .debug = &stderr_writer.interface,
    };
    const cli = CLI.init(allocator, io, init.environ_map, init.minimal.args, writers);

    cli.run() catch |e| {
        cli.writers.err.print("[{s}]\n", .{@errorName(e)}) catch {};
        stdout_writer.interface.flush() catch {};
        stderr_writer.interface.flush() catch {};
        std.process.exit(1);
    };
}

pub const CLI = struct {
    allocator: Allocator,
    io: std.Io,
    environ_map: *std.process.Environ.Map,
    args: std.process.Args,
    writers: Writers,

    pub fn init(allocator: Allocator, io: std.Io, environ_map: *std.process.Environ.Map, args: std.process.Args, writers: Writers) CLI {
        return CLI{
            .allocator = allocator,
            .io = io,
            .environ_map = environ_map,
            .args = args,
            .writers = writers,
        };
    }

    pub fn run(self: CLI) !void {
        switch (try cli_config.run(self.allocator, self.args)) {
            .Parse => |args| try self.parse(args),
            .Docs => |doc| try self.printDocs(doc),
            .Help => try self.printHelp(),
            .Version => try self.printVersion(),
            .UsageError => |err| try self.printUsageError(err),
        }
    }

    fn parse(self: CLI, args: cli_config.ParseArgs) !void {
        const env = Env.fromOS(self.environ_map);
        var config = VMConfig{ .includeStdlib = args.stdlib };
        config.setEnv(env);
        config.explain = args.explain;
        config.io = self.io;
        config.environ_map = self.environ_map;

        var module_name: []const u8 = undefined;
        var source: []const u8 = undefined;
        var parser_path: ?[]const u8 = null;

        switch (args.parser) {
            .String => |str| {
                module_name = "program";
                source = str;
            },
            .Path => |path| {
                module_name = path;
                parser_path = path;
                source = try self.readFile(path);
            },
            .Stdin => {
                module_name = "program";
                source = try self.readStdin("parser");
            },
        }

        const input = switch (args.input) {
            .String => |str| str,
            .Path => |path| try self.readFile(path),
            .Stdin => try self.readStdin("input"),
        };
        const input_name = switch (args.input) {
            .Path => |path| path,
            else => "input",
        };

        var vm = VM.create();
        try vm.init(self.allocator, self.writers, config);
        vm.main_module_path = parser_path;

        if (config.runVM) {
            const parsed = try vm.interpret(module_name, source, input);

            if (parsed.isFailure()) {
                try vm.printParseFailure(input_name);
                if (config.explain) try explain.render(&vm, self.writers.err);
                return error.ParserFailure;
            } else {
                try parsed.writeJson(.Pretty, vm, self.writers.out);
                try self.writers.out.print("\n", .{});
            }

            if (config.print_memory_report) {
                // Flush the result first so the report always follows it
                // when both streams are captured together.
                try self.writers.out.flush();
                try vm.writeMemoryReport(self.writers.err);
                try self.writers.err.flush();
            }
        } else {
            try vm.compile(module_name, source);
        }
    }

    fn readFile(self: CLI, path: []const u8) ![]const u8 {
        return try std.Io.Dir.cwd().readFileAlloc(self.io, path, self.allocator, .unlimited);
    }

    fn readStdin(self: CLI, argName: []const u8) ![]const u8 {
        const stdin = std.Io.File.stdin();
        const stat = try stdin.stat(self.io);

        const isUserInput = stat.kind != std.Io.File.Kind.named_pipe;

        if (isUserInput) try self.writers.out.print("Reading {s} (press ctrl-d twice to end):\n", .{argName});

        var read_buffer: [4096]u8 = undefined;
        var stdin_reader = stdin.reader(self.io, &read_buffer);
        const input = try stdin_reader.interface.allocRemaining(self.allocator, .unlimited);

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

        printWithPager(self.io, text) catch self.writers.out.print("{s}", .{text}) catch |e| return e;
    }

    fn printWithPager(io: std.Io, str: []const u8) !void {
        var pager = try std.process.spawn(io, .{
            .argv = &.{ "less", "-FIRXS" },
            .stdin = .pipe,
        });

        if (pager.stdin) |inputPipe| {
            defer {
                inputPipe.close(io);
                pager.stdin = null;
            }
            var pipe_buffer: [4096]u8 = undefined;
            var pipe_writer = inputPipe.writer(io, &pipe_buffer);
            try pipe_writer.interface.writeAll(str);
            try pipe_writer.interface.flush();
        }

        _ = try pager.wait(io);
    }
};

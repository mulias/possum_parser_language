const clap = @import("clap");
const std = @import("std");

const debug = std.debug;
const io = std.io;

pub const Format = enum { plain, json };

pub const Docs = enum { overview, advanced, language, cli, stdlib };

pub const SourceType = enum { String, Path, Stdin };

pub const Source = union(SourceType) {
    String: []const u8,
    Path: []const u8,
    Stdin: void,
};

pub const ModeType = enum { Parse, Docs, Help, Usage };

pub const Mode = union(ModeType) {
    Parse: struct {
        parser: Source,
        input: Source,
        stdlib: bool,
        import: []const []const u8,
        errorFormat: Format,
    },
    Docs: Docs,
    Help: void,
    Usage: void,
};

const params = clap.parseParamsComptime(
    \\-p, --parser <STR>
    \\-i, --input <STR>
    \\--no-stdlib
    \\--import <FILE>...
    \\--error-format <FORMAT>
    \\-h, --help
    \\-v, --version
    \\--docs <DOCS>
    \\<FILE>...
    \\
);

pub fn run() !Mode {
    const parsers = comptime .{
        .STR = clap.parsers.string,
        .FILE = clap.parsers.string,
        .FORMAT = clap.parsers.enumeration(Format),
        .DOCS = clap.parsers.enumeration(Docs),
    };

    var result = try clap.parse(clap.Help, &params, parsers, .{});
    defer result.deinit();

    // Prioritize --help
    if (result.args.help != 0) return .{ .Help = undefined };

    // Prioritize --docs
    if (result.args.docs) |docs| return .{ .Docs = docs };

    // For Parse mode require one parser param and one input param, either
    // named or positional
    var requiredArgsCount = result.positionals.len;
    if (result.args.parser != null) requiredArgsCount += 1;
    if (result.args.input != null) requiredArgsCount += 1;

    var positionalArg: usize = 0;

    if (requiredArgsCount == 2) {
        var parser: Source = undefined;
        if (result.args.parser) |parserStr| {
            parser = .{ .String = parserStr };
        } else if (isSingleDash(result.positionals[positionalArg])) {
            positionalArg += 1;
            parser = .{ .Stdin = undefined };
        } else {
            positionalArg += 1;
            parser = .{ .Path = result.positionals[0] };
        }

        var input: Source = undefined;
        if (result.args.input) |inputStr| {
            input = .{ .String = inputStr };
        } else if (isSingleDash(result.positionals[positionalArg])) {
            input = .{ .Stdin = undefined };
        } else {
            input = .{ .Path = result.positionals[positionalArg] };
        }

        return .{
            .Parse = .{
                .parser = parser,
                .input = input,
                .stdlib = @field(result.args, "no-stdlib") == 0,
                .import = result.args.import,
                .errorFormat = @field(result.args, "error-format") orelse .plain,
            },
        };
    } else if (requiredArgsCount > 2) {
        // too many args
        return .{ .Usage = undefined };
    } else {
        // need more args
        return .{ .Usage = undefined };
    }
}

pub fn printHelp() !void {
    return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
}

pub fn printUsage() !void {
    const writer = std.io.getStdErr().writer();
    try clap.usage(writer, clap.Help, &params);
    try writer.print("\n", .{});
}

fn isSingleDash(source: []const u8) bool {
    return std.mem.eql(u8, "-", source);
}

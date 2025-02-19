const clap = @import("clap");
const std = @import("std");
const Allocator = std.mem.Allocator;
const debug = std.debug;
const io = std.io;

pub const Format = enum { plain, json };

pub const Docs = enum { overview, advanced, language, cli, stdlib, @"stdlib-ast" };

pub const SourceType = enum { String, Path, Stdin };

pub const Source = union(SourceType) {
    String: []const u8,
    Path: []const u8,
    Stdin: void,
};

pub const UsageErrorType = enum { TooManyArgs, MissingArgs };

pub const ModeType = enum { Parse, Docs, Help, Version, UsageError };

pub const ParseArgs = struct {
    parser: Source,
    input: Source,
    stdlib: bool,
    import: []const []const u8,
    errorFormat: Format,
};

pub const Mode = union(ModeType) {
    Parse: ParseArgs,
    Docs: Docs,
    Help: void,
    Version: void,
    UsageError: UsageErrorType,
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

pub fn run(allocator: Allocator) !Mode {
    const parsers = comptime .{
        .STR = clap.parsers.string,
        .FILE = clap.parsers.string,
        .FORMAT = clap.parsers.enumeration(Format),
        .DOCS = clap.parsers.enumeration(Docs),
    };

    var result = try clap.parse(clap.Help, &params, parsers, .{ .allocator = allocator });
    defer result.deinit();

    if (result.args.help != 0) return .{ .Help = undefined };
    if (result.args.version != 0) return .{ .Version = undefined };
    if (result.args.docs) |docs| return .{ .Docs = docs };

    const files = result.positionals[0];

    // For Parse mode require one parser param and one input param, either
    // named or positional
    var requiredArgsCount = files.len;
    if (result.args.parser != null) requiredArgsCount += 1;
    if (result.args.input != null) requiredArgsCount += 1;

    var positionalArg: usize = 0;

    if (requiredArgsCount == 2) {
        var parser: Source = undefined;
        if (result.args.parser) |parserStr| {
            parser = .{ .String = parserStr };
        } else if (isSingleDash(files[positionalArg])) {
            positionalArg += 1;
            parser = .{ .Stdin = undefined };
        } else {
            parser = .{ .Path = files[positionalArg] };
            positionalArg += 1;
        }

        var input: Source = undefined;
        if (result.args.input) |inputStr| {
            input = .{ .String = inputStr };
        } else if (isSingleDash(files[positionalArg])) {
            input = .{ .Stdin = undefined };
        } else {
            input = .{ .Path = files[positionalArg] };
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
        return .{ .UsageError = .TooManyArgs };
    } else {
        return .{ .UsageError = .MissingArgs };
    }
}

fn isSingleDash(source: []const u8) bool {
    return std.mem.eql(u8, "-", source);
}

const std = @import("std");
const Scanner = @import("scanner.zig").Scanner;
const Token = @import("token.zig").Token;
const Writers = @import("writer.zig").Writers;

const writers = Writers{
    .out = std.io.null_writer.any(),
    .err = std.io.null_writer.any(),
    .debug = std.io.null_writer.any(),
};

fn init(source: []const u8) Scanner {
    return Scanner.init(source, writers, false);
}

fn expectToken(scanner: *Scanner, expected: Token) !void {
    const nextToken = scanner.next();

    if (nextToken) |actual| {
        if (!expected.isEql(actual)) {
            writers.debugPrint("\nExpected token: ", .{});
            try expected.print(writers.debug);
            writers.debugPrint("\nActual token: ", .{});
            try actual.print(writers.debug);
            writers.debugPrint("\n", .{});

            return error.TestExpectedNextToken;
        }
    } else {
        writers.debugPrint("Expected an {s} token, got null", .{@tagName(expected.tokenType)});
        return error.TestExpectedNextToken;
    }
}

test "123 | 456.10" {
    var scanner = init(" 123  |\n  456.10 ");

    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 0, .end = 1 }));
    try expectToken(&scanner, Token.new(.Integer, "123", .{ .start = 1, .end = 4 }));
    try expectToken(&scanner, Token.new(.Whitespace, "  ", .{ .start = 4, .end = 6 }));
    try expectToken(&scanner, Token.new(.Bar, "|", .{ .start = 6, .end = 7 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n  ", .{ .start = 7, .end = 10 }));
    try expectToken(&scanner, Token.new(.Float, "456.10", .{ .start = 10, .end = 16 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 16, .end = 17 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 17, .end = 17 }));
}

test "1 + 2" {
    const source =
        \\1 +
        \\2
    ;
    var scanner = init(source);

    try expectToken(&scanner, Token.new(.Integer, "1", .{ .start = 0, .end = 1 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 1, .end = 2 }));
    try expectToken(&scanner, Token.new(.Plus, "+", .{ .start = 2, .end = 3 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n", .{ .start = 3, .end = 4 }));
    try expectToken(&scanner, Token.new(.Integer, "2", .{ .start = 4, .end = 5 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 5, .end = 5 }));
}

test "Foo = 'a' ; bar = 100" {
    const source =
        \\Foo = 'a'
        \\bar = 100
    ;
    var scanner = init(source);

    try expectToken(&scanner, Token.new(.UppercaseIdentifier, "Foo", .{ .start = 0, .end = 3 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 3, .end = 4 }));
    try expectToken(&scanner, Token.new(.Equal, "=", .{ .start = 4, .end = 5 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 5, .end = 6 }));
    try expectToken(&scanner, Token.new(.SingleQuoteStringStart, "'", .{ .start = 6, .end = 7 }));
    scanner.setStringMode(.SingleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, "a", .{ .start = 7, .end = 8 }));
    try expectToken(&scanner, Token.new(.StringEnd, "'", .{ .start = 8, .end = 9 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n", .{ .start = 9, .end = 10 }));
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "bar", .{ .start = 10, .end = 13 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 13, .end = 14 }));
    try expectToken(&scanner, Token.new(.Equal, "=", .{ .start = 14, .end = 15 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 15, .end = 16 }));
    try expectToken(&scanner, Token.new(.Integer, "100", .{ .start = 16, .end = 19 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 19, .end = 19 }));
}

test "lexer modes: simple string template" {
    var scanner = init("\"hello %(world) end\"");

    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 0, .end = 1 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, "hello ", .{ .start = 1, .end = 7 }));
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 7, .end = 9 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "world", .{ .start = 9, .end = 14 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 14, .end = 15 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, " end", .{ .start = 15, .end = 19 }));
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 19, .end = 20 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 20, .end = 20 }));
}

test "lexer modes: complex string template" {
    var scanner = init("a > \"foo bar %(baz + zab) bop\"");

    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "a", .{ .start = 0, .end = 1 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 1, .end = 2 }));
    try expectToken(&scanner, Token.new(.GreaterThan, ">", .{ .start = 2, .end = 3 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 3, .end = 4 }));
    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 4, .end = 5 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, "foo bar ", .{ .start = 5, .end = 13 }));
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 13, .end = 15 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "baz", .{ .start = 15, .end = 18 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 18, .end = 19 }));
    try expectToken(&scanner, Token.new(.Plus, "+", .{ .start = 19, .end = 20 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 20, .end = 21 }));
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "zab", .{ .start = 21, .end = 24 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 24, .end = 25 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, " bop", .{ .start = 25, .end = 29 }));
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 29, .end = 30 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 30, .end = 30 }));
}

test "lexer modes: backtick string (no template processing)" {
    var scanner = init("`raw string with %(no template) processing`");

    try expectToken(&scanner, Token.new(.BacktickStringStart, "`", .{ .start = 0, .end = 1 }));
    scanner.setBacktickStringMode();
    try expectToken(&scanner, Token.new(.StringContent, "raw string with %(no template) processing", .{ .start = 1, .end = 42 }));
    try expectToken(&scanner, Token.new(.StringEnd, "`", .{ .start = 42, .end = 43 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 43, .end = 43 }));
}

test "lexer modes: empty strings" {
    var scanner = init("\"\"");

    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 0, .end = 1 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 1, .end = 2 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 2, .end = 2 }));
}

test "lexer modes: template at string boundaries" {
    var scanner = init("\"%(foo)\"");

    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 0, .end = 1 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 1, .end = 3 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "foo", .{ .start = 3, .end = 6 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 6, .end = 7 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 7, .end = 8 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 8, .end = 8 }));
}

test "lexer modes: multiple templates" {
    var scanner = init("\"start %(foo) middle %(bar) end\"");

    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 0, .end = 1 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, "start ", .{ .start = 1, .end = 7 }));
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 7, .end = 9 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "foo", .{ .start = 9, .end = 12 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 12, .end = 13 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, " middle ", .{ .start = 13, .end = 21 }));
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 21, .end = 23 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "bar", .{ .start = 23, .end = 26 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 26, .end = 27 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, " end", .{ .start = 27, .end = 31 }));
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 31, .end = 32 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 32, .end = 32 }));
}

test "lexer modes: nested parentheses in template" {
    var scanner = init("\"hello %(func(arg)) world\"");

    try expectToken(&scanner, Token.new(.DoubleQuoteStringStart, "\"", .{ .start = 0, .end = 1 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, "hello ", .{ .start = 1, .end = 7 }));
    try expectToken(&scanner, Token.new(.TemplateStart, "%(", .{ .start = 7, .end = 9 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "func", .{ .start = 9, .end = 13 }));
    try expectToken(&scanner, Token.new(.LeftParen, "(", .{ .start = 13, .end = 14 }));
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "arg", .{ .start = 14, .end = 17 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 17, .end = 18 }));
    try expectToken(&scanner, Token.new(.RightParen, ")", .{ .start = 18, .end = 19 }));
    scanner.setStringMode(.DoubleQuoteStringStart);
    try expectToken(&scanner, Token.new(.StringContent, " world", .{ .start = 19, .end = 25 }));
    try expectToken(&scanner, Token.new(.StringEnd, "\"", .{ .start = 25, .end = 26 }));
    scanner.setNormalMode();
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 26, .end = 26 }));
}

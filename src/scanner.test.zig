const std = @import("std");
const Scanner = @import("scanner.zig").Scanner;
const Token = @import("token.zig").Token;
const Writers = @import("writer.zig").Writers;

const writers = Writers.initStdIo();

fn init(source: []const u8) Scanner {
    return Scanner.init(source, writers, false);
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
    try expectToken(&scanner, Token.new(.String, "'a'", .{ .start = 6, .end = 9 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n", .{ .start = 9, .end = 10 }));
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "bar", .{ .start = 10, .end = 13 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 13, .end = 14 }));
    try expectToken(&scanner, Token.new(.Equal, "=", .{ .start = 14, .end = 15 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .start = 15, .end = 16 }));
    try expectToken(&scanner, Token.new(.Integer, "100", .{ .start = 16, .end = 19 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .start = 19, .end = 19 }));
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

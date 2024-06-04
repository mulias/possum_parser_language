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
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 1, .start = 0, .length = 1 }));
    try expectToken(&scanner, Token.new(.Integer, "123", .{ .line = 1, .start = 1, .length = 3 }));
    try expectToken(&scanner, Token.new(.Whitespace, "  ", .{ .line = 1, .start = 4, .length = 2 }));
    try expectToken(&scanner, Token.new(.Bar, "|", .{ .line = 1, .start = 6, .length = 1 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n  ", .{ .line = 1, .start = 7, .length = 3 }));
    try expectToken(&scanner, Token.new(.Float, "456.10", .{ .line = 2, .start = 2, .length = 6 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 2, .start = 8, .length = 1 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .line = 2, .start = 9, .length = 0 }));
}

test "1 + 2" {
    const source =
        \\1 +
        \\2
    ;
    var scanner = init(source);
    try expectToken(&scanner, Token.new(.Integer, "1", .{ .line = 1, .start = 0, .length = 1 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 1, .start = 1, .length = 1 }));
    try expectToken(&scanner, Token.new(.Plus, "+", .{ .line = 1, .start = 2, .length = 1 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n", .{ .line = 1, .start = 3, .length = 1 }));
    try expectToken(&scanner, Token.new(.Integer, "2", .{ .line = 2, .start = 0, .length = 1 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .line = 2, .start = 1, .length = 0 }));
}

test "Foo = 'a' ; bar = 100" {
    const source =
        \\Foo = 'a'
        \\bar = 100
    ;
    var scanner = init(source);
    try expectToken(&scanner, Token.new(.UppercaseIdentifier, "Foo", .{ .line = 1, .start = 0, .length = 3 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 1, .start = 3, .length = 1 }));
    try expectToken(&scanner, Token.new(.Equal, "=", .{ .line = 1, .start = 4, .length = 1 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 1, .start = 5, .length = 1 }));
    try expectToken(&scanner, Token.new(.String, "'a'", .{ .line = 1, .start = 6, .length = 3 }));
    try expectToken(&scanner, Token.new(.WhitespaceWithNewline, "\n", .{ .line = 1, .start = 9, .length = 1 }));
    try expectToken(&scanner, Token.new(.LowercaseIdentifier, "bar", .{ .line = 2, .start = 0, .length = 3 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 2, .start = 3, .length = 1 }));
    try expectToken(&scanner, Token.new(.Equal, "=", .{ .line = 2, .start = 4, .length = 1 }));
    try expectToken(&scanner, Token.new(.Whitespace, " ", .{ .line = 2, .start = 5, .length = 1 }));
    try expectToken(&scanner, Token.new(.Integer, "100", .{ .line = 2, .start = 6, .length = 3 }));
    try expectToken(&scanner, Token.new(.Eof, "", .{ .line = 2, .start = 9, .length = 0 }));
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

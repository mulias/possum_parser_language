const std = @import("std");
const logger = @import("./logger.zig");

pub const TokenType = enum {
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    LeftBracket,
    RightBracket,
    Comma,
    Dot,
    Plus,
    Semicolon,
    Bang,
    DollarSign,
    Ampersand,
    QuestionMark,
    Equal,
    GreaterThan,
    Bar,
    LessThan,
    LessThanDash,
    LowercaseIdentifier,
    UppercaseIdentifier,
    String,
    Integer,
    Float,
    True,
    False,
    Null,
    Whitespace,
    WhitespaceWithNewline,
    Error,
    Eof,
};

pub const Token = struct {
    tokenType: TokenType,
    lexeme: []const u8,
    line: usize,
    start: usize,

    pub fn isEql(self: Token, other: Token) bool {
        return self.tokenType == other.tokenType and
            std.mem.eql(u8, self.lexeme, other.lexeme) and
            self.line == other.line and
            self.start == other.start;
    }

    pub fn printDebug(self: Token) void {
        logger.debug("{} '{s}' {d}:{d}", .{ self.tokenType, self.lexeme, self.line, self.start });
    }
};

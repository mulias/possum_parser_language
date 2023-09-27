const std = @import("std");

pub const TokenType = enum {
    // Single-character tokens.
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

    // One or two character tokens.
    LessThan,
    LessThanDash,

    // Literals.
    LowercaseIdentifier,
    UppercaseIdentifier,
    String,
    Integer,
    Float,

    // Keywords.
    True,
    False,
    Nil,
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
};

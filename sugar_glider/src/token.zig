const std = @import("std");
const logger = @import("./logger.zig");
const Location = @import("location.zig").Location;

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
    Colon,
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
    loc: Location,

    pub fn new(tokenType: TokenType, lexeme: []const u8, loc: Location) Token {
        return Token{ .tokenType = tokenType, .lexeme = lexeme, .loc = loc };
    }

    pub fn isEql(self: Token, other: Token) bool {
        return self.tokenType == other.tokenType and
            std.mem.eql(u8, self.lexeme, other.lexeme) and
            self.loc.line == other.loc.line and
            self.loc.start == other.loc.start and
            self.loc.length == other.loc.length;
    }

    pub fn isType(self: Token, tokenType: TokenType) bool {
        return self.tokenType == tokenType;
    }

    pub fn print(self: Token, printer: anytype) void {
        printer("{s} '{s}' {d}:{d}-{d}", .{
            @tagName(self.tokenType),
            self.lexeme,
            self.loc.line,
            self.loc.start,
            self.loc.start + self.loc.length,
        });
    }
};

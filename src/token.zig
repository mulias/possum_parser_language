const std = @import("std");
const Region = @import("region.zig").Region;

pub const TokenType = enum {
    Ampersand,
    Bang,
    Bar,
    Colon,
    Comma,
    DashGreaterThan,
    DollarSign,
    DotDot,
    DotDotDot,
    Eof,
    Equal,
    Error,
    False,
    Float,
    GreaterThan,
    Integer,
    LeftBrace,
    LeftBracket,
    LeftParen,
    LessThan,
    LowercaseIdentifier,
    Minus,
    Null,
    Plus,
    QuestionMark,
    RightBrace,
    RightBracket,
    RightParen,
    Scientific,
    Semicolon,
    StringContent,
    SingleQuoteStringStart,
    DoubleQuoteStringStart,
    BacktickStringStart,
    StringEnd,
    TemplateStart,
    TemplateEnd,
    True,
    UnderscoreIdentifier,
    UppercaseIdentifier,
    Whitespace,
    WhitespaceWithNewline,
};

pub const Token = struct {
    tokenType: TokenType,
    lexeme: []const u8,
    region: Region,

    pub fn new(tokenType: TokenType, lexeme: []const u8, region: Region) Token {
        return Token{ .tokenType = tokenType, .lexeme = lexeme, .region = region };
    }

    pub fn isEql(self: Token, other: Token) bool {
        return self.tokenType == other.tokenType and
            std.mem.eql(u8, self.lexeme, other.lexeme) and
            self.region.start == other.region.start and
            self.region.end == other.region.end;
    }

    pub fn isType(self: Token, tokenType: TokenType) bool {
        return self.tokenType == tokenType;
    }

    pub fn isBacktickString(self: Token) bool {
        return self.isType(.String) and self.lexeme.len > 0 and self.lexeme[0] == '`';
    }

    pub fn print(self: Token, writer: anytype) !void {
        try writer.print("{s} '{s}' {d}-{d}", .{
            @tagName(self.tokenType),
            self.lexeme,
            self.region.start,
            self.region.end,
        });
    }
};

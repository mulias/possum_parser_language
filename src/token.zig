const std = @import("std");
const Location = @import("location.zig").Location;
const VMWriter = @import("writer.zig").VMWriter;

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
    String,
    True,
    UnderscoreIdentifier,
    UppercaseIdentifier,
    Whitespace,
    WhitespaceWithNewline,
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

    pub fn isBacktickString(self: Token) bool {
        return self.isType(.String) and self.lexeme.len > 0 and self.lexeme[0] == '`';
    }

    pub fn print(self: Token, writer: VMWriter) !void {
        try writer.print("{s} '{s}' {d}:{d}-{d}", .{
            @tagName(self.tokenType),
            self.lexeme,
            self.loc.line,
            self.loc.start,
            self.loc.start + self.loc.length,
        });
    }
};

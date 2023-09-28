const std = @import("std");
const logger = @import("./logger.zig");
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;

pub const Scanner = struct {
    source: []const u8,
    offset: usize,
    line: usize,
    pos: usize,
    atEnd: bool,

    pub fn init(source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .offset = 0,
            .line = 1,
            .pos = 0,
            .atEnd = false,
        };
    }

    pub fn next(self: *Scanner) ?Token {
        if (self.atEnd) return null;
        const token = self.scanToken();
        if (logger.debugScanner) logger.debug("Scanned token: {}\n", .{token});
        if (token.tokenType == .Eof) self.atEnd = true;
        return token;
    }

    fn scanToken(self: *Scanner) Token {
        self.commit();

        if (self.whitespace()) |whitespaceToken| return whitespaceToken;

        if (self.isAtEnd()) return self.makeToken(.Eof);

        return switch (self.take()) {
            0 => self.makeToken(.Eof),
            '(' => self.makeToken(.LeftParen),
            ')' => self.makeToken(.RightParen),
            '{' => self.makeToken(.LeftBrace),
            '}' => self.makeToken(.RightBrace),
            '[' => self.makeToken(.LeftBracket),
            ']' => self.makeToken(.RightBracket),
            ',' => self.makeToken(.Comma),
            '.' => self.makeToken(.Dot),
            '+' => self.makeToken(.Plus),
            ';' => self.makeToken(.Semicolon),
            '!' => self.makeToken(.Bang),
            '$' => self.makeToken(.DollarSign),
            '&' => self.makeToken(.Ampersand),
            '?' => self.makeToken(.QuestionMark),
            '=' => self.makeToken(.Equal),
            '<' => self.makeToken(if (self.match('-')) TokenType.LessThanDash else TokenType.LessThan),
            '>' => self.makeToken(.GreaterThan),
            '|' => self.makeToken(.Bar),
            '"' => self.scanString(),
            else => |c| {
                if (isDigit(c) or c == '-') return self.scanNumber();
                if (isLower(c)) return self.scanLowercaseIdentifier();
                if (isUpper(c)) return self.scanUppercaseIdentifier();
                return self.makeError("Unexpected character.");
            },
        };
    }

    fn commit(self: *Scanner) void {
        self.source = self.source[self.offset..];
        self.offset = 0;
    }

    fn advance(self: *Scanner) void {
        self.offset += 1;
        self.pos += 1;
    }

    fn take(self: *Scanner) u8 {
        const c = self.peek();
        self.advance();
        return c;
    }

    fn peek(self: *Scanner) u8 {
        if (self.isAtEnd()) return 0;
        return self.source[self.offset];
    }

    fn peekNext(self: *Scanner) u8 {
        if (self.offset + 1 >= self.source.len) return 0;
        return self.source[self.offset + 1];
    }

    fn peekN(self: *Scanner, count: usize) u8 {
        if (self.offset + count >= self.source.len) return 0;
        return self.source[self.offset + count];
    }

    fn match(self: *Scanner, char: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.peek() != char) return false;

        self.advance();

        return true;
    }

    fn isAtEnd(self: *Scanner) bool {
        return self.offset >= self.source.len;
    }

    fn makeToken(self: *Scanner, tokenType: TokenType) Token {
        return Token{
            .tokenType = tokenType,
            .lexeme = self.source[0..self.offset],
            .line = self.line,
            .start = self.pos - self.offset,
        };
    }

    fn makeError(self: *Scanner, message: []const u8) Token {
        return Token{
            .tokenType = .Error,
            .lexeme = message,
            .line = self.line,
            .start = self.pos - self.offset,
        };
    }

    fn scanString(self: *Scanner) Token {
        // if we've already consumed input then assume it was string
        const start = self.pos - self.offset;
        const startLine = self.line;

        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\\' and self.peekNext() == '"') self.advance();
            if (self.peek() == '\n' and self.peekNext() == '\r') self.advance();
            if (self.peek() == '\n') self.line += 1;
            self.advance();
        }

        if (self.isAtEnd()) return self.makeError("Unterminated string.");

        // The closing quote
        self.advance();

        return Token{
            .tokenType = .String,
            .lexeme = self.source[0..self.offset],
            .line = startLine,
            .start = start,
        };
    }

    fn scanNumber(self: *Scanner) Token {
        // Consume negative sign
        if (self.peek() == '-') self.advance();

        // Integer part
        while (isDigit(self.peek())) self.advance();

        // Look for a fractional/scientific part
        if (self.scanDecimalPart() or self.scanScientificPart()) {
            return self.makeToken(.Float);
        }

        return self.makeToken(.Integer);
    }

    fn scanDecimalPart(self: *Scanner) bool {
        if (self.peek() == '.' and isDigit(self.peekNext())) {
            // Consume the "."
            self.advance();

            while (isDigit(self.peek())) self.advance();

            return true;
        } else {
            return false;
        }
    }

    fn scanScientificPart(self: *Scanner) bool {
        if (self.peek() == 'e' or self.peek() == 'E') {
            if ((self.peekNext() == '-' or self.peekNext() == '+') and isDigit(self.peekN(3))) {
                // Consume the "e"/"E" and "-"/"+"
                self.advance();
                self.advance();
                // Exponent part
                while (isDigit(self.peek())) self.advance();
                return true;
            } else if (isDigit(self.peekNext())) {
                // Consume the "e"/"E"
                self.advance();
                // Exponent part
                while (isDigit(self.peek())) self.advance();
                return true;
            } else {
                // had an 'e'/'E' but no exponent part
                return false;
            }
        } else {
            return false;
        }
    }

    fn scanLowercaseIdentifier(self: *Scanner) Token {
        while (isLower(self.peek()) or isDigit(self.peek()) or self.peek() == '_') self.advance();

        return self.makeToken(self.lowercaseIdentifierType());
    }

    fn lowercaseIdentifierType(self: *Scanner) TokenType {
        if (self.checkKeyword("true")) {
            return .True;
        } else if (self.checkKeyword("false")) {
            return .False;
        } else if (self.checkKeyword("null")) {
            return .Null;
        } else {
            return .LowercaseIdentifier;
        }
    }

    fn scanUppercaseIdentifier(self: *Scanner) Token {
        while (isAlpha(self.peek()) or isDigit(self.peek())) self.advance();

        return self.makeToken(.UppercaseIdentifier);
    }

    fn checkKeyword(self: *Scanner, str: []const u8) bool {
        const sourceSlice = self.source[0..self.offset];
        return self.offset == str.len and std.mem.eql(u8, sourceSlice, str);
    }

    fn whitespace(self: *Scanner) ?Token {
        // if we've already consumed input then assume it was whitespace
        const start = self.pos - self.offset;
        const startLine = self.line;

        while (true) {
            switch (self.peek()) {
                ' ', '\r', '\t' => {
                    self.advance();
                },
                '\n' => {
                    self.advance();
                    self.line += 1;
                    self.pos = 0; // reset pos after newline is consumed
                },
                '#' => {
                    // A comment goes until the end of the line
                    while (self.peek() != '\n' and !self.isAtEnd()) {
                        self.advance();
                    }
                },
                else => break,
            }
        }

        if (startLine < self.line) {
            return Token{
                .tokenType = .WhitespaceWithNewline,
                .lexeme = self.source[0..self.offset],
                .line = startLine,
                .start = start,
            };
        } else if (start < self.pos) {
            return Token{
                .tokenType = .Whitespace,
                .lexeme = self.source[0..self.offset],
                .line = startLine,
                .start = start,
            };
        } else {
            return null;
        }
    }
};

fn isDigit(char: u8) bool {
    return '0' <= char and char <= '9';
}

fn isLower(char: u8) bool {
    return 'a' <= char and char <= 'z';
}

fn isUpper(char: u8) bool {
    return 'A' <= char and char <= 'Z';
}

fn isAlpha(char: u8) bool {
    return isLower(char) or isUpper(char);
}

test {
    var scanner = Scanner.init(" 123  |\n  456.10 ");
    try expectToken(&scanner, .{ .tokenType = .Whitespace, .lexeme = " ", .line = 1, .start = 0 });
    try expectToken(&scanner, .{ .tokenType = .Integer, .lexeme = "123", .line = 1, .start = 1 });
    try expectToken(&scanner, .{ .tokenType = .Whitespace, .lexeme = "  ", .line = 1, .start = 4 });
    try expectToken(&scanner, .{ .tokenType = .Bar, .lexeme = "|", .line = 1, .start = 6 });
    try expectToken(&scanner, .{ .tokenType = .WhitespaceWithNewline, .lexeme = "\n  ", .line = 1, .start = 7 });
    try expectToken(&scanner, .{ .tokenType = .Float, .lexeme = "456.10", .line = 2, .start = 2 });
    try expectToken(&scanner, .{ .tokenType = .Whitespace, .lexeme = " ", .line = 2, .start = 8 });
    try expectToken(&scanner, .{ .tokenType = .Eof, .lexeme = "", .line = 2, .start = 9 });
}

fn expectToken(scanner: *Scanner, expected: Token) !void {
    try std.testing.expect(scanner.next().?.isEql(expected));
}

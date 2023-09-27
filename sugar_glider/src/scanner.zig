const std = @import("std");
const logger = @import("./logger.zig");
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;

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

pub const Scanner = struct {
    start: []const u8,
    current: usize,
    line: usize,
    pos: usize,
    atEnd: bool,

    pub fn init(source: []const u8) Scanner {
        return Scanner{
            .start = source,
            .current = 0,
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
        self.skipWhitespace();

        self.start = self.start[self.current..];
        self.current = 0;

        const start = self.pos;

        if (self.isAtEnd()) return self.makeToken(.Eof, start);

        const c = self.peek();
        self.advance();

        return switch (c) {
            '(' => self.makeToken(.LeftParen, start),
            ')' => self.makeToken(.RightParen, start),
            '{' => self.makeToken(.LeftBrace, start),
            '}' => self.makeToken(.RightBrace, start),
            '[' => self.makeToken(.LeftBracket, start),
            ']' => self.makeToken(.RightBracket, start),
            ',' => self.makeToken(.Comma, start),
            '.' => self.makeToken(.Dot, start),
            '+' => self.makeToken(.Plus, start),
            ';' => self.makeToken(.Semicolon, start),
            '!' => self.makeToken(.Bang, start),
            '$' => self.makeToken(.DollarSign, start),
            '&' => self.makeToken(.Ampersand, start),
            '?' => self.makeToken(.QuestionMark, start),
            '=' => self.makeToken(.Equal, start),
            '<' => self.makeToken(if (self.match('-')) TokenType.LessThanDash else TokenType.LessThan, start),
            '>' => self.makeToken(.GreaterThan, start),
            '|' => self.makeToken(.Bar, start),
            '"' => self.scanString(start),
            else => {
                if (isDigit(c) or c == '-') return self.scanNumber(start);
                if (isLower(c)) return self.scanLowercaseIdentifier(start);
                if (isUpper(c)) return self.scanUppercaseIdentifier(start);
                if (c == 0) return self.makeToken(.Eof, start);
                return self.makeError("Unexpected character.", start);
            },
        };
    }

    fn advance(self: *Scanner) void {
        self.current += 1;
        self.pos += 1;
    }

    fn peek(self: *Scanner) u8 {
        if (self.isAtEnd()) return 0;
        return self.start[self.current];
    }

    fn peekNext(self: *Scanner) u8 {
        if (self.current + 1 >= self.start.len) return 0;
        return self.start[self.current + 1];
    }

    fn peekN(self: *Scanner, count: usize) u8 {
        if (self.current + count >= self.start.len) return 0;
        return self.start[self.current + count];
    }

    fn match(self: *Scanner, char: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.peek() != char) return false;

        self.advance();

        return true;
    }

    fn isAtEnd(self: *Scanner) bool {
        return self.current >= self.start.len;
    }

    fn makeToken(self: *Scanner, tokenType: TokenType, start: usize) Token {
        return Token{
            .tokenType = tokenType,
            .lexeme = self.start[0..self.current],
            .line = self.line,
            .start = start,
        };
    }

    fn makeError(self: *Scanner, message: []const u8, start: usize) Token {
        return Token{
            .tokenType = .Error,
            .lexeme = message,
            .line = self.line,
            .start = start,
        };
    }

    fn scanString(self: *Scanner, start: usize) Token {
        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\\' and self.peekNext() == '"') self.advance();
            if (self.peek() == '\n' and self.peekNext() == '\r') self.advance();
            if (self.peek() == '\n') self.line += 1;
            self.advance();
        }

        if (self.isAtEnd()) return self.makeError("Unterminated string.", start);

        // The closing quote
        self.advance();
        return self.makeToken(.String, start);
    }

    fn scanNumber(self: *Scanner, start: usize) Token {
        // Consume negative sign
        if (self.peek() == '-') self.advance();

        // Integer part
        while (isDigit(self.peek())) self.advance();

        // Look for a fractional/scientific part
        if (self.scanDecimalPart() or self.scanScientificPart()) {
            return self.makeToken(.Float, start);
        }

        return self.makeToken(.Integer, start);
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

    fn scanLowercaseIdentifier(self: *Scanner, start: usize) Token {
        while (isLower(self.peek()) or isDigit(self.peek()) or self.peek() == '_') self.advance();

        return self.makeToken(self.lowercaseIdentifierType(), start);
    }

    fn lowercaseIdentifierType(self: *Scanner) TokenType {
        if (self.checkKeyword("true")) {
            return .True;
        } else if (self.checkKeyword("false")) {
            return .False;
        } else if (self.checkKeyword("nil")) {
            return .Nil;
        } else {
            return .LowercaseIdentifier;
        }
    }

    fn scanUppercaseIdentifier(self: *Scanner, start: usize) Token {
        while (isAlpha(self.peek()) or isDigit(self.peek())) self.advance();

        return self.makeToken(.UppercaseIdentifier, start);
    }

    fn checkKeyword(self: *Scanner, str: []const u8) bool {
        const sourceSlice = self.start[0..self.current];
        return self.current == str.len and std.mem.eql(u8, sourceSlice, str);
    }

    fn skipWhitespace(self: *Scanner) void {
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
                else => return,
            }
        }
    }
};

test {
    var scanner = Scanner.init(" 123  |  456.10 ");
    try expectToken(&scanner, .{ .tokenType = .Integer, .lexeme = "123", .line = 1, .start = 1 });
    try expectToken(&scanner, .{ .tokenType = .Bar, .lexeme = "|", .line = 1, .start = 6 });
    try expectToken(&scanner, .{ .tokenType = .Float, .lexeme = "456.10", .line = 1, .start = 9 });
    try expectToken(&scanner, .{ .tokenType = .Eof, .lexeme = "", .line = 1, .start = 16 });
}

fn expectToken(scanner: *Scanner, expected: Token) !void {
    try std.testing.expect(scanner.next().?.isEql(expected));
}

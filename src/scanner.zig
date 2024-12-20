const std = @import("std");
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const Writers = @import("writer.zig").Writers;

pub const Scanner = struct {
    source: []const u8,
    offset: usize,
    line: usize,
    pos: usize,
    atEnd: bool,
    writers: Writers,
    printDebug: bool,

    pub fn init(source: []const u8, writers: Writers, printDebug: bool) Scanner {
        return Scanner{
            .source = source,
            .offset = 0,
            .line = 1,
            .pos = 0,
            .atEnd = false,
            .writers = writers,
            .printDebug = printDebug,
        };
    }

    pub fn initInternal(source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .offset = 0,
            .line = 1,
            .pos = 0,
            .atEnd = false,
            .writers = undefined,
            .printDebug = false,
        };
    }

    pub fn next(self: *Scanner) ?Token {
        if (self.atEnd) return null;
        const token = self.scanToken();
        if (self.printDebug) {
            self.writers.debugPrint("Scanned token: ", .{});
            token.print(self.writers.debug) catch {};
            self.writers.debugPrint("\n", .{});
        }
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
            '.' => if (self.match('.'))
                if (self.match('.')) self.makeToken(.DotDotDot) else self.makeToken(.DotDot)
            else
                return self.makeError("Unexpected character."),
            '+' => self.makeToken(.Plus),
            ';' => self.makeToken(.Semicolon),
            '!' => self.makeToken(.Bang),
            '$' => self.makeToken(.DollarSign),
            '&' => self.makeToken(.Ampersand),
            '?' => self.makeToken(.QuestionMark),
            ':' => self.makeToken(.Colon),
            '=' => self.makeToken(.Equal),
            '<' => self.makeToken(.LessThan),
            '>' => self.makeToken(.GreaterThan),
            '|' => self.makeToken(.Bar),
            '"' => self.scanString('"'),
            '\'' => self.scanString('\''),
            '`' => self.scanBacktickString(),
            '@' => self.scanAtSignIdentifier(),
            '_' => self.scanUnderscoreIdentifier(),
            '-' => if (self.match('>'))
                self.makeToken(.DashGreaterThan)
            else
                self.makeToken(.Minus),
            else => |c| {
                if (isDigit(c)) return self.scanNumber();
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

    pub fn isAtEnd(self: *Scanner) bool {
        return self.offset >= self.source.len;
    }

    fn makeToken(self: *Scanner, tokenType: TokenType) Token {
        return Token.new(tokenType, self.source[0..self.offset], .{
            .start = self.pos - self.offset,
            .end = self.pos,
        });
    }

    fn makeError(self: *Scanner, message: []const u8) Token {
        return Token.new(.Error, message, .{
            .start = self.pos - self.offset,
            .end = self.pos,
        });
    }

    fn scanString(self: *Scanner, mark: u8) Token {
        // if we've already consumed input then assume it was string
        const start = self.pos - self.offset;

        var p = self.peek();
        var templateParenDepth: u64 = 0;

        while ((p != mark or templateParenDepth > 0) and !self.isAtEnd()) {
            switch (p) {
                '\\' => {
                    // Assume next char is an sequences, validate in the compiler.
                    self.advance();
                    self.advance();
                },
                '\n' => {
                    self.advance();
                    self.line += 1;
                },
                '(' => {
                    self.advance();
                    if (templateParenDepth > 0) templateParenDepth += 1;
                },
                ')' => {
                    self.advance();
                    if (templateParenDepth > 0) templateParenDepth -= 1;
                },
                '%' => if (self.peekNext() == '(' and templateParenDepth == 0) {
                    self.advance();
                    self.advance();
                    templateParenDepth = 1;
                } else {
                    self.advance();
                },
                '"' => {
                    self.advance();
                    if (templateParenDepth > 0) _ = self.scanString('"');
                },
                '\'' => {
                    self.advance();
                    if (templateParenDepth > 0) _ = self.scanString('\'');
                },
                else => {
                    self.advance();
                },
            }

            p = self.peek();
        }

        if (self.isAtEnd()) return self.makeError("Unterminated string.");

        // The closing quote
        self.advance();

        return Token.new(.String, self.source[0..self.offset], .{
            .start = start,
            .end = start + self.offset,
        });
    }

    fn scanBacktickString(self: *Scanner) Token {
        // if we've already consumed input then assume it was string
        const start = self.pos - self.offset;

        while (self.peek() != '`' and !self.isAtEnd()) {
            if (self.peek() == '\n') self.line += 1;

            self.advance();
        }

        if (self.isAtEnd()) return self.makeError("Unterminated string.");

        // The closing quote
        self.advance();

        return Token.new(.String, self.source[0..self.offset], .{
            .start = start,
            .end = start + self.offset,
        });
    }

    pub fn scanNumber(self: *Scanner) Token {
        // Consume negative sign
        if (self.offset == 0 and self.peek() == '-') self.advance();

        // Integer part
        while (isDigit(self.peek())) self.advance();

        // Look for a fractional/scientific part
        const hasDecimalPart = self.scanDecimalPart();
        const hasScientificPart = self.scanScientificPart();

        if (self.tokenHasExtraLeadingZero()) {
            return self.makeError("Invalid number.");
        } else if (hasScientificPart) {
            return self.makeToken(.Scientific);
        } else if (hasDecimalPart) {
            return self.makeToken(.Float);
        } else {
            return self.makeToken(.Integer);
        }
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
            if ((self.peekNext() == '-' or self.peekNext() == '+') and isDigit(self.peekN(2))) {
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

    fn tokenHasExtraLeadingZero(self: *Scanner) bool {
        const lexeme = self.source[0..self.offset];
        const number = if (lexeme[0] == '-') lexeme[1..] else lexeme;
        return number.len >= 2 and number[0] == '0' and isDigit(number[1]);
    }

    fn scanLowercaseIdentifier(self: *Scanner) Token {
        var c = self.peek();
        while (isAlpha(c) or isDigit(c) or c == '_' or (c == '.' and self.peekNext() != '.')) {
            self.advance();
            c = self.peek();
        }

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
        var c = self.peek();
        while (isAlpha(c) or isDigit(c) or c == '_' or (c == '.' and self.peekNext() != '.')) {
            self.advance();
            c = self.peek();
        }

        return self.makeToken(.UppercaseIdentifier);
    }

    fn scanAtSignIdentifier(self: *Scanner) Token {
        if (isLower(self.peek())) {
            return self.scanLowercaseIdentifier();
        } else {
            return self.scanUppercaseIdentifier();
        }
    }

    fn scanUnderscoreIdentifier(self: *Scanner) Token {
        while (self.peek() == '_') self.advance();

        if (isLower(self.peek())) {
            return self.scanLowercaseIdentifier();
        } else if (isUpper(self.peek())) {
            return self.scanUppercaseIdentifier();
        } else {
            return self.makeToken(.UnderscoreIdentifier);
        }
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
            return Token.new(.WhitespaceWithNewline, self.source[0..self.offset], .{
                .start = start,
                .end = start + self.offset,
            });
        } else if (start < self.pos) {
            return Token.new(.Whitespace, self.source[0..self.offset], .{
                .start = start,
                .end = start + self.offset,
            });
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

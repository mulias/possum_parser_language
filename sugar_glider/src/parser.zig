const std = @import("std");
const Scanner = @import("scanner.zig").Scanner;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const logger = @import("./logger.zig");
const Value = @import("./value.zig").Value;

pub const Parser = struct {
    scanner: *Scanner,
    chunk: *Chunk,
    current: Token,
    previous: Token,
    hadError: bool,
    panicMode: bool,

    pub fn init(scanner: *Scanner, chunk: *Chunk) Parser {
        return Parser{
            .scanner = scanner,
            .chunk = chunk,
            .current = undefined,
            .previous = undefined,
            .hadError = false,
            .panicMode = false,
        };
    }

    pub fn advance(self: *Parser) void {
        self.previous = self.current;
    }
};

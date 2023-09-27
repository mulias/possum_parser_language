const std = @import("std");
const Scanner = @import("./scanner.zig").Scanner;
const Parser = @import("./parser.zig").Parser;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const logger = @import("./logger.zig");
const Chunk = @import("./chunk.zig").Chunk;

pub fn compile(source: []const u8, chunk: *Chunk) !bool {
    var scanner = Scanner.init(source);
    var parser = Parser.init(&scanner, chunk);

    parser.advance();

    return !parser.hadError;
}

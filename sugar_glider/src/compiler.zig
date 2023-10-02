const std = @import("std");
const Scanner = @import("./scanner.zig").Scanner;
const Parser = @import("./parser.zig").Parser;
const Chunk = @import("./chunk.zig").Chunk;

pub fn compile(source: []const u8, chunk: *Chunk) !bool {
    var scanner = Scanner.init(source);
    var parser = Parser.init(&scanner, chunk);

    try parser.program();

    return !parser.hadError;
}

const std = @import("std");
const Scanner = @import("./scanner.zig").Scanner;
const Parser = @import("./parser.zig").Parser;
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;

pub fn compile(vm: *VM, source: []const u8) !void {
    var parser = Parser.init(vm, source);

    try parser.program();

    if (parser.hadError) return error.CompileError;
}

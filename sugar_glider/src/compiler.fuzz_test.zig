const std = @import("std");
const testing = @import("testing.zig");
const ProgramGenerator = @import("program_generator.zig").ProgramGenerator;
const Chunk = @import("chunk.zig").Chunk;
const compiler = @import("compiler.zig");

test "Compiler can gracefully handle arbitrary programs" {
    var alloc = std.testing.allocator;

    var programs = ProgramGenerator.init(alloc, @as(u64, @intCast(std.time.timestamp())));
    defer programs.deinit();

    for (0..100) |_| {
        const source = programs.random();
        std.debug.print("\n{s}\n", .{source});
        var chunk = Chunk.init(alloc);
        const success = try compiler.compile(source, &chunk);
        try std.testing.expect(success);
        chunk.deinit();
    }
}

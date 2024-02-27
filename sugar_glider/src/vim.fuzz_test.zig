const std = @import("std");
const testing = @import("testing.zig");
const ProgramGenerator = @import("program_generator.zig").ProgramGenerator;
const Chunk = @import("chunk.zig").Chunk;
const compiler = @import("compiler.zig");

test "Compiler can gracefully handle arbitrary programs" {
    var alloc = std.testing.allocator;

    var parser = ProgramGenerator.init(alloc, @as(u64, @intCast(std.time.timestamp())));
    defer parser.deinit();

    for (0..100) |_| {
        const source = parser.random();
        std.debug.print("\n{s}\n", .{source});

        var chunk = Chunk.init(alloc);
        defer chunk.deinit();

        const success = try compiler.compile(source, &chunk);
        try std.testing.expect(success);
    }
}

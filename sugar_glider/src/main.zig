const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const VM = @import("vm.zig").VM;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var vm = VM.init(alloc);
    defer vm.deinit();

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    try chunk.writeConst(.{ .String = "test" }, 1);
    try chunk.writeOp(.End, 2);

    _ = try vm.interpret(&chunk, "test");
}

test {
    @import("std").testing.refAllDecls(@This());
}

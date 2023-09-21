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

    var str = try chunk.addConstant(.{ .String = "test" });

    try chunk.writeOp(.String, 1);
    try chunk.write(str, 1);
    try chunk.writeOp(.Return, 2);

    _ = try vm.interpret(&chunk, "test");
}

test {
    @import("std").testing.refAllDecls(@This());
}

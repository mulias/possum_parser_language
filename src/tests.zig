comptime {
    _ = @import("frontend/scanner.test.zig");
    _ = @import("runtime/vm.test.zig");
    _ = @import("runtime/vm.zig");
    _ = @import("string_buffer.test.zig");
    _ = @import("string_table.zig");
    _ = @import("runtime/elem.zig");
    _ = @import("backend/ir.zig");
    _ = @import("backend/liveness.zig");
    _ = @import("highlight.test.zig");
    _ = @import("frontend.test.zig");
}

const std = @import("std");
const Writer = std.Io.Writer;

pub const Writers = struct {
    out: *Writer,
    err: *Writer,
    debug: *Writer,

    pub fn debugPrint(self: Writers, comptime format: []const u8, args: anytype) void {
        self.debug.print(format, args) catch {};
    }
};

// A std.Io.Writer that forwards every write to an external (host-provided)
// sink function. Used by the wasm build to route output through imported
// JS functions.
pub const ExternalWriter = struct {
    pub const WriteFnType = *const fn (bytes: []const u8) void;

    writeFn: WriteFnType,
    interface: Writer,

    pub fn init(writeFn: WriteFnType, buffer: []u8) ExternalWriter {
        return ExternalWriter{
            .writeFn = writeFn,
            .interface = .{ .vtable = &.{ .drain = drain }, .buffer = buffer },
        };
    }

    fn drain(w: *Writer, data: []const []const u8, splat: usize) Writer.Error!usize {
        const self: *ExternalWriter = @fieldParentPtr("interface", w);

        const buffered = w.buffered();
        if (buffered.len > 0) {
            self.writeFn(buffered);
            w.end = 0;
        }

        const slice = data[0 .. data.len - 1];
        const pattern = data[slice.len];
        var written: usize = 0;
        for (slice) |bytes| {
            self.writeFn(bytes);
            written += bytes.len;
        }
        for (0..splat) |_| {
            self.writeFn(pattern);
            written += pattern.len;
        }
        return written;
    }
};

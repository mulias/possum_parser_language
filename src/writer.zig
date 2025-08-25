const std = @import("std");
const File = std.fs.File;
const Writer = std.Io.Writer;
const env = @import("env.zig");

pub const Writers = struct {
    out: *Writer,
    err: *Writer,
    debug: *Writer,

    pub fn debugPrint(self: Writers, comptime format: []const u8, args: anytype) void {
        self.debug.print(format, args) catch {};
    }
};

pub const ExternalWriter = struct {
    pub const WriteFnType = *const fn (bytes: []const u8) void;

    writeFn: WriteFnType,

    pub fn init(writeFn: WriteFnType) ExternalWriter {
        return ExternalWriter{ .writeFn = writeFn };
    }

    pub const WriteError = error{};

    pub fn write(self: ExternalWriter, bytes: []const u8) WriteError!usize {
        self.writeFn(bytes);
        return bytes.len;
    }

    pub fn deprecatedWriter(self: ExternalWriter) std.io.GenericWriter(ExternalWriter, WriteError, write) {
        return .{ .context = self };
    }
};

const std = @import("std");
const File = std.fs.File;
const AnyWriter = std.io.AnyWriter;
const env = @import("env.zig");

pub const Writers = struct {
    out: AnyWriter,
    err: AnyWriter,
    debug: AnyWriter,

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

    pub const Writer = std.io.Writer(ExternalWriter, WriteError, write);
    pub fn writer(self: ExternalWriter) Writer {
        return .{ .context = self };
    }
};

const std = @import("std");
const File = std.fs.File;
const env = @import("env.zig");

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

// Helper for generic writer error types
pub fn WriterError(comptime Writer: type) type {
    return Writer.Error;
}

// Union type for different writer implementations
pub const AnyWriter = union(enum) {
    file: std.fs.File.Writer,
    external: ExternalWriter.Writer,

    const WriterImpl = struct {
        context: *const AnyWriter,

        pub fn write(self: @This(), bytes: []const u8) Error!usize {
            return self.context.writeImpl(bytes);
        }
    };

    fn writeImpl(self: *const AnyWriter, bytes: []const u8) Error!usize {
        return switch (self.*) {
            .file => |w| w.write(bytes),
            .external => |w| w.write(bytes),
        };
    }

    pub fn writer(self: *const AnyWriter) std.io.Writer(*const AnyWriter, Error, writeImpl) {
        return .{ .context = self };
    }

    pub fn write(self: *const AnyWriter, bytes: []const u8) Error!usize {
        return self.writeImpl(bytes);
    }

    pub fn print(self: *const AnyWriter, comptime format: []const u8, args: anytype) Error!void {
        return std.fmt.format(self.writer(), format, args);
    }

    pub fn writeAll(self: *const AnyWriter, bytes: []const u8) Error!void {
        return self.writer().writeAll(bytes);
    }

    pub fn writeByte(self: *const AnyWriter, byte: u8) Error!void {
        return self.writer().writeByte(byte);
    }

    pub fn writeBytesNTimes(self: *const AnyWriter, bytes: []const u8, n: usize) Error!void {
        return self.writer().writeBytesNTimes(bytes, n);
    }

    pub fn writeByteNTimes(self: *const AnyWriter, byte: u8, n: usize) Error!void {
        return self.writer().writeByteNTimes(byte, n);
    }

    pub const Error = std.fs.File.Writer.Error || ExternalWriter.WriteError;
};

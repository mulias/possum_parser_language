const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const StringTable = @import("string_table.zig").StringTable;
const logger = @import("./logger.zig");

pub const OpCode = enum(u8) {
    Backtrack,
    CallFunctionParser,
    GetConstant,
    Destructure,
    End,
    False,
    GetGlobal,
    Jump,
    JumpIfFailure,
    JumpIfSuccess,
    MergeElems,
    MergeParsed,
    Null,
    Or,
    Return,
    RunParser,
    SetGlobal,
    SubstituteValue,
    TakeLeft,
    TakeRight,
    True,

    pub fn disassemble(self: OpCode, chunk: *Chunk, strings: StringTable, offset: usize) usize {
        switch (self) {
            .Backtrack,
            .Destructure,
            .End,
            .False,
            .MergeElems,
            .MergeParsed,
            .Null,
            .Or,
            .Return,
            .RunParser,
            .SubstituteValue,
            .TakeLeft,
            .TakeRight,
            .True,
            => {
                logger.debug("{s}\n", .{@tagName(self)});
                return offset + 1;
            },
            .GetConstant,
            .GetGlobal,
            .SetGlobal,
            => {
                var constantIdx = chunk.read(offset + 1);
                var constantElem = chunk.getConstant(constantIdx);
                logger.debug("{s} {}: ", .{ @tagName(self), constantIdx });
                constantElem.print(logger.debug, strings);
                logger.debug("\n", .{});
                return offset + 2;
            },
            .CallFunctionParser => {
                const argCount = chunk.read(offset + 1);
                logger.debug("{s} {d}\n", .{ @tagName(self), argCount });
                return offset + 2;
            },
            .Jump,
            .JumpIfFailure,
            .JumpIfSuccess,
            => {
                var jump = @as(u16, @intCast(chunk.read(offset + 1))) << 8;
                jump |= chunk.read(offset + 2);
                const target = @as(isize, @intCast(offset)) + 3 + jump;
                std.debug.print("{s} {} -> {}\n", .{ @tagName(self), offset, target });
                return offset + 3;
            },
        }
    }
};

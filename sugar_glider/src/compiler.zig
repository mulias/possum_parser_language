const std = @import("std");
const ArrayList = std.ArrayList;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("./chunk.zig").Chunk;
const ChunkError = @import("./chunk.zig").ChunkError;
const Elem = @import("./elem.zig").Elem;
const Location = @import("location.zig").Location;
const OpCode = @import("./chunk.zig").OpCode;
const Parser = @import("./parser.zig").Parser;
const Scanner = @import("./scanner.zig").Scanner;
const VM = @import("./vm.zig").VM;
const logger = @import("./logger.zig");

const CompileError = error{
    InvalidAst,
    ChunkWriteFailure,
};

pub const Compiler = struct {
    vm: *VM,
    ast: Ast,

    pub fn init(vm: *VM) Compiler {
        return Compiler{
            .vm = vm,
            .ast = undefined,
        };
    }

    pub fn deinit(self: *Compiler) void {
        _ = self;
    }

    pub fn compile(self: *Compiler, source: []const u8) !void {
        var parser = Parser.init(self.vm, source);
        defer parser.deinit();

        const rootNodeId = try parser.program();

        self.ast = parser.ast;

        try self.writeParser(rootNodeId);
        try self.emitOp(.End, self.ast.endLocation);

        if (logger.debugCompiler) {
            self.currentChunk().disassemble(self.vm.strings, "code");
        }

        self.ast = undefined;
    }

    fn writeParser(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .OpNode => |op| switch (op.opType) {
                .Backtrack => {
                    try self.writeParser(op.left);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.emitOp(.Backtrack, loc);
                    try self.writeParser(op.right);
                    try self.patchJump(jumpIndex, loc);
                },
                .Merge,
                .Sequence,
                .TakeLeft,
                .TakeRight,
                => {
                    try self.writeParser(op.left);
                    const jumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(op.right);
                    try self.writeParserOp(op.opType, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .Destructure => {
                    try self.writePattern(op.left);
                    try self.writeParser(op.right);
                    try self.writeParserOp(op.opType, loc);
                },
                .Or => {
                    try self.writeParser(op.left);
                    const jumpIndex = try self.emitJump(.JumpIfSuccess, loc);
                    try self.writeParser(op.right);
                    try self.writeParserOp(op.opType, loc);
                    try self.patchJump(jumpIndex, loc);
                },
                .Return => {
                    try self.writeParser(op.left);
                    try self.writeValue(op.right);
                    try self.writeParserOp(op.opType, loc);
                },
                .ConditionalIfThen => {
                    // Then/Else is always the right-side node
                    const thenElseOp = self.ast.getConditionalThenElseOp(op.right);
                    const thenElseLoc = self.ast.getLocation(op.right);

                    // Get each part of `ifNodeId ? thenNodeId : elseNodeId`
                    const ifNodeId = op.left;
                    const thenNodeId = thenElseOp.left;
                    const elseNodeId = thenElseOp.right;

                    try self.writeParser(ifNodeId);
                    const failureJumpIndex = try self.emitJump(.JumpIfFailure, loc);
                    try self.writeParser(thenNodeId);
                    try self.emitOp(.TakeRight, self.ast.getLocation(thenNodeId));
                    const successJumpIndex = try self.emitJump(.JumpIfSuccess, thenElseLoc);
                    try self.patchJump(failureJumpIndex, loc);
                    try self.writeParser(elseNodeId);
                    try self.emitOp(.Or, self.ast.getLocation(elseNodeId));
                    try self.patchJump(successJumpIndex, thenElseLoc);
                },
                .ConditionalThenElse => unreachable, // always handled via ConditionalIfThen
            },
            .ElemNode => |elem| try self.writeParserElem(elem, loc),
        }
    }

    fn writeParserOp(self: *Compiler, opType: Ast.OpType, loc: Location) !void {
        const opCode: OpCode = switch (opType) {
            .Backtrack => .Backtrack,
            .Destructure => .Destructure,
            .Merge => .MergeParsed,
            .Or => .Or,
            .Return => .Return,
            .Sequence => .Sequence,
            .TakeLeft => .TakeLeft,
            .TakeRight => .TakeRight,
            .ConditionalIfThen,
            .ConditionalThenElse,
            => unreachable, // No eqivalent OpCode
        };

        try self.emitOp(opCode, loc);
    }

    fn writeParserElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .String,
            .IntegerString,
            .FloatString,
            .CharacterRange,
            .IntegerRange,
            => try self.emitRunLiteralParser(elem, loc),
            .True => {
                // In this context `true` could be a zero-arg function call
                const sId = try self.vm.addString("true");
                try self.emitRunFunctionParser(Elem.string(sId), loc);
            },
            .False => {
                // In this context `false` could be a zero-arg function call
                const sId = try self.vm.addString("false");
                try self.emitRunFunctionParser(Elem.string(sId), loc);
            },
            .Null => {
                // In this context `null` could be a zero-arg function call
                const sId = try self.vm.addString("null");
                try self.emitRunFunctionParser(Elem.string(sId), loc);
            },
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array => {
                    printError("Array literal is only valid as a pattern or value", loc);
                    return CompileError.InvalidAst;
                },
                .Object => {
                    printError("Object literal is only valid as a pattern or value", loc);
                    return CompileError.InvalidAst;
                },
                .Function => try self.emitRunFunctionParser(elem, loc),
            },
        }
    }

    fn writePattern(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .OpNode => |op| switch (op.opType) {
                .Merge => {
                    try self.writePattern(op.left);
                    try self.writePattern(op.right);
                    try self.emitOp(.MergeElems, loc);
                },
                else => {
                    printError("Invalid infix operator in pattern", loc);
                    return CompileError.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writePatternElem(elem, loc),
        }
    }

    fn writePatternElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .String,
            .IntegerString,
            .FloatString,
            => try self.emitConstant(elem, loc),
            .True => try self.emitOp(.True, loc),
            .False => try self.emitOp(.False, loc),
            .Null => try self.emitOp(.Null, loc),
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .CharacterRange => {
                printError("Character range is not valid in pattern", loc);
                return CompileError.InvalidAst;
            },
            .IntegerRange => {
                printError("Integer range is not valid in pattern", loc);
                return CompileError.InvalidAst;
            },
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array,
                .Object,
                => try self.emitConstant(elem, loc),
                .Function => {
                    printError("Function is not valid in pattern", loc);
                    return CompileError.InvalidAst;
                },
            },
        }
    }

    fn writeValue(self: *Compiler, nodeId: usize) !void {
        const node = self.ast.getNode(nodeId);
        const loc = self.ast.getLocation(nodeId);

        switch (node) {
            .OpNode => |op| switch (op.opType) {
                .Merge => {
                    try self.writeValue(op.left);
                    try self.writeValue(op.right);
                    try self.emitOp(.MergeElems, loc);
                },
                else => {
                    printError("Invalid infix operator in value", loc);
                    return CompileError.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writeValueElem(elem, loc),
        }
    }

    fn writeValueElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .String,
            .IntegerString,
            .FloatString,
            => try self.emitConstant(elem, loc),
            .True => try self.emitOp(.True, loc),
            .False => try self.emitOp(.False, loc),
            .Null => try self.emitOp(.Null, loc),
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .CharacterRange => {
                printError("Character range is not valid in value", loc);
                return CompileError.InvalidAst;
            },
            .IntegerRange => {
                printError("Integer range is not valid in value", loc);
                return CompileError.InvalidAst;
            },
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array,
                .Object,
                => try self.emitConstant(elem, loc),
                .Function => {
                    printError("Function is not valid in value", loc);
                    return CompileError.InvalidAst;
                },
            },
        }
    }

    fn currentChunk(self: *Compiler) *Chunk {
        return &self.vm.chunk;
    }

    fn emitJump(self: *Compiler, op: OpCode, loc: Location) !usize {
        try self.emitOp(op, loc);
        // Dummy operands that will be patched later
        try self.currentChunk().writeShort(0xffff, loc);
        return self.currentChunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Compiler, offset: usize, loc: Location) !void {
        const jump = self.currentChunk().nextByteIndex() - offset - 2;

        std.debug.assert(self.currentChunk().read(offset) == 0xff);
        std.debug.assert(self.currentChunk().read(offset + 1) == 0xff);

        self.currentChunk().updateShortAt(offset, @as(u16, @intCast(jump))) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                printError("Too much code to jump over.", loc);
                return err;
            },
            else => return err,
        };
    }

    fn emitByte(self: *Compiler, byte: u8, loc: Location) !void {
        try self.currentChunk().write(byte, loc);
    }

    fn emitOp(self: *Compiler, op: OpCode, loc: Location) !void {
        try self.currentChunk().writeOp(op, loc);
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, loc: Location) !void {
        try self.emitOp(op, loc);
        try self.emitByte(byte, loc);
    }

    fn emitRunFunctionParser(self: *Compiler, elem: Elem, loc: Location) !void {
        try self.emitConstant(elem, loc);
        try self.emitUnaryOp(.RunFunctionParser, 0, loc);
    }

    fn emitRunLiteralParser(self: *Compiler, elem: Elem, loc: Location) !void {
        try self.emitUnaryOp(.RunLiteralParser, try self.makeConstant(elem, loc), loc);
    }

    fn emitConstant(self: *Compiler, elem: Elem, loc: Location) !void {
        try self.emitUnaryOp(.Constant, try self.makeConstant(elem, loc), loc);
    }

    fn makeConstant(self: *Compiler, elem: Elem, loc: Location) !u8 {
        return self.currentChunk().addConstant(elem) catch |err| switch (err) {
            ChunkError.TooManyConstants => {
                printError("Too many constants in one chunk.", loc);
                return err;
            },
            else => return err,
        };
    }

    fn printError(message: []const u8, loc: Location) void {
        loc.print(logger.err);
        logger.err(" Error: {s}\n", .{message});
    }
};

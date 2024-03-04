const std = @import("std");
const ArrayList = std.ArrayList;
const Ast = @import("ast.zig").Ast;
const Chunk = @import("./chunk.zig").Chunk;
const ChunkError = @import("./chunk.zig").ChunkError;
const Elem = @import("./elem.zig").Elem;
const Location = @import("location.zig").Location;
const OpCode = @import("./op_code.zig").OpCode;
const Parser = @import("./parser.zig").Parser;
const Scanner = @import("./scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("./vm.zig").VM;
const logger = @import("./logger.zig");

pub const Compiler = struct {
    vm: *VM,
    ast: Ast,
    function: *Elem.Dyn.Function,

    const Error = error{
        InvalidAst,
        ChunkWriteFailure,
        NoMainParser,
        MultipleMainParsers,
    };

    pub fn init(vm: *VM) !Compiler {
        var main = try Elem.Dyn.Function.create(
            vm,
            try vm.addString("@main"),
            .Main,
        );

        return Compiler{
            .vm = vm,
            .ast = undefined,
            .function = main,
        };
    }

    pub fn deinit(self: *Compiler) void {
        _ = self;
    }

    pub fn compile(self: *Compiler, source: []const u8) !*Elem.Dyn.Function {
        var parser = Parser.init(self.vm, source);
        defer parser.deinit();

        try parser.program();

        self.ast = parser.ast;

        var mainNodeId: ?usize = null;

        for (self.ast.roots.items) |nodeId| {
            if (self.ast.getOpOfType(nodeId, .DeclareGlobal)) |op| {
                try self.compileGlobalDeclaration(op.left, op.right);
            } else if (mainNodeId == null) {
                mainNodeId = nodeId;
            } else {
                return Error.MultipleMainParsers;
            }
        }

        if (mainNodeId) |nodeId| {
            try self.compileMainParser(nodeId);
        } else {
            return Error.NoMainParser;
        }

        self.ast = undefined;

        return self.function;
    }

    fn compileMainParser(self: *Compiler, nodeId: usize) !void {
        try self.writeParser(nodeId);
        try self.emitOp(.End, self.ast.endLocation);

        if (logger.debugCompiler) {
            self.function.disassemble(self.vm.strings);
        }
    }

    fn compileGlobalDeclaration(self: *Compiler, headNodeId: usize, bodyNodeId: usize) !void {
        switch (self.ast.getNode(headNodeId)) {
            .OpNode => |op| switch (op.opType) {
                .CallOrDefineFunction => {
                    const nameNodeId = op.left;
                    const paramsNodeId = op.right;
                    try self.compileGlobalFunction(nameNodeId, paramsNodeId, bodyNodeId);
                },
                else => return Error.InvalidAst,
            },
            .ElemNode => |nameElem| switch (nameElem) {
                .ParserVar => try self.compileGlobalFunction(headNodeId, null, bodyNodeId),
                .ValueVar => try self.compileGlobalValue(headNodeId, bodyNodeId),
                else => return Error.InvalidAst,
            },
        }
    }

    fn compileGlobalFunction(self: *Compiler, nameNodeId: usize, paramsNodeId: ?usize, bodyNodeId: usize) !void {
        const nameElem = switch (self.ast.getNode(nameNodeId)) {
            .ElemNode => |elem| elem,
            else => return Error.InvalidAst,
        };
        const parserName = switch (nameElem) {
            .ParserVar => |sId| sId,
            else => return Error.InvalidAst,
        };

        const nameLoc = self.ast.getLocation(nameNodeId);
        const bodyLoc = self.ast.getLocation(bodyNodeId);

        const nameConstId = try self.makeConstant(nameElem, nameLoc);

        switch (self.ast.getNode(bodyNodeId)) {
            .OpNode => {
                _ = paramsNodeId;
                const function = try self.writeFunction(parserName, bodyNodeId);
                const functionConstId = try self.makeConstant(function.dyn.elem(), nameLoc);

                try self.emitUnaryOp(.Constant, functionConstId, bodyLoc);
                try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);
            },
            .ElemNode => |parserElem| {
                const parserConstId = try self.makeConstant(parserElem, bodyLoc);

                try self.emitUnaryOp(.Constant, parserConstId, bodyLoc);
                try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);
            },
        }
    }

    fn compileGlobalValue(self: *Compiler, nameNodeId: usize, bodyNodeId: usize) !void {
        const nameElem = switch (self.ast.getNode(nameNodeId)) {
            .ElemNode => |elem| switch (elem) {
                .ValueVar => elem,
                else => return Error.InvalidAst,
            },
            else => return Error.InvalidAst,
        };

        const nameLoc = self.ast.getLocation(nameNodeId);

        const nameConstId = try self.makeConstant(nameElem, nameLoc);

        try self.writeValue(bodyNodeId);
        try self.emitUnaryOp(.SetGlobal, nameConstId, nameLoc);
    }

    fn writeFunction(self: *Compiler, functionName: StringTable.Id, bodyNodeId: usize) !*Elem.Dyn.Function {
        const bodyLoc = self.ast.getLocation(bodyNodeId);

        var enclosing = self.function;
        var function = try Elem.Dyn.Function.create(self.vm, functionName, .NamedFunction);

        self.function = function;

        try self.writeParser(bodyNodeId);
        try self.emitOp(.End, bodyLoc);

        if (logger.debugCompiler) {
            self.function.disassemble(self.vm.strings);
        }

        self.function = enclosing;

        return function;
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
                    const thenElseOp = self.ast.getOpOfType(op.right, .ConditionalThenElse).?;
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
                .DeclareGlobal => unreachable,
                .CallOrDefineFunction => @panic("todo"),
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
            .CallOrDefineFunction,
            .DeclareGlobal,
            => unreachable, // No eqivalent OpCode
        };

        try self.emitOp(opCode, loc);
    }

    fn writeParserElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .ParserVar => {
                try self.emitRunParser(elem, loc);
            },
            .ValueVar => {
                printError("Variable is only valid as a pattern or value", loc);
                return Error.InvalidAst;
            },
            .String,
            .IntegerString,
            .FloatString,
            .CharacterRange,
            .IntegerRange,
            => try self.emitRunParser(elem, loc),
            .True => {
                // In this context `true` could be a zero-arg function call
                const sId = try self.vm.addString("true");
                try self.emitCallFunctionParser(Elem.parserVar(sId), loc);
            },
            .False => {
                // In this context `false` could be a zero-arg function call
                const sId = try self.vm.addString("false");
                try self.emitCallFunctionParser(Elem.parserVar(sId), loc);
            },
            .Null => {
                // In this context `null` could be a zero-arg function call
                const sId = try self.vm.addString("null");
                try self.emitCallFunctionParser(Elem.parserVar(sId), loc);
            },
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array => {
                    printError("Array literal is only valid as a pattern or value", loc);
                    return Error.InvalidAst;
                },
                .Object => {
                    printError("Object literal is only valid as a pattern or value", loc);
                    return Error.InvalidAst;
                },
                .Function => try self.emitCallFunctionParser(elem, loc),
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
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writePatternElem(elem, loc),
        }
    }

    fn writePatternElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .ParserVar => {
                printError("parser is not valid in pattern", loc);
                return Error.InvalidAst;
            },
            .ValueVar,
            .String,
            .IntegerString,
            .FloatString,
            => try self.emitConstant(.Constant, elem, loc),
            .True => try self.emitOp(.True, loc),
            .False => try self.emitOp(.False, loc),
            .Null => try self.emitOp(.Null, loc),
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .CharacterRange => {
                printError("Character range is not valid in pattern", loc);
                return Error.InvalidAst;
            },
            .IntegerRange => {
                printError("Integer range is not valid in pattern", loc);
                return Error.InvalidAst;
            },
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array,
                .Object,
                => try self.emitConstant(.Constant, elem, loc),
                .Function => {
                    printError("Function is not valid in pattern", loc);
                    return Error.InvalidAst;
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
                    return Error.InvalidAst;
                },
            },
            .ElemNode => |elem| try self.writeValueElem(elem, loc),
        }
    }

    fn writeValueElem(self: *Compiler, elem: Elem, loc: Location) !void {
        switch (elem) {
            .ParserVar => {
                printError("Parser is not valid in value", loc);
                return Error.InvalidAst;
            },
            .ValueVar => {
                try self.emitConstant(.Constant, elem, loc);
                try self.emitOp(.SubstituteValue, loc);
            },
            .String,
            .IntegerString,
            .FloatString,
            => try self.emitConstant(.Constant, elem, loc),
            .True => try self.emitOp(.True, loc),
            .False => try self.emitOp(.False, loc),
            .Null => try self.emitOp(.Null, loc),
            .Character,
            .Integer,
            .Float,
            => unreachable, // not produced by the parser
            .CharacterRange => {
                printError("Character range is not valid in value", loc);
                return Error.InvalidAst;
            },
            .IntegerRange => {
                printError("Integer range is not valid in value", loc);
                return Error.InvalidAst;
            },
            .Dyn => |d| switch (d.dynType) {
                .String => unreachable, // not produced by the parser
                .Array,
                .Object,
                => try self.emitConstant(.Constant, elem, loc),
                .Function => {
                    printError("Function is not valid in value", loc);
                    return Error.InvalidAst;
                },
            },
        }
    }

    fn chunk(self: *Compiler) *Chunk {
        return &self.function.chunk;
    }

    fn emitJump(self: *Compiler, op: OpCode, loc: Location) !usize {
        try self.emitOp(op, loc);
        // Dummy operands that will be patched later
        try self.chunk().writeShort(0xffff, loc);
        return self.chunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Compiler, offset: usize, loc: Location) !void {
        const jump = self.chunk().nextByteIndex() - offset - 2;

        std.debug.assert(self.chunk().read(offset) == 0xff);
        std.debug.assert(self.chunk().read(offset + 1) == 0xff);

        self.chunk().updateShortAt(offset, @as(u16, @intCast(jump))) catch |err| switch (err) {
            ChunkError.ShortOverflow => {
                printError("Too much code to jump over.", loc);
                return err;
            },
            else => return err,
        };
    }

    fn emitByte(self: *Compiler, byte: u8, loc: Location) !void {
        try self.chunk().write(byte, loc);
    }

    fn emitOp(self: *Compiler, op: OpCode, loc: Location) !void {
        try self.chunk().writeOp(op, loc);
    }

    fn emitUnaryOp(self: *Compiler, op: OpCode, byte: u8, loc: Location) !void {
        try self.emitOp(op, loc);
        try self.emitByte(byte, loc);
    }

    fn emitCallFunctionParser(self: *Compiler, elem: Elem, loc: Location) !void {
        try self.emitConstant(.Constant, elem, loc);
        try self.emitUnaryOp(.CallFunctionParser, 0, loc);
    }

    fn emitRunParser(self: *Compiler, elem: Elem, loc: Location) !void {
        try self.emitUnaryOp(.RunParser, try self.makeConstant(elem, loc), loc);
    }

    fn emitConstant(self: *Compiler, op: OpCode, elem: Elem, loc: Location) !void {
        try self.emitUnaryOp(op, try self.makeConstant(elem, loc), loc);
    }

    fn makeConstant(self: *Compiler, elem: Elem, loc: Location) !u8 {
        return self.chunk().addConstant(elem) catch |err| switch (err) {
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

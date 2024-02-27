const std = @import("std");
const Scanner = @import("scanner.zig").Scanner;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const logger = @import("./logger.zig");
const ElemManager = @import("./elem.zig").ElemManager;
const Elem = @import("./elem.zig").Elem;
const VM = @import("vm.zig").VM;

pub const Precedence = enum {
    Call,
    Or,
    TakeRight,
    TakeLeft,
    Merge,
    Backtrack,
    Destructure,
    Return,
    Sequence,
    Conditional,
    None,

    pub fn get(tokenType: TokenType) Precedence {
        return switch (tokenType) {
            .LeftParen => .Call,
            .RightParen => .None,
            .LeftBrace, .RightBrace => .None,
            .LeftBracket, .RightBracket => .None,
            .Comma, .Dot => .None,
            .Plus => .Merge,
            .Semicolon => .None,
            .Bang => .Backtrack,
            .DollarSign => .Return,
            .Ampersand => .Sequence,
            .QuestionMark => .Conditional,
            .Equal => unreachable,
            .GreaterThan => .TakeRight,
            .Bar => .Or,
            .LessThan => .TakeLeft,
            .LessThanDash => .Destructure,
            .LowercaseIdentifier, .UppercaseIdentifier => .None,
            .String, .Integer, .Float => .None,
            .True, .False, .Null => .None,
            .Whitespace, .WhitespaceWithNewline => .None,
            .Colon, .Error, .Eof => .None,
        };
    }

    pub fn bindingPower(self: Precedence) struct { left: u4, right: u4 } {
        return switch (self) {
            .Or, .TakeRight, .TakeLeft, .Merge, .Backtrack => .{ .left = 5, .right = 6 },
            .Destructure => .{ .left = 5, .right = 6 },
            .Return => .{ .left = 5, .right = 6 },
            .Sequence => .{ .left = 3, .right = 4 },
            .Conditional => .{ .left = 2, .right = 1 },
            .Call => .{ .left = 1, .right = 1 },
            .None => .{ .left = 0, .right = 0 },
        };
    }
};

// Note: We have to spell these out explicitly right now because Zig has
// trouble inferring error sets for recursive functions.
//
// See https://github.com/ziglang/zig/issues/2971
const CompilerError = error{OutOfMemory} || std.os.WriteError;

pub const Parser = struct {
    vm: *VM,
    scanner: Scanner,
    current: Token,
    previous: Token,
    hadError: bool,
    panicMode: bool,

    pub fn init(vm: *VM, source: []const u8) Parser {
        return Parser{
            .vm = vm,
            .scanner = Scanner.init(source),
            .current = undefined,
            .previous = undefined,
            .hadError = false,
            .panicMode = false,
        };
    }

    pub fn program(self: *Parser) !void {
        try self.advance();
        _ = self.skipWhitespace();

        if (self.check(.Eof)) {
            try self.end();
            return;
        }

        try self.statement();
        try self.consume(.Eof, "Expect end of program.");
        try self.end();
    }

    fn statement(self: *Parser) !void {
        try self.parsePrecedence(.Conditional);
    }

    fn expression(self: *Parser) !void {
        try self.parsePrecedence(.Conditional);
    }

    fn end(self: *Parser) !void {
        try self.emitOp(.End);
        if (logger.debugParser) self.currentChunk().disassemble(self.vm.stringTable, "code");
    }

    fn parsePrecedence(self: *Parser, precedence: Precedence) CompilerError!void {
        try self.advance();
        _ = self.skipWhitespace();
        const leftOperandIndex = try self.prefix(self.previous.tokenType);
        _ = self.skipWhitespace();

        while (precedence.bindingPower().right <= Precedence.get(self.current.tokenType).bindingPower().left) {
            try self.advance();
            _ = self.skipWhitespace();
            try self.infix(self.previous.tokenType, leftOperandIndex);
        }
    }

    fn prefix(self: *Parser, tokenType: TokenType) CompilerError!usize {
        if (logger.debugParser) logger.debug("prefix {}\n", .{tokenType});

        const chunkIndex = self.currentChunk().code.items.len;

        switch (tokenType) {
            .LeftParen => try self.grouping(),
            .LowercaseIdentifier => unreachable,
            .UppercaseIdentifier => unreachable,
            .String => try self.string(),
            .Integer => try self.integer(),
            .Float => try self.float(),
            .True, .False, .Null => try self.literal(),
            else => try self.prefixError(),
        }

        return chunkIndex;
    }

    fn infix(self: *Parser, tokenType: TokenType, leftOperandIndex: usize) !void {
        if (logger.debugParser) logger.debug("infix {}\n", .{tokenType});

        switch (tokenType) {
            .LeftParen => unreachable,
            .Bar => try self.binaryOr(),
            .GreaterThan, .LessThan, .Plus, .Bang, .Ampersand => try self.binaryAnd(),
            .DollarSign => try self.binaryReturn(),
            .LessThanDash => try self.binaryDestructure(leftOperandIndex),
            .QuestionMark => try self.conditional(),
            else => try self.infixError(),
        }
    }

    fn string(self: *Parser) !void {
        const s1 = stringContents(self.previous.lexeme);

        if (s1.len == 1 and self.current.tokenType == .Dot) {
            try self.advance();
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .String) {
                    try self.advance();
                    const s2 = stringContents(self.previous.lexeme);
                    if (s2.len == 1) {
                        try self.emitConstant(Elem.characterRange(s1[0], s2[0]));
                        try self.emitOp(.RunLiteralParser);
                    } else {
                        try self.err("Expect single character for character range");
                    }
                } else {
                    try self.err("Expect second string for character range");
                }
            } else {
                try self.err("Expect second period");
            }
        } else {
            const sId = try self.vm.addString(s1);
            try self.emitConstant(Elem.string(sId));
            try self.emitOp(.RunLiteralParser);
        }
    }

    fn stringContents(str: []const u8) []const u8 {
        return str[1 .. str.len - 1];
    }

    fn integer(self: *Parser) !void {
        if (parseInteger(self.previous.lexeme)) |int1| {
            const s1 = self.previous.lexeme;
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .Dot) {
                    try self.advance();
                    if (self.current.tokenType == .Integer) {
                        try self.advance();
                        if (parseInteger(self.previous.lexeme)) |int2| {
                            const s2 = self.previous.lexeme;
                            const sId1 = try self.vm.addString(s1);
                            const sId2 = try self.vm.addString(s2);
                            try self.emitConstant(Elem.integerRange(int1, sId1, int2, sId2));
                            try self.emitOp(.RunLiteralParser);
                        } else {
                            try self.err("Could not parse number");
                        }
                    } else {
                        try self.err("Expect integer");
                    }
                } else {
                    try self.err("Expect second period");
                }
            } else {
                const sId1 = try self.vm.addString(s1);
                try self.emitConstant(Elem.integer(int1, sId1));
                try self.emitOp(.RunLiteralParser);
            }
        } else {
            try self.err("Could not parse number");
        }
    }

    fn parseInteger(lexeme: []const u8) ?i64 {
        if (std.fmt.parseInt(i64, lexeme, 10)) |value| {
            return value;
        } else |_| {
            return null;
        }
    }

    fn float(self: *Parser) !void {
        if (parseFloat(self.previous.lexeme)) |f| {
            const sId = try self.vm.addString(self.previous.lexeme);
            try self.emitConstant(Elem.float(f, sId));
            try self.emitOp(.RunLiteralParser);
        } else {
            try self.err("Could not parse number");
        }
    }

    fn parseFloat(lexeme: []const u8) ?f64 {
        if (std.fmt.parseFloat(f64, lexeme)) |value| {
            return value;
        } else |_| {
            return null;
        }
    }

    fn literal(self: *Parser) !void {
        switch (self.previous.tokenType) {
            .True => try self.emitOp(.True),
            .False => try self.emitOp(.False),
            .Null => try self.emitOp(.Null),
            else => unreachable,
        }
    }

    fn grouping(self: *Parser) !void {
        try self.expression();
        try self.consume(.RightParen, "Expect ')' after expression.");
    }

    fn binaryOr(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        const jumpIndex = try self.emitJump(.JumpIfSuccess);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.emitInfixOp(.Or, operatorLine);

        try self.patchJump(jumpIndex);
    }

    fn binaryAnd(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        const jumpIndex = try self.emitJump(.JumpIfFailure);

        try self.parsePrecedence(Precedence.get(operatorType));

        switch (operatorType) {
            .Plus => try self.emitInfixOp(.MergeParsed, operatorLine),
            .Bang => try self.emitInfixOp(.Backtrack, operatorLine),
            .Ampersand => try self.emitInfixOp(.Sequence, operatorLine),
            .GreaterThan => try self.emitInfixOp(.TakeRight, operatorLine),
            .LessThan => try self.emitInfixOp(.TakeLeft, operatorLine),
            else => try self.err("Unexpected binary operator"), // unreachable
        }

        try self.patchJump(jumpIndex);
    }

    fn binaryReturn(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        const jumpIndex = try self.emitJump(.JumpIfFailure);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.emitInfixOp(.Return, operatorLine);

        try self.patchJump(jumpIndex);
    }

    fn binaryDestructure(self: *Parser, leftOperandIndex: usize) !void {
        _ = leftOperandIndex;
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        // const leftOp: OpCode = @enumFromInt(self.currentChunk().code.items[leftOperandIndex]);

        // // The lhs should be a constant. In some cases it might already be
        // // marked as a pattern, which indicates semantically incorrect code. We
        // // allow this for now and report the error at runtime.
        // std.debug.assert(leftOp == OpCode.Constant or leftOp == OpCode.Pattern);

        // // Update the lhs operand to be a pattern instead of something that
        // // could be interpreted as a parser
        // self.currentChunk().updateOpAt(leftOperandIndex, .Pattern);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.emitInfixOp(.Destructure, operatorLine);
    }

    fn conditional(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        // const operatorLine = self.previous.line;

        // jump to failure branch if the test branch was a failure
        const failureJumpIndex = try self.emitJump(.JumpIfFailure);

        try self.parsePrecedence(.Conditional);

        _ = self.skipWhitespace();
        try self.consume(.Colon, "Expect ':' for conditional else branch.");
        _ = self.skipWhitespace();

        // jump over failure branch if the test branch was a success
        const successJumpIndex = try self.emitJump(.JumpIfSuccess);

        try self.patchJump(failureJumpIndex);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.patchJump(successJumpIndex);
    }

    fn currentChunk(self: *Parser) *Chunk {
        return &self.vm.chunk;
    }

    pub fn advance(self: *Parser) !void {
        self.previous = self.current;

        while (self.scanner.next()) |token| {
            self.current = token;
            if (!self.check(.Error)) break;
            try self.errorAtCurrent(self.current.lexeme);
        }
    }

    fn skipWhitespace(self: *Parser) bool {
        if (self.current.tokenType == .Whitespace or self.current.tokenType == .WhitespaceWithNewline) {
            if (self.scanner.next()) |token| self.current = token;
            return true;
        }
        return false;
    }

    fn check(self: *Parser, tokenType: TokenType) bool {
        return self.current.tokenType == tokenType;
    }

    fn consume(self: *Parser, tokenType: TokenType, message: []const u8) !void {
        if (self.check(tokenType)) {
            try self.advance();
        } else {
            try self.errorAtCurrent(message);
        }
    }

    fn match(self: *Parser, tokenType: TokenType) !bool {
        if (!self.check(tokenType)) return false;
        try self.advance();
        return true;
    }

    fn errorAtCurrent(self: *Parser, message: []const u8) !void {
        try self.errorAt(&self.current, message);
    }

    fn err(self: *Parser, message: []const u8) !void {
        try self.errorAt(&self.previous, message);
    }

    fn prefixError(self: *Parser) !void {
        try self.err("Expect expression.");
    }

    fn infixError(self: *Parser) !void {
        try self.err("Expect expression.");
    }

    fn errorAt(self: *Parser, token: *Token, message: []const u8) !void {
        if (self.panicMode) return;
        self.panicMode = true;

        logger.err("[line {}] Error", .{token.line});

        switch (token.tokenType) {
            .Eof => {
                logger.err(" at end", .{});
            },
            .Error => {},
            else => {
                logger.err(" at '{s}'", .{token.lexeme});
            },
        }

        logger.err(": {s}\n", .{message});

        self.hadError = true;
    }

    fn emitJump(self: *Parser, op: OpCode) !usize {
        try self.emitOp(op);
        // Dummy operands that will be patched later
        try self.emitByte(0xff);
        try self.emitByte(0xff);
        return self.currentChunk().nextByteIndex() - 2;
    }

    fn patchJump(self: *Parser, offset: usize) !void {
        const jump = self.currentChunk().nextByteIndex() - offset - 2;

        if (jump > std.math.maxInt(u16)) {
            try self.err("Too much code to jump over.");
        }

        std.debug.assert(self.currentChunk().read(offset) == 0xff);
        std.debug.assert(self.currentChunk().read(offset + 1) == 0xff);

        self.currentChunk().updateAt(offset, @as(u8, @intCast((jump >> 8) & 0xff)));
        self.currentChunk().updateAt(offset + 1, @as(u8, @intCast(jump & 0xff)));
    }

    fn emitByte(self: *Parser, byte: u8) !void {
        try self.currentChunk().write(byte, self.previous.line);
    }

    fn emitOp(self: *Parser, op: OpCode) !void {
        try self.currentChunk().writeOp(op, self.previous.line);
    }

    fn emitInfixOp(self: *Parser, op: OpCode, line: usize) !void {
        try self.currentChunk().writeOp(op, line);
    }

    fn emitUnaryOp(self: *Parser, op: OpCode, byte: u8) !void {
        try self.emitOp(op);
        try self.emitByte(byte);
    }

    fn emitConstant(self: *Parser, elem: Elem) !void {
        try self.emitUnaryOp(.Constant, try self.makeConstant(elem));
    }

    fn makeConstant(self: *Parser, elem: Elem) !u8 {
        const constant = try self.currentChunk().addConstant(elem);

        if (constant > std.math.maxInt(u8)) {
            try self.err("Too many constants in one chunk.");
            return 0;
        }

        return @as(u8, @intCast(constant));
    }
};

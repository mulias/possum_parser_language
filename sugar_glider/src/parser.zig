const std = @import("std");
const Scanner = @import("scanner.zig").Scanner;
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const logger = @import("./logger.zig");
const Value = @import("./value.zig").Value;

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
            .QuestionMark, .Colon => .Conditional,
            .Equal => unreachable,
            .GreaterThan => .TakeRight,
            .Bar => .Or,
            .LessThan => .TakeLeft,
            .LessThanDash => .Destructure,
            .LowercaseIdentifier, .UppercaseIdentifier => .None,
            .String, .Integer, .Float => .None,
            .True, .False, .Null => .None,
            .Whitespace, .WhitespaceWithNewline => .None,
            .Error, .Eof => .None,
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
    scanner: *Scanner,
    chunk: *Chunk,
    current: Token,
    previous: Token,
    hadError: bool,
    panicMode: bool,

    pub fn init(scanner: *Scanner, chunk: *Chunk) Parser {
        return Parser{
            .scanner = scanner,
            .chunk = chunk,
            .current = undefined,
            .previous = undefined,
            .hadError = false,
            .panicMode = false,
        };
    }

    pub fn program(self: *Parser) !void {
        try self.advance();
        _ = self.skipWhitespace();
        try self.statement();
        try self.consume(TokenType.Eof, "Expect end of program.");
        try self.end();
    }

    pub fn statement(self: *Parser) !void {
        try self.parsePrecedence(.Conditional);
    }

    pub fn expression(self: *Parser) !void {
        try self.parsePrecedence(.Conditional);
    }

    pub fn end(self: *Parser) !void {
        try self.emitOp(.End);
        if (logger.debugParser) self.chunk.disassemble("code");
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

        const chunkIndex = self.chunk.code.items.len;

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
        const str1 = stringContents(self.previous.lexeme);

        if (str1.len == 1 and self.current.tokenType == .Dot) {
            try self.advance();
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .String) {
                    try self.advance();
                    const str2 = stringContents(self.previous.lexeme);
                    if (str2.len == 1) {
                        try self.emitConstant(.{ .CharacterRange = .{ str1[0], str2[0] } });
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
            try self.emitConstant(.{ .String = str1 });
        }
    }

    fn stringContents(str: []const u8) []const u8 {
        return str[1 .. str.len - 1];
    }

    fn integer(self: *Parser) !void {
        if (parseInteger(self.previous.lexeme)) |int1| {
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .Dot) {
                    try self.advance();
                    if (self.current.tokenType == .Integer) {
                        try self.advance();
                        if (parseInteger(self.previous.lexeme)) |int2| {
                            try self.emitConstant(.{ .IntegerRange = .{ int1, int2 } });
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
                try self.emitConstant(.{ .Integer = int1 });
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
        try self.emitConstant(.{ .Float = self.previous.lexeme });
    }

    fn literal(self: *Parser) !void {
        switch (self.previous.tokenType) {
            .True => try self.emitConstant(.{ .True = undefined }),
            .False => try self.emitConstant(.{ .False = undefined }),
            .Null => try self.emitConstant(.{ .Null = undefined }),
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

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.emitInfixOp(.Or, operatorLine);
    }

    fn binaryAnd(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        const jumpIndex = try self.emitJump(.JumpIfFailure);

        try self.parsePrecedence(Precedence.get(operatorType));

        switch (operatorType) {
            .Plus => try self.emitInfixOp(.Merge, operatorLine),
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
        const rightOperandIndex = self.chunk.nextByteIndex();

        try self.parsePrecedence(Precedence.get(operatorType));

        // Update the rhs operand to be a return value instead of something that
        // could be interpreted as a parser
        std.debug.assert(self.chunk.code.items[rightOperandIndex] == @intFromEnum(OpCode.Constant));
        self.chunk.updateOpAt(rightOperandIndex, .ReturnValue);

        try self.emitInfixOp(.Return, operatorLine);

        try self.patchJump(jumpIndex);
    }

    fn binaryDestructure(self: *Parser, leftOperandIndex: usize) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        // Update the lhs operand to be a pattern instead of something that
        // could be interpreted as a parser
        std.debug.assert(self.chunk.code.items[leftOperandIndex] == @intFromEnum(OpCode.Constant));
        self.chunk.updateOpAt(leftOperandIndex, .Pattern);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.emitInfixOp(.Destructure, operatorLine);
    }

    fn conditional(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        // const operatorLine = self.previous.line;

        // jump to failure branch if the test branch was a failure
        const failureJumpIndex = try self.emitJump(.ConditionalJump);

        try self.parsePrecedence(.Sequence);

        _ = self.skipWhitespace();
        try self.consume(.Colon, "Expect ':' for conditional else branch.");
        _ = self.skipWhitespace();

        // jump over failure branch if the test branch was a success
        const successJumpIndex = try self.emitJump(.ConditionalJumpSuccess);

        try self.patchJump(failureJumpIndex);

        try self.parsePrecedence(Precedence.get(operatorType));

        try self.patchJump(successJumpIndex);
    }

    fn currentChunk(self: *Parser) *Chunk {
        return self.chunk;
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

    fn emitConstant(self: *Parser, value: Value) !void {
        try self.emitUnaryOp(.Constant, try self.makeConstant(value));
    }

    fn makeConstant(self: *Parser, value: Value) !u8 {
        const constant = try self.currentChunk().addConstant(value);

        if (constant > std.math.maxInt(u8)) {
            try self.err("Too many constants in one chunk.");
            return 0;
        }

        return @as(u8, @intCast(constant));
    }
};

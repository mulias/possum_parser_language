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
            .Error, .Eof => .None,
        };
    }

    pub fn bindingPower(self: Precedence) struct { left: u4, right: u4 } {
        return switch (self) {
            .Or, .TakeRight, .TakeLeft, .Merge, .Backtrack => .{ .left = 5, .right = 6 },
            .Destructure => .{ .left = 7, .right = 6 },
            .Return => .{ .left = 5, .right = 8 },
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
        try self.prefix(self.previous.tokenType);

        while (precedence.bindingPower().right <= Precedence.get(self.current.tokenType).bindingPower().left) {
            try self.advance();
            _ = self.skipWhitespace();
            try self.infix(self.previous.tokenType);
        }
    }

    fn prefix(self: *Parser, tokenType: TokenType) CompilerError!void {
        if (logger.debugParser) logger.debug("prefix {}\n", .{tokenType});

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
    }

    fn infix(self: *Parser, tokenType: TokenType) !void {
        if (logger.debugParser) logger.debug("infix {}\n", .{tokenType});

        switch (tokenType) {
            .LeftParen => unreachable,
            .Plus, .Bang, .DollarSign, .Ampersand, .QuestionMark => try self.binary(),
            .GreaterThan, .Bar, .LessThan, .LessThanDash => try self.binary(),
            else => try self.infixError(),
        }
    }

    fn string(self: *Parser) !void {
        const source = self.previous.lexeme[1 .. self.previous.lexeme.len - 1];
        try self.emitConstant(.{ .String = source });
    }

    fn integer(self: *Parser) !void {
        if (std.fmt.parseInt(i64, self.previous.lexeme, 10)) |value| {
            try self.emitConstant(.{ .Integer = value });
        } else |_| {
            try self.err("Could not parse number");
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

    fn binary(self: *Parser) !void {
        const operatorType = self.previous.tokenType;
        const operatorLine = self.previous.line;

        try self.parsePrecedence(Precedence.get(operatorType));

        switch (operatorType) {
            .Plus => try self.emitInfixOp(.Merge, operatorLine),
            .Bang => try self.emitInfixOp(.Backtrack, operatorLine),
            .DollarSign => try self.emitInfixOp(.Return, operatorLine),
            .Ampersand => try self.emitInfixOp(.Sequence, operatorLine),
            .QuestionMark => unreachable,
            .GreaterThan => try self.emitInfixOp(.TakeRight, operatorLine),
            .Bar => try self.emitInfixOp(.Or, operatorLine),
            .LessThan => try self.emitInfixOp(.TakeLeft, operatorLine),
            .LessThanDash => try self.emitInfixOp(.Destructure, operatorLine),
            else => try self.err("Unexpected binary operator"), // unreachable
        }
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
        return self.currentChunk().code.items.len - 2;
    }

    fn patchJump(self: *Parser, offset: usize) !void {
        const jump = self.currentChunk().code.items.len - offset - 2;

        if (jump > std.math.maxInt(u16)) {
            try self.err("Too much code to jump over.");
        }

        self.currentChunk().code.items[offset] = @as(u8, @intCast((jump >> 8) & 0xff));
        self.currentChunk().code.items[offset + 1] = @as(u8, @intCast(jump & 0xff));
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

    fn ifStatement(self: *Parser) CompilerError!void {
        try self.consume(.LeftParen, "Expect '(' after 'if'.");
        try self.expression();
        try self.consume(.RightParen, "Expect ')' after condition.");

        const thenJump = try self.emitJump(.JumpIfFalse);
        try self.emitOp(.Pop);
        try self.statement();
        const elseJump = try self.emitJump(.Jump);

        try self.patchJump(thenJump);
        try self.emitOp(.Pop);

        if (try self.match(.Else)) try self.statement();
        try self.patchJump(elseJump);
    }

    fn expressionStatement(self: *Parser) !void {
        try self.expression();
        try self.consume(.Semicolon, "Expect ';' after expression.");
        try self.emitOp(.Pop);
    }

    fn synchronize(self: *Parser) !void {
        self.panicMode = false;

        while (!self.check(.Eof)) {
            if (self.previous.tokenType == .Semicolon) return;

            switch (self.current.tokenType) {
                .Class, .Fun, .Var, .For, .If, .While, .Print, .Return => return,
                else => try self.advance(),
            }
        }
    }
};

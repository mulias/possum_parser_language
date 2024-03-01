const std = @import("std");
const Ast = @import("ast.zig").Ast;
const Elem = @import("./elem.zig").Elem;
const Scanner = @import("scanner.zig").Scanner;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const VM = @import("vm.zig").VM;
const logger = @import("./logger.zig");
const Location = @import("location.zig").Location;

const ParseError = error{
    OutOfMemory,
    UnexpectedInput,
    NoProgram,
    PanicMode,
};

pub const Parser = struct {
    vm: *VM,
    scanner: Scanner,
    current: Token,
    previous: Token,
    ast: Ast,
    hadError: bool,
    panicMode: bool,

    pub fn init(vm: *VM, source: []const u8) Parser {
        return Parser{
            .vm = vm,
            .scanner = Scanner.init(source),
            .current = undefined,
            .previous = undefined,
            .ast = Ast.init(vm.allocator),
            .hadError = false,
            .panicMode = false,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit();
    }

    pub fn program(self: *Parser) !usize {
        try self.advance();
        _ = self.skipWhitespace();

        if (self.check(.Eof)) {
            try self.end();
            return ParseError.NoProgram;
        }

        const rootNodeId = try self.statement();
        try self.consume(.Eof, "Expect end of program.");
        try self.end();

        return rootNodeId;
    }

    fn statement(self: *Parser) !usize {
        return try self.parsePrecedence(.Conditional);
    }

    fn expression(self: *Parser) ParseError!usize {
        return self.parsePrecedence(.Conditional);
    }

    fn end(self: *Parser) !void {
        self.ast.endLocation = self.previous.loc;
    }

    fn parsePrecedence(self: *Parser, precedence: Precedence) ParseError!usize {
        try self.advance();
        _ = self.skipWhitespace();

        var node = try self.prefix(self.previous.tokenType);

        _ = self.skipWhitespace();

        while (precedence.bindingPower().right <= Precedence.get(self.current.tokenType).bindingPower().left) {
            try self.advance();
            _ = self.skipWhitespace();
            node = try self.infix(self.previous.tokenType, node);
        }

        return node;
    }

    fn prefix(self: *Parser, tokenType: TokenType) !usize {
        if (logger.debugParser) logger.debug("prefix {}\n", .{tokenType});

        return switch (tokenType) {
            .LeftParen => self.grouping(),
            .LowercaseIdentifier => unreachable,
            .UppercaseIdentifier => unreachable,
            .String => self.string(),
            .Integer => self.integer(),
            .Float => self.float(),
            .True, .False, .Null => self.literal(),
            else => self.prefixError(),
        };
    }

    fn infix(self: *Parser, tokenType: TokenType, leftNode: usize) !usize {
        if (logger.debugParser) logger.debug("infix {}\n", .{tokenType});

        return switch (tokenType) {
            .Ampersand,
            .Bang,
            .Bar,
            .DollarSign,
            .GreaterThan,
            .LessThan,
            .LessThanDash,
            .Plus,
            => try self.binaryOp(leftNode),
            .QuestionMark => try self.conditionalOp(leftNode),
            else => self.infixError(),
        };
    }

    fn string(self: *Parser) !usize {
        const t1 = self.previous;
        const s1 = stringContents(t1.lexeme);

        if (s1.len == 1 and self.current.tokenType == .Dot) {
            try self.advance();
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .String) {
                    try self.advance();
                    const s2 = stringContents(self.previous.lexeme);
                    if (s2.len == 1) {
                        return self.ast.pushElem(
                            Elem.characterRange(s1[0], s2[0]),
                            Location.new(t1.loc.line, t1.loc.start, 4),
                        );
                    } else {
                        return self.err("Expect single character for character range");
                    }
                } else {
                    return self.err("Expect second string for character range");
                }
            } else {
                return self.err("Expect second period");
            }
        } else {
            const sId = try self.vm.addString(s1);
            return self.ast.pushElem(Elem.string(sId), t1.loc);
        }
    }

    fn stringContents(str: []const u8) []const u8 {
        return str[1 .. str.len - 1];
    }

    fn integer(self: *Parser) !usize {
        const t1 = self.previous;
        const s1 = t1.lexeme;
        if (parseInteger(s1)) |int1| {
            if (self.current.tokenType == .Dot) {
                try self.advance();
                if (self.current.tokenType == .Dot) {
                    try self.advance();
                    if (self.current.tokenType == .Integer) {
                        try self.advance();
                        const t2 = self.previous;
                        const s2 = t2.lexeme;
                        if (parseInteger(s2)) |int2| {
                            return self.ast.pushElem(
                                Elem.integerRange(int1, int2),
                                Location.new(t1.loc.line, t1.loc.start, t1.loc.length + t2.loc.length + 2),
                            );
                        } else {
                            return self.err("Could not parse number");
                        }
                    } else {
                        return self.err("Expect integer");
                    }
                } else {
                    return self.err("Expect second period");
                }
            } else {
                const sId1 = try self.vm.addString(s1);
                return self.ast.pushElem(Elem.integerString(int1, sId1), t1.loc);
            }
        } else {
            // Already verified this is an int during scanning
            unreachable;
        }
    }

    fn parseInteger(lexeme: []const u8) ?i64 {
        if (std.fmt.parseInt(i64, lexeme, 10)) |value| {
            return value;
        } else |_| {
            return null;
        }
    }

    fn float(self: *Parser) !usize {
        const t = self.previous;
        if (parseFloat(t.lexeme)) |f| {
            const sId = try self.vm.addString(t.lexeme);
            return self.ast.pushElem(Elem.floatString(f, sId), t.loc);
        } else {
            // Already verified this is a float during scanning
            unreachable;
        }
    }

    fn parseFloat(lexeme: []const u8) ?f64 {
        if (std.fmt.parseFloat(f64, lexeme)) |value| {
            return value;
        } else |_| {
            return null;
        }
    }

    fn literal(self: *Parser) !usize {
        const t = self.previous;
        return switch (t.tokenType) {
            .True => try self.ast.pushElem(Elem.trueConst, t.loc),
            .False => try self.ast.pushElem(Elem.falseConst, t.loc),
            .Null => try self.ast.pushElem(Elem.nullConst, t.loc),
            else => unreachable,
        };
    }

    fn grouping(self: *Parser) !usize {
        const nodeId = try self.expression();
        try self.consume(.RightParen, "Expect ')' after expression.");
        return nodeId;
    }

    fn binaryOp(self: *Parser, leftNodeId: usize) !usize {
        const t = self.previous;

        const rightNodeId = try self.parsePrecedence(Precedence.get(t.tokenType));

        const op: Ast.OpType = switch (t.tokenType) {
            .Ampersand => .Sequence,
            .Bang => .Backtrack,
            .Bar => .Or,
            .DollarSign => .Return,
            .GreaterThan => .TakeRight,
            .LessThan => .TakeLeft,
            .LessThanDash => .Destructure,
            .Plus => .Merge,
            else => unreachable,
        };

        return self.ast.pushOp(op, leftNodeId, rightNodeId, t.loc);
    }

    fn conditionalOp(self: *Parser, ifNode: usize) !usize {
        const ifThenLoc = self.previous.loc;

        const thenNode = try self.parsePrecedence(.Conditional);

        _ = self.skipWhitespace();
        try self.consume(.Colon, "Expect ':' for conditional else branch.");
        const thenElseLoc = self.previous.loc;
        _ = self.skipWhitespace();

        const elseNode = try self.parsePrecedence(.Conditional);

        const thenElseNode = try self.ast.pushOp(.ConditionalThenElse, thenNode, elseNode, thenElseLoc);

        const ifThenNode = try self.ast.pushOp(.ConditionalIfThen, ifNode, thenElseNode, ifThenLoc);

        return ifThenNode;
    }

    pub fn advance(self: *Parser) !void {
        self.previous = self.current;

        while (self.scanner.next()) |token| {
            self.current = token;
            if (!self.check(.Error)) break;
            return self.errorAtCurrent(self.current.lexeme);
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
            return self.advance();
        } else {
            return self.errorAtCurrent(message);
        }
    }

    fn match(self: *Parser, tokenType: TokenType) !bool {
        if (!self.check(tokenType)) return false;
        try self.advance();
        return true;
    }

    fn errorAtCurrent(self: *Parser, message: []const u8) ParseError {
        return self.errorAt(&self.current, message);
    }

    fn err(self: *Parser, message: []const u8) ParseError {
        return self.errorAt(&self.previous, message);
    }

    fn prefixError(self: *Parser) ParseError {
        return self.err("Expect expression.");
    }

    fn infixError(self: *Parser) ParseError {
        return self.err("Expect expression.");
    }

    fn errorAt(self: *Parser, token: *Token, message: []const u8) ParseError {
        if (self.panicMode) return ParseError.PanicMode;
        self.panicMode = true;

        token.loc.print(logger.err);

        switch (token.tokenType) {
            .Eof => {
                logger.err(" Error at end", .{});
            },
            .Error => {},
            else => {
                logger.err(" Error at '{s}'", .{token.lexeme});
            },
        }

        logger.err(": {s}\n", .{message});

        self.hadError = true;

        return ParseError.UnexpectedInput;
    }
};

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

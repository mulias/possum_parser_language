const std = @import("std");
const Ast = @import("ast.zig").Ast;
const Elem = @import("./elem.zig").Elem;
const Scanner = @import("scanner.zig").Scanner;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const VM = @import("vm.zig").VM;
const logger = @import("./logger.zig");
const Location = @import("location.zig").Location;

pub const Parser = struct {
    vm: *VM,
    scanner: Scanner,
    current: Token,
    previous: Token,
    skippedWhitespace: bool,
    skippedNewline: bool,
    ast: Ast,

    const Error = error{
        OutOfMemory,
        UnexpectedInput,
    };

    pub fn init(vm: *VM) Parser {
        return Parser{
            .vm = vm,
            .scanner = undefined,
            .current = undefined,
            .previous = undefined,
            .skippedWhitespace = false,
            .skippedNewline = false,
            .ast = Ast.init(vm.allocator),
        };
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit();
    }

    pub fn parse(self: *Parser, source: []const u8) !void {
        self.scanner = Scanner.init(source);

        try self.advance();

        while (!try self.match(.Eof)) {
            try self.ast.pushRoot(try self.statement());
        }

        try self.consume(.Eof, "Expect end of program.");
    }

    pub fn end(self: *Parser) !void {
        self.ast.endLocation = self.previous.loc;
    }

    fn statement(self: *Parser) !usize {
        const node = try self.parseWithPrecedence(.None);

        if (self.check(.Eof) or self.skippedNewline or try self.match(.Semicolon)) {
            return node;
        }

        return self.errorAtCurrent("Expected newline or semicolon between statements");
    }

    fn expression(self: *Parser) Error!usize {
        return self.parseWithPrecedence(.None);
    }

    fn parseWithPrecedence(self: *Parser, precedence: Precedence) Error!usize {
        if (logger.debugParser) logger.debug("parse with precedence {}\n", .{precedence});

        try self.advance();

        // This node var is returned either as an ElemNode if there's no infix,
        // or an OpNode if updated in the while loop.
        var node = try self.prefix(self.previous.tokenType);

        // Binding power of the operator to the left of `node`. If `node` is
        // the very start of the code then the precedence is `.None` and
        // binding power is 0.
        const leftOpBindingPower = precedence.bindingPower().right;

        // Binding power of the operator to the right of `node`. If `node` is
        // the very end of the code then the token referenced here will be
        // `.Eof` which has precedence `.None` and binding power 0.
        var rightOpBindingPower = operatorPrecedence(self.current.tokenType).bindingPower().left;

        // Iterate over tokens and build up a right-leaning AST, as long as the
        // right binding power is greater then the left binding power. When
        // called as `parseWithPrecedence(.None)` we know that all tokens will
        // be consumed until another token with precedence `.None`/`.End` is
        // found. This happens when the next token is not an infix operator.
        //
        // We also call `parseWithPrecedence` recursively inside of `infix`,
        // always with a precedence higher than `.None`. While
        // `parseWithPrecedence` produces right-leaning ASTs, recursive
        // functions such as `infix` produce left-leaning ASTs.
        //
        // The result of this while-loop and recursive call combination is an
        // AST where the root node has the lowest binding power, while nodes
        // farther out in the AST have higher binding power.
        while (leftOpBindingPower < rightOpBindingPower) {
            try self.advance();
            node = try self.infix(self.previous.tokenType, node);
            rightOpBindingPower = operatorPrecedence(self.current.tokenType).bindingPower().left;
        }

        return node;
    }

    fn prefix(self: *Parser, tokenType: TokenType) !usize {
        if (logger.debugParser) logger.debug("prefix {}\n", .{tokenType});

        return switch (tokenType) {
            .LeftParen => self.grouping(),
            .LowercaseIdentifier => self.parserVar(),
            .UppercaseIdentifier => self.valueVar(),
            .String => self.string(),
            .Integer => self.integer(),
            .Float => self.float(),
            .True, .False, .Null => self.literal(),
            else => self.errorAtPrevious("Expect expression."),
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
            .Equal,
            => self.binaryOp(leftNode),
            .Comma => self.paramsOrArgs(leftNode),
            .QuestionMark => self.conditionalIfThenOp(leftNode),
            .Colon => self.conditionalThenElseOp(leftNode),
            .LeftParen => {
                if (!self.skippedWhitespace) {
                    return self.callOrDefineFunction(leftNode);
                } else {
                    return self.errorAtPrevious("Expected infix operator.");
                }
            },
            else => self.errorAtPrevious("Expect infix operator."),
        };
    }

    fn parserVar(self: *Parser) !usize {
        const t = self.previous;
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.pushElem(Elem.parserVar(sId), t.loc);
    }

    fn valueVar(self: *Parser) !usize {
        const t = self.previous;
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.pushElem(Elem.valueVar(sId), t.loc);
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
                        return self.errorAtPrevious("Expect single character for character range");
                    }
                } else {
                    return self.errorAtPrevious("Expect second string for character range");
                }
            } else {
                return self.errorAtPrevious("Expect second period");
            }
        } else {
            const sId = try self.vm.strings.insert(s1);
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
                            return self.errorAtPrevious("Could not parse number");
                        }
                    } else {
                        return self.errorAtPrevious("Expect integer");
                    }
                } else {
                    return self.errorAtPrevious("Expect second period");
                }
            } else {
                const sId1 = try self.vm.strings.insert(s1);
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
            const sId = try self.vm.strings.insert(t.lexeme);
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
        if (logger.debugParser) logger.debug("binary op {}\n", .{self.previous.tokenType});

        const t = self.previous;

        const rightNodeId = try self.parseWithPrecedence(operatorPrecedence(t.tokenType));

        const infixType: Ast.InfixType = switch (t.tokenType) {
            .Ampersand => .TakeRight,
            .Bang => .Backtrack,
            .Bar => .Or,
            .DollarSign => .Return,
            .GreaterThan => .TakeRight,
            .LessThan => .TakeLeft,
            .LessThanDash => .Destructure,
            .Plus => .Merge,
            .Equal => .DeclareGlobal,
            else => unreachable,
        };

        return self.ast.pushInfix(infixType, leftNodeId, rightNodeId, t.loc);
    }

    fn paramsOrArgs(self: *Parser, leftNodeId: usize) !usize {
        const t = self.previous;

        const rightNodeId = try self.parseWithPrecedence(operatorPrecedence(t.tokenType));

        return self.ast.pushInfix(.ParamsOrArgs, leftNodeId, rightNodeId, t.loc);
    }

    fn conditionalIfThenOp(self: *Parser, ifNodeId: usize) !usize {
        if (logger.debugParser) logger.debug("conditional if/then {}\n", .{self.previous.tokenType});

        const ifThenLoc = self.previous.loc;

        const thenElseNodeId = try self.parseWithPrecedence(.Conditional);

        const ifThenNodeId = try self.ast.pushInfix(.ConditionalIfThen, ifNodeId, thenElseNodeId, ifThenLoc);

        return ifThenNodeId;
    }

    fn conditionalThenElseOp(self: *Parser, thenNodeId: usize) !usize {
        if (logger.debugParser) logger.debug("conditional then/else {}\n", .{self.previous.tokenType});

        const thenElseLoc = self.previous.loc;

        const elseNodeId = try self.parseWithPrecedence(.Conditional);

        const thenElseNodeId = try self.ast.pushInfix(.ConditionalThenElse, thenNodeId, elseNodeId, thenElseLoc);

        return thenElseNodeId;
    }

    fn callOrDefineFunction(self: *Parser, functionNameNodeId: usize) !usize {
        const callOrDefineLoc = self.previous.loc;

        if (try self.match(.RightParen)) {
            return functionNameNodeId;
        } else {
            const paramsOrArgsNodeId = try self.parseWithPrecedence(.None);
            try self.consume(.RightParen, "Expected closing ')'");

            return self.ast.pushInfix(
                .CallOrDefineFunction,
                functionNameNodeId,
                paramsOrArgsNodeId,
                callOrDefineLoc,
            );
        }
    }

    pub fn advance(self: *Parser) !void {
        self.skippedWhitespace = false;
        self.skippedNewline = false;
        self.previous = self.current;

        while (self.scanner.next()) |token| {
            if (token.isType(.Error)) {
                return self.errorAtCurrent(self.current.lexeme);
            } else if (token.isType(.WhitespaceWithNewline)) {
                self.skippedWhitespace = true;
                self.skippedNewline = true;
            } else if (token.isType(.Whitespace)) {
                self.skippedWhitespace = true;
            } else {
                self.current = token;
                break;
            }
        }
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

    fn errorAtCurrent(self: *Parser, message: []const u8) Error {
        return errorAt(&self.current, message);
    }

    fn errorAtPrevious(self: *Parser, message: []const u8) Error {
        return errorAt(&self.previous, message);
    }

    fn errorAt(token: *Token, message: []const u8) Error {
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

        return Error.UnexpectedInput;
    }

    fn operatorPrecedence(tokenType: TokenType) Precedence {
        return switch (tokenType) {
            .LeftParen => .CallOrDefineFunction,
            .Comma => .FunctionArgOrParam,
            .Bang,
            .Plus,
            .Bar,
            .GreaterThan,
            .LessThan,
            .LessThanDash,
            .DollarSign,
            => .StandardInfix,
            .Ampersand => .Sequence,
            .QuestionMark,
            .Colon,
            => .Conditional,
            .Equal => .DeclareGlobal,
            else => .None,
        };
    }

    const Precedence = enum {
        CallOrDefineFunction,
        FunctionArgOrParam,
        StandardInfix,
        Sequence,
        Conditional,
        DeclareGlobal,
        None,

        pub fn bindingPower(precedence: Precedence) struct { left: u4, right: u4 } {
            return switch (precedence) {
                .CallOrDefineFunction => .{ .left = 11, .right = 12 },
                .FunctionArgOrParam => .{ .left = 10, .right = 9 },
                .StandardInfix => .{ .left = 7, .right = 8 },
                .Sequence => .{ .left = 5, .right = 6 },
                .Conditional => .{ .left = 4, .right = 3 },
                .DeclareGlobal => .{ .left = 2, .right = 2 },
                .None => .{ .left = 0, .right = 0 },
            };
        }
    };
};
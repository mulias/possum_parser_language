const std = @import("std");
const unicode = std.unicode;
const ArrayList = std.ArrayListUnmanaged;
const AnyWriter = std.io.AnyWriter;
const Ast = @import("ast.zig").Ast;
const Elem = @import("elem.zig").Elem;
const HighlightConfig = @import("highlight.zig").HighlightConfig;
const highlightRegion = @import("highlight.zig").highlightRegion;
const Module = @import("module.zig").Module;
const Region = @import("region.zig").Region;
const Scanner = @import("scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const VM = @import("vm.zig").VM;
const Writers = @import("writer.zig").Writers;
const parsing = @import("parsing.zig");

pub const Parser = struct {
    vm: *VM,
    scanner: Scanner,
    source: []const u8,
    module: Module,
    token: Token,
    tokenSkippedWhitespace: bool,
    tokenSkippedNewline: bool,
    ast: Ast,
    writers: Writers,
    printDebug: bool,

    const Error = error{
        OutOfMemory,
        UnexpectedInput,
        CodepointTooLarge,
        Utf8CannotEncodeSurrogateHalf,
        IntegerOverflow,
    } || AnyWriter.Error;

    pub fn init(vm: *VM, module: Module) Parser {
        const ast = Ast.init(vm.allocator);
        return initWithAst(vm, module, ast);
    }

    fn initWithAst(vm: *VM, module: Module, ast: Ast) Parser {
        return Parser{
            .vm = vm,
            .scanner = undefined,
            .source = undefined,
            .module = module,
            .token = undefined,
            .tokenSkippedWhitespace = false,
            .tokenSkippedNewline = false,
            .ast = ast,
            .writers = vm.writers,
            .printDebug = vm.config.printParser,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit();
    }

    pub fn parse(self: *Parser) !void {
        self.scanner = Scanner.init(self.module.source, self.writers, self.vm.config.printScanner);
        self.source = self.module.source;

        try self.advance();

        while (!try self.match(.Eof)) {
            try self.ast.pushRoot(try self.statement());
        }

        try self.consume(.Eof, "Expect end of program.");
    }

    fn parseExpression(self: *Parser, source: []const u8) !*Ast.RNode {
        self.scanner = Scanner.init(source, self.writers, self.vm.config.printScanner);
        self.source = source;
        try self.advance();
        return self.expression();
    }

    fn statement(self: *Parser) !*Ast.RNode {
        const node = try self.parseWithPrecedence(.None);

        if (self.check(.Eof) or self.tokenSkippedNewline or try self.match(.Semicolon)) {
            return node;
        }

        return self.errorAtToken("Expected newline or semicolon between statements");
    }

    fn expression(self: *Parser) Error!*Ast.RNode {
        return self.parseWithPrecedence(.None);
    }

    fn parseWithPrecedence(self: *Parser, precedence: Precedence) Error!*Ast.RNode {
        if (self.printDebug) self.writers.debugPrint("parse with precedence {}\n", .{precedence});

        // This node var is returned either as an ElemNode if there's no infix,
        // or an OpNode if updated in the while loop.
        var node = try self.prefix(self.token.tokenType);

        // Binding power of the operator to the left of `node`. If `node` is
        // the very start of the code then the precedence is `.None` and
        // binding power is 0.
        const leftOpBindingPower = precedence.bindingPower().right;

        // Binding power of the operator to the right of `node`. If `node` is
        // the very end of the code then the token referenced here will be
        // `.Eof` which has precedence `.None` and binding power 0.
        var rightOpBindingPower = operatorPrecedence(self.token.tokenType).bindingPower().left;

        if (self.printDebug) self.writers.debugPrint("Binding power {d} < {d}\n", .{ leftOpBindingPower, rightOpBindingPower });

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
            node = try self.infix(self.token.tokenType, node);
            rightOpBindingPower = operatorPrecedence(self.token.tokenType).bindingPower().left;
        }

        return node;
    }

    fn prefix(self: *Parser, tokenType: TokenType) !*Ast.RNode {
        if (self.printDebug) self.writers.debugPrint("prefix {}\n", .{tokenType});

        return switch (tokenType) {
            .Minus => self.negate(),
            .LeftParen => self.grouping(),
            .LeftBracket => self.array(),
            .LeftBrace => self.object(),
            .LowercaseIdentifier => self.parserVar(),
            .UnderscoreIdentifier,
            .UppercaseIdentifier,
            => self.valueVar(),
            .SingleQuoteStringStart,
            .DoubleQuoteStringStart,
            => self.string(),
            .BacktickStringStart => self.backtickString(),
            .Integer => self.integer(),
            .Float => self.float(),
            .Scientific => self.scientific(),
            .True, .False, .Null => self.literal(),
            .DotDot => self.upperBoundedRange(),
            .DollarSign => self.valueLabel(),
            else => self.errorAtToken("Expect expression."),
        };
    }

    fn infix(self: *Parser, tokenType: TokenType, leftNode: *Ast.RNode) !*Ast.RNode {
        if (self.printDebug) self.writers.debugPrint("infix {}\n", .{tokenType});

        return switch (tokenType) {
            .Ampersand,
            .Bang,
            .Bar,
            .DashGreaterThan,
            .DollarSign,
            .GreaterThan,
            .LessThan,
            .Plus,
            .Minus,
            .Equal,
            => self.binaryOp(leftNode),
            .QuestionMark => self.conditionalOp(leftNode),
            .LeftParen => {
                if (!self.tokenSkippedWhitespace) {
                    return self.callOrDefineFunction(leftNode);
                } else {
                    return self.errorAtToken("Expected infix operator.");
                }
            },
            .DotDot => {
                if (!self.tokenSkippedWhitespace) {
                    return self.fullOrLowerBoundedRange(leftNode);
                } else {
                    return self.errorAtToken("Expected infix operator.");
                }
            },
            else => self.errorAtToken("Expect infix operator."),
        };
    }

    fn parserVar(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.createElem(Elem.parserVar(sId), t.region);
    }

    fn valueVar(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.createElem(Elem.valueVar(sId), t.region);
    }

    fn string(self: *Parser) Error!*Ast.RNode {
        const start_token = self.token;
        const quote_type = start_token.tokenType;

        self.scanner.setStringMode(quote_type);

        var first_part_token: ?Token = null;
        var template_parts = ArrayList(*Ast.RNode){};
        var final: *Ast.RNode = undefined;

        while (true) {
            try self.advance();

            switch (self.token.tokenType) {
                .StringContent => {
                    const token = self.token;

                    if (template_parts.items.len > 0) {
                        const sid = self.internUnescaped(token.lexeme) catch |e| switch (e) {
                            error.InvalidEscapeSequence => return self.errorAt(token, "Invalid escape sequence in string."),
                            else => |unhandled| return unhandled,
                        };
                        const part = try self.ast.createElem(Elem.string(sid), token.region);

                        try template_parts.append(self.ast.arena.allocator(), part);
                    } else {
                        first_part_token = token;
                    }
                },
                .TemplateStart => {
                    if (template_parts.items.len == 0) {
                        if (first_part_token) |leading_string_part| {
                            const sid = self.internUnescaped(leading_string_part.lexeme) catch |e| switch (e) {
                                error.InvalidEscapeSequence => return self.errorAt(leading_string_part, "Invalid escape sequence in string."),
                                else => |unhandled| return unhandled,
                            };
                            const part = try self.ast.createElem(Elem.string(sid), leading_string_part.region);
                            try template_parts.append(self.ast.arena.allocator(), part);
                        }
                    }

                    self.scanner.setNormalMode();
                    try self.advance();

                    if (self.token.tokenType != .RightParen) {
                        const expr = try self.expression();
                        try template_parts.append(self.ast.arena.allocator(), expr);

                        if (self.token.tokenType != .RightParen) {
                            return self.errorAtToken("Expect ')' after expression.");
                        }
                    }
                    self.scanner.setStringMode(quote_type);
                },
                .StringEnd => {
                    const end_token = self.token;
                    const string_region = start_token.region.merge(end_token.region);

                    if (template_parts.items.len > 0) {
                        final = try self.ast.createStringTemplate(template_parts, string_region);
                    } else if (first_part_token) |body_token| {
                        const sid = self.internUnescaped(body_token.lexeme) catch |e| switch (e) {
                            error.InvalidEscapeSequence => return self.errorAt(body_token, "Invalid escape sequence in string."),
                            else => |unhandled| return unhandled,
                        };
                        final = try self.ast.createElem(Elem.string(sid), string_region);
                    } else {
                        const sid = self.internUnescaped("") catch |e| switch (e) {
                            error.InvalidEscapeSequence => return self.errorAt(start_token, "Invalid escape sequence in string."),
                            else => |unhandled| return unhandled,
                        };

                        final = try self.ast.createElem(Elem.string(sid), string_region);
                    }

                    break;
                },
                else => return self.errorAtToken("Unexpected token in string"),
            }
        }

        self.scanner.setNormalMode();
        try self.advance();
        return final;
    }

    fn backtickString(self: *Parser) !*Ast.RNode {
        const start_token = self.token;

        self.scanner.setBacktickStringMode();
        try self.advance();

        switch (self.token.tokenType) {
            .StringContent => {
                const body_token = self.token;
                try self.advance(); // advance to StringEnd
                if (self.token.tokenType != .StringEnd) {
                    return self.errorAtToken("Expected end of string");
                }
                const end_token = self.token;
                self.scanner.setNormalMode();
                try self.advance(); // advance past the StringEnd

                const sid = try self.vm.strings.insert(body_token.lexeme);
                return self.ast.createElem(Elem.string(sid), start_token.region.merge(end_token.region));
            },
            .StringEnd => {
                const end_token = self.token;
                self.scanner.setNormalMode();
                try self.advance(); // advance past the StringEnd

                const sid = try self.vm.strings.insert("");
                return self.ast.createElem(Elem.string(sid), start_token.region.merge(end_token.region));
            },
            .Eof => return self.errorAtToken("Unterminated backtick string"),
            else => return self.errorAtToken("Unexpected token in backtick string"),
        }
    }

    fn internUnescaped(self: *Parser, str: []const u8) !StringTable.Id {
        var buffer = try self.vm.allocator.alloc(u8, str.len);
        defer self.vm.allocator.free(buffer);
        var bufferLen: usize = 0;
        var s = str[0..];

        while (s.len > 0) {
            if (s[0] == '\\') {
                if (s[1] == 'u' and s.len >= 8) {
                    // unicode codepoint escape
                    if (parsing.parseCodepoint(s[2..8])) |c| {
                        const bytesWritten = try unicode.utf8Encode(c, buffer[bufferLen..]);
                        bufferLen += bytesWritten;
                        s = s[8..];
                    } else {
                        return error.InvalidEscapeSequence;
                    }
                } else {
                    // ascii escape
                    const byte: u8 = switch (s[1]) {
                        '0' => 0,
                        'a' => 7,
                        'b' => 8,
                        't' => 9,
                        'n' => 10,
                        'v' => 11,
                        'f' => 12,
                        'r' => 13,
                        '"' => 34,
                        '\'' => 39,
                        '\\' => 92,
                        else => return error.InvalidEscapeSequence,
                    };
                    buffer[bufferLen] = byte;
                    bufferLen += 1;
                    s = s[2..];
                }
            } else {
                // Otherwise copy the current byte and iterate.
                buffer[bufferLen] = s[0];
                bufferLen += 1;
                s = s[1..];
            }
        }

        return self.vm.strings.insert(buffer[0..bufferLen]);
    }

    fn integer(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();

        if (t.tokenType == .Integer) {
            return self.ast.createElem(try Elem.numberString(t.lexeme, .Integer, self.vm), t.region);
        } else {
            return self.errorAtPrevious("Expected integer");
        }
    }

    fn float(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();
        return self.ast.createElem(try Elem.numberString(t.lexeme, .Float, self.vm), t.region);
    }

    fn scientific(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();
        return self.ast.createElem(try Elem.numberString(t.lexeme, .Scientific, self.vm), t.region);
    }

    fn literal(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance();
        return switch (t.tokenType) {
            .True => try self.ast.createElem(Elem.boolean(true), t.region),
            .False => try self.ast.createElem(Elem.boolean(false), t.region),
            .Null => try self.ast.createElem(Elem.nullConst, t.region),
            else => unreachable,
        };
    }

    fn grouping(self: *Parser) !*Ast.RNode {
        const start_region = self.token.region;
        try self.advance(); // consume the '('
        const expr = try self.expression();
        if (self.token.tokenType != .RightParen) {
            return self.errorAtToken("Expect ')' after expression.");
        }
        const end_region = self.token.region;
        try self.advance(); // advance past the ')'

        // TODO: make a grouping ast node so that the expr region can just be
        // the inner part
        const grouped_region = start_region.merge(end_region);
        expr.region = grouped_region;
        return expr;
    }

    fn negate(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance(); // consume the '-'

        if (self.tokenSkippedWhitespace) {
            return self.errorAtPrevious("Expected expression");
        }

        const inner = try self.parseWithPrecedence(.Prefix);
        return self.ast.create(.{ .Negation = inner }, t.region.merge(inner.region));
    }

    fn valueLabel(self: *Parser) !*Ast.RNode {
        const t = self.token;
        try self.advance(); // consume the '$'
        const inner = try self.parseWithPrecedence(.Prefix);
        return self.ast.create(.{ .ValueLabel = inner }, t.region);
    }

    fn binaryOp(self: *Parser, left: *Ast.RNode) !*Ast.RNode {
        if (self.printDebug) self.writers.debugPrint("binary op {}\n", .{self.token.tokenType});

        const t = self.token;
        try self.advance(); // advance past the operator token

        const right = try self.parseWithPrecedence(operatorPrecedence(t.tokenType));

        // Trasnform subtraction into Merge with negated right operand
        if (t.tokenType == .Minus) {
            const negated_right = try self.ast.create(.{ .Negation = right }, right.region);
            return self.ast.createInfix(.Merge, left, negated_right, left.region.merge(negated_right.region));
        }

        if (t.tokenType == .Equal) {
            return self.ast.createDeclareGlobal(left, right, left.region.merge(right.region));
        }

        const infixType: Ast.InfixType = switch (t.tokenType) {
            .Ampersand => .TakeRight,
            .Bang => .Backtrack,
            .Bar => .Or,
            .DashGreaterThan => .Destructure,
            .DollarSign => .Return,
            .GreaterThan => .TakeRight,
            .LessThan => .TakeLeft,
            .Plus => .Merge,
            else => unreachable,
        };

        return self.ast.createInfix(infixType, left, right, left.region.merge(right.region));
    }

    fn conditionalOp(self: *Parser, condition: *Ast.RNode) !*Ast.RNode {
        if (self.printDebug) self.writers.debugPrint("conditional {}\n", .{self.token.tokenType});

        try self.advance(); // advance past the '?' token

        const then_branch = try self.parseWithPrecedence(.Conditional);

        if (self.token.tokenType != .Colon) {
            return self.errorAtToken("Expected ':' after then branch in conditional");
        }
        try self.advance(); // advance past the ':'

        const else_branch = try self.parseWithPrecedence(.Conditional);

        return try self.ast.createConditional(
            condition,
            then_branch,
            else_branch,
            condition.region.merge(else_branch.region),
        );
    }

    fn callOrDefineFunction(self: *Parser, function_ident: *Ast.RNode) !*Ast.RNode {
        try self.advance(); // advance past the '('
        if (self.check(.RightParen)) {
            const closing_paren_region = self.token.region;
            try self.advance(); // advance past the ')'
            const empty_args = ArrayList(*Ast.RNode){};
            return self.ast.createFunction(
                function_ident,
                empty_args,
                function_ident.region.merge(closing_paren_region),
            );
        } else {
            const arguments = try self.paramsOrArgs();
            if (self.token.tokenType != .RightParen) {
                return self.errorAtToken("Expected closing ')'");
            }
            const closing_paren_region = self.token.region;
            try self.advance(); // advance past the ')'

            return self.ast.createFunction(
                function_ident,
                arguments,
                function_ident.region.merge(closing_paren_region),
            );
        }
    }

    fn paramsOrArgs(self: *Parser) !ArrayList(*Ast.RNode) {
        var arguments = ArrayList(*Ast.RNode){};

        const first_expr = try self.expression();
        try arguments.append(self.ast.arena.allocator(), first_expr);

        while (try self.match(.Comma) and !self.check(.RightParen)) {
            const expr = try self.expression();
            try arguments.append(self.ast.arena.allocator(), expr);
        }

        return arguments;
    }

    fn upperBoundedRange(self: *Parser) !*Ast.RNode {
        const range_token = self.token;
        try self.advance(); // consume the '..'
        const upper_bound_node = try self.parseWithPrecedence(operatorPrecedence(range_token.tokenType));

        return self.ast.create(
            .{ .Range = .{ .lower = null, .upper = upper_bound_node } },
            range_token.region.merge(upper_bound_node.region),
        );
    }

    fn fullOrLowerBoundedRange(self: *Parser, lower_bound_node: *Ast.RNode) !*Ast.RNode {
        const range_token = self.token;
        try self.advance(); // advance past the '..' token

        const lower_bounded_range_node: Ast.Node = .{ .Range = .{
            .lower = lower_bound_node,
            .upper = null,
        } };
        const lower_bounded_range_region = lower_bound_node.region.merge(range_token.region);

        // If there's whitespace then the range is done
        if (self.tokenSkippedWhitespace) {
            return self.ast.create(
                lower_bounded_range_node,
                lower_bounded_range_region,
            );
        }

        switch (self.token.tokenType) {
            .Integer,
            .SingleQuoteStringStart,
            .DoubleQuoteStringStart,
            .BacktickStringStart,
            .Minus,
            .LeftParen,
            .UnderscoreIdentifier,
            .UppercaseIdentifier,
            => {
                const upper_bound_node = try self.parseWithPrecedence(
                    operatorPrecedence(range_token.tokenType),
                );
                return self.ast.create(
                    .{ .Range = .{
                        .lower = lower_bound_node,
                        .upper = upper_bound_node,
                    } },
                    lower_bound_node.region.merge(upper_bound_node.region),
                );
            },
            else => {
                return self.ast.create(
                    lower_bounded_range_node,
                    lower_bounded_range_region,
                );
            },
        }
    }

    fn array(self: *Parser) Error!*Ast.RNode {
        const region = self.token.region;
        try self.advance(); // consume the '['

        var elements = ArrayList(*Ast.RNode){};

        // Initial spread: [...expr]
        if (try self.match(.DotDotDot)) {
            const empty_array = try self.ast.createArray(elements, region);
            return self.arraySpread(empty_array);
        }

        // Empty array: []
        if (try self.match(.RightBracket)) {
            return self.ast.createArray(elements, region.merge(self.token.region));
        }

        // First element
        const first_expr = try self.expression();
        try elements.append(self.ast.arena.allocator(), first_expr);

        // Remaining elements
        while (try self.match(.Comma)) {
            if (try self.match(.DotDotDot)) {
                // Middle/end spread
                const array_so_far = try self.ast.createArray(elements, region);
                return self.arraySpread(array_so_far);
            } else if (self.check(.RightBracket)) {
                // Trailing comma before closing bracket
                break;
            } else {
                // Regular array element
                const expr = try self.expression();
                try elements.append(self.ast.arena.allocator(), expr);
            }
        }

        return self.finishArray(elements, region);
    }

    fn object(self: *Parser) Error!*Ast.RNode {
        const region = self.token.region;
        try self.advance(); // consume the '{'

        // Initial spread: {...expr}
        if (try self.match(.DotDotDot)) {
            const empty_pairs = ArrayList(Ast.ObjectPair){};
            const empty_object = try self.ast.createObject(empty_pairs, region);
            return self.objectSpread(empty_object);
        }

        // Empty object: {}
        if (try self.match(.RightBrace)) {
            const empty_pairs = ArrayList(Ast.ObjectPair){};
            const end_region = self.token.region;
            return self.ast.createObject(empty_pairs, region.merge(end_region));
        }

        var pairs = ArrayList(Ast.ObjectPair){};

        // First member
        const first_pair = try self.objectPair();
        try pairs.append(self.ast.arena.allocator(), first_pair);

        // Remaining members
        while (try self.match(.Comma)) {
            const comma_region = self.token.region;
            // Check if there's a spread after the comma
            if (try self.match(.DotDotDot)) {
                const obj_so_far = try self.ast.createObject(pairs, region.merge(comma_region));
                return self.objectSpread(obj_so_far);
            } else if (self.check(.RightBrace)) {
                // Trailing comma before closing brace
                break;
            } else {
                // Regular object pair
                const pair = try self.objectPair();
                try pairs.append(self.ast.arena.allocator(), pair);
            }
        }

        // Pure object without spread, use Object AST node
        if (self.token.tokenType != .RightBrace) {
            return self.errorAtToken("Expected closing '}'");
        }
        const end_region = self.token.region;
        try self.advance(); // advance past the '}'
        return self.ast.createObject(pairs, region.merge(end_region));
    }

    fn objectSpread(self: *Parser, left_object: *Ast.RNode) !*Ast.RNode {
        const dots = self.token;
        const spread = try self.expression();
        var result = try self.ast.createInfix(.Merge, left_object, spread, dots.region.merge(spread.region));

        if (try self.match(.Comma)) {
            // Check if there's actually more content after the comma
            if (self.check(.RightBrace)) {
                // Trailing comma - just close and return
                const closing_brace = self.token;
                try self.advance(); // advance past the '}'
                result.region = result.region.merge(closing_brace.region);
                return result;
            } else {
                // More content after comma - parse it without creating another object() call
                const remaining = try self.parseObjectContinuation();
                result = try self.ast.createInfix(.Merge, result, remaining, result.region.merge(remaining.region));
            }
        } else {
            if (self.token.tokenType != .RightBrace) {
                return self.errorAtToken("Expected closing '}'");
            }
            const closing_brace = self.token;
            try self.advance(); // advance past the '}'
            result.region = result.region.merge(closing_brace.region);
        }
        return result;
    }

    fn arraySpread(self: *Parser, left_array: *Ast.RNode) !*Ast.RNode {
        const spread_region = self.token.region;
        const spread_expr = try self.expression();
        var result = try self.ast.createInfix(.Merge, left_array, spread_expr, spread_region);

        if (try self.match(.Comma)) {
            // Check if there's actually more content after the comma
            if (self.check(.RightBracket)) {
                const closing_bracket = self.token;
                try self.advance(); // advance past the ']'
                result.region = result.region.merge(closing_bracket.region);
                return result;
            } else {
                const remaining_elements = try self.parseArrayContinuation();
                result = try self.ast.createInfix(.Merge, result, remaining_elements, result.region.merge(remaining_elements.region));
            }
        } else {
            if (self.token.tokenType != .RightBracket) {
                return self.errorAtToken("Expected closing ']'");
            }
            const closing_bracket = self.token;
            try self.advance(); // advance past the ']'
            result.region = result.region.merge(closing_bracket.region);
        }
        return result;
    }

    // Like array() but handles spreads differently - doesn't wrap them in Merge([], ...)
    fn parseArrayContinuation(self: *Parser) !*Ast.RNode {
        const region = self.token.region;

        // Check for immediate spread
        if (try self.match(.DotDotDot)) {
            // Direct spread - return the spread expression, not Merge([], spread)
            const spread_expr = try self.expression();

            if (try self.match(.Comma)) {
                // Check if there's actually more content after the comma
                if (self.check(.RightBracket)) {
                    // Trailing comma - just close and return
                    const closing_bracket = self.token;
                    try self.advance(); // advance past the ']'
                    spread_expr.region = spread_expr.region.merge(closing_bracket.region);
                    return spread_expr;
                } else {
                    // More content after comma - parse it
                    const remaining = try self.parseArrayContinuation();
                    return try self.ast.createInfix(.Merge, spread_expr, remaining, spread_expr.region.merge(remaining.region));
                }
            } else {
                if (self.token.tokenType != .RightBracket) {
                    return self.errorAtToken("Expected closing ']'");
                }
                const closing_bracket = self.token;
                try self.advance(); // advance past the ']'
                spread_expr.region = spread_expr.region.merge(closing_bracket.region);
                return spread_expr;
            }
        }

        // Standard array parsing for non-spread elements
        var elements = ArrayList(*Ast.RNode){};

        // Parse the first element
        const first_expr = try self.expression();
        try elements.append(self.ast.arena.allocator(), first_expr);

        // Parse remaining elements
        while (try self.match(.Comma)) {
            if (try self.match(.DotDotDot)) {
                // Handle spread: create array with elements so far, then merge with spread
                const array_so_far = try self.ast.createArray(elements, region);
                const spread_expr = try self.expression();
                var result = try self.ast.createInfix(.Merge, array_so_far, spread_expr, array_so_far.region.merge(spread_expr.region));

                _ = try self.match(.Comma);

                if (!self.check(.RightBracket)) {
                    const remaining = try self.parseArrayContinuation();
                    result = try self.ast.createInfix(.Merge, result, remaining, result.region.merge(remaining.region));
                } else {
                    if (self.token.tokenType != .RightBracket) {
                        return self.errorAtToken("Expected closing ']'");
                    }
                    const closing_bracket = self.token;
                    try self.advance(); // advance past the ']'
                    result.region = result.region.merge(closing_bracket.region);
                }

                return result;
            } else if (self.check(.RightBracket)) {
                // Trailing comma before closing bracket
                break;
            } else {
                const expr = try self.expression();
                try elements.append(self.ast.arena.allocator(), expr);
            }
        }

        return self.finishArray(elements, region);
    }

    // Like object() but handles spreads differently - doesn't wrap them in Merge({}, ...)
    fn parseObjectContinuation(self: *Parser) !*Ast.RNode {
        const region = self.token.region;

        // Check for immediate spread
        if (try self.match(.DotDotDot)) {
            // Direct spread - return the spread expression, not Merge({}, spread)
            const spread_expr = try self.expression();

            if (try self.match(.Comma)) {
                // Check if there's actually more content after the comma
                if (self.check(.RightBrace)) {
                    // Trailing comma - just close and return
                    const closing_brace = self.token;
                    try self.advance(); // advance past the '}'
                    spread_expr.region = spread_expr.region.merge(closing_brace.region);
                    return spread_expr;
                } else {
                    // More content after comma - parse it
                    const remaining = try self.parseObjectContinuation();
                    return try self.ast.createInfix(.Merge, spread_expr, remaining, spread_expr.region.merge(remaining.region));
                }
            } else {
                if (self.token.tokenType != .RightBrace) {
                    return self.errorAtToken("Expected closing '}'");
                }
                const closing_brace = self.token;
                try self.advance(); // advance past the '}'
                spread_expr.region = spread_expr.region.merge(closing_brace.region);
                return spread_expr;
            }
        }

        // Standard object parsing for non-spread elements
        var pairs = ArrayList(Ast.ObjectPair){};

        // Parse the first pair
        const first_pair = try self.objectPair();
        try pairs.append(self.ast.arena.allocator(), first_pair);

        // Parse remaining pairs
        while (try self.match(.Comma)) {
            if (try self.match(.DotDotDot)) {
                // Handle spread: create object with pairs so far, then merge with spread
                const object_so_far = try self.ast.createObject(pairs, region);
                const spread_expr = try self.expression();
                var result = try self.ast.createInfix(.Merge, object_so_far, spread_expr, object_so_far.region.merge(spread_expr.region));

                _ = try self.match(.Comma);

                if (!self.check(.RightBrace)) {
                    const remaining = try self.parseObjectContinuation();
                    result = try self.ast.createInfix(.Merge, result, remaining, result.region.merge(remaining.region));
                } else {
                    if (self.token.tokenType != .RightBrace) {
                        return self.errorAtToken("Expected closing '}'");
                    }
                    const closing_brace = self.token;
                    try self.advance(); // advance past the '}'
                    result.region = result.region.merge(closing_brace.region);
                }

                return result;
            } else if (self.check(.RightBrace)) {
                // Trailing comma before closing brace
                break;
            } else {
                const pair = try self.objectPair();
                try pairs.append(self.ast.arena.allocator(), pair);
            }
        }

        if (self.token.tokenType != .RightBrace) {
            return self.errorAtToken("Expected closing '}'");
        }
        const closing_brace = self.token;
        try self.advance(); // advance past the '}'
        return self.ast.createObject(pairs, region.merge(closing_brace.region));
    }

    fn finishArray(self: *Parser, elements: ArrayList(*Ast.RNode), start_region: Region) !*Ast.RNode {
        if (self.token.tokenType != .RightBracket) {
            return self.errorAtToken("Expected closing ']'");
        }
        const end_region = self.token.region;
        try self.advance(); // advance past the ']'
        return self.ast.createArray(elements, start_region.merge(end_region));
    }

    fn objectMembers(self: *Parser, pairs: *ArrayList(Ast.ObjectPair)) !void {
        const pair = try self.objectPair();
        try pairs.append(self.ast.arena.allocator(), pair);

        // Consume a comma if there is one, and then parse another object
        // member unless it's a spread or it was a trailing comma at the end of
        // the object
        if (try self.match(.Comma) and !(self.check(.DotDotDot) or self.check(.RightBrace))) {
            try self.objectMembers(pairs);
        }
    }

    fn objectPair(self: *Parser) !Ast.ObjectPair {
        const key = try self.expression();

        if (self.token.tokenType != .Colon) {
            return self.errorAtToken("Expected ':' after object member key");
        }
        try self.advance(); // advance past the ':'

        const val = try self.expression();

        return Ast.ObjectPair{
            .key = key,
            .value = val,
        };
    }

    pub fn advance(self: *Parser) !void {
        self.tokenSkippedWhitespace = false;
        self.tokenSkippedNewline = false;

        while (self.scanner.next()) |token| {
            if (token.isType(.Error)) {
                return self.errorAt(token, token.lexeme);
            } else if (token.isType(.WhitespaceWithNewline)) {
                self.tokenSkippedWhitespace = true;
                self.tokenSkippedNewline = true;
            } else if (token.isType(.Whitespace)) {
                self.tokenSkippedWhitespace = true;
            } else {
                self.token = token;
                break;
            }
        }
    }

    pub fn advanceKeepWhitespace(self: *Parser) !void {
        self.token = self.token;
        if (self.scanner.next()) |token| {
            if (token.isType(.Error)) {
                return self.errorAt(token, token.lexeme);
            } else {
                self.token = token;
            }
        }
    }

    fn check(self: *Parser, tokenType: TokenType) bool {
        return self.token.tokenType == tokenType;
    }

    fn consume(self: *Parser, tokenType: TokenType, message: []const u8) !void {
        try self.advance();
        if (self.token.tokenType != tokenType) {
            return self.errorAtToken(message);
        }
    }

    fn match(self: *Parser, tokenType: TokenType) !bool {
        if (!self.check(tokenType)) return false;
        try self.advance();
        return true;
    }

    fn errorAtToken(self: *Parser, message: []const u8) Error {
        return self.errorAt(self.token, message);
    }

    fn errorAtPrevious(self: *Parser, message: []const u8) Error {
        return self.errorAt(self.token, message);
    }

    fn errorAt(self: *Parser, token: Token, message: []const u8) Error {
        try self.writers.err.print("\nError at ", .{});
        switch (token.tokenType) {
            .Eof => {
                try self.writers.err.print("end", .{});
            },
            .Error => {},
            else => {
                try self.writers.err.print("'{s}'", .{token.lexeme});
            },
        }
        try self.writers.err.print(": {s}\n\n", .{message});

        if (self.module.name) |name| {
            try self.writers.err.print("{s}: \n", .{name});
        }

        try self.module.highlight(token.region, self.writers.err);

        try self.writers.err.print("\n", .{});

        return Error.UnexpectedInput;
    }

    fn operatorPrecedence(tokenType: TokenType) Precedence {
        return switch (tokenType) {
            .LeftParen => .Function,
            .DotDot => .Range,
            .Plus,
            .Minus,
            .GreaterThan,
            .LessThan,
            .DashGreaterThan,
            .DollarSign,
            => .StandardInfix,
            .Bang,
            .Bar,
            => .Backtrack,
            .Ampersand => .Sequence,
            .QuestionMark => .Conditional,
            .Equal => .DeclareGlobal,
            else => .None,
        };
    }

    const Precedence = enum {
        Function,
        Prefix,
        Range,
        StandardInfix,
        Backtrack,
        Sequence,
        Conditional,
        DeclareGlobal,
        None,

        pub fn bindingPower(precedence: Precedence) struct { left: u4, right: u4 } {
            return switch (precedence) {
                .Function => .{ .left = 11, .right = 12 },
                .Prefix => .{ .left = 10, .right = 10 },
                .Range => .{ .left = 9, .right = 9 },
                .StandardInfix => .{ .left = 7, .right = 8 },
                .Backtrack => .{ .left = 8, .right = 7 },
                .Sequence => .{ .left = 5, .right = 6 },
                .Conditional => .{ .left = 4, .right = 3 },
                .DeclareGlobal => .{ .left = 2, .right = 2 },
                .None => .{ .left = 0, .right = 0 },
            };
        }
    };
};

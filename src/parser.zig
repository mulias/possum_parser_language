const std = @import("std");
const unicode = std.unicode;
const Ast = @import("ast.zig").Ast;
const Elem = @import("elem.zig").Elem;
const Location = @import("location.zig").Location;
const Scanner = @import("scanner.zig").Scanner;
const StringTable = @import("string_table.zig").StringTable;
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const VM = @import("vm.zig").VM;
const WriterError = @import("writer.zig").VMWriter.Error;
const Writers = @import("writer.zig").Writers;
const parsing = @import("parsing.zig");

pub const Parser = struct {
    vm: *VM,
    scanner: Scanner,
    current: Token,
    previous: Token,
    currentSkippedWhitespace: bool,
    currentSkippedNewline: bool,
    previousSkippedWhitespace: bool,
    previousSkippedNewline: bool,
    ast: Ast,
    writers: Writers,
    printDebug: bool,

    const Error = error{
        OutOfMemory,
        UnexpectedInput,
        CodepointTooLarge,
        Utf8CannotEncodeSurrogateHalf,
        IntegerOverflow,
    } || WriterError;

    pub fn init(vm: *VM) Parser {
        const ast = Ast.init(vm.allocator);
        return initWithAst(vm, ast);
    }

    fn initWithAst(vm: *VM, ast: Ast) Parser {
        return Parser{
            .vm = vm,
            .scanner = undefined,
            .current = undefined,
            .previous = undefined,
            .currentSkippedWhitespace = false,
            .currentSkippedNewline = false,
            .previousSkippedWhitespace = false,
            .previousSkippedNewline = false,
            .ast = ast,
            .writers = vm.writers,
            .printDebug = vm.config.printParser,
        };
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit();
    }

    pub fn parse(self: *Parser, source: []const u8) !void {
        self.scanner = Scanner.init(source, self.writers, self.vm.config.printScanner);

        try self.advance();

        while (!try self.match(.Eof)) {
            try self.ast.pushRoot(try self.statement());
        }

        try self.consume(.Eof, "Expect end of program.");
    }

    fn parseExpression(self: *Parser, source: []const u8) !*Ast.LocNode {
        self.scanner = Scanner.init(source, self.writers, self.vm.config.printScanner);
        try self.advance();
        return self.expression();
    }

    fn statement(self: *Parser) !*Ast.LocNode {
        const node = try self.parseWithPrecedence(.None);

        if (self.check(.Eof) or self.currentSkippedNewline or try self.match(.Semicolon)) {
            return node;
        }

        return self.errorAtCurrent("Expected newline or semicolon between statements");
    }

    fn expression(self: *Parser) Error!*Ast.LocNode {
        return self.parseWithPrecedence(.None);
    }

    fn parseWithPrecedence(self: *Parser, precedence: Precedence) Error!*Ast.LocNode {
        if (self.printDebug) self.writers.debugPrint("parse with precedence {}\n", .{precedence});

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
            try self.advance();
            node = try self.infix(self.previous.tokenType, node);
            rightOpBindingPower = operatorPrecedence(self.current.tokenType).bindingPower().left;
        }

        return node;
    }

    fn prefix(self: *Parser, tokenType: TokenType) !*Ast.LocNode {
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
            .String => self.string(),
            .Integer => self.integer(),
            .Float => self.float(),
            .Scientific => self.scientific(),
            .True, .False, .Null => self.literal(),
            .DotDot => self.upperBoundedRange(),
            .DollarSign => self.valueLabel(),
            else => self.errorAtPrevious("Expect expression."),
        };
    }

    fn infix(self: *Parser, tokenType: TokenType, leftNode: *Ast.LocNode) !*Ast.LocNode {
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
            .QuestionMark => self.conditionalIfThenOp(leftNode),
            .Colon => self.conditionalThenElseOp(leftNode),
            .LeftParen => {
                if (!self.previousSkippedWhitespace) {
                    return self.callOrDefineFunction(leftNode);
                } else {
                    return self.errorAtPrevious("Expected infix operator.");
                }
            },
            .DotDot => {
                if (!self.previousSkippedWhitespace) {
                    return self.fullOrLowerBoundedRange(leftNode);
                } else {
                    return self.errorAtPrevious("Expected infix operator.");
                }
            },
            else => self.errorAtPrevious("Expect infix operator."),
        };
    }

    fn parserVar(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.createElem(Elem.parserVar(sId), t.loc);
    }

    fn valueVar(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        const sId = try self.vm.strings.insert(t.lexeme);
        return self.ast.createElem(Elem.valueVar(sId), t.loc);
    }

    fn string(self: *Parser) !*Ast.LocNode {
        const t1 = self.previous;
        const s1 = stringContents(t1.lexeme);

        if (t1.isBacktickString()) {
            const sId = try self.vm.strings.insert(s1);
            return self.ast.createElem(Elem.string(sId), t1.loc);
        }

        const result = try self.internUnescaped(s1);
        const loc_node = try self.ast.createElem(Elem.string(result.sId), t1.loc);

        if (result.rest.len == 0) {
            return loc_node;
        } else {
            return self.stringTemplate(loc_node, result.rest);
        }
    }

    fn stringTemplate(self: *Parser, first_part: *Ast.LocNode, rest: []const u8) !*Ast.LocNode {
        const loc = self.previous.loc;

        // Don't deinit, we want the shared ast to persist
        var templateParser = initWithAst(self.vm, self.ast);

        // There will be at least one more template part
        const templatePartsRest = try templateParser.stringTemplateParts(rest);

        self.ast = templateParser.ast;

        return self.ast.createInfix(
            .StringTemplate,
            first_part,
            templatePartsRest,
            loc,
        );
    }

    fn stringTemplateParts(templateParser: *Parser, str: []const u8) !*Ast.LocNode {
        const loc = templateParser.previous.loc;
        var template: *Ast.LocNode = undefined;
        var rest_bytes: []const u8 = undefined;

        if (str[0] == '%' and str[1] == '(') {
            // Next template part is an expression
            template = try templateParser.parseExpression(str[2..]);

            // Make sure not to strip whitespace after the template part
            if (templateParser.check(.RightParen)) {
                try templateParser.advanceKeepWhitespace();
            } else {
                return templateParser.errorAtCurrent("Expect ')' after expression.");
            }

            rest_bytes = templateParser.scanner.source;
        } else {
            // Next template part is a string
            const result = try templateParser.internUnescaped(str);
            template = try templateParser.ast.createElem(Elem.string(result.sId), loc);
            rest_bytes = result.rest;
        }

        if (rest_bytes.len == 0) {
            return template;
        } else {
            const rest = try templateParser.stringTemplateParts(rest_bytes);

            return templateParser.ast.createInfix(
                .StringTemplateCons,
                template,
                rest,
                loc,
            );
        }
    }

    fn stringContents(str: []const u8) []const u8 {
        return str[1 .. str.len - 1];
    }

    const InternUnescapedResult = struct {
        sId: StringTable.Id,
        rest: []const u8,
    };

    fn internUnescaped(self: *Parser, str: []const u8) !InternUnescapedResult {
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
                        return self.errorAtPrevious("Invalid escape sequence in string.");
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
                        else => return self.errorAtPrevious("Invalid escape sequence in string."),
                    };
                    buffer[bufferLen] = byte;
                    bufferLen += 1;
                    s = s[2..];
                }
            } else if (s[0] == '%' and s[1] == '(') {
                // Start of a string interpolation template.
                break;
            } else {
                // Otherwise copy the current byte and iterate.
                buffer[bufferLen] = s[0];
                bufferLen += 1;
                s = s[1..];
            }
        }

        return .{
            .sId = try self.vm.strings.insert(buffer[0..bufferLen]),
            .rest = s,
        };
    }

    fn characterStringToCodepoint(strToken: Token) ?u21 {
        const str = stringContents(strToken.lexeme);

        if (str.len == 0) return null; // must be at least one byte long

        if (strToken.isBacktickString()) {
            if (str.len == 1) return @as(u21, @intCast(str[1]));
            return null;
        }

        // unicode codepoint escape
        if (str[0] == '\\' and str[1] == 'u' and str.len == 8) {
            return parsing.parseCodepoint(str[2..8]);
        }

        // ascii escape
        if (str[0] == '\\' and str.len == 2) {
            return switch (str[1]) {
                '0' => 0x00,
                'a' => 0x07,
                'b' => 0x08,
                't' => 0x09,
                'n' => 0x0A,
                'v' => 0x0B,
                'f' => 0x0C,
                'r' => 0x0D,
                '"' => 0x22,
                '\'' => 0x27,
                '\\' => 0x5C,
                else => null,
            };
        }

        // Otherwise must be exactly one codepoint
        const codepointLength = unicode.utf8ByteSequenceLength(str[0]) catch 1;
        if (codepointLength == str.len) {
            return unicode.utf8Decode(str) catch null;
        }

        return null;
    }

    fn integer(self: *Parser) !*Ast.LocNode {
        const t = self.previous;

        if (t.tokenType == .Integer) {
            return self.ast.createElem(try Elem.numberString(t.lexeme, .Integer, self.vm), t.loc);
        } else {
            return self.errorAtPrevious("Expected integer");
        }
    }

    fn float(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        return self.ast.createElem(try Elem.numberString(t.lexeme, .Float, self.vm), t.loc);
    }

    fn scientific(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        return self.ast.createElem(try Elem.numberString(t.lexeme, .Scientific, self.vm), t.loc);
    }

    fn literal(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        return switch (t.tokenType) {
            .True => try self.ast.createElem(Elem.boolean(true), t.loc),
            .False => try self.ast.createElem(Elem.boolean(false), t.loc),
            .Null => try self.ast.createElem(Elem.nullConst, t.loc),
            else => unreachable,
        };
    }

    fn grouping(self: *Parser) !*Ast.LocNode {
        const expr = try self.expression();
        try self.consume(.RightParen, "Expect ')' after expression.");
        return expr;
    }

    fn negate(self: *Parser) !*Ast.LocNode {
        const t = self.previous;

        if (self.currentSkippedWhitespace) {
            return self.errorAtPrevious("Expected expression");
        }

        const inner = try self.parseWithPrecedence(.Prefix);
        return self.ast.create(.{ .Negation = inner }, t.loc);
    }

    fn valueLabel(self: *Parser) !*Ast.LocNode {
        const t = self.previous;
        const inner = try self.parseWithPrecedence(.Prefix);
        return self.ast.create(.{ .ValueLabel = inner }, t.loc);
    }

    fn binaryOp(self: *Parser, left: *Ast.LocNode) !*Ast.LocNode {
        if (self.printDebug) self.writers.debugPrint("binary op {}\n", .{self.previous.tokenType});

        const t = self.previous;

        const right = try self.parseWithPrecedence(operatorPrecedence(t.tokenType));

        const infixType: Ast.InfixType = switch (t.tokenType) {
            .Ampersand => .TakeRight,
            .Bang => .Backtrack,
            .Bar => .Or,
            .DashGreaterThan => .Destructure,
            .DollarSign => .Return,
            .GreaterThan => .TakeRight,
            .LessThan => .TakeLeft,
            .Plus => .Merge,
            .Minus => .NumberSubtract,
            .Equal => .DeclareGlobal,
            else => unreachable,
        };

        return self.ast.createInfix(infixType, left, right, t.loc);
    }

    fn conditionalIfThenOp(self: *Parser, if_loc_node: *Ast.LocNode) !*Ast.LocNode {
        if (self.printDebug) self.writers.debugPrint("conditional if/then {}\n", .{self.previous.tokenType});

        const ifThenLoc = self.previous.loc;

        const then_else_loc_node = try self.parseWithPrecedence(.Conditional);

        const if_then_loc_node = try self.ast.createInfix(.ConditionalIfThen, if_loc_node, then_else_loc_node, ifThenLoc);

        return if_then_loc_node;
    }

    fn conditionalThenElseOp(self: *Parser, then_loc_node: *Ast.LocNode) !*Ast.LocNode {
        if (self.printDebug) self.writers.debugPrint("conditional then/else {}\n", .{self.previous.tokenType});

        const thenElseLoc = self.previous.loc;

        const else_loc_node = try self.parseWithPrecedence(.Conditional);

        const then_else_loc_node = try self.ast.createInfix(.ConditionalThenElse, then_loc_node, else_loc_node, thenElseLoc);

        return then_else_loc_node;
    }

    fn callOrDefineFunction(self: *Parser, function_ident: *Ast.LocNode) !*Ast.LocNode {
        const callOrDefineLoc = self.previous.loc;

        if (try self.match(.RightParen)) {
            return function_ident;
        } else {
            const params_or_args = try self.paramsOrArgs();
            try self.consume(.RightParen, "Expected closing ')'");

            return self.ast.createInfix(
                .CallOrDefineFunction,
                function_ident,
                params_or_args,
                callOrDefineLoc,
            );
        }
    }

    fn paramsOrArgs(self: *Parser) !*Ast.LocNode {
        const expr = try self.expression();

        if (try self.match(.Comma)) {
            const commaLoc = self.previous.loc;
            return self.ast.createInfix(
                .ParamsOrArgs,
                expr,
                try self.paramsOrArgs(),
                commaLoc,
            );
        } else {
            return expr;
        }
    }

    fn upperBoundedRange(self: *Parser) !*Ast.LocNode {
        const range_token = self.previous;
        const upper_bound_node = try self.parseWithPrecedence(operatorPrecedence(range_token.tokenType));

        return self.ast.create(
            .{ .UpperBoundedRange = upper_bound_node },
            Location.new(
                range_token.loc.line,
                range_token.loc.start,
                range_token.loc.length + upper_bound_node.loc.length,
            ),
        );
    }

    fn fullOrLowerBoundedRange(self: *Parser, lower_bound_node: *Ast.LocNode) !*Ast.LocNode {
        const range_token = self.previous;

        const lower_bounded_range_node = .{ .LowerBoundedRange = lower_bound_node };
        const lower_bounded_range_loc = Location.new(
            lower_bound_node.loc.line,
            lower_bound_node.loc.start,
            lower_bound_node.loc.length + range_token.loc.length,
        );

        // If there's whitespace then the range is done
        if (self.currentSkippedWhitespace) {
            return self.ast.create(
                lower_bounded_range_node,
                lower_bounded_range_loc,
            );
        }

        switch (self.current.tokenType) {
            .Integer,
            .String,
            .Minus,
            .LeftParen,
            .UnderscoreIdentifier,
            .UppercaseIdentifier,
            => {
                const upper_bound_node = try self.parseWithPrecedence(
                    operatorPrecedence(range_token.tokenType),
                );
                return self.ast.createInfix(
                    .Range,
                    lower_bound_node,
                    upper_bound_node,
                    Location.new(
                        lower_bound_node.loc.line,
                        lower_bound_node.loc.start,
                        lower_bound_node.loc.length +
                            range_token.loc.length +
                            upper_bound_node.loc.length,
                    ),
                );
            },
            else => {
                return self.ast.create(
                    lower_bounded_range_node,
                    lower_bounded_range_loc,
                );
            },
        }
    }

    fn array(self: *Parser) Error!*Ast.LocNode {
        const loc = self.previous.loc;
        var a = try Elem.Dyn.Array.create(self.vm, 0);
        const elem_loc_node = try self.ast.createElem(a.dyn.elem(), loc);

        if (try self.match(.RightBracket)) {
            return elem_loc_node;
        } else if (try self.match(.DotDotDot)) {
            return self.arraySpread(elem_loc_node);
        } else {
            return self.arrayNonEmpty(elem_loc_node);
        }
    }

    fn arrayNonEmpty(self: *Parser, head: *Ast.LocNode) !*Ast.LocNode {
        const loc = self.previous.loc;
        const array_elems = try self.arrayElems();

        const left_array = try self.ast.createInfix(
            .ArrayHead,
            head,
            array_elems,
            loc,
        );

        if (try self.match(.DotDotDot)) {
            return try self.arraySpread(left_array);
        } else {
            try self.consume(.RightBracket, "Expected closing ']'");
            return left_array;
        }
    }

    fn arraySpread(self: *Parser, left: *Ast.LocNode) !*Ast.LocNode {
        const loc = self.previous.loc;
        const spread = try self.expression();

        const left_merge = try self.ast.createInfix(.Merge, left, spread, loc);

        if (try self.match(.Comma)) {
            const comma_loc = self.previous.loc;
            const right_array = try self.array();

            return self.ast.createInfix(.Merge, left_merge, right_array, comma_loc);
        } else {
            try self.consume(.RightBracket, "Expected closing ']'");
            return left_merge;
        }
    }

    fn arrayElems(self: *Parser) !*Ast.LocNode {
        const expr = try self.expression();

        // There's another array element and it's not a spread
        if (try self.match(.Comma) and !self.check(.DotDotDot)) {
            const commaLoc = self.previous.loc;
            return self.ast.createInfix(
                .ArrayCons,
                expr,
                try self.arrayElems(),
                commaLoc,
            );
        } else {
            return expr;
        }
    }

    fn object(self: *Parser) Error!*Ast.LocNode {
        const loc = self.previous.loc;
        var o = try Elem.Dyn.Object.create(self.vm, 0);
        const elem_loc_node = try self.ast.createElem(o.dyn.elem(), loc);

        if (try self.match(.RightBrace)) {
            return elem_loc_node;
        } else if (try self.match(.DotDotDot)) {
            return self.objectSpread(elem_loc_node);
        } else {
            return self.objectNonEmpty(elem_loc_node);
        }
    }

    fn objectNonEmpty(self: *Parser, head: *Ast.LocNode) !*Ast.LocNode {
        const loc = self.previous.loc;
        const members = try self.objectMembers();

        const left_object = try self.ast.createInfix(
            .ObjectCons,
            head,
            members,
            loc,
        );

        if (try self.match(.DotDotDot)) {
            return try self.objectSpread(left_object);
        } else {
            try self.consume(.RightBrace, "Expected closing '}'");
            return left_object;
        }
    }

    fn objectSpread(self: *Parser, left: *Ast.LocNode) !*Ast.LocNode {
        const dots = self.previous;
        const spread = try self.expression();

        const left_merge = try self.ast.createInfix(
            .Merge,
            left,
            spread,
            Location.new(
                dots.loc.line,
                dots.loc.start,
                dots.loc.length + spread.loc.length,
            ),
        );

        if (try self.match(.Comma)) {
            const comma_loc = self.previous.loc;
            const right_object = try self.object();

            return self.ast.createInfix(.Merge, left_merge, right_object, comma_loc);
        } else {
            try self.consume(.RightBrace, "Expected closing '}'");
            return left_merge;
        }
    }

    fn objectMembers(self: *Parser) !*Ast.LocNode {
        const pair = try self.objectPair();

        if (try self.match(.Comma) and !self.check(.DotDotDot)) {
            const commaLoc = self.previous.loc;
            return self.ast.createInfix(
                .ObjectCons,
                pair,
                try self.objectMembers(),
                commaLoc,
            );
        } else {
            return pair;
        }
    }

    fn objectPair(self: *Parser) !*Ast.LocNode {
        var key: *Ast.LocNode = undefined;

        if (try self.match(.UppercaseIdentifier)) {
            key = try self.valueVar();
        } else {
            try self.consume(.String, "Expected object member key");
            key = try self.string();
        }

        try self.consume(.Colon, "Expected ':' after object member key");

        const val = try self.expression();

        return self.ast.createInfix(
            .ObjectPair,
            key,
            val,
            Location.new(
                key.loc.line,
                key.loc.start,
                key.loc.length + val.loc.length,
            ),
        );
    }

    pub fn advance(self: *Parser) !void {
        self.previous = self.current;
        self.previousSkippedWhitespace = self.currentSkippedWhitespace;
        self.previousSkippedNewline = self.currentSkippedNewline;
        self.currentSkippedWhitespace = false;
        self.currentSkippedNewline = false;

        while (self.scanner.next()) |token| {
            if (token.isType(.Error)) {
                return self.errorAt(token, token.lexeme);
            } else if (token.isType(.WhitespaceWithNewline)) {
                self.currentSkippedWhitespace = true;
                self.currentSkippedNewline = true;
            } else if (token.isType(.Whitespace)) {
                self.currentSkippedWhitespace = true;
            } else {
                self.current = token;
                break;
            }
        }
    }

    pub fn advanceKeepWhitespace(self: *Parser) !void {
        self.previous = self.current;
        if (self.scanner.next()) |token| {
            if (token.isType(.Error)) {
                return self.errorAt(token, token.lexeme);
            } else {
                self.current = token;
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
        return self.errorAt(self.current, message);
    }

    fn errorAtPrevious(self: *Parser, message: []const u8) Error {
        return self.errorAt(self.previous, message);
    }

    fn errorAt(self: *Parser, token: Token, message: []const u8) Error {
        try token.loc.print(self.writers.err);

        switch (token.tokenType) {
            .Eof => {
                try self.writers.err.print(" Error at end", .{});
            },
            .Error => {},
            else => {
                try self.writers.err.print(" Error at '{s}'", .{token.lexeme});
            },
        }

        try self.writers.err.print(": {s}\n", .{message});

        return Error.UnexpectedInput;
    }

    fn operatorPrecedence(tokenType: TokenType) Precedence {
        return switch (tokenType) {
            .LeftParen => .CallOrDefineFunction,
            .DotDot => .Range,
            .Bang,
            .Plus,
            .Minus,
            .Bar,
            .GreaterThan,
            .LessThan,
            .DashGreaterThan,
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
        Prefix,
        Range,
        StandardInfix,
        Sequence,
        Conditional,
        DeclareGlobal,
        None,

        pub fn bindingPower(precedence: Precedence) struct { left: u4, right: u4 } {
            return switch (precedence) {
                .CallOrDefineFunction => .{ .left = 11, .right = 12 },
                .Prefix => .{ .left = 10, .right = 10 },
                .Range => .{ .left = 9, .right = 9 },
                .StandardInfix => .{ .left = 7, .right = 8 },
                .Sequence => .{ .left = 5, .right = 6 },
                .Conditional => .{ .left = 4, .right = 3 },
                .DeclareGlobal => .{ .left = 2, .right = 2 },
                .None => .{ .left = 0, .right = 0 },
            };
        }
    };
};

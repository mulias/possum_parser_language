const std = @import("std");
const Writer = std.Io.Writer;
const Ast = @import("parsed_ast.zig").Ast;
const RNode = Ast.RNode;
const Node = Ast.Node;
const InfixType = Ast.InfixType;

// Structural single-line pretty-printer. Reprints a parsed AST as source
// from structure alone -- regions are ignored, so an AST built with
// placeholder regions still produces valid, parseable source. The output
// round-trips semantically (parse(format(ast)) is equivalent), not
// byte-for-byte: comments and original line breaks are not preserved, and
// operator spellings/parens are canonical.

// A node whose flat printing could re-associate against a surrounding
// operator is wrapped in parens so the tree's grouping is explicit. The
// formatter carries no precedence knowledge -- it groups every such operand
// unconditionally, which is redundant but always correct. Prefix forms,
// calls, and atoms are primaries that never need wrapping.
fn needsGroup(node: Node) bool {
    return switch (node) {
        .InfixNode, .Conditional, .Range => true,
        else => false,
    };
}

fn infixOp(t: InfixType) []const u8 {
    return switch (t) {
        .Destructure => " -> ",
        .Merge => " + ",
        .Or => " | ",
        .Repeat => " * ",
        .Return => " $ ",
        .TakeLeft => " < ",
        .TakeRight => " > ",
        .Sequence => " & ",
        .NumberSubtract => " - ",
    };
}

pub fn format(ast: *const Ast, writer: *Writer) Writer.Error!void {
    for (ast.roots.items, 0..) |root, i| {
        if (i > 0) {
            const tight = isImport(ast.roots.items[i - 1].node) and isImport(root.node);
            try writer.writeAll(if (tight) "\n" else "\n\n");
        }
        try emit(root, writer);
    }
    if (ast.roots.items.len > 0) try writer.writeByte('\n');
}

fn isImport(node: Node) bool {
    return node == .Import;
}

// Emit an operand, wrapping it in parens when its flat printing could
// re-associate against the surrounding operator.
fn emitGrouped(rnode: *RNode, writer: *Writer) Writer.Error!void {
    const group = needsGroup(rnode.node);
    if (group) try writer.writeByte('(');
    try emit(rnode, writer);
    if (group) try writer.writeByte(')');
}

fn emit(rnode: *RNode, writer: *Writer) Writer.Error!void {
    switch (rnode.node) {
        .InfixNode => |infix| {
            try emitGrouped(infix.left, writer);
            try writer.writeAll(infixOp(infix.infixType));
            try emitGrouped(infix.right, writer);
        },
        .Range => |range| {
            if (range.lower) |lower| try emitGrouped(lower, writer);
            try writer.writeAll("..");
            if (range.upper) |upper| try emitGrouped(upper, writer);
        },
        .Negation => |child| {
            try writer.writeByte('-');
            try emitGrouped(child, writer);
        },
        .ValueLabel => |child| {
            try writer.writeByte('$');
            try emitGrouped(child, writer);
        },
        .Conditional => |cond| {
            try emitGrouped(cond.condition, writer);
            try writer.writeAll(" ? ");
            try emitGrouped(cond.then_branch, writer);
            try writer.writeAll(" : ");
            try emitGrouped(cond.else_branch, writer);
        },
        .DeclareGlobal => |global| {
            try emitGrouped(global.head, writer);
            try writer.writeAll(" = ");
            try emitGrouped(global.body, writer);
        },
        .Function => |function| {
            try emitGrouped(function.name, writer);
            try writer.writeByte('(');
            for (function.paramsOrArgs.items, 0..) |arg, i| {
                if (i > 0) try writer.writeAll(", ");
                try emit(arg, writer);
            }
            try writer.writeByte(')');
        },
        .Array => |array| {
            try writer.writeByte('[');
            for (array.items, 0..) |item, i| {
                if (i > 0) try writer.writeAll(", ");
                try emit(item, writer);
            }
            try writer.writeByte(']');
        },
        .Object => |obj| {
            try writer.writeByte('{');
            for (obj.items, 0..) |pair, i| {
                if (i > 0) try writer.writeAll(", ");
                try emit(pair.key, writer);
                try writer.writeAll(": ");
                try emit(pair.value, writer);
            }
            try writer.writeByte('}');
        },
        .StringTemplate => |template| {
            try writer.writeByte('"');
            for (template.items) |part| {
                if (part.node == .String) {
                    try emitStringContent(part.node.String, writer);
                } else {
                    try writer.writeAll("%(");
                    try emit(part, writer);
                    try writer.writeByte(')');
                }
            }
            try writer.writeByte('"');
        },
        .String => |s| {
            try writer.writeByte('"');
            try emitStringContent(s, writer);
            try writer.writeByte('"');
        },
        .NumberString => |ns| {
            if (ns.negated) try writer.writeByte('-');
            try writer.writeAll(ns.number);
        },
        .NumberFloat => |f| try writer.print("{d}", .{f}),
        .Identifier => |ident| try writer.writeAll(ident.name),
        .True => try writer.writeAll("true"),
        .False => try writer.writeAll("false"),
        .Null => try writer.writeAll("null"),
        .Import => |import| try emitImport(import, writer),
    }
}

// Escape a string's bytes for a double-quoted literal. Mirrors the parser's
// unescape table; bytes below 0x20 without a named escape use \uXXXXXX (six
// hex digits, matching parseCodepoint). Non-ASCII bytes pass through as raw
// UTF-8, which the parser copies verbatim.
fn emitStringContent(s: []const u8, writer: *Writer) Writer.Error!void {
    for (s) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            0 => try writer.writeAll("\\0"),
            7 => try writer.writeAll("\\a"),
            8 => try writer.writeAll("\\b"),
            0x0b => try writer.writeAll("\\v"),
            0x0c => try writer.writeAll("\\f"),
            else => if (c < 0x20)
                try writer.print("\\u{x:0>6}", .{c})
            else
                try writer.writeByte(c),
        }
    }
}

fn emitImport(import: *Ast.ImportNode, writer: *Writer) Writer.Error!void {
    try writer.writeAll(if (import.private) "_!" else "!");
    switch (import.path) {
        .file => |file| {
            try writer.writeByte('"');
            try emitStringContent(file, writer);
            try writer.writeByte('"');
        },
        .stdlib => |name| try writer.writeAll(name),
    }
    if (import.selector) |selector| {
        try writer.writeByte('.');
        try writer.writeAll(selector);
    }
}

const testing = std.testing;
const Parser = @import("parser.zig").Parser;
const Module = @import("../runtime.zig").Module;
const test_writers = @import("../testing.zig").writers;

fn expectFormat(source: []const u8, expected: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    const module = Module{ .id = 0, .name = "test", .source = source };
    var parser = Parser.init(&arena, module, test_writers, .{
        .printScanner = false,
        .printParser = false,
    });
    try parser.parse();

    var buffer: [4096]u8 = undefined;
    var writer = Writer.fixed(&buffer);
    try format(&parser.ast, &writer);

    try testing.expectEqualStrings(expected, buffer[0..writer.end]);
}

// The formatted output re-parses to the same canonical form.
fn expectStable(source: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    const module = Module{ .id = 0, .name = "test", .source = source };
    var parser = Parser.init(&arena, module, test_writers, .{
        .printScanner = false,
        .printParser = false,
    });
    try parser.parse();

    var first: [4096]u8 = undefined;
    var first_writer = Writer.fixed(&first);
    try format(&parser.ast, &first_writer);
    const first_out = first[0..first_writer.end];

    var arena2 = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena2.deinit();
    const module2 = Module{ .id = 0, .name = "test", .source = first_out };
    var parser2 = Parser.init(&arena2, module2, test_writers, .{
        .printScanner = false,
        .printParser = false,
    });
    try parser2.parse();

    var second: [4096]u8 = undefined;
    var second_writer = Writer.fixed(&second);
    try format(&parser2.ast, &second_writer);

    try testing.expectEqualStrings(first_out, second[0..second_writer.end]);
}

test "leaves and literals" {
    try expectFormat("true", "true\n");
    try expectFormat("false", "false\n");
    try expectFormat("null", "null\n");
    try expectFormat("42", "42\n");
    try expectFormat("foo", "foo\n");
    try expectFormat("\"hello\"", "\"hello\"\n");
}

test "infix spacing and canonical operators" {
    try expectFormat("a+b", "a + b\n");
    try expectFormat("a->b", "a -> b\n");
    try expectFormat("a$b", "a $ b\n");
    try expectFormat("a-b", "a - b\n");
    try expectFormat("a&b", "a & b\n");
    try expectFormat("a>b", "a > b\n");
}

test "operator chains group explicitly" {
    try expectFormat("a + b + c", "(a + b) + c\n");
    try expectFormat("a & b & c", "(a & b) & c\n");
    try expectFormat("a + (b + c)", "a + (b + c)\n");
}

test "operator operands are grouped" {
    try expectFormat("a * b + c", "(a * b) + c\n");
    try expectFormat("(a & b) > c", "(a & b) > c\n");
    try expectFormat("-(a + b)", "-(a + b)\n");
    try expectFormat("(a + b)..c", "(a + b)..c\n");
}

test "ranges" {
    try expectFormat("0..9", "0..9\n");
    try expectFormat("1..", "1..\n");
    try expectFormat("..9", "..9\n");
}

test "prefix negation and value label" {
    try expectFormat("-5", "-5\n");
    try expectFormat("$1", "$1\n");
}

test "arrays objects calls delimit without parens" {
    try expectFormat("[a, b, c]", "[a, b, c]\n");
    try expectFormat("[]", "[]\n");
    try expectFormat("{a: 1, b: 2}", "{a: 1, b: 2}\n");
    try expectFormat("{}", "{}\n");
    try expectFormat("f(a, b)", "f(a, b)\n");
    try expectFormat("f()", "f()\n");
    // Elements are fully delimited, so even loose operators need no parens.
    try expectFormat("[a | b, c & d]", "[a | b, c & d]\n");
}

test "conditional" {
    try expectFormat("a ? b : c", "a ? b : c\n");
    try expectFormat("a ? b : c ? d : e", "a ? b : (c ? d : e)\n");
}

test "declare global" {
    try expectFormat("x = 1", "x = 1\n");
    try expectFormat("f(a, b) = a + b", "f(a, b) = (a + b)\n");
}

test "string template" {
    try expectFormat("\"a %(b) c\"", "\"a %(b) c\"\n");
}

test "imports tight, defs blank-separated" {
    try expectFormat("_!stdlib/string\n_!stdlib/array", "_!stdlib/string\n_!stdlib/array\n");
    try expectFormat("x = 1\ny = 2", "x = 1\n\ny = 2\n");
    try expectFormat("!stdlib/json\nx = 1", "!stdlib/json\n\nx = 1\n");
    try expectFormat("!stdlib/json.parse", "!stdlib/json.parse\n");
}

test "string escaping" {
    try expectFormat("\"tab\\tquote\\\"\"", "\"tab\\tquote\\\"\"\n");
}

test "statement starting with a group or range parses after another statement" {
    try expectStable("x = 1\n(a -> B) -> C");
    try expectStable("x = 1\n..9");
}

test "output is stable under reparse" {
    try expectStable("as_number(maybe(\"-\") + _number_integer_part)");
    try expectStable("a + b + c | d & e ? f : g");
    try expectStable("f(a, b) = a -> A & b -> B $ [A, B]");
    try expectStable("hex = digit | (\"a\" | \"A\" $ 10)");
}

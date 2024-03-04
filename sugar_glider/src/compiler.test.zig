const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = @import("testing.zig");
const compiler = @import("compiler.zig");
const Chunk = @import("chunk.zig").Chunk;
const ElemManager = @import("./elem.zig").ElemManager;
const Elem = @import("elem.zig").Elem;
const VM = @import("./vm.zig").VM;
const OpCode = @import("op_code.zig").OpCode;

const CompilerTest = struct {
    allocator: Allocator,
    vm: VM,
    chunk: Chunk,

    pub fn init() CompilerTest {
        var allocator = std.testing.allocator;

        return CompilerTest{
            .allocator = allocator,
            .vm = VM.init(allocator),
            .chunk = Chunk.init(allocator),
        };
    }

    pub fn deinit(self: *CompilerTest) void {
        self.chunk.deinit();
        self.vm.deinit();
    }

    pub fn run(self: *CompilerTest, source: []const u8) !void {
        try compiler.compile(&self.vm, source);
        try testing.expectEqualChunks(&self.chunk, &self.vm.chunk);
    }

    pub fn writeOp(self: *CompilerTest, op: OpCode, line: usize) !void {
        try self.chunk.writeOp(op, line);
    }

    pub fn writeConst(self: *CompilerTest, e: Elem, line: usize) !void {
        var idx = try self.chunk.addConstant(e);
        try self.writeOp(.Constant, line);
        try self.chunk.write(idx, line);
    }

    pub fn writeJump(self: *CompilerTest, op: OpCode, offset: usize, line: usize) !void {
        try self.writeOp(op, line);

        const jump = offset - 1;
        if (jump > std.math.maxInt(u16)) {
            unreachable;
        }

        try self.chunk.write(@as(u8, @intCast((jump >> 8) & 0xff)), line);
        try self.chunk.write(@as(u8, @intCast(jump & 0xff)), line);
    }

    pub fn buildElem(self: *CompilerTest) *ElemManager {
        return &self.vm.elemManager;
    }
};

test "123 | 456" {
    var ct = CompilerTest.init();
    defer ct.deinit();

    const source =
        \\ 123 | 456
        \\
    ;

    try ct.writeConst(try ct.buildElem().integer(123, "123"), 1);
    try ct.writeOp(.RunLiteralParser, 1);
    try ct.writeJump(.JumpIfSuccess, 5, 1);
    try ct.writeConst(try ct.buildElem().integer(456, "456"), 1);
    try ct.writeOp(.RunLiteralParser, 1);
    try ct.writeOp(.Or, 1);
    try ct.writeOp(.End, 2);

    try ct.run(source);
}

// test "'a' > 'b' > 'c' | 'abz'" {
//     var ct = CompilerTest.init();
//     defer ct.deinit();

//     const source =
//         \\ "a" > "b" > "c" | "abz"
//     ;

//     try ct.writeConst(Elem.string("a"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeJump(.JumpIfFailure, 5, 1);
//     try ct.writeConst(Elem.string("b"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.TakeRight, 1);
//     try ct.writeJump(.JumpIfFailure, 5, 1);
//     try ct.writeConst(Elem.string("c"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.TakeRight, 1);
//     try ct.writeJump(.JumpIfSuccess, 5, 1);
//     try ct.writeConst(Elem.string("abz"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.Or, 1);
//     try ct.writeOp(.End, 1);

//     try ct.run(source);
// }

// test "1234 | 5678 | 910" {
//     var ct = CompilerTest.init();
//     defer ct.deinit();

//     const source =
//         \\ 1234 | 5678 | 910
//     ;

//     try ct.writeConst(Elem.integer(1234, "1234"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeJump(.JumpIfSuccess, 5, 1);
//     try ct.writeConst(Elem.integer(5678, "5678"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.Or, 1);
//     try ct.writeJump(.JumpIfSuccess, 5, 1);
//     try ct.writeConst(Elem.integer(910, "910"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.Or, 1);
//     try ct.writeOp(.End, 1);

//     try ct.run(source);
// }

// test "'foo' + 'bar' + 'baz'" {
//     var ct = CompilerTest.init();
//     defer ct.deinit();

//     const source =
//         \\ 'foo' + 'bar' + 'baz'
//     ;

//     try ct.writeConst(Elem.string("foo"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeJump(.JumpIfFailure, 5, 1);
//     try ct.writeConst(Elem.string("bar"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.MergeParsed, 1);
//     try ct.writeJump(.JumpIfFailure, 5, 1);
//     try ct.writeConst(Elem.string("baz"), 1);
//     try ct.writeOp(.RunLiteralParser, 1);
//     try ct.writeOp(.MergeParsed, 1);
//     try ct.writeOp(.End, 1);

//     try ct.run(source);
// }

// test "1 + 2 + 3" {
//     var ct = CompilerTest.init();
//     defer ct.deinit();

//     const source =
//         \\ 1 + 2 + 3
//     ;

//     try ct.expected.writeConst(Elem.integer(1, "1"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.integer(2, "2"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.integer(3, "3"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

// 0000    1 Constant 0: 1
// 0002    | RunLiteralParser
// 0003    | JumpIfFailure 3 -> 10
// 0006    | Constant 1: 2
// 0008    | RunLiteralParser
// 0009    | MergeParsed
// 0010    | JumpIfFailure 10 -> 17
// 0013    | Constant 2: 3
// 0015    | RunLiteralParser
// 0016    | MergeParsed
// 0017    | End
//     try ct.run(source);
// }

// test "1.23 + 10" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 1.23 + 10
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.float(1.23, "1.23"), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.integer(10, "10"), 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "0.1 + 0.2" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 0.1 + 0.2
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.float(0.1, "0.1"), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.float(0.2, "0.2"), 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "1e57 + 3e-4" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 1e57 + 3e-4
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.float(1e57, "1e57"), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.float(3e-4, "3e-4"), 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "1 + 2" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\1 +
//         \\2
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integer(1, "1"), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.integer(2, "2"), 2);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 2);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "'foo' $ 'bar'" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const source =
//         \\ 'foo' $ 'bar'
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string("foo"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeConst(Elem.string("bar"), 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "1 ! 12 ! 123" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 1 ! 12 ! 123
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integer(1, "1"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeOp(.Backtrack, 1);
//     try ct.expected.writeConst(Elem.integer(12, "12"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeOp(.Backtrack, 1);
//     try ct.expected.writeConst(Elem.integer(123, "123"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "'true' ? 'foo' + 'bar' : 'baz'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 'true' ? 'foo' + 'bar' : 'baz'
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string("true"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 12, 1);
//     try ct.expected.writeConst(Elem.string("foo"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.string("bar"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeJump(.Jump, 3, 1);
//     try ct.expected.writeConst(Elem.string("baz"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "1000..10000 | 100..1000" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 1000..10000 | 100..1000
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integerRange(1000, "1000", 10000, "10000"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfSuccess, 4, 1);
//     try ct.expected.writeConst(Elem.integerRange(100, "100", 1000, "1000"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Or, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "-100..-1" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ -100..-1
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integerRange(-100, "-100", -1, "-1"), 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.characterRange('a', 'z'), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.characterRange('o', 'o'), 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.characterRange('l', 'q'), 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "'true' $ true" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 'true' $ true
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string("true"), 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.trueConst, 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "('' $ null) + ('' $ null)" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ ('' $ null) + ('' $ null)
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string(""), 1);
//     try ct.expected.writeOp(.Null, 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 10, 1);
//     try ct.expected.writeConst(Elem.string(""), 1);
//     try ct.expected.writeOp(.Null, 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeOp(.MergeParsed, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// // test "('a' $ [1, 2]) + ('b' $ [true, false])" {
// //     var alloc = std.testing.allocator;

// //     const source =
// //         \\ ('a' $ [1, 2]) + ('b' $ [true, false])
// //     ;

// //     var ct.expected = Chunk.init(alloc);
// //     defer ct.expected.deinit();

// //     var a1 = ArrayList(std.json.Value).init(alloc);
// //     defer a1.deinit();
// //     try a1.append(.{ .integer = 1 });
// //     try a1.append(.{ .integer = 2 });

// //     var a2 = ArrayList(std.json.Value).init(alloc);
// //     defer a2.deinit();
// //     try a2.append(.{ .bool = true });
// //     try a2.append(.{ .bool = false });

// //     try ct.expected.writeConst(Elem.string("a" }, 1);
// //     try ct.expected.writeConst(.{ .Array = a1 }, 1);
// //     try ct.expected.writeOp(.Return, 1);
// //     try ct.expected.writeConst(Elem.string("b" }, 1);
// //     try ct.expected.writeConst(.{ .Array = a2 }, 1);
// //     try ct.expected.writeOp(.Return, 1);
// //     try ct.expected.writeOp(.MergeParsed, 1);
// //     try ct.expected.writeOp(.End, 1);

// //     var chunk = Chunk.init(alloc);
// //     defer chunk.deinit();

// //     const success = try compiler.compile(source, &chunk);

// //     try std.testing.expect(success);
// //     try testing.expectEqualChunks(&ct.expected, &chunk);
// // }

// // test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
// //     var alloc = std.testing.allocator;

// //     const source =
// //         \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
// //     ;

// //     var ct.expected = Chunk.init(alloc);
// //     defer ct.expected.deinit();

// //     var o1 = std.StringArrayHashMap(std.json.Value).init(alloc);
// //     defer o1.deinit();
// //     try o1.put("a", .{ .bool = true });

// //     var o2 = std.StringArrayHashMap(std.json.Value).init(alloc);
// //     defer o2.deinit();
// //     try o2.put("a", .{ .bool = false });
// //     try o2.put("b", .{ .null = undefined });

// //     try ct.expected.writeConst(Elem.integer(123, "123"), 1);
// //     try ct.expected.writeConst(.{ .Object = o1 }, 1);
// //     try ct.expected.writeOp(.Return, 1);
// //     try ct.expected.writeConst(Elem.integer(456, "456"), 1);
// //     try ct.expected.writeConst(.{ .Object = o2 }, 1);
// //     try ct.expected.writeOp(.Return, 1);
// //     try ct.expected.writeOp(.MergeParsed, 1);
// //     try ct.expected.writeOp(.End, 1);

// //     var chunk = Chunk.init(alloc);
// //     defer chunk.deinit();

// //     const success = try compiler.compile(source, &chunk);

// //     try std.testing.expect(success);
// //     try testing.expectEqualChunks(&ct.expected, &chunk);
// // }

// test "'f' <- 'a'..'z' & 12 <- 0..100" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 'f' <- 'a'..'z' & 12 <- 0..100
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string("f"), 1);
//     try ct.expected.writeConst(Elem.characterRange('a', 'z'), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Destructure, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 7, 1);
//     try ct.expected.writeConst(Elem.integer(12, "12"), 1);
//     try ct.expected.writeConst(Elem.integerRange(0, "0", 100, "100"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Destructure, 1);
//     try ct.expected.writeOp(.Sequence, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "42 <- 42.0" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 42 <- 42.0
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integer(42, "42"), 1);
//     try ct.expected.writeConst(Elem.float(42.0, "42.0"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Destructure, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "false <- ('' $ true)" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ false <- ('' $ true)
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeOp(.False, 1);
//     try ct.expected.writeConst(Elem.string(""), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.True, 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeOp(.Destructure, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "('a' + 'b') <- 'ab'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ ('a' + 'b') <- 'ab'
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.string("a"), 1);
//     try ct.expected.writeConst(Elem.string("b"), 1);
//     try ct.expected.writeOp(.MergeElems, 1);
//     try ct.expected.writeConst(Elem.string("ab"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Destructure, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "123 & 456 | 789 $ true & 'xyz'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 123 & 456 | 789 $ true & 'xyz'
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integer(123, "123"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 13, 1);
//     try ct.expected.writeConst(Elem.integer(456, "456"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfSuccess, 4, 1);
//     try ct.expected.writeConst(Elem.integer(789, "789"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Or, 1);
//     try ct.expected.writeOp(.True, 1);
//     try ct.expected.writeOp(.Return, 1);
//     try ct.expected.writeOp(.Sequence, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.string("xyz"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Sequence, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "1 ? 2 & 3 : 4" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 1 ? 2 & 3 : 4
//     ;

//     var ct.expected = Chunk.init(alloc);
//     defer ct.expected.deinit();

//     try ct.expected.writeConst(Elem.integer(1, "1"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 12, 1);
//     try ct.expected.writeConst(Elem.integer(2, "2"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeJump(.JumpIfFailure, 4, 1);
//     try ct.expected.writeConst(Elem.integer(3, "3"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.Sequence, 1);
//     try ct.expected.writeJump(.Jump, 3, 1);
//     try ct.expected.writeConst(Elem.integer(4, "4"), 1);
//     try ct.expected.writeOp(.RunLiteralParser, 1);
//     try ct.expected.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
//     try testing.expectEqualChunks(&ct.expected, &chunk);
// }

// test "'foo' <- 'foo' <- 'foo'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ "foo" <- "foo" <- "foo"
//     ;

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compiler.compile(source, &chunk);

//     try std.testing.expect(success);
// }

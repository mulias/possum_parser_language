const std = @import("std");
const ArrayList = std.ArrayList;
const Scanner = @import("./scanner.zig").Scanner;
const Parser = @import("./parser.zig").Parser;
const Token = @import("./token.zig").Token;
const TokenType = @import("./token.zig").TokenType;
const logger = @import("./logger.zig");
const Chunk = @import("./chunk.zig").Chunk;
const expectEqualChunks = @import("./chunk.zig").expectEqualChunks;

pub fn compile(source: []const u8, chunk: *Chunk) !bool {
    var scanner = Scanner.init(source);
    var parser = Parser.init(&scanner, chunk);

    try parser.program();

    return !parser.hadError;
}

test "123 | 456" {
    var alloc = std.testing.allocator;

    const source =
        \\ 123 | 456
        \\
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 123 }, 1);
    try expectedChunk.writeConst(.{ .Integer = 456 }, 1);
    try expectedChunk.writeOp(.Or, 1);
    try expectedChunk.writeOp(.End, 2);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "'a' > 'b' > 'c' | 'abz'" {
    var alloc = std.testing.allocator;

    const source =
        \\ "a" > "b" > "c" | "abz"
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();
    try expectedChunk.writeConst(.{ .String = "a" }, 1);
    try expectedChunk.writeConst(.{ .String = "b" }, 1);
    try expectedChunk.writeOp(.TakeRight, 1);
    try expectedChunk.writeConst(.{ .String = "c" }, 1);
    try expectedChunk.writeOp(.TakeRight, 1);
    try expectedChunk.writeConst(.{ .String = "abz" }, 1);
    try expectedChunk.writeOp(.Or, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1234 | 5678 | 910" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1234 | 5678 | 910
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 1234 }, 1);
    try expectedChunk.writeConst(.{ .Integer = 5678 }, 1);
    try expectedChunk.writeOp(.Or, 1);
    try expectedChunk.writeConst(.{ .Integer = 910 }, 1);
    try expectedChunk.writeOp(.Or, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "'foo' + 'bar' + 'baz'" {
    var alloc = std.testing.allocator;

    const source =
        \\ 'foo' + 'bar' + 'baz'
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .String = "foo" }, 1);
    try expectedChunk.writeConst(.{ .String = "bar" }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeConst(.{ .String = "baz" }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1 + 2 + 3" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1 + 2 + 3
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 1 }, 1);
    try expectedChunk.writeConst(.{ .Integer = 2 }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeConst(.{ .Integer = 3 }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1.23 + 10" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1.23 + 10
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Float = "1.23" }, 1);
    try expectedChunk.writeConst(.{ .Integer = 10 }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "0.1 + 0.2" {
    var alloc = std.testing.allocator;

    const source =
        \\ 0.1 + 0.2
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Float = "0.1" }, 1);
    try expectedChunk.writeConst(.{ .Float = "0.2" }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1e57 + 3e-4" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1e57 + 3e-4
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Float = "1e57" }, 1);
    try expectedChunk.writeConst(.{ .Float = "3e-4" }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1 + 2" {
    var alloc = std.testing.allocator;

    const source =
        \\1 +
        \\2
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 1 }, 1);
    try expectedChunk.writeConst(.{ .Integer = 2 }, 2);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 2);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "'foo' $ 'bar'" {
    var alloc = std.testing.allocator;

    const source =
        \\ 'foo' $ 'bar'
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .String = "foo" }, 1);
    try expectedChunk.writeConst(.{ .String = "bar" }, 1);
    try expectedChunk.writeOp(.Return, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "1 ! 12 ! 123" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1 ! 12 ! 123
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 1 }, 1);
    try expectedChunk.writeConst(.{ .Integer = 12 }, 1);
    try expectedChunk.writeOp(.Backtrack, 1);
    try expectedChunk.writeConst(.{ .Integer = 123 }, 1);
    try expectedChunk.writeOp(.Backtrack, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

// test "'true' ? 'foo' + 'bar' : 'baz'" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ 'true' ? 'foo' + 'bar' : 'baz'
//     ;

//     var expectedChunk = Chunk.init(alloc);
//     defer expectedChunk.deinit();

//     try expectedChunk.writeConst(.{ .String = "true" }, 1);
//     try expectedChunk.writeConst(.{ .String = "foo" }, 1);
//     try expectedChunk.writeJump(.Conditional, 5, 1);
//     try expectedChunk.writeConst(.{ .String = "bar" }, 1);
//     try expectedChunk.writeOp(.Merge, 1);
//     try expectedChunk.writeJump(.Jump, 3, 1);
//     try expectedChunk.writeConst(.{ .String = "baz" }, 1);
//     try expectedChunk.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compile(source, &chunk);

//     try std.testing.expect(success);
//     try expectEqualChunks(&expectedChunk, &chunk);
// }

test "1000..10000 | 100..1000" {
    var alloc = std.testing.allocator;

    const source =
        \\ 1000..10000 | 100..1000
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .IntegerRange = .{ 1000, 10000 } }, 1);
    try expectedChunk.writeConst(.{ .IntegerRange = .{ 100, 1000 } }, 1);
    try expectedChunk.writeOp(.Or, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "-100..-1" {
    var alloc = std.testing.allocator;

    const source =
        \\ -100..-1
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .IntegerRange = .{ -100, -1 } }, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    var alloc = std.testing.allocator;

    const source =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .CharacterRange = .{ 'a', 'z' } }, 1);
    try expectedChunk.writeConst(.{ .CharacterRange = .{ 'o', 'o' } }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeConst(.{ .CharacterRange = .{ 'l', 'q' } }, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "'true' $ true" {
    var alloc = std.testing.allocator;

    const source =
        \\ 'true' $ true
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .String = "true" }, 1);
    try expectedChunk.writeConst(.{ .True = undefined }, 1);
    try expectedChunk.writeOp(.Return, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "('' $ null) + ('' $ null)" {
    var alloc = std.testing.allocator;

    const source =
        \\ ('' $ null) + ('' $ null)
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .String = "" }, 1);
    try expectedChunk.writeConst(.{ .Null = undefined }, 1);
    try expectedChunk.writeOp(.Return, 1);
    try expectedChunk.writeConst(.{ .String = "" }, 1);
    try expectedChunk.writeConst(.{ .Null = undefined }, 1);
    try expectedChunk.writeOp(.Return, 1);
    try expectedChunk.writeOp(.Merge, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

// test "('a' $ [1, 2]) + ('b' $ [true, false])" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ ('a' $ [1, 2]) + ('b' $ [true, false])
//     ;

//     var expectedChunk = Chunk.init(alloc);
//     defer expectedChunk.deinit();

//     var a1 = ArrayList(std.json.Value).init(alloc);
//     defer a1.deinit();
//     try a1.append(.{ .integer = 1 });
//     try a1.append(.{ .integer = 2 });

//     var a2 = ArrayList(std.json.Value).init(alloc);
//     defer a2.deinit();
//     try a2.append(.{ .bool = true });
//     try a2.append(.{ .bool = false });

//     try expectedChunk.writeConst(.{ .String = "a" }, 1);
//     try expectedChunk.writeConst(.{ .Array = a1 }, 1);
//     try expectedChunk.writeOp(.Return, 1);
//     try expectedChunk.writeConst(.{ .String = "b" }, 1);
//     try expectedChunk.writeConst(.{ .Array = a2 }, 1);
//     try expectedChunk.writeOp(.Return, 1);
//     try expectedChunk.writeOp(.Merge, 1);
//     try expectedChunk.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compile(source, &chunk);

//     try std.testing.expect(success);
//     try expectEqualChunks(&expectedChunk, &chunk);
// }

// test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
//     var alloc = std.testing.allocator;

//     const source =
//         \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
//     ;

//     var expectedChunk = Chunk.init(alloc);
//     defer expectedChunk.deinit();

//     var o1 = std.StringArrayHashMap(std.json.Value).init(alloc);
//     defer o1.deinit();
//     try o1.put("a", .{ .bool = true });

//     var o2 = std.StringArrayHashMap(std.json.Value).init(alloc);
//     defer o2.deinit();
//     try o2.put("a", .{ .bool = false });
//     try o2.put("b", .{ .null = undefined });

//     try expectedChunk.writeConst(.{ .Integer = 123 }, 1);
//     try expectedChunk.writeConst(.{ .Object = o1 }, 1);
//     try expectedChunk.writeOp(.Return, 1);
//     try expectedChunk.writeConst(.{ .Integer = 456 }, 1);
//     try expectedChunk.writeConst(.{ .Object = o2 }, 1);
//     try expectedChunk.writeOp(.Return, 1);
//     try expectedChunk.writeOp(.Merge, 1);
//     try expectedChunk.writeOp(.End, 1);

//     var chunk = Chunk.init(alloc);
//     defer chunk.deinit();

//     const success = try compile(source, &chunk);

//     try std.testing.expect(success);
//     try expectEqualChunks(&expectedChunk, &chunk);
// }

test "'f' <- 'a'..'z' & 12 <- 0..100" {
    var alloc = std.testing.allocator;

    const source =
        \\ 'f' <- 'a'..'z' & 12 <- 0..100
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .String = "f" }, 1);
    try expectedChunk.writeConst(.{ .CharacterRange = .{ 'a', 'z' } }, 1);
    try expectedChunk.writeOp(.Destructure, 1);
    try expectedChunk.writeConst(.{ .Integer = 12 }, 1);
    try expectedChunk.writeConst(.{ .IntegerRange = .{ 0, 100 } }, 1);
    try expectedChunk.writeOp(.Destructure, 1);
    try expectedChunk.writeOp(.Sequence, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "42 <- 42.0" {
    var alloc = std.testing.allocator;

    const source =
        \\ 42 <- 42.0
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .Integer = 42 }, 1);
    try expectedChunk.writeConst(.{ .Float = "42.0" }, 1);
    try expectedChunk.writeOp(.Destructure, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

test "false <- ('' $ true)" {
    var alloc = std.testing.allocator;

    const source =
        \\ false <- ('' $ true)
    ;

    var expectedChunk = Chunk.init(alloc);
    defer expectedChunk.deinit();

    try expectedChunk.writeConst(.{ .False = undefined }, 1);
    try expectedChunk.writeConst(.{ .String = "" }, 1);
    try expectedChunk.writeConst(.{ .True = undefined }, 1);
    try expectedChunk.writeOp(.Return, 1);
    try expectedChunk.writeOp(.Destructure, 1);
    try expectedChunk.writeOp(.End, 1);

    var chunk = Chunk.init(alloc);
    defer chunk.deinit();

    const success = try compile(source, &chunk);

    try std.testing.expect(success);
    try expectEqualChunks(&expectedChunk, &chunk);
}

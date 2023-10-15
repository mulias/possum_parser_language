const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = @import("testing.zig");
const VM = @import("vm.zig").VM;
const value = @import("value.zig");
const logger = @import("./logger.zig");

test "'a' > 'b' > 'c' | 'abz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'a' > 'b' > 'c' | 'abz'
    ;

    const result1 = try vm.interpret(parser, "abc");
    try testing.expectSuccess(result1, 0, 3, "\"c\"");

    const result2 = try vm.interpret(parser, "abzsss");
    try testing.expectSuccess(result2, 0, 3, "\"abz\"");

    const result3 = try vm.interpret(parser, "ababz");
    try testing.expectFailure(result3);
}

test "1234 | 5678 | 910" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1234 | 5678 | 910
    ;

    const result = try vm.interpret(parser, "56789");
    try testing.expectSuccess(result, 0, 4, "5678");
}

test "'foo' + 'bar' + 'baz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'foo' + 'bar' + 'baz'
    ;

    const result = try vm.interpret(parser, "foobarbaz");
    try testing.expectSuccess(result, 0, 9, "\"foobarbaz\"");
}

test "1 + 2 + 3" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1 + 2 + 3
    ;

    const result = try vm.interpret(parser, "123");
    try testing.expectSuccess(result, 0, 3, "6");
}

test "1.23 + 10" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1.23 + 10
    ;

    const result = try vm.interpret(parser, "1.2310");
    try testing.expectSuccess(result, 0, 6, "1.123e+01");
}

test "0.1 + 0.2" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 0.1 + 0.2
    ;

    const result = try vm.interpret(parser, "0.10.2");
    try testing.expectSuccess(result, 0, 6, "3.0000000000000004e-01");
}

test "1e57 + 3e-4" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1e57 + 3e-4
    ;

    const result = try vm.interpret(parser, "1e573e-4");
    try testing.expectSuccess(result, 0, 8, "1.0e+57");
}

test "'foo' $ 'bar'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'foo' $ 'bar'
    ;

    const result1 = try vm.interpret(parser, "foo");
    try testing.expectSuccess(result1, 0, 3, "\"bar\"");

    const result2 = try vm.interpret(parser, "f");
    try testing.expectFailure(result2);
}

test "1 ! 12 ! 123" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1 ! 12 ! 123
    ;

    const result = try vm.interpret(parser, "123");
    try testing.expectSuccess(result, 0, 3, "123");
}

test "'true' ? 'foo' + 'bar' : 'baz', first branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'true' ? 'foo' + 'bar' : 'baz'
    ;

    const result = try vm.interpret(parser, "truefoobar");
    try testing.expectSuccess(result, 0, 10, "\"foobar\"");
}

test "'true' ? 'foo' + 'bar' : 'baz', second branch" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'true' ? 'foo' + 'bar' : 'baz'
    ;

    const result = try vm.interpret(parser, "baz");
    try testing.expectSuccess(result, 0, 3, "\"baz\"");
}

test "1000..10000 | 100..1000" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1000..10000 | 100..1000
    ;

    const result = try vm.interpret(parser, "888");
    try testing.expectSuccess(result, 0, 3, "888");
}

test "-100..-1" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ -100..-1
    ;

    const result = try vm.interpret(parser, "-5");
    try testing.expectSuccess(result, 0, 2, "-5");
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;

    const result = try vm.interpret(parser, "foo");
    try testing.expectSuccess(result, 0, 3, "\"foo\"");
}

test "'true' $ true" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'true' $ true
    ;

    const result = try vm.interpret(parser, "true");
    try testing.expectSuccess(result, 0, 4, "true");
}

test "('' $ null) + ('' $ null)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ ('' $ null) + ('' $ null)
    ;

    const result = try vm.interpret(parser, "");
    try testing.expectSuccess(result, 0, 0, "null");
}

// test "('a' $ [1, 2]) + ('b' $ [true, false])" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ ('a' $ [1, 2]) + ('b' $ [true, false])
//     ;

//     const result = try vm.interpret(parser, "abc");

//     var valueString = ArrayList(u8).init(alloc);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 2);
//     try testing.expectJson(alloc, result.ParserSuccess, "[1,2,true,false]");
// }

// test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(alloc);
//     defer vm.deinit();

//     const parser =
//         \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
//     ;

//     const result = try vm.interpret(parser, "123456");

//     var valueString = ArrayList(u8).init(alloc);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 6);
//     try testing.expectJson(alloc, result.ParserSuccess, "{\"a\":false,\"b\":null}");
// }

test "'f' <- 'a'..'z' & 12 <- 0..100" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 'f' <- 'a'..'z' & 12 <- 0..100
    ;

    const result = try vm.interpret(parser, "f12");
    try testing.expectSuccess(result, 0, 3, "12");
}

test "42 <- 42.0" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 42 <- 42.0
    ;

    const result = try vm.interpret(parser, "42.0");
    try testing.expectSuccess(result, 0, 4, "42.0");
}

test "false <- ('' $ true)" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\  false <- ('' $ true)
    ;

    const result = try vm.interpret(parser, "42.0");
    try testing.expectFailure(result);
}

test "('a' + 'b') <- 'ab'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ ('a' + 'b') <- 'ab'
    ;

    const result = try vm.interpret(parser, "ab");
    try testing.expectSuccess(result, 0, 2, "\"ab\"");
}

test "123 & 456 | 789 $ true & 'xyz'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 123 & 456 | 789 $ true & 'xyz'
    ;

    const result1 = try vm.interpret(parser, "123789xyz");
    try testing.expectSuccess(result1, 0, 9, "\"xyz\"");

    const result2 = try vm.interpret(parser, "12378xyz");
    try testing.expectFailure(result2);
}

test "1 ? 2 & 3 : 4" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ 1 ? 2 & 3 : 4
    ;

    const result1 = try vm.interpret(parser, "123");
    try testing.expectSuccess(result1, 0, 3, "3");

    const result2 = try vm.interpret(parser, "4");
    try testing.expectSuccess(result2, 0, 1, "4");
}

test "'foo' <- 'foo' <- 'foo'" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser =
        \\ "foo" <- "foo" <- "foo"
    ;

    const result = try vm.interpret(parser, "foofoo");
    try testing.expectCompileError(result);
}

test "empty program" {
    var alloc = std.testing.allocator;
    var vm = VM.init(alloc);
    defer vm.deinit();

    const parser = "";

    const result = try vm.interpret(parser, "");
    try testing.expectRuntimeError(result);
}

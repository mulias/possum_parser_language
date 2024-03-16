const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = @import("testing.zig");
const VM = @import("vm.zig").VM;
const logger = @import("./logger.zig");
const Elem = @import("elem.zig").Elem;
const allocator = std.testing.allocator;

test "empty program" {
    const parser = "";
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try std.testing.expectError(
            error.NoMainParser,
            vm.interpret(parser, ""),
        );
    }
}

test "no statement sep" {
    const parser = "123 456";
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try std.testing.expectError(
            error.UnexpectedInput,
            vm.interpret(parser, "123456"),
        );
    }
}

test "empty input" {
    const parser =
        \\ "1" | "a" | "a".."z" | ""
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "\"\""),
            Elem.string(vm.strings.getId("")),
            vm.strings,
        );
    }
}

test "'a' > 'b' > 'c' | 'abz'" {
    const parser =
        \\ 'a' > 'b' > 'c' | 'abz'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abc"),
            Elem.string(vm.strings.getId("c")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abzsss"),
            Elem.string(vm.strings.getId("abz")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "ababz"),
        );
    }
}

test "1234 | 5678 | 910" {
    const parser =
        \\ 1234 | 5678 | 910
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "56789"),
            Elem.integerString(5678, vm.strings.getId("5678")),
            vm.strings,
        );
    }
}

test "'foo' + 'bar' + 'baz'" {
    const parser =
        \\ 'foo' + 'bar' + 'baz'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foobarbaz"),
            (try Elem.Dyn.String.copy(&vm, "foobarbaz")).dyn.elem(),
            vm.strings,
        );
    }
}

test "1 + 2 + 3" {
    const parser =
        \\ 1 + 2 + 3
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(6),
            vm.strings,
        );
    }
}

test "1.23 + 10" {
    const parser =
        \\ 1.23 + 10
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1.2310"),
            Elem.float(11.23),
            vm.strings,
        );
    }
}

test "0.1 + 0.2" {
    const parser =
        \\ 0.1 + 0.2
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0.10.2"),
            Elem.float(0.30000000000000004),
            vm.strings,
        );
    }
}

test "1e57 + 3e-4" {
    const parser =
        \\ 1e57 + 3e-4
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1e573e-4"),
            Elem.float(1.0e+57),
            vm.strings,
        );
    }
}

test "'foo' $ 'bar'" {
    const parser =
        \\ 'foo' $ 'bar'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("bar")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "f"));
    }
}

test "1 ! 12 ! 123" {
    const parser =
        \\ 1 ! 12 ! 123
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integerString(123, vm.strings.getId("123")),
            vm.strings,
        );
    }
}

test "'true' ? 'foo' + 'bar' : 'baz'" {
    const parser =
        \\ 'true' ? 'foo' + 'bar' : 'baz'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "truefoobar"),
            (try Elem.Dyn.String.copy(&vm, "foobar")).dyn.elem(),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "baz"),
            Elem.string(vm.strings.getId("baz")),
            vm.strings,
        );
    }
}

test "1000..10000 | 100..1000" {
    const parser =
        \\ 1000..10000 | 100..1000
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "888"),
            Elem.integer(888),
            vm.strings,
        );
    }
}

test "-100..-1" {
    const parser =
        \\ -100..-1
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-5"),
            Elem.integer(-5),
            vm.strings,
        );
    }
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    const parser =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            (try Elem.Dyn.String.copy(&vm, "foo")).dyn.elem(),
            vm.strings,
        );
    }
}

test "'true' $ true" {
    const parser =
        \\ 'true' $ true
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "true"),
            Elem.trueConst,
            vm.strings,
        );
    }
}

test "('' $ null) + ('' $ null)" {
    const parser =
        \\ ('' $ null) + ('' $ null)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            Elem.nullConst,
            vm.strings,
        );
    }
}

// test "('a' $ [1, 2]) + ('b' $ [true, false])" {
//     var alloc = std.testing.allocator;
//     var vm = try VM.init(allocator);
//     defer vm.deinit();

//     const parser =
//         \\ ('a' $ [1, 2]) + ('b' $ [true, false])
//     ;

//     const result = try vm.interpret(parser, "abc");

//     var valueString = ArrayList(u8).init(allocator);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 2);
//     try testing.expectJson(alloc, result.ParserSuccess, "[1,2,true,false]");
// }

// test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
//     var alloc = std.testing.allocator;
//     var vm = try VM.init(allocator);
//     defer vm.deinit();

//     const parser =
//         \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
//     ;

//     const result = try vm.interpret(parser, "123456");

//     var valueString = ArrayList(u8).init(allocator);
//     defer valueString.deinit();

//     try std.testing.expect(result.ParserSuccess.start == 0);
//     try std.testing.expect(result.ParserSuccess.end == 6);
//     try testing.expectJson(alloc, result.ParserSuccess, "{\"a\":false,\"b\":null}");
// }

test "'f' <- 'a'..'z' & 12 <- 0..100" {
    const parser =
        \\ 'f' <- 'a'..'z' & 12 <- 0..100
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "f12"),
            Elem.integer(12),
            vm.strings,
        );
    }
}

test "42 <- 42.0" {
    const parser =
        \\ 42 <- 42.0
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, "42.0"),
            Elem.floatString(42.0, vm.strings.getId("42.0")),
            vm.strings,
        );
    }
}

test "false <- ('' $ true)" {
    const parser =
        \\  false <- ('' $ true)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "42.0"));
    }
}

test "('a' + 'b') <- 'ab'" {
    const parser =
        \\ ('a' + 'b') <- 'ab'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ab"),
            (try Elem.Dyn.String.copy(&vm, "ab")).dyn.elem(),
            vm.strings,
        );
    }
}

test "123 & 456 | 789 $ true & 'xyz'" {
    const parser =
        \\ 123 & 456 | 789 $ true & 'xyz'
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123789xyz"),
            Elem.string(vm.strings.getId("xyz")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "12378xyz"),
        );
    }
}

test "1 ? 2 & 3 : 4" {
    const parser =
        \\ 1 ? 2 & 3 : 4
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integerString(3, vm.strings.getId("3")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "4"),
            Elem.integerString(4, vm.strings.getId("4")),
            vm.strings,
        );
    }
}

test "1 ? 2 : 3 ? 4 : 5" {
    const parser =
        \\1 ? 2 : 3 ? 4 : 5
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "1"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "12"),
            Elem.integerString(2, vm.strings.getId("2")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "13"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "14"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "15"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "2"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "23"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "24"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "25"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "3"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "34"),
            Elem.integerString(4, vm.strings.getId("4")),
            vm.strings,
        );
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "35"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "4"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "45"));
    }
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "5"),
            Elem.integerString(5, vm.strings.getId("5")),
            vm.strings,
        );
    }
}

test "'foo' <- 'foo' <- 'foo'" {
    const parser =
        \\ "foo" <- "foo" <- "foo"
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try std.testing.expectError(
            error.InvalidAst,
            vm.interpret(parser, "foofoo"),
        );
    }
}

test "a = 'a' ; a + a" {
    const parser =
        \\a = 'a'
        \\a + a
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.String.copy(&vm, "aa")).dyn.elem(),
            vm.strings,
        );
    }
}

test "Foo = true ; 123 $ Foo" {
    const parser =
        \\Foo = true ; 123 $ Foo
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.trueConst,
            vm.strings,
        );
    }
}

test "double(p) = p + p ; double('a')" {
    const parser =
        \\double(p) = p + p
        \\double('a')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.String.copy(&vm, "aa")).dyn.elem(),
            vm.strings,
        );
    }
}

test "scan(p) = p | (char > scan(p)) ; scan('end')" {
    const parser =
        \\scan(p) = p | ('a' > scan(p))
        \\scan('end')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaaaaaend"),
            (try Elem.Dyn.String.copy(&vm, "end")).dyn.elem(),
            vm.strings,
        );
    }
}

test "double(p) = p + p ; double('a' + 'b')" {
    const parser =
        \\double(p) = p + p
        \\double('a' + 'b')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abab"),
            (try Elem.Dyn.String.copy(&vm, "abab")).dyn.elem(),
            vm.strings,
        );
    }
}

test "double(p) = p + p ; double('a' + 'b') + double('x' < 'y')" {
    const parser =
        \\double(p) = p + p
        \\double('a' + 'b') + double('x' < 'y')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ababxyxy"),
            (try Elem.Dyn.String.copy(&vm, "ababxx")).dyn.elem(),
            vm.strings,
        );
    }
}

test "id(A) = '' $ A ; id(true)" {
    const parser =
        \\id(A) = '' $ A
        \\id(true)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ignored"),
            Elem.trueConst,
            vm.strings,
        );
    }
}

test "n = '\n' ; n > n > n > 'wow!'" {
    const parser =
        \\n = '\n'
        \\n > n > n > "wow!"
    ;
    const input =
        \\
        \\
        \\
        \\wow!
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.string(vm.strings.getId("wow!")),
            vm.strings,
        );
    }
}

test "'\\n\\'\\\\' > 0" {
    const parser =
        \\'\n\'\\' > 0
    ;
    const input =
        \\
        \\'\0
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.integerString(0, vm.strings.getId("0")),
            vm.strings,
        );
    }
}

test "c = '\\u0000'..'\\U10FFFF' ; c > (c + c) < c" {
    const parser =
        \\c = '\u0000'..'\U10FFFF'
        \\c > (c + c) < c
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abcd"),
            (try Elem.Dyn.String.copy(&vm, "bc")).dyn.elem(),
            vm.strings,
        );
    }
}

test "c = '\\u0001'..'\\U10FFFE' ; c > (c + c) < c" {
    const parser =
        \\c = '\u0001'..'\U10FFFE'
        \\c > (c + c) < c
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abcd"),
            (try Elem.Dyn.String.copy(&vm, "bc")).dyn.elem(),
            vm.strings,
        );
    }
}

test "n = '\n'..'\n' ; n > n > n > 'wow!'" {
    const parser =
        \\n = '\n'..'\n'
        \\n > n > n > "wow!"
    ;
    const input =
        \\
        \\
        \\
        \\wow!
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.string(vm.strings.getId("wow!")),
            vm.strings,
        );
    }
}

test "A = 100 ; A <- 100" {
    const parser =
        \\A = 100
        \\A <- 100
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "100"),
            Elem.integerString(100, vm.strings.getId("100")),
            vm.strings,
        );
    }
}

test "eql_to(p, V) = V <- p ; eql_to('bar' | 'foo', 'foo')" {
    const parser =
        \\eql_to(p, V) = V <- p
        \\eql_to('bar' | 'foo', 'foo')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("foo")),
            vm.strings,
        );
    }
}

test "last(a, b, c) = a > b > c ; last(1, 2, 3)" {
    const parser =
        \\last(a, b, c) = a > b > c
        \\last(1, 2, 3)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integerString(3, vm.strings.getId("3")),
            vm.strings,
        );
    }
}

test "Foo <- 'foo' $ Foo" {
    const parser =
        \\Foo <- 'foo' $ Foo
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("foo")),
            vm.strings,
        );
    }
}

test "peek(p) = V <- p ! '' $ V ; peek(1) + peek(1) + peek(1)" {
    const parser =
        \\peek(p) = V <- p ! '' $ V
        \\peek(1) + peek(1) + peek(1)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1"),
            Elem.integer(3),
            vm.strings,
        );
    }
}

test "@fail" {
    const parser =
        \\@fail
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "sad"),
        );
    }
}

test "a = b ; b = c ; c = 111 ; a" {
    const parser =
        \\a = b
        \\b = c
        \\c = 111
        \\a
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "111"),
            Elem.integerString(111, vm.strings.getId("111")),
            vm.strings,
        );
    }
}

test "a = b ; b = c('bar') ; c(a) = d(a, 'foo') ; d(a, b) = a + b; a" {
    const parser =
        \\a = b
        \\b = c('bar')
        \\c(a) = d(a, 'foo')
        \\d(a, b) = a + b
        \\a
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "barfoo"),
            (try Elem.Dyn.String.copy(&vm, "barfoo")).dyn.elem(),
            vm.strings,
        );
    }
}

test "@number_of('123')" {
    const parser =
        \\@number_of('123')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(123),
            vm.strings,
        );
    }
}

test "@number_of('123.456')" {
    const parser =
        \\@number_of('123.456')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123.456"),
            Elem.float(123.456),
            vm.strings,
        );
    }
}

test "many('🐀' | skip('🛹'))" {
    const parser =
        \\many(('🐀' $ 1) | skip('🛹'))
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "🛹🛹🛹🐀🐀🛹🐀🛹🐀🐀"),
            Elem.integer(5),
            vm.strings,
        );
    }
}

test "123 + (C <- (B <- 456))" {
    const parser =
        \\123 + (C <- (B <- 456))
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123456"),
            Elem.integer(579),
            vm.strings,
        );
    }
}

test "foo(a) = a + a ; foo('a' + 'a')" {
    const parser =
        \\foo(a) = a + a
        \\foo('a' + 'a')
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaa"),
            (try Elem.Dyn.String.copy(&vm, "aaaa")).dyn.elem(),
            vm.strings,
        );
    }
}

test "foo(a) = a + a ; bar(p) = p ; foo(bar('a' + 'a'))" {
    const parser =
        \\foo(a) = a + a
        \\bar(p) = p
        \\foo(bar('a' + 'a'))
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaa"),
            (try Elem.Dyn.String.copy(&vm, "aaaa")).dyn.elem(),
            vm.strings,
        );
    }
}

test "foo(N) = N <- 12 ; A <- const(12) & foo(A)" {
    const parser =
        \\is_twelve(N) = 12 <- const(N)
        \\A <- const(12) & is_twelve(A)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "input"),
            Elem.integer(12),
            vm.strings,
        );
    }
}

test "bar(N <- 12) $ N ; bar(p) = p" {
    const parser =
        \\bar(N <- 12) $ N
        \\bar(p) = p
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try std.testing.expectError(
            error.RuntimeError,
            vm.interpret(parser, "12"),
        );
    }
}

test "foo(N) = bar(N <- 12) ; bar(p) = p ; foo(11)" {
    const parser =
        \\foo(N) = bar(N <- 12)
        \\bar(p) = p
        \\foo(11)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "12"));
    }
}

test "foo(N) = bar(bar(bar(N <- 12))) ; bar(p) = p ; foo(11)" {
    const parser =
        \\foo(N) = bar(bar(bar(N <- 12)))
        \\bar(p) = p
        \\foo(11)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "12"));
    }
}

test "foo(N) = bar(bar(N <- 3) + bar(N <- 3)) ; bar(p) = p ; foo(0)" {
    const parser =
        \\foo(N) = bar(bar(N <- 3) + bar(N <- 3))
        \\bar(p) = p
        \\foo(0)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "33"));
    }
}

test "foo(N) = bar(bar(N <- 3) + bar(N <- 3)) ; bar(p) = p ; foo(3)" {
    const parser =
        \\foo(N) = bar(bar(N <- 3) + bar(N <- 3))
        \\bar(p) = p
        \\foo(3)
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "33"),
            Elem.integer(6),
            vm.strings,
        );
    }
}

test "Max function locals" {
    const parser =
        \\foo(
        \\  A0, A1, A2, A3, A4, A5, A6, A7, A8, A9,
        \\  A10, A11, A12, A13, A14, A15, A16, A17, A18, A19,
        \\  A20, A21, A22, A23, A24, A25, A26, A27, A28, A29,
        \\  A30, A31, A32, A33, A34, A35, A36, A37, A38, A39,
        \\  A40, A41, A42, A43, A44, A45, A46, A47, A48, A49,
        \\  A50, A51, A52, A53, A54, A55, A56, A57, A58, A59,
        \\  A60, A61, A62, A63, A64, A65, A66, A67, A68, A69,
        \\  A70, A71, A72, A73, A74, A75, A76, A77, A78, A79,
        \\  A80, A81, A82, A83, A84, A85, A86, A87, A88, A89,
        \\  A90, A91, A92, A93, A94, A95, A96, A97, A98, A99,
        \\  A100, A101, A102, A103, A104, A105, A106, A107, A108, A109,
        \\  A110, A111, A112, A113, A114, A115, A116, A117, A118, A119,
        \\  A120, A121, A122, A123, A124, A125, A126, A127, A128, A129,
        \\  A130, A131, A132, A133, A134, A135, A136, A137, A138, A139,
        \\  A140, A141, A142, A143, A144, A145, A146, A147, A148, A149,
        \\  A150, A151, A152, A153, A154, A155, A156, A157, A158, A159,
        \\  A160, A161, A162, A163, A164, A165, A166, A167, A168, A169,
        \\  A170, A171, A172, A173, A174, A175, A176, A177, A178, A179,
        \\  A180, A181, A182, A183, A184, A185, A186, A187, A188, A189,
        \\  A190, A191, A192, A193, A194, A195, A196, A197, A198, A199,
        \\  A200, A201, A202, A203, A204, A205, A206, A207, A208, A209,
        \\  A210, A211, A212, A213, A214, A215, A216, A217, A218, A219,
        \\  A220, A221, A222, A223, A224, A225, A226, A227, A228, A229,
        \\  A230, A231, A232, A233, A234, A235, A236, A237, A238, A239,
        \\  A240, A241, A242, A243, A244, A245, A246, A247, A248, A249,
        \\  A250, A251, A252, A253, A254
        \\) = "wow"
        \\0
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0"),
            Elem.integerString(0, vm.strings.getId("0")),
            vm.strings,
        );
    }
}

test "Max function locals overflow error" {
    const parser =
        \\foo(
        \\  A0, A1, A2, A3, A4, A5, A6, A7, A8, A9,
        \\  A10, A11, A12, A13, A14, A15, A16, A17, A18, A19,
        \\  A20, A21, A22, A23, A24, A25, A26, A27, A28, A29,
        \\  A30, A31, A32, A33, A34, A35, A36, A37, A38, A39,
        \\  A40, A41, A42, A43, A44, A45, A46, A47, A48, A49,
        \\  A50, A51, A52, A53, A54, A55, A56, A57, A58, A59,
        \\  A60, A61, A62, A63, A64, A65, A66, A67, A68, A69,
        \\  A70, A71, A72, A73, A74, A75, A76, A77, A78, A79,
        \\  A80, A81, A82, A83, A84, A85, A86, A87, A88, A89,
        \\  A90, A91, A92, A93, A94, A95, A96, A97, A98, A99,
        \\  A100, A101, A102, A103, A104, A105, A106, A107, A108, A109,
        \\  A110, A111, A112, A113, A114, A115, A116, A117, A118, A119,
        \\  A120, A121, A122, A123, A124, A125, A126, A127, A128, A129,
        \\  A130, A131, A132, A133, A134, A135, A136, A137, A138, A139,
        \\  A140, A141, A142, A143, A144, A145, A146, A147, A148, A149,
        \\  A150, A151, A152, A153, A154, A155, A156, A157, A158, A159,
        \\  A160, A161, A162, A163, A164, A165, A166, A167, A168, A169,
        \\  A170, A171, A172, A173, A174, A175, A176, A177, A178, A179,
        \\  A180, A181, A182, A183, A184, A185, A186, A187, A188, A189,
        \\  A190, A191, A192, A193, A194, A195, A196, A197, A198, A199,
        \\  A200, A201, A202, A203, A204, A205, A206, A207, A208, A209,
        \\  A210, A211, A212, A213, A214, A215, A216, A217, A218, A219,
        \\  A220, A221, A222, A223, A224, A225, A226, A227, A228, A229,
        \\  A230, A231, A232, A233, A234, A235, A236, A237, A238, A239,
        \\  A240, A241, A242, A243, A244, A245, A246, A247, A248, A249,
        \\  A250, A251, A252, A253, A254, A255
        \\) = "cool"
        \\0
    ;
    {
        var vm = try VM.init(allocator);
        defer vm.deinit();
        try std.testing.expectError(
            error.MaxFunctionLocals,
            vm.interpret(parser, "0"),
        );
    }
}

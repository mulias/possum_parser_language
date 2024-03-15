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

const std = @import("std");
const allocator = std.testing.allocator;
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const VMConfig = @import("vm.zig").Config;
const Writers = @import("writer.zig").Writers;
const testing = @import("testing.zig");

const writers = Writers.initStdIo();
const config = VMConfig{ .includeStdlib = false };

test "empty program" {
    const parser = "";
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "\"\""),
            Elem.inputSubstring(0, 0),
            vm,
        );
    }
}

test "'a' > 'b' > 'c' | 'abz'" {
    const parser =
        \\ 'a' > 'b' > 'c' | 'abz'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abc"),
            Elem.string(vm.strings.getId("c")),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abzsss"),
            Elem.inputSubstring(0, 3),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "56789"),
            Elem.numberString(vm.strings.getId("5678"), .Integer),
            vm,
        );
    }
}

test "'foo' + 'bar' + 'baz'" {
    const parser =
        \\ 'foo' + 'bar' + 'baz'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foobarbaz"),
            (try Elem.Dyn.String.copy(&vm, "foobarbaz")).dyn.elem(),
            vm,
        );
    }
}

test "1 + 2 + 3" {
    const parser =
        \\ 1 + 2 + 3
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(6),
            vm,
        );
    }
}

test "1.23 + 10" {
    const parser =
        \\ 1.23 + 10
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1.2310"),
            Elem.float(11.23),
            vm,
        );
    }
}

test "0.1 + 0.2" {
    const parser =
        \\ 0.1 + 0.2
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0.10.2"),
            Elem.float(0.30000000000000004),
            vm,
        );
    }
}

test "1e57 + 3e-4" {
    const parser =
        \\ 1e57 + 3e-4
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1e573e-4"),
            Elem.float(1.0e+57),
            vm,
        );
    }
}

test "bool(1,0) + bool(1,0)" {
    const parser =
        \\true(t) = t $ true
        \\false(f) = f $ false
        \\boolean(t, f) = true(t) | false(f)
        \\bool = boolean
        \\
        \\bool(1,0) + bool(1,0)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "11"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "10"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "01"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "00"),
            Elem.boolean(false),
            vm,
        );
    }
}

test "'foo' $ 'bar'" {
    const parser =
        \\ 'foo' $ 'bar'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("bar")),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "f"));
    }
}

test "1 ! 12 ! 123" {
    const parser =
        \\ 1 ! 12 ! 123
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.numberString(vm.strings.getId("123"), .Integer),
            vm,
        );
    }
}

test "'true' ? 'foo' + 'bar' : 'baz'" {
    const parser =
        \\ 'true' ? 'foo' + 'bar' : 'baz'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "truefoobar"),
            (try Elem.Dyn.String.copy(&vm, "foobar")).dyn.elem(),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "baz"),
            Elem.string(vm.strings.getId("baz")),
            vm,
        );
    }
}

test "1000..10000 | 100..1000" {
    const parser =
        \\ 1000..10000 | 100..1000
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "888"),
            Elem.integer(888),
            vm,
        );
    }
}

test "-100..-1" {
    const parser =
        \\ -100..-1
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-5"),
            Elem.integer(-5),
            vm,
        );
    }
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    const parser =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            (try Elem.Dyn.String.copy(&vm, "foo")).dyn.elem(),
            vm,
        );
    }
}

test "'true' $ true" {
    const parser =
        \\ 'true' $ true
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "true"),
            Elem.boolean(true),
            vm,
        );
    }
}

test "('' $ null) + ('' $ null)" {
    const parser =
        \\ ('' $ null) + ('' $ null)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            Elem.nullConst,
            vm,
        );
    }
}

test "'a'..'z' -> 'f' & 0..100 -> 12" {
    const parser =
        \\'a'..'z' -> 'f' & 0..100 -> 12
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "f12"),
            Elem.integer(12),
            vm,
        );
    }
}

test "42.0 -> 42" {
    const parser =
        \\42.0 -> 42
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, "42.0"),
            Elem.numberString(vm.strings.getId("42.0"), .Float),
            vm,
        );
    }
}

test "'' $ true -> false" {
    const parser =
        \\'' $ true -> false
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "42.0"));
    }
}

test "123 & 456 | 789 $ true & 'xyz'" {
    const parser =
        \\ 123 & 456 | 789 $ true & 'xyz'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123789xyz"),
            Elem.string(vm.strings.getId("xyz")),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.numberString(vm.strings.getId("3"), .Integer),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "4"),
            Elem.numberString(vm.strings.getId("4"), .Integer),
            vm,
        );
    }
}

test "1 ? 2 : 3 ? 4 : 5" {
    const parser =
        \\1 ? 2 : 3 ? 4 : 5
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "1"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "12"),
            Elem.numberString(vm.strings.getId("2"), .Integer),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "13"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "14"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "15"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "2"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "23"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "24"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "25"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "3"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "34"),
            Elem.numberString(vm.strings.getId("4"), .Integer),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "35"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "4"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "45"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "5"),
            Elem.numberString(vm.strings.getId("5"), .Integer),
            vm,
        );
    }
}

test "'foo' -> 'foo' -> 'foo'" {
    const parser =
        \\ "foo" -> "foo" -> "foo"
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foofoo"),
            Elem.string(vm.strings.getId("foo")),
            vm,
        );
    }
}

test "a = 'a' ; a + a" {
    const parser =
        \\a = 'a'
        \\a + a
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.String.copy(&vm, "aa")).dyn.elem(),
            vm,
        );
    }
}

test "Foo = true ; 123 $ Foo" {
    const parser =
        \\Foo = true ; 123 $ Foo
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.boolean(true),
            vm,
        );
    }
}

test "double(p) = p + p ; double('a')" {
    const parser =
        \\double(p) = p + p
        \\double('a')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.String.copy(&vm, "aa")).dyn.elem(),
            vm,
        );
    }
}

test "scan(p) = p | (char > scan(p)) ; scan('end')" {
    const parser =
        \\scan(p) = p | ('a' > scan(p))
        \\scan('end')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaaaaaend"),
            (try Elem.Dyn.String.copy(&vm, "end")).dyn.elem(),
            vm,
        );
    }
}

test "double(p) = p + p ; double('a' + 'b')" {
    const parser =
        \\double(p) = p + p
        \\double('a' + 'b')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abab"),
            (try Elem.Dyn.String.copy(&vm, "abab")).dyn.elem(),
            vm,
        );
    }
}

test "double(p) = p + p ; double('a' + 'b') + double('x' < 'y')" {
    const parser =
        \\double(p) = p + p
        \\double('a' + 'b') + double('x' < 'y')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ababxyxy"),
            (try Elem.Dyn.String.copy(&vm, "ababxx")).dyn.elem(),
            vm,
        );
    }
}

test "id(A) = '' $ A ; id(true)" {
    const parser =
        \\id(A) = '' $ A
        \\id(true)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ignored"),
            Elem.boolean(true),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.string(vm.strings.getId("wow!")),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.numberString(vm.strings.getId("0"), .Integer),
            vm,
        );
    }
}

test "c = '\\u000000'..'\\u10FFFF' ; c > (c + c) < c" {
    const parser =
        \\c = '\u000000'..'\u10FFFF'
        \\c > (c + c) < c
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abcd"),
            (try Elem.Dyn.String.copy(&vm, "bc")).dyn.elem(),
            vm,
        );
    }
}

test "c = '\\u000001'..'\\u10FFFE' ; c > (c + c) < c" {
    const parser =
        \\c = '\u000001'..'\u10FFFE'
        \\c > (c + c) < c
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abcd"),
            (try Elem.Dyn.String.copy(&vm, "bc")).dyn.elem(),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, input),
            Elem.string(vm.strings.getId("wow!")),
            vm,
        );
    }
}

test "A = 100 ; 100 -> A" {
    const parser =
        \\A = 100
        \\100 -> A
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "100"),
            Elem.numberString(vm.strings.getId("100"), .Integer),
            vm,
        );
    }
}

test "eql_to(p, V) = p -> V ; eql_to('bar' | 'foo', 'foo')" {
    const parser =
        \\eql_to(p, V) = p -> V
        \\eql_to('bar' | 'foo', 'foo')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("foo")),
            vm,
        );
    }
}

test "last(a, b, c) = a > b > c ; last(1, 2, 3)" {
    const parser =
        \\last(a, b, c) = a > b > c
        \\last(1, 2, 3)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.numberString(vm.strings.getId("3"), .Integer),
            vm,
        );
    }
}

test "'foo' -> Foo $ Foo" {
    const parser =
        \\'foo' -> Foo $ Foo
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            Elem.string(vm.strings.getId("foo")),
            vm,
        );
    }
}

test "peek(p) = p -> V ! '' $ V ; peek(1) + peek(1) + peek(1)" {
    const parser =
        \\peek(p) = p -> V ! '' $ V
        \\peek(1) + peek(1) + peek(1)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1"),
            Elem.integer(3),
            vm,
        );
    }
}

test "@fail" {
    const parser =
        \\@fail
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "111"),
            Elem.numberString(vm.strings.getId("111"), .Integer),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "barfoo"),
            (try Elem.Dyn.String.copy(&vm, "barfoo")).dyn.elem(),
            vm,
        );
    }
}

test "@number_of('123')" {
    const parser =
        \\@number_of('123')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(123),
            vm,
        );
    }
}

test "@number_of('123.456')" {
    const parser =
        \\@number_of('123.456')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123.456"),
            Elem.float(123.456),
            vm,
        );
    }
}

test "many(('🐀' $ 1) | skip('🛹'))" {
    const parser =
        \\const(C) = "" $ C
        \\many(p) = p -> First & _many(p, First)
        \\_many(p, Acc) = p -> Next ? _many(p, Acc + Next) : const(Acc)
        \\skip(p) = null(p)
        \\null(n) = n $ null
        \\
        \\many(('🐀' $ 1) | skip('🛹'))
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "🛹🛹🛹🐀🐀🛹🐀🛹🐀🐀"),
            Elem.integer(5),
            vm,
        );
    }
}

test "123 + ((456 -> B) -> C)" {
    const parser =
        \\123 + ((456 -> B) -> C)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123456"),
            Elem.integer(579),
            vm,
        );
    }
}

test "foo(a) = a + a ; foo('a' + 'a')" {
    const parser =
        \\foo(a) = a + a
        \\foo('a' + 'a')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaa"),
            (try Elem.Dyn.String.copy(&vm, "aaaa")).dyn.elem(),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aaaa"),
            (try Elem.Dyn.String.copy(&vm, "aaaa")).dyn.elem(),
            vm,
        );
    }
}

test "is_twelve(N) = ('' $ N) -> 12 ; 12 -> A & is_twelve(A)" {
    const parser =
        \\is_twelve(N) = ("" $ N) -> 12
        \\12 -> A & is_twelve(A)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "12"),
            Elem.integer(12),
            vm,
        );
    }
}

test "bar(12 -> N) $ N ; bar(p) = p" {
    const parser =
        \\bar(12 -> N) $ N
        \\bar(p) = p
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.RuntimeError,
            vm.interpret(parser, "12"),
        );
    }
}

test "foo(N) = bar(12 -> N) ; bar(p) = p ; foo(11)" {
    const parser =
        \\foo(N) = bar(12 -> N)
        \\bar(p) = p
        \\foo(11)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "12"));
    }
}

test "foo(N) = bar(bar(bar(12 -> N))) ; bar(p) = p ; foo(11)" {
    const parser =
        \\foo(N) = bar(bar(bar(12 -> N)))
        \\bar(p) = p
        \\foo(11)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "12"));
    }
}

test "foo(N) = bar(bar(3 -> N) + bar(3 -> N)) ; bar(p) = p ; foo(0)" {
    const parser =
        \\foo(N) = bar(bar(3 -> N) + bar(3 -> N))
        \\bar(p) = p
        \\foo(0)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "33"));
    }
}

test "foo(N) = bar(bar(3 -> N) + bar(3 -> N)) ; bar(p) = p ; foo(3)" {
    const parser =
        \\foo(N) = bar(bar(3 -> N) + bar(3 -> N))
        \\bar(p) = p
        \\foo(3)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "33"),
            Elem.integer(6),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0"),
            Elem.numberString(vm.strings.getId("0"), .Integer),
            vm,
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
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.MaxFunctionLocals,
            vm.interpret(parser, "0"),
        );
    }
}

test "'aa' $ []" {
    const parser =
        \\"aa" $ []
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.Array.create(&vm, 0)).dyn.elem(),
            vm,
        );
    }
}

test "'aa' $ [1, 2, 3]" {
    const parser =
        \\"aa" $ [1, 2, 3]
    ;
    {
        const array = [_]Elem{ Elem.integer(1), Elem.integer(2), Elem.integer(3) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "'a' -> A $ [[A]]" {
    const parser =
        \\'a' -> A $ [[A]]
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        const result = try vm.interpret(parser, "a");

        const innerArray = [_]Elem{Elem.string(vm.strings.getId("a"))};
        const outerArray = [_]Elem{(try Elem.Dyn.Array.copy(&vm, &innerArray)).dyn.elem()};
        const array = (try Elem.Dyn.Array.copy(&vm, &outerArray)).dyn.elem();

        try testing.expectSuccess(result, array, vm);
    }
}

test "('a' $ [1, 2]) + ('b' $ [true, false])" {
    const parser =
        \\('a' $ [1, 2]) + ('b' $ [true, false])
    ;
    {
        const array = [_]Elem{ Elem.integer(1), Elem.integer(2), Elem.boolean(true), Elem.boolean(false) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abc"),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "('a' + 'b') -> S $ (S + 'c') $ (S + 'd')" {
    const parser =
        \\("a" + "b") -> S $ (S + "c") $ (S + "d")
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ab"),
            (try Elem.Dyn.String.copy(&vm, "abd")).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [1, 2]) -> [A, B] $ [B, A]" {
    const parser =
        \\('' $ [1, 2]) -> [A, B] $ [B, A]
    ;
    {
        const array = [_]Elem{ Elem.integer(2), Elem.integer(1) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [[1, 2, 3], 4, 5]) -> [[1,A,3], B, 5] $ [A, B]" {
    const parser =
        \\("" $ [[1, 2, 3], 4, 5]) -> [[1,A,3], B, 5] $ [A, B]
    ;
    {
        const array = [_]Elem{ Elem.integer(2), Elem.integer(4) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [[], 100]) -> [[], A] $ A" {
    const parser =
        \\('' $ [[], 100]) -> [[], A] $ A
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            Elem.numberString(vm.strings.getId("100"), .Integer),
            vm,
        );
    }
}

test "a = b ; b = a ; a" {
    const parser =
        \\a = b ; b = a ; a
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.AliasCycle,
            vm.interpret(parser, ""),
        );
    }
}

test "foo = bar ; bar = baz ; baz = bar ; foo" {
    const parser =
        \\a = b ; b = a ; a
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.AliasCycle,
            vm.interpret(parser, ""),
        );
    }
}

test "Foo = 1 ; a = Foo ; a" {
    const parser =
        \\Foo = 1 ; a = Foo ; a
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.InvalidGlobalParser,
            vm.interpret(parser, ""),
        );
    }
}

test "true(t) = t $ true ; true('true')" {
    const parser =
        \\true(t) = t $ true ; true('true')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "true"),
            Elem.boolean(true),
            vm,
        );
    }
}

test "camelCase = _foo ; _foo = __bar ; __bar = 123 ; camelCase" {
    const parser =
        \\camelCase = _foo
        \\_foo = __bar
        \\__bar = 123
        \\camelCase
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.numberString(vm.strings.getId("123"), .Integer),
            vm,
        );
    }
}

test "__1adsf = 1 ; __1adsf" {
    const parser =
        \\__1adsf = 1 ; __1adsf
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.UnexpectedInput,
            vm.interpret(parser, "1"),
        );
    }
}

test "missing_parser(1,2,3)" {
    const parser =
        \\missingParser(1,2,3)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.UndefinedVariable,
            vm.interpret(parser, "123"),
        );
    }
}

test "Add(A, B) = A + B ; '' $ Add(3, 12)" {
    const parser =
        \\Add(A, B) = A + B ; '' $ Add(3, 12)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "true"),
            Elem.integer(15),
            vm,
        );
    }
}

test "A = 1 + 100 ; 101 -> A" {
    const parser =
        \\A = 1 + 100 ; 101 -> A
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "101"),
            Elem.integer(101),
            vm,
        );
    }
}

test "fibonacci parser function" {
    const parser =
        \\const(C) = "" $ C
        \\
        \\fib(N) =
        \\  const(N) -> 0 ? const(0) :
        \\  const(N) -> 1 ? const(1) :
        \\  fib(N - 1) -> N1 & fib(N - 2) -> N2 $
        \\  (N1 + N2)
        \\
        \\0..99 -> N & fib(N)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0"),
            Elem.integer(0),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1"),
            Elem.integer(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "2"),
            Elem.integer(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "3"),
            Elem.integer(2),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "7"),
            Elem.integer(13),
            vm,
        );
    }
}

test "fibonacci value function" {
    const parser =
        \\Fib(N) =
        \\  N -> 0 ? 0 :
        \\  N -> 1 ? 1 :
        \\  Fib(N - 1) + Fib(N - 2)
        \\
        \\0..99 -> N $ Fib(N)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0"),
            Elem.integer(0),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1"),
            Elem.integer(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "2"),
            Elem.integer(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "3"),
            Elem.integer(2),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "7"),
            Elem.integer(13),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "12"),
            Elem.integer(144),
            vm,
        );
    }
}

test "'aa' $ {}" {
    const parser =
        \\"aa" $ {}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "aa"),
            (try Elem.Dyn.Object.create(&vm, 0)).dyn.elem(),
            vm,
        );
    }
}

test "'aa' $ {'a': 1, 'b': 2, 'c': 3}" {
    const parser =
        \\'aa' $ {'a': 1, 'b': 2, 'c': 3}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "aa");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 3);
        try object.members.put(vm.strings.getId("a"), Elem.integer(1));
        try object.members.put(vm.strings.getId("b"), Elem.integer(2));
        try object.members.put(vm.strings.getId("c"), Elem.integer(3));

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "1 -> A & 2 -> B $ {'a': A, 'b': B}" {
    const parser =
        \\1 -> A & 2 -> B $ {'a': A, 'b': B}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "12");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 3);
        try object.members.put(vm.strings.getId("a"), Elem.integer(1));
        try object.members.put(vm.strings.getId("b"), Elem.integer(2));

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "'Z' -> A $ {A: 1, 'A': 2}" {
    const parser =
        \\'Z' -> A $ {A: 1, 'A': 2}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "Z");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 3);
        try object.members.put(vm.strings.getId("Z"), Elem.integer(1));
        try object.members.put(vm.strings.getId("A"), Elem.integer(2));

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "object('a'..'z', 0..9)" {
    const parser =
        \\const(C) = "" $ C
        \\
        \\object(key, value) =
        \\  key -> K & value -> V &
        \\  _object(key, value, {K: V})
        \\
        \\_object(key, value, Acc) =
        \\  key -> K & value -> V ?
        \\  _object(key, value, Acc + {K: V}) :
        \\  const(Acc)
        \\
        \\object('a'..'z', 0..9)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "a1b2c3");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 3);
        try object.members.put(vm.strings.getId("a"), Elem.integer(1));
        try object.members.put(vm.strings.getId("b"), Elem.integer(2));
        try object.members.put(vm.strings.getId("c"), Elem.integer(3));

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})" {
    const parser =
        \\ ('123' $ {'a': true}) + ('456' $ {'a': false, 'b': null})
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "123456");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 3);
        try object.members.put(vm.strings.getId("a"), Elem.boolean(false));
        try object.members.put(vm.strings.getId("b"), Elem.nullConst);

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "('' $ {'a': true}) -> {'a': true}" {
    const parser =
        \\("" $ {'a': true}) -> {'a': true}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "");

        // Do this after running the VM to make sure strings are interned
        var object = try Elem.Dyn.Object.create(&vm, 1);
        try object.members.put(vm.strings.getId("a"), Elem.boolean(true));

        try testing.expectSuccess(result, object.dyn.elem(), vm);
    }
}

test "('' $ {'a': true}) -> {'a': false}" {
    const parser =
        \\("" $ {'a': true}) -> {'a': false}
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, ""),
        );
    }
}

test "('' $ {'a': 123}) -> {'a': A} $ A" {
    const parser =
        \\('' $ {'a': 123}) -> {'a': A} $ A
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "");

        try testing.expectSuccess(
            result,
            Elem.numberString(vm.strings.getId("123"), .Integer),
            vm,
        );
    }
}

test "('' $ [1, 2, 3 + 10, 4])" {
    const parser =
        \\('' $ [1, 2, 3 + 10, 4])
    ;
    {
        const array = [_]Elem{
            Elem.integer(1),
            Elem.integer(2),
            Elem.integer(13),
            Elem.integer(4),
        };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "");

        try testing.expectSuccess(
            result,
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [1, 2, 3 - 10, 4])" {
    const parser =
        \\('' $ [1, 2, 3 - 10, 4])
    ;
    {
        const array = [_]Elem{
            Elem.integer(1),
            Elem.integer(2),
            Elem.integer(-7),
            Elem.integer(4),
        };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "");

        try testing.expectSuccess(
            result,
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "'' $ [1, 2, [1+1+1]]" {
    const parser =
        \\'' $ [1, 2, [1+1+1]]
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "");

        const innerArray = [_]Elem{
            Elem.integer(3),
        };
        const array = [_]Elem{
            Elem.integer(1),
            Elem.integer(2),
            (try Elem.Dyn.Array.copy(&vm, &innerArray)).dyn.elem(),
        };

        try testing.expectSuccess(
            result,
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "Foo = (1 -> 2) + 1 ; '' $ [Foo]" {
    const parser =
        \\Foo = (1 -> 2) + 1 ; "" $ [Foo]
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectFailure(
            try vm.interpret(parser, ""),
        );
    }
}

test "array(digit) -> [A, B]" {
    const parser =
        \\const(C) = "" $ C
        \\
        \\array(elem) = elem -> First & _array(elem, [First])
        \\
        \\_array(elem, Acc) =
        \\  elem -> Elem ?
        \\  _array(elem, [...Acc, Elem]) :
        \\  const(Acc)
        \\
        \\digit = 0..9
        \\
        \\array(digit) -> [A, B]
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectFailure(
            try vm.interpret(parser, ""),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectFailure(
            try vm.interpret(parser, "1"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret(parser, "12");

        const array = [_]Elem{
            Elem.integer(1),
            Elem.integer(2),
        };

        try testing.expectSuccess(
            result,
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        try testing.expectFailure(
            try vm.interpret(parser, "123"),
        );
    }
}

test "'ab' -> ('a' + 'b')" {
    const parser =
        \\'ab' -> ('a' + 'b')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ab"),
            Elem.inputSubstring(0, 2),
            vm,
        );
    }
}

test "123 -> (2 + N) $ N" {
    const parser =
        \\123 -> (2 + N) $ N
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(121),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "foo"),
        );
    }
}

test "bool('t','f') -> A & bool('t','f') -> (A + B) $ B" {
    const parser =
        \\true(t) = t $ true
        \\false(f) = f $ false
        \\boolean(t, f) = true(t) | false(f)
        \\bool = boolean
        \\
        \\bool('t','f') -> A & bool('t','f') -> (A + B) $ B
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "tt"),
            Elem.boolean(false),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ff"),
            Elem.boolean(false),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "tf"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "ft"),
            Elem.boolean(true),
            vm,
        );
    }
}

test "('' $ [1,[2],2,3]) -> ([1,A] + A + [3]) $ A" {
    const parser =
        \\('' $ [1,[2],2,3]) -> ([1,A] + A + [3]) $ A
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const array = [_]Elem{Elem.integer(2)};
        try testing.expectSuccess(
            try vm.interpret(parser, "a"),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "'foobar' -> ('fo' + Ob + 'ar') $ Ob" {
    const parser =
        \\'foobar' -> ('fo' + Ob + 'ar') $ Ob
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foobar"),
            (try Elem.Dyn.String.copy(&vm, "ob")).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [1,2,3]) -> [1, ...Rest] $ [...Rest, 100, ...Rest]" {
    const parser =
        \\('' $ [1,2,3]) -> [1, ...Rest] $ [...Rest, 100, ...Rest]
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();

        const array = [_]Elem{
            Elem.integer(2),
            Elem.integer(3),
            Elem.integer(100),
            Elem.integer(2),
            Elem.integer(3),
        };

        try testing.expectSuccess(
            try vm.interpret(parser, "a"),
            (try Elem.Dyn.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "'Hello %('a'..'z')!'" {
    const parser =
        \\'Hello %('a'..'z')!'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "Hello q!"),
            (try Elem.Dyn.String.copy(&vm, "Hello q!")).dyn.elem(),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "Hello a?"),
        );
    }
}

test "A = 1 ; B = 2 ; ('' $ '%(A) + %(A) = %(B)')" {
    const parser =
        \\A = 1 ; B = 2 ; ('' $ '%(A) + %(A) = %(B)')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            (try Elem.Dyn.String.copy(&vm, "1 + 1 = 2")).dyn.elem(),
            vm,
        );
    }
}

test "Invalid JSON number" {
    {
        const parser = "01";
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.UnexpectedInput,
            vm.interpret(parser, "01"),
        );
    }
    {
        const parser = "-01.234";
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.UnexpectedInput,
            vm.interpret(parser, "-01.234"),
        );
    }
}

test "Large number" {
    {
        const large_int = "9999999999999999999999999999999999999999999999999999";
        const parser = large_int;
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, large_int),
            Elem.numberString(vm.strings.getId(large_int), .Integer),
            vm,
        );
    }
}

test "5.." {
    const parser =
        \\5..
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "5"),
            Elem.integer(5),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "57"),
            Elem.integer(57),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "4"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "-2"),
        );
    }
}

test "..30" {
    const parser =
        \\..30
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "5"),
            Elem.integer(5),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "30"),
            Elem.integer(30),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-100"),
            Elem.integer(-100),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "31"),
            Elem.integer(3),
            vm,
        );
    }
}

test "..-1" {
    const parser =
        \\..-1
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-1"),
            Elem.integer(-1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-30"),
            Elem.integer(-30),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-100"),
            Elem.integer(-100),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "3"),
        );
    }
}

test "'a'.." {
    const parser =
        \\'a'..
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "a"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "~"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "4"),
        );
    }
}

test "..'\\u01F920'" {
    const parser =
        \\..'\u01F920'
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "a"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "🤠"),
            Elem.inputSubstring(0, 4),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret(parser, "🤡"),
        );
    }
}

test "int -> 0..5" {
    const parser =
        \\int = ..-1 | 0..
        \\int -> 0..5
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "3"),
            Elem.integer(3),
            vm,
        );
    }
}

// test "0..999 -> N $ 'Your number was %(N).'" {
//     {
//         const parser = "0..999 -> N $ 'Your number was %(N).'";
//         var vm = VM.create();
//         try vm.init(allocator, writers, config);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "123"),
//             (try Elem.Dyn.String.copy(&vm, "Your number was 123.")).dyn.elem(),
//             vm,
//         );
//     }
// }

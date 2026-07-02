const std = @import("std");
const allocator = std.testing.allocator;
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const VMConfig = @import("vm.zig").Config;
const Writers = @import("writer.zig").Writers;
const testing = @import("testing.zig");

var null_buffer: [256]u8 = undefined;
var null_discarding = std.Io.Writer.Discarding.init(&null_buffer);

const writers = Writers{
    .out = &null_discarding.writer,
    .err = &null_discarding.writer,
    .debug = &null_discarding.writer,
};

const config = VMConfig{
    .includeStdlib = false,
    .gc_mode = .StressTest,
};

test "empty program" {
    const parser = "";
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.NoMainParser,
            vm.interpret("test", parser, ""),
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
            vm.interpret("test", parser, "123456"),
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
            try vm.interpret("test", parser, "\"\""),
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
            try vm.interpret("test", parser, "abc"),
            Elem.inputSubstring(2, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "abzsss"),
            Elem.inputSubstring(0, 3),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "ababz"));
    }
}

test "-37" {
    const parser =
        \\-37
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "-37"),
            try Elem.numberStringFromBytes("-37", &vm),
            vm,
        );
    }
}

test "--37" {
    const parser =
        \\--37
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(error.InvalidAst, vm.interpret("test", parser, "--37"));
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
            try vm.interpret("test", parser, "56789"),
            try Elem.numberStringFromBytes("5678", &vm),
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
            try vm.interpret("test", parser, "foobarbaz"),
            Elem.inputSubstring(0, 9),
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
            try vm.interpret("test", parser, "123"),
            Elem.numberFloat(6),
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
            try vm.interpret("test", parser, "1.2310"),
            Elem.numberFloat(11.23),
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
            try vm.interpret("test", parser, "0.10.2"),
            Elem.numberFloat(0.30000000000000004),
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
            try vm.interpret("test", parser, "1e573e-4"),
            Elem.numberFloat(1.0e+57),
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
            try vm.interpret("test", parser, "11"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "10"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "01"),
            Elem.boolean(true),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "00"),
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
            try vm.interpret("test", parser, "foo"),
            Elem.string(vm.strings.getId("bar")),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "f"));
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
            try vm.interpret("test", parser, "truefoobar"),
            Elem.inputSubstring(4, 6),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "baz"),
            Elem.inputSubstring(0, 3),
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
            try vm.interpret("test", parser, "888"),
            Elem.numberFloat(888),
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
            try vm.interpret("test", parser, "-5"),
            Elem.numberFloat(-5),
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
            try vm.interpret("test", parser, "foo"),
            Elem.inputSubstring(0, 3),
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
            try vm.interpret("test", parser, "true"),
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
            try vm.interpret("test", parser, ""),
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
            try vm.interpret("test", parser, "f12"),
            Elem.numberFloat(12),
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
            try vm.interpret("test", parser, "42.0"),
            try Elem.numberStringFromBytes("42.0", &vm),
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
        try testing.expectFailure(try vm.interpret("test", parser, "42.0"));
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
            try vm.interpret("test", parser, "123789xyz"),
            Elem.inputSubstring(6, 3),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "12378xyz"),
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
            try vm.interpret("test", parser, "123"),
            try Elem.numberStringFromBytes("3", &vm),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "4"),
            try Elem.numberStringFromBytes("4", &vm),
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
        try testing.expectFailure(try vm.interpret("test", parser, "1"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "12"),
            try Elem.numberStringFromBytes("2", &vm),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "13"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "14"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "15"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "2"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "23"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "24"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "25"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "3"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "34"),
            try Elem.numberStringFromBytes("4", &vm),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "35"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "4"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "45"));
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "5"),
            try Elem.numberStringFromBytes("5", &vm),
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
            try vm.interpret("test", parser, "foo"),
            Elem.inputSubstring(0, 3),
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
            try vm.interpret("test", parser, "aa"),
            Elem.inputSubstring(0, 2),
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
            try vm.interpret("test", parser, "123"),
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
            try vm.interpret("test", parser, "aa"),
            Elem.inputSubstring(0, 2),
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
            try vm.interpret("test", parser, "aaaaaaaend"),
            Elem.inputSubstring(7, 3),
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
            try vm.interpret("test", parser, "abab"),
            Elem.inputSubstring(0, 4),
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
            try vm.interpret("test", parser, "ababxyxy"),
            (try Elem.DynElem.String.copy(&vm, "ababxx")).dyn.elem(),
            vm,
        );
    }
}

test "id(A) = '' $ A ; id($true)" {
    const parser =
        \\id(A) = '' $ A
        \\id($true)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "ignored"),
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
            try vm.interpret("test", parser, input),
            Elem.inputSubstring(3, 4),
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
            try vm.interpret("test", parser, input),
            try Elem.numberStringFromBytes("0", &vm),
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
            try vm.interpret("test", parser, "abcd"),
            Elem.inputSubstring(1, 2),
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
            try vm.interpret("test", parser, "abcd"),
            Elem.inputSubstring(1, 2),
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
            try vm.interpret("test", parser, input),
            Elem.inputSubstring(3, 4),
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
            try vm.interpret("test", parser, "100"),
            try Elem.numberStringFromBytes("100", &vm),
            vm,
        );
    }
}

test "eql_to(p, V) = p -> V ; eql_to('bar' | 'foo', $'foo')" {
    const parser =
        \\eql_to(p, V) = p -> V
        \\eql_to('bar' | 'foo', $'foo')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "foo"),
            Elem.inputSubstring(0, 3),
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
            try vm.interpret("test", parser, "123"),
            try Elem.numberStringFromBytes("3", &vm),
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
            try vm.interpret("test", parser, "foo"),
            Elem.inputSubstring(0, 3),
            vm,
        );
    }
}

test "peek(p) = @input.offset -> Pos & @at(Pos, p) ; peek(1) + peek(1) + peek(1)" {
    const parser =
        \\peek(p) = @input.offset -> Pos & @at(Pos, p)
        \\peek(1) + peek(1) + peek(1)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "1"),
            Elem.numberFloat(3),
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
            try vm.interpret("test", parser, "sad"),
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
            try vm.interpret("test", parser, "111"),
            try Elem.numberStringFromBytes("111", &vm),
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
            try vm.interpret("test", parser, "barfoo"),
            Elem.inputSubstring(0, 6),
            vm,
        );
    }
}

test "as_number('123')" {
    const parser =
        \\as_number(p) = p -> "%(0 + N)" $ N
        \\as_number('123')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "123"),
            try Elem.numberStringFromBytes("123", &vm),
            vm,
        );
    }
}

test "as_number('123.456')" {
    const parser =
        \\as_number(p) = p -> "%(0 + N)" $ N
        \\as_number('123.456')
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "123.456"),
            try Elem.numberStringFromBytes("123.456", &vm),
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
            try vm.interpret("test", parser, "🛹🛹🛹🐀🐀🛹🐀🛹🐀🐀"),
            Elem.numberFloat(5),
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
            try vm.interpret("test", parser, "123456"),
            Elem.numberFloat(579),
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
            try vm.interpret("test", parser, "aaaa"),
            Elem.inputSubstring(0, 4),
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
            try vm.interpret("test", parser, "aaaa"),
            Elem.inputSubstring(0, 4),
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
            try vm.interpret("test", parser, "12"),
            try Elem.numberStringFromBytes("12", &vm),
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
        try std.testing.expectError(error.RuntimeError, vm.interpret("test", parser, "12"));
    }
}

test "foo(N) = bar(12 -> N) ; bar(p) = p ; foo($11)" {
    const parser =
        \\foo(N) = bar(12 -> N)
        \\bar(p) = p
        \\foo($11)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "12"));
    }
}

test "foo(N) = bar(bar(bar(12 -> N))) ; bar(p) = p ; foo($11)" {
    const parser =
        \\foo(N) = bar(bar(bar(12 -> N)))
        \\bar(p) = p
        \\foo($11)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "12"));
    }
}

test "foo(N) = bar(bar(3 -> N) + bar(3 -> N)) ; bar(p) = p ; foo($0)" {
    const parser =
        \\foo(N) = bar(bar(3 -> N) + bar(3 -> N))
        \\bar(p) = p
        \\foo($0)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret("test", parser, "33"));
    }
}

test "foo(N) = bar(bar(3 -> N) + bar(3 -> N)) ; bar(p) = p ; foo($3)" {
    const parser =
        \\foo(N) = bar(bar(3 -> N) + bar(3 -> N))
        \\bar(p) = p
        \\foo($3)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "33"),
            Elem.numberFloat(6),
            vm,
        );
    }
}

test "Max params" {
    const parser =
        \\foo(
        \\  A1, A2, A3, A4, A5, A6, A7, A8,
        \\  A9, A10, A11, A12, A13, A14, A15, A16,
        \\  A17, A18, A19, A20, A21, A22, A23, A24,
        \\  A25, A26, A27, A28, A29, A30, A31,
        \\) = "wow"
        \\0
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "0"),
            try Elem.numberStringFromBytes("0", &vm),
            vm,
        );
    }
}

test "Max function locals overflow error" {
    const parser =
        \\foo(
        \\  A1, A2, A3, A4, A5, A6, A7, A8,
        \\  A9, A10, A11, A12, A13, A14, A15, A16,
        \\  A17, A18, A19, A20, A21, A22, A23, A24,
        \\  A25, A26, A27, A28, A29, A30, A31, A32,
        \\) = "cool"
        \\0
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(error.MaxFunctionLocals, vm.interpret("test", parser, "0"));
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
            try vm.interpret("test", parser, "aa"),
            (try Elem.DynElem.Array.create(&vm, 0)).dyn.elem(),
            vm,
        );
    }
}

test "'aa' $ [1, 2, 3]" {
    const parser =
        \\"aa" $ [1, 2, 3]
    ;
    {
        const array = [_]Elem{ Elem.numberFloat(1), Elem.numberFloat(2), Elem.numberFloat(3) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "aa"),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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

        const result = try vm.interpret("test", parser, "a");

        vm.gc.mode = .NoGC;
        const innerArray = [_]Elem{Elem.inputSubstring(0, 1)};
        const outerArray = [_]Elem{(try Elem.DynElem.Array.copy(&vm, &innerArray)).dyn.elem()};
        const array = (try Elem.DynElem.Array.copy(&vm, &outerArray)).dyn.elem();

        try testing.expectSuccess(result, array, vm);
    }
}

test "('a' $ [1, 2]) + ('b' $ [true, false])" {
    const parser =
        \\('a' $ [1, 2]) + ('b' $ [true, false])
    ;
    {
        const array = [_]Elem{ Elem.numberFloat(1), Elem.numberFloat(2), Elem.boolean(true), Elem.boolean(false) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "abc"),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            try vm.interpret("test", parser, "ab"),
            (try Elem.DynElem.String.copy(&vm, "abd")).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [1, 2]) -> [A, B] $ [B, A]" {
    const parser =
        \\('' $ [1, 2]) -> [A, B] $ [B, A]
    ;
    {
        const array = [_]Elem{ Elem.numberFloat(2), Elem.numberFloat(1) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, ""),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
}

test "('' $ [[1, 2, 3], 4, 5]) -> [[1,A,3], B, 5] $ [A, B]" {
    const parser =
        \\("" $ [[1, 2, 3], 4, 5]) -> [[1,A,3], B, 5] $ [A, B]
    ;
    {
        const array = [_]Elem{ Elem.numberFloat(2), Elem.numberFloat(4) };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, ""),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            try vm.interpret("test", parser, ""),
            try Elem.numberStringFromBytes("100", &vm),
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
        try std.testing.expectError(error.AliasCycle, vm.interpret("test", parser, ""));
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
        try std.testing.expectError(error.AliasCycle, vm.interpret("test", parser, ""));
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
        try std.testing.expectError(error.InvalidGlobalParser, vm.interpret("test", parser, ""));
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
            try vm.interpret("test", parser, "true"),
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
            try vm.interpret("test", parser, "123"),
            try Elem.numberStringFromBytes("123", &vm),
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
        try std.testing.expectError(error.UnexpectedInput, vm.interpret("test", parser, "1"));
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
        try std.testing.expectError(error.UndefinedVariable, vm.interpret("test", parser, "123"));
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
            try vm.interpret("test", parser, "true"),
            Elem.numberFloat(15),
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
            try vm.interpret("test", parser, "101"),
            try Elem.numberStringFromBytes("101", &vm),
            vm,
        );
    }
}

test "fibonacci parser function" {
    const parser =
        \\const(C) = "" $ C
        \\
        \\fib(N) =
        \\  const(N) -> ..1 ? const(N) :
        \\  fib(N - $1) -> N1 & fib(N - $2) -> N2 $
        \\  (N1 + N2)
        \\
        \\0.. -> N & fib(N)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "0"),
            Elem.numberFloat(0),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "1"),
            Elem.numberFloat(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "2"),
            Elem.numberFloat(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "3"),
            Elem.numberFloat(2),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "7"),
            Elem.numberFloat(13),
            vm,
        );
    }
}

test "fibonacci value function" {
    const parser =
        \\Fib(N) =
        \\  N -> ..1 ? N :
        \\  Fib(N - 1) + Fib(N - 2)
        \\
        \\0.. -> N $ Fib(N)
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "0"),
            Elem.numberFloat(0),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "1"),
            Elem.numberFloat(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "2"),
            Elem.numberFloat(1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "3"),
            Elem.numberFloat(2),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "7"),
            Elem.numberFloat(13),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "12"),
            Elem.numberFloat(144),
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
            try vm.interpret("test", parser, "aa"),
            (try Elem.DynElem.Object.create(&vm, 0)).dyn.elem(),
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
        const result = try vm.interpret("test", parser, "aa");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 3);
        try object.put(&vm, vm.strings.getId("a"), Elem.numberFloat(1));
        try object.put(&vm, vm.strings.getId("b"), Elem.numberFloat(2));
        try object.put(&vm, vm.strings.getId("c"), Elem.numberFloat(3));

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
        const result = try vm.interpret("test", parser, "12");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 3);
        try object.put(&vm, vm.strings.getId("a"), Elem.numberFloat(1));
        try object.put(&vm, vm.strings.getId("b"), Elem.numberFloat(2));

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
        const result = try vm.interpret("test", parser, "Z");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 3);
        try object.put(&vm, vm.strings.getId("Z"), Elem.numberFloat(1));
        try object.put(&vm, vm.strings.getId("A"), Elem.numberFloat(2));

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
        const result = try vm.interpret("test", parser, "a1b2c3");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 3);
        try object.put(&vm, vm.strings.getId("a"), Elem.numberFloat(1));
        try object.put(&vm, vm.strings.getId("b"), Elem.numberFloat(2));
        try object.put(&vm, vm.strings.getId("c"), Elem.numberFloat(3));

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
        const result = try vm.interpret("test", parser, "123456");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 3);
        try object.put(&vm, vm.strings.getId("a"), Elem.boolean(false));
        try object.put(&vm, vm.strings.getId("b"), Elem.nullConst);

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
        const result = try vm.interpret("test", parser, "");

        // Do this after running the VM to make sure strings are interned
        vm.gc.mode = .NoGC;
        var object = try Elem.DynElem.Object.create(&vm, 1);
        try object.put(&vm, vm.strings.getId("a"), Elem.boolean(true));

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
            try vm.interpret("test", parser, ""),
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
        const result = try vm.interpret("test", parser, "");

        try testing.expectSuccess(
            result,
            try Elem.numberStringFromBytes("123", &vm),
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
            Elem.numberFloat(1),
            Elem.numberFloat(2),
            Elem.numberFloat(13),
            Elem.numberFloat(4),
        };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret("test", parser, "");

        try testing.expectSuccess(
            result,
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            Elem.numberFloat(1),
            Elem.numberFloat(2),
            Elem.numberFloat(-7),
            Elem.numberFloat(4),
        };
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret("test", parser, "");

        try testing.expectSuccess(
            result,
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
        const result = try vm.interpret("test", parser, "");

        vm.gc.mode = .NoGC;
        const innerArray = [_]Elem{
            Elem.numberFloat(3),
        };
        const array = [_]Elem{
            Elem.numberFloat(1),
            Elem.numberFloat(2),
            (try Elem.DynElem.Array.copy(&vm, &innerArray)).dyn.elem(),
        };

        try testing.expectSuccess(
            result,
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            try vm.interpret("test", parser, ""),
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
            try vm.interpret("test", parser, ""),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "1"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        const result = try vm.interpret("test", parser, "12");

        const array = [_]Elem{
            Elem.numberFloat(1),
            Elem.numberFloat(2),
        };

        try testing.expectSuccess(
            result,
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "123"),
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
            try vm.interpret("test", parser, "ab"),
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
            try vm.interpret("test", parser, "123"),
            Elem.numberFloat(121),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "foo"),
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
            try vm.interpret("test", parser, "tt"),
            Elem.boolean(false),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "ff"),
            Elem.boolean(false),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "tf"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "ft"),
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
        const array = [_]Elem{Elem.numberFloat(2)};
        try testing.expectSuccess(
            try vm.interpret("test", parser, "a"),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            try vm.interpret("test", parser, "foobar"),
            Elem.inputSubstring(2, 2),
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
            Elem.numberFloat(2),
            Elem.numberFloat(3),
            Elem.numberFloat(100),
            Elem.numberFloat(2),
            Elem.numberFloat(3),
        };
        try testing.expectSuccess(
            try vm.interpret("test", parser, "a"),
            (try Elem.DynElem.Array.copy(&vm, &array)).dyn.elem(),
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
            try vm.interpret("test", parser, "Hello q!"),
            Elem.inputSubstring(0, 8),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "Hello a?"),
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
            try vm.interpret("test", parser, ""),
            (try Elem.DynElem.String.copy(&vm, "1 + 1 = 2")).dyn.elem(),
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
        try std.testing.expectError(error.UnexpectedInput, vm.interpret("test", parser, "01"));
    }
    {
        const parser = "-01.234";
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(error.UnexpectedInput, vm.interpret("test", parser, "-01.234"));
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
            try vm.interpret("test", parser, large_int),
            try Elem.numberStringFromBytes(large_int, &vm),
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
            try vm.interpret("test", parser, "5"),
            Elem.numberFloat(5),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "57"),
            Elem.numberFloat(57),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "4"),
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "-2"),
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
            try vm.interpret("test", parser, "5"),
            Elem.numberFloat(5),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "30"),
            Elem.numberFloat(30),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "-100"),
            Elem.numberFloat(-100),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "31"),
            Elem.numberFloat(3),
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
            try vm.interpret("test", parser, "-1"),
            Elem.numberFloat(-1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "-30"),
            Elem.numberFloat(-30),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "-100"),
            Elem.numberFloat(-100),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "3"),
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
            try vm.interpret("test", parser, "a"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "~"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "4"),
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
            try vm.interpret("test", parser, "a"),
            Elem.inputSubstring(0, 1),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "🤠"),
            Elem.inputSubstring(0, 4),
            vm,
        );
    }
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectFailure(
            try vm.interpret("test", parser, "🤡"),
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
            try vm.interpret("test", parser, "3"),
            Elem.numberFloat(3),
            vm,
        );
    }
}

test "0.. -> I $ -I" {
    const parser =
        \\0.. -> I $ -I
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "3"),
            Elem.numberFloat(-3),
            vm,
        );
    }
}

test "0.. -> I & ..0 -> -I" {
    const parser =
        \\0.. -> I $ -I
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "3"),
            Elem.numberFloat(-3),
            vm,
        );
    }
}
test "0..999 -> N $ 'Your number was %(N).'" {
    {
        const parser = "0..999 -> N $ 'Your number was %(N).'";
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret("test", parser, "123"),
            (try Elem.DynElem.String.copy(&vm, "Your number was 123.")).dyn.elem(),
            vm,
        );
    }
}

const std = @import("std");
const allocator = std.testing.allocator;
const Compiler = @import("compiler.zig").Compiler;
const Elem = @import("elem.zig").Elem;
const VM = @import("vm.zig").VM;
const VMConfig = @import("vm.zig").Config;
const testing = @import("testing.zig");
const writers = testing.writers;

const config = VMConfig{
    .includeStdlib = false,
    .gc_mode = .StressTest,
};

// Compile and run a program split across a `util` module and a `main` module.
fn runWithUtilModule(vm: *VM, util_source: []const u8, main_source: []const u8, input: []const u8) !Elem {
    vm.input = input;

    const util_module = try vm.createModule("util", util_source);
    const main_module = try vm.createModule("main", main_source);

    var compiler = try Compiler.init(vm);
    defer compiler.deinit();

    try compiler.addModule(util_module.*, .{});
    try compiler.addTargetModule(main_module.*, .{});

    try compiler.addModuleDependency(main_module.id, util_module.id);

    vm.compiler = &compiler;
    defer vm.compiler = null;

    try compiler.compile();

    const main = compiler.main.?;
    try vm.push(main.dyn.elem());
    try vm.pushFrame(main);
    try vm.run();

    return vm.peek(0);
}

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

test "foo = bar ; foo # alias to undefined name, called" {
    const parser =
        \\foo = bar ; foo
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(error.UndefinedVariable, vm.interpret("test", parser, "x"));
    }
}

test "foo = bar ; 'x' # alias to undefined name, never called" {
    const parser =
        \\foo = bar ; "x"
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(error.UndefinedVariable, vm.interpret("test", parser, "x"));
    }
}

test "cross-module call into an undefined alias errors" {
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try std.testing.expectError(
            error.UndefinedVariable,
            runWithUtilModule(&vm, "foo = bar", "foo", "x"),
        );
    }
}

test "undefined alias in another module is fine when never compiled" {
    const util_source =
        \\foo = bar
        \\greet = "hi"
    ;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, config);
        defer vm.deinit();
        try testing.expectSuccess(
            try runWithUtilModule(&vm, util_source, "greet", "hi"),
            Elem.inputSubstring(0, 2),
            vm,
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

const rc_config = VMConfig{
    .includeStdlib = false,
    .gc_mode = .NoGC,
};

test "merge appends to a unique array in place" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = try Elem.DynElem.Array.create(&vm, 1);
    try a.append(&vm, Elem.numberFloat(1));
    const b = try Elem.DynElem.Array.create(&vm, 1);
    try b.append(&vm, Elem.numberFloat(2));

    const merged = (try Elem.merge(a.dyn.elem(), b.dyn.elem(), &vm)).?;

    try std.testing.expectEqual(a.dyn.id, merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 2), merged.asDyn().asArray().len());
}

test "merge copies a shared array" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = try Elem.DynElem.Array.create(&vm, 1);
    try a.append(&vm, Elem.numberFloat(1));
    a.dyn.retain();
    const b = try Elem.DynElem.Array.create(&vm, 1);
    try b.append(&vm, Elem.numberFloat(2));

    const merged = (try Elem.merge(a.dyn.elem(), b.dyn.elem(), &vm)).?;

    try std.testing.expect(a.dyn.id != merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 1), a.len());
    try std.testing.expectEqual(@as(usize, 2), merged.asDyn().asArray().len());
}

test "merge appends to a unique object in place" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const o1 = try Elem.DynElem.Object.create(&vm, 1);
    try o1.put(&vm, try vm.strings.insert("a"), Elem.numberFloat(1));
    const o2 = try Elem.DynElem.Object.create(&vm, 1);
    try o2.put(&vm, try vm.strings.insert("b"), Elem.numberFloat(2));

    const merged = (try Elem.merge(o1.dyn.elem(), o2.dyn.elem(), &vm)).?;

    try std.testing.expectEqual(o1.dyn.id, merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 2), merged.asDyn().asObject().members.count());
}

test "merge copies a shared object" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const o1 = try Elem.DynElem.Object.create(&vm, 1);
    try o1.put(&vm, try vm.strings.insert("a"), Elem.numberFloat(1));
    o1.dyn.retain();
    const o2 = try Elem.DynElem.Object.create(&vm, 1);
    try o2.put(&vm, try vm.strings.insert("b"), Elem.numberFloat(2));

    const merged = (try Elem.merge(o1.dyn.elem(), o2.dyn.elem(), &vm)).?;

    try std.testing.expect(o1.dyn.id != merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 1), o1.members.count());
    try std.testing.expectEqual(@as(usize, 2), merged.asDyn().asObject().members.count());
}

test "merge appends to a unique dyn string in place" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const s = try Elem.DynElem.String.copy(&vm, "ab");
    const interned = Elem.string(try vm.strings.insert("cd"));

    const merged = (try Elem.merge(s.dyn.elem(), interned, &vm)).?;

    try std.testing.expectEqual(s.dyn.id, merged.asDyn().id);
    try std.testing.expectEqualStrings("abcd", merged.asDyn().asString().bytes());
}

test "merge references a shared dyn string from a fresh rope" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const s = try Elem.DynElem.String.copy(&vm, "ab");
    s.dyn.retain();
    const interned = Elem.string(try vm.strings.insert("cd"));

    const merged = (try Elem.merge(s.dyn.elem(), interned, &vm)).?;

    try std.testing.expect(s.dyn.id != merged.asDyn().id);
    try std.testing.expectEqualStrings("ab", s.bytes());
    // The rope holds a retained handle on the shared string, no copy.
    try std.testing.expectEqual(@as(u32, 3), s.dyn.ref_count);
    try std.testing.expectEqualStrings("abcd", try merged.asDyn().asString().flatten(&vm));
    // Flattening released the rope's segment handles.
    try std.testing.expectEqual(@as(u32, 2), s.dyn.ref_count);
}

test "merge copies a unique array when fast paths are disabled" {
    var vm = VM.create();
    var no_fast_paths = rc_config;
    no_fast_paths.rc_fast_paths = false;
    try vm.init(allocator, writers, no_fast_paths);
    defer vm.deinit();

    const a = try Elem.DynElem.Array.create(&vm, 1);
    try a.append(&vm, Elem.numberFloat(1));
    const b = try Elem.DynElem.Array.create(&vm, 1);
    try b.append(&vm, Elem.numberFloat(2));

    const merged = (try Elem.merge(a.dyn.elem(), b.dyn.elem(), &vm)).?;

    try std.testing.expect(a.dyn.id != merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 1), a.len());
}

test "repeat leaves the repeated value untouched" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = try Elem.DynElem.Array.create(&vm, 1);
    try a.append(&vm, Elem.numberFloat(1));

    const repeated = (try Elem.repeat(a.dyn.elem(), Elem.numberFloat(3), &vm)).?;

    try std.testing.expect(a.dyn.id != repeated.asDyn().id);
    try std.testing.expectEqual(@as(usize, 1), a.len());
    try std.testing.expectEqual(@as(usize, 3), repeated.asDyn().asArray().len());
    try std.testing.expectEqual(@as(u32, 1), a.dyn.ref_count);
}

// Every DynElem allocation takes an id from vm.nextUniqueId, so the
// uniqueIdCount delta across an operation is its heap allocation count.

test "in-place array merge allocates nothing, copy merge allocates once" {
    {
        var vm = VM.create();
        try vm.init(allocator, writers, rc_config);
        defer vm.deinit();

        const a = try Elem.DynElem.Array.create(&vm, 1);
        try a.append(&vm, Elem.numberFloat(1));
        const b = try Elem.DynElem.Array.create(&vm, 1);
        try b.append(&vm, Elem.numberFloat(2));

        const before = vm.uniqueIdCount;
        _ = (try Elem.merge(a.dyn.elem(), b.dyn.elem(), &vm)).?;
        try std.testing.expectEqual(before, vm.uniqueIdCount);
    }
    {
        var vm = VM.create();
        var no_fast_paths = rc_config;
        no_fast_paths.rc_fast_paths = false;
        try vm.init(allocator, writers, no_fast_paths);
        defer vm.deinit();

        const a = try Elem.DynElem.Array.create(&vm, 1);
        try a.append(&vm, Elem.numberFloat(1));
        const b = try Elem.DynElem.Array.create(&vm, 1);
        try b.append(&vm, Elem.numberFloat(2));

        const before = vm.uniqueIdCount;
        _ = (try Elem.merge(a.dyn.elem(), b.dyn.elem(), &vm)).?;
        try std.testing.expectEqual(before + 1, vm.uniqueIdCount);
    }
}

test "array repeat allocates one accumulator with fast paths, one per merge without" {
    // Iteration 1 is the null-identity merge (no allocation). With fast
    // paths, iteration 2 copies into a fresh accumulator and every later
    // iteration appends in place. Without, every iteration from 2 on
    // copies.
    const count = 50;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, rc_config);
        defer vm.deinit();

        const a = try Elem.DynElem.Array.create(&vm, 1);
        try a.append(&vm, Elem.numberFloat(1));

        const before = vm.uniqueIdCount;
        _ = (try Elem.repeat(a.dyn.elem(), Elem.numberFloat(count), &vm)).?;
        try std.testing.expectEqual(before + 1, vm.uniqueIdCount);
    }
    {
        var vm = VM.create();
        var no_fast_paths = rc_config;
        no_fast_paths.rc_fast_paths = false;
        try vm.init(allocator, writers, no_fast_paths);
        defer vm.deinit();

        const a = try Elem.DynElem.Array.create(&vm, 1);
        try a.append(&vm, Elem.numberFloat(1));

        const before = vm.uniqueIdCount;
        _ = (try Elem.repeat(a.dyn.elem(), Elem.numberFloat(count), &vm)).?;
        try std.testing.expectEqual(before + count - 1, vm.uniqueIdCount);
    }
}

test "string repeat allocates one buffer with fast paths, one per merge without" {
    const count = 50;
    {
        var vm = VM.create();
        try vm.init(allocator, writers, rc_config);
        defer vm.deinit();

        const ab = Elem.string(try vm.strings.insert("ab"));
        const before = vm.uniqueIdCount;
        _ = (try Elem.repeat(ab, Elem.numberFloat(count), &vm)).?;
        try std.testing.expectEqual(before + 1, vm.uniqueIdCount);
    }
    {
        var vm = VM.create();
        var no_fast_paths = rc_config;
        no_fast_paths.rc_fast_paths = false;
        try vm.init(allocator, writers, no_fast_paths);
        defer vm.deinit();

        const ab = Elem.string(try vm.strings.insert("ab"));
        const before = vm.uniqueIdCount;
        _ = (try Elem.repeat(ab, Elem.numberFloat(count), &vm)).?;
        try std.testing.expectEqual(before + count - 1, vm.uniqueIdCount);
    }
}

test "a full program allocates fewer dyns with fast paths than without" {
    // Identical source and input, so compile-time allocations match and
    // the difference is runtime merge copies.
    const parser =
        \\("a" $ [1]) * 20 $ "ok"
    ;
    const input = "aaaaaaaaaaaaaaaaaaaa";

    var vm_fast = VM.create();
    try vm_fast.init(allocator, writers, rc_config);
    defer vm_fast.deinit();
    _ = try vm_fast.interpret("test", parser, input);

    var vm_copy = VM.create();
    var no_fast_paths = rc_config;
    no_fast_paths.rc_fast_paths = false;
    try vm_copy.init(allocator, writers, no_fast_paths);
    defer vm_copy.deinit();
    _ = try vm_copy.interpret("test", parser, input);

    try std.testing.expect(vm_fast.uniqueIdCount < vm_copy.uniqueIdCount);
}

test "closure creation reuses a parked husk once the prior one is consumed" {
    // The repeat loop re-emits the compound argument's closure creation
    // every iteration; each prior closure is fully consumed by frame
    // teardown by then, so its parked husk serves the next creation.
    const parser =
        \\id(q) = q
        \\list(p, sep) = p + (id(sep > p) * 0..)
        \\list("a", ",")
    ;
    const input = "a,a,a,a,a";

    var vm_fast = VM.create();
    try vm_fast.init(allocator, writers, rc_config);
    defer vm_fast.deinit();
    _ = try vm_fast.interpret("test", parser, input);

    try std.testing.expectEqual(@as(u64, 4), vm_fast.rc_stats.husks_reused);

    var vm_copy = VM.create();
    var no_fast_paths = rc_config;
    no_fast_paths.rc_fast_paths = false;
    try vm_copy.init(allocator, writers, no_fast_paths);
    defer vm_copy.deinit();
    _ = try vm_copy.interpret("test", parser, input);

    try std.testing.expectEqual(@as(u64, 0), vm_copy.rc_stats.husks_parked);
    try std.testing.expectEqual(@as(u64, 0), vm_copy.rc_stats.husks_reused);
    try std.testing.expect(vm_fast.uniqueIdCount < vm_copy.uniqueIdCount);
}

test "a live prior closure forces a fresh allocation at the same creation site" {
    // Each recursion level re-executes the creation site while the prior
    // level's closure is still held as a frame local, so nothing has
    // parked yet and every level allocates fresh. The closures park only
    // as the frames unwind.
    const parser =
        \\f(p) = ("!" > f(p + "")) | p
        \\f("a")
    ;
    const input = "!!a";

    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();
    _ = try vm.interpret("test", parser, input);

    try std.testing.expectEqual(@as(u64, 0), vm.rc_stats.husks_reused);
    try std.testing.expectEqual(@as(u64, 2), vm.rc_stats.husks_parked);
}

test "merge of two value strings builds a rope without copying bytes" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = Elem.string(try vm.strings.insert("ab"));
    const b = Elem.string(try vm.strings.insert("cd"));

    const merged = (try Elem.merge(a, b, &vm)).?;
    const s = merged.asDyn().asString();

    try std.testing.expect(s.repr == .rope);
    try std.testing.expectEqual(@as(usize, 4), s.byteLen());
    try std.testing.expectEqualStrings("abcd", try s.flatten(&vm));
    try std.testing.expect(s.repr == .leaf);
}

test "merge prepends a value string onto a unique rope in place" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const b = Elem.string(try vm.strings.insert("bc"));
    const c = Elem.string(try vm.strings.insert("de"));
    const rope = (try Elem.merge(b, c, &vm)).?;

    const a = Elem.string(try vm.strings.insert("a"));
    const merged = (try Elem.merge(a, rope, &vm)).?;

    try std.testing.expectEqual(rope.asDyn().id, merged.asDyn().id);
    try std.testing.expectEqualStrings("abcde", try merged.asDyn().asString().flatten(&vm));
}

test "merge splices a consumed unique rope and empties the husk" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = Elem.string(try vm.strings.insert("ab"));
    const b = Elem.string(try vm.strings.insert("cd"));
    const lhs = (try Elem.merge(a, b, &vm)).?;
    const rhs = (try Elem.merge(a, b, &vm)).?;

    const merged = (try Elem.merge(lhs, rhs, &vm)).?;

    try std.testing.expectEqual(lhs.asDyn().id, merged.asDyn().id);
    try std.testing.expectEqual(@as(usize, 4), merged.asDyn().asString().repr.rope.segments.items.len);
    try std.testing.expectEqual(@as(usize, 0), rhs.asDyn().asString().byteLen());
    try std.testing.expectEqualStrings("abcdabcd", try merged.asDyn().asString().flatten(&vm));
}

test "contiguous input substring segments collapse in a rope" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();
    vm.input = "abcdef";

    const s1 = Elem.inputSubstring(0, 2);
    const s2 = Elem.inputSubstring(3, 1);
    const s3 = Elem.inputSubstring(4, 2);

    // Non-contiguous, so a rope; the following contiguous append
    // extends the last segment instead of adding one.
    const rope = (try Elem.merge(s1, s2, &vm)).?;
    const merged = (try Elem.merge(rope, s3, &vm)).?;

    const s = merged.asDyn().asString();
    try std.testing.expectEqual(@as(usize, 2), s.repr.rope.segments.items.len);
    try std.testing.expectEqualStrings("abdef", try s.flatten(&vm));
}

test "string equality compares ropes without flattening" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const a = Elem.string(try vm.strings.insert("ab"));
    const b = Elem.string(try vm.strings.insert("cd"));
    const rope = (try Elem.merge(a, b, &vm)).?;
    const leaf = (try Elem.DynElem.String.copy(&vm, "abcd")).dyn.elem();
    const interned = Elem.string(try vm.strings.insert("abcd"));
    const shorter = Elem.string(try vm.strings.insert("abc"));

    try std.testing.expect(rope.isEql(leaf, vm));
    try std.testing.expect(rope.isEql(interned, vm));
    try std.testing.expect(interned.isEql(rope, vm));
    try std.testing.expect(!rope.isEql(shorter, vm));
    try std.testing.expect(!shorter.isEql(rope, vm));
    try std.testing.expect(rope.asDyn().asString().repr == .rope);
}

test "string repeat allocates one rope accumulator" {
    var vm = VM.create();
    try vm.init(allocator, writers, rc_config);
    defer vm.deinit();

    const s = Elem.string(try vm.strings.insert("ab"));

    const before = vm.uniqueIdCount;
    const repeated = (try Elem.repeat(s, Elem.numberFloat(500), &vm)).?;
    try std.testing.expectEqual(before + 1, vm.uniqueIdCount);
    try std.testing.expectEqual(@as(usize, 1000), repeated.asDyn().asString().byteLen());
}

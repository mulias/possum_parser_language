const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = @import("testing.zig");
const VM = @import("vm.zig").VM;
const logger = @import("./logger.zig");
const Elem = @import("elem.zig").Elem;
const allocator = std.testing.allocator;

test "'a' > 'b' > 'c' | 'abz'" {
    const parser =
        \\ 'a' > 'b' > 'c' | 'abz'
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abc"),
            Elem.string(vm.getStringId("c").?),
            .{ 0, 3 },
        );
    }
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "abzsss"),
            Elem.string(vm.getStringId("abz").?),
            .{ 0, 3 },
        );
    }
    {
        var vm = VM.init(allocator);
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
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "56789"),
            Elem.integerString(5678, vm.getStringId("5678").?),
            .{ 0, 4 },
        );
    }
}

test "'foo' + 'bar' + 'baz'" {
    const parser =
        \\ 'foo' + 'bar' + 'baz'
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "foobarbaz"),
            (try Elem.Dyn.String.copy(&vm, "foobarbaz")).dyn.elem(),
            .{ 0, 9 },
        );
    }
}

test "1 + 2 + 3" {
    const parser =
        \\ 1 + 2 + 3
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123"),
            Elem.integer(6),
            .{ 0, 3 },
        );
    }
}

test "1.23 + 10" {
    const parser =
        \\ 1.23 + 10
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1.2310"),
            Elem.float(11.23),
            .{ 0, 6 },
        );
    }
}

test "0.1 + 0.2" {
    const parser =
        \\ 0.1 + 0.2
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "0.10.2"),
            Elem.float(0.30000000000000004),
            .{ 0, 6 },
        );
    }
}

test "1e57 + 3e-4" {
    const parser =
        \\ 1e57 + 3e-4
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "1e573e-4"),
            Elem.float(1.0e+57),
            .{ 0, 8 },
        );
    }
}

// test "'foo' $ 'bar'" {
//     const parser =
//         \\ 'foo' $ 'bar'
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "foo"),
//             Elem.string(vm.getStringId("bar").?),
//             .{ 0, 3 },
//         );
//     }
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectFailure(try vm.interpret(parser, "f"));
//     }
// }

// test "1 ! 12 ! 123" {
//     const parser =
//         \\ 1 ! 12 ! 123
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "123"),
//             Elem.integer(123, vm.getStringId("123").?),
//             .{ 0, 3 },
//         );
//     }
// }

// test "'true' ? 'foo' + 'bar' : 'baz'" {
//     const parser =
//         \\ 'true' ? 'foo' + 'bar' : 'baz'
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "truefoobar"),
//             Elem.string(vm.getStringId("foobar").?),
//             .{ 0, 10 },
//         );
//     }
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "baz"),
//             Elem.string(vm.getStringId("baz").?),
//             .{ 0, 3 },
//         );
//     }
// }

test "1000..10000 | 100..1000" {
    const parser =
        \\ 1000..10000 | 100..1000
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "888"),
            Elem.integer(888),
            .{ 0, 3 },
        );
    }
}

test "-100..-1" {
    const parser =
        \\ -100..-1
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "-5"),
            Elem.integer(-5),
            .{ 0, 2 },
        );
    }
}

test "'a'..'z' + 'o'..'o' + 'l'..'q'" {
    const parser =
        \\ 'a'..'z' + 'o'..'o' + 'l'..'q'
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, "foo"),
            (try Elem.Dyn.String.copy(&vm, "foo")).dyn.elem(),
            .{ 0, 3 },
        );
    }
}

test "'true' $ true" {
    const parser =
        \\ 'true' $ true
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "true"),
            Elem.trueConst,
            .{ 0, 4 },
        );
    }
}

test "('' $ null) + ('' $ null)" {
    const parser =
        \\ ('' $ null) + ('' $ null)
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();

        try testing.expectSuccess(
            try vm.interpret(parser, ""),
            Elem.nullConst,
            .{ 0, 0 },
        );
    }
}

// test "('a' $ [1, 2]) + ('b' $ [true, false])" {
//     var alloc = std.testing.allocator;
//     var vm = VM.init(allocator);
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
//     var vm = VM.init(allocator);
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

// test "'f' <- 'a'..'z' & 12 <- 0..100" {
//     const parser =
//         \\ 'f' <- 'a'..'z' & 12 <- 0..100
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "f12"),
//             Elem.integer(12, null),
//             .{ 0, 3 },
//         );
//     }
// }

// test "42 <- 42.0" {
//     const parser =
//         \\ 42 <- 42.0
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();

//         try testing.expectSuccess(
//             try vm.interpret(parser, "42.0"),
//             Elem.float(42.0, vm.getStringId("42.0").?),
//             .{ 0, 4 },
//         );
//     }
// }

test "false <- ('' $ true)" {
    const parser =
        \\  false <- ('' $ true)
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectFailure(try vm.interpret(parser, "42.0"));
    }
}

// test "('a' + 'b') <- 'ab'" {
//     const parser =
//         \\ ('a' + 'b') <- 'ab'
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "ab"),
//             (try Elem.Dyn.String.copy(&vm, "ab")).dyn.elem(),
//             .{ 0, 2 },
//         );
//     }
// }

test "123 & 456 | 789 $ true & 'xyz'" {
    const parser =
        \\ 123 & 456 | 789 $ true & 'xyz'
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "123789xyz"),
            Elem.string(vm.getStringId("xyz").?),
            .{ 0, 9 },
        );
    }
    // {
    //     var vm = VM.init(allocator);
    //     defer vm.deinit();
    //     try testing.expectFailure(
    //         try vm.interpret(parser, "12378xyz"),
    //     );
    // }
}

// test "1 ? 2 & 3 : 4" {
//     const parser =
//         \\ 1 ? 2 & 3 : 4
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "123"),
//             Elem.integer(3, vm.getStringId("3").?),
//             .{ 0, 3 },
//         );
//     }
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try testing.expectSuccess(
//             try vm.interpret(parser, "4"),
//             Elem.integer(4, vm.getStringId("4").?),
//             .{ 0, 1 },
//         );
//     }
// }

// test "'foo' <- 'foo' <- 'foo'" {
//     const parser =
//         \\ "foo" <- "foo" <- "foo"
//     ;
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try std.testing.expectError(
//             error.RuntimeError,
//             vm.interpret(parser, "foofoo"),
//         );
//     }
// }

// test "empty program" {
//     const parser = "";
//     {
//         var vm = VM.init(allocator);
//         defer vm.deinit();
//         try std.testing.expectError(
//             error.RuntimeError,
//             vm.interpret(parser, ""),
//         );
//     }
// }

test "empty input" {
    const parser =
        \\ "1" | "a" | "a".."z" | ""
    ;
    {
        var vm = VM.init(allocator);
        defer vm.deinit();
        try testing.expectSuccess(
            try vm.interpret(parser, "\"\""),
            Elem.string(vm.getStringId("").?),
            .{ 0, 0 },
        );
    }
}

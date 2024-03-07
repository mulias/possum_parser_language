const std = @import("std");
const allocator = std.testing.allocator;
const VM = @import("vm.zig").VM;
const Elem = @import("elem.zig").Elem;
const Parser = @import("parser.zig").Parser;
const Ast = @import("ast.zig").Ast;
const Location = @import("location.zig").Location;
const loc = Location.new;

test "'a' > 'b' > 'c' | 'abz'" {
    const source =
        \\'a' > 'b' > 'c' | 'abz'
    ;
    var vm = VM.init(allocator);
    defer vm.deinit();

    var parser = Parser.init(&vm, source);
    defer parser.deinit();

    try parser.parse();
    var actual = parser.ast;

    var expected = Ast.init(allocator);
    defer expected.deinit();

    _ = try expected.pushElem(Elem.string(vm.strings.getId("a")), loc(1, 0, 3));
    _ = try expected.pushElem(Elem.string(vm.strings.getId("b")), loc(1, 6, 3));
    _ = try expected.pushInfix(.TakeRight, 0, 1, loc(1, 4, 1));
    _ = try expected.pushElem(Elem.string(vm.strings.getId("c")), loc(1, 12, 3));
    _ = try expected.pushInfix(.TakeRight, 2, 3, loc(1, 10, 1));
    _ = try expected.pushElem(Elem.string(vm.strings.getId("abz")), loc(1, 18, 5));
    _ = try expected.pushInfix(.Or, 4, 5, loc(1, 16, 1));

    try std.testing.expectEqualSlices(Ast.Node, expected.nodes.items, actual.nodes.items);
    try std.testing.expectEqualSlices(Location, expected.locations.items, actual.locations.items);
}

test "foo(a, b, c) = a + b + c" {
    const source =
        \\foo(a, b, c) = a + b + c
    ;
    var vm = VM.init(allocator);
    defer vm.deinit();

    var parser = Parser.init(&vm, source);
    defer parser.deinit();

    try parser.parse();
    var actual = parser.ast;

    var expected = Ast.init(allocator);
    defer expected.deinit();

    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("foo")), loc(1, 0, 3));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("a")), loc(1, 4, 1));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("b")), loc(1, 7, 1));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("c")), loc(1, 10, 1));
    _ = try expected.pushInfix(.ParamsOrArgs, 2, 3, loc(1, 8, 1));
    _ = try expected.pushInfix(.ParamsOrArgs, 1, 4, loc(1, 5, 1));
    _ = try expected.pushInfix(.CallOrDefineFunction, 0, 5, loc(1, 3, 1));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("a")), loc(1, 15, 1));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("b")), loc(1, 19, 1));
    _ = try expected.pushInfix(.Merge, 7, 8, loc(1, 17, 1));
    _ = try expected.pushElem(Elem.parserVar(vm.strings.getId("c")), loc(1, 23, 1));
    _ = try expected.pushInfix(.Merge, 9, 10, loc(1, 21, 1));
    _ = try expected.pushInfix(.DeclareGlobal, 6, 11, loc(1, 13, 1));

    try std.testing.expectEqualSlices(Ast.Node, expected.nodes.items, actual.nodes.items);
    try std.testing.expectEqualSlices(Location, expected.locations.items, actual.locations.items);
}

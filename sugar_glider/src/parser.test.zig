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

    _ = try parser.program();
    const actual = parser.ast;

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

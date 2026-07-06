const std = @import("std");
const allocator = std.testing.allocator;
const Frontend = @import("frontend.zig").Frontend;
const DependencyGraph = @import("frontend/dependency_graph.zig");
const Module = @import("module.zig").Module;
const StringTable = @import("string_table.zig").StringTable(.frontend);
const writers = @import("testing.zig").writers;

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const NodeKey = DependencyGraph.NodeKey;

fn key(module_id: Module.Id, name: StringTable.Id) NodeKey {
    return .{ .module_id = module_id, .name = name };
}

fn dependsOn(frontend: *Frontend, from: NodeKey, to: NodeKey) bool {
    const node = frontend.findNode(from.module_id, from.name) orelse return false;
    for (node.dependencies()) |dep| {
        if (dep.module_id == to.module_id and dep.name == to.name) return true;
    }
    return false;
}

fn captures(frontend: *Frontend, anon: NodeKey, parent_name: StringTable.Id, local: StringTable.Id) bool {
    const node = frontend.findNode(anon.module_id, anon.name) orelse return false;
    if (node.* != .anonymous_function) return false;
    for (node.anonymous_function.closure_captures.items) |capture| {
        if (capture.parent_name == parent_name and capture.local == local) return true;
    }
    return false;
}

test "single module with main parser" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ "1" | "2"
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    try std.testing.expect(frontend.main != null);
}

test "module with declarations" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo(N) = "foo" $ N
        \\ bar(P) = "bar" $ P
        \\ foo("input")
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    // Check that declarations were found
    const foo_id = try frontend.strings.insert("foo");
    const bar_id = try frontend.strings.insert("bar");

    const foo_key = DependencyGraph.NodeKey{ .module_id = 0, .name = foo_id };
    const bar_key = DependencyGraph.NodeKey{ .module_id = 0, .name = bar_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(foo_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(bar_key));

    try std.testing.expect(frontend.main != null);
}

test "multiple modules with dependencies" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    // Module 0: utility functions
    const util_source =
        \\ digit = "0".."9"
        \\ letter = "a".."z" | "A".."Z"
    ;

    const util_module = Module{
        .id = 0,
        .name = "util",
        .source = util_source,
    };

    // Module 1: main module that depends on util
    const main_source =
        \\ number = digit * 1..
        \\ word = letter * 1..
        \\ number | word
    ;

    const main_module = Module{
        .id = 1,
        .name = "main",
        .source = main_source,
    };

    // Add util module first
    try frontend.addModule(util_module, .{});

    // Add main module and set it as target
    try frontend.addTargetModule(main_module, .{});

    // Add dependency: main depends on util
    try frontend.addModuleDependency(1, 0);

    try frontend.finalize();

    // Check that declarations exist in both modules
    const digit_id = try frontend.strings.insert("digit");
    const letter_id = try frontend.strings.insert("letter");
    const number_id = try frontend.strings.insert("number");
    const word_id = try frontend.strings.insert("word");

    const digit_key = DependencyGraph.NodeKey{ .module_id = 0, .name = digit_id };
    const letter_key = DependencyGraph.NodeKey{ .module_id = 0, .name = letter_id };
    const number_key = DependencyGraph.NodeKey{ .module_id = 1, .name = number_id };
    const word_key = DependencyGraph.NodeKey{ .module_id = 1, .name = word_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(digit_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(letter_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(number_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(word_key));

    // Names in module 1 resolve to declarations in the depended-on module 0
    try expect(dependsOn(frontend, number_key, digit_key));
    try expect(dependsOn(frontend, word_key, letter_key));

    // Check that main parser exists
    try std.testing.expect(frontend.main != null);

    // Check module dependencies were recorded
    const main_deps = frontend.resolver.module_dependencies.get(1);
    try std.testing.expect(main_deps != null);
    try std.testing.expectEqual(@as(usize, 1), main_deps.?.items.len);
    try std.testing.expectEqual(@as(Module.Id, 0), main_deps.?.items[0]);
}

test "later import shadows earlier import" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const util_a_module = Module{ .id = 0, .name = "util_a", .source = "shared = \"a\"" };
    const util_b_module = Module{ .id = 1, .name = "util_b", .source = "shared = \"b\"" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_it = shared
        \\ use_it
        ,
    };

    try frontend.addModule(util_a_module, .{});
    try frontend.addModule(util_b_module, .{});
    try frontend.addTargetModule(main_module, .{});

    // main imports util_a first, then util_b
    try frontend.addModuleDependency(2, 0);
    try frontend.addModuleDependency(2, 1);

    try frontend.finalize();

    const shared_id = try frontend.strings.insert("shared");
    const use_it_id = try frontend.strings.insert("use_it");
    const use_it_key = key(2, use_it_id);

    // The later import (util_b, module 1) shadows the earlier (util_a, module 0).
    try expect(dependsOn(frontend, use_it_key, key(1, shared_id)));
    try expect(!dependsOn(frontend, use_it_key, key(0, shared_id)));
}

test "identifier resolves through transitive dependency" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const base_module = Module{ .id = 0, .name = "base", .source = "base_val = \"x\"" };
    const mid_module = Module{ .id = 1, .name = "mid", .source = "mid_val = \"y\"" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_it = base_val
        \\ use_it
        ,
    };

    try frontend.addModule(base_module, .{});
    try frontend.addModule(mid_module, .{});
    try frontend.addTargetModule(main_module, .{});

    // main depends on mid, mid depends on base; main does not depend on base directly.
    try frontend.addModuleDependency(1, 0);
    try frontend.addModuleDependency(2, 1);

    try frontend.finalize();

    const base_val_id = try frontend.strings.insert("base_val");
    const use_it_id = try frontend.strings.insert("use_it");
    const use_it_key = key(2, use_it_id);

    // base_val is reachable only through the transitive dependency mid -> base.
    try expect(dependsOn(frontend, use_it_key, key(0, base_val_id)));
}

test "empty module" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const module = Module{
        .id = 0,
        .name = "empty",
        .source = "",
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    // Empty module should have no main parser
    try std.testing.expect(frontend.main == null);
}

test "declaration with value function" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ add(a, b) = a + b
        \\ result = add(1, 2)
        \\ result
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    // Check that value declarations were found
    const add_id = try frontend.strings.insert("add");
    const result_id = try frontend.strings.insert("result");

    const add_key = DependencyGraph.NodeKey{ .module_id = 0, .name = add_id };
    const result_key = DependencyGraph.NodeKey{ .module_id = 0, .name = result_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(add_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(result_key));
}

test "dependency graph population" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo() = bar()
        \\ bar() = baz()
        \\ baz() = "base"
        \\ foo()
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    const foo = try frontend.strings.insert("foo");
    const bar = try frontend.strings.insert("bar");
    const baz = try frontend.strings.insert("baz");

    // foo() -> bar() -> baz() -> (leaf)
    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, bar), key(0, baz)));
    try expectEqual(@as(usize, 0), frontend.getNode(key(0, baz)).dependencies().len);
}

test "anonymous functions" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo(a) = bar(a + a)
        \\ bar(b) = b + b
        \\ foo(1)
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    const foo = try frontend.strings.insert("foo");
    const bar = try frontend.strings.insert("bar");
    const a = try frontend.strings.insert("a");
    // The parser argument `a + a` is lifted into an anonymous function.
    const fn0 = try frontend.strings.insert("@fn0");

    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, foo), key(0, fn0)));

    // The lifted function closes over `a` from its parent foo
    try expect(captures(frontend, key(0, fn0), foo, a));
}

test "nested anonymous functions" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo(a) = bar(bar(a + a) + foo(a))
        \\ bar(b) = b + b
        \\ foo(1)
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    const foo = try frontend.strings.insert("foo");
    const a = try frontend.strings.insert("a");
    const fn0 = try frontend.strings.insert("@fn0");
    const fn1 = try frontend.strings.insert("@fn1");

    // @fn1 is nested inside @fn0, which is nested inside foo. Each level
    // captures `a` from its immediate parent's frame.
    try expect(captures(frontend, key(0, fn0), foo, a));
    try expect(captures(frontend, key(0, fn1), fn0, a));
}

test "nested anonymous functions with multiple captures" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo(a) = bar(a -> N & foo(a * N))
        \\ bar(b) = b + b
        \\ foo(1)
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    const a = try frontend.strings.insert("a");
    const n = try frontend.strings.insert("N");
    const fn0 = try frontend.strings.insert("@fn0");
    const fn1 = try frontend.strings.insert("@fn1");

    // The innermost function `foo(a * N)` captures both `a` and `N` from @fn0
    try expect(captures(frontend, key(0, fn1), fn0, a));
    try expect(captures(frontend, key(0, fn1), fn0, n));

    // orderCapturedLocals places captured names first, in capture order, so
    // runtime SetClosureCaptures can copy capture slot N into local slot N.
    const fn1_node = frontend.getNode(key(0, fn1));
    const locals = fn1_node.anonymous_function.locals.items;
    try expectEqual(@as(usize, 2), locals.len);
    try expectEqual(a, locals[0]);
    try expectEqual(n, locals[1]);
}

test "circular deps" {
    var frontend = try Frontend.init(allocator, writers);
    defer frontend.deinit();

    const source =
        \\ foo = bar
        \\ bar = foo
        \\ foo
    ;

    const module = Module{
        .id = 0,
        .name = "test",
        .source = source,
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    const foo = try frontend.strings.insert("foo");
    const bar = try frontend.strings.insert("bar");

    // The resolver records edges without rejecting cycles: foo and bar depend
    // on each other. Breaking the cycle is left to the compiler.
    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, bar), key(0, foo)));
}

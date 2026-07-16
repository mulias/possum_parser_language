const std = @import("std");
const allocator = std.testing.allocator;
const Frontend = @import("frontend.zig").Frontend;
const VM = @import("runtime.zig").VM;
const NodeKey = @import("frontend.zig").GlobalKey;
const Module = @import("runtime.zig").Module;
const StringTable = @import("frontend.zig").StringTable;
const PathTable = @import("frontend.zig").PathTable;
const writers = @import("testing.zig").writers;
const Region = @import("region.zig").Region;

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

fn key(module_id: Module.Id, name: PathTable.Id) NodeKey {
    return .{ .module_id = module_id, .name = name };
}

fn dependsOn(frontend: *Frontend, from: NodeKey, to: NodeKey) bool {
    const node = frontend.findNode(from.module_id, from.name) orelse return false;
    for (node.dependencies()) |edge| {
        if (edge.target.module_id == to.module_id and edge.target.name == to.name) return true;
    }
    return false;
}

fn captures(frontend: *Frontend, anon: NodeKey, parent_name: PathTable.Id, local: StringTable.Id) bool {
    const node = frontend.findNode(anon.module_id, anon.name) orelse return false;
    if (node.* != .anonymous_function) return false;
    for (node.anonymous_function.closure_captures.items) |capture| {
        if (capture.parent_name == parent_name and capture.local == local) return true;
    }
    return false;
}

test "single module with main parser" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    const foo_id = try frontend.paths.insert(&frontend.strings, "foo");
    const bar_id = try frontend.paths.insert(&frontend.strings, "bar");

    const foo_key = NodeKey{ .module_id = 0, .name = foo_id };
    const bar_key = NodeKey{ .module_id = 0, .name = bar_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(foo_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(bar_key));

    try std.testing.expect(frontend.main != null);
}

test "multiple modules with dependencies" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    try frontend.addModuleDump(1, 0);

    try frontend.finalize();

    // Check that declarations exist in both modules
    const digit_id = try frontend.paths.insert(&frontend.strings, "digit");
    const letter_id = try frontend.paths.insert(&frontend.strings, "letter");
    const number_id = try frontend.paths.insert(&frontend.strings, "number");
    const word_id = try frontend.paths.insert(&frontend.strings, "word");

    const digit_key = NodeKey{ .module_id = 0, .name = digit_id };
    const letter_key = NodeKey{ .module_id = 0, .name = letter_id };
    const number_key = NodeKey{ .module_id = 1, .name = number_id };
    const word_key = NodeKey{ .module_id = 1, .name = word_id };

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
    const main_deps = frontend.resolver.dumps.get(1);
    try std.testing.expect(main_deps != null);
    try std.testing.expectEqual(@as(usize, 1), main_deps.?.items.len);
    try std.testing.expectEqual(@as(Module.Id, 0), main_deps.?.items[0]);
}

test "later import shadows earlier import" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    try frontend.addModuleDump(2, 0);
    try frontend.addModuleDump(2, 1);

    try frontend.finalize();

    const shared_id = try frontend.paths.insert(&frontend.strings, "shared");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");
    const use_it_key = key(2, use_it_id);

    // The later import (util_b, module 1) shadows the earlier (util_a, module 0).
    try expect(dependsOn(frontend, use_it_key, key(1, shared_id)));
    try expect(!dependsOn(frontend, use_it_key, key(0, shared_id)));
}

test "identifier resolves through transitive dependency" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    try frontend.addModuleDump(1, 0);
    try frontend.addModuleDump(2, 1);

    try frontend.finalize();

    const base_val_id = try frontend.paths.insert(&frontend.strings, "base_val");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");
    const use_it_key = key(2, use_it_id);

    // base_val is reachable only through the transitive dependency mid -> base.
    try expect(dependsOn(frontend, use_it_key, key(0, base_val_id)));
}

test "empty module" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    const add_id = try frontend.paths.insert(&frontend.strings, "add");
    const result_id = try frontend.paths.insert(&frontend.strings, "result");

    const add_key = NodeKey{ .module_id = 0, .name = add_id };
    const result_key = NodeKey{ .module_id = 0, .name = result_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(add_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(result_key));
}

test "dependency graph population" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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

    const foo = try frontend.paths.insert(&frontend.strings, "foo");
    const bar = try frontend.paths.insert(&frontend.strings, "bar");
    const baz = try frontend.paths.insert(&frontend.strings, "baz");

    // foo() -> bar() -> baz() -> (leaf)
    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, bar), key(0, baz)));
    try expectEqual(@as(usize, 0), frontend.getNode(key(0, baz)).dependencies().len);
}

test "anonymous functions" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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

    const foo = try frontend.paths.insert(&frontend.strings, "foo");
    const bar = try frontend.paths.insert(&frontend.strings, "bar");
    const a = try frontend.strings.insert("a");
    // The parser argument `a + a` is lifted into an anonymous function.
    const fn0 = try frontend.paths.insert(&frontend.strings, "@fn0");

    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, foo), key(0, fn0)));

    // The lifted function closes over `a` from its parent foo
    try expect(captures(frontend, key(0, fn0), foo, a));
}

test "nested anonymous functions" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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

    const foo = try frontend.paths.insert(&frontend.strings, "foo");
    const a = try frontend.strings.insert("a");
    const fn0 = try frontend.paths.insert(&frontend.strings, "@fn0");
    const fn1 = try frontend.paths.insert(&frontend.strings, "@fn1");

    // @fn1 is nested inside @fn0, which is nested inside foo. Each level
    // captures `a` from its immediate parent's frame.
    try expect(captures(frontend, key(0, fn0), foo, a));
    try expect(captures(frontend, key(0, fn1), fn0, a));
}

test "nested anonymous functions with multiple captures" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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
    const fn0 = try frontend.paths.insert(&frontend.strings, "@fn0");
    const fn1 = try frontend.paths.insert(&frontend.strings, "@fn1");

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

test "alias resolves qualified names" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const json_module = Module{ .id = 0, .name = "json", .source = "bool = \"true\" | \"false\"" };
    const main_module = Module{
        .id = 1,
        .name = "main",
        .source =
        \\ use_it = json.bool
        \\ use_it
        ,
    };

    try frontend.addModule(json_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "json", 0, null, Region.new(0, 0));

    try frontend.finalize();

    const bool_id = try frontend.paths.insert(&frontend.strings, "bool");
    const json_bool_id = try frontend.paths.insert(&frontend.strings, "json.bool");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    // The edge keeps the use-site spelling but targets the export's own key.
    try expect(dependsOn(frontend, key(1, use_it_id), key(0, bool_id)));
    const use_it_node = frontend.findNode(1, use_it_id).?;
    const target = use_it_node.dependencyNamed(json_bool_id).?;
    try expectEqual(@as(Module.Id, 0), target.module_id);
    try expectEqual(bool_id, target.name);
}

test "alias selector re-roots member paths" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const util_module = Module{ .id = 0, .name = "util", .source = "sub.x = \"x\"" };
    const main_module = Module{
        .id = 1,
        .name = "main",
        .source =
        \\ use_it = n.x
        \\ use_it
        ,
    };

    try frontend.addModule(util_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "n", 0, "sub", Region.new(0, 0));

    try frontend.finalize();

    const sub_x_id = try frontend.paths.insert(&frontend.strings, "sub.x");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    try expect(dependsOn(frontend, key(1, use_it_id), key(0, sub_x_id)));
}

test "alias kind filter hides mismatched exports" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const util_module = Module{ .id = 0, .name = "util", .source = "Val = 1" };
    const main_module = Module{
        .id = 1,
        .name = "main",
        .source =
        \\ hidden = num.Val
        \\ Found = Num.Val
        \\ hidden
        ,
    };

    try frontend.addModule(util_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "num", 0, null, Region.new(0, 0));
    try frontend.addModuleAlias(1, "Num", 0, null, Region.new(0, 0));

    try frontend.finalize();

    const val_id = try frontend.paths.insert(&frontend.strings, "Val");
    const hidden_id = try frontend.paths.insert(&frontend.strings, "hidden");
    const found_id = try frontend.paths.insert(&frontend.strings, "Found");

    // A lowercase alias exposes only parsers, so the value export Val is
    // invisible through num but visible through Num.
    try expect(!dependsOn(frontend, key(1, hidden_id), key(0, val_id)));
    try expect(dependsOn(frontend, key(1, found_id), key(0, val_id)));
}

test "alias is re-exported through dumps" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const json_module = Module{ .id = 0, .name = "json", .source = "bool = \"true\"" };
    const barrel_module = Module{ .id = 1, .name = "barrel", .source = "" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_it = json.bool
        \\ use_it
        ,
    };

    try frontend.addModule(json_module, .{});
    try frontend.addModule(barrel_module, .{});
    try frontend.addTargetModule(main_module, .{});
    // The barrel imports json under an alias; main only dumps the barrel.
    try frontend.addModuleAlias(1, "json", 0, null, Region.new(0, 0));
    try frontend.addModuleDump(2, 1);

    try frontend.finalize();

    const bool_id = try frontend.paths.insert(&frontend.strings, "bool");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    try expect(dependsOn(frontend, key(2, use_it_id), key(0, bool_id)));
}

test "private alias is not re-exported" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const json_module = Module{ .id = 0, .name = "json", .source = "bool = \"true\"" };
    // The barrel uses its own private alias; importers of the barrel can't.
    const barrel_module = Module{ .id = 1, .name = "barrel", .source = "own_use = _json.bool" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_it = _json.bool
        \\ use_it
        ,
    };

    try frontend.addModule(json_module, .{});
    try frontend.addModule(barrel_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "_json", 0, null, Region.new(0, 0));
    try frontend.addModuleDump(2, 1);

    try frontend.finalize();

    const bool_id = try frontend.paths.insert(&frontend.strings, "bool");
    const own_use_id = try frontend.paths.insert(&frontend.strings, "own_use");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    try expect(dependsOn(frontend, key(1, own_use_id), key(0, bool_id)));
    try expect(!dependsOn(frontend, key(2, use_it_id), key(0, bool_id)));
}

test "alias chains through re-exports" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const d_module = Module{ .id = 0, .name = "d", .source = "x = \"x\"" };
    const b_module = Module{ .id = 1, .name = "b", .source = "" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_it = a.c.x
        \\ use_it
        ,
    };

    try frontend.addModule(d_module, .{});
    try frontend.addModule(b_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "c", 0, null, Region.new(0, 0));
    try frontend.addModuleAlias(2, "a", 1, null, Region.new(0, 0));

    try frontend.finalize();

    const x_id = try frontend.paths.insert(&frontend.strings, "x");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    try expect(dependsOn(frontend, key(2, use_it_id), key(0, x_id)));
}

test "bare alias binds the target module's main parser" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const json_module = Module{
        .id = 0,
        .name = "json",
        .source =
        \\ bool = "true" | "false"
        \\ bool | "null"
        ,
    };
    const main_module = Module{
        .id = 1,
        .name = "main",
        .source =
        \\ use_it = json
        \\ use_it
        ,
    };

    try frontend.addModule(json_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "json", 0, null, Region.new(0, 0));

    try frontend.finalize();

    const main_id = try frontend.paths.insert(&frontend.strings, "@main");
    const use_it_id = try frontend.paths.insert(&frontend.strings, "use_it");

    try expect(dependsOn(frontend, key(1, use_it_id), key(0, main_id)));
}

test "alias root binding chains through re-exports" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const d_module = Module{
        .id = 0,
        .name = "d",
        .source =
        \\ x = "x"
        \\ "d"
        ,
    };
    const b_module = Module{ .id = 1, .name = "b", .source = "" };
    const main_module = Module{
        .id = 2,
        .name = "main",
        .source =
        \\ use_root = a.c
        \\ use_member = a.c.x
        \\ use_root | use_member
        ,
    };

    try frontend.addModule(d_module, .{});
    try frontend.addModule(b_module, .{});
    try frontend.addTargetModule(main_module, .{});
    try frontend.addModuleAlias(1, "c", 0, null, Region.new(0, 0));
    try frontend.addModuleAlias(2, "a", 1, null, Region.new(0, 0));

    try frontend.finalize();

    const main_id = try frontend.paths.insert(&frontend.strings, "@main");
    const x_id = try frontend.paths.insert(&frontend.strings, "x");
    const use_root_id = try frontend.paths.insert(&frontend.strings, "use_root");
    const use_member_id = try frontend.paths.insert(&frontend.strings, "use_member");

    // a.c is d's main parser and a.c.x is d's export x.
    try expect(dependsOn(frontend, key(2, use_root_id), key(0, main_id)));
    try expect(dependsOn(frontend, key(2, use_member_id), key(0, x_id)));
}

test "uppercase alias binds no root" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    // Created through the VM so that diagnostic reporting can look the
    // module up when finalize fails.
    const util_module = try vm.createModule("util", "\"u\"");
    const main_module = try vm.createModule("main",
        \\ Found = Util
        \\ "x" $ Found
    );

    try frontend.addModule(util_module.*, .{});
    try frontend.addTargetModule(main_module.*, .{});
    try frontend.addModuleAlias(main_module.id, "Util", util_module.id, null, Region.new(0, 0));

    // The main parser is a parser, so a value alias has no root; the bare
    // Util falls through to an unbound local.
    try std.testing.expectError(Frontend.Error.UnboundVariable, frontend.finalize());
}

test "cyclic selector aliases terminate" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
    defer frontend.deinit();

    const module = Module{
        .id = 0,
        .name = "cyclic",
        .source =
        \\ foo = x.foo
        \\ foo
        ,
    };

    try frontend.addTargetModule(module, .{});
    // Each rewrite of x grows the name (x.R -> y.x.R -> x.x.R -> ...), so
    // resolution can only stop at the rewrite cap.
    try frontend.addModuleAlias(0, "x", 0, "y.x", Region.new(0, 0));
    try frontend.addModuleAlias(0, "y", 0, "x", Region.new(0, 0));

    try frontend.finalize();

    const foo_id = try frontend.paths.insert(&frontend.strings, "foo");
    const foo_node = frontend.findNode(0, foo_id).?;
    try expectEqual(@as(usize, 0), foo_node.dependencies().len);
}

test "circular deps" {
    var vm: VM = undefined;
    try vm.init(allocator, writers, .{});
    defer vm.deinit();
    var frontend = try Frontend.init(&vm);
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

    const foo = try frontend.paths.insert(&frontend.strings, "foo");
    const bar = try frontend.paths.insert(&frontend.strings, "bar");

    // The resolver records edges without rejecting cycles: foo and bar depend
    // on each other. Breaking the cycle is left to the compiler.
    try expect(dependsOn(frontend, key(0, foo), key(0, bar)));
    try expect(dependsOn(frontend, key(0, bar), key(0, foo)));
}

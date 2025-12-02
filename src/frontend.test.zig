const std = @import("std");
const allocator = std.testing.allocator;
const Frontend = @import("frontend.zig").Frontend;
const DependencyGraph = @import("frontend/dependency_graph.zig");
const Module = @import("module.zig").Module;
const StringTable = @import("string_table.zig").StringTable;
const Writers = @import("writer.zig").Writers;

var null_buffer: [256]u8 = undefined;
var null_discarding = std.Io.Writer.Discarding.init(&null_buffer);

fn printGraph(frontend: *Frontend) !void {
    _ = frontend;
    // Disabled to avoid hanging in build system
    // const stdout = std.fs.File.stdout();
    // var out_buffer: [4096]u8 = undefined;
    // var stdout_writer = stdout.writer(&out_buffer);
    // defer stdout_writer.interface.flush() catch {};
    // try frontend.resolver.graph.print(frontend.strings.*, &stdout_writer.interface);
}

const writers = Writers{
    .out = &null_discarding.writer,
    .err = &null_discarding.writer,
    .debug = &null_discarding.writer,
};

test "single module with main parser" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // Check that main parser was found
    try std.testing.expect(frontend.main != null);
}

test "module with declarations" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // Check that declarations were found
    const foo_id = try strings.insert("foo");
    const bar_id = try strings.insert("bar");

    const foo_key = DependencyGraph.NodeKey{ .module_id = 0, .name = foo_id };
    const bar_key = DependencyGraph.NodeKey{ .module_id = 0, .name = bar_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(foo_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(bar_key));

    // Check that main parser was found
    try std.testing.expect(frontend.main != null);
}

test "multiple modules with dependencies" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // Check that declarations exist in both modules
    const digit_id = try strings.insert("digit");
    const letter_id = try strings.insert("letter");
    const number_id = try strings.insert("number");
    const word_id = try strings.insert("word");

    const digit_key = DependencyGraph.NodeKey{ .module_id = 0, .name = digit_id };
    const letter_key = DependencyGraph.NodeKey{ .module_id = 0, .name = letter_id };
    const number_key = DependencyGraph.NodeKey{ .module_id = 1, .name = number_id };
    const word_key = DependencyGraph.NodeKey{ .module_id = 1, .name = word_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(digit_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(letter_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(number_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(word_key));

    // Check that main parser exists
    try std.testing.expect(frontend.main != null);

    // Check module dependencies were recorded
    const main_deps = frontend.resolver.module_dependencies.get(1);
    try std.testing.expect(main_deps != null);
    try std.testing.expectEqual(@as(usize, 1), main_deps.?.items.len);
    try std.testing.expectEqual(@as(Module.Id, 0), main_deps.?.items[0]);
}

test "empty module" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
    defer frontend.deinit();

    const module = Module{
        .id = 0,
        .name = "empty",
        .source = "",
    };

    try frontend.addTargetModule(module, .{});
    try frontend.finalize();

    try printGraph(frontend);

    // Empty module should have no main parser
    try std.testing.expect(frontend.main == null);
}

test "declaration with value function" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // Check that value declarations were found
    const add_id = try strings.insert("add");
    const result_id = try strings.insert("result");

    const add_key = DependencyGraph.NodeKey{ .module_id = 0, .name = add_id };
    const result_key = DependencyGraph.NodeKey{ .module_id = 0, .name = result_id };

    try std.testing.expect(frontend.resolver.graph.nodes.contains(add_key));
    try std.testing.expect(frontend.resolver.graph.nodes.contains(result_key));
}

test "dependency graph population" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // After finalize, dependency graph should be populated
    // This will help track which functions depend on which other functions
    // The exact structure to test will depend on the DependencyGraph implementation
}

test "anonymous functions" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // After finalize, dependency graph should be populated
    // This will help track which functions depend on which other functions
    // The exact structure to test will depend on the DependencyGraph implementation
}

test "nested anonymous functions" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // After finalize, dependency graph should be populated
    // This will help track which functions depend on which other functions
    // The exact structure to test will depend on the DependencyGraph implementation
}

test "nested anonymous functions with multiple captures" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // After finalize, dependency graph should be populated
    // This will help track which functions depend on which other functions
    // The exact structure to test will depend on the DependencyGraph implementation
}

test "circular deps" {
    var strings = StringTable.init(allocator);
    defer strings.deinit();

    var frontend = try Frontend.init(allocator, &strings, writers);
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

    try printGraph(frontend);

    // After finalize, dependency graph should be populated
    // This will help track which functions depend on which other functions
    // The exact structure to test will depend on the DependencyGraph implementation
}

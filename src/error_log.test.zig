const std = @import("std");
const testing = std.testing;
const ErrorLog = @import("error_log.zig").ErrorLog;
const InputPosition = @import("error_log.zig").InputPosition;
const ParserType = @import("error_log.zig").ParserType;
const StringTable = @import("string_table.zig").StringTable;

test "ErrorLog basic initialization and cleanup" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    // Basic sanity checks
    try testing.expect(error_log.logical_call_history.items.len == 0);
    try testing.expect(error_log.errors_by_position.count() == 0);
    try testing.expect(error_log.errors_by_function.count() == 0);
}

test "ErrorLog function call tracking" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    // Test adding function calls
    error_log.addFunctionCall(1, false);
    error_log.addFunctionCall(2, false);
    error_log.addFunctionCall(3, false);

    const call_stack = error_log.getCurrentCallStack();
    try testing.expect(call_stack.len == 3);
    try testing.expect(call_stack[0] == 1);
    try testing.expect(call_stack[1] == 2);
    try testing.expect(call_stack[2] == 3);
}

test "ErrorLog function call deduplication" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    // Test deduplication of direct recursion
    error_log.addFunctionCall(1, false);
    error_log.addFunctionCall(1, false); // Should be deduplicated
    error_log.addFunctionCall(2, false);
    error_log.addFunctionCall(2, false); // Should be deduplicated

    const call_stack = error_log.getCurrentCallStack();
    try testing.expect(call_stack.len == 2);
    try testing.expect(call_stack[0] == 1);
    try testing.expect(call_stack[1] == 2);
}

test "ErrorLog addParserFailure simple case" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    const pos = InputPosition{
        .offset = 10,
        .line = 2,
        .line_start = 5,
    };

    const parser_expr = "\"hello\"";
    const parser_type = ParserType.String;
    const call_stack = &[_]StringTable.Id{};

    // This should not crash
    try error_log.addParserFailure(pos, parser_expr, parser_type, call_stack);

    // Check that error was recorded
    try testing.expect(error_log.errors_by_position.count() == 1);
    try testing.expect(error_log.errors_by_function.count() == 1);

    // Check position-based error
    const pos_errors = error_log.errors_by_position.get(10);
    try testing.expect(pos_errors != null);
    try testing.expect(pos_errors.?.parser_failures.items.len == 1);
    try testing.expect(std.mem.eql(u8, pos_errors.?.parser_failures.items[0].parser, "\"hello\""));
}

test "ErrorLog addParserFailure with call stack" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    const pos = InputPosition{
        .offset = 10,
        .line = 2,
        .line_start = 5,
    };

    const parser_expr = "'a'..'z'";
    const parser_type = ParserType.CharacterRange;
    var call_stack_data = [_]StringTable.Id{1, 2, 3};
    const call_stack = call_stack_data[0..];

    try error_log.addParserFailure(pos, parser_expr, parser_type, call_stack);

    // Check that error was recorded with call stack
    const pos_errors = error_log.errors_by_position.get(10);
    try testing.expect(pos_errors != null);
    try testing.expect(pos_errors.?.parser_failures.items.len == 1);
    
    const failure = pos_errors.?.parser_failures.items[0];
    try testing.expect(std.mem.eql(u8, failure.parser, "'a'..'z'"));
    try testing.expect(failure.parser_type == ParserType.CharacterRange);
    try testing.expect(failure.call_stack.len == 3);
    try testing.expect(failure.call_stack[0] == 1);
    try testing.expect(failure.call_stack[1] == 2);
    try testing.expect(failure.call_stack[2] == 3);
}

test "ErrorLog multiple failures at same position" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    const pos = InputPosition{
        .offset = 10,
        .line = 2,
        .line_start = 5,
    };

    const call_stack = &[_]StringTable.Id{};

    // Add multiple different failures at the same position
    try error_log.addParserFailure(pos, "\"hello\"", ParserType.String, call_stack);
    try error_log.addParserFailure(pos, "\"world\"", ParserType.String, call_stack);
    try error_log.addParserFailure(pos, "'a'..'z'", ParserType.CharacterRange, call_stack);

    // Check that all errors were recorded
    const pos_errors = error_log.errors_by_position.get(10);
    try testing.expect(pos_errors != null);
    try testing.expect(pos_errors.?.parser_failures.items.len == 3);
}

test "ErrorLog duplicate failure detection" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    const pos = InputPosition{
        .offset = 10,
        .line = 2,
        .line_start = 5,
    };

    var call_stack_data = [_]StringTable.Id{1};
    const call_stack = call_stack_data[0..];

    // Add the same failure twice
    try error_log.addParserFailure(pos, "\"hello\"", ParserType.String, call_stack);
    try error_log.addParserFailure(pos, "\"hello\"", ParserType.String, call_stack);

    // Should only have one entry due to deduplication
    const pos_errors = error_log.errors_by_position.get(10);
    try testing.expect(pos_errors != null);
    try testing.expect(pos_errors.?.parser_failures.items.len == 1);
}

test "ErrorLog addDestructureFailure" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const error_log = try ErrorLog.init(allocator);
    defer error_log.deinit();

    const pos = InputPosition{
        .offset = 15,
        .line = 3,
        .line_start = 10,
    };

    const value_str = "123";
    const pattern_str = "[\"abc\", 456]";
    var call_stack_data = [_]StringTable.Id{5};
    const call_stack = call_stack_data[0..];

    try error_log.addDestructureFailure(pos, value_str, pattern_str, call_stack);

    // Check that destructure error was recorded
    const pos_errors = error_log.errors_by_position.get(15);
    try testing.expect(pos_errors != null);
    try testing.expect(pos_errors.?.destructure_failures.items.len == 1);
    
    const failure = pos_errors.?.destructure_failures.items[0];
    try testing.expect(std.mem.eql(u8, failure.value, "123"));
    try testing.expect(std.mem.eql(u8, failure.pattern, "[\"abc\", 456]"));
    try testing.expect(failure.call_stack.len == 1);
    try testing.expect(failure.call_stack[0] == 5);
}
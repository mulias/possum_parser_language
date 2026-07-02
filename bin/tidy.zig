//! Dead code detection for zig files, ported from TigerBeetle's src/tidy.zig
//! by way of Roc's ci/tidy.zig.
//!
//! Two checks:
//! - Unused private declarations: a `fn` or `const` without `pub` whose name
//!   appears exactly once in its file is dead. This is a one-sided heuristic:
//!   there might be false negatives, but no false positives.
//! - Dead files: a `.zig` file in src/ that is never referenced by an
//!   `@import("...")` or a `b.path("...")` is invisible to the compiler and
//!   can't be flagged as unused by it.

const std = @import("std");
const Ast = std.zig.Ast;

const max_file_size = 4 * 1024 * 1024;

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var errors: u32 = 0;
    var counter = IdentifierCounter{};
    var detector = DeadFilesDetector{};

    const paths = try listFilePaths(arena);

    for (paths) |path| {
        if (!std.mem.endsWith(u8, path, ".zig")) continue;

        const source = std.fs.cwd().readFileAllocOptions(
            arena,
            path,
            max_file_size,
            null,
            .of(u8),
            0,
        ) catch |err| switch (err) {
            error.FileTooBig => {
                std.debug.print("{s}: error: file exceeds {d} byte limit\n", .{ path, max_file_size });
                errors += 1;
                continue;
            },
            else => return err,
        };

        var tree = try Ast.parse(arena, source, .zig);
        defer tree.deinit(arena);

        if (tree.errors.len > 0) {
            std.debug.print("{s}: error: file has syntax errors, skipping dead code checks\n", .{path});
            errors += 1;
            continue;
        }

        try deadDeclarations(arena, path, &tree, &counter, &errors);
        try detector.visit(arena, path, source);
    }

    detector.finish(&errors);

    if (errors > 0) {
        std.debug.print("{d} dead code errors\n", .{errors});
        std.process.exit(1);
    }
}

const IdentifierCounter = struct {
    map: std.StringHashMapUnmanaged(struct { count: u32, offset: u32 }) = .{},

    fn clear(counter: *IdentifierCounter) void {
        counter.map.clearRetainingCapacity();
    }

    fn record(
        counter: *IdentifierCounter,
        arena: std.mem.Allocator,
        tree: *const Ast,
        token_text: []const u8,
        token_offset: u32,
    ) !void {
        const gop = try counter.map.getOrPut(arena, token_text);

        if (gop.found_existing) {
            // Count occurrences on a single line as one, as a special case for
            // imports: `const foo = std.foo;`
            const between_tokens_text = tree.source[gop.value_ptr.offset..token_offset];
            const same_line_occurrence = std.mem.indexOfScalar(u8, between_tokens_text, '\n') == null;
            if (same_line_occurrence) return;
        } else {
            gop.value_ptr.* = .{ .count = 0, .offset = 0 };
        }

        gop.value_ptr.count += 1;
        gop.value_ptr.offset = token_offset;
    }

    fn get(counter: *const IdentifierCounter, token_text: []const u8) u32 {
        return counter.map.get(token_text).?.count;
    }
};

fn deadDeclarations(
    arena: std.mem.Allocator,
    path: []const u8,
    tree: *const Ast,
    counter: *IdentifierCounter,
    errors: *u32,
) !void {
    defer counter.clear();

    const tags = tree.tokens.items(.tag);
    const starts = tree.tokens.items(.start);

    for (tags, starts, 0..) |tag, start, index| {
        if (tag != .identifier) continue;
        const token_text = tree.tokenSlice(@intCast(index));
        try counter.record(arena, tree, token_text, start);
    }

    for (tags, 0..) |tag, index| {
        if (tag != .identifier) continue;
        const token_text = tree.tokenSlice(@intCast(index));
        const usages = counter.get(token_text);
        std.debug.assert(usages >= 1);
        if (usages == 1 and isPrivateDeclaration(tags, index)) {
            std.debug.print("{s}: error: '{s}' is dead code\n", .{ path, token_text });
            errors.* += 1;
        }
    }
}

// Checks if the given identifier token is the name of a non-public
// declaration by looking backwards at the preceding tokens.
fn isPrivateDeclaration(tags: []const std.zig.Token.Tag, token_index: usize) bool {
    std.debug.assert(tags[token_index] == .identifier);
    var declaration_keyword = false;
    for (0..4) |context_offset| {
        const context_tag: std.zig.Token.Tag = if (token_index < context_offset + 1)
            .eof
        else
            tags[token_index - context_offset - 1];

        if (!declaration_keyword) {
            switch (context_tag) {
                .keyword_fn, .keyword_const => declaration_keyword = true,
                // Not a declaration.
                else => return false,
            }
        } else {
            switch (context_tag) {
                .keyword_inline, .keyword_extern, .string_literal => {},
                // Public declaration can be used in a different file.
                .keyword_pub, .keyword_export => return false,
                // []const u8, or *const u8, or align(...), not a declaration.
                .r_bracket, .r_paren, .asterisk => return false,
                // Non public declaration, never used.
                else => return true,
            }
        }
    } else unreachable;
}

// Textual detection of unused files by scanning for import statements and
// build-registered zig roots. This gives false negatives for unreachable
// cycles of files, as well as for identically-named files, but it should be
// good enough in practice.
const DeadFilesDetector = struct {
    const FileState = struct {
        import_count: u32 = 0,
        definition_count: u32 = 0,
        is_src: bool = false,
    };

    files: std.StringArrayHashMapUnmanaged(FileState) = .{},
    errors_buffer: [64]u8 = undefined,

    fn visit(
        detector: *DeadFilesDetector,
        arena: std.mem.Allocator,
        path: []const u8,
        source: []const u8,
    ) !void {
        if (std.mem.startsWith(u8, path, "src/")) {
            const state = try detector.fileState(arena, path);
            state.definition_count += 1;
            state.is_src = true;
        }

        try detector.recordQuotedZigPaths(arena, source, "@import(\"");
        try detector.recordQuotedZigPaths(arena, source, "b.path(\"");
    }

    fn finish(detector: *DeadFilesDetector, errors: *u32) void {
        for (detector.files.keys(), detector.files.values()) |name, state| {
            if (state.is_src and state.import_count == 0) {
                std.debug.print("{s}: error: file is dead code, nothing imports it\n", .{name});
                errors.* += 1;
            }
        }
    }

    fn fileState(
        detector: *DeadFilesDetector,
        arena: std.mem.Allocator,
        path: []const u8,
    ) !*FileState {
        // Imports are relative paths, so files are keyed by their base name.
        const name = std.fs.path.basename(path);
        const gop = try detector.files.getOrPut(arena, name);
        if (!gop.found_existing) {
            // The name may point into a reused file buffer, so make a copy.
            gop.key_ptr.* = try arena.dupe(u8, name);
            gop.value_ptr.* = .{};
        }
        return gop.value_ptr;
    }

    fn recordQuotedZigPaths(
        detector: *DeadFilesDetector,
        arena: std.mem.Allocator,
        source: []const u8,
        marker: []const u8,
    ) !void {
        var rest = source;
        while (std.mem.indexOf(u8, rest, marker)) |marker_index| {
            rest = rest[marker_index + marker.len ..];
            const quote_index = std.mem.indexOfScalar(u8, rest, '"') orelse break;
            const quoted_path = rest[0..quote_index];
            rest = rest[quote_index..];
            if (!std.mem.endsWith(u8, quoted_path, ".zig")) continue;
            (try detector.fileState(arena, quoted_path)).import_count += 1;
        }
    }
};

/// Lists all files tracked in the repository.
fn listFilePaths(arena: std.mem.Allocator) ![]const []const u8 {
    const run_result = try std.process.Child.run(.{
        .allocator = arena,
        .argv = &.{ "git", "ls-files", "-z" },
        .max_output_bytes = 16 * 1024 * 1024,
    });

    if (run_result.term != .Exited or run_result.term.Exited != 0) return error.GitFailed;

    var paths = std.ArrayListUnmanaged([]const u8){};
    var lines = std.mem.splitScalar(u8, run_result.stdout, 0);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try paths.append(arena, line);
    }
    return paths.items;
}

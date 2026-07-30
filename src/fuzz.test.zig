const std = @import("std");
const builtin = @import("builtin");
const Smith = std.testing.Smith;
const Weight = Smith.Weight;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const Ast = @import("frontend/parsed_ast.zig").Ast;
const RNode = Ast.RNode;
const formatter = @import("frontend/formatter.zig");
const Region = @import("region.zig").Region;
const VM = @import("runtime.zig").VM;
const writers = @import("testing.zig").writers;

// Fuzz the ast -> format -> compile pipeline: build a random parsed ast with
// placeholder regions, print it with the formatter, and compile the printed
// source through the full frontend and backend. A random program may be
// rejected with a reported compile error, but it must never crash, fail to
// parse (the formatter's output is always valid source), or fail without
// printing a diagnostic. UnsupportedPattern failures are the pattern-bytecode
// gaps still to close; each finding's printed program is a candidate todo.t
// case.
//
// Under `zig build test` this runs once with empty fuzz input (every Smith
// choice takes its first weight's minimum) as a smoke test. Under
// `zig build test --fuzz` the fuzzer drives the Smith choices with coverage
// feedback.

test "format-compile" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(_: void, smith: *Smith) !void {
    var arena = ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var ast = Ast.init(&arena);
    var gen = Gen{ .smith = smith, .ast = &ast };
    try gen.program();

    var out = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer out.deinit();
    formatter.format(&ast, &out.writer) catch return error.OutOfMemory;
    const source = out.written();

    // In fuzz mode, persist the program before compiling so that a crash
    // inside the compiler leaves it behind; a surviving iteration removes it.
    if (builtin.fuzz) persist("inflight", source);
    defer if (builtin.fuzz) remove("inflight", source);

    // The VM's error writer is captured: the frontend and backend print a
    // diagnostic before returning a user-facing compile error, so an error
    // with no diagnostic is an internal failure.
    var err_out = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer err_out.deinit();
    var vm_writers = writers;
    vm_writers.err = &err_out.writer;

    var vm = VM.create();
    try vm.init(std.testing.allocator, vm_writers, .{
        .includeStdlib = false,
        .io = std.testing.io,
    });
    defer vm.deinit();

    vm.compile("fuzz", source) catch |err| switch (err) {
        error.OutOfMemory, error.WriteFailed => return error.OutOfMemory,
        // A pattern-bytecode gap: the finding this fuzzer exists to surface.
        error.UnsupportedPattern,
        // The formatter printed source that failed to scan or parse.
        error.UnexpectedInput,
        error.CodepointTooLarge,
        error.Utf8CannotEncodeSurrogateHalf,
        error.IntegerOverflow,
        error.InvalidEscapeSequence,
        => return reportFailure(err, source),
        else => if (err_out.written().len == 0) {
            // No diagnostic was printed: an internal error, not a
            // reported rejection of an invalid random program.
            return reportFailure(err, source);
        },
    };
}

// Print and persist the failing program. The message goes to stderr in a
// single write so that parallel fuzz workers rarely interleave, but that is
// best-effort: the file under fuzz-failures/ is the reliable artifact, and
// each one is a possum program that reproduces the failure directly.
fn reportFailure(err: anyerror, source: []const u8) anyerror {
    var msg_buf: [8192]u8 = undefined;
    const msg = std.fmt.bufPrint(&msg_buf, "\nfuzz: {t} compiling:\n{s}\n", .{ err, source }) catch
        "\nfuzz: message too long, see fuzz-failures/\n";
    std.Io.File.stderr().writeStreamingAll(std.testing.io, msg) catch {};
    persist(@errorName(err), source);
    return err;
}

fn persist(prefix: []const u8, source: []const u8) void {
    const io = std.testing.io;
    var dir = std.Io.Dir.cwd().createDirPathOpen(io, "fuzz-failures", .{}) catch return;
    defer dir.close(io);
    var name_buf: [128]u8 = undefined;
    const name = failureName(&name_buf, prefix, source) catch return;
    dir.writeFile(io, .{ .sub_path = name, .data = source }) catch {};
}

fn remove(prefix: []const u8, source: []const u8) void {
    const io = std.testing.io;
    var dir = std.Io.Dir.cwd().openDir(io, "fuzz-failures", .{}) catch return;
    defer dir.close(io);
    var name_buf: [128]u8 = undefined;
    const name = failureName(&name_buf, prefix, source) catch return;
    dir.deleteFile(io, name) catch {};
}

fn failureName(buf: []u8, prefix: []const u8, source: []const u8) ![]const u8 {
    return std.fmt.bufPrint(buf, "{s}-{x}.possum", .{
        prefix,
        std.hash.Wyhash.hash(0, source),
    });
}

const placeholder = Region.new(0, 0);

// Grammar-directed generator over the parsed ast. Only parser-producible
// shapes are emitted, so the formatted output must parse. Identifier and
// literal pools are deliberately tiny so random programs collide into valid
// bindings often enough to reach the pattern compiler.
//
// Generation follows the language's three shapes: parser expressions,
// patterns, and constructed values. The shapes share leaves but admit
// different operators.
const Gen = struct {
    smith: *Smith,
    ast: *Ast,
    decls: ArrayList(Decl) = .empty,
    nodes_left: u32 = node_budget,

    const DeclKind = enum { parser, value };
    const Decl = struct {
        name: []const u8,
        kind: DeclKind,
        arity: u8,
        params: [param_names.len]DeclKind,
    };
    const Error = error{OutOfMemory};

    const max_depth = 6;
    const node_budget = 128;

    const decl_names = [_][]const u8{ "p", "q", "r", "s" };
    const value_decl_names = [_][]const u8{ "V", "W" };
    // Parser or value spelling per parameter slot.
    const param_names = [_][2][]const u8{ .{ "x", "X" }, .{ "y", "Y" } };
    const value_names = [_][]const u8{ "A", "B", "C", "X", "Y", "V", "W" };
    const string_pool = [_][]const u8{ "", "a", "b", "ab", "abc", " ", "0" };
    const number_pool = [_][]const u8{ "0", "1", "2", "3", "7", "10", "42", "0.5" };
    const char_pool = [_][]const u8{ "a", "b", "z", "0", "9" };

    fn alc(g: *Gen) Allocator {
        return g.ast.arena.allocator();
    }

    pub fn program(g: *Gen) Error!void {
        var i: usize = 0;
        while (i < decl_names.len and !g.smith.eosWeightedSimple(2, 1)) : (i += 1) {
            try g.declaration(decl_names[i]);
        }
        var j: usize = 0;
        while (j < value_decl_names.len and !g.smith.eosWeightedSimple(1, 2)) : (j += 1) {
            try g.valueDeclaration(value_decl_names[j]);
        }
        try g.ast.pushRoot(try g.expr(0));
    }

    fn declaration(g: *Gen, name: []const u8) Error!void {
        const arity = g.smith.valueRangeAtMost(u8, 0, param_names.len);
        var param_kinds: [param_names.len]DeclKind = undefined;
        const ident = try g.identNode(name);
        const head = if (arity == 0) ident else blk: {
            var params: ArrayList(*RNode) = .empty;
            for (param_names[0..arity], 0..) |slot, i| {
                const is_value = g.smith.value(bool);
                param_kinds[i] = if (is_value) .value else .parser;
                try params.append(g.alc(), try g.identNode(slot[@intFromBool(is_value)]));
            }
            break :blk try g.ast.createFunction(ident, params, placeholder);
        };
        // Recorded before the body so the body can call itself and earlier
        // declarations.
        try g.decls.append(g.alc(), .{
            .name = name,
            .kind = .parser,
            .arity = arity,
            .params = param_kinds,
        });
        const body = try g.expr(0);
        try g.ast.pushRoot(try g.ast.createDeclareGlobal(head, body, placeholder));
    }

    // A value function declaration; parameters are values.
    fn valueDeclaration(g: *Gen, name: []const u8) Error!void {
        const arity = g.smith.valueRangeAtMost(u8, 0, param_names.len);
        const ident = try g.identNode(name);
        const head = if (arity == 0) ident else blk: {
            var params: ArrayList(*RNode) = .empty;
            for (param_names[0..arity]) |slot| {
                try params.append(g.alc(), try g.identNode(slot[1]));
            }
            break :blk try g.ast.createFunction(ident, params, placeholder);
        };
        try g.decls.append(g.alc(), .{
            .name = name,
            .kind = .value,
            .arity = arity,
            .params = @splat(.value),
        });
        const body = try g.value(0);
        try g.ast.pushRoot(try g.ast.createDeclareGlobal(head, body, placeholder));
    }

    const ExprKind = enum {
        number,
        ident,
        string,
        boolean,
        null_,
        destructure,
        sequence,
        or_,
        merge,
        repeat,
        return_,
        take_left,
        take_right,
        subtract,
        range,
        negation,
        conditional,
        array,
        object,
        template,
        call,
    };

    // The first weight is the empty-input default; destructure dominates so
    // coverage reaches the pattern compiler.
    const expr_weights = [_]Weight{
        .value(ExprKind, .number, 3),
        .value(ExprKind, .ident, 5),
        .value(ExprKind, .string, 3),
        .value(ExprKind, .boolean, 1),
        .value(ExprKind, .null_, 1),
        .value(ExprKind, .destructure, 8),
        .value(ExprKind, .sequence, 5),
        .value(ExprKind, .or_, 4),
        .value(ExprKind, .merge, 4),
        .value(ExprKind, .repeat, 4),
        .value(ExprKind, .return_, 4),
        .value(ExprKind, .take_left, 1),
        .value(ExprKind, .take_right, 2),
        .value(ExprKind, .subtract, 1),
        .value(ExprKind, .range, 2),
        .value(ExprKind, .negation, 1),
        .value(ExprKind, .conditional, 1),
        .value(ExprKind, .array, 2),
        .value(ExprKind, .object, 2),
        .value(ExprKind, .template, 2),
        .value(ExprKind, .call, 3),
    };

    fn expr(g: *Gen, depth: u8) Error!*RNode {
        if (depth >= max_depth or g.nodes_left == 0) return g.leaf();
        g.nodes_left -= 1;

        return switch (g.smith.valueWeighted(ExprKind, &expr_weights)) {
            .number => g.number(),
            .ident => g.parserRef(depth),
            .string => g.string(),
            .boolean => g.boolean(),
            .null_ => g.ast.create(.Null, placeholder),
            .destructure => g.ast.createInfix(.Destructure, try g.expr(depth + 1), try g.pattern(depth + 1), placeholder),
            .sequence => g.ast.createInfix(.Sequence, try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .or_ => g.ast.createInfix(.Or, try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .merge => g.ast.createInfix(.Merge, try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .repeat => g.ast.createInfix(.Repeat, try g.expr(depth + 1), try g.count(depth + 1), placeholder),
            .return_ => g.ast.createInfix(.Return, try g.expr(depth + 1), try g.value(depth + 1), placeholder),
            .take_left => g.ast.createInfix(.TakeLeft, try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .take_right => g.ast.createInfix(.TakeRight, try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .subtract => g.ast.createInfix(.NumberSubtract, try g.count(depth + 1), try g.count(depth + 1), placeholder),
            .range => g.range(),
            .negation => g.ast.create(.{ .Negation = try g.count(depth + 1) }, placeholder),
            .conditional => g.ast.createConditional(try g.expr(depth + 1), try g.expr(depth + 1), try g.expr(depth + 1), placeholder),
            .array => g.array(depth, .expr_ctx),
            .object => g.object(depth, .expr_ctx),
            .template => g.template(depth, .expr_ctx),
            .call => g.call(depth, .parser),
        };
    }

    const PatKind = enum {
        value_var,
        number,
        string,
        underscore,
        boolean,
        null_,
        array,
        object,
        template,
        merge,
        negated_number,
        call,
        range,
    };

    // Containers, templates, and merges dominate: those shapes feed
    // writeMatchSteps and the remaining unsupported-pattern paths.
    const pat_weights = [_]Weight{
        .value(PatKind, .value_var, 8),
        .value(PatKind, .number, 3),
        .value(PatKind, .string, 3),
        .value(PatKind, .underscore, 2),
        .value(PatKind, .boolean, 1),
        .value(PatKind, .null_, 1),
        .value(PatKind, .array, 5),
        .value(PatKind, .object, 5),
        .value(PatKind, .template, 5),
        .value(PatKind, .merge, 6),
        .value(PatKind, .negated_number, 1),
        .value(PatKind, .call, 2),
        .value(PatKind, .range, 1),
    };

    fn pattern(g: *Gen, depth: u8) Error!*RNode {
        if (depth >= max_depth or g.nodes_left == 0) return g.valueVar();
        g.nodes_left -= 1;

        return switch (g.smith.valueWeighted(PatKind, &pat_weights)) {
            .value_var => g.valueVar(),
            .number => g.number(),
            .string => g.string(),
            .underscore => g.identNode("_"),
            .boolean => g.boolean(),
            .null_ => g.ast.create(.Null, placeholder),
            .array => g.array(depth, .pat_ctx),
            .object => g.object(depth, .pat_ctx),
            .template => g.template(depth, .pat_ctx),
            .merge => g.ast.createInfix(.Merge, try g.pattern(depth + 1), try g.pattern(depth + 1), placeholder),
            .negated_number => g.ast.create(.{ .Negation = try g.number() }, placeholder),
            .call => g.call(depth, null),
            .range => g.range(),
        };
    }

    const ValKind = enum {
        value_var,
        number,
        string,
        boolean,
        null_,
        array,
        object,
        template,
        merge,
        subtract,
        repeat,
        or_,
        take_left,
        take_right,
        sequence,
        return_,
        conditional,
        destructure,
        call,
    };

    // Constructed values: the parsing infixes act as control flow here, and
    // a nested destructure is an ordinary value expression.
    const val_weights = [_]Weight{
        .value(ValKind, .value_var, 5),
        .value(ValKind, .number, 3),
        .value(ValKind, .string, 3),
        .value(ValKind, .boolean, 1),
        .value(ValKind, .null_, 1),
        .value(ValKind, .array, 3),
        .value(ValKind, .object, 3),
        .value(ValKind, .template, 3),
        .value(ValKind, .merge, 4),
        .value(ValKind, .subtract, 2),
        .value(ValKind, .repeat, 2),
        .value(ValKind, .or_, 2),
        .value(ValKind, .take_left, 1),
        .value(ValKind, .take_right, 1),
        .value(ValKind, .sequence, 1),
        .value(ValKind, .return_, 1),
        .value(ValKind, .conditional, 2),
        .value(ValKind, .destructure, 4),
        .value(ValKind, .call, 3),
    };

    fn value(g: *Gen, depth: u8) Error!*RNode {
        if (depth >= max_depth or g.nodes_left == 0) return g.valueLeaf();
        g.nodes_left -= 1;

        return switch (g.smith.valueWeighted(ValKind, &val_weights)) {
            .value_var => g.valueVar(),
            .number => g.number(),
            .string => g.string(),
            .boolean => g.boolean(),
            .null_ => g.ast.create(.Null, placeholder),
            .array => g.array(depth, .val_ctx),
            .object => g.object(depth, .val_ctx),
            .template => g.template(depth, .val_ctx),
            .merge => g.ast.createInfix(.Merge, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .subtract => g.ast.createInfix(.NumberSubtract, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .repeat => g.ast.createInfix(.Repeat, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .or_ => g.ast.createInfix(.Or, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .take_left => g.ast.createInfix(.TakeLeft, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .take_right => g.ast.createInfix(.TakeRight, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .sequence => g.ast.createInfix(.Sequence, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .return_ => g.ast.createInfix(.Return, try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .conditional => g.ast.createConditional(try g.value(depth + 1), try g.value(depth + 1), try g.value(depth + 1), placeholder),
            .destructure => g.ast.createInfix(.Destructure, try g.value(depth + 1), try g.pattern(depth + 1), placeholder),
            .call => g.call(depth, .value),
        };
    }

    const ValueLeafKind = enum { number, string, value_var, boolean, null_ };

    const value_leaf_weights = [_]Weight{
        .value(ValueLeafKind, .number, 3),
        .value(ValueLeafKind, .value_var, 4),
        .value(ValueLeafKind, .string, 3),
        .value(ValueLeafKind, .boolean, 1),
        .value(ValueLeafKind, .null_, 1),
    };

    fn valueLeaf(g: *Gen) Error!*RNode {
        return switch (g.smith.valueWeighted(ValueLeafKind, &value_leaf_weights)) {
            .number => g.number(),
            .string => g.string(),
            .value_var => g.valueVar(),
            .boolean => g.boolean(),
            .null_ => g.ast.create(.Null, placeholder),
        };
    }

    const Ctx = enum { expr_ctx, pat_ctx, val_ctx };

    fn child(g: *Gen, depth: u8, ctx: Ctx) Error!*RNode {
        return switch (ctx) {
            .expr_ctx => g.expr(depth + 1),
            .pat_ctx => g.pattern(depth + 1),
            .val_ctx => g.value(depth + 1),
        };
    }

    fn array(g: *Gen, depth: u8, ctx: Ctx) Error!*RNode {
        var elements: ArrayList(*RNode) = .empty;
        const n = g.smith.valueRangeAtMost(u8, 0, 3);
        for (0..n) |_| {
            try elements.append(g.alc(), try g.child(depth, ctx));
        }
        return g.ast.createArray(elements, placeholder);
    }

    fn object(g: *Gen, depth: u8, ctx: Ctx) Error!*RNode {
        var pairs: ArrayList(Ast.ObjectPair) = .empty;
        const n = g.smith.valueRangeAtMost(u8, 0, 3);
        for (0..n) |_| {
            try pairs.append(g.alc(), .{
                .key = try g.objectKey(),
                .value = try g.child(depth, ctx),
            });
        }
        return g.ast.createObject(pairs, placeholder);
    }

    const KeyKind = enum { string, value_var, number };

    // Value vars as keys exercise non-constant object keys (G4).
    const key_weights = [_]Weight{
        .value(KeyKind, .string, 5),
        .value(KeyKind, .value_var, 2),
        .value(KeyKind, .number, 1),
    };

    fn objectKey(g: *Gen) Error!*RNode {
        return switch (g.smith.valueWeighted(KeyKind, &key_weights)) {
            .string => g.string(),
            .value_var => g.valueVar(),
            .number => g.number(),
        };
    }

    fn template(g: *Gen, depth: u8, ctx: Ctx) Error!*RNode {
        var parts: ArrayList(*RNode) = .empty;
        const n = g.smith.valueRangeAtMost(u8, 1, 3);
        for (0..n) |_| {
            if (g.smith.boolWeighted(1, 1)) {
                try parts.append(g.alc(), try g.child(depth, ctx));
            } else {
                try parts.append(g.alc(), try g.ast.create(.{ .String = g.pick(&string_pool) }, placeholder));
            }
        }
        return g.ast.createStringTemplate(parts, placeholder);
    }

    const CountKind = enum { number, value_var, range, subtract };

    const count_weights = [_]Weight{
        .value(CountKind, .number, 4),
        .value(CountKind, .value_var, 3),
        .value(CountKind, .range, 2),
        .value(CountKind, .subtract, 1),
    };

    // Numeric contexts: repeat counts, subtraction operands, negation.
    fn count(g: *Gen, depth: u8) Error!*RNode {
        if (depth >= max_depth or g.nodes_left == 0) return g.number();
        g.nodes_left -= 1;

        return switch (g.smith.valueWeighted(CountKind, &count_weights)) {
            .number => g.number(),
            .value_var => g.valueVar(),
            .range => g.range(),
            .subtract => g.ast.createInfix(.NumberSubtract, try g.count(depth + 1), try g.count(depth + 1), placeholder),
        };
    }

    const RangeKind = enum { int_int, int_open, open_int, char_char, var_var };

    fn range(g: *Gen) Error!*RNode {
        const bounds: struct { lower: ?*RNode, upper: ?*RNode } = switch (g.smith.value(RangeKind)) {
            .int_int => .{ .lower = try g.number(), .upper = try g.number() },
            .int_open => .{ .lower = try g.number(), .upper = null },
            .open_int => .{ .lower = null, .upper = try g.number() },
            .char_char => .{
                .lower = try g.ast.create(.{ .String = g.pick(&char_pool) }, placeholder),
                .upper = try g.ast.create(.{ .String = g.pick(&char_pool) }, placeholder),
            },
            .var_var => .{ .lower = try g.valueVar(), .upper = try g.valueVar() },
        };
        return g.ast.create(.{ .Range = .{ .lower = bounds.lower, .upper = bounds.upper } }, placeholder);
    }

    const LeafKind = enum { number, string, value_var, parser_ref, boolean, null_, underscore };

    const leaf_weights = [_]Weight{
        .value(LeafKind, .number, 4),
        .value(LeafKind, .string, 3),
        .value(LeafKind, .value_var, 3),
        .value(LeafKind, .parser_ref, 3),
        .value(LeafKind, .boolean, 1),
        .value(LeafKind, .null_, 1),
        .value(LeafKind, .underscore, 1),
    };

    fn leaf(g: *Gen) Error!*RNode {
        return switch (g.smith.valueWeighted(LeafKind, &leaf_weights)) {
            .number => g.number(),
            .string => g.string(),
            .value_var => g.valueVar(),
            .parser_ref => g.bareRef(),
            .boolean => g.boolean(),
            .null_ => g.ast.create(.Null, placeholder),
            .underscore => g.identNode("_"),
        };
    }

    // A bare reference to an arity-0 parser declaration, or a number when
    // none exists yet.
    fn bareRef(g: *Gen) Error!*RNode {
        var candidates: [decl_names.len][]const u8 = undefined;
        var n: usize = 0;
        for (g.decls.items) |decl| {
            if (decl.kind == .parser and decl.arity == 0) {
                candidates[n] = decl.name;
                n += 1;
            }
        }
        if (n == 0) return g.number();
        return g.identNode(candidates[g.smith.index(n)]);
    }

    // A parser-position identifier: a declared arity-0 parser, a lowercase
    // parameter, or a value var.
    fn parserRef(g: *Gen, depth: u8) Error!*RNode {
        _ = depth;
        return switch (g.smith.valueRangeAtMost(u8, 0, 2)) {
            0 => g.bareRef(),
            1 => g.identNode(param_names[g.smith.index(param_names.len)][0]),
            else => g.valueVar(),
        };
    }

    // A call to a declared function of the wanted kind (either kind in
    // pattern position), with each argument generated per the parameter's
    // kind so calls pass the call check. Falls back when nothing callable
    // of that kind is declared.
    fn call(g: *Gen, depth: u8, want: ?DeclKind) Error!*RNode {
        var candidates: [decl_names.len + value_decl_names.len]Decl = undefined;
        var n: usize = 0;
        for (g.decls.items) |decl| {
            if (decl.arity == 0) continue;
            if (want) |kind| if (decl.kind != kind) continue;
            candidates[n] = decl;
            n += 1;
        }
        if (n == 0) {
            return if (want) |kind| switch (kind) {
                .parser => g.bareRef(),
                .value => g.valueVar(),
            } else g.valueVar();
        }
        const decl = candidates[g.smith.index(n)];
        var args: ArrayList(*RNode) = .empty;
        for (decl.params[0..decl.arity]) |kind| {
            try args.append(g.alc(), switch (kind) {
                .parser => try g.expr(depth + 1),
                .value => try g.value(depth + 1),
            });
        }
        return g.ast.createFunction(try g.identNode(decl.name), args, placeholder);
    }

    fn number(g: *Gen) Error!*RNode {
        return g.ast.create(.{ .NumberString = .{
            .number = g.pick(&number_pool),
            .negated = g.smith.boolWeighted(4, 1),
        } }, placeholder);
    }

    fn string(g: *Gen) Error!*RNode {
        return g.ast.create(.{ .String = g.pick(&string_pool) }, placeholder);
    }

    fn boolean(g: *Gen) Error!*RNode {
        return g.ast.create(if (g.smith.value(bool)) .True else .False, placeholder);
    }

    fn valueVar(g: *Gen) Error!*RNode {
        return g.identNode(g.pick(&value_names));
    }

    fn identNode(g: *Gen, name: []const u8) Error!*RNode {
        var ident = Ast.IdentifierNode{
            .name = name,
            .builtin = false,
            .underscored = false,
            .kind = .Parser,
        };
        if (name[0] == '_') {
            ident.kind = .Underscore;
        } else if (std.ascii.isUpper(name[0])) {
            ident.kind = .Value;
        }
        return g.ast.create(.{ .Identifier = ident }, placeholder);
    }

    fn pick(g: *Gen, pool: []const []const u8) []const u8 {
        return pool[g.smith.index(pool.len)];
    }
};

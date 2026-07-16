const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoHashMapUnmanaged;
const StringTable = @import("string_table.zig").FrontendStringTable;
const PathTable = @import("path_table.zig").PathTable;
const Ast = @import("can_ast.zig");
const Module = @import("../runtime.zig").Module;
const DependencyGraph = @import("dependency_graph.zig");
const Region = @import("../region.zig").Region;

arena: *ArenaAllocator,
paths: *PathTable,
strings: *StringTable,
// Per-module ordered unqualified dumps: every export of a dumped module is
// visible bare. Implicit stdlib/builtins edges are just early entries, so a
// later dump shadows an earlier one.
dumps: HashMap(Module.Id, ArrayList(Module.Id)) = .{},
// Per-module qualified imports: names starting with the alias resolve in the
// target module's public exports.
aliases: HashMap(Module.Id, ArrayList(Alias)) = .{},
graph: DependencyGraph = .{},
diagnostics: ArrayList(Diagnostic) = .{},
// Scratch space reused by every resolveScopedName call. The function runs to
// completion before the next identifier is resolved and never re-enters
// itself, so a single buffer is safe and avoids a per-identifier allocation.
scoped_name_chain: ArrayList(*DependencyGraph.Node) = .{},
// Scratch space reused by every findDeclaration call, same reasoning. Keyed
// on (module, name), not module alone: alias rewriting can legitimately
// revisit a module looking for a different name.
visited_exports: ArrayList(DependencyGraph.NodeKey) = .{},

pub const Resolver = @This();

// Mutually-recursive selector aliases can grow a name on every rewrite and
// never converge; such a chain can't ground out in a declaration, so cutting
// it off resolves the name to nothing.
const max_alias_rewrites = 64;

// The canonicalizer's name for a module's main parser (its bare parser
// expression). User-written @-names are rejected, so the name is unambiguous.
const main_parser_name = "@main";

// Whether a name binds a parser (lowercase) or a value (uppercase).
pub const Kind = enum { parser, value };

pub const Alias = struct {
    alias: PathTable.Id,
    // The alias's case selects which kind of exports the namespace holds, so
    // first-character kind classification stays correct at every use site.
    kind: Kind,
    target_module: Module.Id,
    // A member or namespace path inside the target module that the alias is
    // mounted on; null mounts the module root.
    selector_prefix: ?PathTable.Id,
    region: Region,
};

// A namespaced (dotted) value identifier that resolves to no declaration:
// it would otherwise become a local, and locals can't be namespaced.
pub const Diagnostic = struct {
    module_id: Module.Id,
    region: Region,
    name: PathTable.Id,
};

pub fn init(arena: *ArenaAllocator, paths: *PathTable, strings: *StringTable) Resolver {
    return Resolver{
        .arena = arena,
        .paths = paths,
        .strings = strings,
    };
}

pub fn addModule(self: *Resolver, module: Module, ast: Ast) !void {
    try self.graph.addModule(self.arena.allocator(), module, ast);
}

pub fn addDump(self: *Resolver, module_id: Module.Id, target_module: Module.Id) !void {
    const gop = try self.dumps.getOrPut(self.arena.allocator(), module_id);
    if (!gop.found_existing) {
        gop.value_ptr.* = .{};
    }
    try gop.value_ptr.append(self.arena.allocator(), target_module);
}

pub fn addAlias(
    self: *Resolver,
    module_id: Module.Id,
    alias: PathTable.Id,
    target_module: Module.Id,
    selector_prefix: ?PathTable.Id,
    region: Region,
) !void {
    const gop = try self.aliases.getOrPut(self.arena.allocator(), module_id);
    if (!gop.found_existing) {
        gop.value_ptr.* = .{};
    }
    try gop.value_ptr.append(self.arena.allocator(), .{
        .alias = alias,
        .kind = self.nameKind(alias),
        .target_module = target_module,
        .selector_prefix = selector_prefix,
        .region = region,
    });
}

fn nameKind(self: *const Resolver, path: PathTable.Id) Kind {
    const first_segment = self.strings.get(self.paths.segments(path)[0]);
    for (first_segment) |c| {
        if (c == '_' or c == '@') continue;
        return if (std.ascii.isUpper(c)) .value else .parser;
    }
    return .parser;
}

fn pathIsPrivate(self: *const Resolver, path: PathTable.Id) bool {
    const first_segment = self.strings.get(self.paths.segments(path)[0]);
    return first_segment.len > 0 and first_segment[0] == '_';
}

pub fn resolve(self: *Resolver) !void {
    // Declarations are resolved first so that their locals are known, then
    // anonymous functions from the outside in, so that each can find the
    // locals and closure captures of its parent chain.
    var iter = self.graph.nodes.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;

        if (node.* == .declaration) {
            try self.resolveDeclaration(key, node);
        }
    }

    const AnonEntry = struct {
        key: DependencyGraph.NodeKey,
        node: *DependencyGraph.Node,
        depth: usize,

        fn lessThan(_: void, a: @This(), b: @This()) bool {
            return a.depth < b.depth;
        }
    };

    var anons = ArrayList(AnonEntry){};
    iter = self.graph.nodes.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;

        if (node.* == .anonymous_function) {
            try anons.append(self.arena.allocator(), .{
                .key = key,
                .node = node,
                .depth = self.parentDepth(key, node),
            });
        }
    }

    std.mem.sort(AnonEntry, anons.items, {}, AnonEntry.lessThan);

    for (anons.items) |entry| {
        try self.resolveAnonymousFunction(entry.key, entry.node);
    }

    // Ordering happens after all anonymous functions are resolved because
    // resolving an inner function can add captures to its parents.
    for (anons.items) |entry| {
        try self.orderCapturedLocals(entry.node);
    }
}

fn parentDepth(self: *Resolver, key: DependencyGraph.NodeKey, node: *DependencyGraph.Node) usize {
    var depth: usize = 0;
    var current = node.anonymous_function.parent();

    while (current) |parent_name| {
        depth += 1;
        const parent_node = self.graph.nodes.get(.{
            .module_id = key.module_id,
            .name = parent_name,
        }) orelse break;

        current = switch (parent_node.*) {
            .anonymous_function => |*n| n.parent(),
            else => null,
        };
    }

    return depth;
}

fn resolveDeclaration(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
) !void {
    const allocator = self.arena.allocator();
    const decl = node.declaration.ast;
    switch (decl) {
        .parser => |p| {
            for (p.node.params.items) |param| {
                const param_name = switch (param) {
                    .parser => |parser_ident| parser_ident.node.name,
                    .value => |value_ident| value_ident.node.name,
                };
                const decl_node = &node.declaration;
                // The canonicalizer rejects namespaced params.
                try decl_node.locals.append(allocator, self.paths.single(param_name).?);
            }

            try self.walkParser(key, node, p.node.body);
        },
        .value => |v| {
            for (v.node.params.items) |param| {
                const decl_node = &node.declaration;
                // The canonicalizer rejects namespaced params.
                try decl_node.locals.append(allocator, self.paths.single(param.node.name).?);
            }

            try self.walkValue(key, node, v.node.body);
        },
    }
}

fn resolveAnonymousFunction(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
) !void {
    try self.walkParser(key, node, node.anonymous_function.ast.node.body);
}

// At runtime `SetClosureCaptures` copies closure capture slot N into local
// slot N, so captured names must occupy the anonymous function's first local
// slots, in capture order.
fn orderCapturedLocals(self: *Resolver, node: *DependencyGraph.Node) !void {
    const allocator = self.arena.allocator();
    const anon = &node.anonymous_function;

    if (anon.closure_captures.items.len == 0) {
        return;
    }

    var ordered = ArrayList(StringTable.Id){};

    for (anon.closure_captures.items) |capture| {
        try ordered.append(allocator, capture.local);
    }

    for (anon.locals.items) |local| {
        var captured = false;
        for (anon.closure_captures.items) |capture| {
            if (capture.local == local) {
                captured = true;
                break;
            }
        }
        if (!captured) {
            try ordered.append(allocator, local);
        }
    }

    anon.locals = ordered;
}

fn walkParser(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    rnode: *Ast.Parser.RNode,
) error{OutOfMemory}!void {
    switch (rnode.node) {
        .identifier => |ident| {
            try self.resolveParserIdentifier(key, node, ident.name);
        },
        .@"or" => |infix| {
            try self.walkParser(key, node, infix.left);
            try self.walkParser(key, node, infix.right);
        },
        .@"return" => |ret| {
            try self.walkParser(key, node, ret.left);
            try self.walkValue(key, node, ret.right);
        },
        .anonymous_function => |anon| {
            // Add dependency on the anonymous function itself
            try self.addDependency(node, .{
                .ref = anon.name,
                .target = .{
                    .module_id = key.module_id,
                    .name = anon.name,
                },
            });
        },
        .conditional => |cond| {
            try self.walkParser(key, node, cond.condition);
            try self.walkParser(key, node, cond.then_branch);
            try self.walkParser(key, node, cond.else_branch);
        },
        .destructure => |dest| {
            try self.walkParser(key, node, dest.left);
            try self.walkPattern(key, node, dest.right);
        },
        .function_call => |fc| {
            try self.walkParser(key, node, fc.function);
            for (fc.args.items) |arg| {
                switch (arg) {
                    .parser => |p| try self.walkParser(key, node, p),
                    .value => |v| try self.walkValue(key, node, v),
                }
            }
        },
        .merge => |infix| {
            try self.walkParser(key, node, infix.left);
            try self.walkParser(key, node, infix.right);
        },
        .negation => |inner| {
            try self.walkParser(key, node, inner);
        },
        .range => |range| {
            if (range.lower) |lower| try self.walkParser(key, node, lower);
            if (range.upper) |upper| try self.walkParser(key, node, upper);
        },
        .repeat => |rep| {
            try self.walkParser(key, node, rep.left);
            try self.walkPattern(key, node, rep.right);
        },
        .string_template => |tmpl| {
            for (tmpl.items) |item| {
                try self.walkParser(key, node, item);
            }
        },
        .take_left => |infix| {
            try self.walkParser(key, node, infix.left);
            try self.walkParser(key, node, infix.right);
        },
        .take_right => |infix| {
            try self.walkParser(key, node, infix.left);
            try self.walkParser(key, node, infix.right);
        },
        .number_string, .string => {},
    }
}

fn walkValue(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    rnode: *Ast.Value.RNode,
) error{OutOfMemory}!void {
    switch (rnode.node) {
        .identifier => |ident| {
            try self.resolveValueIdentifier(key, node, ident.name, rnode.region);
        },
        .@"or" => |infix| {
            try self.walkValue(key, node, infix.left);
            try self.walkValue(key, node, infix.right);
        },
        .@"return" => |ret| {
            try self.walkValue(key, node, ret.left);
            try self.walkValue(key, node, ret.right);
        },
        .array => |arr| {
            for (arr.items) |item| {
                try self.walkValue(key, node, item);
            }
        },
        .conditional => |cond| {
            try self.walkValue(key, node, cond.condition);
            try self.walkValue(key, node, cond.then_branch);
            try self.walkValue(key, node, cond.else_branch);
        },
        .destructure => |dest| {
            try self.walkValue(key, node, dest.left);
            try self.walkPattern(key, node, dest.right);
        },
        .function_call => |fc| {
            try self.walkValue(key, node, fc.function);
            for (fc.args.items) |arg| {
                try self.walkValue(key, node, arg);
            }
        },
        .merge => |infix| {
            try self.walkValue(key, node, infix.left);
            try self.walkValue(key, node, infix.right);
        },
        .negation => |inner| {
            try self.walkValue(key, node, inner);
        },
        .object => |obj| {
            for (obj.items) |pair| {
                try self.walkValue(key, node, pair.key);
                try self.walkValue(key, node, pair.value);
            }
        },
        .repeat => |rep| {
            try self.walkValue(key, node, rep.left);
            try self.walkValue(key, node, rep.right);
        },
        .string_template => |tmpl| {
            for (tmpl.items) |item| {
                try self.walkValue(key, node, item);
            }
        },
        .take_left => |infix| {
            try self.walkValue(key, node, infix.left);
            try self.walkValue(key, node, infix.right);
        },
        .take_right => |infix| {
            try self.walkValue(key, node, infix.left);
            try self.walkValue(key, node, infix.right);
        },
        .false, .null, .number_float, .number_string, .string, .true => {},
    }
}

fn walkPattern(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    rnode: *Ast.Pattern.RNode,
) error{OutOfMemory}!void {
    switch (rnode.node) {
        .identifier => |ident| {
            try self.resolveValueIdentifier(key, node, ident.name, rnode.region);
        },
        .array => |arr| {
            for (arr.items) |item| {
                try self.walkPattern(key, node, item);
            }
        },
        .function_call => |fc| {
            try self.walkValue(key, node, fc.function);
            for (fc.args.items) |arg| {
                try self.walkValue(key, node, arg);
            }
        },
        .merge => |infix| {
            try self.walkPattern(key, node, infix.left);
            try self.walkPattern(key, node, infix.right);
        },
        .negation => |inner| {
            try self.walkPattern(key, node, inner);
        },
        .object => |obj| {
            for (obj.items) |pair| {
                try self.walkPattern(key, node, pair.key);
                try self.walkPattern(key, node, pair.value);
            }
        },
        .range => |range| {
            if (range.lower) |lower| try self.walkPattern(key, node, lower);
            if (range.upper) |upper| try self.walkPattern(key, node, upper);
        },
        .repeat => |rep| {
            try self.walkPattern(key, node, rep.left);
            try self.walkPattern(key, node, rep.right);
        },
        .string_template => |tmpl| {
            for (tmpl.items) |item| {
                try self.walkPattern(key, node, item);
            }
        },
        .false, .null, .number_float, .number_string, .string, .true => {},
    }
}

fn addCapture(self: *Resolver, anon: *DependencyGraph.AnonymousFunctionNode, capture: DependencyGraph.ClosureCapture) !void {
    for (anon.closure_captures.items) |existing| {
        if (existing.parent_name == capture.parent_name and existing.local == capture.local) {
            return;
        }
    }
    try anon.closure_captures.append(self.arena.allocator(), capture);
}

// Resolve a name against the node's locals and the locals of its parent
// chain. A name found in the parent chain is recorded as a closure capture on
// every anonymous function between the local's owner and this node, so that
// each closure captures the value from its immediate parent's frame.
fn resolveScopedName(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: PathTable.Id,
) error{OutOfMemory}!bool {
    // Dotted names are never locals, only declarations.
    const segment = self.paths.single(name) orelse return false;

    for (node.locals()) |local| {
        if (local == segment) return true;
    }

    if (node.* != .anonymous_function) {
        return false;
    }

    const chain = &self.scoped_name_chain;
    chain.clearRetainingCapacity();
    try chain.append(self.arena.allocator(), node);

    var current_parent = node.anonymous_function.parent();
    while (current_parent) |parent_name| {
        const parent_node = self.graph.nodes.get(.{
            .module_id = key.module_id,
            .name = parent_name,
        }) orelse return false;

        var found = false;
        for (parent_node.locals()) |local| {
            if (local == segment) {
                found = true;
                break;
            }
        }

        if (!found and parent_node.* == .anonymous_function) {
            for (parent_node.anonymous_function.closure_captures.items) |capture| {
                if (capture.local == segment) {
                    found = true;
                    break;
                }
            }
        }

        if (found) {
            for (chain.items) |chain_node| {
                const anon = &chain_node.anonymous_function;
                try self.addCapture(anon, .{
                    .parent_name = anon.parent().?,
                    .local = segment,
                });
            }
            return true;
        }

        switch (parent_node.*) {
            .anonymous_function => |*parent_anon| {
                try chain.append(self.arena.allocator(), parent_node);
                current_parent = parent_anon.parent();
            },
            else => return false,
        }
    }

    return false;
}

fn addDependency(self: *Resolver, node: *DependencyGraph.Node, edge: DependencyGraph.Edge) !void {
    const deps = node.dependenciesList();
    for (deps.items) |existing| {
        if (existing.ref == edge.ref and
            existing.target.module_id == edge.target.module_id and
            existing.target.name == edge.target.name)
        {
            return;
        }
    }
    try deps.append(self.arena.allocator(), edge);
}

// Find the declaration or precompiled function an identifier refers to, first
// in its own module, then through its alias table, then in the modules it
// dumps. Anonymous function names (`@main`, `@fn0`, ...) are internal and
// can't be referenced by identifier. A module sees its own private
// (underscored) declarations and aliases but only the public exports of its
// dumps.
//
// When two dumps export the same name, the later import shadows the earlier
// one, so dumps are searched in reverse insertion order. The search recurses
// into transitive dumps (every import is re-exported), so callers only need
// to record each module's direct dumps rather than a flattened closure. Dump
// graphs may be cyclic; the visited list keeps the recursion finite.
fn findDeclaration(self: *Resolver, module_id: Module.Id, name: PathTable.Id) error{OutOfMemory}!?DependencyGraph.NodeKey {
    const own_key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };

    if (self.graph.nodes.get(own_key)) |found| {
        if (found.* != .anonymous_function) return own_key;
    }

    self.visited_exports.clearRetainingCapacity();
    try self.visited_exports.append(self.arena.allocator(), own_key);

    switch (try self.resolveThroughAliases(module_id, name, .include_private, 0)) {
        .resolved => |key| return key,
        .unresolved => return null,
        .no_match => {},
    }

    return self.findExportedInDumps(module_id, name, 0);
}

fn findExportedInDumps(self: *Resolver, module_id: Module.Id, name: PathTable.Id, rewrite_depth: usize) error{OutOfMemory}!?DependencyGraph.NodeKey {
    const dumps = self.dumps.get(module_id) orelse return null;

    var i = dumps.items.len;
    while (i > 0) {
        i -= 1;
        if (try self.findExported(dumps.items[i], name, rewrite_depth)) |dep_key| {
            return dep_key;
        }
    }

    return null;
}

fn findExported(self: *Resolver, module_id: Module.Id, name: PathTable.Id, rewrite_depth: usize) error{OutOfMemory}!?DependencyGraph.NodeKey {
    const key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };

    for (self.visited_exports.items) |visited| {
        if (visited.module_id == key.module_id and visited.name == key.name) return null;
    }
    try self.visited_exports.append(self.arena.allocator(), key);

    if (self.graph.nodes.get(key)) |found| {
        if (found.* != .anonymous_function and !found.isPrivate()) return key;
    }

    switch (try self.resolveThroughAliases(module_id, name, .public_only, rewrite_depth)) {
        .resolved => |resolved| return resolved,
        .unresolved => return null,
        .no_match => {},
    }

    return self.findExportedInDumps(module_id, name, rewrite_depth);
}

const AliasLookup = union(enum) {
    // No alias prefixes the name; the search continues into dumps.
    no_match,
    // An alias claims the name's prefix but the member doesn't resolve. The
    // alias still shadows the prefix, so the search stops rather than fall
    // through to dumps.
    unresolved,
    resolved: DependencyGraph.NodeKey,
};

// Resolve a name whose prefix matches one of the module's aliases: splice
// the alias's selector onto the remaining segments and look the rewritten
// name up among the target module's public exports. The resolved node must
// match the alias's kind — a lowercase alias exposes only parsers, an
// uppercase alias only values.
fn resolveThroughAliases(
    self: *Resolver,
    module_id: Module.Id,
    name: PathTable.Id,
    privacy: enum { include_private, public_only },
    rewrite_depth: usize,
) error{OutOfMemory}!AliasLookup {
    const alias = self.matchAlias(module_id, name, privacy == .include_private) orelse return .no_match;
    if (rewrite_depth >= max_alias_rewrites) return .unresolved;

    const remainder = self.paths.segments(name)[self.paths.segments(alias.alias).len..];

    if (remainder.len == 0 and alias.selector_prefix == null) {
        // A bare alias names the target module's root: its main parser. The
        // main parser is a parser, so only a lowercase alias binds it; an
        // uppercase alias yields a namespace of values with no root.
        if (alias.kind != .parser) return .unresolved;

        const root_key = DependencyGraph.NodeKey{
            .module_id = alias.target_module,
            .name = try self.paths.insert(self.strings, main_parser_name),
        };
        if (self.graph.nodes.get(root_key) != null) return .{ .resolved = root_key };
        return .unresolved;
    }

    const allocator = self.arena.allocator();
    var segments = ArrayList(StringTable.Id){};
    defer segments.deinit(allocator);
    if (alias.selector_prefix) |prefix| {
        try segments.appendSlice(allocator, self.paths.segments(prefix));
    }
    try segments.appendSlice(allocator, remainder);
    const rewritten = try self.paths.insertSegments(self.strings, segments.items);

    if (try self.findExported(alias.target_module, rewritten, rewrite_depth + 1)) |key| {
        const node = self.graph.nodes.get(key).?;
        if (self.nodeKind(key, node) != alias.kind) return .unresolved;
        return .{ .resolved = key };
    }

    return .unresolved;
}

// The longest alias whose segments prefix the name. A dotted alias mounts a
// module under a nested namespace, so the most specific mount wins.
fn matchAlias(self: *const Resolver, module_id: Module.Id, name: PathTable.Id, include_private: bool) ?*const Alias {
    const list = self.aliases.get(module_id) orelse return null;
    const name_segments = self.paths.segments(name);

    var best: ?*const Alias = null;
    var best_len: usize = 0;
    for (list.items) |*alias| {
        if (!include_private and self.pathIsPrivate(alias.alias)) continue;
        const alias_segments = self.paths.segments(alias.alias);
        if (alias_segments.len > name_segments.len) continue;
        if (alias_segments.len < best_len) continue;
        if (!std.mem.eql(StringTable.Id, alias_segments, name_segments[0..alias_segments.len])) continue;
        best = alias;
        best_len = alias_segments.len;
    }

    return best;
}

fn nodeKind(self: *const Resolver, key: DependencyGraph.NodeKey, node: *const DependencyGraph.Node) Kind {
    return switch (node.*) {
        .declaration => |*decl| switch (decl.ast) {
            .parser => .parser,
            .value => .value,
        },
        // Precompiled builtins carry no declaration; their names follow the
        // same case convention (`@fail` is a parser, `@Fail` a value).
        .precompiled => self.nameKind(key.name),
        .anonymous_function => .parser,
    };
}

fn resolveParserIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: PathTable.Id,
) error{OutOfMemory}!void {
    if (try self.resolveScopedName(key, node, name)) return;

    if (try self.findDeclaration(key.module_id, name)) |dep_key| {
        try self.addDependency(node, .{ .ref = name, .target = dep_key });
    }
}

fn resolveValueIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: PathTable.Id,
    region: Region,
) error{OutOfMemory}!void {
    if (try self.resolveScopedName(key, node, name)) return;

    if (try self.findDeclaration(key.module_id, name)) |dep_key| {
        try self.addDependency(node, .{ .ref = name, .target = dep_key });
        return;
    }

    // An unresolved value identifier becomes a local, and locals can't be
    // namespaced.
    const segment = self.paths.single(name) orelse {
        try self.diagnostics.append(self.arena.allocator(), .{
            .module_id = key.module_id,
            .region = region,
            .name = name,
        });
        return;
    };

    const unbound_locals = node.localsList();
    for (unbound_locals.items) |local| {
        if (local == segment) return;
    }
    try unbound_locals.append(self.arena.allocator(), segment);
}

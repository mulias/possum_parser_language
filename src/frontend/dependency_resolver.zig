const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoHashMapUnmanaged;
const StringTable = @import("string_table.zig").FrontendStringTable;
const Ast = @import("can_ast.zig");
const Module = @import("../runtime.zig").Module;
const DependencyGraph = @import("dependency_graph.zig");

arena: *ArenaAllocator,
module_dependencies: HashMap(Module.Id, ArrayList(Module.Id)) = .{},
graph: DependencyGraph = .{},
// Scratch space reused by every resolveScopedName call. The function runs to
// completion before the next identifier is resolved and never re-enters
// itself, so a single buffer is safe and avoids a per-identifier allocation.
scoped_name_chain: ArrayList(*DependencyGraph.Node) = .{},

pub const Resolver = @This();

pub fn init(arena: *ArenaAllocator) Resolver {
    return Resolver{
        .arena = arena,
    };
}

pub fn addModule(self: *Resolver, module: Module, ast: Ast) !void {
    try self.graph.addModule(self.arena.allocator(), module, ast);
}

pub fn addModuleDependency(self: *Resolver, module_id: Module.Id, dependency_id: Module.Id) !void {
    const gop = try self.module_dependencies.getOrPut(self.arena.allocator(), module_id);
    if (!gop.found_existing) {
        gop.value_ptr.* = .{};
    }
    try gop.value_ptr.append(self.arena.allocator(), dependency_id);
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
                try decl_node.locals.append(allocator, param_name);
            }

            try self.walkParser(key, node, p.node.body);
        },
        .value => |v| {
            for (v.node.params.items) |param| {
                const decl_node = &node.declaration;
                try decl_node.locals.append(allocator, param.node.name);
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
                .module_id = key.module_id,
                .name = anon.name,
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
            try self.resolveValueIdentifier(key, node, ident.name);
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
            try self.resolveValueIdentifier(key, node, ident.name);
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
    name: StringTable.Id,
) error{OutOfMemory}!bool {
    for (node.locals()) |local| {
        if (local == name) return true;
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
            if (local == name) {
                found = true;
                break;
            }
        }

        if (!found and parent_node.* == .anonymous_function) {
            for (parent_node.anonymous_function.closure_captures.items) |capture| {
                if (capture.local == name) {
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
                    .local = name,
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

fn addDependency(self: *Resolver, node: *DependencyGraph.Node, dep: DependencyGraph.NodeKey) !void {
    const deps = node.dependenciesList();
    for (deps.items) |existing| {
        if (existing.module_id == dep.module_id and existing.name == dep.name) {
            return;
        }
    }
    try deps.append(self.arena.allocator(), dep);
}

// Find the declaration or precompiled function an identifier refers to, first
// in its own module and then in the modules it depends on. Anonymous function
// names (`@main`, `@fn0`, ...) are internal and can't be referenced by
// identifier.
//
// When two dependencies declare the same name, the later import shadows the
// earlier one, so dependencies are searched in reverse insertion order. The
// search recurses into transitive dependencies, so callers only need to
// record each module's direct dependencies rather than a flattened closure.
fn findDeclaration(self: *Resolver, module_id: Module.Id, name: StringTable.Id) ?DependencyGraph.NodeKey {
    const own_key = DependencyGraph.NodeKey{
        .module_id = module_id,
        .name = name,
    };

    if (self.graph.nodes.get(own_key)) |found| {
        if (found.* != .anonymous_function) return own_key;
    }

    if (self.module_dependencies.get(module_id)) |dependencies| {
        var i = dependencies.items.len;
        while (i > 0) {
            i -= 1;
            if (self.findDeclaration(dependencies.items[i], name)) |dep_key| {
                return dep_key;
            }
        }
    }

    return null;
}

fn resolveParserIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: StringTable.Id,
) error{OutOfMemory}!void {
    if (try self.resolveScopedName(key, node, name)) return;

    if (self.findDeclaration(key.module_id, name)) |dep_key| {
        try self.addDependency(node, dep_key);
    }
}

fn resolveValueIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: StringTable.Id,
) error{OutOfMemory}!void {
    if (try self.resolveScopedName(key, node, name)) return;

    if (self.findDeclaration(key.module_id, name)) |dep_key| {
        try self.addDependency(node, dep_key);
        return;
    }

    const unbound_locals = node.localsList();
    for (unbound_locals.items) |local| {
        if (local == name) return;
    }
    try unbound_locals.append(self.arena.allocator(), name);
}

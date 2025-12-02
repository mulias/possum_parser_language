const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoHashMapUnmanaged;
const StringTable = @import("../string_table.zig").StringTable;
const Ast = @import("can_ast.zig");
const Module = @import("../module.zig").Module;
const DependencyGraph = @import("dependency_graph.zig");

arena: *ArenaAllocator,
module_dependencies: HashMap(Module.Id, ArrayList(Module.Id)) = .{},
graph: DependencyGraph = .{},

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
    if (self.module_dependencies.getPtr(module_id)) |module_deps| {
        try module_deps.append(self.arena.allocator(), dependency_id);
    } else {
        var new_deps = ArrayList(Module.Id){};
        try new_deps.append(self.arena.allocator(), dependency_id);
        try self.module_dependencies.put(self.arena.allocator(), module_id, new_deps);
    }
}

pub fn resolve(self: *Resolver) !void {
    var iter = self.graph.nodes.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const node = entry.value_ptr.*;

        switch (node.*) {
            .precompiled => {},
            .declaration => try self.resolveDeclaration(key, node),
            .anonymous_function => try self.resolveAnonymousFunction(key, node),
        }
    }
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
            const anon_key = DependencyGraph.NodeKey{
                .module_id = key.module_id,
                .name = anon.name,
            };
            const deps = switch (node.*) {
                .precompiled => unreachable,
                .declaration => |*n| &n.dependencies,
                .anonymous_function => |*n| &n.dependencies,
            };

            // Only add if not already present
            var already_present = false;
            for (deps.items) |dep| {
                if (dep.module_id == anon_key.module_id and dep.name == anon_key.name) {
                    already_present = true;
                    break;
                }
            }
            if (!already_present) {
                try deps.append(self.arena.allocator(), anon_key);
            }
        },
        .backtrack => |infix| {
            try self.walkParser(key, node, infix.left);
            try self.walkParser(key, node, infix.right);
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

fn resolveParserIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: StringTable.Id,
) error{OutOfMemory}!void {
    const allocator = self.arena.allocator();
    const locals = switch (node.*) {
        .precompiled => &[_]StringTable.Id{},
        .declaration => |*n| n.locals.items,
        .anonymous_function => |*n| n.locals.items,
    };

    for (locals) |local| {
        if (local == name) return;
    }

    if (node.* == .anonymous_function) {
        var current_key = key;
        var current_parent = node.anonymous_function.parent;

        while (current_parent) |parent_name| {
            const parent_key = DependencyGraph.NodeKey{
                .module_id = current_key.module_id,
                .name = parent_name,
            };

            if (self.graph.nodes.get(parent_key)) |parent_node| {
                const parent_locals = switch (parent_node.*) {
                    .precompiled => &[_]StringTable.Id{},
                    .declaration => |*n| n.locals.items,
                    .anonymous_function => |*n| n.locals.items,
                };

                for (parent_locals) |local| {
                    if (local == name) {
                        const anon_node = &node.anonymous_function;

                        // Check if already captured
                        var already_captured = false;
                        for (anon_node.closure_captures.items) |capture| {
                            if (capture.parent_name == parent_name and capture.local == name) {
                                already_captured = true;
                                break;
                            }
                        }

                        if (!already_captured) {
                            try anon_node.closure_captures.append(allocator, .{
                                .parent_name = parent_name,
                                .local = name,
                            });
                        }
                        return;
                    }
                }

                // Check if parent captures this variable
                if (parent_node.* == .anonymous_function) {
                    const parent_anon = parent_node.anonymous_function;
                    for (parent_anon.closure_captures.items) |capture| {
                        if (capture.local == name) {
                            const anon_node = &node.anonymous_function;

                            // Check if already captured
                            var already_captured = false;
                            for (anon_node.closure_captures.items) |existing_capture| {
                                if (existing_capture.parent_name == capture.parent_name and existing_capture.local == name) {
                                    already_captured = true;
                                    break;
                                }
                            }

                            if (!already_captured) {
                                try anon_node.closure_captures.append(allocator, capture);
                            }
                            return;
                        }
                    }
                }

                current_key = parent_key;
                current_parent = switch (parent_node.*) {
                    .anonymous_function => |*n| n.parent,
                    else => null,
                };
            } else {
                break;
            }
        }
    }

    var search_key = DependencyGraph.NodeKey{
        .module_id = key.module_id,
        .name = name,
    };

    if (self.graph.nodes.get(search_key)) |_| {
        const deps = switch (node.*) {
            .precompiled => unreachable,
            .declaration => |*n| &n.dependencies,
            .anonymous_function => |*n| &n.dependencies,
        };

        // Check if already present
        var already_present = false;
        for (deps.items) |dep| {
            if (dep.module_id == search_key.module_id and dep.name == search_key.name) {
                already_present = true;
                break;
            }
        }

        if (!already_present) {
            try deps.append(allocator, search_key);
        }
        return;
    }

    if (self.module_dependencies.get(key.module_id)) |dependencies| {
        for (dependencies.items) |module_id| {
            search_key.module_id = module_id;
            if (self.graph.nodes.get(search_key)) |_| {
                const deps = switch (node.*) {
                    .precompiled => unreachable,
                    .declaration => |*n| &n.dependencies,
                    .anonymous_function => |*n| &n.dependencies,
                };

                // Check if already present
                var already_present = false;
                for (deps.items) |dep| {
                    if (dep.module_id == search_key.module_id and dep.name == search_key.name) {
                        already_present = true;
                        break;
                    }
                }

                if (!already_present) {
                    try deps.append(allocator, search_key);
                }
                return;
            }
        }
    }
}

fn resolveValueIdentifier(
    self: *Resolver,
    key: DependencyGraph.NodeKey,
    node: *DependencyGraph.Node,
    name: StringTable.Id,
) error{OutOfMemory}!void {
    const allocator = self.arena.allocator();
    const locals = switch (node.*) {
        .precompiled => &[_]StringTable.Id{},
        .declaration => |*n| n.locals.items,
        .anonymous_function => |*n| n.locals.items,
    };

    for (locals) |local| {
        if (local == name) return;
    }

    if (node.* == .anonymous_function) {
        var current_key = key;
        var current_parent = node.anonymous_function.parent;

        while (current_parent) |parent_name| {
            const parent_key = DependencyGraph.NodeKey{
                .module_id = current_key.module_id,
                .name = parent_name,
            };

            if (self.graph.nodes.get(parent_key)) |parent_node| {
                const parent_locals = switch (parent_node.*) {
                    .precompiled => &[_]StringTable.Id{},
                    .declaration => |*n| n.locals.items,
                    .anonymous_function => |*n| n.locals.items,
                };

                for (parent_locals) |local| {
                    if (local == name) {
                        const anon_node = &node.anonymous_function;

                        // Check if already captured
                        var already_captured = false;
                        for (anon_node.closure_captures.items) |capture| {
                            if (capture.parent_name == parent_name and capture.local == name) {
                                already_captured = true;
                                break;
                            }
                        }

                        if (!already_captured) {
                            try anon_node.closure_captures.append(allocator, .{
                                .parent_name = parent_name,
                                .local = name,
                            });
                        }
                        return;
                    }
                }

                // Check if parent captures this variable
                if (parent_node.* == .anonymous_function) {
                    const parent_anon = parent_node.anonymous_function;
                    for (parent_anon.closure_captures.items) |capture| {
                        if (capture.local == name) {
                            const anon_node = &node.anonymous_function;

                            // Check if already captured
                            var already_captured = false;
                            for (anon_node.closure_captures.items) |existing_capture| {
                                if (existing_capture.parent_name == capture.parent_name and existing_capture.local == name) {
                                    already_captured = true;
                                    break;
                                }
                            }

                            if (!already_captured) {
                                try anon_node.closure_captures.append(allocator, capture);
                            }
                            return;
                        }
                    }
                }

                current_key = parent_key;
                current_parent = switch (parent_node.*) {
                    .anonymous_function => |*n| n.parent,
                    else => null,
                };
            } else {
                break;
            }
        }
    }

    var search_key = DependencyGraph.NodeKey{
        .module_id = key.module_id,
        .name = name,
    };

    if (self.graph.nodes.get(search_key)) |_| {
        const deps = switch (node.*) {
            .precompiled => unreachable,
            .declaration => |*n| &n.dependencies,
            .anonymous_function => |*n| &n.dependencies,
        };

        // Check if already present
        var already_present = false;
        for (deps.items) |dep| {
            if (dep.module_id == search_key.module_id and dep.name == search_key.name) {
                already_present = true;
                break;
            }
        }

        if (!already_present) {
            try deps.append(allocator, search_key);
        }
        return;
    }

    if (self.module_dependencies.get(key.module_id)) |dependencies| {
        for (dependencies.items) |module_id| {
            search_key.module_id = module_id;
            if (self.graph.nodes.get(search_key)) |_| {
                const deps = switch (node.*) {
                    .precompiled => unreachable,
                    .declaration => |*n| &n.dependencies,
                    .anonymous_function => |*n| &n.dependencies,
                };

                // Check if already present
                var already_present = false;
                for (deps.items) |dep| {
                    if (dep.module_id == search_key.module_id and dep.name == search_key.name) {
                        already_present = true;
                        break;
                    }
                }

                if (!already_present) {
                    try deps.append(allocator, search_key);
                }
                return;
            }
        }
    }

    const unbound_locals = switch (node.*) {
        .precompiled => unreachable,
        .declaration => |*n| &n.locals,
        .anonymous_function => |*n| &n.locals,
    };

    // Check if already present
    var already_present = false;
    for (unbound_locals.items) |local| {
        if (local == name) {
            already_present = true;
            break;
        }
    }

    if (!already_present) {
        try unbound_locals.append(allocator, name);
    }
}

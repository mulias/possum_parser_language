const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const Frontend = @import("../frontend.zig");
const Ast = Frontend.Ast;
const Paths = @import("path_table.zig").PathTable;
const Region = @import("../region.zig").Region;

// Compile-time check of parser function calls against the callee's declared
// parameter kinds. The can ast records whether each argument is a parser or
// a value; the goal ast erases that distinction (a literal argument has no
// surface kind there), so the check runs on the can ast once the dependency
// graph has resolved callees. Value calls are not checked, matching the
// value compilation path.

pub const Diagnostic = struct {
    region: Region,
    expected: Kind,

    pub const Kind = enum { parser, value };
};

pub fn checkParserFunction(
    frontend: *Frontend,
    node: *Frontend.DependencyGraphNode,
    body: *Ast.Parser.RNode,
) error{OutOfMemory}!?Diagnostic {
    var checker = Checker{ .frontend = frontend, .node = node };
    return checker.walkParser(body);
}

const Checker = struct {
    frontend: *Frontend,
    // The dependency-graph node whose body is being checked. Its locals and
    // dependencies stand in for the compiler's per-function scope stack.
    node: *Frontend.DependencyGraphNode,

    fn walkParser(self: *Checker, rnode: *Ast.Parser.RNode) error{OutOfMemory}!?Diagnostic {
        switch (rnode.node) {
            .@"or" => |n| {
                if (try self.walkParser(n.left)) |d| return d;
                return self.walkParser(n.right);
            },
            .@"return" => |n| return self.walkParser(n.left),
            // An anonymous function body is checked through its own
            // dependency-graph node.
            .anonymous_function => return null,
            .conditional => |n| {
                if (try self.walkParser(n.condition)) |d| return d;
                if (try self.walkParser(n.then_branch)) |d| return d;
                return self.walkParser(n.else_branch);
            },
            .destructure => |n| return self.walkParser(n.left),
            .function_call => |call| return self.walkCall(call),
            .identifier, .number_string, .string => return null,
            .merge => |n| {
                if (try self.walkParser(n.left)) |d| return d;
                return self.walkParser(n.right);
            },
            .range => |n| {
                if (n.lower) |lower| if (try self.walkParser(lower)) |d| return d;
                if (n.upper) |upper| return self.walkParser(upper);
                return null;
            },
            .repeat => |n| return self.walkParser(n.left),
            .string_template => |parts| {
                for (parts.items) |part| if (try self.walkParser(part)) |d| return d;
                return null;
            },
            .take_left => |n| {
                if (try self.walkParser(n.left)) |d| return d;
                return self.walkParser(n.right);
            },
            .take_right => |n| {
                if (try self.walkParser(n.left)) |d| return d;
                return self.walkParser(n.right);
            },
        }
    }

    fn walkCall(self: *Checker, call: Ast.Parser.FunctionCall) error{OutOfMemory}!?Diagnostic {
        if (try self.checkArgKinds(call)) |d| return d;
        if (try self.walkParser(call.function)) |d| return d;
        for (call.args.items) |arg| switch (arg) {
            .parser => |p| if (try self.walkParser(p)) |d| return d,
            .value => {},
        };
        return null;
    }

    fn checkArgKinds(self: *Checker, call: Ast.Parser.FunctionCall) error{OutOfMemory}!?Diagnostic {
        const ident = switch (call.function.node) {
            .identifier => |ident| ident,
            else => return null,
        };
        // A local callee shadows any global; its param kinds are only
        // runtime known and are asserted by the emitted bytecode.
        if (self.isLocal(ident.name)) return null;
        const decl = (try self.resolveFunction(ident.name)) orelse return null;
        // An arity mismatch is its own error; kinds only compare
        // positionally when the arity matches.
        if (decl.param_count() != call.args.items.len) return null;

        for (call.args.items, 0..) |arg, i| {
            const expected_parser = switch (decl) {
                .parser => |p| p.node.params.items[i] == .parser,
                .value => false,
            };
            if ((arg == .parser) != expected_parser) {
                return .{
                    .region = arg.region(),
                    .expected = if (expected_parser) .parser else .value,
                };
            }
        }
        return null;
    }

    fn isLocal(self: *const Checker, name: Paths.Id) bool {
        const segment = self.frontend.paths.single(name) orelse return false;
        for (self.node.locals()) |local| {
            if (local == segment) return true;
        }
        return false;
    }

    // Resolve a callee name to the function declaration it names, chasing
    // parameterless bare-identifier aliases the way the backend
    // denormalizes them. Precompiled builtins and unresolved names have no
    // can declaration to check against.
    fn resolveFunction(self: *Checker, name: Paths.Id) error{OutOfMemory}!?Ast.ParserOrValue.Declaration {
        var node = self.node;
        var ref = name;
        var visited: ArrayList(Frontend.GlobalKey) = .{};
        defer visited.deinit(self.frontend.allocator);

        while (true) {
            const key = node.dependencyNamed(ref) orelse return null;
            for (visited.items) |seen| {
                if (seen.module_id == key.module_id and seen.name == key.name) return null;
            }
            try visited.append(self.frontend.allocator, key);

            const target = self.frontend.getNode(key);
            switch (target.*) {
                .precompiled, .anonymous_function => return null,
                .declaration => |*decl_node| {
                    const decl = decl_node.ast;
                    if (decl.param_count() == 0) {
                        if (aliasTargetName(decl)) |next_ref| {
                            node = target;
                            ref = next_ref;
                            continue;
                        }
                    }
                    return decl;
                },
            }
        }
    }

    fn aliasTargetName(decl: Ast.ParserOrValue.Declaration) ?Paths.Id {
        return switch (decl) {
            .parser => |p| switch (p.node.body.node) {
                .identifier => |ident| ident.name,
                else => null,
            },
            .value => |v| switch (v.node.body.node) {
                .identifier => |ident| ident.name,
                else => null,
            },
        };
    }
};

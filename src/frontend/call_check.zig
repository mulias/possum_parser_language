const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const Frontend = @import("../frontend.zig");
const Ast = @import("goal_ast.zig");
const Paths = @import("path_table.zig").PathTable;
const Region = @import("../region.zig").Region;

// Compile-time check of parser function calls against the callee's declared
// parameter kinds. A goal `call` records which arguments are values
// (value_args) and a declaration which parameters are values (param_types);
// a mismatch on a parser-invoked callee is the surface parser-vs-value
// error. Value calls target value functions, whose params are all values
// and so always match, so only calls with a parser-kind identifier callee
// need checking.

pub const Diagnostic = struct {
    region: Region,
    expected: Kind,

    pub const Kind = enum { parser, value };
};

pub fn checkFunction(
    frontend: *Frontend,
    node: *Frontend.DependencyGraphNode,
    ast: *const Ast,
    body: Ast.NodeId,
) error{OutOfMemory}!?Diagnostic {
    var checker = Checker{ .frontend = frontend, .node = node, .ast = ast };
    return checker.walk(body);
}

const Checker = struct {
    frontend: *Frontend,
    // The dependency-graph node whose body is being checked. Its locals and
    // dependencies stand in for the compiler's per-function scope stack.
    node: *Frontend.DependencyGraphNode,
    ast: *const Ast,

    fn walk(self: *Checker, id: Ast.NodeId) error{OutOfMemory}!?Diagnostic {
        const rnode = self.ast.goals.items[id];
        switch (rnode.node) {
            .call => |call| {
                if (try self.checkCall(call)) |d| return d;
                if (try self.walk(call.callee)) |d| return d;
                for (call.args) |arg| if (try self.walk(arg)) |d| return d;
            },
            .alt => |arms| {
                for (arms.items) |arm| {
                    if (arm.guard) |guard| if (try self.walk(guard)) |d| return d;
                    if (arm.body) |body| if (try self.walk(body)) |d| return d;
                }
            },
            .seq => |seq| {
                for (seq.goals.items) |goal| if (try self.walk(goal)) |d| return d;
            },
            .neg, .to_string => |inner| return self.walk(inner),
            .merge => |merge| {
                if (try self.walk(merge.left)) |d| return d;
                return self.walk(merge.right);
            },
            .mult => |mult| {
                if (try self.walk(mult.left)) |d| return d;
                return self.walk(mult.right);
            },
            .array => |items| {
                for (items.items) |item| if (try self.walk(item)) |d| return d;
            },
            .object => |pairs| {
                for (pairs.items) |pair| {
                    if (try self.walk(pair.key)) |d| return d;
                    if (try self.walk(pair.value)) |d| return d;
                }
            },
            .range => |range| {
                if (range.lower) |lower| if (try self.walk(lower)) |d| return d;
                if (range.upper) |upper| return self.walk(upper);
            },
            // The count pattern is not parser context; only the repeated
            // body is walked, matching the surface check.
            .repeat => |rep| return self.walk(rep.body),
            // A match comes from a destructure: only its scrutinee is parser
            // context. The pattern side holds no parser-invoked calls.
            .match => |match| return self.walk(match.scrutinee),
            // Lambdas are checked through their own graph node.
            .lambda => {},
            .ident, .number_string, .number_float, .string, .true, .false, .null => {},
        }
        return null;
    }

    fn checkCall(self: *Checker, call: Ast.Call) error{OutOfMemory}!?Diagnostic {
        const callee = self.ast.goals.items[call.callee].node;
        const ident = switch (callee) {
            .ident => |ident| ident,
            else => return null,
        };
        // Value calls always match their value callee's all-value params.
        if (ident.kind != .parser) return null;
        // A local callee shadows any global; its param kinds are only
        // runtime known and are asserted by the emitted bytecode.
        if (self.isLocal(ident.name)) return null;
        const decl = (try self.resolveFunction(ident.name)) orelse return null;
        // An arity mismatch is its own error; kinds only compare
        // positionally when the arity matches. Args past bit 31 are
        // unrepresentable and rejected by the compiler.
        if (decl.params.items.len != call.args.len) return null;

        var i: usize = 0;
        while (i < call.args.len and i < 32) : (i += 1) {
            const bit = @as(u32, 1) << @intCast(i);
            const arg_is_value = call.value_args & bit != 0;
            const param_is_value = decl.param_types & bit != 0;
            if (arg_is_value != param_is_value) {
                return .{
                    .region = self.ast.goals.items[call.args[i]].region,
                    .expected = if (param_is_value) .value else .parser,
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

    // Resolve a callee name to the declaration it names, chasing
    // parameterless bare-identifier aliases the way the backend
    // denormalizes them. Precompiled builtins and unresolved names have no
    // declaration to check against.
    fn resolveFunction(self: *Checker, name: Paths.Id) error{OutOfMemory}!?*const Ast.Declaration {
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
                    const decl = decl_node.decl;
                    if (decl.params.items.len == 0) {
                        if (aliasTargetName(decl_node.module_ast, decl)) |next_ref| {
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

    // The name a parameterless alias forwards to: a value alias's body is a
    // bare identifier, a parser alias's is that identifier invoked.
    fn aliasTargetName(ast: *const Ast, decl: *const Ast.Declaration) ?Paths.Id {
        switch (ast.goals.items[decl.body].node) {
            .ident => |ident| return ident.name,
            .call => |call| {
                if (call.args.len != 0) return null;
                switch (ast.goals.items[call.callee].node) {
                    .ident => |ident| return ident.name,
                    else => return null,
                }
            },
            else => return null,
        }
    }
};

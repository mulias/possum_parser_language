const std = @import("std");
const Frontend = @import("../frontend.zig");
const GlobalKey = Frontend.GlobalKey;
const DependencyGraphNode = Frontend.DependencyGraphNode;
const FrontendStrings = Frontend.StringTable;
const Paths = Frontend.PathTable;
const runtime = @import("../runtime.zig");
const Elem = runtime.Elem;
const Module = runtime.Module;

pub const GlobalMap = std.AutoHashMapUnmanaged(GlobalKey, Elem);

// Resolve identifiers written in a function body against the current scope
// and the global map. Holds only borrowed references, so the compiler can
// build a fresh resolver per lookup with its live current scope.
pub const NameResolver = struct {
    scope: *const DependencyGraphNode,
    global_map: *const GlobalMap,
    paths: *const Paths,

    pub fn findGlobal(self: NameResolver, module_id: Module.Id, name: Paths.Id) ?Elem {
        if (self.global_map.get(.{ .module_id = module_id, .name = name })) |elem| {
            return elem;
        }
        return null;
    }

    // Resolve an identifier in the body of the function currently being
    // compiled. Names that refer to declarations in other modules are found
    // through the function's dependency graph node, where the resolver
    // recorded the target module. Anonymous functions are in the globals map
    // but can't be invoked by name, so they are hidden here.
    pub fn resolveGlobal(self: NameResolver, module_id: Module.Id, name: Paths.Id) ?Elem {
        if (self.findGlobal(module_id, name)) |elem| {
            return visibleGlobal(elem);
        }

        for (self.scope.dependencies()) |dep_key| {
            if (dep_key.name == name) {
                const elem = self.findGlobal(dep_key.module_id, dep_key.name) orelse return null;
                return visibleGlobal(elem);
            }
        }

        return null;
    }

    // The frame slot of an identifier. Dotted names are never locals.
    pub fn localSlot(self: NameResolver, name: Paths.Id) ?u8 {
        const segment = self.paths.single(name) orelse return null;
        return self.localSlotSid(segment);
    }

    pub fn localSlotSid(self: NameResolver, segment: FrontendStrings.Id) ?u8 {
        for (self.scope.locals(), 0..) |local, i| {
            if (local == segment) return @intCast(i);
        }
        return null;
    }

    fn visibleGlobal(elem: Elem) ?Elem {
        if (elem.isDynType(.Function) and elem.asDyn().asFunction().is_anonymous) {
            return null;
        }
        return elem;
    }
};

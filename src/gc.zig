const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const VM = @import("vm.zig").VM;
const Elem = @import("elem.zig").Elem;

pub const GC = struct {
    vm: *VM,
    parent_allocator: Allocator,
    bytesAllocated: usize,
    nextGC: usize,
    nextDyn: ?*Elem.DynElem,
    nextGray: ?*Elem.DynElem,
    collections: u64,
    mode: Mode,
    print_gc: bool,
    print_trace: bool,
    running_gc: bool,

    pub const Mode = enum { GC, NoGC, StressTest };

    const HEAP_GROW_FACTOR = 2;

    pub fn init(vm: *VM, parent_allocator: Allocator) GC {
        return .{
            .vm = vm,
            .parent_allocator = parent_allocator,
            .bytesAllocated = 0,
            .nextGC = 1024 * 1024,
            .nextDyn = null,
            .nextGray = null,
            .collections = 0,
            .mode = vm.config.gc_mode,
            .print_gc = vm.config.print_gc,
            .print_trace = false,
            .running_gc = false,
        };
    }

    pub fn deinit(self: *GC) void {
        self.running_gc = true;
        var dyn = self.nextDyn;
        while (dyn) |d| {
            const next = d.next;
            d.destroy(self.vm);
            dyn = next;
        }
        self.running_gc = false;
    }

    pub fn allocator(self: *GC) Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            },
        };
    }

    pub fn createDynElem(self: *GC, comptime T: type, dynType: Elem.DynType) !*Elem.DynElem {
        const ptr = try self.allocator().create(T);
        const id = self.vm.nextUniqueId();

        ptr.dyn = Elem.DynElem{
            .id = id,
            .dynType = dynType,
            .next = self.nextDyn,
            .isMarked = false,
            .nextGray = null,
        };

        self.nextDyn = &ptr.dyn;

        return &ptr.dyn;
    }

    fn shouldRunGc(self: GC, n: usize) bool {
        if (self.running_gc) return false;
        return (self.mode == .GC and self.bytesAllocated + n > self.nextGC) or self.mode == .StressTest;
    }

    fn alloc(ctx: *anyopaque, n: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        const self: *GC = @ptrCast(@alignCast(ctx));
        if (self.shouldRunGc(n)) {
            self.collectGarbage();
        }
        const out = self.parent_allocator.rawAlloc(n, alignment, ret_addr) orelse return null;
        self.bytesAllocated += n;
        return out;
    }

    pub fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        const self: *GC = @ptrCast(@alignCast(ctx));
        if (new_len > buf.len) {
            if (self.shouldRunGc(new_len - buf.len)) {
                self.collectGarbage();
            }
        }

        if (self.parent_allocator.rawResize(buf, alignment, new_len, ret_addr)) {
            if (new_len > buf.len) {
                self.bytesAllocated += new_len - buf.len;
            } else {
                self.bytesAllocated -= buf.len - new_len;
            }
            return true;
        } else {
            return false;
        }
    }

    pub fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *GC = @ptrCast(@alignCast(ctx));
        if (new_len > buf.len) {
            if (self.shouldRunGc(new_len - buf.len)) {
                self.collectGarbage();
            }
        }

        const out = self.parent_allocator.rawRemap(buf, alignment, new_len, ret_addr);

        if (out != null) {
            if (new_len > buf.len) {
                self.bytesAllocated += new_len - buf.len;
            } else {
                self.bytesAllocated -= buf.len - new_len;
            }
        }

        return out;
    }

    pub fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        const self: *GC = @ptrCast(@alignCast(ctx));
        self.parent_allocator.rawFree(buf, alignment, ret_addr);
        self.bytesAllocated -= buf.len;
        if (self.bytesAllocated < 0) {
            self.vm.writers.debug.print("allocated: {} bytes\n", .{self.bytesAllocated}) catch {};
        }
    }

    // Force a collection regardless of mode, for the post-run memory
    // report: afterward the dyn chain holds only reachable values.
    pub fn collect(self: *GC) void {
        self.collectGarbage();
    }

    fn collectGarbage(self: *GC) void {
        self.collections += 1;

        if (self.print_gc) {
            self.vm.writers.debug.print("-- gc begin (allocated: {} bytes, threshold: {} bytes)\n", .{ self.bytesAllocated, self.nextGC }) catch {};
        }

        const before_count = self.countDynElems();

        self.running_gc = true;
        self.clearConsumedMutableConstants();
        if (comptime builtin.mode == .Debug) self.auditRefCounts();
        self.markRoots();
        self.traceReferences();
        self.sweep();
        self.running_gc = false;

        const after_count = self.countDynElems();
        self.nextGC = self.bytesAllocated * HEAP_GROW_FACTOR;

        if (self.print_gc) {
            self.vm.writers.debug.print("-- gc end (freed {} objects, {} remain)\n\n", .{ before_count - after_count, after_count }) catch {};
        }
    }

    // Recount the owning handles the refcount scheme tracks (value-stack
    // entries and frame locals, container children, closure captures and
    // functions) and assert no value's true handle count exceeds its
    // ref_count. Undercounts license in-place mutation of shared values;
    // this turns them into an assertion failure at the next collection.
    // Overcounts are expected: decrements are deferred or skipped, and
    // handles held only by Zig temporaries or the constant table are not
    // recounted here.
    fn auditRefCounts(self: *GC) void {
        var counts = std.AutoHashMap(*Elem.DynElem, u32).init(self.parent_allocator);
        defer counts.deinit();

        for (self.vm.stack.items) |value| {
            auditHandle(&counts, value);
        }

        var dyn = self.nextDyn;
        while (dyn) |d| : (dyn = d.next) {
            d.forEachChild(&counts, auditHandle);
        }

        var iter = counts.iterator();
        while (iter.next()) |entry| {
            const d = entry.key_ptr.*;
            const true_count = entry.value_ptr.*;
            if (true_count > d.ref_count) {
                std.debug.panic(
                    "refcount audit: {s}(id={d}) has {d} live handles but ref_count {d}",
                    .{ @tagName(d.dynType), d.id, true_count, d.ref_count },
                );
            }
        }
    }

    fn auditHandle(counts: *std.AutoHashMap(*Elem.DynElem, u32), value: Elem) void {
        if (!value.isType(.Dyn)) return;
        const d = value.asDyn();
        if (d.ref_count == Elem.DynElem.immortal_ref_count) return;
        const entry = counts.getOrPut(d) catch return;
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }

    fn countDynElems(self: *GC) usize {
        var count: usize = 0;
        var dyn = self.nextDyn;
        while (dyn) |d| {
            count += 1;
            dyn = d.next;
        }
        return count;
    }

    // A mutable-constant cache entry whose slot holds the only handle was
    // fully consumed: its children are unobservable until the next reuse
    // refreshes them from the template. Releasing them here mirrors
    // sweep's dead-holder release — a value whose only extra holder is a
    // parked cache copy becomes unique again — and lets the children be
    // swept this cycle. The emptied husk stays parked for reuse.
    fn clearConsumedMutableConstants(self: *GC) void {
        for (self.vm.modules.items) |module| {
            for (module.mutable_constants.items) |maybe_cached| {
                const cached = maybe_cached orelse continue;
                if (!cached.isUnique()) continue;
                cached.clearChildren();
            }
        }
    }

    fn markRoots(self: *GC) void {
        if (self.print_trace) {
            self.vm.writers.debug.print("  marking roots:\n", .{}) catch {};
            self.vm.writers.debug.print("    stack items: {}\n", .{self.vm.stack.items.len}) catch {};
        }

        if (self.vm.compiler) |compiler| {
            for (compiler.functions.items) |f| {
                self.markDyn(&f.dyn);
            }

            // Declared globals are only referenced by the global_map until
            // the first use in another function's bytecode adds them to a
            // module's constants.
            var globals = compiler.global_map.valueIterator();
            while (globals.next()) |elem| {
                self.markElem(elem.*);
            }

            if (compiler.main) |main| {
                self.markDyn(&main.dyn);
            }
        }

        if (self.vm.singleton_empty_array) |empty_array| {
            self.markDyn(empty_array.asDyn());
        }
        if (self.vm.singleton_empty_object) |empty_object| {
            self.markDyn(empty_object.asDyn());
        }

        for (self.vm.stack.items) |value| {
            self.markElem(value);
        }

        if (self.print_trace) {
            self.vm.writers.debug.print("    frames: {}\n", .{self.vm.frames.items.len}) catch {};
        }

        for (self.vm.frames.items) |f| {
            self.markDyn(&f.function.dyn);
        }

        if (self.print_trace) {
            self.vm.writers.debug.print("    modules: {}\n", .{self.vm.modules.items.len}) catch {};
        }

        for (self.vm.modules.items) |module| {
            if (self.print_trace and module.constants.items.len > 0) {
                self.vm.writers.debug.print("    module {s}: marking {} constants\n", .{ module.name, module.constants.items.len }) catch {};
            }
            for (module.constants.items) |elem| {
                self.markElem(elem);
            }
            for (module.mutable_constants.items) |maybe_cached| {
                if (maybe_cached) |cached| self.markDyn(cached);
            }
        }

        if (self.print_trace) {
            self.vm.writers.debug.print("    temp dyns: {}\n", .{self.vm.temp_dyns.items.len}) catch {};
        }

        for (self.vm.temp_dyns.items) |dyn| {
            self.markDyn(dyn);
        }
    }

    fn traceReferences(self: *GC) void {
        while (self.nextGray) |dyn| {
            self.nextGray = dyn.nextGray;
            dyn.nextGray = null;
            self.blackenDyn(dyn);
        }
    }

    fn sweep(self: *GC) void {
        // A dead holder's child handles die with it. Releasing them before
        // any destruction (children may themselves be dead and about to be
        // freed) restores precision for the survivors: a value whose only
        // extra holder was garbage becomes unique again.
        var unmarked = self.nextDyn;
        while (unmarked) |d| : (unmarked = d.next) {
            if (!d.isMarked) d.releaseChildren();
        }

        var previous: ?*Elem.DynElem = null;
        var maybeObject = self.nextDyn;
        while (maybeObject) |object| {
            if (object.isMarked) {
                object.isMarked = false;
                previous = object;
                maybeObject = object.next;
            } else {
                const unreached = object;
                maybeObject = object.next;

                if (self.print_trace) {
                    self.vm.writers.debug.print("  sweep {} (type: {s}, id: {})\n", .{ @intFromPtr(unreached), @tagName(unreached.dynType), unreached.id }) catch {};
                }

                if (self.print_gc) {
                    self.printDeallocate(unreached);
                }

                if (previous) |p| {
                    p.next = maybeObject;
                } else {
                    self.nextDyn = maybeObject;
                }

                unreached.destroy(self.vm);
            }
        }
    }

    fn blackenDyn(self: *GC, dyn: *Elem.DynElem) void {
        if (self.print_trace) {
            self.vm.writers.debug.print("  blacken {} (type: {s}, id: {})\n", .{ @intFromPtr(dyn), @tagName(dyn.dynType), dyn.id }) catch {};
        }

        dyn.forEachChild(self, markElem);
    }

    fn markElem(self: *GC, elem: Elem) void {
        if (elem.isType(.Dyn)) self.markDyn(elem.asDyn());
    }

    fn markDyn(self: *GC, dyn: *Elem.DynElem) void {
        if (dyn.isMarked) return;

        if (self.print_trace) {
            self.vm.writers.debug.print("  mark {} (type: {s}, id: {})\n", .{ @intFromPtr(dyn), @tagName(dyn.dynType), dyn.id }) catch {};
        }

        dyn.isMarked = true;

        dyn.nextGray = self.nextGray;
        self.nextGray = dyn;
    }

    pub fn printAllocate(self: *GC, dyn: *Elem.DynElem) void {
        self.vm.writers.debug.print("GC: allocate {s}(id={})\n", .{ @tagName(dyn.dynType), dyn.id }) catch {};
    }

    fn printDeallocate(self: *GC, dyn: *Elem.DynElem) void {
        self.vm.writers.debug.print("GC: deallocate {s}(id={}) ", .{ @tagName(dyn.dynType), dyn.id }) catch {};
        dyn.print(self.vm.*, self.vm.writers.debug) catch {};
        self.vm.writers.debug.print("\n", .{}) catch {};
    }
};

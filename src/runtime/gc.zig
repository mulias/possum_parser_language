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
    // Heads of the parked-husk free lists: fully consumed values whose
    // header and payload capacity are ready to reuse. Parked husks hold
    // no handles, keep ref_count at parked_ref_count, stay linked in
    // the dyn list, and thread the free list through nextGray, which is
    // only otherwise used mid-collection. Collection clears the heads
    // before marking, so parked husks sweep as ordinary garbage: every
    // collection is also the pool trim.
    parked: ParkedLists,
    mode: Mode,
    print_gc: bool,
    print_trace: bool,
    running_gc: bool,

    // Pools are keyed by the payload a parked husk keeps warm. The two
    // string reprs park separately: a take can't convert a leaf's byte
    // buffer into a rope's segment list (or back) without allocating.
    const PoolKey = enum { array, object, closure, string_leaf, string_rope };

    const ParkedLists = std.EnumArray(PoolKey, ?*Elem.DynElem);

    fn poolKey(dyn: *Elem.DynElem) ?PoolKey {
        return switch (dyn.dynType) {
            .Array => .array,
            .Object => .object,
            .Closure => .closure,
            .String => switch (dyn.asString().repr) {
                .leaf => .string_leaf,
                .rope => .string_rope,
            },
            .Function, .NativeCode => null,
        };
    }

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
            .parked = ParkedLists.initFill(null),
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

    // Park a fully consumed value's husk for reuse. The caller owns the
    // value's only handle and is dropping it: children are released and
    // collections emptied here, so the husk holds no handles while parked.
    // Closures keep their function handle; see Closure.clearCaptures.
    pub fn park(self: *GC, dyn: *Elem.DynElem) void {
        std.debug.assert(dyn.ref_count == 1);
        const key = poolKey(dyn).?;
        switch (key) {
            .array, .object => dyn.clearChildren(),
            .closure => dyn.asClosure().clearCaptures(),
            .string_leaf => dyn.asString().repr.leaf.clearRetainingCapacity(),
            .string_rope => {
                dyn.releaseChildren();
                const rope = &dyn.asString().repr.rope;
                rope.segments.clearRetainingCapacity();
                rope.byte_len = 0;
            },
        }
        dyn.ref_count = Elem.DynElem.parked_ref_count;
        dyn.nextGray = self.parked.get(key);
        self.parked.set(key, dyn);
        self.vm.rc_stats.husks_parked += 1;
    }

    // Release a consumed value's handle; when it was the only one and the
    // type is poolable, park the husk instead of leaving it for the next
    // collection. Only sound where the handle is the value's last touch:
    // parking empties the husk in place. Gated with the other
    // uniqueness-trusting paths so a refcount bug can be bisected with
    // one flag.
    pub fn reclaim(self: *GC, dyn: *Elem.DynElem) void {
        if (self.vm.config.rc_fast_paths and dyn.ref_count == 1 and poolKey(dyn) != null) {
            return self.park(dyn);
        }
        dyn.release();
    }

    // The take side checks only the head of the free list: a miss leaves
    // the husk parked for the next collection to trim. Takes allocate
    // nothing, so an unparked husk is safe to fill while unrooted exactly
    // as far as a freshly created one is: callers must not allocate
    // through gc.allocator() past the reserved capacity until the value
    // is rooted.
    pub fn takeParkedArray(self: *GC, capacity: usize) ?*Elem.DynElem.Array {
        const head = self.parked.get(.array) orelse return null;
        const array = head.asArray();
        if (array.elems.capacity < capacity) return null;
        self.unpark(head);
        return array;
    }

    pub fn takeParkedObject(self: *GC, capacity: usize) ?*Elem.DynElem.Object {
        const head = self.parked.get(.object) orelse return null;
        const object = head.asObject();
        if (object.members.capacity() < capacity) return null;
        self.unpark(head);
        return object;
    }

    pub fn takeParkedClosure(self: *GC, function: *Elem.DynElem.Function, localCount: u8) ?*Elem.DynElem.Closure {
        const head = self.parked.get(.closure) orelse return null;
        const closure = head.asClosure();
        if (closure.captures.len != localCount) return null;
        self.unpark(head);
        if (closure.function != function) {
            function.dyn.retain();
            closure.function.dyn.release();
            closure.function = function;
        }
        return closure;
    }

    pub fn takeParkedLeaf(self: *GC, size: usize) ?*Elem.DynElem.String {
        const head = self.parked.get(.string_leaf) orelse return null;
        const string = head.asString();
        if (string.repr.leaf.capacity() < size) return null;
        self.unpark(head);
        return string;
    }

    pub fn takeParkedRope(self: *GC, capacity: usize) ?*Elem.DynElem.String {
        const head = self.parked.get(.string_rope) orelse return null;
        const string = head.asString();
        if (string.repr.rope.segments.capacity < capacity) return null;
        self.unpark(head);
        return string;
    }

    fn unpark(self: *GC, dyn: *Elem.DynElem) void {
        std.debug.assert(dyn.ref_count == Elem.DynElem.parked_ref_count);
        self.parked.set(poolKey(dyn).?, dyn.nextGray);
        dyn.nextGray = null;
        dyn.ref_count = 1;
        self.vm.rc_stats.husks_reused += 1;
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
        if (self.print_gc) {
            self.vm.writers.debug.print("-- gc begin (allocated: {} bytes, threshold: {} bytes)\n", .{ self.bytesAllocated, self.nextGC }) catch {};
        }

        const before_count = self.countDynElems();

        self.running_gc = true;
        self.parked = ParkedLists.initFill(null);
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

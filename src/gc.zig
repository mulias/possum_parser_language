const std = @import("std");
const Allocator = std.mem.Allocator;
const VM = @import("vm.zig").VM;
const Compiler = @import("./compiler.zig").Compiler;
const Elem = @import("elem.zig").Elem;

pub const GC = struct {
    vm: *VM,
    parent_allocator: Allocator,
    bytesAllocated: usize,
    nextGC: usize,
    nextDyn: ?*Elem.DynElem,
    nextGray: ?*Elem.DynElem,
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

    fn collectGarbage(self: *GC) void {
        if (self.print_gc) {
            self.vm.writers.debug.print("-- gc begin (allocated: {} bytes, threshold: {} bytes)\n", .{ self.bytesAllocated, self.nextGC }) catch {};
        }

        const before_count = self.countDynElems();

        self.running_gc = true;
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
            var iter = module.globals.iterator();
            while (iter.next()) |global| {
                self.markElem(global.value_ptr.*);
            }

            if (self.print_trace and module.constants.items.len > 0) {
                self.vm.writers.debug.print("    module {s}: marking {} constants\n", .{ module.name, module.constants.items.len }) catch {};
            }
            for (module.constants.items) |elem| {
                self.markElem(elem);
            }
        }

        if (self.vm.active_compiler) |compiler| {
            if (self.print_trace) {
                self.vm.writers.debug.print("    active compiler functions: {}\n", .{compiler.functions.items.len}) catch {};
            }
            for (compiler.functions.items) |f| {
                self.markDyn(&f.dyn);
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

        switch (dyn.dynType) {
            .Array => {
                const array = dyn.asArray();
                for (array.elems.items) |elem| self.markElem(elem);
            },
            .Object => {
                const object = dyn.asObject();
                var iter = object.members.iterator();
                while (iter.next()) |entry| self.markElem(entry.value_ptr.*);
            },
            .Function => {},
            .Closure => {
                const closure = dyn.asClosure();
                self.markDyn(&closure.function.dyn);
                for (closure.captures) |maybe_elem| {
                    if (maybe_elem) |elem| self.markElem(elem);
                }
            },
            .String,
            .NativeCode,
            => {},
        }
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

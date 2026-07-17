const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Module = @import("module.zig").Module;
const VM = @import("vm.zig").VM;

// Loads the modules that import declarations name. Disk paths and embedded
// logical names are disjoint keyspaces with separate caches. A module is
// cached before it is parsed, so import cycles rejoin the in-progress
// module instead of recursing forever.
pub const ModuleLoader = struct {
    vm: *VM,
    allocator: Allocator,
    // Normalized absolute path -> module. Keys live in owned_buffers.
    disk_cache: std.StringHashMapUnmanaged(Module.Id) = .{},
    // Embedded logical name -> module. Keys are static strings.
    embedded_cache: std.StringHashMapUnmanaged(Module.Id) = .{},
    // The absolute directory a file-backed module's relative imports
    // resolve against. Values are slices of owned_buffers entries.
    module_dirs: std.AutoHashMapUnmanaged(Module.Id, []const u8) = .{},
    // Allocations the loader owns: cache keys, module names, file sources.
    owned_buffers: ArrayList([]const u8) = .{},
    cwd_cache: ?[]const u8 = null,

    // The wasm build has no filesystem; only embedded modules load there.
    const has_disk = !builtin.target.cpu.arch.isWasm();

    pub const Error = error{
        FileImportUnsupported,
        ModuleNotFound,
        OutOfMemory,
    };

    pub const Result = struct {
        module: *Module,
        newly_loaded: bool,
    };

    const EmbeddedSource = struct {
        logical_name: []const u8,
        display_name: []const u8,
        source: []const u8,
    };

    const embedded_sources = [_]EmbeddedSource{
        .{
            .logical_name = "stdlib",
            .display_name = "stdlib/stdlib.possum",
            .source = @embedFile("stdlib/stdlib.possum"),
        },
        .{
            .logical_name = "stdlib/string",
            .display_name = "stdlib/string.possum",
            .source = @embedFile("stdlib/string.possum"),
        },
        .{
            .logical_name = "stdlib/number",
            .display_name = "stdlib/number.possum",
            .source = @embedFile("stdlib/number.possum"),
        },
        .{
            .logical_name = "stdlib/const",
            .display_name = "stdlib/const.possum",
            .source = @embedFile("stdlib/const.possum"),
        },
        .{
            .logical_name = "stdlib/array",
            .display_name = "stdlib/array.possum",
            .source = @embedFile("stdlib/array.possum"),
        },
        .{
            .logical_name = "stdlib/object",
            .display_name = "stdlib/object.possum",
            .source = @embedFile("stdlib/object.possum"),
        },
        .{
            .logical_name = "stdlib/repeat",
            .display_name = "stdlib/repeat.possum",
            .source = @embedFile("stdlib/repeat.possum"),
        },
        .{
            .logical_name = "stdlib/util",
            .display_name = "stdlib/util.possum",
            .source = @embedFile("stdlib/util.possum"),
        },
        .{
            .logical_name = "stdlib/json",
            .display_name = "stdlib/json.possum",
            .source = @embedFile("stdlib/json.possum"),
        },
        .{
            .logical_name = "stdlib/toml",
            .display_name = "stdlib/toml.possum",
            .source = @embedFile("stdlib/toml.possum"),
        },
        .{
            .logical_name = "stdlib/ast",
            .display_name = "stdlib/ast.possum",
            .source = @embedFile("stdlib/ast.possum"),
        },
        .{
            .logical_name = "stdlib/String",
            .display_name = "stdlib/string_value.possum",
            .source = @embedFile("stdlib/string_value.possum"),
        },
        .{
            .logical_name = "stdlib/Number",
            .display_name = "stdlib/number_value.possum",
            .source = @embedFile("stdlib/number_value.possum"),
        },
        .{
            .logical_name = "stdlib/Array",
            .display_name = "stdlib/array_value.possum",
            .source = @embedFile("stdlib/array_value.possum"),
        },
        .{
            .logical_name = "stdlib/Object",
            .display_name = "stdlib/object_value.possum",
            .source = @embedFile("stdlib/object_value.possum"),
        },
        .{
            .logical_name = "stdlib/Predicate",
            .display_name = "stdlib/predicate_value.possum",
            .source = @embedFile("stdlib/predicate_value.possum"),
        },
        .{
            .logical_name = "stdlib/Cast",
            .display_name = "stdlib/cast_value.possum",
            .source = @embedFile("stdlib/cast_value.possum"),
        },
    };

    pub fn init(vm: *VM, allocator: Allocator) ModuleLoader {
        return ModuleLoader{
            .vm = vm,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ModuleLoader) void {
        self.disk_cache.deinit(self.allocator);
        self.embedded_cache.deinit(self.allocator);
        self.module_dirs.deinit(self.allocator);
        for (self.owned_buffers.items) |buffer| self.allocator.free(buffer);
        self.owned_buffers.deinit(self.allocator);
        if (self.cwd_cache) |dir| self.allocator.free(dir);
    }

    pub fn getOrLoadEmbedded(self: *ModuleLoader, logical_name: []const u8) Error!Result {
        if (self.embedded_cache.get(logical_name)) |module_id| {
            return .{ .module = self.vm.getModule(module_id), .newly_loaded = false };
        }

        for (embedded_sources) |embedded| {
            if (std.mem.eql(u8, embedded.logical_name, logical_name)) {
                const module = try self.vm.createModule(embedded.display_name, embedded.source);
                try self.embedded_cache.put(self.allocator, embedded.logical_name, module.id);
                return .{ .module = module, .newly_loaded = true };
            }
        }

        return Error.ModuleNotFound;
    }

    pub fn getOrLoadFile(self: *ModuleLoader, literal: []const u8, importer: Module.Id) Error!Result {
        if (comptime !has_disk) {
            return Error.FileImportUnsupported;
        } else {
            const path = try self.resolvePath(literal, importer);
            errdefer self.allocator.free(path);

            if (self.disk_cache.get(path)) |module_id| {
                self.allocator.free(path);
                return .{ .module = self.vm.getModule(module_id), .newly_loaded = false };
            }

            const source = std.fs.cwd().readFileAlloc(self.allocator, path, std.math.maxInt(u32)) catch |err| switch (err) {
                error.OutOfMemory => return Error.OutOfMemory,
                else => return Error.ModuleNotFound,
            };
            errdefer self.allocator.free(source);

            const name = try self.allocator.dupe(u8, literal);
            errdefer self.allocator.free(name);

            const module = try self.vm.createModule(name, source);
            try self.registerPath(path, module.id);
            try self.trackBuffer(source);
            try self.trackBuffer(name);
            return .{ .module = module, .newly_loaded = true };
        }
    }

    // Seed the disk cache with an already-created module, so that imports
    // naming the same file dedup against it and its relative imports
    // resolve against its directory. The literal resolves against the
    // current working directory; no file is read.
    pub fn registerFileModule(self: *ModuleLoader, literal: []const u8, module_id: Module.Id) Error!void {
        if (comptime !has_disk) {
            return;
        } else {
            const path = try self.resolvePath(literal, module_id);
            errdefer self.allocator.free(path);
            if (self.disk_cache.contains(path)) {
                self.allocator.free(path);
                return;
            }
            try self.registerPath(path, module_id);
        }
    }

    // Takes ownership of `path`, which must be normalized and absolute.
    fn registerPath(self: *ModuleLoader, path: []const u8, module_id: Module.Id) Error!void {
        try self.disk_cache.put(self.allocator, path, module_id);
        try self.module_dirs.put(self.allocator, module_id, std.fs.path.dirname(path) orelse path);
        try self.trackBuffer(path);
    }

    fn trackBuffer(self: *ModuleLoader, buffer: []const u8) Error!void {
        try self.owned_buffers.append(self.allocator, buffer);
    }

    // Lexically normalize an import path: `~/` expands to the home
    // directory, absolute paths stand alone, and relative paths join the
    // importing module's directory (the working directory when the
    // importer is not file-backed). No symlink resolution.
    fn resolvePath(self: *ModuleLoader, literal: []const u8, importer: Module.Id) Error![]const u8 {
        if (std.mem.eql(u8, literal, "~") or std.mem.startsWith(u8, literal, "~/")) {
            const home = std.posix.getenv("HOME") orelse return Error.ModuleNotFound;
            return std.fs.path.resolve(self.allocator, &.{ home, literal[@min(literal.len, 2)..] }) catch Error.OutOfMemory;
        }
        if (std.fs.path.isAbsolute(literal)) {
            return std.fs.path.resolve(self.allocator, &.{literal}) catch Error.OutOfMemory;
        }
        const dir = self.module_dirs.get(importer) orelse try self.cwd();
        return std.fs.path.resolve(self.allocator, &.{ dir, literal }) catch Error.OutOfMemory;
    }

    fn cwd(self: *ModuleLoader) Error![]const u8 {
        if (self.cwd_cache == null) {
            self.cwd_cache = std.process.getCwdAlloc(self.allocator) catch return Error.ModuleNotFound;
        }
        return self.cwd_cache.?;
    }
};

const testing_writers = @import("../testing.zig").writers;
const test_allocator = std.testing.allocator;

fn testVM(vm: *VM) !void {
    try vm.init(test_allocator, testing_writers, .{ .includeStdlib = false });
}

test "embedded module loads once and is cached" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    const first = try vm.loader.getOrLoadEmbedded("stdlib");
    try std.testing.expect(first.newly_loaded);
    try std.testing.expectEqualStrings("stdlib/stdlib.possum", first.module.name);

    const second = try vm.loader.getOrLoadEmbedded("stdlib");
    try std.testing.expect(!second.newly_loaded);
    try std.testing.expectEqual(first.module.id, second.module.id);
}

test "unknown embedded module errors" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    try std.testing.expectError(
        ModuleLoader.Error.ModuleNotFound,
        vm.loader.getOrLoadEmbedded("stdlib/nope"),
    );
}

test "disk modules dedup by normalized path and resolve relative to the importer" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try tmp.dir.makeDir("sub");
    try tmp.dir.writeFile(.{ .sub_path = "sub/a.possum", .data = "x = \"x\"" });
    try tmp.dir.writeFile(.{ .sub_path = "sub/b.possum", .data = "y = \"y\"" });

    const tmp_path = try tmp.dir.realpathAlloc(test_allocator, ".");
    defer test_allocator.free(tmp_path);

    const a_path = try std.fs.path.join(test_allocator, &.{ tmp_path, "sub", "a.possum" });
    defer test_allocator.free(a_path);

    const a = try vm.loader.getOrLoadFile(a_path, 0);
    try std.testing.expect(a.newly_loaded);
    try std.testing.expectEqualStrings("x = \"x\"", a.module.source);

    // A dotted respelling of the same file hits the cache.
    const a_dotted = try std.fs.path.join(test_allocator, &.{ tmp_path, "sub", ".", "..", "sub", "a.possum" });
    defer test_allocator.free(a_dotted);
    const a_again = try vm.loader.getOrLoadFile(a_dotted, 0);
    try std.testing.expect(!a_again.newly_loaded);
    try std.testing.expectEqual(a.module.id, a_again.module.id);

    // A relative path from module `a` resolves in a's directory.
    const b = try vm.loader.getOrLoadFile("b.possum", a.module.id);
    try std.testing.expect(b.newly_loaded);
    try std.testing.expectEqualStrings("y = \"y\"", b.module.source);
}

test "missing file errors" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    try std.testing.expectError(
        ModuleLoader.Error.ModuleNotFound,
        vm.loader.getOrLoadFile("/nonexistent/nope.possum", 0),
    );
}

test "registerFileModule seeds the cache without reading disk" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    const module = try vm.createModule("virtual.possum", "x = \"x\"");
    try vm.loader.registerFileModule("virtual.possum", module.id);

    const hit = try vm.loader.getOrLoadFile("virtual.possum", module.id);
    try std.testing.expect(!hit.newly_loaded);
    try std.testing.expectEqual(module.id, hit.module.id);
}

test "~ expands to the home directory" {
    var vm = VM.create();
    try testVM(&vm);
    defer vm.deinit();

    if (std.posix.getenv("HOME")) |home| {
        const resolved = try vm.loader.resolvePath("~/foo.possum", 0);
        defer test_allocator.free(resolved);
        try std.testing.expect(std.mem.startsWith(u8, resolved, home));
        try std.testing.expect(std.mem.endsWith(u8, resolved, "/foo.possum"));
    }
}

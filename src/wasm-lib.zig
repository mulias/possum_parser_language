const std = @import("std");
const io = std.io;
const process = std.process;
const Allocator = std.mem.Allocator;

const VM = @import("./vm.zig").VM;
const ExternalWriter = @import("./writer.zig").ExternalWriter;

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = general_purpose_allocator.allocator();

// These functions are expected to be passed in as part of the WASM environment
extern fn writeOut(ptr: usize, len: usize) void;
extern fn writeErr(ptr: usize, len: usize) void;

fn writeOutSlice(bytes: []const u8) void {
    writeOut(@intFromPtr(bytes.ptr), bytes.len);
}

fn writeErrSlice(bytes: []const u8) void {
    writeErr(@intFromPtr(bytes.ptr), bytes.len);
}

fn createVMPtr() !*VM {
    const errWriter = ExternalWriter.init(writeErrSlice).writer();

    var vm = try allocator.create(VM);
    vm.* = VM.create();
    try vm.init(allocator, errWriter);
    return vm;
}

export fn createVM() usize {
    var vm = createVMPtr() catch return 0;
    return @intFromPtr(vm);
}

export fn destroyVM(vm: *VM) void {
    vm.deinit();
    allocator.destroy(vm);
}

export fn interpret(vm: *VM, parser_ptr: [*]const u8, parser_len: usize, input_ptr: [*]const u8, input_len: usize) usize {
    const outWriter = ExternalWriter.init(writeOutSlice).writer();

    const parser = parser_ptr[0..parser_len];
    const input = input_ptr[0..input_len];

    const parsed = vm.interpret(parser, input) catch |err| {
        vm.errWriter.print("Error: {s}", .{@errorName(err)}) catch return 1;
        return 1;
    };

    if (parsed == .Failure) {
        vm.errWriter.print("Parser Failure", .{}) catch return 1;
    } else {
        parsed.print(outWriter, vm.strings) catch return 1;
    }

    return 0;
}

export fn run(parser_ptr: [*]const u8, parser_len: usize, input_ptr: [*]const u8, input_len: usize) usize {
    var vm = createVMPtr() catch return 1;
    defer destroyVM(vm);
    return interpret(vm, parser_ptr, parser_len, input_ptr, input_len);
}

pub export fn alloc(len: usize) usize {
    var buf = allocator.alloc(u8, len) catch return 0;
    return @intFromPtr(buf.ptr);
}

pub export fn dealloc(ptr: [*]const u8, len: usize) void {
    allocator.free(ptr[0..len]);
}

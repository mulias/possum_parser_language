const std = @import("std");
const unicode = std.unicode;
const Elem = @import("elem.zig").Elem;
const Function = @import("elem.zig").Elem.DynElem.Function;
const NativeCode = @import("elem.zig").Elem.DynElem.NativeCode;
const Region = @import("region.zig").Region;
const StringTable = @import("string_table.zig").StringTable(.runtime);
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;
const parsing = @import("parsing.zig");

pub const CreateError = error{ OutOfMemory, ShortOverflow };

const CreateFn = *const fn (vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function;

pub const BuiltinFunction = struct {
    name: []const u8,
    create: CreateFn,
};

pub const functions = [_]BuiltinFunction{
    .{ .name = "@fail", .create = createFailParser },
    .{ .name = "@Fail", .create = createFailValue },
    .{ .name = "@Crash", .create = createCrashValue },
    .{ .name = "@Codepoint", .create = createCodepointValue },
    .{ .name = "@SurrogatePairCodepoint", .create = createSurrogatePairCodepointValue },
    .{ .name = "@dbg", .create = createDbgParser },
    .{ .name = "@Dbg", .create = createDbgValue },
    .{ .name = "@Add", .create = createAddValue },
    .{ .name = "@Subtract", .create = createSubtractValue },
    .{ .name = "@Multiply", .create = createMultiplyValue },
    .{ .name = "@Divide", .create = createDivideValue },
    .{ .name = "@Power", .create = createPowerValue },
    .{ .name = "@Modulus", .create = createModulusValue },
    .{ .name = "@Floor", .create = createFloorValue },
    .{ .name = "@Ceiling", .create = createCeilingValue },
    .{ .name = "@input.offset", .create = createInputOffset },
    .{ .name = "@input.line", .create = createInputLine },
    .{ .name = "@input.line_offset", .create = createInputLineOffset },
    .{ .name = "@at", .create = createAt },
};

// Instantiate the builtin with the given name, or return null if no such
// builtin exists. The name is interned into the VM string table here so that
// only builtins that are actually created add strings to the table.
pub fn create(vm: *VM, module: *Module, name: []const u8) CreateError!?*Function {
    for (functions) |bf| {
        if (std.mem.eql(u8, bf.name, name)) {
            const sid = try vm.strings.insert(bf.name);
            return try bf.create(vm, module, sid);
        }
    }
    return null;
}

fn createFailParser(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 0,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .PushFail, loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn createFailValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 0,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .PushFail, loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn createCrashValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .Crash, loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn createCodepointValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(
        vm,
        "stringToCodepointNative",
        stringToCodepoint,
    );

    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn stringToCodepoint(vm: *VM) VM.Error!void {
    const value = vm.popArg();
    defer value.release();

    if (value.isSuccess()) {
        if (try value.stringBytes(vm)) |bytes| {
            if (parsing.parseCodepoint(bytes)) |c| {
                const len = try unicode.utf8CodepointSequenceLength(c);
                const buffer = try vm.allocator.alloc(u8, len);
                defer vm.allocator.free(buffer);
                _ = try unicode.utf8Encode(c, buffer);
                var str = try Elem.DynElem.String.copy(vm, buffer);
                try vm.push(str.dyn.elem());
            } else {
                try vm.pushFailure();
            }
        } else {
            try vm.pushFailure();
        }
    } else {
        try vm.pushFailure();
    }
}

fn createSurrogatePairCodepointValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(
        vm,
        "stringsToSurrogateCodepointNative",
        stringsToSurrogateCodepoint,
    );

    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn stringsToSurrogateCodepoint(vm: *VM) VM.Error!void {
    const lowSurrogate = vm.popArg();
    const highSurrogate = vm.popArg();
    defer lowSurrogate.release();
    defer highSurrogate.release();

    if (highSurrogate.isSuccess() and lowSurrogate.isSuccess()) {
        if (try highSurrogate.stringBytes(vm)) |high| {
            if (try lowSurrogate.stringBytes(vm)) |low| {
                if (parsing.parseSurrogatePair(high, low)) |c| {
                    const len = try unicode.utf8CodepointSequenceLength(c);
                    const buffer = try vm.allocator.alloc(u8, len);
                    defer vm.allocator.free(buffer);
                    _ = try unicode.utf8Encode(c, buffer);
                    var str = try Elem.DynElem.String.copy(vm, buffer);
                    try vm.push(str.dyn.elem());
                } else {
                    try vm.pushFailure();
                }
            } else {
                try vm.pushFailure();
            }
        } else {
            try vm.pushFailure();
        }
    } else {
        try vm.pushFailure();
    }
}

fn createDbgParser(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .CallFunction, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn createDbgValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn dbgNative(vm: *VM) VM.Error!void {
    const value = vm.peek(0);
    const parser = vm.peek(1);
    try parser.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(": ", .{});
    try value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print("\n", .{});
}

fn createAddValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "addNative", addNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn addNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(0) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(0) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        if (a.isZero(vm.strings)) {
            return vm.push(b);
        } else if (b.isZero(vm.strings)) {
            return vm.push(a);
        }

        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() + b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Add expected number or null arguments", .{});
    }
}

fn createSubtractValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "subtractNative", subtractNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn subtractNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(0) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(0) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() - b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Subtract expected number or null arguments", .{});
    }
}

fn createMultiplyValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "multiplyNative", multiplyNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn multiplyNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(1) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(1) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() * b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Multiply expected number or null arguments", .{});
    }
}

fn createDivideValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "divideNative", divideNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn divideNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(1) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(1) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        if (b.isEql(Elem.numberFloat(0), vm.*)) {
            return vm.runtimeError("@Divide denominator is 0", .{});
        }

        const res = Elem.numberFloat(a.asFloat() / b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Divide expected number or null arguments", .{});
    }
}

fn createPowerValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "powerNative", powerNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn powerNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(1) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(1) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(std.math.pow(f64, a.asFloat(), b.asFloat()));
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Power expected number or null arguments", .{});
    }
}

fn createModulusValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "modulusNative", modulusNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn modulusNative(vm: *VM) VM.Error!void {
    const arg_b = vm.popArg();
    const arg_a = vm.popArg();
    defer arg_b.release();
    defer arg_a.release();

    var a = if (arg_a.isConst(.Null)) Elem.numberFloat(1) else arg_a;
    var b = if (arg_b.isConst(.Null)) Elem.numberFloat(1) else arg_b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = std.math.mod(f64, a.asFloat(), b.asFloat()) catch |e| switch (e) {
            error.DivisionByZero => return vm.runtimeError("@Mod denominator is 0", .{}),
            error.NegativeDenominator => return vm.runtimeError("@Mod denominator is negative", .{}),
        };

        return vm.push(Elem.numberFloat(res));
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Mod expected number or null arguments", .{});
    }
}

fn createFloorValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "floorNative", floorNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn floorNative(vm: *VM) VM.Error!void {
    const arg = vm.popArg();
    defer arg.release();

    var a = if (arg.isConst(.Null)) Elem.numberFloat(0) else arg;

    if (a.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;

        const res = Elem.numberFloat(std.math.floor(a.asFloat()));
        return vm.push(res);
    } else if (a.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Floor expected number or null arguments", .{});
    }
}

fn createCeilingValue(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 1,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "ceilingNative", ceilingNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn ceilingNative(vm: *VM) VM.Error!void {
    const arg = vm.popArg();
    defer arg.release();

    var a = if (arg.isConst(.Null)) Elem.numberFloat(0) else arg;

    if (a.isNumber()) {
        a = if (a.isType(.NumberString)) a.asNumberString().toNumberFloat(vm.strings) else a;

        const res = Elem.numberFloat(std.math.ceil(a.asFloat()));
        return vm.push(res);
    } else if (a.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Ceiling expected number or null arguments", .{});
    }
}

fn createInputOffset(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 0,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputOffsetNative", inputOffsetNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn inputOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.offset)),
    ))));
}

fn createInputLine(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 0,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputLineNative", inputLineNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn inputLineNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.line)),
    ))));
}

fn createInputLineOffset(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 0,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputLineOffsetNative", inputLineOffsetNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn inputLineOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(
        @as(f64, @floatFromInt(vm.inputPos.offset)) - @as(f64, @floatFromInt(vm.inputPos.line_start)),
    ));
}

fn createAt(vm: *VM, module: *Module, name: StringTable.Id) CreateError!*Function {
    const fun = try Function.create(vm, .{
        .module_id = module.id,
        .name = name,
        .arity = 2,
        .is_anonymous = false,
        .region = Region.new(0, 0),
    });

    fun.param_types.set(0, .Value);
    fun.param_types.set(1, .Parser);

    // Prevent GC
    _ = try module.addConstant(vm.allocator, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "setInputPositionNative", setInputPositionNative);
    const nc_id = try module.addConstant(vm.allocator, native_code.dyn.elem());
    std.debug.assert(nc_id <= 255);

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(vm.allocator, .SetInputMark, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .NativeCode, loc);
    try fun.chunk.write(vm.allocator, @intCast(nc_id), loc);
    const jumpIndex = try fun.chunk.writeJump(vm.allocator, .JumpIfFailure, loc);
    try fun.chunk.writeOp(vm.allocator, .GetLocal, loc);
    try fun.chunk.write(vm.allocator, 1, loc);
    try fun.chunk.writeOp(vm.allocator, .CallFunction, loc);
    try fun.chunk.write(vm.allocator, 0, loc);
    try fun.chunk.writeOp(vm.allocator, .ResetInput, loc);
    try fun.chunk.patchJump(jumpIndex);
    try fun.chunk.writeOp(vm.allocator, .End, loc);

    return fun;
}

fn setInputPositionNative(vm: *VM) VM.Error!void {
    const arg = vm.popArg();
    defer arg.release();

    var pos = arg;
    if (pos.isNumber()) {
        pos = if (pos.isType(.NumberString)) pos.asNumberString().toNumberFloat(vm.strings) else pos;
        const float = pos.asFloat();

        if (@floor(float) == float) {
            const offset = @as(usize, @intFromFloat(float));
            // offset might be truncated if float is negative
            if (0 <= float and offset <= vm.input.len) {
                vm.inputPos = .{ .offset = offset };
            } else {
                return vm.pushFailure();
            }
        } else {
            return vm.runtimeError("@at expected integer position value", .{});
        }
    } else if (pos.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@at expected integer position value", .{});
    }
}

const std = @import("std");
const unicode = std.unicode;
const Elem = @import("elem.zig").Elem;
const Function = @import("elem.zig").Elem.DynElem.Function;
const NativeCode = @import("elem.zig").Elem.DynElem.NativeCode;
const Region = @import("region.zig").Region;
const VM = @import("vm.zig").VM;
const Module = @import("module.zig").Module;
const parsing = @import("parsing.zig");

pub fn loadFunctions(vm: *VM, module: *Module) !void {
    try createFailParser(vm, module);
    try createFailValue(vm, module);
    try createCrashValue(vm, module);
    try createCodepointValue(vm, module);
    try createSurrogatePairCodepointValue(vm, module);
    try createDbgParser(vm, module);
    try createDbgValue(vm, module);
    try createAddValue(vm, module);
    try createSubtractValue(vm, module);
    try createMultiplyValue(vm, module);
    try createDivideValue(vm, module);
    try createPowerValue(vm, module);
    try createInputOffset(vm, module);
    try createInputLine(vm, module);
    try createInputLineOffset(vm, module);
}

fn createFailParser(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn createFailValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn createCrashValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Crash");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const argName = try vm.strings.insert("Message");
    _ = try fun.addLocal(vm, .{ .ValueVar = argName });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.Crash, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn createCodepointValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Codepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(
        vm,
        "stringToCodepointNative",
        stringToCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const argName = try vm.strings.insert("HexString");
    _ = try fun.addLocal(vm, .{ .ValueVar = argName });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn stringToCodepoint(vm: *VM) VM.Error!void {
    const value = vm.pop();

    if (value.isSuccess()) {
        if (value.stringBytes(vm.*)) |bytes| {
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

fn createSurrogatePairCodepointValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@SurrogatePairCodepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(
        vm,
        "stringsToSurrogateCodepointNative",
        stringsToSurrogateCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("HighSurrogate");
    const arg2 = try vm.strings.insert("LowSurrogate");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn stringsToSurrogateCodepoint(vm: *VM) VM.Error!void {
    const lowSurrogate = vm.pop();
    const highSurrogate = vm.pop();

    if (highSurrogate.isSuccess() and lowSurrogate.isSuccess()) {
        if (highSurrogate.stringBytes(vm.*)) |high| {
            if (lowSurrogate.stringBytes(vm.*)) |low| {
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

fn createDbgParser(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@dbg");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("p");
    _ = try fun.addLocal(vm, .{ .ParserVar = arg1 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.CallFunction, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn createDbgValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Dbg");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("V");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn dbgNative(vm: *VM) VM.Error!void {
    const value = vm.peek(0);
    const parser = vm.peek(1);
    try parser.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print(": ", .{});
    try value.print(vm.*, vm.writers.debug);
    try vm.writers.debug.print("\n", .{});
}

fn createAddValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Add");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "addNative", addNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn addNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.numberFloat(0) else a;
    b = if (b.isConst(.Null)) Elem.numberFloat(0) else b;

    if (a.isNumber() and b.isNumber()) {
        if (a.isZero(vm.strings)) {
            return vm.push(b);
        } else if (b.isZero(vm.strings)) {
            return vm.push(a);
        }

        a = if (a.isType(.NumberString)) try a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) try b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() + b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Add expected number or null arguments", .{});
    }
}

fn createSubtractValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Subtract");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "subtractNative", subtractNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn subtractNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.numberFloat(0) else a;
    b = if (b.isConst(.Null)) Elem.numberFloat(0) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) try a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) try b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() - b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Subtract expected number or null arguments", .{});
    }
}

fn createMultiplyValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Multiply");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "multiplyNative", multiplyNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn multiplyNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.numberFloat(1) else a;
    b = if (b.isConst(.Null)) Elem.numberFloat(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) try a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) try b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(a.asFloat() * b.asFloat());
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Multiply expected number or null arguments", .{});
    }
}

fn createDivideValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Divide");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "divideNative", divideNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn divideNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.numberFloat(1) else a;
    b = if (b.isConst(.Null)) Elem.numberFloat(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) try a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) try b.asNumberString().toNumberFloat(vm.strings) else b;

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

fn createPowerValue(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@Power");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "powerNative", powerNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    _ = try fun.addLocal(vm, .{ .ValueVar = arg1 });
    _ = try fun.addLocal(vm, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn powerNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.numberFloat(1) else a;
    b = if (b.isConst(.Null)) Elem.numberFloat(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a.isType(.NumberString)) try a.asNumberString().toNumberFloat(vm.strings) else a;
        b = if (b.isType(.NumberString)) try b.asNumberString().toNumberFloat(vm.strings) else b;

        const res = Elem.numberFloat(std.math.pow(f64, a.asFloat(), b.asFloat()));
        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Power expected number or null arguments", .{});
    }
}

fn createInputOffset(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@input.offset");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputOffsetNative", inputOffsetNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn inputOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.offset)),
    ))));
}

fn createInputLine(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@input.line");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputLineNative", inputLineNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn inputLineNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.line)),
    ))));
}

fn createInputLineOffset(vm: *VM, module: *Module) !void {
    const name = try vm.strings.insert("@input.line_offset");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    // Prevent GC
    try module.addGlobal(vm.allocator, fun.name, fun.dyn.elem());

    const native_code = try NativeCode.create(vm, "inputLineOffsetNative", inputLineOffsetNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);
}

fn inputLineOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.numberFloat(
        @as(f64, @floatFromInt(
            @as(i64, @intCast(vm.inputPos.offset - vm.inputPos.line_start)),
        )),
    ));
}

const std = @import("std");
const unicode = std.unicode;
const Elem = @import("elem.zig").Elem;
const Function = @import("elem.zig").Elem.DynElem.Function;
const NativeCode = @import("elem.zig").Elem.DynElem.NativeCode;
const Region = @import("region.zig").Region;
const VM = @import("vm.zig").VM;
const parsing = @import("parsing.zig");

pub fn functions(vm: *VM) ![15]*Function {
    return [_]*Function{
        try createFailParser(vm),
        try createFailValue(vm),
        try createCrashValue(vm),
        try createCodepointValue(vm),
        try createSurrogatePairCodepointValue(vm),
        try createDbgParser(vm),
        try createDbgValue(vm),
        try createAddValue(vm),
        try createSubtractValue(vm),
        try createMultiplyValue(vm),
        try createDivideValue(vm),
        try createPowerValue(vm),
        try createInputOffset(vm),
        try createInputLine(vm),
        try createInputLineOffset(vm),
    };
}

fn createFailParser(vm: *VM) !*Function {
    const name = try vm.strings.insert("@fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn createFailValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn createCrashValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Crash");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    const argName = try vm.strings.insert("Message");
    try fun.locals.append(vm.allocator, .{ .ValueVar = argName });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.Crash, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn createCodepointValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Codepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(
        vm,
        "stringToCodepointNative",
        stringToCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const argName = try vm.strings.insert("HexString");
    try fun.locals.append(vm.allocator, .{ .ValueVar = argName });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
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

fn createSurrogatePairCodepointValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@SurrogatePairCodepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(
        vm,
        "stringsToSurrogateCodepointNative",
        stringsToSurrogateCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("HighSurrogate");
    const arg2 = try vm.strings.insert("LowSurrogate");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
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

fn createDbgParser(vm: *VM) !*Function {
    const name = try vm.strings.insert("@dbg");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("p");
    try fun.locals.append(vm.allocator, .{ .ParserVar = arg1 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.CallFunction, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn createDbgValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Dbg");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("V");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

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

fn createAddValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Add");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "addNative", addNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn addNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.number(0) else a;
    b = if (b.isConst(.Null)) Elem.number(0) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a == .NumberString) try a.NumberString.toNumberElem(vm.strings) else a;
        b = if (b == .NumberString) try b.NumberString.toNumberElem(vm.strings) else b;

        const res = switch (a) {
            .Number => |num1| switch (b) {
                .Number => |num2| Elem.number(num1 + num2),
                else => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        };

        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Add expected number or null arguments", .{});
    }
}

fn createSubtractValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Subtract");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "subtractNative", subtractNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn subtractNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.number(0) else a;
    b = if (b.isConst(.Null)) Elem.number(0) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a == .NumberString) try a.NumberString.toNumberElem(vm.strings) else a;
        b = if (b == .NumberString) try b.NumberString.toNumberElem(vm.strings) else b;

        const res = switch (a) {
            .Number => |num1| switch (b) {
                .Number => |num2| Elem.number(num1 - num2),
                else => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        };

        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Subtract expected number or null arguments", .{});
    }
}

fn createMultiplyValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Multiply");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "multiplyNative", multiplyNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn multiplyNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.number(1) else a;
    b = if (b.isConst(.Null)) Elem.number(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a == .NumberString) try a.NumberString.toNumberElem(vm.strings) else a;
        b = if (b == .NumberString) try b.NumberString.toNumberElem(vm.strings) else b;

        const res = switch (a) {
            .Number => |num1| switch (b) {
                .Number => |num2| Elem.number(num1 * num2),
                else => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        };

        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Multiply expected number or null arguments", .{});
    }
}

fn createDivideValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Divide");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "divideNative", divideNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn divideNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.number(1) else a;
    b = if (b.isConst(.Null)) Elem.number(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a == .NumberString) try a.NumberString.toNumberElem(vm.strings) else a;
        b = if (b == .NumberString) try b.NumberString.toNumberElem(vm.strings) else b;

        if (b.isEql(Elem.number(0), vm.*)) {
            return vm.runtimeError("@Divide denominator is 0", .{});
        }

        const res = switch (a) {
            .Number => |num1| switch (b) {
                .Number => |num2| Elem.number(num1 / num2),
                else => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        };

        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Divide expected number or null arguments", .{});
    }
}

fn createPowerValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Power");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "powerNative", powerNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("A");
    const arg2 = try vm.strings.insert("B");
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg1 });
    try fun.locals.append(vm.allocator, .{ .ValueVar = arg2 });

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn powerNative(vm: *VM) VM.Error!void {
    var b = vm.pop();
    var a = vm.pop();

    a = if (a.isConst(.Null)) Elem.number(1) else a;
    b = if (b.isConst(.Null)) Elem.number(1) else b;

    if (a.isNumber() and b.isNumber()) {
        a = if (a == .NumberString) try a.NumberString.toNumberElem(vm.strings) else a;
        b = if (b == .NumberString) try b.NumberString.toNumberElem(vm.strings) else b;

        const res = switch (a) {
            .Number => |num1| switch (b) {
                .Number => |num2| Elem.number(std.math.pow(f64, num1, num2)),
                else => @panic("Internal Error"),
            },
            else => @panic("Internal Error"),
        };

        return vm.push(res);
    } else if (a.isConst(.Failure) or b.isConst(.Failure)) {
        return vm.pushFailure();
    } else {
        return vm.runtimeError("@Power expected number or null arguments", .{});
    }
}

fn createInputOffset(vm: *VM) !*Function {
    const name = try vm.strings.insert("@input.offset");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "inputOffsetNative", inputOffsetNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn inputOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.number(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.offset)),
    ))));
}

fn createInputLine(vm: *VM) !*Function {
    const name = try vm.strings.insert("@input.line");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "inputLineNative", inputLineNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn inputLineNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.number(@as(f64, @floatFromInt(
        @as(i64, @intCast(vm.inputPos.line)),
    ))));
}

fn createInputLineOffset(vm: *VM) !*Function {
    const name = try vm.strings.insert("@input.line_offset");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
        .region = Region.new(0, 0),
    });

    const native_code = try NativeCode.create(vm, "inputLineOffsetNative", inputLineOffsetNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const loc = Region.new(0, 0);

    try fun.chunk.writeOp(.NativeCode, loc);
    try fun.chunk.write(nc_id, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

fn inputLineOffsetNative(vm: *VM) VM.Error!void {
    return vm.push(Elem.number(
        @as(f64, @floatFromInt(
            @as(i64, @intCast(vm.inputPos.offset - vm.inputPos.line_start)),
        )),
    ));
}

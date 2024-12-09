const std = @import("std");
const unicode = std.unicode;
const Elem = @import("elem.zig").Elem;
const Function = @import("elem.zig").Elem.Dyn.Function;
const NativeCode = @import("elem.zig").Elem.Dyn.NativeCode;
const Location = @import("location.zig").Location;
const VM = @import("vm.zig").VM;
const parsing = @import("parsing.zig");

pub fn functions(vm: *VM) ![8]*Function {
    return [_]*Function{
        try createFailParser(vm),
        try createFailValue(vm),
        try createNumberOfParser(vm),
        try createNumberOfValue(vm),
        try createCrashValue(vm),
        try createCodepointValue(vm),
        try createSurrogatePairCodepointValue(vm),
        try createDbgParser(vm),
    };
}

pub fn createFailParser(vm: *VM) !*Function {
    const name = try vm.strings.insert("@fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
    });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createFailValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Fail");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 0,
    });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createNumberOfParser(vm: *VM) !*Function {
    const name = try vm.strings.insert("@number_of");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 1,
    });

    const argName = try vm.strings.insert("p");
    try fun.locals.append(.{ .ParserVar = argName });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.CallFunction, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NumberOf, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createNumberOfValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@NumberOf");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
    });

    const argName = try vm.strings.insert("V");
    try fun.locals.append(.{ .ValueVar = argName });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.NumberOf, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createCrashValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Crash");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
    });

    const argName = try vm.strings.insert("Message");
    try fun.locals.append(.{ .ValueVar = argName });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.Crash, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createCodepointValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@Codepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 1,
    });

    const native_code = try NativeCode.create(
        vm,
        "stringToCodepointNative",
        stringToCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const argName = try vm.strings.insert("HexString");
    try fun.locals.append(.{ .ValueVar = argName });

    const loc = Location.new(0, 0, 0);

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
                var str = try Elem.Dyn.String.copy(vm, buffer);
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

pub fn createSurrogatePairCodepointValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@SurrogatePairCodepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
    });

    const native_code = try NativeCode.create(
        vm,
        "stringsToSurrogateCodepointNative",
        stringsToSurrogateCodepoint,
    );

    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("HighSurrogate");
    const arg2 = try vm.strings.insert("LowSurrogate");
    try fun.locals.append(.{ .ValueVar = arg1 });
    try fun.locals.append(.{ .ValueVar = arg2 });

    const loc = Location.new(0, 0, 0);

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
                    var str = try Elem.Dyn.String.copy(vm, buffer);
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

pub fn createDbgParser(vm: *VM) !*Function {
    const name = try vm.strings.insert("@dbg");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 1,
    });

    const native_code = try NativeCode.create(vm, "dbgNative", dbgNative);
    const nc_id = try fun.chunk.addConstant(native_code.dyn.elem());

    const arg1 = try vm.strings.insert("p");
    try fun.locals.append(.{ .ParserVar = arg1 });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.CallFunction, loc);
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

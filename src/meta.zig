const std = @import("std");
const Function = @import("elem.zig").Elem.Dyn.Function;
const Location = @import("location.zig").Location;
const VM = @import("vm.zig").VM;

pub fn functions(vm: *VM) ![6]*Function {
    return [_]*Function{
        try createFailParser(vm),
        try createFailValue(vm),
        try createNumberOf(vm),
        try createCrashValue(vm),
        try createCodepointValue(vm),
        try createSurrogatePairCodepointValue(vm),
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

pub fn createNumberOf(vm: *VM) !*Function {
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

    const argName = try vm.strings.insert("HexString");
    try fun.locals.append(.{ .ValueVar = argName });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.StringToCodepoint, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

pub fn createSurrogatePairCodepointValue(vm: *VM) !*Function {
    const name = try vm.strings.insert("@SurrogatePairCodepoint");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedValue,
        .arity = 2,
    });

    const arg1 = try vm.strings.insert("HighSurrogate");
    const arg2 = try vm.strings.insert("LowSurrogate");
    try fun.locals.append(.{ .ValueVar = arg1 });
    try fun.locals.append(.{ .ValueVar = arg2 });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(0, loc);
    try fun.chunk.writeOp(.GetLocal, loc);
    try fun.chunk.write(1, loc);
    try fun.chunk.writeOp(.StringsToCodepoint, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

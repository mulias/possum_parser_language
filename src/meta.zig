const std = @import("std");
const Function = @import("elem.zig").Elem.Dyn.Function;
const Location = @import("location.zig").Location;
const VM = @import("vm.zig").VM;

pub fn functions(vm: *VM) ![3]*Function {
    return [_]*Function{
        try createFail(vm),
        try createNumberOf(vm),
        try createCrashValue(vm),
    };
}

pub fn createFail(vm: *VM) !*Function {
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

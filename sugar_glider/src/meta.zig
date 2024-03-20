const std = @import("std");
const VM = @import("vm.zig").VM;
const Function = @import("elem.zig").Elem.Dyn.Function;
const Location = @import("location.zig").Location;

pub fn functions(vm: *VM) ![3]*Function {
    return [3]*Function{
        try createSucceed(vm),
        try createFail(vm),
        try createNumberOf(vm),
    };
}

pub fn createSucceed(vm: *VM) !*Function {
    const name = try vm.strings.insert("@succeed");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedParser,
        .arity = 0,
    });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.Succeed, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
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

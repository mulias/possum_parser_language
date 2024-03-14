const std = @import("std");
const VM = @import("vm.zig").VM;
const Function = @import("elem.zig").Elem.Dyn.Function;
const Location = @import("location.zig").Location;

pub fn functions(vm: *VM) ![2]*Function {
    return [2]*Function{
        try createSucceed(vm),
        try createFail(vm),
    };
}

pub fn createSucceed(vm: *VM) !*Function {
    const name = try vm.strings.insert("@succeed");
    var fun = try Function.create(vm, .{
        .name = name,
        .functionType = .NamedFunction,
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
        .functionType = .NamedFunction,
        .arity = 0,
    });

    const loc = Location.new(0, 0, 0);

    try fun.chunk.writeOp(.Fail, loc);
    try fun.chunk.writeOp(.End, loc);

    return fun;
}

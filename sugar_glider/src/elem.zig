const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Chunk = @import("./chunk.zig").Chunk;
const StringArrayHashMap = std.StringArrayHashMap;
const StringBuffer = @import("string_buffer.zig").StringBuffer;
const StringTable = @import("string_table.zig").StringTable;
const Tuple = std.meta.Tuple;
const VM = @import("vm.zig").VM;
const logger = @import("logger.zig");

pub const ElemType = enum {
    ParserVar,
    ValueVar,
    Character,
    String,
    Integer,
    Float,
    IntegerString,
    FloatString,
    CharacterRange,
    IntegerRange,
    True,
    False,
    Null,
    Dyn,
};

pub const Elem = union(ElemType) {
    ParserVar: StringTable.Id,
    ValueVar: StringTable.Id,
    Character: u8,
    String: StringTable.Id,
    Integer: i64,
    Float: f64,
    IntegerString: struct { value: i64, sId: StringTable.Id },
    FloatString: struct { value: f64, sId: StringTable.Id },
    CharacterRange: Tuple(&.{ u8, u8 }),
    IntegerRange: Tuple(&.{ i64, i64 }),
    True: void,
    False: void,
    Null: void,
    Dyn: *Dyn,

    pub fn parserVar(sId: StringTable.Id) Elem {
        return Elem{ .ParserVar = sId };
    }

    pub fn valueVar(sId: StringTable.Id) Elem {
        return Elem{ .ValueVar = sId };
    }

    pub fn character(c: u8) Elem {
        return Elem{ .Character = c };
    }

    pub fn string(sId: StringTable.Id) Elem {
        return Elem{ .String = sId };
    }

    pub fn integer(value: i64) Elem {
        return Elem{ .Integer = value };
    }

    pub fn float(value: f64) Elem {
        return Elem{ .Float = value };
    }

    pub fn integerString(value: i64, sId: StringTable.Id) Elem {
        return Elem{ .IntegerString = .{ .value = value, .sId = sId } };
    }

    pub fn floatString(value: f64, sId: StringTable.Id) Elem {
        return Elem{ .FloatString = .{ .value = value, .sId = sId } };
    }

    pub fn characterRange(low: u8, high: u8) Elem {
        return Elem{ .CharacterRange = .{ low, high } };
    }

    pub fn integerRange(low: i64, high: i64) Elem {
        return Elem{ .IntegerRange = .{ low, high } };
    }

    pub const trueConst = Elem{ .True = undefined };

    pub const falseConst = Elem{ .False = undefined };

    pub const nullConst = Elem{ .Null = undefined };

    pub fn print(self: Elem, printer: anytype, strings: StringTable) void {
        switch (self) {
            .ParserVar => |sId| printer("{s}", .{strings.get(sId)}),
            .ValueVar => |sId| printer("{s}", .{strings.get(sId)}),
            .Character => |c| printer("\"{c}\"", .{c}),
            .String => |sId| printer("\"{s}\"", .{strings.get(sId)}),
            .Integer => |n| printer("{d}", .{n}),
            .Float => |n| printer("{d}", .{n}),
            .IntegerString => |n| printer("{s}", .{strings.get(n.sId)}),
            .FloatString => |n| printer("{s}", .{strings.get(n.sId)}),
            .CharacterRange => |r| printer("\"{c}\"..\"{c}\"", .{ r[0], r[1] }),
            .IntegerRange => |r| printer("{d}..{d}", .{ r[0], r[1] }),
            .True => printer("true", .{}),
            .False => printer("false", .{}),
            .Null => printer("null", .{}),
            .Dyn => |d| d.print(printer, strings),
        }
    }

    pub fn isType(self: Elem, elemType: ElemType) bool {
        return std.mem.eql(u8, @tagName(self), @tagName(elemType));
    }

    pub fn isDynType(self: Elem, dynType: DynType) bool {
        return switch (self) {
            .Dyn => |d| d.isType(dynType),
            else => false,
        };
    }

    pub fn asDyn(self: Elem) *Dyn {
        return switch (self) {
            .Dyn => |d| return d,
            else => @panic("internal error"),
        };
    }

    pub fn isEql(self: Elem, other: Elem, strings: StringTable) bool {
        return switch (self) {
            .ParserVar => |sId1| switch (other) {
                .ParserVar => |sId2| sId1 == sId2,
                else => false,
            },
            .ValueVar => |sId1| switch (other) {
                .ValueVar => |sId2| sId1 == sId2,
                else => false,
            },
            .Character => |c1| switch (other) {
                .Character => |c2| c1 == c2,
                .String => |sId2| {
                    const s2 = strings.get(sId2);
                    return s2.len == 1 and c1 == s2[0];
                },
                .Dyn => |d2| {
                    if (d2.isType(.String)) {
                        const ds2 = d2.asString();
                        return ds2.len() == 1 and c1 == ds2.bytes()[0];
                    }
                    return false;
                },
                else => false,
            },
            .String => |sId1| switch (other) {
                .Character => |c2| {
                    const s1 = strings.get(sId1);
                    return s1.len == 1 and s1[0] == c2;
                },
                .String => |sId2| sId1 == sId2,
                .Dyn => |d2| {
                    if (d2.isType(.String)) {
                        const s1 = strings.get(sId1);
                        const s2 = d2.asString().bytes();
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                else => false,
            },
            .Integer => |n1| switch (other) {
                .Integer => |n2| n1 == n2,
                .Float => |n2| @as(f64, @floatFromInt(n1)) == n2,
                .IntegerString => |n2| n1 == n2.value,
                .FloatString => |n2| @as(f64, @floatFromInt(n1)) == n2.value,
                else => false,
            },
            .Float => |n1| switch (other) {
                .Integer => |n2| n1 == @as(f64, @floatFromInt(n2)),
                .Float => |n2| n1 == n2,
                .IntegerString => |n2| n1 == @as(f64, @floatFromInt(n2.value)),
                .FloatString => |n2| n1 == n2.value,
                else => false,
            },
            .IntegerString => |n1| switch (other) {
                .Integer => |n2| n1.value == n2,
                .Float => |n2| @as(f64, @floatFromInt(n1.value)) == n2,
                .IntegerString => |n2| n1.value == n2.value,
                .FloatString => |n2| @as(f64, @floatFromInt(n1.value)) == n2.value,
                else => false,
            },
            .FloatString => |n1| switch (other) {
                .Integer => |n2| n1.value == @as(f64, @floatFromInt(n2)),
                .Float => |n2| n1.value == n2,
                .IntegerString => |n2| n1.value == @as(f64, @floatFromInt(n2.value)),
                .FloatString => |n2| n1.value == n2.value,
                else => false,
            },
            .IntegerRange => |r1| switch (other) {
                .IntegerRange => |r2| r1[0] == r2[0] and r1[1] == r2[1],
                else => false,
            },
            .CharacterRange => |r1| switch (other) {
                .CharacterRange => |r2| r1[0] == r2[0] and r1[1] == r2[1],
                else => false,
            },
            .True => switch (other) {
                .True => true,
                else => false,
            },
            .False => switch (other) {
                .False => true,
                else => false,
            },
            .Null => switch (other) {
                .Null => true,
                else => false,
            },
            .Dyn => |d1| switch (other) {
                .Character => |c2| {
                    if (d1.isType(.String)) {
                        const ds1 = d1.asString();
                        return ds1.len() == 1 and ds1.bytes()[0] == c2;
                    }
                    return false;
                },
                .String => |sId2| {
                    if (d1.isType(.String)) {
                        const s1 = d1.asString().bytes();
                        const s2 = strings.get(sId2);
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                .Dyn => |d2| d1.isEql(d2, strings),
                else => false,
            },
        };
    }

    pub fn merge(elemA: Elem, elemB: Elem, vm: *VM) !?Elem {
        return switch (elemA) {
            .ParserVar => @panic("Attempted to merge an unresolved parser variable, this should never happen."),
            .ValueVar => @panic("Attempted to merge an unresolved value variable, this should never happen."),
            .Character => |c1| switch (elemB) {
                .Character => |c2| {
                    const s = try Elem.Dyn.String.create(vm, 2);
                    try s.concatByte(c1);
                    try s.concatByte(c2);
                    return s.dyn.elem();
                },
                .String => |sId2| {
                    const s2 = vm.strings.get(sId2);
                    const s = try Elem.Dyn.String.create(vm, 1 + s2.len);
                    try s.concatByte(c1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .Dyn => |d| switch (d.dynType) {
                    .String => {
                        const ds2 = d.asString();
                        const s = try Elem.Dyn.String.create(vm, 1 + ds2.buffer.size);
                        try s.concatByte(c1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .String => |sId1| switch (elemB) {
                .Character => |c2| {
                    const s1 = vm.strings.get(sId1);
                    const s = try Elem.Dyn.String.create(vm, s1.len + 1);
                    try s.concatBytes(s1);
                    try s.concatByte(c2);
                    return s.dyn.elem();
                },
                .String => |sId2| {
                    const s1 = vm.strings.get(sId1);
                    const s2 = vm.strings.get(sId2);
                    const s = try Elem.Dyn.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .Dyn => |d| switch (d.dynType) {
                    .String => {
                        const s1 = vm.strings.get(sId1);
                        const ds2 = d.asString();
                        const s = try Elem.Dyn.String.create(vm, s1.len + ds2.buffer.size);
                        try s.concatBytes(s1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .Integer => |n1| switch (elemB) {
                .Integer => |n2| integer(n1 + n2),
                .Float => |n2| float(@as(f64, @floatFromInt(n1)) + n2),
                .IntegerString => |n2| integer(n1 + n2.value),
                .FloatString => |n2| float(@as(f64, @floatFromInt(n1)) + n2.value),
                else => null,
            },
            .Float => |n1| switch (elemB) {
                .Integer => |n2| float(n1 + @as(f64, @floatFromInt(n2))),
                .Float => |n2| float(n1 + n2),
                .IntegerString => |n2| float(n1 + @as(f64, @floatFromInt(n2.value))),
                .FloatString => |n2| float(n1 + n2.value),
                else => null,
            },
            .IntegerString => |n1| switch (elemB) {
                .Integer => |n2| integer(n1.value + n2),
                .Float => |n2| float(@as(f64, @floatFromInt(n1.value)) + n2),
                .IntegerString => |n2| integer(n1.value + n2.value),
                .FloatString => |n2| float(@as(f64, @floatFromInt(n1.value)) + n2.value),
                else => null,
            },
            .FloatString => |n1| switch (elemB) {
                .Integer => |n2| float(n1.value + @as(f64, @floatFromInt(n2))),
                .Float => |n2| float(n1.value + n2),
                .IntegerString => |n2| float(n1.value + @as(f64, @floatFromInt(n2.value))),
                .FloatString => |n2| float(n1.value + n2.value),
                else => null,
            },
            .CharacterRange => unreachable,
            .IntegerRange => unreachable,
            .True => if (elemB.isType(.True)) elemA else null,
            .False => if (elemB.isType(.False)) elemA else null,
            .Null => if (elemB.isType(.Null)) elemA else null,
            .Dyn => |d1| switch (d1.dynType) {
                .String => {
                    const ds1 = d1.asString();
                    return switch (elemB) {
                        .Character => |c2| {
                            try ds1.concatByte(c2);
                            return ds1.dyn.elem();
                        },
                        .String => |sId2| {
                            const s2 = vm.strings.get(sId2);
                            try ds1.concatBytes(s2);
                            return ds1.dyn.elem();
                        },
                        .Dyn => |d2| switch (d2.dynType) {
                            .String => {
                                const ds2 = d2.asString();
                                try ds1.concat(ds2);
                                return ds1.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Array => {
                    const a1 = d1.asArray();
                    return switch (elemB) {
                        .Dyn => |d2| switch (d2.dynType) {
                            .Array => {
                                const a2 = d2.asArray();
                                const a = try Elem.Dyn.Array.create(vm, a1.elems.items.len + a2.elems.items.len);
                                try a.concat(a1);
                                try a.concat(a2);
                                return a.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Object => {
                    const o1 = d1.asObject();
                    return switch (elemB) {
                        .Dyn => |d2| switch (d2.dynType) {
                            .Object => {
                                const o2 = d2.asObject();
                                const o = try Elem.Dyn.Object.create(vm, o1.members.count() + o2.members.count());
                                try o.concat(o1);
                                try o.concat(o2);
                                return o.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Function => unreachable,
            },
        };
    }

    pub const DynType = enum {
        String,
        Array,
        Object,
        Function,
    };

    pub const Dyn = struct {
        dynType: DynType,
        next: ?*Dyn,

        pub fn allocate(vm: *VM, comptime T: type, dynType: DynType) !*Dyn {
            const ptr = try vm.allocator.create(T);

            ptr.dyn = Dyn{
                .dynType = dynType,
                .next = vm.dynList,
            };

            vm.dynList = &ptr.dyn;
            return &ptr.dyn;
        }

        pub fn destroy(self: *Dyn, vm: *VM) void {
            switch (self.dynType) {
                .String => self.asString().destroy(vm),
                .Array => self.asArray().destroy(vm),
                .Object => self.asObject().destroy(vm),
                .Function => self.asFunction().destroy(vm),
            }
        }

        pub fn elem(self: *Dyn) Elem {
            return Elem{ .Dyn = self };
        }

        pub fn print(self: *Dyn, printer: anytype, strings: StringTable) void {
            switch (self.dynType) {
                .String => self.asString().print(printer),
                .Array => self.asArray().print(printer, strings),
                .Object => self.asObject().print(printer, strings),
                .Function => self.asFunction().print(printer, strings),
            }
        }

        pub fn isEql(self: *Dyn, other: *Dyn, strings: StringTable) bool {
            return switch (self.dynType) {
                .String => self.asString().isEql(other),
                .Array => self.asArray().isEql(other, strings),
                .Object => self.asObject().isEql(other, strings),
                .Function => self.asFunction().isEql(other),
            };
        }

        pub fn isType(self: *Dyn, dynType: DynType) bool {
            return self.dynType == dynType;
        }

        pub fn asString(self: *Dyn) *String {
            return @fieldParentPtr(String, "dyn", self);
        }

        pub fn asArray(self: *Dyn) *Array {
            return @fieldParentPtr(Array, "dyn", self);
        }

        pub fn asObject(self: *Dyn) *Object {
            return @fieldParentPtr(Object, "dyn", self);
        }

        pub fn asFunction(self: *Dyn) *Function {
            return @fieldParentPtr(Function, "dyn", self);
        }

        pub const String = struct {
            dyn: Dyn,
            buffer: StringBuffer,

            pub fn copy(vm: *VM, source: []const u8) !*String {
                const str = try create(vm, source.len);
                try str.concatBytes(source);
                return str;
            }

            pub fn create(vm: *VM, size: usize) !*String {
                const dyn = try Dyn.allocate(vm, String, .String);
                const str = dyn.asString();
                var buffer = StringBuffer.init(vm.allocator);
                try buffer.allocate(size);

                str.* = String{
                    .dyn = dyn.*,
                    .buffer = buffer,
                };

                return str;
            }

            pub fn destroy(self: *String, vm: *VM) void {
                self.buffer.deinit();
                vm.allocator.destroy(self);
            }

            pub fn print(self: *String, printer: anytype) void {
                printer("\"{s}\"", .{self.buffer.str()});
            }

            pub fn isEql(self: *String, other: *Dyn) bool {
                return other.isType(.String) and std.mem.eql(
                    u8,
                    self.buffer.str(),
                    other.asString().buffer.str(),
                );
            }

            pub fn concat(self: *String, other: *String) !void {
                try self.buffer.concat(other.buffer.str());
            }

            pub fn concatByte(self: *String, other: u8) !void {
                try self.buffer.concat(&[_]u8{other});
            }

            pub fn concatBytes(self: *String, other: []const u8) !void {
                try self.buffer.concat(other);
            }

            pub fn len(self: *String) usize {
                return self.buffer.size;
            }

            pub fn bytes(self: *String) []const u8 {
                return self.buffer.str();
            }
        };

        pub const Array = struct {
            dyn: Dyn,
            elems: ArrayList(Elem),

            pub fn create(vm: *VM, capacity: usize) !*Array {
                const dyn = try Dyn.allocate(vm, Array, .Array);
                const array = dyn.asArray();

                var elems = ArrayList(Elem).init(vm.allocator);
                try elems.ensureTotalCapacity(capacity);

                array.* = Array{
                    .dyn = dyn.*,
                    .elems = elems,
                };

                return array;
            }

            pub fn destroy(self: *Array, vm: *VM) void {
                self.elems.deinit();
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Array, printer: anytype, strings: StringTable) void {
                printer("[", .{});
                for (self.elems.items) |e| {
                    e.print(printer, strings);
                    printer(",", .{});
                }
                printer("]", .{});
            }

            pub fn isEql(self: *Array, other: *Dyn, strings: StringTable) bool {
                if (!other.isType(.Array)) return false;

                for (self.elems.items, other.asArray().elems.items) |a, b| {
                    if (!a.isEql(b, strings)) return false;
                }

                return true;
            }

            pub fn concat(self: *Array, other: *Array) !void {
                try self.elems.appendSlice(other.elems.items);
            }
        };

        pub const Object = struct {
            dyn: Dyn,
            members: StringArrayHashMap(Elem),

            pub fn create(vm: *VM, capacity: usize) !*Object {
                const dyn = try Dyn.allocate(vm, Array, .Array);
                const object = dyn.asObject();

                var members = StringArrayHashMap(Elem).init(vm.allocator);
                try members.ensureTotalCapacity(capacity);

                object.* = Object{
                    .dyn = dyn.*,
                    .members = members,
                };

                return object;
            }

            pub fn destroy(self: *Object, vm: *VM) void {
                self.members.deinit();
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Object, printer: anytype, strings: StringTable) void {
                printer("{{", .{});
                var iterator = self.members.iterator();
                while (iterator.next()) |entry| {
                    printer("{s}: ", .{entry.key_ptr.*});
                    entry.value_ptr.*.print(printer, strings);
                    printer(",", .{});
                }
                printer("}}", .{});
            }

            pub fn isEql(self: *Object, other: *Dyn, strings: StringTable) bool {
                if (!other.isType(.Object)) return false;

                var otherObject = other.asObject();

                if (self.members.count() != otherObject.members.count()) return false;

                var iterator = self.members.iterator();
                while (iterator.next()) |entry| {
                    if (otherObject.members.get(entry.key_ptr.*)) |otherVal| {
                        if (!entry.value_ptr.*.isEql(otherVal, strings)) return false;
                    } else {
                        return false;
                    }
                }

                return true;
            }

            pub fn concat(self: *Object, other: *Object) !void {
                var iterator = other.members.iterator();
                while (iterator.next()) |entry| {
                    try self.members.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }
        };

        pub const FunctionType = enum { NamedFunction, AnonFunction, Main };

        pub const Function = struct {
            dyn: Dyn,
            arity: u8,
            chunk: Chunk,
            name: StringTable.Id,
            functionType: FunctionType,

            pub fn create(vm: *VM, fields: struct { name: StringTable.Id, functionType: FunctionType, arity: u8 }) !*Function {
                const dyn = try Dyn.allocate(vm, Function, .Function);
                const function = dyn.asFunction();

                function.* = Function{
                    .dyn = dyn.*,
                    .arity = fields.arity,
                    .chunk = Chunk.init(vm.allocator),
                    .name = fields.name,
                    .functionType = fields.functionType,
                };

                return function;
            }

            pub fn destroy(self: *Function, vm: *VM) void {
                self.chunk.deinit();
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Function, printer: anytype, strings: StringTable) void {
                printer("{s}", .{strings.get(self.name)});
            }

            pub fn isEql(self: *Function, other: *Dyn) bool {
                if (!other.isType(.Function)) return false;
                return self == other.asFunction();
            }

            pub fn disassemble(self: *Function, strings: StringTable) void {
                const label = strings.get(self.name);
                self.chunk.disassemble(strings, label);
            }
        };
    };
};

test "struct size" {
    try std.testing.expectEqual(24, @sizeOf(Elem));
    try std.testing.expectEqual(16, @sizeOf(Elem.Dyn));
    try std.testing.expectEqual(56, @sizeOf(Elem.Dyn.String));
}
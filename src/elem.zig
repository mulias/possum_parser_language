const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoArrayHashMap = std.AutoArrayHashMap;
const Tuple = std.meta.Tuple;
const json = std.json;
const unicode = std.unicode;
const Chunk = @import("chunk.zig").Chunk;
const StringBuffer = @import("string_buffer.zig").StringBuffer;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const VMWriter = @import("writer.zig").VMWriter;
const parsing = @import("parsing.zig");

pub const ElemType = enum {
    ParserVar,
    ValueVar,
    String,
    Integer,
    Float,
    CharacterRange,
    IntegerRange,
    Boolean,
    Null,
    Failure,
    Dyn,
};

pub const Elem = union(ElemType) {
    ParserVar: StringTable.Id,
    ValueVar: StringTable.Id,
    String: StringTable.Id,
    Integer: struct { value: i64, sId: ?StringTable.Id },
    Float: struct { value: f64, sId: ?StringTable.Id },
    CharacterRange: struct { low: u21, lowLength: u3, high: u21, highLength: u3 },
    IntegerRange: Tuple(&.{ i64, i64 }),
    Boolean: bool,
    Null: void,
    Failure: void,
    Dyn: *Dyn,

    pub fn parserVar(sId: StringTable.Id) Elem {
        return Elem{ .ParserVar = sId };
    }

    pub fn valueVar(sId: StringTable.Id) Elem {
        return Elem{ .ValueVar = sId };
    }

    pub fn string(sId: StringTable.Id) Elem {
        return Elem{ .String = sId };
    }

    pub fn integer(value: i64, sId: ?StringTable.Id) Elem {
        return Elem{ .Integer = .{ .value = value, .sId = sId } };
    }

    pub fn float(value: f64, sId: ?StringTable.Id) Elem {
        return Elem{ .Float = .{ .value = value, .sId = sId } };
    }

    pub fn characterRange(low: u21, high: u21) !Elem {
        return Elem{ .CharacterRange = .{
            .low = low,
            .lowLength = try unicode.utf8CodepointSequenceLength(low),
            .high = high,
            .highLength = try unicode.utf8CodepointSequenceLength(high),
        } };
    }

    pub fn integerRange(low: i64, high: i64) Elem {
        return Elem{ .IntegerRange = .{ low, high } };
    }

    pub fn boolean(b: bool) Elem {
        return Elem{ .Boolean = b };
    }

    pub const nullConst = Elem{ .Null = undefined };

    pub const failureConst = Elem{ .Failure = undefined };

    pub fn print(self: Elem, writer: VMWriter, strings: StringTable) !void {
        return switch (self) {
            .ParserVar => |sId| try writer.print("{s}", .{strings.get(sId)}),
            .ValueVar => |sId| try writer.print("{s}", .{strings.get(sId)}),
            .String => |sId| try writer.print("\"{s}\"", .{strings.get(sId)}),
            .Integer => |n| if (n.sId) |sId| {
                try writer.print("{s}", .{strings.get(sId)});
            } else {
                try writer.print("{d}", .{n.value});
            },
            .Float => |n| if (n.sId) |sId| {
                try writer.print("{s}", .{strings.get(sId)});
            } else {
                try writer.print("{d}", .{n.value});
            },
            .CharacterRange => |r| try writer.print("\"{u}\"..\"{u}\"", .{ r.low, r.high }),
            .IntegerRange => |r| try writer.print("{d}..{d}", .{ r[0], r[1] }),
            .Boolean => |b| try writer.print("{s}", .{if (b) "true" else "false"}),
            .Null => try writer.print("null", .{}),
            .Failure => try writer.print("@Failure", .{}),
            .Dyn => |d| d.print(writer, strings),
        };
    }

    pub fn isSuccess(self: Elem) bool {
        return self != .Failure;
    }

    pub fn isFailure(self: Elem) bool {
        return self == .Failure;
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
            .String => |sId1| switch (other) {
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
                .Integer => |n2| n1.value == n2.value,
                .Float => |n2| @as(f64, @floatFromInt(n1.value)) == n2.value,
                else => false,
            },
            .Float => |n1| switch (other) {
                .Integer => |n2| n1.value == @as(f64, @floatFromInt(n2.value)),
                .Float => |n2| n1.value == n2.value,
                else => false,
            },
            .IntegerRange => |r1| switch (other) {
                .IntegerRange => |r2| r1[0] == r2[0] and r1[1] == r2[1],
                else => false,
            },
            .CharacterRange => |r1| switch (other) {
                .CharacterRange => |r2| r1.low == r2.low and r1.high == r2.high,
                else => false,
            },
            .Boolean => |b1| switch (other) {
                .Boolean => |b2| b1 == b2,
                else => false,
            },
            .Null => switch (other) {
                .Null => true,
                else => false,
            },
            .Failure => switch (other) {
                .Failure => true,
                else => false,
            },
            .Dyn => |d1| switch (other) {
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

    pub fn isValueMatchingPattern(value: Elem, pattern: Elem, strings: StringTable) bool {
        // If the pattern is an unbound value variable then the match is always
        // successful. After pattern matching we'll go back and bind the var to
        // `value`.
        switch (pattern) {
            .ValueVar => return true,
            else => {},
        }

        return switch (value) {
            .String,
            .Integer,
            .Float,
            .Boolean,
            .Null,
            .Failure,
            => return value.isEql(pattern, strings),
            .ValueVar,
            .ParserVar,
            .IntegerRange,
            .CharacterRange,
            => @panic("Internal error"),
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => return value.isEql(pattern, strings),
                .Array => {
                    if (pattern.isDynType(.Array)) {
                        const valueArray = dyn.asArray();
                        const patternArray = pattern.asDyn().asArray();

                        if (valueArray.elems.items.len != patternArray.elems.items.len) {
                            return false;
                        }

                        for (valueArray.elems.items, patternArray.elems.items) |ve, pe| {
                            if (!ve.isValueMatchingPattern(pe, strings)) {
                                return false;
                            }
                        }

                        return true;
                    } else {
                        return false;
                    }
                },
                .Object => {
                    if (pattern.isDynType(.Object)) {
                        var valueObject = dyn.asObject();
                        var patternObject = pattern.asDyn().asObject();

                        if (valueObject.members.count() != patternObject.members.count()) {
                            return false;
                        }

                        var iterator = valueObject.members.iterator();
                        while (iterator.next()) |valueEntry| {
                            if (patternObject.members.get(valueEntry.key_ptr.*)) |patternMember| {
                                if (!valueEntry.value_ptr.*.isValueMatchingPattern(patternMember, strings)) {
                                    return false;
                                }
                            } else {
                                return false;
                            }
                        }

                        return true;
                    } else {
                        return false;
                    }
                },
                .Function,
                .Closure,
                => @panic("internal error"),
            },
        };
    }

    pub fn merge(elemA: Elem, elemB: Elem, vm: *VM) !?Elem {
        if (elemA == .Failure) return Elem.failureConst;
        if (elemB == .Failure) return Elem.failureConst;
        if (elemA == .Null) return elemB;
        if (elemB == .Null) return elemA;

        return switch (elemA) {
            .ParserVar,
            .ValueVar,
            .Failure,
            .Null,
            => @panic("Internal error"),
            .String => |sId1| switch (elemB) {
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
                .Integer => |n2| integer(n1.value + n2.value, null),
                .Float => |n2| float(@as(f64, @floatFromInt(n1.value)) + n2.value, null),
                else => null,
            },
            .Float => |n1| switch (elemB) {
                .Integer => |n2| float(n1.value + @as(f64, @floatFromInt(n2.value)), null),
                .Float => |n2| float(n1.value + n2.value, null),
                else => null,
            },
            .CharacterRange => unreachable,
            .IntegerRange => unreachable,
            .Boolean => |b1| switch (elemB) {
                .Boolean => |b2| boolean(b1 or b2),
                else => null,
            },
            .Dyn => |d1| switch (d1.dynType) {
                .String => {
                    const ds1 = d1.asString();
                    return switch (elemB) {
                        .String => |sId2| {
                            const s2 = vm.strings.get(sId2);
                            const s = try Elem.Dyn.String.create(vm, ds1.buffer.size + s2.len);
                            try s.concat(ds1);
                            try s.concatBytes(s2);
                            return s.dyn.elem();
                        },
                        .Dyn => |d2| switch (d2.dynType) {
                            .String => {
                                const ds2 = d2.asString();
                                const s = try Elem.Dyn.String.create(vm, ds1.buffer.size + ds2.buffer.size);
                                try s.concat(ds1);
                                try s.concat(ds2);
                                return s.dyn.elem();
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
                .Function,
                .Closure,
                => @panic("Internal error"),
            },
        };
    }

    pub fn negateNumber(elem: Elem) ?Elem {
        if (elem == .Failure) return Elem.failureConst;

        return switch (elem) {
            .ParserVar,
            .ValueVar,
            .Failure,
            => @panic("Internal error"),
            .String => null,
            .Integer => |n| integer(n.value * -1, null),
            .Float => |n| float(n.value * -1, null),
            .Null => integer(0, null),
            else => null,
        };
    }

    pub fn toNumber(self: Elem, strings: *StringTable) !?Elem {
        return switch (self) {
            .String => |sId| {
                const s = strings.get(sId);
                if (parsing.parseInteger(s)) |i| {
                    return Elem.integer(i, sId);
                } else if (parsing.parseFloat(s)) |f| {
                    return Elem.float(f, sId);
                } else {
                    return null;
                }
            },
            .Integer,
            .Float,
            => self,
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => {
                    const s = dyn.asString().buffer.str();
                    if (parsing.parseInteger(s)) |i| {
                        const sId = try strings.insert(s);
                        return Elem.integer(i, sId);
                    } else if (parsing.parseFloat(s)) |f| {
                        const sId = try strings.insert(s);
                        return Elem.float(f, sId);
                    } else {
                        return null;
                    }
                },
                else => null,
            },
            else => null,
        };
    }

    pub fn toJson(self: Elem, allocator: Allocator, strings: StringTable) !json.Value {
        return switch (self) {
            .String => |sId| {
                const s = strings.get(sId);
                return .{ .string = s };
            },
            .Integer => |i| if (i.sId) |sId| {
                const s = strings.get(sId);
                return .{ .number_string = s };
            } else {
                return .{ .integer = i.value };
            },
            .Float => |f| if (f.sId) |sId| {
                const s = strings.get(sId);
                return .{ .number_string = s };
            } else {
                return .{ .float = f.value };
            },
            .Boolean => |b| .{ .bool = b },
            .Null => .{ .null = undefined },
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => {
                    const s = dyn.asString().buffer.str();
                    return .{ .string = s };
                },
                .Array => {
                    const array = dyn.asArray();
                    var jsonArray = ArrayList(json.Value).init(allocator);
                    try jsonArray.ensureTotalCapacity(array.elems.items.len);

                    for (array.elems.items) |item| {
                        try jsonArray.append(try item.toJson(allocator, strings));
                    }

                    return .{ .array = jsonArray };
                },
                .Object => {
                    var object = dyn.asObject();
                    var jsonObject = std.StringArrayHashMap(json.Value).init(allocator);
                    try jsonObject.ensureTotalCapacity(object.members.count());

                    var iterator = object.members.iterator();
                    while (iterator.next()) |entry| {
                        const key = strings.get(entry.key_ptr.*);
                        const value = try entry.value_ptr.*.toJson(allocator, strings);
                        try jsonObject.put(key, value);
                    }

                    return .{ .object = jsonObject };
                },
                .Function,
                .Closure,
                => @panic("Internal Error"),
            },
            .ParserVar,
            .ValueVar,
            .CharacterRange,
            .IntegerRange,
            .Failure,
            => @panic("Internal Error"),
        };
    }

    pub fn writeJson(self: Elem, allocator: Allocator, strings: StringTable, outstream: anytype) !void {
        const j = try self.toJson(allocator, strings);
        try json.stringify(j, .{}, outstream);
    }

    pub fn printJson(self: Elem, opts: json.StringifyOptions, allocator: Allocator, writer: VMWriter, strings: StringTable) !void {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const jsonValue = try self.toJson(arena.allocator(), strings);
        try json.stringify(jsonValue, opts, writer);
    }

    pub const DynType = enum {
        String,
        Array,
        Object,
        Function,
        Closure,
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
                .Closure => self.asClosure().destroy(vm),
            }
        }

        pub fn elem(self: *Dyn) Elem {
            return Elem{ .Dyn = self };
        }

        pub fn print(self: *Dyn, writer: VMWriter, strings: StringTable) !void {
            return switch (self.dynType) {
                .String => self.asString().print(writer),
                .Array => self.asArray().print(writer, strings),
                .Object => self.asObject().print(writer, strings),
                .Function => self.asFunction().print(writer, strings),
                .Closure => self.asClosure().print(writer, strings),
            };
        }

        pub fn isEql(self: *Dyn, other: *Dyn, strings: StringTable) bool {
            return switch (self.dynType) {
                .String => self.asString().isEql(other),
                .Array => self.asArray().isEql(other, strings),
                .Object => self.asObject().isEql(other, strings),
                .Function => self.asFunction().isEql(other),
                .Closure => self.asClosure().isEql(other),
            };
        }

        pub fn isType(self: *Dyn, dynType: DynType) bool {
            return self.dynType == dynType;
        }

        pub fn asString(self: *Dyn) *String {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asArray(self: *Dyn) *Array {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asObject(self: *Dyn) *Object {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asFunction(self: *Dyn) *Function {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asClosure(self: *Dyn) *Closure {
            return @fieldParentPtr("dyn", self);
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

            pub fn print(self: *String, writer: VMWriter) !void {
                try writer.print("\"{s}\"", .{self.buffer.str()});
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

            pub fn copy(vm: *VM, elems: []const Elem) !*Array {
                const a = try create(vm, elems.len);
                try a.elems.appendSlice(elems);
                return a;
            }

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

            pub fn print(self: *Array, writer: VMWriter, strings: StringTable) VMWriter.Error!void {
                if (self.elems.items.len == 0) {
                    try writer.print("[]", .{});
                } else {
                    const lastItemIndex = self.elems.items.len - 1;

                    try writer.print("[", .{});
                    for (self.elems.items[0..lastItemIndex]) |e| {
                        try e.print(writer, strings);
                        try writer.print(", ", .{});
                    }
                    try self.elems.items[lastItemIndex].print(writer, strings);
                    try writer.print("]", .{});
                }
            }

            pub fn isEql(self: *Array, other: *Dyn, strings: StringTable) bool {
                if (!other.isType(.Array)) return false;

                const otherArray = other.asArray();

                if (self.elems.items.len != otherArray.elems.items.len) return false;

                for (self.elems.items, otherArray.elems.items) |a, b| {
                    if (!a.isEql(b, strings)) return false;
                }

                return true;
            }

            pub fn append(self: *Array, item: Elem) !void {
                try self.elems.append(item);
            }

            pub fn concat(self: *Array, other: *Array) !void {
                try self.elems.appendSlice(other.elems.items);
            }

            pub fn len(self: *Array) usize {
                return self.elems.items.len;
            }

            pub fn subarray(self: *Array, vm: *VM, startIndex: usize, length: usize) !*Array {
                std.debug.assert(startIndex + length <= self.len());
                return try copy(vm, self.elems.items[startIndex..(startIndex + length)]);
            }
        };

        pub const Object = struct {
            dyn: Dyn,
            members: AutoArrayHashMap(StringTable.Id, Elem),

            pub fn create(vm: *VM, capacity: usize) !*Object {
                const dyn = try Dyn.allocate(vm, Object, .Object);
                const object = dyn.asObject();

                var members = AutoArrayHashMap(StringTable.Id, Elem).init(vm.allocator);
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

            pub fn print(self: *Object, writer: VMWriter, strings: StringTable) VMWriter.Error!void {
                if (self.members.count() == 0) {
                    try writer.print("{{}}", .{});
                } else {
                    const lastMemberIndex = self.members.count() - 1;

                    try writer.print("{{", .{});
                    var iterator = self.members.iterator();
                    while (iterator.next()) |entry| {
                        try writer.print("\"{s}\": ", .{strings.get(entry.key_ptr.*)});
                        try entry.value_ptr.*.print(writer, strings);

                        if (iterator.index <= lastMemberIndex) {
                            try writer.print(", ", .{});
                        }
                    }
                    try writer.print("}}", .{});
                }
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

        pub const FunctionType = enum {
            AnonParser,
            Main,
            NamedParser,
            NamedValue,
        };

        pub const Function = struct {
            dyn: Dyn,
            arity: u8,
            chunk: Chunk,
            name: StringTable.Id,
            functionType: FunctionType,
            locals: ArrayList(Local),

            pub const Local = union(enum) {
                ParserVar: StringTable.Id,
                ValueVar: StringTable.Id,

                pub fn name(self: Local) StringTable.Id {
                    return switch (self) {
                        .ParserVar => |sId| sId,
                        .ValueVar => |sId| sId,
                    };
                }

                pub fn isParserVar(self: Local) bool {
                    return switch (self) {
                        .ParserVar => true,
                        .ValueVar => false,
                    };
                }
            };

            pub fn create(vm: *VM, fields: struct { name: StringTable.Id, functionType: FunctionType, arity: u8 }) !*Function {
                const dyn = try Dyn.allocate(vm, Function, .Function);
                const function = dyn.asFunction();

                function.* = Function{
                    .dyn = dyn.*,
                    .arity = fields.arity,
                    .chunk = Chunk.init(vm.allocator),
                    .name = fields.name,
                    .functionType = fields.functionType,
                    .locals = ArrayList(Local).init(vm.allocator),
                };

                return function;
            }

            pub fn destroy(self: *Function, vm: *VM) void {
                self.chunk.deinit();
                self.locals.deinit();
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Function, writer: VMWriter, strings: StringTable) !void {
                try writer.print("{s}", .{strings.get(self.name)});
            }

            pub fn isEql(self: *Function, other: *Dyn) bool {
                if (!other.isType(.Function)) return false;
                return self == other.asFunction();
            }

            pub fn disassemble(self: *Function, strings: StringTable, writer: VMWriter) !void {
                const label = strings.get(self.name);
                try self.chunk.disassemble(strings, label, writer);
            }

            pub fn addLocal(self: *Function, local: Local) !?u8 {
                if (self.locals.items.len >= std.math.maxInt(u8)) {
                    return error.MaxFunctionLocals;
                }

                for (self.locals.items) |item| {
                    if (item.name() == local.name()) {
                        return error.VariableNameUsedInScope;
                    }
                }

                try self.locals.append(local);

                return @as(u8, @intCast(self.locals.items.len - 1));
            }

            pub fn localSlot(self: *Function, name: StringTable.Id) ?u8 {
                var i = self.locals.items.len;
                while (i > 0) {
                    i -= 1;

                    if (self.locals.items[i].name() == name) {
                        return @as(u8, @intCast(i));
                    }
                }

                return null;
            }

            pub fn localVar(self: *Function, slot: u8) Local {
                return self.locals.items[@as(usize, @intCast(slot))];
            }
        };

        pub const Closure = struct {
            dyn: Dyn,
            function: *Function,
            captures: []?Elem,

            pub fn create(vm: *VM, function: *Function) !*Closure {
                const dyn = try Dyn.allocate(vm, Closure, .Closure);
                const closure = dyn.asClosure();

                const captures = try vm.allocator.alloc(?Elem, function.locals.items.len);
                @memset(captures, null);

                closure.* = Closure{
                    .dyn = dyn.*,
                    .function = function,
                    .captures = captures,
                };

                return closure;
            }

            pub fn destroy(self: *Closure, vm: *VM) void {
                vm.allocator.free(self.captures);
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Closure, writer: VMWriter, strings: StringTable) VMWriter.Error!void {
                try writer.print("|{s} ", .{strings.get(self.function.name)});

                if (self.captures.len > 0) {
                    const lastItemIndex = self.captures.len - 1;

                    for (self.captures[0..lastItemIndex]) |maybeElem| {
                        if (maybeElem) |e| {
                            try e.print(writer, strings);
                            try writer.print(", ", .{});
                        } else {
                            try writer.print("_, ", .{});
                        }
                    }
                    if (self.captures[lastItemIndex]) |e| {
                        try e.print(writer, strings);
                    } else {
                        try writer.print("_", .{});
                    }
                }

                try writer.print("|", .{});
            }

            pub fn isEql(self: *Closure, other: *Dyn) bool {
                if (!other.isType(.Closure)) return false;
                return self == other.asClosure();
            }

            pub fn capture(self: *Closure, index: usize, local: Elem) void {
                self.captures[index] = local;
            }

            pub fn getCaptured(self: *Closure, name: StringTable.Id) ?Elem {
                if (self.function.localSlot(name)) |slot| {
                    return self.captures[slot];
                }
                return null;
            }
        };
    };
};

test "struct size" {
    try std.testing.expectEqual(24, @sizeOf(Elem));
    try std.testing.expectEqual(16, @sizeOf(Elem.Dyn));
    try std.testing.expectEqual(56, @sizeOf(Elem.Dyn.String));
    try std.testing.expectEqual(56, @sizeOf(Elem.Dyn.Array));
    try std.testing.expectEqual(72, @sizeOf(Elem.Dyn.Object));
    try std.testing.expectEqual(200, @sizeOf(Elem.Dyn.Function));
    try std.testing.expectEqual(40, @sizeOf(Elem.Dyn.Closure));
}

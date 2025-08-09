const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const AutoArrayHashMap = std.AutoArrayHashMapUnmanaged;
const Tuple = std.meta.Tuple;
const json = std.json;
const json_pretty = @import("json_pretty.zig");
const unicode = std.unicode;
const Chunk = @import("chunk.zig").Chunk;
const Module = @import("module.zig").Module;
const Region = @import("region.zig").Region;
const StringBuffer = @import("string_buffer.zig").StringBuffer;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;
const parsing = @import("parsing.zig");

pub const ElemType = enum(u3) {
    ParserVar,
    ValueVar,
    String,
    InputSubstring,
    NumberString,
    Number,
    Const,
    Dyn,
};

pub const Elem = union(ElemType) {
    ParserVar: StringTable.Id,
    ValueVar: StringTable.Id,
    String: StringTable.Id,
    InputSubstring: InputSubstringElem,
    NumberString: NumberStringElem,
    Number: f64,
    Const: ConstElem,
    Dyn: *DynElem,

    pub const InputSubstringElem = struct {
        start: u16,
        offset: u32,

        pub fn new(start: u16, offset: u32) InputSubstringElem {
            return InputSubstringElem{ .start = start, .offset = offset };
        }

        pub fn fromRange(start_pos: usize, end_pos: usize) ?InputSubstringElem {
            const offset = end_pos - start_pos;
            if (start_pos <= std.math.maxInt(u16) and offset <= std.math.maxInt(u32)) {
                return InputSubstringElem.new(@as(u16, @intCast(start_pos)), @as(u32, @intCast(offset)));
            }
            return null;
        }

        pub fn end(self: InputSubstringElem) usize {
            return self.start + self.offset;
        }

        pub fn isContiguous(is1: InputSubstringElem, is2: InputSubstringElem) bool {
            const contiguous12 = is1.start <= is2.end() and is1.end() >= is2.start;
            const contiguous21 = is2.start <= is1.end() and is2.end() >= is1.start;
            return contiguous12 or contiguous21;
        }

        pub fn bytes(self: InputSubstringElem, vm: VM) []const u8 {
            return vm.input[self.start..self.end()];
        }

        pub fn eql(self: InputSubstringElem, other: InputSubstringElem) bool {
            return self.start == other.start and self.offset == other.offset;
        }

        pub fn mergeUnion(is1: InputSubstringElem, is2: InputSubstringElem) ?InputSubstringElem {
            if (is1.isContiguous(is2)) {
                const new_start = @min(is1.start, is2.start);
                const new_end = @max(is1.end(), is2.end());
                const new_offset = @as(usize, @intCast(new_end)) - @as(usize, @intCast(new_start));
                if (new_offset <= std.math.maxInt(u32)) {
                    return InputSubstringElem.new(new_start, @as(u32, @intCast(new_offset)));
                }
            }
            return null;
        }
    };

    pub const NumberStringElem = struct {
        sId: StringTable.Id,
        negated: bool,

        pub fn new(bytes: []const u8, vm: *VM) !NumberStringElem {
            if (bytes[0] == '-') {
                const sId = try vm.strings.insert(bytes);
                return NumberStringElem{ .sId = sId, .negated = true };
            } else {
                var buffer = try vm.allocator.alloc(u8, bytes.len + 1);
                defer vm.allocator.free(buffer);
                buffer[0] = '-';
                @memcpy(buffer[1..], bytes);
                const sId = try vm.strings.insert(buffer);
                return NumberStringElem{ .sId = sId, .negated = false };
            }
        }

        pub fn toString(self: NumberStringElem, strings: StringTable) []const u8 {
            const bs = strings.get(self.sId);
            if (self.negated) {
                return bs;
            } else {
                return bs[1..];
            }
        }

        pub fn negate(self: NumberStringElem) NumberStringElem {
            return NumberStringElem{
                .sId = self.sId,
                .negated = !self.negated,
            };
        }

        pub fn toNumberElem(self: NumberStringElem, strings: StringTable) !Elem {
            const bytes = self.toString(strings);
            const f = std.fmt.parseFloat(f64, bytes) catch |err| switch (err) {
                std.fmt.ParseFloatError.InvalidCharacter => @panic("Internal Error"),
            };
            return Elem.number(f);
        }
    };

    pub const ConstElem = enum { True, False, Null, Failure };

    pub fn parserVar(sId: StringTable.Id) Elem {
        return Elem{ .ParserVar = sId };
    }

    pub fn valueVar(sId: StringTable.Id) Elem {
        return Elem{ .ValueVar = sId };
    }

    pub fn string(sId: StringTable.Id) Elem {
        return Elem{ .String = sId };
    }

    pub fn inputSubstring(start: u16, offset: u32) Elem {
        return Elem{ .InputSubstring = InputSubstringElem.new(start, offset) };
    }

    pub fn inputSubstringFromRange(start: usize, end: usize, vm: *VM) !Elem {
        if (InputSubstringElem.fromRange(start, end)) |substring| {
            return Elem{ .InputSubstring = substring };
        } else {
            const str = try Elem.DynElem.String.copy(vm, vm.input[start..end]);
            return str.dyn.elem();
        }
    }

    pub fn numberString(bytes: []const u8, vm: *VM) !Elem {
        return Elem{ .NumberString = try NumberStringElem.new(bytes, vm) };
    }

    pub fn number(f: f64) Elem {
        return Elem{ .Number = f };
    }

    pub fn boolean(b: bool) Elem {
        return Elem{ .Const = if (b) .True else .False };
    }

    pub const nullConst = Elem{ .Const = .Null };

    pub const failureConst = Elem{ .Const = .Failure };

    pub fn print(self: Elem, vm: VM, writer: anytype) !void {
        // try writer.print("{s} ", .{@tagName(self)});
        return switch (self) {
            .ParserVar => |sid| if (StringTable.asReserved(sid)) |rid| {
                try writer.print("_{d}", .{rid});
            } else {
                try writer.print("{s}", .{vm.strings.get(sid)});
            },
            .ValueVar => |sid| if (StringTable.asReserved(sid)) |rid| {
                try writer.print("_{d}", .{rid});
            } else {
                try writer.print("{s}", .{vm.strings.get(sid)});
            },
            .String => |sid| if (StringTable.asReserved(sid)) |rid| {
                try writer.print("_{d}", .{rid});
            } else {
                try writer.print("\"{s}\"", .{vm.strings.get(sid)});
            },
            .InputSubstring => |is| try writer.print("\"{s}\"", .{is.bytes(vm)}),
            .NumberString => |ns| try writer.print("{s}", .{ns.toString(vm.strings)}),
            .Number => |f| {
                if (@trunc(f) == f and f >= @as(f64, @floatFromInt(std.math.minInt(i64))) and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                    try writer.print("{d}", .{@as(i64, @intFromFloat(f))});
                } else {
                    try writer.print("{d}", .{f});
                }
            },
            .Const => |c| switch (c) {
                .True => try writer.print("true", .{}),
                .False => try writer.print("false", .{}),
                .Null => try writer.print("null", .{}),
                .Failure => try writer.print("@Failure", .{}),
            },
            .Dyn => |d| d.print(vm, writer),
        };
    }

    pub fn isSuccess(self: Elem) bool {
        return self != .Const or self.Const != .Failure;
    }

    pub fn isFailure(self: Elem) bool {
        return self == .Const and self.Const == .Failure;
    }

    pub fn isType(self: Elem, elemType: ElemType) bool {
        return self == elemType;
    }

    pub fn isConst(self: Elem, constType: ConstElem) bool {
        return self == .Const and self.Const == constType;
    }

    pub fn isDynType(self: Elem, dynType: DynType) bool {
        return switch (self) {
            .Dyn => |d| d.isType(dynType),
            else => false,
        };
    }

    pub fn asDyn(self: Elem) *DynElem {
        return switch (self) {
            .Dyn => |d| return d,
            else => @panic("internal error"),
        };
    }

    pub fn isEql(self: Elem, other: Elem, vm: VM) bool {
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
                .InputSubstring => |is2| {
                    const s1 = vm.strings.get(sId1);
                    const s2 = is2.bytes(vm);
                    return std.mem.eql(u8, s1, s2);
                },
                .Dyn => |d2| {
                    if (d2.isType(.String)) {
                        const s1 = vm.strings.get(sId1);
                        const s2 = d2.asString().bytes();
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                else => false,
            },
            .InputSubstring => |is1| switch (other) {
                .String => |sId2| {
                    const s1 = is1.bytes(vm);
                    const s2 = vm.strings.get(sId2);
                    return std.mem.eql(u8, s1, s2);
                },
                .InputSubstring => |is2| {
                    if (is1.eql(is2)) return true;
                    const s1 = is1.bytes(vm);
                    const s2 = is2.bytes(vm);
                    return std.mem.eql(u8, s1, s2);
                },
                .Dyn => |d2| {
                    if (d2.isType(.String)) {
                        const s1 = is1.bytes(vm);
                        const s2 = d2.asString().bytes();
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                else => false,
            },
            .NumberString => |n1| switch (other) {
                .NumberString => |n2| {
                    const elem1 = n1.toNumberElem(vm.strings) catch return false;
                    const elem2 = n2.toNumberElem(vm.strings) catch return false;
                    return isEql(elem1, elem2, vm);
                },
                .Number => {
                    const elem1 = n1.toNumberElem(vm.strings) catch return false;
                    return isEql(elem1, other, vm);
                },
                else => false,
            },
            .Number => |num1| switch (other) {
                .NumberString => |n2| {
                    const elem2 = n2.toNumberElem(vm.strings) catch return false;
                    return isEql(self, elem2, vm);
                },
                .Number => |num2| num1 == num2,
                else => false,
            },
            .Const => |c1| switch (other) {
                .Const => |c2| c1 == c2,
                else => false,
            },
            .Dyn => |d1| switch (other) {
                .String => |sId2| {
                    if (d1.isType(.String)) {
                        const s1 = d1.asString().bytes();
                        const s2 = vm.strings.get(sId2);
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                .InputSubstring => |is2| {
                    if (d1.isType(.String)) {
                        const s1 = d1.asString().bytes();
                        const s2 = is2.bytes(vm);
                        return std.mem.eql(u8, s1, s2);
                    }
                    return false;
                },
                .Dyn => |d2| d1.isEql(d2, vm),
                else => false,
            },
        };
    }

    pub fn isLessThanOrEqualInRangePattern(value: Elem, high: Elem, vm: VM) !bool {
        return switch (value) {
            .ValueVar => true,
            .String,
            .InputSubstring,
            .Dyn,
            => {
                const value_codepoint = value.toCodepoint(vm) orelse return false;

                if (high == .ValueVar) {
                    return true;
                } else {
                    const high_codepoint = high.toCodepoint(vm) orelse return false;
                    return value_codepoint <= high_codepoint;
                }
            },
            .NumberString => |ns| {
                const num = try ns.toNumberElem(vm.strings);
                return num.isLessThanOrEqualInRangePattern(high, vm);
            },
            .Number => |num_value| switch (high) {
                .ValueVar => true,
                .NumberString => |ns| {
                    const highNum = try ns.toNumberElem(vm.strings);
                    return value.isLessThanOrEqualInRangePattern(highNum, vm);
                },
                .Number => |num_high| num_value <= num_high,
                else => false,
            },
            .Const,
            .ParserVar,
            => false,
        };
    }

    fn toCodepoint(elem: Elem, vm: VM) ?u21 {
        if (elem.stringBytes(vm)) |bytes| {
            return unicode.utf8Decode(bytes) catch return null;
        } else {
            return null;
        }
    }

    pub fn merge(elemA: Elem, elemB: Elem, vm: *VM) !?Elem {
        if (elemA.isConst(.Failure)) return Elem.failureConst;
        if (elemB.isConst(.Failure)) return Elem.failureConst;
        if (elemA.isConst(.Null)) return elemB;
        if (elemB.isConst(.Null)) return elemA;

        return switch (elemA) {
            .String => |sId1| switch (elemB) {
                .String => |sId2| {
                    const s1 = vm.strings.get(sId1);
                    const s2 = vm.strings.get(sId2);
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .InputSubstring => |is2| {
                    const s1 = vm.strings.get(sId1);
                    const s2 = is2.bytes(vm.*);
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .Dyn => |d| switch (d.dynType) {
                    .String => {
                        const s1 = vm.strings.get(sId1);
                        const ds2 = d.asString();
                        const s = try Elem.DynElem.String.create(vm, s1.len + ds2.buffer.size);
                        try s.concatBytes(s1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .InputSubstring => |is1| switch (elemB) {
                .String => |sId2| {
                    const s1 = is1.bytes(vm.*);
                    const s2 = vm.strings.get(sId2);
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .InputSubstring => |is2| {
                    if (is1.mergeUnion(is2)) |merged| {
                        return Elem{ .InputSubstring = merged };
                    } else {
                        const s1 = is1.bytes(vm.*);
                        const s2 = is2.bytes(vm.*);
                        const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                        try s.concatBytes(s1);
                        try s.concatBytes(s2);
                        return s.dyn.elem();
                    }
                },
                .Dyn => |d| switch (d.dynType) {
                    .String => {
                        const s1 = is1.bytes(vm.*);
                        const ds2 = d.asString();
                        const s = try Elem.DynElem.String.create(vm, s1.len + ds2.buffer.size);
                        try s.concatBytes(s1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .NumberString => |n1| {
                if (elemB.isZero(vm)) {
                    return elemA;
                } else {
                    const elem1 = try n1.toNumberElem(vm.strings);
                    return merge(elem1, elemB, vm);
                }
            },
            .Number => |num1| switch (elemB) {
                .NumberString => |n2| {
                    if (elemA.isZero(vm)) {
                        return elemB;
                    } else {
                        const elem2 = try n2.toNumberElem(vm.strings);
                        return merge(elemA, elem2, vm);
                    }
                },
                .Number => |num2| number(num1 + num2),
                else => null,
            },
            .Const => |c1| switch (c1) {
                .True, .False => switch (elemB) {
                    .Const => |c2| switch (c2) {
                        .True, .False => boolean((c1 == .True) or (c2 == .True)),
                        else => null,
                    },
                    else => null,
                },
                else => null,
            },
            .ParserVar,
            .ValueVar,
            => @panic("Internal error"),
            .Dyn => |d1| switch (d1.dynType) {
                .String => {
                    const ds1 = d1.asString();
                    return switch (elemB) {
                        .String => |sId2| {
                            const s2 = vm.strings.get(sId2);
                            const s = try Elem.DynElem.String.create(vm, ds1.buffer.size + s2.len);
                            try s.concat(ds1);
                            try s.concatBytes(s2);
                            return s.dyn.elem();
                        },
                        .InputSubstring => |is2| {
                            const s2 = is2.bytes(vm.*);
                            const s = try Elem.DynElem.String.create(vm, ds1.buffer.size + s2.len);
                            try s.concat(ds1);
                            try s.concatBytes(s2);
                            return s.dyn.elem();
                        },
                        .Dyn => |d2| switch (d2.dynType) {
                            .String => {
                                const ds2 = d2.asString();
                                const s = try Elem.DynElem.String.create(vm, ds1.buffer.size + ds2.buffer.size);
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
                                const a = try Elem.DynElem.Array.create(vm, a1.elems.items.len + a2.elems.items.len);
                                try a.concat(vm.allocator, a1);
                                try a.concat(vm.allocator, a2);
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
                                const o = try Elem.DynElem.Object.create(vm, o1.members.count() + o2.members.count());
                                try o.concat(vm.allocator, o1);
                                try o.concat(vm.allocator, o2);
                                return o.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Function,
                .NativeCode,
                .Closure,
                => @panic("Internal error"),
            },
        };
    }

    pub fn isNumber(elem: Elem) bool {
        return elem == .Number or elem == .NumberString;
    }

    pub fn negateNumber(elem: Elem) !Elem {
        return switch (elem) {
            .ParserVar,
            => @panic("Internal error"),
            .Const => |c| switch (c) {
                .Failure => elem,
                .Null => number(0),
                .True, .False => error.ExpectedNumber,
            },
            .NumberString => |n| Elem{ .NumberString = n.negate() },
            .Number => |f| number(f * -1),
            else => error.ExpectedNumber,
        };
    }

    pub fn toNumber(self: Elem, vm: *VM) !?Elem {
        const bytes = switch (self) {
            .NumberString,
            .Number,
            => return self,
            .String => |sId| vm.strings.get(sId),
            .InputSubstring => |is| vm.input[is[0]..is[1]],
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => dyn.asString().buffer.str(),
                else => return null,
            },
            else => return null,
        };

        if (parsing.isValidNumberString(bytes)) {
            return try Elem.numberString(bytes, vm);
        } else {
            return null;
        }
    }

    pub fn isZero(self: Elem, vm: *VM) bool {
        return switch (self) {
            .NumberString => |ns| {
                const n = ns.toNumberElem(vm.strings) catch return false;
                return n.isZero(vm);
            },
            .Number => |f| f == 0,
            else => false,
        };
    }

    pub fn toString(self: Elem, vm: *VM) !Elem {
        if (self.isType(.String) or self.isType(.InputSubstring) or self.isDynType(.String)) {
            return self;
        } else {
            var bytes = ArrayList(u8){};
            try self.writeJson(.Compact, vm.*, bytes.writer(vm.allocator));
            defer bytes.deinit(vm.allocator);

            const s = try Elem.DynElem.String.copy(vm, bytes.items);
            return s.dyn.elem();
        }
    }

    pub fn stringBytes(elem: Elem, vm: VM) ?[]const u8 {
        return switch (elem) {
            .String => |sId| vm.strings.get(sId),
            .InputSubstring => |is| is.bytes(vm),
            .Dyn => |d| switch (d.dynType) {
                .String => d.asString().buffer.str(),
                else => null,
            },
            else => null,
        };
    }

    pub fn getOrPutSid(elem: Elem, vm: *VM) !?StringTable.Id {
        switch (elem) {
            .String => |sid| return sid,
            else => {
                if (elem.stringBytes(vm.*)) |bytes| {
                    return try vm.strings.insert(bytes);
                } else {
                    return null;
                }
            },
        }
    }

    pub fn toJson(self: Elem, vm: VM) !json.Value {
        return switch (self) {
            .String => |sId| {
                const s = vm.strings.get(sId);
                return .{ .string = s };
            },
            .InputSubstring => |is| {
                const s = is.bytes(vm);
                return .{ .string = s };
            },
            .NumberString => |n| {
                return .{ .number_string = n.toString(vm.strings) };
            },
            .Number => |f| {
                if (@trunc(f) == f and f >= @as(f64, @floatFromInt(std.math.minInt(i64))) and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                    return .{ .integer = @as(i64, @intFromFloat(f)) };
                } else {
                    return .{ .float = f };
                }
            },
            .Const => |c| switch (c) {
                .True => .{ .bool = true },
                .False => .{ .bool = false },
                .Null => .{ .null = undefined },
                .Failure => @panic("Internal Error"),
            },
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => {
                    const s = dyn.asString().buffer.str();
                    return .{ .string = s };
                },
                .Array => {
                    const array = dyn.asArray();
                    var jsonArray = json.Array.init(vm.allocator);
                    try jsonArray.ensureTotalCapacity(array.elems.items.len);

                    for (array.elems.items) |item| {
                        try jsonArray.append(try item.toJson(vm));
                    }

                    return .{ .array = jsonArray };
                },
                .Object => {
                    var object = dyn.asObject();
                    var jsonObject = json.ObjectMap.init(vm.allocator);
                    try jsonObject.ensureTotalCapacity(object.members.count());

                    var iterator = object.members.iterator();
                    while (iterator.next()) |entry| {
                        const key = vm.strings.get(entry.key_ptr.*);
                        const value = try entry.value_ptr.*.toJson(vm);
                        try jsonObject.put(key, value);
                    }

                    return .{ .object = jsonObject };
                },
                .Function,
                .NativeCode,
                .Closure,
                => @panic("Internal Error"),
            },
            .ParserVar,
            .ValueVar,
            => @panic("Internal Error"),
        };
    }

    pub fn writeJson(self: Elem, format: json_pretty.Format, vm: VM, outstream: anytype) !void {
        var arena = std.heap.ArenaAllocator.init(vm.allocator);
        defer arena.deinit();

        const j = try self.toJson(vm);
        try json_pretty.stringify(j, format, outstream);
    }

    pub fn fromJson(value: json.Value, vm: *VM) !Elem {
        return switch (value) {
            .null => Elem.nullConst,
            .bool => |b| Elem.boolean(b),
            .integer => |i| Elem.number(@as(f64, @floatFromInt(i))),
            .float => |f| Elem.number(f),
            .number_string => |number_bytes| {
                if (parsing.isValidNumberString(number_bytes)) {
                    return Elem.numberString(number_bytes, vm);
                } else {
                    @panic("Internal Error");
                }
            },
            .string => |s| (try Elem.DynElem.String.copy(vm, s)).dyn.elem(),
            .array => |a| {
                const array = try Elem.DynElem.Array.create(vm, a.items.len);
                for (a.items) |array_value| {
                    try array.append(vm.allocator, try fromJson(array_value, vm));
                }
                return array.dyn.elem();
            },
            .object => |o| {
                const obj = try Elem.DynElem.Object.create(vm, o.count());
                var iterator = o.iterator();
                while (iterator.next()) |entry| {
                    const elem_key = try vm.strings.insert(entry.key_ptr.*);
                    const elem_value = try fromJson(entry.value_ptr.*, vm);
                    try obj.members.put(vm.allocator, elem_key, elem_value);
                }
                return obj.dyn.elem();
            },
        };
    }

    pub const DynType = enum {
        String,
        Array,
        Object,
        Function,
        NativeCode,
        Closure,
    };

    pub const DynElem = struct {
        id: u64,
        dynType: DynType,
        next: ?*DynElem,

        pub fn allocate(vm: *VM, comptime T: type, dynType: DynType) !*DynElem {
            const ptr = try vm.allocator.create(T);
            const id = vm.nextUniqueId();

            ptr.dyn = DynElem{
                .id = id,
                .dynType = dynType,
                .next = vm.dynList,
            };

            vm.dynList = &ptr.dyn;
            return &ptr.dyn;
        }

        pub fn destroy(self: *DynElem, vm: *VM) void {
            switch (self.dynType) {
                .String => self.asString().destroy(vm),
                .Array => self.asArray().destroy(vm),
                .Object => self.asObject().destroy(vm),
                .Function => self.asFunction().destroy(vm),
                .NativeCode => self.asNativeCode().destroy(vm),
                .Closure => self.asClosure().destroy(vm),
            }
        }

        pub fn elem(self: *DynElem) Elem {
            return Elem{ .Dyn = self };
        }

        pub fn print(self: *DynElem, vm: VM, writer: anytype) !void {
            return switch (self.dynType) {
                .String => self.asString().print(writer),
                .Array => self.asArray().print(vm, writer),
                .Object => self.asObject().print(vm, writer),
                .Function => self.asFunction().print(vm, writer),
                .NativeCode => self.asNativeCode().print(writer),
                .Closure => self.asClosure().print(vm, writer),
            };
        }

        pub fn isEql(self: *DynElem, other: *DynElem, vm: VM) bool {
            return switch (self.dynType) {
                .String => self.asString().isEql(other),
                .Array => self.asArray().isEql(other, vm),
                .Object => self.asObject().isEql(other, vm),
                .Function => self.asFunction().isEql(other),
                .NativeCode => self.asNativeCode().isEql(other),
                .Closure => self.asClosure().isEql(other),
            };
        }

        pub fn isType(self: *DynElem, dynType: DynType) bool {
            return self.dynType == dynType;
        }

        pub fn asString(self: *DynElem) *String {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asArray(self: *DynElem) *Array {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asObject(self: *DynElem) *Object {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asFunction(self: *DynElem) *Function {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asNativeCode(self: *DynElem) *NativeCode {
            return @fieldParentPtr("dyn", self);
        }

        pub fn asClosure(self: *DynElem) *Closure {
            return @fieldParentPtr("dyn", self);
        }

        pub const String = struct {
            dyn: DynElem,
            buffer: StringBuffer,

            pub fn copy(vm: *VM, source: []const u8) !*String {
                const str = try create(vm, source.len);
                try str.concatBytes(source);
                return str;
            }

            pub fn create(vm: *VM, size: usize) !*String {
                const dyn = try DynElem.allocate(vm, String, .String);
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

            pub fn print(self: *String, writer: anytype) !void {
                try writer.print("\"{s}\"", .{self.buffer.str()});
            }

            pub fn isEql(self: *String, other: *DynElem) bool {
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
            dyn: DynElem,
            elems: ArrayList(Elem),

            pub fn copy(vm: *VM, elems: []const Elem) !*Array {
                const a = try create(vm, elems.len);
                try a.elems.appendSlice(vm.allocator, elems);
                return a;
            }

            pub fn create(vm: *VM, capacity: usize) !*Array {
                const dyn = try DynElem.allocate(vm, Array, .Array);
                const array = dyn.asArray();

                var elems = ArrayList(Elem){};
                try elems.ensureTotalCapacity(vm.allocator, capacity);

                array.* = Array{
                    .dyn = dyn.*,
                    .elems = elems,
                };

                return array;
            }

            pub fn destroy(self: *Array, vm: *VM) void {
                self.elems.deinit(vm.allocator);
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Array, vm: VM, writer: anytype) @TypeOf(writer).Error!void {
                if (self.elems.items.len == 0) {
                    try writer.print("[]", .{});
                } else {
                    const lastItemIndex = self.elems.items.len - 1;

                    try writer.print("[", .{});
                    for (self.elems.items[0..lastItemIndex]) |e| {
                        try e.print(vm, writer);
                        try writer.print(", ", .{});
                    }
                    try self.elems.items[lastItemIndex].print(vm, writer);
                    try writer.print("]", .{});
                }
            }

            pub fn isEql(self: *Array, other: *DynElem, vm: VM) bool {
                if (!other.isType(.Array)) return false;

                const otherArray = other.asArray();

                if (self.elems.items.len != otherArray.elems.items.len) return false;

                for (self.elems.items, otherArray.elems.items) |a, b| {
                    if (!a.isEql(b, vm)) return false;
                }

                return true;
            }

            pub fn append(self: *Array, allocator: Allocator, item: Elem) !void {
                try self.elems.append(allocator, item);
            }

            pub fn concat(self: *Array, allocator: Allocator, other: *Array) !void {
                try self.elems.appendSlice(allocator, other.elems.items);
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
            dyn: DynElem,
            members: AutoArrayHashMap(StringTable.Id, Elem),

            pub fn create(vm: *VM, capacity: usize) !*Object {
                const dyn = try DynElem.allocate(vm, Object, .Object);
                const object = dyn.asObject();

                var members = AutoArrayHashMap(StringTable.Id, Elem){};
                try members.ensureTotalCapacity(vm.allocator, capacity);

                object.* = Object{
                    .dyn = dyn.*,
                    .members = members,
                };

                return object;
            }

            pub fn copy(vm: *VM, other: *Object) !*Object {
                const obj = try create(vm, other.members.count());
                try obj.concat(vm.allocator, other);
                return obj;
            }

            pub fn destroy(self: *Object, vm: *VM) void {
                self.members.deinit(vm.allocator);
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Object, vm: VM, writer: anytype) @TypeOf(writer).Error!void {
                if (self.members.count() == 0) {
                    try writer.print("{{}}", .{});
                } else {
                    const lastMemberIndex = self.members.count() - 1;

                    try writer.print("{{", .{});
                    var iterator = self.members.iterator();
                    while (iterator.next()) |entry| {
                        const sid = entry.key_ptr.*;

                        if (StringTable.asReserved(sid)) |rid| {
                            try writer.print("_{d}_", .{rid});
                        } else {
                            try writer.print("\"{s}\": ", .{vm.strings.get(sid)});
                            try entry.value_ptr.*.print(vm, writer);
                        }

                        if (iterator.index <= lastMemberIndex) {
                            try writer.print(", ", .{});
                        }
                    }
                    try writer.print("}}", .{});
                }
            }

            pub fn isEql(self: *Object, other: *DynElem, vm: VM) bool {
                if (!other.isType(.Object)) return false;

                var otherObject = other.asObject();

                if (self.members.count() != otherObject.members.count()) return false;

                var iterator = self.members.iterator();
                while (iterator.next()) |entry| {
                    if (otherObject.members.get(entry.key_ptr.*)) |otherVal| {
                        if (!entry.value_ptr.*.isEql(otherVal, vm)) return false;
                    } else {
                        return false;
                    }
                }

                return true;
            }

            pub fn concat(self: *Object, allocator: Allocator, other: *Object) !void {
                var iterator = other.members.iterator();
                while (iterator.next()) |entry| {
                    try self.members.put(allocator, entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            pub fn putReservedId(self: *Object, allocator: Allocator, reservedId: u8, value: Elem) !void {
                return self.members.put(allocator, std.math.maxInt(u32) - @as(u32, @intCast(reservedId)), value);
            }
        };

        pub const FunctionType = enum {
            AnonParser,
            Main,
            NamedParser,
            NamedValue,
        };

        pub const Function = struct {
            dyn: DynElem,
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

            pub fn create(vm: *VM, fields: struct { name: StringTable.Id, functionType: FunctionType, arity: u8, region: Region }) !*Function {
                const dyn = try DynElem.allocate(vm, Function, .Function);
                const function = dyn.asFunction();

                var chunk = Chunk.init(vm.allocator);
                chunk.sourceRegion = fields.region;

                function.* = Function{
                    .dyn = dyn.*,
                    .arity = fields.arity,
                    .chunk = chunk,
                    .name = fields.name,
                    .functionType = fields.functionType,
                    .locals = ArrayList(Local){},
                };

                return function;
            }

            pub fn createAnonParser(vm: *VM, fields: struct { arity: u8, region: Region }) !*Function {
                const dyn = try DynElem.allocate(vm, Function, .Function);
                const function = dyn.asFunction();

                const name_str = try std.fmt.allocPrint(vm.allocator, "@fn{d}", .{dyn.id});
                defer vm.allocator.free(name_str);
                const name = try vm.strings.insert(name_str);

                var chunk = Chunk.init(vm.allocator);
                chunk.sourceRegion = fields.region;

                function.* = Function{
                    .dyn = dyn.*,
                    .arity = fields.arity,
                    .chunk = chunk,
                    .name = name,
                    .functionType = .AnonParser,
                    .locals = ArrayList(Local){},
                };

                return function;
            }

            pub fn destroy(self: *Function, vm: *VM) void {
                self.chunk.deinit();
                self.locals.deinit(vm.allocator);
                vm.allocator.destroy(self);
            }

            pub fn print(self: *Function, vm: VM, writer: anytype) !void {
                try writer.print("{s}", .{vm.strings.get(self.name)});
            }

            pub fn isEql(self: *Function, other: *DynElem) bool {
                if (!other.isType(.Function)) return false;
                return self == other.asFunction();
            }

            pub fn disassemble(self: *Function, vm: VM, writer: anytype, module: ?*Module) !void {
                const label = vm.strings.get(self.name);
                try self.chunk.disassemble(vm, writer, label, module);
            }

            pub fn addLocal(self: *Function, allocator: Allocator, local: Local) !?u8 {
                if (self.locals.items.len >= std.math.maxInt(u8)) {
                    return error.MaxFunctionLocals;
                }

                for (self.locals.items) |item| {
                    if (item.name() == local.name()) {
                        return error.VariableNameUsedInScope;
                    }
                }

                try self.locals.append(allocator, local);

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

            pub fn nameBytes(self: *Function, vm: VM) []const u8 {
                return vm.strings.get(self.name);
            }

            pub fn isBuiltin(self: *Function, vm: VM) bool {
                const name = self.nameBytes(vm);
                return name.len > 0 and name[0] == '@';
            }
        };

        pub const NativeCode = struct {
            dyn: DynElem,
            name: []const u8,
            handle: NativeCodeHandle,

            pub const NativeCodeHandle = *const fn (vm: *VM) VM.Error!void;

            pub fn create(vm: *VM, name: []const u8, handle: NativeCodeHandle) !*NativeCode {
                const dyn = try DynElem.allocate(vm, NativeCode, .NativeCode);
                const nc = dyn.asNativeCode();

                nc.* = NativeCode{
                    .dyn = dyn.*,
                    .name = name,
                    .handle = handle,
                };

                return nc;
            }

            pub fn destroy(self: *NativeCode, vm: *VM) void {
                vm.allocator.destroy(self);
            }

            pub fn print(self: *NativeCode, writer: anytype) !void {
                try writer.print("{s}", .{self.name});
            }

            pub fn isEql(self: *NativeCode, other: *DynElem) bool {
                if (!other.isType(.NativeCode)) return false;
                return self == other.asNativeCode();
            }
        };

        pub const Closure = struct {
            dyn: DynElem,
            function: *Function,
            captures: []?Elem,

            pub fn create(vm: *VM, function: *Function) !*Closure {
                const dyn = try DynElem.allocate(vm, Closure, .Closure);
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

            pub fn print(self: *Closure, vm: VM, writer: anytype) @TypeOf(writer).Error!void {
                try writer.print("|{s} ", .{vm.strings.get(self.function.name)});

                if (self.captures.len > 0) {
                    const lastItemIndex = self.captures.len - 1;

                    for (self.captures[0..lastItemIndex]) |maybeElem| {
                        if (maybeElem) |e| {
                            try e.print(vm, writer);
                            try writer.print(", ", .{});
                        } else {
                            try writer.print("_, ", .{});
                        }
                    }
                    if (self.captures[lastItemIndex]) |e| {
                        try e.print(vm, writer);
                    } else {
                        try writer.print("_", .{});
                    }
                }

                try writer.print("|", .{});
            }

            pub fn isEql(self: *Closure, other: *DynElem) bool {
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
    try std.testing.expectEqual(16, @sizeOf(Elem));
    try std.testing.expectEqual(24, @sizeOf(Elem.DynElem));
    try std.testing.expectEqual(64, @sizeOf(Elem.DynElem.String));
    try std.testing.expectEqual(48, @sizeOf(Elem.DynElem.Array));
    try std.testing.expectEqual(64, @sizeOf(Elem.DynElem.Object));
    try std.testing.expectEqual(184, @sizeOf(Elem.DynElem.Function));
    try std.testing.expectEqual(48, @sizeOf(Elem.DynElem.Closure));
}

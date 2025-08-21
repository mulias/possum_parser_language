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

const mask_sign: u64 = 0x8000000000000000;
const mask_exponent: u64 = 0x7FF0000000000000;
const mask_quiet: u64 = 0x0008000000000000;
const mask_type: u64 = 0x0007000000000000;
const mask_nan: u64 = mask_exponent | mask_quiet;
const mask_signature: u64 = mask_sign | mask_exponent | mask_quiet | mask_type;
const mask_payload: u64 = ~mask_signature;
const signature_nan: u13 = 0x1FF8;

pub const ElemType = enum(u3) {
    Const = 0,
    Dyn = 1,
    InputSubstring = 2,
    NumberString = 3,
    ParserVar = 4,
    String = 5,
    ValueVar = 6,
    NumberFloat = 7,
};

pub const TaggedType = enum(u3) {
    Const = 0,
    Dyn = 1,
    InputSubstring = 2,
    NumberString = 3,
    ParserVar = 4,
    String = 5,
    ValueVar = 6,
};

pub const Elem = packed union {
    bits: u64,
    float: f64,
    tagged: packed struct {
        payload: packed union {
            bits: u48,
            interned_string: packed struct { sid: u32, _unused: u16 = 0 },
            input_substring: InputSubstringElem,
            number_string: NumberStringElem,
            constant: packed struct { value: ConstElem, _unused: u46 = 0 },
        },
        type: TaggedType,
        signature: u13 = signature_nan,
    },

    pub const InputSubstringElem = packed struct {
        start: u24,
        offset: u24,

        pub fn new(start: u24, offset: u24) InputSubstringElem {
            return InputSubstringElem{ .start = start, .offset = offset };
        }

        pub fn fromRange(start_pos: usize, end_pos: usize) ?InputSubstringElem {
            const offset = end_pos - start_pos;
            if (start_pos <= std.math.maxInt(u24) and offset <= std.math.maxInt(u24)) {
                return InputSubstringElem.new(@as(u24, @intCast(start_pos)), @as(u24, @intCast(offset)));
            }
            return null;
        }

        pub fn end(self: InputSubstringElem) usize {
            return self.start + self.offset;
        }

        pub fn isContiguous(is1: InputSubstringElem, is2: InputSubstringElem) bool {
            return is1.end() == is2.start;
        }

        pub fn bytes(self: InputSubstringElem, vm: VM) []const u8 {
            return vm.input[self.start..self.end()];
        }

        pub fn eql(self: InputSubstringElem, other: InputSubstringElem) bool {
            return self.start == other.start and self.offset == other.offset;
        }

        pub fn mergeContiguous(is1: InputSubstringElem, is2: InputSubstringElem) ?InputSubstringElem {
            if (is1.isContiguous(is2)) {
                const new_start = is1.start;
                const new_end = is2.end();
                const new_offset = @as(usize, @intCast(new_end)) - @as(usize, @intCast(new_start));
                if (new_offset <= std.math.maxInt(u24)) {
                    return InputSubstringElem.new(new_start, @as(u24, @intCast(new_offset)));
                }
            }
            return null;
        }

        pub fn elem(self: InputSubstringElem) Elem {
            return Elem{ .tagged = .{
                .payload = .{ .input_substring = self },
                .type = .InputSubstring,
            } };
        }
    };

    pub const NumberStringElem = packed struct {
        sid: StringTable.Id,
        negated: bool,
        _unused: u15 = 0,

        pub fn new(bytes: []const u8, vm: *VM) !NumberStringElem {
            if (bytes[0] == '-') {
                const sId = try vm.strings.insert(bytes);
                return NumberStringElem{ .sid = sId, .negated = true };
            } else {
                var buffer = try vm.allocator.alloc(u8, bytes.len + 1);
                defer vm.allocator.free(buffer);
                buffer[0] = '-';
                @memcpy(buffer[1..], bytes);
                const sId = try vm.strings.insert(buffer);
                return NumberStringElem{ .sid = sId, .negated = false };
            }
        }

        pub fn toBytes(self: NumberStringElem, strings: StringTable) []const u8 {
            const bs = strings.get(self.sid);
            if (self.negated) {
                return bs;
            } else {
                return bs[1..];
            }
        }

        pub fn negate(self: NumberStringElem) NumberStringElem {
            return NumberStringElem{
                .sid = self.sid,
                .negated = !self.negated,
            };
        }

        pub fn toNumberFloat(self: NumberStringElem, strings: StringTable) !Elem {
            const bytes = self.toBytes(strings);
            const f = std.fmt.parseFloat(f64, bytes) catch |err| switch (err) {
                std.fmt.ParseFloatError.InvalidCharacter => @panic("Internal Error"),
            };
            return Elem.numberFloat(f);
        }

        pub fn elem(self: NumberStringElem) Elem {
            return Elem{ .tagged = .{
                .payload = .{ .number_string = self },
                .type = .NumberString,
            } };
        }
    };

    pub const ConstElem = enum(u2) {
        False = 0,
        True = 1,
        Null = 2,
        Failure = 3,

        pub fn bytes(c: ConstElem) []const u8 {
            return switch (c) {
                .False => "false",
                .True => "true",
                .Null => "null",
                .Failure => "@Failure",
            };
        }
    };

    pub fn parserVar(sid: StringTable.Id) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .interned_string = .{ .sid = sid } },
            .type = .ParserVar,
        } };
    }

    pub fn valueVar(sid: StringTable.Id) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .interned_string = .{ .sid = sid } },
            .type = .ValueVar,
        } };
    }

    pub fn string(sid: StringTable.Id) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .interned_string = .{ .sid = sid } },
            .type = .String,
        } };
    }

    pub fn inputSubstring(start: u24, offset: u24) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .input_substring = .{ .start = start, .offset = offset } },
            .type = .InputSubstring,
        } };
    }

    pub fn inputSubstringFromRange(start: usize, end: usize) !?Elem {
        if (InputSubstringElem.fromRange(start, end)) |substring| {
            return Elem{ .tagged = .{
                .payload = .{ .input_substring = substring },
                .type = .InputSubstring,
            } };
        } else {
            return null;
        }
    }

    pub fn numberString(sid: StringTable.Id, negated: bool) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .numberString = .{ .sid = sid, .negated = negated } },
            .type = .NumberString,
        } };
    }

    pub fn numberStringFromBytes(bytes: []const u8, vm: *VM) !Elem {
        const number_string = try NumberStringElem.new(bytes, vm);
        return Elem{ .tagged = .{
            .payload = .{ .number_string = number_string },
            .type = .NumberString,
        } };
    }

    pub fn numberFloat(f: f64) Elem {
        return Elem{ .float = f };
    }

    pub fn boolean(b: bool) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .constant = .{ .value = if (b) ConstElem.True else ConstElem.False } },
            .type = .Const,
        } };
    }

    pub const nullConst = Elem{ .tagged = .{
        .payload = .{ .constant = .{ .value = ConstElem.Null } },
        .type = .Const,
    } };

    pub const failureConst = Elem{ .tagged = .{
        .payload = .{ .constant = .{ .value = ConstElem.Failure } },
        .type = .Const,
    } };

    pub fn isNaN(self: Elem) bool {
        return self.bits & ~mask_sign == (@as(u64, 0) << 48) | mask_nan;
    }

    pub fn isFloat(self: Elem) bool {
        return self.tagged.signature != signature_nan or self.isNaN();
    }

    pub fn isTagged(self: Elem) bool {
        return !self.isFloat();
    }

    pub fn isNumber(self: Elem) bool {
        return self.isFloat() or self.isType(.NumberString);
    }

    pub fn isType(self: Elem, elemType: ElemType) bool {
        if (elemType == .NumberFloat) {
            return self.isFloat();
        } else {
            return self.isTagged() and @intFromEnum(self.tagged.type) == @intFromEnum(elemType);
        }
    }

    pub fn getType(self: Elem) ElemType {
        if (self.isFloat()) {
            return .NumberFloat;
        } else {
            return @enumFromInt(@intFromEnum(self.tagged.type));
        }
    }

    pub fn isConst(self: Elem, constType: ConstElem) bool {
        return self.isType(.Const) and self.tagged.payload.constant.value == constType;
    }

    pub fn isDynType(self: Elem, dynType: DynType) bool {
        if (!self.isType(.Dyn)) return false;
        const d = self.asDyn();
        return d.isType(dynType);
    }

    pub fn isSuccess(self: Elem) bool {
        return !self.isConst(.Failure);
    }

    pub fn isFailure(self: Elem) bool {
        return self.isConst(.Failure);
    }

    pub fn asParserVar(self: Elem) StringTable.Id {
        std.debug.assert(self.isType(.ParserVar));
        return self.tagged.payload.interned_string.sid;
    }

    pub fn asValueVar(self: Elem) StringTable.Id {
        std.debug.assert(self.isType(.ValueVar));
        return self.tagged.payload.interned_string.sid;
    }

    pub fn asString(self: Elem) StringTable.Id {
        std.debug.assert(self.isType(.String));
        return self.tagged.payload.interned_string.sid;
    }

    pub fn asInputSubstring(self: Elem) InputSubstringElem {
        std.debug.assert(self.isType(.InputSubstring));
        return self.tagged.payload.input_substring;
    }

    pub fn asNumberString(self: Elem) NumberStringElem {
        std.debug.assert(self.isType(.NumberString));
        return self.tagged.payload.number_string;
    }

    pub fn asFloat(self: Elem) f64 {
        std.debug.assert(self.isFloat());
        return self.float;
    }

    pub fn asConst(self: Elem) ConstElem {
        std.debug.assert(self.isType(.Const));
        return self.tagged.payload.constant.value;
    }

    pub fn asDyn(self: Elem) *DynElem {
        std.debug.assert(self.isType(.Dyn));
        return @ptrFromInt(@as(usize, @intCast(self.bits & mask_payload)));
    }

    pub fn print(self: Elem, vm: VM, writer: anytype) !void {
        switch (self.getType()) {
            .ParserVar => {
                const sid = self.asParserVar();
                if (StringTable.asReserved(sid)) |rid| {
                    try writer.print("_{d}", .{rid});
                } else {
                    try writer.print("{s}", .{vm.strings.get(sid)});
                }
            },
            .ValueVar => {
                const sid = self.asValueVar();
                if (StringTable.asReserved(sid)) |rid| {
                    try writer.print("_{d}", .{rid});
                } else {
                    try writer.print("{s}", .{vm.strings.get(sid)});
                }
            },
            .String => {
                const sid = self.asString();
                if (StringTable.asReserved(sid)) |rid| {
                    try writer.print("_{d}", .{rid});
                } else {
                    try writer.print("\"{s}\"", .{vm.strings.get(sid)});
                }
            },
            .InputSubstring => {
                const is = self.asInputSubstring();
                try writer.print("\"{s}\"", .{is.bytes(vm)});
            },
            .NumberString => {
                const ns = self.asNumberString();
                try writer.print("{s}", .{ns.toBytes(vm.strings)});
            },
            .Const => {
                const c = self.asConst();
                try writer.print("{s}", .{c.bytes()});
            },
            .Dyn => {
                const d = self.asDyn();
                try d.print(vm, writer);
            },
            .NumberFloat => {
                const f = self.asFloat();
                if (@trunc(f) == f and f >= @as(f64, @floatFromInt(std.math.minInt(i64))) and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                    try writer.print("{d}", .{@as(i64, @intFromFloat(f))});
                } else {
                    try writer.print("{d}", .{f});
                }
            },
        }
    }

    pub fn tagName(self: Elem) []const u8 {
        return if (self.isFloat()) "Float" else @tagName(self.tagged.type);
    }

    pub fn isEql(self: Elem, other: Elem, vm: VM) bool {
        // Handle numbers first
        if (self.isFloat()) {
            if (other.isFloat()) {
                return self.asFloat() == other.asFloat();
            } else if (other.isType(.NumberString)) {
                const f2 = try other.asNumberString().toNumberFloat(vm.strings);
                return self.isEql(f2, vm);
            }
        } else if (self.isType(.NumberString)) {
            const f1 = try self.asNumberString().toNumberFloat(vm.strings);
            return f1.isEql(other, vm);
        }

        // Handle non-numbers
        if (self.isType(.ParserVar)) {
            return other.isType(.ParserVar) and self.asParserVar() == other.asParserVar();
        } else if (self.isType(.ValueVar)) {
            return other.isType(.ValueVar) and self.asValueVar() == other.asValueVar();
        } else if (self.isType(.String)) {
            const sId1 = self.asString();
            if (other.isType(.String)) {
                return sId1 == other.asString();
            } else if (other.isType(.InputSubstring)) {
                const s1 = vm.strings.get(sId1);
                const is2 = other.asInputSubstring();
                const s2 = is2.bytes(vm);
                return std.mem.eql(u8, s1, s2);
            } else if (other.isType(.Dyn)) {
                const d2 = other.asDyn();
                if (d2.isType(.String)) {
                    const s1 = vm.strings.get(sId1);
                    const s2 = d2.asString().bytes();
                    return std.mem.eql(u8, s1, s2);
                }
            }
            return false;
        } else if (self.isType(.InputSubstring)) {
            const is1 = self.asInputSubstring();
            if (other.isType(.String)) {
                const s1 = is1.bytes(vm);
                const s2 = vm.strings.get(other.asString());
                return std.mem.eql(u8, s1, s2);
            } else if (other.isType(.InputSubstring)) {
                const is2 = other.asInputSubstring();
                if (is1.eql(is2)) return true;
                const s1 = is1.bytes(vm);
                const s2 = is2.bytes(vm);
                return std.mem.eql(u8, s1, s2);
            } else if (other.isType(.Dyn)) {
                const d2 = other.asDyn();
                if (d2.isType(.String)) {
                    const s1 = is1.bytes(vm);
                    const s2 = d2.asString().bytes();
                    return std.mem.eql(u8, s1, s2);
                }
            }
            return false;
        } else if (self.isType(.NumberString)) {
            const n1 = self.asNumberString();
            if (other.isType(.NumberString)) {
                const n2 = other.asNumberString();
                const elem1 = n1.toNumberFloat(vm.strings) catch return false;
                const elem2 = n2.toNumberFloat(vm.strings) catch return false;
                return elem1.isEql(elem2, vm);
            } else if (other.isFloat()) {
                const elem1 = n1.toNumberFloat(vm.strings) catch return false;
                return elem1.isEql(other, vm);
            }
            return false;
        } else if (self.isType(.Const)) {
            if (!other.isType(.Const)) return false;
            return self.tagged.payload.constant.value == other.tagged.payload.constant.value;
        } else if (self.isType(.Dyn)) {
            const d1 = self.asDyn();
            if (other.isType(.String)) {
                if (d1.isType(.String)) {
                    const s1 = d1.asString().bytes();
                    const s2 = vm.strings.get(other.asString());
                    return std.mem.eql(u8, s1, s2);
                }
                return false;
            } else if (other.isType(.InputSubstring)) {
                if (d1.isType(.String)) {
                    const s1 = d1.asString().bytes();
                    const is2 = other.asInputSubstring();
                    const s2 = is2.bytes(vm);
                    return std.mem.eql(u8, s1, s2);
                }
                return false;
            } else if (other.isType(.Dyn)) {
                return d1.isEql(other.asDyn(), vm);
            }
            return false;
        }
        return false;
    }

    pub fn isLessThanOrEqualInRangePattern(value: Elem, high: Elem, vm: VM) !bool {
        if (value.isType(.ValueVar)) {
            return true;
        }

        if (value.isType(.String) or value.isType(.InputSubstring) or value.isType(.Dyn)) {
            const value_codepoint = value.toCodepoint(vm) orelse return false;

            if (high.isType(.ValueVar)) {
                return true;
            } else {
                const high_codepoint = high.toCodepoint(vm) orelse return false;
                return value_codepoint <= high_codepoint;
            }
        }

        if (value.isType(.NumberString)) {
            const ns = value.asNumberString();
            const num = try ns.toNumberFloat(vm.strings);
            return num.isLessThanOrEqualInRangePattern(high, vm);
        }

        if (value.isFloat()) {
            const num_value = value.asFloat();
            if (high.isType(.ValueVar)) {
                return true;
            } else if (high.isType(.NumberString)) {
                const ns = high.asNumberString();
                const highNum = try ns.toNumberFloat(vm.strings);
                return value.isLessThanOrEqualInRangePattern(highNum, vm);
            } else if (high.isFloat()) {
                return num_value <= high.asFloat();
            }
            return false;
        }

        if (value.isType(.Const) or value.isType(.ParserVar)) {
            return false;
        }

        return false;
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

        return switch (elemA.getType()) {
            .String => switch (elemB.getType()) {
                .String => {
                    const s1 = vm.strings.get(elemA.asString());
                    const s2 = vm.strings.get(elemB.asString());
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .InputSubstring => {
                    const s1 = vm.strings.get(elemA.asString());
                    const s2 = elemB.asInputSubstring().bytes(vm.*);
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .Dyn => switch (elemB.asDyn().dynType) {
                    .String => {
                        const s1 = vm.strings.get(elemA.asString());
                        const ds2 = elemB.asDyn().asString();
                        const s = try Elem.DynElem.String.create(vm, s1.len + ds2.buffer.size);
                        try s.concatBytes(s1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .InputSubstring => switch (elemB.getType()) {
                .String => {
                    const s1 = elemA.asInputSubstring().bytes(vm.*);
                    const s2 = vm.strings.get(elemB.asString());
                    const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                    try s.concatBytes(s1);
                    try s.concatBytes(s2);
                    return s.dyn.elem();
                },
                .InputSubstring => {
                    const is1 = elemA.asInputSubstring();
                    const is2 = elemB.asInputSubstring();
                    if (is1.mergeContiguous(is2)) |merged| {
                        return merged.elem();
                    } else {
                        const s1 = is1.bytes(vm.*);
                        const s2 = is2.bytes(vm.*);
                        const s = try Elem.DynElem.String.create(vm, s1.len + s2.len);
                        try s.concatBytes(s1);
                        try s.concatBytes(s2);
                        return s.dyn.elem();
                    }
                },
                .Dyn => switch (elemB.asDyn().dynType) {
                    .String => {
                        const s1 = elemA.asInputSubstring().bytes(vm.*);
                        const ds2 = elemB.asDyn().asString();
                        const s = try Elem.DynElem.String.create(vm, s1.len + ds2.buffer.size);
                        try s.concatBytes(s1);
                        try s.concat(ds2);
                        return s.dyn.elem();
                    },
                    else => null,
                },
                else => null,
            },
            .NumberString => {
                if (elemB.isZero(vm.strings)) {
                    return elemA;
                } else {
                    const elem1 = try elemA.asNumberString().toNumberFloat(vm.strings);
                    return merge(elem1, elemB, vm);
                }
            },
            .NumberFloat => switch (elemB.getType()) {
                .NumberString => {
                    if (elemA.isZero(vm.strings)) {
                        return elemB;
                    } else {
                        const elem2 = try elemB.asNumberString().toNumberFloat(vm.strings);
                        return merge(elemA, elem2, vm);
                    }
                },
                .NumberFloat => numberFloat(elemA.asFloat() + elemB.asFloat()),
                else => null,
            },
            .Const => if (elemB.isType(.Const)) {
                return boolean((elemA.asConst() == .True) or (elemB.asConst() == .True));
            } else {
                return null;
            },
            .ParserVar,
            .ValueVar,
            => @panic("Internal error"),
            .Dyn => switch (elemA.asDyn().dynType) {
                .String => {
                    const ds1 = elemA.asDyn().asString();
                    return switch (elemB.getType()) {
                        .String => {
                            const s2 = vm.strings.get(elemB.asString());
                            const s = try Elem.DynElem.String.create(vm, ds1.buffer.size + s2.len);
                            try s.concat(ds1);
                            try s.concatBytes(s2);
                            return s.dyn.elem();
                        },
                        .InputSubstring => {
                            const s2 = elemB.asInputSubstring().bytes(vm.*);
                            const s = try Elem.DynElem.String.create(vm, ds1.buffer.size + s2.len);
                            try s.concat(ds1);
                            try s.concatBytes(s2);
                            return s.dyn.elem();
                        },
                        .Dyn => switch (elemB.asDyn().dynType) {
                            .String => {
                                const ds2 = elemB.asDyn().asString();
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
                    const a1 = elemA.asDyn().asArray();
                    return switch (elemB.getType()) {
                        .Dyn => switch (elemB.asDyn().dynType) {
                            .Array => {
                                const a2 = elemB.asDyn().asArray();
                                const a = try Elem.DynElem.Array.create(vm, a1.elems.items.len + a2.elems.items.len);
                                try a.concat(vm, a1);
                                try a.concat(vm, a2);
                                return a.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Object => {
                    const o1 = elemA.asDyn().asObject();
                    return switch (elemB.getType()) {
                        .Dyn => switch (elemB.asDyn().dynType) {
                            .Object => {
                                const o2 = elemB.asDyn().asObject();
                                const o = try Elem.DynElem.Object.create(vm, o1.members.count() + o2.members.count());
                                try o.concat(vm, o1);
                                try o.concat(vm, o2);
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

    pub fn repeat(elem: Elem, count: Elem, vm: *VM) !?Elem {
        if (elem.isConst(.Failure)) return Elem.failureConst;
        if (count.isConst(.Failure)) return Elem.failureConst;

        // Multiply numbers
        if (elem.isNumber() and count.isNumber()) {
            // Preserve number strings if multiplying by identity
            if (count.isEql(numberFloat(1), vm.*)) return elem;

            // Convert to floats if needed
            const floatElem = if (elem.isFloat())
                elem
            else
                try elem.asNumberString().toNumberFloat(vm.strings);

            const floatCount = if (count.isFloat())
                count
            else
                try count.asNumberString().toNumberFloat(vm.strings);

            return numberFloat(floatElem.asFloat() * floatCount.asFloat());
        }

        // For non-numbers the rhs must be a non-negative integer
        var repeat_count: i64 = 0;
        if (count.isFloat()) {
            const f = count.asFloat();
            if (@trunc(f) == f and f >= 0 and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                repeat_count = @as(i64, @intFromFloat(f));
            } else {
                return null;
            }
        } else if (count.isType(.NumberString)) {
            const floatCount = try count.asNumberString().toNumberFloat(vm.strings);
            const f = floatCount.asFloat();
            if (@trunc(f) == f and f >= 0 and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                repeat_count = @as(i64, @intFromFloat(f));
            } else {
                return null;
            }
        } else {
            return null;
        }

        // Repeatedly merge the element with itself. When the count is 0 the
        // result is Null.
        var result = Elem.nullConst;
        var i: i64 = 0;
        while (i < repeat_count) : (i += 1) {
            if (try merge(result, elem, vm)) |merged| {
                result = merged;
            } else {
                return null;
            }
        }

        return result;
    }

    pub fn negateNumber(elem: Elem) !Elem {
        return switch (elem.getType()) {
            .ParserVar,
            => @panic("Internal error"),
            .Const => switch (elem.asConst()) {
                .Failure => elem,
                .Null => numberFloat(0),
                .True, .False => error.ExpectedNumber,
            },
            .NumberString => elem.asNumberString().negate().elem(),
            .NumberFloat => numberFloat(elem.asFloat() * -1),
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

    pub fn isZero(self: Elem, strings: StringTable) bool {
        return switch (self.getType()) {
            .NumberString => {
                const ns = self.asNumberString();
                const n = ns.toNumberFloat(strings) catch return false;
                return n.isZero(strings);
            },
            .NumberFloat => self.asFloat() == 0,
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
        return switch (elem.getType()) {
            .String => vm.strings.get(elem.asString()),
            .InputSubstring => elem.asInputSubstring().bytes(vm),
            .Dyn => switch (elem.asDyn().dynType) {
                .String => elem.asDyn().asString().buffer.str(),
                else => null,
            },
            else => null,
        };
    }

    pub fn getOrPutSid(elem: Elem, vm: *VM) !?StringTable.Id {
        switch (elem.getType()) {
            .String => return elem.asString(),
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
        return switch (self.getType()) {
            .String => {
                const s = vm.strings.get(self.asString());
                return .{ .string = s };
            },
            .InputSubstring => {
                const s = self.asInputSubstring().bytes(vm);
                return .{ .string = s };
            },
            .NumberString => {
                return .{ .number_string = self.asNumberString().toBytes(vm.strings) };
            },
            .NumberFloat => {
                const f = self.asFloat();
                if (@trunc(f) == f and f >= @as(f64, @floatFromInt(std.math.minInt(i64))) and f <= @as(f64, @floatFromInt(std.math.maxInt(i64)))) {
                    return .{ .integer = @as(i64, @intFromFloat(f)) };
                } else {
                    return .{ .float = f };
                }
            },
            .Const => switch (self.asConst()) {
                .True => .{ .bool = true },
                .False => .{ .bool = false },
                .Null => .{ .null = undefined },
                .Failure => @panic("Internal Error"),
            },
            .Dyn => switch (self.asDyn().dynType) {
                .String => {
                    const s = self.asDyn().asString().buffer.str();
                    return .{ .string = s };
                },
                .Array => {
                    const array = self.asDyn().asArray();
                    var jsonArray = json.Array.init(vm.allocator);
                    try jsonArray.ensureTotalCapacity(array.elems.items.len);

                    for (array.elems.items) |item| {
                        try jsonArray.append(try item.toJson(vm));
                    }

                    return .{ .array = jsonArray };
                },
                .Object => {
                    var object = self.asDyn().asObject();
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
            .integer => |i| Elem.numberFloat(@as(f64, @floatFromInt(i))),
            .float => |f| Elem.numberFloat(f),
            .number_string => |number_bytes| {
                if (parsing.isValidNumberString(number_bytes)) {
                    return Elem.numberStringFromBytes(number_bytes, vm);
                } else {
                    @panic("Internal Error");
                }
            },
            .string => |s| (try Elem.DynElem.String.copy(vm, s)).dyn.elem(),
            .array => |a| {
                const array = try Elem.DynElem.Array.create(vm, a.items.len);

                // Prevent GC
                try vm.pushTempDyn(&array.dyn);
                defer vm.dropTempDyn();

                for (a.items) |array_value| {
                    try array.append(vm, try fromJson(array_value, vm));
                }
                return array.dyn.elem();
            },
            .object => |o| {
                const obj = try Elem.DynElem.Object.create(vm, o.count());

                // Prevent GC
                try vm.pushTempDyn(&obj.dyn);
                defer vm.dropTempDyn();

                var iterator = o.iterator();
                while (iterator.next()) |entry| {
                    const elem_key = try vm.strings.insert(entry.key_ptr.*);
                    const elem_value = try fromJson(entry.value_ptr.*, vm);
                    try obj.put(vm, elem_key, elem_value);
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
        isMarked: bool = false,
        nextGray: ?*DynElem = null,

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
            const addr = @intFromPtr(self);
            std.debug.assert(addr & mask_signature == 0);
            return Elem{ .tagged = .{
                .payload = .{ .bits = @as(u48, @intCast(addr & mask_payload)) },
                .type = .Dyn,
            } };
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
                // Allocate buffer before string is added to GC
                var buffer = StringBuffer.init(vm.gc.allocator());
                try buffer.allocate(size);

                const dyn = try vm.gc.createDynElem(String, .String);
                const str = dyn.asString();

                str.* = String{
                    .dyn = dyn.*,
                    .buffer = buffer,
                };

                return str;
            }

            pub fn destroy(self: *String, vm: *VM) void {
                self.buffer.deinit();
                vm.gc.allocator().destroy(self);
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
                try a.elems.appendSlice(vm.gc.allocator(), elems);
                return a;
            }

            pub fn create(vm: *VM, capacity: usize) !*Array {
                // Allocate elems before array is added to GC
                var elems = ArrayList(Elem){};
                try elems.ensureTotalCapacity(vm.gc.allocator(), capacity);

                const dyn = try vm.gc.createDynElem(Array, .Array);
                const array = dyn.asArray();

                array.* = Array{
                    .dyn = dyn.*,
                    .elems = elems,
                };

                return array;
            }

            pub fn destroy(self: *Array, vm: *VM) void {
                self.elems.deinit(vm.gc.allocator());
                vm.gc.allocator().destroy(self);
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

            pub fn append(self: *Array, vm: *VM, item: Elem) !void {
                try self.elems.append(vm.gc.allocator(), item);
            }

            pub fn concat(self: *Array, vm: *VM, other: *Array) !void {
                try self.elems.appendSlice(vm.gc.allocator(), other.elems.items);
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
                // Allocate members before object is added to GC
                var members: AutoArrayHashMap(StringTable.Id, Elem) = .{};
                try members.ensureTotalCapacity(vm.gc.allocator(), capacity);

                const dyn = try vm.gc.createDynElem(Object, .Object);
                const obj = dyn.asObject();

                obj.* = Object{
                    .dyn = dyn.*,
                    .members = members,
                };

                return obj;
            }

            pub fn copy(vm: *VM, other: *Object) !*Object {
                const obj = try create(vm, other.members.count());
                try obj.concat(vm.gc.allocator(), other);
                return obj;
            }

            pub fn destroy(self: *Object, vm: *VM) void {
                self.members.deinit(vm.gc.allocator());
                vm.gc.allocator().destroy(self);
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

            pub fn concat(self: *Object, vm: *VM, other: *Object) !void {
                var iterator = other.members.iterator();
                while (iterator.next()) |entry| {
                    try self.members.put(vm.gc.allocator(), entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            pub fn put(self: *Object, vm: *VM, sid: StringTable.Id, value: Elem) !void {
                try self.members.put(vm.gc.allocator(), sid, value);
            }

            pub fn putReservedId(self: *Object, vm: *VM, reservedId: u8, value: Elem) !void {
                return self.members.put(vm.gc.allocator(), std.math.maxInt(u32) - @as(u32, @intCast(reservedId)), value);
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
                const dyn = try vm.gc.createDynElem(Function, .Function);
                const function = dyn.asFunction();

                const chunk = Chunk{ .source_region = fields.region };

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
                const dyn = try vm.gc.createDynElem(Function, .Function);
                const function = dyn.asFunction();

                const name_str = try std.fmt.allocPrint(vm.allocator, "@fn{d}", .{dyn.id});
                defer vm.allocator.free(name_str);
                const name = try vm.strings.insert(name_str);

                const chunk = Chunk{
                    .source_region = fields.region,
                };

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
                self.chunk.deinit(vm.allocator);
                self.locals.deinit(vm.gc.allocator());
                vm.gc.allocator().destroy(self);
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

            pub fn addLocal(self: *Function, vm: *VM, local: Local) !?u8 {
                if (self.locals.items.len >= std.math.maxInt(u8)) {
                    return error.MaxFunctionLocals;
                }

                for (self.locals.items) |item| {
                    if (item.name() == local.name()) {
                        return error.VariableNameUsedInScope;
                    }
                }

                try self.locals.append(vm.gc.allocator(), local);

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
                const dyn = try vm.gc.createDynElem(NativeCode, .NativeCode);
                const nc = dyn.asNativeCode();

                nc.* = NativeCode{
                    .dyn = dyn.*,
                    .name = name,
                    .handle = handle,
                };

                return nc;
            }

            pub fn destroy(self: *NativeCode, vm: *VM) void {
                vm.gc.allocator().destroy(self);
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
                const captures = try vm.gc.allocator().alloc(?Elem, function.locals.items.len);
                @memset(captures, null);

                const dyn = try vm.gc.createDynElem(Closure, .Closure);
                const closure = dyn.asClosure();

                closure.* = Closure{
                    .dyn = dyn.*,
                    .function = function,
                    .captures = captures,
                };

                return closure;
            }

            pub fn destroy(self: *Closure, vm: *VM) void {
                vm.gc.allocator().free(self.captures);
                vm.gc.allocator().destroy(self);
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
    try std.testing.expectEqual(8, @sizeOf(Elem));
    try std.testing.expectEqual(32, @sizeOf(Elem.DynElem));
    try std.testing.expectEqual(72, @sizeOf(Elem.DynElem.String));
    try std.testing.expectEqual(56, @sizeOf(Elem.DynElem.Array));
    try std.testing.expectEqual(72, @sizeOf(Elem.DynElem.Object));
    try std.testing.expectEqual(176, @sizeOf(Elem.DynElem.Function));
    try std.testing.expectEqual(56, @sizeOf(Elem.DynElem.Closure));
}

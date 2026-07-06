const std = @import("std");
const Writer = std.Io.Writer;
const ArrayList = std.ArrayListUnmanaged;
const AutoArrayHashMap = std.AutoArrayHashMapUnmanaged;
const json = std.json;
const json_pretty = @import("json_pretty.zig");
const unicode = std.unicode;
const Chunk = @import("chunk.zig").Chunk;
const Module = @import("module.zig").Module;
const Region = @import("region.zig").Region;
const StringBuffer = @import("string_buffer.zig").StringBuffer;
const StringTable = @import("string_table.zig").StringTable(.runtime);
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
    ValueVar = 4,
    String = 5,
    NumberFloat = 6,
};

pub const TaggedType = enum(u3) {
    Const = 0,
    Dyn = 1,
    InputSubstring = 2,
    NumberString = 3,
    ValueVar = 4,
    String = 5,
};

pub const Elem = packed union {
    bits: u64,
    float: f64,
    tagged: packed struct {
        payload: packed union {
            bits: u48,
            value_var: ValueVar,
            interned_string: packed struct { sid: StringTable.Id, _unused: u16 = 0 },
            input_substring: InputSubstringElem,
            number_string: NumberStringElem,
            constant: packed struct { value: ConstElem, _unused: u46 = 0 },
        },
        type: TaggedType,
        signature: u13 = signature_nan,
    },

    pub const ValueVar = packed struct {
        sid: StringTable.Id,
        placeholder: bool,
        _unused: u15 = 0,
    };

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

        pub fn toNumberFloat(self: NumberStringElem, strings: StringTable) Elem {
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

    pub fn valueVar(sid: StringTable.Id, placeholder: bool) Elem {
        return Elem{ .tagged = .{
            .payload = .{ .value_var = .{ .sid = sid, .placeholder = placeholder } },
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
            .payload = .{ .number_string = .{ .sid = sid, .negated = negated } },
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

    pub fn isInteger(self: Elem, strings: StringTable) bool {
        if (self.isFloat()) {
            const f = self.asFloat();
            return @trunc(f) == f;
        } else if (self.isType(.NumberString)) {
            const ns = self.asNumberString();
            for (ns.toBytes(strings)) |byte| {
                if (byte == '.' or byte == 'e' or byte == 'E') {
                    return false;
                }
            }
            return true;
        } else {
            return false;
        }
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

    pub fn asValueVar(self: Elem) ValueVar {
        std.debug.assert(self.isType(.ValueVar));
        return self.tagged.payload.value_var;
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

    pub fn asInteger(self: Elem, strings: StringTable) !i64 {
        const f = if (self.isType(.NumberString))
            self.asNumberString().toNumberFloat(strings).asFloat()
        else
            self.asFloat();

        return @as(i64, @intFromFloat(f));
    }

    pub fn asConst(self: Elem) ConstElem {
        std.debug.assert(self.isType(.Const));
        return self.tagged.payload.constant.value;
    }

    pub fn asDyn(self: Elem) *DynElem {
        std.debug.assert(self.isType(.Dyn));
        return @ptrFromInt(@as(usize, @intCast(self.bits & mask_payload)));
    }

    // Refcount helpers that no-op for value-type Elems, which have no
    // identity and are never mutated in place.
    pub fn retain(self: Elem) void {
        if (self.isType(.Dyn)) self.asDyn().retain();
    }

    pub fn release(self: Elem) void {
        if (self.isType(.Dyn)) self.asDyn().release();
    }

    pub fn isStringy(self: Elem) bool {
        return self.isType(.String) or self.isType(.InputSubstring) or self.isDynType(.String);
    }

    pub fn isEmptyString(self: Elem, vm: VM) bool {
        return switch (self.getType()) {
            .String => vm.strings.get(self.asString()).len == 0,
            .InputSubstring => self.asInputSubstring().offset == 0,
            .Dyn => self.isDynType(.String) and self.asDyn().asString().byteLen() == 0,
            else => false,
        };
    }

    // Iterate the contiguous byte runs of a stringy Elem: one run for
    // value strings and leaves, one per segment for ropes.
    const StringRuns = struct {
        single: ?[]const u8,
        segments: []const Elem,
        index: usize = 0,

        fn init(e: Elem, vm: VM) StringRuns {
            if (e.isType(.Dyn)) {
                switch (e.asDyn().asString().repr) {
                    .rope => |rope| return .{ .single = null, .segments = rope.segments.items },
                    .leaf => {},
                }
            }
            return .{ .single = DynElem.String.segmentBytes(e, vm), .segments = &.{} };
        }

        fn next(self: *StringRuns, vm: VM) ?[]const u8 {
            if (self.single) |s| {
                self.single = null;
                return s;
            }
            if (self.index >= self.segments.len) return null;
            const s = DynElem.String.segmentBytes(self.segments[self.index], vm);
            self.index += 1;
            return s;
        }
    };

    fn eqlStrings(a: Elem, b: Elem, vm: VM) bool {
        if (a.isType(.String) and b.isType(.String)) return a.asString() == b.asString();
        if (a.isType(.InputSubstring) and b.isType(.InputSubstring) and
            a.asInputSubstring().eql(b.asInputSubstring())) return true;
        if (a.isType(.Dyn) and b.isType(.Dyn) and a.asDyn() == b.asDyn()) return true;

        var runs_a = StringRuns.init(a, vm);
        var runs_b = StringRuns.init(b, vm);
        var ra: []const u8 = "";
        var rb: []const u8 = "";
        while (true) {
            if (ra.len == 0) ra = runs_a.next(vm) orelse break;
            if (rb.len == 0) rb = runs_b.next(vm) orelse break;
            const n = @min(ra.len, rb.len);
            if (!std.mem.eql(u8, ra[0..n], rb[0..n])) return false;
            ra = ra[n..];
            rb = rb[n..];
        }
        // One side ran out; equal iff the other has no bytes left either.
        while (ra.len == 0) ra = runs_a.next(vm) orelse break;
        while (rb.len == 0) rb = runs_b.next(vm) orelse break;
        return ra.len == 0 and rb.len == 0;
    }

    pub fn print(self: Elem, vm: VM, writer: *Writer) Writer.Error!void {
        switch (self.getType()) {
            .ValueVar => {
                const v = self.asValueVar();
                if (StringTable.asReserved(v.sid)) |rid| {
                    try writer.print("_{d}_", .{rid});
                } else {
                    try writer.print("{s}", .{vm.strings.get(v.sid)});
                }
            },
            .String => {
                const sid = self.asString();
                if (StringTable.asReserved(sid)) |rid| {
                    try writer.print("_{d}_", .{rid});
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
                if (self.isInteger(vm.strings)) {
                    try writer.print("{d}", .{@as(i64, @intFromFloat(self.asFloat()))});
                } else {
                    try writer.print("{d}", .{self.asFloat()});
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
                const f2 = other.asNumberString().toNumberFloat(vm.strings);
                return self.isEql(f2, vm);
            }
        } else if (self.isType(.NumberString)) {
            const f1 = self.asNumberString().toNumberFloat(vm.strings);
            return f1.isEql(other, vm);
        }

        // Handle non-numbers
        if (self.isStringy() and other.isStringy()) {
            return eqlStrings(self, other, vm);
        }

        if (self.isType(.ValueVar)) {
            if (!other.isType(.ValueVar)) return false;
            const sid1 = self.asValueVar().sid;
            const sid2 = other.asValueVar().sid;
            return sid1 == sid2;
        } else if (self.isType(.Const)) {
            if (!other.isType(.Const)) return false;
            return self.tagged.payload.constant.value == other.tagged.payload.constant.value;
        } else if (self.isType(.Dyn)) {
            if (other.isType(.Dyn)) return self.asDyn().isEql(other.asDyn(), vm);
            return false;
        }
        return false;
    }

    pub fn isLessThanOrEqualInRangePattern(value: Elem, high: Elem, vm: VM) !bool {
        if (value.isType(.ValueVar) or high.isType(.ValueVar)) {
            return true;
        }

        if (value.isType(.String) or value.isType(.InputSubstring) or value.isType(.Dyn)) {
            const value_codepoint = value.toCodepoint(vm) orelse return false;
            const high_codepoint = high.toCodepoint(vm) orelse return false;
            return value_codepoint <= high_codepoint;
        }

        if (value.isType(.NumberString)) {
            const ns = value.asNumberString();
            const num = ns.toNumberFloat(vm.strings);
            return num.isLessThanOrEqualInRangePattern(high, vm);
        }

        if (value.isFloat()) {
            const num_value = value.asFloat();
            if (high.isType(.NumberString)) {
                const ns = high.asNumberString();
                const highNum = ns.toNumberFloat(vm.strings);
                return value.isLessThanOrEqualInRangePattern(highNum, vm);
            } else if (high.isFloat()) {
                return num_value <= high.asFloat();
            }
            return false;
        }

        if (value.isType(.Const)) {
            return false;
        }

        return false;
    }

    fn toCodepoint(elem: Elem, vm: VM) ?u21 {
        var buf: [4]u8 = undefined;
        const bytes = elem.shortStringBytes(&buf, vm) orelse return null;
        return unicode.utf8Decode(bytes) catch return null;
    }

    // Bytes of a stringy elem when they fit in `buf`, without
    // allocating: value strings and leaves are borrowed directly, rope
    // segments are gathered into `buf`. Null when not stringy or when a
    // rope is longer than the buffer.
    fn shortStringBytes(elem: Elem, buf: []u8, vm: VM) ?[]const u8 {
        if (!elem.isStringy()) return null;
        if (elem.isType(.Dyn)) {
            switch (elem.asDyn().asString().repr) {
                .rope => |rope| {
                    if (rope.byte_len > buf.len) return null;
                    var i: usize = 0;
                    for (rope.segments.items) |seg| {
                        const bs = DynElem.String.segmentBytes(seg, vm);
                        @memcpy(buf[i..(i + bs.len)], bs);
                        i += bs.len;
                    }
                    return buf[0..i];
                },
                .leaf => {},
            }
        }
        return DynElem.String.segmentBytes(elem, vm);
    }

    pub fn merge(elemA: Elem, elemB: Elem, vm: *VM) !?Elem {
        if (elemA.isConst(.Failure)) return Elem.failureConst;
        if (elemB.isConst(.Failure)) return Elem.failureConst;
        if (elemA.isConst(.Null)) return elemB;
        if (elemB.isConst(.Null)) return elemA;

        if (elemA.isStringy() and elemB.isStringy()) {
            return try mergeStrings(elemA, elemB, vm);
        }

        return switch (elemA.getType()) {
            .String, .InputSubstring => null,
            .NumberString => {
                if (elemB.isZero(vm.strings)) {
                    return elemA;
                } else {
                    const elem1 = elemA.asNumberString().toNumberFloat(vm.strings);
                    return merge(elem1, elemB, vm);
                }
            },
            .NumberFloat => switch (elemB.getType()) {
                .NumberString => {
                    if (elemA.isZero(vm.strings)) {
                        return elemB;
                    } else {
                        const elem2 = elemB.asNumberString().toNumberFloat(vm.strings);
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
            .ValueVar,
            => return null,
            .Dyn => switch (elemA.asDyn().dynType) {
                .String => null,
                .Array => {
                    const a1 = elemA.asDyn().asArray();
                    if (vm.config.rc_fast_paths and a1.dyn.isUniqueBesidesCache() and elemB.isDynType(.Array)) {
                        vm.rc_stats.merge_in_place += 1;
                        const a2 = elemB.asDyn().asArray();
                        try a1.concatStealing(vm, a2);
                        return elemA;
                    }
                    return switch (elemB.getType()) {
                        .Dyn => switch (elemB.asDyn().dynType) {
                            .Array => {
                                vm.rc_stats.merge_copy += 1;
                                const a2 = elemB.asDyn().asArray();
                                const a = try Elem.DynElem.Array.create(vm, a1.elems.items.len + a2.elems.items.len);
                                try a.concat(vm, a1);
                                try a.concatStealing(vm, a2);
                                return a.dyn.elem();
                            },
                            else => null,
                        },
                        else => null,
                    };
                },
                .Object => {
                    const o1 = elemA.asDyn().asObject();
                    if (vm.config.rc_fast_paths and o1.dyn.isUniqueBesidesCache() and elemB.isDynType(.Object)) {
                        vm.rc_stats.merge_in_place += 1;
                        const o2 = elemB.asDyn().asObject();
                        try o1.concatStealing(vm, o2);
                        return elemA;
                    }
                    return switch (elemB.getType()) {
                        .Dyn => switch (elemB.asDyn().dynType) {
                            .Object => {
                                vm.rc_stats.merge_copy += 1;
                                const o2 = elemB.asDyn().asObject();
                                const o = try Elem.DynElem.Object.create(vm, o1.members.count() + o2.members.count());
                                try o.concat(vm, o1);
                                try o.concatStealing(vm, o2);
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

    // Merge two strings. Value strings and leaves are the leaves of the
    // representation; merges build ropes instead of copying bytes
    // wherever a copy can be avoided. Both operands must be rooted:
    // every path below may allocate.
    fn mergeStrings(elemA: Elem, elemB: Elem, vm: *VM) !Elem {
        if (elemA.isEmptyString(vm.*)) return elemB;
        if (elemB.isEmptyString(vm.*)) return elemA;

        // Adjacent input substrings stay a value type: zero-copy.
        if (elemA.isType(.InputSubstring) and elemB.isType(.InputSubstring)) {
            if (elemA.asInputSubstring().mergeContiguous(elemB.asInputSubstring())) |merged| {
                return merged.elem();
            }
        }

        if (!vm.config.rc_fast_paths) {
            if (elemA.isType(.Dyn) or elemB.isType(.Dyn)) vm.rc_stats.merge_copy += 1;
            return try copyStrings(elemA, elemB, vm);
        }

        if (elemA.isType(.Dyn)) {
            const sa = elemA.asDyn().asString();
            if (sa.dyn.isUnique()) {
                vm.rc_stats.merge_in_place += 1;
                switch (sa.repr) {
                    // An owned buffer accumulates rhs bytes directly,
                    // keeping left-fold accumulation contiguous.
                    .leaf => try appendStringBytes(sa, elemB, vm),
                    .rope => try ropeAppend(sa, elemB, vm),
                }
                return elemA;
            }
        } else if (elemB.isType(.Dyn)) {
            const sb = elemB.asDyn().asString();
            // A consumable unique rope absorbs a prepended value
            // segment: right-built strings stay linear.
            if (sb.dyn.isUnique() and sb.repr == .rope) {
                vm.rc_stats.merge_in_place += 1;
                try sb.prependSegment(vm, elemA);
                return elemB;
            }
        }

        // No in-place path: build a fresh rope referencing both
        // operands instead of copying their bytes. Shared ropes are
        // flattened first so segments stay one level deep, and segment
        // capacity is counted up front so filling the rope cannot
        // allocate while it is unrooted. For the stats this is the
        // not-in-place bucket: no existing Dyn was mutated.
        if (elemA.isType(.Dyn) or elemB.isType(.Dyn)) vm.rc_stats.merge_copy += 1;
        if (elemA.isType(.Dyn) and elemA.asDyn().asString().repr == .rope) {
            _ = try elemA.asDyn().asString().flatten(vm);
        }
        var splice_b: ?*DynElem.String = null;
        var capacity_b: usize = 1;
        if (elemB.isType(.Dyn)) {
            const sb = elemB.asDyn().asString();
            if (sb.repr == .rope) {
                if (sb.dyn.isUnique()) {
                    splice_b = sb;
                    capacity_b = sb.repr.rope.segments.items.len;
                } else {
                    _ = try sb.flatten(vm);
                }
            }
        }

        const result = try DynElem.String.createRope(vm, 1 + capacity_b);
        try result.appendSegment(vm, elemA);
        if (splice_b) |sb| {
            try result.spliceRope(vm, sb);
        } else {
            try result.appendSegment(vm, elemB);
        }
        return result.dyn.elem();
    }

    // Append a string operand's bytes into a unique leaf.
    fn appendStringBytes(sa: *DynElem.String, e: Elem, vm: *VM) !void {
        var runs = StringRuns.init(e, vm.*);
        while (runs.next(vm.*)) |run| try sa.concatBytes(run);
    }

    // Append a string operand onto a unique rope: values and leaves
    // become segments, unique ropes are spliced, shared ropes are
    // flattened and referenced.
    fn ropeAppend(sa: *DynElem.String, e: Elem, vm: *VM) !void {
        if (e.isType(.Dyn)) {
            const se = e.asDyn().asString();
            if (se.repr == .rope) {
                if (se.dyn.isUnique()) return sa.spliceRope(vm, se);
                _ = try se.flatten(vm);
            }
        }
        try sa.appendSegment(vm, e);
    }

    // Baseline for disabled fast paths: always copy both operands into
    // a fresh leaf, exactly the pre-refcounting behavior. The exact
    // pre-sizing means the fills never reallocate the unrooted leaf.
    fn copyStrings(elemA: Elem, elemB: Elem, vm: *VM) !Elem {
        const size = DynElem.String.segmentByteLen(elemA, vm.*) + DynElem.String.segmentByteLen(elemB, vm.*);
        const s = try DynElem.String.create(vm, size);
        try appendStringBytes(s, elemA, vm);
        try appendStringBytes(s, elemB, vm);
        return s.dyn.elem();
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
                elem.asNumberString().toNumberFloat(vm.strings);

            const floatCount = if (count.isFloat())
                count
            else
                count.asNumberString().toNumberFloat(vm.strings);

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
            const floatCount = count.asNumberString().toNumberFloat(vm.strings);
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
        //
        // The extra handle on `elem` keeps it from ever looking unique:
        // the first merge returns `elem` itself (null identity), and the
        // in-place merge path must not consume the value being repeated.
        elem.retain();
        defer elem.release();

        // Root the intermediate result: it lives only in this frame while
        // the next iteration's merge allocates.
        const temp_dyns_start = vm.temp_dyns.items.len;
        defer vm.clearTempDyns(temp_dyns_start);

        var result = Elem.nullConst;
        var i: i64 = 0;
        while (i < repeat_count) : (i += 1) {
            if (try merge(result, elem, vm)) |merged| {
                vm.clearTempDyns(temp_dyns_start);
                if (merged.isType(.Dyn)) try vm.pushTempDyn(merged.asDyn());
                result = merged;
            } else {
                return null;
            }
        }

        return result;
    }

    pub fn negateNumber(elem: Elem) !Elem {
        return switch (elem.getType()) {
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

    pub fn isZero(self: Elem, strings: StringTable) bool {
        return switch (self.getType()) {
            .NumberString => self.asNumberString().toNumberFloat(strings).asFloat() == 0,
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

    // Contiguous bytes of a stringy elem. Ropes are flattened in place
    // (an allocation, hence *VM and the error), so the elem must be
    // rooted.
    pub fn stringBytes(elem: Elem, vm: *VM) !?[]const u8 {
        return switch (elem.getType()) {
            .String => vm.strings.get(elem.asString()),
            .InputSubstring => elem.asInputSubstring().bytes(vm.*),
            .Dyn => switch (elem.asDyn().dynType) {
                .String => try elem.asDyn().asString().flatten(vm),
                else => null,
            },
            else => null,
        };
    }

    pub fn getOrPutSid(elem: Elem, vm: *VM) !?StringTable.Id {
        switch (elem.getType()) {
            .String => return elem.asString(),
            else => {
                if (try elem.stringBytes(vm)) |bytes| {
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
                    const s = try self.asDyn().asString().bytesAlloc(vm, vm.allocator);
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
            .ValueVar => @panic("Internal Error"),
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
        // Number of owning handles to this value: operand-stack entries,
        // frame local slots, container elements, closure captures, and
        // module constant table entries. A uniqueness oracle for in-place
        // mutation, not a collector: counts may drift high (stale-high is
        // a copy, stale-low is a soundness bug), and only the mark-sweep
        // GC frees memory. Born at 1: the creator's handle.
        ref_count: u32 = 1,

        // Set while exactly one module mutable-constant slot holds a
        // handle to this value. That slot is only read by
        // GetConstantMutable, which re-checks the count, so an op
        // holding this value as a stack operand at ref_count 2 owns the
        // only other handle and may mutate in place.
        cache_held: bool = false,

        // Values shared by construction (module constants, the empty
        // container singletons) are pinned at the saturating count and
        // never look unique.
        pub const immortal_ref_count = std.math.maxInt(u32);

        pub fn retain(self: *DynElem) void {
            std.debug.assert(self.ref_count >= 1);
            if (self.ref_count == immortal_ref_count) return;
            self.ref_count +|= 1;
        }

        pub fn release(self: *DynElem) void {
            std.debug.assert(self.ref_count >= 1);
            if (self.ref_count == immortal_ref_count) return;
            self.ref_count -= 1;
        }

        pub fn isUnique(self: *DynElem) bool {
            std.debug.assert(self.ref_count >= 1);
            return self.ref_count == 1;
        }

        // True when the caller's stack operand is the only handle apart
        // from a mutable-constant cache slot. Only valid to call while
        // holding the value as an operand: that handle plus the cache
        // slot account for both counts, so no third holder exists.
        pub fn isUniqueBesidesCache(self: *DynElem) bool {
            std.debug.assert(self.ref_count >= 1);
            return self.ref_count == 1 or (self.cache_held and self.ref_count == 2);
        }

        pub fn makeImmortal(self: *DynElem) void {
            self.ref_count = immortal_ref_count;
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

        // Visit each child handle this value holds. The only place that
        // enumerates which dyn types bear children: GC marking, refcount
        // auditing, and child release all route through here so adding a
        // child-bearing type is a single edit.
        pub fn forEachChild(
            self: *DynElem,
            context: anytype,
            comptime visit: fn (@TypeOf(context), Elem) void,
        ) void {
            switch (self.dynType) {
                .String => switch (self.asString().repr) {
                    .rope => |rope| for (rope.segments.items) |item| visit(context, item),
                    .leaf => {},
                },
                .Array => {
                    for (self.asArray().elems.items) |item| visit(context, item);
                },
                .Object => {
                    var iter = self.asObject().members.iterator();
                    while (iter.next()) |entry| visit(context, entry.value_ptr.*);
                },
                .Closure => {
                    const closure = self.asClosure();
                    visit(context, closure.function.dyn.elem());
                    for (closure.captures) |maybe_elem| {
                        if (maybe_elem) |item| visit(context, item);
                    }
                },
                .Function, .NativeCode => {},
            }
        }

        fn releaseChildElem(_: void, child: Elem) void {
            child.release();
        }

        // Release every child handle a dead or consumed value holds.
        pub fn releaseChildren(self: *DynElem) void {
            self.forEachChild({}, releaseChildElem);
        }

        // Release all children and empty the backing collection, leaving a
        // husk ready to refill. Only Array and Object hold clearable child
        // collections.
        pub fn clearChildren(self: *DynElem) void {
            self.releaseChildren();
            switch (self.dynType) {
                .Array => self.asArray().elems.clearRetainingCapacity(),
                .Object => self.asObject().members.clearRetainingCapacity(),
                else => {},
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

        pub fn print(self: *DynElem, vm: VM, writer: *Writer) Writer.Error!void {
            return switch (self.dynType) {
                .String => self.asString().print(vm, writer),
                .Array => self.asArray().print(vm, writer),
                .Object => self.asObject().print(vm, writer),
                .Function => self.asFunction().print(vm, writer),
                .NativeCode => self.asNativeCode().print(writer),
                .Closure => self.asClosure().print(vm, writer),
            };
        }

        pub fn isEql(self: *DynElem, other: *DynElem, vm: VM) bool {
            return switch (self.dynType) {
                .String => self.asString().isEql(other, vm),
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
            repr: Repr,

            pub const Repr = union(enum) {
                // Owned contiguous bytes: the only form readers consume
                // directly.
                leaf: StringBuffer,
                // Concatenation segments, in order: interned strings,
                // input substrings, and leaf strings. Merges append
                // segments instead of copying bytes; the first byte read
                // flattens the rope into a leaf. Segments are never
                // ropes, so readers walk one level.
                rope: Rope,
            };

            pub const Rope = struct {
                segments: ArrayList(Elem),
                byte_len: usize,
            };

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
                    .repr = .{ .leaf = buffer },
                };

                return str;
            }

            pub fn createRope(vm: *VM, capacity: usize) !*String {
                // Allocate segments before the string is added to GC,
                // with enough capacity that filling the rope allocates
                // nothing: a collection during construction would sweep
                // the unrooted string.
                var segments = ArrayList(Elem){};
                try segments.ensureTotalCapacity(vm.gc.allocator(), capacity);

                const dyn = try vm.gc.createDynElem(String, .String);
                const str = dyn.asString();

                str.* = String{
                    .dyn = dyn.*,
                    .repr = .{ .rope = .{ .segments = segments, .byte_len = 0 } },
                };

                return str;
            }

            pub fn destroy(self: *String, vm: *VM) void {
                switch (self.repr) {
                    .leaf => |*buffer| buffer.deinit(),
                    .rope => |*rope| rope.segments.deinit(vm.gc.allocator()),
                }
                vm.gc.allocator().destroy(self);
            }

            // Collapse a rope into its leaf and return the contiguous
            // bytes. Content-idempotent, so safe on shared values: a
            // cache fill, not a mutation.
            pub fn flatten(self: *String, vm: *VM) ![]const u8 {
                switch (self.repr) {
                    .leaf => {},
                    .rope => |rope| {
                        // Root self: building the leaf allocates, which
                        // can run a collection, and some callers hold
                        // the only handle off-stack (builtin args).
                        try vm.pushTempDyn(&self.dyn);
                        defer vm.dropTempDyn();

                        var buffer = StringBuffer.init(vm.gc.allocator());
                        try buffer.allocate(rope.byte_len);
                        for (rope.segments.items) |seg| {
                            try buffer.concat(segmentBytes(seg, vm.*));
                        }
                        // The swap and releases allocate nothing, so no
                        // collection observes the intermediate state.
                        var segments = rope.segments;
                        self.repr = .{ .leaf = buffer };
                        for (segments.items) |seg| seg.release();
                        segments.deinit(vm.gc.allocator());
                    },
                }
                return self.repr.leaf.str();
            }

            // Bytes of a single rope segment. Dyn segments are always
            // leaves, by construction.
            fn segmentBytes(seg: Elem, vm: VM) []const u8 {
                return switch (seg.getType()) {
                    .String => vm.strings.get(seg.asString()),
                    .InputSubstring => seg.asInputSubstring().bytes(vm),
                    .Dyn => seg.asDyn().asString().bytes(),
                    else => unreachable,
                };
            }

            fn segmentByteLen(seg: Elem, vm: VM) usize {
                return switch (seg.getType()) {
                    .String => vm.strings.get(seg.asString()).len,
                    .InputSubstring => seg.asInputSubstring().offset,
                    .Dyn => seg.asDyn().asString().byteLen(),
                    else => unreachable,
                };
            }

            // Append a value string or leaf as a segment, retaining the
            // stored handle (mirrors Array.append). Adjacent input
            // substrings collapse, keeping contiguous scans at one
            // segment.
            pub fn appendSegment(self: *String, vm: *VM, seg: Elem) !void {
                const rope = &self.repr.rope;
                const items = rope.segments.items;
                if (seg.isType(.InputSubstring) and items.len > 0 and items[items.len - 1].isType(.InputSubstring)) {
                    const last = items[items.len - 1].asInputSubstring();
                    if (last.mergeContiguous(seg.asInputSubstring())) |merged| {
                        items[items.len - 1] = merged.elem();
                        rope.byte_len += seg.asInputSubstring().offset;
                        return;
                    }
                }
                seg.retain();
                try rope.segments.append(vm.gc.allocator(), seg);
                rope.byte_len += segmentByteLen(seg, vm.*);
            }

            // Prepend a segment; see appendSegment.
            pub fn prependSegment(self: *String, vm: *VM, seg: Elem) !void {
                const rope = &self.repr.rope;
                const items = rope.segments.items;
                if (seg.isType(.InputSubstring) and items.len > 0 and items[0].isType(.InputSubstring)) {
                    const first = items[0].asInputSubstring();
                    if (seg.asInputSubstring().mergeContiguous(first)) |merged| {
                        items[0] = merged.elem();
                        rope.byte_len += seg.asInputSubstring().offset;
                        return;
                    }
                }
                seg.retain();
                try rope.segments.insert(vm.gc.allocator(), 0, seg);
                rope.byte_len += segmentByteLen(seg, vm.*);
            }

            // Move `other`'s segments onto the end of self without
            // retaining: the caller owns `other`'s only handle and is
            // consuming it, so each segment's handle transfers. The husk
            // is emptied so its stale handles can't be seen by the audit
            // or a later walk. Capacity is reserved up front so no
            // allocation can observe a segment in both ropes mid-move.
            pub fn spliceRope(self: *String, vm: *VM, other: *String) !void {
                std.debug.assert(other.dyn.isUnique());
                const rope = &self.repr.rope;
                const other_rope = &other.repr.rope;
                try rope.segments.ensureUnusedCapacity(vm.gc.allocator(), other_rope.segments.items.len);
                rope.segments.appendSliceAssumeCapacity(other_rope.segments.items);
                rope.byte_len += other_rope.byte_len;
                other_rope.segments.clearRetainingCapacity();
                other_rope.byte_len = 0;
            }

            pub fn print(self: *String, vm: VM, writer: *Writer) Writer.Error!void {
                switch (self.repr) {
                    .leaf => |buffer| try writer.print("\"{s}\"", .{buffer.str()}),
                    .rope => |rope| {
                        try writer.print("\"", .{});
                        for (rope.segments.items) |seg| {
                            try writer.print("{s}", .{segmentBytes(seg, vm)});
                        }
                        try writer.print("\"", .{});
                    },
                }
            }

            pub fn isEql(self: *String, other: *DynElem, vm: VM) bool {
                if (!other.isType(.String)) return false;
                return eqlStrings(self.dyn.elem(), other.elem(), vm);
            }

            pub fn concat(self: *String, other: *String) !void {
                try self.repr.leaf.concat(other.bytes());
            }

            pub fn concatByte(self: *String, other: u8) !void {
                try self.repr.leaf.concat(&[_]u8{other});
            }

            pub fn concatBytes(self: *String, other: []const u8) !void {
                try self.repr.leaf.concat(other);
            }

            pub fn byteLen(self: *String) usize {
                return switch (self.repr) {
                    .leaf => |buffer| buffer.size,
                    .rope => |rope| rope.byte_len,
                };
            }

            // Contiguous bytes of a leaf. Readers that may see a rope go
            // through Elem.stringBytes, which flattens first.
            pub fn bytes(self: *String) []const u8 {
                return self.repr.leaf.str();
            }

            // Contiguous bytes without mutating: leaves are borrowed,
            // ropes are concatenated into `allocator` memory. For
            // readers that cannot flatten (no *VM).
            pub fn bytesAlloc(self: *String, vm: VM, allocator: std.mem.Allocator) ![]const u8 {
                switch (self.repr) {
                    .leaf => |buffer| return buffer.str(),
                    .rope => |rope| {
                        const out = try allocator.alloc(u8, rope.byte_len);
                        var i: usize = 0;
                        for (rope.segments.items) |seg| {
                            const bs = segmentBytes(seg, vm);
                            @memcpy(out[i..(i + bs.len)], bs);
                            i += bs.len;
                        }
                        return out;
                    },
                }
            }
        };

        pub const Array = struct {
            dyn: DynElem,
            elems: ArrayList(Elem),

            pub fn copy(vm: *VM, elems: []const Elem) !*Array {
                const a = try create(vm, elems.len);
                for (elems) |item| item.retain();
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

            pub fn print(self: *Array, vm: VM, writer: *Writer) Writer.Error!void {
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
                item.retain();
                try self.elems.append(vm.gc.allocator(), item);
            }

            pub fn concat(self: *Array, vm: *VM, other: *Array) !void {
                for (other.elems.items) |item| item.retain();
                try self.elems.appendSlice(vm.gc.allocator(), other.elems.items);
            }

            // Move `other`'s children into self without retaining: the
            // caller owns `other`'s only handle and is consuming it, so
            // each child's handle transfers from `other` to self. The
            // husk is emptied so its stale child handles can't be seen
            // by the audit or a later walk.
            pub fn concatSteal(self: *Array, vm: *VM, other: *Array) !void {
                std.debug.assert(other.dyn.isUniqueBesidesCache());
                try self.elems.appendSlice(vm.gc.allocator(), other.elems.items);
                other.elems.clearRetainingCapacity();
            }

            // Steal `other`'s children when it is a consumable unique
            // operand, otherwise copy them.
            pub fn concatStealing(self: *Array, vm: *VM, other: *Array) !void {
                if (vm.config.rc_fast_paths and other.dyn.isUniqueBesidesCache()) {
                    try self.concatSteal(vm, other);
                } else {
                    try self.concat(vm, other);
                }
            }

            // Reset a mutable-constant cache copy to match its template.
            // Only valid while the cache slot holds the sole handle, so
            // the current children are unobservable: release them and
            // rebuild from the template. Handles every leftover state — a
            // consumed copy emptied by concatSteal, a partial fill
            // abandoned on failure, or a fully populated copy.
            pub fn refreshFrom(self: *Array, vm: *VM, template: *Array) !void {
                self.dyn.clearChildren();
                for (template.elems.items) |item| item.retain();
                try self.elems.appendSlice(vm.gc.allocator(), template.elems.items);
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

            pub fn copy(vm: *VM, source: *Object) !*Object {
                const o = try create(vm, source.members.count());
                try o.concat(vm, source);
                return o;
            }

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

            pub fn destroy(self: *Object, vm: *VM) void {
                self.members.deinit(vm.gc.allocator());
                vm.gc.allocator().destroy(self);
            }

            pub fn print(self: *Object, vm: VM, writer: *Writer) Writer.Error!void {
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
                    try self.put(vm, entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Move `other`'s values into self without retaining; see
            // Array.concatSteal. Capacity is reserved up front so no
            // allocation (and thus no GC audit) can observe a value in
            // both containers mid-move.
            pub fn concatSteal(self: *Object, vm: *VM, other: *Object) !void {
                std.debug.assert(other.dyn.isUniqueBesidesCache());
                try self.members.ensureUnusedCapacity(vm.gc.allocator(), other.members.count());
                var iterator = other.members.iterator();
                while (iterator.next()) |entry| {
                    const gop = self.members.getOrPutAssumeCapacity(entry.key_ptr.*);
                    if (gop.found_existing) gop.value_ptr.*.release();
                    gop.value_ptr.* = entry.value_ptr.*;
                }
                other.members.clearRetainingCapacity();
            }

            // Steal `other`'s members when it is a consumable unique
            // operand, otherwise copy them. See Array.concatStealing.
            pub fn concatStealing(self: *Object, vm: *VM, other: *Object) !void {
                if (vm.config.rc_fast_paths and other.dyn.isUniqueBesidesCache()) {
                    try self.concatSteal(vm, other);
                } else {
                    try self.concat(vm, other);
                }
            }

            // See Array.refreshFrom.
            pub fn refreshFrom(self: *Object, vm: *VM, template: *Object) !void {
                self.dyn.clearChildren();
                try self.concat(vm, template);
            }

            pub fn put(self: *Object, vm: *VM, sid: StringTable.Id, value: Elem) !void {
                value.retain();
                const gop = try self.members.getOrPut(vm.gc.allocator(), sid);
                if (gop.found_existing) gop.value_ptr.*.release();
                gop.value_ptr.* = value;
            }

            pub fn putReservedId(self: *Object, vm: *VM, reservedId: u8, value: Elem) !void {
                return self.put(vm, StringTable.reservedSid(reservedId), value);
            }
        };

        pub const Function = struct {
            dyn: DynElem,
            mid: Module.Id,
            arity: u5,
            param_types: ParamTypes,
            chunk: Chunk,
            name: StringTable.Id,
            is_anonymous: bool,
            builtin: bool,

            pub const ParamType = enum { Parser, Value };

            pub const ParamTypes = struct {
                bitset: u32 = 0,

                pub fn set(self: *ParamTypes, index: u5, param_type: ParamType) void {
                    const bit_value: u32 = switch (param_type) {
                        .Parser => 0,
                        .Value => 1,
                    };
                    const mask: u32 = @as(u32, 1) << index;
                    self.bitset = (self.bitset & ~mask) | (bit_value << index);
                }

                pub fn get(self: ParamTypes, index: u5) ParamType {
                    const bit = (self.bitset >> index) & 1;
                    return if (bit == 0) .Parser else .Value;
                }
            };

            pub fn create(vm: *VM, fields: struct { module_id: Module.Id, name: StringTable.Id, arity: u5, is_anonymous: bool, region: Region }) !*Function {
                const dyn = try vm.gc.createDynElem(Function, .Function);
                const function = dyn.asFunction();

                const chunk = Chunk{ .source_region = fields.region };
                const name_bytes = vm.strings.get(fields.name);

                function.* = Function{
                    .dyn = dyn.*,
                    .mid = fields.module_id,
                    .arity = fields.arity,
                    .param_types = ParamTypes{},
                    .chunk = chunk,
                    .name = fields.name,
                    .is_anonymous = fields.is_anonymous,
                    .builtin = name_bytes.len > 0 and name_bytes[0] == '@',
                };

                return function;
            }

            pub fn destroy(self: *Function, vm: *VM) void {
                self.chunk.deinit(vm.allocator);
                vm.gc.allocator().destroy(self);
            }

            pub fn print(self: *Function, vm: VM, writer: *Writer) Writer.Error!void {
                try writer.print("{s}", .{vm.strings.get(self.name)});
            }

            pub fn isEql(self: *Function, other: *DynElem) bool {
                if (!other.isType(.Function)) return false;
                return self == other.asFunction();
            }

            pub fn disassemble(self: *Function, vm: VM, writer: *Writer) Writer.Error!void {
                const label = vm.strings.get(self.name);
                try self.chunk.disassemble(vm, vm.getModule(self.mid).*, writer, label);
            }

            pub fn nameBytes(self: *Function, vm: VM) []const u8 {
                return vm.strings.get(self.name);
            }

            pub fn isBuiltin(self: *Function) bool {
                return self.builtin;
            }

            pub fn hasEmptyBytecode(self: *Function) bool {
                return self.chunk.code.items.len == 0;
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

            pub fn print(self: *NativeCode, writer: *Writer) Writer.Error!void {
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

            pub fn create(vm: *VM, function: *Function, localCount: u8) !*Closure {
                const captures = try vm.gc.allocator().alloc(?Elem, localCount);
                @memset(captures, null);
                function.dyn.retain();

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

            pub fn print(self: *Closure, vm: VM, writer: *Writer) Writer.Error!void {
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
                local.retain();
                self.captures[index] = local;
            }

            // Reset a consumed closure to its as-created all-null state so
            // CaptureLocal can refill it. The function handle is kept: the
            // husk still references its function, and releasing it here
            // would double-release when the closure is swept.
            pub fn clearCaptures(self: *Closure) void {
                for (self.captures) |*maybe_capture| {
                    if (maybe_capture.*) |captured| captured.release();
                    maybe_capture.* = null;
                }
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
    try std.testing.expectEqual(80, @sizeOf(Elem.DynElem.String));
    try std.testing.expectEqual(56, @sizeOf(Elem.DynElem.Array));
    try std.testing.expectEqual(72, @sizeOf(Elem.DynElem.Object));
    try std.testing.expectEqual(112, @sizeOf(Elem.DynElem.Function));
    try std.testing.expectEqual(56, @sizeOf(Elem.DynElem.Closure));
}

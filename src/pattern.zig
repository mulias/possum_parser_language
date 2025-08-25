const std = @import("std");
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const ArrayListUnmanaged = std.ArrayListUnmanaged;
const Elem = @import("elem.zig").Elem;
const NumberStringElem = Elem.NumberStringElem;
const StringTable = @import("string_table.zig").StringTable;
const VM = @import("vm.zig").VM;

pub const PatternType = enum {
    Array,
    Boolean,
    Constant,
    FunctionCall,
    Local,
    Merge,
    Null,
    Number,
    Object,
    Range,
    String,
    StringTemplate,
    Repeat,
};

pub const Pattern = union(PatternType) {
    Array: ArrayListUnmanaged(Pattern),
    Boolean: bool,
    Constant: PatternVar,
    FunctionCall: FunctionCallVar,
    Local: PatternVar,
    Merge: ArrayListUnmanaged(Pattern),
    Null: void,
    Number: f64,
    Object: ArrayListUnmanaged(ObjectPair),
    Range: RangePattern,
    String: StringTable.Id,
    StringTemplate: ArrayListUnmanaged(Pattern),
    Repeat: RepeatPattern,

    pub const PatternVar = struct {
        sid: StringTable.Id,
        idx: u8, // stack index/chunk constant id
        negation_count: u2,

        pub fn isNegated(self: PatternVar) bool {
            return self.negation_count % 2 == 1;
        }

        pub fn hasBeenNegated(self: PatternVar) bool {
            return self.negation_count != 0;
        }
    };

    pub const FunctionCallVar = struct {
        function: PatternVar,
        kind: enum { Local, Constant },
        args: ArrayListUnmanaged(Pattern),

        pub fn isNegated(self: FunctionCallVar) bool {
            return self.function.isNegated();
        }

        pub fn hasBeenNegated(self: FunctionCallVar) bool {
            return self.function.hasBeenNegated();
        }
    };

    pub const DestructurePattern = struct {
        left: *Pattern, // The parser/expression to evaluate
        right: *Pattern, // The pattern to match against the result
    };

    pub const ObjectPair = struct {
        key: Pattern,
        value: Pattern,
    };

    pub const RangePattern = struct {
        lower: ?*Pattern,
        upper: ?*Pattern,
    };

    pub const RepeatPattern = struct {
        pattern: *Pattern,
        count: *Pattern,
    };

    pub fn print(self: Pattern, vm: VM, writer: *Writer) Writer.Error!void {
        switch (self) {
            .Local => |pvar| try writer.print("{s}{s}", .{
                negativeSigns(pvar.negation_count),
                vm.strings.get(pvar.sid),
            }),
            .Constant => |pvar| try writer.print("{s}{s}", .{
                negativeSigns(pvar.negation_count),
                vm.strings.get(pvar.sid),
            }),
            .FunctionCall => |fc| {
                try writer.print("{s}{s}(", .{
                    negativeSigns(fc.function.negation_count),
                    vm.strings.get(fc.function.sid),
                });
                for (fc.args.items, 0..) |arg, i| {
                    if (i > 0) try writer.print(", ", .{});
                    try arg.print(vm, writer);
                }
                try writer.print(")", .{});
            },
            .String => |sid| try writer.print("\"{s}\"", .{vm.strings.get(sid)}),
            .Number => |n| try writer.print("{d}", .{n}),
            .Boolean => |b| try writer.print("{s}", .{if (b) "true" else "false"}),
            .Null => try writer.print("null", .{}),
            .Array => |arr| {
                try writer.print("[", .{});
                for (arr.items, 0..) |elem, i| {
                    if (i > 0) try writer.print(", ", .{});
                    try elem.print(vm, writer);
                }
                try writer.print("]", .{});
            },
            .StringTemplate => |template| {
                try writer.print("\"", .{});
                for (template.items) |elem| {
                    switch (elem) {
                        .String => |sId| try writer.print("{s}", .{vm.strings.get(sId)}),
                        .Merge => {
                            try writer.print("%", .{});
                            try elem.print(vm, writer);
                        },
                        else => {
                            try writer.print("%(", .{});
                            try elem.print(vm, writer);
                            try writer.print(")", .{});
                        },
                    }
                }
                try writer.print("\"", .{});
            },
            .Object => |obj| {
                try writer.print("{{", .{});
                for (obj.items, 0..) |pair, i| {
                    if (i > 0) try writer.print(", ", .{});
                    try pair.key.print(vm, writer);
                    try writer.print(": ", .{});
                    try pair.value.print(vm, writer);
                }
                try writer.print("}}", .{});
            },
            .Range => |range| {
                if (range.lower) |lower| try lower.print(vm, writer);
                try writer.print("..", .{});
                if (range.upper) |upper| try upper.print(vm, writer);
            },
            .Merge => |merge_items| {
                try writer.print("(", .{});
                for (merge_items.items, 0..) |elem, i| {
                    if (i > 0) try writer.print(" + ", .{});
                    try elem.print(vm, writer);
                }
                try writer.print(")", .{});
            },
            .Repeat => |repeat| {
                try writer.print("(", .{});
                try repeat.pattern.print(vm, writer);
                try writer.print(" * ", .{});
                try repeat.count.print(vm, writer);
                try writer.print(")", .{});
            },
        }
    }

    pub fn deinit(self: *Pattern, allocator: Allocator) void {
        switch (self.*) {
            .Array => |*array| {
                for (array.items) |*item| {
                    item.deinit(allocator);
                }
                array.deinit(allocator);
            },
            .StringTemplate => |*template| {
                for (template.items) |*item| {
                    item.deinit(allocator);
                }
                template.deinit(allocator);
            },
            .Object => |*object| {
                for (object.items) |*pair| {
                    pair.key.deinit(allocator);
                    pair.value.deinit(allocator);
                }
                object.deinit(allocator);
            },
            .Range => |*range| {
                if (range.lower) |lower| {
                    lower.deinit(allocator);
                    allocator.destroy(lower);
                }
                if (range.upper) |upper| {
                    upper.deinit(allocator);
                    allocator.destroy(upper);
                }
            },
            .Merge => |*mergeList| {
                for (mergeList.items) |*item| {
                    item.deinit(allocator);
                }
                mergeList.deinit(allocator);
            },
            .FunctionCall => |*funcCall| {
                for (funcCall.args.items) |*arg| {
                    arg.deinit(allocator);
                }
                funcCall.args.deinit(allocator);
            },
            .Repeat => |*repeat| {
                repeat.pattern.deinit(allocator);
                allocator.destroy(repeat.pattern);
                repeat.count.deinit(allocator);
                allocator.destroy(repeat.count);
            },
            .Local,
            .Constant,
            .String,
            .Number,
            .Boolean,
            .Null,
            => {
                // No cleanup
            },
        }
    }

    fn negativeSigns(count: u2) []const u8 {
        return switch (count) {
            0 => "",
            1 => "-",
            2 => "--",
            3 => "-",
        };
    }

    /// Determine if pattern value is currently negated - negated, tripple
    /// negated, etc.
    pub fn isNegated(self: Pattern) bool {
        return switch (self) {
            .Local => |l| l.isNegated(),
            .Constant => |c| c.isNegated(),
            .FunctionCall => |fc| fc.isNegated(),
            .NumberString,
            .String,
            .Boolean,
            .Null,
            .Array,
            .StringTemplate,
            .Object,
            .Range,
            .Merge,
            => false,
        };
    }

    /// Determine if pattern been negated at least once - negated, double
    /// negated, etc.
    pub fn hasBeenNegated(self: Pattern) bool {
        return switch (self) {
            .Local => |l| l.hasBeenNegated(),
            .Constant => |c| c.hasBeenNegated(),
            .FunctionCall => |fc| fc.hasBeenNegated(),
            .NumberString,
            .String,
            .Boolean,
            .Null,
            .Array,
            .StringTemplate,
            .Object,
            .Range,
            .Merge,
            => false,
        };
    }
};

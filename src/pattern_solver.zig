const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoHashMapUnmanaged;
const VM = @import("vm.zig").VM;
const Pattern = @import("pattern.zig").Pattern;
const Elem = @import("elem.zig").Elem;
const StringTable = @import("string_table.zig").StringTable;

const Simplified = union(enum) {
    Pattern: Pattern,
    Value: Elem,

    pub fn print(self: Simplified, vm: VM, writer: anytype) !void {
        switch (self) {
            .Pattern => |p| {
                try writer.print("Patern(", .{});
                try p.print(vm, writer);
                try writer.print(")", .{});
            },
            .Value => |v| {
                try writer.print("Value(", .{});
                try v.print(vm, writer);
                try writer.print(")", .{});
            },
        }
    }
};

vm: *VM,
bound_locals: ArrayList(Pattern.PatternVar),
depth: u8,
printSteps: bool,

const PatternSolver = @This();

pub fn init(vm: *VM) PatternSolver {
    return PatternSolver{
        .vm = vm,
        .bound_locals = ArrayList(Pattern.PatternVar){},
        .depth = 1,
        .printSteps = vm.config.printVM or vm.config.printDestructure,
    };
}

pub fn deinit(self: *PatternSolver) void {
    self.bound_locals.deinit(self.vm.allocator);
}

pub const Error = error{
    RuntimeError,
    OutOfMemory,
    ExpectedNumber,
} || VM.Error;

pub fn match(self: *PatternSolver, value: Elem, pattern: Pattern) Error!bool {
    self.bound_locals.shrinkRetainingCapacity(0);
    defer self.bound_locals.shrinkRetainingCapacity(0);

    self.depth = 0;
    defer self.depth = 0;

    if (self.printSteps) {
        try self.vm.writers.debug.print("\nDestructure:\n", .{});
    }

    const success = try self.matchPattern(value, pattern);

    if (!success) {
        try self.resetLocals(0);
    }

    if (self.printSteps) {
        if (success) try self.vm.writers.debug.print("Destructure Success: ", .{});
        if (!success) try self.vm.writers.debug.print("Destructure Failure: ", .{});
        try self.printDestructure(value, pattern);
    }

    return success;
}

fn matchPattern(self: *PatternSolver, value: Elem, pattern: Pattern) Error!bool {
    self.depth = self.depth +| 1;
    defer self.depth = self.depth -| 1;

    if (self.printSteps) {
        try self.printDestructure(value, pattern);
    }

    return switch (pattern) {
        .Array => |p| self.matchArray(value, p),
        .Boolean => |p| self.matchBoolean(value, p),
        .Constant => |p| self.matchConstant(value, p),
        .FunctionCall => |p| self.matchFunctionCall(value, p),
        .Local => |p| self.matchLocal(value, p),
        .Merge => |p| self.matchMerge(value, p),
        .Null => self.matchNull(value),
        .NumberString => |p| self.matchNumberString(value, p),
        .Object => |p| self.matchObject(value, p),
        .Range => |p| self.matchRange(value, p),
        .String => |p| self.matchString(value, p),
        .StringTemplate => |p| self.matchStringTemplate(value, p),
    };
}

fn matchArray(self: *PatternSolver, value: Elem, pattern_array: ArrayList(Pattern)) !bool {
    switch (value) {
        .Dyn => |dyn| {
            if (dyn.dynType != .Array) return false;
            const value_array = dyn.asArray();
            return self.matchArrayPart(value_array.elems.items, pattern_array);
        },
        else => return false,
    }
}

fn matchArrayPart(self: *PatternSolver, value_slice: []Elem, pattern_array: ArrayList(Pattern)) !bool {
    if (pattern_array.items.len != value_slice.len) {
        return false;
    }

    for (value_slice, pattern_array.items) |value_elem, pattern_elem| {
        if (!(try self.matchPattern(value_elem, pattern_elem))) return false;
    }
    return true;
}

fn matchBoolean(_: *PatternSolver, value: Elem, pattern_boolean: bool) !bool {
    switch (value) {
        .Const => |c| switch (c) {
            .True => return pattern_boolean == true,
            .False => return pattern_boolean == false,
            else => return false,
        },
        else => return false,
    }
}

fn matchConstant(self: *PatternSolver, value: Elem, pattern_var: Pattern.PatternVar) Error!bool {
    var pattern_value = self.vm.getConstant(pattern_var.idx);

    if (pattern_value.isDynType(.Function)) {
        const function = pattern_value.Dyn.asFunction();

        // Constant function must be zero-arity, since it was not called with args
        if (function.arity != 0) return Error.RuntimeError;

        pattern_value = try self.executeFunctionOnVM(
            Pattern{ .Constant = pattern_var },
            pattern_value,
            null,
        );
    }

    if (pattern_var.hasBeenNegated() and !pattern_value.isNumber()) {
        // Non-number can't be negated
        return Error.RuntimeError;
    } else if (pattern_var.isNegated()) {
        pattern_value = pattern_value.negateNumber() catch |e| switch (e) {
            error.ExpectedNumber => return Error.RuntimeError,
            else => |other_error| return other_error,
        };
    }

    return self.checkEquality(value, pattern_value);
}

fn matchFunctionCall(self: *PatternSolver, value: Elem, function_call: Pattern.FunctionCallVar) Error!bool {
    var result = try self.evalFunctionCall(function_call);

    if (function_call.hasBeenNegated() and !result.isNumber()) {
        // Non-number can't be negated
        return Error.RuntimeError;
    } else if (function_call.isNegated()) {
        result = result.negateNumber() catch |e| switch (e) {
            error.ExpectedNumber => return Error.RuntimeError,
            else => |other_error| return other_error,
        };
    }

    return self.checkEquality(value, result);
}

fn matchLocal(self: *PatternSolver, value: Elem, pattern_var: Pattern.PatternVar) Error!bool {
    var pattern_value = self.vm.getLocal(pattern_var.idx);

    if (pattern_value.isDynType(.Function)) {
        const function = pattern_value.Dyn.asFunction();

        // Constant function must be zero-arity, since it was not called with args
        if (function.arity != 0) return Error.RuntimeError;

        pattern_value = try self.executeFunctionOnVM(
            Pattern{ .Local = pattern_var },
            pattern_value,
            null,
        );
    }

    if (pattern_value == .ValueVar) {
        // Unbound local variable
        const var_id = pattern_value.ValueVar;

        if (pattern_var.hasBeenNegated() and !value.isNumber()) {
            // Negating an unbound pattern variable is valid, but if the value is
            // not a number the match always fails.
            return false;
        } else if (self.vm.varIdIsPlaceholder(var_id)) {
            // Placeholder variable - always matches, no binding
            return true;
        } else if (pattern_var.isNegated()) {
            // Unbound local - bind the value to negation
            const negated_value = value.negateNumber() catch |e| switch (e) {
                error.ExpectedNumber => return Error.RuntimeError,
                else => |other_error| return other_error,
            };
            try self.setLocal(pattern_var, negated_value);
            return true;
        } else {
            // Unbound local - bind the value
            try self.setLocal(pattern_var, value);
            return true;
        }
    } else {
        // Bound local - check equality
        return self.checkEquality(value, pattern_value);
    }
}

const MergeType = enum {
    Array,
    Boolean,
    Number,
    Object,
    String,
    Untyped,
};

fn matchMerge(self: *PatternSolver, value: Elem, pattern_merge: ArrayList(Pattern)) Error!bool {
    std.debug.assert(pattern_merge.items.len > 0);

    var merge_parts = try ArrayList(Simplified).initCapacity(self.vm.allocator, pattern_merge.items.len);
    defer merge_parts.deinit(self.vm.allocator);

    const merge_type = try self.prepareMergePattern(pattern_merge, &merge_parts);

    const parts = merge_parts.items[0..];

    return switch (merge_type) {
        .Array => self.matchArrayMerge(value, parts),
        .Boolean => self.matchBooleanMerge(value, parts),
        .Number => self.matchNumberMerge(value, parts),
        .Object => self.matchObjectMerge(value, pattern_merge),
        .String => self.matchStringMerge(value, parts),
        .Untyped => self.matchUntypedMerge(value, parts),
    };
}

fn prepareMergePattern(self: *PatternSolver, pattern_merge: ArrayList(Pattern), merge_parts: *ArrayList(Simplified)) Error!MergeType {
    var merge_type: MergeType = .Untyped;

    for (pattern_merge.items) |pattern| {
        const part = try self.simplify(pattern);

        if (pattern != .Merge) {
            try merge_parts.append(self.vm.allocator, part);
        }

        if (merge_type == .Untyped) {
            // Merge type of pattern is set by first part that is not untyped
            merge_type = try self.prepareMergePatternPart(part, merge_parts);
        } else {
            // After determining the merge type all remaining parts must be the same type or untyped
            const part_type = try self.prepareMergePatternPart(part, merge_parts);
            if (part_type != merge_type and part_type != .Untyped) {
                return Error.RuntimeError;
            }
        }
    }

    return merge_type;
}

fn prepareMergePatternPart(self: *PatternSolver, part: Simplified, merge_parts: *ArrayList(Simplified)) Error!MergeType {
    return switch (part) {
        .Value => |elem| switch (elem) {
            .String, .InputSubstring => .String,
            .NumberString, .Number => .Number,
            .Const => |c| switch (c) {
                .True, .False => .Boolean,
                .Null, .Failure => .Untyped,
            },
            .ParserVar, .ValueVar => .Untyped,
            .Dyn => |dyn| switch (dyn.dynType) {
                .String => .String,
                .Array => .Array,
                .Object => .Object,
                .Function, .NativeCode, .Closure => .Untyped,
            },
        },
        .Pattern => |remaining_pattern| switch (remaining_pattern) {
            .Array => .Array,
            .Boolean => .Boolean,
            .Constant => .Untyped,
            .FunctionCall => .Untyped,
            .Local => .Untyped,
            .Merge => |merge| self.prepareMergePattern(merge, merge_parts),
            .Null => .Untyped,
            .NumberString => .Number,
            .Object => .Object,
            .Range => return Error.RuntimeError,
            .String => .String,
            .StringTemplate => .String,
        },
    };
}

fn matchArrayMerge(self: *PatternSolver, value: Elem, parts: []Simplified) !bool {
    var before_unbound_range: usize = 0;
    var after_unbound_range: usize = 0;
    var unbound_part: ?Pattern = null;

    var unbound_part_index: ?usize = null;

    for (parts, 0..) |part, part_index| {
        switch (part) {
            .Value => |elem| {
                if (elem.isDynType(.Array)) {
                    const array = elem.asDyn().asArray();
                    if (unbound_part == null) {
                        before_unbound_range += array.len();
                    } else {
                        after_unbound_range += array.len();
                    }
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| switch (pattern) {
                .Array => |array| {
                    if (unbound_part == null) {
                        before_unbound_range += array.items.len;
                    } else {
                        after_unbound_range += array.items.len;
                    }
                },
                else => {
                    if (unbound_part == null) {
                        unbound_part = pattern;
                        unbound_part_index = part_index;
                    } else {
                        // Array merge can only have one unbound part
                        return Error.RuntimeError;
                    }
                },
            },
        }
    }

    if (!value.isDynType(.Array)) {
        return false;
    }

    const value_array = value.asDyn().asArray();

    if (value_array.elems.items.len < before_unbound_range + after_unbound_range) {
        return false;
    }

    var value_index: usize = 0;

    // Match the before parts
    for (parts) |part| {
        switch (part) {
            .Value => |elem| {
                if (elem.isDynType(.Array)) {
                    const array = elem.asDyn().asArray();
                    const end_index = value_index + array.elems.items.len;
                    if (end_index > value_array.elems.items.len) return false;

                    for (array.elems.items, 0..) |expected_elem, i| {
                        const value_elem = value_array.elems.items[value_index + i];
                        if (!(try self.checkEquality(value_elem, expected_elem))) {
                            return false;
                        }
                    }
                    value_index = end_index;
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| switch (pattern) {
                .Array => |array| {
                    const end_index = value_index + array.items.len;
                    if (end_index > value_array.elems.items.len) return false;

                    if (!(try self.matchArrayPart(value_array.elems.items[value_index..end_index], array))) {
                        return false;
                    }
                    value_index = end_index;
                },
                else => {
                    // This is the unbound pattern - break out to handle the gap
                    break;
                },
            },
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_part) |pattern| {
        const unbound_start = value_index;
        const unbound_end = value_array.elems.items.len - after_unbound_range;

        std.debug.assert(unbound_start <= unbound_end);

        // Create an array element containing the unbound range
        const unbound_elems = value_array.elems.items[unbound_start..unbound_end];
        const unbound_array = try Elem.DynElem.Array.create(self.vm, unbound_elems.len);
        try unbound_array.elems.appendSlice(self.vm.allocator, unbound_elems);
        const unbound_elem = unbound_array.dyn.elem();

        if (!(try self.matchPattern(unbound_elem, pattern))) {
            return false;
        }

        value_index = unbound_end;
    }

    // Match the after parts
    if (unbound_part_index) |unbound_idx| {
        for (parts[(unbound_idx + 1)..]) |part| {
            switch (part) {
                .Value => |elem| {
                    if (elem.isDynType(.Array)) {
                        const array = elem.asDyn().asArray();
                        const end_index = value_index + array.elems.items.len;
                        if (end_index > value_array.elems.items.len) return false;

                        for (array.elems.items, 0..) |expected_elem, i| {
                            const value_elem = value_array.elems.items[value_index + i];
                            if (!(try self.checkEquality(value_elem, expected_elem))) {
                                return false;
                            }
                        }
                        value_index = end_index;
                    } else if (elem.isConst(.Null)) {
                        // Skip null
                    } else {
                        @panic("Internal Error");
                    }
                },
                .Pattern => |pattern| switch (pattern) {
                    .Array => |array| {
                        const end_index = value_index + array.items.len;
                        if (end_index > value_array.elems.items.len) return false;

                        if (!(try self.matchArrayPart(value_array.elems.items[value_index..end_index], array))) {
                            return false;
                        }
                        value_index = end_index;
                    },
                    else => {
                        // Shouldn't have more unbound parts
                        @panic("Internal Error");
                    },
                },
            }
        }
    }

    return true;
}

fn matchBooleanMerge(self: *PatternSolver, value: Elem, parts: []Simplified) !bool {
    var bound_truth = Elem.boolean(false);
    var unbound_part: ?Pattern = null;

    for (parts) |part| {
        switch (part) {
            .Value => |elem| {
                if (try bound_truth.merge(elem, self.vm)) |new_truth| {
                    bound_truth = new_truth;
                } else {
                    // We checked that all parts of the pattern had the same type,
                    // so this shouldn't happen.
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| {
                if (unbound_part == null) {
                    unbound_part = pattern;
                } else {
                    // Boolean merge can only have one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    if (unbound_part) |pattern| {
        if (bound_truth.isConst(.True)) {
            if (value.isEql(bound_truth, self.vm.*)) {
                // `true -> (true + X)
                return (try self.matchPattern(Elem.boolean(false), pattern)) or
                    (try self.matchPattern(Elem.boolean(true), pattern));
            } else {
                // `false -> (true + X)
                return false;
            }
        } else {
            // `value -> (false + X)`
            return self.matchPattern(value, pattern);
        }
    } else {
        // `value -> true` / `value -> false`
        return self.checkEquality(value, bound_truth);
    }
}

fn matchNumberMerge(self: *PatternSolver, value: Elem, parts: []Simplified) !bool {
    var bound_sum = Elem.number(0);
    var unbound_part: ?Pattern = null;

    for (parts) |part| {
        switch (part) {
            .Value => |elem| {
                if (try bound_sum.merge(elem, self.vm)) |new_sum| {
                    bound_sum = new_sum;
                } else {
                    // We checked that all parts of the pattern had the same type,
                    // so this shouldn't happen.
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| {
                if (unbound_part == null) {
                    unbound_part = pattern;
                } else {
                    // Number merge can only have one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    if (!value.isNumber()) {
        return false;
    } else if (unbound_part) |pattern| {
        const diff = (try value.merge(try bound_sum.negateNumber(), self.vm)).?;
        return self.matchPattern(diff, pattern);
    } else {
        return self.checkEquality(value, bound_sum);
    }
}

fn matchObjectMerge(self: *PatternSolver, value: Elem, pattern_merge: ArrayList(Pattern)) !bool {
    if (!value.isDynType(.Object)) {
        return false;
    }

    var value_object = value.asDyn().asObject();

    // Initialize a set of all keys in the value object
    var unmatched_keys = HashMap(StringTable.Id, void){};
    defer unmatched_keys.deinit(self.vm.allocator);

    var iterator = value_object.members.iterator();
    while (iterator.next()) |entry| {
        try unmatched_keys.put(self.vm.allocator, entry.key_ptr.*, {});
    }

    var unbound_part: ?Pattern = null;

    // Process each pattern in the merge
    for (pattern_merge.items) |pattern| {
        switch (pattern) {
            .Object => |pattern_object| {
                // Process bound object patterns
                for (pattern_object.items) |pattern_pair| {
                    if (try self.attemptEval(pattern_pair.key)) |key_value| {
                        const key_sid = try key_value.getOrPutSid(self.vm) orelse return Error.RuntimeError;

                        if (value_object.members.get(key_sid)) |value_object_pair_value| {
                            if (!(try self.matchPattern(value_object_pair_value, pattern_pair.value))) {
                                return false;
                            }
                            // Remove this key from unmatched set
                            _ = unmatched_keys.remove(key_sid);
                        } else {
                            // Value object doesn't have this key
                            return false;
                        }
                    } else {
                        // Unbound key case - search linearly through remaining unmatched keys
                        var found_match = false;
                        var key_iterator = unmatched_keys.iterator();
                        var matched_key: ?StringTable.Id = null;

                        const bound_locals_reset_point = self.bound_locals.items.len;

                        while (key_iterator.next()) |entry| {
                            const obj_key_sid = entry.key_ptr.*;
                            const obj_value = value_object.members.get(obj_key_sid).?;

                            // Try to match the key pattern
                            const key_elem = Elem.string(obj_key_sid);

                            if (try self.matchPattern(key_elem, pattern_pair.key)) {
                                // Key matches, now try to match the value
                                if (try self.matchPattern(obj_value, pattern_pair.value)) {
                                    matched_key = obj_key_sid;
                                    found_match = true;
                                    break;
                                }
                            }

                            // If K/V parts were partially bound we need to reset before trying the next key
                            try self.resetLocals(bound_locals_reset_point);
                        }

                        if (!found_match) {
                            return false;
                        }

                        // Remove the matched key from unmatched set
                        if (matched_key) |key| {
                            _ = unmatched_keys.remove(key);
                        }
                    }
                }
            },
            else => {
                // This should be the unbound part
                if (unbound_part == null) {
                    unbound_part = pattern;
                } else {
                    // Object merge can only have one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_part) |pattern| {
        // Create an object with only the unmatched keys
        const unbound_object = try Elem.DynElem.Object.create(self.vm, unmatched_keys.count());

        var key_iterator = unmatched_keys.iterator();
        while (key_iterator.next()) |entry| {
            const key_sid = entry.key_ptr.*;
            const value_elem = value_object.members.get(key_sid).?;
            try unbound_object.members.put(self.vm.allocator, key_sid, value_elem);
        }

        const unbound_elem = unbound_object.dyn.elem();

        if (!(try self.matchPattern(unbound_elem, pattern))) {
            return false;
        }
    }

    return true;
}

fn matchStringMerge(self: *PatternSolver, value: Elem, parts: []Simplified) !bool {
    var before_unbound_length: usize = 0;
    var after_unbound_length: usize = 0;
    var unbound_part: ?Pattern = null;
    var unbound_part_index: ?usize = null;

    // Calculate lengths and find unbound part
    for (parts, 0..) |part, part_index| {
        switch (part) {
            .Value => |elem| {
                if (elem.stringBytes(self.vm.*)) |part_str| {
                    if (unbound_part == null) {
                        before_unbound_length += part_str.len;
                    } else {
                        after_unbound_length += part_str.len;
                    }
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| {
                if (unbound_part == null) {
                    unbound_part = pattern;
                    unbound_part_index = part_index;
                } else {
                    // String merge can only have one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    const value_str = value.stringBytes(self.vm.*) orelse return false;

    if (value_str.len < before_unbound_length + after_unbound_length) {
        return false;
    }

    var value_index: usize = 0;

    // Match the before parts
    for (parts) |part| {
        switch (part) {
            .Value => |elem| {
                if (elem.stringBytes(self.vm.*)) |part_str| {
                    const end_index = value_index + part_str.len;
                    if (end_index > value_str.len) return false;

                    if (!(try self.matchStringBytes(value_str[value_index..end_index], part_str))) {
                        return false;
                    }
                    value_index = end_index;
                } else if (elem.isConst(.Null)) {
                    // Skip null
                } else {
                    return false;
                }
            },
            .Pattern => break,
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_part) |pattern| {
        const unbound_start = value_index;
        const unbound_end = value_str.len - after_unbound_length;

        std.debug.assert(unbound_start <= unbound_end);

        const unbound_value = value_str[unbound_start..unbound_end];
        const unbound_elem = if (value == .InputSubstring) blk: {
            const elem = try Elem.inputSubstringFromRange(unbound_start, unbound_end, self.vm);
            break :blk elem;
        } else blk: {
            // Allocate a dynamic string
            const dyn_str = try Elem.DynElem.String.create(self.vm, unbound_value.len);
            try dyn_str.concatBytes(unbound_value);
            break :blk dyn_str.dyn.elem();
        };

        if (!(try self.matchPattern(unbound_elem, pattern))) {
            return false;
        }

        value_index = unbound_end;
    }

    // Match the after parts
    if (unbound_part_index) |unbound_idx| {
        for (parts[(unbound_idx + 1)..]) |part| {
            switch (part) {
                .Value => |elem| {
                    if (elem.stringBytes(self.vm.*)) |part_str| {
                        const end_index = value_index + part_str.len;
                        if (end_index > value_str.len) return false;

                        if (!(try self.matchStringBytes(value_str[value_index..end_index], part_str))) {
                            return false;
                        }
                        value_index = end_index;
                    } else if (elem.isConst(.Null)) {
                        // Skip null
                    } else {
                        return false;
                    }
                },
                .Pattern => {
                    // Shouldn't have more unbound parts
                    @panic("Internal Error");
                },
            }
        }
    }

    return true;
}

fn matchUntypedMerge(self: *PatternSolver, value: Elem, merge_parts: []Simplified) !bool {
    var unbound_part: ?Pattern = null;

    for (merge_parts) |part| {
        switch (part) {
            .Value => |elem| {
                std.debug.assert(elem.isConst(.Null));
            },
            .Pattern => |pattern| {
                if (unbound_part == null) {
                    unbound_part = pattern;
                } else {
                    // More than one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    if (unbound_part) |pattern| {
        return self.matchPattern(value, pattern);
    } else {
        return self.matchPattern(value, Pattern{ .Null = undefined });
    }
}

fn matchNull(self: *PatternSolver, value: Elem) bool {
    return value.isEql(Elem.nullConst, self.vm.*);
}

fn matchNumberString(self: *PatternSolver, value: Elem, pattern_number: Elem.NumberStringElem) bool {
    const pattern_elem = (Elem{ .NumberString = pattern_number });
    return value.isEql(pattern_elem, self.vm.*);
}

fn matchObject(self: *PatternSolver, value: Elem, pattern_object: ArrayList(Pattern.ObjectPair)) Error!bool {
    self.depth = self.depth +| 1;
    defer self.depth = self.depth -| 1;

    switch (value) {
        .Dyn => |dyn| {
            if (dyn.dynType != .Object) return false;
            var value_object = dyn.asObject();

            if (pattern_object.items.len != value_object.members.count()) {
                return false;
            }

            // Use a set to track which keys we have matched
            var matched_keys = HashMap(StringTable.Id, void){};
            defer matched_keys.deinit(self.vm.allocator);

            for (pattern_object.items) |pattern_pair| {
                if (try self.attemptEval(pattern_pair.key)) |key_value| {
                    // Bound key case
                    const key_sid = switch (key_value) {
                        .String => |sid| sid,
                        else => return Error.RuntimeError,
                    };

                    if (value_object.members.get(key_sid)) |value_object_pair_value| {
                        if (self.printSteps) {
                            try self.printIndentation();
                            try self.vm.writers.debug.print("{{", .{});
                            try key_value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print(": ", .{});
                            try value_object_pair_value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print("}} -> {{", .{});
                            try key_value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print(": ", .{});
                            try pattern_pair.value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print("}}\n", .{});
                        }

                        if (!(try self.matchPattern(value_object_pair_value, pattern_pair.value))) {
                            return false;
                        }

                        // Mark this key as matched (it's ok to match the same key multiple times)
                        try matched_keys.put(self.vm.allocator, key_sid, {});
                    } else {
                        // Value object doesn't have this key
                        return false;
                    }
                } else {
                    // Unbound key case - search linearly through the object
                    var found_match = false;
                    var iterator = value_object.members.iterator();

                    while (iterator.next()) |entry| {
                        const obj_key_sid = entry.key_ptr.*;
                        const obj_value = entry.value_ptr.*;

                        // Skip keys we've already matched
                        if (matched_keys.contains(obj_key_sid)) {
                            continue;
                        }

                        const bound_locals_reset_point = self.bound_locals.items.len;

                        // Try to match the key pattern
                        const key_elem = Elem.string(obj_key_sid);

                        if (self.printSteps) {
                            try self.printIndentation();
                            try self.vm.writers.debug.print("{{", .{});
                            try key_elem.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print(": ", .{});
                            try obj_value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print("}} -> {{", .{});
                            try pattern_pair.key.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print(": ", .{});
                            try pattern_pair.value.print(self.vm.*, self.vm.writers.debug);
                            try self.vm.writers.debug.print("}}\n", .{});
                        }

                        if (try self.matchPattern(key_elem, pattern_pair.key)) {
                            // Key matches, now try to match the value
                            if (try self.matchPattern(obj_value, pattern_pair.value)) {

                                // Both key and value match - mark this key as matched
                                try matched_keys.put(self.vm.allocator, obj_key_sid, {});
                                found_match = true;
                                break;
                            }
                        }

                        // If K/V parts were partially bound we need to reset before trying the next key.
                        try self.resetLocals(bound_locals_reset_point);
                    }

                    if (!found_match) {
                        return false;
                    }
                }
            }

            return true;
        },
        else => return false,
    }
}

fn matchRange(self: *PatternSolver, value: Elem, pattern_range: Pattern.RangePattern) Error!bool {
    std.debug.assert(pattern_range.lower != null or pattern_range.upper != null);

    if (pattern_range.lower) |pattern_range_lower| {
        if (try self.attemptEval(pattern_range_lower.*)) |lower_limit| {
            // No unbound variable, value must be less than limit
            if (!(try lower_limit.isLessThanOrEqualInRangePattern(value, self.vm.*))) return false;
        } else {
            // Lower bound has unbound variables, match the pattern
            if (!(try self.matchPattern(value, pattern_range_lower.*))) {
                return false;
            }
        }
    }

    if (pattern_range.upper) |pattern_range_upper| {
        if (try self.attemptEval(pattern_range_upper.*)) |upper_limit| {
            // No unbound variable, value must be greater than limit
            if (!(try value.isLessThanOrEqualInRangePattern(upper_limit, self.vm.*))) return false;
        } else {
            // Lower bound has unbound variables, match the pattern
            if (!(try self.matchPattern(value, pattern_range_upper.*))) {
                return false;
            }
        }
    }

    return true;
}

fn matchString(self: *PatternSolver, value: Elem, pattern_sid: StringTable.Id) !bool {
    return self.checkEquality(value, .{ .String = pattern_sid });
}

fn matchStringBytes(self: *PatternSolver, value: []const u8, pattern: []const u8) !bool {
    // Doesn't go through matchPattern, manually update depth
    self.depth = self.depth +| 1;
    defer self.depth = self.depth -| 1;

    if (self.printSteps) {
        try self.printIndentation();
        try self.vm.writers.debug.print("\"{s}\" -> \"{s}\"\n", .{ value, pattern });
    }
    return std.mem.eql(u8, value, pattern);
}

fn matchStringTemplate(self: *PatternSolver, value: Elem, template_pattern: ArrayList(Pattern)) Error!bool {
    var parts = try self.vm.allocator.alloc(Simplified, template_pattern.items.len);
    defer self.vm.allocator.free(parts);

    for (template_pattern.items, 0..) |pattern, i| {
        const simplified = try self.simplify(pattern);

        if (simplified == .Value) {
            parts[i] = .{ .Value = try simplified.Value.toString(self.vm) };
        } else {
            parts[i] = simplified;
        }
    }

    var before_unbound_length: usize = 0;
    var after_unbound_length: usize = 0;
    var unbound_part: ?Pattern = null;
    var unbound_part_index: ?usize = null;

    // Calculate lengths and find unbound part
    for (parts, 0..) |part, part_index| {
        switch (part) {
            .Value => |elem| {
                if (elem.stringBytes(self.vm.*)) |part_str| {
                    if (unbound_part == null) {
                        before_unbound_length += part_str.len;
                    } else {
                        after_unbound_length += part_str.len;
                    }
                } else {
                    @panic("Internal Error");
                }
            },
            .Pattern => |pattern| {
                if (unbound_part == null) {
                    unbound_part = pattern;
                    unbound_part_index = part_index;
                } else {
                    // String merge can only have one unbound part
                    return Error.RuntimeError;
                }
            },
        }
    }

    const value_str = value.stringBytes(self.vm.*) orelse return false;

    if (value_str.len < before_unbound_length + after_unbound_length) {
        return false;
    }

    var value_index: usize = 0;

    // Match the before parts
    for (parts) |part| {
        switch (part) {
            .Value => |elem| {
                if (elem.stringBytes(self.vm.*)) |part_str| {
                    const end_index = value_index + part_str.len;
                    if (end_index > value_str.len) return false;

                    if (!(try self.matchStringBytes(value_str[value_index..end_index], part_str))) {
                        return false;
                    }
                    value_index = end_index;
                } else {
                    @panic("Internal Error");
                }
            },
            .Pattern => break,
        }
    }

    // Handle the unbound pattern if it exists
    if (unbound_part) |pattern| {
        const unbound_start = value_index;
        const unbound_end = value_str.len - after_unbound_length;

        std.debug.assert(unbound_start <= unbound_end);

        const unbound_value = value_str[unbound_start..unbound_end];
        const json_parsed = std.json.parseFromSlice(
            std.json.Value,
            self.vm.allocator,
            unbound_value,
            .{ .parse_numbers = false },
        ) catch |e| switch (e) {
            error.OutOfMemory => |oom| return oom,
            else => return false,
        };
        defer json_parsed.deinit();

        const unbound_elem = try Elem.fromJson(json_parsed.value, self.vm);

        if (!(try self.matchPattern(unbound_elem, pattern))) {
            return false;
        }

        value_index = unbound_end;
    }

    // Match the after parts
    if (unbound_part_index) |unbound_idx| {
        for (parts[(unbound_idx + 1)..]) |part| {
            switch (part) {
                .Value => |elem| {
                    if (elem.stringBytes(self.vm.*)) |part_str| {
                        const end_index = value_index + part_str.len;
                        if (end_index > value_str.len) return false;

                        if (!(try self.matchStringBytes(value_str[value_index..end_index], part_str))) {
                            return false;
                        }
                        value_index = end_index;
                    } else if (elem.isConst(.Null)) {
                        // Skip null
                    } else {
                        return false;
                    }
                },
                .Pattern => {
                    // Shouldn't have more unbound parts
                    @panic("Internal Error");
                },
            }
        }
    }

    return true;
}

fn simplify(self: *PatternSolver, pattern: Pattern) Error!Simplified {
    if (try self.attemptEval(pattern)) |value| {
        return .{ .Value = value };
    } else {
        return .{ .Pattern = pattern };
    }
}

fn attemptEval(self: *PatternSolver, pattern: Pattern) Error!?Elem {
    return switch (pattern) {
        .Array => null,
        .Boolean => |b| Elem.boolean(b),
        .Constant => |c| try self.evalConstant(c),
        .FunctionCall => |fc| try self.evalFunctionCall(fc),
        .Local => |l| try self.evalLocal(l),
        .Merge => null,
        .Null => Elem.nullConst,
        .NumberString => |ns| Elem{ .NumberString = ns },
        .Object => null,
        .Range => null,
        .String => |sid| Elem.string(sid),
        .StringTemplate => null,
    };
}

fn evalConstant(self: *PatternSolver, constant: Pattern.PatternVar) !Elem {
    const value = self.vm.getConstant(constant.idx);

    if (value.isDynType(.Function)) {
        // Value is a function which needs to be evaled
        const function = value.Dyn.asFunction();

        // Must be zero-arity, since it was called without args
        if (function.arity != 0) return Error.RuntimeError;

        return self.executeFunctionOnVM(
            Pattern{ .Constant = constant },
            value,
            null,
        );
    } else {
        return value;
    }
}

fn evalFunctionCall(self: *PatternSolver, function_call: Pattern.FunctionCallVar) !Elem {
    const function = switch (function_call.kind) {
        .Local => blk: {
            const local_value = self.vm.getLocal(function_call.function.idx);
            if (local_value.isDynType(.Function)) {
                break :blk local_value;
            } else {
                // Attempt to call non-function value
                return error.RuntimeError;
            }
        },
        .Constant => self.vm.getConstant(function_call.function.idx),
    };
    const function_arity = function.asDyn().asFunction().arity;

    // If the function was passed in to the parent function as a value
    // arg then we can't ensure at compile time that it's actually a
    // function. We handle this above by failing early for the local
    // var. In the constant case we should know at compile time that
    // it's definitely a function.
    std.debug.assert(function.isDynType(.Function));

    if (function_call.args.items.len != function_arity) {
        // Function called with wrong number of arguments
        return error.RuntimeError;
    }

    var arg_values = ArrayList(Elem){};
    defer arg_values.deinit(self.vm.allocator);

    for (function_call.args.items) |arg| {
        if (try self.attemptEval(arg)) |arg_value| {
            try arg_values.append(self.vm.allocator, arg_value);
        } else {
            // Patterns don't support unbound var in function call
            return Error.RuntimeError;
        }
    }

    return self.executeFunctionOnVM(
        Pattern{ .FunctionCall = function_call },
        function,
        arg_values.items,
    );
}

fn evalLocal(self: *PatternSolver, local: Pattern.PatternVar) !?Elem {
    const value = self.vm.getLocal(local.idx);

    if (value.isDynType(.Function)) {
        // Value is a function which needs to be evaled
        const function = value.Dyn.asFunction();

        // Must be zero-arity, since it was called without args
        if (function.arity != 0) return Error.RuntimeError;

        return try self.executeFunctionOnVM(
            Pattern{ .Local = local },
            value,
            null,
        );
    } else if (value != .ValueVar) {
        return value;
    } else {
        return null;
    }
}

fn checkEquality(self: *PatternSolver, value: Elem, pattern: Elem) !bool {
    if (self.printSteps) {
        try self.printDestructureEquality(value, pattern);
    }

    return value.isEql(pattern, self.vm.*);
}

fn setLocal(self: *PatternSolver, local: Pattern.PatternVar, value: Elem) !void {
    self.vm.setLocal(local.idx, value);
    try self.bound_locals.append(self.vm.allocator, local);
}

fn resetLocals(self: *PatternSolver, index: usize) !void {
    const locals = self.bound_locals.items[index..];

    if (self.printSteps and locals.len > 0) {
        try self.printIndentation();

        try self.vm.writers.debug.print("Reset locals: ", .{});
        for (locals) |local| {
            try (Pattern{ .Local = local }).print(self.vm.*, self.vm.writers.debug);
            try self.vm.writers.debug.print(" ", .{});
        }
        try self.vm.writers.debug.print("\n", .{});
    }

    for (locals) |local| {
        self.vm.setLocal(local.idx, Elem.valueVar(local.sid));
    }
    self.bound_locals.shrinkRetainingCapacity(index);
}

fn executeFunctionOnVM(self: *PatternSolver, pattern: Pattern, function: Elem, args: ?[]Elem) !Elem {
    if (self.printSteps) {
        try self.vm.writers.debug.print("\nEval Pattern Function: ", .{});
        try pattern.print(self.vm.*, self.vm.writers.debug);
        try self.vm.writers.debug.print("\n", .{});
    }

    const arg_count: u8 = if (args) |args_array| @as(u8, @intCast(args_array.len)) else 0;

    try self.vm.push(function);

    if (args) |args_array| {
        for (args_array) |arg| try self.vm.push(arg);
    }

    try self.vm.callFunction(function, arg_count, false);
    try self.vm.runFunction();

    if (self.printSteps) {
        try self.vm.writers.debug.print("\n", .{});
    }

    return self.vm.pop();
}

fn printIndentation(self: *PatternSolver) !void {
    for (0..self.depth) |_| {
        try self.vm.writers.debug.print("    ", .{});
    }
}

fn printDestructure(self: *PatternSolver, value: Elem, pattern: Pattern) !void {
    try self.printIndentation();
    try value.print(self.vm.*, self.vm.writers.debug);
    try self.vm.writers.debug.print(" -> ", .{});
    try pattern.print(self.vm.*, self.vm.writers.debug);
    try self.vm.writers.debug.print("\n", .{});
}

fn printDestructureEquality(self: *PatternSolver, value: Elem, pattern: Elem) Error!void {
    try self.printIndentation();
    try value.print(self.vm.*, self.vm.writers.debug);
    try self.vm.writers.debug.print(" -> ", .{});
    try pattern.print(self.vm.*, self.vm.writers.debug);
    try self.vm.writers.debug.print("\n", .{});
}

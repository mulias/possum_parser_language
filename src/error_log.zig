const std = @import("std");
const ArrayList = std.ArrayListUnmanaged;
const AutoHashMap = std.AutoHashMapUnmanaged;
const StringTable = @import("string_table.zig").StringTable;

pub const ErrorLog = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    
    // Logical call history preserved through tail calls
    logical_call_history: ArrayList(StringTable.Id),
    // Track which calls are tail calls (same length as logical_call_history)
    tail_call_flags: ArrayList(bool),

    // Group all errors by positional offset in input
    errors_by_position: AutoHashMap(usize, PositionErrors),
    
    // Track error patterns by function to detect repetitive failures
    errors_by_function: std.HashMap(FunctionErrorKey, FunctionErrorData, FunctionErrorKeyContext, 80),
    
    pub fn init(allocator: std.mem.Allocator) !*ErrorLog {
        const self = try allocator.create(ErrorLog);
        self.* = ErrorLog{
            .allocator = allocator,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .logical_call_history = ArrayList(StringTable.Id){},
            .tail_call_flags = ArrayList(bool){},
            .errors_by_position = AutoHashMap(usize, PositionErrors){},
            .errors_by_function = std.HashMap(FunctionErrorKey, FunctionErrorData, FunctionErrorKeyContext, 80).init(allocator),
        };
        return self;
    }
    
    pub fn deinit(self: *ErrorLog) void {
        self.logical_call_history.deinit(self.allocator);
        self.tail_call_flags.deinit(self.allocator);
        self.errors_by_position.deinit(self.allocator);
        self.errors_by_function.deinit();
        self.arena.deinit();
        self.allocator.destroy(self);
    }
    
    pub fn addFunctionCall(self: *ErrorLog, function_name: StringTable.Id, is_tail_call: bool) void {
        // Deduplicate direct recursion
        if (self.logical_call_history.items.len > 0) {
            const last_item = self.logical_call_history.items[self.logical_call_history.items.len - 1];
            if (last_item == function_name) return; // Skip duplicate
        }
        
        self.logical_call_history.append(self.allocator, function_name) catch {
            // Ignore allocation errors for error reporting
            return;
        };
        self.tail_call_flags.append(self.allocator, is_tail_call) catch {
            // If tail_call_flags fails, remove the function we just added to keep them in sync
            _ = self.logical_call_history.pop();
        };
    }
    
    pub fn popFunctionCall(self: *ErrorLog) void {
        // Remove the last function from the call history when it returns
        // If it was a tail call, recursively pop until we find a non-tail call
        while (self.logical_call_history.items.len > 0 and self.tail_call_flags.items.len > 0) {
            const was_tail_call = self.tail_call_flags.pop() orelse false;
            _ = self.logical_call_history.pop();
            
            // If this wasn't a tail call, we're done
            if (!was_tail_call) break;
            
            // If it was a tail call, continue popping (it bypassed its End opcode)
        }
    }
    
    pub fn getCurrentCallStack(self: *ErrorLog) []StringTable.Id {
        // Return current logical call history as call stack
        return self.logical_call_history.items;
    }
    
    pub fn addParserFailure(
        self: *ErrorLog, 
        pos: InputPosition, 
        parser_expr: []const u8, 
        parser_type: ParserType, 
        call_stack: []StringTable.Id
    ) !void {
        const arena_allocator = self.arena.allocator();
        
        // Track by function for repetitive pattern detection
        const immediate_function = if (call_stack.len > 0) call_stack[call_stack.len - 1] else 0;
        
        // Copy the parser expression first to avoid dangling pointers
        const copied_parser = try arena_allocator.dupe(u8, parser_expr);
        const copied_function_key = FunctionErrorKey{
            .parser = copied_parser,
            .parser_type = parser_type,
            .function_name = immediate_function,
        };
        
        const function_result = try self.errors_by_function.getOrPut(copied_function_key);
        if (!function_result.found_existing) {
            // First time seeing this parser in this function
            const copied_stack = try arena_allocator.dupe(StringTable.Id, call_stack);
            
            function_result.value_ptr.* = try FunctionErrorData.init(pos.offset, copied_stack, arena_allocator);
            
            // Also add to position-based tracking for this first occurrence
            const position_errors = try self.getOrCreatePositionErrors(pos);
            try position_errors.parser_failures.append(arena_allocator, ParserFailure{
                .parser = copied_parser,
                .parser_type = parser_type,
                .call_stack = copied_stack,
            });
        } else {
            // We've seen this parser in this function before
            function_result.value_ptr.addPosition(pos.offset);
            
            // Only add to position tracking if total count is still low
            // (to avoid cluttering position-based view with repetitive errors)
            const MAX_POSITION_ENTRIES = 6;
            if (function_result.value_ptr.total_count <= MAX_POSITION_ENTRIES) {
                const position_errors = try self.getOrCreatePositionErrors(pos);
                
                // Check for duplicates at this position
                var is_duplicate = false;
                for (position_errors.parser_failures.items) |existing| {
                    if (std.mem.eql(u8, existing.parser, copied_parser) and 
                        existing.parser_type == parser_type and
                        std.mem.eql(StringTable.Id, existing.call_stack, call_stack)) {
                        is_duplicate = true;
                        break;
                    }
                }
                
                if (!is_duplicate) {
                    const copied_stack = try arena_allocator.dupe(StringTable.Id, call_stack);
                    
                    try position_errors.parser_failures.append(arena_allocator, ParserFailure{
                        .parser = copied_parser,
                        .parser_type = parser_type,
                        .call_stack = copied_stack,
                    });
                }
            }
        }
    }
    
    pub fn addDestructureFailure(
        self: *ErrorLog,
        pos: InputPosition,
        value_str: []const u8,
        pattern_str: []const u8,
        call_stack: []StringTable.Id
    ) !void {
        const position_errors = try self.getOrCreatePositionErrors(pos);
        
        // Copy strings to arena
        const arena_allocator = self.arena.allocator();
        const copied_value = try arena_allocator.dupe(u8, value_str);
        const copied_pattern = try arena_allocator.dupe(u8, pattern_str);
        const copied_stack = try arena_allocator.dupe(StringTable.Id, call_stack);
        
        try position_errors.destructure_failures.append(arena_allocator, DestructureFailure{
            .value = copied_value,
            .pattern = copied_pattern,
            .call_stack = copied_stack,
        });
    }
    
    fn getOrCreatePositionErrors(self: *ErrorLog, pos: InputPosition) !*PositionErrors {
        const result = try self.errors_by_position.getOrPut(self.allocator, pos.offset);
        if (!result.found_existing) {
            result.value_ptr.* = PositionErrors{
                .offset = pos.offset,
                .line = pos.line,
                .line_start = pos.line_start,
                .parser_failures = ArrayList(ParserFailure){},
                .destructure_failures = ArrayList(DestructureFailure){},
            };
        }
        return result.value_ptr;
    }
};

pub const InputPosition = struct {
    offset: usize,
    line: usize,
    line_start: usize,
};

pub const FunctionErrorKeyContext = struct {
    pub fn hash(self: @This(), key: FunctionErrorKey) u64 {
        _ = self;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(key.parser);
        hasher.update(std.mem.asBytes(&key.parser_type));
        hasher.update(std.mem.asBytes(&key.function_name));
        return hasher.final();
    }
    
    pub fn eql(self: @This(), a: FunctionErrorKey, b: FunctionErrorKey) bool {
        _ = self;
        return std.mem.eql(u8, a.parser, b.parser) and
               a.parser_type == b.parser_type and
               a.function_name == b.function_name;
    }
};

pub const FunctionErrorKey = struct {
    parser: []const u8,           // Parser expression: "pattern", '0'..'9', etc.
    parser_type: ParserType,
    function_name: StringTable.Id, // Immediate function containing this parser
};

pub const FunctionErrorData = struct {
    first_positions: std.BoundedArray(usize, 3),  // First 3 failure positions
    last_positions: std.BoundedArray(usize, 3),   // Last 3 failure positions (sliding window)
    total_count: usize,
    first_call_stack: []StringTable.Id,           // Call stack for error reporting
    
    pub fn init(position: usize, call_stack: []StringTable.Id, arena: std.mem.Allocator) !FunctionErrorData {
        var first_positions = std.BoundedArray(usize, 3).init(0) catch unreachable;
        var last_positions = std.BoundedArray(usize, 3).init(0) catch unreachable;
        
        first_positions.appendAssumeCapacity(position);
        last_positions.appendAssumeCapacity(position);
        
        return FunctionErrorData{
            .first_positions = first_positions,
            .last_positions = last_positions,
            .total_count = 1,
            .first_call_stack = try arena.dupe(StringTable.Id, call_stack),
        };
    }
    
    pub fn addPosition(self: *FunctionErrorData, position: usize) void {
        self.total_count += 1;
        
        // Add to first_positions if not full
        if (self.first_positions.len < 3) {
            self.first_positions.appendAssumeCapacity(position);
        }
        
        // Always update last_positions (sliding window)
        if (self.last_positions.len < 3) {
            self.last_positions.appendAssumeCapacity(position);
        } else {
            // Shift left and add new position
            self.last_positions.buffer[0] = self.last_positions.buffer[1];
            self.last_positions.buffer[1] = self.last_positions.buffer[2];
            self.last_positions.buffer[2] = position;
        }
    }
};

pub const PositionErrors = struct {
    offset: usize,
    line: usize,
    line_start: usize,
    parser_failures: ArrayList(ParserFailure),
    destructure_failures: ArrayList(DestructureFailure),
};

pub const ParserFailure = struct {
    parser: []const u8,          // Parser expression as string (e.g., "forward", '0'..'9')
    parser_type: ParserType,
    call_stack: []StringTable.Id, // Snapshot of call stack when failure occurred
};

pub const ParserType = enum {
    String,              // "literal"
    Number,              // Any number
    CharacterRange,      // 'a'..'z'
    IntegerRange,        // 1..10
    Named,               // Named parser via @fail function
};

pub const DestructureFailure = struct {
    value: []const u8,           // String representation of value
    pattern: []const u8,         // String representation of pattern
    call_stack: []StringTable.Id,
};
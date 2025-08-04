# Possum Error Reporting Implementation Plan

## Overview

Implement comprehensive error reporting that collects all parsing and pattern matching failures at each position, grouping them to show users all possible expected inputs.

## Data Structure Design

```zig
// error_log.zig
pub const ErrorLog = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    
    // Logical call history preserved through tail calls
    logical_call_history: std.RingBuffer,
    call_history_buffer: [50]StringTable.Id,

    // Group all errors by positional offset in input
    errors_by_position: std.AutoHashMap(usize, PositionErrors),
    
    // Track error patterns by function to detect repetitive failures
    errors_by_function: std.AutoHashMap(FunctionErrorKey, FunctionErrorData),
    
    pub fn init(allocator: std.mem.Allocator) !*ErrorLog {
        var self = try allocator.create(ErrorLog);
        self.arena = std.heap.ArenaAllocator.init(allocator);
        self.logical_call_history = std.RingBuffer.init(&self.call_history_buffer);
        self.errors_by_position = std.AutoHashMap(usize, PositionErrors).init(allocator);
        self.errors_by_function = std.AutoHashMap(FunctionErrorKey, FunctionErrorData).init(allocator);
        return self;
    }
    
    pub fn addFunctionCall(self: *ErrorLog, function_name: StringTable.Id) void {
        // Deduplicate direct recursion
        if (self.logical_call_history.len() > 0) {
            const last_item = self.logical_call_history.peekItem(self.logical_call_history.len() - 1);
            if (last_item == function_name) return; // Skip duplicate
        }
        
        self.logical_call_history.writeItem(function_name) catch {
            // Ring buffer handles overflow automatically
        };
    }
    
    pub fn getCurrentCallStack(self: *ErrorLog) []StringTable.Id {
        // Return current logical call history as call stack
        return self.logical_call_history.data[0..self.logical_call_history.len()];
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
        const function_key = FunctionErrorKey{
            .parser = parser_expr,
            .parser_type = parser_type,
            .function_name = immediate_function,
        };
        
        const function_result = try self.errors_by_function.getOrPut(function_key);
        if (!function_result.found_existing) {
            // First time seeing this parser in this function
            const copied_parser = try arena_allocator.dupe(u8, parser_expr);
            const copied_stack = try arena_allocator.dupe(StringTable.Id, call_stack);
            
            function_result.value_ptr.* = try FunctionErrorData.init(pos.offset, copied_stack, arena_allocator);
            
            // Also add to position-based tracking for this first occurrence
            const position_errors = try self.getOrCreatePositionErrors(pos);
            try position_errors.parser_failures.append(ParserFailure{
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
                    if (std.mem.eql(u8, existing.parser, parser_expr) and 
                        existing.parser_type == parser_type and
                        std.mem.eql(StringTable.Id, existing.call_stack, call_stack)) {
                        is_duplicate = true;
                        break;
                    }
                }
                
                if (!is_duplicate) {
                    const copied_parser = try arena_allocator.dupe(u8, parser_expr);
                    const copied_stack = try arena_allocator.dupe(StringTable.Id, call_stack);
                    
                    try position_errors.parser_failures.append(ParserFailure{
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
        
        try position_errors.destructure_failures.append(DestructureFailure{
            .value = copied_value,
            .pattern = copied_pattern,
            .call_stack = copied_stack,
        });
    }
    
    fn getOrCreatePositionErrors(self: *ErrorLog, pos: InputPosition) !*PositionErrors {
        const result = try self.errors_by_position.getOrPut(pos.offset);
        if (!result.found_existing) {
            const arena_allocator = self.arena.allocator();
            result.value_ptr.* = PositionErrors{
                .offset = pos.offset,
                .line = pos.line,
                .line_start = pos.line_start,
                .parser_failures = std.ArrayList(ParserFailure).init(arena_allocator),
                .destructure_failures = std.ArrayList(DestructureFailure).init(arena_allocator),
            };
        }
        return result.value_ptr;
    }
};

pub const FunctionErrorKey = struct {
    parser: []const u8,           // Parser expression: "pattern", '0'..'9', etc.
    parser_type: ParserType,
    function_name: StringTable.Id, // Immediate function containing this parser
    
    pub fn hash(self: FunctionErrorKey) u64 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(self.parser);
        hasher.update(std.mem.asBytes(&self.parser_type));
        hasher.update(std.mem.asBytes(&self.function_name));
        return hasher.final();
    }
    
    pub fn eql(self: FunctionErrorKey, other: FunctionErrorKey) bool {
        return std.mem.eql(u8, self.parser, other.parser) and
               self.parser_type == other.parser_type and
               self.function_name == other.function_name;
    }
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
```

## Example Error Outputs

### Example 1: Multiple Parser Failures (Advent of Code)
```
Error at line 1, column 11: parsing failed at 'down 5'

Expected one of:
  • '0'..'9'
      in: input → commands → command → integer → digit
  • "\n"
      in: input → commands → separator → newline
  • end_of_input
      in: input → end_of_input

Input:
1 | forward 5down 5
           ^~~~~~~
```

### Example 2: Pattern Matching Failure
```
Error at line 3, column 5: pattern match failed

Value '123' did not match pattern '["abc", 456]'
  in: parse_data → validate → check_format
```

### Example 3: Or Combinator Natural Grouping
```
Error at line 2, column 8: parsing failed at 'troo)'

Expected one of:
  • "true"
      in: main → boolean_expr → bool
  • "false"
      in: main → boolean_expr → bool
  • identifier
      in: main → boolean_expr → variable

Input:
2 | while (troo)
          ^~~~
```

## Implementation Steps

### Phase 1: Core Infrastructure

1. **Create error_log.zig** with the data structures above

2. **Add ErrorLog to VM struct**:
   ```zig
   // In vm.zig
   error_log: *ErrorLog = undefined,
   ```

3. **Initialize error log in VM init**:
   ```zig
   self.error_log = try ErrorLog.init(self.allocator);
   ```

### Phase 2: Refactor Failure Handling

1. **Replace pushFailure with variant that tracks error info**:
   ```zig
   // Current pushFailure becomes:
   pub fn pushFailure(self: *VM) !void {
       try self.push(Elem.failureConst);
   }

   // Add new variants:
   pub fn pushParserFailure(self: *VM, parser_expr: []const u8, parser_type: ParserType) !void {
       try self.push(Elem.failureConst);
       try self.error_log.addParserFailure(self.inputPos, parser_expr, parser_type, self.frames);
   }

   pub fn pushDestructureFailure(self: *VM, value: Elem, pattern: []const u8) !void {
       try self.push(Elem.failureConst);
       const value_str = try value.toString(self.allocator);
       try self.error_log.addDestructureFailure(self.inputPos, value_str, pattern, self.frames);
   }
   ```

2. **Convert pop-check-push patterns to peek**:
   ```zig
   // Before (example from And opcode):
   const rhs = self.pop();
   if (rhs.isFailure()) {
       _ = self.pop();
       try self.pushFailure();
   }

   // After:
   if (self.peekIsFailure()) {
       _ = self.pop(); // pop rhs
       _ = self.pop(); // pop lhs
       try self.pushFailure(); // Just propagate existing failure
   }
   ```

### Phase 3: Update Failure Creation Sites

1. **Parser opcodes (String, Number, CharacterRange, IntegerRange)**:
   ```zig
   // Example for String opcode:
   .String => {
       const str = self.readString();
       if (!self.matchString(str)) {
           try self.pushParserFailure(str, .String);
       } else {
           try self.push(Elem.inputSubstring(start, end));
       }
   }
   ```

2. **CharacterRange and IntegerRange opcodes**:
   ```zig
   // Example for CharacterRange:
   .CharacterRange => {
       const start_char = self.readU32();
       const end_char = self.readU32();
       if (!self.matchCharInRange(start_char, end_char)) {
           const expr = try std.fmt.allocPrint(self.allocator, "'{u}'..'{u}'", .{start_char, end_char});
           try self.pushParserFailure(expr, .CharacterRange);
       }
   }
   ```

3. **Destructure opcode**:
   ```zig
   .Destructure => {
       const pattern = self.pop();
       const value = self.pop();
       if (!self.tryDestructure(value, pattern)) {
           const pattern_str = try pattern.toString(self.allocator);
           try self.pushDestructureFailure(value, pattern_str);
       }
   }
   ```

4. **Handle @fail function**:
   ```zig
   // In Fail opcode (src/vm.zig):
   .Fail => {
       const current_function = self.frame().function.name;
       const caller_name = self.strings.get(current_function);
       try self.pushParserFailure(caller_name, .Named);
   }
   ```

5. **Track function calls in logical history**:
   ```zig
   // In callFunction for all named function calls:
   pub fn callFunction(self: *VM, elem: Elem, argCount: u8, isTailPosition: bool) Error!void {
       // ... existing logic ...
       
       // When calling a named function, add to logical history
       if (function.name != null) { // Only for named functions
           self.error_log.addFunctionCall(function.name);
       }
       
       // ... continue with existing tail call logic ...
   }
   ```

6. **Update error collection to use logical call history**:
   ```zig
   // In pushParserFailure and pushDestructureFailure:
   pub fn pushParserFailure(self: *VM, parser_expr: []const u8, parser_type: ParserType) !void {
       try self.push(Elem.failureConst);
       
       // Use logical call history from error log
       const call_stack = self.error_log.getCurrentCallStack();
       try self.error_log.addParserFailure(self.inputPos, parser_expr, parser_type, call_stack);
   }
   ```

### Phase 4: Error Reporting

**Trigger**: Error reporting happens after VM stops running and top stack value is a failure.

1. **Format and display errors**:
   ```zig
   pub fn reportErrors(vm: *VM) !void {
       if (vm.peek(0).isFailure()) {
           try vm.writers.err.print("Parse failed:\n\n", .{});
           
           // First, report any high-frequency patterns from function tracking
           var function_iterator = vm.error_log.errors_by_function.iterator();
           while function_iterator.next()) |entry| {
               const data = entry.value_ptr;
               if (data.total_count > 6) {
                   try vm.formatRepetitiveError(entry.key_ptr, data);
               }
           }
           
           // Then, find position with most errors for detailed breakdown
           var best_position: ?usize = null;
           var most_errors: usize = 0;
           
           var position_iterator = vm.error_log.errors_by_position.iterator();
           while (position_iterator.next()) |entry| {
               const total_errors = entry.value_ptr.parser_failures.items.len + 
                                  entry.value_ptr.destructure_failures.items.len;
               if (total_errors > most_errors) {
                   most_errors = total_errors;
                   best_position = entry.key_ptr.*;
               }
           }
           
           if (best_position) |pos| {
               try vm.formatErrorsAtPosition(pos);
           }
       }
   }
   
   fn formatRepetitiveError(vm: *VM, key: *const FunctionErrorKey, data: *const FunctionErrorData) !void {
       const clean_stack = try vm.cleanCallStack(data.first_call_stack);
       defer vm.allocator.free(clean_stack);
       
       try vm.writers.err.print("Expected {s}", .{key.parser});
       
       if (data.total_count <= 6) {
           // Show all positions
           try vm.writers.err.print(" at positions ");
           for (data.first_positions.constSlice(), 0..) |pos, i| {
               if (i > 0) try vm.writers.err.print(", ");
               try vm.writers.err.print("{}", .{pos});
           }
       } else {
           // Show first few, last few, and total
           try vm.writers.err.print(" at positions ");
           for (data.first_positions.constSlice(), 0..) |pos, i| {
               if (i > 0) try vm.writers.err.print(", ");
               try vm.writers.err.print("{}", .{pos});
           }
           try vm.writers.err.print("...");
           for (data.last_positions.constSlice(), 0..) |pos, i| {
               try vm.writers.err.print(" {}", .{pos});
               if (i < data.last_positions.len - 1) try vm.writers.err.print(",");
           }
           try vm.writers.err.print(" ({} total attempts)", .{data.total_count});
       }
       
       if (clean_stack.len > 0) {
           try vm.writers.err.print("\n    in: ");
           for (clean_stack, 0..) |name_id, i| {
               const name = vm.strings.get(name_id);
               if (i > 0) try vm.writers.err.print(" → ");
               try vm.writers.err.print("{s}", .{name});
           }
       }
       try vm.writers.err.print("\n\n");
   }
   
   fn formatErrorsAtPosition(vm: *VM, position: usize) !void {
       const pos_errors = vm.error_log.errors_by_position.get(position).?;
       
       // Show all parser failures at this position
       for (pos_errors.parser_failures.items) |failure| {
           const clean_stack = try vm.cleanCallStack(failure.call_stack);
           try vm.writers.err.print("  • {s}\n", .{failure.parser});
           if (clean_stack.len > 0) {
               try vm.writers.err.print("      in: ");
               for (clean_stack, 0..) |name_id, i| {
                   const name = vm.strings.get(name_id);
                   if (i > 0) try vm.writers.err.print(" → ");
                   try vm.writers.err.print("{s}", .{name});
               }
               try vm.writers.err.print("\n");
           }
       }
       
       // Show all destructure failures at this position  
       for (pos_errors.destructure_failures.items) |failure| {
           const clean_stack = try vm.cleanCallStack(failure.call_stack);
           try vm.writers.err.print("Value '{s}' did not match pattern '{s}'\n", 
                                   .{ failure.value, failure.pattern });
           if (clean_stack.len > 0) {
               try vm.writers.err.print("  in: ");
               for (clean_stack, 0..) |name_id, i| {
                   const name = vm.strings.get(name_id);
                   if (i > 0) try vm.writers.err.print(" → ");
                   try vm.writers.err.print("{s}", .{name});
               }
               try vm.writers.err.print("\n");
           }
       }
   }
   
   fn cleanCallStack(vm: *VM, call_stack: []StringTable.Id) ![]StringTable.Id {
       var cleaned = std.ArrayList(StringTable.Id).init(vm.allocator);
       
       for (call_stack) |name_id| {
           const name = vm.strings.get(name_id);
           // Skip @ functions, _ prefixed functions, and @main
           if (!std.mem.startsWith(u8, name, "@") and 
               !std.mem.startsWith(u8, name, "_") and
               !std.mem.eql(u8, name, "@main")) {
               try cleaned.append(name_id);
           }
       }
       
       return cleaned.toOwnedSlice();
   }
   ```

2. **Handle edge cases**:
   - **Empty call stack**: Don't show "in:" line if no named functions remain after cleaning
   - **Anonymous functions**: `@fn1234` functions are filtered out during call stack cleaning
   - **Memory management**: Arena allocator is freed when VM is destroyed

## Key Benefits of This Design

1. **Simplicity**: Errors naturally group by position without special Or handling
2. **Completeness**: Captures all failures at the furthest parse position
3. **Clarity**: Separates parsing failures from pattern matching failures
4. **Performance**: Only collects errors after initial failure detected
5. **User-friendly**: Shows all possibilities at the failure point

## Success Metrics

- All parser attempts at a position are captured and displayed
- Error messages clearly show what was expected vs. what was found
- Call stacks are clean and readable
- Pattern matching failures show clear value/pattern mismatch
- Performance impact is minimal (only on parse failure)

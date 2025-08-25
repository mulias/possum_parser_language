const std = @import("std");
const Region = @import("region.zig").Region;

/// Information about a line in the source code
const LineInfo = struct {
    start: usize,
    end: usize, // exclusive, points to newline or end of source
    line_number: usize,
};

/// Configuration for highlighting
pub const HighlightConfig = struct {
    context_lines: usize = 2,
    underline_char: u8 = '^',
    show_line_numbers: bool = true,
};

/// Parse source code into line information
fn parseLines(source: []const u8, allocator: std.mem.Allocator) !std.ArrayListUnmanaged(LineInfo) {
    var lines = std.ArrayListUnmanaged(LineInfo){};

    if (source.len == 0) {
        return lines;
    }

    var line_start: usize = 0;
    var line_number: usize = 1;

    for (source, 0..) |char, i| {
        if (char == '\n') {
            try lines.append(allocator, LineInfo{
                .start = line_start,
                .end = i,
                .line_number = line_number,
            });
            line_start = i + 1;
            line_number += 1;
        }
    }

    // Add the last line if it doesn't end with newline, or if it ends with newline (empty final line)
    if (line_start <= source.len) {
        try lines.append(allocator, LineInfo{
            .start = line_start,
            .end = source.len,
            .line_number = line_number,
        });
    }

    return lines;
}

/// Result type for line finding functions
const AffectedLines = struct {
    start_line: ?usize,
    end_line: ?usize,
};

/// Find which lines contain or are affected by the region
fn findAffectedLines(lines: []const LineInfo, region: Region) AffectedLines {
    var start_line: ?usize = null;
    var end_line: ?usize = null;

    for (lines, 0..) |line, i| {
        // Check if region starts in this line
        if (start_line == null and region.start >= line.start and region.start <= line.end) {
            start_line = i;
        }

        // Check if region ends in this line
        if (region.end >= line.start and region.end <= line.end) {
            end_line = i;
        }
    }

    return .{ .start_line = start_line, .end_line = end_line };
}

/// Find the line containing a specific position (for zero-length regions)
fn findPositionLine(lines: []const LineInfo, position: usize) AffectedLines {
    for (lines, 0..) |line, i| {
        if (position >= line.start and position <= line.end) {
            return .{ .start_line = i, .end_line = i };
        }
    }
    return .{ .start_line = null, .end_line = null };
}

/// Calculate the range of lines to display with context
fn calculateDisplayRange(affected_start: usize, affected_end: usize, total_lines: usize, context: usize) struct {
    start: usize,
    end: usize,
} {
    const start = if (affected_start >= context) affected_start - context else 0;
    const end = @min(affected_end + context + 1, total_lines);
    return .{ .start = start, .end = end };
}

/// Calculate the width needed for line numbers
fn calculateLineNumberWidth(max_line_number: usize) usize {
    if (max_line_number == 0) return 1;
    var width: usize = 0;
    var num = max_line_number;
    while (num > 0) {
        width += 1;
        num /= 10;
    }
    return width;
}

/// Generate underline for a region within a line
fn writeUnderline(
    writer: anytype,
    line: LineInfo,
    region: Region,
    source: []const u8,
    line_number_width: usize,
    show_line_numbers: bool,
    underline_char: u8,
) !void {
    // Calculate the positions within the line
    const region_start = @max(region.start, line.start);
    const region_end = @min(region.end, line.end);

    if (region_start >= region_end) return; // No overlap

    // Write line number padding and pipe symbol if needed
    if (show_line_numbers) {
        // Pad with spaces to match line number width, then add " ▏ "
        var padding = line_number_width;
        while (padding > 0) {
            try writer.print(" ", .{});
            padding -= 1;
        }
        try writer.print(" ▏ ", .{});
    }

    // Get line content and find first non-whitespace character
    const line_content = source[line.start..line.end];
    var first_non_whitespace: ?usize = null;
    for (line_content, 0..) |char, i| {
        if (char != ' ' and char != '\t') {
            first_non_whitespace = i;
            break;
        }
    }

    const underline_start = region_start - line.start;
    const underline_end = region_end - line.start;

    // Write spaces up to the start of the region, but skip leading whitespace
    // if the entire region spans the leading whitespace
    var skip_leading_whitespace = false;
    if (first_non_whitespace) |first_non_ws| {
        // Skip leading whitespace if the region completely contains the non-whitespace part
        if (underline_start <= first_non_ws and underline_end > first_non_ws) {
            skip_leading_whitespace = true;
        }
    }

    for (line_content, 0..) |char, i| {
        const abs_pos = line.start + i;
        if (abs_pos >= region_start) break;

        if (char == '\t') {
            try writer.print("\t", .{});
        } else {
            try writer.print(" ", .{});
        }
    }

    // Write underline characters, potentially skipping leading whitespace
    for (line_content[underline_start..underline_end], underline_start..) |char, i| {
        if (skip_leading_whitespace and first_non_whitespace != null and i < first_non_whitespace.?) {
            // Skip underlining leading whitespace when appropriate
            if (char == '\t') {
                try writer.print("\t", .{});
            } else {
                try writer.print(" ", .{});
            }
        } else {
            // Underline this character
            if (char == '\t') {
                try writer.print("\t", .{});
            } else {
                try writer.print("{c}", .{underline_char});
            }
        }
    }

    try writer.print("\n", .{});
}

/// Check if source is single line (no newlines)
fn isSingleLine(source: []const u8) bool {
    for (source) |char| {
        if (char == '\n') return false;
    }
    return true;
}

pub fn highlightRegion(source: []const u8, region: Region, writer: anytype, config: HighlightConfig) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Handle empty source - return empty output
    if (source.len == 0) {
        return;
    }

    // Clamp region to source bounds
    const clamped_region = Region.new(
        @min(region.start, source.len),
        @min(region.end, source.len),
    );

    // Zero-length regions are treated as positions - show context but no underline
    const is_zero_length = clamped_region.start >= clamped_region.end;

    // Parse lines
    var lines = try parseLines(source, allocator);
    defer lines.deinit(allocator);

    if (lines.items.len == 0) {
        try writer.print("(no lines found)\n", .{});
        return;
    }

    // Determine if we should show line numbers
    const show_line_numbers = config.show_line_numbers and !isSingleLine(source);

    // Find affected lines
    const affected = if (is_zero_length)
        // For zero-length regions, find the line containing the position
        findPositionLine(lines.items, clamped_region.start)
    else
        findAffectedLines(lines.items, clamped_region);

    if (affected.start_line == null or affected.end_line == null) {
        try writer.print("(region not found in source)\n", .{});
        return;
    }

    // Calculate display range
    const display_range = calculateDisplayRange(
        affected.start_line.?,
        affected.end_line.?,
        lines.items.len,
        config.context_lines,
    );

    // Calculate line number width for formatting
    const line_number_width = if (show_line_numbers)
        calculateLineNumberWidth(lines.items[display_range.end - 1].line_number)
    else
        0;

    // Check if we need to truncate (region spans more than 4 lines)
    const region_line_count = if (affected.start_line != null and affected.end_line != null)
        affected.end_line.? - affected.start_line.? + 1
    else
        0;

    const should_truncate = !is_zero_length and region_line_count > 4;

    // Display lines
    for (lines.items[display_range.start..display_range.end], display_range.start..) |line, line_index| {
        // Check if we should skip this line due to truncation
        if (should_truncate and line_index > affected.start_line.? and line_index < affected.end_line.?) {
            // Skip middle lines, but show truncation indicator after first line
            if (line_index == affected.start_line.? + 1) {
                // Write truncation message with proper format
                if (show_line_numbers) {
                    const skipped_lines = affected.end_line.? - affected.start_line.? - 1;

                    // Empty line before message
                    try writer.print("\n", .{});

                    // Centered message "... N lines ..."
                    var padding = line_number_width + 3; // for number width + " ▏ "
                    while (padding > 0) {
                        try writer.print(" ", .{});
                        padding -= 1;
                    }
                    try writer.print("... {} lines ...\n", .{skipped_lines});

                    // Empty line after message
                    try writer.print("\n", .{});
                }
            }
            continue;
        }

        // Write line number if needed
        if (show_line_numbers) {
            // Format line number with right alignment and proper width
            var line_num_buf: [16]u8 = undefined;
            const line_num_str = std.fmt.bufPrint(&line_num_buf, "{d}", .{line.line_number}) catch "?";

            // Pad with spaces on the left to achieve right alignment
            const padding = if (line_number_width > line_num_str.len)
                line_number_width - line_num_str.len
            else
                0;

            var i: usize = 0;
            while (i < padding) {
                try writer.print(" ", .{});
                i += 1;
            }

            try writer.print("{s} ▏", .{line_num_str});
        }

        // Write line content
        const line_content = source[line.start..line.end];
        if (show_line_numbers) {
            // Multi-line format: add space before content if content exists
            if (line_content.len > 0) {
                try writer.print(" {s}\n", .{line_content});
            } else {
                try writer.print("\n", .{});
            }
        } else {
            // Single-line format: no prefix
            try writer.print("{s}\n", .{line_content});
        }

        // Write underline if this line contains the region and it's not zero-length
        if (!is_zero_length and line_index >= affected.start_line.? and line_index <= affected.end_line.?) {
            try writeUnderline(
                writer,
                line,
                clamped_region,
                source,
                line_number_width,
                show_line_numbers,
                config.underline_char,
            );
        }
    }
}

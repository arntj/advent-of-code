const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const mem = std.mem;

// Solves AoC 2023 day 3, and returns parts 1 and 2 solutions.
pub fn solve(allocator: mem.Allocator, lines: []const []const u8) ![2]u32 {
    // Solutions for part 1 and part 2.
    var solution = [2]u32{ 0, 0 };

    // Iterate over lines in input.
    for (0..lines.len) |i| {
        const line = lines[i];

        // Iterate over each character in line.
        for (0..line.len) |j| {
            const c = line[j];

            // Ignore empty spaces or digits.
            if (c == '.' or ascii.isDigit(c)) continue;

            // Find adjacent numbers for this part.
            const adjacent_numbers = try getAdjacentNumbers(allocator, lines, i, j);
            defer allocator.free(adjacent_numbers);

            // Gears with two part numbers should add to part 2 solution.
            if (c == '*' and adjacent_numbers.len == 2) {
                solution[1] += adjacent_numbers[0] * adjacent_numbers[1];
            }

            // All parts add to part 1 solution.
            for (adjacent_numbers) |num| {
                solution[0] += num;
            }
        }
    }

    return solution;
}

test "getAdjacentNumbers finds numbers adjacent to part" {
    const allocator = std.testing.allocator;
    const input = [_][]const u8{
        "467..114",
        "...*....",
        "..35..63",
    };

    const result = try getAdjacentNumbers(allocator, &input, 1, 3);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(@as(u32, 467), result[0]);
    try std.testing.expectEqual(@as(u32, 35), result[1]);
}

test "getAdjacentNumbers finds numbers adjacent to parts close to upper left edge of input" {
    const allocator = std.testing.allocator;
    const input = [_][]const u8{
        "*67..114",
        ".449....",
        "..35..63",
    };

    const result = try getAdjacentNumbers(allocator, &input, 0, 0);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(@as(u32, 67), result[0]);
    try std.testing.expectEqual(@as(u32, 449), result[1]);
}

test "getAdjacentNumbers finds numbers adjacent to parts close to lower right edge of input" {
    const allocator = std.testing.allocator;
    const input = [_][]const u8{
        ".....114",
        "....222.",
        "..35.6.*",
    };

    const result = try getAdjacentNumbers(allocator, &input, 2, 7);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u32, 222), result[0]);
}

// Finds adjacent numbers for a part given it's position in input.
// Caller owns the resulting slice.
fn getAdjacentNumbers(allocator: mem.Allocator, lines: []const []const u8, row: usize, col: usize) ![]u32 {
    // List of numbers.
    var numbers = std.ArrayList(u32).init(allocator);

    // Find area to search for numbers within.
    // Normally a 3x3 box but might be smaller if close to the edges of the input area.
    const from_row = if (row == 0) 0 else row - 1;
    const to_row = @min(row + 1, lines.len - 1);
    const from_col = if (col == 0) 0 else col - 1;
    const to_col = @min(col + 1, lines[row].len - 1);

    // Iterate over rows in search area.
    for (from_row..to_row + 1) |i| {
        var j = from_col;

        // Iterate over cols in search area.
        while (j <= to_col) : (j += 1) {
            const line = lines[i];
            const c = line[j];

            if (!ascii.isDigit(c)) continue;

            // A digit was found. Expand in both directions to find the whole number.
            var start = j;

            while (start > 0 and ascii.isDigit(line[start - 1])) start -= 1;
            while (j < line.len - 1 and ascii.isDigit(line[j + 1])) j += 1;

            // The whole number has been found, convert to int and add to result.
            const number = try fmt.parseInt(u32, line[start .. j + 1], 10);
            try numbers.append(number);
        }
    }

    // Return final list of numbers adjacent to given part.
    return numbers.toOwnedSlice();
}

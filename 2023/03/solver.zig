const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const mem = std.mem;

pub fn solve(allocator: mem.Allocator, lines: [][]const u8) ![2]u32 {
    var solution = [2]u32{ 0, 0 };

    for (0..lines.len) |i| {
        const line = lines[i];

        for (0..line.len) |j| {
            const c = line[j];
            if (c == '.' or ascii.isDigit(c)) continue;

            const adjacent_numbers = try getAdjacentNumbers(allocator, lines, i, j);
            defer allocator.free(adjacent_numbers);

            if (c == '*' and adjacent_numbers.len == 2) {
                solution[1] += adjacent_numbers[0] * adjacent_numbers[1];
            }

            for (adjacent_numbers) |num| {
                solution[0] += num;
            }
        }
    }

    return solution;
}

fn getAdjacentNumbers(allocator: mem.Allocator, lines: [][]const u8, row: usize, col: usize) ![]u32 {
    var numbers = std.ArrayList(u32).init(allocator);

    const from_row = if (row == 0) 0 else row - 1;
    const to_row = @min(row + 1, lines.len - 1);
    const from_col = if (col == 0) 0 else col - 1;
    const to_col = @min(col + 1, lines[row].len - 1);

    for (from_row..to_row + 1) |i| {
        var j = from_col;

        while (j <= to_col) : (j += 1) {
            const line = lines[i];
            const c = line[j];

            if (!ascii.isDigit(c)) continue;

            var start = j;

            while (start > 0 and ascii.isDigit(line[start - 1])) start -= 1;
            while (j < line.len - 1 and ascii.isDigit(line[j + 1])) j += 1;

            const number = try fmt.parseInt(u32, line[start .. j + 1], 10);
            try numbers.append(number);
        }
    }

    return numbers.toOwnedSlice();
}

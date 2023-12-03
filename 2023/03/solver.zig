const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;

pub fn solve_part_1(lines: [][]const u8) !u32 {
    var sum: u32 = 0;

    for (0..lines.len) |i| {
        const line = lines[i];
        var start_number: ?usize = null;

        for (0..line.len) |j| {
            const c = line[j];

            if (ascii.isDigit(c)) {
                if (start_number == null) start_number = j;
            }

            if ((!ascii.isDigit(c) or j == (line.len - 1)) and start_number != null) {
                const end_col = if (ascii.isDigit(c)) j else j - 1;

                if (is_part_number(lines, i, start_number.?, end_col)) {
                    const number = line[start_number.? .. end_col + 1];
                    sum += try fmt.parseInt(u32, number, 10);
                }

                start_number = null;
            }
        }
    }

    return sum;
}

fn is_part_number(lines: [][]const u8, row: usize, start_col: usize, end_col: usize) bool {
    const from_col = if (start_col == 0) 0 else start_col - 1;
    const to_col = @min(end_col + 1, lines[row].len - 1);
    const from_row = if (row == 0) 0 else row - 1;
    const to_row = @min(row + 1, lines.len - 1);

    for (lines[from_row .. to_row + 1]) |curr_row| {
        for (curr_row[from_col .. to_col + 1]) |c| {
            if (c != '.' and !ascii.isDigit(c)) {
                return true;
            }
        }
    }

    return false;
}

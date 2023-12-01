const std = @import("std");
const mem = std.mem;
const expectEqual = std.testing.expectEqual;

test "reads number correctly" {
    const testData = "12";

    const expected: u32 = 12;
    const actual = part1Solver(testData);

    try expectEqual(expected, actual);
}

test "single digit" {
    const testData = "9";

    const expected: u32 = 99;
    const actual = part1Solver(testData);

    try expectEqual(expected, actual);
}

test "more than two digits" {
    const testData = "1999991";

    const expected: u32 = 11;
    const actual = part1Solver(testData);

    try expectEqual(expected, actual);
}

test "skip non digits" {
    const testData = "ab3cdef7ghi";

    const expected: u32 = 37;
    const actual = part1Solver(testData);

    try expectEqual(expected, actual);
}

test "complex multiline testcase" {
    const testData =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;

    const expected: u32 = 142;
    const actual = part1Solver(testData);

    try expectEqual(expected, actual);
}

pub fn part1Solver(text: []const u8) u32 {
    var iter = mem.tokenizeScalar(u8, text, '\n');

    var sum: u32 = 0;

    while (iter.next()) |line| {
        var first: ?u8 = null;
        var last: u8 = 0;

        for (line) |char| {
            switch (char) {
                '0'...'9' => |c| {
                    if (first == null) first = c - '0';
                    last = c - '0';
                },
                else => {},
            }
        }

        sum += first.? * 10 + last;
    }

    return sum;
}

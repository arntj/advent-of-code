const std = @import("std");
const ascii = std.ascii;
const mem = std.mem;
const expectEqual = std.testing.expectEqual;

test "reads number correctly" {
    const testData = "12";

    const expected: u32 = 12;
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

test "single digit" {
    const testData = "9";

    const expected: u32 = 99;
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

test "more than two digits" {
    const testData = "1999991";

    const expected: u32 = 11;
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

test "skip non digits" {
    const testData = "ab3cdef7ghi";

    const expected: u32 = 37;
    const actual = part2Solver(testData);

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
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

test "numbers as digits" {
    const testData = "zzfourzz123zzzninezzz";

    const expected: u32 = 49;
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

test "complex multiline testcase with numbers as digits" {
    const testData =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;

    const expected: u32 = 281;
    const actual = part2Solver(testData);

    try expectEqual(expected, actual);
}

const numbers = [_][]const u8{
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

pub fn part2Solver(text: []const u8) u32 {
    var iter = mem.tokenizeScalar(u8, text, '\n');

    var sum: u32 = 0;

    while (iter.next()) |line| {
        var first: ?u8 = null;
        var last: u8 = 0;

        for (0..line.len) |index| {
            var curr: ?u8 = null;

            const c = line[index];

            if (c >= '0' and c <= '9') {
                curr = c - '0';
            } else {
                for (0..numbers.len) |num_i| {
                    const num = numbers[num_i];

                    if (num.len > line.len - index) continue;

                    const slice = line[index .. index + num.len];

                    if (mem.eql(u8, num, slice)) {
                        curr = @as(u8, @truncate(num_i));
                        break;
                    }
                }
            }

            if (first == null) first = curr;
            if (curr) |curr_num| last = curr_num;
        }

        sum += (first orelse 0) * 10 + last;
    }

    return sum;
}

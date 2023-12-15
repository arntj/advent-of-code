const std = @import("std");

pub fn getReflections(patterns: [][][]const u8) [2]usize {
    var result = [2]usize{ 0, 0 };

    for (patterns) |pattern| {
        const v = findVerticalReflection(pattern);
        const h = findHorizontalReflection(pattern);

        if (v[0]) |res| result[0] += res;
        if (v[1]) |res| result[1] += res;
        if (h[0]) |res| result[0] += 100 * res;
        if (h[1]) |res| result[1] += 100 * res;
    }

    return result;
}

test "Horizontal reflection" {
    var pattern_1 = [_][]const u8{
        "#...##..#",
        "#....#..#",
        "..##..###",
        "#####.##.",
        "#####.##.",
        "..##..###",
        "#....#..#",
    };
    try std.testing.expectEqual([2]?usize{ 4, 1 }, findHorizontalReflection(&pattern_1));

    var pattern_2 = [_][]const u8{
        "#.##..##.",
        "..#.##.#.",
        "##......#",
        "##......#",
        "..#.##.#.",
        "..##..##.",
        "#.#.##.#.",
    };
    try std.testing.expectEqual([2]?usize{ null, 3 }, findHorizontalReflection(&pattern_2));
}
fn findHorizontalReflection(pattern: [][]const u8) [2]?usize {
    var result = [2]?usize{ null, null };

    const rows = pattern.len;
    const cols = pattern[0].len;

    outer_loop: for (0..rows - 1) |i| {
        var diff: u8 = 0;
        for (0..cols) |j| {
            if (pattern[i][j] != pattern[i + 1][j]) diff += 1;

            if (diff > 1) continue :outer_loop;
        }

        var k: usize = 1;

        while (i >= k and i + 1 + k < rows) : (k += 1) {
            for (0..cols) |j| {
                if (pattern[i - k][j] != pattern[i + 1 + k][j]) diff += 1;

                if (diff > 1) continue :outer_loop;
            }
        }

        if (diff == 0) result[0] = i + 1 else result[1] = i + 1;
    }

    return result;
}

test "Vertical reflection" {
    var pattern_1 = [_][]const u8{
        "#.##..##.",
        "..#.##.#.",
        "##......#",
        "##......#",
        "..#.##.#.",
        "..##..##.",
        "#.#.##.#.",
    };
    try std.testing.expectEqual([2]?usize{ 5, null }, findVerticalReflection(&pattern_1));

    var pattern_2 = [_][]const u8{
        "#...##..#",
        "#....#..#",
        "..##..###",
        "#####.##.",
        "#####.##.",
        "..##..###",
        "#....#..#",
    };
    try std.testing.expectEqual([2]?usize{ null, null }, findVerticalReflection(&pattern_2));
}
fn findVerticalReflection(pattern: [][]const u8) [2]?usize {
    var result = [2]?usize{ null, null };

    const rows = pattern.len;
    const cols = pattern[0].len;

    outer_loop: for (0..cols - 1) |i| {
        var diff: u8 = 0;
        for (0..rows) |j| {
            if (pattern[j][i] != pattern[j][i + 1]) diff += 1;

            if (diff > 1) continue :outer_loop;
        }

        var k: usize = 1;

        while (i >= k and i + 1 + k < cols) : (k += 1) {
            for (0..rows) |j| {
                if (pattern[j][i - k] != pattern[j][i + 1 + k]) diff += 1;

                if (diff > 1) continue :outer_loop;
            }
        }

        if (diff == 0) result[0] = i + 1 else result[1] = i + 1;
    }

    return result;
}

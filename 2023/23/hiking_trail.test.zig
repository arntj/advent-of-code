const std = @import("std");
const hiking_trail = @import("./hiking_trail.zig");

const test_input: []const []const u8 = &[_][]const u8{
    "#.#####################",
    "#.......#########...###",
    "#######.#########.#.###",
    "###.....#.>.>.###.#.###",
    "###v#####.#v#.###.#.###",
    "###.>...#.#.#.....#...#",
    "###v###.#.#.#########.#",
    "###...#.#.#.......#...#",
    "#####.#.#.#######.#.###",
    "#.....#.#.#.......#...#",
    "#.#####.#.#.#########v#",
    "#.#...#...#...###...>.#",
    "#.#.#v#######v###.###v#",
    "#...#.>.#...>.>.#.###.#",
    "#####v#.#.###v#.#.###.#",
    "#.....#...#...#.#.#...#",
    "#.#########.###.#.#.###",
    "#...###...#...#...#.###",
    "###.###.#.###v#####v###",
    "#...#...#.#.>.>.#.>.###",
    "#.###.###.#.###.#.#v###",
    "#.....###...###...#...#",
    "#####################.#",
};

test "hikePath should follow path to next node" {
    const result = hiking_trail.hikePath(
        test_input,
        hiking_trail.Pos{ .x = 1, .y = 0 },
        .s,
        false,
    );

    try std.testing.expect(result != null);
    try std.testing.expectEqual(hiking_trail.Pos{ .x = 3, .y = 5 }, result.?.to);
    try std.testing.expectEqual(@as(u16, 15), result.?.dist);
}

test "hikePath should return null for untraversable path" {
    const result = hiking_trail.hikePath(
        test_input,
        hiking_trail.Pos{ .x = 11, .y = 3 },
        .w,
        true,
    );

    try std.testing.expectEqual(@as(?hiking_trail.HikeResult, null), result);
}

test "hikePath should climb hills if not slippery" {
    const result = hiking_trail.hikePath(
        test_input,
        hiking_trail.Pos{ .x = 11, .y = 3 },
        .w,
        false,
    );

    try std.testing.expect(result != null);
    try std.testing.expectEqual(hiking_trail.Pos{ .x = 3, .y = 5 }, result.?.to);
    try std.testing.expectEqual(@as(u16, 22), result.?.dist);
}

test "findLongestPath should find correct answer for slippery conditions" {
    const allocator = std.testing.allocator;

    const result = try hiking_trail.findLongestPath(allocator, test_input, true);

    try std.testing.expectEqual(@as(u16, 94), result);
}

test "findLongestPath should find correct answer for non slippery conditions" {
    const allocator = std.testing.allocator;

    const result = try hiking_trail.findLongestPath(allocator, test_input, false);

    try std.testing.expectEqual(@as(u16, 154), result);
}

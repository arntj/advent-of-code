const std = @import("std");

pub const SpringGroup = struct {
    springs: []const u8,
    groups: []const u8,
};

pub fn unfold(allocator: std.mem.Allocator, group: SpringGroup) !SpringGroup {
    const springs_unfolded = try std.mem.join(allocator, "?", &[_][]const u8{group.springs} ** 5);
    const groups_unfolded = try std.mem.concat(allocator, u8, &[_][]const u8{group.groups} ** 5);

    return .{
        .springs = springs_unfolded,
        .groups = groups_unfolded,
    };
}

test "Count valid arrangements" {
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(
        @as(u64, 1),
        try countValidArrangements(
            allocator,
            "???.###",
            &[_]u8{ 1, 1, 3 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 4),
        try countValidArrangements(
            allocator,
            ".??..??...?##",
            &[_]u8{ 1, 1, 3 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 0),
        try countValidArrangements(
            allocator,
            "..?##",
            &[_]u8{ 1, 3 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 1),
        try countValidArrangements(
            allocator,
            "?#?#?#?#?#?#?#?",
            &[_]u8{ 1, 3, 1, 6 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 1),
        try countValidArrangements(
            allocator,
            "????.#...#...",
            &[_]u8{ 4, 1, 1 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 4),
        try countValidArrangements(
            allocator,
            "????.######..#####.",
            &[_]u8{ 1, 6, 5 },
        ),
    );

    try std.testing.expectEqual(
        @as(u64, 10),
        try countValidArrangements(
            allocator,
            "?###????????",
            &[_]u8{ 3, 2, 1 },
        ),
    );
}

pub fn countValidArrangements(allocator: std.mem.Allocator, springs: []const u8, groups: []const u8) !u64 {
    var memo = std.StringHashMap(u64).init(allocator);
    defer {
        var keys = memo.keyIterator();
        while (keys.next()) |k| allocator.free(k.*);
        memo.deinit();
    }

    return try countValidArrangementsMemoized(allocator, &memo, springs, groups);
}

fn getKey(allocator: std.mem.Allocator, springs: []const u8, groups: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{s} {d}", .{ springs, groups });
}

fn countValidArrangementsMemoized(allocator: std.mem.Allocator, memo: *std.StringHashMap(u64), springs: []const u8, groups: []const u8) !u64 {
    const key = try getKey(allocator, springs, groups);

    if (memo.get(key)) |v| {
        allocator.free(key);
        return v;
    }

    const group = groups[0];

    var next_groups_len: usize = 0;
    for (1..groups.len) |i| {
        next_groups_len += 1 + groups[i];
    }

    if (group + next_groups_len > springs.len) return 0;

    const curr_len = springs.len - next_groups_len;
    const curr_springs = springs[0..curr_len];

    var result: u64 = 0;

    groups_iter: for (0..(curr_len - group + 1)) |i| {
        for (0..i) |j| {
            if (!(curr_springs[j] == '.' or curr_springs[j] == '?')) continue :groups_iter;
        }

        for (i..i + group) |j| {
            if (!(curr_springs[j] == '#' or curr_springs[j] == '?')) continue :groups_iter;
        }

        if (groups.len == 1) {
            for (i + group..springs.len) |j| {
                if (!(springs[j] == '.' or springs[j] == '?')) continue :groups_iter;
            }
            result += 1;
        } else {
            // make sure we have a least one functional spring between this group and next
            if (!(springs[i + group] == '.' or springs[i + group] == '?')) continue :groups_iter;

            const remaining_springs = springs[i + group + 1 .. springs.len];
            const remaining_groups = groups[1..groups.len];

            result += try countValidArrangementsMemoized(allocator, memo, remaining_springs, remaining_groups);
        }
    }

    try memo.put(key, result);

    return result;
}

pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) !SpringGroup {
    var parts = std.mem.tokenizeScalar(u8, line, ' ');

    const springs = parts.next().?;

    const groups_str = parts.next().?;
    var groups_parts = std.mem.tokenizeScalar(u8, groups_str, ',');
    var groups_list = std.ArrayList(u8).init(allocator);

    while (groups_parts.next()) |g| {
        try groups_list.append(try std.fmt.parseInt(u8, g, 10));
    }

    return SpringGroup{
        .springs = springs,
        .groups = try groups_list.toOwnedSlice(),
    };
}

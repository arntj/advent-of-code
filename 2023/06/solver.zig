const std = @import("std");
const testing = std.testing;

pub const Races = struct { times: []u64, times_part2: u64, distances: []u64, distances_part2: u64 };

pub fn solve(races: Races) [2]u64 {
    var result = [2]u64{ 1, undefined };

    for (0..races.times.len) |i| result[0] *= getWaysToWin(races.times[i], races.distances[i]);

    result[1] = getWaysToWin(races.times_part2, races.distances_part2);

    return result;
}

test "ways to win when race lasts 7 time units and record distance is 9 distance units" {
    const result = getWaysToWin(7, 9);

    try testing.expectEqual(@as(u64, 4), result);
}

test "ways to win when race lasts 71530 time units and record distance is 940200 distance units" {
    const result = getWaysToWin(71530, 940200);

    try testing.expectEqual(@as(u64, 71503), result);
}

fn getWaysToWin(time: u64, record_distance: u64) u64 {
    var result: u64 = 0;

    for (1..time) |charge_time| {
        const race_time = time - charge_time;
        const race_distance = charge_time * race_time;
        if (race_distance > record_distance) result += 1;
    }

    return result;
}

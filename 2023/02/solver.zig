const std = @import("std");
const parser = @import("./parser.zig");

pub fn solve(games: []const parser.Game) [2]u64 {
    var part_1: u64 = 0;
    var part_2: u64 = 0;

    for (games) |game| {
        var impossible_game = false;
        var min_cubes = @Vector(3, u64){ 0, 0, 0 };

        for (game.rounds) |round| {
            if (round.red > 12 or round.green > 13 or round.blue > 14) {
                impossible_game = true;
            }

            const cubes_vec = @Vector(3, u8){ round.red, round.green, round.blue };
            min_cubes = @max(min_cubes, cubes_vec);
        }

        if (!impossible_game) part_1 += game.id;

        part_2 += @reduce(.Mul, min_cubes);
    }

    return [2]u64{ part_1, part_2 };
}

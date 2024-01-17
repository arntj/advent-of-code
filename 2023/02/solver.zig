const std = @import("std");
const parser = @import("./parser.zig");

// Finds the solutions to part 1 and part 2 with the given data.
pub fn solve(games: []const parser.Game) [2]u64 {
    var part_1: u64 = 0;
    var part_2: u64 = 0;

    // Iterate over games.
    for (games) |game| {
        // This variable records whether any of the rounds in this game is possible with the requirements for part 1.
        var impossible_game = false;
        // This variable records the minimum set of cubes needed across all rounds.
        // The values are in the order: red, green, blue.
        var min_cubes = @Vector(3, u64){ 0, 0, 0 };

        for (game.rounds) |round| {
            // Check if this round satisifies part 1 requirement.
            if (round.red > 12 or round.green > 13 or round.blue > 14) {
                impossible_game = true;
            }

            // Set the minimum number of cubes needed to be the maximum of this round and any earlier recorded rounds.
            const cubes_vec = @Vector(3, u8){ round.red, round.green, round.blue };
            min_cubes = @max(min_cubes, cubes_vec);
        }

        // Increment part 1 solution if this game satifies part 1 requirements.
        if (!impossible_game) part_1 += game.id;

        // Increment part 2 solution with the power of the minimum set of cubes required to play this game.
        part_2 += @reduce(.Mul, min_cubes);
    }

    return [2]u64{ part_1, part_2 };
}

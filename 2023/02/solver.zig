const std = @import("std");
const parser = @import("./parser.zig");

pub fn solve(games: []const parser.Game) u32 {
    var result: u32 = 0;

    for (games) |game| {
        var impossible_game = false;

        for (game.rounds) |round| {
            if (round.red > 12 or round.green > 13 or round.blue > 14) {
                impossible_game = true;
            }
        }

        if (!impossible_game) result += game.id;
    }

    return result;
}

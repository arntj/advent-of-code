const std = @import("std");
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;

pub const Game = struct {
    id: u8,
    rounds: []Round,
};

pub const Round = struct {
    red: u8,
    green: u8,
    blue: u8,
};

pub fn parseGames(allocator: mem.Allocator, input: []const u8) ![]const Game {
    var games = std.ArrayList(Game).init(allocator);

    var iter = mem.tokenizeScalar(u8, input, '\n');

    while (iter.next()) |line| {
        var rounds = std.ArrayList(Round).init(allocator);

        var game = Game{
            .id = undefined,
            .rounds = undefined,
        };

        var line_parts = mem.tokenizeSequence(u8, line, ": ");
        const game_id = line_parts.next().?;
        const games_str = line_parts.next().?;

        game.id = try fmt.parseInt(u8, game_id["Game ".len..game_id.len], 10);

        var rounds_iter = mem.tokenizeSequence(u8, games_str, "; ");

        while (rounds_iter.next()) |round_str| {
            var curr_round = Round{
                .red = 0,
                .blue = 0,
                .green = 0,
            };
            var cubes_iter = mem.tokenizeSequence(u8, round_str, ", ");

            while (cubes_iter.next()) |cube_str| {
                var parts = mem.tokenizeScalar(u8, cube_str, ' ');
                const number = try fmt.parseInt(u8, parts.next().?, 10);
                const color = parts.next().?;

                switch (color[0]) {
                    'r' => {
                        curr_round.red = number;
                    },
                    'g' => {
                        curr_round.green = number;
                    },
                    'b' => {
                        curr_round.blue = number;
                    },
                    else => unreachable,
                }
            }

            try rounds.append(curr_round);
        }

        game.rounds = try rounds.toOwnedSlice();
        try games.append(game);
    }

    return try games.toOwnedSlice();
}

pub fn freeGames(allocator: mem.Allocator, games: []const Game) void {
    for (games) |game| {
        allocator.free(game.rounds);
    }

    allocator.free(games);
}

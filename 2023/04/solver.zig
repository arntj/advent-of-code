const std = @import("std");
const parser = @import("./parser.zig");

pub fn solve(cards: []parser.Card) [2]u32 {
    var solution = [2]u32{ 0, 0 };

    for (cards) |card| {
        var score: u32 = 0;

        for (card.winning_numbers) |winning_number| {
            for (card.numbers_you_have) |number| {
                if (number == winning_number) {
                    if (score == 0) score = 1 else score *= 2;
                }
            }
        }

        solution[0] += score;
    }

    return solution;
}

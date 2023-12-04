const std = @import("std");
const parser = @import("./parser.zig");
const mem = std.mem;

pub fn solve_part_1(cards: []parser.Card) u32 {
    var solution: u32 = 0;

    for (cards) |card| {
        const winning_numbers = count_winning_numbers(card);

        if (winning_numbers > 0) {
            const score: u32 = @as(u32, 1) << (winning_numbers - 1);
            solution += score;
        }
    }

    return solution;
}

pub fn solve_part_2(allocator: mem.Allocator, cards: []parser.Card) !u32 {
    const card_copies: []u32 = try allocator.alloc(u32, cards.len);
    defer allocator.free(card_copies);

    @memset(card_copies, 1);

    var solution: u32 = 0;

    for (0..cards.len) |i| {
        const card = cards[i];
        const winning_cards = count_winning_numbers(card);

        for (1..winning_cards + 1) |j| {
            card_copies[i + j] += card_copies[i];
        }

        solution += card_copies[i];
    }

    return solution;
}

fn count_winning_numbers(card: parser.Card) u5 {
    var result: u5 = 0;
    for (card.winning_numbers) |winning_number| {
        for (card.numbers_you_have) |number| {
            if (number == winning_number) result += 1;
        }
    }
    return result;
}

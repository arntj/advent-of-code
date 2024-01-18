const std = @import("std");
const parser = @import("./parser.zig");
const mem = std.mem;

test "solvePart1 solves correctly for test data" {
    const cards = [_]parser.Card{
        parser.Card{
            .id = 1,
            .winning_numbers = &[_]u8{ 41, 48, 83, 86, 17 },
            .numbers_you_have = &[_]u8{ 83, 86, 6, 31, 17, 9, 48, 53 },
        },
        parser.Card{
            .id = 2,
            .winning_numbers = &[_]u8{ 13, 32, 20, 16, 61 },
            .numbers_you_have = &[_]u8{ 61, 30, 68, 82, 17, 32, 24, 19 },
        },
        parser.Card{
            .id = 3,
            .winning_numbers = &[_]u8{ 1, 21, 53, 59, 44 },
            .numbers_you_have = &[_]u8{ 69, 82, 63, 72, 16, 21, 14, 1 },
        },
        parser.Card{
            .id = 4,
            .winning_numbers = &[_]u8{ 41, 92, 73, 84, 69 },
            .numbers_you_have = &[_]u8{ 59, 84, 76, 51, 58, 5, 54, 83 },
        },
        parser.Card{
            .id = 5,
            .winning_numbers = &[_]u8{ 87, 83, 26, 28, 32 },
            .numbers_you_have = &[_]u8{ 88, 30, 70, 12, 93, 22, 82, 36 },
        },
        parser.Card{
            .id = 6,
            .winning_numbers = &[_]u8{ 31, 18, 13, 56, 72 },
            .numbers_you_have = &[_]u8{ 74, 77, 10, 23, 35, 67, 36, 11 },
        },
    };

    const result = solvePart1(&cards);

    try std.testing.expectEqual(13, result);
}

pub fn solvePart1(cards: []const parser.Card) u32 {
    var solution: u32 = 0;

    // Iterate over cards.
    for (cards) |card| {
        const winning_numbers = countWinningNumbers(card);

        // If this card has one or more winning numbers, calculate and add score for this card.
        if (winning_numbers > 0) {
            const score: u32 = @as(u32, 1) << (winning_numbers - 1);
            solution += score;
        }
    }

    return solution;
}

test "solvePart2 solves correctly for test data" {
    const allocator = std.testing.allocator;
    const cards = [_]parser.Card{
        parser.Card{
            .id = 1,
            .winning_numbers = &[_]u8{ 41, 48, 83, 86, 17 },
            .numbers_you_have = &[_]u8{ 83, 86, 6, 31, 17, 9, 48, 53 },
        },
        parser.Card{
            .id = 2,
            .winning_numbers = &[_]u8{ 13, 32, 20, 16, 61 },
            .numbers_you_have = &[_]u8{ 61, 30, 68, 82, 17, 32, 24, 19 },
        },
        parser.Card{
            .id = 3,
            .winning_numbers = &[_]u8{ 1, 21, 53, 59, 44 },
            .numbers_you_have = &[_]u8{ 69, 82, 63, 72, 16, 21, 14, 1 },
        },
        parser.Card{
            .id = 4,
            .winning_numbers = &[_]u8{ 41, 92, 73, 84, 69 },
            .numbers_you_have = &[_]u8{ 59, 84, 76, 51, 58, 5, 54, 83 },
        },
        parser.Card{
            .id = 5,
            .winning_numbers = &[_]u8{ 87, 83, 26, 28, 32 },
            .numbers_you_have = &[_]u8{ 88, 30, 70, 12, 93, 22, 82, 36 },
        },
        parser.Card{
            .id = 6,
            .winning_numbers = &[_]u8{ 31, 18, 13, 56, 72 },
            .numbers_you_have = &[_]u8{ 74, 77, 10, 23, 35, 67, 36, 11 },
        },
    };

    const result = try solvePart2(allocator, &cards);

    try std.testing.expectEqual(30, result);
}

pub fn solvePart2(allocator: mem.Allocator, cards: []const parser.Card) !u32 {
    // Initialize an array to count number of copies of each card.
    const card_copies: []u32 = try allocator.alloc(u32, cards.len);
    defer allocator.free(card_copies);

    // We start with 1 copy of each card.
    @memset(card_copies, 1);

    var solution: u32 = 0;

    for (0..cards.len) |i| {
        const card = cards[i];
        const winning_cards = countWinningNumbers(card);

        // The number of the n following cards is incremented with the number of copies of the current card,
        // where n is the number of winning numbers on the current card.
        for (1..winning_cards + 1) |j| {
            card_copies[i + j] += card_copies[i];
        }

        solution += card_copies[i];
    }

    return solution;
}

fn countWinningNumbers(card: parser.Card) u5 {
    var result: u5 = 0;
    for (card.winning_numbers) |winning_number| {
        for (card.numbers_you_have) |number| {
            if (number == winning_number) result += 1;
        }
    }
    return result;
}

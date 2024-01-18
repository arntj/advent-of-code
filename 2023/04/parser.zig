const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

pub const Card = struct {
    id: u8,
    winning_numbers: []const u8,
    numbers_you_have: []const u8,
};

test "parseCard parses card correctly" {
    const allocator = std.testing.allocator;
    const card = "Card 11: 22 14 | 85 44";

    const result = try parseCard(allocator, card);
    defer freeCard(allocator, result);

    try std.testing.expectEqual(11, result.id);

    try std.testing.expectEqual(2, result.winning_numbers.len);
    try std.testing.expectEqual(22, result.winning_numbers[0]);
    try std.testing.expectEqual(14, result.winning_numbers[1]);

    try std.testing.expectEqual(2, result.numbers_you_have.len);
    try std.testing.expectEqual(85, result.numbers_you_have[0]);
    try std.testing.expectEqual(44, result.numbers_you_have[1]);
}

// Parses playing card from input line. The caller owns the allocated memory.
pub fn parseCard(allocator: mem.Allocator, line: []const u8) !Card {
    // Split items by space.
    var parts = mem.tokenizeScalar(u8, line, ' ');

    // Skip first token (which will just be "Card" text).
    _ = parts.next();

    // Get text for card id.
    const card_id_raw = parts.next().?;
    // Remove trailing : after card id.
    const card_id_text = card_id_raw[0 .. card_id_raw.len - 1];
    // And parse to int.
    const card_id = try fmt.parseInt(u8, card_id_text, 10);

    // Parse winning numbers and playing numbers.
    var winning_numbers = std.ArrayList(u8).init(allocator);
    var numbers_you_have = std.ArrayList(u8).init(allocator);
    var parse_winning_numbers: bool = true;

    while (parts.next()) |curr_token| {
        if (curr_token[0] == '|') {
            // The token that separates winning numbers from playing numbers have been reached.
            parse_winning_numbers = false;
            continue;
        }
        const number = try fmt.parseInt(u8, curr_token, 10);
        if (parse_winning_numbers) {
            try winning_numbers.append(number);
        } else {
            try numbers_you_have.append(number);
        }
    }

    return Card{
        .id = card_id,
        .winning_numbers = try winning_numbers.toOwnedSlice(),
        .numbers_you_have = try numbers_you_have.toOwnedSlice(),
    };
}

pub fn freeCard(allocator: mem.Allocator, card: Card) void {
    allocator.free(card.winning_numbers);
    allocator.free(card.numbers_you_have);
}

const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

pub const Card = struct {
    id: u8,
    winning_numbers: []u8,
    numbers_you_have: []u8,
};

pub fn parseCard(allocator: mem.Allocator, line: []const u8) !Card {
    var card = Card{
        .id = undefined,
        .winning_numbers = undefined,
        .numbers_you_have = undefined,
    };

    var parts = mem.tokenizeAny(u8, line, ":|");

    const card_id_str = parts.next().?;
    const last_space = mem.lastIndexOfScalar(u8, card_id_str, ' ');
    const card_id = card_id_str[last_space.? + 1 .. card_id_str.len];
    card.id = try fmt.parseInt(u8, card_id, 10);

    card.winning_numbers = try parseNumbers(allocator, parts.next().?);
    card.numbers_you_have = try parseNumbers(allocator, parts.next().?);

    return card;
}

fn parseNumbers(allocator: mem.Allocator, numbers_list: []const u8) ![]u8 {
    var numbers = std.ArrayList(u8).init(allocator);
    var numbers_iter = mem.tokenizeScalar(u8, numbers_list, ' ');

    while (numbers_iter.next()) |num| {
        try numbers.append(try fmt.parseInt(u8, num, 10));
    }

    return numbers.toOwnedSlice();
}

pub fn freeCard(allocator: mem.Allocator, card: Card) void {
    allocator.free(card.winning_numbers);
    allocator.free(card.numbers_you_have);
}

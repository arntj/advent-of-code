const std = @import("std");
const mem = std.mem;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub const Hand = struct {
    cards: *const [5]u8,
    bid: u16,
};

pub const HandType = enum(u8) {
    five_of_a_kind = 7,
    four_of_a_kind = 6,
    full_house = 5,
    three_of_a_kind = 4,
    two_pair = 3,
    one_pair = 2,
    high_card = 1,
};

const all_cards = "23456789TJQKA";
const all_cards_joker = "J23456789TQKA";

test "High card" {
    try expectEqual(HandType.high_card, getHandType("23456"));
    try expectEqual(HandType.high_card, getHandType("A9372"));
}

test "Five of a kind" {
    try expectEqual(HandType.five_of_a_kind, getHandType("AAAAA"));
    try expectEqual(HandType.five_of_a_kind, getHandType("TTTTT"));
}

test "Four of a kind" {
    try expectEqual(HandType.four_of_a_kind, getHandType("AA8AA"));
    try expectEqual(HandType.four_of_a_kind, getHandType("2A222"));
}

test "Full house" {
    try expectEqual(HandType.full_house, getHandType("23332"));
    try expectEqual(HandType.full_house, getHandType("77444"));
}

test "Three of a kind" {
    try expectEqual(HandType.three_of_a_kind, getHandType("TTT98"));
    try expectEqual(HandType.three_of_a_kind, getHandType("A34AA"));
}

test "Two pairs" {
    try expectEqual(HandType.two_pair, getHandType("23432"));
    try expectEqual(HandType.two_pair, getHandType("755KK"));
}

test "One pair" {
    try expectEqual(HandType.one_pair, getHandType("A23A4"));
    try expectEqual(HandType.one_pair, getHandType("KQQ4T"));
}

pub fn getHandType(cards: *const [5]u8) HandType {
    var card_counts: [all_cards.len]u8 = undefined;
    @memset(&card_counts, 0);

    for (cards.*) |c| {
        const index = mem.indexOfScalar(u8, all_cards, c) orelse unreachable;
        card_counts[index] += 1;
    }

    var pairs: u8 = 0;
    var threes: u8 = 0;

    for (card_counts) |c| {
        if (c == 5) return .five_of_a_kind;
        if (c == 4) return .four_of_a_kind;
        if (c == 3) threes += 1;
        if (c == 2) pairs += 1;
    }

    if (pairs == 1 and threes == 1) return .full_house;
    if (threes == 1) return .three_of_a_kind;
    if (pairs == 2) return .two_pair;
    if (pairs == 1) return .one_pair;

    return .high_card;
}

test "High card with jokers" {
    try expectEqual(HandType.high_card, getHandTypeWithJokers("23456"));
    try expectEqual(HandType.high_card, getHandTypeWithJokers("A9372"));
}

test "Five of a kind with jokers" {
    try expectEqual(HandType.five_of_a_kind, getHandTypeWithJokers("AAAAA"));
    try expectEqual(HandType.five_of_a_kind, getHandTypeWithJokers("TTTTT"));
    try expectEqual(HandType.five_of_a_kind, getHandTypeWithJokers("AAJAA"));
    try expectEqual(HandType.five_of_a_kind, getHandTypeWithJokers("JTTTJ"));
    try expectEqual(HandType.five_of_a_kind, getHandTypeWithJokers("JJJJJ"));
}

test "Four of a kind with jokers" {
    try expectEqual(HandType.four_of_a_kind, getHandTypeWithJokers("AA8AA"));
    try expectEqual(HandType.four_of_a_kind, getHandTypeWithJokers("2A222"));
    try expectEqual(HandType.four_of_a_kind, getHandTypeWithJokers("AA8AJ"));
    try expectEqual(HandType.four_of_a_kind, getHandTypeWithJokers("2AJJ2"));
    try expectEqual(HandType.four_of_a_kind, getHandTypeWithJokers("JAJJ2"));
}

test "Full house with jokers" {
    try expectEqual(HandType.full_house, getHandTypeWithJokers("23332"));
    try expectEqual(HandType.full_house, getHandTypeWithJokers("77444"));
    try expectEqual(HandType.full_house, getHandTypeWithJokers("23J32"));
    try expectEqual(HandType.full_house, getHandTypeWithJokers("77J44"));
}

test "Three of a kind with jokers" {
    try expectEqual(HandType.three_of_a_kind, getHandTypeWithJokers("TTT98"));
    try expectEqual(HandType.three_of_a_kind, getHandTypeWithJokers("A34AA"));
    try expectEqual(HandType.three_of_a_kind, getHandTypeWithJokers("TJT98"));
    try expectEqual(HandType.three_of_a_kind, getHandTypeWithJokers("A34JJ"));
}

test "Two pairs with jokers" {
    try expectEqual(HandType.two_pair, getHandTypeWithJokers("23432"));
    try expectEqual(HandType.two_pair, getHandTypeWithJokers("755KK"));
}

test "One pair with jokers" {
    try expectEqual(HandType.one_pair, getHandTypeWithJokers("A239J"));
    try expectEqual(HandType.one_pair, getHandTypeWithJokers("2QJ4T"));
}

pub fn getHandTypeWithJokers(cards: *const [5]u8) HandType {
    var card_counts: [all_cards_joker.len]u8 = undefined;
    @memset(&card_counts, 0);

    for (cards.*) |c| {
        const index = mem.indexOfScalar(u8, all_cards_joker, c) orelse unreachable;
        card_counts[index] += 1;
    }

    const jokers = card_counts[0];

    if (jokers >= 4) return .five_of_a_kind;

    const card_counts_without_jokers = card_counts[1..card_counts.len];

    var pairs: u8 = 0;
    var threes: u8 = 0;

    for (card_counts_without_jokers) |c| {
        if (c + jokers == 5) return .five_of_a_kind;
        if (c + jokers == 4) return .four_of_a_kind;

        if (c == 3) threes += 1;
        if (c == 2) pairs += 1;
    }

    if (jokers == 3) return .full_house;

    if ((pairs == 1 and jokers >= 2) or (pairs == 2 and jokers == 1) or (threes == 1 and jokers > 0) or (pairs == 1 and threes == 1)) return .full_house;
    if ((threes == 1) or (pairs == 1 and jokers == 1) or (jokers == 2)) return .three_of_a_kind;
    if ((pairs == 2) or (jokers == 2)) return .two_pair;
    if ((pairs == 1) or (jokers == 1)) return .one_pair;

    return .high_card;
}

test "four of a kind less than five of a kind" {
    try expect(handLessThan(.{ .joker = false }, Hand{ .cards = "AAJAA", .bid = 0 }, Hand{ .cards = "22222", .bid = 0 }));
}

test "four of a kind less than five of a kind, with jokers" {
    try expect(handLessThan(.{ .joker = true }, Hand{ .cards = "AAKJA", .bid = 0 }, Hand{ .cards = "22222", .bid = 0 }));
}

test "full house more than three of a kind" {
    try expect(!handLessThan(.{ .joker = false }, Hand{ .cards = "23332", .bid = 0 }, Hand{ .cards = "KAQAA", .bid = 0 }));
}

test "full house more than three of a kind, with jokers" {
    try expect(!handLessThan(.{ .joker = true }, Hand{ .cards = "23332", .bid = 0 }, Hand{ .cards = "KJQAA", .bid = 0 }));
}

test "compare high card" {
    try expect(handLessThan(.{ .joker = false }, Hand{ .cards = "247KQ", .bid = 0 }, Hand{ .cards = "257KQ", .bid = 0 }));
    try expect(handLessThan(.{ .joker = true }, Hand{ .cards = "QQQJA", .bid = 0 }, Hand{ .cards = "KTJJT", .bid = 0 }));
}

pub const HandLessThanContext = struct { joker: bool };

pub fn handLessThan(context: HandLessThanContext, a: Hand, b: Hand) bool {
    const cards = if (context.joker) all_cards_joker else all_cards;

    const a_rank = @intFromEnum(if (context.joker) getHandTypeWithJokers(a.cards) else getHandType(a.cards));
    const b_rank = @intFromEnum(if (context.joker) getHandTypeWithJokers(b.cards) else getHandType(b.cards));

    if (a_rank < b_rank) return true;
    if (a_rank > b_rank) return false;

    for (a.cards, b.cards) |a_c, b_c| {
        const a_i = mem.indexOfScalar(u8, cards, a_c) orelse unreachable;
        const b_i = mem.indexOfScalar(u8, cards, b_c) orelse unreachable;

        if (a_i < b_i) return true;
        if (a_i > b_i) return false;
    }

    return false;
}

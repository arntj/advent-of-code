const std = @import("std");
const camel_cards = @import("./camel_cards.zig");
const fmt = std.fmt;
const heap = std.heap;
const io = std.io;
const mem = std.mem;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var buffer: [1024]u8 = undefined;
    var hands_list = std.ArrayList(camel_cards.Hand).init(allocator);

    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var parts = mem.tokenizeScalar(u8, line, ' ');

        const cards: *const [5]u8 = (try allocator.dupe(u8, parts.next().?))[0..5];
        const bid = try fmt.parseInt(u16, parts.next().?, 10);

        try hands_list.append(camel_cards.Hand{
            .cards = cards,
            .bid = bid,
        });
    }

    const hands = try hands_list.toOwnedSlice();
    defer {
        for (hands) |hand| allocator.free(hand.cards);
        allocator.free(hands);
    }

    var solution = [2]u64{ 0, 0 };

    mem.sort(camel_cards.Hand, hands, camel_cards.HandLessThanContext{ .joker = false }, camel_cards.handLessThan);

    for (0..hands.len) |i| {
        solution[0] += (i + 1) * hands[i].bid;
    }

    mem.sort(camel_cards.Hand, hands, camel_cards.HandLessThanContext{ .joker = true }, camel_cards.handLessThan);

    for (0..hands.len) |i| {
        solution[1] += (i + 1) * hands[i].bid;
    }

    try stdout.print("Part 1 solution: {d}\n", .{solution[0]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[1]});
}

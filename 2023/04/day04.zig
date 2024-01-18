const std = @import("std");
const parser = @import("./parser.zig");
const solver = @import("./solver.zig");
const heap = std.heap;
const io = std.io;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var cards_list = std.ArrayList(parser.Card).init(allocator);
    var buffer: [1024]u8 = undefined;

    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        try cards_list.append(try parser.parseCard(allocator, line));
    }

    const cards = try cards_list.toOwnedSlice();
    defer {
        for (cards) |card| parser.freeCard(allocator, card);
        allocator.free(cards);
    }

    const solution_part_1 = solver.solvePart1(cards);
    const solution_part_2 = try solver.solvePart2(allocator, cards);

    try stdout.print("Part 1 result: {d}\n", .{solution_part_1});
    try stdout.print("Part 2 result: {d}\n", .{solution_part_2});
}

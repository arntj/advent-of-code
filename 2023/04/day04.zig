const std = @import("std");
const parser = @import("./parser.zig");
const heap = std.heap;
const io = std.io;
const print = std.debug.print;

const solver = @import("./solver.zig");

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

    const solution = solver.solve(cards);

    try stdout.print("Part 1 result: {d}\n", .{solution[0]});
}

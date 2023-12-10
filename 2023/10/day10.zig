const std = @import("std");
const pipes = @import("./pipes.zig");
const fmt = std.fmt;
const heap = std.heap;
const io = std.io;
const mem = std.mem;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var buffer: [1024 * 1024]u8 = undefined;
    const len = try stdin.readAll(&buffer);
    const input = buffer[0..len];

    var tiles = try pipes.parseTiles(allocator, input);
    defer pipes.freeTiles(allocator, tiles);

    const solution = try pipes.solve(allocator, &tiles);

    try stdout.print("Part 1 solution: {d}\n", .{solution[0]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[1]});
}

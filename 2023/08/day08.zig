const std = @import("std");
const desert_map = @import("./desert_map.zig");
const heap = std.heap;
const io = std.io;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const map = try desert_map.parseMap(allocator, input);
    defer desert_map.freeMap(allocator, map);

    const solution_part_1 = try desert_map.walkMap(allocator, map, false);
    const solution_part_2 = try desert_map.walkMap(allocator, map, true);

    try stdout.print("Part 1 solution: {d}\n", .{solution_part_1});
    try stdout.print("Part 2 solution: {d}\n", .{solution_part_2});
}

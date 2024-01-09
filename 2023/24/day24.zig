const std = @import("std");
const hail = @import("./hail.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const hailstones = try hail.calculateHailPaths(allocator, input, 200000000000000.0, 400000000000000.0);
    const solution_part2 = try hail.findRockPath(allocator, input);

    try stdout.print("Part 1 solution: {d}\n", .{hailstones});
    try stdout.print("Part 2 solution: {d}\n", .{solution_part2});
}

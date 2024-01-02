const std = @import("std");
const bricks = @import("./bricks.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const all_bricks = try bricks.parseBricks(allocator, input);
    defer allocator.free(all_bricks);

    // for (all_bricks) |brick| {
    //     try stdout.print("{d},{d},{d}~{d},{d},{d}\n", .{ brick.from.x, brick.from.y, brick.from.z, brick.to.x, brick.to.y, brick.to.z });
    // }

    const solution = try bricks.fallingBricks(allocator, all_bricks);

    try stdout.print("Part 1 solution: {d}\n", .{solution[0]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[1]});
}

const std = @import("std");
const lava_lagoon = @import("./lava_lagoon.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const lagoon = try lava_lagoon.parseLagoon(allocator, input);
    defer lava_lagoon.freeLagoon(allocator, lagoon);

    try stdout.print("Part 1 solution: {d}\n", .{lava_lagoon.digLagoon(lagoon.instructions)});
    try stdout.print("Part 2 solution: {d}\n", .{lava_lagoon.digLagoon(lagoon.instructions_corrected)});
}

const std = @import("std");
const garden = @import("./garden.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var garden_list = std.ArrayList([]const u8).init(allocator);
    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try garden_list.append(line);
    }

    const my_garden = try garden_list.toOwnedSlice();
    defer {
        for (my_garden) |line| {
            allocator.free(line);
        }
        allocator.free(my_garden);
    }

    try stdout.print("Part 1 solution: {d}\n", .{try garden.shortGardenWalk(allocator, my_garden)});
    try stdout.print("Part 2 solution: {d}\n", .{try garden.longGardenWalk(allocator, my_garden)});
}

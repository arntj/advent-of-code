const std = @import("std");
const hiking_trail = @import("./hiking_trail.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var lines_list = std.ArrayList([]const u8).init(allocator);

    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try lines_list.append(line);
    }

    const lines = try lines_list.toOwnedSlice();
    defer {
        for (lines) |line| {
            allocator.free(line);
        }
        allocator.free(lines);
    }

    try stdout.print("Part 1 solution: {d}\n", .{try hiking_trail.findLongestPath(allocator, lines, true)});
    try stdout.print("Part 2 solution: {d}\n", .{try hiking_trail.findLongestPath(allocator, lines, false)});
}

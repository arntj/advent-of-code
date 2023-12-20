const std = @import("std");
const parts_sorter = @import("./parts_sorter.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    var sorter = try parts_sorter.PartsSorter.parse(allocator, input);
    defer sorter.deinit();

    try stdout.print("Part 1 solution: {d}\n", .{try sorter.sortParts()});
    try stdout.print("Part 2 solution: {d}\n", .{try sorter.findRanges(allocator)});
}

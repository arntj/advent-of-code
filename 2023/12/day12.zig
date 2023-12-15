const std = @import("std");
const springs = @import("./springs.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var spring_groups_list = std.ArrayList(springs.SpringGroup).init(allocator);

    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try spring_groups_list.append(try springs.parseLine(allocator, line));
    }

    const spring_groups = try spring_groups_list.toOwnedSlice();
    var answer_part1: u64 = 0;
    var answer_part2: u64 = 0;

    for (spring_groups) |group| {
        answer_part1 += try springs.countValidArrangements(allocator, group.springs, group.groups);

        const unfolded = try springs.unfold(allocator, group);
        answer_part2 += try springs.countValidArrangements(allocator, unfolded.springs, unfolded.groups);
    }

    try stdout.print("Part 1 solution: {d}\n", .{answer_part1});
    try stdout.print("Part 2 solution: {d}\n", .{answer_part2});
}

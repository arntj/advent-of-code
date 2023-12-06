const std = @import("std");
const solver = @import("./solver.zig");
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;
const io = std.io;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024);
    defer allocator.free(input);

    const races = try parse_input(allocator, input);
    defer {
        allocator.free(races.distances);
        allocator.free(races.times);
    }

    const solution = solver.solve(races);

    try stdout.print("Part 1 solution: {d}\n", .{solution[0]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[1]});
}

fn parse_input(allocator: mem.Allocator, input: []u8) !solver.Races {
    var times = std.ArrayList(u64).init(allocator);
    var distances = std.ArrayList(u64).init(allocator);

    var lines = mem.tokenizeScalar(u8, input, '\n');

    const times_line = lines.next().?;
    var times_iter = mem.tokenizeScalar(u8, times_line, ' ');
    _ = times_iter.next();
    var part_2_time = std.ArrayList(u8).init(allocator);
    defer part_2_time.deinit();
    while (times_iter.next()) |time| {
        try times.append(try fmt.parseInt(u64, time, 10));
        try part_2_time.appendSlice(time);
    }

    const distances_line = lines.next().?;
    var distances_iter = mem.tokenizeScalar(u8, distances_line, ' ');
    _ = distances_iter.next();
    var part_2_distance = std.ArrayList(u8).init(allocator);
    defer part_2_distance.deinit();
    while (distances_iter.next()) |distance| {
        try distances.append(try fmt.parseInt(u64, distance, 10));
        try part_2_distance.appendSlice(distance);
    }

    return solver.Races{
        .times = try times.toOwnedSlice(),
        .times_part2 = try fmt.parseInt(u64, part_2_time.items, 10),
        .distances = try distances.toOwnedSlice(),
        .distances_part2 = try fmt.parseInt(u64, part_2_distance.items, 10),
    };
}

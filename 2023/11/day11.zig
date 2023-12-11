const std = @import("std");
const observatory = @import("./observatory.zig");
const heap = std.heap;
const io = std.io;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var galaxies = std.ArrayList(observatory.Galaxy).init(allocator);

    var x: u32 = 0;
    var y: u32 = 0;
    var width: u32 = 0;

    var buffer: [1]u8 = undefined;

    while (true) {
        if (try stdin.read(&buffer) == 0) {
            break;
        }

        switch (buffer[0]) {
            '.' => {
                x += 1;
            },
            '#' => {
                try galaxies.append(observatory.Galaxy{ .x = x, .y = y });
                x += 1;
            },
            '\n' => {
                width = x;
                x = 0;
                y += 1;
            },
            else => unreachable,
        }
    }

    var image = observatory.Image{
        .width = width,
        .height = y,
        .galaxies = try galaxies.toOwnedSlice(),
    };

    try observatory.expandUniverse(&image, 2);

    const solution_part_1 = observatory.sumDistances(image);

    try observatory.expandUniverse(&image, 1000000 / 2);

    const solution_part_2 = observatory.sumDistances(image);

    try stdout.print("Part 1 solution: {d}\n", .{solution_part_1});
    try stdout.print("Part 2 solution: {d}\n", .{solution_part_2});
}

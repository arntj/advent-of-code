const std = @import("std");
const heap = std.heap;
const io = std.io;
const print = std.debug.print;

const solver = @import("./solver.zig");

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    var lines = std.ArrayList([]const u8).init(allocator);

    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try lines.append(line);
    }

    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    const part_1 = try solver.solve_part_1(lines.items);

    print("Part 1 result: {d}\n", .{part_1});
}

const std = @import("std");
const oasis = @import("./oasis.zig");
const fmt = std.fmt;
const heap = std.heap;
const io = std.io;
const mem = std.mem;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();

    var lines_list = std.ArrayList([]const i32).init(allocator);
    var buffer: [1024]u8 = undefined;

    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var tokens = mem.tokenizeScalar(u8, line, ' ');
        var line_list = std.ArrayList(i32).init(allocator);

        while (tokens.next()) |num| {
            try line_list.append(try fmt.parseInt(i32, num, 10));
        }

        try lines_list.append(try line_list.toOwnedSlice());
    }

    const lines = try lines_list.toOwnedSlice();
    defer {
        for (lines) |line| allocator.free(line);
        allocator.free(lines);
    }

    const solution = oasis.extrapolateValues(lines);

    try stdout.print("Part 1 solution: {d}\n", .{solution[1]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[0]});
}

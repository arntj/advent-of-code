const std = @import("std");
const parser = @import("./parser.zig");
const solver = @import("./solver.zig");
const heap = std.heap;
const io = std.io;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdout = io.getStdOut().writer();

    const almanac = try parser.parseAlmanac(allocator);
    defer parser.freeAlmanac(allocator, almanac);

    const solution = try solver.solve(allocator, almanac);

    try stdout.print("Part 1 solution: {d}\n", .{solution[0]});
    try stdout.print("Part 2 solution: {d}\n", .{solution[1]});
}

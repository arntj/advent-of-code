const std = @import("std");
const hash = @import("./hash.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const sum = hash.sum_hash(input);

    try stdout.print("Part 1 solution: {d}\n", .{sum});

    const focusing_power = try hash.hashmap(allocator, input);
    try stdout.print("Part 2 solution: {d}\n", .{focusing_power});
}

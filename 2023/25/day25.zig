const std = @import("std");
const network = @import("./network.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    try stdout.print("Part 1 solution: {d}\n", .{try network.groupNodes(allocator, input)});
}

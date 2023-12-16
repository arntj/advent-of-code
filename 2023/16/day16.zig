const std = @import("std");
const contraption = @import("./contraption.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const contrap = try contraption.Contraption.init(allocator, input);

    try stdout.print("Part 1 solution: {d}\n", .{try contrap.energizeTopLeft()});
    try stdout.print("Part 2 solution: {d}\n", .{try contrap.energizeAll()});
}

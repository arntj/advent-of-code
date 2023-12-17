const std = @import("std");
const city_map = @import("./city_map.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    const map = try city_map.CityMap.init(allocator, input);
    defer map.deinit();

    try stdout.print("Part 1 solution: {d}\n", .{try map.navigate(false)});
    try stdout.print("Part 2 solution: {d}\n", .{try map.navigate(true)});
}

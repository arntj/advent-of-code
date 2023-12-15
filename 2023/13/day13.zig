const std = @import("std");
const mirrors = @import("./mirrors.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var patterns_list = std.ArrayList([][]const u8).init(allocator);

    var curr_pattern = std.ArrayList([]u8).init(allocator);

    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        if (line.len == 0) {
            try patterns_list.append(try curr_pattern.toOwnedSlice());
            curr_pattern = std.ArrayList([]u8).init(allocator);
        } else {
            try curr_pattern.append(line);
        }
    }

    try patterns_list.append(try curr_pattern.toOwnedSlice());
    const patterns = try patterns_list.toOwnedSlice();

    const result = mirrors.getReflections(patterns);
    try stdout.print("Part 1 solution: {d}\n", .{result[0]});
    try stdout.print("Part 2 solution: {d}\n", .{result[1]});
}

const std = @import("std");
const heap = std.heap;
const io = std.io;
const print = std.debug.print;

const solver = @import("./solver.zig");

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stdin = io.getStdIn().reader();

    // Read input directly from stdin.
    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(input);

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var input_iter = std.mem.splitScalar(u8, input, '\n');
    while (input_iter.next()) |line| {
        try lines.append(line);
    }

    // Find the solution and print it.
    const solution = try solver.solve(allocator, lines.items);

    print("Part 1 result: {d}\n", .{solution[0]});
    print("Part 2 result: {d}\n", .{solution[1]});
}

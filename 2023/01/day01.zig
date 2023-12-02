const std = @import("std");
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const print = std.debug.print;
const part1 = @import("./part1.zig");
const part2 = @import("./part2.zig");

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        print("No filename given...\n", .{});
        return;
    }

    const file_name = args[1];
    const contents = try readFile(allocator, file_name);
    defer allocator.free(contents);

    print("Part 1 result: {d}\n", .{part1.part1Solver(contents)});
    print("Part 2 result: {d}\n", .{part2.part2Solver(contents)});
}

fn readFile(allocator: mem.Allocator, file_name: []const u8) ![]u8 {
    var file = try fs.cwd().openFile(file_name, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1024 * 1024);
}

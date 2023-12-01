const std = @import("std");
const fmt = std.fmt;
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const print = std.debug.print;
const utils = @import("./utils.zig");

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

    const result = utils.part1Solver(contents);

    print("{d}\n", .{result});
}

fn readFile(allocator: mem.Allocator, file_name: []const u8) ![]u8 {
    var file = try fs.cwd().openFile(file_name, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1024 * 1024);
}

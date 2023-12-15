const std = @import("std");
const platform = @import("./platform.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(allocator, 1024 * 1024);

    const plat = try platform.parseMap(allocator, input);

    platform.tiltN(plat);
    try stdout.print("Part 1 solution: {d}\n", .{platform.calculateLoad(plat)});

    platform.tiltW(plat);
    platform.tiltS(plat);
    platform.tiltE(plat);

    var i: usize = 1;
    const cycles: usize = 1_000_000_000;

    var memo = std.StringHashMap(usize).init(allocator);
    try memo.put(try plat.toString(allocator), 0);

    while (i < cycles) : (i += 1) {
        platform.tiltN(plat);
        platform.tiltW(plat);
        platform.tiltS(plat);
        platform.tiltE(plat);

        const str = try plat.toString(allocator);

        if (memo.get(str)) |prev_i| {
            const cycle_length = i - prev_i;
            while (i + cycle_length < cycles) i += cycle_length;
        } else {
            try memo.put(str, i);
        }
    }

    try stdout.print("Part 2 solution: {d}\n", .{platform.calculateLoad(plat)});
}

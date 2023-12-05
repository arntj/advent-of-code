const std = @import("std");
const fmt = std.fmt;
const io = std.io;
const mem = std.mem;

pub const Range = struct {
    source: i64,
    dest: i64,
    len: i64,
};

pub const Map = struct {
    name: []const u8,
    ranges: []const Range,
};

pub const Almanac = struct {
    seeds: []const i64,
    maps: []const Map,
};

pub fn parse_almanac(allocator: mem.Allocator) !Almanac {
    const stdin = io.getStdIn().reader();

    var buffer: [1024]u8 = undefined;
    const first_line = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')).?;

    var seeds_list = std.ArrayList(i64).init(allocator);
    var seeds_iter = mem.tokenizeScalar(u8, first_line, ' ');

    // skip the "seeds: " part
    _ = seeds_iter.next();

    while (seeds_iter.next()) |seed_str| {
        try seeds_list.append(try fmt.parseInt(i64, seed_str, 10));
    }

    const seeds = try seeds_list.toOwnedSlice();

    // skip newline
    _ = try stdin.readUntilDelimiterOrEof(&buffer, '\n');

    var maps = std.ArrayList(Map).init(allocator);

    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var name_iter = mem.splitScalar(u8, line, ' ');
        const name = try allocator.dupe(u8, name_iter.first());
        var ranges = std.ArrayList(Range).init(allocator);

        while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |range_line| {
            if (range_line.len == 0) {
                break;
            }

            var range_iter = mem.tokenizeScalar(u8, range_line, ' ');
            const dest = try fmt.parseInt(i64, range_iter.next().?, 10);
            const source = try fmt.parseInt(i64, range_iter.next().?, 10);
            const len = try fmt.parseInt(i64, range_iter.next().?, 10);

            try ranges.append(Range{ .source = source, .dest = dest, .len = len });
        }

        try maps.append(Map{
            .name = name,
            .ranges = try ranges.toOwnedSlice(),
        });
    }

    return Almanac{
        .seeds = seeds,
        .maps = try maps.toOwnedSlice(),
    };
}

pub fn free_almanac(allocator: mem.Allocator, almanac: Almanac) void {
    for (almanac.maps) |map| {
        allocator.free(map.name);
        allocator.free(map.ranges);
    }

    allocator.free(almanac.seeds);
    allocator.free(almanac.maps);
}

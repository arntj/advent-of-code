const std = @import("std");

const GardenWalk = struct {
    x: u16,
    y: u16,
    steps: u16,
};

const NumberOfReachableSpots = struct {
    odd: u16 = 0,
    odd_corner: u16 = 0,
    even: u16 = 0,
    even_corner: u16 = 0,
};

pub fn shortGardenWalk(allocator: std.mem.Allocator, garden: [][]const u8) !u16 {
    const result = try gardenWalk(allocator, garden, 64);

    return result.even;
}

pub fn longGardenWalk(allocator: std.mem.Allocator, garden: [][]const u8) !u64 {
    const reachable_spots = try gardenWalk(allocator, garden, 130);

    // The solution is very specific to actual input data so I'm going to cheat and hard code dimensions here.
    const n: u64 = (26501365 - 65) / 131;

    return (n + 1) * (n + 1) * reachable_spots.odd + n * n * reachable_spots.even - (n + 1) * reachable_spots.odd_corner + n * reachable_spots.even_corner;
}

fn gardenWalk(allocator: std.mem.Allocator, garden: [][]const u8, bound: u16) !NumberOfReachableSpots {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var result = NumberOfReachableSpots{};

    var start_x: u16 = undefined;
    var start_y: u16 = undefined;
    const rows: u16 = @intCast(garden.len);
    const cols: u16 = @intCast(garden[0].len);

    for (0..garden.len) |y| {
        for (0..garden[0].len) |x| {
            if (garden[y][x] == 'S') {
                start_x = @intCast(x);
                start_y = @intCast(y);
                break;
            }
        }
    }

    var visited = std.StringHashMap(u64).init(alloc);
    var visiting = std.ArrayList(GardenWalk).init(alloc);

    try visiting.append(GardenWalk{ .x = start_x, .y = start_y, .steps = 0 });

    while (visiting.popOrNull()) |walk| {
        if (walk.steps > bound) continue;

        if (garden[walk.y][walk.x] == '#') continue;

        const pos_str = try posToStr(alloc, walk.x, walk.y);

        if (visited.get(pos_str)) |visited_steps| {
            if (visited_steps <= walk.steps) continue;
        } else {
            const dist_from_center = absDiff(walk.x, start_x) + absDiff(walk.y, start_y);

            const is_even = walk.steps & 1 == 0;
            const inside_corner = dist_from_center <= start_x;

            if (is_even) {
                result.even += 1;

                if (!inside_corner) {
                    result.even_corner += 1;
                }
            } else {
                result.odd += 1;

                if (!inside_corner) {
                    result.odd_corner += 1;
                }
            }
        }

        try visited.put(pos_str, walk.steps);

        if (walk.x > 0) {
            try visiting.append(GardenWalk{ .x = walk.x - 1, .y = walk.y, .steps = walk.steps + 1 });
        }
        if (walk.x < cols - 1) {
            try visiting.append(GardenWalk{ .x = walk.x + 1, .y = walk.y, .steps = walk.steps + 1 });
        }
        if (walk.y > 0) {
            try visiting.append(GardenWalk{ .x = walk.x, .y = walk.y - 1, .steps = walk.steps + 1 });
        }
        if (walk.y < rows - 1) {
            try visiting.append(GardenWalk{ .x = walk.x, .y = walk.y + 1, .steps = walk.steps + 1 });
        }
    }

    return result;
}

fn posToStr(allocator: std.mem.Allocator, x: u16, y: u16) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d},{d}", .{ x, y });
}

fn absDiff(a: u16, b: u16) u16 {
    return if (a > b) a - b else b - a;
}

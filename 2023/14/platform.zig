const std = @import("std");

pub const Rock = struct { x: u8, y: u8 };

pub const Platform = struct {
    rocks: []Rock,
    map: [][]u8,

    pub fn toString(self: Platform, allocator: std.mem.Allocator) ![]const u8 {
        return try std.mem.join(allocator, "\n", self.map);
    }
};

pub fn calculateLoad(input: Platform) u32 {
    var load: u32 = 0;

    for (input.rocks) |r| {
        load += @as(u32, @truncate(input.map.len - r.y));
    }

    return load;
}

pub fn tiltN(input: Platform) void {
    var moved: bool = true;
    while (moved) {
        moved = false;
        for (input.rocks) |*r| {
            const orig_y = r.y;

            while (r.y > 0 and input.map[r.y - 1][r.x] == '.') {
                r.y -= 1;
                moved = true;
            }

            input.map[orig_y][r.x] = '.';
            input.map[r.y][r.x] = 'O';
        }
    }
}

pub fn tiltW(input: Platform) void {
    var moved: bool = true;
    while (moved) {
        moved = false;
        for (input.rocks) |*r| {
            const orig_x = r.x;

            while (r.x > 0 and input.map[r.y][r.x - 1] == '.') {
                r.x -= 1;
                moved = true;
            }

            input.map[r.y][orig_x] = '.';
            input.map[r.y][r.x] = 'O';
        }
    }
}

pub fn tiltS(input: Platform) void {
    var moved: bool = true;
    while (moved) {
        moved = false;
        for (input.rocks) |*r| {
            const orig_y = r.y;

            while (r.y < input.map.len - 1 and input.map[r.y + 1][r.x] == '.') {
                r.y += 1;
                moved = true;
            }

            input.map[orig_y][r.x] = '.';
            input.map[r.y][r.x] = 'O';
        }
    }
}

pub fn tiltE(input: Platform) void {
    var moved: bool = true;
    while (moved) {
        moved = false;
        for (input.rocks) |*r| {
            const orig_x = r.x;

            while (r.x < input.map[0].len - 1 and input.map[r.y][r.x + 1] == '.') {
                r.x += 1;
                moved = true;
            }

            input.map[r.y][orig_x] = '.';
            input.map[r.y][r.x] = 'O';
        }
    }
}

pub fn parseMap(allocator: std.mem.Allocator, input: []u8) !Platform {
    var rocks = std.ArrayList(Rock).init(allocator);
    var lines = std.ArrayList([]u8).init(allocator);
    var curr_line = std.ArrayList(u8).init(allocator);
    var x: u8 = 0;
    var y: u8 = 0;

    for (input) |c| {
        if (c == 'O') {
            try rocks.append(Rock{ .x = x, .y = y });
        }

        if (c == '\n') {
            const line = try curr_line.toOwnedSlice();
            try lines.append(line);
            curr_line = std.ArrayList(u8).init(allocator);
            y += 1;
            x = 0;
        } else {
            try curr_line.append(c);
            x += 1;
        }
    }

    return Platform{
        .rocks = try rocks.toOwnedSlice(),
        .map = try lines.toOwnedSlice(),
    };
}

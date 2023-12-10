const std = @import("std");
const io = std.io;
const mem = std.mem;
const meta = std.meta;

const Pipe = struct {
    north: bool = false,
    south: bool = false,
    east: bool = false,
    west: bool = false,
    distance: ?u32 = null,
    inside: bool = true,
};

const Ground = struct {
    inside: bool = true,
};

const Tile = union(enum) {
    pipe: Pipe,
    start,
    ground: Ground,

    fn connectsNorth(self: Tile) bool {
        return switch (self) {
            .start => true,
            .pipe => |pipe| pipe.north,
            else => false,
        };
    }

    fn connectsSouth(self: Tile) bool {
        return switch (self) {
            .start => true,
            .pipe => |pipe| pipe.south,
            else => false,
        };
    }

    fn connectsEast(self: Tile) bool {
        return switch (self) {
            .start => true,
            .pipe => |pipe| pipe.east,
            else => false,
        };
    }

    fn connectsWest(self: Tile) bool {
        return switch (self) {
            .start => true,
            .pipe => |pipe| pipe.west,
            else => false,
        };
    }
};

const Pos = struct {
    row: usize,
    col: usize,
    dist: u32 = 0,
};

pub fn solve(allocator: mem.Allocator, tiles: *[][]Tile) ![2]u32 {
    const rows = tiles.*.len;
    const cols = tiles.*[0].len;

    var start_pos = Pos{
        .row = undefined,
        .col = undefined,
    };

    for (0..rows) |row| {
        for (0..cols) |col| {
            switch (tiles.*[row][col]) {
                .start => {
                    start_pos.row = row;
                    start_pos.col = col;
                    break;
                },
                else => {},
            }
        }
    }

    var stack = std.ArrayList(Pos).init(allocator);
    defer stack.deinit();

    try stack.append(start_pos);

    while (stack.items.len > 0) {
        const curr_pos = stack.pop();

        const row = curr_pos.row;
        const col = curr_pos.col;
        const dist = curr_pos.dist;

        const curr_tile = tiles.*[row][col];

        if (curr_tile.connectsNorth() and row > 0) {
            const north = &tiles.*[row - 1][col];
            switch (north.*) {
                .pipe => {
                    if (north.*.pipe.south and (north.*.pipe.distance == null or north.*.pipe.distance.? > (dist + 1))) {
                        north.*.pipe.distance = dist + 1;
                        try stack.append(Pos{ .row = row - 1, .col = col, .dist = dist + 1 });
                    }
                },
                else => {},
            }
        }

        if (curr_tile.connectsEast() and col + 1 < cols) {
            const east = &tiles.*[row][col + 1];
            switch (east.*) {
                .pipe => {
                    if (east.*.pipe.west and (east.*.pipe.distance == null or east.*.pipe.distance.? > dist)) {
                        east.*.pipe.distance = dist + 1;
                        try stack.append(Pos{ .row = row, .col = col + 1, .dist = dist + 1 });
                    }
                },
                else => {},
            }
        }

        if (curr_tile.connectsSouth() and row + 1 < rows) {
            const south = &tiles.*[row + 1][col];
            switch (south.*) {
                .pipe => {
                    if (south.*.pipe.north and (south.*.pipe.distance == null or south.*.pipe.distance.? > dist)) {
                        south.*.pipe.distance = dist + 1;
                        try stack.append(Pos{ .row = row + 1, .col = col, .dist = dist + 1 });
                    }
                },
                else => {},
            }
        }

        if (curr_tile.connectsWest() and col > 0) {
            const west = &tiles.*[row][col - 1];
            switch (west.*) {
                .pipe => {
                    if (west.*.pipe.east and (west.*.pipe.distance == null or west.*.pipe.distance.? > dist)) {
                        west.*.pipe.distance = dist + 1;
                        try stack.append(Pos{ .row = row, .col = col - 1, .dist = dist + 1 });
                    }
                },
                else => {},
            }
        }
    }

    var max_dist: u32 = 0;
    var inside: u32 = 0;

    for (0..rows) |row| {
        var is_outside: bool = true;
        var pipe_from_north: bool = undefined;

        for (0..cols) |col| {
            const tile = tiles.*[row][col];

            switch (tile) {
                .pipe => |pipe| {
                    if (pipe.distance != null) {
                        if (pipe.distance.? > max_dist) {
                            max_dist = pipe.distance.?;
                        }

                        if (!(pipe.west or pipe.east)) {
                            is_outside = !is_outside;
                        }

                        if (!(pipe.west)) {
                            pipe_from_north = pipe.north;
                        }

                        if (!(pipe.east) and pipe.north != pipe_from_north) {
                            is_outside = !is_outside;
                        }
                    } else {
                        if (!is_outside) {
                            inside += 1;
                        }
                    }
                },
                .ground => {
                    if (!is_outside) {
                        inside += 1;
                    }
                },
                .start => {
                    const connects_west = col > 0 and tiles.*[row][col - 1].connectsEast();
                    const connects_east = col + 1 < cols and tiles.*[row][col + 1].connectsWest();
                    const connects_north = row > 0 and tiles.*[row - 1][col].connectsSouth();

                    if (!(connects_west or connects_east)) {
                        is_outside = !is_outside;
                    }
                    if (connects_west and !connects_east) {
                        if (connects_north != pipe_from_north) {
                            is_outside = !is_outside;
                        }
                    }
                    if (connects_east and !connects_west) {
                        pipe_from_north = connects_north;
                    }
                },
            }
        }
    }

    return [2]u32{ max_dist, inside };
}

pub fn freeTiles(allocator: mem.Allocator, tiles: [][]Tile) void {
    for (tiles) |row| allocator.free(row);
    allocator.free(tiles);
}

pub fn parseTiles(allocator: mem.Allocator, input: []const u8) ![][]Tile {
    var result_list = std.ArrayList([]Tile).init(allocator);
    var lines = mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const tiles = try allocator.alloc(Tile, line.len);

        for (0..line.len) |i| {
            tiles[i] = switch (line[i]) {
                '|' => Tile{
                    .pipe = Pipe{
                        .north = true,
                        .south = true,
                    },
                },
                '-' => Tile{
                    .pipe = Pipe{
                        .east = true,
                        .west = true,
                    },
                },
                'L' => Tile{
                    .pipe = Pipe{
                        .north = true,
                        .east = true,
                    },
                },
                'J' => Tile{
                    .pipe = Pipe{
                        .north = true,
                        .west = true,
                    },
                },
                '7' => Tile{
                    .pipe = Pipe{
                        .west = true,
                        .south = true,
                    },
                },
                'F' => Tile{ .pipe = Pipe{
                    .south = true,
                    .east = true,
                } },
                '.' => Tile{ .ground = Ground{} },
                'S' => Tile{ .start = {} },
                else => unreachable,
            };
        }

        try result_list.append(tiles);
    }

    return result_list.toOwnedSlice();
}

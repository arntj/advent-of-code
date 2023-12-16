const std = @import("std");

pub const Direction = enum(u8) {
    n = 0,
    s = 1,
    e = 2,
    w = 3,
};

pub const TileType = enum {
    empty,
    h_split,
    v_split,
    mirror_down,
    mirror_up,
};

pub const Tile = struct {
    type: TileType,
};

test "Can visit tile" {
    var visitor = TileVisitor{};

    try std.testing.expect(!visitor.visited());
    try std.testing.expect(!visitor.visitedDir(.n));

    visitor.visit(.n);

    try std.testing.expect(visitor.visited());
    try std.testing.expect(visitor.visitedDir(.n));
}

pub const TileVisitor = struct {
    visited_tile: [4]bool = [4]bool{
        false,
        false,
        false,
        false,
    },

    pub fn visited(self: TileVisitor) bool {
        return for (self.visited_tile) |v| {
            if (v) break true;
        } else false;
    }

    pub fn visitedDir(self: TileVisitor, direction: Direction) bool {
        return self.visited_tile[@intFromEnum(direction)];
    }

    pub fn visit(self: *TileVisitor, direction: Direction) void {
        self.visited_tile[@intFromEnum(direction)] = true;
    }
};

pub const Beam = struct {
    x: usize,
    y: usize,
    direction: Direction,

    pub fn nextBeam(self: Beam, dir: Direction, rows: usize, cols: usize) ?Beam {
        switch (dir) {
            .n => {
                if (self.y == 0) return null;
                return Beam{
                    .x = self.x,
                    .y = self.y - 1,
                    .direction = .n,
                };
            },
            .s => {
                if (self.y == rows - 1) return null;
                return Beam{
                    .x = self.x,
                    .y = self.y + 1,
                    .direction = .s,
                };
            },
            .w => {
                if (self.x == 0) return null;
                return Beam{
                    .x = self.x - 1,
                    .y = self.y,
                    .direction = .w,
                };
            },
            .e => {
                if (self.x == cols - 1) return null;
                return Beam{
                    .x = self.x + 1,
                    .y = self.y,
                    .direction = .e,
                };
            },
        }
    }
};

test "Contraption parses correctly" {
    const allocator = std.testing.allocator;

    const input =
        \\.|...\....
        \\|.-.\.....
        \\.....|-...
        \\........|.
        \\..........
        \\.........\
        \\..../.\\..
        \\.-.-/..|..
        \\.|....-|.\
        \\..//.|....
        \\
    ;

    const contraption = try Contraption.init(allocator, input);

    try std.testing.expectEqual(@as(usize, 10), contraption.rows);
    try std.testing.expectEqual(@as(usize, 10), contraption.cols);
    try std.testing.expectEqual(TileType.empty, contraption.tiles[9][9].type);
    try std.testing.expectEqual(TileType.v_split, contraption.tiles[1][0].type);
    try std.testing.expectEqual(TileType.h_split, contraption.tiles[2][6].type);
    try std.testing.expectEqual(TileType.mirror_up, contraption.tiles[6][4].type);
    try std.testing.expectEqual(TileType.mirror_down, contraption.tiles[8][9].type);

    contraption.deinit();
}

pub const Contraption = struct {
    tiles: [][]Tile,
    rows: usize,
    cols: usize,

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) !Contraption {
        var tokenizer = std.mem.tokenizeScalar(u8, input, '\n');

        var tiles = std.ArrayList([]Tile).init(allocator);

        while (tokenizer.next()) |line| {
            var curr_line = std.ArrayList(Tile).init(allocator);

            for (line) |c| {
                const tile = Tile{ .type = switch (c) {
                    '.' => .empty,
                    '-' => .h_split,
                    '|' => .v_split,
                    '\\' => .mirror_down,
                    '/' => .mirror_up,
                    else => unreachable,
                } };

                try curr_line.append(tile);
            }

            try tiles.append(try curr_line.toOwnedSlice());
        }

        const rows = tiles.items.len;
        const cols = tiles.items[0].len;

        return Contraption{
            .tiles = try tiles.toOwnedSlice(),
            .rows = rows,
            .cols = cols,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Contraption) void {
        for (self.tiles) |line| {
            self.allocator.free(line);
        }
        self.allocator.free(self.tiles);
    }

    pub fn energizeTopLeft(self: Contraption) !u32 {
        return try self.energize(0, 0, .e);
    }

    pub fn energizeAll(self: Contraption) !u32 {
        var result: u32 = 0;

        for (0..self.rows) |y| {
            result = max(result, try self.energize(0, y, .e));
            result = max(result, try self.energize(self.cols - 1, y, .w));
        }

        for (0..self.cols) |x| {
            result = max(result, try self.energize(x, 0, .s));
            result = max(result, try self.energize(x, self.rows - 1, .n));
        }

        return result;
    }

    fn max(a: u32, b: u32) u32 {
        return if (a > b) a else b;
    }

    fn createTileVisitor(self: Contraption) ![][]TileVisitor {
        var tile_visitor = try self.allocator.alloc([]TileVisitor, self.rows);
        for (0..self.rows) |i| {
            const curr_row = try self.allocator.alloc(TileVisitor, self.cols);
            @memset(curr_row, TileVisitor{});
            tile_visitor[i] = curr_row;
        }

        return tile_visitor;
    }

    fn freeTileVisitor(self: Contraption, tile_visitor: [][]TileVisitor) void {
        for (tile_visitor) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(tile_visitor);
    }

    fn energize(self: Contraption, start_x: usize, start_y: usize, start_dir: Direction) !u32 {
        var beams = std.ArrayList(Beam).init(self.allocator);
        defer beams.deinit();

        try beams.append(Beam{
            .x = start_x,
            .y = start_y,
            .direction = start_dir,
        });

        const tile_visitor = try self.createTileVisitor();
        defer self.freeTileVisitor(tile_visitor);

        var visited: u32 = 0;

        while (beams.popOrNull()) |beam| {
            const curr_tile = &self.tiles[beam.y][beam.x];
            var visitor = &tile_visitor[beam.y][beam.x];

            if (visitor.visitedDir(beam.direction)) {
                continue;
            }

            if (!visitor.visited()) {
                visited += 1;
            }

            visitor.visit(beam.direction);

            switch (curr_tile.type) {
                .empty => {
                    if (beam.nextBeam(beam.direction, self.rows, self.cols)) |next_beam| {
                        try beams.append(next_beam);
                    }
                },
                .h_split => {
                    switch (beam.direction) {
                        .n, .s => {
                            if (beam.nextBeam(.e, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                            if (beam.nextBeam(.w, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                        },
                        .e, .w => {
                            if (beam.nextBeam(beam.direction, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                        },
                    }
                },
                .v_split => {
                    switch (beam.direction) {
                        .e, .w => {
                            if (beam.nextBeam(.n, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                            if (beam.nextBeam(.s, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                        },
                        .n, .s => {
                            if (beam.nextBeam(beam.direction, self.rows, self.cols)) |next_beam| {
                                try beams.append(next_beam);
                            }
                        },
                    }
                },
                .mirror_down => {
                    const next_dir: Direction = switch (beam.direction) {
                        .n => Direction.w,
                        .s => Direction.e,
                        .e => Direction.s,
                        .w => Direction.n,
                    };

                    if (beam.nextBeam(next_dir, self.rows, self.cols)) |next_beam| {
                        try beams.append(next_beam);
                    }
                },
                .mirror_up => {
                    const next_dir: Direction = switch (beam.direction) {
                        .n => Direction.e,
                        .s => Direction.w,
                        .e => Direction.n,
                        .w => Direction.s,
                    };

                    if (beam.nextBeam(next_dir, self.rows, self.cols)) |next_beam| {
                        try beams.append(next_beam);
                    }
                },
            }
        }

        return visited;
    }
};

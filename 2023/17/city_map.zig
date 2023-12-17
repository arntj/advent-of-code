const std = @import("std");

pub const Direction = enum(u8) {
    n = 0,
    s = 1,
    w = 2,
    e = 3,
};

const min_heat_loss_default_value: CityMapUnit = 1_000_000;

pub const MinHeatLoss = struct {
    horizontal: CityMapUnit = min_heat_loss_default_value,
    vertical: CityMapUnit = min_heat_loss_default_value,
};

test "CityMap parses input correctly" {
    const allocator = std.testing.allocator;

    const input =
        \\2413432311323
        \\3215453535623
        \\3255245654254
        \\3446585845452
        \\4546657867536
        \\1438598798454
        \\4457876987766
        \\3637877979653
        \\4654967986887
        \\4564679986453
        \\1224686865563
        \\2546548887735
        \\4322674655533
        \\
    ;

    const result = try CityMap.init(allocator, input);
    defer result.deinit();

    try std.testing.expectEqual(@as(CityMapUnit, 3), result.heat_loss[12][12]);

    try std.testing.expectEqual(@as(CityMapUnit, 102), try result.navigate(false));
    try std.testing.expectEqual(@as(CityMapUnit, 94), try result.navigate(true));
}

const CityMapUnit = u32;

pub const CityMap = struct {
    heat_loss: [][]const CityMapUnit,
    rows: usize,
    cols: usize,

    allocator: std.mem.Allocator,

    fn createMinHeatLossIndex(self: CityMap) ![][]MinHeatLoss {
        var min_heat_loss = try self.allocator.alloc([]MinHeatLoss, self.rows);
        for (0..self.rows) |i| {
            min_heat_loss[i] = try self.allocator.alloc(MinHeatLoss, self.cols);
            @memset(min_heat_loss[i], MinHeatLoss{});
        }

        min_heat_loss[0][0].horizontal = 0;
        min_heat_loss[0][0].vertical = 0;

        return min_heat_loss;
    }

    fn freeMinHeatLossIndex(self: CityMap, min_heat_loss: [][]MinHeatLoss) void {
        for (min_heat_loss) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(min_heat_loss);
    }

    pub fn navigate(self: CityMap, ultra_crucible: bool) !CityMapUnit {
        const min_heat_loss = try self.createMinHeatLossIndex();
        defer self.freeMinHeatLossIndex(min_heat_loss);

        for (0..50) |_| {
            for (0..self.rows) |y| {
                for (0..self.cols) |x| {
                    var heat_loss: [4]CityMapUnit = undefined;
                    heat_loss[@intFromEnum(Direction.n)] = min_heat_loss[y][x].horizontal;
                    heat_loss[@intFromEnum(Direction.s)] = min_heat_loss[y][x].horizontal;
                    heat_loss[@intFromEnum(Direction.w)] = min_heat_loss[y][x].vertical;
                    heat_loss[@intFromEnum(Direction.e)] = min_heat_loss[y][x].vertical;

                    const end: usize = if (ultra_crucible) 11 else 4;

                    for (1..end) |i| {
                        if (y >= i) {
                            const curr_heat_loss = &heat_loss[@intFromEnum(Direction.n)];
                            curr_heat_loss.* += self.heat_loss[y - i][x];

                            if (!ultra_crucible or i >= 4) {
                                const next_heat_loss = &min_heat_loss[y - i][x].vertical;
                                if (next_heat_loss.* > curr_heat_loss.*) next_heat_loss.* = curr_heat_loss.*;
                            }
                        }
                        if (y + i < self.rows) {
                            const curr_heat_loss = &heat_loss[@intFromEnum(Direction.s)];
                            curr_heat_loss.* += self.heat_loss[y + i][x];

                            if (!ultra_crucible or i >= 4) {
                                const next_heat_loss = &min_heat_loss[y + i][x].vertical;
                                if (next_heat_loss.* > curr_heat_loss.*) next_heat_loss.* = curr_heat_loss.*;
                            }
                        }
                        if (x >= i) {
                            const curr_heat_loss = &heat_loss[@intFromEnum(Direction.w)];
                            curr_heat_loss.* += self.heat_loss[y][x - i];

                            if (!ultra_crucible or i >= 4) {
                                const next_heat_loss = &min_heat_loss[y][x - i].horizontal;
                                if (next_heat_loss.* > curr_heat_loss.*) next_heat_loss.* = curr_heat_loss.*;
                            }
                        }
                        if (x + i < self.cols) {
                            const curr_heat_loss = &heat_loss[@intFromEnum(Direction.e)];
                            curr_heat_loss.* += self.heat_loss[y][x + i];

                            if (!ultra_crucible or i >= 4) {
                                const next_heat_loss = &min_heat_loss[y][x + i].horizontal;
                                if (next_heat_loss.* > curr_heat_loss.*) next_heat_loss.* = curr_heat_loss.*;
                            }
                        }
                    }
                }
            }
        }

        const final = min_heat_loss[self.rows - 1][self.cols - 1];

        return if (final.horizontal > final.vertical) final.vertical else final.horizontal;
    }

    pub fn init(allocator: std.mem.Allocator, input_str: []const u8) !CityMap {
        var input_rows = std.mem.tokenizeScalar(u8, input_str, '\n');

        var heat_loss = std.ArrayList([]const CityMapUnit).init(allocator);

        while (input_rows.next()) |line| {
            var blocks = std.ArrayList(CityMapUnit).init(allocator);

            for (line) |c| {
                try blocks.append(c - '0');
            }

            try heat_loss.append(try blocks.toOwnedSlice());
        }

        const rows = heat_loss.items.len;
        const cols = heat_loss.items[0].len;

        return CityMap{
            .heat_loss = try heat_loss.toOwnedSlice(),
            .rows = rows,
            .cols = cols,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: CityMap) void {
        for (self.heat_loss) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.heat_loss);
    }
};

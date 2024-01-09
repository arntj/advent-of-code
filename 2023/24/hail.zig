const std = @import("std");

const HailNumberType = f64;

pub const Hailstone = struct {
    px: HailNumberType,
    py: HailNumberType,
    pz: HailNumberType,
    vx: HailNumberType,
    vy: HailNumberType,
    vz: HailNumberType,
};

test "parseHail should parse correctly" {
    const allocator = std.testing.allocator;

    const test_data =
        \\19, 13, 30 @ -2,  1, -2
        \\18, 19, 22 @ -1, -1, -2
    ;

    const result = try parseHail(allocator, test_data);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(Hailstone{ .px = 19.0, .py = 13.0, .pz = 30.0, .vx = -2.0, .vy = 1.0, .vz = -2.0 }, result[0]);
    try std.testing.expectEqual(Hailstone{ .px = 18.0, .py = 19.0, .pz = 22.0, .vx = -1.0, .vy = -1.0, .vz = -2.0 }, result[1]);
}

fn parseHail(allocator: std.mem.Allocator, input: []const u8) ![]Hailstone {
    var hail_list = std.ArrayList(Hailstone).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const at_pos = std.mem.indexOfScalar(u8, line, '@').?;

        var p_iter = std.mem.tokenizeSequence(u8, line[0..at_pos], ", ");
        var v_iter = std.mem.tokenizeSequence(u8, line[at_pos + 1 .. line.len], ", ");

        try hail_list.append(Hailstone{
            .px = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, p_iter.next().?, " ")),
            .py = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, p_iter.next().?, " ")),
            .pz = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, p_iter.next().?, " ")),
            .vx = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, v_iter.next().?, " ")),
            .vy = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, v_iter.next().?, " ")),
            .vz = try std.fmt.parseFloat(HailNumberType, std.mem.trim(u8, v_iter.next().?, " ")),
        });
    }

    return hail_list.toOwnedSlice();
}

test "willIntersect returns correct answer for hailstones crossing inside test area" {
    const a = Hailstone{
        .px = 19.0,
        .py = 13.0,
        .pz = 30.0,
        .vx = -2.0,
        .vy = 1.0,
        .vz = -2.0,
    };
    const b = Hailstone{
        .px = 18.0,
        .py = 19.0,
        .pz = 22.0,
        .vx = -1.0,
        .vy = -1.0,
        .vz = -2.0,
    };

    const result = willIntersect(a, b, 7.0, 27.0);

    try std.testing.expect(result);
}

test "willIntersect returns correct answer for hailstones crossing outside test area" {
    const a = Hailstone{
        .px = 19.0,
        .py = 13.0,
        .pz = 30.0,
        .vx = -2.0,
        .vy = 1.0,
        .vz = -2.0,
    };
    const b = Hailstone{
        .px = 12.0,
        .py = 31.0,
        .pz = 28.0,
        .vx = -1.0,
        .vy = -2.0,
        .vz = -1.0,
    };

    const result = willIntersect(a, b, 7.0, 27.0);

    try std.testing.expect(!result);
}

test "willIntersect returns correct answer for hailstones where one crossed in the past" {
    const a = Hailstone{
        .px = 19.0,
        .py = 13.0,
        .pz = 30.0,
        .vx = -2.0,
        .vy = 1.0,
        .vz = -2.0,
    };
    const b = Hailstone{
        .px = 20.0,
        .py = 19.0,
        .pz = 15.0,
        .vx = 1.0,
        .vy = -5.0,
        .vz = -3.0,
    };

    const result = willIntersect(a, b, 7.0, 27.0);

    try std.testing.expect(!result);
}

test "willIntersect returns correct answer for hailstones with parallell paths" {
    const a = Hailstone{
        .px = 18.0,
        .py = 19.0,
        .pz = 22.0,
        .vx = -1.0,
        .vy = -1.0,
        .vz = -2.0,
    };
    const b = Hailstone{
        .px = 20.0,
        .py = 25.0,
        .pz = 34.0,
        .vx = -2.0,
        .vy = -2.0,
        .vz = -4.0,
    };

    const result = willIntersect(a, b, 7.0, 27.0);

    try std.testing.expect(!result);
}

fn willIntersect(a: Hailstone, b: Hailstone, low: HailNumberType, high: HailNumberType) bool {
    if (a.vx == b.vx and a.vy == b.vy) return false;

    const t_a = (b.vx * (a.py - b.py) - b.vy * (a.px - b.px)) / (a.vx * b.vy - a.vy * b.vx);
    const t_b = (a.vx * (b.py - a.py) - a.vy * (b.px - a.px)) / (b.vx * a.vy - b.vy * a.vx);

    if (t_a < 0.0 or t_b < 0.0) return false;

    const x = a.px + a.vx * t_a;
    const y = a.py + a.vy * t_a;

    return x >= low and x <= high and y >= low and y <= high;
}

test "calculateHailPaths should return correct result for test data" {
    const allocator = std.testing.allocator;

    const test_data =
        \\19, 13, 30 @ -2,  1, -2
        \\18, 19, 22 @ -1, -1, -2
        \\20, 25, 34 @ -2, -2, -4
        \\12, 31, 28 @ -1, -2, -1
        \\20, 19, 15 @  1, -5, -3
    ;

    const result = try calculateHailPaths(allocator, test_data, 7.0, 27.0);

    try std.testing.expectEqual(@as(u32, 2), result);
}

pub fn calculateHailPaths(allocator: std.mem.Allocator, input: []const u8, low: HailNumberType, high: HailNumberType) !u32 {
    var result: u32 = 0;

    const hailstones = try parseHail(allocator, input);
    defer allocator.free(hailstones);

    for (0..hailstones.len - 1) |i| {
        for (i + 1..hailstones.len) |j| {
            const a = hailstones[i];
            const b = hailstones[j];

            if (willIntersect(a, b, low, high)) {
                result += 1;
            }
        }
    }

    return result;
}

pub fn findRockPath(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const hailstones = try parseHail(allocator, input);
    defer allocator.free(hailstones);

    var solution: Hailstone = undefined;

    var matrix = [4]@Vector(5, HailNumberType){
        undefined,
        undefined,
        undefined,
        undefined,
    };

    // find solution for x and y
    for (0..4) |i| {
        matrix[i][0] = hailstones[i + 1].vy - hailstones[i].vy;
        matrix[i][1] = hailstones[i].vx - hailstones[i + 1].vx;
        matrix[i][2] = hailstones[i].py - hailstones[i + 1].py;
        matrix[i][3] = hailstones[i + 1].px - hailstones[i].px;
        matrix[i][4] = hailstones[i + 1].px * hailstones[i + 1].vy - hailstones[i + 1].py * hailstones[i + 1].vx - hailstones[i].px * hailstones[i].vy + hailstones[i].py * hailstones[i].vx;
    }

    gaussElim(&matrix);

    solution.px = matrix[0][4];
    solution.py = matrix[1][4];
    solution.vx = matrix[2][4];
    solution.vy = matrix[3][4];

    // find solution for y and z
    for (0..4) |i| {
        matrix[i][0] = hailstones[i + 1].vz - hailstones[i].vz;
        matrix[i][1] = hailstones[i].vy - hailstones[i + 1].vy;
        matrix[i][2] = hailstones[i].pz - hailstones[i + 1].pz;
        matrix[i][3] = hailstones[i + 1].py - hailstones[i].py;
        matrix[i][4] = hailstones[i + 1].py * hailstones[i + 1].vz - hailstones[i + 1].pz * hailstones[i + 1].vy - hailstones[i].py * hailstones[i].vz + hailstones[i].pz * hailstones[i].vy;
    }

    gaussElim(&matrix);

    solution.pz = matrix[1][4];
    solution.vz = matrix[3][4];

    var result: u64 = 0;
    result += @intFromFloat(solution.px);
    result += @intFromFloat(solution.py);
    result += @intFromFloat(solution.pz);
    return result;
}

fn gaussElim(matrix: *[4]@Vector(5, HailNumberType)) void {
    const rows = 4;
    const cols = 5;

    for (0..rows) |i| {
        const divide_by = matrix[i][i];
        for (0..cols) |j| {
            matrix[i][j] /= divide_by;
        }
        for (i + 1..rows) |j| {
            const factor = matrix[j][i];
            if (factor != 0.0) {
                for (0..cols) |k| {
                    matrix[j][k] -= factor * matrix[i][k];
                }
            }
        }
    }
    for (0..rows - 1) |i_inv| {
        const i = rows - 1 - i_inv;

        for (0..i) |j| {
            matrix[j][4] -= matrix[j][i] * matrix[i][4];
            matrix[j][i] = 0.0;
        }
    }
}

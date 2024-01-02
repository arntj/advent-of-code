const std = @import("std");

const BrickPos = struct {
    x: u16,
    y: u16,
    z: u16,
};

const Brick = struct {
    from: BrickPos,
    to: BrickPos,
};

pub fn fallingBricks(allocator: std.mem.Allocator, bricks: []Brick) ![2]u64 {
    _ = try fall(allocator, bricks);

    var safe_to_disintegrate: u64 = @truncate(bricks.len);
    var would_fall: u64 = 0;

    const bricks_copy = try allocator.alloc(Brick, bricks.len - 1);
    defer allocator.free(bricks_copy);

    for (0..bricks.len) |i| {
        for (0..bricks.len) |j| {
            if (j == i) continue;

            if (j < i) {
                bricks_copy[j] = bricks[j];
            } else {
                bricks_copy[j - 1] = bricks[j];
            }
        }

        if (i < bricks.len - 1) {
            for (i + 1..bricks.len) |j| {
                bricks_copy[j - 1] = bricks[j];
            }
        }

        const fallen_bricks = try fall(allocator, bricks_copy);

        if (fallen_bricks > 0) {
            safe_to_disintegrate -= 1;
            would_fall += fallen_bricks;
        }
    }

    return [2]u64{ safe_to_disintegrate, would_fall };
}

fn fall(allocator: std.mem.Allocator, bricks: []Brick) !u64 {
    var fallen_bricks = std.AutoHashMap(usize, void).init(allocator);
    defer fallen_bricks.deinit();

    var has_moved = true;

    while (has_moved) {
        has_moved = false;

        for (0..bricks.len) |i| {
            const brick = &bricks[i];

            const fall_height = fallHeight(brick, bricks, null);
            if (fall_height > 0) {
                brick.from.z -= fall_height;
                brick.to.z -= fall_height;
                has_moved = true;
                try fallen_bricks.put(i, {});
            }
        }
    }

    return fallen_bricks.count();
}

fn fallHeight(brick: *Brick, bricks: []Brick, skip_brick: ?*Brick) u16 {
    if (brick.from.z <= 1) return 0;

    var result: ?u16 = null;

    for (bricks) |*other_brick| {
        if (brick == other_brick) continue;
        if (skip_brick != null and skip_brick.? == other_brick) continue;

        const x_overlap = brick.from.x <= other_brick.to.x and other_brick.from.x <= brick.to.x;
        const y_overlap = brick.from.y <= other_brick.to.y and other_brick.from.y <= brick.to.y;

        if (x_overlap and y_overlap and brick.from.z > (other_brick.to.z)) {
            if (brick.from.z == (other_brick.to.z + 1)) return 0;

            const z_diff = brick.from.z - (other_brick.to.z + 1);
            if (result == null or z_diff < result.?) result = z_diff;
        }
    }

    return result orelse brick.from.z - 1;
}

pub fn parseBricks(allocator: std.mem.Allocator, input: []const u8) ![]Brick {
    var bricks_list = std.ArrayList(Brick).init(allocator);

    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines_iter.next()) |line| {
        try bricks_list.append(try parseBrick(line));
    }

    return bricks_list.toOwnedSlice();
}

fn parseBrick(input: []const u8) !Brick {
    var parts = std.mem.splitScalar(u8, input, '~');

    return Brick{
        .from = try parseBrickPos(parts.next().?),
        .to = try parseBrickPos(parts.next().?),
    };
}

fn parseBrickPos(input: []const u8) !BrickPos {
    var parts = std.mem.splitScalar(u8, input, ',');

    return BrickPos{
        .x = try std.fmt.parseInt(u16, parts.next().?, 10),
        .y = try std.fmt.parseInt(u16, parts.next().?, 10),
        .z = try std.fmt.parseInt(u16, parts.next().?, 10),
    };
}

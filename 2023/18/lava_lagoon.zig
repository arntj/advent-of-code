const std = @import("std");

const LagoonNumberType = i64;

const Direction = enum {
    u,
    d,
    l,
    r,
};

const LavaLagoon = struct {
    instructions: []Instruction,
    instructions_corrected: []Instruction,
};

const Instruction = struct {
    direction: Direction,
    distance: LagoonNumberType,
};

test "Parses lagoon correctly" {
    const allocator = std.testing.allocator;
    const input =
        \\R 6 (#70c710)
        \\D 5 (#0dc571)
        \\U 30 (#5713f0)
        \\
    ;

    const result = try parseLagoon(allocator, input);
    defer freeLagoon(allocator, result);

    try std.testing.expectEqual(Direction.r, result.instructions[0].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 6), result.instructions[0].distance);

    try std.testing.expectEqual(Direction.d, result.instructions[1].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 5), result.instructions[1].distance);

    try std.testing.expectEqual(Direction.u, result.instructions[2].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 30), result.instructions[2].distance);

    try std.testing.expectEqual(Direction.r, result.instructions_corrected[0].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 461937), result.instructions_corrected[0].distance);

    try std.testing.expectEqual(Direction.d, result.instructions_corrected[1].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 56407), result.instructions_corrected[1].distance);

    try std.testing.expectEqual(Direction.r, result.instructions_corrected[2].direction);
    try std.testing.expectEqual(@as(LagoonNumberType, 356671), result.instructions_corrected[2].distance);
}
pub fn parseLagoon(allocator: std.mem.Allocator, input: []const u8) !LavaLagoon {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var instructions = std.ArrayList(Instruction).init(allocator);
    var instructions_corrected = std.ArrayList(Instruction).init(allocator);

    while (lines.next()) |line| {
        const direction: Direction = switch (line[0]) {
            'U' => .u,
            'D' => .d,
            'L' => .l,
            'R' => .r,
            else => unreachable,
        };
        const dist_str = line[2 .. line.len - 10];

        const direction_corrected: Direction = switch (line[line.len - 2]) {
            '0' => .r,
            '1' => .d,
            '2' => .l,
            '3' => .u,
            else => unreachable,
        };
        const dist_hex = line[line.len - 7 .. line.len - 2];

        try instructions.append(Instruction{
            .direction = direction,
            .distance = try std.fmt.parseInt(LagoonNumberType, dist_str, 10),
        });

        try instructions_corrected.append(Instruction{
            .direction = direction_corrected,
            .distance = try std.fmt.parseInt(LagoonNumberType, dist_hex, 16),
        });
    }

    return LavaLagoon{
        .instructions = try instructions.toOwnedSlice(),
        .instructions_corrected = try instructions_corrected.toOwnedSlice(),
    };
}

pub fn freeLagoon(allocator: std.mem.Allocator, lagoon: LavaLagoon) void {
    allocator.free(lagoon.instructions);
    allocator.free(lagoon.instructions_corrected);
}

pub fn digLagoon(instructions: []const Instruction) LagoonNumberType {
    var x: LagoonNumberType = 0;
    var y: LagoonNumberType = 0;

    var result: LagoonNumberType = 0;
    var boundary: LagoonNumberType = 0;

    for (instructions) |instr| {
        const prev_x = x;
        const prev_y = y;

        switch (instr.direction) {
            .u => {
                y -= instr.distance;
            },
            .d => {
                y += instr.distance;
            },
            .l => {
                x -= instr.distance;
            },
            .r => {
                x += instr.distance;
            },
        }

        boundary += instr.distance;
        result += prev_x * y - x * prev_y;
    }

    result = @divFloor(result, 2);
    result += @divFloor(boundary, 2) + 1;

    return result;
}

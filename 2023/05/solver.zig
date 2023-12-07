const std = @import("std");
const parser = @import("./parser.zig");
const mem = std.mem;

const UnitRange = struct {
    start: i64,
    end: i64,
};

pub fn solve(allocator: mem.Allocator, almanac: parser.Almanac) ![2]i64 {
    var units = try allocator.dupe(i64, almanac.seeds);
    defer allocator.free(units);

    var unit_ranges = std.ArrayList(?UnitRange).init(allocator);
    defer unit_ranges.deinit();

    for (0..units.len / 2) |i| {
        try unit_ranges.append(UnitRange{
            .start = units[i * 2],
            .end = units[i * 2] + units[i * 2 + 1] - 1,
        });
    }

    for (almanac.maps) |map| {
        for (0..units.len) |i| {
            const unit = units[i];
            var next_unit: ?i64 = null;

            for (map.ranges) |range| {
                if (unit >= range.source and unit < (range.source + range.len)) {
                    next_unit = range.dest + (unit - range.source);
                    break;
                }
            }

            units[i] = next_unit orelse unit;
        }

        var new_unit_ranges = std.ArrayList(?UnitRange).init(allocator);

        for (map.ranges) |range| {
            for (0..unit_ranges.items.len) |i| {
                const curr_range = unit_ranges.items[i] orelse continue;

                if (getOverlap(curr_range, range)) |overlap| {
                    if (overlap.start > curr_range.start) {
                        try unit_ranges.append(UnitRange{
                            .start = curr_range.start,
                            .end = overlap.start - 1,
                        });
                    }
                    if (overlap.end < curr_range.end) {
                        try unit_ranges.append(UnitRange{
                            .start = overlap.end + 1,
                            .end = curr_range.end,
                        });
                    }

                    try new_unit_ranges.append(UnitRange{
                        .start = overlap.start + (range.dest - range.source),
                        .end = overlap.end + (range.dest - range.source),
                    });

                    unit_ranges.items[i] = null;
                }
            }
        }

        for (unit_ranges.items) |curr_range| {
            if (curr_range == null) continue;

            try new_unit_ranges.append(curr_range);
        }

        unit_ranges.deinit();
        unit_ranges = new_unit_ranges;
    }

    var part_1_solution: i64 = units[0];

    for (units[1..units.len]) |unit| {
        if (unit < part_1_solution) part_1_solution = unit;
    }

    var part_2_solution: i64 = 999999999;

    for (unit_ranges.items[0..unit_ranges.items.len]) |unit_range_or_null| {
        const unit_range = unit_range_or_null orelse continue;

        if (unit_range.start < part_2_solution) part_2_solution = unit_range.start;
    }

    return [2]i64{ part_1_solution, part_2_solution };
}

const Overlap = struct {
    start: i64,
    end: i64,
};

fn getOverlap(unit_range: UnitRange, range: parser.Range) ?Overlap {
    const range_end = range.source + range.len - 1;

    if (range.source > unit_range.end or range_end < unit_range.start) return null;

    const start = if (range.source < unit_range.start) unit_range.start else range.source;
    const end = if (range_end > unit_range.end) unit_range.end else range_end;

    return Overlap{
        .start = start,
        .end = end,
    };
}

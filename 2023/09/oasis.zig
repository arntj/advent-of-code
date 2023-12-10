const std = @import("std");
const mem = std.mem;

pub fn extrapolateValues(values: [][]const i32) [2]i32 {
    var result = @Vector(2, i32){ 0, 0 };

    for (values) |line| {
        result += extrapolateLine(line);
    }

    return result;
}

pub fn extrapolateLine(values: []const i32) @Vector(2, i32) {
    if (isOnlyZeroes(values)) return @Vector(2, i32){ 0, 0 };

    var buffer: [100]i32 = undefined;
    var diff = buffer[0 .. values.len - 1];

    for (0..diff.len) |i| {
        diff[i] = values[i + 1] - values[i];
    }

    const result = extrapolateLine(diff);

    return @Vector(2, i32){ values[0] - result[0], values[values.len - 1] + result[1] };
}

pub fn isOnlyZeroes(slice: []const i32) bool {
    return mem.indexOfNone(i32, slice, &[_]i32{0}) == null;
}

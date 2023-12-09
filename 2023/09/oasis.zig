const std = @import("std");
const mem = std.mem;

pub fn extrapolate_values(values: [][]const i32) [2]i32 {
    var result = @Vector(2, i32){ 0, 0 };

    for (values) |line| {
        result += extrapolate_line(line);
    }

    return result;
}

pub fn extrapolate_line(values: []const i32) @Vector(2, i32) {
    if (is_only_zeros(values)) return @Vector(2, i32){ 0, 0 };

    var buffer: [100]i32 = undefined;
    var diff = buffer[0 .. values.len - 1];

    for (0..diff.len) |i| {
        diff[i] = values[i + 1] - values[i];
    }

    const result = extrapolate_line(diff);

    return @Vector(2, i32){ values[0] - result[0], values[values.len - 1] + result[1] };
}

pub fn is_only_zeros(slice: []const i32) bool {
    return mem.indexOfNone(i32, slice, &[_]i32{0}) == null;
}

const std = @import("std");
const mem = std.mem;

pub fn extrapolate_values(values: [][]const i32) [2]i32 {
    var result = [2]i32{ 0, 0 };

    for (values) |line| {
        var buffer: [100][100]i32 = undefined;

        var i: usize = 0;
        var slice = buffer[0][1 .. line.len + 1];
        @memcpy(slice, line);

        // calculate diffs until all zero
        while (mem.indexOfNone(i32, slice, &[_]i32{0}) != null) : (i += 1) {
            var next_slice = buffer[i + 1][1..slice.len];

            for (0..next_slice.len) |j| {
                next_slice[j] = slice[j + 1] - slice[j];
            }

            slice = next_slice;
        }

        // init extrapolation
        slice = buffer[i][0 .. slice.len + 2];
        slice[0] = 0;
        slice[slice.len - 1] = 0;

        // extrapolate backwards
        while (i > 0) : (i -= 1) {
            var next_slice = buffer[i - 1][0 .. slice.len + 1];
            next_slice[0] = next_slice[1] - slice[0];
            next_slice[next_slice.len - 1] = next_slice[next_slice.len - 2] + slice[slice.len - 1];
            slice = next_slice;
        }

        result[0] += slice[slice.len - 1];
        result[1] += slice[0];
    }

    return result;
}

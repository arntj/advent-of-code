const std = @import("std");

pub const Lens = struct {
    label: []const u8,
    focal_length: u8,
};

pub fn hashmap(allocator: std.mem.Allocator, str: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var boxes: [256][]Lens = undefined;
    const empty: []Lens = &[_]Lens{};
    @memset(&boxes, empty);

    var instructions = std.mem.tokenizeAny(u8, str, ",\n");

    while (instructions.next()) |instr| {
        if (instr[instr.len - 1] == '-') {
            const label = instr[0 .. instr.len - 1];
            const i = hash(label);
            const lenses_in_box = &boxes[i];

            var found: bool = false;
            for (0..lenses_in_box.len) |j| {
                if (std.mem.eql(u8, label, lenses_in_box.*[j].label)) {
                    found = true;
                }

                if (found and j + 1 < lenses_in_box.len) lenses_in_box.*[j] = lenses_in_box.*[j + 1];
            }

            if (found) {
                boxes[i] = lenses_in_box.*[0 .. lenses_in_box.len - 1];
            }
        } else {
            var parts = std.mem.splitScalar(u8, instr, '=');
            const label = parts.next().?;
            const i = hash(label);
            const lenses_in_box = boxes[i];

            const focal_length_str = parts.next().?;
            const focal_length = try std.fmt.parseInt(u8, focal_length_str, 10);

            for (lenses_in_box) |*lens| {
                if (std.mem.eql(u8, label, lens.label)) {
                    lens.focal_length = focal_length;
                    break;
                }
            } else {
                var new_lenses_in_box = try alloc.alloc(Lens, lenses_in_box.len + 1);
                @memcpy(new_lenses_in_box[0..lenses_in_box.len], lenses_in_box);
                new_lenses_in_box[lenses_in_box.len] = Lens{
                    .label = label,
                    .focal_length = focal_length,
                };
                boxes[i] = new_lenses_in_box;
            }
        }
    }

    var result: u32 = 0;

    for (0..boxes.len) |i| {
        const lenses_in_box = boxes[i];

        for (0..lenses_in_box.len) |j| {
            const lens = lenses_in_box[j];

            result += @as(u32, @truncate((i + 1) * (j + 1) * lens.focal_length));
        }
    }

    return result;
}

pub fn sum_hash(input: []const u8) u32 {
    var instructions = std.mem.tokenizeAny(u8, input, ",\n");

    var sum: u32 = 0;

    while (instructions.next()) |inst| {
        sum += hash(inst);
    }

    return sum;
}

pub fn hash(str: []const u8) u8 {
    var result: u32 = 0;

    for (str) |c| result = (result + c) * 17 % 256;

    return @as(u8, @truncate(result));
}

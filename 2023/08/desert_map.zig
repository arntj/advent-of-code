const std = @import("std");
const mem = std.mem;

const MapNode = struct {
    name: []const u8,
    left: *MapNode,
    right: *MapNode,
};

const DesertMap = struct {
    directions: []const u8,
    nodes: []MapNode,
};

pub fn freeMap(allocator: mem.Allocator, map: DesertMap) void {
    allocator.free(map.directions);
    for (map.nodes) |*node| {
        allocator.free(node.name);
    }
    allocator.free(map.nodes);
}

pub fn parseMap(allocator: mem.Allocator, input: []const u8) !DesertMap {
    var lines = mem.tokenizeScalar(u8, input, '\n');

    const directions = try allocator.dupe(u8, lines.next().?);

    var nodes = std.ArrayList(MapNode).init(allocator);

    // fill in with node names
    while (lines.next()) |line| {
        try nodes.append(MapNode{
            .name = try allocator.dupe(u8, line[0..3]),
            .left = undefined,
            .right = undefined,
        });
    }

    // start over
    lines.reset();
    _ = lines.next();
    var i: usize = 0;

    // fill in with node directions (pointers to next node)
    while (lines.next()) |line| : (i += 1) {
        const left_str = line[7..10];
        const right_str = line[12..15];

        var left: ?*MapNode = null;
        var right: ?*MapNode = null;

        for (nodes.items) |*node| {
            if (mem.eql(u8, left_str, node.name)) left = node;
            if (mem.eql(u8, right_str, node.name)) right = node;

            if (left != null and right != null) break;
        }

        nodes.items[i].left = left.?;
        nodes.items[i].right = right.?;
    }

    return DesertMap{
        .directions = directions,
        .nodes = try nodes.toOwnedSlice(),
    };
}

pub fn walkMap(allocator: mem.Allocator, map: DesertMap, is_ghost: bool) !u64 {
    var cycles = std.ArrayList(u64).init(allocator);
    defer cycles.deinit();

    // find out how many steps it takes to reach the end node for each start node - the cycle lengths
    for (map.nodes) |*node| {
        if (is_ghost) {
            if (node.name[2] != 'A') continue;
        } else {
            if (!mem.eql(u8, node.name, "AAA")) continue;
        }

        var curr_node = &node;
        var counter: u64 = 0;
        var index: usize = 0;

        while (true) {
            counter += 1;
            const d = map.directions[index];
            curr_node = if (d == 'L') &curr_node.*.left else &curr_node.*.right;

            if (is_ghost) {
                if (curr_node.*.name[2] == 'Z') break;
            } else {
                if (mem.eql(u8, curr_node.*.name, "ZZZ")) break;
            }

            index = (index + 1) % map.directions.len;
        }
        try cycles.append(counter);
    }

    var steps: u64 = cycles.items[0];

    // find out the least number of steps that is divisible by all cycle lengths
    for (cycles.items[1..cycles.items.len]) |c| {
        const curr_steps = steps;

        while (steps % c != 0) steps += curr_steps;
    }

    return steps;
}

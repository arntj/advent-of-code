const std = @import("std");

pub const Pos = struct {
    x: u16,
    y: u16,
};

pub const Direction = enum(u8) {
    n = 0,
    s = 1,
    w = 2,
    e = 3,
};

pub const directions = [_]Direction{ .n, .s, .w, .e };

pub const HikeResult = struct {
    to: Pos,
    dist: u16,
};

const HikeEdge = struct {
    from: Pos,
    to: Pos,
};

const Graph = struct {
    nodes: []Node,
    start: Pos,
    end: Pos,
};

const Node = struct {
    pos: Pos,
    edges: []Edge,
};

const Edge = struct {
    from: Pos,
    to: Pos,
    dist: u16,
};

const Hike = struct {
    node: Pos,
    dist: u16,
    been_at: *std.AutoHashMap(Pos, void),
};

pub fn findLongestPath(allocator: std.mem.Allocator, input: []const []const u8, slippery: bool) !u16 {
    const graph = try buildGraph(allocator, input, slippery);
    defer freeGraph(allocator, graph);

    return try walkGraph(allocator, graph);
}

pub fn walkGraph(allocator: std.mem.Allocator, graph: Graph) !u16 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var outbound_edges = std.AutoHashMap(Pos, []Edge).init(alloc);

    for (graph.nodes) |node| {
        try outbound_edges.put(node.pos, node.edges);
    }

    var longest_distance: u16 = 0;
    var hikes = std.ArrayList(Hike).init(alloc);

    const been_at = try alloc.create(std.AutoHashMap(Pos, void));
    been_at.* = std.AutoHashMap(Pos, void).init(alloc);
    try hikes.append(Hike{ .node = graph.start, .dist = 0, .been_at = been_at });

    while (hikes.popOrNull()) |hike| {
        const edges = outbound_edges.get(hike.node) orelse unreachable;
        try hike.been_at.*.put(hike.node, {});
        var has_added: bool = false;

        for (edges) |e| {
            if (hike.been_at.*.contains(e.to)) continue;

            const new_dist = hike.dist + e.dist;

            if (std.meta.eql(e.to, graph.end)) {
                if (new_dist > longest_distance) longest_distance = new_dist;
                continue;
            }

            var next_been_at = hike.been_at;
            if (has_added) {
                next_been_at = try alloc.create(std.AutoHashMap(Pos, void));
                next_been_at.* = try hike.been_at.*.clone();
            }
            has_added = true;

            try hikes.append(Hike{ .node = e.to, .dist = new_dist, .been_at = next_been_at });
        }
    }

    return longest_distance;
}

pub fn buildGraph(allocator: std.mem.Allocator, input: []const []const u8, slippery: bool) !Graph {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const rows = input.len;

    var edges_map = std.AutoHashMap(HikeEdge, u16).init(alloc);
    var nodes_to_visit = std.ArrayList(Pos).init(alloc);
    try nodes_to_visit.append(Pos{ .x = 1, .y = 0 });
    var end: Pos = undefined;

    while (nodes_to_visit.popOrNull()) |node| {
        if (node.y == rows - 1) {
            // don't need to explore paths from end node
            end = node;
            continue;
        }
        for (directions) |dir| {
            if (hikePath(input, node, dir, slippery)) |hike_result| {
                const key = HikeEdge{ .from = node, .to = hike_result.to };
                const existing_value = edges_map.get(key);
                const curr_dist = existing_value orelse 0;

                if (hike_result.dist > curr_dist) {
                    try edges_map.put(HikeEdge{ .from = node, .to = hike_result.to }, hike_result.dist);
                }

                if (existing_value == null) {
                    try nodes_to_visit.append(hike_result.to);
                }
            }
        }
    }

    var outbound_edges = std.AutoHashMap(Pos, *std.ArrayList(Edge)).init(alloc);
    var edges_iter = edges_map.iterator();

    while (edges_iter.next()) |entry| {
        const from = entry.key_ptr.*.from;
        const to = entry.key_ptr.*.to;
        const dist = entry.value_ptr.*;
        if (!outbound_edges.contains(from)) {
            const new_list = try alloc.create(std.ArrayList(Edge));
            new_list.* = std.ArrayList(Edge).init(alloc);
            try outbound_edges.put(from, new_list);
        }
        try outbound_edges.get(from).?.*.append(Edge{ .from = from, .to = to, .dist = dist });
    }

    var nodes = std.ArrayList(Node).init(allocator);
    var outbound_iter = outbound_edges.iterator();

    while (outbound_iter.next()) |entry| {
        const pos = entry.key_ptr.*;
        const edges = try allocator.dupe(Edge, entry.value_ptr.*.items);

        try nodes.append(Node{ .pos = pos, .edges = edges });
    }

    return Graph{
        .nodes = try nodes.toOwnedSlice(),
        .start = Pos{ .x = 1, .y = 0 },
        .end = end,
    };
}

pub fn freeGraph(allocator: std.mem.Allocator, graph: Graph) void {
    for (graph.nodes) |node| {
        allocator.free(node.edges);
    }
    allocator.free(graph.nodes);
}

pub fn hikePath(input: []const []const u8, start: Pos, dir: Direction, slippery: bool) ?HikeResult {
    const rows = input.len;
    const cols = input[0].len;

    const next = move(start, dir, rows, cols);

    if (next == null) return null;
    if (!checkAllowedMove(input[next.?.y][next.?.x], dir, slippery)) return null;

    var prev_pos: Pos = start;
    var curr_pos: Pos = next.?;
    var dist: u16 = 1;

    while (true) {
        var buffer: [4]Pos = undefined;
        const allowed_moves = getAllowedMoves(&buffer, input, curr_pos, slippery);
        if (curr_pos.y == rows - 1) {
            // reached end node
            break;
        } else if (allowed_moves.len == 0 or (allowed_moves.len == 1 and std.meta.eql(allowed_moves[0], prev_pos))) {
            // dead end
            return null;
        } else if (allowed_moves.len == 1 or (allowed_moves.len == 2 and std.meta.eql(allowed_moves[1], prev_pos))) {
            prev_pos = curr_pos;
            curr_pos = allowed_moves[0];
            dist += 1;
        } else if (allowed_moves.len == 2 and std.meta.eql(allowed_moves[0], prev_pos)) {
            prev_pos = curr_pos;
            curr_pos = allowed_moves[1];
            dist += 1;
        } else if (allowed_moves.len >= 2) {
            // reached node
            break;
        }
    }

    if (std.meta.eql(curr_pos, start)) return null;

    return HikeResult{ .to = curr_pos, .dist = dist };
}

fn move(from: Pos, direction: Direction, rows: usize, cols: usize) ?Pos {
    switch (direction) {
        .n => {
            if (from.y == 0) return null;
            return Pos{ .x = from.x, .y = from.y - 1 };
        },
        .s => {
            if (from.y == rows - 1) return null;
            return Pos{ .x = from.x, .y = from.y + 1 };
        },
        .w => {
            if (from.x == 0) return null;
            return Pos{ .x = from.x - 1, .y = from.y };
        },
        .e => {
            if (from.x == cols - 1) return null;
            return Pos{ .x = from.x + 1, .y = from.y };
        },
    }
}

fn getAllowedMoves(buffer: *[4]Pos, input: []const []const u8, from: Pos, slippery: bool) []Pos {
    const rows = input.len;
    const cols = input[0].len;
    var i: usize = 0;

    for (directions) |dir| {
        if (move(from, dir, rows, cols)) |next_move| {
            const c = input[next_move.y][next_move.x];
            if (!checkAllowedMove(c, dir, slippery)) continue;
            buffer[i] = next_move;
            i += 1;
        }
    }

    return buffer[0..i];
}

fn checkAllowedMove(char: u8, dir: Direction, slippery: bool) bool {
    return switch (char) {
        '.' => true,
        '#' => false,
        '^' => (dir == .n) or !slippery,
        'v' => (dir == .s) or !slippery,
        '<' => (dir == .w) or !slippery,
        '>' => (dir == .e) or !slippery,
        else => unreachable,
    };
}

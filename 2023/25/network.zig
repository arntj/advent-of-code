const std = @import("std");

const NodesLookup = std.StringArrayHashMap([][]const u8);
const NodeGroup = std.StringArrayHashMap(void);

pub fn groupNodes(allocator: std.mem.Allocator, input: []const u8) !usize {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // A lookup to find which other nodes each node connects to.
    var nodes_lookup = NodesLookup.init(alloc);
    try populateNodesLookup(alloc, input, &nodes_lookup);

    // Split nodes in two groups.
    var groups: [2]*NodeGroup = undefined;

    for (0..2) |i| {
        groups[i] = try alloc.create(NodeGroup);
        groups[i].* = NodeGroup.init(alloc);
    }

    // Fill the groups.
    try fillGroups(allocator, &nodes_lookup, &groups);

    // Find and move nodes that have been put in the wrong group.
    try sortGroups(&nodes_lookup, &groups);

    return groups[0].count() * groups[1].count();
}

fn fillGroups(allocator: std.mem.Allocator, nodes_lookup: *NodesLookup, groups: *[2]*NodeGroup) !void {
    // Use an arbitrary node as starting node.
    const start_node = nodes_lookup.keys()[0];

    // Find another node that is the highest possible number of steps away from starting node.
    const furthest_node = try findFurthestNode(allocator, nodes_lookup, start_node);

    // Put these two group in each node.
    try groups[0].put(start_node, {});
    try groups[1].put(furthest_node, {});

    // Create list of remaining nodes.
    var remaining = std.ArrayList([]const u8).init(allocator);
    defer remaining.deinit();

    for (nodes_lookup.keys()) |node| {
        if (!(std.mem.eql(u8, node, start_node) or std.mem.eql(u8, node, furthest_node))) {
            try remaining.append(node);
        }
    }

    while (remaining.items.len > 0) {
        // Iterate backwards over remaining nodes (as we may be removing nodes as we go).
        const len = remaining.items.len;
        for (0..len) |i_inv| {
            const i = len - 1 - i_inv;
            const node = remaining.items[i];
            const connect_to = nodes_lookup.get(node).?;

            // Count how many nodes in each group this node connect to.
            var group_len = [2]u16{ 0, 0 };

            for (connect_to) |c_node| {
                for (0..2) |group_search_i| {
                    if (groups[group_search_i].contains(c_node)) {
                        group_len[group_search_i] += 1;
                        break;
                    }
                }
            }

            // See if we can find a group that this node is clearly "more" connected to.
            if (group_len[0] == group_len[1]) continue;

            const max_group_len: usize = if (group_len[0] > group_len[1]) 0 else 1;

            // If yes and it is another group than this node is currently in, move node.
            try groups[max_group_len].put(node, {});
            _ = remaining.swapRemove(i);
        }
    }
}

// This function is to help ensure that each node is actually in the correct group.
fn sortGroups(nodes_lookup: *NodesLookup, groups: *[2]*NodeGroup) !void {
    var changed: bool = true;

    // Iterate until groups stabilize at a specific configuration.
    while (changed) {
        changed = false;

        // Find size of largest group.
        const len = @max(groups.*[0].count(), groups.*[1].count());

        // Iterate over all nodes in groups by alternating between each group.
        node_loop: for (0..len) |i| {
            for (0..groups.len) |j| {
                if (groups[j].count() <= i) continue;

                const node = groups[j].keys()[i];

                // Count how many nodes in each group the current node is connected to.
                var group_len = [2]u16{ 0, 0 };

                for (nodes_lookup.get(node).?) |search_node| {
                    for (0..2) |group_search_i| {
                        if (groups[group_search_i].contains(search_node)) {
                            group_len[group_search_i] += 1;
                            break;
                        }
                    }
                }

                // Check if the node is clearly "more" connected to one group than to another.
                if (group_len[0] == group_len[1]) continue;

                // Check if we need to change groups for node.
                const max_group_len: usize = if (group_len[0] > group_len[1]) 0 else 1;
                if (max_group_len == j) continue;

                // If yes, move node to another group.
                _ = groups[j].swapRemove(node);
                try groups[max_group_len].put(node, {});

                // Group configuration is not stabilized yet, start over.
                changed = true;
                break :node_loop;
            }
        }
    }
}

// Build node lookup from input.
fn populateNodesLookup(allocator: std.mem.Allocator, input: []const u8, lookup: *NodesLookup) !void {
    // Create a temporary lookup, using StringArrayHashMap to simplify lookup of connected nodes.
    var temp_lookup = std.StringHashMap(*std.StringArrayHashMap(void)).init(allocator);
    defer temp_lookup.deinit();

    // Split input in lines.
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        // Node to connect from.
        const name_from = line[0..3];

        // Get node from lookup, or add if it doesn't already exist in lookup.
        const result = try temp_lookup.getOrPut(name_from);

        if (!result.found_existing) {
            const new_hash_map = try allocator.create(std.StringArrayHashMap(void));
            new_hash_map.* = std.StringArrayHashMap(void).init(allocator);
            result.value_ptr.* = new_hash_map;
        }

        // Iterate over connected nodes.
        var nodes_iter = std.mem.tokenizeScalar(u8, line[5..line.len], ' ');

        while (nodes_iter.next()) |name_to| {
            // Add to lookup for connection from name_from to name_to.
            var connect_to = temp_lookup.get(name_from).?;
            try connect_to.put(name_to, {});

            // Also add for the other direction.
            // If node isn't already in lookup, add to lookup.
            const get_or_put_result = try temp_lookup.getOrPut(name_to);

            if (!get_or_put_result.found_existing) {
                const new_hash = try allocator.create(std.StringArrayHashMap(void));
                new_hash.* = std.StringArrayHashMap(void).init(allocator);
                get_or_put_result.value_ptr.* = new_hash;
            }
            const connect_from = get_or_put_result.value_ptr.*;
            if (!connect_from.contains(name_from)) {
                try connect_from.put(name_from, {});
            }
        }
    }

    // Add final result to lookup, and cleanup memory.
    var iter = temp_lookup.iterator();

    while (iter.next()) |element| {
        const connect_to = element.value_ptr;
        const keys = try allocator.dupe([]const u8, connect_to.*.keys());
        try lookup.put(element.key_ptr.*, keys);
        connect_to.*.deinit();
        allocator.destroy(connect_to.*);
    }
}

const NodeSearch = struct {
    node: []const u8,
    dist: u16,
};

// Find a node with the furthest possible distance from given node.
pub fn findFurthestNode(allocator: std.mem.Allocator, lookup: *NodesLookup, start_node: []const u8) ![]const u8 {
    // Create lookup for node distances, and seed with starting node.
    var node_distances = std.StringHashMap(u16).init(allocator);
    defer node_distances.deinit();
    try node_distances.put(start_node, 0);

    // Create list for depth-first search and seed with starting node.
    var nodes_to_check = std.ArrayList(NodeSearch).init(allocator);
    defer nodes_to_check.deinit();
    try nodes_to_check.append(NodeSearch{ .node = start_node, .dist = 0 });

    // Depth-first search
    while (nodes_to_check.popOrNull()) |node| {
        const node_connect_to = lookup.get(node.node).?;
        const next_dist = node.dist + 1;

        // Iterate over connected nodes from given node.
        for (node_connect_to) |next| {
            const get_dist_res = try node_distances.getOrPut(next);

            // If a shorter distance was found to a given node, save the new distance and continue search from that node.
            if (!get_dist_res.found_existing or get_dist_res.value_ptr.* > next_dist) {
                get_dist_res.value_ptr.* = next_dist;
                try nodes_to_check.append(NodeSearch{ .node = next, .dist = next_dist });
            }
        }
    }

    // Find maximum distance, and a node with this distance.
    var max_dist: u16 = 0;
    var max_node: []const u8 = undefined;

    var iter = node_distances.iterator();
    while (iter.next()) |el| {
        if (el.value_ptr.* > max_dist) {
            max_dist = el.value_ptr.*;
            max_node = el.key_ptr.*;
        }
    }

    return max_node;
}

const std = @import("std");

const Pulse = enum {
    high,
    low,
};

const MachineType = enum {
    flip_flop,
    conjunction,
    broadcaster,
};

const MachineState = union(MachineType) {
    flip_flop: bool,
    conjunction: std.StringHashMap(Pulse),
    broadcaster: void,
};

const Machine = struct {
    name: []const u8,
    type: MachineType,
    outputs: [][]const u8,
};

const PulseState = struct {
    type: Pulse,
    from: []const u8,
    to: []const u8,
};

test "Parses network correctly" {
    const allocator = std.testing.allocator;

    const input =
        \\broadcaster -> ab, cd
        \\%ab -> cd
        \\&cd -> output
        \\
    ;

    var net = try Network.parse(allocator, input);
    defer net.deinit();

    try std.testing.expectEqualStrings("broadcaster", net.machines[0].name);
    try std.testing.expectEqualStrings("cd", net.machines[0].outputs[1]);
    try std.testing.expectEqualStrings("ab", net.machines[1].name);
    try std.testing.expectEqualStrings("cd", net.machines[1].outputs[0]);
    try std.testing.expectEqualStrings("output", net.machines[2].outputs[0]);
}

pub const Network = struct {
    machines: []Machine,

    allocator: std.mem.Allocator,

    pub fn sendPulses(self: *Network) ![2]u64 {
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        var machines = std.StringHashMap(Machine).init(alloc);
        var machine_states = std.StringHashMap(MachineState).init(alloc);

        var rx_parent: []const u8 = undefined;

        for (self.machines) |machine| {
            try machines.put(machine.name, machine);
            switch (machine.type) {
                .flip_flop => {
                    try machine_states.put(machine.name, MachineState{ .flip_flop = false });
                },
                .conjunction => {
                    var conj_states = std.StringHashMap(Pulse).init(alloc);

                    for (self.machines) |m| {
                        for (m.outputs) |out| {
                            if (std.mem.eql(u8, out, machine.name)) {
                                try conj_states.put(m.name, .low);
                            }
                        }
                    }
                    try machine_states.put(machine.name, MachineState{ .conjunction = conj_states });
                },
                .broadcaster => {
                    try machine_states.put(machine.name, MachineState{ .broadcaster = {} });
                },
            }

            for (machine.outputs) |out| {
                if (std.mem.eql(u8, "rx", out)) {
                    rx_parent = machine.name;
                }
            }
        }

        var rx_cycles = std.StringHashMap(u64).init(alloc);
        var rx_cycles_count: u32 = 0;

        for (self.machines) |m| {
            for (m.outputs) |o| {
                if (std.mem.eql(u8, o, rx_parent)) {
                    rx_cycles_count += 1;
                    break;
                }
            }
        }

        var high: u64 = 0;
        var low: u64 = 0;

        var pulses = std.fifo.LinearFifo(PulseState, .Dynamic).init(alloc);
        var part_1_answer: u64 = undefined;

        for (0..10_000) |i| {
            if (i == 1000) {
                part_1_answer = high * low;
            }

            const has_all_answers: bool = i > 1000 and rx_cycles.count() == rx_cycles_count;

            if (has_all_answers) break;

            try pulses.writeItem(PulseState{
                .type = .low,
                .from = "button",
                .to = "broadcaster",
            });
            low += 1;

            while (pulses.readItem()) |pulse| {
                const next_machine = machines.get(pulse.to);
                if (next_machine == null) continue;

                const machine = next_machine.?;
                var machine_state = machine_states.getPtr(pulse.to).?;

                var out_pulse: ?Pulse = null;
                switch (machine_state.*) {
                    .broadcaster => {
                        out_pulse = pulse.type;
                    },
                    .flip_flop => |flip_flop| {
                        switch (pulse.type) {
                            .low => {
                                machine_state.flip_flop = !flip_flop;
                                out_pulse = if (machine_state.flip_flop) .high else .low;
                            },
                            .high => {},
                        }
                    },
                    .conjunction => |*conj| {
                        if (std.mem.eql(u8, pulse.to, rx_parent) and pulse.type == .high and !rx_cycles.contains(pulse.from)) {
                            try rx_cycles.put(pulse.from, i + 1);
                        }
                        try conj.put(pulse.from, pulse.type);
                        out_pulse = .low;
                        var vals = conj.valueIterator();

                        while (vals.next()) |v| {
                            if (v.* == .low) {
                                out_pulse = .high;
                                break;
                            }
                        }
                    },
                }
                if (out_pulse) |curr_pulse| {
                    for (machine.outputs) |out| {
                        try pulses.writeItem(PulseState{
                            .type = curr_pulse,
                            .from = pulse.to,
                            .to = try alloc.dupe(u8, out),
                        });
                        switch (curr_pulse) {
                            .high => high += 1,
                            .low => low += 1,
                        }
                    }
                }
            }
        }

        var rx_cycles_iter = rx_cycles.valueIterator();
        var part_2_answer: u64 = rx_cycles_iter.next().?.*;

        while (rx_cycles_iter.next()) |c| {
            const orig = part_2_answer;
            while (part_2_answer % c.* != 0) {
                part_2_answer += orig;
            }
        }

        return [2]usize{ part_1_answer, part_2_answer };
    }

    pub fn parse(allocator: std.mem.Allocator, input: []const u8) !Network {
        var machines = std.ArrayList(Machine).init(allocator);

        var lines = std.mem.tokenizeScalar(u8, input, '\n');

        while (lines.next()) |line| {
            var split = std.mem.tokenizeSequence(u8, line, " -> ");
            const name = split.next().?;
            var outputs_list = std.ArrayList([]const u8).init(allocator);
            var outputs_iter = std.mem.tokenizeSequence(u8, split.rest(), ", ");

            while (outputs_iter.next()) |out| {
                try outputs_list.append(try allocator.dupe(u8, out));
            }

            const outputs = try outputs_list.toOwnedSlice();

            var machine_name = name;
            var machine_type: MachineType = undefined;
            if (std.mem.eql(u8, "broadcaster", name)) {
                machine_type = .broadcaster;
            } else if (name[0] == '%') {
                machine_name = name[1..name.len];
                machine_type = .flip_flop;
            } else if (name[0] == '&') {
                machine_name = name[1..name.len];
                machine_type = .conjunction;
            } else {
                unreachable;
            }
            try machines.append(Machine{
                .name = try allocator.dupe(u8, machine_name),
                .type = machine_type,
                .outputs = outputs,
            });
        }

        return Network{
            .machines = try machines.toOwnedSlice(),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Network) void {
        for (self.machines) |machine| {
            self.allocator.free(machine.name);

            for (machine.outputs) |out| {
                self.allocator.free(out);
            }
            self.allocator.free(machine.outputs);
        }
        self.allocator.free(self.machines);
    }
};

const std = @import("std");

const PartRating = enum {
    x,
    m,
    a,
    s,

    pub fn fromChar(c: u8) PartRating {
        return switch (c) {
            'x' => .x,
            'm' => .m,
            'a' => .a,
            's' => .s,
            else => unreachable,
        };
    }
};

const Operator = enum {
    gt,
    lt,

    pub fn fromChar(c: u8) Operator {
        return switch (c) {
            '>' => .gt,
            '<' => .lt,
            else => unreachable,
        };
    }
};

const NextStep = union(enum) {
    send_to: []const u8,
    accept: void,
    reject: void,

    pub fn parse(input: []const u8) NextStep {
        if (input.len == 1) {
            switch (input[0]) {
                'A' => return NextStep{ .accept = {} },
                'R' => return NextStep{ .reject = {} },
                else => unreachable,
            }
        } else {
            return NextStep{ .send_to = input };
        }
    }
};

const Condition = struct {
    rating: PartRating,
    operator: Operator,
    value: u32,
    next_step: NextStep,
};

const WorkflowStep = union(enum) {
    condition: Condition,
    send_to: []const u8,
    accept: void,
    reject: void,

    pub fn parse(input: []const u8) !WorkflowStep {
        if (input.len == 1) {
            switch (input[0]) {
                'A' => return WorkflowStep{ .accept = {} },
                'R' => return WorkflowStep{ .reject = {} },
                else => unreachable,
            }
        } else if (input.len < 4) {
            return WorkflowStep{ .send_to = input };
        } else {
            const separator = std.mem.indexOf(u8, input, ":").?;

            const condition = Condition{
                .rating = PartRating.fromChar(input[0]),
                .operator = Operator.fromChar(input[1]),
                .value = try std.fmt.parseInt(u32, input[2..separator], 10),
                .next_step = NextStep.parse(input[separator + 1 .. input.len]),
            };

            return WorkflowStep{ .condition = condition };
        }
    }
};

const Workflow = struct {
    name: []const u8,
    steps: []WorkflowStep,
};

const Part = struct {
    ratings: [4]u32 = undefined,

    pub fn setRating(self: *Part, rating_type: PartRating, value: u32) void {
        self.ratings[@intFromEnum(rating_type)] = value;
    }

    pub fn getRating(self: Part, rating_type: PartRating) u32 {
        return self.ratings[@intFromEnum(rating_type)];
    }
};

const Range = struct {
    from: u32,
    to: u32,
};

const RangeSet = struct {
    ranges: [4]Range,
    workflow: []const u8,

    pub fn getRange(self: RangeSet, rating: PartRating) Range {
        return self.ranges[@intFromEnum(rating)];
    }

    pub fn nextRange(self: RangeSet, rating: PartRating, from: u32, to: u32) RangeSet {
        var next = self;
        next.ranges[@intFromEnum(rating)] = Range{
            .from = from,
            .to = to,
        };

        return next;
    }

    pub fn distinctCombinations(self: RangeSet) u64 {
        var product: u64 = 1;

        for (self.ranges) |r| {
            product *= r.to - r.from + 1;
        }

        return product;
    }
};

test "Parses correctly" {
    const allocator = std.testing.allocator;
    const input =
        \\px{a<2006:qkq,m>2090:A,R}
        \\in{s<1351:px,qqz}
        \\
        \\{x=1,m=2,a=3,s=4}
        \\{x=5,m=6,a=7,s=8}
        \\
    ;

    var parts_sorter = try PartsSorter.parse(allocator, input);
    defer parts_sorter.deinit();

    try std.testing.expectEqual(PartRating.a, parts_sorter.workflows[0].steps[0].condition.rating);
    try std.testing.expectEqual(WorkflowStep{ .reject = {} }, parts_sorter.workflows[0].steps[2]);
    try std.testing.expectEqualStrings("qqz", parts_sorter.workflows[1].steps[1].send_to);

    try std.testing.expectEqual(@as(u32, 1), parts_sorter.parts[0].getRating(.x));
    try std.testing.expectEqual(@as(u32, 7), parts_sorter.parts[1].getRating(.a));
}

pub const PartsSorter = struct {
    workflows: []Workflow,
    parts: []Part,

    allocator: std.mem.Allocator,

    pub fn findRanges(self: *PartsSorter, allocator: std.mem.Allocator) !u64 {
        var hash_workflows = std.StringHashMap(Workflow).init(self.allocator);
        defer hash_workflows.deinit();

        for (self.workflows) |workflow| {
            try hash_workflows.put(workflow.name, workflow);
        }

        const initial = RangeSet{
            .ranges = [4]Range{
                Range{ .from = 1, .to = 4000 },
                Range{ .from = 1, .to = 4000 },
                Range{ .from = 1, .to = 4000 },
                Range{ .from = 1, .to = 4000 },
            },
            .workflow = "in",
        };

        var range_sets = std.ArrayList(RangeSet).init(allocator);
        defer range_sets.deinit();

        var result: u64 = 0;

        try range_sets.append(initial);

        while (range_sets.popOrNull()) |range_set| {
            const workflow = hash_workflows.get(range_set.workflow).?;
            var curr_range_set = range_set;

            for (workflow.steps) |step| {
                switch (step) {
                    .condition => |cond| {
                        const range = curr_range_set.getRange(cond.rating);
                        var inside: ?RangeSet = null;
                        var outside: ?RangeSet = null;

                        switch (cond.operator) {
                            .gt => {
                                if (range.from > cond.value) {
                                    inside = curr_range_set;
                                } else if (range.to > cond.value) {
                                    inside = curr_range_set.nextRange(cond.rating, cond.value + 1, range.to);
                                    outside = curr_range_set.nextRange(cond.rating, range.from, cond.value);
                                } else {
                                    outside = curr_range_set;
                                }
                            },
                            .lt => {
                                if (range.to < cond.value) {
                                    inside = curr_range_set;
                                } else if (range.from < cond.value) {
                                    inside = curr_range_set.nextRange(cond.rating, range.from, cond.value - 1);
                                    outside = curr_range_set.nextRange(cond.rating, cond.value, range.to);
                                } else {
                                    outside = curr_range_set;
                                }
                            },
                        }

                        if (inside) |in| {
                            switch (cond.next_step) {
                                .send_to => |send_to| {
                                    var to_send = in;
                                    to_send.workflow = send_to;
                                    try range_sets.append(to_send);
                                },
                                .accept => {
                                    result += in.distinctCombinations();
                                },
                                .reject => {},
                            }
                        }

                        if (outside) |out| {
                            curr_range_set = out;
                        } else {
                            break;
                        }
                    },
                    .send_to => |send_to| {
                        curr_range_set.workflow = send_to;
                        try range_sets.append(curr_range_set);
                    },
                    .accept => {
                        result += curr_range_set.distinctCombinations();
                    },
                    .reject => {},
                }
            }
        }

        return result;
    }

    pub fn sortParts(self: *PartsSorter) !u32 {
        var hash_workflows = std.StringHashMap(Workflow).init(self.allocator);
        defer hash_workflows.deinit();

        for (self.workflows) |workflow| {
            try hash_workflows.put(workflow.name, workflow);
        }

        var result: u32 = 0;

        for (self.parts) |part| {
            var curr_workflow = hash_workflows.get("in").?;
            var passed: ?bool = null;

            while (passed == null) {
                for (curr_workflow.steps) |step| {
                    switch (step) {
                        .condition => |cond| {
                            const rating = part.getRating(cond.rating);

                            var next: bool = false;

                            switch (cond.operator) {
                                .lt => {
                                    if (rating < cond.value) next = true;
                                },
                                .gt => {
                                    if (rating > cond.value) next = true;
                                },
                            }

                            if (next) {
                                switch (cond.next_step) {
                                    .accept => {
                                        passed = true;
                                        break;
                                    },
                                    .reject => {
                                        passed = false;
                                        break;
                                    },
                                    .send_to => |send_to| {
                                        curr_workflow = hash_workflows.get(send_to).?;
                                        break;
                                    },
                                }
                            }
                        },
                        .accept => {
                            passed = true;
                            break;
                        },
                        .reject => {
                            passed = false;
                            break;
                        },
                        .send_to => |send_to| {
                            curr_workflow = hash_workflows.get(send_to).?;
                            break;
                        },
                    }
                }
            }

            if (passed == true) {
                result += part.getRating(.x) + part.getRating(.m) + part.getRating(.a) + part.getRating(.s);
            }
        }

        return result;
    }

    pub fn parse(allocator: std.mem.Allocator, input: []const u8) !PartsSorter {
        var workflows = std.ArrayList(Workflow).init(allocator);

        var lines = std.mem.splitScalar(u8, input, '\n');

        while (lines.next()) |line| {
            if (line.len == 0) break;

            const bracket_pos = std.mem.indexOf(u8, line, "{").?;
            const name = line[0..bracket_pos];

            const steps_str = line[bracket_pos + 1 .. line.len - 1];
            var steps_iter = std.mem.tokenizeScalar(u8, steps_str, ',');
            var steps = std.ArrayList(WorkflowStep).init(allocator);

            while (steps_iter.next()) |step_str| {
                try steps.append(try WorkflowStep.parse(step_str));
            }

            try workflows.append(Workflow{
                .name = name,
                .steps = try steps.toOwnedSlice(),
            });
        }

        var parts = std.ArrayList(Part).init(allocator);

        while (lines.next()) |line| {
            if (line.len == 0) break;

            const line_parts = line[1 .. line.len - 1];
            var parts_iter = std.mem.tokenizeScalar(u8, line_parts, ',');
            var part = Part{};

            while (parts_iter.next()) |part_str| {
                part.setRating(
                    PartRating.fromChar(part_str[0]),
                    try std.fmt.parseInt(u32, part_str[2..part_str.len], 10),
                );
            }

            try parts.append(part);
        }

        return PartsSorter{
            .workflows = try workflows.toOwnedSlice(),
            .parts = try parts.toOwnedSlice(),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *PartsSorter) void {
        for (self.workflows) |workflow| {
            self.allocator.free(workflow.steps);
        }

        self.allocator.free(self.workflows);
        self.allocator.free(self.parts);
    }
};

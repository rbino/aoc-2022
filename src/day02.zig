const std = @import("std");
const data = @embedFile("data/day02.txt");
const assert = std.debug.assert;
const print = std.debug.print;
const tokenize = std.mem.tokenize;

pub const Shape = enum(u8) {
    rock = 1,
    paper = 2,
    scissors = 3,

    pub fn parse(in: u8) Shape {
        return switch (in) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => unreachable,
        };
    }

    pub fn points(self: Shape) usize {
        return @enumToInt(self);
    }

    pub fn outcome(self: Shape, other: Shape) Outcome {
        if (self == other) return .draw;
        return if (self.beats() == other) .victory else .loss;
    }

    pub fn beats(self: Shape) Shape {
        return switch (self) {
            .rock => .scissors,
            .paper => .rock,
            .scissors => .paper,
        };
    }

    pub fn beatenBy(self: Shape) Shape {
        switch (self) {
            inline else => |shape| {
                const winner = comptime blk: {
                    inline for (@typeInfo(Shape).Enum.fields) |field| {
                        const other_shape = @intToEnum(Shape, field.value);
                        if (other_shape.beats() == shape) {
                            break :blk other_shape;
                        }
                    }
                    unreachable;
                };
                return winner;
            },
        }
    }
};

pub const Outcome = enum(u8) {
    loss = 0,
    draw = 3,
    victory = 6,

    pub fn parse(in: u8) Outcome {
        return switch (in) {
            'X' => .loss,
            'Y' => .draw,
            'Z' => .victory,
            else => unreachable,
        };
    }

    pub fn points(self: Outcome) usize {
        return @enumToInt(self);
    }

    pub fn requiredShape(self: Outcome, other_player_shape: Shape) Shape {
        switch (self) {
            .loss => return other_player_shape.beats(),
            .draw => return other_player_shape,
            .victory => return other_player_shape.beatenBy(),
        }
    }
};

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
}

fn solvePart1(input: []const u8) !usize {
    var total_score: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        assert(line.len == 3);
        const elf_shape = Shape.parse(line[0]);
        const player_shape = Shape.parse(line[2]);
        const outcome = player_shape.outcome(elf_shape);
        total_score += outcome.points() + player_shape.points();
    }

    return total_score;
}

fn solvePart2(input: []const u8) !usize {
    var total_score: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        assert(line.len == 3);
        const elf_shape = Shape.parse(line[0]);
        const outcome = Outcome.parse(line[2]);
        const player_shape = outcome.requiredShape(elf_shape);
        total_score += outcome.points() + player_shape.points();
    }

    return total_score;
}

test "example input" {
    const input =
        \\A Y
        \\B X
        \\C Z
    ;

    const part1_result = try solvePart1(input);
    assert(part1_result == 15);

    const part2_result = try solvePart2(input);
    assert(part2_result == 12);
}

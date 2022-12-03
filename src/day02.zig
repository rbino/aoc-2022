const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Order = std.math.Order;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub const Shape = enum(u8) {
    rock = 1,
    paper = 2,
    scissors = 3,

    const loss_points: usize = 0;
    const draw_points: usize = 3;
    const victory_points: usize = 6;

    pub fn parse(in: u8) Shape {
        return switch (in) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => unreachable,
        };
    }

    pub fn shapePoints(self: Shape) usize {
        return @enumToInt(self);
    }

    pub fn outcomePoints(self: Shape, other: Shape) usize {
        if (self == other) return draw_points;

        return switch (self) {
            .rock => if (other == .scissors) victory_points else loss_points,
            .paper => if (other == .rock) victory_points else loss_points,
            .scissors => if (other == .paper) victory_points else loss_points,
        };
    }
};

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

fn solvePart1(input: []const u8) !usize {
    var total_score: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        assert(line.len == 3);
        const elf_shape = Shape.parse(line[0]);
        const player_shape = Shape.parse(line[2]);
        total_score += player_shape.outcomePoints(elf_shape) + player_shape.shapePoints();
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
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

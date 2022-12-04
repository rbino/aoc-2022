const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

fn solvePart1(input: []const u8) !usize {
    var fully_contained: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const comma_idx = indexOf(u8, line, ',').?;
        const first_range = try Range.parse(line[0..comma_idx]);
        const second_range = try Range.parse(line[comma_idx + 1 ..]);
        if (first_range.fullyContains(second_range) or second_range.fullyContains(first_range)) {
            fully_contained += 1;
        }
    }
    return fully_contained;
}

pub const Range = struct {
    start: usize,
    end: usize,

    pub fn parse(section: []const u8) !Range {
        const dash_idx = indexOf(u8, section, '-').?;
        return Range{
            .start = try parseInt(usize, section[0..dash_idx], 10),
            .end = try parseInt(usize, section[dash_idx + 1 ..], 10),
        };
    }

    pub fn fullyContains(self: Range, other: Range) bool {
        return (other.start >= self.start and other.end <= self.end);
    }
};

test "example input" {
    const input =
        \\2-4,6-8
        \\2-3,4-5
        \\5-7,7-9
        \\2-8,3-7
        \\6-6,4-6
        \\2-6,4-8
    ;

    assert(try solvePart1(input) == 2);
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

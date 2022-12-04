const std = @import("std");
const data = @embedFile("data/day04.txt");
const tokenize = std.mem.tokenize;
const indexOf = std.mem.indexOfScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const assert = std.debug.assert;

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
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

fn solvePart2(input: []const u8) !usize {
    var overlapping: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const comma_idx = indexOf(u8, line, ',').?;
        const first_range = try Range.parse(line[0..comma_idx]);
        const second_range = try Range.parse(line[comma_idx + 1 ..]);
        if (first_range.overlaps(second_range)) {
            overlapping += 1;
        }
    }
    return overlapping;
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

    pub fn overlaps(self: Range, other: Range) bool {
        return (other.start <= self.end and other.end >= self.start);
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
    assert(try solvePart2(input) == 4);
}

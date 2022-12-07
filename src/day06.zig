const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    const part1_result = solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

fn solvePart1(input: []const u8) usize {
    var detector = MarkerDetector{};
    for (trimRight(u8, input, "\n")) |c| {
        if (detector.feedAndDetect(c)) {
            return detector.pos;
        }
    }
    unreachable;
}

pub const MarkerDetector = struct {
    const marker_length = 4;
    const Self = @This();

    buffer: [marker_length]u8 = undefined,
    pos: usize = 0,
    start: u2 = 0,
    end: u2 = 0,

    pub fn feedAndDetect(self: *Self, char: u8) bool {
        var i: u2 = self.start;
        while (i != self.end) : (i +%= 1) {
            if (self.buffer[i] == char) {
                self.start = i +% 1;
            }
        }
        self.buffer[self.end] = char;
        self.end +%= 1;
        self.pos += 1;
        return self.start == self.end;
    }
};

test "example input" {
    assert(solvePart1("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7);
    assert(solvePart1("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5);
    assert(solvePart1("nppdvjthqldpwncqszvftbrmjlhg") == 6);
    assert(solvePart1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10);
    assert(solvePart1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11);
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
const trimRight = std.mem.trimRight;
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

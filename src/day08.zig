const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");

pub fn main() !void {
    const part1_result = solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

fn solvePart1(input: []const u8) usize {
    const columns = indexOf(u8, input, '\n').?;
    const columns_including_newline = columns + 1;
    const rows = @divExact(input.len, columns_including_newline);
    var total_visible_trees: usize = 0;
    for (input) |c, idx| {
        if (c == '\n') continue;

        const x = idx % columns_including_newline;
        const y = @divFloor(idx, columns_including_newline);

        const is_visible = blk: {
            if (x == 0 or
                x == columns - 1 or
                y == 0 or
                y == rows - 1) break :blk true;

            // Check if visible from left
            var i: usize = y * columns_including_newline;
            while (i < idx) : (i += 1) {
                if (input[i] >= c) break;
            } else break :blk true;

            // Check if visible from top
            i = x;
            while (i < idx) : (i += columns_including_newline) {
                if (input[i] >= c) break;
            } else break :blk true;

            // Check if visible from right
            i = ((y + 1) * columns_including_newline) - 2;
            while (i > idx) : (i -= 1) {
                if (input[i] >= c) break;
            } else break :blk true;

            // Check if visible from bottom
            i = input.len - columns_including_newline + x;
            while (i > idx) : (i -= columns_including_newline) {
                if (input[i] >= c) break;
            } else break :blk true;

            break :blk false;
        };

        if (is_visible) total_visible_trees += 1;
    }

    return total_visible_trees;
}

const expectEqual = std.testing.expectEqual;

test "example input" {
    const input =
        \\30373
        \\25512
        \\65332
        \\33549
        \\35390
        \\
    ;

    try expectEqual(solvePart1(input), 21);
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const splitBackwards = std.mem.splitBackwards;
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

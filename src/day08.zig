const std = @import("std");
const split = std.mem.split;
const splitBackwards = std.mem.splitBackwards;
const indexOf = std.mem.indexOfScalar;
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("data/day08.txt");

pub fn main() !void {
    const part1_result = solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
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

fn solvePart2(input: []const u8) usize {
    const columns = indexOf(u8, input, '\n').?;
    const columns_including_newline = columns + 1;
    var best_scenic_score: usize = 0;
    for (input) |c, idx| {
        if (c == '\n') continue;

        const x = idx % columns_including_newline;
        const y = @divFloor(idx, columns_including_newline);

        var i: usize = undefined;
        var left_scenic_score: usize = 0;
        if (x > 0) {
            // Check visibility to the left
            i = idx;
            while (true) {
                i -= 1;
                left_scenic_score += 1;
                if (input[i] >= c or i <= y * columns_including_newline) break;
            }
        }

        var top_scenic_score: usize = 0;
        if (y > 0) {
            // Check visibility towards the top
            i = idx;
            while (true) {
                i -= columns_including_newline;
                top_scenic_score += 1;
                if (input[i] >= c or i <= x) break;
            }
        }

        // Check visibility to the right
        var right_scenic_score: usize = 0;
        i = idx + 1;
        while (i <= ((y + 1) * columns_including_newline) - 2) : (i += 1) {
            right_scenic_score += 1;
            if (input[i] >= c) break;
        }

        // Check visibility towards the bottom
        var bottom_scenic_score: usize = 0;
        i = idx + columns_including_newline;
        while (i <= input.len - columns_including_newline + x) : (i += columns_including_newline) {
            bottom_scenic_score += 1;
            if (input[i] >= c) break;
        }

        const scenic_score = left_scenic_score * top_scenic_score *
            right_scenic_score * bottom_scenic_score;

        if (scenic_score > best_scenic_score) best_scenic_score = scenic_score;
    }

    return best_scenic_score;
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
    try expectEqual(solvePart2(input), 8);
}

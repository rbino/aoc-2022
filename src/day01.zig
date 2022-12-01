const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const swap = std.mem.swap;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
}

fn solvePart1(input: []const u8) !usize {
    var max_calories: usize = 0;
    var elf_iterator = split(u8, input, "\n\n");
    while (elf_iterator.next()) |elf| {
        var elf_calories: usize = 0;
        var food_iterator = tokenize(u8, elf, "\n");
        while (food_iterator.next()) |food| {
            const calories = try parseInt(usize, food, 10);
            elf_calories += calories;
        }
        if (elf_calories > max_calories) {
            max_calories = elf_calories;
        }
    }
    return max_calories;
}

fn solvePart2(input: []const u8) !usize {
    // The top 3 calories transporters, in descending order of calories
    var top_3_calories_desc: [3]usize = .{0} ** 3;
    var elf_iterator = split(u8, input, "\n\n");
    while (elf_iterator.next()) |elf| {
        var elf_calories: usize = 0;
        var food_iterator = tokenize(u8, elf, "\n");
        while (food_iterator.next()) |food| {
            const calories = try parseInt(usize, food, 10);
            elf_calories += calories;
        }
        var i: u8 = 0;
        while (i < top_3_calories_desc.len) : (i += 1) {
            if (elf_calories > top_3_calories_desc[i]) {
                var j: u8 = top_3_calories_desc.len - 1;
                while (j > i) : (j -= 1) {
                    swap(usize, &top_3_calories_desc[j], &top_3_calories_desc[j - 1]);
                }
                top_3_calories_desc[i] = elf_calories;
                break;
            }
        }
    }

    var sum: usize = 0;
    for (top_3_calories_desc) |calories| {
        sum += calories;
    }
    return sum;
}

test "example input" {
    const input =
        \\1000
        \\2000
        \\3000
        \\
        \\4000
        \\
        \\5000
        \\6000
        \\
        \\7000
        \\8000
        \\9000
        \\
        \\10000
    ;

    const part1_result = try solvePart1(input);
    assert(part1_result == 24000);

    const part2_result = try solvePart2(input);
    assert(part2_result == 45000);
}


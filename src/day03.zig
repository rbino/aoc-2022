const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

const priority_count = ('z' - 'a' + 1) + ('Z' - 'A' + 1);
const PrioritySet = std.StaticBitSet(priority_count);

fn priority(item: u8) u8 {
    return switch (item) {
        'a'...'z' => item - 'a' + 1,
        'A'...'Z' => item - 'A' + 27,
        else => unreachable,
    };
}

fn solvePart1(input: []const u8) !usize {
    var priority_sum: usize = 0;
    var lines = tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        assert(line.len % 2 == 0);
        const half = line.len / 2;
        var first_compartment = initCompartmentSet(line[0..half]);
        const second_compartment = initCompartmentSet(line[half..]);
        first_compartment.setIntersection(second_compartment);
        const misplaced_item_priority = first_compartment.findFirstSet().? + 1;
        priority_sum += misplaced_item_priority;
    }

    return priority_sum;
}

fn initCompartmentSet(compartment: []const u8) PrioritySet {
    var bitset = PrioritySet.initEmpty();
    for (compartment) |item| {
        const p = priority(item);
        bitset.set(p - 1);
    }
    return bitset;
}


test "priority" {
    assert(priority('p') == 16);
    assert(priority('L') == 38);
    assert(priority('P') == 42);
    assert(priority('v') == 22);
    assert(priority('t') == 20);
    assert(priority('s') == 19);
}

test "example input" {
    const input =
        \\vJrwpWtwJgWrhcsFMMfFFhFp
        \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        \\PmmdzqPrVvPwwTWBwg
        \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        \\ttgJtRGJQctTZtZT
        \\CrZsJsPPZsGzwwsLwLmpwMDw
    ;

    const part1_result = try solvePart1(input);
    assert(part1_result == 157);
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

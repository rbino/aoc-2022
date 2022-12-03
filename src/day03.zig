const std = @import("std");
const tokenize = std.mem.tokenize;
const print = std.debug.print;
const assert = std.debug.assert;
const data = @embedFile("data/day03.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
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
        var first_compartment = initPrioritySet(line[0..half]);
        const second_compartment = initPrioritySet(line[half..]);
        first_compartment.setIntersection(second_compartment);
        const misplaced_item_priority = first_compartment.findFirstSet().? + 1;
        priority_sum += misplaced_item_priority;
    }

    return priority_sum;
}

fn solvePart2(input: []const u8) !usize {
    const group_size = 3;
    var priority_sum: usize = 0;
    var lines = tokenize(u8, input, "\n");
    outer: while (true) {
        var intersection_set: ?PrioritySet = null;
        var i: usize = 0;
        while (i < group_size) : (i += 1) {
            const line = lines.next() orelse break :outer;
            if (intersection_set) |*intersection| {
                const rucksack_set = initPrioritySet(line);
                intersection.setIntersection(rucksack_set);
            } else {
                intersection_set = initPrioritySet(line);
            }
        }
        const common_item_priority = intersection_set.?.findFirstSet().? + 1;
        priority_sum += common_item_priority;
    }

    return priority_sum;
}

fn initPrioritySet(items: []const u8) PrioritySet {
    var bitset = PrioritySet.initEmpty();
    for (items) |item| {
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

    const part2_result = try solvePart2(input);
    assert(part2_result == 70);
}

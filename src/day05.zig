const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;
const ArenaAllocator = std.heap.ArenaAllocator;
const CrateStack = ArrayList(u8);

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    const part1_result = try solvePart1(gpa, data);
    print("Part 1 result: {s}\n", .{part1_result});

    const part2_result = try solvePart2(gpa, data);
    print("Part 2 result: {s}\n", .{part2_result});
}

fn solvePart1(allocator: Allocator, input: []const u8) ![]const u8 {
    const starting_stacks_end = indexOfStr(u8, input, "\n\n").?;
    var backwards_initial_stacks = splitBackwards(u8, input[0..starting_stacks_end], "\n");

    const number_of_stacks = parseNumberOfStacks(backwards_initial_stacks.next().?);

    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();
    var stacks = try arena.alloc(CrateStack, number_of_stacks);
    for (stacks) |*stack| stack.* = CrateStack.init(arena);

    while (backwards_initial_stacks.next()) |line| {
        try pushStacksLine(stacks, line);
    }

    var instructions = tokenize(u8, input[starting_stacks_end + 2 ..], "\n");
    while (instructions.next()) |instr| {
        try moveCrates9000(stacks, instr);
    }

    var result = try allocator.alloc(u8, number_of_stacks);
    for (result) |*top_of_stack, i| {
        const stack_items = stacks[i].items;
        top_of_stack.* = stack_items[stack_items.len - 1];
    }

    return result;
}

fn solvePart2(allocator: Allocator, input: []const u8) ![]const u8 {
    const starting_stacks_end = indexOfStr(u8, input, "\n\n").?;
    var backwards_initial_stacks = splitBackwards(u8, input[0..starting_stacks_end], "\n");

    const number_of_stacks = parseNumberOfStacks(backwards_initial_stacks.next().?);

    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();
    var stacks = try arena.alloc(CrateStack, number_of_stacks);
    for (stacks) |*stack| stack.* = CrateStack.init(arena);

    while (backwards_initial_stacks.next()) |line| {
        try pushStacksLine(stacks, line);
    }

    var instructions = tokenize(u8, input[starting_stacks_end + 2 ..], "\n");
    while (instructions.next()) |instr| {
        try moveCrates9001(stacks, instr);
    }

    var result = try allocator.alloc(u8, number_of_stacks);
    for (result) |*top_of_stack, i| {
        const stack_items = stacks[i].items;
        top_of_stack.* = stack_items[stack_items.len - 1];
    }

    return result;
}

fn parseNumberOfStacks(index_line: []const u8) usize {
    const index_line_trimmed = trimRight(u8, index_line, " ");
    var number_of_stacks: usize = 0;
    var multiplier: usize = 1;
    var i = index_line_trimmed.len - 1;
    while (true) : ({
        i -= 1;
        multiplier *= 10;
    }) {
        const c = index_line_trimmed[i];
        if (c == ' ') break;
        assert(c >= '0' and c <= '9');
        number_of_stacks += (c - '0') * multiplier;
    }

    return number_of_stacks;
}

fn pushStacksLine(stacks: []CrateStack, line: []const u8) !void {
    var crates = tokenize(u8, line, " []");
    while (crates.next()) |crate_slice| {
        assert(crate_slice.len == 1);
        const stack_index = @divFloor(crates.index, 4);
        const crate = crate_slice[0];
        try stacks[stack_index].append(crate);
    }
}

fn moveCrates9000(stacks: []CrateStack, instr: []const u8) !void {
    // Instruction format:
    // move n_crates from src_stack to dst_stack
    var tokens = split(u8, instr, " ");
    assert(std.mem.eql(u8, "move", tokens.next().?));
    const n_crates = try parseInt(usize, tokens.next().?, 10);
    assert(std.mem.eql(u8, "from", tokens.next().?));
    // Adjust for 1-based
    const src_stack = try parseInt(usize, tokens.next().?, 10) - 1;
    assert(std.mem.eql(u8, "to", tokens.next().?));
    // Adjust for 1-based
    const dst_stack = try parseInt(usize, tokens.next().?, 10) - 1;
    assert(tokens.next() == null);

    var i: usize = 0;
    while (i < n_crates) : (i += 1) {
        const crate = stacks[src_stack].pop();
        try stacks[dst_stack].append(crate);
    }
}

fn moveCrates9001(stacks: []CrateStack, instr: []const u8) !void {
    // Instruction format:
    // move n_crates from src_stack to dst_stack
    var tokens = split(u8, instr, " ");
    assert(std.mem.eql(u8, "move", tokens.next().?));
    const n_crates = try parseInt(usize, tokens.next().?, 10);
    assert(std.mem.eql(u8, "from", tokens.next().?));
    // Adjust for 1-based
    const src_stack = try parseInt(usize, tokens.next().?, 10) - 1;
    assert(std.mem.eql(u8, "to", tokens.next().?));
    // Adjust for 1-based
    const dst_stack = try parseInt(usize, tokens.next().?, 10) - 1;
    assert(tokens.next() == null);

    const src_len = stacks[src_stack].items.len;
    const crates_start = src_len - n_crates;
    const crates = stacks[src_stack].items[crates_start..];
    const new_len = src_len - n_crates;
    stacks[src_stack].shrinkRetainingCapacity(new_len);
    try stacks[dst_stack].appendSlice(crates);
}

test "parseNumberOfStacks" {
    assert(parseNumberOfStacks(" 1 2 3 4 5 ") == 5);
    assert(parseNumberOfStacks("1 2 3 4 5") == 5);
    assert(parseNumberOfStacks(" 1 2 3 4 5 6 7 8 9 10 11 12 ") == 12);
    assert(parseNumberOfStacks("1 2 3 4 5 6 7 8 9 10 11 12") == 12);
}

test "pushStacksLine" {
    const number_of_stacks = 5;
    var stacks = try testing_allocator.alloc(CrateStack, number_of_stacks);
    defer testing_allocator.free(stacks);
    for (stacks) |*stack| stack.* = CrateStack.init(testing_allocator);
    defer for (stacks) |*stack| {
        stack.deinit();
    };
    try pushStacksLine(stacks, "[A] [B]         [E]");
    assert(stacks[0].items[0] == 'A');
    assert(stacks[1].items[0] == 'B');
    assert(stacks[2].items.len == 0);
    assert(stacks[3].items.len == 0);
    assert(stacks[4].items[0] == 'E');
}

test "example input" {
    const input =
        \\
        \\    [D]    
        \\[N] [C]    
        \\[Z] [M] [P]
        \\ 1   2   3 
        \\
        \\move 1 from 2 to 1
        \\move 3 from 1 to 3
        \\move 2 from 2 to 1
        \\move 1 from 1 to 2
    ;

    const result1 = try solvePart1(testing_allocator, input);
    defer testing_allocator.free(result1);
    assert(std.mem.eql(u8, result1, "CMZ"));

    const result2 = try solvePart2(testing_allocator, input);
    defer testing_allocator.free(result2);
    assert(std.mem.eql(u8, result2, "MCD"));
}

const testing_allocator = std.testing.allocator;

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const splitBackwards = std.mem.splitBackwards;
const indexOfStr = std.mem.indexOf;
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

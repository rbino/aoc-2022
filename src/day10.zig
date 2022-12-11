const std = @import("std");
const tokenize = std.mem.tokenize;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const absCast = std.math.absCast;
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("data/day10.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    try solvePart2(data);
}

fn solvePart1(input: []const u8) !isize {
    var sum_of_signal_strength: isize = 0;
    var x: isize = 1;
    var cycles: isize = 1;
    var instructions = tokenize(u8, input, "\n");
    while (instructions.next()) |instr| {
        const instruction = try Instruction.parse(instr);

        var i = instruction.cycles();
        while (i > 0) : (i -= 1) {
            if (@mod(cycles - 20, 40) == 0) {
                sum_of_signal_strength += x * cycles;
            }
            cycles += 1;
        }

        switch (instruction) {
            .addx => |operand| x += operand,
            else => {},
        }
    }

    return sum_of_signal_strength;
}

fn solvePart2(input: []const u8) !void {
    var crt_pos: isize = 0;
    var x: isize = 1;
    var cycles: isize = 1;
    var instructions = tokenize(u8, input, "\n");
    while (instructions.next()) |instr| {
        const instruction = try Instruction.parse(instr);

        var i = instruction.cycles();
        while (i > 0) : (i -= 1) {
            if (@mod(cycles, 40) == 1) {
                crt_pos = 0;
                print("\n", .{});
            }
            if (absCast(x - crt_pos) <= 1) print("#", .{}) else print(".", .{});
            crt_pos += 1;
            cycles += 1;
        }

        switch (instruction) {
            .addx => |operand| x += operand,
            else => {},
        }
    }
    print("\n", .{});
}

const Instruction = union(enum) {
    noop,
    addx: i32,

    pub fn parse(in: []const u8) !Instruction {
        if (eql(u8, in[0..4], "noop")) {
            return .noop;
        }

        if (eql(u8, in[0..4], "addx")) {
            const operand = try parseInt(i32, in[5..], 10);
            return .{ .addx = operand };
        }

        unreachable;
    }

    pub fn cycles(self: Instruction) u8 {
        return switch (self) {
            .noop => 1,
            .addx => 2,
        };
    }
};

const expectEqual = std.testing.expectEqual;

test "example input" {
    const input =
        \\addx 15
        \\addx -11
        \\addx 6
        \\addx -3
        \\addx 5
        \\addx -1
        \\addx -8
        \\addx 13
        \\addx 4
        \\noop
        \\addx -1
        \\addx 5
        \\addx -1
        \\addx 5
        \\addx -1
        \\addx 5
        \\addx -1
        \\addx 5
        \\addx -1
        \\addx -35
        \\addx 1
        \\addx 24
        \\addx -19
        \\addx 1
        \\addx 16
        \\addx -11
        \\noop
        \\noop
        \\addx 21
        \\addx -15
        \\noop
        \\noop
        \\addx -3
        \\addx 9
        \\addx 1
        \\addx -3
        \\addx 8
        \\addx 1
        \\addx 5
        \\noop
        \\noop
        \\noop
        \\noop
        \\noop
        \\addx -36
        \\noop
        \\addx 1
        \\addx 7
        \\noop
        \\noop
        \\noop
        \\addx 2
        \\addx 6
        \\noop
        \\noop
        \\noop
        \\noop
        \\noop
        \\addx 1
        \\noop
        \\noop
        \\addx 7
        \\addx 1
        \\noop
        \\addx -13
        \\addx 13
        \\addx 7
        \\noop
        \\addx 1
        \\addx -33
        \\noop
        \\noop
        \\noop
        \\addx 2
        \\noop
        \\noop
        \\noop
        \\addx 8
        \\noop
        \\addx -1
        \\addx 2
        \\addx 1
        \\noop
        \\addx 17
        \\addx -9
        \\addx 1
        \\addx 1
        \\addx -3
        \\addx 11
        \\noop
        \\noop
        \\addx 1
        \\noop
        \\addx 1
        \\noop
        \\noop
        \\addx -13
        \\addx -19
        \\addx 1
        \\addx 3
        \\addx 26
        \\addx -30
        \\addx 12
        \\addx -1
        \\addx 3
        \\addx 1
        \\noop
        \\noop
        \\noop
        \\addx -9
        \\addx 18
        \\addx 1
        \\addx 2
        \\noop
        \\noop
        \\addx 9
        \\noop
        \\noop
        \\noop
        \\addx -1
        \\addx 2
        \\addx -37
        \\addx 1
        \\addx 3
        \\noop
        \\addx 15
        \\addx -21
        \\addx 22
        \\addx -6
        \\addx 1
        \\noop
        \\addx 2
        \\addx 1
        \\noop
        \\addx -10
        \\noop
        \\noop
        \\addx 20
        \\addx 1
        \\addx 2
        \\addx 2
        \\addx -6
        \\addx -11
        \\noop
        \\noop
        \\noop
    ;

    try expectEqual(try solvePart1(input), 13140);
}

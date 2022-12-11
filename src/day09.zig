const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    const part1_result = try solvePart1(gpa, data);
    print("Part 1 result: {}\n", .{part1_result});
}

pub const Head = struct {
    x: isize,
    y: isize,

    const Self = @This();

    pub fn move(self: *Self, direction: u8) void {
        switch (direction) {
            'U' => self.y += 1,
            'D' => self.y -= 1,
            'R' => self.x += 1,
            'L' => self.x -= 1,
            else => unreachable,
        }
    }
};

pub const Tail = struct {
    x: isize,
    y: isize,

    const Self = @This();

    pub fn follow(self: *Self, head: Head) void {
        const x_delta = head.x - self.x;
        const y_delta = head.y - self.y;

        if (absCast(x_delta) <= 1 and absCast(y_delta) <= 1) return;

        if (absCast(x_delta) > 0 and absCast(y_delta) > 0) {
            switch (order(absCast(x_delta), absCast(y_delta))) {
                .lt => {
                    self.x = head.x;
                    self.y = head.y - sign(y_delta);
                },

                .gt => {
                    self.y = head.y;
                    self.x = head.x - sign(x_delta);
                },
                else => unreachable,
            }
            return;
        }

        if (absCast(x_delta) > 0) {
            self.x += sign(x_delta);
        } else {
            self.y += sign(y_delta);
        }
    }
};

fn solvePart1(allocator: Allocator, input: []const u8) !usize {
    var head = Head{ .x = 0, .y = 0 };
    var tail = Tail{ .x = 0, .y = 0 };

    var position_set = Map(Tail, void).init(allocator);
    defer position_set.deinit();

    var moves = tokenize(u8, input, "\n");
    while (moves.next()) |move| {
        const direction = move[0];
        var times = try parseInt(usize, move[2..], 10);
        while (times > 0) : (times -= 1) {
            head.move(direction);
            tail.follow(head);
            _ = try position_set.fetchPut(tail, {});
        }
    }

    return position_set.count();
}

const expectEqual = std.testing.expectEqual;
const testing_allocator = std.testing.allocator;

test "example input" {
    const input =
        \\R 4
        \\U 4
        \\L 3
        \\D 1
        \\R 4
        \\D 1
        \\L 5
        \\R 2
    ;

    try expectEqual(try solvePart1(testing_allocator, input), 13);
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
const absCast = std.math.absCast;
const order = std.math.order;
const sign = std.math.sign;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

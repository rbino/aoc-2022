const std = @import("std");
const Allocator = std.mem.Allocator;
const Map = std.AutoHashMap;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const absCast = std.math.absCast;
const order = std.math.order;
const sign = std.math.sign;
const print = std.debug.print;
const assert = std.debug.assert;
const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    const part1_result = try solvePart1(gpa, data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(gpa, data);
    print("Part 2 result: {}\n", .{part2_result});
}

pub const Knot = struct {
    x: isize,
    y: isize,

    pub fn move(self: *Knot, direction: u8) void {
        switch (direction) {
            'U' => self.y += 1,
            'D' => self.y -= 1,
            'R' => self.x += 1,
            'L' => self.x -= 1,
            else => unreachable,
        }
    }

    pub fn follow(self: *Knot, other: Knot) void {
        const x_delta = other.x - self.x;
        const y_delta = other.y - self.y;

        if (absCast(x_delta) <= 1 and absCast(y_delta) <= 1) return;

        if (absCast(x_delta) > 0 and absCast(y_delta) > 0) {
            switch (order(absCast(x_delta), absCast(y_delta))) {
                .lt => {
                    self.x = other.x;
                    self.y = other.y - sign(y_delta);
                },

                .gt => {
                    self.y = other.y;
                    self.x = other.x - sign(x_delta);
                },

                .eq => {
                    self.x = other.x - sign(x_delta);
                    self.y = other.y - sign(y_delta);
                },
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
    var head: Knot = .{ .x = 0, .y = 0 };
    var tail: Knot = .{ .x = 0, .y = 0 };

    var position_set = Map(Knot, void).init(allocator);
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

fn solvePart2(allocator: Allocator, input: []const u8) !usize {
    var head: Knot = .{ .x = 0, .y = 0 };
    var tails: [9]Knot = [_]Knot{.{ .x = 0, .y = 0 }} ** 9;

    var position_set = Map(Knot, void).init(allocator);
    defer position_set.deinit();

    var moves = tokenize(u8, input, "\n");
    while (moves.next()) |move| {
        const direction = move[0];
        var times = try parseInt(usize, move[2..], 10);
        while (times > 0) : (times -= 1) {
            head.move(direction);
            tails[0].follow(head);
            var i: usize = 1;
            while (i < tails.len) : (i += 1) {
                tails[i].follow(tails[i - 1]);
            }
            _ = try position_set.fetchPut(tails[tails.len - 1], {});
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
    try expectEqual(try solvePart2(testing_allocator, input), 1);

    const input2 =
        \\R 5
        \\U 8
        \\L 8
        \\D 3
        \\R 17
        \\D 10
        \\L 25
        \\U 20
    ;
    try expectEqual(try solvePart2(testing_allocator, input2), 36);
}

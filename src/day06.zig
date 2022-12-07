const std = @import("std");
const data = @embedFile("data/day06.txt");
const trimRight = std.mem.trimRight;
const print = std.debug.print;
const assert = std.debug.assert;

pub fn main() !void {
    const part1_result = solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
}

const PacketMarkerDetector = MarkerDetector(4);

fn solvePart1(input: []const u8) usize {
    var detector = PacketMarkerDetector{};
    for (trimRight(u8, input, "\n")) |c| {
        if (detector.feedAndDetect(c)) {
            return detector.pos;
        }
    }
    unreachable;
}

const MessageMarkerDetector = MarkerDetector(14);

fn solvePart2(input: []const u8) usize {
    var detector = MessageMarkerDetector{};
    for (trimRight(u8, input, "\n")) |c| {
        if (detector.feedAndDetect(c)) {
            return detector.pos;
        }
    }
    unreachable;
}

fn MarkerDetector(comptime marker_length: usize) type {
    return struct {
        const Self = @This();

        buffer: [marker_length]u8 = undefined,
        pos: usize = 0,
        start: usize = 0,
        end: usize = 0,

        pub fn feedAndDetect(self: *Self, char: u8) bool {
            var i: usize = self.start;
            while (i != self.end) : (i = (i + 1) % marker_length) {
                if (self.buffer[i] == char) {
                    self.start = (i + 1) % marker_length;
                }
            }
            self.buffer[self.end] = char;
            self.end = (self.end + 1) % marker_length;
            self.pos += 1;
            return self.start == self.end;
        }
    };
}

test "example input" {
    assert(solvePart1("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7);
    assert(solvePart1("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5);
    assert(solvePart1("nppdvjthqldpwncqszvftbrmjlhg") == 6);
    assert(solvePart1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 10);
    assert(solvePart1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 11);

    assert(solvePart2("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 19);
    assert(solvePart2("bvwbjplbgvbhsrlpgdmjqwftvncz") == 23);
    assert(solvePart2("nppdvjthqldpwncqszvftbrmjlhg") == 23);
    assert(solvePart2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") == 29);
    assert(solvePart2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") == 26);
}

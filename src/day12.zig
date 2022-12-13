const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Order = std.math.Order;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});
}

const Vertex = struct {
    index: usize,
    predecessor: ?usize,
    shortest_path: usize,
};

fn lessThan(context: void, a: Vertex, b: Vertex) Order {
    _ = context;
    return switch (std.math.order(a.shortest_path, b.shortest_path)) {
        // Use index to disambiguate between vertices with the same shortest path
        .eql => std.math.order(a.index, b.index),
        else => |order| order,
    };
}

const PriorityQueue = std.PriorityQueue(Vertex, void, lessThan);

fn solvePart1(allocator: Allocator, input: []const u8) !usize {
    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();

    const start = indexOf(u8, input, 'S').?;
    var priority_queue = PriorityQueue.init(arena);
    const source = .{ .index = start, .predecessor = null, .shortest_path = 0 };
    priority_queue.append(source);
}

const expectEqual = std.testing.expectEqual;

test "example input" {
    const input =
        \\Sabqponm
        \\abcryxxl
        \\accszExk
        \\acctuvwj
        \\abdefghi
    ;
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

const std = @import("std");
const BoundedArray = std.BoundedArray;
const LinearFifo = std.fifo.LinearFifo;
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const startsWith = std.mem.startsWith;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("data/day11.txt");

pub fn main() !void {
    const part1_result = try solvePart1(data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(data);
    print("Part 2 result: {}\n", .{part2_result});
}

fn solvePart1(input: []const u8) !usize {
    var monkeys = try BoundedArray(Monkey, 16).init(0);
    var monkey_notes = split(u8, input, "\n\n");
    while (monkey_notes.next()) |note| {
        const monkey = try Monkey.init(note);
        try monkeys.append(monkey);
    }

    {
        var i: usize = 0;
        while (i < 20) : (i += 1) {
            for (monkeys.slice()) |*monkey| {
                while (monkey.turnTick()) |thrown_item| {
                    try monkeys.slice()[thrown_item.target].receiveItem(thrown_item.item);
                }
            }
        }
    }

    var first_best: usize = 0;
    var second_best: usize = 0;
    for (monkeys.constSlice()) |monkey| {
        const inspected_items = monkey.inspected_items;
        if (inspected_items > first_best) {
            second_best = first_best;
            first_best = inspected_items;
        } else if (inspected_items > second_best) {
            second_best = inspected_items;
        }
    }

    return first_best * second_best;
}

fn solvePart2(input: []const u8) !usize {
    var monkeys = try BoundedArray(Monkey, 16).init(0);
    var monkey_notes = split(u8, input, "\n\n");
    while (monkey_notes.next()) |note| {
        const monkey = try Monkey.init(note);
        try monkeys.append(monkey);
    }

    var mcm: usize = 1;
    for (monkeys.constSlice()) |monkey| {
        mcm *= monkey.test_divisor;
    }

    {
        var i: usize = 0;
        while (i < 10_000) : (i += 1) {
            for (monkeys.slice()) |*monkey| {
                while (monkey.turnTickV2()) |thrown_item| {
                    try monkeys.slice()[thrown_item.target].receiveItem(thrown_item.item % mcm);
                }
            }
        }
    }

    var first_best: usize = 0;
    var second_best: usize = 0;
    for (monkeys.constSlice()) |monkey| {
        const inspected_items = monkey.inspected_items;
        if (inspected_items > first_best) {
            second_best = first_best;
            first_best = inspected_items;
        } else if (inspected_items > second_best) {
            second_best = inspected_items;
        }
    }

    return first_best * second_best;
}

const ItemsQueue = LinearFifo(usize, .{ .Static = 64 });

const Monkey = struct {
    items: ItemsQueue,
    operation: Operation,
    test_divisor: usize,
    success_target: usize,
    fail_target: usize,
    inspected_items: usize,

    pub fn init(note: []const u8) !Monkey {
        var lines = tokenize(u8, note, "\n");
        const monkey_header = lines.next().?;
        assert(startsWith(u8, monkey_header, "Monkey"));

        const starting_items = lines.next().?;
        const starting_items_header = "  Starting items: ";
        assert(startsWith(u8, starting_items, starting_items_header));
        var items = ItemsQueue.init();
        var starting_items_it = tokenize(u8, starting_items[starting_items_header.len..], ", ");
        while (starting_items_it.next()) |item_str| {
            const item = try parseInt(usize, item_str, 10);
            try items.writeItem(item);
        }

        const operation_str = lines.next().?;
        const operation_header = "  Operation: new = ";
        assert(startsWith(u8, operation_str, operation_header));
        const operation = try Operation.parse(operation_str[operation_header.len..]);

        const divisor_str = lines.next().?;
        const divisor_header = "  Test: divisible by ";
        assert(startsWith(u8, divisor_str, divisor_header));
        const divisor = try parseInt(usize, divisor_str[divisor_header.len..], 10);

        const success_target_str = lines.next().?;
        const success_target_header = "    If true: throw to monkey ";
        assert(startsWith(u8, success_target_str, success_target_header));
        const success_target = try parseInt(usize, success_target_str[success_target_header.len..], 10);

        const fail_target_str = lines.next().?;
        const fail_target_header = "    If false: throw to monkey ";
        assert(startsWith(u8, fail_target_str, fail_target_header));
        const fail_target = try parseInt(usize, fail_target_str[fail_target_header.len..], 10);

        return Monkey{
            .items = items,
            .operation = operation,
            .test_divisor = divisor,
            .success_target = success_target,
            .fail_target = fail_target,
            .inspected_items = 0,
        };
    }

    pub const ThrownItem = struct {
        item: usize,
        target: usize,
    };

    pub fn turnTick(self: *Monkey) ?ThrownItem {
        var item = self.items.readItem() orelse return null;
        self.inspected_items += 1;
        item = self.operation.apply(item);
        item = @divFloor(item, 3);
        const target =
            if (item % self.test_divisor == 0) self.success_target else self.fail_target;
        return .{ .item = item, .target = target };
    }

    pub fn turnTickV2(self: *Monkey) ?ThrownItem {
        var item = self.items.readItem() orelse return null;
        self.inspected_items += 1;
        item = self.operation.apply(item);
        const target =
            if (item % self.test_divisor == 0) self.success_target else self.fail_target;
        return .{ .item = item, .target = target };
    }

    pub fn receiveItem(self: *Monkey, item: usize) !void {
        try self.items.writeItem(item);
    }
};

const Operation = struct {
    op1: Operand,
    operator: Operator,
    op2: Operand,

    pub fn parse(input: []const u8) !Operation {
        var tokens = tokenize(u8, input, " ");
        const op1 = try Operand.parse(tokens.next().?);
        const operator = try Operator.parse(tokens.next().?);
        const op2 = try Operand.parse(tokens.next().?);

        return .{ .op1 = op1, .operator = operator, .op2 = op2 };
    }

    pub fn apply(self: Operation, old_value: usize) usize {
        const op1 = switch (self.op1) {
            .old_value => old_value,
            .constant => |c| c,
        };

        const op2 = switch (self.op2) {
            .old_value => old_value,
            .constant => |c| c,
        };

        return switch (self.operator) {
            .mult => op1 * op2,
            .add => op1 + op2,
        };
    }
};

const Operator = enum {
    mult,
    add,

    pub fn parse(input: []const u8) !Operator {
        assert(input.len == 1);
        return switch (input[0]) {
            '+' => .add,
            '*' => .mult,
            else => error.UnknownOperator,
        };
    }
};

const Operand = union(enum) {
    old_value,
    constant: usize,

    pub fn parse(input: []const u8) !Operand {
        if (eql(u8, input, "old")) return .old_value;
        const c = try parseInt(usize, input, 10);
        return .{ .constant = c };
    }
};

const expectEqual = std.testing.expectEqual;

test "example input" {
    const input =
        \\Monkey 0:
        \\  Starting items: 79, 98
        \\  Operation: new = old * 19
        \\  Test: divisible by 23
        \\    If true: throw to monkey 2
        \\    If false: throw to monkey 3
        \\
        \\Monkey 1:
        \\  Starting items: 54, 65, 75, 74
        \\  Operation: new = old + 6
        \\  Test: divisible by 19
        \\    If true: throw to monkey 2
        \\    If false: throw to monkey 0
        \\
        \\Monkey 2:
        \\  Starting items: 79, 60, 97
        \\  Operation: new = old * old
        \\  Test: divisible by 13
        \\    If true: throw to monkey 1
        \\    If false: throw to monkey 3
        \\
        \\Monkey 3:
        \\  Starting items: 74
        \\  Operation: new = old + 3
        \\  Test: divisible by 17
        \\    If true: throw to monkey 0
        \\    If false: throw to monkey 1
    ;

    try expectEqual(try solvePart1(input), 10605);
    try expectEqual(try solvePart2(input), 2713310158);
}

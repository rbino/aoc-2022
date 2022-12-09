const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const MultiArrayList = std.MultiArrayList;
const ArrayList = std.ArrayList;
const StringArrayHashMap = std.StringArrayHashMap;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    const part1_result = try solvePart1(gpa, data);
    print("Part 1 result: {}\n", .{part1_result});
}

const FileSystemEntry = union(enum) {
    file: u32,
    directory: u32,
};

const EntryMap = StringArrayHashMap(FileSystemEntry);

const Directory = struct {
    parent: ?u32,
    size: u32,
    entries: EntryMap,
};

fn solvePart1(allocator: Allocator, input: []const u8) !usize {
    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();

    var directories = MultiArrayList(Directory){};
    var files = ArrayList(u32).init(arena);

    var dir_stack = ArrayList(u32).init(arena);

    var commands_iterator = tokenize(u8, input, "\n");
    while (commands_iterator.next()) |command| {
        switch (Command.parse(command)) {
            .root_cd => {
                assert(directories.len == 0);
                const entries = EntryMap.init(arena);
                const dir = .{
                    .parent = null,
                    .size = 0,
                    .entries = entries,
                };
                try directories.append(arena, dir);
                try dir_stack.append(0);
            },
            .parent_cd => {
                assert(dir_stack.items.len > 0);
                _ = dir_stack.pop();
            },
            .cd => |target| {
                const current_dir = dir_stack.items[dir_stack.items.len - 1];
                const target_dir = directories.get(current_dir).entries.get(target) orelse
                    return error.DirNotFound;
                const dir_idx = switch (target_dir) {
                    .directory => |d| d,
                    .file => return error.NotADir,
                };
                try dir_stack.append(dir_idx);
            },
            .ls => {},
            .dir_entry => |entry| {
                const current_dir = dir_stack.items[dir_stack.items.len - 1];
                const entries = EntryMap.init(arena);
                const dir = .{
                    .parent = current_dir,
                    .size = 0,
                    .entries = entries,
                };
                try directories.append(arena, dir);
                const dir_idx = @intCast(u32, directories.len - 1);
                var parent_entries = &directories.items(.entries)[current_dir];
                try parent_entries.put(entry, .{ .directory = dir_idx });
            },
            .file_entry => |entry| {
                const current_dir = dir_stack.items[dir_stack.items.len - 1];
                const file_size = entry.size;
                const file_name = entry.name;
                try files.append(file_size);
                const file_idx = @intCast(u32, files.items.len - 1);
                var parent_entries = &directories.items(.entries)[current_dir];
                try parent_entries.put(file_name, .{ .file = file_idx });

                var dir_idx = current_dir;
                while (true) {
                    var size = &directories.items(.size)[dir_idx];
                    size.* += file_size;
                    if (directories.items(.parent)[dir_idx]) |parent| {
                        dir_idx = parent;
                    } else break;
                }
            },
        }
    }

    var ret: usize = 0;
    for (directories.items(.size)) |size| {
        if (size <= 100_000) ret += size;
    }

    return ret;
}

const FileEntry = struct {
    name: []const u8,
    size: u32,
};

const Command = union(enum) {
    root_cd: void,
    parent_cd: void,
    cd: []const u8,
    ls: void,
    dir_entry: []const u8,
    file_entry: FileEntry,

    pub fn parse(input: []const u8) Command {
        var in = input;
        if (in[0] == '$') {
            // Consume "$ "
            in = in[2..];
            if (startsWith(u8, in, "cd")) {
                // Consume "cd "
                in = in[3..];
                if (eql(u8, in, "/")) return .root_cd;
                if (eql(u8, in, "..")) return .parent_cd;

                return .{ .cd = in };
            }

            if (eql(u8, in, "ls")) return .ls;

            unreachable;
        }

        if (startsWith(u8, in, "dir")) {
            // Consume "dir "
            return .{ .dir_entry = in[4..] };
        }

        const spaceIndex = indexOf(u8, in, ' ').?;
        const size = parseInt(u32, in[0..spaceIndex], 10) catch unreachable;
        const name = in[spaceIndex + 1 ..];
        return .{ .file_entry = .{ .name = name, .size = size } };
    }
};

const expectEqual = std.testing.expectEqual;
const testing_allocator = std.testing.allocator;

test "example input" {
    const input =
        \\$ cd /
        \\$ ls
        \\dir a
        \\14848514 b.txt
        \\8504156 c.dat
        \\dir d
        \\$ cd a
        \\$ ls
        \\dir e
        \\29116 f
        \\2557 g
        \\62596 h.lst
        \\$ cd e
        \\$ ls
        \\584 i
        \\$ cd ..
        \\$ cd ..
        \\$ cd d
        \\$ ls
        \\4060174 j
        \\8033020 d.log
        \\5626152 d.ext
        \\7214296 k    
    ;

    const result = try solvePart1(testing_allocator, input);
    try expectEqual(result, 95437);
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
const startsWith = std.mem.startsWith;
const eql = std.mem.eql;
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

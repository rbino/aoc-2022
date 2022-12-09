const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const MultiArrayList = std.MultiArrayList;
const ArrayList = std.ArrayList;
const StrMap = std.StringHashMap;
const util = @import("util.zig");
const gpa = util.gpa;
const tokenize = std.mem.tokenize;
const indexOf = std.mem.indexOfScalar;
const startsWith = std.mem.startsWith;
const eql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const assert = std.debug.assert;
const maxInt = std.math.maxInt;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    const part1_result = try solvePart1(gpa, data);
    print("Part 1 result: {}\n", .{part1_result});

    const part2_result = try solvePart2(gpa, data);
    print("Part 2 result: {}\n", .{part2_result});
}

const FileSystemEntry = union(enum) {
    file: u32,
    directory: u32,
};

const EntryMap = StrMap(FileSystemEntry);

const Directory = struct {
    size: u32,
    entries: EntryMap,
};

fn solvePart1(allocator: Allocator, input: []const u8) !usize {
    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();

    const directories = try populateDirectories(arena, input);

    var ret: usize = 0;
    for (directories.items(.size)) |size| {
        if (size <= 100_000) ret += size;
    }

    return ret;
}

fn solvePart2(allocator: Allocator, input: []const u8) !usize {
    var arena_impl = ArenaAllocator.init(allocator);
    defer arena_impl.deinit();
    const arena = arena_impl.allocator();

    const directories = try populateDirectories(arena, input);

    const total_disk_space = 70_000_000;
    const needed_unused_space = 30_000_000;

    const current_unused_space = total_disk_space - directories.get(0).size;
    const min_deletion = needed_unused_space - current_unused_space;

    var best: usize = maxInt(usize);
    for (directories.items(.size)) |size| {
        if (size >= min_deletion and size < best) best = size;
    }

    return best;
}

fn populateDirectories(allocator: Allocator, input: []const u8) !MultiArrayList(Directory) {
    var directories = MultiArrayList(Directory){};
    var files = ArrayList(u32).init(allocator);

    var dir_stack = ArrayList(u32).init(allocator);

    var commands_iterator = tokenize(u8, input, "\n");
    while (commands_iterator.next()) |command| {
        switch (Command.parse(command)) {
            .root_cd => {
                assert(directories.len == 0);
                const entries = EntryMap.init(allocator);
                const dir = .{
                    .size = 0,
                    .entries = entries,
                };
                try directories.append(allocator, dir);
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
                const entries = EntryMap.init(allocator);
                const dir = .{
                    .size = 0,
                    .entries = entries,
                };
                try directories.append(allocator, dir);
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

                for (dir_stack.items) |dir| {
                    var size = &directories.items(.size)[dir];
                    size.* += file_size;
                }
            },
        }
    }

    return directories;
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

    const result1 = try solvePart1(testing_allocator, input);
    try expectEqual(result1, 95437);

    const result2 = try solvePart2(testing_allocator, input);
    try expectEqual(result2, 24933642);
}

const std = @import("std");
const counter = @import("counter.zig");

pub fn main(init: std.process.Init) !void {
    var flag_w = false;
    var flag_l = false;
    var flag_c = false;
    const io = init.io;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);

    var filepaths: std.ArrayList([]const u8) = .empty;

    for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            std.debug.print("Help\n", .{});
            std.process.exit(0);
        } else if (std.mem.startsWith(u8, arg, "-")) {
            if (std.mem.eql(u8, arg, "-w")) {
                flag_w = true;
            } else if (std.mem.eql(u8, arg, "-l")) {
                flag_l = true;
            } else if (std.mem.eql(u8, arg, "-c")) {
                flag_c = true;
            } else {
                std.debug.print("Unknown flag: {s}\n", .{arg});
                std.process.exit(1);
            }
        } else {
            try filepaths.append(allocator, arg);
        }
    }

    if (filepaths.items.len == 0) {
        std.debug.print("You must specify the path of the file to be read.\n", .{});
        std.process.exit(1);
    } else {
        var total_lines: usize = 0;
        var total_words: usize = 0;
        var total_bytes: usize = 0;

        for (filepaths.items) |path| {
            if (!std.fs.path.isAbsolute(path)) {
                std.debug.print("Please provide an absolute path.\n", .{});
                std.process.exit(1);
            }

            const no_flags = !flag_w and !flag_l and !flag_c;

            var file = std.Io.Dir.openFileAbsolute(io, path, .{}) catch |err| {
                std.debug.print("Could not open file: {}\n", .{err});
                std.process.exit(1);
            };

            const filesize = try file.length(io); // * Bytes

            const content = allocator.alloc(u8, filesize) catch |err| {
                std.debug.print("Could not allocate memory: {}\n", .{err});
                std.process.exit(1);
            };

            var fr = file.reader(io, content);
            fr.interface.readSliceAll(content) catch |err| {
                std.debug.print("Error while reading file: {}\n", .{err});
                std.process.exit(1);
            };

            const result = counter.count(content);

            if (flag_l or no_flags) {
                std.debug.print("{s} - Lines: {}\n", .{ path, result.lines });
            }
            if (flag_w or no_flags) {
                std.debug.print("{s} - Words: {}\n", .{ path, result.words });
            }
            if (flag_c or no_flags) {
                std.debug.print("{s} - Bytes: {}\n\n", .{ path, filesize });
            }

            total_lines += result.lines;
            total_words += result.words;
            total_bytes += filesize;

            file.close(io);
        }

        if (filepaths.items.len > 1) {
            std.debug.print("Total - Lines: {}\n", .{total_lines});
            std.debug.print("Total - Words: {}\n", .{total_words});
            std.debug.print("Total - Bytes: {}\n", .{total_bytes});
        }
    }
}

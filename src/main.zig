const std = @import("std");
const counter = @import("counter.zig");

pub fn main(init: std.process.Init) !void {
    var flag_w = false;
    var flag_l = false;
    var flag_c = false;
    var filepath: []const u8 = undefined;
    const io = init.io;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);

    if (args.len >= 2) {
        filepath = args[1];

        if (!std.fs.path.isAbsolute(filepath)) {
            std.debug.print("Bitte einen absoluten Pfad angeben.\n", .{});
            std.process.exit(1);
        }

        for (args[2..]) |arg| {
            if (std.mem.eql(u8, arg, "-w")) {
                flag_w = true;
            } else if (std.mem.eql(u8, arg, "-l")) {
                flag_l = true;
            } else if (std.mem.eql(u8, arg, "-c")) {
                flag_c = true;
            } else {
                std.debug.print("Unbekanntes Flag: {s}\n", .{arg});
                std.process.exit(1);
            }
        }

        const no_flags = !flag_w and !flag_l and !flag_c;

        var file = std.Io.Dir.openFileAbsolute(io, filepath, .{}) catch |err| {
            std.debug.print("Konnte Datei nicht oeffnen. {}\n", .{err});
            std.process.exit(1);
        };
        defer file.close(io);

        const filesize = try file.length(io); // * Bytes

        const content = allocator.alloc(u8, filesize) catch |err| {
            std.debug.print("Konnte Speicher nicht allozieren: {}\n", .{err});
            std.process.exit(1);
        };
        var fr = file.reader(io, content);
        fr.interface.readSliceAll(content) catch |err| {
            std.debug.print("Fehler beim Lesen der Datei: {}\n", .{err});
            std.process.exit(1);
        };

        const result = counter.count(content);

        if (flag_l or no_flags) {
            std.debug.print("Zeilen: {}\n", .{result.lines});
        }
        if (flag_w or no_flags) {
            std.debug.print("Woerter: {}\n", .{result.words});
        }
        if (flag_c or no_flags) {
            std.debug.print("Bytes: {}\n", .{filesize});
        }
    } else {
        std.debug.print("Du musst den Pfad der Datei angeben, der gelesen werden soll.\n", .{});
        std.process.exit(1);
    }
}

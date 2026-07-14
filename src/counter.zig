const std = @import("std");

pub const Counts = struct {
    lines: usize,
    words: usize,
};

pub fn count(content: []const u8) Counts {
    var lines: usize = 0;
    for (content) |byte| { // * Lines
        if (byte == '\n') {
            lines += 1;
        }
    }

    if (content.len != 0 and content[content.len - 1] != '\n') {
        lines += 1;
    }

    var words: usize = 0;
    var in_word = false;
    for (content) |byte| { // * Words
        if (!std.ascii.isWhitespace(byte) and !in_word) {
            words += 1;
            in_word = true;
        } else if (std.ascii.isWhitespace(byte)) {
            in_word = false;
        }
    }

    return .{ .lines = lines, .words = words };
}

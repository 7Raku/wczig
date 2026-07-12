fn is_whitespace(byte: u8) bool {
    if (byte == ' ') {
        return true;
    } else if (byte == '\t') {
        return true;
    } else if (byte == '\n') {
        return true;
    } else {
        return false;
    }
}

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
        if (!is_whitespace(byte) and !in_word) {
            words += 1;
            in_word = true;
        } else if (is_whitespace(byte)) {
            in_word = false;
        }
    }

    return .{ .lines = lines, .words = words };
}

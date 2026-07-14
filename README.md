# wordcount

A small `wc`-inspired command-line tool written in Zig. Counts lines, words, and bytes in one or more files. Made for learning.

## Features

- Count lines, words, and bytes per file
- Combined totals when multiple files are given
- Selective counting via flags (`-l`, `-w`, `-c`)
- Clean, readable block-style output
- Built-in help text (`-h` / `--help`)

## Installation

Build with the Zig compiler:

```bash
zig build -Doptimize=ReleaseFast
```

The resulting binary will be available under `zig-out/bin/`.

## Usage

```
Usage: wczig [OPTIONS] <FILE>...

Count lines, words, and bytes in one or more files.

Options:
  -l           Print line count
  -w           Print word count
  -c           Print byte count
  -h, --help   Show this help message

If no options are given, all three counts are shown.
```

### Examples

Count everything in a single file:

```bash
wczig file.txt
```

```
file.txt
  Lines: 12
  Words: 45
  Bytes: 312
```

Count only lines across multiple files, with a combined total:

```bash
wczig -l file1.txt file2.txt
```

```
file1.txt
  Lines: 12

file2.txt
  Lines: 8

Total
  Lines: 20
```

Show help:

```bash
wczig -h
```
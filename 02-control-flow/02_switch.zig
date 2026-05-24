// switch in Zig is:
//   1. Exhaustive — every possible value must be handled (or use `else`)
//   2. An expression — it produces a value
//   3. No fallthrough — cases are completely independent (unlike C)
//   4. Supports ranges, multi-value cases, captures, and tagged unions

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Switch as a statement ---
    const day: u8 = 3;
    switch (day) {
        1 => print("Monday\n",    .{}),
        2 => print("Tuesday\n",   .{}),
        3 => print("Wednesday\n", .{}),
        4 => print("Thursday\n",  .{}),
        5 => print("Friday\n",    .{}),
        6 => print("Saturday\n",  .{}),
        7 => print("Sunday\n",    .{}),
        else => print("Invalid day\n", .{}),
    }

    // --- Switch as an expression ---
    const code: u32 = 404;
    const message = switch (code) {
        200      => "OK",
        201      => "Created",
        400      => "Bad Request",
        401, 403 => "Auth Error",    // multiple values in one arm
        404      => "Not Found",
        500      => "Server Error",
        else     => "Unknown",
    };
    print("HTTP {d}: {s}\n", .{ code, message });

    // --- Ranges with ... (inclusive on both ends) ---
    const ch: u8 = 'g';
    const kind = switch (ch) {
        'a'...'z' => "lowercase",
        'A'...'Z' => "uppercase",
        '0'...'9' => "digit",
        else      => "other",
    };
    print("'{c}' is {s}\n", .{ ch, kind });

    // --- Exhaustive switch on an enum (no else needed) ---
    const Direction = enum { north, south, east, west };
    const dir = Direction.east;
    const opposite = switch (dir) {
        .north => Direction.south,
        .south => Direction.north,
        .east  => Direction.west,
        .west  => Direction.east,
        // No `else` needed — all cases covered. Adding one would be an error.
    };
    print("Opposite of {s} is {s}\n", .{ @tagName(dir), @tagName(opposite) });

    // --- Multi-line switch arm with a block ---
    // Use `break :blk value` to return a value from a block.
    const x: i32 = 7;
    const result = switch (x) {
        0      => 0,
        1...5  => x * 2,
        6...10 => blk: {
            const squared = x * x;
            break :blk squared + 1; // 50
        },
        else => -1,
    };
    print("switch({d}) = {d}\n", .{ x, result });

    // --- Capture: get the matched value inside the arm ---
    const Value = union(enum) {
        int: i32,
        float: f64,
        text: []const u8,
    };
    const v = Value{ .float = 3.14 };
    switch (v) {
        .int   => |n| print("int: {d}\n",   .{n}),
        .float => |f| print("float: {d}\n", .{f}),
        .text  => |s| print("text: {s}\n",  .{s}),
    }

    // --- switch continue: loop inside a switch dispatch ---
    // Zig 0.16 added `continue :label value` inside switch to jump to
    // another arm. This replaces computed goto patterns from C.
    var state: u32 = 3;
    var steps: u32 = 0;
    dispatch: switch (state) {
        0 => {
            print("Done after {d} steps\n", .{steps});
        },
        1 => {
            steps += 1;
            state = 0;
            continue :dispatch state;
        },
        2 => {
            steps += 1;
            state = 1;
            continue :dispatch state;
        },
        3 => {
            steps += 1;
            state = 2;
            continue :dispatch state;
        },
        else => unreachable,
    }

    // --- Switching on error values ---
    const FileError = error{ NotFound, PermissionDenied, OutOfMemory };
    const err = FileError.PermissionDenied;
    switch (err) {
        error.NotFound        => print("File not found\n",    .{}),
        error.PermissionDenied => print("Permission denied\n", .{}),
        error.OutOfMemory     => print("Out of memory\n",     .{}),
    }
}
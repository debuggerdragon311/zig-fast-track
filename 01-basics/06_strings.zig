// Zig has no built-in string type. Strings are slices of bytes: []const u8
//
// A string literal like "hello" has the type *const [5:0]u8
//   *const   — immutable pointer
//   [5:0]    — array of 5 bytes, null-terminated (the :0 sentinel)
//   u8       — byte
//
// It coerces freely to []const u8 (a slice = pointer + length).
// Zig strings are UTF-8 by convention but the type doesn't enforce it.
// The length is in bytes, not Unicode codepoints.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- String literals ---
    const greeting = "Hello, Zig!";          // type: *const [11:0]u8
    const as_slice: []const u8 = greeting;                 // coerces fine
    print("{s}\n", .{greeting});
    print("length: {d} bytes\n", .{greeting.len});
    _ = as_slice;

    // --- Indexing gives a u8 byte, not a character ---
    const word = "Zig";
    print("word[0] = {d} = '{c}'\n", .{ word[0], word[0] }); // 90 = 'Z'

    // --- Slicing ---
    const sentence = "systems programming";
    const sub = sentence[0..7]; // "systems" — start..end (end excluded)
    print("slice: {s}\n", .{sub});

    // --- Multi-line strings ---
    // Use \\ prefix on each line. No closing delimiter needed.
    const poem =
        \\No malloc by default,
        \\no hidden control flow,
        \\no exceptions.
    ;
    print("{s}\n", .{poem});

    // --- Comparing strings ---
    // == compares pointers, NOT content. Always use std.mem.eql.
    const s1 = "hello";
    const s2 = "hello";
    const s3 = "world";
    print("eql s1 s2: {}\n", .{std.mem.eql(u8, s1, s2)}); // true
    print("eql s1 s3: {}\n", .{std.mem.eql(u8, s1, s3)}); // false

    // --- Checking prefix / suffix ---
    const filename = "main.zig";
    print("starts with 'main': {}\n", .{std.mem.startsWith(u8, filename, "main")});
    print("ends with '.zig':   {}\n", .{std.mem.endsWith(u8, filename, ".zig")});

    // --- Building strings into a fixed buffer ---
    // Zig has no heap-allocated String type in the stdlib.
    // For small strings: use a fixed buffer on the stack.
    var buf: [64]u8 = undefined;
    const result = std.fmt.bufPrint(&buf, "Zig {s} released in {d}", .{ "0.16.0", 2026 }) catch unreachable;
    print("{s}\n", .{result});
    print("formatted len: {d}\n", .{result.len});

    // --- String concatenation at comptime ---
    // ++ concatenates two array literals at compile time.
    const part1 = "Hello, ";
    const part2 = "world!";
    const combined = part1 ++ part2; // comptime only — both must be comptime-known
    print("{s}\n", .{combined});

    // --- Iterating over bytes ---
    const text = "Zig!";
    for (text, 0..) |byte, i| {
        print("  [{d}] = {d} ('{c}')\n", .{ i, byte, byte });
    }

    // --- UTF-8 note ---
    // Non-ASCII characters take more than 1 byte.
    // .len gives bytes, not codepoints.
    const emoji = "⚡";
    print("'⚡' byte length: {d}\n", .{emoji.len}); // 3 bytes for this codepoint
    // Use std.unicode for proper codepoint handling (covered in a later module).

    // --- Null-terminated strings for C interop ---
    // When calling C APIs, use [*:0]const u8 or std.mem.span to convert.
    const c_str: [*:0]const u8 = "null terminated";
    const back_to_slice = std.mem.span(c_str);
    print("c_str as slice: {s}\n", .{back_to_slice});
}
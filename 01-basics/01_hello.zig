// The entry point of every Zig program is "pub fn main()".
// It can return void, u8, or an error union like !void.
//
// std.debug.print writes to stderr. It never fails — no error to handle.
// The second argument ".{}" is an anonymous struct of format arguments.
// An empty struct means "no arguments".

const std = @import("std");

pub fn main() void {
    // Basic print — format string, then a tuple of args
    std.debug.print("Hello, world!\n", .{});

    // Printing a value — {d} means decimal integer
    const answer: u32 = 42;
    std.debug.print("The answer is {d}\n", .{answer});

    // Printing multiple values in one call
    const name = "Zig";
    const version = "0.16.0";
    std.debug.print("{s} version {s} is ready\n", .{ name, version });

    // {} uses the default formatter — works on most types
    const is_fast = true;
    std.debug.print("Is it fast? {}\n", .{is_fast});

    // Aliasing print to save typing — common pattern in Zig codebases
    const print = std.debug.print;
    print("Same function, shorter name\n", .{});

    // \n = newline, \t = tab, \\ = backslash, \" = quote
    print("Escape sequences:\n\tTab here\n\t\"Quoted\"\n", .{});
}
// Zig has two kinds of bindings: const and var.
//
// const  — the value cannot change after assignment (use this by default)
// var    — the value can change (only use when you need mutation)
//
// Zig does NOT have global mutable state by default.
// The compiler will warn you if a var is never mutated (use const instead).

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- const ---
    // Type is inferred from the right-hand side.
    // Here, `message` is *const [13:0]u8 — a pointer to a string literal.
    const message = "Hello, basics";
    print("{s}\n", .{message});

    // You can also annotate the type explicitly.
    const speed: u32 = 299_792_458; // underscores allowed in numeric literals
    print("Speed of light: {d} m/s\n", .{speed});

    // --- var ---
    // Must be assigned before use, or explicitly set to undefined.
    var counter: u32 = 0;
    counter += 1;
    counter += 1;
    print("Counter: {d}\n", .{counter});

    // --- Type inference ---
    // When you write a literal like 100, Zig gives it a comptime_int type.
    // It coerces to whatever integer type is needed at the use site.
    const x = 100;       // comptime_int
    const y: i64 = 100;  // explicitly i64
    _ = x;               // _ discards a value (suppresses unused-variable error)
    _ = y;

    // --- undefined ---
    // `undefined` is a valid initial value that means "not yet set".
    // Reading from it before writing is safety-checked illegal behavior.
    // The compiler does NOT zero-initialize for you.
    var buffer: [4]u8 = undefined;
    buffer[0] = 'Z';
    buffer[1] = 'i';
    buffer[2] = 'g';
    buffer[3] = '!';
    print("{s}\n", .{buffer});

    // --- Block-scoped bindings ---
    // Zig uses {} blocks for scoping.
    // Unlike C, Zig does NOT allow shadowing a local with the same name.
    // Each block can define its own bindings that don't exist outside it.
    const base: u32 = 10;
    const doubled: u32 = blk: {
        const factor: u32 = 2;   // `factor` only exists inside this block
        break :blk base * factor;
    };
    // `factor` is gone here — this would be a compile error: print("{d}", .{factor});
    print("base={d}, doubled={d}\n", .{ base, doubled });

    // --- @TypeOf ---
    // Ask the compiler what type something is — useful for debugging.
    const some_num: i32 = -5;
    print("Type of some_num: {}\n", .{@TypeOf(some_num)});
    print("Type of message:  {}\n", .{@TypeOf(message)});
}
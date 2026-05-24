// The bool type has exactly two values: true and false.
// Size: 1 byte (like most languages).
//
// Zig has NO truthy/falsy values.
// 0 is not false. null is not false. Only `false` is false.
// if (1) {} is a compile error — the condition must be a bool.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Basic bool ---
    const is_ready: bool = true;
    const has_error: bool = false;
    print("ready: {}, error: {}\n", .{ is_ready, has_error });

    // --- Logical operators ---
    // and — short-circuits: right side not evaluated if left is false
    // or  — short-circuits: right side not evaluated if left is true
    // !   — logical NOT
    const a = true;
    const b = false;
    print("a and b = {}\n", .{a and b}); // false
    print("a or  b = {}\n", .{a or  b}); // true
    print("!a      = {}\n", .{!a});       // false
    print("!b      = {}\n", .{!b});       // true

    // --- Comparison operators produce bool ---
    const x: i32 = 10;
    const y: i32 = 20;
    print("{d} == {d} → {}\n", .{ x, y, x == y });
    print("{d} != {d} → {}\n", .{ x, y, x != y });
    print("{d} <  {d} → {}\n", .{ x, y, x <  y });
    print("{d} >  {d} → {}\n", .{ x, y, x >  y });
    print("{d} <= {d} → {}\n", .{ x, y, x <= y });
    print("{d} >= {d} → {}\n", .{ x, y, x >= y });

    // --- if is an expression, not just a statement ---
    // The result of an if block can be assigned to a const/var.
    const score: u32 = 75;
    const grade = if (score >= 90) "A"
                    else if (score >= 75) "B"
                    else if (score >= 60) "C"
                    else "F";
    print("Score {d} → grade {s}\n", .{ score, grade });

    // --- if with a captured value (optional unwrap — covered more in 05-optionals) ---
    const maybe: ?u32 = 42;
    if (maybe) |val| {
        print("Got value: {d}\n", .{val});
    } else {
        print("Got null\n", .{});
    }

    // --- Boolean in a struct field ---
    const Config = struct {
        verbose: bool,
        dry_run: bool,
    };
    const cfg = Config{ .verbose = true, .dry_run = false };
    if (cfg.verbose) {
        print("Verbose mode enabled\n", .{});
    }
    if (!cfg.dry_run) {
        print("Actually running (not a dry run)\n", .{});
    }

    // --- @sizeOf bool ---
    print("@sizeOf(bool) = {d} byte\n", .{@sizeOf(bool)});
}
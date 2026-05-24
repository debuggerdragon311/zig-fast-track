// Zig `if` is an expression — it produces a value.
// Condition MUST be a bool. No truthy/falsy. No implicit conversions.
// 0 is not false. null is not false. A pointer is not true.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Basic if/else ---
    const temperature: i32 = 72;
    if (temperature > 80) {
        print("Hot\n", .{});
    } else if (temperature > 60) {
        print("Comfortable\n", .{});
    } else {
        print("Cold\n", .{});
    }

    // --- if as an expression (replaces the ternary operator) ---
    // Both branches must produce the same type.
    const score: u32 = 85;
    const grade = if (score >= 90) "A"
                    else if (score >= 80) "B"
                    else if (score >= 70) "C"
                    else "F";
    print("Score {d} = grade {s}\n", .{ score, grade });

    // Assigning an if expression to a var works the same way.
    const threshold: i32 = 0;
    const label: []const u8 = if (threshold >= 0) "non-negative" else "negative";
    print("{d} is {s}\n", .{ threshold, label });

    // --- if with optional capture (unwrapping ?T) ---
    // If the optional has a value, the block runs with `val` bound to it.
    // The else branch handles the null case.
    const maybe_port: ?u16 = 8080;
    if (maybe_port) |port| {
        print("Listening on port {d}\n", .{port});
    } else {
        print("No port configured\n", .{});
    }

    // Null case
    const no_port: ?u16 = null;
    if (no_port) |port| {
        print("port: {d}\n", .{port});
    } else {
        print("Port is null\n", .{});
    }

    // --- Capture by pointer — modify the optional's contents ---
    var mutable_val: ?i32 = 10;
    if (mutable_val) |*v| {
        v.* *= 2; // double it in-place
    }
    print("Doubled optional: {?}\n", .{mutable_val}); // {?} prints optionals

    // --- if with error union capture ---
    // Unwrap !T: |value| gets the success, else |err| gets the error.
    const result: anyerror!u32 = 42;
    if (result) |value| {
        print("Got value: {d}\n", .{value});
    } else |err| {
        print("Got error: {}\n", .{err});
    }

    const failed: anyerror!u32 = error.NotFound;
    if (failed) |value| {
        print("value: {d}\n", .{value});
    } else |err| {
        print("Got error: {s}\n", .{@errorName(err)});
    }

    // --- Nested if: combine optional + error union ---
    // If has a narrow scope: the capture only lives inside the block.
    const outer: ?i32 = 5;
    if (outer) |o| {
        const doubled = o * 2;
        if (doubled > 8) {
            print("Doubled {d} exceeds 8\n", .{doubled});
        }
    }

    // --- if without else in void context ---
    // When both branches produce void, else is optional.
    const flag = true;
    if (flag) print("flag is set\n", .{});
}
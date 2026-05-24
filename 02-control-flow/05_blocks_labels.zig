// In Zig, any `{ }` block is an expression that can return a value.
// Labels turn blocks and loops into named targets for break/continue.
//
// Syntax:
//   label: { ... break :label value; }
//   label: while (...) { break :label; continue :label; }
//   label: for   (...) { break :label; continue :label; }
//
// This replaces goto, labeled breaks in Java, and some uses of closures.
// The returned value's type must match across all break sites.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Block as an expression ---
    // A plain block can compute and return a value with `break :label value`.
    const answer = blk: {
        const x = 6;
        const y = 7;
        break :blk x * y;
    };
    print("6 * 7 = {d}\n", .{answer});

    // --- Block to initialize a complex value ---
    // Useful when the initial value needs multi-step logic.
    const digits = [_]i8{ 3, 8, 9, 0, 7, 4, 1 };
    const min, const max = compute: {
        var lo: i8 = std.math.maxInt(i8);
        var hi: i8 = std.math.minInt(i8);
        for (digits) |d| {
            if (d < lo) lo = d;
            if (d > hi) hi = d;
        }
        break :compute .{ lo, hi }; // destructuring: returns two values
    };
    print("min = {d}, max = {d}\n", .{ min, max });

    // --- Labeled break from a nested loop ---
    // `break :outer` exits the outer for loop entirely.
    // Without the label, `break` would only exit the inner loop.
    const grid = [4][4]u8{
        .{ 0, 0, 0, 0 },
        .{ 0, 0, 7, 0 },
        .{ 0, 0, 0, 0 },
        .{ 0, 0, 0, 0 },
    };
    var target_row: usize = 0;
    var target_col: usize = 0;
    outer: for (grid, 0..) |row, r| {
        for (row, 0..) |cell, c| {
            if (cell == 7) {
                target_row = r;
                target_col = c;
                break :outer; // exits BOTH loops
            }
        }
    }
    print("Found 7 at [{d}][{d}]\n", .{ target_row, target_col });

    // --- Labeled continue ---
    // `continue :outer` skips the rest of the inner loop and goes to the
    // next iteration of the outer loop.
    print("Pairs where i != j: ", .{});
    outer2: for (0..4) |i| {
        for (0..4) |j| {
            if (i == j) continue :outer2; // skip to next i
            print("({d},{d}) ", .{ i, j });
        }
    }
    print("\n", .{});

    // --- Block with void return ---
    // A block with no `break :label value` returns void.
    // Useful for grouping side-effectful code.
    setup: {
        const ready = true;
        if (!ready) break :setup; // early exit from block
        print("Setup complete\n", .{});
    }

    // --- Nested labeled blocks ---
    // Each label is independent. You can break from any named block.
    const val = outer3: {
        const a = inner: {
            const x = 10;
            if (x > 5) break :inner x * 2; // 20
            break :inner 0;
        };
        if (a > 15) break :outer3 a + 1; // 21
        break :outer3 0;
    };
    print("Nested blocks result: {d}\n", .{val});

    // --- while with a labeled break returning a value ---
    // The break value becomes the result of the while expression.
    var i: u32 = 0;
    const first_over_50 = search: while (i < 100) : (i += 1) {
        const sq = i * i;
        if (sq > 50) break :search sq;
    } else 0; // else: never found (loop finished naturally)
    print("First square > 50: {d}\n", .{first_over_50});

    // --- Shadowing with blocks ---
    // A block creates a new scope. Inner `const x` doesn't conflict.
    const x: u32 = 1;
    const y: u32 = inner_scope: {
        const _x: u32 = 99;         // shadows outer x inside this block only not allowed like C
        break :inner_scope _x + 1;  // 100
    };
    print("outer x={d}, y={d}\n", .{ x, y }); // x is still 1
}
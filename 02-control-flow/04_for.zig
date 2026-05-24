// Zig `for` iterates over:
//   - slices and arrays
//   - ranges (0..N)
//   - multiple collections in parallel (all same length)
//
// `for` does NOT have a C-style init/condition/increment form.
// Use `while` with a continue expression for that (see 03_while.zig).

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- for over a slice — value capture ---
    const primes = [_]u32{ 2, 3, 5, 7, 11, 13 };
    for (primes) |p| {
        print("{d} ", .{p});
    }
    print("\n", .{});

    // --- for with index --- 
    // Add a second capture `, index` by zipping with `0..`
    for (primes, 0..) |p, i| {
        print("primes[{d}] = {d}\n", .{ i, p });
    }

    // --- for over a range ---
    // 0..5 means 0, 1, 2, 3, 4 (end is exclusive)
    for (0..5) |i| {
        print("{d} ", .{i});
    }
    print("\n", .{});

    // --- for over a string (iterates bytes) ---
    const word = "Zig";
    for (word) |byte| {
        print("0x{X} ", .{byte});
    }
    print("\n", .{});

    // --- for by reference — mutate elements in place ---
    var scores = [_]i32{ 10, 20, 30, 40 };
    for (&scores) |*score| {
        score.* += 5; // dereference the pointer to write
    }
    for (scores) |s| print("{d} ", .{s});
    print("\n", .{});

    // --- Multi-object for — iterate two slices in parallel ---
    // Both must have the same length; mismatched lengths are a runtime panic.
    const names   = [_][]const u8{ "Alice", "Bob", "Carol" };
    const heights = [_]u32{ 165, 182, 170 };
    for (names, heights) |name, h| {
        print("{s}: {d}cm\n", .{ name, h });
    }

    // --- Multi-object with index ---
    for (names, heights, 0..) |name, h, i| {
        print("[{d}] {s} {d}cm\n", .{ i, name, h });
    }

    // --- for as an expression with else ---
    // else runs only if break was never hit — useful for search.
    const data = [_]i32{ 3, 7, -1, 9, 2 };
    const target: i32 = -1;
    const idx = for (data, 0..) |val, i| {
        if (val == target) break i;
    } else data.len; // sentinel: "not found"
    if (idx < data.len) {
        print("Found {d} at index {d}\n", .{ target, idx });
    } else {
        print("{d} not found\n", .{target});
    }

    // --- Nested for with labeled break ---
    // `break :outer` exits the outer loop from inside the inner one.
    const matrix = [3][3]u8{
        .{ 1, 2, 3 },
        .{ 4, 5, 6 },
        .{ 7, 8, 9 },
    };
    const search: u8 = 5;
    var found_row: usize = 0;
    var found_col: usize = 0;
    outer: for (matrix, 0..) |row, r| {
        for (row, 0..) |val, c| {
            if (val == search) {
                found_row = r;
                found_col = c;
                break :outer;
            }
        }
    }
    print("Found {d} at row {d}, col {d}\n", .{ search, found_row, found_col });

    // --- inline for — loop unrolled at compile time ---
    // Every iteration runs at comptime. Use when `i` must be comptime-known.
    // Common use: iterating over a tuple of types.
    const types = .{ u8, u16, u32, u64 };
    inline for (types) |T| {
        print("{s}: {d} bytes\n", .{ @typeName(T), @sizeOf(T) });
    }

    // --- for over a slice of optionals ---
    const maybe_values = [_]?u32{ 1, null, 3, null, 5 };
    for (maybe_values) |item| {
        if (item) |v| {
            print("{d} ", .{v});
        } else {
            print("_ ", .{});
        }
    }
    print("\n", .{});
}
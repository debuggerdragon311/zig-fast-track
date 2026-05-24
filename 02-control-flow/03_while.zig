// Zig `while` loop forms:
//
//   while (condition) { body }
//   while (condition) : (continue_expr) { body }
//   while (condition) |capture| { body }          -- optional unwrap
//   while (condition) |capture| : (expr) { body } -- optional + continue expr
//
// The continue expression runs after every iteration including `continue`,
// but NOT after `break`. This is unlike C's for loop increment.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Basic while ---
    var i: u32 = 0;
    while (i < 5) {
        print("{d} ", .{i});
        i += 1;
    }
    print("\n", .{});

    // --- While with continue expression : (expr) ---
    // The `: (i += 1)` runs at the end of every iteration.
    // This is the idiomatic Zig equivalent of C's `for (i = 0; i < 5; i++)`.
    var j: u32 = 0;
    while (j < 5) : (j += 1) {
        print("{d} ", .{j});
    }
    print("\n", .{});

    // --- While with break ---
    var k: u32 = 0;
    while (true) {
        if (k == 3) break;
        print("{d} ", .{k});
        k += 1;
    }
    print("\n", .{});

    // --- While with continue ---
    // `continue` skips the rest of the body but still runs the continue expr.
    var n: u32 = 0;
    while (n < 10) : (n += 1) {
        if (n % 2 == 0) continue; // skip even numbers
        print("{d} ", .{n});      // prints odd: 1 3 5 7 9
    }
    print("\n", .{});

    // --- While as an expression with else ---
    // The `else` branch runs only if the condition became false naturally
    // (i.e. break was NOT used). Useful for search loops.
    const haystack = [_]u32{ 1, 5, 3, 8, 2, 7 };
    const needle: u32 = 8;
    var idx: usize = 0;
    const found = while (idx < haystack.len) : (idx += 1) {
        if (haystack[idx] == needle) break true;
    } else false;
    print("Found {d}? {}\n", .{ needle, found });

    // --- Unwrapping an optional with while ---
    // while (optional) |value| runs as long as the optional is non-null.
    // Returns null to stop the loop.
    var opt: ?u32 = 3;
    while (opt) |val| {
        print("opt = {d}\n", .{val});
        opt = if (val == 0) null else val - 1;
    }

    // --- Unwrapping an iterator-style optional ---
    // Common pattern: a "next()" function returns ?T.
    // The loop stops automatically when null is returned.
    const Scanner = struct {
        data: []const u8,
        pos: usize,

        fn next(self: *@This()) ?u8 {
            if (self.pos >= self.data.len) return null;
            defer self.pos += 1;
            return self.data[self.pos];
        }
    };
    var scanner = Scanner{ .data = "Zig", .pos = 0 };
    while (scanner.next()) |byte| {
        print("byte: '{c}'\n", .{byte});
    }

    // --- While with error union capture ---
    // while (expr) |val| runs while no error; else |err| on error.
    const Iterator = struct {
        count: u32,
        fn next(self: *@This()) !?u32 {
            if (self.count > 3) return error.Overflow;
            if (self.count == 3) return null;
            defer self.count += 1;
            return self.count;
        }
    };
    var it = Iterator{ .count = 0 };
    while (it.next() catch null) |val| {
        print("iter val: {d}\n", .{val});
    }

    // --- Multi-expression continue (use a block) ---
    var a: u32 = 1;
    var b: u32 = 1;
    while (a + b < 100) : ({
        const tmp = a + b;
        a = b;
        b = tmp;
    }) {
        print("{d} ", .{a});
    }
    print("\n", .{}); // Fibonacci
}
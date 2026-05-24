// Zig integers are explicit about size and signedness.
// There is no "int". You pick exactly what you need.
//
// Signed:   i8  i16  i32  i64  i128  isize
// Unsigned: u8  u16  u32  u64  u128  usize
//
// usize / isize — pointer-sized (32-bit on 32-bit targets, 64-bit on 64-bit)
// Use usize for array indices, lengths, and memory sizes.
//
// Zig also supports arbitrary bit-width integers: u1, u7, u24, i3, u63, etc.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Sizes and limits ---
    print("u8  range: 0 to {d}\n",           .{std.math.maxInt(u8)});
    print("i8  range: {d} to {d}\n",         .{ std.math.minInt(i8), std.math.maxInt(i8) });
    print("u64 max:   {d}\n",                .{std.math.maxInt(u64)});
    print("usize is {d} bytes on this CPU\n", .{@sizeOf(usize)});

    // --- Arithmetic ---
    // In Debug builds, integer overflow is a runtime panic.
    // Zig does NOT silently wrap like C.
    const a: u32 = 1000;
    const b: u32 = 500;
    print("{d} + {d} = {d}\n", .{ a, b, a + b });
    print("{d} * {d} = {d}\n", .{ a, b, a * b });
    print("{d} / {d} = {d}\n", .{ a, b, a / b }); // integer division, truncates
    print("{d} % {d} = {d}\n", .{ a, b, a % b }); // remainder

    // --- Wrapping arithmetic ---
    // Use +% -% *% when you WANT wraparound behavior (e.g. checksums, hashing).
    // This is explicit — you opt in. No silent surprises.
    const max_u8: u8 = std.math.maxInt(u8);      // 255
    const wrapped = max_u8 +% 1;            // wraps to 0 instead of panicking
    print("255 +% 1 = {d} (wrapping)\n", .{wrapped});

    const min_i8: i8 = std.math.minInt(i8);      // -128
    const wrapped2 = min_i8 -% 1;           // wraps to 127
    print("-128 -% 1 = {d} (wrapping)\n", .{wrapped2});

    // --- Saturating arithmetic ---
    // +| -| *| — clamps at the type's min/max instead of wrapping.
    const sat = max_u8 +| 10; // saturates at 255, doesn't wrap
    print("255 +| 10 = {d} (saturating)\n", .{sat});

    // --- Casting ---
    // NO implicit conversion between integer types. Always explicit.
    const small: u8  = 42;
    const big: u64   = @intCast(small); // safe: u8 fits in u64
    print("u8 {d} cast to u64: {d}\n", .{ small, big });

    // Casting from a larger type is checked at runtime in Debug mode.
    // If the value doesn't fit, it panics.
    const fits: u32  = 200;
    const byte: u8   = @intCast(fits); // ok at runtime — 200 fits in u8
    print("u32 {d} cast to u8: {d}\n", .{ fits, byte });

    // Truncating cast — takes the low bits, no panic ever
    const big_num: u32 = 256;           // 0x0100
    const trunc: u8    = @truncate(big_num); // low 8 bits = 0x00 = 0
    print("u32 256 truncated to u8: {d}\n", .{trunc});

    // --- Hex, binary, octal literals ---
    const hex: u32  = 0xFF_00_AA;
    const bin: u8   = 0b1010_1010;
    const oct: u16  = 0o777;
    print("hex: {X}, binary: {b}, octal: {o}\n", .{ hex, bin, oct });

    // --- Bit shifts ---
    const shifted_left:  u8 = 1 << 4; // 16
    const shifted_right: u8 = 128 >> 2; // 32
    print("1 << 4 = {d}, 128 >> 2 = {d}\n", .{ shifted_left, shifted_right });

    // --- Bitwise operators ---
    const p: u8 = 0b1111_0000;
    const q: u8 = 0b1010_1010;
    print("AND: {b:0>8}\n", .{p & q});  // 0b1010_0000
    print("OR:  {b:0>8}\n", .{p | q});  // 0b1111_1010
    print("XOR: {b:0>8}\n", .{p ^ q});  // 0b0101_1010
    print("NOT: {b:0>8}\n", .{~p});     // 0b0000_1111

    // --- clamp ---
    const val: i32 = 150;
    const clamped = std.math.clamp(val, 0, 100);
    print("clamp(150, 0, 100) = {d}\n", .{clamped});
}
// Zig float types: f16  f32  f64  f80  f128
//
// f32  — single precision (~7 significant decimal digits)
// f64  — double precision (~15 significant decimal digits) — default for literals
// f80  — 80-bit extended (x86 only)
// f128 — quad precision (very slow, use rarely)
//
// Float literals are comptime_float and coerce to any float type.
// Like integers, there is NO implicit conversion between float sizes or
// between integers and floats. Always explicit.

const std = @import("std");
const print = std.debug.print;

pub fn main() void {

    // --- Basic floats ---
    const pi: f64  = 3.14159265358979;
    const tau: f64 = 2.0 * pi;
    print("pi  = {d}\n", .{pi});
    print("tau = {d:.6}\n", .{tau}); // {d:.6} = 6 decimal places

    // --- f32 vs f64 precision ---
    const precise: f64 = 1.0 / 3.0;
    const lossy: f32   = 1.0 / 3.0;
    print("f64: {d:.15}\n", .{precise}); // 0.333333333333333...
    print("f32: {d:.15}\n", .{lossy});   // notice precision loss

    // --- Scientific notation ---
    const avogadro: f64 = 6.022e23;
    const planck: f64   = 6.626e-34;
    print("Avogadro: {e}\n", .{avogadro});
    print("Planck:   {e}\n", .{planck});

    // --- Integer to float (must be explicit) ---
    const count: u32 = 7;
    const ratio: f64 = @floatFromInt(count); // u32 -> f64
    print("7 as f64: {d}\n", .{ratio});

    // --- Float to integer (must be explicit, truncates toward zero) ---
    const temperature: f64 = 98.6;
    const temp_int: i32    = @intFromFloat(temperature); // truncates: 98
    print("98.6 as i32: {d}\n", .{temp_int});

    // --- Float to float casting ---
    const big: f64   = 1234.5678;
    const small: f32 = @floatCast(big); // precision may be lost
    print("f64 -> f32: {d:.4}\n", .{small});

    // --- Special values ---
    const inf    = std.math.inf(f64);
    const neg_inf = -std.math.inf(f64);
    const nan    = std.math.nan(f64);
    print("inf:     {d}\n", .{inf});
    print("-inf:    {d}\n", .{neg_inf});
    print("nan:     {d}\n", .{nan});
    print("is nan?  {}\n", .{std.math.isNan(nan)});

    // --- Precision trap: never compare floats with == ---
    // 0.1 + 0.2 is NOT exactly 0.3 in binary floating point.
    const bad = (0.1 + 0.2) == 0.3;
    print("0.1 + 0.2 == 0.3 ? {}\n", .{bad}); // false!

    // Use approxEqAbs instead, with a tolerance (epsilon)
    const close = std.math.approxEqAbs(f64, 0.1 + 0.2, 0.3, 1e-9);
    print("approx equal?       {}\n", .{close}); // true

    // --- Useful std.math functions ---
    print("sqrt(2.0)  = {d:.6}\n", .{@sqrt(2.0)});  // builtin
    print("abs(-7.5)  = {d}\n",    .{@abs(-7.5)});   // builtin
    print("floor(3.9) = {d}\n",    .{@floor(3.9)}); // builtin
    print("ceil(3.1)  = {d}\n",    .{@ceil(3.1)});  // builtin
    print("round(3.5) = {d}\n",    .{@round(3.5)}); // builtin

    // --- std.math constants ---
    print("std.math.pi  = {d:.10}\n", .{std.math.pi});
    print("std.math.e   = {d:.10}\n", .{std.math.e});
}
<div align=center>

# 01 · Basics

> **Goal:** Get comfortable with Zig's syntax before touching anything dangerous.
> Every file here compiles and runs standalone — no build system needed yet.

---
</div>

## How to run any file...

```bash
zig run 01_hello.zig
```


## The one concept that trips everyone up

Zig has **no implicit type coercion between numeric types**. This is intentional.

```zig
const x: u8  = 10;
const y: u16 = x;           // ✗ compile error
const y: u16 = @intCast(x); // ✓ explicit cast
```

You will see `@intCast`, `@floatFromInt`, and `@intFromFloat` constantly.
They are not boilerplate — they are you telling the compiler "yes, I know what I am doing."

---

## Format specifiers

`std.debug.print` uses the same format strings as `std.fmt`.

| Specifier | Prints |
|-----------|--------|
| `{}`  | default format (auto) |
| `{d}` | decimal integer |
| `{x}` | hex (lowercase) |
| `{X}` | hex (uppercase) |
| `{b}` | binary |
| `{s}` | string / `[]const u8` |
| `{c}` | single character (`u8`) |
| `{e}` | scientific notation (float) |
| `{?}` | optional (prints `null` or the value) |
| `{!}` | error union |
| `{any}` | any type, uses default formatter |

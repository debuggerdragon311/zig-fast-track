# 02 · Control Flow

> **Goal:** Master every branching and looping construct Zig has.
> The big shift from C/Rust: almost everything is an **expression** — it
> produces a value you can assign directly to a `const`.

---

## How to run any file

```bash
zig run 01_if_else.zig
```

---

## What's in this folder

| File | What you'll learn |
|------|-------------------|
| `01_if_else.zig` | `if` as statement and expression, `else if` chains |
| `02_switch.zig` | Exhaustive switch, ranges, multi-case, capture, `continue :label` |
| `03_while.zig` | `while`, continue expression `: (i += 1)`, `break`/`continue`, `else` |
| `04_for.zig` | `for` over slices, ranges, multi-object, by reference, `else` |
| `05_blocks_labels.zig` | Named blocks, `break :label value`, labeled loops, destructuring |

---

## The key insight

In Zig, `if`, `switch`, and block expressions all **return values**.
There is no ternary operator (`? :`). You use `if` instead:

```zig
// C:   int label = score >= 90 ? 1 : 0;
// Zig:
const label = if (score >= 90) 1 else 0;
```

`switch` works the same way:

```zig
const name = switch (color) {
    .red   => "red",
    .green => "green",
    .blue  => "blue",
};
```

---

## Switch is exhaustive by default

If you don't handle every possible value, **it won't compile**.
This catches bugs the C switch/default pattern misses entirely.

```zig
const Direction = enum { north, south, east, west };

const label = switch (dir) {
    .north => "N",
    .south => "S",
    .east  => "E",
    // forgot .west — compile error: switch must handle all cases
};
```

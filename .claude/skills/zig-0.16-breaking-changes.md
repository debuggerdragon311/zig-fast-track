# Zig 0.16.0 — Breaking Changes Reference

Source-verified against: `zig-0.16.0/lib/std/` and `zig-0.16.0/lib/std/start.zig`

---

## 1. `std.Io` is now the I/O interface (capital I)

The biggest change in 0.16.0. All I/O that can block — files, networking,
timers, synchronization — moved into `std.Io` (capital I), which is an
interface similar to `std.mem.Allocator`.

### What this means for lesson code

For beginner lessons, use `std.debug.print`. It bypasses the `Io` interface
and writes directly to stderr using the lowest-level syscall available.
It never fails and requires no `Io` instance.

```zig
// CORRECT for all beginner/intermediate lessons
const std = @import("std");
pub fn main() void {
    std.debug.print("Hello {s}\n", .{"world"});
}
```

For production code that needs stdout or file I/O, the new pattern is:

```zig
// CORRECT production stdout pattern (0.16.0)
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [4096]u8 = undefined;
    var file_writer = std.Io.File.stdout().writer(io, &buf);
    const w = &file_writer.interface;
    try w.print("Hello {s}\n", .{"world"});
    try w.flush();
}
```

### Old patterns that NO LONGER WORK

```zig
// BROKEN in 0.16.0 — do not generate
const stdout = std.io.getStdOut().writer();  // std.io (lowercase) is gone
try stdout.print("hello\n", .{});            // writer() API changed

// BROKEN — async/await removed entirely
const frame = async myFunc();
await frame;
```

---

## 2. `GeneralPurposeAllocator` renamed to `DebugAllocator`

Verified in: `zig-0.16.0/lib/std/heap.zig` line 20
```
pub const DebugAllocator = @import("heap/debug_allocator.zig").DebugAllocator;
```

### Old vs New

```zig
// BROKEN (0.15 and earlier)
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();

// CORRECT (0.16.0)
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();
const allocator = gpa.allocator();
```

### `deinit()` now returns `std.heap.Check`

Verified in: `zig-0.16.0/lib/std/heap/debug_allocator.zig` line 495
```zig
pub fn deinit(self: *Self) std.heap.Check {
```

`std.heap.Check` is `enum { ok, leak }`.
The `_ =` pattern discards the result. To assert no leaks:

```zig
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer {
    const check = gpa.deinit();
    if (check == .leak) @panic("memory leak detected");
}
```

---

## 3. `std.Io.Writer` replaces `std.io.Writer`

The writer type is now `std.Io.Writer` (capital I).
It is a vtable-based interface, not a generic type.

Verified in: `zig-0.16.0/lib/std/Io/Writer.zig`

Key methods on `*std.Io.Writer`:
- `try w.writeAll(bytes: []const u8) Error!void`
- `try w.writeByte(byte: u8) Error!void`
- `try w.print(comptime fmt, args) Error!void`
- `try w.flush() Error!void`
- `w.buffered() []u8` — returns unflurhed bytes

`Writer.Error` is `error{WriteFailed}` (not `anyerror`).

### Fixed-buffer writer (stack allocated, no allocator)

```zig
var buf: [256]u8 = undefined;
var w: std.Io.Writer = .fixed(&buf);
try w.print("result: {d}\n", .{42});
const output: []u8 = w.buffered(); // "result: 42\n"
```

### Allocating writer (heap allocated)

```zig
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();
try aw.writer.print("hello {s}\n", .{"world"});
const result: []u8 = aw.writer.buffered();
```

---

## 4. `main` function signatures

Verified in: `zig-0.16.0/lib/std/start.zig` lines 696–748

Three valid `main` signatures in 0.16.0:

```zig
// 1. Simplest — no args, no Io (works for all lesson files)
pub fn main() void { ... }
pub fn main() !void { ... }

// 2. With process.Init (gets Io, allocator, args)
pub fn main(init: std.process.Init) !void {
    const io  = init.io;
    const gpa = init.gpa;
    // init.arena, init.args, init.environ_map also available
}

// 3. With process.Init.Minimal (args only, no Io)
pub fn main(init: std.process.Init.Minimal) !void {
    // init.args only
}
```

For all lessons in this repo, use signature #1: `pub fn main() void`.

---

## 5. `switch` gains `continue :label` dispatch

New in 0.16.0. A `switch` statement can be labeled, and arms can
`continue :label value` to jump to another arm. This replaces computed-goto
patterns from C and some state-machine patterns.

```zig
var state: u32 = 3;
dispatch: switch (state) {
    0 => { /* done */ },
    1 => { state = 0; continue :dispatch state; },
    2 => { state = 1; continue :dispatch state; },
    3 => { state = 2; continue :dispatch state; },
    else => unreachable,
}
```

---

## 6. Variable shadowing is now a compile error

In 0.14/0.15, shadowing was allowed with a warning. In 0.16.0 it is a
**compile error**.

```zig
const x: u32 = 10;
{
    const x: u32 = 20; // ERROR: local constant 'x' shadows local constant from outer scope
}
```

**Never generate shadowing code.** Use distinct names.

---

## 7. `@branchHint` is new in 0.16.0

`@branchHint(.likely)` and `@branchHint(.cold)` replace the old
`@setCold` builtin for branch probability hints to the optimizer.
Do not use `@setCold` in 0.16.0 code.

---

## 8. `std.heap.smp_allocator` is new

For production multi-threaded programs without a custom allocator:

```zig
// Available in 0.16.0 for non-WASM, non-single-threaded targets
const allocator = std.heap.smp_allocator;
```

This is a lock-free, scalable allocator designed for multi-threaded use.
`start.zig` uses it by default when linking without libc.

---

## Format specifiers — new in 0.16.0

Verified from `Writer.zig` `printValue` function:

| Specifier | Meaning |
|-----------|---------|
| `{D}` | nanoseconds as human duration |
| `{B}` | bytes in SI units (kB, MB, GB) |
| `{Bi}` | bytes in IEC units (KiB, MiB, GiB) |
| `{t}` | tag name for enums, unions, and error sets |
| `{b64}` | base64 encode bytes |
| `{f}` | call `.format(writer)` method on the type |

`{t}` replaces the pattern of manually calling `@tagName` in format strings.

---

## `std.mem` renames

| Old name | New name in 0.16.0 |
|----------|-------------------|
| `std.mem.indexOfScalar` | `std.mem.findScalar` (old name still works as alias) |
| `std.mem.lastIndexOfScalar` | `std.mem.findScalarLast` |
| `std.mem.indexOfAny` | `std.mem.findAny` |
| `std.mem.indexOfDiff` | `std.mem.findDiff` |
| `std.mem.indexOfSentinel` | `std.mem.findSentinel` |

The old names are kept as `pub const` aliases, so they still compile,
but prefer the new names in new code.

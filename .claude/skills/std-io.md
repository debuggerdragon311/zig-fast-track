# std.Io — Verified API Reference (Zig 0.16.0)

Source: `zig-0.16.0/lib/std/Io.zig`, `zig-0.16.0/lib/std/Io/Writer.zig`,
`zig-0.16.0/lib/std/Io/File.zig`, `zig-0.16.0/lib/std/Io/Threaded.zig`

Note: `std.Io` uses a **capital I**. `std.io` (lowercase) from older versions
is gone. Any code using `std.io` is targeting 0.15 or earlier.

---

## Overview

`std.Io` is an interface (vtable-based) introduced in 0.16.0 that unifies all
blocking I/O operations: files, networking, timers, synchronization.

It works like `std.mem.Allocator` — code that does I/O accepts an `Io`
parameter instead of using a global runtime.

For **lesson files**, use `std.debug.print`. It does not need an `Io` instance.
`std.Io` is for **production code** in lessons 11+ (concurrency, file I/O).

---

## `std.Io.Writer`

The writer interface. A vtable struct, not a generic type.

Source: `zig-0.16.0/lib/std/Io/Writer.zig`

### Core methods

```zig
// All methods take *Writer (pointer receiver)
try w.writeAll(bytes: []const u8) Error!void
try w.writeByte(byte: u8) Error!void
try w.print(comptime fmt: []const u8, args: anytype) Error!void
try w.flush() Error!void
w.buffered() []u8          // returns unflused buffered bytes (no error)
w.unusedCapacitySlice() []u8
w.unusedCapacityLen() usize
w.advance(n: usize) void   // after writing to unusedCapacitySlice manually
```

`Writer.Error` = `error{WriteFailed}` — not `anyerror`.

### Fixed-buffer writer (stack allocated)

```zig
var buf: [256]u8 = undefined;
var w: std.Io.Writer = .fixed(&buf);
try w.print("x = {d}\n", .{42});
const result = w.buffered(); // []u8 — "x = 42\n"
// No flush needed — fixed buffer, no underlying sink
```

Returns `error.WriteFailed` when the buffer is full.

### Allocating writer (heap allocated, grows automatically)

```zig
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();
try aw.writer.print("hello {s}\n", .{"world"});
const result: []u8 = aw.writer.buffered();
// Or take ownership:
const owned: []u8 = try aw.toOwnedSlice();
defer allocator.free(owned);
```

### Discarding writer (counts bytes, discards output)

```zig
var buf: [64]u8 = undefined;
var d: std.Io.Writer.Discarding = .init(&buf);
try d.writer.print("hello {d}\n", .{42});
const total_bytes = d.fullCount(); // includes buffered bytes
```

---

## `std.Io.File`

Represents an OS file handle.

Source: `zig-0.16.0/lib/std/Io/File.zig`

### Getting stdout, stderr, stdin

```zig
// These return File structs — verified from File.zig lines 91–130
const out_file = std.Io.File.stdout();
const err_file = std.Io.File.stderr();
const in_file  = std.Io.File.stdin();
```

### Creating a File.Writer

```zig
// Requires an Io instance and a buffer you own
var buf: [4096]u8 = undefined;
var fw = std.Io.File.stdout().writer(io, &buf);
// fw.interface is a *std.Io.Writer
try fw.interface.print("Hello {s}\n", .{"world"});
try fw.interface.flush();
```

Signature verified from `File.zig` line 600:
```zig
pub fn writer(file: File, io: Io, buffer: []u8) Writer
```

---

## Getting an `Io` instance

### In main with `std.process.Init` (recommended)

Verified from `start.zig` lines 696–748:

```zig
pub fn main(init: std.process.Init) !void {
    const io  = init.io;       // std.Io instance
    const gpa = init.gpa;      // allocator (DebugAllocator in debug mode)
    _ = io;
    _ = gpa;
}
```

`init.io` is backed by `std.Io.Threaded` — uses thread pool for async ops.

### Available fields on `std.process.Init`

```zig
pub const Init = struct {
    minimal:     Minimal,      // args and environ
    arena:       *ArenaAllocator,
    gpa:         Allocator,
    io:          Io,
    environ_map: *Environ.Map,
    preopens:    Preopens,
};
```

### In tests (`std.testing.io`)

```zig
test "file write" {
    const io = std.testing.io; // test Io instance
    var buf: [64]u8 = undefined;
    var fw = std.Io.File.stdout().writer(io, &buf);
    try fw.interface.writeAll("test\n");
    try fw.interface.flush();
}
```

---

## `std.Io.Threaded`

The default Io implementation for most programs. Uses a thread pool.

Source: `zig-0.16.0/lib/std/Io/Threaded.zig`

```zig
// start.zig creates this automatically when main has std.process.Init
// You don't create it manually in most code.
// For custom programs:
var threaded: std.Io.Threaded = .init(allocator, .{});
defer threaded.deinit();
const io: std.Io = threaded.io();
```

---

## `std.Io.Dir`

Directory operations. Replaces `std.fs.Dir` in 0.16.0.

```zig
// Open a file relative to a directory
const file = try std.Io.Dir.openFileAbsolute(io, "/etc/hosts", .{});
defer file.close(io);
```

---

## Buffered I/O pattern

For high-throughput I/O, use a larger buffer:

```zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [65536]u8 = undefined; // 64KB buffer
    var fw = std.Io.File.stdout().writer(io, &buf);
    const w = &fw.interface;

    for (0..1000) |i| {
        try w.print("line {d}\n", .{i});
    }
    try w.flush(); // flush once at end
}
```

---

## What is NOT in std.Io

These are still in their old modules in 0.16.0:
- `std.mem` — memory operations (no change)
- `std.fmt.bufPrint` — stack-based formatting (no change)
- `std.debug.print` — stderr debugging (no change)
- `std.math` — math functions (no change)

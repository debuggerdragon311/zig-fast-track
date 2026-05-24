# Zig 0.16.0 — Agent Instructions

This project targets **Zig 0.16.0**. All generated code must compile on 0.16.0.
Do not generate code targeting 0.13, 0.14, or 0.15 — APIs changed significantly.

---

## Read before generating any code

Always consult these skill files before writing or editing `.zig` files:

| Skill file | When to read |
|------------|-------------|
| `.claude/skills/zig-0.16-breaking-changes.md` | Always — covers every renamed/removed API |
| `.claude/skills/std-debug.md` | Any time you write print, assert, or panic |
| `.claude/skills/std-io.md` | Any file I/O, stdout, stderr, networking |
| `.claude/skills/allocators.md` | Any heap allocation |
| `.claude/skills/build-system.md` | Editing build.zig or adding compilation steps |
| `.claude/skills/testing.md` | Writing or running tests |
| `.claude/skills/common-mistakes.md` | Before finalizing any generated code |

---

## The most critical 0.16.0 changes at a glance

| Old (≤ 0.15) | Correct (0.16.0) |
|--------------|-----------------|
| `std.io.getStdOut().writer()` | `std.debug.print` (debug) or `std.Io.File.stdout().writer(io, &buf)` (production) |
| `std.heap.GeneralPurposeAllocator(.{}){}` | `std.heap.DebugAllocator(.{}){} = .init` |
| `gpa.deinit()` returns `bool` | `gpa.deinit()` returns `std.heap.Check` (`.ok` or `.leak`) |
| `std.io.Writer` (lowercase) | `std.Io.Writer` (capital I) |
| `async` / `await` keywords | Removed — replaced by `std.Io` interface |
| Variable shadowing allowed | **Compile error** in 0.16.0 — use distinct names |

---

## Non-negotiable compiler rules

These are enforced by the compiler — violating them is a compile error or runtime panic:

- **No implicit numeric coercion** — use `@intCast`, `@floatFromInt`, `@intFromFloat`, `@floatCast`, `@truncate`
- **No local variable shadowing** — compile error; always use distinct names
- **Exhaustive switch on enums** — every variant must be handled, or use `else`
- **`var` that is never mutated** — compiler error; use `const`
- **Integer overflow in Debug/ReleaseSafe** — runtime panic; use `+%` for intentional wrapping
- **`try` on fallible functions** — forgetting `try` is a compile error; errors cannot be silently discarded

---

## Preferred patterns for common tasks

### Output (use for all non-production code)
```zig
const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("value: {d}\n", .{42});
}
```

### Heap allocation
```zig
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();
const allocator = gpa.allocator();
```

### Error handling
```zig
const result = try fallibleFn();          // propagate
const result = fallibleFn() catch 0;      // default value
const result = fallibleFn() catch |err| { // handle explicitly
    std.debug.print("error: {s}\n", .{@errorName(err)});
    return;
};
```

### Resource cleanup
```zig
const buf = try allocator.alloc(u8, size);
errdefer allocator.free(buf); // only on error path
// ... initialize buf ...
return buf;                   // caller owns it — errdefer does NOT run
```

### Testing
```zig
test "description" {
    const allocator = std.testing.allocator; // detects leaks
    try std.testing.expectEqual(@as(u32, 42), result);
    try std.testing.expectEqualStrings("expected", actual);
}
```

---

## Code quality standards

When generating `.zig` files for this project:

1. Every file must compile — no pseudocode, no `// TODO: implement`
2. Use `const` by default; only use `var` when mutation is necessary
3. Pass allocators as parameters — never store or access them globally
4. Use `errdefer` for cleanup on error paths, `defer` for unconditional cleanup
5. Prefer `std.mem.Allocator` as parameter type, not concrete allocator types
6. Format specifiers must match argument types exactly — mismatches are compile errors
7. Comments explain *why*, not *what* — the code already shows what

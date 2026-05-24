# Build System — Verified Patterns (Zig 0.16.0)

Source: `zig-0.16.0/build.zig`, `zig-0.16.0/doc/langref/build.zig`,
`zig-0.16.0/lib/std/Build.zig`

---

## Running standalone lesson files (no build system)

For lessons 01–08, files are standalone. Run directly:

```bash
zig run 01_hello.zig
zig run 02_variables.zig
```

Build with optimization:
```bash
zig run -O ReleaseSafe 01_hello.zig
zig run -O ReleaseFast 01_hello.zig
```

---

## Minimal `build.zig` (verified from `doc/langref/build.zig`)

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target   = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "my-program",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target   = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

### Key 0.16.0 API notes

- `b.addExecutable` takes `.root_module` — not `root_source_file` directly
- `b.createModule` wraps the source file + target + optimize
- `b.standardTargetOptions` and `b.standardOptimizeOption` are unchanged

---

## Adding a test step

```zig
const unit_tests = b.addTest(.{
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target   = target,
        .optimize = optimize,
    }),
});

const run_tests = b.addRunArtifact(unit_tests);
const test_step = b.step("test", "Run unit tests");
test_step.dependOn(&run_tests.step);
```

Run tests: `zig build test`

---

## Repo build.zig for zig-fast-track

A single `build.zig` at the repo root that can run tests for any milestone:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Helper to add a test step for a whole directory
    const all_test_step = b.step("test", "Run all lesson tests");

    // Milestone 01 — basics
    addLessonTests(b, target, optimize, all_test_step, "01-basics", &.{
        "01_hello.zig",
        "02_variables.zig",
        "03_integers.zig",
        "04_floats.zig",
        "05_booleans.zig",
        "06_strings.zig",
    });

    // Milestone 02 — control flow
    addLessonTests(b, target, optimize, all_test_step, "02-control-flow", &.{
        "01_if_else.zig",
        "02_switch.zig",
        "03_while.zig",
        "04_for.zig",
        "05_blocks_labels.zig",
    });

    // Add more milestones as they are written...
}

fn addLessonTests(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    parent_step: *std.Build.Step,
    dir: []const u8,
    files: []const []const u8,
) void {
    for (files) |file| {
        const path = b.pathJoin(&.{ dir, file });
        const exe = b.addExecutable(.{
            .name = file[0 .. file.len - 4], // strip .zig
            .root_module = b.createModule(.{
                .root_source_file = b.path(path),
                .target   = target,
                .optimize = optimize,
            }),
        });
        const run = b.addRunArtifact(exe);
        parent_step.dependOn(&run.step);
    }
}
```

### Usage

```bash
zig build test          # run all lessons
zig build test-01       # run only milestone 01 (add a named step)
zig build -Doptimize=ReleaseSafe test
```

---

## `build.zig.zon` — package manifest

Required when using the package manager or publishing:

```zig
.{
    .name = .zig_fast_track,
    .version = "0.1.0",
    .minimum_zig_version = "0.16.0",
    .dependencies = .{},
    .paths = .{"."},
}
```

- `.minimum_zig_version` prevents people from building with older Zig
- No dependencies needed for this tutorial repo

---

## Incremental compilation (0.16.0 feature)

```bash
# Enable incremental compilation for faster rebuilds during development
zig build -fincremental

# Watch mode — recompiles on file change
zig build -fincremental --watch
```

Incremental compilation is significantly improved in 0.16.0 and is stable
for most use cases.

---

## Optimization modes

| Flag | Mode | When to use |
|------|------|-------------|
| (default) | `Debug` | Development — full safety checks, stack traces |
| `-O ReleaseSafe` | `ReleaseSafe` | Production — optimized, safety checks kept |
| `-O ReleaseFast` | `ReleaseFast` | Max performance — safety checks removed |
| `-O ReleaseSmall` | `ReleaseSmall` | Smallest binary — safety checks removed |

For the capstone project, compile with `-O ReleaseSafe`:

```bash
zig build-exe src/main.zig -O ReleaseSafe
```

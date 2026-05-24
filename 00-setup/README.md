<div align=center>

# 00 · Setup

> Install Zig 0.16.0, verify it works, and configure your editor.
> This entire repo is written for **0.16.0 only** — older versions will not compile the examples.

---

</div>

## Step 1 — Download Zig 0.16.0

Go to **[ziglang.org/download](https://ziglang.org/download/)** and grab the binary for your platform.

Direct links for 0.16.0:

| Platform | Architecture | Download |
|----------|--------------|----------|
| Windows  | x86_64       | [zig-windows-x86_64-0.16.0.zip](https://ziglang.org/download/0.16.0/zig-windows-x86_64-0.16.0.zip) |
| macOS    | Apple Silicon (M1/M2/M3) | [zig-macos-aarch64-0.16.0.tar.xz](https://ziglang.org/download/0.16.0/zig-macos-aarch64-0.16.0.tar.xz) |
| macOS    | Intel        | [zig-macos-x86_64-0.16.0.tar.xz](https://ziglang.org/download/0.16.0/zig-macos-x86_64-0.16.0.tar.xz) |
| Linux    | x86_64       | [zig-linux-x86_64-0.16.0.tar.xz](https://ziglang.org/download/0.16.0/zig-linux-x86_64-0.16.0.tar.xz) |
| Linux    | aarch64      | [zig-linux-aarch64-0.16.0.tar.xz](https://ziglang.org/download/0.16.0/zig-linux-aarch64-0.16.0.tar.xz) |

> Not sure which to pick? On macOS, run `uname -m` in your terminal. If it prints `arm64` → Apple Silicon. If `x86_64` → Intel.

Extract the archive anywhere you like. Zig is a self-contained folder — no installer, no admin rights needed.

---

## Step 2 — Add Zig to your PATH

You need `zig` to be callable from any terminal. This is a one-time step.

### Windows (PowerShell)

**System-wide** (run PowerShell as Administrator):
```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\path\to\zig-windows-x86_64-0.16.0",
   "Machine"
)
```

**Current user only** (no admin needed):
```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\path\to\zig-windows-x86_64-0.16.0",
   "User"
)
```

Replace `C:\path\to\zig-windows-x86_64-0.16.0` with wherever you extracted the zip. Restart PowerShell after.

### macOS / Linux / BSD

Add this line to your shell config file (`.zshrc`, `.bashrc`, `.profile`, etc.):

```bash
export PATH=$PATH:~/path/to/zig-linux-x86_64-0.16.0
```

Then reload it:

```bash
source ~/.zshrc   # or source ~/.bashrc
```

### Package managers (alternative to manual download)

If you prefer a package manager:

**Windows:**
```powershell
winget install -e --id zig.zig   # WinGet
choco install zig                 # Chocolatey
scoop install zig                 # Scoop
```

**macOS:**
```bash
brew install zig        # Homebrew
sudo port install zig   # MacPorts
```

**Linux:** Check your distro's package manager. Note that distro packages often lag behind the official release — verify with `zig version` after installing.

---

## Step 3 — Verify the installation

Open a fresh terminal and run:

```bash
zig version
```

You should see exactly:

```
0.16.0
```

If you see a different version, you have an old Zig on your PATH ahead of the new one. Fix the PATH order and try again.

---

## Step 4 — Run Hello World

```bash
mkdir hello-world
cd hello-world
zig init
```

This creates a project scaffold:

```
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
```

Run it:

```bash
zig build run
```

Expected output:

```
All your codebase are belong to us.
Run `zig build test` to run the tests.
```

That confirms the compiler, build system, and linker all work on your machine.

---

## Step 5 — Editor setup

### VS Code

Install the **Zig Language** extension (`ziglang.vscode-zig`). It bundles ZLS (Zig Language Server) and gives you:
- Syntax highlighting
- Go-to-definition
- Inline error diagnostics
- Auto-complete

### Neovim / Vim

Install [zigtools/zls](https://github.com/zigtools/zls) and wire it up through your LSP client (`nvim-lspconfig`, `ALE`, etc.).

### JetBrains (CLion / IDEA)

Use the **ZigBrains** plugin from the JetBrains Marketplace.

### Other editors

See the full list at [ziglang.org/learn/tools](https://ziglang.org/learn/tools/).

> **ZLS version must match your Zig version.** If you install ZLS separately, grab the release tagged `0.16.0`. Mismatched versions cause confusing errors.

---

## Step 6 — Clone this repo and run lesson 01

```bash
git clone https://github.com/debuggerdragon311/zig-fast-track.git
cd zig-fast-track/01-basics
zig run 01_hello.zig
```

Expected output:

```
Hello, world!
The answer is 42
Zig version 0.16.0 is ready
Is it fast? true
Same function, shorter name
Escape sequences:
	Tab here
	"Quoted"
```

You're ready. Move to [`01-basics/`](../01-basics/).

---

## Troubleshooting

**`zig: command not found`**
PATH is not set correctly. Double-check Step 2 and open a fresh terminal.

**`error: expected Zig version 0.x.x, found 0.16.0`**
A `build.zig.zon` in the project pins a different version. Use the version this repo expects: 0.16.0.

**Compilation errors on the first lesson**
You are likely running an older Zig. Confirm with `zig version`. The `std.Io` interface and several APIs changed in 0.16.0 — nothing in this repo will work on 0.13, 0.14, or 0.15.

**Windows: `zig build run` opens a window and closes immediately**
Run it from a terminal (PowerShell or cmd), not by double-clicking.
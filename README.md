# ASM Maze Solver — Win32 NASM

A 32-bit x86 Windows console program written entirely in NASM assembly. It generates random mazes or loads a custom maze from a text file and solves it visually using a **Depth-First Search (DFS)** algorithm with animated, color-coded terminal output.

---

## Features

- **3 random maze modes**: Easy (10×10), Medium (20×20), Hard (30×30)
- **File mode**: load any custom maze from `maze.txt` — dimensions are auto-detected
- **DFS visualization**: watch the solver explore the maze in real time
- **3 display styles**: Minimal, Normal, Dense
- **3 speed levels**: Slow, Normal, Fast
- **Color-coded UI**: walls, paths, visited cells, current head, start and end markers

---

## Prerequisites

| Tool | Notes |
|------|-------|
| [NASM](https://www.nasm.us/) ≥ 2.15 | Assembler |
| [MinGW-w64](https://www.mingw-w64.org/) | Provides `gcc -m32` for 32-bit linking |
| Windows 7 / 10 / 11 | Win32 console API required |

Both `nasm` and `gcc` must be on your `PATH`:

```powershell
nasm --version   # NASM version 2.x
gcc --version    # gcc (MinGW-w64 ...)
```

---

## Project Structure

```
asm-maze-solver-win32-nasm/
├── main.asm          # Entry point, menu, shared data section
├── maze.txt          # Custom maze file (loaded with option F)
├── build.bat         # Build script
├── UI/
│   └── ui.asm        # Console rendering, color, cursor (SV1)
├── IO/
│   └── file.asm      # File I/O, maze dimension auto-detection (SV2)
├── core/
│   └── core.asm      # DFS solver, random maze generator (SV3)
└── reports/          # Project documentation
```

---

## Build

```bat
build.bat
```

The script runs:

```bat
nasm -f win32 main.asm -o main.o
gcc -m32 main.o -o maze_solver.exe -lkernel32
```

A successful build produces `maze_solver.exe` in the same directory.

---

## Run

```bat
maze_solver.exe
```

---

## Menu

```
MAZE SOLVER (DFS) - Choose mode:
1) Easy   (random 10x10)
2) Medium (random 20x20)
3) Hard   (random 30x30)
F) Load from maze.txt
```

After selecting a mode you are prompted for:

1. **Speed** — `1` Slow · `2` Normal · `3` Fast
2. **Display** — `1` Minimal · `2` Normal · `3` Dense

### Display legend

| Symbol | Color | Meaning |
|--------|-------|---------|
| `#` | Dark grey | Wall |
| `.` | White | Open path |
| `@` | Cyan | Current DFS head |
| `*` | Yellow | Visited cell |
| `S` | Green | Start |
| `E` | Red | End / exit |

---

## Maze File Format

Custom mazes are read from `maze.txt` placed in the **same directory** as `maze_solver.exe`.

### Characters

| Char | Meaning |
|------|---------|
| `1` | Wall |
| `0` | Open path |
| `S` | Start (exactly one) |
| `E` | End / exit (exactly one) |

### Rules

1. **LF line endings only** (`\n`, `0x0A`).  
   Do **not** save with Windows CRLF (`\r\n`) — the extra `\r` bytes corrupt the maze buffer.  
   In VS Code: check the status bar (bottom-right) and click `CRLF` → select `LF` before saving.

2. **Rectangular grid** — every row must have exactly the same number of characters.

3. **Outer border** — surround the entire maze with `1` walls on all four sides.

4. **Exactly one `S`** and **one `E`** anywhere inside the border.

5. **Size limit** — `cols × rows ≤ 1600` (roughly 40×40 maximum).

6. A single blank line at the start of the file is allowed and ignored automatically.

7. UTF-8 BOM and UTF-16 BOM are stripped automatically.

### Minimal example

```
111111111
1S00000E1
111111111
```

### Full example (39×14)

```
111111111111111111111111111111111111111
1S0000000000001000000000000000000000001
101111111111101011111111111111111111101
101000000000101010000000000010000000101
101011111110101010111111111010111110101
101010000010101010100000001010100010101
101010111010101010101111101010101010101
101010101010101010101000101010101010101
101010101010100010101010101000101010101
101010101010111110101010111111101010101
101000101010000000101000000000001010101
101111101011111111101111111111111010101
1000000010000000000000000000000000100E1
111111111111111111111111111111111111111
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Maze display is garbled / wrong dimensions | CRLF line endings | Convert to LF (see Rule 1 above) |
| Maze display wrong after resize | Console window too narrow | Widen the terminal to at least `cols + 4` characters |
| `Cannot open maze.txt` | File not found | Place `maze.txt` next to `maze_solver.exe` |
| `No start S found` | Missing `S` in file | Verify maze contains exactly one `S` |
| Random maze generates instead of file | File option not selected | Press `F` at the main menu |

---

## Authors

| Role | Responsibility |
|------|---------------|
| **SV1** | UI module — console rendering, color, cursor (`UI/ui.asm`) |
| **SV2** | I/O module — file reading, dimension auto-detection (`IO/file.asm`) |
| **SV3** | Core module — DFS solver, random maze generator (`core/core.asm`) |

---

*Computer Architecture course project — Win32 NASM, pure x86 assembly, no C runtime.*

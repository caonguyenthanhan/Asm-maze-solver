# Report Overview (Win32 NASM)

## Summary

Project: Maze solver with DFS (Win32 32-bit, NASM + WinAPI).

Additional documentation:
- `reports/REPORT_DETAILED.md`
- `reports/REPORT_DIAGRAMS.html`
- `reports/BLOG_REPORT.html`

Code is split into 3 modules for independent student reporting:

- UI (SV1): `Asm-maze-solver-win32-nasm/UI/ui.asm`
- File I/O (SV2): `Asm-maze-solver-win32-nasm/IO/file.asm`
- Core/DFS (SV3): `Asm-maze-solver-win32-nasm/core/core.asm`

Integration entrypoint:

- `Asm-maze-solver-win32-nasm/main.asm`

## Demo Scenarios

1. UI demo: clear screen, move cursor, draw characters.
2. I/O demo: read `maze.txt`, normalize CR/LF, BOM, and verify buffer.
3. Core demo: run DFS on a hardcoded maze buffer and visualize steps.
4. Full integration: run `maze_solver.exe` with `maze.txt`.

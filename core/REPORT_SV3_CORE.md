# SV3 Report (Core + DFS + Integration)

## Module

- File: `core/core.asm`
- Responsibilities:
  - Maze indexing 2D -> 1D
  - Valid cell check
  - DFS stack (software stack arrays)
  - DFS solve loop
  - Full maze drawing mapping

## Public Procedures

- `MAIN_FindStart`
- `MAIN_DrawFullMaze`
- `MAIN_GetIndex`
- `MAIN_IsValid`
- `DFS_Push`
- `DFS_Pop`
- `DFS_Solve`

## Demo

Build and run:

```powershell
cd "Asm-maze-solver-win32-nasm\core"
.\build_core_demo.bat
.\core_demo.exe
```

## Integration

Full build:

```powershell
cd "Asm-maze-solver-win32-nasm"
.\build.bat
.\maze_solver.exe
```

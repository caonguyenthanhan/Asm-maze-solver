# SV2 Report (File I/O)

## Module

- File: `IO/file.asm`
- Responsibilities:
  - Open `maze.txt`
  - Read into memory buffer `maze`
  - Normalize data:
    - Remove CR/LF
    - Ignore UTF-8 BOM / UTF-16 BOM
    - Ignore NUL bytes
  - Return success/failure in `EAX`

## Public Procedures

- `FILE_ReadMaze` (EAX=1 success, EAX=0 error)

## Demo

Build and run:

```powershell
cd "Asm-maze-solver-win32-nasm\IO"
.\build_io_demo.bat
.\io_demo.exe
```

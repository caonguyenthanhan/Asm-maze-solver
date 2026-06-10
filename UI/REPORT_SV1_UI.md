# SV1 Report (UI)

## Module

- File: `UI/ui.asm`
- Responsibilities:
  - Clear screen
  - Cursor movement (GotoXY)
  - Draw character / draw animated cell
  - Print null-terminated string
  - Wait for a key press

## Public Procedures

- `UI_ClearScreen`
- `UI_GotoXY`
- `UI_DrawChar`
- `UI_DrawCell`
- `UI_PrintZ`
- `UI_WaitKey`

## Demo

Build and run:

```powershell
cd "Asm-maze-solver-win32-nasm\UI"
.\build_ui_demo.bat
.\ui_demo.exe
```

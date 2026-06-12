# SV1 Report - Console UI

## Scope

SV1 owns the standalone Windows Console UI:

- `UI/ui.asm`: reusable low-level console procedures and high-level screens.
- `UI/demo_ui.asm`: interactive UI demonstration using sample data.
- `UI/build_ui_demo.bat`: standalone UI build script.

The UI demo does not read maze files and does not run DFS. File status, maze
content, solver progress, and statistics shown in the demo are sample values.
The integration module can later call the same `UI_Show...` procedures with
real application state.

## Implemented Screens

- Main menu
- Instructions
- Maze source selection
- Random-maze difficulty selection
- Solver speed selection
- Visualization-density selection
- File selection
- Filename prompt
- Maze validation success
- Maze validation error
- Solving progress
- Successful result
- Failed result
- Project/team information
- Exit/thank-you screen

The screen layout follows the ASCII mockups in the Lab 08 specification and
stays below the normal 80-column Windows Console width.

## Low-Level Procedures

- `UI_ClearScreen`: clear the console and reset the cursor.
- `UI_ClearLine`: clear the row selected by `coord_y`.
- `UI_GotoXY`: move the cursor using `coord_x` and `coord_y`.
- `UI_DrawChar`: draw the character in `AL`.
- `UI_DrawCell`: draw a character and wait for `ui_delay_ms`.
- `UI_PrintZ`: print the zero-terminated string addressed by `EDX`.
- `UI_ShowScreen`: print a zero-terminated table of string pointers.
- `UI_PrintLinesAt`: print a table of strings starting at row `BX`.
- `UI_DrawMaze`: render a fixed-width maze using a pointer, rows, and columns.
- `UI_WaitKey`: read one console character.
- `UI_ReadChoice`: return the next non-CR/LF character in `AL`.
- `UI_SetColor` / `UI_ResetColor`: set and restore console text attributes.
- `UI_PrintDec2` / `UI_PrintDec4`: print fixed-width decimal values.

All low-level procedures preserve general-purpose registers except where the
procedure contract explicitly returns a value.

## High-Level Screen Procedures

- `UI_ShowMainMenu`
- `UI_ShowHelp`
- `UI_ShowSourceMenu`
- `UI_ShowDifficultyMenu`
- `UI_ShowSpeedMenu`
- `UI_ShowDisplayMenu`
- `UI_ShowFileMenu`
- `UI_ShowFilenamePrompt`
- `UI_ShowValidationSuccess`
- `UI_ShowValidationError`
- `UI_ShowSolvingScreen`
- `UI_ShowResultSuccess`
- `UI_ShowResultFailure`
- `UI_ShowProjectInfo`
- `UI_ShowExitScreen`
- `UI_ShowInvalidChoice`

## Demo Flow

The standalone demo provides these interactions:

- Main menu option `1`: choose maze source, difficulty when random, speed,
  visualization density, validation success, solving screen, then result.
- Result option `1`: solve again and alternate between success/failure results.
- Main menu option `2`: instructions.
- Main menu option `3`: file-selection screens and validation-error example.
- Main menu option `4`: team/project information.
- Main menu option `5`: thank-you screen and exit.

## Build and Run

```powershell
cd UI
.\build_ui_demo.bat
.\ui_demo.exe
```

Requirements:

- Windows Console
- NASM Win32
- MinGW GCC 32-bit toolchain installed at `C:\msys64\mingw32\bin`

## Integration Boundary

SV1 only renders screens and receives keyboard choices. These operations remain
the responsibilities of other modules:

- Opening, reading, and validating a real maze file.
- Running DFS and deciding success or failure.
- Producing real step, visited-cell, and backtrack statistics.

## Specification Addition

The Word mockups do not include the existing project options for random-maze
difficulty, solver speed, and visualization density. The UI demo includes these
screens so that the UI specification also covers features already implemented
by the integrated project.

The standalone UI demo stores the selected maze dimensions and renders distinct
sample grids for Easy `10x10`, Normal `15x15`, Hard `20x20`, and file mode.
These are display samples; actual random generation remains a Core concern.

The solving screen also runs a UI-only path animation. It demonstrates the
selected Slow/Normal/Fast delay, but it is not the real DFS algorithm.

During that animation, the information panel and result statistics are updated
from the demo state: current position, steps, visited cells, and backtracks.

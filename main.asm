; Integration entrypoint (Win32 NASM)
; This file is the only build target for the full program (maze_solver.exe).
; Modules:
;   - UI:   UI/ui.asm
;   - IO:   IO/file.asm
;   - Core: core/core.asm

; NASM syntax, 32-bit Windows
extern _GetStdHandle@4
extern _WriteConsoleA@20
extern _ReadConsoleA@20
extern _ExitProcess@4
extern _SetConsoleCursorPosition@8
extern _GetConsoleScreenBufferInfo@8
extern _FillConsoleOutputCharacterA@20
extern _FillConsoleOutputAttribute@20
extern _SetConsoleTextAttribute@8
extern _Sleep@4
extern _GetTickCount@0
extern _CreateFileA@28
extern _ReadFile@20
extern _CloseHandle@4
extern _GetFileSize@8

section .data
    cols dd 10
    rows dd 10
    stack_cap dd 1600
    ui_delay_ms dd 80
    mode_kind db 0
    mode_level dd 1
    rand_state dd 0
    gen_attempt dd 0
    gen_target_x dd 0
    gen_target_y dd 0
    gen_threshold db 0
    ui_attr_default dw 7
    dfs_steps dd 0
    dfs_display_mode db 1
    maze times 1600 db 0
    maze_work times 1600 db 0
    currX dd 0
    currY dd 0
    stack_x times 1600 db 0
    stack_y times 1600 db 0
    stack_top dd 0
    maze_file db 'maze.txt', 0
    menu_title db 'MAZE SOLVER (DFS) - Choose mode:', 0
    menu_opt1 db '1) Easy   (random 10x10)', 0
    menu_opt2 db '2) Medium (random 20x20)', 0
    menu_opt3 db '3) Hard   (random 30x30)', 0
    menu_optf db 'F) Load from maze.txt', 0
    menu_speed db 'Choose speed: 1) Slow  2) Normal  3) Fast', 0
    menu_display db 'Choose display: 1) Minimal  2) Normal  3) Dense', 0
    msg_generating db 'Generating solvable maze, please wait...', 0
    msg_start db 'AI solving maze with DFS...', 0
    status_step db 'Step:', 0
    status_x db ' X:', 0
    status_y db ' Y:', 0
    status_pad db '     ', 0
    legend_prefix db 'Legend: ', 0
    legend_wall db '#', 0
    legend_wall_text db ' Wall,  ', 0
    legend_path db '.', 0
    legend_path_text db ' Path,  ', 0
    legend_vis db '*', 0
    legend_vis_text db ' Visited,  ', 0
    legend_cur db '@', 0
    legend_cur_text db ' Current,  ', 0
    legend_s db 'S', 0
    legend_s_text db ' Start,  ', 0
    legend_e db 'E', 0
    legend_e_text db ' End', 0
    msg_done db 'Maze solved! Press any key to exit.', 0
    msg_file_err db 'Cannot open maze.txt. Press any key to exit.', 0
    msg_start_err db 'No start S found in maze. Press any key to exit.', 0
    hConsole dd 0
    hInput dd 0
    bytes_written dd 0
    buffer db 0
    num_buf times 16 db 0

    ; COORD structure
    coord_x dw 0
    coord_y dw 0

section .bss
    file_size resd 1
    file_handle resd 1
    bytes_read resd 1

section .text
global _main

_main:
    ; Get stdout handle
    push -11          ; STD_OUTPUT_HANDLE
    call _GetStdHandle@4
    mov [hConsole], eax

    push -10
    call _GetStdHandle@4
    mov [hInput], eax

    ; Clear screen
    call UI_ClearScreen

menu_loop:
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, menu_title
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_opt1
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 2
    call UI_GotoXY
    mov edx, menu_opt2
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, menu_opt3
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, menu_optf
    call UI_PrintZ

menu_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je menu_read_key
    cmp al, 10
    je menu_read_key
    cmp al, '1'
    je mode_easy
    cmp al, '2'
    je mode_medium
    cmp al, '3'
    je mode_hard
    cmp al, 'F'
    je mode_file
    cmp al, 'f'
    je mode_file
    call UI_ClearScreen
    jmp menu_loop

mode_easy:
    mov byte [mode_kind], 1
    mov dword [mode_level], 1
    jmp speed_menu

mode_medium:
    mov byte [mode_kind], 1
    mov dword [mode_level], 2
    jmp speed_menu

mode_hard:
    mov byte [mode_kind], 1
    mov dword [mode_level], 3
    jmp speed_menu

mode_file:
    mov byte [mode_kind], 0
    jmp speed_menu

speed_menu:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, menu_speed
    call UI_PrintZ

speed_loop:
speed_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je speed_read_key
    cmp al, 10
    je speed_read_key
    cmp al, '1'
    je speed_slow
    cmp al, '2'
    je speed_normal
    cmp al, '3'
    je speed_fast
    jmp speed_loop

speed_slow:
    mov dword [ui_delay_ms], 150
    jmp display_menu

speed_normal:
    mov dword [ui_delay_ms], 80
    jmp display_menu

speed_fast:
    mov dword [ui_delay_ms], 10
    jmp display_menu

display_menu:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, menu_display
    call UI_PrintZ

display_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je display_read_key
    cmp al, 10
    je display_read_key
    cmp al, '1'
    je display_min
    cmp al, '2'
    je display_norm
    cmp al, '3'
    je display_dense
    jmp display_read_key

display_min:
    mov byte [dfs_display_mode], 0
    jmp load_or_generate

display_norm:
    mov byte [dfs_display_mode], 1
    jmp load_or_generate

display_dense:
    mov byte [dfs_display_mode], 2
    jmp load_or_generate

load_or_generate:
    call UI_ClearScreen
    mov dword [dfs_steps], 0

    cmp byte [mode_kind], 0
    je load_file

    call _GetTickCount@0
    mov [rand_state], eax

generate_maze:
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, msg_generating
    call UI_PrintZ

    mov dword [gen_attempt], 0
gen_try:
    inc dword [gen_attempt]
    mov eax, [gen_attempt]
    dec eax
    mov [coord_x], ax
    mov word [coord_y], 1
    call UI_GotoXY
    mov al, '.'
    call UI_DrawChar
    mov eax, [mode_level]
    call MAIN_GenerateRandomMaze
    cmp eax, 1
    je gen_ok
    cmp dword [gen_attempt], 5
    jb gen_try
    jmp after_load

gen_ok:
    call UI_ClearScreen
    jmp after_load

load_file:
    call FILE_ReadMaze
    cmp eax, 0
    je err_file

after_load:

    ; Find start position ('S')
    call MAIN_FindStart
    cmp eax, 0
    je err_start

    ; Draw full maze
    call MAIN_DrawFullMaze
    call MAIN_PrintLegend

    ; Print start message at (0,12)
    mov word [coord_x], 0
    mov eax, [rows]
    add eax, 2
    mov [coord_y], ax
    call UI_ClearLine
    call UI_GotoXY
    mov edx, msg_start
    call UI_PrintZ

    ; Run DFS solve
    call DFS_Solve

    ; Print done message at (0,14)
    mov word [coord_x], 0
    mov eax, [rows]
    add eax, 4
    mov [coord_y], ax
    call UI_ClearLine
    call UI_GotoXY
    mov edx, msg_done
    call UI_PrintZ

    ; Wait for user input (simple, just Sleep a bit)
    call UI_WaitKey
    jmp exit

err_file:
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, msg_file_err
    call UI_PrintZ
    call UI_WaitKey
    jmp exit

err_start:
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, msg_start_err
    call UI_PrintZ
    call UI_WaitKey
    jmp exit

exit:
    mov word [coord_x], 0
    mov eax, [rows]
    add eax, 16
    mov [coord_y], ax
    call UI_GotoXY
    push 0
    call _ExitProcess@4

MAIN_PrintLegend:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov word [coord_x], 0
    mov eax, [rows]
    mov [coord_y], ax
    call UI_ClearLine
    call UI_GotoXY
    mov edx, legend_prefix
    call UI_PrintZ
    mov eax, 8
    call UI_SetColor
    mov edx, legend_wall
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_wall_text
    call UI_PrintZ
    mov eax, 7
    call UI_SetColor
    mov edx, legend_path
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_path_text
    call UI_PrintZ
    mov eax, 14
    call UI_SetColor
    mov edx, legend_vis
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_vis_text
    call UI_PrintZ
    mov eax, 11
    call UI_SetColor
    mov edx, legend_cur
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_cur_text
    call UI_PrintZ
    mov eax, 10
    call UI_SetColor
    mov edx, legend_s
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_s_text
    call UI_PrintZ
    mov eax, 12
    call UI_SetColor
    mov edx, legend_e
    call UI_PrintZ
    call UI_ResetColor
    mov edx, legend_e_text
    call UI_PrintZ
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

%include "UI/ui.asm"
%include "IO/file.asm"
%include "core/core.asm"

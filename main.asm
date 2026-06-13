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
extern _FlushConsoleInputBuffer@4

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
    dfs_prev_char db 0
    maze times 1600 db 0
    maze_work times 1600 db 0
    currX dd 0
    currY dd 0
    stack_x times 1600 db 0
    stack_y times 1600 db 0
    stack_top dd 0
    startX dd 0
    startY dd 0
    endX dd 0
    endY dd 0
    errorCode dd 0
    cells_examined dd 0
    dfs_result db 0
    input_name_buf times 64 db 0
    maze_file db 'maze.txt', 0
    maze_file_pad times 55 db 0
    menu_title db 'ASM MAZE SOLVER - NASM WIN32', 0
    menu_sep   db '====================================', 0
    menu_opt1 db '1) Giai me cung (doc file)', 0
    menu_opt2 db '2) Xem huong dan', 0
    menu_opt3 db '3) Chon file me cung', 0
    menu_opt4 db '4) Thong tin nhom / du an', 0
    menu_opt5 db '5) Thoat', 0
    menu_opt6 db '6) Tao me cung ngau nhien (bonus)', 0
    menu_prompt db 'Nhap lua chon: ', 0
    menu_invalid db 'Lua chon khong hop le. Bam phim bat ky de thu lai.', 0
    gen_title db 'CHON DO KHO (BONUS)', 0
    gen_opt1 db '1) Easy   (random 10x10)', 0
    gen_opt2 db '2) Medium (random 20x20)', 0
    gen_opt3 db '3) Hard   (random 30x30)', 0
    gen_optb db 'B) Quay lai menu', 0
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
    help_title db 'HUONG DAN', 0
    help_l1 db '#: Tuong   .: Duong   @: AI hien tai   *: Da xet', 0
    help_l2 db 'S: Bat dau   E: Dich', 0
    help_l3 db 'AI dung DFS de tim duong tu S den E.', 0
    help_l4 db 'Bam phim bat ky de quay lai menu.', 0
    file_title db 'CHON FILE ME CUNG', 0
    file_opt1 db '1) Dung maze.txt', 0
    file_opt2 db '2) Nhap ten file khac', 0
    file_opt3 db '3) Quay lai menu', 0
    file_ask db 'Nhap ten file: ', 0
    info_title db 'THONG TIN NHOM / DU AN', 0
    info_l1 db 'Du an : ASM Maze Solver - NASM Win32', 0
    info_l2 db 'Mo ta : AI tu dong giai me cung bang DFS', 0
    info_l3 db 'Ngon ngu: Assembly NASM 32-bit, Windows', 0
    info_l4 db 'Moi truong: NASM >= 2.15 + GCC -m32 (MinGW)', 0
    info_l5 db 'SV1: UI - Console render, color, cursor', 0
    info_l6 db 'SV2: IO - Doc file, phat hien kich thuoc', 0
    info_l7 db 'SV3: Core - DFS solver, sinh me cung', 0
    info_l8 db 'Bam phim bat ky de quay lai menu.', 0
    result_title db 'KET QUA', 0
    result_found db 'DA TIM THAY DUONG DI DEN DICH', 0
    result_notfound db 'KHONG TIM THAY DUONG DI', 0
    result_steps db 'So buoc DFS: ', 0
    result_cells db 'So o da xet: ', 0
    result_m1 db '1) Giai me cung khac', 0
    result_m2 db '2) Quay lai menu', 0
    result_m3 db '3) Thoat', 0
    err_1 db 'Khong tim thay file me cung.', 0
    err_2 db 'File me cung rong.', 0
    err_3 db 'File me cung sai dinh dang.', 0
    err_4 db 'Khong tim thay diem bat dau S.', 0
    err_5 db 'Khong tim thay diem ket thuc E.', 0
    err_6 db 'Me cung vuot qua kich thuoc cho phep.', 0
    err_7 db 'Cau truc me cung khong hop le (cac dong khong deu).', 0
    err_back db 'Bam phim bat ky de quay lai menu.', 0
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
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, menu_title
    call UI_PrintZ
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_sep
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 2
    call UI_GotoXY
    mov edx, menu_opt1
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, menu_opt2
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, menu_opt3
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 5
    call UI_GotoXY
    mov edx, menu_opt4
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 6
    call UI_GotoXY
    mov edx, menu_opt5
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 7
    call UI_GotoXY
    mov edx, menu_opt6
    call UI_PrintZ

    mov word [coord_x], 0
    mov word [coord_y], 9
    call UI_GotoXY
    mov edx, menu_prompt
    call UI_PrintZ

menu_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je menu_read_key
    cmp al, 10
    je menu_read_key
    cmp al, '1'
    je mode_file
    cmp al, '2'
    je show_help
    cmp al, '3'
    je choose_file
    cmp al, '4'
    je show_info
    cmp al, '5'
    je exit
    cmp al, '6'
    je gen_menu
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, menu_invalid
    call UI_PrintZ
    call UI_WaitKey
    jmp menu_loop

show_help:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, help_title
    call UI_PrintZ
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_sep
    call UI_PrintZ
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, help_l1
    call UI_PrintZ
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, help_l2
    call UI_PrintZ
    mov word [coord_y], 5
    call UI_GotoXY
    mov edx, help_l3
    call UI_PrintZ
    mov word [coord_y], 7
    call UI_GotoXY
    mov edx, help_l4
    call UI_PrintZ
    call MAIN_WaitKey
    jmp menu_loop

show_info:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, info_title
    call UI_PrintZ
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_sep
    call UI_PrintZ
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, info_l1
    call UI_PrintZ
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, info_l2
    call UI_PrintZ
    mov word [coord_y], 5
    call UI_GotoXY
    mov edx, info_l3
    call UI_PrintZ
    mov word [coord_y], 6
    call UI_GotoXY
    mov edx, info_l4
    call UI_PrintZ
    mov word [coord_y], 8
    call UI_GotoXY
    mov edx, info_l5
    call UI_PrintZ
    mov word [coord_y], 9
    call UI_GotoXY
    mov edx, info_l6
    call UI_PrintZ
    mov word [coord_y], 10
    call UI_GotoXY
    mov edx, info_l7
    call UI_PrintZ
    mov word [coord_y], 12
    call UI_GotoXY
    mov edx, info_l8
    call UI_PrintZ
    call MAIN_WaitKey
    jmp menu_loop

choose_file:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, file_title
    call UI_PrintZ
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_sep
    call UI_PrintZ
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, file_opt1
    call UI_PrintZ
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, file_opt2
    call UI_PrintZ
    mov word [coord_y], 5
    call UI_GotoXY
    mov edx, file_opt3
    call UI_PrintZ
    mov word [coord_y], 7
    call UI_GotoXY
    mov edx, menu_prompt
    call UI_PrintZ

file_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je file_read_key
    cmp al, 10
    je file_read_key
    cmp al, '1'
    je file_default
    cmp al, '2'
    je file_input
    cmp al, '3'
    je menu_loop
    jmp file_read_key

file_default:
    call MAIN_SetDefaultMazeFile
    jmp mode_file

file_input:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, file_ask
    call UI_PrintZ
    call MAIN_FlushInput    ; discard leftover CR/LF from previous keypress
    mov edx, input_name_buf
    mov ecx, 63
    call MAIN_ReadLine
    mov esi, input_name_buf
    mov edi, maze_file
    mov ecx, 64
    call MAIN_StrCopyZ
    jmp mode_file

gen_menu:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, gen_title
    call UI_PrintZ
    mov word [coord_y], 1
    call UI_GotoXY
    mov edx, menu_sep
    call UI_PrintZ
    mov word [coord_y], 3
    call UI_GotoXY
    mov edx, gen_opt1
    call UI_PrintZ
    mov word [coord_y], 4
    call UI_GotoXY
    mov edx, gen_opt2
    call UI_PrintZ
    mov word [coord_y], 5
    call UI_GotoXY
    mov edx, gen_opt3
    call UI_PrintZ
    mov word [coord_y], 6
    call UI_GotoXY
    mov edx, gen_optb
    call UI_PrintZ

gen_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je gen_read_key
    cmp al, 10
    je gen_read_key
    cmp al, '1'
    je mode_easy
    cmp al, '2'
    je mode_medium
    cmp al, '3'
    je mode_hard
    cmp al, 'B'
    je menu_loop
    cmp al, 'b'
    je menu_loop
    jmp gen_read_key

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
    jmp after_gen

load_file:
    call FILE_ReadMaze
    cmp eax, 0
    je show_error

after_load:
    call MAIN_ValidateMaze
    cmp eax, 0
    je show_error
    mov eax, [startX]
    mov [currX], eax
    mov eax, [startY]
    mov [currY], eax
    jmp after_draw

after_gen:
    ; generator guarantees S/E placement — skip file validate, use FindStart
    call MAIN_FindStart
    cmp eax, 0
    je show_error

after_draw:

    call MAIN_DrawFullMaze
    call MAIN_PrintLegend

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
    jmp show_result

show_error:
    call UI_ClearScreen
    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov eax, [errorCode]
    cmp eax, 1
    je show_err_1
    cmp eax, 2
    je show_err_2
    cmp eax, 3
    je show_err_3
    cmp eax, 4
    je show_err_4
    cmp eax, 5
    je show_err_5
    cmp eax, 6
    je show_err_6
    cmp eax, 7
    je show_err_7
    mov edx, err_3
    jmp show_err_print
show_err_1:
    mov edx, err_1
    jmp show_err_print
show_err_2:
    mov edx, err_2
    jmp show_err_print
show_err_3:
    mov edx, err_3
    jmp show_err_print
show_err_4:
    mov edx, err_4
    jmp show_err_print
show_err_5:
    mov edx, err_5
    jmp show_err_print
show_err_6:
    mov edx, err_6
    jmp show_err_print
show_err_7:
    mov edx, err_7
show_err_print:
    call UI_PrintZ
    mov word [coord_x], 0
    mov word [coord_y], 2
    call UI_GotoXY
    mov edx, err_back
    call UI_PrintZ
    call UI_WaitKey
    jmp menu_loop

show_result:
    mov eax, [rows]
    add eax, 2
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_ClearLine
    call UI_GotoXY
    mov edx, result_title
    call UI_PrintZ

    mov eax, [rows]
    add eax, 3
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_ClearLine
    call UI_GotoXY
    cmp byte [dfs_result], 1
    je show_result_found
    mov eax, 12
    call UI_SetColor
    mov edx, result_notfound
    call UI_PrintZ
    call UI_ResetColor
    jmp show_result_stats
show_result_found:
    mov eax, 10
    call UI_SetColor
    mov edx, result_found
    call UI_PrintZ
    call UI_ResetColor

show_result_stats:
    mov eax, [rows]
    add eax, 5
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_ClearLine
    call UI_GotoXY
    mov edx, result_steps
    call UI_PrintZ
    mov eax, [dfs_steps]
    call UI_PrintDec4

    mov eax, [rows]
    add eax, 6
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_ClearLine
    call UI_GotoXY
    mov edx, result_cells
    call UI_PrintZ
    mov eax, [cells_examined]
    call UI_PrintDec4

    mov eax, [rows]
    add eax, 8
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_GotoXY
    mov edx, result_m1
    call UI_PrintZ
    mov eax, [rows]
    add eax, 9
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_GotoXY
    mov edx, result_m2
    call UI_PrintZ
    mov eax, [rows]
    add eax, 10
    mov [coord_y], ax
    mov word [coord_x], 0
    call UI_GotoXY
    mov edx, result_m3
    call UI_PrintZ

result_read_key:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je result_read_key
    cmp al, 10
    je result_read_key
    cmp al, '1'
    je choose_file
    cmp al, '2'
    je menu_loop
    cmp al, '3'
    je exit
    jmp result_read_key

exit:
    mov word [coord_x], 0
    mov eax, [rows]
    add eax, 16
    mov [coord_y], ax
    call UI_GotoXY
    push 0
    call _ExitProcess@4

MAIN_ReadLine:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push esi
    push edi

    push 0
    push bytes_read
    push ecx
    push edx
    push dword [hInput]
    call _ReadConsoleA@20

    mov esi, edx
    mov ebx, [bytes_read]
    xor edi, edi

MAIN_ReadLineScan:
    cmp edi, ebx
    jae MAIN_ReadLineDone
    mov al, [esi+edi]
    cmp al, 13
    je MAIN_ReadLineTerm
    cmp al, 10
    je MAIN_ReadLineTerm
    cmp al, 0
    je MAIN_ReadLineDone
    inc edi
    jmp MAIN_ReadLineScan

MAIN_ReadLineTerm:
    mov byte [esi+edi], 0

MAIN_ReadLineDone:
    pop edi
    pop esi
    pop ebx
    pop eax
    leave
    ret

MAIN_StrCopyZ:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    xor ebx, ebx

MAIN_StrCopyLoop:
    cmp ebx, ecx
    jae MAIN_StrCopyEnd
    mov al, [esi+ebx]
    mov [edi+ebx], al
    cmp al, 0
    je MAIN_StrCopyDone
    inc ebx
    jmp MAIN_StrCopyLoop

MAIN_StrCopyEnd:
    mov byte [edi+ecx-1], 0

MAIN_StrCopyDone:
    pop ebx
    pop eax
    leave
    ret

MAIN_SetDefaultMazeFile:
    push ebp
    mov ebp, esp
    push eax
    mov byte [maze_file+0], 'm'
    mov byte [maze_file+1], 'a'
    mov byte [maze_file+2], 'z'
    mov byte [maze_file+3], 'e'
    mov byte [maze_file+4], '.'
    mov byte [maze_file+5], 't'
    mov byte [maze_file+6], 'x'
    mov byte [maze_file+7], 't'
    mov byte [maze_file+8], 0
    pop eax
    leave
    ret

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

; Flush console input buffer (discard all pending keystrokes including CR/LF)
; Use before MAIN_ReadLine to prevent stale input
MAIN_FlushInput:
    push ebp
    mov ebp, esp
    push dword [hInput]
    call _FlushConsoleInputBuffer@4
    leave
    ret

; Wait for a real keypress, discarding any leading CR/LF first
; Replaces UI_WaitKey in screens that follow menu navigation
MAIN_WaitKey:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
MAIN_WaitKeyLoop:
    push 0
    push bytes_read
    push 1
    push buffer
    push dword [hInput]
    call _ReadConsoleA@20
    mov al, [buffer]
    cmp al, 13
    je MAIN_WaitKeyLoop
    cmp al, 10
    je MAIN_WaitKeyLoop
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

%include "UI/ui.asm"
%include "IO/file.asm"
%include "core/core.asm"

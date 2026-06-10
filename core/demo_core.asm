; SV3 - Core demo (Win32 NASM)

extern _GetStdHandle@4
extern _ExitProcess@4
extern _WriteConsoleA@20
extern _ReadConsoleA@20
extern _SetConsoleCursorPosition@8
extern _GetConsoleScreenBufferInfo@8
extern _FillConsoleOutputCharacterA@20
extern _FillConsoleOutputAttribute@20
extern _Sleep@4

section .data
    cols dd 10
    rows dd 10
    stack_cap dd 100
    ui_delay_ms dd 80
    rand_state dd 1

    maze db \
        '1','1','1','1','1','1','1','1','1','1',\
        '1','S','0','0','0','0','0','0','0','1',\
        '1','1','1','1','1','1','1','1','0','1',\
        '1','0','0','0','0','0','0','1','0','1',\
        '1','0','1','1','1','1','0','1','0','1',\
        '1','0','1','0','0','0','0','1','0','1',\
        '1','0','1','0','1','1','1','1','0','1',\
        '1','0','1','0','0','0','0','0','0','1',\
        '1','0','1','1','1','1','1','1','E','1',\
        '1','1','1','1','1','1','1','1','1','1'

    currX dd 0
    currY dd 0
    stack_x times 100 db 0
    stack_y times 100 db 0
    stack_top dd 0
    maze_work times 400 db 0

    msg_title db 'Core demo: DFS on hardcoded maze. Press any key...', 0

    hConsole dd 0
    hInput dd 0
    bytes_written dd 0
    buffer db 0
    coord_x dw 0
    coord_y dw 0

section .bss
    bytes_read resd 1

section .text
global _main

_main:
    push -11
    call _GetStdHandle@4
    mov [hConsole], eax

    push -10
    call _GetStdHandle@4
    mov [hInput], eax

    call UI_ClearScreen

    call MAIN_FindStart
    call MAIN_DrawFullMaze
    call DFS_Solve

    mov word [coord_x], 0
    mov eax, [rows]
    add eax, 2
    mov [coord_y], ax
    call UI_GotoXY
    mov edx, msg_title
    call UI_PrintZ

    call UI_WaitKey
    push 0
    call _ExitProcess@4

%include "..\UI\ui.asm"
%include "core.asm"

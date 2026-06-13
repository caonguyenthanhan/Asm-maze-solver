; SV1 - UI demo (Win32 NASM)

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
    msg_title db 'UI demo: press any key...', 0
    hConsole dd 0
    hInput dd 0
    bytes_written dd 0
    buffer db 0
    ui_delay_ms dd 80
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

    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY
    mov edx, msg_title
    call UI_PrintZ

    mov word [coord_x], 5
    mov word [coord_y], 2
    mov al, '#'
    call UI_DrawChar

    mov word [coord_x], 6
    mov word [coord_y], 2
    mov al, 'S'
    call UI_DrawChar

    call UI_WaitKey
    push 0
    call _ExitProcess@4

%include "ui.asm"

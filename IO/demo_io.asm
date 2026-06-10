; SV2 - File I/O demo (Win32 NASM)

extern _GetStdHandle@4
extern _ExitProcess@4
extern _WriteConsoleA@20
extern _CreateFileA@28
extern _ReadFile@20
extern _CloseHandle@4
extern _GetFileSize@8

section .data
    hConsole dd 0
    bytes_written dd 0

    maze_file db '..\maze.txt', 0
    msg_ok db 'IO demo: read maze.txt OK', 13, 10, 0
    msg_err db 'IO demo: cannot read maze.txt', 13, 10, 0

    maze times 400 db 0

section .bss
    file_size resd 1
    file_handle resd 1
    bytes_read resd 1

section .text
global _main

_main:
    push -11
    call _GetStdHandle@4
    mov [hConsole], eax

    call FILE_ReadMaze
    cmp eax, 1
    jne io_err

    mov edx, msg_ok
    call PrintZ
    jmp io_exit

io_err:
    mov edx, msg_err
    call PrintZ

io_exit:
    push 0
    call _ExitProcess@4

PrintZ:
    push ebp
    mov ebp, esp
    push eax
    push ecx
    push edi

    mov edi, edx
    xor ecx, ecx
PrintZ_Len:
    cmp byte [edi+ecx], 0
    je PrintZ_Do
    inc ecx
    jmp PrintZ_Len
PrintZ_Do:
    push 0
    push bytes_written
    push ecx
    push edx
    push dword [hConsole]
    call _WriteConsoleA@20

    pop edi
    pop ecx
    pop eax
    leave
    ret

%include "file.asm"

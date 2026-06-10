; SV2 - File I/O module (Win32 NASM)
; Public procedures:
;   FILE_ReadMaze
;
; Contract:
;   - Input: maze_file (ASCIIZ) points to file name (default: maze.txt)
;   - Output: maze buffer contains file content with CR/LF removed
;   - Returns: EAX=1 success, EAX=0 error

section .text

; Read maze.txt into memory and normalize the buffer.
FILE_ReadMaze:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx

    push 0
    push 0x00000080
    push 3
    push 0
    push 1
    push 0x80000000
    push maze_file
    call _CreateFileA@28
    cmp eax, -1
    je FILE_Error
    mov [file_handle], eax

    push 0
    push dword [file_handle]
    call _GetFileSize@8
    mov [file_size], eax

    push 0
    push bytes_read
    push dword [file_size]
    push maze
    push dword [file_handle]
    call _ReadFile@20

    push dword [file_handle]
    call _CloseHandle@4

    mov esi, maze
    mov edi, maze
    mov ecx, [file_size]

    cmp ecx, 3
    jb FILE_ProcessChar
    cmp byte [esi], 0xEF
    jne FILE_CheckUtf16
    cmp byte [esi+1], 0xBB
    jne FILE_CheckUtf16
    cmp byte [esi+2], 0xBF
    jne FILE_CheckUtf16
    add esi, 3
    sub ecx, 3
    jmp FILE_ProcessChar

FILE_CheckUtf16:
    cmp ecx, 2
    jb FILE_ProcessChar
    mov ax, [esi]
    cmp ax, 0xFEFF
    jne FILE_ProcessChar
    add esi, 2
    sub ecx, 2

FILE_ProcessChar:
    cmp ecx, 0
    je FILE_DoneProcess
    mov al, [esi]
    inc esi
    dec ecx
    cmp al, 0
    je FILE_ProcessChar
    cmp al, 13
    je FILE_ProcessChar
    cmp al, 10
    je FILE_ProcessChar
    mov [edi], al
    inc edi
    jmp FILE_ProcessChar

FILE_DoneProcess:
    mov eax, 1
    jmp FILE_Done

FILE_Error:
    mov eax, 0

FILE_Done:
    pop edx
    pop ecx
    pop ebx
    leave
    ret

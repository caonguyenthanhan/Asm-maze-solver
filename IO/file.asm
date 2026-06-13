; SV2 - File I/O module (Win32 NASM)
; Public procedures:
;   FILE_ReadMaze
;
; Contract:
;   - Input:  maze_file (ASCIIZ) -> file name (default: maze.txt)
;   - Output: maze buffer filled, [cols] and [rows] auto-detected from file
;   - Returns: EAX=1 success, EAX=0 error

section .text

FILE_ReadMaze:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx

    ; Open file (GENERIC_READ, OPEN_EXISTING)
    push 0
    push 0x00000080
    push 3
    push 0
    push 1
    push 0x80000000
    push maze_file
    call _CreateFileA@28
    cmp eax, -1
    je FILE_NoFile
    mov [file_handle], eax

    push 0
    push dword [file_handle]
    call _GetFileSize@8
    mov [file_size], eax
    test eax, eax
    jnz FILE_SizeOk
    mov dword [errorCode], 2
    push dword [file_handle]
    call _CloseHandle@4
    jmp FILE_ErrorReturn
FILE_SizeOk:

    push 0
    push bytes_read
    push dword [file_size]
    push maze
    push dword [file_handle]
    call _ReadFile@20

    push dword [file_handle]
    call _CloseHandle@4

    mov esi, maze
    mov ecx, [file_size]

    ; Strip UTF-8 BOM (EF BB BF) if present
    cmp ecx, 3
    jb FILE_CheckUtf16
    cmp byte [esi], 0xEF
    jne FILE_CheckUtf16
    cmp byte [esi+1], 0xBB
    jne FILE_CheckUtf16
    cmp byte [esi+2], 0xBF
    jne FILE_CheckUtf16
    add esi, 3
    sub ecx, 3
    jmp FILE_Measure

FILE_CheckUtf16:
    cmp ecx, 2
    jb FILE_Measure
    mov ax, [esi]
    cmp ax, 0xFEFF
    jne FILE_Measure
    add esi, 2
    sub ecx, 2

FILE_Measure:
    ; --- Pass 1: count cols = chars in first non-empty line ---
    push esi
    push ecx

FILE_SkipLeadCols:
    cmp ecx, 0
    je FILE_ColsZero
    mov al, [esi]
    cmp al, 0x0D
    je FILE_SkipLeadColsAdv
    cmp al, 0x0A
    je FILE_SkipLeadColsAdv
    jmp FILE_ColsCount
FILE_SkipLeadColsAdv:
    inc esi
    dec ecx
    jmp FILE_SkipLeadCols

FILE_ColsCount:
    xor ebx, ebx
FILE_ColsChar:
    cmp ecx, 0
    je FILE_SetCols
    mov al, [esi]
    cmp al, 0x0D
    je FILE_SetCols
    cmp al, 0x0A
    je FILE_SetCols
    cmp al, 0
    je FILE_SetCols
    inc esi
    dec ecx
    inc ebx
    jmp FILE_ColsChar

FILE_ColsZero:
    xor ebx, ebx
FILE_SetCols:
    mov [cols], ebx
    pop ecx
    pop esi

    ; --- Pass 2: count rows = number of non-empty lines ---
    push esi
    push ecx
    xor ebx, ebx          ; row counter
    xor edx, edx          ; chars in current line

FILE_RowLoop:
    cmp ecx, 0
    je FILE_RowFlush
    mov al, [esi]
    inc esi
    dec ecx
    cmp al, 0x0D
    je FILE_RowLoop        ; skip CR
    cmp al, 0
    je FILE_RowLoop        ; skip nulls
    cmp al, 0x0A
    jne FILE_RowChar
    cmp edx, 0             ; empty line - skip
    je FILE_RowLoop
    cmp edx, [cols]
    jne FILE_Ragged
    inc ebx                ; completed non-empty row
    xor edx, edx
    jmp FILE_RowLoop
FILE_RowChar:
    inc edx
    jmp FILE_RowLoop
FILE_RowFlush:
    cmp edx, 0
    je FILE_SetRows
    cmp edx, [cols]
    jne FILE_Ragged
    inc ebx                ; last line with no trailing newline
FILE_SetRows:
    mov [rows], ebx
    pop ecx
    pop esi

    ; --- Pass 3: strip CR/LF/null and pack maze buffer in-place ---
    ; edi starts at maze[0], esi at maze[bom_offset]
    ; edi <= esi always, so in-place overwrite is safe
    mov edi, maze
FILE_PackLoop:
    cmp ecx, 0
    je FILE_PackDone
    mov al, [esi]
    inc esi
    dec ecx
    cmp al, 0
    je FILE_PackLoop
    cmp al, 0x0D
    je FILE_PackLoop
    cmp al, 0x0A
    je FILE_PackLoop
    mov [edi], al
    inc edi
    jmp FILE_PackLoop

FILE_PackDone:
    mov dword [errorCode], 0
    mov eax, 1
    jmp FILE_Done

FILE_Ragged:
    mov dword [errorCode], 7
    jmp FILE_ErrorReturn

FILE_NoFile:
    mov dword [errorCode], 1
    jmp FILE_ErrorReturn

FILE_Error:
    mov eax, 0
    jmp FILE_Done

FILE_ErrorReturn:
    mov eax, 0
    jmp FILE_Done

FILE_Done:
    pop edx
    pop ecx
    pop ebx
    leave
    ret

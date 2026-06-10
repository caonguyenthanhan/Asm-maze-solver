; SV1 - UI module (Win32 NASM)
; Public procedures:
;   UI_ClearScreen
;   UI_GotoXY        (uses coord_x, coord_y)
;   UI_DrawChar      (AL = char, uses coord_x, coord_y)
;   UI_DrawCell      (AL = char, animated via Sleep)
;   UI_PrintZ        (EDX -> zero-terminated string)
;   UI_WaitKey

section .text

; Clear the entire console screen and reset cursor to (0,0).
UI_ClearScreen:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 22

    lea eax, [ebp-22]
    push eax
    push dword [hConsole]
    call _GetConsoleScreenBufferInfo@8

    movzx eax, word [ebp-22]
    movzx edx, word [ebp-20]
    imul eax, edx
    push bytes_written
    push 0
    push eax
    push dword 32
    push dword [hConsole]
    call _FillConsoleOutputCharacterA@20

    movzx eax, word [ebp-14]
    movzx edx, word [ebp-22]
    movzx ecx, word [ebp-20]
    imul edx, ecx
    push bytes_written
    push 0
    push edx
    push eax
    push dword [hConsole]
    call _FillConsoleOutputAttribute@20

    mov word [coord_x], 0
    mov word [coord_y], 0
    call UI_GotoXY

    add esp, 22
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

UI_ClearLine:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 22
    lea eax, [ebp-22]
    push eax
    push dword [hConsole]
    call _GetConsoleScreenBufferInfo@8
    movzx ecx, word [ebp-22]
    movzx eax, word [coord_y]
    shl eax, 16
    push bytes_written
    push eax
    push ecx
    push dword 32
    push dword [hConsole]
    call _FillConsoleOutputCharacterA@20
    movzx eax, word [ui_attr_default]
    movzx edx, word [coord_y]
    shl edx, 16
    push bytes_written
    push edx
    push ecx
    push eax
    push dword [hConsole]
    call _FillConsoleOutputAttribute@20
    add esp, 22
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_GotoXY:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    movzx eax, word [coord_y]
    shl eax, 16
    mov ax, [coord_x]
    push eax
    push dword [hConsole]
    call _SetConsoleCursorPosition@8

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

UI_DrawChar:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov byte [buffer], al
    call UI_GotoXY

    push 0
    push bytes_written
    push 1
    push buffer
    push dword [hConsole]
    call _WriteConsoleA@20

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_DrawCell:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    call UI_DrawChar
    push dword [ui_delay_ms]
    call _Sleep@4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; Print a zero-terminated ASCII string at the current cursor position.
UI_PrintZ:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edi
    push esi
    push edx

    mov edi, edx
    xor ecx, ecx
UI_PrintZ_Len:
    cmp byte [edi+ecx], 0
    je UI_PrintZ_Do
    inc ecx
    jmp UI_PrintZ_Len
UI_PrintZ_Do:
    push 0
    push bytes_written
    push ecx
    push edx
    push dword [hConsole]
    call _WriteConsoleA@20

    pop edx
    pop esi
    pop edi
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_WaitKey:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push 0
    push bytes_read
    push 1
    push buffer
    push dword [hInput]
    call _ReadConsoleA@20
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_SetColor:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov ebx, [ebp-4]
    push ebx
    push dword [hConsole]
    call _SetConsoleTextAttribute@8
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_ResetColor:
    push ebp
    mov ebp, esp
    push eax
    movzx eax, word [ui_attr_default]
    call UI_SetColor
    pop eax
    leave
    ret

UI_PrintDec2:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    add dl, '0'
    mov byte [num_buf], al
    mov byte [num_buf+1], dl
    push 0
    push bytes_written
    push 2
    push num_buf
    push dword [hConsole]
    call _WriteConsoleA@20
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

UI_PrintDec4:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov ebx, 10
    mov ecx, 4
    lea edi, [num_buf+3]
UI_PrintDec4_Loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    dec ecx
    jnz UI_PrintDec4_Loop
    push 0
    push bytes_written
    push 4
    push num_buf
    push dword [hConsole]
    call _WriteConsoleA@20
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

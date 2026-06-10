; SV3 - Core + DFS module (Win32 NASM)
; Public procedures:
;   MAIN_FindStart
;   MAIN_DrawFullMaze
;   MAIN_GetIndex
;   MAIN_IsValid
;   DFS_Push / DFS_Pop
;   DFS_Solve
;
; Data layout assumptions:
;   - maze is a 1D array storing cols*rows characters
;   - stack_x/stack_y are software stacks to avoid using hardware stack for DFS state

section .text

; Locate the starting cell 'S' in maze and set currX/currY.
MAIN_FindStart:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi

    mov esi, maze
    xor ecx, ecx

MAIN_FindRow:
    cmp ecx, [rows]
    jae MAIN_FindNotFound
    xor ebx, ebx

MAIN_FindCol:
    cmp ebx, [cols]
    jae MAIN_FindNextRow
    cmp byte [esi], 'S'
    je MAIN_FindFound
    inc esi
    inc ebx
    jmp MAIN_FindCol

MAIN_FindNextRow:
    inc ecx
    jmp MAIN_FindRow

MAIN_FindFound:
    mov [currX], ebx
    mov [currY], ecx
    mov eax, 1
    jmp MAIN_FindDone

MAIN_FindNotFound:
    mov eax, 0

MAIN_FindDone:
    pop esi
    pop ecx
    pop ebx
    leave
    ret

MAIN_DrawFullMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, maze
    xor ecx, ecx

MAIN_DrawRow:
    cmp ecx, [rows]
    jae MAIN_DrawDone
    xor ebx, ebx

MAIN_DrawCol:
    cmp ebx, [cols]
    jae MAIN_DrawNextRow

    mov [coord_x], bx
    mov [coord_y], cx
    mov al, [esi]
    cmp al, '1'
    jne MAIN_DrawMapZero
    mov al, '#'
    jmp MAIN_DrawCell
MAIN_DrawMapZero:
    cmp al, '0'
    jne MAIN_DrawCell
    mov al, '.'
MAIN_DrawCell:
    mov dl, al
    movzx eax, word [ui_attr_default]
    cmp dl, '#'
    jne MAIN_DrawAttr_NotWall
    mov eax, 8
    jmp MAIN_DrawAttr_Set
MAIN_DrawAttr_NotWall:
    cmp dl, 'S'
    jne MAIN_DrawAttr_NotStart
    mov eax, 10
    jmp MAIN_DrawAttr_Set
MAIN_DrawAttr_NotStart:
    cmp dl, 'E'
    jne MAIN_DrawAttr_Set
    mov eax, 12
MAIN_DrawAttr_Set:
    call UI_SetColor
    mov al, dl
    call UI_DrawChar
    call UI_ResetColor

    inc esi
    inc ebx
    jmp MAIN_DrawCol

MAIN_DrawNextRow:
    inc ecx
    jmp MAIN_DrawRow

MAIN_DrawDone:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

MAIN_GetIndex:
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax

    pop edx
    pop eax
    leave
    ret

MAIN_IsValid:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi

    test ebx, ebx
    js MAIN_Invalid
    cmp ebx, [cols]
    jae MAIN_Invalid

    test ecx, ecx
    js MAIN_Invalid
    cmp ecx, [rows]
    jae MAIN_Invalid

    call MAIN_GetIndex
    mov al, [esi]
    cmp al, '0'
    je MAIN_Valid
    cmp al, ' '
    je MAIN_Valid
    cmp al, 'E'
    je MAIN_Valid
    cmp al, 'S'
    je MAIN_Valid
    jmp MAIN_Invalid

MAIN_Valid:
    mov eax, 1
    jmp MAIN_IsValidDone

MAIN_Invalid:
    mov eax, 0

MAIN_IsValidDone:
    pop esi
    pop ecx
    pop ebx
    leave
    ret

DFS_Push:
    push ebp
    mov ebp, esp
    push esi

    mov esi, [stack_top]
    cmp esi, [stack_cap]
    jae DFS_PushDone
    mov byte [stack_x + esi], bl
    mov byte [stack_y + esi], cl
    inc dword [stack_top]

DFS_PushDone:
    pop esi
    leave
    ret

DFS_Pop:
    push ebp
    mov ebp, esp
    push esi

    dec dword [stack_top]
    mov esi, [stack_top]
    mov bl, byte [stack_x + esi]
    mov cl, byte [stack_y + esi]

    pop esi
    leave
    ret

DFS_Solve:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov dword [stack_top], 0
    mov ebx, [currX]
    mov ecx, [currY]
    call DFS_Push

DFS_Loop:
    cmp dword [stack_top], 0
    je DFS_End

    call DFS_Pop
    mov [currX], ebx
    mov [currY], ecx

    mov edx, ebx
    mov edi, ecx

    call MAIN_GetIndex
    mov al, [esi]
    cmp al, 'E'
    je DFS_Found
    cmp al, 'V'
    je DFS_Loop
    cmp al, '1'
    je DFS_Loop
    mov ah, al
    mov byte [esi], 'V'

DFS_Draw:
    inc dword [dfs_steps]
    call DFS_UpdateStatus
    mov [coord_x], bx
    mov [coord_y], cx
    mov al, [dfs_display_mode]
    cmp al, 0
    je DFS_DrawMinimal
    cmp al, 1
    je DFS_DrawNormal
    jmp DFS_DrawDense

DFS_DrawMinimal:
    mov al, ah
    cmp al, 'S'
    je DFS_DrawS_Min
    mov eax, 11
    call UI_SetColor
    mov al, '@'
    call UI_DrawCell
    call UI_ResetColor
    mov al, ah
    cmp al, ' '
    je DFS_MinRestoreSpace
    mov al, '.'
    call UI_DrawChar
    jmp DFS_AfterDraw
DFS_MinRestoreSpace:
    mov al, ' '
    call UI_DrawChar
    jmp DFS_AfterDraw
DFS_DrawS_Min:
    mov eax, 10
    call UI_SetColor
    mov al, 'S'
    call UI_DrawCell
    call UI_ResetColor
    jmp DFS_AfterDraw

DFS_DrawNormal:
    mov al, ah
    cmp al, 'S'
    je DFS_DrawS_Norm
    mov eax, 11
    call UI_SetColor
    mov al, '@'
    call UI_DrawCell
    call UI_ResetColor
    mov eax, [dfs_steps]
    and eax, 3
    jnz DFS_NormRestore
    mov eax, 14
    call UI_SetColor
    mov al, '*'
    call UI_DrawChar
    call UI_ResetColor
    jmp DFS_AfterDraw
DFS_NormRestore:
    mov al, ah
    cmp al, ' '
    je DFS_NormRestoreSpace
    mov al, '.'
    call UI_DrawChar
    jmp DFS_AfterDraw
DFS_NormRestoreSpace:
    mov al, ' '
    call UI_DrawChar
    jmp DFS_AfterDraw
DFS_DrawS_Norm:
    mov eax, 10
    call UI_SetColor
    mov al, 'S'
    call UI_DrawCell
    call UI_ResetColor
    jmp DFS_AfterDraw

DFS_DrawDense:
    mov al, ah
    cmp al, 'S'
    je DFS_DrawS_Dense
    mov eax, 11
    call UI_SetColor
    mov al, '@'
    call UI_DrawCell
    call UI_ResetColor
    mov eax, 14
    call UI_SetColor
    mov al, '*'
    call UI_DrawChar
    call UI_ResetColor
    jmp DFS_AfterDraw
DFS_DrawS_Dense:
    mov eax, 10
    call UI_SetColor
    mov al, 'S'
    call UI_DrawCell
    call UI_ResetColor
DFS_AfterDraw:

    mov ebx, edx
    inc ebx
    mov ecx, edi
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_TryDown
    call DFS_Push

DFS_TryDown:
    mov ebx, edx
    mov ecx, edi
    inc ecx
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_TryLeft
    call DFS_Push

DFS_TryLeft:
    mov ebx, edx
    dec ebx
    mov ecx, edi
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_TryUp
    call DFS_Push

DFS_TryUp:
    mov ebx, edx
    mov ecx, edi
    dec ecx
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_Loop
    call DFS_Push
    jmp DFS_Loop

DFS_Found:
    mov [coord_x], bx
    mov [coord_y], cx
    mov eax, 12
    call UI_SetColor
    mov al, 'E'
    call UI_DrawChar
    call UI_ResetColor
    mov dword [stack_top], 0

DFS_End:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

DFS_UpdateStatus:
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
    add eax, 3
    mov [coord_y], ax
    call UI_ClearLine
    call UI_GotoXY
    mov edx, status_step
    call UI_PrintZ
    mov eax, [dfs_steps]
    call UI_PrintDec4
    mov edx, status_x
    call UI_PrintZ
    mov eax, [currX]
    call UI_PrintDec2
    mov edx, status_y
    call UI_PrintZ
    mov eax, [currY]
    call UI_PrintDec2
    mov edx, status_pad
    call UI_PrintZ
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

MAIN_RandByte:
    push ebp
    mov ebp, esp
    push edx

    mov eax, [rand_state]
    imul eax, eax, 1103515245
    add eax, 12345
    mov [rand_state], eax
    shr eax, 16
    and eax, 0xFF

    pop edx
    leave
    ret

MAIN_GenerateRandomMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ebx, 10
    mov dl, 179
    cmp eax, 1
    je MAIN_GenSet
    mov ebx, 20
    mov dl, 141
    cmp eax, 2
    je MAIN_GenSet
    mov ebx, 30
    mov dl, 115

MAIN_GenSet:
    mov [cols], ebx
    mov [rows], ebx
    mov [gen_threshold], dl

    mov eax, [cols]
    sub eax, 2
    mov [gen_target_x], eax
    mov eax, [rows]
    sub eax, 2
    mov [gen_target_y], eax

    mov eax, [rows]
    mul dword [cols]
    mov ecx, eax
    mov edi, maze
    mov al, '1'
    cld
    rep stosb

    mov ebx, 1
    mov ecx, 1

MAIN_PathWrite:
    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    mov byte [esi], '0'

    cmp ebx, [gen_target_x]
    jne MAIN_PathCheckY
    cmp ecx, [gen_target_y]
    je MAIN_PathDone
    inc ecx
    jmp MAIN_PathWrite

MAIN_PathCheckY:
    cmp ecx, [gen_target_y]
    jne MAIN_PathRand
    inc ebx
    jmp MAIN_PathWrite

MAIN_PathRand:
    call MAIN_RandByte
    test al, 1
    jz MAIN_PathRight
    inc ecx
    jmp MAIN_PathWrite
MAIN_PathRight:
    inc ebx
    jmp MAIN_PathWrite

MAIN_PathDone:
    mov ecx, 1
MAIN_RandRow:
    mov eax, [rows]
    sub eax, 1
    cmp ecx, eax
    jae MAIN_Finalize
    mov ebx, 1
MAIN_RandCol:
    mov eax, [cols]
    sub eax, 1
    cmp ebx, eax
    jae MAIN_RandNextRow

    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    cmp byte [esi], '1'
    jne MAIN_RandSkip
    call MAIN_RandByte
    mov dl, [gen_threshold]
    cmp al, dl
    jb MAIN_RandOpen
    jmp MAIN_RandSkip
MAIN_RandOpen:
    mov byte [esi], '0'
MAIN_RandSkip:
    inc ebx
    jmp MAIN_RandCol

MAIN_RandNextRow:
    inc ecx
    jmp MAIN_RandRow

MAIN_Finalize:
    mov ebx, 1
    mov ecx, 1
    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    mov byte [esi], 'S'

    mov ebx, [cols]
    sub ebx, 2
    mov ecx, [rows]
    sub ecx, 2
    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    mov byte [esi], 'E'

    mov eax, 1

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

DFS_IsValidWork:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi

    test ebx, ebx
    js DFS_WorkInvalid
    cmp ebx, [cols]
    jae DFS_WorkInvalid
    test ecx, ecx
    js DFS_WorkInvalid
    cmp ecx, [rows]
    jae DFS_WorkInvalid

    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze_work
    add esi, eax

    mov al, [esi]
    cmp al, '0'
    je DFS_WorkValid
    cmp al, 'S'
    je DFS_WorkValid
    cmp al, 'E'
    je DFS_WorkValid
    jmp DFS_WorkInvalid

DFS_WorkValid:
    mov eax, 1
    jmp DFS_WorkDone

DFS_WorkInvalid:
    mov eax, 0

DFS_WorkDone:
    pop esi
    pop ecx
    pop ebx
    leave
    ret

DFS_CheckSolvable:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax, [rows]
    mul dword [cols]
    mov ecx, eax
    mov esi, maze
    mov edi, maze_work
    cld
    rep movsb

    mov dword [stack_top], 0
    mov ebx, 1
    mov ecx, 1
    call DFS_Push

DFS_CheckLoop:
    cmp dword [stack_top], 0
    je DFS_CheckFail

    call DFS_Pop

    mov edx, ebx
    mov edi, ecx

    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze_work
    add esi, eax
    mov al, [esi]
    cmp al, 'E'
    je DFS_CheckOk
    cmp al, 'V'
    je DFS_CheckLoop
    cmp al, '1'
    je DFS_CheckLoop
    mov byte [esi], 'V'

DFS_CheckNeighbors:
    mov ebx, edx
    inc ebx
    mov ecx, edi
    call DFS_IsValidWork
    cmp eax, 1
    jne DFS_CheckDown
    call DFS_Push

DFS_CheckDown:
    mov ebx, edx
    mov ecx, edi
    inc ecx
    call DFS_IsValidWork
    cmp eax, 1
    jne DFS_CheckLeft
    call DFS_Push

DFS_CheckLeft:
    mov ebx, edx
    dec ebx
    mov ecx, edi
    call DFS_IsValidWork
    cmp eax, 1
    jne DFS_CheckUp
    call DFS_Push

DFS_CheckUp:
    mov ebx, edx
    mov ecx, edi
    dec ecx
    call DFS_IsValidWork
    cmp eax, 1
    jne DFS_CheckLoop
    call DFS_Push
    jmp DFS_CheckLoop

DFS_CheckOk:
    mov eax, 1
    jmp DFS_CheckDone

DFS_CheckFail:
    mov eax, 0

DFS_CheckDone:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

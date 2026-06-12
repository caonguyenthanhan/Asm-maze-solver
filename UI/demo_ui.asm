; SV1 - Standalone UI demo (Win32 NASM)
; Uses sample data only. It does not read files or run DFS.

extern _GetStdHandle@4
extern _ExitProcess@4
extern _WriteConsoleA@20
extern _ReadConsoleA@20
extern _SetConsoleCursorPosition@8
extern _GetConsoleScreenBufferInfo@8
extern _FillConsoleOutputCharacterA@20
extern _FillConsoleOutputAttribute@20
extern _SetConsoleTextAttribute@8
extern _Sleep@4

section .data
    hConsole dd 0
    hInput dd 0
    bytes_written dd 0
    buffer db 0
    ui_delay_ms dd 80
    ui_attr_default dw 7
    demo_result_kind db 0
    demo_map_ptr dd demo_map_easy
    demo_map_cols dd 10
    demo_map_rows dd 10
    demo_curr_x dd 1
    demo_curr_y dd 1
    demo_steps dd 0
    demo_visited dd 0
    demo_backtracks dd 0
    coord_x dw 0
    coord_y dw 0
    num_buf times 16 db 0
    demo_info_position db '| Vi tri hien tai : (', 0
    demo_info_comma db ', ', 0
    demo_info_close db ')', 0
    demo_info_steps db '| So buoc da di    : ', 0
    demo_info_visited db '| So o da xet      : ', 0
    demo_info_backtrack db '| So lan quay lui  : ', 0

    ; Fixed-width sample maps used only to demonstrate responsive UI.
    demo_map_easy:
        times 10 db '#'
        db '#', 'S'
        times 6 db '.'
        db '.', '#'
        %rep 6
            db '#'
            times 8 db '.'
            db '#'
        %endrep
        db '#'
        times 7 db '.'
        db 'E', '#'
        times 10 db '#'

    demo_map_file:
        times 10 db '#'
        db '#', 'S', '.', '.', '.', '.', '.', '.', '.', '#'
        db '#', '.', '.', '#', '.', '#', '#', '#', '.', '#'
        db '#', '#', '.', '#', '.', '.', '.', '#', '.', '#'
        db '#', '.', '.', '.', '#', '#', '.', '#', '.', '#'
        db '#', '.', '#', '.', '.', '.', '.', '#', '.', '#'
        db '#', '.', '#', '#', '#', '.', '#', '#', '.', '#'
        db '#', '.', '.', '.', '.', '.', '.', '.', '.', '#'
        db '#', '.', '#', '#', '#', '#', '#', '.', 'E', '#'
        times 10 db '#'

    demo_map_medium:
        times 15 db '#'
        db '#', 'S'
        times 11 db '.'
        db '.', '#'
        %rep 5
            db '#'
            times 13 db '.'
            db '#'
        %endrep
        db '#'
        times 6 db '#'
        times 7 db '.'
        db '#'
        %rep 5
            db '#'
            times 13 db '.'
            db '#'
        %endrep
        db '#'
        times 12 db '.'
        db 'E', '#'
        times 15 db '#'

    demo_map_hard:
        times 20 db '#'
        db '#', 'S'
        times 16 db '.'
        db '.', '#'
        %rep 8
            db '#'
            times 18 db '.'
            db '#'
        %endrep
        db '#'
        times 9 db '#'
        times 9 db '.'
        db '#'
        %rep 7
            db '#'
            times 18 db '.'
            db '#'
        %endrep
        db '#'
        times 17 db '.'
        db 'E', '#'
        times 20 db '#'

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

UI_Demo_Main:
    call UI_ShowMainMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_Solve
    cmp al, '2'
    je UI_Demo_Help
    cmp al, '3'
    je UI_Demo_File
    cmp al, '4'
    je UI_Demo_Info
    cmp al, '5'
    je UI_Demo_Exit
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Main

UI_Demo_Help:
    call UI_ShowHelp
    call UI_ReadChoice
    jmp UI_Demo_Main

UI_Demo_File:
    call UI_ShowFileMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_Validation
    cmp al, '2'
    je UI_Demo_Filename
    cmp al, '3'
    je UI_Demo_Main
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_File

UI_Demo_Filename:
    call UI_ShowFilenamePrompt
    call UI_ReadChoice
    jmp UI_Demo_File

UI_Demo_Info:
    call UI_ShowProjectInfo
    call UI_ReadChoice
    jmp UI_Demo_Main

UI_Demo_Solve:
    call UI_ShowSourceMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_Difficulty
    cmp al, '2'
    je UI_Demo_SelectFileMap
    cmp al, '3'
    je UI_Demo_Main
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Solve

UI_Demo_Difficulty:
    call UI_ShowDifficultyMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_SelectEasy
    cmp al, '2'
    je UI_Demo_SelectMedium
    cmp al, '3'
    je UI_Demo_SelectHard
    cmp al, '4'
    je UI_Demo_Solve
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Difficulty

UI_Demo_SelectEasy:
    mov dword [demo_map_ptr], demo_map_easy
    mov dword [demo_map_cols], 10
    mov dword [demo_map_rows], 10
    jmp UI_Demo_Speed

UI_Demo_SelectMedium:
    mov dword [demo_map_ptr], demo_map_medium
    mov dword [demo_map_cols], 15
    mov dword [demo_map_rows], 15
    jmp UI_Demo_Speed

UI_Demo_SelectHard:
    mov dword [demo_map_ptr], demo_map_hard
    mov dword [demo_map_cols], 20
    mov dword [demo_map_rows], 20
    jmp UI_Demo_Speed

UI_Demo_SelectFileMap:
    mov dword [demo_map_ptr], demo_map_file
    mov dword [demo_map_cols], 10
    mov dword [demo_map_rows], 10
    jmp UI_Demo_Speed

UI_Demo_Speed:
    call UI_ShowSpeedMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_SpeedSlow
    cmp al, '2'
    je UI_Demo_SpeedNormal
    cmp al, '3'
    je UI_Demo_SpeedFast
    cmp al, '4'
    je UI_Demo_Solve
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Speed

UI_Demo_SpeedSlow:
    mov dword [ui_delay_ms], 150
    jmp UI_Demo_Display

UI_Demo_SpeedNormal:
    mov dword [ui_delay_ms], 80
    jmp UI_Demo_Display

UI_Demo_SpeedFast:
    mov dword [ui_delay_ms], 10
    jmp UI_Demo_Display

UI_Demo_Display:
    call UI_ShowDisplayMenu
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_StartValidation
    cmp al, '2'
    je UI_Demo_StartValidation
    cmp al, '3'
    je UI_Demo_StartValidation
    cmp al, '4'
    je UI_Demo_Speed
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Display

UI_Demo_StartValidation:
    call UI_ShowValidationSuccess
    call UI_ReadChoice

    call UI_Demo_ShowSolvingMap
    call UI_Demo_AnimateMaze
    call UI_ReadChoice

UI_Demo_Result:
    cmp byte [demo_result_kind], 0
    jne UI_Demo_ResultFailure
    call UI_Demo_ShowSuccessMap
    jmp UI_Demo_ResultChoice
UI_Demo_ResultFailure:
    call UI_Demo_ShowFailureMap
UI_Demo_ResultChoice:
    call UI_ReadChoice
    cmp al, '1'
    je UI_Demo_SolveAgain
    cmp al, '2'
    je UI_Demo_Main
    cmp al, '3'
    je UI_Demo_Exit
    call UI_ShowInvalidChoice
    call UI_ReadChoice
    jmp UI_Demo_Result

UI_Demo_SolveAgain:
    xor byte [demo_result_kind], 1
    jmp UI_Demo_Solve

UI_Demo_Validation:
    call UI_ShowValidationError
    call UI_ReadChoice
    jmp UI_Demo_File

UI_Demo_ShowSolvingMap:
    call UI_ShowSolvingHeader
    mov edx, [demo_map_ptr]
    mov eax, [demo_map_cols]
    mov ecx, [demo_map_rows]
    mov bx, 6
    call UI_DrawMaze
    mov eax, [demo_map_rows]
    add eax, 7
    mov bx, ax
    mov edx, ui_solve_footer_lines
    call UI_PrintLinesAt
    ret

UI_Demo_ShowSuccessMap:
    call UI_ShowResultSuccessHeader
    mov edx, [demo_map_ptr]
    mov eax, [demo_map_cols]
    mov ecx, [demo_map_rows]
    mov bx, 4
    call UI_DrawMaze
    mov eax, [demo_map_rows]
    add eax, 5
    mov bx, ax
    mov edx, ui_ok_footer_lines
    call UI_PrintLinesAt
    call UI_Demo_UpdateResultStats
    ret

UI_Demo_ShowFailureMap:
    call UI_ShowResultFailureHeader
    mov edx, [demo_map_ptr]
    mov eax, [demo_map_cols]
    mov ecx, [demo_map_rows]
    mov bx, 4
    call UI_DrawMaze
    mov eax, [demo_map_rows]
    add eax, 5
    mov bx, ax
    mov edx, ui_fail_footer_lines
    call UI_PrintLinesAt
    call UI_Demo_UpdateResultStats
    ret

; UI-only animation. It demonstrates movement but does not run DFS.
UI_Demo_AnimateMaze:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov dword [demo_curr_x], 1
    mov dword [demo_curr_y], 1
    mov dword [demo_steps], 0
    mov dword [demo_visited], 0
    mov dword [demo_backtracks], 0
    call UI_Demo_UpdateSolveInfo

    mov eax, 14
    call UI_SetColor

    mov ecx, 2
    mov ebx, [demo_map_cols]
    sub ebx, 2
UI_Demo_AnimateRight:
    cmp ecx, ebx
    ja UI_Demo_AnimateDownInit
    mov [coord_x], cx
    mov word [coord_y], 7
    mov al, '*'
    call UI_DrawCell
    mov [demo_curr_x], ecx
    mov dword [demo_curr_y], 1
    inc dword [demo_steps]
    inc dword [demo_visited]
    call UI_Demo_UpdateSolveInfo
    inc ecx
    jmp UI_Demo_AnimateRight

UI_Demo_AnimateDownInit:
    mov edx, 2
    mov esi, [demo_map_rows]
    sub esi, 2
UI_Demo_AnimateDown:
    cmp edx, esi
    ja UI_Demo_AnimateDone
    mov ecx, [demo_map_cols]
    sub ecx, 2
    mov [coord_x], cx
    mov ecx, edx
    add ecx, 6
    mov [coord_y], cx
    mov al, '*'
    call UI_DrawCell
    mov eax, [demo_map_cols]
    sub eax, 2
    mov [demo_curr_x], eax
    mov [demo_curr_y], edx
    inc dword [demo_steps]
    inc dword [demo_visited]
    call UI_Demo_UpdateSolveInfo
    inc edx
    jmp UI_Demo_AnimateDown

UI_Demo_AnimateDone:
    call UI_ResetColor
    mov eax, 12
    call UI_SetColor
    mov ecx, [demo_map_cols]
    sub ecx, 2
    mov [coord_x], cx
    mov ecx, [demo_map_rows]
    add ecx, 4
    mov [coord_y], cx
    mov al, 'E'
    call UI_DrawChar
    call UI_ResetColor
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Update the solving-screen information using the current demo state.
UI_Demo_UpdateSolveInfo:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, [demo_map_rows]
    add eax, 9
    mov bx, ax
    call UI_Demo_PrintPositionLine

    inc bx
    mov edx, demo_info_steps
    mov eax, [demo_steps]
    call UI_Demo_PrintMetricLine

    inc bx
    mov edx, demo_info_visited
    mov eax, [demo_visited]
    call UI_Demo_PrintMetricLine

    inc bx
    mov edx, demo_info_backtrack
    mov eax, [demo_backtracks]
    call UI_Demo_PrintMetricLine

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Update the result-screen statistics using the final demo state.
UI_Demo_UpdateResultStats:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, [demo_map_rows]
    add eax, 7
    mov bx, ax
    mov edx, demo_info_steps
    mov eax, [demo_steps]
    call UI_Demo_PrintMetricLine

    inc bx
    mov edx, demo_info_visited
    mov eax, [demo_visited]
    call UI_Demo_PrintMetricLine

    inc bx
    mov edx, demo_info_backtrack
    mov eax, [demo_backtracks]
    call UI_Demo_PrintMetricLine

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Input: BX = output row.
UI_Demo_PrintPositionLine:
    push eax
    push edx
    mov word [coord_x], 0
    mov [coord_y], bx
    call UI_ClearLine
    call UI_GotoXY
    mov edx, demo_info_position
    call UI_PrintZ
    mov eax, [demo_curr_x]
    call UI_PrintDec2
    mov edx, demo_info_comma
    call UI_PrintZ
    mov eax, [demo_curr_y]
    call UI_PrintDec2
    mov edx, demo_info_close
    call UI_PrintZ
    mov word [coord_x], 59
    mov [coord_y], bx
    mov al, '|'
    call UI_DrawChar
    pop edx
    pop eax
    ret

; Input: BX = output row, EDX = label, EAX = value.
UI_Demo_PrintMetricLine:
    push eax
    push edx
    mov word [coord_x], 0
    mov [coord_y], bx
    call UI_ClearLine
    call UI_GotoXY
    call UI_PrintZ
    pop edx
    pop eax
    call UI_PrintDec4
    mov word [coord_x], 59
    mov [coord_y], bx
    mov al, '|'
    call UI_DrawChar
    ret

UI_Demo_Exit:
    call UI_ShowExitScreen
    push 1000
    call _Sleep@4
    push 0
    call _ExitProcess@4

%include "ui.asm"

; SV1 - UI module (Win32 NASM)
;
; Low-level procedures:
;   UI_ClearScreen, UI_ClearLine, UI_GotoXY
;   UI_DrawChar, UI_DrawCell, UI_PrintZ
;   UI_PrintLinesAt, UI_DrawMaze
;   UI_WaitKey, UI_ReadChoice
;   UI_SetColor, UI_ResetColor
;   UI_PrintDec2, UI_PrintDec4
;
; High-level screens:
;   UI_ShowMainMenu, UI_ShowHelp
;   UI_ShowSourceMenu, UI_ShowDifficultyMenu
;   UI_ShowSpeedMenu, UI_ShowDisplayMenu
;   UI_ShowFileMenu, UI_ShowFilenamePrompt
;   UI_ShowValidationSuccess, UI_ShowValidationError
;   UI_ShowSolvingScreen
;   UI_ShowResultSuccess, UI_ShowResultFailure
;   UI_ShowProjectInfo, UI_ShowExitScreen
;   UI_ShowInvalidChoice

section .data
    ui_main_00 db '+==========================================================+', 0
    ui_main_01 db '|              ASM MAZE SOLVER - NASM WIN32                |', 0
    ui_main_02 db '+==========================================================+', 0
    ui_main_03 db '|  1. Bat dau giai me cung                                 |', 0
    ui_main_04 db '|  2. Xem huong dan                                        |', 0
    ui_main_05 db '|  3. Chon file me cung                                    |', 0
    ui_main_06 db '|  4. Thong tin nhom / du an                               |', 0
    ui_main_07 db '|  5. Thoat                                                |', 0
    ui_main_08 db '+==========================================================+', 0
    ui_main_09 db 'Nhap lua chon cua ban: ', 0
    ui_main_lines dd ui_main_00, ui_main_01, ui_main_02, ui_main_03
                  dd ui_main_04, ui_main_05, ui_main_06, ui_main_07
                  dd ui_main_08, ui_main_09, 0

    ui_help_00 db '+======================= HUONG DAN ========================+', 0
    ui_help_01 db '| Muc tieu: AI tu dong tim duong tu S den E bang DFS.      |', 0
    ui_help_02 db '|                                                          |', 0
    ui_help_03 db '| # : Tuong       S : Bat dau       E : Dich               |', 0
    ui_help_04 db '| * : Vi tri hien tai cua AI                               |', 0
    ui_help_05 db '| . : O da di qua          x : O bi quay lui               |', 0
    ui_help_06 db '|                                                          |', 0
    ui_help_07 db '| Chuong trinh delay tung buoc de hien thi qua trinh DFS.  |', 0
    ui_help_08 db '+==========================================================+', 0
    ui_help_09 db 'Bam phim bat ky de quay lai menu...', 0
    ui_help_lines dd ui_help_00, ui_help_01, ui_help_02, ui_help_03
                  dd ui_help_04, ui_help_05, ui_help_06, ui_help_07
                  dd ui_help_08, ui_help_09, 0

    ui_source_00 db '+==================== CHON NGUON ME CUNG ==================+', 0
    ui_source_01 db '|  1. Tao me cung ngau nhien                               |', 0
    ui_source_02 db '|  2. Su dung file maze.txt                                |', 0
    ui_source_03 db '|  3. Quay lai menu chinh                                  |', 0
    ui_source_04 db '+==========================================================+', 0
    ui_source_05 db 'Nhap lua chon cua ban: ', 0
    ui_source_lines dd ui_source_00, ui_source_01, ui_source_02
                    dd ui_source_03, ui_source_04, ui_source_05, 0

    ui_level_00 db '+==================== CHON DO KHO =========================+', 0
    ui_level_01 db '|  1. De        - Me cung ngau nhien 10x10                 |', 0
    ui_level_02 db '|  2. Thuong    - Me cung ngau nhien 15x15                 |', 0
    ui_level_03 db '|  3. Kho       - Me cung ngau nhien 20x20                 |', 0
    ui_level_04 db '|  4. Quay lai                                             |', 0
    ui_level_05 db '+==========================================================+', 0
    ui_level_06 db 'Nhap lua chon cua ban: ', 0
    ui_level_lines dd ui_level_00, ui_level_01, ui_level_02, ui_level_03
                   dd ui_level_04, ui_level_05, ui_level_06, 0

    ui_speed_00 db '+=================== CHON TOC DO GIAI =====================+', 0
    ui_speed_01 db '|  1. Cham       - Delay 150 ms                            |', 0
    ui_speed_02 db '|  2. Binh thuong - Delay 80 ms                            |', 0
    ui_speed_03 db '|  3. Nhanh      - Delay 10 ms                             |', 0
    ui_speed_04 db '|  4. Quay lai                                             |', 0
    ui_speed_05 db '+==========================================================+', 0
    ui_speed_06 db 'Nhap lua chon cua ban: ', 0
    ui_speed_lines dd ui_speed_00, ui_speed_01, ui_speed_02, ui_speed_03
                   dd ui_speed_04, ui_speed_05, ui_speed_06, 0

    ui_display_00 db '+================= CHON CHE DO HIEN THI ===================+', 0
    ui_display_01 db '|  1. Toi gian - Chi hien thi vi tri hien tai              |', 0
    ui_display_02 db '|  2. Binh thuong - Hien thi mot phan cac o da tham        |', 0
    ui_display_03 db '|  3. Day du - Hien thi tat ca cac o da tham               |', 0
    ui_display_04 db '|  4. Quay lai                                             |', 0
    ui_display_05 db '+==========================================================+', 0
    ui_display_06 db 'Nhap lua chon cua ban: ', 0
    ui_display_lines dd ui_display_00, ui_display_01, ui_display_02
                     dd ui_display_03, ui_display_04, ui_display_05
                     dd ui_display_06, 0

    ui_file_00 db '+==================== CHON FILE ME CUNG ===================+', 0
    ui_file_01 db '|  1. Su dung file mac dinh: maze.txt                      |', 0
    ui_file_02 db '|  2. Nhap ten file me cung khac                           |', 0
    ui_file_03 db '|  3. Quay lai menu chinh                                  |', 0
    ui_file_04 db '+==========================================================+', 0
    ui_file_05 db 'Nhap lua chon cua ban: ', 0
    ui_file_lines dd ui_file_00, ui_file_01, ui_file_02, ui_file_03
                  dd ui_file_04, ui_file_05, 0

    ui_name_00 db '+==================== CHON FILE ME CUNG ===================+', 0
    ui_name_01 db '| Vui long nhap ten file me cung can doc.                  |', 0
    ui_name_02 db '| Vi du: maze1.txt, maze2.txt, test_maze.txt               |', 0
    ui_name_03 db '+==========================================================+', 0
    ui_name_04 db 'Nhap ten file: ', 0
    ui_name_05 db '', 0
    ui_name_06 db 'UI demo khong doc file that. Bam phim de quay lai...', 0
    ui_name_lines dd ui_name_00, ui_name_01, ui_name_02, ui_name_03
                  dd ui_name_04, ui_name_05, ui_name_06, 0

    ui_valid_00 db '+================ KIEM TRA DU LIEU ME CUNG ================+', 0
    ui_valid_01 db '| Dang kiem tra file me cung...                            |', 0
    ui_valid_02 db '|                                                          |', 0
    ui_valid_03 db '| [OK] File me cung doc thanh cong                         |', 0
    ui_valid_04 db '| [OK] Ky tu trong file hop le                             |', 0
    ui_valid_05 db '| [OK] Tim thay diem bat dau S                             |', 0
    ui_valid_06 db '| [OK] Tim thay diem dich E                                |', 0
    ui_valid_07 db '| [OK] Kich thuoc me cung hop le                           |', 0
    ui_valid_08 db '+==========================================================+', 0
    ui_valid_09 db 'Du lieu hop le. Bam phim bat ky de xem man hinh giai...', 0
    ui_valid_lines dd ui_valid_00, ui_valid_01, ui_valid_02, ui_valid_03
                   dd ui_valid_04, ui_valid_05, ui_valid_06, ui_valid_07
                   dd ui_valid_08, ui_valid_09, 0

    ui_error_00 db '+================ KIEM TRA DU LIEU ME CUNG ================+', 0
    ui_error_01 db '| Dang kiem tra file me cung...                            |', 0
    ui_error_02 db '|                                                          |', 0
    ui_error_03 db '| [OK] File me cung doc thanh cong                         |', 0
    ui_error_04 db '| [ERROR] Khong tim thay diem dich E                       |', 0
    ui_error_05 db '|                                                          |', 0
    ui_error_06 db '| Du lieu khong hop le. Khong the bat dau DFS.             |', 0
    ui_error_07 db '+==========================================================+', 0
    ui_error_08 db 'Bam phim bat ky de quay lai menu...', 0
    ui_error_lines dd ui_error_00, ui_error_01, ui_error_02, ui_error_03
                   dd ui_error_04, ui_error_05, ui_error_06, ui_error_07
                   dd ui_error_08, 0

    ui_solve_00 db '+==================== DANG GIAI ME CUNG ===================+', 0
    ui_solve_01 db '| Thuat toan: DFS                                          |', 0
    ui_solve_02 db '| Trang thai : Dang tim duong                              |', 0
    ui_solve_03 db '| Toc do     : Binh thuong                                 |', 0
    ui_solve_04 db '+==========================================================+', 0
    ui_solve_05 db '', 0
    ui_solve_06 db '##########', 0
    ui_solve_07 db '#S...*...#', 0
    ui_solve_08 db '###.###..#', 0
    ui_solve_09 db '#.......E#', 0
    ui_solve_10 db '##########', 0
    ui_solve_11 db '', 0
    ui_solve_12 db '+======================== THONG TIN =======================+', 0
    ui_solve_13 db '| Vi tri hien tai : (5, 1)                                 |', 0
    ui_solve_14 db '| So buoc da di    : 25                                    |', 0
    ui_solve_15 db '| So o da xet      : 18                                    |', 0
    ui_solve_16 db '| So lan quay lui  : 3                                     |', 0
    ui_solve_17 db '+==========================================================+', 0
    ui_solve_18 db 'Dang hien thi qua trinh AI di tung buoc...', 0
    ui_solve_19 db 'Bam phim bat ky de xem ket qua...', 0
    ui_solve_lines dd ui_solve_00, ui_solve_01, ui_solve_02, ui_solve_03
                   dd ui_solve_04, ui_solve_05, ui_solve_06, ui_solve_07
                   dd ui_solve_08, ui_solve_09, ui_solve_10, ui_solve_11
                   dd ui_solve_12, ui_solve_13, ui_solve_14, ui_solve_15
                   dd ui_solve_16, ui_solve_17, ui_solve_18, ui_solve_19, 0
    ui_solve_header_lines dd ui_solve_00, ui_solve_01, ui_solve_02
                          dd ui_solve_03, ui_solve_04, ui_solve_05, 0
    ui_solve_footer_lines dd ui_solve_11, ui_solve_12, ui_solve_13
                          dd ui_solve_14, ui_solve_15, ui_solve_16
                          dd ui_solve_17, ui_solve_18, ui_solve_19, 0

    ui_ok_00 db '+=================== KET QUA GIAI ME CUNG =================+', 0
    ui_ok_01 db '| Trang thai: DA TIM THAY DUONG DI DEN DICH                |', 0
    ui_ok_02 db '+==========================================================+', 0
    ui_ok_03 db '', 0
    ui_ok_04 db '##########', 0
    ui_ok_05 db '#S***....#', 0
    ui_ok_06 db '###*###..#', 0
    ui_ok_07 db '#..*****E#', 0
    ui_ok_08 db '##########', 0
    ui_ok_09 db '', 0
    ui_ok_10 db '+========================= THONG KE =======================+', 0
    ui_ok_11 db '| So buoc DFS     : 42                                     |', 0
    ui_ok_12 db '| So o da xet     : 30                                     |', 0
    ui_ok_13 db '| So lan quay lui : 5                                      |', 0
    ui_ok_14 db '| Ket qua         : Thanh cong                             |', 0
    ui_ok_15 db '+==========================================================+', 0
    ui_ok_16 db '|  1. Giai me cung khac                                    |', 0
    ui_ok_17 db '|  2. Quay lai menu chinh                                  |', 0
    ui_ok_18 db '|  3. Thoat chuong trinh                                   |', 0
    ui_ok_19 db '+==========================================================+', 0
    ui_ok_20 db 'Nhap lua chon cua ban: ', 0
    ui_ok_lines dd ui_ok_00, ui_ok_01, ui_ok_02, ui_ok_03, ui_ok_04
                dd ui_ok_05, ui_ok_06, ui_ok_07, ui_ok_08, ui_ok_09
                dd ui_ok_10, ui_ok_11, ui_ok_12, ui_ok_13, ui_ok_14
                dd ui_ok_15, ui_ok_16, ui_ok_17, ui_ok_18, ui_ok_19
                dd ui_ok_20, 0
    ui_ok_header_lines dd ui_ok_00, ui_ok_01, ui_ok_02, ui_ok_03, 0
    ui_ok_footer_lines dd ui_ok_09, ui_ok_10, ui_ok_11, ui_ok_12
                       dd ui_ok_13, ui_ok_14, ui_ok_15, ui_ok_16
                       dd ui_ok_17, ui_ok_18, ui_ok_19, ui_ok_20, 0

    ui_fail_00 db '+=================== KET QUA GIAI ME CUNG =================+', 0
    ui_fail_01 db '| Trang thai: KHONG TIM THAY DUONG DI                      |', 0
    ui_fail_02 db '+==========================================================+', 0
    ui_fail_03 db '', 0
    ui_fail_04 db '##########', 0
    ui_fail_05 db '#Sxxx#...#', 0
    ui_fail_06 db '#####.##.#', 0
    ui_fail_07 db '#......#E#', 0
    ui_fail_08 db '##########', 0
    ui_fail_09 db '', 0
    ui_fail_10 db '+========================= THONG KE =======================+', 0
    ui_fail_11 db '| So buoc DFS     : 35                                     |', 0
    ui_fail_12 db '| So o da xet     : 28                                     |', 0
    ui_fail_13 db '| So lan quay lui : 10                                     |', 0
    ui_fail_14 db '| Ket qua         : That bai                               |', 0
    ui_fail_15 db '+==========================================================+', 0
    ui_fail_16 db '|  1. Giai me cung khac                                    |', 0
    ui_fail_17 db '|  2. Quay lai menu chinh                                  |', 0
    ui_fail_18 db '|  3. Thoat chuong trinh                                   |', 0
    ui_fail_19 db '+==========================================================+', 0
    ui_fail_20 db 'Nhap lua chon cua ban: ', 0
    ui_fail_lines dd ui_fail_00, ui_fail_01, ui_fail_02, ui_fail_03
                  dd ui_fail_04, ui_fail_05, ui_fail_06, ui_fail_07
                  dd ui_fail_08, ui_fail_09, ui_fail_10, ui_fail_11
                  dd ui_fail_12, ui_fail_13, ui_fail_14, ui_fail_15
                  dd ui_fail_16, ui_fail_17, ui_fail_18, ui_fail_19
                  dd ui_fail_20, 0
    ui_fail_header_lines dd ui_fail_00, ui_fail_01, ui_fail_02
                         dd ui_fail_03, 0
    ui_fail_footer_lines dd ui_fail_09, ui_fail_10, ui_fail_11
                         dd ui_fail_12, ui_fail_13, ui_fail_14
                         dd ui_fail_15, ui_fail_16, ui_fail_17
                         dd ui_fail_18, ui_fail_19, ui_fail_20, 0

    ui_info_00 db '+================= THONG TIN NHOM / DU AN =================+', 0
    ui_info_01 db '| Ten du an : ASM Maze Solver - NASM Win32                 |', 0
    ui_info_02 db '| Mo ta     : Game AI tu dong giai me cung bang DFS        |', 0
    ui_info_03 db '| Ngon ngu  : Assembly NASM 32-bit tren Windows            |', 0
    ui_info_04 db '| Moi truong: MSYS2, NASM, GCC                             |', 0
    ui_info_05 db '|                                                          |', 0
    ui_info_06 db '| Thanh vien 1: Phu trach UI, Use Case, giao dien          |', 0
    ui_info_07 db '| Thanh vien 2: Phu trach doc file va quan ly du lieu      |', 0
    ui_info_08 db '| Thanh vien 3: Phu trach thuat toan DFS va tich hop       |', 0
    ui_info_09 db '+==========================================================+', 0
    ui_info_10 db 'Bam phim bat ky de quay lai menu...', 0
    ui_info_lines dd ui_info_00, ui_info_01, ui_info_02, ui_info_03
                  dd ui_info_04, ui_info_05, ui_info_06, ui_info_07
                  dd ui_info_08, ui_info_09, ui_info_10, 0

    ui_exit_00 db '+==========================================================+', 0
    ui_exit_01 db '|               CAM ON BAN DA SU DUNG GAME                 |', 0
    ui_exit_02 db '|                                                          |', 0
    ui_exit_03 db '|              ASM MAZE SOLVER - NASM WIN32                |', 0
    ui_exit_04 db '|                                                          |', 0
    ui_exit_05 db '|              Chuong trinh ket thuc an toan.              |', 0
    ui_exit_06 db '+==========================================================+', 0
    ui_exit_lines dd ui_exit_00, ui_exit_01, ui_exit_02, ui_exit_03
                  dd ui_exit_04, ui_exit_05, ui_exit_06, 0

    ui_invalid_msg db 'Lua chon khong hop le. Vui long nhap lai.', 0

section .text

; Clear the entire console screen and reset cursor to (0,0).
UI_ClearScreen:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 22

    lea eax, [ebp-46]
    push eax
    push dword [hConsole]
    call _GetConsoleScreenBufferInfo@8

    movzx eax, word [ebp-46]
    movzx edx, word [ebp-44]
    imul eax, edx
    push bytes_written
    push 0
    push eax
    push dword 32
    push dword [hConsole]
    call _FillConsoleOutputCharacterA@20

    movzx eax, word [ebp-38]
    movzx edx, word [ebp-46]
    movzx ecx, word [ebp-44]
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
    pop eax
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

    lea eax, [ebp-46]
    push eax
    push dword [hConsole]
    call _GetConsoleScreenBufferInfo@8

    movzx ecx, word [ebp-46]
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
    push eax
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
    pop eax
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

; EDX points to a zero-terminated ASCII string.
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

; EDX points to a zero-terminated table of string pointers.
UI_ShowScreen:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, edx
    xor ebx, ebx
    call UI_ClearScreen
UI_ShowScreen_Loop:
    mov edx, [esi]
    test edx, edx
    jz UI_ShowScreen_Done
    mov word [coord_x], 0
    mov [coord_y], bx
    call UI_GotoXY
    call UI_PrintZ
    add esi, 4
    inc ebx
    jmp UI_ShowScreen_Loop
UI_ShowScreen_Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; EDX points to a zero-terminated table of string pointers.
; BX is the first output row. The screen is not cleared.
UI_PrintLinesAt:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, edx
UI_PrintLinesAt_Loop:
    mov edx, [esi]
    test edx, edx
    jz UI_PrintLinesAt_Done
    mov word [coord_x], 0
    mov [coord_y], bx
    call UI_GotoXY
    call UI_PrintZ
    add esi, 4
    inc ebx
    jmp UI_PrintLinesAt_Loop
UI_PrintLinesAt_Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; Draw a fixed-width maze grid without clearing the screen.
; EDX = maze address, EAX = columns, ECX = rows, BX = first output row.
UI_DrawMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 4

    mov esi, edx
    mov [ebp-28], eax
    mov edi, ecx
UI_DrawMaze_Loop:
    test edi, edi
    jz UI_DrawMaze_Done
    mov word [coord_x], 0
    mov [coord_y], bx
    call UI_GotoXY
    push 0
    push bytes_written
    push dword [ebp-28]
    push esi
    push dword [hConsole]
    call _WriteConsoleA@20
    add esi, [ebp-28]
    inc ebx
    dec edi
    jmp UI_DrawMaze_Loop
UI_DrawMaze_Done:
    add esp, 4
    pop edi
    pop esi
    pop edx
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

; Return the next non-CR/LF character in AL.
UI_ReadChoice:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi
UI_ReadChoice_Loop:
    call UI_WaitKey
    mov al, [buffer]
    cmp al, 13
    je UI_ReadChoice_Loop
    cmp al, 10
    je UI_ReadChoice_Loop
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

; Input: EAX = console text attribute.
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

UI_ShowMainMenu:
    mov edx, ui_main_lines
    jmp UI_ShowScreen

UI_ShowHelp:
    mov edx, ui_help_lines
    jmp UI_ShowScreen

UI_ShowSourceMenu:
    mov edx, ui_source_lines
    jmp UI_ShowScreen

UI_ShowDifficultyMenu:
    mov edx, ui_level_lines
    jmp UI_ShowScreen

UI_ShowSpeedMenu:
    mov edx, ui_speed_lines
    jmp UI_ShowScreen

UI_ShowDisplayMenu:
    mov edx, ui_display_lines
    jmp UI_ShowScreen

UI_ShowFileMenu:
    mov edx, ui_file_lines
    jmp UI_ShowScreen

UI_ShowFilenamePrompt:
    mov edx, ui_name_lines
    jmp UI_ShowScreen

UI_ShowValidationSuccess:
    mov edx, ui_valid_lines
    jmp UI_ShowScreen

UI_ShowValidationError:
    mov edx, ui_error_lines
    jmp UI_ShowScreen

UI_ShowSolvingScreen:
    mov edx, ui_solve_lines
    jmp UI_ShowScreen

UI_ShowSolvingHeader:
    mov edx, ui_solve_header_lines
    jmp UI_ShowScreen

UI_ShowResultSuccess:
    mov edx, ui_ok_lines
    jmp UI_ShowScreen

UI_ShowResultSuccessHeader:
    mov edx, ui_ok_header_lines
    jmp UI_ShowScreen

UI_ShowResultFailure:
    mov edx, ui_fail_lines
    jmp UI_ShowScreen

UI_ShowResultFailureHeader:
    mov edx, ui_fail_header_lines
    jmp UI_ShowScreen

UI_ShowProjectInfo:
    mov edx, ui_info_lines
    jmp UI_ShowScreen

UI_ShowExitScreen:
    mov edx, ui_exit_lines
    jmp UI_ShowScreen

UI_ShowInvalidChoice:
    push eax
    push edx
    mov word [coord_x], 0
    mov word [coord_y], 12
    call UI_ClearLine
    call UI_GotoXY
    mov eax, 12
    call UI_SetColor
    mov edx, ui_invalid_msg
    call UI_PrintZ
    call UI_ResetColor
    pop edx
    pop eax
    ret

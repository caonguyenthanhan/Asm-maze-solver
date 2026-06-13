; SV3 - Core + DFS module (Win32 NASM)
; Public procedures:
;   MAIN_FindStart
;   MAIN_DrawFullMaze
;   MAIN_GetIndex
;   MAIN_IsValid
;   DFS_Push / DFS_Pop
;   DFS_Solve
;
; Giả định về cấu trúc dữ liệu:
;   - maze (mê cung) là một mảng 1 chiều (1D) lưu trữ (cols * rows) ký tự.
;   - stack_x / stack_y là các ngăn xếp bằng phần mềm (mảng tùy chỉnh) để lưu trạng thái DFS 
;     thay vì dùng ngăn xếp phần cứng (hardware stack), giúp tránh tràn bộ nhớ (Stack Overflow).
;
; Quy ước chung về thanh ghi trong module này:
;   - EBX thường dùng lưu tọa độ X (cột)
;   - ECX thường dùng lưu tọa độ Y (hàng)
;   - ESI thường dùng làm con trỏ trỏ tới mảng (maze)

section .text

; -------------------------------------------------------------------------
; MAIN_FindStart: Tìm ô bắt đầu 'S' trong mê cung và thiết lập currX, currY.
; Trả về: EAX = 1 nếu tìm thấy, 0 nếu không tìm thấy.
; -------------------------------------------------------------------------
MAIN_FindStart:
    ; --- Thiết lập Stack Frame ---
    push ebp
    mov ebp, esp
    ; Bảo toàn các thanh ghi sẽ sử dụng
    push ebx
    push ecx
    push esi

    mov esi, maze       ; Trỏ ESI vào đầu mảng mê cung
    xor ecx, ecx        ; ecx = 0 (dùng làm biến đếm hàng - Y)

MAIN_FindRow:
    cmp ecx, [rows]     ; Nếu Y >= tổng số hàng
    jae MAIN_FindNotFound ; -> Không tìm thấy, nhảy tới cuối
    xor ebx, ebx        ; ebx = 0 (dùng làm biến đếm cột - X)

MAIN_FindCol:
    cmp ebx, [cols]     ; Nếu X >= tổng số cột
    jae MAIN_FindNextRow  ; -> Chuyển sang hàng tiếp theo
    cmp byte [esi], 'S' ; Kiểm tra ký tự hiện tại có phải là 'S' không?
    je MAIN_FindFound   ; Nếu bằng 'S', nhảy tới nhãn tìm thấy
    inc esi             ; Tăng con trỏ mảng lên 1 byte (sang ký tự tiếp)
    inc ebx             ; Tăng X lên 1
    jmp MAIN_FindCol    ; Lặp lại kiểm tra cột

MAIN_FindNextRow:
    inc ecx             ; Tăng Y lên 1
    jmp MAIN_FindRow    ; Lặp lại kiểm tra hàng

MAIN_FindFound:
    mov [currX], ebx    ; Lưu tọa độ X tìm được vào biến currX
    mov [currY], ecx    ; Lưu tọa độ Y tìm được vào biến currY
    mov eax, 1          ; EAX = 1 (Trạng thái: Thành công)
    jmp MAIN_FindDone

MAIN_FindNotFound:
    mov eax, 0          ; EAX = 0 (Trạng thái: Thất bại)

MAIN_FindDone:
    ; Phục hồi thanh ghi và dọn dẹp Stack Frame
    pop esi
    pop ecx
    pop ebx
    leave
    ret

; -------------------------------------------------------------------------
; MAIN_DrawFullMaze: Vẽ toàn bộ mê cung ra màn hình UI
; -------------------------------------------------------------------------
MAIN_DrawFullMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, maze       ; ESI = con trỏ đầu mảng mê cung
    xor ecx, ecx        ; ecx (Y) = 0

MAIN_DrawRow:
    cmp ecx, [rows]
    jae MAIN_DrawDone   ; Nếu vẽ hết các hàng thì xong
    xor ebx, ebx        ; ebx (X) = 0

MAIN_DrawCol:
    cmp ebx, [cols]
    jae MAIN_DrawNextRow

    mov [coord_x], bx   ; Đưa tọa độ X vào biến của UI
    mov [coord_y], cx   ; Đưa tọa độ Y vào biến của UI
    mov al, [esi]       ; Đọc ký tự tại ô hiện tại vào AL

    ; --- Ánh xạ ký tự logic sang ký tự hiển thị ---
    cmp al, '1'         ; Nếu là '1' (Tường)
    jne MAIN_DrawMapZero
    mov al, '#'         ; Vẽ thành dấu '#'
    jmp MAIN_DrawCell
MAIN_DrawMapZero:
    cmp al, '0'         ; Nếu là '0' (Đường đi)
    jne MAIN_DrawCell
    mov al, '.'         ; Vẽ thành dấu '.'

MAIN_DrawCell:
    mov dl, al          ; Cất ký tự cần vẽ vào DL
    movzx eax, word [ui_attr_default] ; Nạp màu mặc định

    ; --- Cài đặt màu sắc dựa trên loại ô ---
    cmp dl, '#'
    jne MAIN_DrawAttr_NotWall
    mov eax, 8          ; Mã màu 8 cho Tường
    jmp MAIN_DrawAttr_Set
MAIN_DrawAttr_NotWall:
    cmp dl, 'S'
    jne MAIN_DrawAttr_NotStart
    mov eax, 10         ; Mã màu 10 cho điểm Start
    jmp MAIN_DrawAttr_Set
MAIN_DrawAttr_NotStart:
    cmp dl, 'E'
    jne MAIN_DrawAttr_Set
    mov eax, 12         ; Mã màu 12 cho điểm End
MAIN_DrawAttr_Set:
    call UI_SetColor    ; Gọi hàm UI để đổi màu
    mov al, dl          ; Nạp lại ký tự cần vẽ vào AL
    call UI_DrawChar    ; Gọi hàm UI để in ký tự
    call UI_ResetColor  ; Trả lại màu gốc

    inc esi             ; Tiến tới ô tiếp theo trong mảng
    inc ebx             ; X++
    jmp MAIN_DrawCol

MAIN_DrawNextRow:
    inc ecx             ; Y++
    jmp MAIN_DrawRow

MAIN_DrawDone:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; -------------------------------------------------------------------------
; MAIN_GetIndex: Chuyển đổi tọa độ (X, Y) sang chỉ mục mảng 1D (Index)
; Đầu vào: EBX = X, ECX = Y
; Trả về: ESI = Địa chỉ bộ nhớ của ô (maze + Y * cols + X)
; -------------------------------------------------------------------------
MAIN_GetIndex:
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov eax, ecx        ; EAX = Y
    mul dword [cols]    ; EAX = Y * cols (Nhân độ rộng)
    add eax, ebx        ; EAX = Y * cols + X (Cộng offset cột)
    
    mov esi, maze       ; Lấy địa chỉ cơ sở của mê cung
    add esi, eax        ; Cộng thêm offset vừa tính được -> ESI trỏ đúng ô

    pop edx
    pop eax
    leave
    ret

; -------------------------------------------------------------------------
; MAIN_IsValid: Kiểm tra tọa độ (X,Y) có hợp lệ để di chuyển vào không
; Đầu vào: EBX = X, ECX = Y
; Trả về: EAX = 1 (Hợp lệ), 0 (Không hợp lệ/Đụng tường)
; -------------------------------------------------------------------------
MAIN_IsValid:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi

    ; Kiểm tra biên trục X
    test ebx, ebx       ; Kỹ thuật tối ưu: test ebx, ebx để kiểm tra số âm
    js MAIN_Invalid     ; Jump if Sign: Nếu X < 0 -> Báo lỗi
    cmp ebx, [cols]
    jae MAIN_Invalid    ; Nếu X >= cols -> Vượt biên giới -> Lỗi

    ; Kiểm tra biên trục Y
    test ecx, ecx
    js MAIN_Invalid     ; Nếu Y < 0 -> Lỗi
    cmp ecx, [rows]
    jae MAIN_Invalid    ; Nếu Y >= rows -> Lỗi

    call MAIN_GetIndex  ; Lấy địa chỉ của ô hiện tại vào ESI
    mov al, [esi]       ; Đọc nội dung ô vào AL
    
    ; Ô chỉ hợp lệ nếu là đường đi hoặc điểm đầu/cuối
    cmp al, '0'
    je MAIN_Valid
    cmp al, ' '
    je MAIN_Valid
    cmp al, 'E'
    je MAIN_Valid
    cmp al, 'S'
    je MAIN_Valid
    jmp MAIN_Invalid    ; Ngược lại (VD: '1' hoặc 'V') là không hợp lệ

MAIN_Valid:
    mov eax, 1          ; Hợp lệ
    jmp MAIN_IsValidDone

MAIN_Invalid:
    mov eax, 0          ; Không hợp lệ

MAIN_IsValidDone:
    pop esi
    pop ecx
    pop ebx
    leave
    ret

; -------------------------------------------------------------------------
; MAIN_ValidateMaze: Xác thực dữ liệu mê cung có đúng chuẩn không
; Kiểm tra kích thước, số lượng S/E, ký tự lạ.
; -------------------------------------------------------------------------
MAIN_ValidateMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov dword [errorCode], 0

    ; Kiểm tra giới hạn kích thước (tối đa 1600 ô)
    mov eax, [cols]
    imul eax, dword [rows] ; EAX = cols * rows
    cmp eax, 1600
    jbe MAIN_ValidateSizeOk
    mov dword [errorCode], 6 ; Mã lỗi 6: Mê cung quá lớn
    xor eax, eax             ; EAX = 0 (Thất bại)
    jmp MAIN_ValidateDone

MAIN_ValidateSizeOk:
    mov esi, maze
    xor edi, edi        ; Đếm số lượng điểm 'S' (Start)
    xor edx, edx        ; Đếm số lượng điểm 'E' (End)
    xor ecx, ecx        ; Y = 0

MAIN_ValidateRow:
    cmp ecx, [rows]
    jae MAIN_ValidateCounts
    xor ebx, ebx        ; X = 0

MAIN_ValidateCol:
    cmp ebx, [cols]
    jae MAIN_ValidateNextRow
    mov al, [esi]

    ; Lọc ký tự rác
    cmp al, '0'
    je MAIN_ValidateCharOk
    cmp al, '1'
    je MAIN_ValidateCharOk
    cmp al, ' '
    je MAIN_ValidateCharOk
    cmp al, 'S'
    je MAIN_ValidateCharS
    cmp al, 'E'
    je MAIN_ValidateCharE
    
    mov dword [errorCode], 3 ; Mã lỗi 3: Ký tự không hợp lệ
    xor eax, eax
    jmp MAIN_ValidateDone

MAIN_ValidateCharS:
    inc edi             ; Tăng bộ đếm 'S'
    mov [startX], ebx
    mov [startY], ecx
    jmp MAIN_ValidateCharOk

MAIN_ValidateCharE:
    inc edx             ; Tăng bộ đếm 'E'
    mov [endX], ebx
    mov [endY], ecx

MAIN_ValidateCharOk:
    inc esi
    inc ebx
    jmp MAIN_ValidateCol

MAIN_ValidateNextRow:
    inc ecx
    jmp MAIN_ValidateRow

MAIN_ValidateCounts:
    test edi, edi       ; Kiểm tra đếm số lượng 'S'
    jz MAIN_ValidateNoS ; Nếu = 0 -> Lỗi thiếu S
    cmp edi, 1
    jne MAIN_ValidateBadFormat ; Nếu > 1 -> Dư thừa S
    
    test edx, edx       ; Kiểm tra đếm số lượng 'E'
    jz MAIN_ValidateNoE ; Nếu = 0 -> Lỗi thiếu E
    cmp edx, 1
    jne MAIN_ValidateBadFormat ; Nếu > 1 -> Dư thừa E
    
    mov eax, 1          ; Mê cung hoàn toàn hợp lệ
    jmp MAIN_ValidateDone

MAIN_ValidateNoS:
    mov dword [errorCode], 4
    xor eax, eax
    jmp MAIN_ValidateDone

MAIN_ValidateNoE:
    mov dword [errorCode], 5
    xor eax, eax
    jmp MAIN_ValidateDone

MAIN_ValidateBadFormat:
    mov dword [errorCode], 3
    xor eax, eax

MAIN_ValidateDone:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; -------------------------------------------------------------------------
; DFS_Push: Đẩy một tọa độ (X, Y) vào Custom Stack (Ngăn xếp phần mềm)
; Đầu vào: BL = X, CL = Y
; -------------------------------------------------------------------------
DFS_Push:
    push ebp
    mov ebp, esp
    push esi

    mov esi, [stack_top] ; Lấy vị trí đỉnh ngăn xếp hiện tại
    cmp esi, [stack_cap] ; Kiểm tra xem có vượt sức chứa không?
    jae DFS_PushDone     ; Nếu có, bỏ qua (Tránh tràn ngăn xếp - Stack Overflow)
    
    mov byte [stack_x + esi], bl ; Lưu X vào mảng stack_x
    mov byte [stack_y + esi], cl ; Lưu Y vào mảng stack_y
    inc dword [stack_top]        ; Tăng con trỏ đỉnh ngăn xếp lên 1

DFS_PushDone:
    pop esi
    leave
    ret

; -------------------------------------------------------------------------
; DFS_Pop: Lấy một tọa độ từ Custom Stack ra
; Trả về: BL = X, CL = Y
; -------------------------------------------------------------------------
DFS_Pop:
    push ebp
    mov ebp, esp
    push esi

    dec dword [stack_top]        ; Giảm con trỏ đỉnh xuống 1
    mov esi, [stack_top]
    mov bl, byte [stack_x + esi] ; Lấy X ra từ stack_x
    mov cl, byte [stack_y + esi] ; Lấy Y ra từ stack_y

    pop esi
    leave
    ret

; -------------------------------------------------------------------------
; DFS_Solve: Vòng lặp chính của thuật toán Tìm kiếm theo chiều sâu (DFS)
; -------------------------------------------------------------------------
DFS_Solve:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Khởi tạo các biến môi trường cho quá trình giải thuật
    mov byte [dfs_result], 0     ; Khởi tạo kết quả = 0 (Chưa tìm thấy)
    mov dword [cells_examined], 0
    mov dword [stack_top], 0     ; Xoá sạch Custom Stack
    
    mov ebx, [currX]             ; Nạp toạ độ xuất phát 'S'
    mov ecx, [currY]
    call DFS_Push                ; Đưa điểm Start vào ngăn xếp

DFS_Loop:
    cmp dword [stack_top], 0     ; Kiểm tra Stack rỗng không?
    je DFS_End                   ; Rỗng -> Đã duyệt hết mà không thấy đường ra (Thất bại)

    call DFS_Pop                 ; Rút tọa độ ở đỉnh stack ra EBX (X), ECX (Y)
    mov [currX], ebx
    mov [currY], ecx

    mov edx, ebx                 ; Sao lưu X sang EDX
    mov edi, ecx                 ; Sao lưu Y sang EDI

    call MAIN_GetIndex           ; Lấy địa chỉ ô hiện tại vào ESI
    mov al, [esi]
    
    cmp al, 'E'                  ; Đã tới đích chưa?
    je DFS_Found                 ; Nhảy đến bước thành công
    cmp al, 'V'                  ; Đã thăm rồi ('V' = Visited)?
    je DFS_Loop                  ; Bỏ qua, lấy phần tử tiếp theo trong stack
    cmp al, '1'                  ; Là tường? (Double check)
    je DFS_Loop

    ; --- Đánh dấu ô đang xét ---
    mov [dfs_prev_char], al      ; Lưu ký tự cũ trước khi ghi đè
    mov byte [esi], 'V'          ; Đánh dấu ô này là 'V' (Đã thăm)
    inc dword [cells_examined]   ; Tăng bộ đếm số ô đã kiểm tra

DFS_Draw:
    inc dword [dfs_steps]        ; Tăng số bước thuật toán
    call DFS_UpdateStatus        ; Cập nhật thanh trạng thái giao diện
    
    mov [coord_x], bx            ; Cập nhật tọa độ hiển thị
    mov [coord_y], cx
    mov al, [dfs_display_mode]   ; Xem người dùng đang chọn chế độ vẽ nào
    cmp al, 0
    je DFS_DrawMinimal
    cmp al, 1
    je DFS_DrawNormal
    jmp DFS_DrawDense

    ; Khối lệnh vẽ Minimal (Chỉ vẽ đầu dò)
DFS_DrawMinimal:
    mov al, [dfs_prev_char]
    cmp al, 'S'
    je DFS_DrawS_Min
    mov eax, 11                  ; Đổi màu Cyan (Đầu dò @)
    call UI_SetColor
    mov al, '@'
    call UI_DrawCell
    call UI_ResetColor
    mov al, [dfs_prev_char]
    cmp al, ' '
    je DFS_MinRestoreSpace
    mov al, '.'                  ; Xoá vết chân
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

    ; Khối lệnh vẽ Normal (Có để lại vết chân thưa)
DFS_DrawNormal:
    mov al, [dfs_prev_char]
    cmp al, 'S'
    je DFS_DrawS_Norm
    mov eax, 11
    call UI_SetColor
    mov al, '@'
    call UI_DrawCell
    call UI_ResetColor
    mov eax, [dfs_steps]
    and eax, 3                   ; Đánh dấu cách quãng (mod 4)
    jnz DFS_NormRestore
    mov eax, 14
    call UI_SetColor
    mov al, '*'                  ; Vết chân vàng
    call UI_DrawChar
    call UI_ResetColor
    jmp DFS_AfterDraw
DFS_NormRestore:
    mov al, [dfs_prev_char]
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

    ; Khối lệnh vẽ Dense (Để lại dấu chân liên tục '*')
DFS_DrawDense:
    mov al, [dfs_prev_char]
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

    ; =========================================================
    ; Tìm kiếm nút kề (Neighbor Expansion) - Thứ tự: Phải, Xuống, Trái, Lên
    ; Nhờ cấu trúc Stack (LIFO), hướng được đưa vào *sau cùng* sẽ được đi *trước tiên*.
    ; =========================================================

    ; --- 1. Hướng Phải (Right) ---
    mov ebx, edx
    inc ebx             ; X + 1
    mov ecx, edi
    call MAIN_IsValid   ; Có đi được không?
    cmp eax, 1
    jne DFS_TryDown
    call DFS_Push       ; Đi được thì push vào ngăn xếp

DFS_TryDown:
    ; --- 2. Hướng Xuống (Down) ---
    mov ebx, edx
    mov ecx, edi
    inc ecx             ; Y + 1
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_TryLeft
    call DFS_Push

DFS_TryLeft:
    ; --- 3. Hướng Trái (Left) ---
    mov ebx, edx
    dec ebx             ; X - 1
    mov ecx, edi
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_TryUp
    call DFS_Push

DFS_TryUp:
    ; --- 4. Hướng Lên (Up) ---
    mov ebx, edx
    mov ecx, edi
    dec ecx             ; Y - 1
    call MAIN_IsValid
    cmp eax, 1
    jne DFS_Loop
    call DFS_Push
    
    jmp DFS_Loop        ; Lặp lại chu trình để xử lý đỉnh ngăn xếp mới

DFS_Found:
    mov byte [dfs_result], 1  ; Đánh dấu trạng thái tìm thấy đích
    mov [coord_x], bx
    mov [coord_y], cx
    mov eax, 12               ; Chớp UI màu 12 cho điểm 'E'
    call UI_SetColor
    mov al, 'E'
    call UI_DrawChar
    call UI_ResetColor
    mov dword [stack_top], 0  ; Dọn dẹp ngăn xếp kết thúc sớm

DFS_End:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; -------------------------------------------------------------------------
; DFS_UpdateStatus: In dòng trạng thái số bước và toạ độ ở phía dưới UI
; -------------------------------------------------------------------------
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
    mov [coord_y], ax      ; Đặt con trỏ ở tọa độ Y = rows + 3
    
    call UI_ClearLine      ; Xoá dòng cũ
    call UI_GotoXY         ; Di chuyển con trỏ UI
    
    mov edx, status_step
    call UI_PrintZ         ; In chữ "Bước: "
    mov eax, [dfs_steps]
    call UI_PrintDec4      ; In số nguyên (4 chữ số)
    
    mov edx, status_x
    call UI_PrintZ         ; In chữ "X: "
    mov eax, [currX]
    call UI_PrintDec2      ; In số nguyên (2 chữ số)
    
    mov edx, status_y
    call UI_PrintZ         ; In chữ "Y: "
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

; -------------------------------------------------------------------------
; MAIN_RandByte: Hàm tạo số giả ngẫu nhiên 1 Byte
; Thuật toán: Linear Congruential Generator (LCG)
; Công thức: state = (state * 1103515245 + 12345)
; -------------------------------------------------------------------------
MAIN_RandByte:
    push ebp
    mov ebp, esp
    push edx

    mov eax, [rand_state]
    imul eax, eax, 1103515245 ; Nhân trạng thái hiện tại với hằng số magic
    add eax, 12345            ; Cộng thêm bias
    mov [rand_state], eax     ; Cập nhật lại trạng thái cho lần gọi sau
    
    shr eax, 16               ; Dịch bit sang phải (bỏ 16 bit ít ngẫu nhiên nhất)
    and eax, 0xFF             ; Mặt nạ lấy ra đúng 1 Byte (0 -> 255)

    pop edx
    leave
    ret

; -------------------------------------------------------------------------
; MAIN_GenerateRandomMaze: Thuật toán tự động sinh bản đồ Mê cung
; EAX = Độ khó/Kích thước (1 = Nhỏ, 2 = Vừa, khác = Lớn)
; -------------------------------------------------------------------------
MAIN_GenerateRandomMaze:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Thiết lập kích thước phụ thuộc thông số truyền vào
    mov ebx, 10           ; Kích thước mặc định
    mov dl, 179           ; Ngưỡng mật độ tường (threshold)
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

    ; Đặt mục tiêu đích E ở góc phải dưới
    mov eax, [cols]
    sub eax, 2
    mov [gen_target_x], eax
    mov eax, [rows]
    sub eax, 2
    mov [gen_target_y], eax

    ; --- TỐI ƯU HÓA ---
    ; Tô toàn bộ bản đồ bằng '1' (Tường cứng) sử dụng tập lệnh lặp chuỗi
    mov eax, [rows]
    mul dword [cols]
    mov ecx, eax        ; ECX = Tổng số ô (cols * rows) dùng cho bộ đếm rep
    mov edi, maze       ; EDI = Đích đổ dữ liệu
    mov al, '1'         ; Ký tự cần điền
    cld                 ; Dọn cờ hướng để chuỗi tiến lên
    rep stosb           ; Điền khối bộ nhớ bằng ký tự trong AL rất nhanh

    ; --- TẠO MỘT ĐƯỜNG ĐI CHẮC CHẮN GIẢI ĐƯỢC ---
    ; Bắt đầu từ góc (1,1) di chuyển lắt léo về đích
    mov ebx, 1          ; Khởi đầu X = 1
    mov ecx, 1          ; Khởi đầu Y = 1

MAIN_PathWrite:
    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    mov byte [esi], '0' ; Đào tường thành đường '0'

    cmp ebx, [gen_target_x]
    jne MAIN_PathCheckY
    cmp ecx, [gen_target_y]
    je MAIN_PathDone
    inc ecx             ; Chỉ còn đường đi xuống Y
    jmp MAIN_PathWrite

MAIN_PathCheckY:
    cmp ecx, [gen_target_y]
    jne MAIN_PathRand
    inc ebx             ; Chỉ còn đường đi sang phải X
    jmp MAIN_PathWrite

MAIN_PathRand:
    ; Tung đồng xu (Rand) để quyết định đi ngang hay đi dọc
    call MAIN_RandByte
    test al, 1
    jz MAIN_PathRight   ; Nếu chẵn -> Đi ngang
    inc ecx             ; Nếu lẻ -> Đi dọc
    jmp MAIN_PathWrite
MAIN_PathRight:
    inc ebx
    jmp MAIN_PathWrite

MAIN_PathDone:
    ; --- ĐỤC LỖ TƯỜNG NGẪU NHIÊN ---
    ; Quét toàn bộ mê cung, đục thêm các ô bằng bộ sinh ngẫu nhiên
    mov ecx, 1
MAIN_RandRow:
    mov eax, [rows]
    sub eax, 1
    cmp ecx, eax
    jae MAIN_Finalize   ; Xong thì đi chốt hạ
    mov ebx, 1
MAIN_RandCol:
    mov eax, [cols]
    sub eax, 1
    cmp ebx, eax
    jae MAIN_RandNextRow

    ; Tính toán địa chỉ
    mov eax, ecx
    mul dword [cols]
    add eax, ebx
    mov esi, maze
    add esi, eax
    
    cmp byte [esi], '1'
    jne MAIN_RandSkip   ; Nếu đã là đường đi thì bỏ qua
    call MAIN_RandByte
    mov dl, [gen_threshold]
    cmp al, dl          ; So sánh số random sinh ra với mức threshold
    jb MAIN_RandOpen    ; Nhỏ hơn ngưỡng thì đục tường
    jmp MAIN_RandSkip
MAIN_RandOpen:
    mov byte [esi], '0' ; Đục thành đường '0'
MAIN_RandSkip:
    inc ebx
    jmp MAIN_RandCol

MAIN_RandNextRow:
    inc ecx
    jmp MAIN_RandRow

MAIN_Finalize:
    ; Đặt cờ đích S (1,1) và E (target_x, target_y)
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

    mov eax, 1          ; Thành công

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret

; -------------------------------------------------------------------------
; DFS_IsValidWork: Khác với IsValid ở trên, hàm này áp dụng trên 
; mảng phụ "maze_work" thay vì mảng thật "maze".
; -------------------------------------------------------------------------
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
    mov esi, maze_work      ; <-- Chú ý: Trỏ tới mảng nháp maze_work
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

; -------------------------------------------------------------------------
; DFS_CheckSolvable: Chạy thuật toán DFS ẩn (không hiển thị UI) trên mảng nháp
; để đảm bảo rằng Mê cung vừa sinh ngẫu nhiên chắc chắn CÓ THỂ GIẢI ĐƯỢC.
; -------------------------------------------------------------------------
DFS_CheckSolvable:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Copy toàn bộ "maze" sang "maze_work" để test mà không phá hỏng mảng chính
    mov eax, [rows]
    mul dword [cols]
    mov ecx, eax
    mov esi, maze
    mov edi, maze_work
    cld
    rep movsb               ; Di chuyển hàng loạt byte từ [ESI] sang [EDI]

    ; Bắt đầu mô phỏng lại luồng chạy y hệt DFS_Solve
    mov dword [stack_top], 0
    mov ebx, 1
    mov ecx, 1
    call DFS_Push

DFS_CheckLoop:
    cmp dword [stack_top], 0
    je DFS_CheckFail        ; Nếu stack rỗng mà chưa thấy E -> Vô nghiệm

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
    je DFS_CheckOk          ; Bắt được E -> Mê cung giải được
    cmp al, 'V'
    je DFS_CheckLoop
    cmp al, '1'
    je DFS_CheckLoop
    mov byte [esi], 'V'     ; Đánh dấu đã thăm trên mảng nháp

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
    mov eax, 1              ; Trả về True
    jmp DFS_CheckDone

DFS_CheckFail:
    mov eax, 0              ; Trả về False

DFS_CheckDone:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret
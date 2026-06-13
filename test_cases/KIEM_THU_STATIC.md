# Báo cáo Kiểm thử Tĩnh (Static Analysis) — ASM Maze Solver
> Ngày: 2026-06-13 | Phương pháp: Trace code tĩnh + xác minh luồng điều khiển

---

## 1. Kết quả Build

| Bước | Lệnh | Kết quả |
|---|---|---|
| NASM assemble | `nasm -f win32 main.asm -o main.o` | **EXIT:0 — không warning** |
| GCC link | `gcc -m32 main.o -o maze_solver.exe -lkernel32` | **Build successful** |

---

## 2. Trace tĩnh FILE_ReadMaze theo từng test case

### Luồng FILE_ReadMaze:
1. `CreateFileA` → fail → `FILE_NoFile` → `errorCode=1`, EAX=0 ✓
2. `GetFileSize` → 0 → `errorCode=2`, đóng handle, EAX=0 ✓
3. Đọc file OK → skip BOM → Pass1 (đếm cols) → Pass2 (đếm rows + check ragged)
4. Pass2: mỗi dòng so `edx` với `[cols]` → lệch → `FILE_Ragged` → `errorCode=7`, EAX=0 ✓
5. Pass3: strip CR/LF → pack maze → EAX=1 ✓

| TC | File | Kỳ vọng | Trace kết quả | Đúng? |
|---|---|---|---|---|
| tc_empty.txt | 0 bytes | errorCode=2 | `GetFileSize`=0 → `jnz FILE_SizeOk` KHÔNG jump → `errorCode=2` | ✅ |
| tc_no_s.txt | hợp lệ format, thiếu S | errorCode=4 | FILE_ReadMaze OK (EAX=1) → MAIN_ValidateMaze: edi(S_count)=0 → `MAIN_ValidateNoS` → `errorCode=4` | ✅ |
| tc_no_e.txt | hợp lệ format, thiếu E | errorCode=5 | FILE_ReadMaze OK → MAIN_ValidateMaze: edx(E_count)=0 → `MAIN_ValidateNoE` → `errorCode=5` | ✅ |
| tc_bad_char.txt | có ký tự 'X' | errorCode=3 | FILE_ReadMaze OK → MAIN_ValidateMaze: gặp 'X', không match '0'/'1'/'S'/'E'/' ' → `errorCode=3` | ✅ |
| tc_ragged.txt | dòng 3 ngắn (5 chars vs 9) | errorCode=7 | Pass2 FILE_ReadMaze: `cmp edx,[cols]` (5 ≠ 9) → `FILE_Ragged` → `errorCode=7`, EAX=0 | ✅ |
| tc_valid_small.txt | 9×3, S=(1,1), E=(7,1) | errorCode=0, DFS chạy | FILE_ReadMaze: cols=9, rows=3 → ValidateMaze OK → DFS_Solve | ✅ |
| tc_no_path.txt | S bị chặn hoàn toàn | dfs_result=0 | FILE+Validate OK → DFS_Solve: push S, pop S, gặp '1' ở 4 hướng → stack rỗng → `DFS_End`, dfs_result=0 | ✅ |
| tc_multi_s.txt | 2 ký tự S | errorCode=3 | MAIN_ValidateMaze: `edi` tăng lên 2, `cmp edi,1` → `jne MAIN_ValidateBadFormat` → `errorCode=3` | ✅ |
| khong_ton_tai.txt | không có file | errorCode=1 | `CreateFileA` trả -1 → `je FILE_NoFile` → `errorCode=1`, EAX=0 | ✅ |

---

## 3. Trace tĩnh DFS_Solve sau fix dfs_prev_char

### Luồng DFS_Solve (sau fix):
```
mov [dfs_prev_char], al   ; lưu ký tự ô gốc vào biến nhớ (KHÔNG dùng ah nữa)
mov byte [esi], 'V'
inc dword [cells_examined]
→ gọi DFS_UpdateStatus (dùng eax thoải mái, dfs_prev_char KHÔNG bị ảnh hưởng)
→ gọi UI_SetColor (dùng eax — dfs_prev_char vẫn an toàn)
→ mov al, [dfs_prev_char]   ; đọc lại từ biến nhớ — ĐÚNG
→ cmp al, 'S'               ; phán đoán đúng
```

| Kiểm tra | Kết quả |
|---|---|
| Ô 'S': `mov al,[dfs_prev_char]` → `cmp al,'S'` → vẽ `S` màu xanh | ✅ Đúng |
| Ô '0': khôi phục `.` | ✅ Đúng |
| Ô ' ' (space): khôi phục space | ✅ Đúng |
| `dfs_prev_char` không bị phá bởi UI_SetColor/DFS_UpdateStatus | ✅ An toàn (biến nhớ .data) |
| 3 draw mode (Minimal/Normal/Dense) đều dùng `[dfs_prev_char]` | ✅ Đã thay đủ |

---

## 4. Trace tĩnh luồng generator sau tách after_gen

```
gen_ok → after_gen:
    call MAIN_FindStart     ; tìm S trong maze vừa sinh
    cmp eax, 0
    je show_error           ; nếu không tìm thấy S → báo lỗi (phòng ngừa)
    → after_draw → MAIN_DrawFullMaze → DFS_Solve
```

| Kiểm tra | Kết quả |
|---|---|
| Generator sinh S tại (1,1) theo `MAIN_Finalize` | ✅ Luôn có S |
| `MAIN_FindStart` set `currX/currY` từ S tìm được | ✅ DFS bắt đầu đúng chỗ |
| KHÔNG gọi `MAIN_ValidateMaze` → không rơi vào show_error do errorCode | ✅ |
| Generator Easy 10×10 = 100 ≤ 1600, Medium 400, Hard 900 | ✅ Không vượt buffer |

---

## 5. Trace tĩnh luồng điều hướng menu

| TC | Phím | Nhãn đích | Xử lý sau | Kết quả |
|---|---|---|---|---|
| TC-01 | (mở app) | `menu_loop` | In 6 mục + sep | ✅ |
| TC-02 | `9` | fallthrough | `menu_invalid` → WaitKey → `menu_loop` | ✅ |
| TC-03 | `2` | `show_help` | In help + sep → WaitKey → `menu_loop` | ✅ |
| TC-04 | `4` | `show_info` | In info + sep → WaitKey → `menu_loop` | ✅ |
| TC-05 | `1` | `mode_file` → ... | speed→display→load_file→validate→DFS→result | ✅ |
| TC-17 | `1` ở result | `choose_file` | `UI_ClearScreen` ở đầu → màn sạch | ✅ |
| TC-18 | `2` ở result | `menu_loop` | `UI_ClearScreen` ở đầu menu_loop | ✅ |
| TC-19 | `3` ở result | `exit` | `ExitProcess(0)` | ✅ |
| TC-20 | `5` ở menu | `exit` | `ExitProcess(0)` | ✅ |

---

## 6. Vấn đề phát hiện trong quá trình trace

### 6.1. [PHÁT HIỆN MỚI] tc_no_path.txt — cấu trúc maze
File `tc_no_path.txt` có cấu trúc:
```
111111111   (row 0)
1S1111111   (row 1) — S tại (1,1), bị bao vây bởi '1'
111111111   (row 2)
1111111E1   (row 3) — E tại (7,3)
111111111   (row 4)
```
Các dòng đều 9 chars → ragged check OK.
DFS từ S(1,1): thử phải(2,1)='1', xuống(1,2)='1', trái(0,1)='1', lên(1,0)='1' → stack rỗng → `dfs_result=0` → `show_result` NOT FOUND. ✅

### 6.2. [OK] tc_valid_small.txt — đường thẳng
```
111111111
1S00000E1   — S(1,1), E(7,1), đường thẳng
111111111
```
DFS: push S(1,1) → pop → gặp '0' → push phải(2,1) → ... → gặp E(7,1) → `dfs_result=1`. ✅

### 6.3. [LƯU Ý] tc_no_path.txt có 5 dòng, 9 cols → cols×rows = 45 ≤ 1600 ✅

---

## 7. Tổng kết

| Hạng mục | Kết quả |
|---|---|
| Build NASM + GCC | ✅ Không lỗi, không warning |
| errorCode 1 (no file) | ✅ Trace đúng |
| errorCode 2 (empty) | ✅ Trace đúng |
| errorCode 3 (bad char / multi S/E) | ✅ Trace đúng |
| errorCode 4 (no S) | ✅ Trace đúng |
| errorCode 5 (no E) | ✅ Trace đúng |
| errorCode 7 (ragged) | ✅ Trace đúng |
| DFS dfs_prev_char fix | ✅ An toàn, không còn ah bị phá |
| Generator tách after_gen | ✅ Không bị validate chặn nhầm |
| Menu điều hướng | ✅ Tất cả nhánh đúng |
| DFS not-found (tc_no_path) | ✅ Stack rỗng → dfs_result=0 |
| DFS found (tc_valid_small) | ✅ Gặp E → dfs_result=1 |

**Không phát hiện thêm lỗi tĩnh nào.** Hệ thống sẵn sàng test runtime.

---

## 8. Test case files để dùng khi chạy tay

| File | Dùng với | Kỳ vọng |
|---|---|---|
| `test_cases/tc_empty.txt` | Menu 3→2 | Lỗi: "File me cung rong" |
| `test_cases/tc_no_s.txt` | Menu 3→2 | Lỗi: "Khong tim thay diem bat dau S" |
| `test_cases/tc_no_e.txt` | Menu 3→2 | Lỗi: "Khong tim thay diem ket thuc E" |
| `test_cases/tc_bad_char.txt` | Menu 3→2 | Lỗi: "File me cung sai dinh dang" |
| `test_cases/tc_ragged.txt` | Menu 3→2 | Lỗi: "Cau truc me cung khong hop le" |
| `test_cases/tc_valid_small.txt` | Menu 3→2 | Giải được, Found |
| `test_cases/tc_no_path.txt` | Menu 3→2 | Giải xong, Not Found |
| `test_cases/tc_multi_s.txt` | Menu 3→2 | Lỗi: "File me cung sai dinh dang" |
| `khong_ton_tai.txt` | Menu 3→2 | Lỗi: "Khong tim thay file" |
| `maze.txt` | Menu 1 hoặc 3→1 | Giải 39×14 |
| `1-maze.txt` | Menu 3→2 | Giải 10×10 |

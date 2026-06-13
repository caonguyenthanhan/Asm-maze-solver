# KẾ HOẠCH NÂNG CẤP — ASM Maze Solver (Win32 NASM)

> Tài liệu dành cho DEV bám theo khi code. Mục tiêu: đưa hệ thống hiện tại tiệm cận đặc tả `Dac_ta_Lab08_Maze_Solver.md`.
> Quy ước checkbox: `[ ]` chưa làm · `[x]` xong · `[~]` đang làm/một phần.

---

## 0. Quyết định đã chốt & điều chỉnh đặc tả

### 0.1. Quyết định (đã xác nhận với người dùng)
- **Menu**: theo đặc tả (Giải / Hướng dẫn / Chọn file / Thông tin nhóm / Thoát) + giữ **Tạo mê cung ngẫu nhiên** làm mục bonus.
- **Chọn file**: cho phép **nhập tên file qua console** (UC04 đầy đủ).
- **Thống kê**: cốt lõi → trạng thái found/not-found + số bước (steps) + số ô đã xét (cells examined).
- **Ký hiệu**: GIỮ NGUYÊN scheme hiện tại (`#`=tường, `.`=đường, `@`=AI hiện tại, `*`=visited, `S`, `E`). KHÔNG đổi sang `*`/`./x` của đặc tả.

### 0.2. Điều chỉnh đặc tả cho khớp giới hạn hợp ngữ
- `errorCode 6`: đổi ngưỡng từ "> 20×20" thành **`cols × rows ≤ 1600`** (~40×40) theo buffer `maze times 1600`.
- **Bỏ**: đếm số lần quay lui (backtrack count) và đo thời gian (GetTickCount) ở màn kết quả — đặc tả UC08 cho phép bỏ phần thống kê chi tiết.
- **Bỏ**: đổi ký hiệu `.`/`x` — giữ scheme màu hiện tại.
- **Gộp**: màn "Kiểm tra dữ liệu" liệt kê từng dòng `[OK]` → gộp thành 1 thông báo hợp lệ, hoặc 1 thông báo lỗi cụ thể nếu sai.
- **Kiểu biến**: đặc tả ghi `rows/cols` là `DW`; code hiện dùng `dd` (DWORD). GIỮ `dd` để không phải sửa toàn bộ `core.asm`. Ghi chú lại trong báo cáo.

---

## 1. Mục tiêu & phạm vi

### 1.1. Trong phạm vi
- Bổ sung các màn hình còn thiếu: Hướng dẫn, Chọn/nhập file, Kết quả + thống kê, Thông tin nhóm.
- Bổ sung validate dữ liệu mê cung + cơ chế `errorCode`.
- Thêm biến `startX/Y`, `endX/Y`, `errorCode`, `cells_examined`, `dfs_result`.
- Tái cấu trúc menu chính theo đặc tả, giữ generator làm bonus.

### 1.2. Ngoài phạm vi (không làm lần này)
- Backtrack count, đo thời gian.
- Đổi ký hiệu hiển thị.
- Đổi `dd` → `dw` cho rows/cols.
- Vẽ khung viền `+===+` đẹp như mockup cho TOÀN BỘ màn (chỉ làm tiêu đề có khung đơn giản nếu kịp; không bắt buộc).

---

## 2. Bản đồ hiện trạng code (baseline)

| File | Thủ tục/nhãn hiện có | Ghi chú |
|---|---|---|
| `main.asm` | `_main`, `menu_loop`, `mode_easy/medium/hard/file`, `speed_*`, `display_*`, `load_or_generate`, `MAIN_PrintLegend` | Menu xoay quanh generator; có speed + display menu |
| `IO/file.asm` | `FILE_ReadMaze` | ĐÃ auto-detect `cols`/`rows`; strip BOM + CR/LF; chưa set errorCode, chưa validate |
| `core/core.asm` | `MAIN_FindStart`, `MAIN_DrawFullMaze`, `MAIN_GetIndex`, `MAIN_IsValid`, `DFS_Push/Pop`, `DFS_Solve`, `DFS_UpdateStatus`, `MAIN_RandByte`, `MAIN_GenerateRandomMaze`, `DFS_IsValidWork`, `DFS_CheckSolvable` | DFS chạy + đếm `dfs_steps`; chưa đếm ô xét; chưa lưu cờ found |
| `UI/ui.asm` | `UI_ClearScreen`, `UI_ClearLine`, `UI_GotoXY`, `UI_DrawChar`, `UI_DrawCell`, `UI_PrintZ`, `UI_WaitKey`, `UI_SetColor`, `UI_ResetColor`, `UI_PrintDec2`, `UI_PrintDec4` | Đủ primitive để tái dùng |

### 2.1. Biến hiện có trong `.data` (main.asm) — KHÔNG xóa
`cols, rows, stack_cap, ui_delay_ms, mode_kind, mode_level, rand_state, gen_*, ui_attr_default, dfs_steps, dfs_display_mode, maze, maze_work, currX, currY, stack_x, stack_y, stack_top, maze_file, menu_*, msg_*, status_*, legend_*, hConsole, hInput, bytes_written, buffer, num_buf, coord_x, coord_y`.
`.bss`: `file_size, file_handle, bytes_read`.

---

## 3. Biến/dữ liệu cần THÊM (tổng hợp, làm ở Phase 1)

> Thêm vào `.data` (có giá trị đầu) hoặc `.bss` (chưa khởi tạo) trong `main.asm`.

### 3.1. Biến trạng thái (.data)
- [ ] `startX dd 0`
- [ ] `startY dd 0`
- [ ] `endX dd 0`
- [ ] `endY dd 0`
- [ ] `errorCode dd 0`   ; 0=OK,1=no file,2=empty,3=bad char,4=no S,5=no E,6=oversize,7=ragged
- [ ] `cells_examined dd 0`
- [ ] `dfs_result db 0`   ; 0=not found, 1=found
- [ ] `input_name_buf times 64 db 0`  ; buffer nhập tên file

### 3.2. Chuỗi menu chính mới (.data) — ASCII, kết thúc `,0`
- [ ] `m_title` : "==== ASM MAZE SOLVER - NASM WIN32 ===="
- [ ] `m_1` : "1. Bat dau giai me cung (doc file)"
- [ ] `m_2` : "2. Xem huong dan"
- [ ] `m_3` : "3. Chon file me cung"
- [ ] `m_4` : "4. Thong tin nhom / du an"
- [ ] `m_5` : "5. Thoat"
- [ ] `m_6` : "6. Tao me cung ngau nhien (bonus)"
- [ ] `m_prompt` : "Nhap lua chon: "
- [ ] `m_invalid` : "Lua chon khong hop le! Bam phim de thu lai."

### 3.3. Chuỗi màn hướng dẫn (.data)
- [ ] `g_title`, `g_line1..g_lineN` mô tả ký hiệu + cách DFS chạy + dòng "Bam phim bat ky de quay lai menu".

### 3.4. Chuỗi chọn file (.data)
- [ ] `f_title`, `f_opt1` ("1. Dung maze.txt"), `f_opt2` ("2. Nhap ten file khac"), `f_opt3` ("3. Quay lai"), `f_ask_name` ("Nhap ten file: ").

### 3.5. Chuỗi kết quả + thống kê (.data)
- [ ] `r_found` : "DA TIM THAY DUONG DI DEN DICH"
- [ ] `r_notfound` : "KHONG TIM THAY DUONG DI"
- [ ] `r_steps` : "So buoc DFS: "
- [ ] `r_cells` : "So o da xet: "
- [ ] `r_menu1` ("1. Giai me cung khac"), `r_menu2` ("2. Quay lai menu"), `r_menu3` ("3. Thoat").

### 3.6. Chuỗi thông tin nhóm (.data)
- [ ] `info_*` : tên dự án, mô tả, ngôn ngữ, môi trường, thành viên + "Bam phim de quay lai".

### 3.7. Chuỗi lỗi theo errorCode (.data) — map FR-09
- [ ] `err_1` "Khong tim thay file me cung"
- [ ] `err_2` "File me cung rong"
- [ ] `err_3` "File me cung sai dinh dang (ky tu khong hop le)"
- [ ] `err_4` "Khong tim thay diem bat dau S"
- [ ] `err_5` "Khong tim thay diem ket thuc E"
- [ ] `err_6` "Me cung vuot qua kich thuoc cho phep"
- [ ] `err_7` "Cau truc me cung khong hop le (cac dong khong deu)"

**Checklist Phase 1:**
- [ ] Tất cả biến trên đã khai báo, build `nasm -f win32 main.asm` không lỗi symbol.
- [ ] Không trùng tên với biến cũ.
- [ ] Chuỗi đều ASCII, không Unicode (NFR-02).

---

## 4. PHASE 2 — Menu chính mới (FR-01, FR-02, UC01)

**File:** `main.asm` (vùng `_main` → `menu_loop`).

### 4.1. Việc cụ thể
- [ ] Viết lại `menu_loop`: clear screen → in `m_title`, `m_1..m_6`, `m_prompt`.
- [ ] Đọc phím bằng `UI_WaitKey`, bỏ qua CR(13)/LF(10).
- [ ] Rẽ nhánh: `1`→`do_solve_file`, `2`→`show_help`, `3`→`choose_file`, `4`→`show_info`, `5`→`do_exit`, `6`→`do_generate`.
- [ ] Phím khác → in `m_invalid`, chờ phím, quay lại `menu_loop` (KHÔNG treo, NFR-03).
- [ ] Các nhánh xử lý xong đều `jmp menu_loop` (trừ exit).

### 4.2. Checklist Phase 2
- [ ] Chạy hiện đúng 6 dòng menu + tiêu đề.
- [ ] Nhập `9`/chữ lạ → báo invalid, không thoát.
- [ ] Nhập từng số 1–6 nhảy đúng nhánh (tạm để nhánh rỗng `jmp menu_loop` nếu phase sau chưa làm).
- [ ] Sau mỗi chức năng quay lại được menu.
- [ ] Bảo toàn `hConsole`/`hInput` (không bị ghi đè).

---

## 5. PHASE 3 — Màn hướng dẫn (FR-03, UC02)

**File:** `main.asm`, nhãn `show_help`.

### 5.1. Việc cụ thể
- [ ] Clear screen.
- [ ] In `g_title` + các dòng `g_line*` (mỗi dòng đặt `coord_y` tăng dần, gọi `UI_GotoXY` + `UI_PrintZ`).
- [ ] In bảng ký hiệu: `#`=Tuong, `.`=Duong, `@`=AI hien tai, `*`=Da xet, `S`=Bat dau, `E`=Dich (đúng scheme đang dùng).
- [ ] Dòng cuối: "Bam phim bat ky de quay lai menu".
- [ ] `UI_WaitKey` → `jmp menu_loop`.

### 5.2. Checklist Phase 3
- [ ] Hiển thị đầy đủ, không tràn quá rộng (NFR-02).
- [ ] Bảng ký hiệu khớp scheme thực tế trong DFS (không ghi `x` quay lui vì code không có).
- [ ] Bấm phím quay lại menu ổn định.

---

## 6. PHASE 4 — Chọn/nhập file (FR-04, UC04)

**File:** `main.asm` nhãn `choose_file`; có thể thêm thủ tục đọc tên trong `IO/file.asm`.

### 6.1. Việc cụ thể
- [ ] `choose_file`: clear screen → in `f_title`, `f_opt1`, `f_opt2`, `f_opt3`, prompt.
- [ ] Đọc phím:
  - `1` → giữ `maze_file = "maze.txt"` → `jmp do_solve_file`.
  - `2` → `jmp input_filename`.
  - `3` → `jmp menu_loop`.
  - khác → invalid, chờ phím, lặp lại.
- [ ] `input_filename`:
  - [ ] In `f_ask_name`.
  - [ ] Dùng `_ReadConsoleA` đọc vào `input_name_buf` (cho phép ~63 ký tự).
  - [ ] Cắt CR/LF cuối chuỗi → thay bằng `0` (ASCIIZ).
  - [ ] Copy `input_name_buf` → `maze_file` (hoặc trỏ `maze_file` sang buffer). **Lưu ý**: `maze_file` hiện là chuỗi cố định `'maze.txt',0`. Cần đổi thành buffer đủ lớn HOẶC dùng con trỏ riêng cho `CreateFileA`.
  - [ ] `jmp do_solve_file`.

### 6.2. Rủi ro/Quyết định kỹ thuật
- [ ] **`maze_file` phải là buffer ghi được**: đổi khai báo `maze_file times 64 db 0` và khởi tạo sẵn `"maze.txt"` vào đó lúc đầu chương trình, hoặc copy chuỗi mặc định vào khi chọn option 1.
- [ ] Phải bảo đảm chuỗi tên file kết thúc `0` trước khi gọi `CreateFileA` (NFR-03).

### 6.3. Checklist Phase 4
- [ ] Option 1 mở đúng `maze.txt`.
- [ ] Option 2 nhập "1-maze.txt" → đọc đúng file đó.
- [ ] Nhập tên file không tồn tại → rơi vào errorCode=1, báo lỗi, không treo.
- [ ] Option 3 quay lại menu.
- [ ] Ký tự thừa (CR/LF) trong tên file đã bị cắt.

---

## 7. PHASE 5 — Validate dữ liệu + errorCode (FR-04.1/4.2, FR-09, UC05, NFR-06)

**File:** `IO/file.asm` (mở rộng sau `FILE_ReadMaze`) hoặc thủ tục mới `FILE_ValidateMaze` trong `core`.

### 7.1. Luồng đề xuất
1. `FILE_ReadMaze` trả `EAX=0` nếu không mở được file → set `errorCode=1`.
2. Nếu `file_size = 0` → `errorCode=2`.
3. Tạo thủ tục `MAIN_ValidateMaze` chạy SAU khi đọc:
   - [ ] Duyệt `rows*cols` ký tự trong `maze`, kiểm tra chỉ thuộc `{'0','1','S','E',' '}`. Sai → `errorCode=3`.
   - [ ] Đếm số `S`. Nếu 0 → `errorCode=4`. Lưu `startX/startY` tại `S` đầu tiên.
   - [ ] Đếm số `E`. Nếu 0 → `errorCode=5`. Lưu `endX/endY`.
   - [ ] Kiểm tra `cols*rows ≤ 1600`. Sai → `errorCode=6`.
   - [ ] Kiểm tra các dòng đều nhau (ragged). **Lưu ý**: hiện `FILE_ReadMaze` strip hết newline nên KHÔNG còn biên dòng để kiểm tra ragged. Cần kiểm tra ragged NGAY trong `FILE_ReadMaze` (so độ dài mỗi dòng với `cols` trước khi strip). Sai → `errorCode=7`.
   - [ ] Tất cả OK → `errorCode=0`, `EAX=1`.

### 7.2. Điều chỉnh `FILE_ReadMaze` (để bắt errorCode 2 & 7)
- [ ] Thêm: nếu `file_size = 0` → set `errorCode=2`, trả `EAX=0`.
- [ ] Trong Pass 2 (đếm rows): so sánh độ dài từng dòng với `cols`; nếu lệch → đánh dấu ragged → `errorCode=7`.
- [ ] Giữ nguyên auto-detect cols/rows đã có.

### 7.3. Tích hợp vào luồng giải (main.asm)
- [ ] `do_solve_file`: gọi `FILE_ReadMaze`. Nếu `EAX=0` → `jmp show_error` (đọc `errorCode`, in `err_*` tương ứng).
- [ ] Gọi `MAIN_ValidateMaze`. Nếu `EAX=0` → `jmp show_error`.
- [ ] `show_error`: switch theo `errorCode` in chuỗi `err_1..err_7`, chờ phím, `jmp menu_loop`.

### 7.4. Checklist Phase 5
- [ ] File không tồn tại → "Khong tim thay file" (err 1).
- [ ] File rỗng → "File rong" (err 2).
- [ ] File có ký tự lạ (vd 'a') → "sai dinh dang" (err 3).
- [ ] File thiếu S → err 4; thiếu E → err 5.
- [ ] File > 1600 ô → err 6.
- [ ] File dòng lệch nhau → err 7.
- [ ] File hợp lệ → `startX/Y`, `endX/Y` đúng tọa độ; vào DFS.
- [ ] NFR-08: không ghi/sửa file (chỉ đọc).

---

## 8. PHASE 6 — Đếm thống kê trong DFS (FR-06, FR-08)

**File:** `core/core.asm` (`DFS_Solve`).

### 8.1. Việc cụ thể
- [ ] Reset đầu `DFS_Solve`: `cells_examined=0`, `dfs_result=0` (dfs_steps đã có reset ở main).
- [ ] Tại nhánh đánh dấu ô mới `'V'` (mỗi ô lần đầu được xét): `inc dword [cells_examined]`.
- [ ] Tại `DFS_Found`: `mov byte [dfs_result], 1`.
- [ ] Khi stack rỗng mà chưa found (`DFS_End`): `dfs_result` giữ 0.
- [ ] Giữ nguyên `dfs_steps` và `DFS_UpdateStatus`.

### 8.2. Checklist Phase 6
- [ ] Mê cung giải được → `dfs_result=1`, `cells_examined>0`.
- [ ] Mê cung không có đường (chắn E) → `dfs_result=0`, không treo (NFR-03).
- [ ] `cells_examined` ≤ tổng số ô đường.
- [ ] DFS vẫn animate từng bước như cũ.

---

## 9. PHASE 7 — Màn kết quả + thống kê (FR-08, UC08)

**File:** `main.asm` nhãn `show_result`.

### 9.1. Việc cụ thể
- [ ] Sau `DFS_Solve` (trong `do_solve_file`) → `jmp show_result` thay cho `msg_done` cũ.
- [ ] In tiêu đề kết quả.
- [ ] `cmp byte [dfs_result],1` → in `r_found` (xanh) / `r_notfound` (đỏ).
- [ ] In `r_steps` + `UI_PrintDec4 [dfs_steps]`.
- [ ] In `r_cells` + `UI_PrintDec4 [cells_examined]`.
- [ ] In sub-menu: `r_menu1/2/3`.
- [ ] Đọc phím: `1`→ `jmp choose_file` (giải khác), `2`→`jmp menu_loop`, `3`→`do_exit`, khác→lặp.

### 9.2. Checklist Phase 7
- [ ] Found → hiện thông báo xanh + số liệu đúng.
- [ ] Not found → hiện thông báo đỏ.
- [ ] Số bước/ô xét hiển thị đúng định dạng số.
- [ ] Sub-menu 1/2/3 hoạt động; phím sai không treo.
- [ ] Vị trí in không đè lên mê cung (đặt `coord_y` dưới mê cung: `rows + offset`).

---

## 10. PHASE 8 — Màn thông tin nhóm (UC08 phần info)

**File:** `main.asm` nhãn `show_info`.

### 10.1. Việc cụ thể
- [ ] Clear screen → in `info_*` (tên dự án, mô tả, ngôn ngữ, môi trường, 3 thành viên + vai trò UI/IO/Core).
- [ ] Dòng cuối "Bam phim de quay lai" → `UI_WaitKey` → `jmp menu_loop`.

### 10.2. Checklist Phase 8
- [ ] Hiển thị đủ thông tin, ASCII.
- [ ] Bấm phím quay lại menu.

---

## 11. PHASE 9 — Tích hợp generator (bonus) & dọn nhánh cũ

**File:** `main.asm`.

### 11.1. Việc cụ thể
- [ ] `do_generate` (menu mục 6): giữ luồng cũ `speed_menu → display_menu → generate_maze`, sau khi giải xong → `jmp show_result` (dùng chung màn kết quả mới).
- [ ] `do_solve_file` (mục 1): bỏ qua speed/display menu HOẶC vẫn hỏi speed/display trước khi vẽ (tùy chọn — khuyến nghị giữ hỏi speed để demo).
- [ ] Xóa/đấu nối lại các nhãn cũ không còn dùng (`mode_easy/medium/hard` gộp vào `do_generate` + chọn level).
- [ ] Bảo đảm KHÔNG còn nhãn mồ côi gây lỗi NASM.

### 11.2. Checklist Phase 9
- [ ] Mục 6 vẫn sinh mê cung + giải + ra màn kết quả mới.
- [ ] Mục 1 đọc file + validate + giải + kết quả.
- [ ] Không còn nhãn thừa, build sạch.

---

## 12. PHASE 10 — Build & Verify tổng (NFR-01)

### 12.1. Lệnh build (PowerShell)
```powershell
cd "d:\desktop\KienTrucMayTinh-HopNgu\New folder\doan\Asm-maze-solver-win32-nasm"
.\build.bat
```

### 12.2. Ma trận kiểm thử (chạy `maze_solver.exe`)
| TC | Thao tác | Kỳ vọng |
|---|---|---|
| TC-01 | Mở app | Hiện menu 6 mục + tiêu đề |
| TC-02 | Nhập `9` | Báo invalid, không thoát |
| TC-03 | Mục 2 | Màn hướng dẫn, bấm phím về menu |
| TC-04 | Mục 3 → 1 | Giải `maze.txt`, ra kết quả |
| TC-05 | Mục 3 → 2 → `1-maze.txt` | Giải đúng file nhập |
| TC-06 | Mục 3 → 2 → `khong_ton_tai.txt` | err 1 |
| TC-07 | File thiếu S | err 4 |
| TC-08 | File thiếu E | err 5 |
| TC-09 | File ký tự lạ | err 3 |
| TC-10 | File dòng lệch | err 7 |
| TC-11 | `maze.txt` (39×14) | Hiển thị ĐÚNG (bug cũ đã fix) |
| TC-12 | Mê cung chắn E | Not found, không treo |
| TC-13 | Mục 6 (generator) | Sinh + giải + kết quả |
| TC-14 | Màn kết quả → 1/2/3 | Giải khác / menu / thoát đúng |
| TC-15 | Mục 4 | Thông tin nhóm |
| TC-16 | Mục 5 | Thoát sạch |

### 12.3. Checklist Phase 10
- [ ] `nasm -f win32 main.asm` không warning/error.
- [ ] `gcc -m32` link thành công.
- [ ] 16 TC ở trên PASS.
- [ ] File mê cung KHÔNG bị sửa sau khi chạy (NFR-08).
- [ ] Không treo ở mọi nhánh nhập sai (NFR-03).

---

## 13. Ma trận truy vết yêu cầu (Requirement Traceability)

| Yêu cầu | Phase | Trạng thái |
|---|---|---|
| FR-01 Menu chính | 2 | [ ] |
| FR-02 Nhận lựa chọn | 2 | [ ] |
| FR-03 Hướng dẫn | 3 | [ ] |
| FR-04 Chọn/đọc file | 4 | [ ] |
| FR-04.1 Kích thước | 5 (có sẵn 1 phần) | [ ] |
| FR-04.2 Tìm S/E | 5 | [ ] |
| FR-04.3 Đóng file | có sẵn | [x] |
| FR-05 Vẽ mê cung | có sẵn | [x] |
| FR-06 Chạy DFS | có sẵn + 6 | [~] |
| FR-07 Hoạt ảnh | có sẵn | [x] |
| FR-08 Thống kê | 6,7 | [ ] |
| FR-09 Xử lý lỗi | 5 | [ ] |
| FR-10 Thoát | 2 | [ ] |
| FR-11 Tốc độ | có sẵn | [x] |
| NFR-01 Môi trường | 10 | [ ] |
| NFR-02 Dễ đọc ASCII | 2,3,7,8 | [ ] |
| NFR-03 Ổn định | tất cả | [ ] |
| NFR-04 Tách module | có sẵn | [x] |
| NFR-05 Bảo toàn thanh ghi | tất cả | [ ] |
| NFR-06 Validate | 5 | [ ] |
| NFR-07 Giới hạn bộ nhớ | 5 | [ ] |
| NFR-08 Không sửa file | 5,10 | [ ] |

---

## 14. Quy tắc vàng khi code (KHẮC KHE — đọc trước mỗi phase)

- [ ] **Bảo toàn thanh ghi (NFR-05)**: mọi thủ tục mới phải `push/pop` đầy đủ các thanh ghi nó dùng (theo đúng pattern `push ebp/mov ebp,esp ... leave/ret` đang có). DFS đang dùng `ebx,ecx,edx,esi,edi` — UI/IO không được phá.
- [ ] **ASCII only (NFR-02)**: không nhập ký tự có dấu/Unicode vào chuỗi `.data`.
- [ ] **ASCIIZ**: mọi chuỗi truyền `UI_PrintZ` phải kết thúc `,0`.
- [ ] **Stack balance**: gọi WinAPI `stdcall` — API tự dọn stack; KHÔNG tự `add esp` sau các hàm `@N` đã có hậu tố số byte.
- [ ] **Không sửa file (NFR-08)**: chỉ mở `GENERIC_READ`.
- [ ] **Không treo (NFR-03)**: mọi vòng đọc phím nhập sai phải có đường quay lại, không loop chết.
- [ ] **Đặt vị trí in dưới mê cung**: dùng `[rows] + offset` cho `coord_y` để không đè bản đồ.
- [ ] **Build sau mỗi phase**: không dồn nhiều phase rồi mới build — khó lần lỗi.
- [ ] **Một thay đổi nhỏ → 1 lần build**: bám checklist từng phase.

---

## 15. Thứ tự thực thi khuyến nghị

```
Phase 1 (biến/chuỗi)  ──►  Phase 2 (menu)  ──►  Phase 3 (hướng dẫn)
   └──►  Phase 5 (validate) cần Phase 1
Phase 4 (chọn file) ──► cần Phase 5 để báo lỗi
Phase 6 (đếm DFS) ──► Phase 7 (kết quả) cần Phase 6
Phase 8 (info)  ──►  Phase 9 (generator+dọn)  ──►  Phase 10 (build & test)
```

Khuyến nghị làm tuyến: **1 → 2 → 3 → 5 → 4 → 6 → 7 → 8 → 9 → 10**.

---

## 16. Definition of Done (DoD) toàn dự án
- [ ] Tất cả checklist từng phase đã `[x]`.
- [ ] 16 test case (mục 12.2) PASS.
- [ ] Ma trận truy vết (mục 13) không còn `[ ]` ở các FR/NFR trong phạm vi.
- [ ] Build sạch, không warning.
- [ ] README cập nhật phần menu mới (nếu menu đổi).
- [ ] Cập nhật báo cáo: ghi rõ các điểm "nới đặc tả" ở mục 0.2.


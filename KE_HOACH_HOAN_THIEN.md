# KẾ HOẠCH HOÀN THIỆN HỆ THỐNG — ASM Maze Solver

> Nhiệm vụ: kế hoạch + checklist để hoàn thiện & kiểm chứng chức năng. KHÔNG chứa code.
> Checkbox: `[ ]` chưa làm · `[x]` xong · `[~]` một phần.

---

## 0. Phát hiện hiện trạng (đọc từ code thực tế)

Khác với giả định "chỉ có giao diện", luồng chức năng trong `main.asm` ĐÃ được nối dây:

| Menu | Luồng đã nối | Thủ tục gọi |
|---|---|---|
| 1. Giải (file) | ✅ | `mode_file → speed_menu → display_menu → load_file → FILE_ReadMaze → MAIN_ValidateMaze → MAIN_DrawFullMaze → DFS_Solve → show_result` |
| 2. Hướng dẫn | ✅ | `show_help` (in text) |
| 3. Chọn file | ✅ | `choose_file → file_default / file_input` |
| 4. Thông tin | ✅ | `show_info` |
| 5. Thoát | ✅ | `exit → ExitProcess` |
| 6. Generator | ✅ | `gen_menu → mode_easy/medium/hard → ... → generate_maze` |

**Kết luận:** Không cần viết lại chức năng. Việc cần làm là **kiểm chứng runtime từng chức năng** + **sửa các bug tiềm ẩn** phát hiện khi đọc code (Mục 1) + **hoàn thiện các điểm còn yếu** (Mục 2).

> Bước đầu tiên bắt buộc: **rebuild** `build.bat` để chắc chắn exe khớp code mới nhất. Rất có thể cảm giác "chức năng chưa có" đến từ exe cũ.

---

## 1. Bug / điểm nghi ngờ cần kiểm tra (phát hiện khi đọc code)

> Đây là các giả thuyết cần XÁC MINH khi chạy, không phải lỗi đã xác nhận.

### 1.1. [NGHI NGỜ CAO] `DFS_Solve` dùng `ah` lưu ký tự gốc nhưng bị hàm con phá
- **Vị trí:** `core/core.asm`, đoạn `mov ah, al` (lưu ký tự ô trước khi ghi `'V'`), sau đó gọi `DFS_UpdateStatus`, `UI_SetColor`, `UI_DrawCell`, `UI_DrawChar`.
- **Rủi ro:** các hàm UI dùng `eax` (set color nhận màu qua eax, PrintDec dùng eax...). Khi trả về, `ah` gần như chắc chắn đã bị thay đổi → nhánh `cmp al, 'S'` / khôi phục ô bị sai.
- **Hệ quả khả kiến:** ô 'S' bị vẽ đè thành '@'/'.', hoặc màu/ký tự nhấp nháy sai. KHÔNG làm treo, nhưng hiển thị lệch.
- [ ] Xác minh: chạy, quan sát ô S sau khi DFS đi qua có còn đúng không.
- [ ] Nếu sai: lưu ký tự gốc vào biến nhớ (vd `dfs_prev_char db 0`) thay vì `ah`.

### 1.2. [NGHI NGỜ TRUNG BÌNH] Vẽ lại khi "Giải mê cung khác" từ màn kết quả
- **Vị trí:** `show_result` mục `1` → `choose_file`. Màn hình cũ (mê cung + kết quả) chưa được clear toàn bộ trước khi vào `choose_file`.
- **Thực tế:** `choose_file` có `UI_ClearScreen` ở đầu nên có thể OK.
- [ ] Xác minh: bấm 1 ở màn kết quả → màn chọn file có sạch không.

### 1.3. [NGHI NGỜ TRUNG BÌNH] `MAIN_ValidateMaze` chạy cho cả nhánh generator
- **Vị trí:** `after_load` luôn gọi `MAIN_ValidateMaze`.
- **Rủi ro:** nếu generator sinh mê cung kích thước > 1600 hoặc thiếu S/E ở rìa → bị báo lỗi errorCode dù không phải file.
- [ ] Xác minh: chạy generator Hard (30×30 = 900 ≤ 1600 OK) — kiểm tra không bị rơi vào `show_error`.

### 1.4. [CẦN KIỂM TRA] Đường dẫn file tương đối khi nhập tên file
- **Vị trí:** `file_input` copy tên vào `maze_file`, `CreateFileA` mở theo thư mục hiện hành.
- **Rủi ro:** chạy exe từ thư mục khác → không thấy file.
- [ ] Xác minh: nhập `1-maze.txt` khi chạy exe từ chính thư mục dự án.

### 1.5. [CẦN KIỂM TRA] `MAIN_ValidateMaze` đếm S/E — chấp nhận nhiều S/E?
- **Rủi ro:** file có 2 'S' → validate vẫn pass, DFS dùng S đầu tiên. Đặc tả nói "đúng một S/E".
- [ ] Quyết định: có cần báo lỗi khi nhiều S/E không? (đề xuất: bỏ qua, dùng cái đầu — ghi chú trong đặc tả).

---

## 2. Điểm còn yếu so với đặc tả (tùy chọn hoàn thiện)

| # | Hạng mục | Hiện trạng | Đề xuất |
|---|---|---|---|
| 2.1 | Hỏi tốc độ/hiển thị cho nhánh GIẢI FILE | Có hỏi (dùng chung speed/display) | OK — giữ |
| 2.2 | Khung viền `+===+` các màn | Chỉ tiêu đề text | Tùy chọn: thêm dòng `===` phân cách |
| 2.3 | Thống kê số lần quay lui | Không có | Ngoài phạm vi (đã chốt) |
| 2.4 | Thông báo "Dang giai..." rõ ràng | Có `msg_start` | OK |
| 2.5 | Xử lý phím ESC ở màn help/info | Bất kỳ phím nào | OK theo thực tế |

---

## 3. PHASE 0 — Rebuild & smoke test (BẮT BUỘC TRƯỚC TIÊN)

**Mục tiêu:** loại bỏ khả năng exe cũ gây cảm giác "thiếu chức năng".

- [ ] Mở PowerShell tại thư mục dự án.
- [ ] Chạy `.\build.bat` → xác nhận "Build successful".
- [ ] Chạy `.\maze_solver.exe` → menu 6 mục hiện ra.
- [ ] Thử lần lượt phím 1–6 + 1 phím sai, ghi nhận hành vi thực tế vào cột "Kết quả" của Mục 5.

```powershell
cd "d:\desktop\KienTrucMayTinh-HopNgu\New folder\doan\asm-maze-solver-win32-nasm"
.\build.bat
.\maze_solver.exe
```

---

## 4. PHASE 1 — Audit & sửa bug runtime

> Chỉ sửa khi Phase 0 + Mục 5 xác nhận có lỗi thật. Mỗi sửa = 1 build lại.

### 4.1. Checklist xử lý bug 1.1 (ah bị phá)
- [ ] Quan sát: sau khi DFS đi qua, ô `S` còn hiển thị `S` màu xanh?
- [ ] Nếu sai → thêm biến `dfs_prev_char db 0` trong `.data`.
- [ ] Thay mọi chỗ đọc/ghi `ah` (lưu ký tự ô) bằng `dfs_prev_char`.
- [ ] Build lại, kiểm tra ô S/space khôi phục đúng.

### 4.2. Checklist xử lý bug 1.3 (validate cho generator)
- [ ] Chạy generator Easy/Medium/Hard, xác nhận KHÔNG rơi vào `show_error`.
- [ ] Nếu có lỗi → cho nhánh generator bỏ qua `MAIN_ValidateMaze` (chỉ validate cho `mode_kind=0`).

### 4.3. Checklist xử lý bug 1.2 / 1.4 / 1.5
- [ ] 1.2: bấm "Giải khác" từ kết quả → màn chọn file sạch.
- [ ] 1.4: nhập tên file tồn tại → mở đúng; tên sai → err_1.
- [ ] 1.5: chốt hành vi nhiều S/E (đề xuất giữ nguyên + ghi chú đặc tả).

---

## 5. PHASE 2 — Ma trận kiểm chứng chức năng (điền khi chạy)

| TC | Thao tác | Kỳ vọng | Kết quả thực tế | Đạt? |
|---|---|---|---|---|
| TC-01 | Mở app | Menu 6 mục + tiêu đề | | [ ] |
| TC-02 | Phím `9` | "Lua chon khong hop le", không thoát | | [ ] |
| TC-03 | Phím `2` (help) | Màn hướng dẫn, bấm phím về menu | | [ ] |
| TC-04 | Phím `4` (info) | Màn thông tin, về menu | | [ ] |
| TC-05 | `3` → `1` (maze.txt) | Giải `maze.txt` 39×14, hiển thị đúng | | [ ] |
| TC-06 | `3` → `2` → `1-maze.txt` | Giải đúng file nhập | | [ ] |
| TC-07 | `3` → `2` → `khong_co.txt` | err_1 | | [ ] |
| TC-08 | File thiếu S | err_4 | | [ ] |
| TC-09 | File thiếu E | err_5 | | [ ] |
| TC-10 | File ký tự lạ | err_3 | | [ ] |
| TC-11 | File dòng lệch | err_7 | | [ ] |
| TC-12 | Mê cung chắn E | Not found + thống kê, không treo | | [ ] |
| TC-13 | `6` → Easy | Sinh + giải + kết quả | | [ ] |
| TC-14 | `6` → Medium/Hard | Sinh + giải + kết quả | | [ ] |
| TC-15 | Speed 1/2/3 | Tốc độ animation khác nhau rõ | | [ ] |
| TC-16 | Display 1/2/3 | Kiểu vẽ khác nhau | | [ ] |
| TC-17 | Màn kết quả → `1` | Về chọn file | | [ ] |
| TC-18 | Màn kết quả → `2` | Về menu | | [ ] |
| TC-19 | Màn kết quả → `3` | Thoát | | [ ] |
| TC-20 | Phím `5` ở menu | Thoát sạch | | [ ] |
| TC-21 | Ô S sau khi DFS qua | Vẫn hiển thị đúng (bug 1.1) | | [ ] |

---

## 6. PHASE 3 — Hoàn thiện tùy chọn (chỉ làm nếu còn thời gian)

- [ ] 2.2: thêm dòng phân cách `===` dưới tiêu đề các màn cho đẹp.
- [ ] Thống nhất vị trí in (mọi màn dùng offset chuẩn, không đè nhau).
- [ ] Kiểm tra màu `UI_ResetColor` áp dụng nhất quán sau mỗi đoạn tô màu.

---

## 7. Quy tắc khi sửa (KHẮC KHE)
- [ ] **Một bug → một sửa → một build → một test.** Không gộp.
- [ ] Bảo toàn thanh ghi: nếu cần giữ giá trị qua lời gọi hàm UI, LƯU VÀO BIẾN NHỚ, không dựa vào `ah/al` (NFR-05).
- [ ] Không đổi ký hiệu/màu đang dùng.
- [ ] Chỉ đọc file (NFR-08), không ghi.
- [ ] Sau mỗi sửa, chạy lại GetDiagnostics + build.

---

## 8. Thứ tự thực hiện khuyến nghị
```
Phase 0 (rebuild + smoke) ──► Phase 2 (điền ma trận TC, tìm lỗi thật)
   └──► Phase 1 (chỉ sửa bug đã xác nhận) ──► test lại TC liên quan
   └──► Phase 3 (hoàn thiện thẩm mỹ, nếu còn thời gian)
```

## 9. Definition of Done
- [ ] `build.bat` thành công, không warning.
- [ ] 21 test case Phase 2 đều Đạt.
- [ ] Bug 1.1 (ô S) đã xác minh/đã sửa.
- [ ] Generator (TC-13/14) không bị validate chặn nhầm.
- [ ] Cập nhật đặc tả v2 nếu có thay đổi hành vi.


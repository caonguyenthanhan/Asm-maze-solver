# **🧭 asm-maze-solver**

**asm-maze-solver** là một ứng dụng Console được viết hoàn toàn bằng ngôn ngữ bậc thấp **Assembly (x86 16-bit)** trên môi trường giả lập DOS.

Dự án áp dụng trí tuệ nhân tạo (AI) cơ bản thông qua thuật toán **Tìm kiếm theo chiều sâu (DFS - Depth-First Search)** và kỹ thuật **Quay lui (Backtracking)** để tự động đọc bản đồ, dò đường và vẽ hoạt ảnh tìm lối thoát khỏi mê cung thời gian thực.

## **🚀 Các Tính Năng Chính (Features)**

Dự án được chia thành 3 module chính, tương ứng với nhiệm vụ của 3 thành viên:

1. **Module Dữ Liệu (File I/O):**

   * Đọc bản đồ mê cung từ file maze.txt.
   * Chuyển đổi dữ liệu thô thành mảng 1 chiều quản lý trong bộ nhớ RAM.
   * Định vị tọa độ Điểm bắt đầu (Start) và Điểm kết thúc (End).

2. **Module Thuật Toán (AI \& Logic):**

   * Triển khai thuật toán **DFS** bằng cơ chế Ngăn xếp (Stack) thủ công tự xây dựng (không dùng trực tiếp Stack hệ thống để tránh lỗi xung đột CALL/RET).
   * Xử lý logic di chuyển 4 hướng và Quay lui (Backtracking) khi gặp ngõ cụt.

3. **Module Giao Diện (UI \& Animation):**

   * Sử dụng ngắt BIOS (INT 10h) để điều khiển con trỏ và vẽ ký tự.
   * Sử dụng ngắt hệ thống (INT 15h hoặc vòng lặp delay) để tạo hoạt ảnh (animation) dò đường từ từ thay vì in kết quả ngay lập tức.

## **🛠️ Yêu Cầu Hệ Thống (Prerequisites)**

Do chương trình được viết cho kiến trúc x86 16-bit (MS-DOS), bạn cần sử dụng một trong các phần mềm giả lập sau để chạy:

* [**emu8086**](https://emu8086-microprocessor-emulator.en.softonic.com/)**:** Khuyến nghị cho việc phát triển và debug (dành cho Windows).
* [**DOSBox**](https://www.dosbox.com/)**:** Kết hợp với TASM hoặc MASM (Hỗ trợ đa nền tảng: Windows, macOS, Linux).

## **🗂️ Cấu Trúc File Mê Cung (maze.txt)**

File dữ liệu phải nằm cùng thư mục với file thực thi. Dữ liệu sử dụng trực tiếp các ký tự ASCII để mô tả bản đồ:

* '1': Tường (Wall)
* '0': Đường đi (Path)
* 'S': Điểm xuất phát (Start)
* 'E': Điểm đích (End)

*Ví dụ một file maze.txt:*

1111111111  
1S00100011  
1110101111  
1000000001  
1011111101  
1000001001  
1111101011  
1000101011  
10100000E1  
1111111111

## **⚙️ Hướng Dẫn Cài Đặt Và Chạy**

### **Cách 1: Sử dụng emu8086 (Dễ nhất)**

1. Clone repository này về máy:  
   git clone https://github.com/caonguyenthanhan/Asm-maze-solver.git
2. Mở phần mềm emu8086.
3. Nhấn **Open** và chọn file main.asm trong thư mục vừa tải về.
4. Đảm bảo file maze.txt nằm trong cùng thư mục gốc (hoặc thư mục MyBuild của emu8086 tùy thuộc vào cấu hình đường dẫn).
5. Nhấn **Emulate** sau đó nhấn **Run** để xem AI giải mê cung.

### **Cách 2: Sử dụng DOSBox + TASM**

1. Mount thư mục chứa code vào DOSBox.
2. Dịch file .asm sang .obj:  
   tasm main.asm
3. Link file .obj sang .exe:  
   tlink main.obj
4. Chạy chương trình:  
   main.exe

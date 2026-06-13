@echo off
setlocal
cd /d "%~dp0"
nasm -f win32 demo_ui.asm -o demo_ui.o
if errorlevel 1 exit /b 1
gcc -m32 demo_ui.o -o ui_demo.exe -lkernel32
if errorlevel 1 exit /b 1
echo Build OK: ui_demo.exe

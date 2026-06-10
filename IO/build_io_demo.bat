@echo off
setlocal
cd /d "%~dp0"
nasm -f win32 demo_io.asm -o demo_io.o
if errorlevel 1 exit /b 1
gcc -m32 demo_io.o -o io_demo.exe -lkernel32
if errorlevel 1 exit /b 1
echo Build OK: io_demo.exe

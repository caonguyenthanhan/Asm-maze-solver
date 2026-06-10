@echo off
setlocal
cd /d "%~dp0"
nasm -f win32 demo_core.asm -o demo_core.o
if errorlevel 1 exit /b 1
gcc -m32 demo_core.o -o core_demo.exe -lkernel32
if errorlevel 1 exit /b 1
echo Build OK: core_demo.exe

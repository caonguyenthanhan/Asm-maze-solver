
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
set "PATH=C:\msys64\mingw32\bin;%PATH%"
echo Building maze_solver.exe...
nasm -f win32 main.asm -o main.o
if errorlevel 1 (
    echo NASM failed!
    pause
    exit /b 1
)
gcc -m32 main.o -o maze_solver.exe -lkernel32
if errorlevel 1 (
    echo Linking failed!
    pause
    exit /b 1
)
echo Build successful! Run maze_solver.exe
pause

@echo off

:: Set this to where DIV3 is installed. 
:: NOTE: The slash on the end is important.
set "DIV_INSTALL_DIR=C:\Projects\DIV\div-beta-nightly\"

:: Remember program directory.
set "PROGRAM_DIR=%~dp0"

:: Change to DIV directory and run DIV debugger on the compiled executable.
cd %DIV_INSTALL_DIR%
echo Running executable in debug mode...
call system\divdbg-WINDOWS.exe system\EXEC.EXE

:: Change to program directory.
echo Finished running executable.
cd %PROGRAM_DIR%

@echo off

:: Set this to where DIV3 is installed. 
:: NOTE: The slash on the end is important.
set "DIV_INSTALL_DIR=C:\Projects\DIV\div-beta-nightly\"

:: Remember program directory.
set "PROGRAM_DIR=%~dp0"

:: Change to DIV directory and run compiler on .PRG file.
cd %DIV_INSTALL_DIR%
echo Compiling...
call system\div-WINDOWS.exe -c "%PROGRAM_DIR%faust2.prg"

:: Change to program directory and copy over exec.path.
:: TODO: This batch script should automatically create and populate exec.path so you don't have to bother with configuring it.
echo Copying exec.path...
xcopy /y "%PROGRAM_DIR%exec.path" "%DIV_INSTALL_DIR%system\"

:: Change to DIV directory and run debugger on the outputted executable.
echo Running executable in debug mode...
call system\divdbg-WINDOWS.exe system\EXEC.EXE

:: Change to program
echo Finished running executable.
cd %PROGRAM_DIR%

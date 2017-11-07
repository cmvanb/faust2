@echo off

:: Set this to where DIV3 is installed. 
:: NOTE: The slash on the end is important.
set "DIV_INSTALL_DIR=C:\Projects\DIV\div-beta-nightly\"

:: Remember program directory.
set "PROGRAM_DIR=%~dp0"

:: Change to DIV directory and run compiler on .PRG file.
cd %DIV_INSTALL_DIR%
echo Compiling...
echo system\div-WINDOWS.exe -c "%PROGRAM_DIR%faust2.prg"
call system\div-WINDOWS.exe -c "%PROGRAM_DIR%faust2.prg"

:: TODO: This batch script should automatically create and populate exec.path so you don't have to bother with configuring it.
:: Copy over exec.path, this is needed for the DIV compiler to know where the program's assets are located.
echo Copying exec.path...
xcopy /y "%PROGRAM_DIR%exec.path" "%DIV_INSTALL_DIR%system\"

:: Change to program directory.
echo Finished compiling.
cd %PROGRAM_DIR%


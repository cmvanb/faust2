@echo off

:: Set this to where DIV3 is installed. 
:: NOTE: The slash on the end is important.
set "DIV_INSTALL_DIR=C:\Projects\DIV\div-beta-nightly\"

:: Remember program directory.
set "PROGRAM_DIR=%~dp0"
set "PROGRAM_FILE=faust2.prg"

:: Change to DIV directory and run compiler on .PRG file.
cd %DIV_INSTALL_DIR%
echo Compiling...
call system\div-WINDOWS.exe -c "%PROGRAM_DIR%%PROGRAM_FILE%"

:: Copy over exec.path, this is needed for the DIV compiler to know where the program's assets are located.
xcopy /y "%PROGRAM_DIR%exec.path" system\

:: NOTE: DOESN'T ACTUALLY WORK FOR DIV COMPILER. COPYING OVER DIV3-GENERATED exec.path APPEARS TO BE ONLY SOLUTION.
:: Write the program directory to exec.path.
::echo Writing %PROGRAM_DIR:~0,-1% to %DIV_INSTALL_DIR%system\exec.path...
::echo %PROGRAM_DIR:~0,-1%> system\exec.path

:: Run DIV debugger on the compiled executable.
echo Running executable in debug mode...
call system\divdbg-WINDOWS.exe "system\EXEC.EXE"

:: Change to program directory.
echo Finished compiling.
cd %PROGRAM_DIR%



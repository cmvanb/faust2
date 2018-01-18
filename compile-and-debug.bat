@echo off

:: Set this to where DIV3 is installed. 
:: NOTE: The slash on the end is important.
set "DIV_INSTALL_DIR=C:\Projects\DIV\DIV-Games-Studio\"
set "DIV_SYSTEM_DIR=%DIV_INSTALL_DIR%system\"

:: stdout.txt contains compilation output.
set "DIV_STDOUT_FILE=%DIV_SYSTEM_DIR%stdout.txt"

:: Set the program directory, usually the current directory.
set "PRG_DIR=%~dp0"

:: Set the file to be compiled.
::set "PRG_FILE=%PRG_DIR%faust2.prg"
set "PRG_FILE=%PRG_DIR%%1"

type %PRG_FILE% > nul
if errorlevel 1 (
    echo Did you forget to pass the .prg parameter?
    goto nocompile
)

:: exec.path contains the program directory, it is needed by the DIV debugger.
set "PRG_EXECPATH_FILE=%PRG_DIR%exec.path"

:: Write exec.path, using PowerShell script. Using windows batch to write this
:: file doesn't work because windows batch adds a few extra bytes to the end
:: of every file. Those extra bytes break DIV's interpreter!
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PRG_DIR%write-exec-path.ps1'"

:: Change to DIV directory and run compiler on .PRG file.
cd %DIV_INSTALL_DIR%
echo Compiling...
call system\div-WINDOWS.exe -c "%PRG_FILE%"

:: Copy over exec.path, this is needed for the DIV debugger to know where the 
:: program's assets are located. We do this after compiling because compiling
:: will create an empty exec.path in the system directory.
xcopy /y %PRG_EXECPATH_FILE% %DIV_SYSTEM_DIR% > nul

:: Check if stdout.txt exists, and if so check for compilation errors.
:: NOTE: Find command will return errorlevel 0 if it finds the string, and 
:: errorlevel 1 if it doesn't.
if exist %DIV_STDOUT_FILE% (
    find "error" %DIV_STDOUT_FILE% > nul
    if not errorlevel 1 (
        findstr "error" %DIV_STDOUT_FILE%
        goto nocompile
    ) else (
        goto compile
    )
) else (
    echo stdout.txt missing from %DIV_SYSTEM_DIR%.
    goto nocompile
)


:compile
echo ...compilation successful!

:: Run DIV debugger on the compiled executable.
echo Running executable in debug mode...
call system\divdbg-WINDOWS.exe "system\EXEC.EXE"

echo ...finished debugging.
goto done

:nocompile
:: Print errors found.
echo ...compilation failed.
goto done

:done
:: Change to program directory.
cd %PRG_DIR%



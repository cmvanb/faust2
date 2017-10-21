@echo off

set "DIV_INSTALL_DIR=C:\Projects\DIV\div-beta-nightly\"

call %DIV_INSTALL_DIR%\system\div-WINDOWS.exe -c faust2.prg

xcopy exec.path %DIV_INSTALL_DIR%\system\

call %DIV_INSTALL_DIR%\system\divdbg-WINDOWS.exe %DIV_INSTALL_DIR%\system\EXEC.EXE

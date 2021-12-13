@echo off
set current_dir=%~dp0

PUSHD %CURRENT_DIR%\3rd\ant
%CURRENT_DIR%\..\luamake\luamake.exe -mode release
%CURRENT_DIR%\..\luamake\luamake.exe tools -mode release
POPD

pause
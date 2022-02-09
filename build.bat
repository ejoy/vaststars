@echo off
set current_dir=%~dp0

title build debug - %current_dir%
pushd %CURRENT_DIR%
luamake.exe -mode debug
luamake.exe tools -mode debug
popd

pause
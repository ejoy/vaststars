@echo off
set current_dir=%~dp0

title build debug - %current_dir%
pushd %CURRENT_DIR%
luamake.exe -mode debug %1 %2
luamake.exe tools -mode debug %1 %2
popd

pause
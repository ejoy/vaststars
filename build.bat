@echo off
set current_dir=%~dp0

pushd %CURRENT_DIR%
%CURRENT_DIR%\..\luamake\luamake.exe -mode release
popd

pushd %CURRENT_DIR%\3rd\ant\
%CURRENT_DIR%\..\luamake\luamake.exe -mode release
%CURRENT_DIR%\..\luamake\luamake.exe tools -mode release
popd

pause
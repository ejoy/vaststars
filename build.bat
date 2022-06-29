@echo off
set current_dir=%~dp0
set mode=debug
title build %mode% - %current_dir%
pushd %CURRENT_DIR%
luamake.exe -mode %mode% %1 %2
luamake.exe tools -mode %mode% %1 %2
popd

pause
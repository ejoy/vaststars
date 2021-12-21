@echo off
@set current_dir=%~dp0

pushd %current_dir%
%current_dir%bin\msvc\release\vaststars.exe
popd

pause
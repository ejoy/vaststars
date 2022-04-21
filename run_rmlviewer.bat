@echo off
chcp 65001
set current_dir=%~dp0
set exe=bin\msvc\debug\vaststars.exe
set titlemsg=debug
set param=.\3rd\ant\tools\rmlviewer\main.lua
set /p rml=rml file:

:AGAIN

pushd %current_dir%
if not exist "%exe%" (
	set exe=bin\msvc\release\vaststars.exe
	set titlemsg=release
)

%current_dir%%exe% %param% %rml%
popd

goto AGAIN

pause
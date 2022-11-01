@echo off
chcp 65001
set current_dir=%~dp0
set mode=release
set exe=bin\msvc\%mode%\vaststars.exe
set cachedir=.build
set param=.\3rd\ant\tools\rmlviewer\main.lua
set /p rml=rml file:

:AGAIN

pushd %current_dir%
if exist "%cachedir%" (
	rem rd /s /q %cachedir%
)

if not exist "%exe%" (
	set mode=debug
	set exe=bin\msvc\debug\vaststars.exe
)

title %mode% - %current_dir%%exe%
%current_dir%%exe% %param% %rml%
popd

goto AGAIN

pause
@echo off
@chcp 65001 >nul

set current_dir=%~dp0
set cachedir=.\3rd\ant\tools\prefab_editor\.build
set param=.\3rd\ant\tools\rmlviewer\main.lua
set mode=%1
set /p rml=rml file:

if not defined mode (
	set mode=release
)

if exist "%cachedir%" (
	rem rd /s /q %cachedir%
)

set exe=bin\msvc\%mode%\vaststars.exe
if not exist "%exe%" (
	echo can not found "%exe%"
	goto end
)

:again
pushd %current_dir%
	title %mode% - %current_dir%%exe%
	%current_dir%%exe% %param% %rml%
popd
goto :again

:end
pause
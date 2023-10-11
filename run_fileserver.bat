@echo off
@chcp 65001 >nul

set current_dir=%~dp0
set mode=%1
if not defined mode (
	set mode=release
)

set exe=bin\msvc\%mode%\vaststars.exe
if not exist "%exe%" (
	echo can not found "%exe%"
	goto end
)

pushd %current_dir%
	title %mode% - %current_dir%%exe% - fileserver
	%current_dir%%exe% -s
popd

:end
pause
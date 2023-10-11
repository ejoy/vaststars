@echo off
@chcp 65001 >nul

set current_dir=%~dp0
set cachedir=./startup/.build
set param=startup/main.lua

set mode=%1
if not defined mode (
	set mode=release
)

set runtime=%2
if not defined runtime (
    set exe=bin\msvc\%mode%\vaststars.exe
) else (
    set exe=bin\msvc\%mode%\vaststars_rt.exe
)

if exist "%cachedir%" (
	rem rd /s /q %cachedir%
)

if not exist "%exe%" (
	echo can not found "%exe%"
	goto end
)

pushd %current_dir%
	title %mode% - %current_dir%%exe%
	%current_dir%%exe% %param%
popd

:end
pause
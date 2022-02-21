@echo off
chcp 65001
set current_dir=%~dp0
set exe=bin\msvc\debug\vaststars.exe
set titlemsg=debug
set cachedir=.build
set param=

pushd %current_dir%

if exist "%cachedir%" (
	rem rd /s /q %cachedir%
)

if not exist "%exe%" (
	set exe=bin\msvc\release\vaststars.exe
	set titlemsg=release
)

title %titlemsg% - %current_dir%%exe%
%current_dir%%exe% %param%

popd
pause
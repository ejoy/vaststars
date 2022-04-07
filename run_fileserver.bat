@echo off
chcp 65001
set current_dir=%~dp0
set exe=bin\msvc\debug\vaststars.exe
set titlemsg=debug fileserver
set cachedir=.build
set param=.\3rd\ant\tools\fileserver\main.lua ../../startup

pushd %current_dir%

if exist "%cachedir%" (
	rem rd /s /q %cachedir%
)

if not exist "%exe%" (
	set exe=bin\msvc\release\vaststars.exe
	set titlemsg=release fileserver
)

title %titlemsg% - %current_dir%%exe%
%current_dir%%exe% %param%

popd
pause
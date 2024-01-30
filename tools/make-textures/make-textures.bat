@echo off
chcp 65001
set current_dir=%~dp0
set exe=../../bin/msvc/debug/vaststars.exe
set titlemsg=debug
set param=./tools/make-textures/make-textures.lua

pushd %current_dir%

if not exist "%exe%" (
	set exe=../bin/msvc/release/vaststars.exe
	set titlemsg=release
)

%current_dir%%exe% %param% --images_dir=%current_dir%..\..\startup\pkg\vaststars.resources\ui\images\ --textures_dir=%current_dir%..\..\startup\pkg\vaststars.resources\ui\textures\ --remove_all=true
%current_dir%%exe% %param% --images_dir=%current_dir%..\..\startup\pkg\vaststars.resources\images\icons\ --textures_dir=%current_dir%..\..\startup\pkg\vaststars.resources\textures\icons\ --remove_all=true

popd
pause
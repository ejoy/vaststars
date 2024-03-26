@echo off
chcp 65001
set current_dir=%~dp0
set exe=../../bin/msvc/debug/vaststars.exe
set titlemsg=debug
set param=./tools/make-atlas/make-atlas.lua

pushd %current_dir%

if not exist "%exe%" (
	set exe=../bin/msvc/release/vaststars.exe
	set titlemsg=release
)

%current_dir%%exe% %param%  --clear=true --name=item --width=1280 --height=1024 --image_dir=%current_dir%..\..\startup\pkg\vaststars.resources\images\icons\item --texture_dir=%current_dir%..\..\startup\pkg\vaststars.resources\textures\icons\item --parent_dir=%current_dir%..\..\startup

popd
pause
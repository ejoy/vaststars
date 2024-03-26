@echo off
chcp 65001
set current_dir=%~dp0
set exe=../../bin/msvc/debug/vaststars.exe
set titlemsg=debug
set param=./tools/set-atlas/set-atlas.lua

pushd %current_dir%

if not exist "%exe%" (
	set exe=../bin/msvc/release/vaststars.exe
	set titlemsg=release
)

%current_dir%%exe% %param% --atlas_dir=%current_dir%..\..\startup\pkg\vaststars.resources\ --parent_dir=%current_dir%..\..\startup --setting_path=%current_dir%..\..\startup\pkg\vaststars.settings\atlas_setting.ant

popd
pause
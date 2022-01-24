@echo off
@set current_dir=%~dp0

chcp 65001

pushd %current_dir%\3rd\ant\tools\prefab_editor\
if exist ".build" (
	rd /s /q .build
)

pushd %current_dir%
%current_dir%bin\msvc\release\vaststars.exe .\3rd\ant\tools\prefab_editor\main.lua
popd

pause
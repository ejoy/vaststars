@echo off
@set current_dir=%~dp0

pushd %current_dir%
%current_dir%bin\msvc\release\vaststars.exe .\3rd\ant\tools\prefab_editor\main.lua
popd
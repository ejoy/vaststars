@echo off
@set current_dir=%~dp0

pushd %current_dir%\3rd\ant\
.\bin\msvc\release\lua.exe %current_dir%\main.lua
popd
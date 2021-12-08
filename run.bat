@echo off
@set current_dir=%~dp0

pushd %current_dir%
git submodule update --init
popd

pushd %current_dir%\3rd\ant\
.\bin\lua.exe %current_dir%\main.lua
popd
@echo off
@set current_dir=%~dp0

pushd %current_dir%
if exist ".build" (
	rd /s /q .build
)

%current_dir%bin\msvc\release\vaststars.exe
popd

pause
@echo off
@chcp 65001 >nul

set current_dir=%~dp0

pushd %current_dir%
rd /s /q startup\.build
rd /s /q build
rd /s /q bin
rd /s /q .\3rd\ant\tools\prefab_editor\.build
popd

pause
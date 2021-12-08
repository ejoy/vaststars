@echo off
@set current_dir=%~dp0

pushd %current_dir%
rd /s /q .build
rd /s /q .\3rd\ant\tools\prefab_editor\.build
popd

pause
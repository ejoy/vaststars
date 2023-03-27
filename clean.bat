@echo off
@chcp 65001 >nul
set current_dir=%~dp0

set list=%list% startup\.build
set list=%list% build
set list=%list% bin
set list=%list% 3rd\ant\tools\prefab_editor\.build
set list=%list% 3rd\ant\bin

pushd %current_dir%
(for %%a in (%list%) do (
    if exist %%a (
        rd /s /q %%a
    )
))
popd

pause
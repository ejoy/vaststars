@echo off
@chcp 65001 >nul
set current_dir=%~dp0

set exit_or_pause=%1
set list=%list% startup\.build
set list=%list% startup\.log
set list=%list% startup\.repo
set list=%list% build
set list=%list% bin
set list=%list% 3rd\ant\tools\prefab_editor\.build
set list=%list% 3rd\ant\bin

pushd %current_dir%
(for %%a in (%list%) do (
    if exist %%a (
        rmdir /s /q %%a
    )
))
popd

if "%exit_or_pause%"=="" pause
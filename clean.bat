@echo off
@setlocal
@chcp 65001 >nul
set current_dir=%~dp0

set exit_or_pause=%1
set list=%list% startup\.app
set list=%list% startup\.fileserver
set list=%list% startup\res
set list=%list% build
set list=%list% bin
set list=%list% 3rd\ant\bin
set list=%list% 3rd\ant\build
set list=%list% 3rd\ant\tools\editor\.build

pushd %current_dir%
(for %%a in (%list%) do (
    if exist %%a (
        rmdir /s /q %%a
    )
))
popd

if "%exit_or_pause%"=="" pause
endlocal
@echo off
@setlocal
@chcp 65001 >nul
set current_dir=%~dp0

set exit_or_pause=%1
set list=%list% startup\.build

set list=%list% startup\.app
set list=%list% startup\.fileserver
set list=%list% startup\.log
set list=%list% startup\res

set list=%list% 3rd\ant\tools\editor\.app
set list=%list% 3rd\ant\tools\editor\.fileserver
set list=%list% 3rd\ant\tools\editor\.log
set list=%list% 3rd\ant\tools\editor\res

pushd %current_dir%
(for %%a in (%list%) do (
    if exist %%a (
        rmdir /s /q %%a
    )
))
popd

if "%exit_or_pause%"=="" pause
endlocal
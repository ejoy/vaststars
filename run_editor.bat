@echo off
@set current_dir=%~dp0

pushd %current_dir%\3rd\ant\
call run_editor.bat
popd
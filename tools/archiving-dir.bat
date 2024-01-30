@echo off
chcp 65001
set current_dir=%~dp0
set archiving=%current_dir%..\startup\.app\archiving

if not exist "%archiving%" (
	echo can not found %archiving%
	pause
)

explorer.exe ..\startup\.app\archiving
@echo off
set "GODOT=D:\HOME3\Mobile\Godot\bin\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64.exe"
if not exist "%GODOT%" (
	echo Godot not found at: %GODOT%
	pause
	exit /b 1
)
start "" "%GODOT%" --path "%~dp0."

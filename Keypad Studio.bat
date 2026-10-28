@echo off
title Keypad Studio
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0studio\bridge.ps1"
if errorlevel 1 (
  echo.
  echo Something went wrong on startup. See the message above.
  pause
)

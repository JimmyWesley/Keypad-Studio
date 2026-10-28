@echo off
title Keypad Studio
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0studio\bridge.ps1"
if errorlevel 1 (
  echo.
  echo Algo deu errado ao iniciar. Veja a mensagem acima.
  pause
)

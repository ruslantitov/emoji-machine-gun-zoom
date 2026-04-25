@echo off
title Emoji machine gun (Zoom) setup
echo Starting installer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\bootstrap.ps1"
if errorlevel 1 (
  echo.
  echo Launch failed. See the error message above.
  pause
  exit /b 1
)
echo.
echo Done. You can close this window.
timeout /t 3 >nul

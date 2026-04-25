@echo off
title Emoji machine gun (Zoom) setup
echo Starting installer...
set "BOOTSTRAP=%~dp0bootstrap.ps1"
if not exist "%BOOTSTRAP%" (
  echo.
  echo bootstrap.ps1 was not found next to START.cmd.
  echo Extract the whole ZIP to a normal folder first, then run START.cmd from the extracted folder.
  echo Do not launch START.cmd from inside the ZIP preview or a Temp folder.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%BOOTSTRAP%"
if errorlevel 1 (
  echo.
  echo Launch failed. See the error message above.
  pause
  exit /b 1
)
echo.
echo Done. You can close this window.
timeout /t 3 >nul

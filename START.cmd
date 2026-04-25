@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\bootstrap.ps1"
if errorlevel 1 (
  echo.
  echo Launch failed. See the error message above.
  pause
)

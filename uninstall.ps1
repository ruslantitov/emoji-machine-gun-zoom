$ErrorActionPreference = "Stop"

$zoomBin = Join-Path $env:APPDATA "Zoom\bin"
$startup = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"

Remove-Item (Join-Path $startup "Emoji machine gun (Zoom).cmd") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $zoomBin "Emoji machine gun (Zoom).cmd") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $zoomBin "Emoji machine gun (Zoom).ahk") -Force -ErrorAction SilentlyContinue

Write-Host "Removed startup and script files if they existed."

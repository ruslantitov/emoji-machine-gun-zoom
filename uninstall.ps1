$ErrorActionPreference = "Stop"

$zoomBin = Join-Path $env:APPDATA "Zoom\bin"
$startup = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$installedScriptPath = Join-Path $zoomBin "Emoji machine gun (Zoom).ahk"
$installedWatcherPath = Join-Path $zoomBin "watch-zoom.ps1"

function Stop-MatchingProcesses {
    param(
        [string]$NameFilter,
        [string]$PathFilter
    )

    $escapedPath = [regex]::Escape($PathFilter)
    $processes = Get-CimInstance Win32_Process -Filter $NameFilter | Where-Object { $_.CommandLine -match $escapedPath }
    foreach ($process in $processes) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

Stop-MatchingProcesses -NameFilter "Name = 'powershell.exe' OR Name = 'pwsh.exe'" -PathFilter $installedWatcherPath
Stop-MatchingProcesses -NameFilter "Name = 'AutoHotkey.exe' OR Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey32.exe' OR Name = 'AutoHotkeyUX.exe'" -PathFilter $installedScriptPath

Remove-Item (Join-Path $startup "Emoji machine gun (Zoom).cmd") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $startup "Emoji machine gun (Zoom) watcher.vbs") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $zoomBin "Emoji machine gun (Zoom).cmd") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $zoomBin "Emoji machine gun (Zoom).ahk") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $zoomBin "watch-zoom.ps1") -Force -ErrorAction SilentlyContinue

Write-Host "Removed watcher, startup entry, and script files if they existed."

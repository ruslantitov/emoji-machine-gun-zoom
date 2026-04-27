$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScriptPath = Join-Path $scriptRoot "Emoji machine gun (Zoom).ahk"
$mutexName = "EmojiMachineGunZoomWatcher"
$pollMs = 1500

function Test-ZoomRunning {
    return $null -ne (Get-Process Zoom,"Zoom Workplace" -ErrorAction SilentlyContinue | Select-Object -First 1)
}

function Get-AutoHotkeyV2Path {
    $candidates = @(
        (Join-Path $env:ProgramFiles "AutoHotkey\v2\AutoHotkey64.exe")
        (Join-Path $env:ProgramFiles "AutoHotkey\v2\AutoHotkey.exe")
        (Join-Path ${env:ProgramFiles(x86)} "AutoHotkey\v2\AutoHotkey32.exe")
        (Join-Path ${env:ProgramFiles(x86)} "AutoHotkey\v2\AutoHotkey.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey64.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey32.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey.exe")
        (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        (Join-Path $env:ProgramFiles "AutoHotkey\AutoHotkey.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\AutoHotkey.exe")
        (Get-Command AutoHotkeyUX.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
        (Join-Path $env:ProgramFiles "AutoHotkey\UX\AutoHotkeyUX.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\UX\AutoHotkeyUX.exe")
    ) | Where-Object { $_ }

    foreach ($path in ($candidates | Select-Object -Unique)) {
        if (Test-Path $path) {
            return [string]$path
        }
    }

    throw "AutoHotkey v2 executable was not found."
}

function Get-EmojiMachineGunProcess {
    $escapedPath = [regex]::Escape($mainScriptPath)
    Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey.exe' OR Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey32.exe' OR Name = 'AutoHotkeyUX.exe'" |
        Where-Object { $_.CommandLine -match $escapedPath }
}

function Start-EmojiMachineGun {
    if (Get-EmojiMachineGunProcess) {
        return
    }

    $ahkExe = Get-AutoHotkeyV2Path
    Start-Process -FilePath $ahkExe -WorkingDirectory $scriptRoot -ArgumentList @("`"$mainScriptPath`"")
}

function Stop-EmojiMachineGun {
    $processes = @(Get-EmojiMachineGunProcess)
    foreach ($process in $processes) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

$mutex = [System.Threading.Mutex]::new($false, $mutexName)
if (-not $mutex.WaitOne(0, $false)) {
    exit 0
}

try {
    while ($true) {
        if (Test-ZoomRunning) {
            Start-EmojiMachineGun
        } else {
            Stop-EmojiMachineGun
        }

        Start-Sleep -Milliseconds $pollMs
    }
} finally {
    $mutex.ReleaseMutex() | Out-Null
    $mutex.Dispose()
}

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot

function Test-Winget {
    $cmd = Get-Command winget -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

function Ensure-Winget {
    if (Test-Winget) {
        return
    }

    Write-Host "WinGet not found. Trying to register App Installer..."
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
    } catch {
        Write-Host "Register-by-family-name failed. Downloading App Installer from the official winget-cli release..."
        $msix = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $msix
        Add-AppxPackage -Path $msix -ErrorAction Stop
    }

    Start-Sleep -Seconds 2

    if (-not (Test-Winget)) {
        throw "WinGet could not be installed automatically. Install Microsoft App Installer manually, then rerun this launcher."
    }
}

function Test-AutoHotkeyV2 {
    $candidates = @(
        (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue).Source
        (Join-Path $env:ProgramFiles "AutoHotkey\v2\AutoHotkey64.exe")
        (Join-Path $env:ProgramFiles "AutoHotkey\AutoHotkey.exe")
        (Join-Path ${env:ProgramFiles(x86)} "AutoHotkey\v2\AutoHotkey32.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\AutoHotkey.exe")
    ) | Where-Object { $_ }

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            try {
                $version = [version](Get-Item $path).VersionInfo.ProductVersion
                if ($version.Major -ge 2) {
                    return $true
                }
            } catch {
                continue
            }
        }
    }

    return $false
}

function Get-AutoHotkeyV2Path {
    $candidates = @(
        (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue).Source
        (Join-Path $env:ProgramFiles "AutoHotkey\v2\AutoHotkey64.exe")
        (Join-Path $env:ProgramFiles "AutoHotkey\AutoHotkey.exe")
        (Join-Path ${env:ProgramFiles(x86)} "AutoHotkey\v2\AutoHotkey32.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey64.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey32.exe")
        (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\AutoHotkey.exe")
    ) | Where-Object { $_ }

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Install-AutoHotkeyV2 {
    Ensure-Winget
    Write-Host "AutoHotkey v2 not found. Installing it now..."
    winget install --id AutoHotkey.AutoHotkey --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
}

if (-not (Test-AutoHotkeyV2)) {
    Install-AutoHotkeyV2
}

$ahkExe = Get-AutoHotkeyV2Path
if (-not $ahkExe) {
    throw "AutoHotkey v2 could not be found after installation."
}

$scriptPath = Join-Path $projectRoot "Emoji machine gun (Zoom).ahk"
Start-Process -FilePath $ahkExe -WorkingDirectory $projectRoot -ArgumentList @("`"$scriptPath`"")

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "Emoji machine gun is running. Look for the tray icon, then open Zoom and use F5-F9.",
    "Emoji machine gun (Zoom)"
) | Out-Null

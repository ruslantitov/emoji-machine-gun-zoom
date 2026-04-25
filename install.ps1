$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$zoomBin = Join-Path $env:APPDATA "Zoom\bin"
$startup = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"

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
        throw "WinGet could not be installed automatically. Install Microsoft App Installer manually, then rerun this installer."
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

function Install-AutoHotkeyV2 {
    Ensure-Winget
    Write-Host "AutoHotkey v2 not found. Installing it now..."
    winget install --id AutoHotkey.AutoHotkey --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
}

if (-not (Test-AutoHotkeyV2)) {
    Install-AutoHotkeyV2
}

if (!(Test-Path $zoomBin)) {
    throw "Zoom bin folder not found: $zoomBin"
}

Copy-Item (Join-Path $projectRoot "Emoji machine gun (Zoom).ahk") $zoomBin -Force

$cmdPath = Join-Path $zoomBin "Emoji machine gun (Zoom).cmd"
@"
@echo off
start "" "C:\Users\$env:USERNAME\AppData\Roaming\Zoom\bin\Emoji machine gun (Zoom).ahk"
"@ | Set-Content -Encoding ASCII $cmdPath

$startupCmd = Join-Path $startup "Emoji machine gun (Zoom).cmd"
Copy-Item $cmdPath $startupCmd -Force

Write-Host "Installed to $zoomBin"
Write-Host "Startup shortcut created in $startup"

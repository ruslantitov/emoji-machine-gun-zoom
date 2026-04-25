$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

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
    return $null -ne (Get-AutoHotkeyV2Path)
}

function Test-AutoHotkeyV2Executable {
    param(
        [string]$Path
    )

    if (-not $Path -or -not (Test-Path $Path)) {
        return $false
    }

    $fileName = [System.IO.Path]::GetFileName($Path)
    if ($fileName -eq "AutoHotkeyUX.exe") {
        return $true
    }

    try {
        $version = [version](Get-Item $Path).VersionInfo.ProductVersion
        return $version.Major -ge 2
    } catch {
        return $false
    }
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
        if (Test-AutoHotkeyV2Executable $path) {
            return [string]$path
        }
    }

    return $null
}

function Install-AutoHotkeyV2 {
    Ensure-Winget
    Write-Host "AutoHotkey v2 not found. Installing it now..."
    winget install --id AutoHotkey.AutoHotkey --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity | Out-Host

    for ($i = 0; $i -lt 10; $i++) {
        $ahkExe = Get-AutoHotkeyV2Path
        if ($ahkExe) {
            return $ahkExe
        }

        Start-Sleep -Seconds 1
    }

    Write-Host "AutoHotkey package is registered but the executable was not found. Repairing with winget..."
    winget repair --id AutoHotkey.AutoHotkey --exact --accept-package-agreements --accept-source-agreements --silent --disable-interactivity | Out-Host

    for ($i = 0; $i -lt 10; $i++) {
        $ahkExe = Get-AutoHotkeyV2Path
        if ($ahkExe) {
            return $ahkExe
        }

        Start-Sleep -Seconds 1
    }

    return $null
}

if (-not (Test-AutoHotkeyV2)) {
    $installedAhkExe = Install-AutoHotkeyV2
} else {
    Write-Host "AutoHotkey v2 is already installed. Skipping installation."
}

$ahkExe = if ($installedAhkExe) { [string]$installedAhkExe } else { [string](Get-AutoHotkeyV2Path) }
if (-not $ahkExe) {
    throw "AutoHotkey v2 could not be found after installation."
}

if (-not (Test-Path $ahkExe)) {
    throw "AutoHotkey executable was resolved to a missing path: $ahkExe"
}

$scriptPath = Join-Path $projectRoot "Emoji machine gun (Zoom).ahk"
Start-Process -FilePath $ahkExe -ArgumentList @($scriptPath)

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "Emoji machine gun is running. Look for the tray icon, then open Zoom and use F5-F9.",
    "Emoji machine gun (Zoom)"
) | Out-Null

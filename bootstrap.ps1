$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$zoomBin = Join-Path $env:APPDATA "Zoom\bin"
$startup = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$installedScriptPath = Join-Path $zoomBin "Emoji machine gun (Zoom).ahk"
$installedWatcherPath = Join-Path $zoomBin "watch-zoom.ps1"
$startupVbsPath = Join-Path $startup "Emoji machine gun (Zoom) watcher.vbs"
$legacyStartupCmdPath = Join-Path $startup "Emoji machine gun (Zoom).cmd"
$legacyInstalledCmdPath = Join-Path $zoomBin "Emoji machine gun (Zoom).cmd"

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

function Get-AutoHotkeyRegistryLocations {
    $paths = @()
    $registryRoots = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($root in $registryRoots) {
        if (-not (Test-Path $root)) {
            continue
        }

        Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $item = Get-ItemProperty $_.PSPath -ErrorAction Stop
                if ($item.DisplayName -and $item.DisplayName -like "AutoHotkey*") {
                    if ($item.InstallLocation) {
                        $paths += $item.InstallLocation
                    }
                    if ($item.DisplayIcon) {
                        $paths += (Split-Path $item.DisplayIcon -Parent)
                    }
                }
            } catch {
                continue
            }
        }
    }

    return $paths | Where-Object { $_ } | Select-Object -Unique
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

    foreach ($installLocation in Get-AutoHotkeyRegistryLocations) {
        $candidates += @(
            (Join-Path $installLocation "AutoHotkey64.exe")
            (Join-Path $installLocation "AutoHotkey32.exe")
            (Join-Path $installLocation "AutoHotkey.exe")
            (Join-Path $installLocation "v2\AutoHotkey64.exe")
            (Join-Path $installLocation "v2\AutoHotkey32.exe")
            (Join-Path $installLocation "v2\AutoHotkey.exe")
            (Join-Path $installLocation "UX\AutoHotkeyUX.exe")
            (Join-Path $installLocation "UX\AutoHotkey64.exe")
        )
    }

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

function Get-EmojiMachineGunProcess {
    param(
        [string]$ScriptPath
    )

    $escapedPath = [regex]::Escape($ScriptPath)
    Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey.exe' OR Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey32.exe' OR Name = 'AutoHotkeyUX.exe'" |
        Where-Object { $_.CommandLine -match $escapedPath }
}

function Get-WatcherProcess {
    param(
        [string]$WatcherPath
    )

    $escapedPath = [regex]::Escape($WatcherPath)
    Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe' OR Name = 'pwsh.exe'" |
        Where-Object { $_.CommandLine -match $escapedPath }
}

function Install-EmojiMachineGunFiles {
    New-Item -ItemType Directory -Path $zoomBin -Force | Out-Null
    Copy-Item (Join-Path $projectRoot "Emoji machine gun (Zoom).ahk") $installedScriptPath -Force
    Copy-Item (Join-Path $projectRoot "watch-zoom.ps1") $installedWatcherPath -Force
    Remove-Item $legacyInstalledCmdPath -Force -ErrorAction SilentlyContinue
}

function Install-WatcherStartup {
    New-Item -ItemType Directory -Path $startup -Force | Out-Null
    Remove-Item $legacyStartupCmdPath -Force -ErrorAction SilentlyContinue
    $command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $installedWatcherPath
    $vbs = @"
Set shell = CreateObject("WScript.Shell")
shell.Run "$command", 0
"@
    Set-Content -Path $startupVbsPath -Value $vbs -Encoding ASCII
}

function Restart-EmojiMachineGunWatcher {
    $watcherProcesses = @(Get-WatcherProcess -WatcherPath $installedWatcherPath)
    foreach ($process in $watcherProcesses) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }

    $emojiProcesses = @(Get-EmojiMachineGunProcess -ScriptPath $installedScriptPath)
    foreach ($process in $emojiProcesses) {
        Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
    }

    Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile"
        "-ExecutionPolicy", "Bypass"
        "-WindowStyle", "Hidden"
        "-File", "`"$installedWatcherPath`""
    )
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

Install-EmojiMachineGunFiles
Install-WatcherStartup
Restart-EmojiMachineGunWatcher

Write-Host "Emoji machine gun watcher is installed."
Write-Host "AutoHotkey will start only while Zoom is running and will stop when Zoom closes."

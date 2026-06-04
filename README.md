# Emoji machine gun (Zoom)

Windows and macOS.

Quick start:
- [QUICK_START.md](QUICK_START.md)
- Release page: https://github.com/ruslantitov/emoji-machine-gun-zoom/releases/latest
- macOS docs: [macos/README.md](macos/README.md)
- The release ZIP extracts into one root folder with separate `windows/` and `macos/` subfolders.

## RU
Минимальный AutoHotkey v2-скрипт для Zoom. Он использует только штатные горячие клавиши Zoom и работает без привязки к координатам экрана.

### Что делает
- `F5` - удержание запускает смешанный поток `heart -> thumbs up -> clap`
- `F6` - удержание отправляет `clap`
- `F7` - удержание отправляет `thumbs up`
- `F8` - удержание отправляет `heart`
- `F9` - удержание отправляет `tada / party`

### Требования
- Windows 11
- Zoom desktop app
- AutoHotkey v2

`bootstrap.ps1` сам проверяет наличие `winget`. Если `winget` отсутствует, он сначала пытается поднять Microsoft App Installer, а потом ставит `AutoHotkey v2`.

### Установка
1. Скачайте релиз ZIP.
2. Распакуйте архив целиком в обычную папку.
3. Запустите `START.cmd` из распакованной папки, не из окна ZIP и не из `Temp`.
4. Установщик сначала проверит `winget`, потом поставит `AutoHotkey v2`, если он отсутствует.
5. Установщик скопирует `.ahk` и скрытый watcher в `%APPDATA%\Emoji machine gun (Zoom)` и добавит watcher в `Startup`.
6. Когда Zoom запущен, watcher поднимает `AutoHotkey`.
7. Когда Zoom закрывается, watcher гасит `AutoHotkey`, и его больше нет даже в трее.
8. Если Windows скрывает расширения, файл может отображаться как просто `START`.

### Как это работает
Скрипт активирует окно Zoom и отправляет его штатные сочетания:
- `Alt+Shift+4` - clap
- `Alt+Shift+5` - thumbs up
- `Alt+Shift+6` - heart
- `Alt+Shift+9` - tada

Документация Zoom:
- https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0067050

## EN
Minimal AutoHotkey v2 script for Zoom. It uses only Zoom built-in hotkeys and does not depend on screen coordinates.

### What it does
- `F5` - hold to spam a mixed stream of `heart -> thumbs up -> clap`
- `F6` - hold to spam `clap`
- `F7` - hold to spam `thumbs up`
- `F8` - hold to spam `heart`
- `F9` - hold to spam `tada / party`

### Requirements
- Windows 11
- Zoom desktop app
- AutoHotkey v2

`bootstrap.ps1` checks for `winget` first. If `winget` is missing, it tries to install Microsoft App Installer and then installs `AutoHotkey v2`.

### Install
1. Download the ZIP release.
2. Extract the whole archive into a normal folder.
3. Run `START.cmd` from the extracted folder, not from the ZIP preview and not from `Temp`.
4. The installer checks `winget` and installs `AutoHotkey v2` if needed.
5. The installer copies the `.ahk` script and a hidden watcher into `%APPDATA%\Emoji machine gun (Zoom)` and adds the watcher to `Startup`.
6. When Zoom is running, the watcher starts `AutoHotkey`.
7. When Zoom closes, the watcher stops `AutoHotkey`, so it is no longer present even in the tray.
8. If Windows hides file extensions, the file may appear as just `START`.

### How it works
The script activates the Zoom window and sends built-in Zoom shortcuts:
- `Alt+Shift+4` - clap
- `Alt+Shift+5` - thumbs up
- `Alt+Shift+6` - heart
- `Alt+Shift+9` - tada

Zoom docs:
- https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0067050

## Repo
- `Emoji machine gun (Zoom).ahk` - main script
- `bootstrap.ps1` - installer that installs prerequisites and configures the watcher
- `watch-zoom.ps1` - hidden watcher that starts/stops AutoHotkey with Zoom
- `uninstall.ps1` - remove startup and files
- `START.cmd` - one-click installer
- `uninstall.cmd` - one-click removal
- `LICENSE` - project license
- `QUICK_START.md` - minimal install instructions
- `RELEASE_CHECKLIST.md` - pre-release test checklist

The release ZIP is built automatically by GitHub Actions on tags like `v1.0.0`.

## macOS
There is also a macOS version in [macos/README.md](macos/README.md).
It uses Hammerspoon instead of AutoHotkey, but follows the same idea:
- global `Command + 1` to `5`
- press once or hold to spam reactions
- use only Zoom built-in shortcuts
- work only while Zoom is running
- reactions appear only inside an active Zoom meeting
- the macOS installer checks whether Hammerspoon is already installed, downloads it automatically if needed, and opens the exact macOS permission pages for Accessibility and Input Monitoring
- the release ZIP does not include unsigned `.app` or `.command` launchers, because Gatekeeper can block them before our code runs
- the recommended macOS install path is the Terminal command in `macos/README_MAC_INSTALL.txt`
- the command streams `macos/bootstrap.sh` from GitHub, so no downloaded executable file needs to be opened

# Emoji machine gun (Zoom)

Windows only.

Quick start:
- [QUICK_START.md](QUICK_START.md)
- Release page: https://github.com/ruslantitov/emoji-machine-gun-zoom/releases/latest

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

`install.ps1` сам проверяет наличие `winget`. Если `winget` отсутствует, он сначала пытается поднять Microsoft App Installer, а потом ставит `AutoHotkey v2`.

### Установка
1. Скачайте релиз ZIP.
2. Запустите `install.cmd`.
3. Скрипт сначала проверит `winget`, потом поставит `AutoHotkey v2`, если он отсутствует, затем запустит `.ahk`.
4. На первом запуске `.ahk` сам скопирует себя в папку Zoom и добавит автозапуск в `Startup`.
5. Если Windows скрывает расширения, файл может отображаться как просто `install`.

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

`install.ps1` checks for `winget` first. If `winget` is missing, it tries to install Microsoft App Installer and then installs `AutoHotkey v2`.

### Install
1. Download the ZIP release.
2. Run `install.cmd`.
3. The installer checks `winget`, installs `AutoHotkey v2` if needed, and then launches the `.ahk` file.
4. On first run, the `.ahk` file copies itself into the Zoom folder and adds startup support.
5. If Windows hides file extensions, the file may appear as just `install`.

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
- `install.ps1` - install into Zoom folder + startup
- `uninstall.ps1` - remove startup and files
- `install.cmd` - one-click installer
- `uninstall.cmd` - one-click removal
- `LICENSE` - project license
- `QUICK_START.md` - minimal install instructions

The release ZIP is built automatically by GitHub Actions on tags like `v1.0.0`.

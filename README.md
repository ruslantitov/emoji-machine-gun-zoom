# Emoji machine gun (Zoom)

Минимальный AutoHotkey v2-скрипт для Zoom. Он использует только штатные горячие клавиши Zoom и работает без привязки к координатам экрана.

## Что делает

- `F5` - удержание запускает смешанный поток `heart -> thumbs up -> clap`
- `F6` - удержание отправляет `clap`
- `F7` - удержание отправляет `thumbs up`
- `F8` - удержание отправляет `heart`
- `F9` - удержание отправляет `tada / party`

## Требования

- Windows 11
- Zoom desktop app
- AutoHotkey v2

`install.ps1` сам проверяет наличие `winget`. Если `winget` отсутствует, он сначала пытается поднять Microsoft App Installer, а потом ставит `AutoHotkey v2`.

## Установка

### Вариант 1. Через установщик

1. Скачайте релиз ZIP.
2. Запустите `install.ps1`.
3. Скрипт сначала проверит `winget`, потом поставит `AutoHotkey v2`, если он отсутствует, затем скопирует файлы в папку Zoom и добавит автозапуск в `Startup`.

### Вариант 2. Вручную

1. Скопируйте `Emoji machine gun (Zoom).ahk` в `C:\Users\<USER>\AppData\Roaming\Zoom\bin\`
2. Добавьте ярлык или `cmd`-обертку в папку автозагрузки Windows.

## Как это работает

Скрипт активирует окно Zoom и отправляет его штатные сочетания:

- `Alt+Shift+4` - clap
- `Alt+Shift+5` - thumbs up
- `Alt+Shift+6` - heart
- `Alt+Shift+9` - tada

Документация Zoom:

- https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0067050

## Что внутри репозитория

- `Emoji machine gun (Zoom).ahk` - основной скрипт
- `install.ps1` - установка в папку Zoom + автозапуск
- `uninstall.ps1` - удаление автозапуска и файлов
- `install.cmd` - one-click запуск установщика
- `uninstall.cmd` - one-click удаление
- `LICENSE` - лицензия проекта

Релизный ZIP собирается автоматически GitHub Actions при пуше тега вида `v1.0.0`.

## Примечание

Если Zoom обновит горячие клавиши, нужно будет править только маппинг в одном месте.

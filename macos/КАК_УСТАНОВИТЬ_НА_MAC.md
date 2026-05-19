# Как установить на Mac

В новом релизе открывайте файл:

```text
README_MAC_INSTALL.txt
```

Скопируйте команду оттуда в Terminal и нажмите Enter.

Команда:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruslantitov/emoji-machine-gun-zoom/main/macos/bootstrap.sh)"
```

Не открывайте `Emoji machine gun (Zoom).app`, `УСТАНОВИТЬ.command` или `INSTALL.command`, если они остались в старой папке релиза. В новом релизе эти файлы больше не нужны.

После запуска команды установщик сам:

- установит или откроет Hammerspoon
- включит автозапуск
- откроет нужные страницы настроек

В открывшихся настройках включите `Hammerspoon`:

- `Accessibility`
- `Input Monitoring`

Потом откройте Zoom и удерживайте:

- `Command + 1` - микс реакций
- `Command + 2` - clap
- `Command + 3` - thumbs up
- `Command + 4` - heart
- `Command + 5` - tada / party

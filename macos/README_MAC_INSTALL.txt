Установка на Mac без окна Gatekeeper

Если Mac блокирует скачанный .command файл или предлагает переместить его в Корзину,
не открывайте этот файл повторно.

Самый надежный способ без Apple Developer подписи:

1. Откройте Terminal.
2. Вставьте эту команду целиком:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruslantitov/emoji-machine-gun-zoom/main/macos/bootstrap.sh)"

3. Нажмите Enter.
4. Если macOS откроет настройки приватности, включите Hammerspoon в:
   - Accessibility
   - Input Monitoring

Почему так:
- обычные скачанные программы без подписи Apple может блокировать Gatekeeper;
- текстовая команда в Terminal не является скачанным приложением;
- все равно будут обычные macOS-разрешения для Hammerspoon, их нужно включить руками.

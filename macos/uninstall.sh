#!/bin/bash
set -euo pipefail

if [ -d "${HOME}/.hammerspoon" ] || [ -f "${HOME}/.hammerspoon/init.lua" ]; then
  CONFIG_DIR="${HOME}/.hammerspoon"
else
  CONFIG_DIR="${HOME}/.hammerspoon"
fi

INSTALL_DIR="${CONFIG_DIR}/emoji-machine-gun-zoom"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${LAUNCH_AGENTS_DIR}/com.ruslantitov.emoji-machine-gun-zoom.plist"
INIT_PATH="${CONFIG_DIR}/init.lua"
BLOCK_START="-- BEGIN emoji-machine-gun-zoom"
BLOCK_END="-- END emoji-machine-gun-zoom"

launchctl unload "${PLIST_PATH}" >/dev/null 2>&1 || true
rm -f "${PLIST_PATH}"
rm -rf "${INSTALL_DIR}"

if [ -f "${INIT_PATH}" ]; then
  temp_init="$(mktemp)"

  awk -v start="${BLOCK_START}" -v end="${BLOCK_END}" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "${INIT_PATH}" > "${temp_init}"

  mv "${temp_init}" "${INIT_PATH}"
fi

osascript -e 'tell application "Hammerspoon" to quit' >/dev/null 2>&1 || true

echo "Emoji machine gun for Zoom was removed from macOS."

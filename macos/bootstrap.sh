#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

find_hammerspoon_app() {
  local candidate
  for candidate in "/Applications/Hammerspoon.app" "${HOME}/Applications/Hammerspoon.app"; do
    if [ -d "${candidate}" ]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  if command -v mdfind >/dev/null 2>&1; then
    candidate="$(mdfind 'kMDItemCFBundleIdentifier == "org.hammerspoon.Hammerspoon" && kMDItemContentType == "com.apple.application-bundle"' | head -n 1)"
    if [ -n "${candidate:-}" ] && [ -d "${candidate}" ]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi

  return 1
}

download_hammerspoon() {
  local release_json release_url release_name pkg_path extract_dir app_path
  release_json="$(mktemp)"
  pkg_path="$(mktemp -t hammerspoon.XXXXXX)"
  extract_dir="$(mktemp -d)"

  curl -fsSL "https://api.github.com/repos/Hammerspoon/hammerspoon/releases/latest" -o "${release_json}"

  read -r release_name release_url <<EOF
$(python3 - "${release_json}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    data = json.load(fh)

for asset in data.get("assets", []):
    name = asset.get("name", "")
    url = asset.get("browser_download_url", "")
    if name.endswith(".zip") or name.endswith(".dmg"):
        print(name, url)
        raise SystemExit(0)

print("")
PY
)
EOF

  if [ -z "${release_url:-}" ]; then
    echo "Could not find a downloadable Hammerspoon release archive."
    return 1
  fi

  curl -fL "${release_url}" -o "${pkg_path}"

  case "${release_name}" in
    *.zip)
      unzip -q "${pkg_path}" -d "${extract_dir}"
      app_path="$(find "${extract_dir}" -maxdepth 3 -name 'Hammerspoon.app' -type d | head -n 1)"
      ;;
    *.dmg)
      local mount_point
      mount_point="$(mktemp -d)"
      hdiutil attach -nobrowse -quiet -mountpoint "${mount_point}" "${pkg_path}"
      app_path="$(find "${mount_point}" -maxdepth 2 -name 'Hammerspoon.app' -type d | head -n 1)"
      ;;
    *)
      echo "Unsupported Hammerspoon archive type: ${release_name}"
      return 1
      ;;
  esac

  if [ -z "${app_path:-}" ] || [ ! -d "${app_path}" ]; then
    echo "Downloaded Hammerspoon archive did not contain Hammerspoon.app"
    return 1
  fi

  if [ -d "/Applications" ] && [ -w "/Applications" ]; then
    rm -rf "/Applications/Hammerspoon.app"
    cp -R "${app_path}" "/Applications/"
    xattr -dr com.apple.quarantine "/Applications/Hammerspoon.app" >/dev/null 2>&1 || true
    if [ -d "/Applications/Hammerspoon.app" ]; then
      return 0
    fi
  fi

  mkdir -p "${HOME}/Applications"
  rm -rf "${HOME}/Applications/Hammerspoon.app"
  cp -R "${app_path}" "${HOME}/Applications/"
  xattr -dr com.apple.quarantine "${HOME}/Applications/Hammerspoon.app" >/dev/null 2>&1 || true

  if [ ! -d "${HOME}/Applications/Hammerspoon.app" ]; then
    echo "Failed to install Hammerspoon.app to either /Applications or ~/Applications."
    return 1
  fi
}

ensure_hammerspoon() {
  if find_hammerspoon_app >/dev/null 2>&1; then
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    if brew install --cask hammerspoon; then
      if find_hammerspoon_app >/dev/null 2>&1; then
        return
      fi
    fi
  fi

  download_hammerspoon
}

open_privacy_pane() {
  local pane="$1"
  open "x-apple.systempreferences:com.apple.preference.security?${pane}" >/dev/null 2>&1 || true
}

show_dialog() {
  local title="$1"
  local message="$2"

  osascript - "$title" "$message" <<'APPLESCRIPT'
on run argv
  set dialogTitle to item 1 of argv
  set dialogMessage to item 2 of argv
  display dialog dialogMessage with title dialogTitle buttons {"Quit", "Continue"} default button "Continue" cancel button "Quit" with icon caution
end run
APPLESCRIPT
}

wait_for_accessibility() {
  local attempts=0
  while [ "${attempts}" -lt 30 ]; do
    if hs -c 'print(hs.accessibilityState())' 2>/dev/null | tail -n 1 | grep -qx 'true'; then
      return 0
    fi
    sleep 2
    attempts=$((attempts + 1))
  done

  return 1
}

install_files() {
  mkdir -p "${INSTALL_DIR}"
  cp "${SCRIPT_DIR}/init.lua" "${INSTALL_DIR}/init.lua"

  mkdir -p "${CONFIG_DIR}"
  if [ ! -f "${INIT_PATH}" ]; then
    touch "${INIT_PATH}"
  fi

  local temp_init
  temp_init="$(mktemp)"

  awk -v start="${BLOCK_START}" -v end="${BLOCK_END}" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "${INIT_PATH}" > "${temp_init}"

  cat >> "${temp_init}" <<EOF

${BLOCK_START}
package.path = package.path .. ";${INSTALL_DIR}/?.lua"
dofile("${INSTALL_DIR}/init.lua")
${BLOCK_END}
EOF

  mv "${temp_init}" "${INIT_PATH}"
}

install_launch_agent() {
  mkdir -p "${LAUNCH_AGENTS_DIR}"
  cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.ruslantitov.emoji-machine-gun-zoom</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/open</string>
      <string>-a</string>
      <string>Hammerspoon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
  </dict>
</plist>
EOF

  launchctl unload "${PLIST_PATH}" >/dev/null 2>&1 || true
  launchctl load "${PLIST_PATH}"
}

restart_hammerspoon() {
  osascript -e 'tell application "Hammerspoon" to quit' >/dev/null 2>&1 || true
  local app_path
  if app_path="$(find_hammerspoon_app)"; then
    open "${app_path}"
  else
    open -a Hammerspoon
  fi
}

run_permission_wizard() {
  show_dialog \
    "Emoji machine gun for Zoom" \
    "macOS needs two permissions for Hammerspoon: Accessibility and Input Monitoring. The installer will open the exact System Settings pages for you. Turn on Hammerspoon in each page, then come back here and click Continue."

  open_privacy_pane "Privacy_Accessibility"
  show_dialog \
    "Enable Accessibility" \
    "Turn on Hammerspoon in Privacy & Security > Accessibility, then click Continue."

  wait_for_accessibility || true

  open_privacy_pane "Privacy_ListenEvent"
  show_dialog \
    "Enable Input Monitoring" \
    "Turn on Hammerspoon in Privacy & Security > Input Monitoring, then click Continue."
}

ensure_hammerspoon
install_files
install_launch_agent
restart_hammerspoon
run_permission_wizard

echo "Emoji machine gun for Zoom is installed on macOS."
echo "Grant Hammerspoon Accessibility and Input Monitoring access in System Settings if macOS prompts for it."

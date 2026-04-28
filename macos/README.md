# Emoji machine gun (Zoom) for macOS

macOS only.

This version uses [Hammerspoon](https://www.hammerspoon.org/) to watch Zoom, bind global hotkeys, and send Zoom's built-in reaction shortcuts.

## What it does

- `Command + 1` - hold to spam a mixed stream of `heart -> thumbs up -> clap`
- `Command + 2` - hold to spam `clap`
- `Command + 3` - hold to spam `thumbs up`
- `Command + 4` - hold to spam `heart`
- `Command + 5` - hold to spam `tada / party`

## Requirements

- macOS
- Zoom desktop app
- Hammerspoon
- Accessibility permission for Hammerspoon
- Input Monitoring permission for Hammerspoon

## Zoom shortcuts used on macOS

- `Option + Command + 4` - clap
- `Option + Command + 5` - thumbs up
- `Option + Command + 6` - heart
- `Option + Command + 9` - tada

## Install

1. Extract the ZIP and open the `macos/` folder.
2. Double-click `INSTALL.command`.
3. Follow the installer prompts. It first checks whether Hammerspoon is already installed; if not, it downloads it automatically, then opens the exact macOS pages for Accessibility and Input Monitoring.
4. Open Zoom and use `Command + 1` to `5`.
5. If macOS blocks `INSTALL.command` after a browser download, right-click it and choose `Open`. If that still fails, run `xattr -dr com.apple.quarantine ~/Desktop/emoji-machine-gun-zoom-v1.1.11` once in Terminal, then open `INSTALL.command` again.

If you prefer Terminal, you can still run:

```bash
chmod +x bootstrap.sh uninstall.sh
./bootstrap.sh
```

Notes:
- The installer does not replace the whole Hammerspoon config anymore.
- It only injects its own marked block into `~/.hammerspoon/init.lua`.
- Uninstall removes only that block and leaves the rest of the user's Hammerspoon config intact.
- The installer opens the exact System Settings pages for Accessibility and Input Monitoring automatically.
- `INSTALL.command` is the recommended double-click entry point on macOS.

## Lifecycle

- The script is loaded by Hammerspoon at login.
- It only sends reactions while Zoom is running.
- If Zoom closes, the reaction loop stops immediately.
- Reopening Zoom works in the same macOS session without reinstalling anything.

## Remove

Run:

```bash
./uninstall.sh
```

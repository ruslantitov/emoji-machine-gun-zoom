# Emoji machine gun (Zoom) for macOS

macOS only.

This version uses [Hammerspoon](https://www.hammerspoon.org/) to watch Zoom, bind global hotkeys, and send Zoom's built-in reaction shortcuts.

## What it does

- `Command + 1` - press once or hold to spam a mixed stream of `heart -> thumbs up -> clap`
- `Command + 2` - press once or hold to spam `clap`
- `Command + 3` - press once or hold to spam `thumbs up`
- `Command + 4` - press once or hold to spam `heart`
- `Command + 5` - press once or hold to spam `tada / party`

Zoom must be inside an active meeting. If only the Zoom home window is open, reactions have nowhere to appear.

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

For the public release ZIP, use the Terminal command from `README_MAC_INSTALL.txt`:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruslantitov/emoji-machine-gun-zoom/main/macos/bootstrap.sh)"
```

The release ZIP intentionally does not include unsigned `.app` or `.command` launchers. New macOS versions can block those files before our code runs, sometimes with only `Move to Trash` / `Done`.

For local development from a trusted checkout, you can still run `./bootstrap.sh` from this folder.

Notes:
- The installer does not replace the whole Hammerspoon config anymore.
- It only injects its own marked block into `~/.hammerspoon/init.lua`.
- Uninstall removes only that block and leaves the rest of the user's Hammerspoon config intact.
- The installer opens the exact System Settings pages for Accessibility and Input Monitoring automatically.
- If permissions look enabled but hotkeys do nothing, remove and add Hammerspoon again in both privacy panes.

## Lifecycle

- The script is loaded by Hammerspoon at login.
- It only sends reactions while Zoom is running.
- The first reaction is sent immediately on key press; holding the key repeats it.
- If Zoom closes, the reaction loop stops immediately.
- Reopening Zoom works in the same macOS session without reinstalling anything.

## Remove

Run:

```bash
./uninstall.sh
```

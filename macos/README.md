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

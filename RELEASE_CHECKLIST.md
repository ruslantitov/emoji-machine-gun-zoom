# Release Checklist

Use this checklist before every public GitHub release.

The goal is simple:
- catch installer mistakes before users see them
- test the same ZIP that users will download
- avoid publishing a broken release because of a small packaging issue

## Rules

- Do not publish straight from local code without testing the final ZIP.
- Test the extracted ZIP in a clean folder, not the repo working directory.
- Prefer one small fix per release.
- If something important changed in install/startup behavior, do a full uninstall and reinstall test.

## Pre-release

- Confirm the repo is in the expected state.
- Confirm the release ZIP contains the expected files only.
- Confirm `README.md` and `QUICK_START.md` still match actual behavior.
- Confirm no unfinished experimental files are being included by accident.

## Clean install test

1. Remove the current install:
   - run `uninstall.cmd`

2. Prepare a clean test folder:
   - download or build the ZIP
   - extract the ZIP into a new empty folder

3. Install from the extracted ZIP:
   - run `START.cmd`
   - confirm the installer finishes without errors

## Windows verification

- `Emoji machine gun (Zoom).ahk` is copied into `%APPDATA%\Zoom\bin`
- `watch-zoom.ps1` is copied into `%APPDATA%\Zoom\bin`
- `Emoji machine gun (Zoom) watcher.vbs` is created in the Startup folder
- the generated `watcher.vbs` contains a valid quoted path to `watch-zoom.ps1`
- AutoHotkey v2 is detected or installed successfully

## Runtime verification

With Zoom closed:
- `AutoHotkey` is not running

With Zoom open:
- `AutoHotkey` starts automatically
- no obvious error window appears

Inside a real Zoom meeting:
- hold `F5` -> mixed reactions work
- hold `F6` -> clap works
- hold `F7` -> thumbs up works
- hold `F8` -> heart works
- hold `F9` -> tada works

After closing Zoom:
- `AutoHotkey` stops again

## Uninstall verification

- run `uninstall.cmd`
- confirm Startup entry is removed
- confirm installed script files are removed
- confirm `AutoHotkey` started by this project is no longer running

## Release decision

Publish the release only if all of the following are true:
- install works from the ZIP
- runtime behavior works in Zoom
- uninstall works
- no unexpected files are included

If any item fails:
- fix it
- rebuild the ZIP
- rerun the checklist

## Versioning rule

- Normally: new fix -> new version
- Exception: replacing the same release asset is allowed only for an immediate hotfix right after release
- Do not treat one version as a moving target long-term

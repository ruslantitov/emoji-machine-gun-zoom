#Requires AutoHotkey v2.0
#SingleInstance Force

; Emoji machine gun (Zoom)
;
; Hold to fire:
; F5  - mixed stream: heart, thumbs up, clap
; F6  - clap
; F7  - thumbs up
; F8  - heart
; F9  - tada / party
;
; This version uses only Zoom built-in shortcuts and a hold loop.

global activeKey := ""
global activeReaction := ""
global fireDelayMs := 70
global mixIndex := 0

global reactionHotkeys := Map(
    "clap", "{Alt down}{Shift down}{vk34}{Shift up}{Alt up}",
    "thumbs", "{Alt down}{Shift down}{vk35}{Shift up}{Alt up}",
    "heart", "{Alt down}{Shift down}{vk36}{Shift up}{Alt up}",
    "tada", "{Alt down}{Shift down}{vk39}{Shift up}{Alt up}"
)

$F5::StartReaction("F5", "mix", "Смешанный режим")
$F6::StartReaction("F6", "clap", "Аплодисменты")
$F7::StartReaction("F7", "thumbs", "Лайки")
$F8::StartReaction("F8", "heart", "Сердца")
$F9::StartReaction("F9", "tada", "Праздник")

$F5 Up::StopReaction("F5")
$F6 Up::StopReaction("F6")
$F7 Up::StopReaction("F7")
$F8 Up::StopReaction("F8")
$F9 Up::StopReaction("F9")

StartReaction(keyName, reactionName, tooltipText) {
    global activeKey, activeReaction

    activeKey := keyName
    activeReaction := reactionName

    ToolTip(tooltipText, 20, 20)
    SetTimer(() => ToolTip(), -600)

    SetTimer(() => FireLoop(keyName, reactionName), -1)
}

StopReaction(keyName) {
    global activeKey, activeReaction

    if activeKey != keyName {
        return
    }

    activeKey := ""
    activeReaction := ""
    ToolTip("Стоп", 20, 20)
    SetTimer(() => ToolTip(), -500)
}

FireLoop(keyName, reactionName) {
    global activeKey, activeReaction, fireDelayMs

    while activeKey = keyName && activeReaction = reactionName && GetKeyState(keyName, "P") {
        if !ActivateZoomWindow() {
            activeKey := ""
            activeReaction := ""
            ToolTip("Zoom не найден", 20, 20)
            SetTimer(() => ToolTip(), -1000)
            break
        }

        SendZoomReaction(reactionName)
        Sleep(fireDelayMs)
    }

    if activeKey = keyName && activeReaction = reactionName {
        activeKey := ""
        activeReaction := ""
    }
}

SendZoomReaction(reactionName) {
    global reactionHotkeys, mixIndex
    SetKeyDelay(30, 30)

    if reactionName = "mix" {
        mixIndex += 1
        if mixIndex > 3 {
            mixIndex := 1
        }

        if mixIndex = 1 {
            SendEvent(reactionHotkeys["heart"])
            return
        }

        if mixIndex = 2 {
            SendEvent(reactionHotkeys["thumbs"])
            return
        }

        if mixIndex = 3 {
            SendEvent(reactionHotkeys["clap"])
            return
        }
    }

    SendEvent(reactionHotkeys[reactionName])
}

ActivateZoomWindow() {
    zoomHwnd := WinExist("ahk_exe Zoom.exe")
    if !zoomHwnd {
        zoomHwnd := WinExist("ahk_exe Zoom Workplace.exe")
    }
    if !zoomHwnd {
        return false
    }

    WinActivate(zoomHwnd)
    WinWaitActive(zoomHwnd, , 0.5)
    Sleep(30)
    return true
}

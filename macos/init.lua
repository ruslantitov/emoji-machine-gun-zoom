hs.hotkey.alertDuration = 0.5
pcall(function()
  hs.ipc.cliInstall()
end)
hs.allowAppleScript(true)

local zoomBundleIds = {
  ["us.zoom.xos"] = true,
}

local activeKey = nil
local activeReaction = nil
local fireDelaySeconds = 0.07
local mixIndex = 0
local reactionTimer = nil
local appWatcher = nil
local caffeinateWatcher = nil
local activationEventtap = nil
local hotkeyWatchdog = nil
local hotkeyHandles = {}
local zoomSeen = false
local bindCount = 0
local lastBindAt = nil
local lastBindReason = nil
local lastHotkeyAt = nil
local lastHotkey = nil
local lastSendAt = nil
local lastSendReaction = nil
local lastSendApp = nil
local lastInputAt = nil
local lastInputKey = nil
local eventtapRestartCount = 0
local lastEventtapRestartAt = nil
local lastEventtapRestartReason = nil
local pressedActivationKeys = {}

local activationHotkeys = {
  mix = { mods = { "cmd" }, key = "1" },
  clap = { mods = { "cmd" }, key = "2" },
  thumbs = { mods = { "cmd" }, key = "3" },
  heart = { mods = { "cmd" }, key = "4" },
  tada = { mods = { "cmd" }, key = "5" },
}

local reactionHotkeys = {
  clap = { mods = { "alt", "cmd" }, key = "4" },
  thumbs = { mods = { "alt", "cmd" }, key = "5" },
  heart = { mods = { "alt", "cmd" }, key = "6" },
  tada = { mods = { "alt", "cmd" }, key = "9" },
}

local activationKeycodes = {
  [18] = { keyName = "mix", reactionName = "mix" },
  [19] = { keyName = "clap", reactionName = "clap" },
  [20] = { keyName = "thumbs", reactionName = "thumbs" },
  [21] = { keyName = "heart", reactionName = "heart" },
  [23] = { keyName = "tada", reactionName = "tada" },
}

local function getZoomApp()
  local app = hs.application.get("us.zoom.xos")
  if app and app:isRunning() then
    return app
  end

  app = hs.application.find("zoom.us")
  if app and app:isRunning() then
    return app
  end

  app = hs.application.find("Zoom Workplace")
  if app and app:isRunning() then
    return app
  end

  return nil
end

local function isZoomRunning()
  local app = getZoomApp()
  return app ~= nil and app:isRunning()
end

local function activateZoom()
  local app = getZoomApp()
  if not app then
    return nil
  end

  app:activate()
  hs.timer.usleep(30000)
  return app
end

local function sendZoomReaction(reactionName)
  local app = activateZoom()
  if not app then
    return false
  end

  if reactionName == "mix" then
    mixIndex = mixIndex + 1
    if mixIndex > 3 then
      mixIndex = 1
    end

    if mixIndex == 1 then
      reactionName = "heart"
    elseif mixIndex == 2 then
      reactionName = "thumbs"
    else
      reactionName = "clap"
    end
  end

  local shortcut = reactionHotkeys[reactionName]
  if not shortcut then
    return false
  end

  hs.eventtap.keyStroke(shortcut.mods, shortcut.key, 20000)
  lastSendAt = os.date("%Y-%m-%d %H:%M:%S")
  lastSendReaction = reactionName
  lastSendApp = app:name()
  return true
end

local function stopReaction(keyName)
  if activeKey ~= keyName then
    return
  end

  activeKey = nil
  activeReaction = nil

  if reactionTimer then
    reactionTimer:stop()
    reactionTimer = nil
  end

end

local function startReaction(keyName, reactionName)
  if activeKey == keyName and activeReaction == reactionName and reactionTimer then
    return
  end

  lastHotkeyAt = os.date("%Y-%m-%d %H:%M:%S")
  lastHotkey = keyName
  activeKey = keyName
  activeReaction = reactionName

  if reactionTimer then
    reactionTimer:stop()
    reactionTimer = nil
  end

  if not sendZoomReaction(reactionName) then
    stopReaction(keyName)
    return
  end

  reactionTimer = hs.timer.doEvery(fireDelaySeconds, function()
    if activeKey ~= keyName or activeReaction ~= reactionName then
      return
    end

    if not isZoomRunning() then
      stopReaction(keyName)
      return
    end

    if not sendZoomReaction(reactionName) then
      stopReaction(keyName)
    end
  end)
end

local function stopAllState()
  activeKey = nil
  activeReaction = nil

  if reactionTimer then
    reactionTimer:stop()
    reactionTimer = nil
  end
end

local function clearActivationHotkeys()
  for _, hotkey in ipairs(hotkeyHandles) do
    pcall(function() hotkey:delete() end)
  end
  hotkeyHandles = {}
end

local function bindActivationHotkeys(reason)
  clearActivationHotkeys()
  hotkeyHandles = {
    hs.hotkey.bind(activationHotkeys.mix.mods, activationHotkeys.mix.key, function() startReaction("mix", "mix") end, function() stopReaction("mix") end),
    hs.hotkey.bind(activationHotkeys.clap.mods, activationHotkeys.clap.key, function() startReaction("clap", "clap") end, function() stopReaction("clap") end),
    hs.hotkey.bind(activationHotkeys.thumbs.mods, activationHotkeys.thumbs.key, function() startReaction("thumbs", "thumbs") end, function() stopReaction("thumbs") end),
    hs.hotkey.bind(activationHotkeys.heart.mods, activationHotkeys.heart.key, function() startReaction("heart", "heart") end, function() stopReaction("heart") end),
    hs.hotkey.bind(activationHotkeys.tada.mods, activationHotkeys.tada.key, function() startReaction("tada", "tada") end, function() stopReaction("tada") end),
  }
  bindCount = bindCount + 1
  lastBindAt = os.date("%Y-%m-%d %H:%M:%S")
  lastBindReason = reason or "manual"
end

local function handleActivationEvent(event)
  local eventType = event:getType()
  local flags = event:getFlags()

  if eventType == hs.eventtap.event.types.flagsChanged then
    if activeKey and not flags.cmd then
      pressedActivationKeys = {}
      hs.timer.doAfter(0, stopAllState)
    end
    return false
  end

  local mapping = activationKeycodes[event:getKeyCode()]
  if not mapping then
    return false
  end

  if eventType == hs.eventtap.event.types.keyDown then
    if flags.cmd and not flags.alt and not flags.ctrl then
      lastInputAt = os.date("%Y-%m-%d %H:%M:%S")
      lastInputKey = mapping.keyName
      pressedActivationKeys[mapping.keyName] = true
      hs.timer.doAfter(0, function()
        if pressedActivationKeys[mapping.keyName] then
          startReaction(mapping.keyName, mapping.reactionName)
        end
      end)
      return true
    end
    return false
  end

  if eventType == hs.eventtap.event.types.keyUp then
    pressedActivationKeys[mapping.keyName] = nil
    if activeKey == mapping.keyName then
      hs.timer.doAfter(0, function()
        stopReaction(mapping.keyName)
      end)
      return true
    end
  end

  return false
end

local function startActivationEventtap(reason)
  if activationEventtap then
    pcall(function() activationEventtap:stop() end)
  end

  activationEventtap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, handleActivationEvent)
  activationEventtap:start()

  eventtapRestartCount = eventtapRestartCount + 1
  lastEventtapRestartAt = os.date("%Y-%m-%d %H:%M:%S")
  lastEventtapRestartReason = reason or "manual"
end

local function isActivationEventtapRunning()
  local ok, enabled = pcall(function()
    return activationEventtap ~= nil and activationEventtap:isEnabled()
  end)
  return ok and enabled or false
end

local function scheduleHotkeyRebinds(reason)
  local delays = { 1, 3, 8, 20, 45 }
  for _, delay in ipairs(delays) do
    hs.timer.doAfter(delay, function()
      if activeKey == nil then
        bindActivationHotkeys(reason .. "+" .. tostring(delay) .. "s")
        startActivationEventtap(reason .. "+" .. tostring(delay) .. "s")
      end
    end)
  end
end

local function handleZoomLifecycle(appName, eventType, appObject)
  local bundleId = appObject and appObject:bundleID() or nil
  if bundleId and not zoomBundleIds[bundleId] then
    return
  end

  local isZoomName = appName == "zoom.us" or appName == "Zoom Workplace"
  if not isZoomName and not bundleId then
    return
  end

  if eventType == hs.application.watcher.launched then
    zoomSeen = true
    scheduleHotkeyRebinds("zoom-launched")
    return
  end

  if eventType == hs.application.watcher.activated then
    zoomSeen = true
    hs.timer.doAfter(1, function()
      if activeKey == nil then
        bindActivationHotkeys("zoom-activated")
      end
    end)
    return
  end

  if eventType == hs.application.watcher.terminated then
    stopAllState()
    zoomSeen = false
  end
end

appWatcher = hs.application.watcher.new(handleZoomLifecycle)
appWatcher:start()

if isZoomRunning() then
  zoomSeen = true
end

bindActivationHotkeys("startup")
startActivationEventtap("startup")
scheduleHotkeyRebinds("startup")

hotkeyWatchdog = hs.timer.doEvery(30, function()
  if activeKey == nil then
    bindActivationHotkeys("watchdog")
    startActivationEventtap("watchdog")
  end
end)

caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake or eventType == hs.caffeinate.watcher.screensDidUnlock then
    stopAllState()
    scheduleHotkeyRebinds("wake-unlock")
  end
end)
caffeinateWatcher:start()

EmojiMachineGunZoom = {
  status = function()
    return {
      zoomRunning = isZoomRunning(),
      activeKey = activeKey,
      activeReaction = activeReaction,
      zoomSeen = zoomSeen,
      bindCount = bindCount,
      hotkeyCount = #hotkeyHandles,
      lastBindAt = lastBindAt,
      lastBindReason = lastBindReason,
      lastHotkeyAt = lastHotkeyAt,
      lastHotkey = lastHotkey,
      lastSendAt = lastSendAt,
      lastSendReaction = lastSendReaction,
      lastSendApp = lastSendApp,
      lastInputAt = lastInputAt,
      lastInputKey = lastInputKey,
      eventtapRunning = isActivationEventtapRunning(),
      eventtapRestartCount = eventtapRestartCount,
      lastEventtapRestartAt = lastEventtapRestartAt,
      lastEventtapRestartReason = lastEventtapRestartReason,
    }
  end,
  rebind = function()
    bindActivationHotkeys("manual-api")
    startActivationEventtap("manual-api")
    return EmojiMachineGunZoom.status()
  end,
  test = function(reactionName)
    return sendZoomReaction(reactionName or "heart")
  end,
}

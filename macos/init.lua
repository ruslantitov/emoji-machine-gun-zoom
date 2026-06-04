hs.hotkey.alertDuration = 0.5
pcall(function()
  hs.ipc.cliInstall()
end)
hs.allowAppleScript(true)

local zoomBundleIds = {
  ["us.zoom.xos"] = true,
  ["us.zoom.ZoomClips"] = true,
  ["us.zoom.ZoomRooms"] = true,
}

local activeKey = nil
local activeReaction = nil
local fireDelaySeconds = 0.07
local mixIndex = 0
local reactionTimer = nil
local appWatcher = nil
local zoomSeen = false

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

local function getZoomApp()
  for bundleId, _ in pairs(zoomBundleIds) do
    local app = hs.application.get(bundleId)
    if app and app:isRunning() then
      return app
    end
  end

  local app = hs.application.find("zoom.us")
  if app and app:isRunning() then
    return app
  end

  return hs.application.find("Zoom Workplace")
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

hs.hotkey.bind(activationHotkeys.mix.mods, activationHotkeys.mix.key, function() startReaction("mix", "mix") end, function() stopReaction("mix") end)
hs.hotkey.bind(activationHotkeys.clap.mods, activationHotkeys.clap.key, function() startReaction("clap", "clap") end, function() stopReaction("clap") end)
hs.hotkey.bind(activationHotkeys.thumbs.mods, activationHotkeys.thumbs.key, function() startReaction("thumbs", "thumbs") end, function() stopReaction("thumbs") end)
hs.hotkey.bind(activationHotkeys.heart.mods, activationHotkeys.heart.key, function() startReaction("heart", "heart") end, function() stopReaction("heart") end)
hs.hotkey.bind(activationHotkeys.tada.mods, activationHotkeys.tada.key, function() startReaction("tada", "tada") end, function() stopReaction("tada") end)

EmojiMachineGunZoom = {
  status = function()
    return {
      zoomRunning = isZoomRunning(),
      activeKey = activeKey,
      activeReaction = activeReaction,
      zoomSeen = zoomSeen,
    }
  end,
}

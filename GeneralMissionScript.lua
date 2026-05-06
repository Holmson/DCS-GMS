-- GeneralMissionScript.lua
-- Reusable single-player mission helper for DCS World.
-- No MIST, no MOOSE. Load with DO SCRIPT FILE after a mission config file.

--[[
Quick start:

1) Copy GMS_Config_Template.lua for your mission, for example:
   MyMission_GMS_Config.lua

2) Edit the copied config file. It must define the global table GMS_CONFIG.
   This is where you configure flags, zones, fuel thresholds, and watches.

3) In the Mission Editor, load files in this order:
   DO SCRIPT FILE -> MyMission_GMS_Config.lua
   DO SCRIPT FILE -> GeneralMissionScript.lua

4) Use Mission Editor triggers against the flags configured in GMS_CONFIG.

If no config file is loaded first, GMS starts with defaults, but no mission
flags are mapped.
--]]

GMS_CONFIG = GMS_CONFIG or {}
GMS = GMS or {}

GMS.version = "0.1.0"
GMS.started = GMS.started or false
GMS.playersByUnitName = GMS.playersByUnitName or {}
GMS.handlers = GMS.handlers or {}
GMS.watchState = GMS.watchState or {}
GMS.missionStartedEmitted = GMS.missionStartedEmitted or false

local DEFAULT_CONFIG = {
  debug = false,
  debugToScreen = false,
  debugScreenSeconds = 5,
  autoStart = true,
  logPrefix = "GMS",
  pollInterval = 2,
  pulseSeconds = 1,

  trackPlayerUnitsOnly = true,
  playerUnitNames = {},
  playerGroupNames = {},

  flagRules = {},

  fuel = {
    enabled = true,
    increaseDelta = 0.01,
    resetMargin = 0.05,
    resetThresholdsOnFuelIncrease = true,
    thresholds = {
      joker = 0.45,
      bingo = 0.30,
      emergency = 0.12,
    },
  },

  zones = {},
  zoneRules = {},

  roe = {
    enabled = false,
    allowedWeaponZones = {},
  },

  winchester = {
    enabled = true,
    includeGun = false,
    resetOnRearm = true,
    buckets = {
      all = true,
      aa = true,
      ag = true,
      guided = true,
      bombs = true,
    },
  },

  watches = {
    unitsDestroyed = {},
    groupsDestroyed = {},
    staticsDestroyed = {},
  },

  weaponClassOverrides = {
    -- ["AIM_120C"] = { role = "AA", call = "FOX3", guided = true, buckets = { aa = true, guided = true } },
  },
}

local function copyTable(src)
  if type(src) ~= "table" then
    return src
  end

  local dst = {}
  for k, v in pairs(src) do
    dst[k] = copyTable(v)
  end
  return dst
end

local function mergeTable(base, override)
  local result = copyTable(base)

  if type(override) ~= "table" then
    return result
  end

  for k, v in pairs(override) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = mergeTable(result[k], v)
    else
      result[k] = copyTable(v)
    end
  end

  return result
end

GMS.config = mergeTable(DEFAULT_CONFIG, GMS_CONFIG)

local function dcsLog(level, message)
  local text = string.format("[%s] %s", GMS.config.logPrefix or "GMS", tostring(message))

  if env and env.info and level == "info" then
    env.info(text)
  elseif env and env.warning and level == "warning" then
    env.warning(text)
  elseif env and env.error and level == "error" then
    env.error(text)
  elseif env and env.info then
    env.info(text)
  end

  if GMS.config.debugToScreen and trigger and trigger.action and trigger.action.outText then
    local seconds = tonumber(GMS.config.debugScreenSeconds) or 5
    trigger.action.outText(text, seconds)
  end
end

function GMS.log(message)
  if GMS.config.debug then
    dcsLog("info", message)
  end
end

function GMS.warn(message)
  dcsLog("warning", message)
end

local function safeCall(fn, fallback)
  local ok, result = pcall(fn)
  if ok then
    return result
  end
  return fallback
end

local function safeMethod(obj, methodName, ...)
  if not obj or type(obj[methodName]) ~= "function" then
    return nil
  end

  local args = { ... }
  return safeCall(function()
    return obj[methodName](obj, unpack(args))
  end, nil)
end

local function isExisting(obj)
  if not obj then
    return false
  end

  local exists = safeMethod(obj, "isExist")
  if exists == false then
    return false
  end

  return true
end

local function getObjectName(obj)
  return safeMethod(obj, "getName") or safeMethod(obj, "getTypeName") or "unknown"
end

local function getTypeName(obj)
  return safeMethod(obj, "getTypeName") or "unknown"
end

local function getCoalition(obj)
  return safeMethod(obj, "getCoalition")
end

local function getGroupName(unit)
  local group = safeMethod(unit, "getGroup")
  return safeMethod(group, "getName")
end

local function getPlayerName(unit)
  return safeMethod(unit, "getPlayerName")
end

local function getPoint(obj)
  return safeMethod(obj, "getPoint")
end

local function distance2d(a, b)
  if not a or not b then
    return nil
  end

  local dx = (a.x or 0) - (b.x or 0)
  local dz = (a.z or 0) - (b.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function normalizeId(value)
  local s = tostring(value or "unknown")
  s = string.lower(s)
  s = string.gsub(s, "[^%w_]+", "_")
  s = string.gsub(s, "_+", "_")
  s = string.gsub(s, "^_", "")
  s = string.gsub(s, "_$", "")
  if s == "" then
    return "unknown"
  end
  return s
end

local function toNumber(value, fallback)
  local n = tonumber(value)
  if n ~= nil then
    return n
  end
  return fallback
end

local function listHasAnyValues(t)
  if type(t) ~= "table" then
    return false
  end

  for _, _ in pairs(t) do
    return true
  end

  return false
end

local function getUnitByName(name)
  if Unit and Unit.getByName then
    return safeCall(function()
      return Unit.getByName(name)
    end, nil)
  end
  return nil
end

local function getGroupByName(name)
  if Group and Group.getByName then
    return safeCall(function()
      return Group.getByName(name)
    end, nil)
  end
  return nil
end

local function getStaticByName(name)
  if StaticObject and StaticObject.getByName then
    return safeCall(function()
      return StaticObject.getByName(name)
    end, nil)
  end
  return nil
end

local function getPlaceName(place)
  if not place then
    return nil
  end

  return safeMethod(place, "getName") or safeMethod(place, "getTypeName")
end

local function getFlag(flag)
  if not trigger or not trigger.misc or not trigger.misc.getUserFlag then
    return 0
  end

  return toNumber(safeCall(function()
    return trigger.misc.getUserFlag(flag)
  end, 0), 0)
end

local function setFlag(flag, value)
  if not flag then
    return
  end

  if trigger and trigger.action and trigger.action.setUserFlag then
    safeCall(function()
      trigger.action.setUserFlag(flag, value)
    end, nil)
  end
end

local function scheduleOnce(delaySeconds, fn)
  if timer and timer.scheduleFunction and timer.getTime then
    timer.scheduleFunction(function()
      fn()
      return nil
    end, nil, timer.getTime() + delaySeconds)
  else
    fn()
  end
end

local function applySingleFlagRule(eventName, eventData, rule)
  if type(rule) ~= "table" or not rule.flag then
    return
  end

  local mode = rule.mode or "latch"
  local flag = rule.flag
  local value = rule.value

  if mode == "counter" then
    local increment = toNumber(rule.increment or eventData.increment, 1)
    setFlag(flag, getFlag(flag) + increment)
  elseif mode == "state" then
    if eventData.state then
      setFlag(flag, value or 1)
    else
      setFlag(flag, 0)
    end
  elseif mode == "pulse" then
    setFlag(flag, value or 1)
    scheduleOnce(rule.seconds or GMS.config.pulseSeconds or 1, function()
      setFlag(flag, 0)
    end)
  elseif mode == "clear" then
    setFlag(flag, 0)
  elseif mode == "value" then
    setFlag(flag, value or eventData.value or 1)
  else
    setFlag(flag, value or 1)
  end

  GMS.log(string.format("Flag rule: %s -> %s (%s)", eventName, tostring(flag), mode))
end

local function applyFlagRules(eventName, eventData)
  local rules = GMS.config.flagRules and GMS.config.flagRules[eventName]
  if not rules then
    return
  end

  if rules.flag then
    applySingleFlagRule(eventName, eventData, rules)
    return
  end

  for _, rule in ipairs(rules) do
    applySingleFlagRule(eventName, eventData, rule)
  end
end

function GMS.on(eventName, callback)
  if not GMS.handlers[eventName] then
    GMS.handlers[eventName] = {}
  end

  table.insert(GMS.handlers[eventName], callback)
end

local function runHandlers(eventName, data)
  local handlers = GMS.handlers[eventName]
  if handlers then
    for _, callback in ipairs(handlers) do
      safeCall(function()
        callback(data)
      end, nil)
    end
  end

  local wildcardHandlers = GMS.handlers["*"]
  if wildcardHandlers then
    for _, callback in ipairs(wildcardHandlers) do
      safeCall(function()
        callback(eventName, data)
      end, nil)
    end
  end
end

function GMS.emit(eventName, data)
  data = data or {}
  data.eventName = eventName
  data.time = data.time or (timer and timer.getTime and timer.getTime()) or 0

  GMS.log("Event: " .. eventName)
  applyFlagRules(eventName, data)
  runHandlers(eventName, data)
end

local function emitMissionStarted(data)
  if GMS.missionStartedEmitted then
    return
  end

  GMS.missionStartedEmitted = true
  GMS.emit("mission.started", data or {})
end

local function getEventId(name)
  if world and world.event then
    return world.event[name]
  end
  return nil
end

local function eventIs(event, name)
  local id = getEventId(name)
  return id ~= nil and event and event.id == id
end

local function makePlayerData(unit, reason)
  local unitName = getObjectName(unit)
  local player = GMS.playersByUnitName[unitName] or {
    unitName = unitName,
    firstSeenReason = reason,
    zoneStates = {},
    zoneRuleStates = {},
    fuelTriggered = {},
    winchesterTriggered = {},
    counters = {
      shots = 0,
      hits = 0,
      kills = 0,
    },
  }

  player.unit = unit
  player.unitName = unitName
  player.groupName = getGroupName(unit)
  player.playerName = getPlayerName(unit) or player.playerName
  player.typeName = getTypeName(unit)
  player.lastSeen = (timer and timer.getTime and timer.getTime()) or 0
  player.alive = player.alive ~= false

  GMS.playersByUnitName[unitName] = player
  return player
end

local function basePlayerEventData(player, event)
  return {
    player = player,
    unit = player and player.unit,
    unitName = player and player.unitName,
    groupName = player and player.groupName,
    playerName = player and player.playerName,
    typeName = player and player.typeName,
    rawEvent = event,
  }
end

local function resolvePlayerUnit(player)
  if not player then
    return nil
  end

  if isExisting(player.unit) then
    return player.unit
  end

  local unit = getUnitByName(player.unitName)
  if isExisting(unit) then
    player.unit = unit
    return unit
  end

  return nil
end

local function isConfiguredPlayerUnit(unit)
  local unitName = getObjectName(unit)
  local groupName = getGroupName(unit)

  if GMS.config.playerUnitNames and GMS.config.playerUnitNames[unitName] then
    return true
  end

  if GMS.config.playerGroupNames and groupName and GMS.config.playerGroupNames[groupName] then
    return true
  end

  return false
end

local function isTrackedUnit(unit)
  if not isExisting(unit) then
    return false
  end

  local unitName = getObjectName(unit)
  if GMS.playersByUnitName[unitName] then
    return true
  end

  if isConfiguredPlayerUnit(unit) then
    return true
  end

  if not GMS.config.trackPlayerUnitsOnly then
    return true
  end

  return getPlayerName(unit) ~= nil
end

local function trackUnitIfNeeded(unit, reason)
  if not isTrackedUnit(unit) then
    return nil
  end

  return makePlayerData(unit, reason)
end

local function emitPlayerState(player, stateName, value, eventName, event)
  if not player then
    return
  end

  if player[stateName] == value then
    return
  end

  player[stateName] = value

  local data = basePlayerEventData(player, event)
  data.state = value
  GMS.emit(eventName, data)
end

local function pointInZone(point, zoneName)
  if not point or not trigger or not trigger.misc or not trigger.misc.getZone then
    return false
  end

  local zone = safeCall(function()
    return trigger.misc.getZone(zoneName)
  end, nil)

  if not zone or not zone.point or not zone.radius then
    return false
  end

  local dist = distance2d(point, zone.point)
  return dist ~= nil and dist <= zone.radius
end

local function pointInAnyZone(point, zoneNames)
  if type(zoneNames) ~= "table" then
    return false
  end

  for _, zoneName in ipairs(zoneNames) do
    if pointInZone(point, zoneName) then
      return true
    end
  end

  return false
end

local function getSpeedMps(unit)
  local velocity = safeMethod(unit, "getVelocity")
  if not velocity then
    return nil
  end

  local x = velocity.x or 0
  local y = velocity.y or 0
  local z = velocity.z or 0
  return math.sqrt(x * x + y * y + z * z)
end

local function getFuelFraction(unit)
  return safeMethod(unit, "getFuel")
end

local function upperText(value)
  return string.upper(tostring(value or ""))
end

local function textContainsAny(text, patterns)
  for _, pattern in ipairs(patterns) do
    if string.find(text, pattern) then
      return true
    end
  end
  return false
end

local function bucketTable(...)
  local buckets = {}
  local values = { ... }
  for _, value in ipairs(values) do
    buckets[value] = true
  end
  return buckets
end

local function classifyWeaponByName(typeName)
  local text = upperText(typeName)

  if text == "" or text == "UNKNOWN" then
    return {
      role = "UNKNOWN",
      call = nil,
      guided = false,
      buckets = {},
      relevant = false,
    }
  end

  local override = GMS.config.weaponClassOverrides and GMS.config.weaponClassOverrides[typeName]
  if not override then
    override = GMS.config.weaponClassOverrides and GMS.config.weaponClassOverrides[text]
  end

  if override then
    return {
      role = override.role or "UNKNOWN",
      call = override.call,
      guided = override.guided == true,
      buckets = override.buckets or {},
      relevant = override.relevant ~= false,
    }
  end

  if textContainsAny(text, { "AIM_120", "AIM%-120", "AIM120", "SD%-10", "R%-77", "R_77", "METEOR" }) then
    return { role = "AA", call = "FOX3", guided = true, buckets = bucketTable("aa", "guided"), relevant = true }
  end

  if textContainsAny(text, { "AIM_7", "AIM%-7", "AIM7", "R%-27", "R_27", "R%-33", "R_33" }) then
    return { role = "AA", call = "FOX1", guided = true, buckets = bucketTable("aa", "guided"), relevant = true }
  end

  if textContainsAny(text, { "AIM_9", "AIM%-9", "AIM9", "R%-73", "R_73", "R%-60", "R_60", "MAGIC", "MICA_IR" }) then
    return { role = "AA", call = "FOX2", guided = true, buckets = bucketTable("aa", "guided"), relevant = true }
  end

  if textContainsAny(text, { "AGM_88", "AGM%-88", "KH%-58", "KH_58", "LD%-10" }) then
    return { role = "SEAD", call = "MAGNUM", guided = true, buckets = bucketTable("ag", "guided"), relevant = true }
  end

  if textContainsAny(text, { "AGM_65", "AGM%-65", "KH%-25", "KH_25", "KH%-29", "KH_29" }) then
    return { role = "AG", call = "RIFLE", guided = true, buckets = bucketTable("ag", "guided"), relevant = true }
  end

  if textContainsAny(text, { "AGM_84", "AGM%-84", "HARPOON", "RB%-15", "RB_15", "C%-802", "C_802" }) then
    return { role = "ANTI_SHIP", call = "BRUISER", guided = true, buckets = bucketTable("ag", "guided"), relevant = true }
  end

  if textContainsAny(text, { "GBU", "LS_6", "LS%-6", "JDAM", "JSOW", "CBU_10", "CBU%-10", "SDB" }) then
    return { role = "BOMB", call = nil, guided = true, buckets = bucketTable("ag", "guided", "bombs"), relevant = true }
  end

  if textContainsAny(text, { "MK_8", "MK%-8", "FAB", "BETAB", "SAMP", "BOMB", "ROCKEYE", "CBU" }) then
    return { role = "BOMB", call = nil, guided = false, buckets = bucketTable("ag", "bombs"), relevant = true }
  end

  if textContainsAny(text, { "HYDRA", "S%-8", "S_8", "S%-13", "S_13", "ZUNI", "ROCKET" }) then
    return { role = "ROCKET", call = nil, guided = false, buckets = bucketTable("ag"), relevant = true }
  end

  if textContainsAny(text, { "SHELL", "CANNON", "GUN", "M61", "GAU", "GSH", "NR_30" }) then
    return { role = "GUN", call = nil, guided = false, buckets = {}, relevant = GMS.config.winchester.includeGun == true }
  end

  if textContainsAny(text, { "AGM", "KH", "KAB", "MAV" }) then
    return { role = "AG", call = nil, guided = true, buckets = bucketTable("ag", "guided"), relevant = true }
  end

  return {
    role = "UNKNOWN",
    call = nil,
    guided = false,
    buckets = {},
    relevant = true,
  }
end

local function classifyWeaponObject(weapon)
  local typeName = getTypeName(weapon)
  local info = classifyWeaponByName(typeName)
  info.typeName = typeName
  return info
end

local function emitWeaponClassEvents(player, event, baseEventName, weaponInfo)
  local data = basePlayerEventData(player, event)
  data.weapon = event and event.weapon
  data.weaponTypeName = weaponInfo.typeName
  data.weaponRole = weaponInfo.role
  data.weaponCall = weaponInfo.call
  data.weaponGuided = weaponInfo.guided
  data.weaponBuckets = weaponInfo.buckets

  GMS.emit(baseEventName, data)

  if weaponInfo.role and weaponInfo.role ~= "UNKNOWN" then
    GMS.emit(baseEventName .. "." .. normalizeId(weaponInfo.role), data)
  end

  if weaponInfo.call then
    GMS.emit(baseEventName .. "." .. normalizeId(weaponInfo.call), data)
  end

  if weaponInfo.guided then
    GMS.emit(baseEventName .. ".guided", data)
  end

  if weaponInfo.buckets then
    for bucket, enabled in pairs(weaponInfo.buckets) do
      if enabled then
        GMS.emit(baseEventName .. "." .. normalizeId(bucket), data)
      end
    end
  end
end

local function checkFriendlyFire(player, event)
  local initiator = event and event.initiator
  local target = event and event.target

  if not initiator or not target then
    return
  end

  local initiatorCoalition = getCoalition(initiator)
  local targetCoalition = getCoalition(target)

  if initiatorCoalition and targetCoalition and initiatorCoalition == targetCoalition and getObjectName(initiator) ~= getObjectName(target) then
    local data = basePlayerEventData(player, event)
    data.target = target
    data.targetName = getObjectName(target)
    data.targetTypeName = getTypeName(target)
    GMS.emit("player.weapon.friendly_fire", data)
  end
end

local function checkRoeWeaponRelease(player, event)
  if not GMS.config.roe or not GMS.config.roe.enabled then
    return
  end

  local allowedZones = GMS.config.roe.allowedWeaponZones or {}
  if not listHasAnyValues(allowedZones) then
    return
  end

  local point = getPoint(event and event.initiator)
  if not pointInAnyZone(point, allowedZones) then
    local data = basePlayerEventData(player, event)
    data.weapon = event and event.weapon
    data.weaponTypeName = event and event.weapon and getTypeName(event.weapon) or nil
    GMS.emit("player.weapon.roe_violation", data)
  end
end

local function emitWinchester(player, bucket, state)
  if not GMS.config.winchester.buckets[bucket] then
    return
  end

  local data = basePlayerEventData(player, nil)
  data.bucket = bucket
  data.state = state

  if state then
    GMS.emit("player.winchester." .. bucket, data)
  else
    GMS.emit("player.winchester." .. bucket .. "_reset", data)
  end
end

local function checkWinchester(player)
  if not GMS.config.winchester.enabled then
    return
  end

  local unit = resolvePlayerUnit(player)
  if not unit then
    return
  end

  local ammo = safeMethod(unit, "getAmmo")
  if type(ammo) ~= "table" then
    return
  end

  local counts = {
    all = 0,
    aa = 0,
    ag = 0,
    guided = 0,
    bombs = 0,
  }

  for _, item in ipairs(ammo) do
    local count = toNumber(item.count, 0)
    if count > 0 then
      local desc = item.desc or {}
      local typeName = desc.typeName or desc.displayName or item.typeName or "unknown"
      local info = classifyWeaponByName(typeName)

      if info.relevant then
        counts.all = counts.all + count
      end

      if info.buckets then
        for bucket, enabled in pairs(info.buckets) do
          if enabled and counts[bucket] ~= nil then
            counts[bucket] = counts[bucket] + count
          end
        end
      end
    end
  end

  player.ammoCounts = counts

  for bucket, count in pairs(counts) do
    local isWinchester = count <= 0
    local wasWinchester = player.winchesterTriggered[bucket] == true

    if isWinchester and not wasWinchester then
      player.winchesterTriggered[bucket] = true
      emitWinchester(player, bucket, true)
    elseif not isWinchester and wasWinchester and GMS.config.winchester.resetOnRearm then
      player.winchesterTriggered[bucket] = false
      emitWinchester(player, bucket, false)
    end
  end
end

local function handleFuel(player)
  local fuelConfig = GMS.config.fuel or {}
  if fuelConfig.enabled == false then
    return
  end

  local unit = resolvePlayerUnit(player)
  if not unit then
    return
  end

  local fuel = getFuelFraction(unit)
  if fuel == nil then
    return
  end

  local previousFuel = player.fuel
  player.fuel = fuel

  if previousFuel and fuel > previousFuel + (fuelConfig.increaseDelta or 0.01) then
    local data = basePlayerEventData(player, nil)
    data.previousFuel = previousFuel
    data.fuel = fuel
    data.deltaFuel = fuel - previousFuel
    GMS.emit("player.fuel.increased", data)
  end

  for thresholdName, thresholdValue in pairs(fuelConfig.thresholds or {}) do
    local triggered = player.fuelTriggered[thresholdName] == true

    if fuel <= thresholdValue and not triggered then
      player.fuelTriggered[thresholdName] = true

      local data = basePlayerEventData(player, nil)
      data.fuel = fuel
      data.thresholdName = thresholdName
      data.thresholdValue = thresholdValue
      data.state = true
      GMS.emit("player.fuel." .. normalizeId(thresholdName), data)
    elseif triggered and fuelConfig.resetThresholdsOnFuelIncrease and fuel > thresholdValue + (fuelConfig.resetMargin or 0.05) then
      player.fuelTriggered[thresholdName] = false

      local data = basePlayerEventData(player, nil)
      data.fuel = fuel
      data.thresholdName = thresholdName
      data.thresholdValue = thresholdValue
      data.state = false
      GMS.emit("player.fuel." .. normalizeId(thresholdName) .. "_reset", data)
    end
  end
end

local function handleZoneTransitions(player)
  local unit = resolvePlayerUnit(player)
  if not unit then
    return
  end

  local point = getPoint(unit)
  if not point then
    return
  end

  for _, zoneConfig in ipairs(GMS.config.zones or {}) do
    local zoneName = zoneConfig.name
    local zoneId = normalizeId(zoneConfig.id or zoneName)

    if zoneName then
      local inside = pointInZone(point, zoneName)
      local previous = player.zoneStates[zoneId]

      if previous == nil then
        player.zoneStates[zoneId] = inside
      elseif previous ~= inside then
        player.zoneStates[zoneId] = inside

        local data = basePlayerEventData(player, nil)
        data.zoneName = zoneName
        data.zoneId = zoneId
        data.state = inside
        data.point = point

        if inside then
          GMS.emit("player.zone.enter", data)
          GMS.emit("player.zone." .. zoneId .. ".enter", data)

          if zoneConfig.violationOnEnter then
            GMS.emit("player.zone.violation", data)
            GMS.emit("player.zone." .. zoneId .. ".violation", data)
          end
        else
          GMS.emit("player.zone.leave", data)
          GMS.emit("player.zone." .. zoneId .. ".leave", data)

          if zoneConfig.violationOnLeave then
            GMS.emit("player.zone.violation", data)
            GMS.emit("player.zone." .. zoneId .. ".violation", data)
          end
        end
      end
    end
  end
end

local function zoneRuleMatches(rule, point, altitudeMeters, speedMps)
  if rule.zone and not pointInZone(point, rule.zone) then
    return false
  end

  if rule.altitudeBelowMeters and not (altitudeMeters < rule.altitudeBelowMeters) then
    return false
  end

  if rule.altitudeAboveMeters and not (altitudeMeters > rule.altitudeAboveMeters) then
    return false
  end

  if rule.speedBelowKph and not ((speedMps or 0) * 3.6 < rule.speedBelowKph) then
    return false
  end

  if rule.speedAboveKph and not ((speedMps or 0) * 3.6 > rule.speedAboveKph) then
    return false
  end

  return true
end

local function handleZoneRules(player)
  local unit = resolvePlayerUnit(player)
  if not unit then
    return
  end

  local point = getPoint(unit)
  if not point then
    return
  end

  local altitudeMeters = point.y or 0
  local speedMps = getSpeedMps(unit)

  for _, rule in ipairs(GMS.config.zoneRules or {}) do
    local id = normalizeId(rule.id or rule.event or "zone_rule")
    local eventName = rule.event or ("player.zone_rule." .. id)
    local matched = zoneRuleMatches(rule, point, altitudeMeters, speedMps)
    local previous = player.zoneRuleStates[id]

    if previous == nil then
      player.zoneRuleStates[id] = matched
    elseif previous ~= matched then
      player.zoneRuleStates[id] = matched

      local data = basePlayerEventData(player, nil)
      data.ruleId = id
      data.zoneName = rule.zone
      data.altitudeMeters = altitudeMeters
      data.speedMps = speedMps
      data.speedKph = speedMps and speedMps * 3.6 or nil
      data.state = matched
      GMS.emit(eventName, data)

      if matched then
        GMS.emit(eventName .. ".enter", data)
      else
        GMS.emit(eventName .. ".clear", data)
      end
    end
  end
end

local function handleAirbornePolling(player)
  local unit = resolvePlayerUnit(player)
  if not unit then
    return
  end

  local inAir = safeMethod(unit, "inAir")
  if inAir == nil then
    return
  end

  if inAir then
    emitPlayerState(player, "airborne", true, "player.airborne_state", nil)
    emitPlayerState(player, "onGround", false, "player.on_ground_state", nil)
  else
    emitPlayerState(player, "airborne", false, "player.airborne_state", nil)
    emitPlayerState(player, "onGround", true, "player.on_ground_state", nil)
  end
end

local function isUnitDeadByName(name)
  local unit = getUnitByName(name)
  if not isExisting(unit) then
    return true
  end

  local life = safeMethod(unit, "getLife")
  return life ~= nil and life <= 1
end

local function isStaticDeadByName(name)
  local static = getStaticByName(name)
  if not isExisting(static) then
    return true
  end

  local life = safeMethod(static, "getLife")
  return life ~= nil and life <= 1
end

local function isGroupDeadByName(name)
  local group = getGroupByName(name)
  if not isExisting(group) then
    return true
  end

  local units = safeMethod(group, "getUnits")
  if type(units) ~= "table" or #units == 0 then
    return true
  end

  for _, unit in ipairs(units) do
    if isExisting(unit) and not isUnitDeadByName(getObjectName(unit)) then
      return false
    end
  end

  return true
end

local function checkWatchList(kind, list, checker)
  if type(list) ~= "table" then
    return
  end

  for _, watch in ipairs(list) do
    local key = kind .. ":" .. tostring(watch.name or watch.event or "unknown")
    if not GMS.watchState[key] and watch.name and checker(watch.name) then
      GMS.watchState[key] = true

      local data = {
        watch = watch,
        watchKind = kind,
        targetName = watch.name,
        state = true,
      }

      GMS.emit(watch.event or ("objective." .. normalizeId(watch.name) .. ".destroyed"), data)
    end
  end
end

local function handleWatches()
  local watches = GMS.config.watches or {}
  checkWatchList("unit", watches.unitsDestroyed, isUnitDeadByName)
  checkWatchList("group", watches.groupsDestroyed, isGroupDeadByName)
  checkWatchList("static", watches.staticsDestroyed, isStaticDeadByName)
end

function GMS.poll()
  for _, player in pairs(GMS.playersByUnitName) do
    if resolvePlayerUnit(player) then
      handleAirbornePolling(player)
      handleFuel(player)
      handleZoneTransitions(player)
      handleZoneRules(player)
      checkWinchester(player)
    end
  end

  handleWatches()
end

local function schedulePoll()
  if not timer or not timer.scheduleFunction or not timer.getTime then
    return
  end

  timer.scheduleFunction(function()
    safeCall(function()
      GMS.poll()
    end, nil)
    return timer.getTime() + (GMS.config.pollInterval or 2)
  end, nil, timer.getTime() + (GMS.config.pollInterval or 2))
end

local function handlePlayerEnter(event, eventName)
  local player = makePlayerData(event.initiator, eventName)
  local data = basePlayerEventData(player, event)

  GMS.emit(eventName, data)

  data.state = true
  GMS.emit("player.alive", data)

  GMS.emit("player.airframe_detected", data)
  GMS.emit("player.airframe." .. normalizeId(player.typeName), data)
end

local function handleTakeoffEvent(event, eventName)
  local player = trackUnitIfNeeded(event.initiator, eventName)
  if not player then
    return
  end

  local wasAirborne = player.airborne == true
  player.airborne = true
  player.onGround = false
  player.lastTakeoffPlaceName = getPlaceName(event.place)

  local data = basePlayerEventData(player, event)
  data.place = event.place
  data.placeName = player.lastTakeoffPlaceName
  data.state = true
  GMS.emit(eventName, data)

  if not wasAirborne then
    GMS.emit("player.airborne", data)
  end
end

local function handleLandingEvent(event, eventName)
  local player = trackUnitIfNeeded(event.initiator, eventName)
  if not player then
    return
  end

  local wasOnGround = player.onGround == true
  player.airborne = false
  player.onGround = true
  player.lastLandingPlaceName = getPlaceName(event.place)

  local data = basePlayerEventData(player, event)
  data.place = event.place
  data.placeName = player.lastLandingPlaceName
  data.state = true
  GMS.emit(eventName, data)

  if not wasOnGround then
    GMS.emit("player.on_ground", data)
  end

  if eventName == "player.land" and data.placeName then
    GMS.emit("player.land_at." .. normalizeId(data.placeName), data)
  end
end

local function handleRefuelingStart(event)
  local player = trackUnitIfNeeded(event.initiator, "player.refueling.start")
  if not player then
    return
  end

  player.refueling = true
  player.refuelStartFuel = getFuelFraction(event.initiator)

  local data = basePlayerEventData(player, event)
  data.fuel = player.refuelStartFuel
  data.state = true
  GMS.emit("player.refueling.start", data)
end

local function handleRefuelingStop(event)
  local player = trackUnitIfNeeded(event.initiator, "player.refueling.stop")
  if not player then
    return
  end

  local finalFuel = getFuelFraction(event.initiator)
  local deltaFuel = nil

  if player.refuelStartFuel and finalFuel then
    deltaFuel = finalFuel - player.refuelStartFuel
  end

  player.refueling = false

  local data = basePlayerEventData(player, event)
  data.fuel = finalFuel
  data.previousFuel = player.refuelStartFuel
  data.deltaFuel = deltaFuel
  data.state = false
  GMS.emit("player.refueling.stop", data)

  if deltaFuel and deltaFuel > 0 then
    GMS.emit("player.aar.fuel_received", data)
  end
end

local function handleWeaponEvent(event, eventName)
  local player = trackUnitIfNeeded(event.initiator, eventName)
  if not player then
    return
  end

  local weaponInfo = classifyWeaponObject(event.weapon)
  emitWeaponClassEvents(player, event, eventName, weaponInfo)
  checkRoeWeaponRelease(player, event)

  scheduleOnce(0.5, function()
    checkWinchester(player)
  end)
end

local function handleHitEvent(event)
  local initiatorPlayer = trackUnitIfNeeded(event.initiator, "player.weapon.hit")
  if initiatorPlayer then
    initiatorPlayer.counters.hits = initiatorPlayer.counters.hits + 1

    local data = basePlayerEventData(initiatorPlayer, event)
    data.target = event.target
    data.targetName = getObjectName(event.target)
    data.targetTypeName = getTypeName(event.target)
    GMS.emit("player.weapon.hit", data)
    checkFriendlyFire(initiatorPlayer, event)
  end

  local targetPlayer = trackUnitIfNeeded(event.target, "player.hit")
  if targetPlayer then
    local data = basePlayerEventData(targetPlayer, event)
    data.attacker = event.initiator
    data.attackerName = getObjectName(event.initiator)
    data.attackerTypeName = getTypeName(event.initiator)
    GMS.emit("player.hit", data)
  end
end

local function handleKillEvent(event)
  local initiatorPlayer = trackUnitIfNeeded(event.initiator, "player.weapon.kill")
  if initiatorPlayer then
    initiatorPlayer.counters.kills = initiatorPlayer.counters.kills + 1

    local data = basePlayerEventData(initiatorPlayer, event)
    data.target = event.target
    data.targetName = getObjectName(event.target)
    data.targetTypeName = getTypeName(event.target)
    GMS.emit("player.weapon.kill", data)
    checkFriendlyFire(initiatorPlayer, event)
  end

  local targetPlayer = trackUnitIfNeeded(event.target, "player.dead")
  if targetPlayer then
    targetPlayer.alive = false
    local data = basePlayerEventData(targetPlayer, event)
    data.attacker = event.initiator
    data.attackerName = getObjectName(event.initiator)
    data.state = true
    GMS.emit("player.dead", data)

    data.state = false
    GMS.emit("player.alive", data)
  end
end

local function handlePlayerTerminalEvent(event, eventName, stateField)
  local player = trackUnitIfNeeded(event.initiator, eventName)
  if not player then
    return
  end

  player[stateField] = true
  if eventName == "player.dead" or eventName == "player.crashed" or eventName == "player.pilot_dead" then
    player.alive = false
  end

  local data = basePlayerEventData(player, event)
  data.state = true
  GMS.emit(eventName, data)

  if eventName == "player.dead" or eventName == "player.crashed" or eventName == "player.pilot_dead" then
    data.state = false
    GMS.emit("player.alive", data)
  end
end

function GMS:onEvent(event)
  if not event or not event.id then
    return
  end

  if eventIs(event, "S_EVENT_MISSION_START") then
    emitMissionStarted({ rawEvent = event, source = "dcs_event" })
    return
  end

  if eventIs(event, "S_EVENT_MISSION_END") then
    GMS.emit("mission.ended", { rawEvent = event })
    return
  end

  if eventIs(event, "S_EVENT_PLAYER_ENTER_UNIT") then
    if isExisting(event.initiator) then
      handlePlayerEnter(event, "player.enter_unit")
    end
    return
  end

  if eventIs(event, "S_EVENT_TOOK_CONTROL") then
    if isExisting(event.initiator) then
      handlePlayerEnter(event, "player.took_control")
    end
    return
  end

  if eventIs(event, "S_EVENT_PLAYER_LEAVE_UNIT") then
    local player = trackUnitIfNeeded(event.initiator, "player.leave_unit")
    if player then
      GMS.emit("player.leave_unit", basePlayerEventData(player, event))
    else
      GMS.emit("player.leave_unit.unknown", { rawEvent = event })
    end
    return
  end

  if eventIs(event, "S_EVENT_ENGINE_STARTUP") then
    local player = trackUnitIfNeeded(event.initiator, "player.engine.startup")
    if player then
      GMS.emit("player.engine.startup", basePlayerEventData(player, event))
    end
    return
  end

  if eventIs(event, "S_EVENT_ENGINE_SHUTDOWN") then
    local player = trackUnitIfNeeded(event.initiator, "player.engine.shutdown")
    if player then
      GMS.emit("player.engine.shutdown", basePlayerEventData(player, event))
    end
    return
  end

  if eventIs(event, "S_EVENT_RUNWAY_TAKEOFF") then
    handleTakeoffEvent(event, "player.runway_takeoff")
    return
  end

  if eventIs(event, "S_EVENT_TAKEOFF") then
    handleTakeoffEvent(event, "player.takeoff")
    return
  end

  if eventIs(event, "S_EVENT_RUNWAY_TOUCH") then
    handleLandingEvent(event, "player.runway_touch")
    return
  end

  if eventIs(event, "S_EVENT_LAND") then
    handleLandingEvent(event, "player.land")
    return
  end

  if eventIs(event, "S_EVENT_REFUELING") then
    handleRefuelingStart(event)
    return
  end

  if eventIs(event, "S_EVENT_REFUELING_STOP") then
    handleRefuelingStop(event)
    return
  end

  if eventIs(event, "S_EVENT_SHOT") then
    handleWeaponEvent(event, "player.weapon.fired")
    return
  end

  if eventIs(event, "S_EVENT_WEAPON_DROP") then
    handleWeaponEvent(event, "player.weapon.dropped")
    return
  end

  if eventIs(event, "S_EVENT_SHOOTING_START") then
    local player = trackUnitIfNeeded(event.initiator, "player.weapon.gun_start")
    if player then
      GMS.emit("player.weapon.gun_start", basePlayerEventData(player, event))
    end
    return
  end

  if eventIs(event, "S_EVENT_SHOOTING_END") then
    local player = trackUnitIfNeeded(event.initiator, "player.weapon.gun_end")
    if player then
      GMS.emit("player.weapon.gun_end", basePlayerEventData(player, event))
    end
    return
  end

  if eventIs(event, "S_EVENT_HIT") then
    handleHitEvent(event)
    return
  end

  if eventIs(event, "S_EVENT_KILL") then
    handleKillEvent(event)
    return
  end

  if eventIs(event, "S_EVENT_EJECTION") then
    handlePlayerTerminalEvent(event, "player.ejected", "ejected")
    return
  end

  if eventIs(event, "S_EVENT_CRASH") then
    handlePlayerTerminalEvent(event, "player.crashed", "crashed")
    return
  end

  if eventIs(event, "S_EVENT_DEAD") then
    handlePlayerTerminalEvent(event, "player.dead", "dead")
    return
  end

  if eventIs(event, "S_EVENT_PILOT_DEAD") then
    handlePlayerTerminalEvent(event, "player.pilot_dead", "pilotDead")
    return
  end
end

function GMS.start()
  if GMS.started then
    return
  end

  GMS.started = true

  if not world or not world.addEventHandler then
    GMS.warn("DCS world.addEventHandler is not available. GMS did not start.")
    return
  end

  world.addEventHandler(GMS)
  schedulePoll()
  GMS.emit("gms.started", { version = GMS.version })
  emitMissionStarted({ source = "gms.start" })
  GMS.log("Started version " .. GMS.version)
end

if GMS.config.autoStart ~= false then
  GMS.start()
end

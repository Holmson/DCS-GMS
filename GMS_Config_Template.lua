-- GMS_Config_Template.lua
-- Copy this file per mission, rename it, edit it, and load it before
-- GeneralMissionScript.lua with a Mission Editor DO SCRIPT FILE action.

GMS_CONFIG = {
  -- Debug is helpful while testing a mission. Turn debugToScreen off for the
  -- final release if the messages become distracting.
  debug = true,
  debugToScreen = true,
  debugScreenSeconds = 5,

  -- Optional player filters. Leave both tables empty to auto-detect player
  -- units through DCS player events/getPlayerName().
  playerUnitNames = {
    -- ["Player Hornet"] = true,
  },

  playerGroupNames = {
    -- ["Springfield 1"] = true,
  },

  -- Event name -> DCS user flag mapping.
  --
  -- The text in square brackets is the GMS event name.
  -- The flag value is the DCS Mission Editor flag name or number.
  --
  -- Common modes:
  -- latch   : set once and keep true
  -- state   : true while event.state is true, false when it clears
  -- counter : increase the flag value every time the event fires
  -- pulse   : set briefly, then reset to 0
  flagRules = {
    ["mission.started"] = { flag = "mission_started", mode = "latch" },
    ["player.enter_unit"] = { flag = "player_entered", mode = "latch" },
    ["player.runway_takeoff"] = { flag = "airborne", mode = "latch" },
    ["player.land"] = { flag = "landed", mode = "latch" },
    ["player.dead"] = { flag = "player_dead", mode = "latch" },

    ["player.weapon.fired"] = { flag = "weapons_fired", mode = "counter" },
    ["player.weapon.hit"] = { flag = "weapon_hits", mode = "counter" },
    ["player.weapon.kill"] = { flag = "weapon_kills", mode = "counter" },

    ["player.fuel.joker"] = { flag = "joker_fuel", mode = "latch" },
    ["player.fuel.bingo"] = { flag = "bingo_fuel", mode = "latch" },
    ["player.fuel.emergency"] = { flag = "emergency_fuel", mode = "latch" },

    ["player.zone.target.enter"] = { flag = "target_entered", mode = "latch" },
    ["player.zone.nfz.violation"] = { flag = "no_fly_violation", mode = "latch" },
  },

  -- DCS trigger zones to watch.
  --
  -- name: exact DCS Mission Editor trigger zone name
  -- id  : short GMS event name part, e.g. "target" creates
  --       player.zone.target.enter and player.zone.target.leave
  zones = {
    { name = "TARGET_ZONE", id = "target" },
    -- { name = "NO_FLY_ZONE", id = "nfz", violationOnEnter = true },
    -- { name = "SAFE_CORRIDOR", id = "corridor", violationOnLeave = true },
  },

  -- Polling rules for altitude/speed conditions in zones.
  zoneRules = {
    -- {
    --   id = "low_in_target",
    --   zone = "TARGET_ZONE",
    --   altitudeBelowMeters = 300,
    -- },
    -- {
    --   id = "too_fast_in_corridor",
    --   zone = "SAFE_CORRIDOR",
    --   speedAboveKph = 800,
    -- },
  },

  fuel = {
    enabled = true,
    thresholds = {
      joker = 0.45,
      bingo = 0.30,
      emergency = 0.12,
    },
  },

  -- Simple polling watches for objectives.
  watches = {
    unitsDestroyed = {
      -- { name = "Target-1", event = "objective.target_1.destroyed" },
    },
    groupsDestroyed = {
      -- { name = "Armor Group", event = "objective.armor.destroyed" },
    },
    staticsDestroyed = {
      -- { name = "Ammo Depot", event = "objective.ammo_depot.destroyed" },
    },
  },

  -- Optional weapon classification overrides for mission-specific correction.
  weaponClassOverrides = {
    -- ["AIM_120C"] = {
    --   role = "AA",
    --   call = "FOX3",
    --   guided = true,
    --   buckets = { aa = true, guided = true },
    -- },
  },
}

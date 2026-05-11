-- GMS_Config_Template.lua
-- Copy this file per mission, rename it, edit it, and load it before
-- GeneralMissionScript.lua with a Mission Editor DO SCRIPT FILE action.
-- If you use a separate voice-over table, load that voice file before this
-- config file. The filename can be mission-specific, but the table should be
-- named GMS_VOICE_OVERS unless you change voice.linesTable below.
-- Optional voice sequence files should define GMS_VOICE_SEQUENCES.

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
    -- Mission / player slot
    ["mission.started"] = { flag = "mission_started", mode = "latch" },
    ["player.enter_unit"] = { flag = "player_entered", mode = "latch" },
    ["player.took_control"] = { flag = "player_took_control", mode = "latch" },

    -- Airframe-specific events use the normalized DCS type name.
    -- Replace f_a_18c with your detected type, e.g. f_16c_50 or a_10c_2.
    ["player.airframe.a_10c_2"] = { flag = "hawg_c2_active", mode = "latch" },
    ["player.airframe.a_10c"] = { flag = "hawg_ff_active", mode = "latch" },
    ["player.airframe.a_10a"] = { flag = "hawg_fc_active", mode = "latch" },

    -- Engine / takeoff / landing
    ["player.engine.startup"] = { flag = "engine_started", mode = "latch" },
    ["player.engine.shutdown"] = { flag = "engine_shutdown", mode = "latch" },
    ["player.runway_takeoff"] = { flag = "airborne", mode = "latch" },
    ["player.takeoff"] = { flag = "takeoff_confirmed", mode = "latch" },
    ["player.land"] = { flag = "landed", mode = "latch" },

    -- Landing-place events use the normalized DCS airbase/carrier/FARP name.
    -- Example: if debug shows player.land_at.batumi, map that exact event.
    -- ["player.land_at.batumi"] = { flag = "landed_batumi", mode = "latch" },

    -- Refueling / AAR
    -- These two rules use the same flag as a true/false state.
    ["player.refueling.start"] = { flag = "refueling_active", mode = "state" },
    ["player.refueling.stop"] = { flag = "refueling_active", mode = "state" },
    ["player.aar.fuel_received"] = { flag = "aar_fuel_received", mode = "latch" },

    -- General weapon events
    ["player.weapon.fired"] = { flag = "weapons_fired", mode = "counter" },
    ["player.weapon.gun_start"] = { flag = "gun_started", mode = "pulse", seconds = 2 },
    ["player.weapon.gun_end"] = { flag = "gun_ended", mode = "pulse", seconds = 2 },
    ["player.weapon.hit"] = { flag = "weapon_hits", mode = "counter" },
    ["player.weapon.kill"] = { flag = "weapon_kills", mode = "counter" },
    ["player.hit"] = { flag = "player_hit", mode = "counter" },
    ["player.weapon.friendly_fire"] = { flag = "friendly_fire", mode = "latch" },
    ["player.weapon.roe_violation"] = { flag = "roe_violation", mode = "latch" },

    -- Weapon classification events
    ["player.weapon.fired.fox1"] = { flag = "fox1_fired", mode = "counter" },
    ["player.weapon.fired.fox2"] = { flag = "fox2_fired", mode = "pulse" },
    ["player.weapon.fired.fox3"] = { flag = "fox3_fired", mode = "counter" },
    ["player.weapon.fired.rifle"] = { flag = "rifle_fired", mode = "pulse" },
    ["player.weapon.fired.magnum"] = { flag = "magnum_fired", mode = "pulse" },
    ["player.weapon.fired.bruiser"] = { flag = "bruiser_fired", mode = "counter" },
    ["player.weapon.fired.bombs"] = { flag = "bombs_fired", mode = "pulse" },
    ["player.weapon.dropped.bombs"] = { flag = "bombs_dropped", mode = "counter" },
    ["player.weapon.fired.rockets"] = { flag = "rockets_fired", mode = "pulse" },

    -- Winchester / ammunition
    ["player.winchester.aa"] = { flag = "winchester_aa", mode = "latch" },
    ["player.winchester.ag"] = { flag = "winchester_ag", mode = "latch" },
    -- Optional report prompt events. These fire after the player uses the F10
    -- report menu, not when the state is first detected.
    ["player.winchester.aa.reported"] = { flag = "winchester_aa_reported", mode = "latch" },
    ["player.winchester.ag.reported"] = { flag = "winchester_ag_reported", mode = "latch" },

    -- Fuel
    ["player.fuel.joker"] = { flag = "joker_fuel", mode = "latch" },
    ["player.fuel.bingo"] = { flag = "bingo_fuel", mode = "latch" },
    ["player.fuel.emergency"] = { flag = "emergency_fuel", mode = "latch" },
    ["player.fuel.bingo.reported"] = { flag = "bingo_fuel_reported", mode = "latch" },

    -- Damage / death
    ["player.ejected"] = { flag = "player_ejected", mode = "latch" },
    ["player.crashed"] = { flag = "player_crashed", mode = "latch" },
    ["player.dead"] = { flag = "player_dead", mode = "latch" },
    ["player.pilot_dead"] = { flag = "pilot_dead", mode = "latch" },

    -- Zone-specific events. Replace "target" / "nfz" / "corridor" with the
    -- id values configured below in zones.
    ["player.zone.target.enter"] = { flag = "target_entered", mode = "latch" },
    ["player.zone.target.leave"] = { flag = "target_left", mode = "latch" },
    ["player.zone.nfz.violation"] = { flag = "no_fly_violation", mode = "latch" },
    ["player.zone.corridor.leave"] = { flag = "corridor_left", mode = "latch" },
    ["player.zone.corridor.violation"] = { flag = "corridor_violation", mode = "latch" },

    -- Pattern examples for your own zone ids:
    -- ["player.zone.my_zone.enter"] = { flag = "my_zone_entered", mode = "latch" },
    -- ["player.zone.my_zone.leave"] = { flag = "my_zone_left", mode = "latch" },
    -- ["player.zone.my_zone.violation"] = { flag = "my_zone_violation", mode = "latch" },

    -- Objective watches. These event names come from the watches section below.
    ["objective.target_1.destroyed"] = { flag = "target_1_destroyed", mode = "latch" },
    ["objective.armor.destroyed"] = { flag = "armor_group_destroyed", mode = "latch" },
  },

  -- Optional voice-over module.
  --
  -- enabled = false keeps GMS voice features completely inactive.
  -- defaultMode = "sound" uses outSound + outText.
  -- defaultMode = "radio" uses radioTransmission + outText.
  -- A mission voice file can have any filename, but should define the
  -- GMS_VOICE_OVERS table.
  -- Optional sequence files should define GMS_VOICE_SEQUENCES. Keep long
  -- voice content there and only map GMS events to your voice IDs or sequence
  -- names here.
  voice = {
    enabled = false,
    defaultMode = "sound",
    subtitle = true,
    subtitleFormat = "[%s] %s",

    -- Radio mode needs sender zones from the Mission Editor.
    -- Frequencies are in Hz, so 251 MHz is 251000000.
    radio = {
      defaultZone = "RADIO_PLAYER",
      defaultFrequency = 251000000,
      defaultModulation = "AM",
      defaultPower = 100,
      fallbackToSound = true,
    },

    speakers = {
      -- Speaker names must match unitName/speaker values in GMS_VOICE_OVERS.
      -- Replace these examples with the callsigns used by your mission.
      YOU = {
        zone = "RADIO_PLAYER",
        frequency = 251000000,
        modulation = "AM",
        power = 50,
      },
      PLAYER_TOWER = {
        zone = "RADIO_PLAYER",
        frequency = 251000000,
        modulation = "AM",
        power = 50,
      },
      PLAYER_AWACS = {
        zone = "RADIO_PLAYER",
        frequency = 251000000,
        modulation = "AM",
        power = 50,
      },
      PLAYER_SPECIAL = {
        zone = "RADIO_PLAYER",
        frequency = 251000000,
        modulation = "AM",
        power = 50,
      },
      SEMBACH_TOWER = {
        zone = "RADIO_TOWER",
        frequency = 250000000,
        modulation = "AM",
        power = 100,
      },
      MAGIC = {
        zone = "RADIO_AWACS",
        frequency = 377800000,
        modulation = "AM",
        power = 100,
      },
      WINGMAN = {
        zone = "RADIO_WINGMAN",
        frequency = 251000000,
        modulation = "AM",
        power = 100,
      },
    },

    -- The table name lets GMS resolve the mission voice file at playback
    -- time. The direct lines assignment is convenient when the table was
    -- already loaded before this config.
    linesTable = "GMS_VOICE_OVERS",
    lines = GMS_VOICE_OVERS or {},

    -- Optional table for dialogue blocks. The sequence file can be loaded with
    -- any filename as long as it defines GMS_VOICE_SEQUENCES.
    sequencesTable = "GMS_VOICE_SEQUENCES",
    sequences = GMS_VOICE_SEQUENCES or {},

    eventMap = {
      -- Replace these IDs with IDs from your GMS_VOICE_OVERS table.
      ["player.runway_takeoff"] = { id = 1101, once = false },
      ["player.weapon.fired.fox1"] = { id = 1102, cooldown = 4 },
      ["player.weapon.fired.fox2"] = { id = 1103, cooldown = 4 },
      ["player.weapon.fired.fox3"] = { id = 1104, cooldown = 4 },
      ["player.weapon.fired.rifle"] = { id = 1105, cooldown = 4 },
      ["player.weapon.fired.magnum"] = { id = 1106, cooldown = 4 },
      ["player.weapon.fired.bruiser"] = { id = 1107, cooldown = 4 },
      ["player.weapon.fired.bomb"] = { id = 1108, cooldown = 4 },
      ["player.weapon.droped.bomb"] = { id = 1108, cooldown = 4 },
      ["player.weapon.fired.rockets"] = { id = 1109, cooldown = 4 },
      ["player.weapon.gun_start"] = { id = 1110, cooldown = 4 },
      ["player.ejected"] = { id = 1111, once = true },
      -- ["player.runway_takeoff"] = { sequence = "departure_wheels_up", once = true },
      --["player.weapon.fired.rifle"] = { id = 1002, cooldown = 15 },
      -- ["player.zone.target.enter"] = { id = 1003, once = true, delay = 2 },
    },
  },

  -- Optional F10 report prompts.
  --
  -- Detection events stay separate from report events. For example:
  -- player.fuel.bingo          -> GMS detected bingo fuel
  -- player.fuel.bingo.reported -> player used the F10 report menu
  reportPrompts = {
    enabled = false,
    menuRoot = "GMS Reports",
    alertSound = "AUDIO/alert.ogg",
    messageSeconds = 15,
    removeOnReport = true,
    emitAfterVoice = true,

    prompts = {
      bingo_fuel = {
        triggerEvent = "player.fuel.bingo",
        resetEvent = "player.fuel.bingo_reset",
        reportEvent = "player.fuel.bingo.reported",
        menuText = "BINGO FUEL",
        message = "You have reached bingo fuel - use F10 radio menu to report.",
        sequence = "report_bingo_fuel",
        once = true,
      },

      winchester_ag = {
        triggerEvent = "player.winchester.ag",
        resetEvent = "player.winchester.ag_reset",
        reportEvent = "player.winchester.ag.reported",
        menuText = "WINCHESTER A/G",
        message = "You are winchester - use F10 radio menu to report.",
        sequence = "report_winchester_ag",
        once = true,
      },

      winchester_aa = {
        triggerEvent = "player.winchester.aa",
        resetEvent = "player.winchester.aa_reset",
        reportEvent = "player.winchester.aa.reported",
        menuText = "WINCHESTER A/A",
        message = "You are winchester - use F10 radio menu to report your weapons state.",
        sequence = "report_winchester_aa",
        once = true,
      },
    },
  },

  -- DCS trigger zones to watch.
  --
  -- name: exact DCS Mission Editor trigger zone name
  -- id  : short GMS event name part, e.g. "target" creates
  --       player.zone.target.enter and player.zone.target.leave
  zones = {
    { name = "TARGET_ZONE", id = "target" },
    { name = "NO_FLY_ZONE", id = "nfz", violationOnEnter = true },
    { name = "SAFE_CORRIDOR", id = "corridor", violationOnLeave = true },
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
      -- name: exact DCS unit name
      -- event: GMS event emitted when that unit is destroyed
      { name = "Target-1", event = "objective.target_1.destroyed" },
    },
    groupsDestroyed = {
      -- name: exact DCS group name
      -- event: GMS event emitted when all units in that group are destroyed
      { name = "Armor Group", event = "objective.armor.destroyed" },
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

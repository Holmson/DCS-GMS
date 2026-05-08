# DCS General Mission Script

Reusable Lua helper for DCS single-player missions. It uses only the native DCS
mission scripting API: no MIST, no MOOSE.

Current script version: `0.2.0`.

## Files

- `GeneralMissionScript.lua`: the reusable library. Load it in every mission,
  but normally do not edit it for mission-specific logic.
- `GMS_Config_Template.lua`: copy this file per mission, rename it, and edit the
  copy. This is where your Mission Editor flags, zones, fuel thresholds, and
  watches go.
- `Mission 08 - Illumination.lua`: example mission voice-over table. It stores
  voice IDs, audio file paths, subtitles, speakers, and durations for one
  mission.
- `CHANGELOG.md`: short version history.

## Load Order

1. Copy `GMS_Config_Template.lua` for your mission, for example
   `MyMission_GMS_Config.lua`.
2. Edit your copied config file.
3. If the mission uses a separate voice-over table, add a `DO SCRIPT FILE`
   action for that file first. The filename can be different for every mission.
4. In the Mission Editor, add a `DO SCRIPT FILE` action that loads your config
   file.
5. Add a final `DO SCRIPT FILE` action that loads `GeneralMissionScript.lua`.

`GMS_CONFIG` must be loaded before `GeneralMissionScript.lua`, because the main
script reads the config while it is loading. If your config references an
external voice-over table directly, load that voice file before the config.
The default convention is that every mission-specific voice file defines the
same global table name: `GMS_VOICE_OVERS`.

Recommended Mission Editor load order:

```text
MISSION START
  DO SCRIPT FILE -> MyMission_VoiceOvers.lua  (only if used)
  DO SCRIPT FILE -> MyMission_GMS_Config.lua
  DO SCRIPT FILE -> GeneralMissionScript.lua
```

Do not edit `GeneralMissionScript.lua` for mission-specific flags or zones.
Keep those changes in your copied config file.

## Minimal Config

This is the smallest useful mission-specific config. Put this content into your
copied config file, for example `MyMission_GMS_Config.lua`.

The repository also contains `GMS_Config_Template.lua`, which already includes
this structure plus more commented examples.

You do not need to understand all Lua details to start. In this block you mostly
edit three things:

- the event name in square brackets, for example `["player.runway_takeoff"]`
- the flag name or number after `flag =`
- the behavior after `mode =`

```lua
GMS_CONFIG = {
  debug = true,
  debugToScreen = true,
  debugScreenSeconds = 5,

  flagRules = {
    -- Edit the flag value to the DCS user flag number or name you want.
    ["mission.started"] = { flag = "mission_started", mode = "latch" },
    ["player.enter_unit"] = { flag = "player_entered", mode = "latch" },
    ["player.runway_takeoff"] = { flag = "airborne", mode = "latch" },
    ["player.land"] = { flag = "landed", mode = "latch" },
    ["player.dead"] = { flag = "player_dead", mode = "latch" },
    ["player.weapon.fired"] = { flag = "weapons_fired", mode = "counter" },
    ["player.weapon.hit"] = { flag = "weapon_hits", mode = "counter" },
    ["player.weapon.kill"] = { flag = "weapon_kills", mode = "counter" },
    ["player.fuel.bingo"] = { flag = "bingo_fuel", mode = "latch" },
  },

  zones = {
    { name = "TARGET_ZONE", id = "target" },
  },
}
```

Lua syntax notes:

- text values use quotes, for example `"airborne"`
- every entry inside `flagRules` usually ends with a comma
- lines that start with `--` are comments and are ignored by DCS
- `{ ... }` creates a table; in this project it is used for config blocks

If you only want to add a new Mission Editor flag, add one line inside
`flagRules` in your config file:

```lua
["gms.event.name"] = { flag = "your_flag_name", mode = "latch" },
```

Then replace `gms.event.name`, `your_flag_name`, and `latch` with the event,
flag, and mode you need.

## Debug Output

- `debug = true` enables GMS event logging via `env.info` in `dcs.log`.
- `debugToScreen = true` also shows those messages in-game via
  `trigger.action.outText`.
- `debugScreenSeconds = 5` controls how long each on-screen debug message stays
  visible.

## Flag Rules

`flagRules` live in your mission config file. They define which GMS event should
write to which DCS user flag.

```lua
flagRules = {
  ["player.runway_takeoff"] = { flag = "airborne", mode = "latch" },
  ["player.weapon.fired"] = { flag = "weapons_fired", mode = "counter" },
  ["player.alive"] = { flag = "player_alive", mode = "state" },
}
```

The left side, for example `player.runway_takeoff`, is the GMS event name. The
`flag = ...` value is the DCS user flag you use in the Mission Editor.

You can use numeric flags:

```lua
["player.runway_takeoff"] = { flag = 20, mode = "latch" }
```

Or named flags:

```lua
["player.runway_takeoff"] = { flag = "airborne", mode = "latch" }
```

Named flags are easier to read in mission configs. Numeric flags are still fine
if you prefer the classic Mission Editor style.

## Flag Modes

- `latch`: set flag to `1`, or to `value` if provided. Good for one-time events
  like takeoff, landing, objective complete, or player dead.
- `state`: set flag to `1` when `event.state == true`, otherwise `0`. Good for
  true/false states like alive, airborne, on ground, in zone, or rule active.
- `counter`: increment the current flag value. Good for repeated events like
  weapons fired, hits, kills, zone entries, or engine starts.
- `pulse`: set flag briefly, then reset it to `0`. Good for short trigger
  windows when you only want one Mission Editor action to react.
- `clear`: set flag to `0`. Useful for custom reset events.
- `value`: set flag to `event.value` or configured `value`.

## Mission Editor Usage

GMS events are internal event names. The Mission Editor only sees DCS user
flags, so every event you want to use in a trigger needs a `flagRules` entry in
your config file.

Example:

```lua
GMS_CONFIG = {
  flagRules = {
    ["player.runway_takeoff"] = { flag = "airborne", mode = "latch" },
    ["player.weapon.fired"] = { flag = "weapons_fired", mode = "counter" },
    ["player.alive"] = { flag = "player_alive", mode = "state" },
    ["player.zone.target.enter"] = { flag = "target_entered", mode = "pulse", seconds = 3 },
  },
}
```

Mission Editor examples:

- `latch`: use `FLAG IS TRUE (airborne)` after the player has taken off once.
- `counter`: use `FLAG MORE THAN (weapons_fired, 2)` after three weapon
  releases.
- `state`: use `FLAG IS TRUE (player_alive)` while the state is true, and
  `FLAG IS FALSE (player_alive)` when it clears.
- `pulse`: use `FLAG IS TRUE (target_entered)` for a short trigger window,
  then it resets.

## Zones Config

Zone names are created in the DCS Mission Editor, not in this script. Add a
trigger zone in the Mission Editor and give it a clear name, for example
`TARGET_ZONE`, `FENCE_IN_ZONE`, or `NO_FLY_ZONE`.

Then reference that exact Mission Editor zone name in `GMS_CONFIG.zones`:

```lua
GMS_CONFIG = {
  zones = {
    { name = "TARGET_ZONE", id = "target" },
    { name = "NO_FLY_ZONE", id = "nfz", violationOnEnter = true },
    { name = "SAFE_CORRIDOR", id = "corridor", violationOnLeave = true },
  },

  flagRules = {
    ["player.zone.enter"] = { flag = "any_zone_entered", mode = "counter" },
    ["player.zone.target.enter"] = { flag = "target_entered", mode = "latch" },
    ["player.zone.nfz.violation"] = {
      flag = "no_fly_violation",
      mode = "latch",
    },
    ["player.zone.corridor.violation"] = {
      flag = "corridor_left",
      mode = "latch",
    },
  },
}
```

`name` is the real DCS trigger zone name. It must match the Mission Editor zone
exactly.

`id` is the short GMS name used in event names. It should be simple lowercase
text without spaces, for example `target`, `ip`, `fence_in`, or `nfz`.

Generic zone events fire for any configured zone:

- `player.zone.enter`
- `player.zone.leave`
- `player.zone.violation`

Specific zone events include the zone `id`:

- `player.zone.target.enter`
- `player.zone.target.leave`
- `player.zone.nfz.violation`

Use generic events when you only care that the player entered or left any
configured zone. Use specific events when a Mission Editor trigger should react
to one exact zone.

## Zone Rules Config

`zoneRules` are polling checks for conditions inside zones. They are useful for
rules like "player is below 300 meters inside target zone" or "player is faster
than 800 km/h inside safe corridor".

Example:

```lua
GMS_CONFIG = {
  zoneRules = {
    {
      id = "low_in_target",
      zone = "TARGET_ZONE",
      altitudeBelowMeters = 300,
    },
    {
      id = "too_fast_in_corridor",
      zone = "SAFE_CORRIDOR",
      speedAboveKph = 800,
    },
  },

  flagRules = {
    ["player.zone_rule.low_in_target"] = {
      flag = "low_in_target",
      mode = "state",
    },
    ["player.zone_rule.low_in_target.enter"] = {
      flag = "low_warning",
      mode = "pulse",
      seconds = 5,
    },
    ["player.zone_rule.too_fast_in_corridor"] = {
      flag = "too_fast",
      mode = "state",
    },
  },
}
```

`id` is the rule name used by GMS to build event names. For example:

- `id = "low_in_target"` creates `player.zone_rule.low_in_target`
- it also creates `player.zone_rule.low_in_target.enter`
- and `player.zone_rule.low_in_target.clear`

The main rule event, for example `player.zone_rule.low_in_target`, is best used
with `mode = "state"`, because it becomes true when the rule matches and false
when the rule clears.

The `.enter` event fires once when the rule first becomes true. The `.clear`
event fires once when it becomes false again.

You can also set a custom event name:

```lua
{
  id = "low_in_target",
  zone = "TARGET_ZONE",
  altitudeBelowMeters = 300,
  event = "mission.low_altitude_warning",
}
```

Then use `mission.low_altitude_warning`,
`mission.low_altitude_warning.enter`, and `mission.low_altitude_warning.clear`
in `flagRules`.

## Voice-Over Module

Voice-over support is optional. Leave `voice.enabled = false` if a mission does
not need it.

The voice module can be used in two ways:

- manually from the Mission Editor with `GMS.voice.play(815)` or
  `triggerVoiceOver(815)`
- automatically from GMS events with `voice.eventMap`

Recommended setup with a separate voice-over table:

```lua
-- MyMission_VoiceOvers.lua
GMS_VOICE_OVERS = {
  [815] = {
    oggFile = "AUDIO/715.ogg",
    subtitle = "Hawg Two Two, wheels up.",
    unitName = "YOU",
    duration = 3.0,
  },
}
```

The mission config then references that table instead of copying all voice
lines into `GMS_CONFIG`:

```lua
GMS_CONFIG = {
  voice = {
    enabled = true,
    defaultMode = "sound",

    linesTable = "GMS_VOICE_OVERS",
    lines = GMS_VOICE_OVERS or {},

    eventMap = {
      ["player.runway_takeoff"] = { id = 815, once = true },
    },
  },
}
```

`linesTable` is the global table name from the voice file. `lines` is the direct
table reference when the voice file was already loaded before the config. Using
the same table name in every mission means only the `DO SCRIPT FILE` action has
to point to the mission-specific voice file.

With `defaultMode = "sound"`, GMS uses:

- `trigger.action.outSound(file)`
- `trigger.action.outText(subtitle, duration)`

Radio-based setup:

```lua
GMS_CONFIG = {
  voice = {
    enabled = true,
    defaultMode = "radio",
    linesTable = "GMS_VOICE_OVERS",
    lines = GMS_VOICE_OVERS or {},

    speakers = {
      MAGIC = {
        zone = "RADIO_MAGIC",
        frequency = 251000000,
        modulation = "AM",
        power = 100,
      },
    },

    eventMap = {
      ["player.zone.target.enter"] = { id = 820, once = true },
    },
  },
}
```

With `defaultMode = "radio"`, GMS uses `trigger.action.radioTransmission`.
The sender position comes from the Mission Editor trigger zone configured for
the speaker, for example `RADIO_MAGIC`. Subtitles are still shown through
`outText` because that is robust and independent from radio reception.

Speaker names must match the `unitName`/`speaker` values in the voice table.
For Mission 08 examples, that means names like `YOU`, `MUDSHARK`, `MAGIC`,
`SEMBACH TOWER`, or `SPRENDLINGEN`.

Radio notes:

- `frequency` is in Hz, so 251 MHz is `251000000`.
- `modulation` can be `"AM"` or `"FM"`.
- `fallbackToSound = true` in `voice.radio` lets GMS fall back to normal
  `outSound` if the radio zone is missing.

Event mapping options:

- `once = true`: play only once per mission.
- `cooldown = 15`: do not play again until 15 seconds have passed.
- `delay = 2`: wait 2 seconds before playing.
- `mode = "radio"` or `mode = "sound"`: override the default mode for this
  mapping.

## Event Reference

Recommended flag mode is only a starting point. You can map any event to any
mode if your mission logic needs it.

### System / Mission

- `gms.started`: GMS loaded and event handler registered. Suggested mode:
  `latch`. Mission Editor: `FLAG IS TRUE`.
- `mission.started`: mission/GMS start signal. Suggested mode: `latch`.
  Mission Editor: `FLAG IS TRUE`.
- `mission.ended`: DCS mission end event. Suggested mode: `latch`.
  Mission Editor: `FLAG IS TRUE`.

### Player / Slot / Airframe

- `player.enter_unit`: player entered a unit. Suggested mode: `latch`.
- `player.leave_unit`: player left a tracked unit. Suggested mode: `latch`
  or `pulse`.
- `player.leave_unit.unknown`: player left event without a known tracked unit.
  Suggested mode: `pulse`.
- `player.took_control`: player took direct control. Suggested mode: `latch`.
- `player.airframe_detected`: player aircraft type was detected. Suggested
  mode: `latch`.
- `player.airframe.<type_name>`: type-specific airframe event, for example
  `player.airframe.f_a_18c`. Suggested mode: `latch`.
- `player.alive`: true when player is alive, false after dead/crash/pilot dead.
  Suggested mode: `state`.

### Engine / Start / Flight / Landing

- `player.engine.startup`: engine startup event. Suggested mode: `latch` or
  `counter`.
- `player.engine.shutdown`: engine shutdown event. Suggested mode: `latch` or
  `counter`.
- `player.runway_takeoff`: precise airborne moment from runway takeoff.
  Suggested mode: `latch`.
- `player.takeoff`: DCS takeoff confirmation event. Suggested mode: `latch`.
- `player.runway_touch`: runway touchdown. Suggested mode: `pulse` or
  `counter`.
- `player.land`: final landing event. Suggested mode: `latch` or `counter`.
- `player.land_at.<place_name>`: landing at a specific base/carrier/FARP name.
  Suggested mode: `latch`.
- `player.airborne`: emitted when player becomes airborne. Suggested mode:
  `latch` or `pulse`.
- `player.on_ground`: emitted when player becomes on-ground. Suggested mode:
  `latch` or `pulse`.
- `player.airborne_state`: polling state for airborne true/false. Suggested
  mode: `state`.
- `player.on_ground_state`: polling state for on-ground true/false. Suggested
  mode: `state`.

### Refueling / AAR

- `player.refueling.start`: AAR/contact/refueling started. Suggested mode:
  `state` or `latch`.
- `player.refueling.stop`: AAR/refueling stopped. Suggested mode: `pulse` or
  `latch`.
- `player.aar.fuel_received`: refueling stopped with positive fuel delta.
  Suggested mode: `latch` or `counter`.

### Weapons

- `player.weapon.fired`: weapon fired. Suggested mode: `counter`.
- `player.weapon.dropped`: weapon dropped/released. Suggested mode: `counter`.
- `player.weapon.gun_start`: gun/autocannon firing started. Suggested mode:
  `pulse` or `latch`.
- `player.weapon.gun_end`: gun/autocannon firing ended. Suggested mode:
  `pulse`.
- `player.weapon.hit`: player hit something. Suggested mode: `counter`.
- `player.weapon.kill`: player killed/destroyed something. Suggested mode:
  `counter`.
- `player.hit`: player was hit. Suggested mode: `latch` or `counter`.
- `player.weapon.friendly_fire`: player hit/killed same coalition. Suggested
  mode: `latch` or `counter`.
- `player.weapon.roe_violation`: weapon release outside configured allowed
  zone. Suggested mode: `latch` or `counter`.

### Weapon Classification

These are emitted for `player.weapon.fired.*` and, where applicable,
`player.weapon.dropped.*`.

- `player.weapon.fired.fox1`: semi-active radar A/A missile. Suggested mode:
  `counter`.
- `player.weapon.fired.fox2`: IR A/A missile. Suggested mode: `counter`.
- `player.weapon.fired.fox3`: active radar A/A missile. Suggested mode:
  `counter`.
- `player.weapon.fired.rifle`: A/G missile classification. Suggested mode:
  `counter`.
- `player.weapon.fired.magnum`: anti-radiation missile classification.
  Suggested mode: `counter`.
- `player.weapon.fired.bruiser`: anti-ship missile classification. Suggested
  mode: `counter`.
- `player.weapon.fired.guided`: guided weapon. Suggested mode: `counter`.
- `player.weapon.fired.aa`: air-to-air weapon. Suggested mode: `counter`.
- `player.weapon.fired.ag`: air-to-ground weapon. Suggested mode: `counter`.
- `player.weapon.fired.bombs`: bomb class. Suggested mode: `counter`.
- `player.weapon.dropped.guided`: guided dropped weapon. Suggested mode:
  `counter`.
- `player.weapon.dropped.ag`: A/G dropped weapon. Suggested mode: `counter`.
- `player.weapon.dropped.bombs`: dropped bomb. Suggested mode: `counter`.

### Winchester / Ammunition

- `player.winchester.all`: no relevant weapons left. Suggested mode: `latch`.
- `player.winchester.aa`: no A/A weapons left. Suggested mode: `latch`.
- `player.winchester.ag`: no A/G weapons left. Suggested mode: `latch`.
- `player.winchester.guided`: no guided weapons left. Suggested mode: `latch`.
- `player.winchester.bombs`: no bombs left. Suggested mode: `latch`.
- `player.winchester.all_reset`: relevant weapons available again. Suggested
  mode: `pulse`.
- `player.winchester.aa_reset`: A/A weapons available again. Suggested mode:
  `pulse`.
- `player.winchester.ag_reset`: A/G weapons available again. Suggested mode:
  `pulse`.
- `player.winchester.guided_reset`: guided weapons available again. Suggested
  mode: `pulse`.
- `player.winchester.bombs_reset`: bombs available again. Suggested mode:
  `pulse`.

### Fuel

- `player.fuel.joker`: fuel dropped below configured joker threshold.
  Suggested mode: `latch`.
- `player.fuel.bingo`: fuel dropped below configured bingo threshold.
  Suggested mode: `latch`.
- `player.fuel.emergency`: fuel dropped below configured emergency threshold.
  Suggested mode: `latch`.
- `player.fuel.joker_reset`: fuel rose above joker threshold plus reset margin.
  Suggested mode: `pulse`.
- `player.fuel.bingo_reset`: fuel rose above bingo threshold plus reset margin.
  Suggested mode: `pulse`.
- `player.fuel.emergency_reset`: fuel rose above emergency threshold plus reset
  margin. Suggested mode: `pulse`.
- `player.fuel.increased`: fuel increased, for example through AAR. Suggested
  mode: `counter` or `pulse`.

### Damage / Death

- `player.ejected`: player ejected. Suggested mode: `latch`.
- `player.crashed`: player crashed. Suggested mode: `latch`.
- `player.dead`: player unit dead. Suggested mode: `latch`.
- `player.pilot_dead`: pilot dead event. Suggested mode: `latch`.
- `player.alive`: use `state` if you want one flag to represent alive/dead.

### Zones

Zones are configured in `GMS_CONFIG.zones`. The `name` is the DCS Mission Editor
trigger zone name. The `id` is the shorter GMS name used in event names.

Generic zone events do not include a zone id and fire for every configured zone.
Specific zone events include the zone id and only fire for that one zone.

- `player.zone.enter`: player entered any configured zone. Suggested mode:
  `counter` or `pulse`.
- `player.zone.leave`: player left any configured zone. Suggested mode:
  `counter` or `pulse`.
- `player.zone.<zone_id>.enter`: player entered a specific configured zone.
  Suggested mode: `latch` or `pulse`.
- `player.zone.<zone_id>.leave`: player left a specific configured zone.
  Suggested mode: `latch` or `pulse`.
- `player.zone.violation`: generic zone violation. Suggested mode: `latch` or
  `counter`.
- `player.zone.<zone_id>.violation`: zone-specific violation. Suggested mode:
  `latch` or `counter`.

### Zone Rules

Zone rules are polling checks for altitude/speed constraints in zones.
The `<rule_id>` part comes from the `id` value in `GMS_CONFIG.zoneRules`.
For example, `id = "low_in_target"` creates
`player.zone_rule.low_in_target`.

- `player.zone_rule.<rule_id>`: rule changed true/false. Suggested mode:
  `state`.
- `player.zone_rule.<rule_id>.enter`: rule became true. Suggested mode:
  `latch` or `pulse`.
- `player.zone_rule.<rule_id>.clear`: rule became false. Suggested mode:
  `pulse` or `clear`.
- Custom rule event names are possible with `event = "..."` in `zoneRules`.

### Objectives / Watches

- `objective.<target_name>.destroyed`: configured unit/group/static object is
  destroyed. Suggested mode: `latch`.
- Custom objective event names are possible with `event = "..."` in the watch
  config.

## Notes

- `S_EVENT_RUNWAY_TAKEOFF` is treated as the precise airborne moment.
- `S_EVENT_LAND` is treated as the final landing event. `player.land_at.*`
  is emitted only on this event, not on runway touch.
- Fuel, zones, zone rules, winchester, and objective watches are polling-based.
- Weapon classification uses broad heuristics plus `weaponClassOverrides` for
  mission-specific correction.

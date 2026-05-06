# DCS General Mission Script

Reusable Lua helper for DCS single-player missions. It uses only the native DCS
mission scripting API: no MIST, no MOOSE.

## Load Order

1. Optional: add a Mission Editor `DO SCRIPT` action that defines `GMS_CONFIG`.
2. Add a `DO SCRIPT FILE` action that loads `GeneralMissionScript.lua`.

## Minimal Config

```lua
GMS_CONFIG = {
  debug = true,

  flagRules = {
    ["mission.started"] = { flag = 1, mode = "latch" },
    ["player.enter_unit"] = { flag = 10, mode = "latch" },
    ["player.runway_takeoff"] = { flag = 20, mode = "latch" },
    ["player.land"] = { flag = 21, mode = "latch" },
    ["player.dead"] = { flag = 30, mode = "latch" },
    ["player.weapon.fired"] = { flag = 100, mode = "counter" },
    ["player.weapon.hit"] = { flag = 101, mode = "counter" },
    ["player.weapon.kill"] = { flag = 102, mode = "counter" },
    ["player.fuel.bingo"] = { flag = 200, mode = "latch" },
  },

  zones = {
    { name = "TARGET_ZONE", id = "target" },
  },
}
```

## Flag Modes

- `latch`: set flag to `1`, or to `value` if provided.
- `state`: set flag to `1` when `event.state == true`, otherwise `0`.
- `counter`: increment the current flag value.
- `pulse`: set flag briefly, then reset it to `0`.
- `clear`: set flag to `0`.
- `value`: set flag to `event.value` or configured `value`.

## Core Event Names

- `gms.started`
- `mission.started`
- `mission.ended`
- `player.enter_unit`
- `player.leave_unit`
- `player.took_control`
- `player.airframe_detected`
- `player.airframe.<type_name>`
- `player.alive`
- `player.engine.startup`
- `player.engine.shutdown`
- `player.runway_takeoff`
- `player.takeoff`
- `player.runway_touch`
- `player.land`
- `player.land_at.<place_name>`
- `player.airborne`
- `player.on_ground`
- `player.airborne_state`
- `player.on_ground_state`
- `player.ejected`
- `player.crashed`
- `player.dead`
- `player.pilot_dead`

## Weapon Event Names

- `player.weapon.fired`
- `player.weapon.dropped`
- `player.weapon.gun_start`
- `player.weapon.gun_end`
- `player.weapon.hit`
- `player.weapon.kill`
- `player.weapon.friendly_fire`
- `player.weapon.roe_violation`
- `player.weapon.fired.fox1`
- `player.weapon.fired.fox2`
- `player.weapon.fired.fox3`
- `player.weapon.fired.rifle`
- `player.weapon.fired.magnum`
- `player.weapon.fired.bruiser`
- `player.winchester.all`
- `player.winchester.aa`
- `player.winchester.ag`
- `player.winchester.guided`
- `player.winchester.bombs`

## Fuel, AAR, Zones, Objectives

- `player.fuel.joker`
- `player.fuel.bingo`
- `player.fuel.emergency`
- `player.fuel.increased`
- `player.refueling.start`
- `player.refueling.stop`
- `player.aar.fuel_received`
- `player.zone.enter`
- `player.zone.leave`
- `player.zone.<zone_id>.enter`
- `player.zone.<zone_id>.leave`
- `player.zone.violation`
- `player.zone.<zone_id>.violation`
- `player.zone_rule.<rule_id>`
- `objective.<target_name>.destroyed`

## Notes

- `S_EVENT_RUNWAY_TAKEOFF` is treated as the precise airborne moment.
- `S_EVENT_LAND` is treated as the final landing event. `player.land_at.*`
  is emitted only on this event, not on runway touch.
- Fuel, zones, zone rules, winchester, and objective watches are polling-based.
- Weapon classification uses broad heuristics plus `weaponClassOverrides` for
  mission-specific correction.

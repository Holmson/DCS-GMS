# Changelog

## 0.2.1 - 2026-05-08

- Added optional voice sequence support through `GMS_VOICE_SEQUENCES`.
- Added `GMS.voice.playSequence()` and `triggerVoiceSequence()`.
- Added sequence mappings in `voice.eventMap` with `sequence = "..."`.
- Renamed the voice-over table example to `GMS_VoiceOvers_Template.lua`.
- Added `GMS_VoiceSequences_Template.lua`.
- Bumped script version to `0.2.1`.

## 0.2.0 - 2026-05-08

- Added optional voice-over module with `sound` and `radio` playback modes.
- Added event-to-voice mapping through `voice.eventMap`.
- Added support for external mission voice tables through `GMS_VOICE_OVERS`.
- Added `GMS_VoiceOvers_Template.lua` as an example voice-over table.
- Documented voice-over load order, table references, speaker mapping, and radio
  sender zones.

## 0.1.0 - 2026-05-08

- Initial reusable General Mission Script for DCS single-player missions.
- Added player, weapon, fuel, zone, damage, and objective event tracking.
- Added configurable Mission Editor flag rules.
- Added debug logging and optional in-game debug output.

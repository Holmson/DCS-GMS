-- GMS_VoiceSequences_Template.lua
-- Copy this file per mission, rename it, edit it, and load it before the
-- mission GMS config file.
--
-- This file defines dialogue blocks. The individual voice lines stay in the
-- mission voice-over table, usually GMS_VOICE_OVERS.

GMS_VOICE_SEQUENCES = {
  -- Simple sequence: GMS waits for each voice line's duration before playing
  -- the next line. gap adds an extra pause before that line starts.
  magic_check_in = {
    { id = 719 },
    { id = 720, gap = 1.0 },
    { id = 721, gap = 1.0 },
  },

  -- Sequence-level options are optional. mode overrides the default voice mode
  -- for this whole sequence unless a line sets its own mode.
  magic_checkin = {
    mode = "radio",
    gap = 0.5,
    lines = {
      { id = 819 },
      { id = 820 },
      { id = 821 },
    },
  },
}

-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    debugMode    = 0,
    positionLeft = 100,
    positionTop  = 100,
    unlocked     = true,
    mode         = 2,
    spins        = 0,
    wins         = 0,
}

local characterDefaults = {
    spins = 0,
    wins  = 0,
}

function S2W:GetDefaults()
    return defaults
end

function S2W:GetCharacterDefaults()
    return characterDefaults
end

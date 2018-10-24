-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

S2W.Defaults = {}

local settings = {
    debugMode    = 0,
    positionLeft = 100,
    positionTop  = 100,
    unlocked     = true,
    mode         = 2,
    spins        = 0,
    wins         = 0,
}

local characterSettings = {
    spins = 0,
    wins  = 0,
}

function S2W.Defaults:Get()
    return settings
end

function S2W.Defaults:GetCharacter()
    return charactersettings
end

-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Main.lua
-- -----------------------------------------------------------------------------

local EM           = EVENT_MANAGER
local SC           = SLASH_COMMANDS

S2W                = {}
S2W.name           = "Spin2Win"
S2W.version        = "1.3.0"
S2W.dbVersion      = 1
S2W.slash          = "/s2w"
S2W.prefix         = "[Spin2Win] "
S2W.enabled        = false
S2W.HUDHidden      = false
S2W.ForceShow      = false
S2W.isDead         = false

-- Mode Globals
S2W_MODE_SESSION   = 1
S2W_MODE_CHARACTER = 2
S2W_MODE_ACCOUNT   = 3

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
S2W.debugMode      = 0
-- -----------------------------------------------------------------------------

function S2W:Trace(debugLevel, ...)
    if debugLevel <= S2W.debugMode then
        local message = zo_strformat(...)
        d(S2W.prefix .. message)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

local function S2W_Initialize(_, addonName)
    if addonName ~= S2W.name then return end

    S2W:Trace(1, "Spin2Win Loaded")
    EM:UnregisterForEvent(S2W.name, EVENT_ADD_ON_LOADED)

    S2W.saved = ZO_SavedVars:NewAccountWide("Spin2WinVariables", S2W.dbVersion, nil, S2W.Defaults:Get())
    S2W.savedCharacter = ZO_SavedVars:New("Spin2WinVariables", S2W.dbVersion, nil, S2W.Defaults:GetCharacter())

    -- Use saved debugMode value if the above value has not been changed
    if S2W.debugMode == 0 then
        S2W.debugMode = S2W.saved.debugMode
        S2W:Trace(1, "Setting debug value to saved: <<1>>", S2W.saved.debugMode)
    end

    SC[S2W.slash] = S2W.UI.SlashCommand
    SC['/s2wreport'] = S2W.UI.Report

    -- Update initial dead state
    S2W.isDead = IsUnitDead("player")

    S2W.Tracking.RegisterEvents()
    S2W.Settings:Init()
    S2W.Tracking.CheckSpinSlotted()
    S2W.UI.ToggleHUD()

    S2W:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(S2W.name, EVENT_ADD_ON_LOADED, S2W_Initialize)

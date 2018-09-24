-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Main.lua
-- -----------------------------------------------------------------------------

S2W             = {}
S2W.name        = "Spin2Win"
S2W.version     = "1.1.0"
S2W.dbVersion   = 1
S2W.slash       = "/s2w"
S2W.prefix      = "[S2W] "
S2W.enabled     = false
S2W.HUDHidden   = false
S2W.ForceShow   = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
S2W.debugMode = 0
-- -----------------------------------------------------------------------------

function S2W:Trace(debugLevel, ...)
    if debugLevel <= S2W.debugMode then
        d(S2W.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function S2W.Initialize(event, addonName)
    if addonName ~= S2W.name then return end

    S2W:Trace(1, "Spin2Win Loaded")
    EVENT_MANAGER:UnregisterForEvent(S2W.name, EVENT_ADD_ON_LOADED)

    S2W.saved = ZO_SavedVars:NewAccountWide("Spin2WinVariables", S2W.dbVersion, nil, S2W:GetDefaults())
    S2W.savedCharacter = ZO_SavedVars:New("Spin2WinVariables", S2W.dbVersion, nil, S2W:GetCharacterDefaults())

    -- Use saved debugMode value if the above value has not been changed
    if S2W.debugMode == 0 then
        S2W.debugMode = S2W.saved.debugMode
        S2W:Trace(1, "Setting debug value to saved: " .. S2W.saved.debugMode)
    end

    SLASH_COMMANDS[S2W.slash] = S2W.SlashCommand

    S2W.Tracking.RegisterEvents()
    S2W.UI.Draw()
    S2W.UI.ToggleHUD()

    S2W.UI.Update(false)
    S2W:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ADD_ON_LOADED, function(...) S2W.Initialize(...) end)


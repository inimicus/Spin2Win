-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Sep 24, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Spin2Win",
    displayName = "Spin2Win",
    author      = "g4rr3t",
    version     = S2W.version,
    registerForRefresh  = true,
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "Data",
        width = "full",
    },
    [2] = {
        type = "button",
        name = "Reset Session",
        func = function() end,
        tooltip = "Reset session statistics (since the last login or reload UI).", -- string id or function returning a string (optional)
        width = "half",
    },
    [3] = {
        type = "button",
        name = "Reset Lifetime",
        func = function() end,
        tooltip = "Reset character lifetime statistics to zero.",
        width = "half",
    },
    [4] = {
        type = "button",
        name = "Reset Account",
        func = function() end,
        tooltip = "Reset account lifetime data to zero. Does not affect per-character data.", -- string id or function returning a string (optional)
        warning = "Does not reset data for any character",
        width = "half",
    },
    [5] = {
        type = "header",
        name = "Counter",
        width = "full",
    },
    [6] = {
        type = "dropdown",
        name = "Statistics Display",
        choices = {"Session", "Character Lifetime", "Account Lifetime"},
        choicesValues = {1, 2, 3},
        getFunc = function() return 2 end,
        setFunc = function(var) db.var = var doStuff() end,
        tooltip = "Change which statistics are displayed in the main window",
        choicesTooltips = {"Statistics since logging in or reloading the UI.", "Lifetime stats for the current character.", "Lifetime stats of all characters in the account combined."},
        width = "full",
        scrollable = false,
    },
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
function ToggleLocked(control)
    MOON.preferences.unlocked = not MOON.preferences.unlocked
    MOON.Container:SetMovable(MOON.preferences.unlocked)
    if MOON.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Force Showing
function ForceShow(control)
    MOON.ForceShow = not MOON.ForceShow
    if MOON.ForceShow then
        control:SetText("Hide")
        MOON.HUDHidden = false
        MOON.Container:SetHidden(false)
        MOON.UpdateStacks(5)
    else
        control:SetText("Show")
        MOON.HUDHidden = true
        MOON.Container:SetHidden(true)
        MOON.UpdateStacks(0)
    end
end

-- Sizing
function SetSize(value)
    MOON.preferences.size = value
    MOON.Container:SetDimensions(value, value)
    MOON.Texture:SetDimensions(value, value)
    MOON.SetFontSize(value)
end

function GetSize()
    return MOON.preferences.size
end

-- Show In Combat
function SetHideOutOfCombat(value)
    MOON.preferences.hideOOC = value

    if value then
        MOON.RegisterCombatEvent()
    else
        MOON.UnregisterCombatEvent()
    end

end

function GetHideOutOfCombat()
    return MOON.preferences.hideOOC
end

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function S2W:InitSettings()
    LAM:RegisterAddonPanel(S2W.name, panelData)
    LAM:RegisterOptionControls(S2W.name, optionsTable)

    S2W:Trace(2, "Finished InitSettings()")
end


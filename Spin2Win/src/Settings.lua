-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Sep 24, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

S2W.Settings = {}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Reset Data
local function _DoResetSession()
    S2W.UI.Spins = 0
    S2W.UI.Wins = 0
    S2W.UI.Update(false)
end

local function _DoResetCharacter()
    S2W.savedCharacter.spins = 0
    S2W.savedCharacter.wins = 0
    S2W.UI.Update(false)
end

local function _DoResetAccount()
    S2W.saved.spins = 0
    S2W.saved.wins = 0
    S2W.UI.Update(false)
end

local function _DoResetAll()
    _DoResetSession()
    _DoResetCharacter()
    _DoResetAccount()
end

-- Mode
local function _SetMode(mode)
    S2W.saved.mode = mode
    S2W.UI.Update(false)
end

local function _GetMode(mode)
    return S2W.saved.mode
end

-- -----------------------------------------------------------------------------
-- Settings Menu
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
    {
        type = "header",
        name = "Data",
        width = "full",
    },
    {
        type = "button",
        name = "Reset Session",
        func = function() _DoResetSession() end,
        tooltip = "Reset session statistics (since the last login or reload UI).",
        warning = "Resetting session data sets statistics since login or last UI load to zero. It does not affect per-character or account-wide data. This cannot be undone.",
        isDangerous = true,
        width = "half",
    },
    {
        type = "button",
        name = "Reset Lifetime",
        func = function() _DoResetCharacter() end,
        tooltip = "Reset character lifetime statistics to zero.",
        warning = "Resetting character data sets statistics for this character to zero. It does not affect session or account data. This cannot be undone.",
        isDangerous = true,
        width = "half",
    },
    {
        type = "button",
        name = "Reset Account",
        func = function() _DoResetAccount() end,
        tooltip = "Reset account lifetime data to zero. Does not affect per-character data.",
        warning = "Resetting account data sets statistics for this account to zero. It does not affect session or per-character data. This cannot be undone.",
        isDangerous = true,
        width = "half",
    },
    {
        type = "button",
        name = "Reset All Data",
        func = function() _DoResetAll() end,
        tooltip = "Reset all data to zero. Except other characters.",
        warning = "Resetting all data sets statistics for the session, current character, and account to zero. It does not affect other character data, so per-character statistics will be kept.",
        isDangerous = true,
        width = "half",
    },
    {
        type = "header",
        name = "Counter",
        width = "full",
    },
    {
        type = "dropdown",
        name = "Statistics Display",
        choices = {"Session", "Character Lifetime", "Account Lifetime"},
        choicesValues = {1, 2, 3},
        getFunc = function() return _GetMode() end,
        setFunc = function(mode) _SetMode(mode) end,
        tooltip = "Change which statistics are displayed in the main window",
        -- Tooltips appear to be bugged and don't properly disappear.
        --choicesTooltips = {"Statistics since logging in or reloading the UI.", "Lifetime stats for the current character.", "Lifetime stats of all characters in the account combined."},
        width = "full",
        scrollable = false,
    },
}

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function S2W.Settings:Init()
    LAM:RegisterAddonPanel(S2W.name, panelData)
    LAM:RegisterOptionControls(S2W.name, optionsTable)

    S2W:Trace(3, "Finished Settings Init")
end


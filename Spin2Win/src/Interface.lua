-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

local WM      = WINDOW_MANAGER
local SM      = SCENE_MANAGER

S2W.UI        = {}

-- Session Storage
local session = {
    spins = 0,
    wins  = 0,
}

-- -----------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------

local function _FormatThousands(n)
    if n == nil then return 0 end
    return FormatIntegerWithDigitGrouping(n, ',', 3)
end

local function _ToggleDraggable(state)
    if S2W.saved.unlocked then
        if state then
            WM:SetMouseCursor(12)
            S2W.Background:SetCenterColor(0.5, 0.5, 0.5, 0.25)
        else
            WM:SetMouseCursor(0)
            S2W.Background:SetCenterColor(0.1, 0.1, 0.1, 0.25)
        end
    end
end

local function _SavePosition()
    local top  = S2W.Container:GetTop()
    local left = S2W.Container:GetLeft()

    S2W:Trace(2, "Saving position - Left: <<1>> Top: <<2>>", left, top)

    S2W.saved.positionLeft = left
    S2W.saved.positionTop  = top
end

local function _SetPosition(left, top)
    S2W:Trace(2, "Setting - Left: <<1>> Top: <<2>>", left, top)
    S2W.Container:ClearAnchors()
    S2W.Container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function _Report(command)
    if command == "" then
        -- Handle nan or negative, change to zero
        local sessionRatio = session.wins / session.spins
        if sessionRatio ~= sessionRatio or sessionRatio < 0 then
            sessionRatio = 0
        end

        local lifetimeRatio = S2W.savedCharacter.wins / S2W.savedCharacter.spins
        if lifetimeRatio ~= lifetimeRatio or lifetimeRatio < 0 then
            lifetimeRatio = 0
        end

        StartChatInput(zo_strformat(
            "·•°•· Spin2Win Report ·•°•·  Spins: <<1>> (Lifetime <<4>>)  •  Wins: <<2>> (Lifetime <<5>>)  •  Ratio: <<3>> (Lifetime <<6>>)",
            _FormatThousands(session.spins),
            _FormatThousands(session.wins),
            string.format("%.2f", sessionRatio),
            _FormatThousands(S2W.savedCharacter.spins),
            _FormatThousands(S2W.savedCharacter.wins),
            string.format("%.2f", lifetimeRatio)
        ))
    elseif command == "account" then
        -- Handle nan or negative, change to zero
        local accountRatio = S2W.saved.wins / S2W.saved.spins
        if accountRatio ~= accountRatio or accountRatio < 0 then
            accountRatio = 0
        end

        StartChatInput(zo_strformat(
            "·•°•· Spin2Win Report ·•°•· Account-wide ·•°•·  Spins: <<1>>  •  Wins: <<2>>  •  Ratio: <<3>>",
            _FormatThousands(S2W.saved.spins),
            _FormatThousands(S2W.saved.wins),
            string.format("%.2f", accountRatio)
        ))

        -- Default ----------------------------------------------------------------
    else
        d(zo_strformat("<<1>>Command `report <<2>>` not recognized!", S2W.prefix, command))
    end
end

-- -----------------------------------------------------------------------------
-- Shared functions
-- -----------------------------------------------------------------------------

function S2W.UI.Draw()
    local container = WM:GetControlByName("S2WContainer")

    if S2W.enabled then
        -- Draw UI and create context if it doesn't exist
        if container == nil then
            local c = WM:CreateTopLevelWindow("S2WContainer")
            c:SetClampedToScreen(true)
            c:SetDimensions(200, 50)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(S2W.saved.unlocked)
            if S2W.HUDHidden then
                c:SetHidden(true)
            else
                c:SetHidden(false)
            end
            c:SetHandler("OnMoveStop", _SavePosition)
            c:SetHandler("OnMouseEnter", function() _ToggleDraggable(true) end)
            c:SetHandler("OnMouseExit", function() _ToggleDraggable(false) end)

            local bg = WM:CreateControl("S2WBackdrop", c, CT_BACKDROP)
            bg:SetEdgeColor(0.1, 0.1, 0.1, 0.25)
            bg:SetEdgeTexture(nil, 1, 1, 0, nil)
            bg:SetCenterColor(0.1, 0.1, 0.1, 0.25)
            bg:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)
            bg:SetDimensions(200, 50)
            bg:SetAlpha(1)
            bg:SetDrawLayer(0)

            local r = WM:CreateControl("S2WTexture", c, CT_TEXTURE)
            r:SetTexture('/esoui/art/icons/ability_dualwield_005_b.dds')
            r:SetDimensions(50, 50)
            r:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

            local sl = WM:CreateControl("S2WSpinsLabel", c, CT_LABEL)
            sl:SetAnchor(TOPLEFT, c, TOPLEFT, 55, 2)
            sl:SetDimensions(45, 25)
            sl:SetColor(0.68, 0.96, 0.49, 1)
            sl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
            sl:SetVerticalAlignment(CENTER)
            sl:SetHorizontalAlignment(RIGHT)
            sl:SetPixelRoundingEnabled(true)
            sl:SetText("Spins:")

            local wl = WM:CreateControl("S2WWinsLabel", c, CT_LABEL)
            wl:SetAnchor(TOPLEFT, c, TOPLEFT, 55, 25)
            wl:SetDimensions(45, 25)
            wl:SetColor(0.68, 0.96, 0.49, 1)
            wl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
            wl:SetVerticalAlignment(CENTER)
            wl:SetHorizontalAlignment(RIGHT)
            wl:SetPixelRoundingEnabled(true)
            wl:SetText("Wins:")

            local sc = WM:CreateControl("S2WSpinsCount", c, CT_LABEL)
            sc:SetAnchor(TOPLEFT, c, TOPLEFT, 105, 2)
            sc:SetDimensions(105, 25)
            sc:SetColor(1, 1, 1, 1)
            sc:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
            sc:SetVerticalAlignment(CENTER)
            sc:SetHorizontalAlignment(RIGHT)
            sc:SetPixelRoundingEnabled(true)
            sc:SetText("--")

            local wc = WM:CreateControl("S2WWinsCount", c, CT_LABEL)
            wc:SetAnchor(TOPLEFT, c, TOPLEFT, 105, 25)
            wc:SetDimensions(105, 25)
            wc:SetColor(1, 1, 1, 1)
            wc:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
            wc:SetVerticalAlignment(CENTER)
            wc:SetHorizontalAlignment(RIGHT)
            wc:SetPixelRoundingEnabled(true)
            wc:SetText("--")

            S2W.Container = c
            S2W.Background = bg
            S2W.SpinsCount = sc
            S2W.WinsCount = wc

            _SetPosition(S2W.saved.positionLeft, S2W.saved.positionTop)

            -- Reuse context
        else
            if S2W.HUDHidden then
                container:SetHidden(true)
            else
                container:SetHidden(false)
            end
        end

        -- Disable display
    else
        if container ~= nil then
            container:SetHidden(true)
        end
    end

    S2W:Trace(2, "Finished DrawUI()")
end

function S2W.UI.Update(shouldIncrement)
    S2W.UI.UpdateSpins(shouldIncrement)
    S2W.UI.UpdateWins(shouldIncrement)
end

function S2W.UI.UpdateSpins(shouldIncrement)
    -- Do nothing if disabled
    if not S2W.enabled then return end

    -- If we should increment or just update display (e.g. changing modes)
    -- Not set and true increment, false does not
    if shouldIncrement == nil or shouldIncrement ~= false then
        -- Increment saved spins
        session.spins = session.spins + 1
        S2W.saved.spins = S2W.saved.spins + 1
        S2W.savedCharacter.spins = S2W.savedCharacter.spins + 1
    end

    S2W:Trace(1, "Spins - Session: <<1>> Character: <<2>> Account: <<3>>", session.spins, S2W.savedCharacter.spins,
        S2W.saved.spins)

    -- Set based on mode
    local spins
    if S2W.saved.mode == S2W_MODE_ACCOUNT then
        spins = S2W.saved.spins
    elseif S2W.saved.mode == S2W_MODE_CHARACTER then
        spins = S2W.savedCharacter.spins
    elseif S2W.saved.mode == S2W_MODE_SESSION then
        spins = session.spins
    end

    -- Update Display
    if spins == 0 or spins == nil then
        S2W.SpinsCount:SetText('--')
    else
        local spinOut = _FormatThousands(spins)
        S2W.SpinsCount:SetText(spinOut)
    end
end

function S2W.UI.UpdateWins(shouldIncrement)
    -- Do nothing if disabled
    if not S2W.enabled then return end

    -- If we should increment or just update display (e.g. changing modes)
    -- Not set and true increment, false does not
    if shouldIncrement == nil or shouldIncrement ~= false then
        -- Increment saved wins
        session.wins = session.wins + 1
        S2W.saved.wins = S2W.saved.wins + 1
        S2W.savedCharacter.wins = S2W.savedCharacter.wins + 1
    end

    S2W:Trace(1, "Wins - Session: <<1>> Character: <<2>> Account: <<3>>", session.wins, S2W.savedCharacter.wins,
        S2W.saved.wins)

    -- Set based on mode
    local wins
    if S2W.saved.mode == S2W_MODE_ACCOUNT then
        wins = S2W.saved.wins
    elseif S2W.saved.mode == S2W_MODE_CHARACTER then
        wins = S2W.savedCharacter.wins
    elseif S2W.saved.mode == S2W_MODE_SESSION then
        wins = session.wins
    end

    -- Update Display
    if wins == 0 or wins == nil then
        S2W.WinsCount:SetText('--')
    else
        local winOut = _FormatThousands(wins)
        S2W.WinsCount:SetText(winOut)
    end
end

function S2W.UI.ToggleHUD()
    local hudScene = SM:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(_, newState)
        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SM:GetNextScene():GetName() ~= "hudui" then
            S2W.HUDHidden = true
            S2W:Trace(3, "Hiding HUD")
            S2W.UI.Show(false)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            S2W.HUDHidden = false
            S2W:Trace(3, "Showing HUD")
            S2W.UI.Show(true)
        end
    end)

    S2W:Trace(2, "Finished ToggleHUD()")
end

function S2W.UI.Show(shouldShow)
    local context = WM:GetControlByName("S2WContainer")
    if context ~= nil then
        if S2W.ForceShow then
            context:SetHidden(false)
        elseif (shouldShow and S2W.enabled and not S2W.HUDHidden and not S2W.isDead) then
            context:SetHidden(false)
        else
            context:SetHidden(true)
        end
    end
end

function S2W.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(S2W.prefix .. "Setting debug level to 0 (Off)")
        S2W.debugMode = 0
        S2W.saved.debugMode = 0
    elseif command == "debug 1" then
        d(S2W.prefix .. "Setting debug level to 1 (Low)")
        S2W.debugMode = 1
        S2W.saved.debugMode = 1
    elseif command == "debug 2" then
        d(S2W.prefix .. "Setting debug level to 2 (Medium)")
        S2W.debugMode = 2
        S2W.saved.debugMode = 2
    elseif command == "debug 3" then
        d(S2W.prefix .. "Setting debug level to 3 (High)")
        S2W.debugMode = 3
        S2W.saved.debugMode = 3

        -- Modes ------------------------------------------------------------------
    elseif command == "mode session" then
        d(S2W.prefix .. "Setting display mode to Session")
        S2W.saved.mode = 1
        S2W.UI.Update(false)
    elseif command == "mode character" then
        d(S2W.prefix .. "Setting display mode to Character")
        S2W.saved.mode = 2
        S2W.UI.Update(false)
    elseif command == "mode account" then
        d(S2W.prefix .. "Setting display mode to Account")
        S2W.saved.mode = 3
        S2W.UI.Update(false)

        -- Reporting---------------------------------------------------------------
    elseif command == "report" or string.sub(command, 1, 7) == "report " then
        _Report(string.sub(command, 8))

        -- Default ----------------------------------------------------------------
    else
        d(zo_strformat("<<1>>Command `<<2>>` not recognized!", S2W.prefix, command))
    end
end

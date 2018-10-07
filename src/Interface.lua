-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

S2W.UI = {}
S2W.UI.Position = {}
S2W.UI.Spins = 0
S2W.UI.Wins = 0
S2W.UI.MODE_SESSION = 1
S2W.UI.MODE_CHARACTER = 2
S2W.UI.MODE_ACCOUNT = 3

function S2W.UI.Draw()
    local c = WINDOW_MANAGER:CreateTopLevelWindow("S2WContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(200, 50)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(S2W.saved.unlocked)
    c:SetHidden(false)
    c:SetHandler("OnMoveStop", function(...) S2W.UI.Position.Save() end)
    c:SetHandler("OnMouseEnter", function(...) toggleDraggable(true) end)
    c:SetHandler("OnMouseExit", function(...) toggleDraggable(false) end)

    local bg = WINDOW_MANAGER:CreateControl("S2WBackdrop", c, CT_BACKDROP)
    bg:SetEdgeColor(0.1, 0.1, 0.1, 0.25)
    bg:SetEdgeTexture(nil, 1, 1, 0, nil)
    bg:SetCenterColor(0.1, 0.1, 0.1, 0.25)
    bg:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)
    bg:SetDimensions(200, 50)
    bg:SetAlpha(1)
    bg:SetDrawLayer(0)

    local r = WINDOW_MANAGER:CreateControl("S2WTexture", c, CT_TEXTURE)
    r:SetTexture('/esoui/art/icons/ability_dualwield_005_b.dds')
    r:SetDimensions(50, 50)
    r:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    local sl = WINDOW_MANAGER:CreateControl("S2WSpinsLabel", c, CT_LABEL)
    sl:SetAnchor(TOPLEFT, c, TOPLEFT, 55, 2)
    sl:SetDimensions(45, 25)
    sl:SetColor(0.68, 0.96, 0.49, 1)
    sl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    sl:SetVerticalAlignment(CENTER)
    sl:SetHorizontalAlignment(RIGHT)
    sl:SetPixelRoundingEnabled(true)
    sl:SetText("Spins:")

    local wl = WINDOW_MANAGER:CreateControl("S2WWinsLabel", c, CT_LABEL)
    wl:SetAnchor(TOPLEFT, c, TOPLEFT, 55, 25)
    wl:SetDimensions(45, 25)
    wl:SetColor(0.68, 0.96, 0.49, 1)
    wl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    wl:SetVerticalAlignment(CENTER)
    wl:SetHorizontalAlignment(RIGHT)
    wl:SetPixelRoundingEnabled(true)
    wl:SetText("Wins:")

    local sc = WINDOW_MANAGER:CreateControl("S2WSpinsCount", c, CT_LABEL)
    sc:SetAnchor(TOPLEFT, c, TOPLEFT, 105, 2)
    sc:SetDimensions(105, 25)
    sc:SetColor(1, 1, 1, 1)
    sc:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    sc:SetVerticalAlignment(CENTER)
    sc:SetHorizontalAlignment(RIGHT)
    sc:SetPixelRoundingEnabled(true)
    sc:SetText("--")

    local wc = WINDOW_MANAGER:CreateControl("S2WWinsCount", c, CT_LABEL)
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
    S2W.Texture = r
    S2W.SpinsLabel = sl
    S2W.WinsLabel = sl
    S2W.SpinsCount = sc
    S2W.WinsCount = wc

    S2W.UI.Position.Set(S2W.saved.positionLeft, S2W.saved.positionTop)

    S2W:Trace(2, "Finished DrawUI()")
end

function S2W.UI.Update(shouldIncrement)
    S2W.UI.UpdateSpins(shouldIncrement)
    S2W.UI.UpdateWins(shouldIncrement)
end

function S2W.UI.UpdateSpins(shouldIncrement)

    -- If we should increment or just update display (e.g. changing modes)
    -- Not set and true increment, false does not
    if shouldIncrement == nil or shouldIncrement ~= false then
        -- Increment saved spins
        S2W.UI.Spins = S2W.UI.Spins + 1
        S2W.saved.spins = S2W.saved.spins + 1
        S2W.savedCharacter.spins = S2W.savedCharacter.spins + 1
    end

    S2W:Trace(1, zo_strformat("Spins - Session: <<1>> Character: <<2>> Account: <<3>>", S2W.UI.Spins, S2W.savedCharacter.spins, S2W.saved.spins))

    -- Set based on mode
    if S2W.saved.mode == S2W.UI.MODE_ACCOUNT then
        spins = S2W.saved.spins
    elseif S2W.saved.mode == S2W.UI.MODE_CHARACTER then
        spins = S2W.savedCharacter.spins
    elseif S2W.saved.mode == S2W.UI.MODE_SESSION then
        spins = S2W.UI.Spins
    end

    -- Update Display
    if spins == 0 or spins == nil then
        S2W.SpinsCount:SetText('--')
    else
        local spinOut = formatThousands(spins)
        S2W.SpinsCount:SetText(spinOut)
    end
end

function S2W.UI.UpdateWins(shouldIncrement)

    -- If we should increment or just update display (e.g. changing modes)
    -- Not set and true increment, false does not
    if shouldIncrement == nil or shouldIncrement ~= false then
        -- Increment saved wins
        S2W.UI.Wins = S2W.UI.Wins + 1
        S2W.saved.wins = S2W.saved.wins + 1
        S2W.savedCharacter.wins = S2W.savedCharacter.wins + 1
    end

    S2W:Trace(1, zo_strformat("Wins - Session: <<1>> Character: <<2>> Account: <<3>>", S2W.UI.Wins, S2W.savedCharacter.wins, S2W.saved.wins))

    -- Set based on mode
    if S2W.saved.mode == S2W.UI.MODE_ACCOUNT then
        wins = S2W.saved.wins
    elseif S2W.saved.mode == S2W.UI.MODE_CHARACTER then
        wins = S2W.savedCharacter.wins
    elseif S2W.saved.mode == S2W.UI.MODE_SESSION then
        wins = S2W.UI.Wins
    end

    -- Update Display
    if wins == 0 or wins == nil then
        S2W.WinsCount:SetText('--')
    else
        local winOut = formatThousands(wins)
        S2W.WinsCount:SetText(winOut)
    end
end

function toggleDraggable(state)
    if S2W.saved.unlocked then
        if state then
            WINDOW_MANAGER:SetMouseCursor(12)
            S2W.Background:SetCenterColor(0.5, 0.5, 0.5, 0.25)
        else
            WINDOW_MANAGER:SetMouseCursor(0)
            S2W.Background:SetCenterColor(0.1, 0.1, 0.1, 0.25)
        end
    end
end

function formatThousands(n)
    if n == nil then return 0 end

    -- Thanks to http://lua-users.org/wiki/FormattingNumbers
    local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function S2W.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            S2W:Trace(3, "Hiding HUD")
            S2W.UI.Show(false)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            S2W:Trace(3, "Showing HUD")
            S2W.UI.Show(true)
        end
    end)

    S2W:Trace(2, "Finished ToggleHUD()")
end

function S2W.UI.Show(shouldShow)

    -- Don't change states if display should be forced to show
    if S2W.ForceShow then
        S2W.Container:SetHidden(false)
        return
    end

    if (shouldShow) then
        S2W.HUDHidden = false
        S2W.Container:SetHidden(false)
    else
        S2W.HUDHidden = true
        S2W.Container:SetHidden(true)
    end
end


function S2W.UI.Position.Save()
    local top   = S2W.Container:GetTop()
    local left  = S2W.Container:GetLeft()

    S2W:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    S2W.saved.positionLeft = left
    S2W.saved.positionTop  = top
end

function S2W.UI.Position.Set(left, top)
    S2W:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    S2W.Container:ClearAnchors()
    S2W.Container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
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
    elseif command == "report" then
        S2W.UI.Report(command)

    -- Default ----------------------------------------------------------------
    else
        d(S2W.prefix .. "Command not recognized!")
    end
end

function S2W.UI.Report(command)
    if command == "" or command == "report" then

        -- Handle nan or negative, change to zero
        local sessionRatio = S2W.UI.Wins / S2W.UI.Spins
        if sessionRatio ~= sessionRatio or sessionRatio < 0 then
            sessionRatio = 0
        end

        local lifetimeRatio = S2W.savedCharacter.wins / S2W.savedCharacter.spins
        if lifetimeRatio ~= lifetimeRatio or lifetimeRatio < 0 then
            lifetimeRatio = 0
        end

        StartChatInput(zo_strformat("*** Spin2Win Report *** Spins: <<1>> | Wins: <<2>> | Ratio: <<3>> | Lifetime Spins: <<4>> | Lifetime Wins: <<5>> | Lifetime Ratio: <<6>>",
            formatThousands(S2W.UI.Spins), formatThousands(S2W.UI.Wins), string.format("%.2f", sessionRatio),
            formatThousands(S2W.savedCharacter.spins), formatThousands(S2W.savedCharacter.wins), string.format("%.2f", lifetimeRatio)))

    elseif command == "account" or command == "report account" then

        -- Handle nan or negative, change to zero
        local accountRatio = S2W.saved.wins / S2W.saved.spins
        if accountRatio ~= accountRatio or accountRatio < 0 then
            accountRatio = 0
        end

        StartChatInput(zo_strformat("*** Spin2Win Report - Account-wide *** Spins: <<1>> | Wins: <<2>> | Ratio: <<3>>",
            formatThousands(S2W.saved.spins), formatThousands(S2W.saved.wins), string.format("%.2f", accountRatio)))

    -- Default ----------------------------------------------------------------
    else
        d(S2W.prefix .. "Command not recognized!")
    end
end


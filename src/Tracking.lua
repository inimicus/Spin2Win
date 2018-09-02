-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

S2W.Tracking = {}
S2W.Tracking.SpinCount = 0
S2W.Tracking.WinCount = 0

local IDs = {
    STEEL_TORNADO = {
        EFFECT = 39665,
        ABILITY = 38861,
    },
    WHIRLWIND = {
        EFFECT = 39620,
        ABILITY = 28591,
    },
    WHIRLING_BLADES = {
        EFFECT = 39666,
        ABILITY = 38891,
    },
}

function S2W.Tracking.RegisterEvents()

    S2W:Trace(2, "Registering events")

    for morph, table in pairs(IDs) do

        S2W:Trace(2, "Registering: " .. morph)

        for skillType, id in pairs(table) do

            local name = zo_strformat("<<1>>_<<2>>_<<3>>", S2W.name, morph, skillType)
            S2W:Trace(3, zo_strformat("Registering: <<1>> (<<2>>)", morph, id))

            -- Register effects - Spins
            if skillType == "EFFECT" then
                EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, S2W.Tracking.DidSpin)
                EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED,
                    REGISTER_FILTER_ABILITY_ID,                 id,
                    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,    COMBAT_UNIT_TYPE_PLAYER)

            -- Register abilities - Wins
            elseif skillType == "ABILITY" then
                EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, _AvAWin)
                EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT,
                    REGISTER_FILTER_ABILITY_ID,     id,
                    REGISTER_FILTER_UNIT_TAG,       COMBAT_UNIT_TYPE_PLAYER,
                    REGISTER_FILTER_IS_ERROR,       false,
                    REGISTER_FILTER_COMBAT_RESULT,  ACTION_RESULT_KILLING_BLOW)

            -- Not a valid skillType
            else
                -- Do nothing
            end

        end
    end

    -- Battlegrounds KBs
    EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL, _BGWin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL,
        REGISTER_FILTER_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

end

function S2W.Tracking.UnregisterEvents()
    for morph, table in pairs(S2W.Tracking.IDs) do
        S2W:Trace(2, "Unregistering: " .. morph)

        for skillType, id in pairs(table) do
            local name = zo_strformat("<<1>>_<<2>>_<<3>>", S2W.name, morph, skillType)
            S2W:Trace(3, zo_strformat("Unregistering: <<1>> (<<2>>)", morph, id))

            -- Unregister effects
            if skillType == "EFFECT" then
                EVENT_MANAGER:UnregisterForEvent(name, EVENT_EFFECT_CHANGED)

            -- Unregister abilities
            elseif skillType == "ABILITY" then
                EVENT_MANAGER:UnregisterForEvent(name, EVENT_COMBAT_EVENT)

            -- Not a valid skillType
            else
                -- Do Nothing
            end
        end
    end

    -- Battlegrounds
    EVENT_MANAGER:UnregisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL)
end

function S2W.Tracking.DidSpin(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    if changeType ~= EFFECT_RESULT_GAINED then return end

    S2W.Tracking.SpinCount = S2W.Tracking.SpinCount + 1
    S2W:Trace(1, zo_strformat("Counted: <<1>> spins", S2W.Tracking.SpinCount))
    S2W:Trace(2, zo_strformat("<<1>> (<<2>>)", effectName, effectAbilityId))

    S2W.UI.UpdateSpins(S2W.Tracking.SpinCount)

end

--EVENT_COMBAT_EVENT (
--  number eventCode,
--  ActionResult result,
--  boolean isError,
--  string abilityName,
--  number abilityGraphic,
--  ActionSlotType abilityActionSlotType,
--  string sourceName,
--  CombatUnitType sourceType,
--  string targetName,
--  CombatUnitType targetType,
--  number hitValue,
--  CombatMechanicType powerType,
--  DamageType damageType,
--  boolean log,
--  number sourceUnitId,
--  number targetUnitId,
--  number abilityId
--)
function _AvAWin(eventID, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType, _, _, _, _, _, _, abilityId)

    -- Only count player wins
    if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceName ~= targetName then
        S2W:Trace(2, zo_strformat("AVA Win: <<1>> killed <<2>> with <<3>> (<<4>>)", sourceName, targetName, abilityName, abilityId))
        S2W.Tracking.DidWin()
    else
        S2W:Trace(2, zo_strformat("No AVA Win: Non-player source or self-inflicted - <<1>> killed <<2>> with <<3>> (<<4>>)", sourceName, targetName, abilityName, abilityId))
    end

end

--EVENT_BATTLEGROUND_KILL (
--  number eventCode,
--  string killedPlayerCharacterName,
--  string killedPlayerDisplayName,
--  BattlegroundAlliance killedPlayerBattlegroundAlliance,
--  string killingPlayerCharacterName,
--  string killingPlayerDisplayName,
--  BattlegroundAlliance killingPlayerBattlegroundAlliance,
--  BattlegroundKillType battlegroundKillType,
--  number killingAbilityId
--)
function _BGWin(_, killedPlayerCharacterName, _, _, _, _, _, battlegroundKillType, killingAbilityId)

    -- Ignore all but killing blows
    if battlegroundKillType ~= BATTLEGROUND_KILL_TYPE_KILLING_BLOW then return end

    -- Only count Spin-based wins
    if killingAbilityId == IDs.STEEL_TORNADO.ABILITY or
            killingAbilityId == IDs.WHIRLWIND.ABILITY or
            killingAbilityId == IDs.WHIRLING_BLADES.ABILITY then
        S2W:Trace(2, zo_strformat("BG Win: On <<1>> with <<2>> (<<3>>)", killedPlayerCharacterName, GetAbilityName(killingAbilityId), killingAbilityId))
        S2W.Tracking.DidWin()
    else
        S2W:Trace(2, zo_strformat("BG No-Spin KB: <<1>> (<<2>>)", GetAbilityName(killingAbilityId), killingAbilityId))
        return
    end

end

function S2W.Tracking.DidWin()
    S2W.Tracking.WinCount = S2W.Tracking.WinCount + 1
    S2W:Trace(1, zo_strformat("Counted <<1>> wins", S2W.Tracking.WinCount))
    S2W.UI.UpdateWins(S2W.Tracking.WinCount)
end


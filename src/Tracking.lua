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

local SPIN2WIN_EFFECT_ID = 39665
local WHIRLWIND_EFFECT_ID = 39620
local WHIRLING_BLADES_EFFECT_ID = 39666

local SPIN2WIN_ABILITY_ID = 38861
local WHIRLWIND_ABILITY_ID = 28591
local WHIRLING_BLADES_ABILITY_ID = 38891

function S2W.Tracking.RegisterEvents()

    S2W:Trace(2, "Registering events")

    -- SPINNING ------------------------
    EVENT_MANAGER:RegisterForEvent(S2W.name .. "SPIN2WIN", EVENT_EFFECT_CHANGED, S2W.Tracking.DidSpin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "SPIN2WIN", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,                 SPIN2WIN_EFFECT_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,    COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(S2W.name .. "WHIRLWIND", EVENT_EFFECT_CHANGED, S2W.Tracking.DidSpin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "WHIRLWIND", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,                 WHIRLWIND_EFFECT_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,    COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(S2W.name .. "WHIRLING_BLADES", EVENT_EFFECT_CHANGED, S2W.Tracking.DidSpin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "WHIRLING_BLADES", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,                 WHIRLING_BLADES_EFFECT_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,    COMBAT_UNIT_TYPE_PLAYER)

    -- WINNING ---------------------------------------------------------------
    -- Alliance vs Alliance
    EVENT_MANAGER:RegisterForEvent(S2W.name .. "SPIN2WIN", EVENT_COMBAT_EVENT, _AvAWin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "SPIN2WIN", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,     SPIN2WIN_ABILITY_ID,
        REGISTER_FILTER_UNIT_TAG,       COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR,       false,
        REGISTER_FILTER_COMBAT_RESULT,  ACTION_RESULT_KILLING_BLOW)

    EVENT_MANAGER:RegisterForEvent(S2W.name .. "WHIRLWIND", EVENT_COMBAT_EVENT, _AvAWin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "WHIRLWIND", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,     WHIRLWIND_ABILITY_ID,
        REGISTER_FILTER_UNIT_TAG,       COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR,       false,
        REGISTER_FILTER_COMBAT_RESULT,  ACTION_RESULT_KILLING_BLOW)

    EVENT_MANAGER:RegisterForEvent(S2W.name .. "WHIRLINGBLADES", EVENT_COMBAT_EVENT, _AvAWin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name .. "WHIRLINGBLADES", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,     WHIRLING_BLADES_ABILITY_ID,
        REGISTER_FILTER_UNIT_TAG,       COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR,       false,
        REGISTER_FILTER_COMBAT_RESULT,  ACTION_RESULT_KILLING_BLOW)

    -- Battlegrounds
    -- This needs further testing
    EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL, _BGWin)
    EVENT_MANAGER:AddFilterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL,
        --REGISTER_FILTER_ABILITY_ID,   SPIN2WIN_ABILITY_ID,
        REGISTER_FILTER_UNIT_TAG,   COMBAT_UNIT_TYPE_PLAYER)

end

function S2W.Tracking.UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "SPIN2WIN", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "WHIRLWIND", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "WHIRLING_BLADES", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "SPIN2WIN", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "WHIRLWIND", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(S2W.name .. "WHIRLING_BLADES", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL)
    S2W:Trace(2, "Unregistering effects")
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
    S2W:Trace(2, zo_strformat("AVA Win: <<1>> (<<2>>) on target <<3>> (<<4>>) with result <<5>>", abilityName, abilityId, targetName, targetType, result))
    S2W.Tracking.DidWin()
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
function _BGWin(_, killedPlayerCharacterName, killedPlayerDisplayName, _, killingPlayerCharacterName, _, _, battlegroundKillType, killingAbilityId)
    S2W:Trace(2, zo_strformat("BG Win: #<<1>> on target <<2>>", killingAbilityId, killedPlayerCharacterName))
    -- Ignore non-spin kills
    if killingAbilityId ~= SPIN2WIN_ABILITY_ID or
        killingAbilityId ~= WHIRLWIND_ABILITY_ID or
        killingAbilityId ~= WHIRLING_BLADES_ABILITY_ID then return end
    S2W.Tracking.DidWin()
end

function S2W.Tracking.DidWin()
    S2W:Trace(1, "Counted " .. S2W.Tracking.WinCount .. " wins")
    S2W.Tracking.WinCount = S2W.Tracking.WinCount + 1
    S2W.UI.UpdateWins(S2W.Tracking.WinCount)
end


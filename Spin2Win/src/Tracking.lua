-- -----------------------------------------------------------------------------
-- Spin2Win
-- Author:  g4rr3t
-- Created: Aug 22, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local EM                        = EVENT_MANAGER
local WM                        = WINDOW_MANAGER

S2W.Tracking                    = {}

-- Convenience constants identifying skill lines, skills in skill tree
local S2W_SKILL_LINE_DUAL_WIELD = 3
local S2W_SKILL_WHIRLWIND       = 4

-- Keep track of ability we're monitoring in the event of a respec/morph
local trackedAbility

-- IDs of spin abilities
-- Due to effect IDs differing from ability IDs, such as
-- when tracking uses of spin, we need to map the ability
-- ID to the effect ID here.
local IDs                       = { -- Ability ID = Effect ID
    [38861] = 39665,                -- Steel Tornado
    [28591] = 39620,                -- Whirlwind
    [38891] = 39666,                -- Whirling Blades
}

-- -----------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------

-- Updates death state as alive
-- @param none
-- @return none
local function _OnAlive()
    S2W.isDead = false
    S2W.UI.Show(true)
end

-- Updates death state as dead
-- @param none
-- @return none
local function _OnDeath()
    S2W.isDead = true
    S2W.UI.Show(false)
end

-- Callback when hotbars have been updated, e.g. skill (un)slotted
-- @param none
-- @return none
local function _HotbarsUpdated()
    S2W:Trace(2, "Hotbars Updated!")
    S2W.Tracking.CheckSpinSlotted()
end

-- Check action bars for slotted wins
-- @param *integer* abilityId - Ability to check bars for
-- @return *integer|nil* slottedPosition - Slot index of first found skill
local function _GetSlottedPosition(abilityId)
    for x = 3, 7 do
        --- Disable mismatch of integer -> luaindex
        --- @diagnostic disable-next-line: param-type-mismatch
        local slotPrimary = GetSlotBoundId(x, HOTBAR_CATEGORY_PRIMARY)
        if slotPrimary == abilityId then return slotPrimary end

        --- Disable mismatch of integer -> luaindex
        --- @diagnostic disable-next-line: param-type-mismatch
        local slotBackup = GetSlotBoundId(x, HOTBAR_CATEGORY_BACKUP)
        if slotBackup == abilityId then return slotBackup end
    end

    -- No skill matching ID slotted
    return nil
end

-- Wrapper for external call to update wins count
-- @param none
-- @return none
local function _DidWin()
    S2W.UI.UpdateWins()
end

-- Track all spins
-- @param *integer* result
-- @param *MsgEffectResult* changeType
-- @param *integer* effectSlot
-- @param *string* effectName
-- @param *string* unitTag
-- @param *number* beginTime
-- @param *number* endTime
-- @param *integer* stackCount
-- @param *string* iconName
-- @param *string* buffType
-- @param *BuffEffectType* effectType
-- @param *AbilityType* abilityType
-- @param *StatusEffectType* statusEffectType
-- @param *string* unitName
-- @param *integer* unitId
-- @param *integer* abilityId
-- @param *CombatUnitType* sourceType
-- @return none
local function _DidSpin(_, changeType, _, effectName, _, _, _, _, _, _, _, _, _, _, _, effectAbilityId)
    -- Ignore non-gained effects
    if changeType ~= ACTION_RESULT_EFFECT_GAINED then return end

    -- Update Spins
    S2W:Trace(2, "<<1>> (<<2>>)", effectName, effectAbilityId)
    S2W.UI.UpdateSpins()
end

-- Track AVA wins
-- @param *integer* eventId
-- @param *ActionResult* result
-- @param *bool* isError
-- @param *string* abilityName
-- @param *integer* abilityGraphic
-- @param *ActionSlotType* abilityActionSlotType
-- @param *string* _sourceName
-- @param *CombatUnitType* sourceType
-- @param *string* targetName
-- @param *CombatUnitType* targetType
-- @param *integer* hitValue
-- @param *CombatMechanicType* powerType
-- @param *DamageType* damageType
-- @param *bool* log
-- @param *integer* sourceUnitId
-- @param *integer* targetUnitId
-- @param *integer* abilityId
-- @return none
local function _AvAWin(_, _, _, abilityName, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, _, abilityId)
    -- Only count player wins
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and sourceName ~= targetName then
        S2W:Trace(2, "AVA Win: <<1>> killed <<2>> with <<3>> (<<4>>)", sourceName, targetName, abilityName, abilityId)
        _DidWin()
    else
        S2W:Trace(2, "No AVA Win: Non-player source or self-inflicted - <<1>> killed <<2>> with <<3>> (<<4>>)",
            sourceName, targetName, abilityName, abilityId)
    end
end

-- Track Battlegrounds wins
-- @param *string* killedPlayerCharacterName
-- @param *string* killedPlayerDisplayName
-- @param *BattlegroundAlliance* killedPlayerBattlegroundAlliance
-- @param *string* killingPlayerCharacterName
-- @param *string* killingPlayerDisplayName
-- @param *BattlegroundAlliance* killingPlayerBattlegroundAlliance
-- @param *BattlegroundKillType* battlegroundKillType
-- @param *integer* killingAbilityId
-- @return none
local function _BGWin(_, killedPlayerCharacterName, _, _, _, _, _, battlegroundKillType, killingAbilityId)
    -- Ignore all but killing blows
    if battlegroundKillType ~= BATTLEGROUND_KILL_TYPE_KILLING_BLOW then return end

    -- Only count Spin-based wins
    if killingAbilityId == IDs.STEEL_TORNADO.ABILITY or
        killingAbilityId == IDs.WHIRLWIND.ABILITY or
        killingAbilityId == IDs.WHIRLING_BLADES.ABILITY then
        S2W:Trace(2, "BG Win: On <<1>> with <<2>> (<<3>>)", killedPlayerCharacterName, GetAbilityName(killingAbilityId),
            killingAbilityId)
        _DidWin()
    else
        S2W:Trace(2, "BG No-Spin KB: <<1>> (<<2>>)", GetAbilityName(killingAbilityId), killingAbilityId)
        return
    end
end

-- Register events, call when tracking should be enabled
-- @param *integer* abilityId - Skill ability ID to register
-- @return none
local function _RegisterEventsForId(abilityId)
    local effectId = IDs[abilityId]

    S2W:Trace(2, "Registering - Ability: <<1>> Effect: <<2>>", abilityId, effectId)

    -- Spins
    EM:RegisterForEvent(S2W.name .. '_' .. effectId, EVENT_COMBAT_EVENT, _DidSpin)
    EM:AddFilterForEvent(S2W.name .. '_' .. effectId, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID, effectId,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- AVA Wins
    EM:RegisterForEvent(S2W.name .. '_' .. abilityId, EVENT_COMBAT_EVENT, _AvAWin)
    EM:AddFilterForEvent(S2W.name .. '_' .. abilityId, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID, abilityId,
        REGISTER_FILTER_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR, false,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW
    )

    -- Battlegrounds KBs
    EM:RegisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL, _BGWin)
    EM:AddFilterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL,
        REGISTER_FILTER_UNIT_TAG, COMBAT_UNIT_TYPE_PLAYER)

    -- Hide/Show on Death/Alive
    EM:RegisterForEvent(S2W.name, EVENT_PLAYER_ALIVE, _OnAlive)
    EM:RegisterForEvent(S2W.name, EVENT_PLAYER_DEAD, _OnDeath)
end

-- Unregister events, call when tracking should be disabled
-- @param *integer* abilityId - Skill ability ID to unregister
-- @return none
local function _UnregisterEventsForId(abilityId)
    S2W:Trace(2, "Unregistering: <<1>>", abilityId)

    local effectId = IDs[abilityId]

    EM:UnregisterForEvent(S2W.name .. '_' .. effectId, EVENT_EFFECT_CHANGED)
    EM:UnregisterForEvent(S2W.name .. '_' .. abilityId, EVENT_COMBAT_EVENT)

    -- Battlegrounds
    EM:UnregisterForEvent(S2W.name, EVENT_BATTLEGROUND_KILL)

    -- Death state
    EM:UnregisterForEvent(S2W.name, EVENT_PLAYER_ALIVE)
    EM:UnregisterForEvent(S2W.name, EVENT_PLAYER_DEAD)
end

-- -----------------------------------------------------------------------------
-- Shared functions
-- -----------------------------------------------------------------------------

-- Check if spin is slotted on either bar
-- and enable display and tracking accordingly
-- @param none
-- @return none
function S2W.Tracking.CheckSpinSlotted()
    --- Disable mismatch of integer -> luaindex
    --- @diagnostic disable-next-line: param-type-mismatch
    local skillPurchased = IsSkillAbilityPurchased(SKILL_TYPE_WEAPON, S2W_SKILL_LINE_DUAL_WIELD, S2W_SKILL_WHIRLWIND)

    -- Check if skill is purchased
    -- Bail if not purchased and not enabled
    -- If not purchased but enabled, then suspect respec and fall through
    if not skillPurchased and not S2W.enabled then return end

    --- Disable mismatch of integer -> luaindex
    --- @diagnostic disable-next-line: param-type-mismatch
    local abilityId = GetSkillAbilityId(SKILL_TYPE_WEAPON, S2W_SKILL_LINE_DUAL_WIELD, S2W_SKILL_WHIRLWIND, false) --[[@as integer]]
    --- Disable mismatch of integer -> luaindex
    --- @diagnostic disable-next-line: param-type-mismatch
    local name = GetSkillAbilityInfo(SKILL_TYPE_WEAPON, S2W_SKILL_LINE_DUAL_WIELD, S2W_SKILL_WHIRLWIND)
    S2W:Trace(1, "Ability: <<1>> (<<2>>)", name, abilityId)
    local slottedPosition = _GetSlottedPosition(abilityId)

    -- If spin is slotted
    if slottedPosition ~= nil then
        if not S2W.enabled or abilityId ~= trackedAbility then
            S2W:Trace(1, "Enabling S2W, slot <<1>>", slottedPosition)
            trackedAbility = abilityId
            S2W.enabled = true
            _RegisterEventsForId(abilityId)
            S2W.UI.Draw()

            local textureControl = WM:GetControlByName("S2WTexture")
            local texture = GetAbilityIcon(abilityId)
            textureControl:SetTexture(texture)

            S2W.UI.Update(false)
        else
            S2W:Trace(1, "Already enabled")
        end

        -- Spin not slotted
    else
        if S2W.enabled then
            S2W:Trace(1, "Disabling S2W")
            S2W.enabled = false
            _UnregisterEventsForId(abilityId)
            S2W.UI.Draw()
        else
            S2W:Trace(1, "Already disabled")
        end
    end
end

-- Register events required regardless of slotted spin state
-- @param none
-- @return none
function S2W.Tracking.RegisterEvents()
    S2W:Trace(2, "Registering events")
    EM:RegisterForEvent(S2W.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, _HotbarsUpdated)
end

-- Unregister above events
-- @param none
-- @return none
function S2W.Tracking.UnregisterEvents()
    S2W:Trace(2, "Unregistering events")
    EM:UnregisterForEvent(S2W.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
end

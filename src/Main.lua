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

    SLASH_COMMANDS[S2W.slash] = S2W.UI.SlashCommand
    SLASH_COMMANDS['/s2wreport'] = S2W.UI.Report

    S2W.Tracking.RegisterEvents()
    S2W:InitSettings()
    S2W.UI.Draw()
    S2W.UI.ToggleHUD()

    -- On initial load:
    -- - Check if ability purchased
    -- - If not purchased, abort
    -- - Check CanAbilityBeUsedFromHotbar for both bars
    -- - Check if ability is slotted on bars where CanAbilityBeUsedFromHotbar returns true
    -- - If can slot on either bar, enable
    -- - Else abort
    --
    -- Skill changes on bar
    -- - Check CanAbilityBeUsedFromHotbar
    -- - if true, check if skill is slotted
    -- - when can't be used or skill not slotted, don't enable if disabled and disable if enabled (maybe)

    -- maybe use to detect dual wield?
    -- * EVENT_ACTIVE_WEAPON_PAIR_CHANGED (*[ActiveWeaponPair|#ActiveWeaponPair]* _activeWeaponPair_, *bool* _locked_)
    local SKILL_LINE_DUAL_WIELD = 3
    local SKILL_WHIRLWIND = 4
    local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex = GetSkillAbilityInfo(SKILL_TYPE_WEAPON, SKILL_LINE_DUAL_WIELD, SKILL_WHIRLWIND)
    d(zo_strformat("Name: <<1>> purchased: <<2>>", name, tostring(purchased)))

    local abilityId = GetSkillAbilityId(SKILL_TYPE_WEAPON, SKILL_LINE_DUAL_WIELD, SKILL_WHIRLWIND)
    local effectiveAbilityId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, HOTBAR_CATEGORY_PRIMARY)
    d(zo_strformat("Ability unlocked: <<1>> (<<2>>) effectively: <<3>>", GetAbilityName(abilityId), abilityId, effectiveAbilityId))

    --local skillLineName = GetSkillLineName(SKILL_TYPE_WEAPON, SKILL_LINE_DUAL_WIELD)
    --d(skillLineName)

    --local skillType, skillLineIndex, skillIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(*integer* _abilityId_)

    --HOTBAR_CATEGORY_BACKUP
    --HOTBAR_CATEGORY_PRIMARY

    local slotted = {}
    slotted[HOTBAR_CATEGORY_PRIMARY] = {}
    slotted[HOTBAR_CATEGORY_BACKUP] = {}

    local output = {}
    output[HOTBAR_CATEGORY_PRIMARY] = ''
    output[HOTBAR_CATEGORY_BACKUP] = ''

    local usedPrimary = CanAbilityBeUsedFromHotbar(38861, HOTBAR_CATEGORY_PRIMARY)
    local usedBackup = CanAbilityBeUsedFromHotbar(38861, HOTBAR_CATEGORY_BACKUP)

    d(zo_strformat("Can be used on primary: <<1>>", tostring(usedPrimary)))
    d(zo_strformat("Can be used on backup: <<1>>", tostring(usedBackup)))

    for x = 3, 8 do
        slotted[HOTBAR_CATEGORY_PRIMARY][x] = GetAbilityName(GetSlotBoundId(x, HOTBAR_CATEGORY_PRIMARY))
        slotted[HOTBAR_CATEGORY_BACKUP][x] = GetAbilityName(GetSlotBoundId(x, HOTBAR_CATEGORY_BACKUP))

        output[HOTBAR_CATEGORY_PRIMARY] = output[HOTBAR_CATEGORY_PRIMARY] .. x .. ': ' .. slotted[HOTBAR_CATEGORY_PRIMARY][x] .. ' '
        output[HOTBAR_CATEGORY_BACKUP] = output[HOTBAR_CATEGORY_BACKUP] .. x .. ': ' .. slotted[HOTBAR_CATEGORY_BACKUP][x] .. ' '
    end

    d('Main: ' .. output[HOTBAR_CATEGORY_PRIMARY])
    d('Backup: ' .. output[HOTBAR_CATEGORY_BACKUP])

    -- Fires on bar swap and purchasing skills
    --EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ABILITY_LIST_CHANGED, function(...) d('Ability List Changed') end)

    --* EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED (*bool* _didActiveHotbarChange_, *bool* _shouldUpdateAbilityAssignments_, *[HotBarCategory|#HotBarCategory]* _activeHotbarCategory_)
    local function ActiveHotbarUpdated(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
        d(zo_strformat("Hotbar Updated - didChange: <<1>> shouldUpdate: <<2>> activeCategory: <<3>>", tostring(didActiveHotbarChange), tostring(shouldUpdateAbilityAssignments), activeHotbarCategory))
    end
    --EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, ActiveHotbarUpdated)

    -- Not helpful detecting new skill slotted
    -- EVENT_ACTION_SLOT_STATE_UPDATED = 131176
    -- * EVENT_ACTION_SLOT_UPDATED (*luaindex* _slotNum_)
    local function SlotUpdated(slotNum, var1, var2)
        d(zo_strformat("Slot Updated - slotNum: <<1>> var1: <<2>> var2: <<3>>", slotNum, var1, tostring(var2)))
    end
    --EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ACTION_SLOT_UPDATED, SlotUpdated)

    -- Does not fire when slotted abilities change
    -- * EVENT_ACTION_SLOT_ABILITY_SLOTTED (*bool* _newAbilitySlotted_)
    local function AbilitySlotted(newAbilitySlotted, var1, var2)
        d(zo_strformat("Ability Slotted - new: <<1>> var1: <<2>> var2: <<3>>", tostring(newAbilitySlotted), tostring(var1), tostring(var2)))
    end
    --EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ACTION_SLOT_ABILITY_SLOTTED, AbilitySlotted)

    -- maybe?
    -- * EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED
    -- EVENT_ACTION_UPDATE_COOLDOWNS = 131180
    local function HotbarsUpdated(var1, var2)
        d(zo_strformat("All Hotbars Updated - var1: <<1>> var2: <<2>>", tostring(var1), tostring(var2)))
    end
    EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, HotbarsUpdated)

    -- Lots of events on bar swap, not useful
    -- * EVENT_ACTION_SLOT_STATE_UPDATED (*luaindex* _slotNum_)
    -- EVENT_ITEM_SLOT_CHANGED = 131177
    local function StateUpdated(slotNum, var1, var2)
        d(zo_strformat("State Updated - slotNum: <<1>> var1: <<2>> var2: <<3>>", slotNum, tostring(var1), tostring(var2)))
    end
    --EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ACTION_SLOT_STATE_UPDATED, StateUpdated)

    S2W.UI.Update(false)
    S2W:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(S2W.name, EVENT_ADD_ON_LOADED, function(...) S2W.Initialize(...) end)


--[[
    QB Inventory Server Wrapper with Hooks System

    Hooks system inspired by and based on ox_inventory's hook implementation
    Credits to Overextended (ox_inventory) for the original hooks design
]]

if GetResourceState('qb-inventory') ~= 'started' then
    return
end

local Normalizer = require 'wrappers.normalizer'

-- Hooks storage --------------------------------------------------------------
local registeredHooks = {}

-- Local helpers --------------------------------------------------------------
local qbInv = exports['qb-inventory']

-- Hook management functions --------------------------------------------------
-- Based on ox_inventory's hooks implementation by Overextended

local function registerHook(hookName, callback)
    if type(hookName) ~= 'string' or type(callback) ~= 'function' then
        error('Invalid hook registration: hookName must be string, callback must be function')
    end

    if not registeredHooks[hookName] then
        registeredHooks[hookName] = {}
    end

    table.insert(registeredHooks[hookName], callback)
end

local function triggerHook(hookName, ...)
    local callbacks = registeredHooks[hookName]
    if not callbacks then return end

    for i = 1, #callbacks do
        local success, result = pcall(callbacks[i], ...)
        if not success then
            print(('Hook error in %s: %s'):format(hookName, result))
        elseif result == false then
            return false
        end
    end
    return true
end

local function removeHook(hookName, callback)
    local callbacks = registeredHooks[hookName]
    if not callbacks then return end

    for i = #callbacks, 1, -1 do
        if callbacks[i] == callback then
            table.remove(callbacks, i)
            break
        end
    end
end

local function clearHooks(hookName)
    if hookName then
        registeredHooks[hookName] = nil
    else
        registeredHooks = {}
    end
end

-- Basic inventory functions --------------------------------------------------

local function addItem(source, item, count, metadata)
    return qbInv:AddItem(source, item, count or 1, metadata)
end

local function removeItem(source, item, count, metadata, slot)
    return qbInv:RemoveItem(source, item, count or 1, slot or false)
end

local function getItemCount(source, item, metadata)
    return qbInv:GetItemCount(source, item)
end

local function getItem(source, item, metadata, strict)
    return qbInv:GetItemByName(source, item)
end

local function getInventory(source)
    return qbInv:GetInventory(source)
end

local function getSlots(source)
    local used, free = qbInv:GetSlots(source)
    return free + used
end

local function getWeight(source)
    return qbInv:GetFreeWeight(source)
end

local function canCarryItem(source, item, count, metadata)
    return qbInv:CanAddItem(source, item, count or 1)
end

local function canCarryWeight(source, weight)
    return weight <= qbInv:GetFreeWeight(source)
end

local function clearInventory(source, keep)
    return qbInv:ClearInventory(source, keep)
end

-- Enhanced functions with hook support ---------------------------------------

local function addItemWithHook(source, item, count, metadata)
    local data = {
        source = source,
        item = item,
        count = count,
        metadata = metadata
    }

    if triggerHook('addItem', data) == false then
        return false
    end

    local result = qbInv:AddItem(source, item, count or 1, metadata)

    if result then
        triggerHook('afterAddItem', data, result)
    end

    return result
end

local function removeItemWithHook(source, item, count, metadata, slot)
    local data = {
        source = source,
        item = item,
        count = count,
        metadata = metadata,
        slot = slot
    }

    if triggerHook('removeItem', data) == false then
        return false
    end

    local result = qbInv:RemoveItem(source, item, count or 1, slot or false)

    if result then
        triggerHook('afterRemoveItem', data, result)
    end

    return result
end

local function giveItemWithHook(source, target, item, count, metadata)
    local data = {
        source = source,
        target = target,
        item = item,
        count = count,
        metadata = metadata
    }

    if triggerHook('giveItem', data) == false then
        return false
    end

    local removed = qbInv:RemoveItem(source, item, count or 1, false)
    if removed then
        local added = qbInv:AddItem(target, item, count or 1, metadata)
        if added then
            triggerHook('afterGiveItem', data, { removed = removed, added = added })
            return true
        else
            qbInv:AddItem(source, item, count or 1, metadata)
            return false
        end
    end

    return false
end

local function clearInventoryWithHook(source, keep)
    local data = {
        source = source,
        keep = keep
    }

    if triggerHook('clearInventory', data) == false then
        return false
    end

    local result = qbInv:ClearInventory(source, keep)

    if result then
        triggerHook('afterClearInventory', data, result)
    end

    return result
end

-- Register functions in normalizer ------------------------------------------
Normalizer.inventory.getItem      = getItem
Normalizer.inventory.addItem      = addItemWithHook
Normalizer.inventory.removeItem   = removeItemWithHook
Normalizer.capabilities.inventory = true

-- Public API -----------------------------------------------------------------
return {
    addItem        = addItemWithHook,
    removeItem     = removeItemWithHook,
    getItemCount   = getItemCount,
    getItem        = getItem,
    getInventory   = getInventory,
    getSlots       = getSlots,
    getWeight      = getWeight,
    canCarryItem   = canCarryItem,
    canCarryWeight = canCarryWeight,
    clearInventory = clearInventoryWithHook,
    giveItem       = giveItemWithHook,
    registerHook   = registerHook,
    triggerHook    = triggerHook,
    removeHook     = removeHook,
    clearHooks     = clearHooks,
}

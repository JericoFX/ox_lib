--[[
    QB Inventory Server Wrapper (functional)
]]

if GetResourceState('qb-inventory') ~= 'started' then
    return
end

local Normalizer = require 'wrappers.core.normalizer'

-- Local helpers --------------------------------------------------------------
local qbInv = exports['qb-inventory']

-- Add a new item
local function addItem(source, item, count, metadata)
    return qbInv:AddItem(source, item, count or 1, metadata)
end

-- Remove an item
local function removeItem(source, item, count, metadata, slot)
    return qbInv:RemoveItem(source, item, count or 1, slot or false)
end

-- Get item count for a player
local function getItemCount(source, item, metadata)
    return qbInv:GetItemCount(source, item)
end

-- Get first instance of item
local function getItem(source, item, metadata, strict)
    return qbInv:GetItemByName(source, item)
end

-- Get full inventory table
local function getInventory(source)
    return qbInv:GetInventory(source)
end

-- Slots and weight helpers
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

-- Register minimal API in Normalizer ----------------------------------------
Normalizer.inventory.getItem      = getItem
Normalizer.inventory.addItem      = addItem
Normalizer.inventory.removeItem   = removeItem
Normalizer.capabilities.inventory = true

-- Public API -----------------------------------------------------------------
return {
    addItem        = addItem,
    removeItem     = removeItem,
    getItemCount   = getItemCount,
    getItem        = getItem,
    getInventory   = getInventory,
    getSlots       = getSlots,
    getWeight      = getWeight,
    canCarryItem   = canCarryItem,
    canCarryWeight = canCarryWeight,
    clearInventory = clearInventory,
}

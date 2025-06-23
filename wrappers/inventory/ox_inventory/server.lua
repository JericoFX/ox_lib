--[[
    OX Inventory Server Functions
]]

-- Early exit if ox_inventory is not running
if GetResourceState('ox_inventory') ~= 'started' then
    return
end
local ox_inventory = exports.ox_inventory
local Normalizer = require 'wrappers.normalizer'

-- Local helpers --------------------------------------------------------------
local function getItem(source, item, metadata, strict)
    return Normalizer.cache:get(('oxi:getItem:%s:%s'):format(source, item), function()
        return ox_inventory:GetItem(source, item, metadata, strict)
    end)
end

local function addItem(source, item, count, metadata)
    return ox_inventory:AddItem(source, item, count, metadata)
end

local function removeItem(source, item, count, metadata, slot)
    return ox_inventory:RemoveItem(source, item, count, metadata, slot)
end

local function getItemCount(source, item, metadata)
    return ox_inventory:GetItemCount(source, item, metadata)
end

local function getInventory(source)
    return ox_inventory:GetInventory(source)
end

local function getSlots(source)
    return ox_inventory:GetSlots(source)
end

local function getWeight(source)
    return ox_inventory:GetWeight(source)
end

local function canCarryItem(source, item, count, metadata)
    return ox_inventory:CanCarryItem(source, item, count, metadata)
end

local function canCarryWeight(source, weight)
    return ox_inventory:CanCarryWeight(source, weight)
end

local function setMaxWeight(source, weight)
    return ox_inventory:SetMaxWeight(source, weight)
end

local function confiscateInventory(source)
    return ox_inventory:ConfiscateInventory(source)
end

local function returnInventory(source)
    return ox_inventory:ReturnInventory(source)
end

local function clearInventory(source, keep)
    return ox_inventory:ClearInventory(source, keep)
end

local function createShop(data)
    return ox_inventory:CreateShop(data)
end

local function createStash(data)
    return ox_inventory:CreateStash(data)
end

-- Register functions in normalizer ------------------------------------------
Normalizer.inventory.getItem      = getItem
Normalizer.inventory.addItem      = addItem
Normalizer.inventory.removeItem   = removeItem
Normalizer.capabilities.inventory = true

-- Public API -----------------------------------------------------------------
return {
    getItem             = getItem,
    addItem             = addItem,
    removeItem          = removeItem,
    getItemCount        = getItemCount,
    getInventory        = getInventory,
    getSlots            = getSlots,
    getWeight           = getWeight,
    canCarryItem        = canCarryItem,
    canCarryWeight      = canCarryWeight,
    setMaxWeight        = setMaxWeight,
    confiscateInventory = confiscateInventory,
    returnInventory     = returnInventory,
    clearInventory      = clearInventory,
    createShop          = createShop,
    createStash         = createStash,
}

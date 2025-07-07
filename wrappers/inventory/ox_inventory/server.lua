--[[
    OX Inventory Server Functions
]]

-- Early exit if ox_inventory is not running
if GetResourceState('ox_inventory') ~= 'started' then
    return
end
local ox_inventory = exports.ox_inventory
local Normalizer = require 'wrappers.normalizer'

-- Hooks storage --------------------------------------------------------------
local registeredHooks = {}

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

-- Hook management functions --------------------------------------------------

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

    local result = ox_inventory:AddItem(source, item, count, metadata)

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

    local result = ox_inventory:RemoveItem(source, item, count, metadata, slot)

    if result then
        triggerHook('afterRemoveItem', data, result)
    end

    return result
end

local function buyItemWithHook(source, shopName, item, count, price)
    local data = {
        source = source,
        shopName = shopName,
        item = item,
        count = count,
        price = price
    }

    if triggerHook('buyItem', data) == false then
        return false
    end

    local result = ox_inventory:AddItem(source, item, count)

    if result then
        triggerHook('afterBuyItem', data, result)
    end

    return result
end

local function swapSlotsWithHook(source, fromSlot, toSlot, fromInventory, toInventory)
    local data = {
        source = source,
        fromSlot = fromSlot,
        toSlot = toSlot,
        fromInventory = fromInventory,
        toInventory = toInventory
    }

    if triggerHook('swapSlots', data) == false then
        return false
    end

    local result = ox_inventory:SwapSlots(source, fromSlot, toSlot, fromInventory, toInventory)

    if result then
        triggerHook('afterSwapSlots', data, result)
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

    local removed = ox_inventory:RemoveItem(source, item, count, metadata)
    if removed then
        local added = ox_inventory:AddItem(target, item, count, metadata)
        if added then
            triggerHook('afterGiveItem', data, { removed = removed, added = added })
            return true
        else
            ox_inventory:AddItem(source, item, count, metadata)
            return false
        end
    end

    return false
end

-- Register functions in normalizer ------------------------------------------
Normalizer.inventory.getItem      = getItem
Normalizer.inventory.addItem      = addItemWithHook
Normalizer.inventory.removeItem   = removeItemWithHook
Normalizer.capabilities.inventory = true

-- Public API -----------------------------------------------------------------
return {
    getItem             = getItem,
    addItem             = addItemWithHook,
    removeItem          = removeItemWithHook,
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
    registerHook        = registerHook,
    triggerHook         = triggerHook,
    removeHook          = removeHook,
    clearHooks          = clearHooks,
    buyItem             = buyItemWithHook,
    swapSlots           = swapSlotsWithHook,
    giveItem            = giveItemWithHook,
}

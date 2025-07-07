--[[
    OX Shops Server Functions with Hooks Support
]]

if GetResourceState('ox_inventory') ~= 'started' then
    return
end

local ox_inventory = exports.ox_inventory
local Normalizer = require 'wrappers.normalizer'

-- Local helpers --------------------------------------------------------------

local function createShop(shopData)
    if not shopData or not shopData.name then
        print('[ox_shops] Error: Shop data or name is missing')
        return false
    end

    local data = {
        shopName = shopData.name,
        shopData = shopData
    }

    if lib.inventory.triggerHook('createShop', data) == false then
        return false
    end

    local success, result = pcall(function()
        return ox_inventory:CreateShop(shopData)
    end)

    if success then
        lib.inventory.triggerHook('afterCreateShop', data, result)
        return result
    else
        print('[ox_shops] Failed to create shop: ' .. tostring(result))
        return false
    end
end

local function deleteShop(shopName)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return false
    end

    local data = { shopName = shopName }

    if lib.inventory.triggerHook('deleteShop', data) == false then
        return false
    end

    local success, result = pcall(function()
        return ox_inventory:RemoveInventory(shopName)
    end)

    if success then
        lib.inventory.triggerHook('afterDeleteShop', data, result)
        return result
    else
        print('[ox_shops] Failed to delete shop: ' .. tostring(result))
        return false
    end
end

local function addShopItem(shopName, itemData)
    if not shopName or not itemData then
        print('[ox_shops] Error: Shop name and item data are required')
        return false
    end

    local formattedItem = {
        name = itemData.name,
        count = itemData.amount or itemData.count or 10,
        price = itemData.price or 1,
        metadata = itemData.metadata or {}
    }

    local data = {
        shopName = shopName,
        itemData = formattedItem
    }

    if lib.inventory.triggerHook('addShopItem', data) == false then
        return false
    end

    local success, result = pcall(function()
        return ox_inventory:AddItem(shopName, formattedItem.name, formattedItem.count, formattedItem.metadata, false, 'ox_shops:addItem')
    end)

    if success then
        lib.inventory.triggerHook('afterAddShopItem', data, result)
        return result
    else
        print('[ox_shops] Failed to add item to shop: ' .. tostring(result))
        return false
    end
end

local function removeShopItem(shopName, itemName, amount)
    if not shopName or not itemName then
        print('[ox_shops] Error: Shop name and item name are required')
        return false
    end

    local data = {
        shopName = shopName,
        itemName = itemName,
        amount = amount or 1
    }

    if lib.inventory.triggerHook('removeShopItem', data) == false then
        return false
    end

    local success, result = pcall(function()
        return ox_inventory:RemoveItem(shopName, itemName, amount or 1, false, 'ox_shops:removeItem')
    end)

    if success then
        lib.inventory.triggerHook('afterRemoveShopItem', data, result)
        return result
    else
        print('[ox_shops] Failed to remove item from shop: ' .. tostring(result))
        return false
    end
end

local function buyShopItem(source, shopName, itemName, amount, price)
    if not source or not shopName or not itemName then
        print('[ox_shops] Error: Missing required parameters for buyShopItem')
        return false
    end

    local data = {
        source = source,
        shopName = shopName,
        itemName = itemName,
        amount = amount or 1,
        price = price or 0
    }

    if lib.inventory.triggerHook('buyShopItem', data) == false then
        return false
    end

    local removed = removeShopItem(shopName, itemName, amount or 1)
    if removed then
        local added = lib.inventory.buyItem(source, shopName, itemName, amount or 1, price or 0)
        if added then
            lib.inventory.triggerHook('afterBuyShopItem', data, { removed = removed, added = added })
            return true
        else
            addShopItem(shopName, { name = itemName, amount = amount or 1, price = price or 0 })
            return false
        end
    end

    return false
end

local function sellToShop(source, shopName, itemName, amount, price)
    if not source or not shopName or not itemName then
        print('[ox_shops] Error: Missing required parameters for sellToShop')
        return false
    end

    local data = {
        source = source,
        shopName = shopName,
        itemName = itemName,
        amount = amount or 1,
        price = price or 0
    }

    if lib.inventory.triggerHook('sellToShop', data) == false then
        return false
    end

    local removed = lib.inventory.removeItem(source, itemName, amount or 1)
    if removed then
        local added = addShopItem(shopName, { name = itemName, amount = amount or 1, price = price or 0 })
        if added then
            lib.inventory.triggerHook('afterSellToShop', data, { removed = removed, added = added })
            return true
        else
            lib.inventory.addItem(source, itemName, amount or 1)
            return false
        end
    end

    return false
end

local function getShop(shopName)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return nil
    end

    local success, result = pcall(function()
        return ox_inventory:GetInventory(shopName)
    end)

    if success then
        return result
    else
        print('[ox_shops] Failed to get shop: ' .. tostring(result))
        return nil
    end
end

local function updateShopItem(shopName, itemName, updateData)
    if not shopName or not itemName or not updateData then
        print('[ox_shops] Error: Shop name, item name and update data are required')
        return false
    end

    local data = {
        shopName = shopName,
        itemName = itemName,
        updateData = updateData
    }

    if lib.inventory.triggerHook('updateShopItem', data) == false then
        return false
    end

    local removed = removeShopItem(shopName, itemName)
    if removed then
        local added = addShopItem(shopName, {
            name = itemName,
            amount = updateData.amount or 1,
            price = updateData.price or 1,
            metadata = updateData.metadata or {}
        })

        if added then
            lib.inventory.triggerHook('afterUpdateShopItem', data, { removed = removed, added = added })
            return true
        end
    end

    return false
end

local function clearShop(shopName)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return false
    end

    local data = { shopName = shopName }

    if lib.inventory.triggerHook('clearShop', data) == false then
        return false
    end

    local success, result = pcall(function()
        return ox_inventory:ClearInventory(shopName)
    end)

    if success then
        lib.inventory.triggerHook('afterClearShop', data, result)
        return result
    else
        print('[ox_shops] Failed to clear shop: ' .. tostring(result))
        return false
    end
end

-- Register functions in normalizer ------------------------------------------
Normalizer.shops.createShop     = createShop
Normalizer.shops.deleteShop     = deleteShop
Normalizer.shops.addShopItem    = addShopItem
Normalizer.shops.removeShopItem = removeShopItem
Normalizer.shops.buyShopItem    = buyShopItem
Normalizer.shops.sellToShop     = sellToShop
Normalizer.shops.getShop        = getShop
Normalizer.shops.updateShopItem = updateShopItem
Normalizer.shops.clearShop      = clearShop
Normalizer.capabilities.shops   = true

-- Public API -----------------------------------------------------------------
return {
    createShop     = createShop,
    deleteShop     = deleteShop,
    addShopItem    = addShopItem,
    removeShopItem = removeShopItem,
    buyShopItem    = buyShopItem,
    sellToShop     = sellToShop,
    getShop        = getShop,
    updateShopItem = updateShopItem,
    clearShop      = clearShop,
}

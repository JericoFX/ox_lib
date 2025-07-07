--[[ local Shops = lib.class('shops')
local Normalizer = require 'wrappers.normalizer'

function Shops:constructor()
    self.system = 'ox_shops'
end

-- Create a new shop using ox_inventory
function Shops:createShop(shopData)
    if not shopData or not shopData.name then
        print('[ox_shops] Error: Shop data or name is missing')
        return false
    end

    -- Format shop data for ox_inventory compatibility
    local formattedData = {
        name = shopData.name,
        label = shopData.label or shopData.name,
        coords = shopData.coords,
        slots = shopData.slots or #(shopData.items or {}),
        items = shopData.items or {}
    }

    -- Use ox_inventory CreateInventory for shops
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:CreateInventory(shopData.name, {
                label = shopData.label or shopData.name,
                maxweight = shopData.maxweight or 100000,
                slots = shopData.slots or 50
            })
        end)
        if success then
            print('[ox_shops] Shop inventory created successfully: ' .. shopData.name)
            -- Now populate the shop with items
            self:populateShop(shopData.name, shopData.items or {})
            return true
        else
            print('[ox_shops] Failed to create shop using ox_inventory: ' .. tostring(result))
        end
    end

    -- Fallback to event-based creation
    TriggerServerEvent('ox_shops:server:CreateShop', formattedData)
    return true
end

-- Populate shop with items
function Shops:populateShop(shopName, items)
    if not shopName or not items then return false end

    for _, item in pairs(items) do
        if item.name and item.amount and item.price then
            self:addShopItem(shopName, item)
        end
    end
    return true
end

-- Open a shop using ox_inventory
function Shops:openShop(shopName, playerSource)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return false
    end

    -- Use ox_inventory OpenInventory for shops
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:OpenInventory(playerSource or cache.serverId, shopName)
        end)
        if success then
            return true
        else
            print('[ox_shops] Failed to open shop using ox_inventory: ' .. tostring(result))
        end
    end

    -- Fallback to event-based opening
    TriggerServerEvent('ox_shops:server:OpenShop', shopName)
    return true
end

-- Add item to shop
function Shops:addShopItem(shopName, itemData)
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

    -- Use ox_inventory AddItem if available
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:AddItem(shopName, formattedItem.name, formattedItem.count, formattedItem.metadata, false, 'ox_shops:addItem')
        end)
        if success then
            return true
        else
            print('[ox_shops] Failed to add item using ox_inventory: ' .. tostring(result))
        end
    end

    TriggerServerEvent('ox_shops:server:AddShopItem', shopName, formattedItem)
    return true
end

-- Remove item from shop
function Shops:removeShopItem(shopName, itemName, amount)
    if not shopName or not itemName then
        print('[ox_shops] Error: Shop name and item name are required')
        return false
    end

    -- Use ox_inventory RemoveItem if available
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:RemoveItem(shopName, itemName, amount or 1, false, 'ox_shops:removeItem')
        end)
        if success then
            return true
        else
            print('[ox_shops] Failed to remove item using ox_inventory: ' .. tostring(result))
        end
    end

    TriggerServerEvent('ox_shops:server:RemoveShopItem', shopName, itemName, amount)
    return true
end

-- Update shop item
function Shops:updateShopItem(shopName, itemName, updateData)
    if not shopName or not itemName or not updateData then
        print('[ox_shops] Error: Shop name, item name and update data are required')
        return false
    end

    -- For ox_inventory, we might need to remove and re-add the item
    if updateData.amount then
        self:removeShopItem(shopName, itemName)
        self:addShopItem(shopName, {
            name = itemName,
            amount = updateData.amount,
            price = updateData.price,
            metadata = updateData.metadata
        })
    end

    TriggerServerEvent('ox_shops:server:UpdateShopItem', shopName, itemName, updateData)
    return true
end

-- Get shop data
function Shops:getShop(shopName)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return nil
    end

    -- Use ox_inventory GetInventory if available
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:GetInventory(shopName)
        end)
        if success and result then
            return result
        end
    end

    -- Fallback to callback-based approach
    local promise = promise.new()
    TriggerServerEvent('ox_shops:server:GetShop', shopName, function(shopData)
        promise:resolve(shopData)
    end)
    return Citizen.Await(promise)
end

-- Delete shop
function Shops:deleteShop(shopName)
    if not shopName then
        print('[ox_shops] Error: Shop name is required')
        return false
    end

    -- Use ox_inventory RemoveInventory if available
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:RemoveInventory(shopName)
        end)
        if success then
            return true
        end
    end

    TriggerServerEvent('ox_shops:server:DeleteShop', shopName)
    return true
end

-- Get all shops
function Shops:getAllShops()
    local promise = promise.new()
    TriggerServerEvent('ox_shops:server:GetAllShops', function(shopsData)
        promise:resolve(shopsData)
    end)
    return Citizen.Await(promise)
end

-- Buy item from shop
function Shops:buyItem(shopName, itemName, amount)
    if not shopName or not itemName then
        print('[ox_shops] Error: Shop name and item name are required')
        return false
    end

    local data = {
        shopName = shopName,
        itemName = itemName,
        amount = amount or 1
    }

    TriggerServerEvent('ox_shops:server:BuyItem', shopName, itemName, amount or 1)
    return true
end

-- Register shop hook
function Shops:registerShopHook(hookName, callback)
    if IsDuplicityVersion() then
        if lib.inventory and lib.inventory.registerHook then
            lib.inventory.registerHook(hookName, callback)
        end
    end
end

-- Trigger shop hook
function Shops:triggerShopHook(hookName, ...)
    if IsDuplicityVersion() then
        if lib.inventory and lib.inventory.triggerHook then
            return lib.inventory.triggerHook(hookName, ...)
        end
    end
    return true
end

-- Check if shop exists
function Shops:shopExists(shopName)
    if not shopName then return false end

    local shopData = self:getShop(shopName)
    return shopData ~= nil
end

-- Create shop with items easily
function Shops:createQuickShop(name, label, coords, items)
    local shopData = {
        name = name,
        label = label,
        coords = coords,
        items = items or {},
        slots = #(items or {}),
        maxweight = 100000
    }

    return self:createShop(shopData)
end

-- Get shop items
function Shops:getShopItems(shopName)
    if not shopName then return {} end

    local shopData = self:getShop(shopName)
    return shopData and shopData.items or {}
end

-- Clear shop items
function Shops:clearShop(shopName)
    if not shopName then return false end

    -- Use ox_inventory ClearInventory if available
    if GetResourceState('ox_inventory') == 'started' then
        local success, result = pcall(function()
            return exports.ox_inventory:ClearInventory(shopName)
        end)
        if success then
            return true
        end
    end

    TriggerServerEvent('ox_shops:server:ClearShop', shopName)
    return true
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.shops.createShop       = function(...) return Shops:createShop(...) end
Normalizer.shops.openShop         = function(...) return Shops:openShop(...) end
Normalizer.shops.addShopItem      = function(...) return Shops:addShopItem(...) end
Normalizer.shops.removeShopItem   = function(...) return Shops:removeShopItem(...) end
Normalizer.shops.updateShopItem   = function(...) return Shops:updateShopItem(...) end
Normalizer.shops.getShop          = function(...) return Shops:getShop(...) end
Normalizer.shops.deleteShop       = function(...) return Shops:deleteShop(...) end
Normalizer.shops.getAllShops      = function(...) return Shops:getAllShops(...) end
Normalizer.shops.buyItem          = function(...) return Shops:buyItem(...) end
Normalizer.shops.shopExists       = function(...) return Shops:shopExists(...) end
Normalizer.shops.createQuickShop  = function(...) return Shops:createQuickShop(...) end
Normalizer.shops.getShopItems     = function(...) return Shops:getShopItems(...) end
Normalizer.shops.clearShop        = function(...) return Shops:clearShop(...) end
Normalizer.shops.populateShop     = function(...) return Shops:populateShop(...) end
Normalizer.shops.registerShopHook = function(...) return Shops:registerShopHook(...) end
Normalizer.shops.triggerShopHook  = function(...) return Shops:triggerShopHook(...) end
Normalizer.capabilities.shops     = true

return Shops
 ]]
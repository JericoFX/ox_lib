--[[
    TODO: usar clases en el cliente
]]

local Inventory = lib.class('Inventory')

function Inventory:constructor()
    self.system = 'qb-inventory'
    self.exports = exports['qb-inventory']
end

function Inventory:openInventory(type, data)
    if type == 'player' then
        TriggerServerEvent('inventory:server:OpenInventory', 'player')
    else
        TriggerServerEvent('inventory:server:OpenInventory', type, data)
    end
end

function Inventory:closeInventory()
    TriggerEvent('inventory:client:CloseInventory')
end

function Inventory:getItemCount(item, metadata)
    local playerData = lib.core.getPlayerData()
    if not playerData or not playerData._original.items then return 0 end

    for _, itemData in pairs(playerData._original.items) do
        if itemData and itemData.name == item then
            return itemData.amount or 0
        end
    end
    return 0
end

function Inventory:getItem(item, metadata, strict)
    local playerData = lib.core.getPlayerData()
    if not playerData or not playerData._original.items then return nil end

    for _, itemData in pairs(playerData._original.items) do
        if itemData and itemData.name == item then
            return itemData
        end
    end
    return nil
end

function Inventory:getSlots()
    local playerData = lib.core.getPlayerData()
    return playerData and playerData._original.maxweight or 120000
end

function Inventory:getWeight()
    local playerData = lib.core.getPlayerData()
    if not playerData or not playerData._original.items then return 0 end

    local weight = 0
    for _, item in pairs(playerData._original.items) do
        if item and item.amount then
            weight = weight + (item.weight * item.amount)
        end
    end
    return weight
end

function Inventory:isInventoryOpen()
    return IsNuiFocused()
end

function Inventory:useItem(data, cb)
    TriggerServerEvent('inventory:server:UseItem', data.name, data.amount)
    if cb then cb() end
end

function Inventory:canCarryItem(item, count, metadata)
    return true
end

function Inventory:canCarryWeight(weight)
    local currentWeight = self:getWeight()
    local maxWeight = self:getSlots()
    return (currentWeight + weight) <= maxWeight
end

return Inventory

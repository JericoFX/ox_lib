--[[
    TODO: usar clases en el cliente
]]

return {
    openInventory = function(type, data)
        if type == 'player' then
            TriggerServerEvent('inventory:server:OpenInventory', 'player')
        else
            TriggerServerEvent('inventory:server:OpenInventory', type, data)
        end
    end,

    closeInventory = function()
        TriggerEvent('inventory:client:CloseInventory')
    end,

    getItemCount = function(item, metadata)
        local playerData = lib.core.getPlayerData()
        if not playerData or not playerData._original.items then return 0 end

        for _, itemData in pairs(playerData._original.items) do
            if itemData and itemData.name == item then
                return itemData.amount or 0
            end
        end
        return 0
    end,

    getItem = function(item, metadata, strict)
        local playerData = lib.core.getPlayerData()
        if not playerData or not playerData._original.items then return nil end

        for _, itemData in pairs(playerData._original.items) do
            if itemData and itemData.name == item then
                return itemData
            end
        end
        return nil
    end,

    getSlots = function()
        local playerData = lib.core.getPlayerData()
        return playerData and playerData._original.maxweight or 120000
    end,

    getWeight = function()
        local playerData = lib.core.getPlayerData()
        if not playerData or not playerData._original.items then return 0 end

        local weight = 0
        for _, item in pairs(playerData._original.items) do
            if item and item.amount then
                weight = weight + (item.weight * item.amount)
            end
        end
        return weight
    end,

    isInventoryOpen = function()
        return IsNuiFocused()
    end,

    useItem = function(data, cb)
        TriggerServerEvent('inventory:server:UseItem', data.name, data.amount)
        if cb then cb() end
    end,

    canCarryItem = function(item, count, metadata)
        -- Simple check for QB
        return true
    end,

    canCarryWeight = function(weight)
        local currentWeight = lib.inventory.getWeight()
        local maxWeight = lib.inventory.getSlots()
        return (currentWeight + weight) <= maxWeight
    end
}

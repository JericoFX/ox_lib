--[[
    QB Inventory Server Functions
]]

return {
    addItem = function(source, item, count, metadata)
        local Player = lib.core.getPlayer(source)
        if not Player then return false end
        return Player._original.Functions.AddItem(item, count, false, metadata)
    end,

    removeItem = function(source, item, count, metadata, slot)
        local Player = lib.core.getPlayer(source)
        if not Player then return false end
        return Player._original.Functions.RemoveItem(item, count, slot)
    end,

    getItemCount = function(source, item, metadata)
        local Player = lib.core.getPlayer(source)
        if not Player then return 0 end

        local playerItem = Player._original.Functions.GetItemByName(item)
        return playerItem and playerItem.amount or 0
    end,

    getItem = function(source, item, metadata, strict)
        local Player = lib.core.getPlayer(source)
        if not Player then return nil end

        return Player._original.Functions.GetItemByName(item)
    end,

    getInventory = function(source)
        local Player = lib.core.getPlayer(source)
        if not Player then return nil end

        return Player._original.PlayerData.items
    end,

    getSlots = function(source)
        local Player = lib.core.getPlayer(source)
        if not Player then return 0 end

        return Player._original.PlayerData.maxweight or 120000
    end,

    getWeight = function(source)
        local Player = lib.core.getPlayer(source)
        if not Player then return 0 end

        local weight = 0
        if Player._original.PlayerData.items then
            for _, item in pairs(Player._original.PlayerData.items) do
                if item and item.amount then
                    weight = weight + (item.weight * item.amount)
                end
            end
        end
        return weight
    end,

    canCarryItem = function(source, item, count, metadata)
        local Player = lib.core.getPlayer(source)
        if not Player then return false end

        -- QB simple check - puede ser más complejo según configuración
        return true
    end,

    canCarryWeight = function(source, weight)
        local currentWeight = lib.inventory.getWeight(source)
        local maxWeight = lib.inventory.getSlots(source)
        return (currentWeight + weight) <= maxWeight
    end,

    clearInventory = function(source, keep)
        local Player = lib.core.getPlayer(source)
        if not Player then return false end

        Player._original.Functions.ClearInventory()
        return true
    end
}

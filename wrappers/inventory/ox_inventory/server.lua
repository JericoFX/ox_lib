--[[
    OX Inventory Server Functions
]]

return {
    addItem = function(source, item, count, metadata)
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    end,

    removeItem = function(source, item, count, metadata, slot)
        return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
    end,

    getItemCount = function(source, item, metadata)
        return exports.ox_inventory:GetItemCount(source, item, metadata)
    end,

    getItem = function(source, item, metadata, strict)
        return exports.ox_inventory:GetItem(source, item, metadata, strict)
    end,

    getInventory = function(source)
        return exports.ox_inventory:GetInventory(source)
    end,

    getSlots = function(source)
        return exports.ox_inventory:GetSlots(source)
    end,

    getWeight = function(source)
        return exports.ox_inventory:GetWeight(source)
    end,

    canCarryItem = function(source, item, count, metadata)
        return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
    end,

    canCarryWeight = function(source, weight)
        return exports.ox_inventory:CanCarryWeight(source, weight)
    end,

    setMaxWeight = function(source, weight)
        return exports.ox_inventory:SetMaxWeight(source, weight)
    end,

    confiscateInventory = function(source)
        return exports.ox_inventory:ConfiscateInventory(source)
    end,

    returnInventory = function(source)
        return exports.ox_inventory:ReturnInventory(source)
    end,

    clearInventory = function(source, keep)
        return exports.ox_inventory:ClearInventory(source, keep)
    end,

    createShop = function(data)
        return exports.ox_inventory:CreateShop(data)
    end,

    createStash = function(data)
        return exports.ox_inventory:CreateStash(data)
    end
}

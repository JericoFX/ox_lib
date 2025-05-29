--[[
    NO EXISTE SHARED SOLO CLIENTE, RECUERDA CAMBIARLO! (Me voy a olvidar)
]]

return {
    -- Server functions
    addItem = function(source, item, count, metadata)
        if lib.context == 'server' then
            return exports['qs-inventory']:AddItem(source, item, count, metadata)
        else
            TriggerServerEvent('qs-inventory:server:AddItem', item, count, metadata)
        end
    end,

    removeItem = function(source, item, count, metadata, slot)
        if lib.context == 'server' then
            return exports['qs-inventory']:RemoveItem(source, item, count, slot)
        else
            TriggerServerEvent('qs-inventory:server:RemoveItem', item, count, slot)
        end
    end,

    getItemCount = function(source, item, metadata)
        if lib.context == 'server' then
            return exports['qs-inventory']:GetItemCount(source, item)
        else
            return exports['qs-inventory']:GetItemCount(item)
        end
    end,

    getItem = function(source, item, metadata, strict)
        if lib.context == 'server' then
            return exports['qs-inventory']:GetItem(source, item)
        else
            return exports['qs-inventory']:GetItem(item)
        end
    end,

    -- Client functions
    openInventory = function(type, data)
        if lib.context == 'client' then
            exports['qs-inventory']:OpenInventory()
        end
    end,

    closeInventory = function()
        if lib.context == 'client' then
            exports['qs-inventory']:CloseInventory()
        end
    end,

    isInventoryOpen = function()
        if lib.context == 'client' then
            return exports['qs-inventory']:IsInventoryOpen()
        end
        return false
    end,

    getWeight = function(source)
        if lib.context == 'server' then
            return exports['qs-inventory']:GetWeight(source)
        else
            return exports['qs-inventory']:GetWeight()
        end
    end,

    getSlots = function(source)
        if lib.context == 'server' then
            return exports['qs-inventory']:GetSlots(source)
        else
            return exports['qs-inventory']:GetSlots()
        end
    end,

    canCarryItem = function(source, item, count, metadata)
        if lib.context == 'server' then
            return exports['qs-inventory']:CanCarryItem(source, item, count)
        else
            return exports['qs-inventory']:CanCarryItem(item, count)
        end
    end,

    canCarryWeight = function(source, weight)
        if lib.context == 'server' then
            return exports['qs-inventory']:CanCarryWeight(source, weight)
        else
            return exports['qs-inventory']:CanCarryWeight(weight)
        end
    end,

    useItem = function(data, cb)
        if lib.context == 'client' then
            TriggerServerEvent('qs-inventory:server:UseItem', data.name, data.amount)
            if cb then cb() end
        end
    end,

    clearInventory = function(source, keep)
        if lib.context == 'server' then
            return exports['qs-inventory']:ClearInventory(source)
        end
    end
}

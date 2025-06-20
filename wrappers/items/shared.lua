local Items = {}

-- Only meaningful on server side
if not IsDuplicityVersion() then
    -- Return stub that throws to avoid silent misuse from client scripts
    return setmetatable({}, {
        __index = function(_, k)
            return function()
                error(('lib.items.%s is server-side only'):format(k), 2)
            end
        end
    })
end

local inventorySystem = lib.inventory and lib.inventory.system or 'unknown'
local resourceName    = GetCurrentResourceName()

-------------------------------------------------------------------------------
-- 1. ITEM DEFINITION / REGISTRATION
-------------------------------------------------------------------------------
local pendingOx       = {}

---@param def table
function Items.define(def)
    if type(def) ~= 'table' or not def.name then return end

    if inventorySystem == 'qb-inventory' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if not QBCore or not QBCore.Shared then return end

        if not QBCore.Shared.Items[def.name] then
            QBCore.Shared.Items[def.name] = {
                name        = def.name,
                label       = def.label or def.name,
                weight      = def.weight or 0,
                unique      = def.unique or false,
                useable     = def.useable ~= false,
                description = def.description or '',
                image       = def.image or (def.name .. '.png'),
                type        = def.type or 'item',
                stack       = def.stack ~= false,
                combinable  = def.combinable,
            }
            print(('^2[ITEM WRAPPER]^0 Registered %s in QBCore.Shared.Items'):format(def.name))
        end
    elseif inventorySystem == 'ox_inventory' then
        pendingOx[#pendingOx + 1] = def
        print(('^3[ITEM WRAPPER]^0 Add to ox_inventory/data/items.lua: [' .. def.name .. '] = { label = "' .. (def.label or def.name) .. '", weight = ' .. (def.weight or 0) .. ', stack = ' .. tostring(def.stack ~= false) .. ', close = ' .. tostring(def.closeOnUse ~= false) .. ' }'))
    end
end

-------------------------------------------------------------------------------
-- 2. USABLE CALLBACK REGISTRATION
-------------------------------------------------------------------------------

local function wrapCallback(cb, system)
    if system == 'qb-inventory' then
        -- keep original signature: (source, item, ...)
        return function(source, item, ...)
            cb(source, item, ...)
        end
    else -- ox_inventory passes (event, item, inventory, slot, data)
        return function(event, item, inventory, slot, data)
            cb(event, item, inventory, slot, data)
        end
    end
end

---@param itemName string
---@param callback function
function Items.registerUse(itemName, callback)
    if not itemName or type(callback) ~= 'function' then return end

    if inventorySystem == 'qb-inventory' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
            QBCore.Functions.CreateUseableItem(itemName, wrapCallback(callback, 'qb-inventory'))
        end
    elseif inventorySystem == 'ox_inventory' then
        local exportName = itemName -- simple: export matches item name
        exports(exportName, wrapCallback(callback, 'ox_inventory'))

        print(('^2[ITEM WRAPPER]^0 Remember to set  server.export = "%s.%s"  in the item definition for ox_inventory'):format(resourceName, exportName))
    else
        print('^1[ITEM WRAPPER]^0 Cannot register usable item – unknown inventory system')
    end
end

-------------------------------------------------------------------------------
-- expose via lib
-------------------------------------------------------------------------------
lib.items = Items

return Items

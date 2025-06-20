--[[
    Example Inventory Wrapper – Server side

    1. Copia esta carpeta y renómbrala con el nombre de tu sistema.
    2. Sustituye 'my_inventory' por el nombre real del recurso.
    3. Reemplaza las llamadas de exports.* por la API de tu sistema.
    4. Asegúrate de registrar al menos getItem / addItem / removeItem en Normalizer
       y devolver la tabla pública con el resto de helpers que quieras exponer.
]]

if GetResourceState('my_inventory') ~= 'started' then
    return
end

local Normalizer = require 'wrappers.core.normalizer'

-- Ejemplos de helpers mínimos ------------------------------------------------
local function getItem(source, item, metadata, strict)
    return exports.my_inventory:GetItem(source, item, metadata, strict)
end

local function addItem(source, item, count, metadata)
    return exports.my_inventory:AddItem(source, item, count, metadata)
end

local function removeItem(source, item, count, metadata, slot)
    return exports.my_inventory:RemoveItem(source, item, count, metadata, slot)
end

-- Registrar API mínima -------------------------------------------------------
Normalizer.inventory.getItem      = getItem
Normalizer.inventory.addItem      = addItem
Normalizer.inventory.removeItem   = removeItem
Normalizer.capabilities.inventory = true

-- Tabla pública --------------------------------------------------------------
return {
    getItem    = getItem,
    addItem    = addItem,
    removeItem = removeItem,
}

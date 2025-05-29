--[[
    OX Inventory Client Functions
]]

-- Crear clase local, NO asignar a lib.inventory directamente
local Inventory = lib.class('Inventory')

-- Constructor de la clase
function Inventory:constructor()
    self.system = 'ox_inventory'
    self.exports = exports.ox_inventory
end

-- Métodos de la clase (misma funcionalidad, sintaxis de clase)
function Inventory:openInventory(type, data)
    return self.exports:openInventory(type, data)
end

function Inventory:closeInventory()
    return self.exports:closeInventory()
end

function Inventory:getItemCount(item, metadata)
    return self.exports:GetItemCount(item, metadata)
end

function Inventory:getItem(item, metadata, strict)
    return self.exports:GetItem(item, metadata, strict)
end

function Inventory:getSlots()
    return self.exports:GetSlots()
end

function Inventory:getWeight()
    return self.exports:GetWeight()
end

function Inventory:isInventoryOpen()
    return self.exports:isInventoryOpen()
end

function Inventory:useItem(data, cb)
    return self.exports:useItem(data, cb)
end

function Inventory:displayMetadata(metadata)
    return self.exports:displayMetadata(metadata)
end

function Inventory:setCurrentWeapon(weapon)
    return self.exports:getCurrentWeapon(weapon)
end

function Inventory:weaponWheel()
    return self.exports:weaponWheel()
end

function Inventory:canCarryItem(item, count, metadata)
    return self.exports:CanCarryItem(item, count, metadata)
end

function Inventory:canCarryWeight(weight)
    return self.exports:CanCarryWeight(weight)
end

-- Método adicional para debugging
function Inventory:getSystem()
    return self.system
end

-- Retornar la clase para que shared.lua la asigne a lib.inventory
return Inventory

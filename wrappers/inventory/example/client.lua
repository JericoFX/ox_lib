--[[
    Example Inventory Wrapper – Client side

    Este archivo es opcional y muestra cómo exponer utilidades que solo
    existen en cliente (p. ej. abrir/cerrar inventario).
    Copia y ajusta a tu sistema.
]]

if GetResourceState('my_inventory') ~= 'started' then
    return
end

local function openInventory()
    exports.my_inventory:OpenInventory()
end

local function closeInventory()
    exports.my_inventory:CloseInventory()
end

local function isInventoryOpen()
    return exports.my_inventory:IsInventoryOpen()
end

return {
    openInventory   = openInventory,
    closeInventory  = closeInventory,
    isInventoryOpen = isInventoryOpen,
}

-- examples/shops_usage.lua
-- Ejemplos de uso de las nuevas funciones de shops en ox_lib

-- Básicamente, usar lib.shops para acceder a todas las funciones
local shops = lib.shops

-- ===============================================
-- CREAR SHOPS BÁSICOS
-- ===============================================

-- Crear una tienda básica
local basicShopData = {
    name = "grocery_store_1",
    label = "Tienda de Abarrotes Central",
    coords = vector3(24.47, -1346.62, 29.5),
    slots = 20,
    maxweight = 50000,
    items = {
        { name = "bread", amount = 50,  price = 2 },
        { name = "water", amount = 100, price = 1 },
        { name = "milk",  amount = 30,  price = 3 }
    }
}

shops.createShop(basicShopData)

-- Crear tienda usando función rápida
shops.createQuickShop(
    "weapon_shop_1",
    "Ammunation Downtown",
    vector3(21.70, -1107.41, 29.8),
    {
        { name = "weapon_pistol", amount = 10,  price = 5000 },
        { name = "ammo_pistol",   amount = 500, price = 10 },
        { name = "weapon_knife",  amount = 20,  price = 100 }
    }
)

-- ===============================================
-- GESTIÓN DE SHOPS
-- ===============================================

-- Abrir shop para un jugador
shops.openShop("grocery_store_1", GetPlayerServerId(PlayerId()))

-- Verificar si shop existe
if shops.shopExists("grocery_store_1") then
    print("La tienda existe")
end

-- Obtener información del shop
local shopInfo = shops.getShop("grocery_store_1")
if shopInfo then
    print("Shop: " .. shopInfo.label)
    print("Ubicación: " .. tostring(shopInfo.coords))
end

-- Obtener todos los shops
local allShops = shops.getAllShops()
for shopName, shopData in pairs(allShops) do
    print("Shop disponible: " .. shopName .. " - " .. shopData.label)
end

-- ===============================================
-- GESTIÓN DE ITEMS EN SHOPS
-- ===============================================

-- Agregar item a shop existente
shops.addShopItem("grocery_store_1", {
    name = "sandwich",
    amount = 25,
    price = 5,
    metadata = { quality = 100 }
})

-- Actualizar item existente
shops.updateShopItem("grocery_store_1", "bread", {
    amount = 75,
    price = 2.5
})

-- Remover item del shop
shops.removeShopItem("grocery_store_1", "milk", 10)

-- Obtener items del shop
local shopItems = shops.getShopItems("grocery_store_1")
for _, item in pairs(shopItems) do
    print("Item: " .. item.name .. " - Cantidad: " .. item.amount .. " - Precio: $" .. item.price)
end

-- ===============================================
-- COMPRAS EN SHOPS
-- ===============================================

-- Comprar item del shop
shops.buyItem("grocery_store_1", "bread", 2)

-- ===============================================
-- FUNCIONES AVANZADAS
-- ===============================================

-- Poblar shop con muchos items
local farmacyItems = {
    { name = "bandage",     amount = 100, price = 15 },
    { name = "painkillers", amount = 50,  price = 25 },
    { name = "firstaid",    amount = 20,  price = 50 },
    { name = "medkit",      amount = 10,  price = 100 }
}

shops.createQuickShop(
    "pharmacy_1",
    "Farmacia Central",
    vector3(313.47, -1077.96, 29.48),
    farmacyItems
)

-- Limpiar todos los items de un shop
shops.clearShop("pharmacy_1")

-- Volver a poblar con items nuevos
shops.populateShop("pharmacy_1", {
    { name = "vitamins",     amount = 200, price = 5 },
    { name = "energy_drink", amount = 150, price = 8 }
})

-- Eliminar shop completamente
shops.deleteShop("pharmacy_1")

-- ===============================================
-- EJEMPLOS ESPECÍFICOS POR SISTEMA
-- ===============================================

-- Para servidores con ox_inventory
if GetResourceState('ox_inventory') == 'started' then
    print("Usando sistema ox_inventory")

    -- Crear shop con metadata complejo
    shops.createShop({
        name = "electronics_store",
        label = "Tienda de Electrónicos",
        coords = vector3(-656.67, -854.41, 24.49),
        slots = 30,
        maxweight = 100000,
        items = {
            {
                name = "phone",
                amount = 20,
                price = 500,
                metadata = {
                    quality = 100,
                    brand = "iFruit",
                    color = "black"
                }
            }
        }
    })
end

-- Para servidores con qb-inventory
if GetResourceState('qb-inventory') == 'started' then
    print("Usando sistema qb-inventory")

    -- Crear shop con formato qb-inventory
    shops.createShop({
        name = "clothing_store",
        label = "Tienda de Ropa",
        coords = vector3(72.33, -1399.09, 29.38),
        slots = 25,
        items = {
            { name = "tshirt", amount = 50, price = 25 },
            { name = "jeans",  amount = 30, price = 40 },
            { name = "shoes",  amount = 25, price = 60 }
        }
    })
end

-- ===============================================
-- FUNCIÓN DE UTILIDAD COMPLETA
-- ===============================================

-- Función para crear una cadena de tiendas
local function createStoreChain(baseName, label, locations, items)
    for i, location in ipairs(locations) do
        local shopName = baseName .. "_" .. i
        local success = shops.createQuickShop(shopName, label .. " #" .. i, location, items)

        if success then
            print("Tienda creada: " .. shopName .. " en " .. tostring(location))
        else
            print("Error creando tienda: " .. shopName)
        end
    end
end

-- Crear cadena de supermercados
local supermarketLocations = {
    vector3(24.47, -1346.62, 29.5),
    vector3(-47.02, -1757.25, 29.42),
    vector3(1164.81, -323.04, 69.21)
}

local supermarketItems = {
    { name = "bread",  amount = 100, price = 2 },
    { name = "water",  amount = 200, price = 1 },
    { name = "milk",   amount = 50,  price = 3 },
    { name = "eggs",   amount = 75,  price = 4 },
    { name = "cheese", amount = 40,  price = 6 }
}

createStoreChain("supermarket", "Supermercado", supermarketLocations, supermarketItems)

print("Sistema de shops ox_lib inicializado completamente!")

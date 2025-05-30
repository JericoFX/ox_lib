-- Muy repetitivo este codigo, tengo que encontrar la forma de cargar un config o algo
local function detectSystem()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs-inventory'
    else
        return nil
    end
end

local function loadSystemFunctions(system)
    if not system then return {} end

    local context = lib.context
    local systemPath = ('wrappers/inventory/%s/%s.lua'):format(system, context)
    local chunk = LoadResourceFile('ox_lib', systemPath)

    if not chunk then
        systemPath = ('wrappers/inventory/%s/shared.lua'):format(system)
        chunk = LoadResourceFile('ox_lib', systemPath)
    end

    if chunk then
        local fn, err = load(chunk, ('@@ox_lib/%s'):format(systemPath))
        if fn and not err then
            return fn() or {}
        end
    end

    return {}
end

-- Mapeo de recursos a sistemas
local inventoryMapping = {
    ['ox_inventory'] = 'ox_inventory',
    ['qb-inventory'] = 'qb-inventory',
    ['qs-inventory'] = 'qs-inventory'
}

-- Inicializar con sistema unknown
lib.inventory = {
    system = 'unknown'
}

-- Escuchar cuando se inician los inventarios
AddEventHandler('onResourceStart', function(resourceName)
    local system = inventoryMapping[resourceName]

    if system then
        print('^2========================================')
        print('^2[INVENTORY INICIADO]^0')
        print('^2Recurso: ^5' .. resourceName)
        print('^2Inventory: ^5' .. system)
        print('^2========================================^0')

        local inventoryInstance = loadSystemFunctions(system)
        inventoryInstance.system = system

        lib.inventory = inventoryInstance
    end
end)

return lib.inventory

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

-- Singleton instance
local inventoryInstance
local system = detectSystem()

if system then
    inventoryInstance = loadSystemFunctions(system)
    inventoryInstance.system = system
else
    inventoryInstance = {
        system = 'unknown'
    }
end

lib.inventory = inventoryInstance

return lib.inventory

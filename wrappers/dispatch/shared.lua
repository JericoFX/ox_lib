local function detectSystem()
    if GetResourceState('cd_dispatch') == 'started' then
        return 'cd_dispatch'
    elseif GetResourceState('ps-dispatch') == 'started' then
        return 'ps-dispatch'
    elseif GetResourceState('qs-dispatch') == 'started' then
        return 'qs-dispatch'
    elseif GetResourceState('origen_police') == 'started' then
        return 'origen_police'
    else
        return nil
    end
end

local function loadSystemFunctions(system)
    if not system then return {} end

    local context = lib.context
    local systemPath = ('wrappers/dispatch/%s/%s.lua'):format(system, context)
    local chunk = LoadResourceFile('ox_lib', systemPath)

    if not chunk then
        systemPath = ('wrappers/dispatch/%s/shared.lua'):format(system)
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
local dispatchMapping = {
    ['cd_dispatch'] = 'cd_dispatch',
    ['ps-dispatch'] = 'ps-dispatch',
    ['qs-dispatch'] = 'qs-dispatch',
    ['origen_police'] = 'origen_police'
}

-- Inicializar con sistema unknown
lib.dispatch = {
    system = 'unknown'
}

-- Escuchar cuando se inician los dispatches
AddEventHandler('onResourceStart', function(resourceName)
    local system = dispatchMapping[resourceName]

    if system then
        print('^2========================================')
        print('^2[DISPATCH INICIADO]^0')
        print('^2Recurso: ^5' .. resourceName)
        print('^2Dispatch: ^5' .. system)
        print('^2========================================^0')

        local dispatchInstance = loadSystemFunctions(system)
        dispatchInstance.system = system

        lib.dispatch = dispatchInstance
    end
end)

return lib.dispatch

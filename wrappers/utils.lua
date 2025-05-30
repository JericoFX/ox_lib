-- Utilidades para wrappers

-- Cargar configuración
local function loadConfig()
    local configPath = 'wrappers/config.lua'
    local chunk = LoadResourceFile('ox_lib', configPath)

    if chunk then
        local fn, err = load(chunk, ('@@ox_lib/%s'):format(configPath))
        if fn and not err then
            return fn()
        else
            print('^1[WRAPPER UTILS] Error cargando config: ' .. tostring(err))
        end
    else
        print('^1[WRAPPER UTILS] No se encontró wrappers/config.lua')
    end

    return {}
end

-- Función genérica para crear wrappers
local function createWrapper(wrapperType, libKey)
    local config = loadConfig()
    local mapping = config[wrapperType] or {}

    local function loadSystemFunctions(system)
        if not system then return {} end

        local context = lib.context
        local systemPath = ('wrappers/%s/%s/%s.lua'):format(wrapperType, system, context)
        local chunk = LoadResourceFile('ox_lib', systemPath)

        if not chunk then
            systemPath = ('wrappers/%s/%s/shared.lua'):format(wrapperType, system)
            chunk = LoadResourceFile('ox_lib', systemPath)
        end

        if chunk then
            local fn, err = load(chunk, ('@@ox_lib/%s'):format(systemPath))
            if fn and not err then
                print('^2[' .. wrapperType:upper() .. ' LOADER] Cargado: ^5' .. systemPath)
                return fn() or {}
            else
                print('^1[' .. wrapperType:upper() .. ' LOADER] Error: ^5' .. systemPath .. ' -> ' .. tostring(err))
            end
        end

        return {}
    end

    -- Inicializar con sistema unknown
    lib[libKey] = {
        [wrapperType == 'core' and 'framework' or 'system'] = 'unknown'
    }

    -- Escuchar cuando se inician los recursos
    AddEventHandler('onResourceStart', function(resourceName)
        local system = mapping[resourceName]

        if system then
            print('^2[' .. wrapperType:upper() .. ' INICIADO] ' .. resourceName .. ' -> ' .. system)

            local instance = loadSystemFunctions(system)
            if wrapperType == 'core' then
                instance.framework = system
                instance.resourceName = resourceName
            else
                instance.system = system
            end

            lib[libKey] = instance

            print('^2[' .. wrapperType:upper() .. '] lib.' .. libKey .. ' actualizado exitosamente^0')
        end
    end)

    return lib[libKey]
end

return {
    loadConfig = loadConfig,
    createWrapper = createWrapper
}

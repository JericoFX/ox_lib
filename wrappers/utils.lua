local function createWrapper(wrapperType, libKey) -- FUCKING FINALLY this will load every existent resource and the once that start later, fuck... sorry for the spanish comments, it helps me a lot
    local config = require "wrappers.config"
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

    local function detectAndLoadSystem()
        for resourceName, system in pairs(mapping) do
            if GetResourceState(resourceName) == 'started' then
                print('^2[' .. wrapperType:upper() .. ' DETECTOR] Encontrado: ' .. resourceName .. ' -> ' .. system)

                local instance = loadSystemFunctions(system)
                if wrapperType == 'core' then
                    instance.framework = system
                    instance.resourceName = resourceName
                else
                    instance.system = system
                end

                lib[libKey] = instance
                print('^2[' .. wrapperType:upper() .. '] lib.' .. libKey .. ' configurado exitosamente^0')
                return true
            end
        end
        return false
    end

    if not detectAndLoadSystem() then
        lib[libKey] = {
            [wrapperType == 'core' and 'framework' or 'system'] = 'unknown'
        }
        print('^3[' .. wrapperType:upper() .. '] No se detectó ningún sistema, usando unknown^0')
    end

    AddEventHandler('onResourceStart', function(resourceName)
        local system = mapping[resourceName]

        if system then
            local currentSystem = lib[libKey] and lib[libKey][wrapperType == 'core' and 'framework' or 'system']

            if currentSystem == 'unknown' then
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
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        local system = mapping[resourceName]

        if system and lib[libKey] then
            local currentResourceName = lib[libKey].resourceName
            local currentSystem = lib[libKey][wrapperType == 'core' and 'framework' or 'system']

            if currentResourceName == resourceName or currentSystem == system then
                print('^1[' .. wrapperType:upper() .. ' DETENIDO] ' .. resourceName .. ' -> ' .. system)

                if not detectAndLoadSystem() then
                    lib[libKey] = {
                        [wrapperType == 'core' and 'framework' or 'system'] = 'unknown'
                    }
                    print('^3[' .. wrapperType:upper() .. '] Volviendo a unknown, no hay sistemas disponibles^0')
                end
            end
        end
    end)

    return lib[libKey]
end

return {
    loadConfig = require "wrappers.config",
    createWrapper = createWrapper
}

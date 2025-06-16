local LoadResourceFile = LoadResourceFile
local GetResourceState = GetResourceState
local AddEventHandler = AddEventHandler
local globalPrint = print

local function createWrapper(wrapperType, libKey) -- FUCKING FINALLY this will load every existent resource and the once that start later, fuck... sorry for the spanish comments, it helps me a lot
    local config = require "wrappers.config"
    local mapping = config[wrapperType] or {}

    -- Evitar spam de consolas: solo se imprimen los logs la primera vez que
    -- se carga un tipo de wrapper en el cliente/servidor. Para ello usamos
    -- un KVP (almacenamiento local) como flag. KVP está disponible tanto en
    -- client como server mediante las funciones *Kvp*; si no existen, se
    -- cae de forma segura y simplemente mantiene los prints.

    local GetResourceKvpString = GetResourceKvpString -- puede ser nil en server antiguo
    local SetResourceKvpNoSync = SetResourceKvpNoSync

    local kvpKey = ("ox_lib_wrapper_%s_printed"):format(wrapperType)
    local shouldPrint = true

    if GetResourceKvpString then
        shouldPrint = not GetResourceKvpString(kvpKey)
    end

    local function debugPrint(...)
        if shouldPrint then
            globalPrint(...)
        end
    end

    -- Prefijo para todos los mensajes de salida de este wrapper
    local prefix = ('[%s '):format(wrapperType:upper())

    -- Local print que inyecta el prefijo
    local function printLn(level, msg)
        debugPrint(('^%s%s^0'):format(level, prefix .. msg))
    end

    local function loadSystemFunctions(system)
        if not system then return nil end

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
                printLn('2', ('LOADER] Cargado: ^5%s'):format(systemPath))
                return fn()
            else
                printLn('1', ('LOADER] Error: ^5%s -> %s'):format(systemPath, tostring(err)))
            end
        end

        return nil
    end

    local function detectAndLoadSystem()
        for resourceName, system in pairs(mapping) do
            if GetResourceState(resourceName) == 'started' then
                printLn('2', ('DETECTOR] Encontrado: %s -> %s'):format(resourceName, system))

                local instance = loadSystemFunctions(system) or {}
                if wrapperType == 'core' then
                    instance.framework = system
                    instance.resourceName = resourceName
                else
                    instance.system = system
                end

                lib[libKey] = instance
                printLn('2', ('] lib.%s configurado exitosamente'):format(libKey))
                return true
            end
        end
        return false
    end

    if not detectAndLoadSystem() then
        lib[libKey] = { [wrapperType == 'core' and 'framework' or 'system'] = 'unknown' }
        printLn('3', '] No se detectó ningún sistema, usando unknown')
    end

    local function onResourceStart(resourceName)
        local system = mapping[resourceName]

        if system then
            local currentSystem = lib[libKey] and lib[libKey][wrapperType == 'core' and 'framework' or 'system']

            if currentSystem == 'unknown' then
                printLn('2', ('INICIADO] %s -> %s'):format(resourceName, system))

                local instance = loadSystemFunctions(system) or {}
                if wrapperType == 'core' then
                    instance.framework = system
                    instance.resourceName = resourceName
                else
                    instance.system = system
                end

                lib[libKey] = instance
                printLn('2', ('] lib.%s actualizado exitosamente'):format(libKey))
            end
        end
    end

    local function onResourceStop(resourceName)
        local system = mapping[resourceName]

        if system and lib[libKey] then
            local currentResourceName = lib[libKey].resourceName
            local currentSystem = lib[libKey][wrapperType == 'core' and 'framework' or 'system']

            if currentResourceName == resourceName or currentSystem == system then
                printLn('1', ('DETENIDO] %s -> %s'):format(resourceName, system))

                if not detectAndLoadSystem() then
                    lib[libKey] = { [wrapperType == 'core' and 'framework' or 'system'] = 'unknown' }
                    printLn('3', '] Volviendo a unknown, no hay sistemas disponibles')
                end
            end
        end
    end

    AddEventHandler('onResourceStart', onResourceStart)
    AddEventHandler('onResourceStop', onResourceStop)

    -- Una vez finalizada la inicialización, marcamos que ya se imprimió para
    -- este tipo de wrapper y evitamos futuros duplicados desde otros
    -- resources.
    if shouldPrint and SetResourceKvpNoSync then
        SetResourceKvpNoSync(kvpKey, '1')
    end

    return lib[libKey]
end

return {
    loadConfig = require "wrappers.config",
    createWrapper = createWrapper
}

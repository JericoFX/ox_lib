local function detectFramework()
    -- Lista de frameworks a verificar
    local frameworks = {
        { name = 'esx_extended', folder = 'esx_extended' },
        { name = 'es_extended',  folder = 'esx_extended' },
        { name = 'qb-core',      folder = 'qb-core' },
        { name = 'qbx_core',     folder = 'qb-core' },
        { name = 'ox_core',      folder = 'ox_core' }
    }

    for _, framework in ipairs(frameworks) do
        local state = GetResourceState(framework.name)
        if state == 'started' then
            return framework.folder, framework.name
        end
    end

    return nil, nil
end

local function loadFrameworkFunctions(framework)
    if not framework then return {} end
    local context = lib.context
    local frameworkPath = ('wrappers/core/%s/%s.lua'):format(framework, context)
    local chunk = LoadResourceFile('ox_lib', frameworkPath)

    if not chunk then
        frameworkPath = ('wrappers/core/%s/shared.lua'):format(framework)
        chunk = LoadResourceFile('ox_lib', frameworkPath)
    end

    if chunk then
        local fn, err = load(chunk, ('@@ox_lib/%s'):format(frameworkPath))
        if fn and not err then
            print('^2[FRAMEWORK LOADER] Cargado exitosamente: ^5' .. frameworkPath)
            return fn() or {}
        else
            print('^1[FRAMEWORK LOADER] Error al cargar: ^5' .. frameworkPath .. ' Error: ' .. tostring(err))
        end
    end

    return {}
end

-- Mapeo de recursos a frameworks
local frameworkMapping = {
    ['esx_extended'] = 'esx_extended',
    ['es_extended'] = 'esx_extended',
    ['qb-core'] = 'qb-core',
    ['qbx_core'] = 'qb-core',
    ['ox_core'] = 'ox_core'
}

-- Inicializar con framework unknown
lib.core = {
    framework = 'unknown'
}

-- Escuchar cuando se inician los frameworks
AddEventHandler('onResourceStart', function(resourceName)
    local framework = frameworkMapping[resourceName]

    if framework then
        print('^2========================================')
        print('^2[FRAMEWORK INICIADO]^0')
        print('^2Recurso: ^5' .. resourceName)
        print('^2Framework: ^5' .. framework)
        print('^2========================================^0')

        local coreInstance = loadFrameworkFunctions(framework)
        coreInstance.framework = framework
        coreInstance.resourceName = resourceName

        lib.core = coreInstance
    end
end)

return lib.core

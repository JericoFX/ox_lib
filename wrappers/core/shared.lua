local function detectFramework()
    if GetResourceState('es_extended') == 'started' then
        return 'esx_extended'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb-core'
    elseif GetResourceState('qbx_core') == 'started' then
        return 'qbx_core'
    else
        return nil
    end
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
            return fn() or {}
        end
    end

    return {}
end

-- Singleton instance
local coreInstance
local framework = detectFramework()

if framework then
    coreInstance = loadFrameworkFunctions(framework)
    coreInstance.framework = framework
else
    coreInstance = {
        framework = 'unknown'
    }
end

lib.core = coreInstance

return lib.core

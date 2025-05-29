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

-- Singleton instance
local dispatchInstance
local system = detectSystem()

if system then
    dispatchInstance = loadSystemFunctions(system)
    dispatchInstance.system = system
else
    dispatchInstance = {
        system = 'unknown'
    }
end

lib.dispatch = dispatchInstance

return lib.dispatch

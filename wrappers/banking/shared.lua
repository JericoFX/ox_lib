local function detectSystem()
    if GetResourceState('qb-banking') == 'started' then
        return 'qb-banking'
    elseif GetResourceState('okokBanking') == 'started' then
        return 'okokBanking'
    elseif GetResourceState('Renewed-Banking') == 'started' then
        return 'Renewed-Banking'
    elseif GetResourceState('pickle_banking') == 'started' then
        return 'pickle_banking'
    else
        return nil
    end
end

local function loadSystemFunctions(system)
    if not system then return {} end

    local context = lib.context
    local systemPath = ('wrappers/banking/%s/%s.lua'):format(system, context)
    local chunk = LoadResourceFile('ox_lib', systemPath)

    if not chunk then
        systemPath = ('wrappers/banking/%s/shared.lua'):format(system)
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
local bankingInstance
local system = detectSystem()

if system then
    bankingInstance = loadSystemFunctions(system)
    bankingInstance.system = system
else
    bankingInstance = {
        system = 'unknown'
    }
end

lib.banking = bankingInstance

return lib.banking

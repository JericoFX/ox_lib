-- Modulo de telefono en serio?
local function detectSystem()
    if GetResourceState('qb-phone') == 'started' then
        return 'qb-phone'
    elseif GetResourceState('qs-smartphone') == 'started' then
        return 'qs-smartphone'
    elseif GetResourceState('lb-phone') == 'started' then
        return 'lb-phone'
    elseif GetResourceState('renewed-phone') == 'started' then
        return 'renewed-phone'
    else
        return nil
    end
end

local function loadSystemFunctions(system)
    if not system then return {} end

    local context = lib.context
    local systemPath = ('wrappers/phone/%s/%s.lua'):format(system, context)
    local chunk = LoadResourceFile('ox_lib', systemPath)

    if not chunk then
        systemPath = ('wrappers/phone/%s/shared.lua'):format(system)
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
local phoneInstance
local system = detectSystem()

if system then
    phoneInstance = loadSystemFunctions(system)
    phoneInstance.system = system
else
    phoneInstance = {
        system = 'unknown'
    }
end

lib.phone = phoneInstance

return lib.phone

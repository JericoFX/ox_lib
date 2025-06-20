-- normalizer.lua - centralised framework-agnostic core

--- Internal helpers ----------------------------------------------------------

local function _dig(src, path)
    for key in string.gmatch(path, '[^%.]+') do
        src = src and src[key]
    end
    return src
end

local function _pick(data, selector)
    if not selector then return nil end
    local t = type(selector)
    if t == 'function' then
        return selector(data)
    elseif t == 'string' then
        return _dig(data, selector)
    end
    return selector
end

--- Cache object --------------------------------------------------------------

---@class Normalizer_Cache
local Cache = {}
local _store = {}

---@generic T
---@param key string
---@param fetch fun():T
---@return T
function Cache:get(key, fetch)
    local value = _store[key]
    if value ~= nil then
        _store[key] = nil -- invalidate immediately after the first read
        return value
    end
    return fetch()
end

---@param key string
---@param value any
function Cache:set(key, value)
    _store[key] = value
end

--- Stub generator ------------------------------------------------------------

local function _stub(area, fn)
    return function()
        error(('Normalizer.%s.%s not implemented'):format(area, fn), 2)
    end
end

--- Inventory interface -------------------------------------------------------

---@class Normalizer_Inventory
---@field getItem fun(source:number, item:string, metadata?:table, strict?:boolean):table|nil
---@field addItem fun(source:number, item:string, count:number, metadata?:table):boolean
---@field removeItem fun(source:number, item:string, count:number, metadata?:table, slot?:number):boolean

---@class Normalizer_Dispatch
---@field sendAlert fun(data:table)
---@field sendPoliceAlert fun(data:table)
---@field sendEMSAlert fun(data:table)
---@field sendFireAlert fun(data:table)
---@field sendMechanicAlert fun(data:table)
---@field sendCustomAlert fun(data:table)

---@class Normalizer_Fuel
---@field getFuel fun(vehicle:any):number
---@field setFuel fun(vehicle:any, fuel:number):boolean
---@field addFuel fun(vehicle:any, amount:number):boolean

---@class Normalizer_Voice
---@field setPlayerRadio fun(frequency:number)
---@field setPlayerPhone fun(callId:number)
---@field setProximityRange fun(range:number)
---@field mutePlayer fun(player:number, muted:boolean)

--- Core object ---------------------------------------------------------------

---@class Normalizer
---@field cache Normalizer_Cache
---@field capabilities table<string, boolean>
---@field inventory Normalizer_Inventory
---@field dispatch Normalizer_Dispatch
---@field fuel Normalizer_Fuel
---@field voice Normalizer_Voice
local M = {
    cache        = Cache,
    capabilities = {
        inventory = false,
        dispatch  = false,
        fuel      = false,
        garage    = false,
        housing   = false,
        phone     = false,
        targeting = false,
        voice     = false
    },
    inventory    = {
        getItem    = _stub('inventory', 'getItem'),
        addItem    = _stub('inventory', 'addItem'),
        removeItem = _stub('inventory', 'removeItem'),
    },
    dispatch     = {
        sendAlert         = _stub('dispatch', 'sendAlert'),
        sendPoliceAlert   = _stub('dispatch', 'sendPoliceAlert'),
        sendEMSAlert      = _stub('dispatch', 'sendEMSAlert'),
        sendFireAlert     = _stub('dispatch', 'sendFireAlert'),
        sendMechanicAlert = _stub('dispatch', 'sendMechanicAlert'),
        sendCustomAlert   = _stub('dispatch', 'sendCustomAlert'),
    },
    fuel         = {
        getFuel = _stub('fuel', 'getFuel'),
        setFuel = _stub('fuel', 'setFuel'),
        addFuel = _stub('fuel', 'addFuel'),
    },
    voice        = {
        setPlayerRadio    = _stub('voice', 'setPlayerRadio'),
        setPlayerPhone    = _stub('voice', 'setPlayerPhone'),
        setProximityRange = _stub('voice', 'setProximityRange'),
        mutePlayer        = _stub('voice', 'mutePlayer'),
    },
    garage       = {},
    housing      = {},
    phone        = {},
    targeting    = {
        addEntity    = _stub('targeting', 'addEntity'),
        removeEntity = _stub('targeting', 'removeEntity'),
        addZone      = _stub('targeting', 'addZone'),
        removeZone   = _stub('targeting', 'removeZone'),
    },
}

--- Player data normalisation -------------------------------------------------

---Normalises a raw framework player object into a common structure.
---@param data table
---@param map table<string, any>
---@param post fun(raw:table, normalised:table)? -- optional post-processor
---@return table|nil
function M.player(data, map, post)
    if not data then return nil end

    local n = {
        id         = _pick(data, map.id),
        identifier = _pick(data, map.identifier) or _pick(data, map.id),
        name       = _pick(data, map.name) or 'Unknown',

        job        = _pick(data, map.job) or {},
        gang       = _pick(data, map.gang) or { name = 'none', label = 'None', grade = 0 },
        money      = _pick(data, map.money) or {},
        metadata   = _pick(data, map.metadata) or {},

        charinfo   = _pick(data, map.charinfo),

        _original  = data
    }

    if post then post(data, n) end
    return n
end

-- Add __call metamethod for backward compatibility
setmetatable(M, {
    __call = function(_, ...)
        return M.player(...)
    end
})

return M

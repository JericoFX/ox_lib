local function dig(src, path)
    for key in string.gmatch(path, '[^%.]+') do
        src = src and src[key]
    end
    return src
end

local function pick(data, selector)
    if not selector then return nil end
    local t = type(selector)
    if t == 'function' then
        return selector(data)
    elseif t == 'string' then
        return dig(data, selector)
    end
    return selector
end

---@param data table                       -- Raw playerData from framework
---@param map table                        -- Mapping table
---@param post fun(raw:table,n:table)?     -- Optional post-processor for extra tweaks
---@return table|nil                       -- Normalised playerData
return function(data, map, post)
    if not data then return nil end

    local n = {
        -- identifiers
        id         = pick(data, map.id),
        identifier = pick(data, map.identifier) or pick(data, map.id),
        name       = pick(data, map.name) or 'Unknown',

        -- structured blocks
        job      = pick(data, map.job)      or {},
        gang     = pick(data, map.gang)     or { name = 'none', label = 'None', grade = 0 },
        money    = pick(data, map.money)    or {},
        metadata = pick(data, map.metadata) or {},

        charinfo = pick(data, map.charinfo),

        _original = data
    }

    if post then post(data, n) end
    return n
end 
local vec3 = vec3 or vector3 -- fallback if vec3 is not globally available

---@class PolyzoneWrapper
local PolyzoneWrapper = {}

local createdZones = {}

-- Helper to calculate height (thickness) for box zones
local function getHeight(minZ, maxZ)
    if minZ and maxZ then
        return (maxZ - minZ) / 2
    end
    return 2.0 -- sensible default
end

---Create a BoxZone equivalent using ox_lib
---@param name string
---@param center vector3
---@param length number
---@param width number
---@param opts table | nil
---@return CZone
function PolyzoneWrapper:AddBoxZone(name, center, length, width, opts)
    opts               = opts or {}

    -- ox_lib expects half sizes, PolyZone uses full length/width
    local size         = vec3(length / 2, width / 2, getHeight(opts.minZ, opts.maxZ))
    local heading      = opts.heading or 0.0
    local debugDraw    = opts.debugPoly or false

    local zone         = lib.zones.box({
        coords = center,
        size = size,
        rotation = heading,
        debug = debugDraw
    })

    createdZones[name] = zone

    -- bridge callbacks to mimic PolyZone events
    function zone:onEnter()
        TriggerEvent('polyzone:enter', name, opts)
    end

    function zone:onExit()
        TriggerEvent('polyzone:exit', name, opts)
    end

    return zone
end

---Create a CircleZone equivalent using ox_lib (sphere)
function PolyzoneWrapper:AddCircleZone(name, center, radius, opts)
    opts = opts or {}

    local debugDraw = opts.debugPoly or false

    local zone = lib.zones.sphere({
        coords = center,
        radius = radius,
        debug = debugDraw
    })

    createdZones[name] = zone

    function zone:onEnter()
        TriggerEvent('polyzone:enter', name, opts)
    end

    function zone:onExit()
        TriggerEvent('polyzone:exit', name, opts)
    end

    return zone
end

---Create a PolyZone equivalent using ox_lib
function PolyzoneWrapper:AddPolyZone(name, points, opts)
    opts = opts or {}

    local debugDraw = opts.debugPoly or false

    local zone = lib.zones.poly({
        points = points,
        thickness = getHeight(opts.minZ, opts.maxZ),
        debug = debugDraw
    })

    createdZones[name] = zone

    function zone:onEnter()
        TriggerEvent('polyzone:enter', name, opts)
    end

    function zone:onExit()
        TriggerEvent('polyzone:exit', name, opts)
    end

    return zone
end

---Remove a previously created zone
---@param name string
function PolyzoneWrapper:RemoveZone(name)
    local zone = createdZones[name]
    if zone then
        zone:remove()
        createdZones[name] = nil
    end
end

---Utility to check if a point is inside a named zone (mimics PolyZone:isPointInside)
function PolyzoneWrapper:IsPointInside(name, coords)
    local zone = createdZones[name]
    if not zone then return false end
    return zone:contains(coords)
end

return PolyzoneWrapper

local Target = lib.class('Target')
local Normalizer = require 'wrappers.core.normalizer'

function Target:constructor()
    self.system = 'ox_target'
end

function Target:addEntity(entity, options)
    -- ox_target provides multiple helpers; attempt localEntity first for compatibility
    local ok, res = pcall(function()
        return exports.ox_target:addLocalEntity(entity, options)
    end)
    if ok and res ~= nil then return res end

    if exports.ox_target and exports.ox_target.addEntity then
        return exports.ox_target:addEntity(entity, options)
    end
end

function Target:removeEntity(entity)
    if exports.ox_target and exports.ox_target.removeEntity then
        return exports.ox_target:removeEntity(entity)
    end
end

function Target:addZone(name, coords, options)
    options          = options or {}

    -- Prefer ox_target's boxed zone helper (compatible with qb-target signature)
    local length     = options.length or 1.0
    local width      = options.width or 1.0

    local zoneOpts   = options.zone or options.box or options
    local targetOpts = options.target or options.options or {}

    if exports.ox_target and exports.ox_target.addBoxZone then
        return exports.ox_target:addBoxZone(name, coords, length, width, zoneOpts, targetOpts)
    end

    -- Fallback to new ox_target API (single table param)
    return exports.ox_target:addBoxZone({
        name       = name,
        coords     = coords,
        size       = options.size or vec3(length, width, options.height or 3.0),
        rotation   = options.rotation or 0.0,
        debug      = options.debug or false,
        drawSprite = options.drawSprite,
        options    = targetOpts,
        distance   = options.distance or 2.5
    })
end

function Target:removeZone(name)
    if exports.ox_target and exports.ox_target.removeZone then
        return exports.ox_target:removeZone(name)
    end
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.targeting.addEntity    = function(...) return Target:addEntity(...) end
Normalizer.targeting.removeEntity = function(...) return Target:removeEntity(...) end
Normalizer.targeting.addZone      = function(...) return Target:addZone(...) end
Normalizer.targeting.removeZone   = function(...) return Target:removeZone(...) end
Normalizer.capabilities.targeting = true

return Target

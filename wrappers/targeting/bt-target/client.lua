local Target = lib.class('Target')
local normalizer = require 'wrappers.normalizer'

function Target:constructor()
    self.system = 'bt-target'
end

function Target:addEntity(entity, options)
    return exports['bt-target']:AddTargetEntity(entity, options)
end

function Target:removeEntity(entity)
    return exports['bt-target']:RemoveTargetEntity(entity)
end

function Target:addZone(name, coords, options)
    options          = options or {}
    local length     = options.length or 1.0
    local width      = options.width or 1.0

    local zoneOpts   = options.zone or options.box or options
    local targetOpts = options.target or options.options or {}

    return exports['bt-target']:AddBoxZone(name, coords, length, width, zoneOpts, targetOpts)
end

function Target:removeZone(name)
    return exports['bt-target']:RemoveZone(name)
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.targeting.addEntity    = function(...) return Target:addEntity(...) end
Normalizer.targeting.removeEntity = function(...) return Target:removeEntity(...) end
Normalizer.targeting.addZone      = function(...) return Target:addZone(...) end
Normalizer.targeting.removeZone   = function(...) return Target:removeZone(...) end
Normalizer.capabilities.targeting = true

return Target

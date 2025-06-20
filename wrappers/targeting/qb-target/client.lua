local Target = lib.class('Target')
local Normalizer = require 'wrappers.core.normalizer'

function Target:constructor()
    self.system = 'qb-target'
    self.target = exports['qb-target']
end

function Target:addEntity(entity, options)
    return self.target:AddTargetEntity(entity, options)
end

function Target:removeEntity(entity)
    return self.target:RemoveTargetEntity(entity)
end

function Target:addZone(name, coords, options)
    options          = options or {}
    local length     = options.length or 1.0
    local width      = options.width or 1.0

    local zoneOpts   = options.zone or options.box or options
    local targetOpts = options.target or options.options or {}

    return self.target:AddBoxZone(name, coords, length, width, zoneOpts, targetOpts)
end

function Target:removeZone(name)
    return self.target:RemoveZone(name)
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.targeting.addEntity    = function(...) return Target:addEntity(...) end
Normalizer.targeting.removeEntity = function(...) return Target:removeEntity(...) end
Normalizer.targeting.addZone      = function(...) return Target:addZone(...) end
Normalizer.targeting.removeZone   = function(...) return Target:removeZone(...) end
Normalizer.capabilities.targeting = true

return Target

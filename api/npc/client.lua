-- NPC system (minimal baseline)
-- Creates lightweight peds; extra logic is opt-in via fluent setters

local Enums = lib.enums.npc
local Hooks = lib.hooks -- lazy-loads imports/hooks/shared.lua sin ciclos

lib.npc = lib.class('NPC')

-- global storage
lib.npc.activeNPCs = {}
lib.npc.behaviors = {}

-- constructor: model (string|hash), coords (vector3), heading? (number)
function lib.npc:constructor(model, coords, heading)
    assert(model, 'model required')
    assert(coords, 'coords required')

    local modelHash = type(model) == 'number' and model or GetHashKey(model)
    lib.requestModel(modelHash, 5000)

    self.private = {}
    self.private.ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z, heading or 0.0, false, true)
    assert(DoesEntityExist(self.private.ped), 'ped creation failed')

    self.private.id = #lib.npc.activeNPCs + 1
    lib.npc.activeNPCs[self.private.id] = self

    self.state = Enums.STATES.IDLE
    self.private.behaviors = nil
    self.private.schedule = nil
    self.private.guardZone = nil
    self.private.interactions = nil
    self.private.relationships = nil
    self.memory = {}

    -- disparar hook de spawn
    Hooks.trigger('npc:spawned', self)
end

-- basic getters
function lib.npc:getPed() return self.private.ped end

function lib.npc:getId() return self.private.id end

-- fluent setters (return self)
function lib.npc:setBehaviors(list, initial)
    self.private.behaviors = list
    if initial then self:changeBehavior(initial) end
    return self
end

function lib.npc:setSchedule(tbl)
    self.private.schedule = tbl
    return self
end

function lib.npc:setGuardZone(cfg)
    self.private.guardZone = cfg
    return self
end

function lib.npc:setInteractions(c)
    self.private.interactions = c
    return self
end

function lib.npc:setRelationships(c)
    self.private.relationships = c
    return self
end

-- behavior switching
function lib.npc:changeBehavior(name)
    if not (self.private.behaviors and lib.npc.behaviors[name]) then return false end
    ClearPedTasks(self.private.ped)
    self.state = Enums.STATES.IDLE
    self.currentBehavior = name
    -- disparar hook de cambio de comportamiento
    Hooks.trigger('npc:behavior_changed', self, name)
    return true
end

-- runtime AI update (cheap; only runs logic that is configured)
function lib.npc:update()
    -- schedule
    if self.private.schedule then
        local hour = GetClockHours()
        local nextB = self.private.schedule[hour]
        if nextB and nextB ~= self.currentBehavior then self:changeBehavior(nextB) end
    end

    -- execute behavior
    if self.currentBehavior and lib.npc.behaviors[self.currentBehavior] then
        lib.npc.behaviors[self.currentBehavior](self)
    end
end

-- cleanup
function lib.npc:destroy()
    if DoesEntityExist(self.private.ped) then DeleteEntity(self.private.ped) end
    lib.npc.activeNPCs[self.private.id] = nil
    -- disparar hook de destrucción
    Hooks.trigger('npc:destroyed', self)
end

-- static helpers
function lib.npc.registerBehavior(name, fn) lib.npc.behaviors[name] = fn end

-- acceso rápido a hooks
function lib.npc.onSpawned(cb, prio) Hooks.on('npc:spawned', cb, prio) end

function lib.npc.onBehaviorChanged(cb, prio) Hooks.on('npc:behavior_changed', cb, prio) end

function lib.npc.onDestroyed(cb, prio) Hooks.on('npc:destroyed', cb, prio) end

function lib.npc.get(n) return lib.npc.activeNPCs[n] end

function lib.npc.all() return lib.npc.activeNPCs end

-- global update loop (client side)
CreateThread(function()
    while true do
        if next(lib.npc.activeNPCs) then
            for _, npc in pairs(lib.npc.activeNPCs) do npc:update() end
        end
        Wait(2000) -- cheap, dev can change
    end
end)

return lib.npc

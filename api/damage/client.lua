---@meta

---@class DamageInfo
---@field entity number Entity that received damage
---@field attacker number Entity that caused damage
---@field damage number Damage amount
---@field weapon string|number Weapon hash or name
---@field hitComponent number Hit component/bone
---@field coords vector3 Damage coordinates

---@class lib.damage
---@field private damageHandlers table
local Damage = lib.class('Damage')

---Damage API Class - Client Side
---Simple wrapper around low-level damage events
---@param options? table Damage system options
function Damage:constructor(options)
    options = options or {}

    -- Initialize private properties
    self.private.damageHandlers = {}

    -- Setup damage event listeners
    self:_setupDamageListeners()
end

-- =====================================
-- DAMAGE EVENT FUNCTIONS
-- =====================================

---Register damage handler
---@param callback fun(damageInfo: DamageInfo): boolean Callback function, return false to cancel damage
---@return number handlerId Handler ID for removal
function Damage:onDamage(callback)
    local handlerId = #self.private.damageHandlers + 1
    self.private.damageHandlers[handlerId] = {
        id = handlerId,
        callback = callback,
        active = true
    }
    return handlerId
end

---Register entity damage handler
---@param entity number Entity to watch
---@param callback fun(damageInfo: DamageInfo): boolean Callback function
---@return number handlerId Handler ID for removal
function Damage:onEntityDamage(entity, callback)
    return self:onDamage(function(damageInfo)
        if damageInfo.entity == entity then
            return callback(damageInfo)
        end
        return true -- Allow damage for other entities
    end)
end

---Register player damage handler
---@param callback fun(damageInfo: DamageInfo): boolean Callback function
---@return number handlerId Handler ID for removal
function Damage:onPlayerDamage(callback)
    local playerPed = PlayerPedId()
    return self:onEntityDamage(playerPed, callback)
end

---Remove damage handler
---@param handlerId number Handler ID to remove
function Damage:removeDamageHandler(handlerId)
    if self.private.damageHandlers[handlerId] then
        self.private.damageHandlers[handlerId].active = false
        self.private.damageHandlers[handlerId] = nil
    end
end

-- =====================================
-- DAMAGE APPLICATION FUNCTIONS
-- =====================================

-- ---Apply damage to entity
-- ---@param entity number Target entity
-- ---@param damage number Damage amount
-- ---@param weapon? string|number Weapon hash or name
-- ---@param attacker? number Attacker entity
-- ---@param coords? vector3 Damage coordinates
-- function Damage:applyDamage(entity, damage, weapon, attacker, coords)
--     weapon = weapon or GetHashKey('WEAPON_UNARMED')
--     attacker = attacker or 0
--     coords = coords or GetEntityCoords(entity)

--     -- Convert weapon name to hash if needed
--     if type(weapon) == 'string' then
--         weapon = GetHashKey(weapon)
--     end

--     -- Apply the damage
--     ApplyDamageToPed(entity, damage, false)

--     -- Trigger our damage event for consistency
--     local damageInfo = {
--         entity = entity,
--         attacker = attacker,
--         damage = damage,
--         weapon = weapon,
--         hitComponent = 0,
--         coords = coords
--     }

--     self:_processDamageEvent(damageInfo)
-- end

---Apply damage to vehicle
---@param vehicle number Target vehicle
---@param damage number Damage amount
---@param component? number Vehicle component
-- function Damage:applyVehicleDamage(vehicle, damage, component)
--     component = component or 0

--     -- Apply vehicle damage
--     SetVehicleDamage(vehicle, 0.0, 0.0, 0.0, damage, 100.0, true)
-- end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Get entity health
---@param entity number Entity handle
---@return number health Current health
function Damage:getEntityHealth(entity)
    return GetEntityHealth(entity)
end

---Set entity health
---@param entity number Entity handle
---@param health number New health value
-- function Damage:setEntityHealth(entity, health)
--     SetEntityHealth(entity, health)
-- end

---Check if entity is dead
---@param entity number Entity handle
---@return boolean dead True if entity is dead
function Damage:isEntityDead(entity)
    return IsEntityDead(entity)
end

---Get damage multiplier for body part
---@param component number Hit component/bone
---@return number multiplier Damage multiplier
function Damage:getDamageMultiplier(component)
    -- Basic damage multipliers for different body parts
    local multipliers = {
        [31086] = 2.0, -- Head
        [39317] = 1.5, -- Neck
        [24818] = 1.0, -- Spine
        [24816] = 1.0, -- Chest
        [0] = 1.0      -- Default
    }

    return multipliers[component] or 1.0
end

-- =====================================
-- PRIVATE FUNCTIONS
-- =====================================

---Private method to setup damage listeners
function Damage:_setupDamageListeners()
    -- Setup AddEventHandler for entity damage
    AddEventHandler('gameEventTriggered', function(eventName, eventData)
        if eventName == 'CEventNetworkEntityDamage' then
            local damageInfo = {
                entity = eventData[1],
                attacker = eventData[2],
                damage = eventData[4],
                weapon = eventData[5],
                hitComponent = eventData[3],
                coords = GetEntityCoords(eventData[1])
            }

            self:_processDamageEvent(damageInfo)
        end
    end)
end

---Private method to process damage events
---@param damageInfo DamageInfo Damage information
function Damage:_processDamageEvent(damageInfo)
    -- Call all active damage handlers
    for _, handler in pairs(self.private.damageHandlers) do
        if handler.active then
            local result = handler.callback(damageInfo)
            return result
        end
    end
end

-- Create default instance
lib.damage = Damage:new()

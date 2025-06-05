---@meta

---@class lib.player
---@field playerId number The player ID or cache.ped if not specified
lib.player = lib.class("player")

---Player API Class - Client Only
---Player management system for client-side only
---@param playerId? number If passed, it's for that specific player. If not passed, uses cache.ped
---@return lib.player
function lib.player:constructor(playerId)
    -- Si se pasa playerId, es para ese jugador específico
    -- Si no se pasa, usa el cache.ped
    self.playerId = playerId or cache.ped
end

-- =====================================
-- CLIENT FUNCTIONS
-- =====================================

---Get the local player
---@return number ped The local player ped
function lib.player:getLocalPlayer()
    return cache.ped
end

---Get the ped of the local player or specific player
---@return number ped The player ped entity
function lib.player:getPed()
    if self.playerId == cache.ped then
        return PlayerPedId()
    else
        return cache.serverId
    end
end

---Get player position
---@return vector3? coords The player coordinates or nil if invalid
function lib.player:getPosition()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end
    return nil
end

---Get player heading
---@return number heading The player heading in degrees
function lib.player:getHeading()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityHeading(ped)
    end
    return 0
end

---Check if player is in a vehicle
---@return number|false vehicle The vehicle entity or false if not in vehicle
function lib.player:isInVehicle()
    local ped = self:getPed()
    if ped and ped ~= 0 and IsPedInAnyVehicle(ped, false) then
        return cache.vehicle
    end
    return false
end

---Get player's current vehicle
---@return number? vehicle The vehicle entity or nil if not in vehicle
function lib.player:getCurrentVehicle()
    local ped = self:getPed()
    if ped and ped ~= 0 and self:isInVehicle() then
        return cache.vehicle
    end
    return nil
end

---Check if player is driving
---@return boolean driving True if player is driving
function lib.player:isDriving()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        local vehicle = self:isInVehicle()
        if vehicle then
            return cache.seat == lib.enums.vehicles.SEATS.DRIVER
        end
    end
    return false
end

---Get player's current seat in vehicle
---@return string? seatName The seat name from enums
---@return number? seatIndex The seat index (-1 for driver, 0+ for passengers)
function lib.player:getVehicleSeat()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        local vehicle = cache.vehicle
        if vehicle then -- BOLUDO CACHE.VEHICLE RETORNA FALSO SI NO EXISTE!
            for seat, seatIndex in pairs(lib.enums.vehicles.SEATS) do
                if GetPedInVehicleSeat(vehicle, seatIndex) == ped then
                    return seat, seatIndex
                end
            end
        end
    end
    return nil, nil
end

---Check if player is dead
---@return boolean dead True if player is dead
function lib.player:isDead()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return IsEntityDead(ped)
    end
    return false
end

---Get ped state using enums
---@return string? state The ped state from enums or nil if invalid ped
function lib.player:getPedState()
    local ped = self:getPed()
    if not ped or ped == 0 then return nil end

    if IsEntityDead(ped) then
        return lib.enums.peds.PED_STATES.DEAD
    elseif IsPedRagdoll(ped) then
        return lib.enums.peds.PED_STATES.RAGDOLL
    elseif IsPedInAnyVehicle(ped, false) then
        return lib.enums.peds.PED_STATES.DRIVING
    elseif IsPedSwimming(ped) then
        return lib.enums.peds.PED_STATES.SWIMMING
    elseif IsPedFalling(ped) then
        return lib.enums.peds.PED_STATES.FALLING
    elseif IsPedClimbing(ped) then
        return lib.enums.peds.PED_STATES.CLIMBING
    elseif IsPedSprinting(ped) then
        return lib.enums.peds.PED_STATES.SPRINTING
    elseif IsPedRunning(ped) then
        return lib.enums.peds.PED_STATES.RUNNING
    elseif IsPedWalking(ped) then
        return lib.enums.peds.PED_STATES.WALKING
    else
        return lib.enums.peds.PED_STATES.IDLE
    end
end

---Get player's health level
---@return number health The health value (0-200 typically)
function lib.player:getHealth()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityHealth(ped)
    end
    return 0
end

---Get player's armor level
---@return number armor The armor value (0-100 typically)
function lib.player:getArmour()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetPedArmour(ped)
    end
    return 0
end

---Check if player is online (for other players)
---@return boolean online True if player is online
function lib.player:isOnline()
    if self.playerId == cache.ped then
        return true
    end

    local players = GetActivePlayers()
    for i = 1, #players do
        if GetPlayerServerId(players[i]) == self.playerId then
            return true
        end
    end
    return false
end

---Get distance between players
---@param otherPlayer lib.player|vector3|number Other player instance, coordinates, or player ID
---@return number? distance The distance in units or nil if invalid
function lib.player:getDistanceFrom(otherPlayer)
    local myPos = self:getPosition()
    local otherPos

    if type(otherPlayer) == 'table' and otherPlayer.getPosition then
        otherPos = otherPlayer:getPosition()
    elseif type(otherPlayer) == 'vector3' then
        otherPos = otherPlayer
        return #(myPos - otherPos)
    elseif type(otherPlayer) == 'number' then
        otherPos = GetEntityCoords(otherPlayer)
        return #(myPos - otherPos)
    else
        return nil
    end
end

return lib.player

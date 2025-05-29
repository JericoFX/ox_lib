--[[
    Player API Class - Client Only
    Sistema de clases solo para el lado del cliente
]]

lib.player = lib.class('Player')

function lib.player:constructor(playerId)
    -- Si se pasa playerId, es para ese jugador específico
    -- Si no se pasa, usa el cache.ped
    self.playerId = playerId or cache.ped
end

-- =====================================
-- FUNCIONES CLIENT
-- =====================================

-- Obtener el jugador local
function lib.player:getLocalPlayer()
    return cache.ped
end

-- Obtener el ped del jugador local o del jugador específico
function lib.player:getPed()
    if self.playerId == cache.ped then
        return PlayerPedId()
    else
        return cache.serverId
    end
end

-- Obtener posición del jugador
function lib.player:getPosition()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end
    return nil
end

-- Obtener heading del jugador
function lib.player:getHeading()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityHeading(ped)
    end
    return 0
end

-- Verificar si el jugador está en un vehículo
function lib.player:isInVehicle()
    local ped = self:getPed()
    if ped and ped ~= 0 and IsPedInAnyVehicle(ped, false) then
        return cache.vehicle
    end
    return false
end

-- Obtener vehículo actual del jugador
function lib.player:getCurrentVehicle()
    local ped = self:getPed()
    if ped and ped ~= 0 and IsPedInAnyVehicle(ped, false) then
        return cache.vehicle
    end
    return nil
end

-- Verificar si el jugador está manejando
function lib.player:isDriving()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            return cache.seat == lib.enums.vehicles.SEATS.DRIVER
        end
    end
    return false
end

-- Obtener asiento actual del jugador en el vehículo
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

-- Verificar si el jugador está muerto
function lib.player:isDead()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return IsEntityDead(ped)
    end
    return false
end

-- Obtener estado del ped usando enums
function lib.player:getPedState()
    local ped = self:getPed()
    if not ped or ped == 0 then return nil end

    if IsEntityDead(ped) then
        return lib.enums.peds.PED_STATES.DEAD
    elseif IsPedRagdoll(ped) then
        return 'RAGDOLL'
    elseif IsPedInAnyVehicle(ped, false) then
        return 'DRIVING'
    elseif IsPedSwimming(ped) then
        return 'SWIMMING'
    elseif IsPedFalling(ped) then
        return 'FALLING'
    elseif IsPedClimbing(ped) then
        return 'CLIMBING'
    elseif IsPedSprinting(ped) then
        return 'SPRINTING'
    elseif IsPedRunning(ped) then
        return 'RUNNING'
    elseif IsPedWalking(ped) then
        return 'WALKING'
    else
        return 'IDLE'
    end
end

-- Obtener nivel de salud del jugador
function lib.player:getHealth()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetEntityHealth(ped)
    end
    return 0
end

-- Obtener nivel de armadura del jugador
function lib.player:getArmour()
    local ped = self:getPed()
    if ped and ped ~= 0 then
        return GetPedArmour(ped)
    end
    return 0
end

-- Verificar si el jugador está en línea (para otros jugadores)
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

-- Obtener distancia entre jugadores
function lib.player:getDistanceFrom(otherPlayer)
    local myPos = self:getPosition()
    local otherPos

    if type(otherPlayer) == 'table' and otherPlayer.getPosition then
        otherPos = otherPlayer:getPosition()
    elseif type(otherPlayer) == 'vector3' then
        otherPos = otherPlayer
    else
        return nil
    end

    if myPos and otherPos then
        return #(myPos - otherPos)
    end
    return nil
end

return lib.player

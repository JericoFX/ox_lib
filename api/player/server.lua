--[[
    Player API - Server Functions
    Tabla de funciones que se agregan a lib.player
]]

local Player = {}

-- =====================================
-- FUNCIONES VALIDACION
-- =====================================

-- Validar identificador de jugador
function Player.isValidPlayerId(playerId)
    return type(playerId) == 'number' and playerId > 0
end

-- =====================================
-- FUNCIONES JUGADORES
-- =====================================

-- Obtener todos los jugadores conectados
function Player.getAllPlayers()
    return GetPlayers()
end

-- Verificar si un jugador está conectado
function Player.isPlayerConnected(source)
    if not Player.isValidPlayerId(source) then
        return false
    end

    local players = GetPlayers()
    for i = 1, #players do
        if tonumber(players[i]) == source then
            return true
        end
    end

    return false
end

-- Obtener nombre del jugador
function Player.getPlayerName(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    return GetPlayerName(source)
end

-- Obtener ping del jugador
function Player.getPlayerPing(source)
    if not Player.isValidPlayerId(source) then
        return 0
    end

    return GetPlayerPing(source)
end

-- Obtener endpoints del jugador
function Player.getPlayerEndpoint(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    return GetPlayerEndpoint(source)
end

-- Obtener identifiers del jugador
function Player.getPlayerIdentifiers(source)
    if not Player.isValidPlayerId(source) then
        return {}
    end

    local identifiers = {}
    local numIdentifiers = GetNumPlayerIdentifiers(source)

    for i = 0, numIdentifiers - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            table.insert(identifiers, identifier)
        end
    end

    return identifiers
end

local function getPlayerIdentifier(source, identifier)
    return GetPlayerIdentifierByType(source, identifier)
end

-- Obtener license del jugador
function Player.getPlayerLicense(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    return getPlayerIdentifier(source, 'license')
end

-- Obtener Steam ID del jugador
function Player.getPlayerSteam(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    return getPlayerIdentifier(source, 'steam')
end

-- -- Kickear jugador -- peligroso sin chequear permisos
-- function Player.kickPlayer(source, reason)
--     if not Player.isValidPlayerId(source) then
--         return false
--     end

--     DropPlayer(source, reason or 'Kicked by admin')
--     return true
-- end

-- Obtener coordenadas del jugador
function Player.getPlayerCoords(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end

    return nil
end

-- Teletransportar jugador
function Player.teleportPlayer(source, coords)
    if not Player.isValidPlayerId(source) then
        return false
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return false
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        SetEntityCoords(ped, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
        return true
    end

    return false
end

-- Verificar si jugador está en vehículo
function Player.isPlayerInVehicle(source)
    if not Player.isValidPlayerId(source) then
        return false
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        return IsPedInAnyVehicle(ped)
    end

    return false
end

-- Obtener vehículo del jugador
function Player.getPlayerVehicle(source)
    if not Player.isValidPlayerId(source) then
        return nil
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 and IsPedInAnyVehicle(ped) then
        return GetVehiclePedIsIn(ped, false)
    end

    return nil
end

-- Congelar jugador
function Player.freezePlayer(source, toggle)
    if not Player.isValidPlayerId(source) then
        return false
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        FreezeEntityPosition(ped, toggle == true)
        return true
    end

    return false
end

-- Hacer jugador invisible
function Player.setPlayerInvisible(source, toggle)
    if not Player.isValidPlayerId(source) then
        return false
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        SetEntityVisible(ped, not (toggle == true), false)
        return true
    end

    return false
end

-- Curar jugador
function Player.healPlayer(source)
    if not Player.isValidPlayerId(source) then
        return false
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 100)
        return true
    end

    return false
end

-- Obtener distancia entre jugadores
function Player.getPlayerDistance(source1, source2)
    if not Player.isValidPlayerId(source1) or not Player.isValidPlayerId(source2) then
        return nil
    end

    local coords1 = Player.getPlayerCoords(source1)
    local coords2 = Player.getPlayerCoords(source2)

    if coords1 and coords2 then
        return #(coords1 - coords2)
    end

    return nil
end

lib.player = Player
return lib.player

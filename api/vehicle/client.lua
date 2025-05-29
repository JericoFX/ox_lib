--[[
    Vehicle API Class - Client Only
    Sistema de clases solo para el lado del cliente
]]

lib.vehicle = lib.class('Vehicle')

function lib.vehicle:constructor(vehicle)
    -- Si se pasa vehicle, es para ese vehículo específico
    -- Si no se pasa, obtiene el vehículo actual del jugador
    if vehicle then
        self.vehicle = vehicle
    else
        local ped = PlayerPedId()
        self.vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or nil
    end
end

-- =====================================
-- FUNCIONES CLIENT
-- =====================================

-- Verificar si el vehículo es válido
function lib.vehicle:isValid()
    return self.vehicle and self.vehicle ~= 0 and DoesEntityExist(self.vehicle)
end

-- Obtener modelo del vehículo
function lib.vehicle:getModel()
    if not self:isValid() then return nil end
    return GetEntityModel(self.vehicle)
end

-- Obtener nombre del modelo
function lib.vehicle:getModelName()
    if not self:isValid() then return nil end
    return GetDisplayNameFromVehicleModel(self:getModel())
end

-- Obtener coordenadas del vehículo
function lib.vehicle:getCoords()
    if not self:isValid() then return nil end
    return GetEntityCoords(self.vehicle)
end

-- Obtener rotación del vehículo
function lib.vehicle:getRotation()
    if not self:isValid() then return nil end
    return GetEntityRotation(self.vehicle)
end

-- Obtener heading del vehículo
function lib.vehicle:getHeading()
    if not self:isValid() then return 0.0 end
    return GetEntityHeading(self.vehicle)
end

-- Obtener velocidad del vehículo
function lib.vehicle:getSpeed()
    if not self:isValid() then return 0.0 end
    return GetEntitySpeed(self.vehicle)
end

-- Obtener velocidad en MPH
function lib.vehicle:getSpeedMph()
    return self:getSpeed() * 2.236936
end

-- Obtener velocidad en KMH
function lib.vehicle:getSpeedKmh()
    return self:getSpeed() * 3.6
end

-- Obtener salud del vehículo
function lib.vehicle:getHealth()
    if not self:isValid() then return 0 end
    return GetVehicleEngineHealth(self.vehicle)
end

-- Establecer salud del vehículo
function lib.vehicle:setHealth(health)
    if not self:isValid() then return false end
    SetVehicleEngineHealth(self.vehicle, health)
    return true
end

-- Obtener salud del motor
function lib.vehicle:getEngineHealth()
    if not self:isValid() then return 0 end
    return GetVehicleEngineHealth(self.vehicle)
end

-- Establecer salud del motor
function lib.vehicle:setEngineHealth(health)
    if not self:isValid() then return false end
    SetVehicleEngineHealth(self.vehicle, health)
    return true
end

-- Obtener salud del tanque de gasolina
function lib.vehicle:getPetrolTankHealth()
    if not self:isValid() then return 0 end
    return GetVehiclePetrolTankHealth(self.vehicle)
end

-- Establecer salud del tanque
function lib.vehicle:setPetrolTankHealth(health)
    if not self:isValid() then return false end
    SetVehiclePetrolTankHealth(self.vehicle, health)
    return true
end

-- Verificar si el motor está encendido
function lib.vehicle:isEngineOn()
    if not self:isValid() then return false end
    return GetIsVehicleEngineRunning(self.vehicle)
end

-- Encender/apagar motor
function lib.vehicle:setEngineOn(state, instantly)
    if not self:isValid() then return false end
    SetVehicleEngineOn(self.vehicle, state, instantly or false, true)
    return true
end

-- Obtener el conductor
function lib.vehicle:getDriver()
    if not self:isValid() then return nil end
    return GetPedInVehicleSeat(self.vehicle, lib.enums.vehicles.SEATS.DRIVER)
end

-- Obtener pasajero en asiento específico (usa enum para nombres de asientos)
function lib.vehicle:getPassenger(seatIndex)
    if not self:isValid() then return nil end
    return GetPedInVehicleSeat(self.vehicle, seatIndex)
end

-- Obtener pasajero por nombre de asiento
function lib.vehicle:getPassengerByName(seatName)
    if not self:isValid() then return nil end
    local seatIndex = lib.enums.vehicles.SEATS[seatName]
    if seatIndex then
        return GetPedInVehicleSeat(self.vehicle, seatIndex)
    end
    return nil
end

-- Obtener todos los ocupantes con nombres de asientos
function lib.vehicle:getOccupants()
    if not self:isValid() then return {} end

    local occupants = {}

    -- Usar enums para mapear asientos
    for seatName, seatIndex in pairs(lib.enums.vehicles.SEATS) do
        local ped = GetPedInVehicleSeat(self.vehicle, seatIndex)
        if ped and ped ~= 0 then
            occupants[seatName] = ped
        end
    end

    return occupants
end

-- Verificar si hay espacio libre
function lib.vehicle:hasFreeSeat()
    if not self:isValid() then return false end

    local maxSeats = GetVehicleMaxNumberOfPassengers(self.vehicle) + 1 -- +1 para conductor
    local occupants = self:getOccupants()

    local occupiedSeats = 0
    for _ in pairs(occupants) do
        occupiedSeats = occupiedSeats + 1
    end

    return occupiedSeats < maxSeats
end

-- Obtener el asiento libre más cercano usando enums
function lib.vehicle:getFreeSeat()
    if not self:isValid() then return nil end

    -- Verificar conductor primero
    if not self:getDriver() or self:getDriver() == 0 then
        return 'DRIVER', lib.enums.vehicles.SEATS.DRIVER
    end

    -- Verificar asientos de pasajeros en orden de prioridad
    local seatPriority = { 'PASSENGER', 'REAR_LEFT', 'REAR_RIGHT' }

    for _, seatName in ipairs(seatPriority) do
        local seatIndex = lib.enums.vehicles.SEATS[seatName]
        if seatIndex then
            local passenger = GetPedInVehicleSeat(self.vehicle, seatIndex)
            if not passenger or passenger == 0 then
                return seatName, seatIndex
            end
        end
    end

    return nil, nil
end

-- Verificar si el vehículo está dañado
function lib.vehicle:isDamaged()
    if not self:isValid() then return true end
    return GetVehicleEngineHealth(self.vehicle) < 1000.0
end

-- Reparar vehículo completamente
function lib.vehicle:repair()
    if not self:isValid() then return false end

    SetVehicleFixed(self.vehicle)
    SetVehicleDeformationFixed(self.vehicle)
    SetVehicleUndriveable(self.vehicle, false)
    SetVehicleEngineOn(self.vehicle, true, true, true)

    return true
end

-- Obtener nivel de combustible
function lib.vehicle:getFuelLevel()
    if not self:isValid() then return 0.0 end
    return GetVehicleFuelLevel(self.vehicle)
end

-- Establecer nivel de combustible
function lib.vehicle:setFuelLevel(level)
    if not self:isValid() then return false end
    SetVehicleFuelLevel(self.vehicle, level)
    return true
end

-- Verificar si está bloqueado
function lib.vehicle:isLocked()
    if not self:isValid() then return false end
    return GetVehicleDoorLockStatus(self.vehicle) ~= 0
end

-- Bloquear/desbloquear
function lib.vehicle:setLocked(state)
    if not self:isValid() then return false end
    SetVehicleDoorsLocked(self.vehicle, state and 2 or 1)
    return true
end

-- Abrir puerta usando enum
function lib.vehicle:openDoor(doorName, loose, instantly) -- chequea si pasa string o numero, si numero usa directamente el numero
    if not self:isValid() then return false end
    local doorIndex = lib.enums.vehicles.DOORS[doorName]
    if doorIndex then
        SetVehicleDoorOpen(self.vehicle, doorIndex, loose or false, instantly or false)
        return true
    end
    return false
end

-- Cerrar puerta usando enum
function lib.vehicle:closeDoor(doorName, instantly) --mismo aca
    if not self:isValid() then return false end
    local doorIndex = lib.enums.vehicles.DOORS[doorName]
    if doorIndex then
        SetVehicleDoorShut(self.vehicle, doorIndex, instantly or false)
        return true
    end
    return false
end

-- Verificar si la puerta está dañada usando enum
function lib.vehicle:isDoorDamaged(doorName)
    if not self:isValid() then return false end
    local doorIndex = lib.enums.vehicles.DOORS[doorName]
    if doorIndex then
        return IsVehicleDoorDamaged(self.vehicle, doorIndex)
    end
    return false
end

-- Romper puerta usando enum
function lib.vehicle:breakDoor(doorName, deleteDoor)
    if not self:isValid() then return false end
    local doorIndex = lib.enums.vehicles.DOORS[doorName]
    if doorIndex then
        SetVehicleDoorBroken(self.vehicle, doorIndex, deleteDoor or false)
        return true
    end
    return false
end

-- Subir/bajar ventana usando enum
function lib.vehicle:rollDownWindow(windowName)
    if not self:isValid() then return false end
    local windowIndex = lib.enums.vehicles.WINDOWS[windowName]
    if windowIndex then
        RollDownWindow(self.vehicle, windowIndex)
        return true
    end
    return false
end

function lib.vehicle:rollUpWindow(windowName)
    if not self:isValid() then return false end
    local windowIndex = lib.enums.vehicles.WINDOWS[windowName]
    if windowIndex then
        RollUpWindow(self.vehicle, windowIndex)
        return true
    end
    return false
end

-- Verificar si la ventana está intacta usando enum
function lib.vehicle:isWindowIntact(windowName)
    if not self:isValid() then return false end
    local windowIndex = lib.enums.vehicles.WINDOWS[windowName]
    if windowIndex then
        return IsVehicleWindowIntact(self.vehicle, windowIndex)
    end
    return false
end

-- Romper ventana usando enum
function lib.vehicle:smashWindow(windowName)
    if not self:isValid() then return false end
    local windowIndex = lib.enums.vehicles.WINDOWS[windowName]
    if windowIndex then
        SmashVehicleWindow(self.vehicle, windowIndex)
        return true
    end
    return false
end

-- Obtener clase del vehículo usando enum
function lib.vehicle:getClass()
    if not self:isValid() then return nil end
    local classId = GetVehicleClass(self.vehicle)

    -- Buscar el nombre de la clase en los enums
    for className, enumClassId in pairs(lib.enums.vehicles.CLASSES) do
        if enumClassId == classId then
            return className, classId
        end
    end

    return nil, classId
end

-- Verificar si es de una clase específica
function lib.vehicle:isClass(className)
    local currentClass = self:getClass()
    return currentClass == className
end

-- Obtener modificación usando enum
function lib.vehicle:getMod(modName)
    if not self:isValid() then return nil end
    local modIndex = lib.enums.vehicles.MODS[modName]
    if modIndex then
        return GetVehicleMod(self.vehicle, modIndex)
    end
    return nil
end

-- Establecer modificación usando enum
function lib.vehicle:setMod(modName, modValue)
    if not self:isValid() then return false end
    local modIndex = lib.enums.vehicles.MODS[modName]
    if modIndex then
        SetVehicleMod(self.vehicle, modIndex, modValue, false)
        return true
    end
    return false
end

-- Obtener color usando enum (para nombres comunes)
function lib.vehicle:getColorName()
    if not self:isValid() then return nil end
    local primaryColor, secondaryColor = GetVehicleColours(self.vehicle)

    -- Buscar el nombre del color en los enums
    for colorName, colorId in pairs(lib.enums.vehicles.COLORS) do
        if colorId == primaryColor then
            return colorName, primaryColor, secondaryColor
        end
    end

    return nil, primaryColor, secondaryColor
end

-- Establecer color usando enum
function lib.vehicle:setColor(primaryColorName, secondaryColorName)
    if not self:isValid() then return false end

    local primaryColor = lib.enums.vehicles.COLORS[primaryColorName]
    local secondaryColor = secondaryColorName and lib.enums.vehicles.COLORS[secondaryColorName] or primaryColor

    if primaryColor then
        SetVehicleColours(self.vehicle, primaryColor, secondaryColor or primaryColor)
        return true
    end
    return false
end

return lib.vehicle

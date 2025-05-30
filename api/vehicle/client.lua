---@meta

---@class VehicleCreateOptions
---@field plate? string License plate text
---@field color? table|{primary: number, secondary: number}|{[1]: number, [2]: number} Vehicle colors
---@field fuel? number Fuel level (0-100)
---@field engineHealth? number Engine health (0-1000)
---@field locked? boolean Whether vehicle is locked
---@field engineOn? boolean Whether engine is on

---@class VehicleCreateResult
---@field success boolean Whether creation was successful
---@field instance? lib.vehicle Vehicle instance (if successful)
---@field entity? number Vehicle entity (if successful)
---@field error? string Error message (if failed)
---@field originalData table Original creation data

---@class lib.vehicle
---@field vehicle number? The vehicle entity this instance controls
local Vehicle = {}

---Vehicle API Class - Client Only
---Vehicle management system for client-side only
---@param vehicle? number If passed, it's for that specific vehicle. If not passed, gets player's current vehicle
---@return lib.vehicle
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
-- CREATION FUNCTIONS
-- =====================================

---Static function to create a vehicle with callback
---@param model string|number Vehicle model name or hash
---@param coords vector3|table Vehicle spawn coordinates
---@param heading? number Vehicle heading in degrees (default: 0.0)
---@param callback? fun(success: boolean, message: string, instance?: lib.vehicle, entity?: number) Callback function
---@param options? VehicleCreateOptions Additional creation options
---@return boolean started True if creation process started
function lib.vehicle.create(model, coords, heading, callback, options)
    options = options or {}

    -- Validar parámetros
    if type(model) ~= 'string' and type(model) ~= 'number' then
        if callback then callback(false, 'Invalid vehicle model') end
        return false
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        if callback then callback(false, 'Invalid coordinates') end
        return false
    end

    heading = heading or 0.0

    -- Convertir coordenadas si es necesario
    local vehicleCoords = coords
    if type(coords) == 'table' then
        vehicleCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    -- Asegurarse de que el modelo esté cargado
    local modelHash = type(model) == 'string' and joaat(model) or model

    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        if callback then callback(false, 'Invalid vehicle model: ' .. tostring(model)) end
        return false
    end

    -- Cargar el modelo con callback
    lib.requestModel(modelHash, function(success)
        if not success then
            if callback then callback(false, 'Could not load model: ' .. tostring(model)) end
            return
        end

        -- Crear el vehículo
        local vehicle = CreateVehicle(modelHash, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, heading, true, false)

        if not vehicle or vehicle == 0 then
            SetModelAsNoLongerNeeded(modelHash)
            if callback then callback(false, 'Could not create vehicle') end
            return
        end

        -- Aplicar opciones adicionales si se proporcionan
        if options.plate then
            SetVehicleNumberPlateText(vehicle, options.plate)
        end

        if options.color then
            if type(options.color) == 'table' then
                if options.color.primary and options.color.secondary then
                    SetVehicleColours(vehicle, options.color.primary, options.color.secondary)
                elseif options.color[1] and options.color[2] then
                    SetVehicleColours(vehicle, options.color[1], options.color[2])
                end
            end
        end

        if options.fuel ~= nil then
            SetVehicleFuelLevel(vehicle, options.fuel)
        end

        if options.engineHealth then
            SetVehicleEngineHealth(vehicle, options.engineHealth)
        end

        if options.locked ~= nil then
            SetVehicleDoorsLocked(vehicle, options.locked and 2 or 1)
        end

        if options.engineOn ~= nil then
            SetVehicleEngineOn(vehicle, options.engineOn, true, true)
        end

        -- Crear instancia de la clase vehicle
        local vehicleInstance = lib.vehicle:new(vehicle)

        -- Limpiar modelo
        SetModelAsNoLongerNeeded(modelHash)

        -- Ejecutar callback con éxito
        if callback then
            callback(true, 'Vehicle created successfully', vehicleInstance, vehicle)
        end
    end)

    return true
end

---Static function to create a vehicle and place player inside
---@param model string|number Vehicle model name or hash
---@param coords vector3|table Vehicle spawn coordinates
---@param heading? number Vehicle heading in degrees (default: 0.0)
---@param seatName? string Seat name from enums (default: 'DRIVER')
---@param callback? fun(success: boolean, message: string, instance?: lib.vehicle, entity?: number) Callback function
---@param options? VehicleCreateOptions Additional creation options
function lib.vehicle.createAndEnter(model, coords, heading, seatName, callback, options)
    seatName = seatName or 'DRIVER'

    lib.vehicle.create(model, coords, heading, function(success, message, vehicleInstance, vehicleEntity)
        if not success then
            if callback then callback(false, message) end
            return
        end

        -- Obtener el ped del jugador
        local playerPed = PlayerPedId()

        -- Obtener el índice del asiento
        local seatIndex = lib.enums.vehicles.SEATS[seatName]
        if not seatIndex then
            if callback then callback(false, 'Invalid seat: ' .. tostring(seatName)) end
            return
        end

        -- Colocar al jugador en el vehículo
        TaskWarpPedIntoVehicle(playerPed, vehicleEntity, seatIndex)

        if callback then
            callback(true, 'Vehicle created and player placed successfully', vehicleInstance, vehicleEntity)
        end
    end, options)
end

---Static function to create multiple vehicles with callback
---@param vehicles table[] List of vehicle creation data
---@param callback? fun(success: boolean, message: string, results: VehicleCreateResult[]) Callback function
---@return boolean started True if creation process started
function lib.vehicle.createMultiple(vehicles, callback)
    if type(vehicles) ~= 'table' then
        if callback then callback(false, 'Invalid vehicle list') end
        return false
    end

    local createdVehicles = {}
    local totalVehicles = #vehicles
    local completedVehicles = 0
    local hasError = false

    if totalVehicles == 0 then
        if callback then callback(true, 'No vehicles to create', {}) end
        return true
    end

    -- Función para verificar si todos los vehículos han sido procesados
    local function checkCompletion()
        completedVehicles = completedVehicles + 1

        if completedVehicles >= totalVehicles then
            if hasError then
                if callback then callback(false, 'Some vehicles could not be created', createdVehicles) end
            else
                if callback then callback(true, 'All vehicles created successfully', createdVehicles) end
            end
        end
    end

    -- Crear cada vehículo
    for i, vehicleData in ipairs(vehicles) do
        lib.vehicle.create(
            vehicleData.model,
            vehicleData.coords,
            vehicleData.heading,
            function(success, message, vehicleInstance, vehicleEntity)
                if success then
                    createdVehicles[i] = {
                        success = true,
                        instance = vehicleInstance,
                        entity = vehicleEntity,
                        originalData = vehicleData
                    }
                else
                    hasError = true
                    createdVehicles[i] = {
                        success = false,
                        error = message,
                        originalData = vehicleData
                    }
                end

                checkCompletion()
            end,
            vehicleData.options
        )
    end

    return true
end

-- =====================================
-- CLIENT FUNCTIONS
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

-- =====================================
-- DELETION FUNCTIONS
-- =====================================

-- Eliminar este vehículo con callback
function lib.vehicle:delete(callback)
    if not self:isValid() then
        if callback then callback(false, 'Invalid vehicle') end
        return false
    end

    local vehicleEntity = self.vehicle

    -- Eliminar el vehículo
    DeleteVehicle(vehicleEntity)

    -- Verificar si se eliminó correctamente
    local success = not DoesEntityExist(vehicleEntity)

    if success then
        self.vehicle = nil
        if callback then callback(true, 'Vehicle deleted successfully') end
    else
        if callback then callback(false, 'Could not delete vehicle') end
    end

    return success
end

-- Función estática para eliminar un vehículo por entity con callback
function lib.vehicle.deleteEntity(vehicleEntity, callback)
    if not vehicleEntity or vehicleEntity == 0 or not DoesEntityExist(vehicleEntity) then
        if callback then callback(false, 'Invalid vehicle entity') end
        return false
    end

    -- Eliminar el vehículo
    DeleteVehicle(vehicleEntity)

    -- Verificar si se eliminó correctamente
    local success = not DoesEntityExist(vehicleEntity)

    if success then
        if callback then callback(true, 'Vehicle deleted successfully') end
    else
        if callback then callback(false, 'Could not delete vehicle') end
    end

    return success
end

-- Función estática para eliminar múltiples vehículos con callback
function lib.vehicle.deleteMultiple(vehicles, callback)
    if type(vehicles) ~= 'table' then
        if callback then callback(false, 'Invalid vehicle list') end
        return false
    end

    local deletedVehicles = {}
    local totalVehicles = #vehicles
    local hasError = false

    if totalVehicles == 0 then
        if callback then callback(true, 'No vehicles to delete', {}) end
        return true
    end

    -- Eliminar cada vehículo
    for i, vehicle in ipairs(vehicles) do
        local vehicleEntity = vehicle

        -- Si es una instancia de lib.vehicle, obtener la entidad
        if type(vehicle) == 'table' and vehicle.vehicle then
            vehicleEntity = vehicle.vehicle
        end

        local success = false
        local message = ''

        if vehicleEntity and vehicleEntity ~= 0 and DoesEntityExist(vehicleEntity) then
            DeleteVehicle(vehicleEntity)
            success = not DoesEntityExist(vehicleEntity)
            message = success and 'Deleted successfully' or 'Could not delete'
        else
            message = 'Invalid vehicle'
        end

        if not success then
            hasError = true
        end

        deletedVehicles[i] = {
            success = success,
            message = message,
            originalVehicle = vehicle
        }
    end

    if callback then
        if hasError then
            callback(false, 'Some vehicles could not be deleted', deletedVehicles)
        else
            callback(true, 'All vehicles deleted successfully', deletedVehicles)
        end
    end

    return not hasError
end

-- Función estática para eliminar vehículos en un área con callback
function lib.vehicle.deleteInArea(coords, radius, callback, filterFunction)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        if callback then callback(false, 'Invalid coordinates') end
        return false
    end

    radius = radius or 10.0

    -- Convertir coordenadas si es necesario
    local areaCoords = coords
    if type(coords) == 'table' then
        areaCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    -- Obtener vehículos cercanos
    local nearbyVehicles = lib.getNearbyVehicles(areaCoords, radius, true)
    local vehiclesToDelete = {}

    -- Filtrar vehículos si se proporciona una función de filtro
    for _, vehicleData in ipairs(nearbyVehicles) do
        local shouldDelete = true

        if filterFunction and type(filterFunction) == 'function' then
            shouldDelete = filterFunction(vehicleData.vehicle, vehicleData)
        end

        if shouldDelete then
            table.insert(vehiclesToDelete, vehicleData.vehicle)
        end
    end

    -- Eliminar los vehículos filtrados
    lib.vehicle.deleteMultiple(vehiclesToDelete, function(success, message, results)
        if callback then
            callback(success, message, results, #vehiclesToDelete)
        end
    end)

    return true
end

return lib.vehicle

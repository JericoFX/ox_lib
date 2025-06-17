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
lib.vehicle = lib.class("vehicle")

---Vehicle API Class - Client Only
---Vehicle management system for client-side only
---@param vehicle? number If passed, it's for that specific vehicle. If not passed, gets player's current vehicle
---@return lib.vehicle
function lib.vehicle:constructor(vehicle)
    if vehicle then
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            self.vehicle = vehicle
        else
            self.vehicle = nil
        end
    else
        self.vehicle = cache.vehicle or nil
    end
end

-- =====================================
-- VALIDATION FUNCTIONS
-- =====================================

---Check if the vehicle instance is valid
---@return boolean valid True if vehicle exists and is valid
function lib.vehicle:isValid()
    return self.vehicle and self.vehicle ~= 0 and DoesEntityExist(self.vehicle) and IsEntityAVehicle(self.vehicle)
end

---Get the vehicle entity ID
---@return number? vehicle The vehicle entity or nil if invalid
function lib.vehicle:getEntity()
    if self:isValid() then
        return self.vehicle
    end
    return nil
end

---Set a new vehicle entity for this instance
---@param vehicle number The new vehicle entity
---@return boolean success True if the vehicle was set successfully
function lib.vehicle:setVehicle(vehicle)
    if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        self.vehicle = vehicle
        return true
    end
    return false
end

---Static function to create an instance from any vehicle entity
---@param vehicle number Vehicle entity
---@return lib.vehicle? instance Vehicle instance or nil if invalid
function lib.vehicle.fromEntity(vehicle)
    if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        return lib.vehicle:new(vehicle)
    end
    return nil
end

---Static function to get player's current vehicle as instance
---@return lib.vehicle? instance Vehicle instance or nil if player not in vehicle
function lib.vehicle.getCurrent()
    if cache.vehicle then
        return lib.vehicle:new(cache.vehicle)
    end
    return nil
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

    if type(model) ~= 'string' and type(model) ~= 'number' then
        if callback then callback(false, 'Invalid vehicle model') end
        return false
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        if callback then callback(false, 'Invalid coordinates') end
        return false
    end

    heading = heading or 0.0

    local vehicleCoords = coords
    if type(coords) == 'table' then
        vehicleCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local modelHash = type(model) == 'string' and joaat(model) or model

    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        if callback then callback(false, 'Invalid vehicle model: ' .. tostring(model)) end
        return false
    end

    local success, loadedModel = pcall(lib.requestModel, modelHash)
    if not success or not loadedModel then
        if callback then callback(false, 'Could not load vehicle model: ' .. tostring(model)) end
        return false
    end

    local vehicle = CreateVehicle(modelHash, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, heading, true, false)

    if not vehicle or vehicle == 0 then
        SetModelAsNoLongerNeeded(modelHash)
        if callback then callback(false, 'Could not create vehicle') end
        return false
    end

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

    if options.fuel and options.fuel >= 0 and options.fuel <= 100 then
        SetVehicleFuelLevel(vehicle, options.fuel + 0.0)
    end

    if options.engineHealth and options.engineHealth >= 0 and options.engineHealth <= 1000 then
        SetVehicleEngineHealth(vehicle, options.engineHealth)
    end

    if options.locked ~= nil then
        SetVehicleDoorsLocked(vehicle, options.locked and 2 or 1)
    end

    if options.engineOn ~= nil then
        SetVehicleEngineOn(vehicle, options.engineOn, true, true)
    end

    local vehicleInstance = lib.vehicle:new(vehicle)

    SetModelAsNoLongerNeeded(modelHash)

    if callback then
        callback(true, 'Vehicle created successfully', vehicleInstance, vehicle)
    end

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
        local playerPed = cache.ped

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
-- VEHICLE SYNC SYSTEM WITH STATEBAGS
-- =====================================

---Initialize vehicle sync system
function lib.vehicle:initSync()
    if not self:isValid() then return false end
    
    local properties = self:getProperties()
    Entity(self.vehicle).state:set('vehicleProperties', properties, true)
    
    return true
end

---Sync vehicle properties using StateBags
---@param properties? table Specific properties to sync (optional, will get current if nil)
---@return boolean success True if sync was initiated
function lib.vehicle:syncProperties(properties)
    if not self:isValid() then return false end
    
    properties = properties or self:getProperties()
    Entity(self.vehicle).state:set('vehicleProperties', properties, true)
    
    return true
end

---Set properties and auto-sync
---@param properties table Vehicle properties
---@param fixVehicle? boolean Fix vehicle after setting
---@return boolean success
function lib.vehicle:setPropertiesAndSync(properties, fixVehicle)
    if not self:isValid() then return false end
    
    local success = self:setProperties(properties, fixVehicle)
    if success then
        self:syncProperties(properties)
    end
    
    return success
end

---Get synced properties from StateBag
---@return table? properties Synced properties or nil
function lib.vehicle:getSyncedProperties()
    if not self:isValid() then return nil end
    
    return Entity(self.vehicle).state.vehicleProperties
end

---Set custom vehicle state
---@param key string State key
---@param value any State value
---@param replicated? boolean Whether to replicate to other clients
---@return boolean success
function lib.vehicle:setState(key, value, replicated)
    if not self:isValid() then return false end
    
    Entity(self.vehicle).state:set(key, value, replicated ~= false)
    return true
end

---Get custom vehicle state
---@param key string State key
---@return any value State value
function lib.vehicle:getState(key)
    if not self:isValid() then return nil end
    
    return Entity(self.vehicle).state[key]
end

-- =====================================
-- VEHICLE DIMENSIONS AND POSITIONING
-- =====================================

---Get vehicle dimensions (length, width, height)
---@return table? dimensions {length: number, width: number, height: number}
function lib.vehicle:getDimensions()
    if not self:isValid() then return nil end
    
    local min, max = GetModelDimensions(self:getModel())
    
    return {
        length = max.y - min.y,
        width = max.x - min.x,
        height = max.z - min.z,
        min = min,
        max = max
    }
end

---Get front position of vehicle with optional offset
---@param offset? number Additional offset from front (default: 2.5)
---@return vector3? frontPos Front position coordinates
function lib.vehicle:getFrontPosition(offset)
    if not self:isValid() then return nil end
    
    offset = offset or 2.5
    local coords = self:getCoords()
    local dimensions = self:getDimensions()
    local heading = math.rad(self:getHeading())
    
    local frontDistance = (dimensions.length / 2) + offset
    
    local frontPos = vector3(
        coords.x + math.sin(-heading) * frontDistance,
        coords.y + math.cos(-heading) * frontDistance,
        coords.z
    )
    
    return frontPos
end

---Get rear position of vehicle with optional offset
---@param offset? number Additional offset from rear (default: 2.5)
---@return vector3? rearPos Rear position coordinates
function lib.vehicle:getRearPosition(offset)
    if not self:isValid() then return nil end
    
    offset = offset or 2.5
    local coords = self:getCoords()
    local dimensions = self:getDimensions()
    local heading = math.rad(self:getHeading())
    
    local rearDistance = (dimensions.length / 2) + offset
    
    local rearPos = vector3(
        coords.x - math.sin(-heading) * rearDistance,
        coords.y - math.cos(-heading) * rearDistance,
        coords.z
    )
    
    return rearPos
end

---Get left side position of vehicle with optional offset
---@param offset? number Additional offset from left side (default: 2.0)
---@return vector3? leftPos Left side position coordinates
function lib.vehicle:getLeftPosition(offset)
    if not self:isValid() then return nil end
    
    offset = offset or 2.0
    local coords = self:getCoords()
    local dimensions = self:getDimensions()
    local heading = math.rad(self:getHeading())
    
    local sideDistance = (dimensions.width / 2) + offset
    
    local leftPos = vector3(
        coords.x + math.cos(heading) * sideDistance,
        coords.y + math.sin(heading) * sideDistance,
        coords.z
    )
    
    return leftPos
end

---Get right side position of vehicle with optional offset
---@param offset? number Additional offset from right side (default: 2.0)
---@return vector3? rightPos Right side position coordinates
function lib.vehicle:getRightPosition(offset)
    if not self:isValid() then return nil end
    
    offset = offset or 2.0
    local coords = self:getCoords()
    local dimensions = self:getDimensions()
    local heading = math.rad(self:getHeading())
    
    local sideDistance = (dimensions.width / 2) + offset
    
    local rightPos = vector3(
        coords.x - math.cos(heading) * sideDistance,
        coords.y - math.sin(heading) * sideDistance,
        coords.z
    )
    
    return rightPos
end

---Get all cardinal positions around vehicle
---@param offset? number Offset distance (default: 2.5)
---@return table positions {front: vector3, rear: vector3, left: vector3, right: vector3}
function lib.vehicle:getAllPositions(offset)
    if not self:isValid() then return {} end
    
    return {
        front = self:getFrontPosition(offset),
        rear = self:getRearPosition(offset),
        left = self:getLeftPosition(offset or 2.0),
        right = self:getRightPosition(offset or 2.0)
    }
end

---Check if position is clear (no obstacles)
---@param position vector3 Position to check
---@param radius? number Check radius (default: 1.5)
---@return boolean clear True if position is clear
function lib.vehicle:isPositionClear(position, radius)
    radius = radius or 1.5
    
    local nearbyVehicles = lib.getNearbyVehicles(position, radius, true)
    if #nearbyVehicles > 0 then return false end
    
    local nearbyObjects = lib.getNearbyObjects(position, radius, true)
    if #nearbyObjects > 0 then return false end
    
    return true
end

---Find the best clear position around vehicle
---@param preferredSide? string Preferred side ('front', 'rear', 'left', 'right')
---@param offset? number Offset distance (default: 2.5)
---@return vector3? position Best available position or nil
function lib.vehicle:getBestClearPosition(preferredSide, offset)
    if not self:isValid() then return nil end
    
    local positions = self:getAllPositions(offset)
    
    if preferredSide and positions[preferredSide] then
        if self:isPositionClear(positions[preferredSide]) then
            return positions[preferredSide]
        end
    end
    
    local priorityOrder = {'front', 'rear', 'left', 'right'}
    
    for _, side in ipairs(priorityOrder) do
        if side ~= preferredSide and positions[side] then
            if self:isPositionClear(positions[side]) then
                return positions[side]
            end
        end
    end
    
    return nil
end

---Calculate distance between vehicle and target
---@param target vector3|number Target coordinates or entity
---@param fromSide? string Calculate from specific side ('front', 'rear', 'left', 'right')
---@return number distance Distance in units
function lib.vehicle:getDistanceTo(target, fromSide)
    if not self:isValid() then return 0.0 end
    
    local vehiclePos
    
    if fromSide then
        local positions = self:getAllPositions()
        vehiclePos = positions[fromSide] or self:getCoords()
    else
        vehiclePos = self:getCoords()
    end
    
    local targetPos
    if type(target) == 'number' then
        targetPos = GetEntityCoords(target)
    else
        targetPos = target
    end
    
    return #(vehiclePos - targetPos)
end

---Get closest approach distance to another vehicle
---@param otherVehicle number|lib.vehicle Other vehicle entity or instance
---@return number distance Closest distance between vehicle edges
function lib.vehicle:getClosestDistanceTo(otherVehicle)
    if not self:isValid() then return 0.0 end
    
    local otherEntity = otherVehicle
    if type(otherVehicle) == 'table' and otherVehicle.vehicle then
        otherEntity = otherVehicle.vehicle
    end
    
    if not DoesEntityExist(otherEntity) then return 0.0 end
    
    local myPositions = self:getAllPositions(0)
    local otherInstance = lib.vehicle.fromEntity(otherEntity)
    local otherPositions = otherInstance:getAllPositions(0)
    
    local minDistance = math.huge
    
    for _, myPos in pairs(myPositions) do
        for _, otherPos in pairs(otherPositions) do
            local distance = #(myPos - otherPos)
            if distance < minDistance then
                minDistance = distance
            end
        end
    end
    
    return minDistance
end

---Get spawn position relative to vehicle
---@param side string Side to spawn ('front', 'rear', 'left', 'right')
---@param distance? number Distance from vehicle (default: uses vehicle length + 2.5)
---@param findClear? boolean Find clear position automatically (default: true)
---@return vector3? position Spawn position or nil if not available
function lib.vehicle:getSpawnPosition(side, distance, findClear)
    if not self:isValid() then return nil end
    
    findClear = findClear ~= false
    
    if not distance then
        local dimensions = self:getDimensions()
        distance = dimensions.length + 2.5
    end
    
    local position
    if side == 'front' then
        position = self:getFrontPosition(distance)
    elseif side == 'rear' then
        position = self:getRearPosition(distance)
    elseif side == 'left' then
        position = self:getLeftPosition(distance)
    elseif side == 'right' then
        position = self:getRightPosition(distance)
    else
        return nil
    end
    
    if findClear and not self:isPositionClear(position) then
        return self:getBestClearPosition(side, distance)
    end
    
    return position
end

-- =====================================
-- TOWING AND ATTACHMENT SYSTEM
-- =====================================

---Check if vehicle can tow another vehicle
---@param targetVehicle number Target vehicle entity
---@return boolean canTow True if towing is possible
function lib.vehicle:canTowVehicle(targetVehicle)
    if not self:isValid() then return false end
    
    local targetInstance = lib.vehicle.fromEntity(targetVehicle)
    if not targetInstance then return false end
    
    local vehicleClass = self:getClass()
    local canTow = lib.enums.vehicles.TOW_CAPABLE[vehicleClass] or false
    
    if not canTow then return false end
    
    local targetClass = targetInstance:getClass()
    local canBeTowed = lib.enums.vehicles.TOWABLE[targetClass] or false
    
    return canBeTowed
end

---Attach trailer to vehicle
---@param trailerVehicle number Trailer vehicle entity
---@param callback? fun(success: boolean, message: string) Callback function
---@return boolean started True if attachment process started
function lib.vehicle:attachTrailer(trailerVehicle, callback)
    if not self:isValid() then 
        if callback then callback(false, 'Invalid tow vehicle') end
        return false 
    end
    
    if not self:canTowVehicle(trailerVehicle) then
        if callback then callback(false, 'Vehicles not compatible for towing') end
        return false
    end
    
    local towCoords = self:getCoords()
    local trailerCoords = GetEntityCoords(trailerVehicle)
    local distance = #(towCoords - trailerCoords)
    
    if distance > 10.0 then
        if callback then callback(false, 'Vehicles too far apart') end
        return false
    end
    
    AttachVehicleToTrailer(self.vehicle, trailerVehicle, 5.0)
    
    CreateThread(function()
        Wait(500)
        local isAttached = IsVehicleAttachedToTrailer(self.vehicle)
        
        if isAttached then
            self:setState('trailerAttached', NetworkGetNetworkIdFromEntity(trailerVehicle), true)
            TriggerServerEvent('ox_lib:syncTrailerAttachment', {
                towVehicle = NetworkGetNetworkIdFromEntity(self.vehicle),
                trailer = NetworkGetNetworkIdFromEntity(trailerVehicle),
                attached = true
            })
            
            if callback then callback(true, 'Trailer attached successfully') end
        else
            if callback then callback(false, 'Failed to attach trailer') end
        end
    end)
    
    return true
end

---Detach trailer from vehicle
---@param callback? fun(success: boolean, message: string) Callback function
---@return boolean started True if detachment process started
function lib.vehicle:detachTrailer(callback)
    if not self:isValid() then 
        if callback then callback(false, 'Invalid vehicle') end
        return false 
    end
    
    if not IsVehicleAttachedToTrailer(self.vehicle) then
        if callback then callback(false, 'No trailer attached') end
        return false
    end
    
    DetachVehicleFromTrailer(self.vehicle)
    
    CreateThread(function()
        Wait(500)
        local isDetached = not IsVehicleAttachedToTrailer(self.vehicle)
        
        if isDetached then
            self:setState('trailerAttached', nil, true)
            TriggerServerEvent('ox_lib:syncTrailerAttachment', {
                towVehicle = NetworkGetNetworkIdFromEntity(self.vehicle),
                trailer = nil,
                attached = false
            })
            
            if callback then callback(true, 'Trailer detached successfully') end
        else
            if callback then callback(false, 'Failed to detach trailer') end
        end
    end)
    
    return true
end

---Find nearby compatible trailers
---@param radius? number Search radius (default: 15.0)
---@return table trailers List of compatible trailers
function lib.vehicle:findNearbyTrailers(radius)
    if not self:isValid() then return {} end
    
    radius = radius or 15.0
    local coords = self:getCoords()
    local nearbyVehicles = lib.getNearbyVehicles(coords, radius, true)
    local compatibleTrailers = {}
    
    for _, vehicleData in ipairs(nearbyVehicles) do
        if vehicleData.vehicle ~= self.vehicle then
            if self:canTowVehicle(vehicleData.vehicle) then
                table.insert(compatibleTrailers, {
                    vehicle = vehicleData.vehicle,
                    distance = vehicleData.distance,
                    instance = lib.vehicle.fromEntity(vehicleData.vehicle)
                })
            end
        end
    end
    
    table.sort(compatibleTrailers, function(a, b) return a.distance < b.distance end)
    
    return compatibleTrailers
end

-- =====================================
-- SPECIAL VEHICLE FUNCTIONS
-- =====================================

---Get special vehicle type
---@return string? specialType Type of special vehicle or nil
function lib.vehicle:getSpecialType()
    if not self:isValid() then return nil end
    
    local modelName = self:getModelName()
    
    local specialTypes = {
        ['TOWTRUCK'] = 'tow_truck',
        ['TOWTRUCK2'] = 'tow_truck',
        ['FLATBED'] = 'flatbed',
        ['FIRETRUK'] = 'fire_truck',
        ['AMBULANCE'] = 'ambulance',
        ['POLICE'] = 'police',
        ['POLICE2'] = 'police',
        ['POLICE3'] = 'police',
        ['SHERIFF'] = 'police',
        ['RIOT'] = 'swat',
        ['BUZZARD'] = 'helicopter',
        ['BUZZARD2'] = 'helicopter'
    }
    
    return specialTypes[modelName] or nil
end

---Get tow truck hook position
---@return vector3? hookPos Hook position or nil
function lib.vehicle:getTowTruckHook()
    if not self:isValid() then return nil end
    
    local specialType = self:getSpecialType()
    if specialType ~= 'tow_truck' and specialType ~= 'flatbed' then
        return nil
    end
    
    local hookBone = GetEntityBoneIndexByName(self.vehicle, 'hook')
    if hookBone ~= -1 then
        return GetWorldPositionOfEntityBone(self.vehicle, hookBone)
    end
    
    local coords = self:getCoords()
    return coords + GetEntityForwardVector(self.vehicle) * -4.0
end

---Tow vehicle with hook mechanism
---@param targetVehicle number Target vehicle entity
---@param callback? fun(success: boolean, message: string) Callback function
---@return boolean started True if towing process started
function lib.vehicle:towVehicleWithHook(targetVehicle, callback)
    if not self:isValid() then 
        if callback then callback(false, 'Invalid tow truck') end
        return false 
    end
    
    local specialType = self:getSpecialType()
    if specialType ~= 'tow_truck' and specialType ~= 'flatbed' then
        if callback then callback(false, 'Vehicle is not a tow truck') end
        return false
    end
    
    local hookPos = self:getTowTruckHook()
    local targetCoords = GetEntityCoords(targetVehicle)
    local distance = #(hookPos - targetCoords)
    
    if distance > 8.0 then
        if callback then callback(false, 'Target vehicle too far from hook') end
        return false
    end
    
    local playerPed = cache.ped
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
    
    CreateThread(function()
        Wait(5000)
        ClearPedTasks(playerPed)
        
        AttachEntityToEntity(
            targetVehicle, 
            self.vehicle, 
            GetEntityBoneIndexByName(self.vehicle, 'hook'),
            0.0, -2.0, 1.0,
            0.0, 0.0, 0.0,
            false, false, false, false, 0, true
        )
        
        if IsEntityAttachedToEntity(targetVehicle, self.vehicle) then
            self:setState('towedVehicle', NetworkGetNetworkIdFromEntity(targetVehicle), true)
            if callback then callback(true, 'Vehicle towed successfully') end
        else
            if callback then callback(false, 'Failed to tow vehicle') end
        end
    end)
    
    return true
end

---Set emergency lights for emergency vehicles
---@param state boolean Light state
---@param pattern? number Light pattern (default: 1)
---@return boolean success True if lights were set
function lib.vehicle:setEmergencyLights(state, pattern)
    if not self:isValid() then return false end
    
    local specialType = self:getSpecialType()
    if specialType ~= 'police' and specialType ~= 'fire_truck' and specialType ~= 'ambulance' then
        return false
    end
    
    pattern = pattern or 1
    
    if state then
        SetVehicleSiren(self.vehicle, true)
        SetVehicleHasMutedSirens(self.vehicle, false)
        
        if pattern == 2 then
            SetVehicleHasMutedSirens(self.vehicle, true)
        end
    else
        SetVehicleSiren(self.vehicle, false)
    end
    
    self:setState('emergencyLights', state, true)
    
    return true
end

-- =====================================
-- CLIENT FUNCTIONS
-- =====================================

function lib.vehicle:getModel()
    if not self:isValid() then return nil end
    return GetEntityModel(self.vehicle)
end

function lib.vehicle:getModelName()
    if not self:isValid() then return nil end
    return GetDisplayNameFromVehicleModel(self:getModel())
end

function lib.vehicle:getCoords()
    if not self:isValid() then return nil end
    return GetEntityCoords(self.vehicle)
end

function lib.vehicle:getRotation()
    if not self:isValid() then return nil end
    return GetEntityRotation(self.vehicle)
end

function lib.vehicle:getHeading()
    if not self:isValid() then return 0.0 end
    return GetEntityHeading(self.vehicle)
end

function lib.vehicle:getSpeed()
    if not self:isValid() then return 0.0 end
    return GetEntitySpeed(self.vehicle)
end

function lib.vehicle:getSpeedMph()
    return self:getSpeed() * 2.236936
end

function lib.vehicle:getSpeedKmh()
    return self:getSpeed() * 3.6
end

function lib.vehicle:getHealth()
    if not self:isValid() then return 0 end
    return GetVehicleEngineHealth(self.vehicle)
end

function lib.vehicle:setHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehicleEngineHealth(self.vehicle, health)
    return true
end

function lib.vehicle:getEngineHealth()
    if not self:isValid() then return 0 end
    return GetVehicleEngineHealth(self.vehicle)
end

function lib.vehicle:setEngineHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehicleEngineHealth(self.vehicle, health)
    return true
end

function lib.vehicle:getPetrolTankHealth()
    if not self:isValid() then return 0 end
    return GetVehiclePetrolTankHealth(self.vehicle)
end

function lib.vehicle:setPetrolTankHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehiclePetrolTankHealth(self.vehicle, health)
    return true
end

function lib.vehicle:isEngineOn()
    if not self:isValid() then return false end
    return GetIsVehicleEngineRunning(self.vehicle)
end

function lib.vehicle:setEngineOn(state, instantly)
    if not self:isValid() then return false end
    SetVehicleEngineOn(self.vehicle, state, instantly or false, true)
    return true
end

function lib.vehicle:getDriver()
    if not self:isValid() then return nil end
    return GetPedInVehicleSeat(self.vehicle, lib.enums.vehicles.SEATS.DRIVER)
end

function lib.vehicle:getPassenger(seatIndex)
    if not self:isValid() then return nil end
    return GetPedInVehicleSeat(self.vehicle, seatIndex)
end

function lib.vehicle:getPassengerByName(seatName)
    if not self:isValid() then return nil end
    local seatIndex = lib.enums.vehicles.SEATS[seatName]
    if seatIndex then
        return GetPedInVehicleSeat(self.vehicle, seatIndex)
    end
    return nil
end

function lib.vehicle:getOccupants()
    if not self:isValid() then return {} end

    local occupants = {}

    for seatName, seatIndex in pairs(lib.enums.vehicles.SEATS) do
        local ped = GetPedInVehicleSeat(self.vehicle, seatIndex)
        if ped and ped ~= 0 then
            occupants[seatName] = ped
        end
    end

    return occupants
end

function lib.vehicle:hasFreeSeat()
    if not self:isValid() then return false end

    local maxSeats = GetVehicleMaxNumberOfPassengers(self.vehicle) + 1
    local occupants = self:getOccupants()

    local occupiedSeats = 0
    for _ in pairs(occupants) do
        occupiedSeats = occupiedSeats + 1
    end

    return occupiedSeats < maxSeats
end

function lib.vehicle:getFreeSeat()
    if not self:isValid() then return nil end

    if not self:getDriver() or self:getDriver() == 0 then
        return 'DRIVER', lib.enums.vehicles.SEATS.DRIVER
    end

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

function lib.vehicle:isDamaged()
    if not self:isValid() then return true end
    return GetVehicleEngineHealth(self.vehicle) < 1000.0
end

function lib.vehicle:repair()
    if not self:isValid() then return false end

    SetVehicleFixed(self.vehicle)
    SetVehicleDeformationFixed(self.vehicle)
    SetVehicleUndriveable(self.vehicle, false)
    SetVehicleEngineOn(self.vehicle, true, true, true)

    return true
end

function lib.vehicle:getFuelLevel()
    if not self:isValid() then return 0.0 end
    return GetVehicleFuelLevel(self.vehicle)
end

function lib.vehicle:setFuelLevel(level)
    if not self:isValid() then return false end
    if level < 0 or level > 100.0 then return false end
    SetVehicleFuelLevel(self.vehicle, level + 0.0)
    return true
end

function lib.vehicle:isLocked()
    if not self:isValid() then return false end
    return GetVehicleDoorLockStatus(self.vehicle) ~= 0
end

function lib.vehicle:setLocked(state)
    if not self:isValid() then return false end
    SetVehicleDoorsLocked(self.vehicle, state and 2 or 1)
    return true
end

---Set vehicle locked state and sync
---@param state boolean Lock state
---@return boolean success
function lib.vehicle:setLockedAndSync(state)
    if not self:isValid() then return false end
    
    local success = self:setLocked(state)
    if success then
        self:setState('isLocked', state, true)
    end
    
    return success
end

---Set engine state and sync
---@param state boolean Engine state
---@return boolean success
function lib.vehicle:setEngineAndSync(state)
    if not self:isValid() then return false end
    
    local success = self:setEngineOn(state)
    if success then
        self:setState('engineOn', state, true)
    end
    
    return success
end

---Set fuel level and sync
---@param level number Fuel level (0-100)
---@return boolean success
function lib.vehicle:setFuelAndSync(level)
    if not self:isValid() then return false end
    
    local success = self:setFuelLevel(level)
    if success then
        self:setState('fuelLevel', level, true)
    end
    
    return success
end

function lib.vehicle:openDoor(door, loose, instantly)
    if not self:isValid() then return false end
    
    local doorIndex = door
    if type(door) == 'string' then
        doorIndex = lib.enums.vehicles.DOORS[door]
        if not doorIndex then return false end
    elseif type(door) ~= 'number' then
        return false
    end
    
    SetVehicleDoorOpen(self.vehicle, doorIndex, loose or false, instantly or false)
    return true
end

function lib.vehicle:closeDoor(door, instantly)
    if not self:isValid() then return false end
    
    local doorIndex = door
    if type(door) == 'string' then
        doorIndex = lib.enums.vehicles.DOORS[door]
        if not doorIndex then return false end
    elseif type(door) ~= 'number' then
        return false
    end
    
    SetVehicleDoorShut(self.vehicle, doorIndex, instantly or false)
    return true
end

function lib.vehicle:isDoorDamaged(door)
    if not self:isValid() then return false end
    
    local doorIndex = door
    if type(door) == 'string' then
        doorIndex = lib.enums.vehicles.DOORS[door]
        if not doorIndex then return false end
    elseif type(door) ~= 'number' then
        return false
    end
    
    return IsVehicleDoorDamaged(self.vehicle, doorIndex)
end

function lib.vehicle:breakDoor(door, deleteDoor)
    if not self:isValid() then return false end
    
    local doorIndex = door
    if type(door) == 'string' then
        doorIndex = lib.enums.vehicles.DOORS[door]
        if not doorIndex then return false end
    elseif type(door) ~= 'number' then
        return false
    end
    
    SetVehicleDoorBroken(self.vehicle, doorIndex, deleteDoor or false)
    return true
end

function lib.vehicle:rollDownWindow(window)
    if not self:isValid() then return false end
    
    local windowIndex = window
    if type(window) == 'string' then
        windowIndex = lib.enums.vehicles.WINDOWS[window]
        if not windowIndex then return false end
    elseif type(window) ~= 'number' then
        return false
    end
    
    RollDownWindow(self.vehicle, windowIndex)
    return true
end

function lib.vehicle:rollUpWindow(window)
    if not self:isValid() then return false end
    
    local windowIndex = window
    if type(window) == 'string' then
        windowIndex = lib.enums.vehicles.WINDOWS[window]
        if not windowIndex then return false end
    elseif type(window) ~= 'number' then
        return false
    end
    
    RollUpWindow(self.vehicle, windowIndex)
    return true
end

function lib.vehicle:isWindowIntact(window)
    if not self:isValid() then return false end
    
    local windowIndex = window
    if type(window) == 'string' then
        windowIndex = lib.enums.vehicles.WINDOWS[window]
        if not windowIndex then return false end
    elseif type(window) ~= 'number' then
        return false
    end
    
    return IsVehicleWindowIntact(self.vehicle, windowIndex)
end

function lib.vehicle:smashWindow(window)
    if not self:isValid() then return false end
    
    local windowIndex = window
    if type(window) == 'string' then
        windowIndex = lib.enums.vehicles.WINDOWS[window]
        if not windowIndex then return false end
    elseif type(window) ~= 'number' then
        return false
    end
    
    SmashVehicleWindow(self.vehicle, windowIndex)
    return true
end

function lib.vehicle:getClass()
    if not self:isValid() then return nil end
    local classId = GetVehicleClass(self.vehicle)

    for className, enumClassId in pairs(lib.enums.vehicles.CLASSES) do
        if enumClassId == classId then
            return className, classId
        end
    end

    return nil, classId
end

function lib.vehicle:isClass(className)
    local currentClass = self:getClass()
    return currentClass == className
end

function lib.vehicle:getMod(modName)
    if not self:isValid() then return nil end
    local modIndex = lib.enums.vehicles.MODS[modName]
    if modIndex then
        return GetVehicleMod(self.vehicle, modIndex)
    end
    return nil
end

function lib.vehicle:setMod(modName, modValue)
    if not self:isValid() then return false end
    local modIndex = lib.enums.vehicles.MODS[modName]
    if modIndex then
        SetVehicleMod(self.vehicle, modIndex, modValue, false)
        return true
    end
    return false
end

function lib.vehicle:getColorName()
    if not self:isValid() then return nil end
    local primaryColor, secondaryColor = GetVehicleColours(self.vehicle)

    for colorName, colorId in pairs(lib.enums.vehicles.COLORS) do
        if colorId == primaryColor then
            return colorName, primaryColor, secondaryColor
        end
    end

    return nil, primaryColor, secondaryColor
end

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

---Get complete vehicle properties using ox_lib system
---@return table? properties Complete vehicle properties table
function lib.vehicle:getProperties()
    if not self:isValid() then return nil end
    return lib.getVehicleProperties(self.vehicle)
end

---Set complete vehicle properties using ox_lib system
---@param properties table Vehicle properties table
---@param fixVehicle? boolean Fix vehicle after setting properties
---@return boolean success True if properties were set successfully
function lib.vehicle:setProperties(properties, fixVehicle)
    if not self:isValid() then return false end
    if type(properties) ~= 'table' then return false end
    
    local success, result = pcall(lib.setVehicleProperties, self.vehicle, properties, fixVehicle)
    return success
end

-- =====================================
-- DELETION FUNCTIONS
-- =====================================

function lib.vehicle:delete(callback)
    if not self:isValid() then
        if callback then callback(false, 'Invalid vehicle') end
        return false
    end

    local vehicleEntity = self.vehicle

    DeleteVehicle(vehicleEntity)

    local success = not DoesEntityExist(vehicleEntity)

    if success then
        self.vehicle = nil
        if callback then callback(true, 'Vehicle deleted successfully') end
    else
        if callback then callback(false, 'Could not delete vehicle') end
    end

    return success
end

function lib.vehicle.deleteEntity(vehicleEntity, callback)
    if not vehicleEntity or vehicleEntity == 0 or not DoesEntityExist(vehicleEntity) then
        if callback then callback(false, 'Invalid vehicle entity') end
        return false
    end

    DeleteVehicle(vehicleEntity)

    local success = not DoesEntityExist(vehicleEntity)

    if success then
        if callback then callback(true, 'Vehicle deleted successfully') end
    else
        if callback then callback(false, 'Could not delete vehicle') end
    end

    return success
end

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

    for i, vehicle in ipairs(vehicles) do
        local vehicleEntity = vehicle

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

function lib.vehicle.deleteInArea(coords, radius, callback, filterFunction)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        if callback then callback(false, 'Invalid coordinates') end
        return false
    end

    radius = radius or 10.0

    local areaCoords = coords
    if type(coords) == 'table' then
        areaCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local nearbyVehicles = lib.getNearbyVehicles(areaCoords, radius, true)
    local vehiclesToDelete = {}

    for _, vehicleData in ipairs(nearbyVehicles) do
        local shouldDelete = true

        if filterFunction and type(filterFunction) == 'function' then
            shouldDelete = filterFunction(vehicleData.vehicle, vehicleData)
        end

        if shouldDelete then
            table.insert(vehiclesToDelete, vehicleData.vehicle)
        end
    end

    lib.vehicle.deleteMultiple(vehiclesToDelete, function(success, message, results)
        if callback then
            callback(success, message, results, #vehiclesToDelete)
        end
    end)

    return true
end

-- =====================================
-- STATIC UTILITY FUNCTIONS
-- =====================================

---Static function to calculate safe distance between two vehicles
---@param vehicle1 number First vehicle entity
---@param vehicle2 number Second vehicle entity
---@return number distance Safe distance needed between vehicles
function lib.vehicle.calculateSafeDistance(vehicle1, vehicle2)
    if not DoesEntityExist(vehicle1) or not DoesEntityExist(vehicle2) then
        return 5.0
    end
    
    local v1_dimensions = lib.vehicle.fromEntity(vehicle1):getDimensions()
    local v2_dimensions = lib.vehicle.fromEntity(vehicle2):getDimensions()
    
    local v1_length = v1_dimensions and v1_dimensions.length or 4.0
    local v2_length = v2_dimensions and v2_dimensions.length or 4.0
    
    return (v1_length / 2) + (v2_length / 2) + 2.0
end

---Static function to find spawn position around any coordinates
---@param coords vector3 Center coordinates
---@param vehicleModel string|number Vehicle model to calculate space for
---@param preferredSide? string Preferred side
---@return vector3? position Best spawn position
function lib.vehicle.findSpawnPosition(coords, vehicleModel, preferredSide)
    local modelHash = type(vehicleModel) == 'string' and joaat(vehicleModel) or vehicleModel
    local min, max = GetModelDimensions(modelHash)
    local length = max.y - min.y
    local width = max.x - min.x
    
    local testPositions = {
        front = coords + vector3(0, length + 2.5, 0),
        rear = coords + vector3(0, -(length + 2.5), 0),
        left = coords + vector3(-(width + 2.0), 0, 0),
        right = coords + vector3(width + 2.0, 0, 0)
    }
    
    if preferredSide and testPositions[preferredSide] then
        local nearbyVehicles = lib.getNearbyVehicles(testPositions[preferredSide], 3.0, true)
        if #nearbyVehicles == 0 then
            return testPositions[preferredSide]
        end
    end
    
    for side, position in pairs(testPositions) do
        if side ~= preferredSide then
            local nearbyVehicles = lib.getNearbyVehicles(position, 3.0, true)
            if #nearbyVehicles == 0 then
                return position
            end
        end
    end
    
    return nil
end

-- =====================================
-- EVENT HANDLERS AND INITIALIZATION
-- =====================================

---Listen for vehicle property changes via StateBags
local function setupVehicleStateListener()
    AddStateBagChangeHandler('vehicleProperties', nil, function(bagName, key, value, source, replicated)
        if replicated then return end
        
        local entityNetId = tonumber(bagName:gsub('entity:', ''))
        if not entityNetId then return end
        
        local entity = NetworkGetEntityFromNetworkId(entityNetId)
        if not entity or not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then return end
        
        if entity ~= cache.vehicle then
            local vehicleInstance = lib.vehicle.fromEntity(entity)
            if vehicleInstance and value then
                vehicleInstance:setProperties(value)
            end
        end
    end)
end

CreateThread(setupVehicleStateListener)

---Auto-sync when player enters vehicle
AddEventHandler('ox:playerEnteredVehicle', function(vehicle, seat)
    local vehicleInstance = lib.vehicle.fromEntity(vehicle)
    if vehicleInstance then
        vehicleInstance:initSync()
    end
end)

---Handle trailer attachment updates from server
RegisterNetEvent('ox_lib:trailerAttachmentUpdate', function(data)
    local towVehicle = NetworkGetEntityFromNetworkId(data.towVehicle)
    local trailer = data.trailer and NetworkGetEntityFromNetworkId(data.trailer) or nil
    
    if DoesEntityExist(towVehicle) then
        local vehicleInstance = lib.vehicle.fromEntity(towVehicle)
        if vehicleInstance then
            if data.attached and trailer and DoesEntityExist(trailer) then
                vehicleInstance:setState('trailerAttached', data.trailer, false)
            else
                vehicleInstance:setState('trailerAttached', nil, false)
            end
        end
    end
end)

-- =====================================
-- ENUMS EXTENSION
-- =====================================

if not lib.enums.vehicles.TOW_CAPABLE then
    lib.enums.vehicles.TOW_CAPABLE = {
        ['UTILITY'] = true,
        ['COMMERCIAL'] = true,
        ['INDUSTRIAL'] = true,
        ['SERVICE'] = true
    }
end

if not lib.enums.vehicles.TOWABLE then
    lib.enums.vehicles.TOWABLE = {
        ['COMPACTS'] = true,
        ['SEDANS'] = true,
        ['SUVS'] = true,
        ['COUPES'] = true,
        ['SPORTS'] = true,
        ['SPORTS_CLASSICS'] = true,
        ['SUPER'] = true,
        ['MUSCLE'] = true,
        ['OFF_ROAD'] = true,
        ['MOTORCYCLES'] = true
    }
end

return lib.vehicle

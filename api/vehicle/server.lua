
---@meta

---@class VehicleCreateOptions
---@field plate? string License plate text
---@field type? string Vehicle type ('automobile', 'bike', 'boat', 'heli', 'plane', 'submarine', 'trailer', 'train')
---@field properties? table Vehicle properties to apply after creation
---@field networked? boolean Whether vehicle should be networked (default: true)

---@class lib.vehicle
---@field vehicle number? The vehicle entity this instance controls
lib.vehicle = lib.class("vehicle")

---Vehicle API Class - Server Side
---Vehicle management system for server-side
---@param vehicle? number If passed, it's for that specific vehicle. If not passed, creates empty instance
---@return lib.vehicle
function lib.vehicle:constructor(vehicle)
    if vehicle then
        if DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            self.vehicle = vehicle
        else
            self.vehicle = nil
        end
    else
        self.vehicle = nil
    end
end

-- =====================================
-- VALIDATION FUNCTIONS
-- =====================================

---Check if the vehicle instance is valid
---@return boolean valid True if vehicle exists and is valid
function lib.vehicle:isValid()
    return self.vehicle and self.vehicle ~= 0 and DoesEntityExist(self.vehicle) and GetEntityType(self.vehicle) == 2
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
    if vehicle and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
        self.vehicle = vehicle
        return true
    end
    return false
end

---Static function to create an instance from any vehicle entity
---@param vehicle number Vehicle entity
---@return lib.vehicle? instance Vehicle instance or nil if invalid
function lib.vehicle.fromEntity(vehicle)
    if vehicle and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
        return lib.vehicle:new(vehicle)
    end
    return nil
end

-- =====================================
-- CREATION FUNCTIONS
-- =====================================

---Static function to create a vehicle
---@param model string|number Vehicle model name or hash
---@param coords vector3|table Vehicle spawn coordinates
---@param heading? number Vehicle heading in degrees (default: 0.0)
---@param options? VehicleCreateOptions Additional creation options
---@return lib.vehicle? instance Vehicle instance or nil if failed
function lib.vehicle.create(model, coords, heading, options)
    options = options or {}

    if type(model) ~= 'string' and type(model) ~= 'number' then
        return nil
    end

    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return nil
    end

    heading = heading or 0.0

    local vehicleCoords = coords
    if type(coords) == 'table' then
        vehicleCoords = vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local modelHash = type(model) == 'string' and joaat(model) or model

    local vehicleType = options.type or 'automobile'

    local vehicle = CreateVehicleServerSetter(modelHash, vehicleType, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, heading)

    if not vehicle or vehicle == 0 then
        return nil
    end

    local vehicleInstance = lib.vehicle:new(vehicle)

    if options.plate then
        SetVehicleNumberPlateText(vehicle, options.plate)
    end

    if options.properties then
        lib.setVehicleProperties(vehicle, options.properties)
    end

    return vehicleInstance
end

---Static function to create multiple vehicles
---@param vehicles table[] List of vehicle creation data
---@return lib.vehicle[] instances Array of created vehicle instances
function lib.vehicle.createMultiple(vehicles)
    local results = {}

    for i, vehicleData in ipairs(vehicles) do
        local instance = lib.vehicle.create(
            vehicleData.model,
            vehicleData.coords,
            vehicleData.heading,
            vehicleData.options
        )
        results[i] = instance
    end

    return results
end

-- =====================================
-- SERVER FUNCTIONS
-- =====================================

function lib.vehicle:getModel()
    if not self:isValid() then return nil end
    return GetEntityModel(self.vehicle)
end

function lib.vehicle:getCoords()
    if not self:isValid() then return nil end
    return GetEntityCoords(self.vehicle)
end

function lib.vehicle:setCoords(coords, teleport)
    if not self:isValid() then return false end

    if type(coords) == 'vector3' then
        SetEntityCoords(self.vehicle, coords.x, coords.y, coords.z, false, false, false, teleport ~= false)
    elseif type(coords) == 'table' then
        SetEntityCoords(self.vehicle, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], false, false, false, teleport ~= false)
    else
        return false
    end

    return true
end

function lib.vehicle:getHeading()
    if not self:isValid() then return 0.0 end
    return GetEntityHeading(self.vehicle)
end

function lib.vehicle:setHeading(heading)
    if not self:isValid() then return false end
    SetEntityHeading(self.vehicle, heading)
    return true
end

function lib.vehicle:getRotation()
    if not self:isValid() then return nil end
    return GetEntityRotation(self.vehicle)
end

function lib.vehicle:setRotation(rotation)
    if not self:isValid() then return false end

    if type(rotation) == 'vector3' then
        SetEntityRotation(self.vehicle, rotation.x, rotation.y, rotation.z, 2)
    elseif type(rotation) == 'table' then
        SetEntityRotation(self.vehicle, rotation.x or rotation[1], rotation.y or rotation[2], rotation.z or rotation[3], 2)
    else
        return false
    end

    return true
end

function lib.vehicle:getEngineHealth()
    if not self:isValid() then return 0 end
    return GetVehicleEngineHealth(self.vehicle)
end

function lib.vehicle:setEngineHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehicleEngineHealth(self.vehicle, health + 0.0)
    return true
end

function lib.vehicle:getBodyHealth()
    if not self:isValid() then return 0 end
    return GetVehicleBodyHealth(self.vehicle)
end

function lib.vehicle:setBodyHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehicleBodyHealth(self.vehicle, health + 0.0)
    return true
end

function lib.vehicle:getPetrolTankHealth()
    if not self:isValid() then return 0 end
    return GetVehiclePetrolTankHealth(self.vehicle)
end

function lib.vehicle:setPetrolTankHealth(health)
    if not self:isValid() then return false end
    if health < 0 or health > 1000 then return false end
    SetVehiclePetrolTankHealth(self.vehicle, health + 0.0)
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

function lib.vehicle:isEngineOn()
    if not self:isValid() then return false end
    return GetIsVehicleEngineRunning(self.vehicle)
end

function lib.vehicle:setEngineOn(state, instantly)
    if not self:isValid() then return false end
    SetVehicleEngineOn(self.vehicle, state, instantly or false, true)
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

function lib.vehicle:repair()
    if not self:isValid() then return false end

    SetVehicleFixed(self.vehicle)
    SetVehicleDeformationFixed(self.vehicle)
    SetVehicleUndriveable(self.vehicle, false)
    SetVehicleEngineOn(self.vehicle, true, true, true)

    return true
end

function lib.vehicle:explode(damageSource, hasEntityDamage)
    if not self:isValid() then return false end

    damageSource = damageSource or 0
    hasEntityDamage = hasEntityDamage ~= false

    ExplodeVehicle(self.vehicle, hasEntityDamage, false)
    return true
end

function lib.vehicle:getDriver()
    if not self:isValid() then return nil end
    local driver = GetPedInVehicleSeat(self.vehicle, -1)
    return driver ~= 0 and driver or nil
end

function lib.vehicle:getPassenger(seatIndex)
    if not self:isValid() then return nil end
    local passenger = GetPedInVehicleSeat(self.vehicle, seatIndex)
    return passenger ~= 0 and passenger or nil
end

function lib.vehicle:getOccupants()
    if not self:isValid() then return {} end

    local occupants = {}
    local maxSeats = GetVehicleMaxNumberOfPassengers(self.vehicle)

    local driver = self:getDriver()
    if driver then
        occupants[-1] = driver
    end

    for seat = 0, maxSeats - 1 do
        local passenger = self:getPassenger(seat)
        if passenger then
            occupants[seat] = passenger
        end
    end

    return occupants
end

function lib.vehicle:hasFreeSeat()
    if not self:isValid() then return false end

    local maxSeats = GetVehicleMaxNumberOfPassengers(self.vehicle) + 1
    local occupants = self:getOccupants()

    local occupiedCount = 0
    for _ in pairs(occupants) do
        occupiedCount = occupiedCount + 1
    end

    return occupiedCount < maxSeats
end

function lib.vehicle:getFreeSeat()
    if not self:isValid() then return nil end

    if not self:getDriver() then
        return -1
    end

    local maxSeats = GetVehicleMaxNumberOfPassengers(self.vehicle)
    for seat = 0, maxSeats - 1 do
        if not self:getPassenger(seat) then
            return seat
        end
    end

    return nil
end

function lib.vehicle:setPlayerIntoVehicle(source, seat)
    if not self:isValid() then return false end

    seat = seat or -1

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        SetPedIntoVehicle(ped, self.vehicle, seat)
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

    lib.setVehicleProperties(self.vehicle, properties)
    return true
end

-- =====================================
-- MODIFICATION FUNCTIONS
-- =====================================

function lib.vehicle:setMod(mod, value)
    if not self:isValid() then return false end
    local props = {}
    if type(mod) == 'number' then
        props['mod' .. mod] = value
    elseif type(mod) == 'string' then
        if not mod:find('^mod') then
            mod = 'mod' .. mod:gsub("^%l", string.upper)
        end
        props[mod] = value
    else
        return false
    end
    lib.setVehicleProperties(self.vehicle, props)
    return true
end

function lib.vehicle:setMods(mods)
    if not self:isValid() then return false end
    if type(mods) ~= 'table' then return false end
    lib.setVehicleProperties(self.vehicle, mods)
    return true
end

function lib.vehicle:setExtra(extraId, enabled)
    if not self:isValid() then return false end
    local props = { extras = { [extraId] = enabled and 0 or 1 } }
    lib.setVehicleProperties(self.vehicle, props)
    return true
end

function lib.vehicle:setExtras(extras)
    if not self:isValid() then return false end
    if type(extras) ~= 'table' then return false end
    local props = { extras = extras }
    lib.setVehicleProperties(self.vehicle, props)
    return true
end

function lib.vehicle:setNeon(enabled, color)
    if not self:isValid() then return false end
    local props = {}
    if enabled ~= nil then
        if type(enabled) == 'table' then
            props.neonEnabled = enabled
        elseif type(enabled) == 'boolean' then
            props.neonEnabled = { enabled, enabled, enabled, enabled }
        end
    end
    if color then
        props.neonColor = color
    end
    lib.setVehicleProperties(self.vehicle, props)
    return true
end

-- =====================================
-- DELETION FUNCTIONS
-- =====================================

function lib.vehicle:delete()
    if not self:isValid() then return false end

    local vehicleEntity = self.vehicle
    DeleteEntity(vehicleEntity)

    local success = not DoesEntityExist(vehicleEntity)

    if success then
        self.vehicle = nil
    end

    return success
end

function lib.vehicle.deleteEntity(vehicleEntity)
    if not vehicleEntity or vehicleEntity == 0 or not DoesEntityExist(vehicleEntity) then
        return false
    end

    DeleteEntity(vehicleEntity)
    return not DoesEntityExist(vehicleEntity)
end

function lib.vehicle.deleteMultiple(vehicles)
    local results = {}

    for i, vehicle in ipairs(vehicles) do
        local vehicleEntity = vehicle

        if type(vehicle) == 'table' and vehicle.vehicle then
            vehicleEntity = vehicle.vehicle
        end

        results[i] = lib.vehicle.deleteEntity(vehicleEntity)
    end

    return results
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Static function to get all vehicles
---@return number[] vehicles Array of all vehicle entities
function lib.vehicle.getAllVehicles()
    return GetAllVehicles()
end

---Static function to get vehicles in area
---@param coords vector3|table Center coordinates
---@param radius? number Search radius (default: 50.0)
---@return table[] vehicles Array of nearby vehicles with distance info
function lib.vehicle.getVehiclesInArea(coords, radius)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
        return {}
    end

    radius = radius or 50.0

    local vehicles = lib.vehicle.getAllVehicles()
    local nearbyVehicles = {}
    local centerCoords = type(coords) == 'vector3' and coords or vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(centerCoords - vehicleCoords)

        if distance <= radius then
            table.insert(nearbyVehicles, {
                vehicle = vehicle,
                coords = vehicleCoords,
                distance = distance,
                instance = lib.vehicle.fromEntity(vehicle)
            })
        end
    end

    table.sort(nearbyVehicles, function(a, b)
        return a.distance < b.distance
    end)

    return nearbyVehicles
end

---Static function to get player's vehicle
---@param source number Player source
---@return lib.vehicle? instance Vehicle instance or nil if player not in vehicle
function lib.vehicle.getPlayerVehicle(source)
    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 and IsPedInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle and vehicle ~= 0 then
            return lib.vehicle.fromEntity(vehicle)
        end
    end
    return nil
end

-- =====================================
-- SYNC SYSTEM SERVER EVENTS
-- =====================================

---Validate if player has access to vehicle
---@param playerId number Player ID
---@param networkId number Vehicle network ID
---@return boolean hasAccess True if player has access
function lib.vehicle.hasAccess(playerId, networkId)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if not DoesEntityExist(vehicle) then return false end
    
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleCoords = GetEntityCoords(vehicle)
    
    if #(playerCoords - vehicleCoords) > 10.0 then return false end
    
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if driver == playerPed then return true end
    
    return true
end

---Handle vehicle properties changes
RegisterNetEvent('ox_lib:vehiclePropertiesChanged', function(networkId, properties)
    local source = source
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    
    if not DoesEntityExist(vehicle) then return end
    
    if not lib.vehicle.hasAccess(source, networkId) then
        print(('Player %s attempted to modify vehicle %s without permission'):format(source, networkId))
        return
    end
end)

---Handle trailer attachment sync
RegisterNetEvent('ox_lib:syncTrailerAttachment', function(data)
    local source = source
    
    if not lib.vehicle.hasAccess(source, data.towVehicle) then
        return
    end
    
    TriggerClientEvent('ox_lib:trailerAttachmentUpdate', -1, data)
end)

return lib.vehicle

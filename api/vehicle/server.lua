---@meta

---@class lib.vehicle
---@field spawn fun(model: string | number, coords: vector3 | table, heading?: number, properties?: table, isTemporary?: boolean): number | nil
---@field despawn fun(entity: number, force?: boolean): boolean
---@field setProperties fun(entity: number, properties: table): boolean
---@field getProperties fun(entity: number): table | nil
---@field isValidVehicle fun(entity: number): boolean
---@field giveKeys fun(entity: number, playerId: number): boolean
---@field removeKeys fun(entity: number, playerId: number): boolean
---@field hasKeys fun(entity: number, playerId: number): boolean
---@field setOwner fun(entity: number, playerId: number): boolean
---@field getOwner fun(entity: number): number | nil
---@field setTuning fun(entity: number, tuning: table): boolean
---@field getTuning fun(entity: number): table | nil
---@field setUpgrades fun(entity: number, upgrades: table): boolean
---@field getUpgrades fun(entity: number): table | nil
---@field heal fun(entity: number): boolean
---@field lock fun(entity: number, state: number): boolean
---@field unlock fun(entity: number): boolean
---@field isLocked fun(entity: number): boolean
---@field getEngineHealth fun(entity: number): number | nil
---@field setEngineHealth fun(entity: number, health: number): boolean
---@field getBodyHealth fun(entity: number): number | nil
---@field setBodyHealth fun(entity: number, health: number): boolean
---@field setPetrolTankHealth fun(entity: number, health: number): boolean
---@field getPetrolTankHealth fun(entity: number): number | nil
---@field repair fun(entity: number): boolean
---@field setDirt fun(entity: number, level: number): boolean
---@field getDirt fun(entity: number): number | nil
---@field wash fun(entity: number): boolean
---@field setPlate fun(entity: number, plate: string): boolean
---@field getPlate fun(entity: number): string | nil
---@field generatePlate fun(): string
---@field isPlateAvailable fun(plate: string): boolean
---@field setLivery fun(entity: number, livery: number): boolean
---@field getLivery fun(entity: number): number | nil
---@field getMaxLiveries fun(entity: number): number
---@field setRoofLivery fun(entity: number, livery: number): boolean
---@field getRoofLivery fun(entity: number): number | nil
---@field getMaxRoofLiveries fun(entity: number): number
---@field setNumberPlateTextIndex fun(entity: number, plateIndex: number): boolean
---@field getNumberPlateTextIndex fun(entity: number): number | nil
---@field setMod fun(entity: number, modType: number, modIndex: number, customTires?: boolean): boolean
---@field getMod fun(entity: number, modType: number): number | nil
---@field removeMod fun(entity: number, modType: number): boolean
---@field setNeonLights fun(entity: number, left: boolean, right: boolean, front: boolean, back: boolean): boolean
---@field getNeonLights fun(entity: number): table | nil
---@field setNeonColor fun(entity: number, r: number, g: number, b: number): boolean
---@field getNeonColor fun(entity: number): table | nil
---@field setTyreSmokeColor fun(entity: number, r: number, g: number, b: number): boolean
---@field getTyreSmokeColor fun(entity: number): table | nil
---@field setWindowTint fun(entity: number, tint: number): boolean
---@field getWindowTint fun(entity: number): number | nil
---@field setXenonLights fun(entity: number, enabled: boolean, color?: number): boolean
---@field getXenonLights fun(entity: number): table | nil
---@field setTurbo fun(entity: number, enabled: boolean): boolean
---@field getTurbo fun(entity: number): boolean | nil
---@field setHorn fun(entity: number, hornId: number): boolean
---@field getHorn fun(entity: number): number | nil
---@field setExtra fun(entity: number, extraId: number, enabled: boolean): boolean
---@field getExtra fun(entity: number, extraId: number): boolean | nil
---@field setFuel fun(entity: number, fuel: number): boolean
---@field getFuel fun(entity: number): number | nil
---@field setOilLevel fun(entity: number, oil: number): boolean
---@field getOilLevel fun(entity: number): number | nil
---@field getVehicleData fun(entity: number): table | nil
---@field saveVehicle fun(entity: number, owner?: number): table | nil
---@field loadVehicle fun(data: table, coords?: vector3 | table, heading?: number): number | nil

-- Vehicle cache for tracking spawned vehicles
local spawnedVehicles = {}
local vehicleKeys = {}
local vehicleOwners = {}

-- Vehicle API - Server Side
local vehicle = {}

-- =====================================
-- VEHICLE SPAWNING AND MANAGEMENT
-- =====================================

---Spawns a vehicle at specified coordinates
---@param model string | number Vehicle model hash or name
---@param coords vector3 | table Spawn coordinates
---@param heading? number Vehicle heading (default: 0.0)
---@param properties? table Vehicle properties to apply
---@param isTemporary? boolean Whether vehicle should be cleaned up automatically
---@return number | nil entity Vehicle entity handle or nil if failed
function vehicle.spawn(model, coords, heading, properties, isTemporary)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end

    if type(coords) == 'table' and coords.x then
        coords = vector3(coords.x, coords.y, coords.z)
    end

    local entity = CreateVehicleServerSetter(model, 'automobile', coords.x, coords.y, coords.z, heading or 0.0)

    if not DoesEntityExist(entity) then
        lib.logger:error('vehicle', 'Failed to spawn vehicle model: %s', model)
        return nil
    end

    -- Apply properties if provided
    if properties then
        vehicle.setProperties(entity, properties)
    end

    -- Track spawned vehicle
    spawnedVehicles[entity] = {
        model = model,
        spawned = GetGameTimer(),
        isTemporary = isTemporary or false,
        coords = coords,
        heading = heading
    }

    lib.logger:debug('vehicle', 'Vehicle spawned - Entity: %s, Model: %s', entity, model)
    return entity
end

---Despawns a vehicle entity
---@param entity number Vehicle entity handle
---@param force? boolean Force deletion even if occupied
---@return boolean success Whether vehicle was successfully deleted
function vehicle.despawn(entity, force)
    if not DoesEntityExist(entity) then
        lib.logger:warn('vehicle', 'Invalid vehicle entity: %s', entity)
        return false
    end

    TaskEveryoneLeaveVehicle(entity)

    -- Clean up tracking data
    spawnedVehicles[entity] = nil
    vehicleKeys[entity] = nil
    vehicleOwners[entity] = nil

    DeleteEntity(entity)
    lib.logger:debug('vehicle', 'Vehicle despawned - Entity: %s', entity)
    return true
end

---Checks if entity is a valid vehicle
---@param entity number Entity handle to check
---@return boolean isValid Whether entity is a valid vehicle
function vehicle.isValidVehicle(entity)
    return DoesEntityExist(entity)
end

-- =====================================
-- VEHICLE PROPERTIES
-- =====================================

---Sets vehicle properties from a table
---@param entity number Vehicle entity handle
---@param properties table Properties table (from ox_lib vehicleProperties)
---@return boolean success Whether properties were applied successfully
function vehicle.setProperties(entity, properties)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server can only set StateBag, actual property application happens on client
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if not netId then
        lib.logger:warn('vehicle', 'Cannot set properties - entity not networked: %s', entity)
        return false
    end

    -- This triggers client-side property application via StateBag listener
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)

    lib.logger:debug('vehicle', 'Properties requested for vehicle: %s (NetID: %s)', entity, netId)
    return true
end

---Gets vehicle properties as a table
---@param entity number Vehicle entity handle
---@return table | nil properties Vehicle properties or nil if failed
function vehicle.getProperties(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get detailed properties - this must be handled client-side
    -- Return cached StateBag data if available, or request from client
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties

    if cachedProperties then
        return cachedProperties
    end

    lib.logger:warn('vehicle', 'Properties not available on server for entity: %s - use client-side getVehicleProperties', entity)
    return nil
end

-- =====================================
-- VEHICLE KEYS AND OWNERSHIP
-- =====================================

---Gives keys to a player for a vehicle
---@param entity number Vehicle entity handle
---@param playerId number Player server ID
---@return boolean success Whether keys were given successfully
function vehicle.giveKeys(entity, playerId)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    if not vehicleKeys[entity] then
        vehicleKeys[entity] = {}
    end

    vehicleKeys[entity][playerId] = true
    lib.logger:debug('vehicle', 'Keys given to player %s for vehicle: %s', playerId, entity)
    return true
end

---Removes keys from a player for a vehicle
---@param entity number Vehicle entity handle
---@param playerId number Player server ID
---@return boolean success Whether keys were removed successfully
function vehicle.removeKeys(entity, playerId)
    if not vehicle.isValidVehicle(entity) or not vehicleKeys[entity] then
        return false
    end

    vehicleKeys[entity][playerId] = nil
    lib.logger:debug('vehicle', 'Keys removed from player %s for vehicle: %s', playerId, entity)
    return true
end

---Checks if a player has keys for a vehicle
---@param entity number Vehicle entity handle
---@param playerId number Player server ID
---@return boolean hasKeys Whether player has keys
function vehicle.hasKeys(entity, playerId)
    if not vehicle.isValidVehicle(entity) or not vehicleKeys[entity] then
        return false
    end

    return vehicleKeys[entity][playerId] == true
end

---Sets the owner of a vehicle
---@param entity number Vehicle entity handle
---@param playerId number Player server ID
---@return boolean success Whether ownership was set
function vehicle.setOwner(entity, playerId)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    vehicleOwners[entity] = playerId
    vehicle.giveKeys(entity, playerId) -- Owner automatically gets keys
    lib.logger:debug('vehicle', 'Owner set to player %s for vehicle: %s', playerId, entity)
    return true
end

---Gets the owner of a vehicle
---@param entity number Vehicle entity handle
---@return number | nil ownerId Player server ID or nil if no owner
function vehicle.getOwner(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return vehicleOwners[entity]
end

-- =====================================
-- VEHICLE MODIFICATIONS
-- =====================================

---Sets vehicle tuning (performance modifications)
---@param entity number Vehicle entity handle
---@param tuning table Tuning modifications
---@return boolean success Whether tuning was applied
function vehicle.setTuning(entity, tuning)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot apply tuning directly - delegate to client via properties
    local properties = { tuning = tuning }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)

    lib.logger:debug('vehicle', 'Tuning requested for vehicle: %s', entity)
    return true
end

---Gets vehicle tuning modifications
---@param entity number Vehicle entity handle
---@return table | nil tuning Tuning modifications or nil
function vehicle.getTuning(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get tuning details - must be handled client-side
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties

    if cachedProperties and cachedProperties.tuning then
        return cachedProperties.tuning
    end

    lib.logger:warn('vehicle', 'Tuning data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle upgrades (turbo, armor, etc.)
---@param entity number Vehicle entity handle
---@param upgrades table Upgrade modifications
---@return boolean success Whether upgrades were applied
function vehicle.setUpgrades(entity, upgrades)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot apply upgrades directly - delegate to client via properties
    local properties = {
        modTurbo = upgrades.turbo,
        modXenon = upgrades.xenon,
        bulletProofTyres = upgrades.bulletProofTyres
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)

    lib.logger:debug('vehicle', 'Upgrades requested for vehicle: %s', entity)
    return true
end

---Gets vehicle upgrades
---@param entity number Vehicle entity handle
---@return table | nil upgrades Vehicle upgrades or nil
function vehicle.getUpgrades(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get upgrade details - must be handled client-side
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties

    if cachedProperties then
        return {
            turbo = cachedProperties.modTurbo,
            xenon = cachedProperties.modXenon,
            bulletProofTyres = cachedProperties.bulletProofTyres
        }
    end

    lib.logger:warn('vehicle', 'Upgrade data not available on server for entity: %s - use client-side', entity)
    return nil
end

-- =====================================
-- VEHICLE HEALTH AND REPAIR
-- =====================================

---Heals a vehicle to full health
---@param entity number Vehicle entity handle
---@return boolean success Whether vehicle was healed
function vehicle.heal(entity)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot apply visual fixes directly - delegate to client
    local properties = {
        engineHealth = 1000.0,
        bodyHealth = 1000.0,
        tankHealth = 1000.0
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)

    lib.logger:debug('vehicle', 'Vehicle heal requested: %s', entity)
    return true
end

---Repairs a vehicle
---@param entity number Vehicle entity handle
---@return boolean success Whether vehicle was repaired
function vehicle.repair(entity)
    return vehicle.heal(entity)
end

---Gets vehicle engine health
---@param entity number Vehicle entity handle
---@return number | nil health Engine health (0-1000) or nil
function vehicle.getEngineHealth(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleEngineHealth(entity)
end

---Sets vehicle engine health
---@param entity number Vehicle entity handle
---@param health number Engine health (0-1000)
---@return boolean success Whether health was set
function vehicle.setEngineHealth(entity, health)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleEngineHealth(entity, health)
    return true
end

---Gets vehicle body health
---@param entity number Vehicle entity handle
---@return number | nil health Body health (0-1000) or nil
function vehicle.getBodyHealth(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleBodyHealth(entity)
end

---Sets vehicle body health
---@param entity number Vehicle entity handle
---@param health number Body health (0-1000)
---@return boolean success Whether health was set
function vehicle.setBodyHealth(entity, health)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleBodyHealth(entity, health)
    return true
end

---Gets vehicle petrol tank health
---@param entity number Vehicle entity handle
---@return number | nil health Petrol tank health (0-1000) or nil
function vehicle.getPetrolTankHealth(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehiclePetrolTankHealth(entity)
end

---Sets vehicle petrol tank health
---@param entity number Vehicle entity handle
---@param health number Petrol tank health (0-1000)
---@return boolean success Whether health was set
function vehicle.setPetrolTankHealth(entity, health)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehiclePetrolTankHealth(entity, health)
    return true
end

-- =====================================
-- VEHICLE LOCKING
-- =====================================

---Locks a vehicle with specified lock state
---@param entity number Vehicle entity handle
---@param state number Lock state (0-4)
---@return boolean success Whether vehicle was locked
function vehicle.lock(entity, state)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleDoorsLocked(entity, state)
    lib.logger:debug('vehicle', 'Vehicle locked with state %s: %s', state, entity)
    return true
end

---Unlocks a vehicle
---@param entity number Vehicle entity handle
---@return boolean success Whether vehicle was unlocked
function vehicle.unlock(entity)
    return vehicle.lock(entity, 1) -- Unlocked
end

---Checks if vehicle is locked
---@param entity number Vehicle entity handle
---@return boolean locked Whether vehicle is locked
function vehicle.isLocked(entity)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    return GetVehicleDoorLockStatus(entity) ~= 1
end

-- =====================================
-- VEHICLE APPEARANCE
-- =====================================

---Sets vehicle dirt level
---@param entity number Vehicle entity handle
---@param level number Dirt level (0.0-15.0)
---@return boolean success Whether dirt was applied
function vehicle.setDirt(entity, level)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleDirtLevel(entity, level)
    return true
end

---Gets vehicle dirt level
---@param entity number Vehicle entity handle
---@return number | nil level Dirt level or nil
function vehicle.getDirt(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleDirtLevel(entity)
end

---Washes a vehicle (removes dirt)
---@param entity number Vehicle entity handle
---@return boolean success Whether vehicle was washed
function vehicle.wash(entity)
    return vehicle.setDirt(entity, 0.0)
end

-- =====================================
-- VEHICLE PLATES
-- =====================================

---Sets vehicle license plate
---@param entity number Vehicle entity handle
---@param plate string License plate text
---@return boolean success Whether plate was set
function vehicle.setPlate(entity, plate)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleNumberPlateText(entity, plate)
    return true
end

---Gets vehicle license plate
---@param entity number Vehicle entity handle
---@return string | nil plate License plate text or nil
function vehicle.getPlate(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleNumberPlateText(entity)
end

---Generates a random license plate
---@return string plate Generated license plate
function vehicle.generatePlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local numbers = '0123456789'
    local plate = ''

    -- Generate format: XXX 000
    for i = 1, 3 do
        plate = plate .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end

    plate = plate .. ' '

    for i = 1, 3 do
        plate = plate .. numbers:sub(math.random(1, #numbers), math.random(1, #numbers))
    end

    return plate
end

---Checks if a license plate is available
---@param plate string License plate to check
---@return boolean available Whether plate is available
function vehicle.isPlateAvailable(plate)
    -- This would typically check against a database
    -- For now, return true as a placeholder
    return true
end

-- =====================================
-- VEHICLE LIVERIES
-- =====================================

---Sets vehicle livery
---@param entity number Vehicle entity handle
---@param livery number Livery index
---@return boolean success Whether livery was set
function vehicle.setLivery(entity, livery)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleLivery(entity, livery)
    return true
end

---Gets vehicle livery
---@param entity number Vehicle entity handle
---@return number | nil livery Current livery index or nil
function vehicle.getLivery(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleLivery(entity)
end

---Gets maximum liveries for vehicle
---@param entity number Vehicle entity handle
---@return number count Maximum livery count
function vehicle.getMaxLiveries(entity)
    if not vehicle.isValidVehicle(entity) then
        return 0
    end

    return GetVehicleLiveryCount(entity)
end

---Sets vehicle roof livery
---@param entity number Vehicle entity handle
---@param livery number Roof livery index
---@return boolean success Whether roof livery was set
function vehicle.setRoofLivery(entity, livery)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleRoofLivery(entity, livery)
    return true
end

---Gets vehicle roof livery
---@param entity number Vehicle entity handle
---@return number | nil livery Current roof livery index or nil
function vehicle.getRoofLivery(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleRoofLivery(entity)
end

---Gets maximum roof liveries for vehicle
---@param entity number Vehicle entity handle
---@return number count Maximum roof livery count
function vehicle.getMaxRoofLiveries(entity)
    if not vehicle.isValidVehicle(entity) then
        return 0
    end

    return GetVehicleRoofLiveryCount(entity)
end

-- =====================================
-- VEHICLE MODS
-- =====================================

---Sets a vehicle modification
---@param entity number Vehicle entity handle
---@param modType number Modification type
---@param modIndex number Modification index
---@param customTires? boolean Whether to use custom tires
---@return boolean success Whether mod was set
function vehicle.setMod(entity, modType, modIndex, customTires)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot apply mods directly - delegate to client
    local modKey = 'mod' .. modType
    local properties = { [modKey] = modIndex }
    if customTires ~= nil then
        properties['customTires' .. modType] = customTires
    end
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets a vehicle modification
---@param entity number Vehicle entity handle
---@param modType number Modification type
---@return number | nil modIndex Current mod index or nil
function vehicle.getMod(entity, modType)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get mod details - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        local modKey = 'mod' .. modType
        return cachedProperties[modKey]
    end

    lib.logger:warn('vehicle', 'Mod data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Removes a vehicle modification
---@param entity number Vehicle entity handle
---@param modType number Modification type
---@return boolean success Whether mod was removed
function vehicle.removeMod(entity, modType)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot remove mods directly - delegate to client
    local modKey = 'mod' .. modType
    local properties = { [modKey] = -1 }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

-- =====================================
-- ADVANCED FEATURES
-- =====================================

---Sets vehicle neon lights
---@param entity number Vehicle entity handle
---@param left boolean Left neon
---@param right boolean Right neon
---@param front boolean Front neon
---@param back boolean Back neon
---@return boolean success Whether neons were set
function vehicle.setNeonLights(entity, left, right, front, back)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set neons directly - delegate to client
    local properties = {
        neonEnabled = { left, right, front, back }
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle neon lights status
---@param entity number Vehicle entity handle
---@return table | nil neons Neon status table or nil
function vehicle.getNeonLights(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get neon details - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties and cachedProperties.neonEnabled then
        return {
            left = cachedProperties.neonEnabled[1],
            right = cachedProperties.neonEnabled[2],
            front = cachedProperties.neonEnabled[3],
            back = cachedProperties.neonEnabled[4]
        }
    end

    lib.logger:warn('vehicle', 'Neon data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle neon color
---@param entity number Vehicle entity handle
---@param r number Red value (0-255)
---@param g number Green value (0-255)
---@param b number Blue value (0-255)
---@return boolean success Whether color was set
function vehicle.setNeonColor(entity, r, g, b)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set neon color directly - delegate to client
    local properties = {
        neonColor = { r, g, b }
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle neon color
---@param entity number Vehicle entity handle
---@return table | nil color RGB color table or nil
function vehicle.getNeonColor(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get neon color - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties and cachedProperties.neonColor then
        local color = cachedProperties.neonColor
        return { r = color[1], g = color[2], b = color[3] }
    end

    lib.logger:warn('vehicle', 'Neon color not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle tire smoke color
---@param entity number Vehicle entity handle
---@param r number Red value (0-255)
---@param g number Green value (0-255)
---@param b number Blue value (0-255)
---@return boolean success Whether color was set
function vehicle.setTyreSmokeColor(entity, r, g, b)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set tyre smoke color directly - delegate to client
    local properties = {
        tyreSmokeColor = { r, g, b }
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle tire smoke color
---@param entity number Vehicle entity handle
---@return table | nil color RGB color table or nil
function vehicle.getTyreSmokeColor(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get tyre smoke color - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties and cachedProperties.tyreSmokeColor then
        local color = cachedProperties.tyreSmokeColor
        return { r = color[1], g = color[2], b = color[3] }
    end

    lib.logger:warn('vehicle', 'Tyre smoke color not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle window tint
---@param entity number Vehicle entity handle
---@param tint number Tint level (0-6)
---@return boolean success Whether tint was set
function vehicle.setWindowTint(entity, tint)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set window tint directly - delegate to client
    local properties = {
        windowTint = tint
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle window tint
---@param entity number Vehicle entity handle
---@return number | nil tint Tint level or nil
function vehicle.getWindowTint(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get window tint - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        return cachedProperties.windowTint
    end

    lib.logger:warn('vehicle', 'Window tint not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle xenon lights
---@param entity number Vehicle entity handle
---@param enabled boolean Whether xenon is enabled
---@param color? number Xenon color (0-12)
---@return boolean success Whether xenon was set
function vehicle.setXenonLights(entity, enabled, color)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set xenon directly - delegate to client
    local properties = {
        modXenon = enabled,
        xenonColor = color
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle xenon lights
---@param entity number Vehicle entity handle
---@return table | nil xenon Xenon status and color or nil
function vehicle.getXenonLights(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get xenon details - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        return {
            enabled = cachedProperties.modXenon,
            color = cachedProperties.xenonColor
        }
    end

    lib.logger:warn('vehicle', 'Xenon data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle turbo
---@param entity number Vehicle entity handle
---@param enabled boolean Whether turbo is enabled
---@return boolean success Whether turbo was set
function vehicle.setTurbo(entity, enabled)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set turbo directly - delegate to client
    local properties = {
        modTurbo = enabled
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle turbo status
---@param entity number Vehicle entity handle
---@return boolean | nil enabled Turbo status or nil
function vehicle.getTurbo(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get turbo status - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        return cachedProperties.modTurbo
    end

    lib.logger:warn('vehicle', 'Turbo status not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle horn
---@param entity number Vehicle entity handle
---@param hornId number Horn ID
---@return boolean success Whether horn was set
function vehicle.setHorn(entity, hornId)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set horn directly - delegate to client
    local properties = {
        modHorns = hornId
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle horn
---@param entity number Vehicle entity handle
---@return number | nil hornId Horn ID or nil
function vehicle.getHorn(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get horn details - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        return cachedProperties.modHorns
    end

    lib.logger:warn('vehicle', 'Horn data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle extra
---@param entity number Vehicle entity handle
---@param extraId number Extra ID
---@param enabled boolean Whether extra is enabled
---@return boolean success Whether extra was set
function vehicle.setExtra(entity, extraId, enabled)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set extras directly - delegate to client
    local properties = {
        extras = { [extraId] = enabled and 0 or 1 } -- Note: ox_lib uses inverted logic (0=enabled, 1=disabled)
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle extra status
---@param entity number Vehicle entity handle
---@param extraId number Extra ID
---@return boolean | nil enabled Extra status or nil
function vehicle.getExtra(entity, extraId)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get extra details - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties and cachedProperties.extras then
        local extraValue = cachedProperties.extras[extraId]
        return extraValue == 0 -- Note: ox_lib uses inverted logic (0=enabled, 1=disabled)
    end

    lib.logger:warn('vehicle', 'Extra data not available on server for entity: %s - use client-side', entity)
    return nil
end

---Sets vehicle number plate text index
---@param entity number Vehicle entity handle
---@param plateIndex number Plate index
---@return boolean success Whether plate index was set
function vehicle.setNumberPlateTextIndex(entity, plateIndex)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    -- Server cannot set plate index directly - delegate to client
    local properties = {
        plateIndex = plateIndex
    }
    Entity(entity).state:set('ox_lib:setVehicleProperties', properties, true)
    return true
end

---Gets vehicle number plate text index
---@param entity number Vehicle entity handle
---@return number | nil plateIndex Plate index or nil
function vehicle.getNumberPlateTextIndex(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    -- Server cannot get plate index - use cached properties
    local stateBag = Entity(entity).state
    local cachedProperties = stateBag and stateBag.vehicleProperties
    if cachedProperties then
        return cachedProperties.plateIndex
    end

    lib.logger:warn('vehicle', 'Plate index not available on server for entity: %s - use client-side', entity)
    return nil
end

-- =====================================
-- FUEL AND RESOURCES
-- =====================================

---Sets vehicle fuel level
---@param entity number Vehicle entity handle
---@param fuel number Fuel level (0-100)
---@return boolean success Whether fuel was set
function vehicle.setFuel(entity, fuel)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleFuelLevel(entity, fuel)
    return true
end

---Gets vehicle fuel level
---@param entity number Vehicle entity handle
---@return number | nil fuel Fuel level or nil
function vehicle.getFuel(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleFuelLevel(entity)
end

---Sets vehicle oil level
---@param entity number Vehicle entity handle
---@param oil number Oil level (0-100)
---@return boolean success Whether oil was set
function vehicle.setOilLevel(entity, oil)
    if not vehicle.isValidVehicle(entity) then
        return false
    end

    SetVehicleOilLevel(entity, oil)
    return true
end

---Gets vehicle oil level
---@param entity number Vehicle entity handle
---@return number | nil oil Oil level or nil
function vehicle.getOilLevel(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    return GetVehicleOilLevel(entity)
end

-- =====================================
-- DATA MANAGEMENT
-- =====================================

---Gets comprehensive vehicle data
---@param entity number Vehicle entity handle
---@return table | nil data Complete vehicle data or nil
function vehicle.getVehicleData(entity)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    local data = {
        entity = entity,
        model = GetEntityModel(entity),
        plate = vehicle.getPlate(entity),
        properties = vehicle.getProperties(entity),
        health = {
            engine = vehicle.getEngineHealth(entity),
            body = vehicle.getBodyHealth(entity),
            petrolTank = vehicle.getPetrolTankHealth(entity)
        },
        owner = vehicle.getOwner(entity),
        spawned = spawnedVehicles[entity] and spawnedVehicles[entity].spawned or nil,
        coords = GetEntityCoords(entity),
        heading = GetEntityHeading(entity)
    }

    return data
end

---Saves vehicle data for persistence
---@param entity number Vehicle entity handle
---@param owner? number Owner player ID
---@return table | nil data Saved vehicle data or nil
function vehicle.saveVehicle(entity, owner)
    if not vehicle.isValidVehicle(entity) then
        return nil
    end

    local data = {
        model = GetEntityModel(entity),
        plate = vehicle.getPlate(entity),
        properties = vehicle.getProperties(entity),
        owner = owner or vehicle.getOwner(entity),
        coords = GetEntityCoords(entity),
        heading = GetEntityHeading(entity),
        saved = GetGameTimer()
    }

    lib.logger:debug('vehicle', 'Vehicle saved - Entity: %s, Plate: %s', entity, data.plate)
    return data
end

---Loads vehicle from saved data
---@param data table Saved vehicle data
---@param coords? vector3 | table Override spawn coordinates
---@param heading? number Override spawn heading
---@return number | nil entity Spawned vehicle entity or nil
function vehicle.loadVehicle(data, coords, heading)
    if not data or not data.model then
        lib.logger:warn('vehicle', 'Invalid vehicle data provided')
        return nil
    end

    local spawnCoords = coords or data.coords
    local spawnHeading = heading or data.heading

    local entity = vehicle.spawn(data.model, spawnCoords, spawnHeading, data.properties)

    if entity then
        if data.plate then
            vehicle.setPlate(entity, data.plate)
        end

        if data.owner then
            vehicle.setOwner(entity, data.owner)
        end

        lib.logger:debug('vehicle', 'Vehicle loaded - Entity: %s, Plate: %s', entity, data.plate)
    end

    return entity
end

-- =====================================
-- CLEANUP AND MAINTENANCE
-- =====================================

-- Cleanup thread for temporary vehicles
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute

        local currentTime = GetGameTimer()

        for entity, data in pairs(spawnedVehicles) do
            if data.isTemporary then
                -- Remove temporary vehicles after 30 minutes if not occupied
                if currentTime - data.spawned > 1800000 and GetVehicleNumberOfPassengers(entity) == 0 then
                    vehicle.despawn(entity, true)
                    lib.logger:debug('vehicle', 'Temporary vehicle cleaned up: %s', entity)
                end
            end

            -- Clean up data for deleted vehicles
            if not DoesEntityExist(entity) then
                spawnedVehicles[entity] = nil
                vehicleKeys[entity] = nil
                vehicleOwners[entity] = nil
            end
        end
    end
end)

-- Global instance
lib.vehicle = vehicle

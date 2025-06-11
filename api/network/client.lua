---@meta

---@class NetworkOptions
---@field canMigrate? boolean Whether the entity can migrate between players
---@field syncToPlayer? number Specific player to sync to
---@field timeout? number Timeout for network operations in milliseconds

---@class NetworkEntityInfo
---@field netId number Network ID of the entity
---@field entity number Entity handle
---@field owner number Player who owns the entity
---@field created number Timestamp when entity was networked

---@class lib.network : OxClass
---@field private entityCache table<number, number> Cache mapping entities to network IDs
---@field private netIdCache table<number, number> Cache mapping network IDs to entities
---@field private syncedEntities table<number, NetworkEntityInfo> Information about synced entities
local Network = lib.class('Network')

---Network API Class - Client Side
---Simplified and consistent network entity management across client/server
---Automatically handles the confusion between VehToNet/NetToVeh and NetworkGet* natives
function Network:constructor()
    self.private.entityCache = {}
    self.private.netIdCache = {}
    self.private.syncedEntities = {}

    self:_startCleanupThread()
end

-- =====================================
-- CORE NETWORK FUNCTIONS
-- =====================================

---Get Network ID from entity handle (works consistently on client/server)
---@param entity number Entity handle
---@return number|nil netId Network ID or nil if invalid
function Network:getNetId(entity)
    if not entity or not DoesEntityExist(entity) then
        lib.logger:warn('network', 'Invalid entity passed to getNetId: %s', entity)
        return nil
    end

    local cached = self.private.entityCache[entity]
    if cached then return cached end

    local netId

    if IsEntityAVehicle(entity) then
        netId = VehToNet(entity)
    elseif IsEntityAPed(entity) then
        netId = PedToNet(entity)
    elseif IsEntityAnObject(entity) then
        netId = ObjToNet(entity)
    else
        netId = NetworkGetNetworkIdFromEntity(entity)
    end

    if netId and netId ~= 0 then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return netId
    end

    lib.logger:warn('network', 'Failed to get network ID for entity: %s', entity)
    return nil
end

---Get entity handle from Network ID (works consistently on client/server)
---@param netId number Network ID
---@return number|nil entity Entity handle or nil if invalid
function Network:getEntity(netId)
    if not netId or netId == 0 then
        lib.logger:warn('network', 'Invalid network ID passed to getEntity: %s', netId)
        return nil
    end

    local cached = self.private.netIdCache[netId]
    if cached and DoesEntityExist(cached) then return cached end

    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity and DoesEntityExist(entity) then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return entity
    end

    -- Try specific conversion functions as fallback
    entity = NetToVeh(netId)
    if entity and DoesEntityExist(entity) then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return entity
    end

    entity = NetToPed(netId)
    if entity and DoesEntityExist(entity) then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return entity
    end

    entity = NetToObj(netId)
    if entity and DoesEntityExist(entity) then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return entity
    end

    lib.logger:warn('network', 'Failed to get entity for network ID: %s', netId)
    return nil
end

---Check if entity exists in network scope
---@param entity number Entity handle
---@return boolean exists Whether the entity exists and is networked
function Network:doesEntityExist(entity)
    if not entity or not DoesEntityExist(entity) then return false end

    local netId = self:getNetId(entity)
    return netId ~= nil and netId ~= 0
end

---Check if network ID is valid and entity exists
---@param netId number Network ID
---@return boolean exists Whether the network ID is valid and entity exists
function Network:doesNetIdExist(netId)
    if not netId or netId == 0 then return false end

    local entity = self:getEntity(netId)
    return entity ~= nil and DoesEntityExist(entity)
end

-- =====================================
-- NETWORK ENTITY INFORMATION
-- =====================================

---Get detailed information about a networked entity
---@param entity number Entity handle
---@return NetworkEntityInfo|nil info Entity network information
function Network:getEntityInfo(entity)
    local netId = self:getNetId(entity)
    if not netId then return nil end

    local owner = NetworkGetEntityOwner(entity)

    return {
        netId = netId,
        entity = entity,
        owner = owner,
        created = GetGameTimer()
    }
end

---Get the owner of a networked entity
---@param entity number Entity handle
---@return number|nil owner Player ID who owns the entity
function Network:getEntityOwner(entity)
    if not DoesEntityExist(entity) then return nil end
    return NetworkGetEntityOwner(entity)
end

---Check if local player owns the entity
---@param entity number Entity handle
---@return boolean owns Whether local player owns the entity
function Network:doesPlayerOwnEntity(entity)
    local owner = self:getEntityOwner(entity)
    return owner == PlayerId()
end

-- =====================================
-- NETWORK REQUESTS
-- =====================================

---Request control of a networked entity
---@param entity number Entity handle
---@param timeout? number Timeout in milliseconds (default: 5000)
---@return boolean success Whether control was gained
function Network:requestControl(entity, timeout)
    if not DoesEntityExist(entity) then
        lib.logger:warn('network', 'Cannot request control of non-existent entity: %s', entity)
        return false
    end

    if self:doesPlayerOwnEntity(entity) then
        return true
    end

    timeout = timeout or 5000
    local startTime = GetGameTimer()

    NetworkRequestControlOfEntity(entity)

    while GetGameTimer() - startTime < timeout do
        if self:doesPlayerOwnEntity(entity) then
            lib.logger:debug('network', 'Gained control of entity: %s', entity)
            return true
        end
        Wait(50)
    end

    lib.logger:warn('network', 'Failed to gain control of entity: %s (timeout)', entity)
    return false
end

---Request control of network ID
---@param netId number Network ID
---@param timeout? number Timeout in milliseconds (default: 5000)
---@return boolean success Whether control was gained
function Network:requestControlOfNetId(netId, timeout)
    if not self:doesNetIdExist(netId) then
        lib.logger:warn('network', 'Cannot request control of invalid network ID: %s', netId)
        return false
    end

    timeout = timeout or 5000
    local startTime = GetGameTimer()

    NetworkRequestControlOfNetworkId(netId)

    while GetGameTimer() - startTime < timeout do
        local entity = self:getEntity(netId)
        if entity and self:doesPlayerOwnEntity(entity) then
            lib.logger:debug('network', 'Gained control of network ID: %s', netId)
            return true
        end
        Wait(50)
    end

    lib.logger:warn('network', 'Failed to gain control of network ID: %s (timeout)', netId)
    return false
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Convert coordinates to network safe format
---@param coords vector3 Coordinates to convert
---@return table networkCoords Network safe coordinates
function Network:coordsToNetwork(coords)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

---Convert network coordinates to vector3
---@param networkCoords table Network coordinates
---@return vector3 coords Vector3 coordinates
function Network:networkToCoords(networkCoords)
    return vector3(networkCoords.x, networkCoords.y, networkCoords.z)
end

---Clear caches for deleted entities
---@private
function Network:_cleanupCaches()
    for entity, netId in pairs(self.private.entityCache) do
        if not DoesEntityExist(entity) then
            self.private.entityCache[entity] = nil
            self.private.netIdCache[netId] = nil
            self.private.syncedEntities[entity] = nil
        end
    end
end

---Start cleanup thread for cache maintenance
---@private
function Network:_startCleanupThread()
    CreateThread(function()
        while true do
            Wait(30000)
            self:_cleanupCaches()
        end
    end)
end

-- Global instance
lib.network = Network:new()

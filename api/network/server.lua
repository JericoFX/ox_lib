---@meta

---@class NetworkSyncOptions
---@field canMigrate? boolean Whether the entity can migrate between players (default: true)
---@field syncToPlayer? number Specific player to sync to
---@field timeout? number Timeout for network operations in milliseconds
---@field autoCleanup? boolean Whether to auto-cleanup when entity is deleted (default: true)

---@class NetworkEntityData
---@field netId number Network ID of the entity
---@field entity number Entity handle
---@field owner number Player who owns the entity
---@field created number Timestamp when entity was networked
---@field options NetworkSyncOptions Original sync options
---@field players table<number, boolean> Players who have this entity synced

---@class lib.network : OxClass
---@field private entityCache table<number, number> Cache mapping entities to network IDs
---@field private netIdCache table<number, number> Cache mapping network IDs to entities
---@field private syncedEntities table<number, NetworkEntityData> Information about synced entities
---@field private pendingSync table<number, boolean> Entities pending sync
local Network = lib.class('Network')

---Network API Class - Server Side
---Advanced network entity management with automatic synchronization
---Handles entity registration, migration, and cleanup automatically
function Network:constructor()
    self.private.entityCache = {}
    self.private.netIdCache = {}
    self.private.syncedEntities = {}
    self.private.pendingSync = {}

    self:_startSyncThread()
    self:_startCleanupThread()
end

-- =====================================
-- CORE NETWORK FUNCTIONS
-- =====================================

---Get Network ID from entity handle (server version)
---@param entity number Entity handle
---@return number|nil netId Network ID or nil if invalid
function Network:getNetId(entity)
    if not entity or not DoesEntityExist(entity) then
        lib.logger:warn('network', 'Invalid entity passed to getNetId: %s', entity)
        return nil
    end

    local cached = self.private.entityCache[entity]
    if cached then return cached end

    local netId = NetworkGetNetworkIdFromEntity(entity)

    if netId and netId ~= 0 then
        self.private.entityCache[entity] = netId
        self.private.netIdCache[netId] = entity
        return netId
    end

    lib.logger:warn('network', 'Failed to get network ID for entity: %s', entity)
    return nil
end

---Get entity handle from Network ID (server version)
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

    lib.logger:warn('network', 'Failed to get entity for network ID: %s', netId)
    return nil
end

-- =====================================
-- NETWORK SYNCHRONIZATION
-- =====================================

---Synchronize entity to network with advanced options
---@param entity number Entity handle
---@param options? NetworkSyncOptions Sync options
---@return number|nil netId Network ID assigned to entity
function Network:sync(entity, options)
    if not DoesEntityExist(entity) then
        lib.logger:error('network', 'Cannot sync non-existent entity: %s', entity)
        return nil
    end

    options = options or {}
    options.canMigrate = options.canMigrate ~= false   -- Default true
    options.autoCleanup = options.autoCleanup ~= false -- Default true

    -- Check if already synced
    local existingNetId = self:getNetId(entity)
    if existingNetId then
        lib.logger:debug('network', 'Entity already synced with netId: %s', existingNetId)
        return existingNetId
    end

    -- Register as networked entity
    NetworkRegisterEntityAsNetworked(entity)

    local netId = self:getNetId(entity)
    if not netId then
        lib.logger:error('network', 'Failed to get netId after NetworkRegisterEntityAsNetworked')
        return nil
    end

    -- Apply network options
    if options.canMigrate ~= nil then
        SetNetworkIdCanMigrate(netId, options.canMigrate)
    end

    if options.syncToPlayer then
        SetNetworkIdSyncToPlayer(netId, options.syncToPlayer, true)
    end

    -- Store sync data
    self.private.syncedEntities[entity] = {
        netId = netId,
        entity = entity,
        owner = NetworkGetEntityOwner(entity),
        created = GetGameTimer(),
        options = options,
        players = {}
    }

    lib.logger:info('network', 'Entity synced successfully - Entity: %s, NetId: %s', entity, netId)
    return netId
end

---Sync entity to specific player
---@param entity number Entity handle
---@param playerId number Player to sync to
---@param sync? boolean Whether to sync (default: true)
---@return boolean success Whether sync was successful
function Network:syncToPlayer(entity, playerId, sync)
    local netId = self:getNetId(entity)
    if not netId then
        lib.logger:warn('network', 'Cannot sync non-networked entity to player: %s', entity)
        return false
    end

    sync = sync ~= false
    SetNetworkIdSyncToPlayer(netId, playerId, sync)

    local entityData = self.private.syncedEntities[entity]
    if entityData then
        entityData.players[playerId] = sync
    end

    lib.logger:debug('network', 'Entity %s sync to player %s: %s', entity, playerId, sync)
    return true
end

---Sync entity to all players
---@param entity number Entity handle
---@param sync? boolean Whether to sync (default: true)
---@return boolean success Whether sync was successful
function Network:syncToAllPlayers(entity, sync)
    local success = true

    for _, playerId in ipairs(GetPlayers()) do
        if not self:syncToPlayer(entity, tonumber(playerId), sync) then
            success = false
        end
    end

    return success
end

-- =====================================
-- NETWORK ENTITY MANAGEMENT
-- =====================================

---Get detailed information about a networked entity
---@param entity number Entity handle
---@return NetworkEntityData|nil data Entity network data
function Network:getEntityData(entity)
    return self.private.syncedEntities[entity]
end

---Get all synced entities
---@return table<number, NetworkEntityData> entities All synced entities
function Network:getAllSyncedEntities()
    return self.private.syncedEntities
end

---Remove entity from network (unsync)
---@param entity number Entity handle
---@param deleteEntity? boolean Whether to delete the entity (default: false)
---@return boolean success Whether removal was successful
function Network:unsync(entity, deleteEntity)
    local entityData = self.private.syncedEntities[entity]
    if not entityData then
        lib.logger:warn('network', 'Entity not found in sync list: %s', entity)
        return false
    end

    -- Clean up caches
    self.private.entityCache[entity] = nil
    self.private.netIdCache[entityData.netId] = nil
    self.private.syncedEntities[entity] = nil

    if deleteEntity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end

    lib.logger:debug('network', 'Entity unsynced: %s', entity)
    return true
end

-- =====================================
-- NETWORK OWNERSHIP
-- =====================================

---Get entity owner
---@param entity number Entity handle
---@return number|nil owner Player ID who owns the entity
function Network:getEntityOwner(entity)
    if not DoesEntityExist(entity) then return nil end
    return NetworkGetEntityOwner(entity)
end

---Set entity owner
---@param entity number Entity handle
---@param playerId number Player ID to set as owner
---@return boolean success Whether ownership was set
function Network:setEntityOwner(entity, playerId)
    local netId = self:getNetId(entity)
    if not netId then
        lib.logger:warn('network', 'Cannot set owner of non-networked entity: %s', entity)
        return false
    end

    SetNetworkIdCanMigrate(netId, false)
    NetworkRequestControlOfEntity(entity)

    Wait(100)

    SetNetworkIdCanMigrate(netId, true)
    SetEntityOwner(entity, playerId)

    local entityData = self.private.syncedEntities[entity]
    if entityData then
        entityData.owner = playerId
    end

    lib.logger:debug('network', 'Set entity %s owner to player %s', entity, playerId)
    return true
end

-- =====================================
-- NETWORK EVENTS AND CALLBACKS
-- =====================================

---Register callback for when entity ownership changes
---@param entity number Entity handle
---@param callback function Callback function (entity, oldOwner, newOwner)
---@return boolean success Whether callback was registered
function Network:onOwnershipChange(entity, callback)
    local entityData = self.private.syncedEntities[entity]
    if not entityData then return false end

    entityData.onOwnershipChange = callback
    return true
end

---Register callback for when entity is deleted
---@param entity number Entity handle
---@param callback function Callback function (entity, netId)
---@return boolean success Whether callback was registered
function Network:onEntityDeleted(entity, callback)
    local entityData = self.private.syncedEntities[entity]
    if not entityData then return false end

    entityData.onDeleted = callback
    return true
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Check if entity is synced
---@param entity number Entity handle
---@return boolean synced Whether entity is network synced
function Network:isSynced(entity)
    return self.private.syncedEntities[entity] ~= nil
end

---Get network statistics
---@return table stats Network usage statistics
function Network:getStats()
    local stats = {
        totalSyncedEntities = 0,
        vehicleCount = 0,
        pedCount = 0,
        objectCount = 0,
        averageAge = 0
    }

    local totalAge = 0
    local currentTime = GetGameTimer()

    for entity, data in pairs(self.private.syncedEntities) do
        stats.totalSyncedEntities = stats.totalSyncedEntities + 1
        totalAge = totalAge + (currentTime - data.created)

        if DoesEntityExist(entity) then
            if IsEntityAVehicle(entity) then
                stats.vehicleCount = stats.vehicleCount + 1
            elseif IsEntityAPed(entity) then
                stats.pedCount = stats.pedCount + 1
            elseif IsEntityAnObject(entity) then
                stats.objectCount = stats.objectCount + 1
            end
        end
    end

    if stats.totalSyncedEntities > 0 then
        stats.averageAge = totalAge / stats.totalSyncedEntities
    end

    return stats
end

-- =====================================
-- PRIVATE FUNCTIONS
-- =====================================

---Process pending sync operations
---@private
function Network:_processPendingSync()
    for entity, _ in pairs(self.private.pendingSync) do
        if DoesEntityExist(entity) then
            local netId = self:getNetId(entity)
            if netId then
                self.private.pendingSync[entity] = nil
            end
        else
            self.private.pendingSync[entity] = nil
        end
    end
end

---Monitor entity ownership changes
---@private
function Network:_monitorOwnership()
    for entity, data in pairs(self.private.syncedEntities) do
        if DoesEntityExist(entity) then
            local currentOwner = NetworkGetEntityOwner(entity)
            if currentOwner ~= data.owner then
                local oldOwner = data.owner
                data.owner = currentOwner

                if data.onOwnershipChange then
                    data.onOwnershipChange(entity, oldOwner, currentOwner)
                end
            end
        end
    end
end

---Clean up deleted entities
---@private
function Network:_cleanupDeleted()
    for entity, data in pairs(self.private.syncedEntities) do
        if not DoesEntityExist(entity) then
            if data.onDeleted then
                data.onDeleted(entity, data.netId)
            end

            self.private.entityCache[entity] = nil
            self.private.netIdCache[data.netId] = nil
            self.private.syncedEntities[entity] = nil

            lib.logger:debug('network', 'Cleaned up deleted entity: %s', entity)
        end
    end
end

---Start sync monitoring thread
---@private
function Network:_startSyncThread()
    CreateThread(function()
        while true do
            self:_processPendingSync()
            self:_monitorOwnership()
            Wait(1000)
        end
    end)
end

---Start cleanup thread
---@private
function Network:_startCleanupThread()
    CreateThread(function()
        while true do
            Wait(30000)
            self:_cleanupDeleted()
        end
    end)
end

-- Global instance
lib.network = Network:new()

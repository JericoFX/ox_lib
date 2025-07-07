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

---@class lib.network
---@field getNetId fun(entity: number): number|nil
---@field getEntity fun(netId: number): number|nil
---@field sync fun(entity: number, options?: NetworkSyncOptions): number|nil
---@field syncToPlayer fun(entity: number, playerId: number, sync?: boolean): boolean
---@field syncToAllPlayers fun(entity: number, sync?: boolean): boolean
---@field getEntityData fun(entity: number): NetworkEntityData|nil
---@field getAllSyncedEntities fun(): table<number, NetworkEntityData>
---@field unsync fun(entity: number, deleteEntity?: boolean): boolean
---@field getEntityOwner fun(entity: number): number|nil
---@field requestOwnershipChange fun(entity: number, playerId: number): boolean
---@field isSynced fun(entity: number): boolean
---@field getStats fun(): table

local entityCache = {}
local netIdCache = {}
local syncedEntities = {}

local network = {}

-- =====================================
-- CORE NETWORK FUNCTIONS
-- =====================================

---Get Network ID from entity handle (server version)
---@param entity number Entity handle
---@return number|nil netId Network ID or nil if invalid
function network.getNetId(entity)
    if not entity or entity == 0 then
        lib.logger:warn('network', 'Invalid entity passed to getNetId: %s', entity)
        return nil
    end

    local cached = entityCache[entity]
    if cached then return cached end

    local netId = NetworkGetNetworkIdFromEntity(entity)

    if netId and netId ~= 0 then
        entityCache[entity] = netId
        netIdCache[netId] = entity
        return netId
    end

    lib.logger:warn('network', 'Failed to get network ID for entity: %s', entity)
    return nil
end

---Get entity handle from Network ID (server version)
---@param netId number Network ID
---@return number|nil entity Entity handle or nil if invalid
function network.getEntity(netId)
    if not netId or netId == 0 then
        lib.logger:warn('network', 'Invalid network ID passed to getEntity: %s', netId)
        return nil
    end

    local cached = netIdCache[netId]
    if cached then return cached end

    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity and entity ~= 0 then
        entityCache[entity] = netId
        netIdCache[netId] = entity
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
function network.sync(entity, options)
    if not entity or entity == 0 then
        lib.logger:error('network', 'Cannot sync invalid entity: %s', entity)
        return nil
    end

    options = options or {}
    options.canMigrate = options.canMigrate ~= false
    options.autoCleanup = options.autoCleanup ~= false

    local existingNetId = network.getNetId(entity)
    if existingNetId then
        lib.logger:debug('network', 'Entity already synced with netId: %s', existingNetId)
        return existingNetId
    end


    local netId = network.getNetId(entity)
    if not netId then
        lib.logger:error('network', 'Failed to get netId after ')
        return nil
    end

    if options.canMigrate ~= nil then
        SetNetworkIdCanMigrate(netId, options.canMigrate)
    end

    if options.syncToPlayer then
        SetNetworkIdSyncToPlayer(netId, options.syncToPlayer, true)
    end

    syncedEntities[entity] = {
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
function network.syncToPlayer(entity, playerId, sync)
    local netId = network.getNetId(entity)
    if not netId then
        lib.logger:warn('network', 'Cannot sync non-networked entity to player: %s', entity)
        return false
    end

    sync = sync ~= false
    SetNetworkIdSyncToPlayer(netId, playerId, sync)

    local entityData = syncedEntities[entity]
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
function network.syncToAllPlayers(entity, sync)
    local success = true

    for _, playerId in ipairs(GetPlayers()) do
        if not network.syncToPlayer(entity, tonumber(playerId), sync) then
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
function network.getEntityData(entity)
    return syncedEntities[entity]
end

---Get all synced entities
---@return table<number, NetworkEntityData> entities All synced entities
function network.getAllSyncedEntities()
    return syncedEntities
end

---Remove entity from network (unsync)
---@param entity number Entity handle
---@param deleteEntity? boolean Whether to delete the entity (default: false)
---@return boolean success Whether removal was successful
function network.unsync(entity, deleteEntity)
    local entityData = syncedEntities[entity]
    if not entityData then
        lib.logger:warn('network', 'Entity not found in sync list: %s', entity)
        return false
    end

    entityCache[entity] = nil
    netIdCache[entityData.netId] = nil
    syncedEntities[entity] = nil

    if deleteEntity and entity and entity ~= 0 then
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
function network.getEntityOwner(entity)
    if not entity or entity == 0 then return nil end
    return NetworkGetEntityOwner(entity)
end

---Request ownership change (delegates to client)
---@param entity number Entity handle
---@param playerId number Player ID to request ownership for
---@return boolean success Whether request was sent
function network.requestOwnershipChange(entity, playerId)
    local netId = network.getNetId(entity)
    if not netId then
        lib.logger:warn('network', 'Cannot request ownership of non-networked entity: %s', entity)
        return false
    end

    Entity(entity).state:set('ox_lib:requestOwnership', {
        targetPlayer = playerId,
        requestTime = GetGameTimer()
    }, true)

    lib.logger:debug('network', 'Ownership change requested for entity %s to player %s', entity, playerId)
    return true
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Check if entity is synced
---@param entity number Entity handle
---@return boolean synced Whether entity is network synced
function network.isSynced(entity)
    return syncedEntities[entity] ~= nil
end

---Get network statistics
---@return table stats Network usage statistics
function network.getStats()
    local stats = {
        totalSyncedEntities = 0,
        averageAge = 0
    }

    local totalAge = 0
    local currentTime = GetGameTimer()

    for entity, data in pairs(syncedEntities) do
        if entity and entity ~= 0 then
            stats.totalSyncedEntities = stats.totalSyncedEntities + 1
            totalAge = totalAge + (currentTime - data.created)
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

---Monitor entity ownership changes
local function monitorOwnership()
    for entity, data in pairs(syncedEntities) do
        if entity and entity ~= 0 then
            local currentOwner = NetworkGetEntityOwner(entity)
            if currentOwner ~= data.owner then
                local oldOwner = data.owner
                data.owner = currentOwner

                lib.logger:debug('network', 'Entity %s ownership changed from %s to %s', entity, oldOwner, currentOwner)
            end
        end
    end
end

---Clean up invalid entities
local function cleanupInvalid()
    for entity, data in pairs(syncedEntities) do
        if not entity or entity == 0 then
            entityCache[entity] = nil
            if data.netId then
                netIdCache[data.netId] = nil
            end
            syncedEntities[entity] = nil

            lib.logger:debug('network', 'Cleaned up invalid entity: %s', entity)
        end
    end
end

-- =====================================
-- INITIALIZATION
-- =====================================

CreateThread(function()
    while true do
        monitorOwnership()
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        Wait(30000)
        cleanupInvalid()
    end
end)

lib.network = network

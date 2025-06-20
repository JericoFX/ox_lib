---@meta

---@class StateBagOptions
---@field replicated? boolean Whether the state is replicated (default: true)
---@field persistent? boolean Whether the state persists (default: false)
---@field private? boolean Whether only owner can modify (default: false)

---@class StateBagWatcher
---@field key string State key being watched
---@field callback function Callback function
---@field entity? number Entity if watching entity statebag
---@field active boolean Whether watcher is active

---@class lib.statebags
---@field private watchers table
---@field private listeners table
---@field private entityWatchers table
local StateBags = lib.class('StateBags')

---StateBags API Class - Client Side
---Reactive state management system with automatic listeners and watchers
---@param options? table StateBags system options
function StateBags:constructor(options)
    options = options or {}

    -- Initialize private properties
    self.private.watchers = {}
    self.private.listeners = {}
    self.private.entityWatchers = {}
    self.private.watcherIdCounter = 0

    -- Setup global state bag change listeners
    self:_setupGlobalListeners()
end

-- =====================================
-- CORE STATEBAG FUNCTIONS
-- =====================================

---Set a global state value
---@param key string State key
---@param value any State value
---@param options? StateBagOptions State options
function StateBags:setGlobalState(key, value, options)
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to setGlobalState', 2)
    end
    if key:match('^_meta_') then
        error('Cannot set metadata keys directly', 2)
    end
    if #key > 255 then
        error('State key length exceeds 255 bytes', 2)
    end

    local valueType = type(value)
    if valueType == 'function' or valueType == 'userdata' or valueType == 'thread' then
        error(('Unsupported value type provided to setGlobalState: %s'):format(valueType), 2)
    end

    options = options or {}

    -- Set the global state
    GlobalState[key] = value

    -- Store metadata if needed
    if options.persistent or options.private then
        local metadata = {
            persistent = options.persistent,
            private = options.private,
            replicated = options.replicated ~= false
        }
        GlobalState['_meta_' .. key] = metadata
    end
end

---Get a global state value
---@param key string State key
---@return any value State value or nil
function StateBags:getGlobalState(key)
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to getGlobalState', 2)
    end

    return GlobalState[key]
end

---Set a player state value
---@param playerId number Player server ID
---@param key string State key
---@param value any State value
---@param options? StateBagOptions State options
function StateBags:setPlayerState(playerId, key, value, options)
    if not playerId or type(playerId) ~= 'number' then
        error('Invalid playerId provided to setPlayerState', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to setPlayerState', 2)
    end
    if key:match('^_meta_') then
        error('Cannot set metadata keys directly', 2)
    end
    if #key > 255 then
        error('State key length exceeds 255 bytes', 2)
    end

    local valueType = type(value)
    if valueType == 'function' or valueType == 'userdata' or valueType == 'thread' then
        error(('Unsupported value type provided to setPlayerState: %s'):format(valueType), 2)
    end

    options = options or {}

    local stateBag = Player(playerId).state
    stateBag[key] = value

    -- Store metadata if needed
    if options.persistent or options.private then
        local metadata = {
            persistent = options.persistent,
            private = options.private,
            replicated = options.replicated ~= false
        }
        stateBag['_meta_' .. key] = metadata
    end
end

---Get a player state value
---@param playerId number Player server ID
---@param key string State key
---@return any value State value or nil
function StateBags:getPlayerState(playerId, key)
    if not playerId or type(playerId) ~= 'number' then
        error('Invalid playerId provided to getPlayerState', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to getPlayerState', 2)
    end

    return Player(playerId).state[key]
end

---Set an entity state value
---@param entity number Entity handle
---@param key string State key
---@param value any State value
---@param options? StateBagOptions State options
function StateBags:setEntityState(entity, key, value, options)
    if not entity or type(entity) ~= 'number' then
        error('Invalid entity provided to setEntityState', 2)
    end
    if not DoesEntityExist(entity) then
        error('Entity does not exist', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to setEntityState', 2)
    end
    if key:match('^_meta_') then
        error('Cannot set metadata keys directly', 2)
    end
    if #key > 255 then
        error('State key length exceeds 255 bytes', 2)
    end

    local valueType = type(value)
    if valueType == 'function' or valueType == 'userdata' or valueType == 'thread' then
        error(('Unsupported value type provided to setEntityState: %s'):format(valueType), 2)
    end

    options = options or {}

    local stateBag = Entity(entity).state
    stateBag[key] = value

    -- Store metadata if needed
    if options.persistent or options.private then
        local metadata = {
            persistent = options.persistent,
            private = options.private,
            replicated = options.replicated ~= false
        }
        stateBag['_meta_' .. key] = metadata
    end
end

---Get an entity state value
---@param entity number Entity handle
---@param key string State key
---@return any value State value or nil
function StateBags:getEntityState(entity, key)
    if not entity or type(entity) ~= 'number' then
        error('Invalid entity provided to getEntityState', 2)
    end
    if not DoesEntityExist(entity) then
        error('Entity does not exist', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to getEntityState', 2)
    end

    return Entity(entity).state[key]
end

-- =====================================
-- REACTIVE WATCHERS
-- =====================================

---Watch global state changes
---@param key string State key to watch
---@param callback fun(key: string, value: any, oldValue: any): void Callback function
---@return number watcherId Unique watcher ID for removal
function StateBags:watchGlobalState(key, callback)
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to watchGlobalState', 2)
    end
    if not callback or type(callback) ~= 'function' then
        error('Invalid callback provided to watchGlobalState', 2)
    end

    self.private.watcherIdCounter = self.private.watcherIdCounter + 1
    local watcherId = self.private.watcherIdCounter

    local watcher = {
        id = watcherId,
        key = key,
        callback = callback,
        type = 'global',
        active = true,
        instance = self
    }

    self.private.watchers[watcherId] = watcher

    -- Setup AddStateBagChangeHandler
    local handler = AddStateBagChangeHandler(key, nil, function(bagName, key, value, reserved, replicated)
        if watcher.active and bagName == 'global' then
            local oldValue = self.private.lastValues and self.private.lastValues[key]
            callback(key, value, oldValue)

            -- Store last value
            if not self.private.lastValues then
                self.private.lastValues = {}
            end
            self.private.lastValues[key] = value
        end
    end)

    watcher.handler = handler
    return watcherId
end

---Watch player state changes
---@param playerId number Player server ID
---@param key string State key to watch
---@param callback fun(playerId: number, key: string, value: any, oldValue: any): void Callback function
---@return number watcherId Unique watcher ID for removal
function StateBags:watchPlayerState(playerId, key, callback)
    if not playerId or type(playerId) ~= 'number' then
        error('Invalid playerId provided to watchPlayerState', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to watchPlayerState', 2)
    end
    if not callback or type(callback) ~= 'function' then
        error('Invalid callback provided to watchPlayerState', 2)
    end

    self.private.watcherIdCounter = self.private.watcherIdCounter + 1
    local watcherId = self.private.watcherIdCounter

    local watcher = {
        id = watcherId,
        key = key,
        callback = callback,
        type = 'player',
        playerId = playerId,
        active = true,
        instance = self
    }

    self.private.watchers[watcherId] = watcher

    -- Setup AddStateBagChangeHandler for specific player
    local handler = AddStateBagChangeHandler(key, ('player:%d'):format(playerId), function(bagName, key, value, reserved, replicated)
        if watcher.active then
            local oldValue = self.private.lastPlayerValues and self.private.lastPlayerValues[playerId] and self.private.lastPlayerValues[playerId][key]
            callback(playerId, key, value, oldValue)

            -- Store last value
            if not self.private.lastPlayerValues then
                self.private.lastPlayerValues = {}
            end
            if not self.private.lastPlayerValues[playerId] then
                self.private.lastPlayerValues[playerId] = {}
            end
            self.private.lastPlayerValues[playerId][key] = value
        end
    end)

    watcher.handler = handler
    return watcherId
end

---Watch entity state changes
---@param entity number Entity handle
---@param key string State key to watch
---@param callback fun(entity: number, key: string, value: any, oldValue: any): void Callback function
---@return number watcherId Unique watcher ID for removal
function StateBags:watchEntityState(entity, key, callback)
    if not entity or type(entity) ~= 'number' then
        error('Invalid entity provided to watchEntityState', 2)
    end
    if not DoesEntityExist(entity) then
        error('Entity does not exist', 2)
    end
    if not key or type(key) ~= 'string' then
        error('Invalid key provided to watchEntityState', 2)
    end
    if not callback or type(callback) ~= 'function' then
        error('Invalid callback provided to watchEntityState', 2)
    end

    self.private.watcherIdCounter = self.private.watcherIdCounter + 1
    local watcherId = self.private.watcherIdCounter

    local watcher = {
        id = watcherId,
        key = key,
        callback = callback,
        type = 'entity',
        entity = entity,
        active = true,
        instance = self
    }

    self.private.watchers[watcherId] = watcher

    -- Get the network ID for the entity
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId == 0 then
        error('Failed to get network ID for entity', 2)
    end

    -- Setup AddStateBagChangeHandler for specific entity
    local handler = AddStateBagChangeHandler(key, ('entity:%d'):format(netId), function(bagName, key, value, reserved, replicated)
        if watcher.active then
            local oldValue = self.private.lastEntityValues and self.private.lastEntityValues[entity] and self.private.lastEntityValues[entity][key]
            callback(entity, key, value, oldValue)

            -- Store last value
            if not self.private.lastEntityValues then
                self.private.lastEntityValues = {}
            end
            if not self.private.lastEntityValues[entity] then
                self.private.lastEntityValues[entity] = {}
            end
            self.private.lastEntityValues[entity][key] = value
        end
    end)

    watcher.handler = handler
    return watcherId
end

-- =====================================
-- WATCHER MANAGEMENT
-- =====================================

---Remove a watcher
---@param watcherId number Watcher ID to remove
---@return boolean success True if watcher was removed successfully
function StateBags:removeWatcher(watcherId)
    if not watcherId or type(watcherId) ~= 'number' then
        return false
    end

    local watcher = self.private.watchers[watcherId]
    if not watcher then
        return false
    end

    watcher.active = false

    if watcher.handler then
        RemoveStateBagChangeHandler(watcher.handler)
        watcher.handler = nil
    end

    self.private.watchers[watcherId] = nil
    return true
end

---Remove all watchers for this instance
---@return number removedCount Number of watchers removed
function StateBags:removeAllWatchers()
    local removedCount = 0

    for watcherId, watcher in pairs(self.private.watchers) do
        if self:removeWatcher(watcherId) then
            removedCount = removedCount + 1
        end
    end

    return removedCount
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Get all global states matching pattern
---@param pattern string Lua pattern to match keys
---@return table states Matching states
function StateBags:getGlobalStatesMatching(pattern)
    local states = {}

    -- Iterate through GlobalState
    for key, value in pairs(GlobalState) do
        if string.match(key, pattern) and not string.match(key, '^_meta_') then
            states[key] = value
        end
    end

    return states
end

---Check if a state exists
---@param type string State type ('global', 'player', 'entity')
---@param key string State key
---@param id? number Player ID or Entity handle (for player/entity states)
---@return boolean exists True if state exists
function StateBags:stateExists(type, key, id)
    if type == 'global' then
        return GlobalState[key] ~= nil
    elseif type == 'player' and id then
        return Player(id).state[key] ~= nil
    elseif type == 'entity' and id then
        return Entity(id).state[key] ~= nil
    end
    return false
end

---Get active watcher count
---@return number count Number of active watchers
function StateBags:getWatcherCount()
    local count = 0
    for _, watcher in pairs(self.private.watchers) do
        if watcher.active then
            count = count + 1
        end
    end
    return count
end

---Private method to setup global listeners
function StateBags:_setupGlobalListeners()
    -- Initialize storage for last values
    self.private.lastValues = {}
    self.private.lastPlayerValues = {}
    self.private.lastEntityValues = {}
end

-- Create default instance
lib.statebags = StateBags:new()

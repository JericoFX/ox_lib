---@meta
--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

if not _VERSION:find('5.4') then
    error('Lua 5.4 must be enabled in the resource manifest!', 2)
end

local resourceName = GetCurrentResourceName()
local ox_lib = 'ox_lib'

-- Some people have decided to load this file as part of ox_lib's fxmanifest?
if resourceName == ox_lib then return end

if lib and lib.name == ox_lib then
    error(("Cannot load ox_lib more than once.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(resourceName))
end

local export = exports[ox_lib]

if GetResourceState(ox_lib) ~= 'started' then
    error('^1ox_lib must be started before this resource.^0', 0)
end

local status = export.hasLoaded()

if status ~= true then error(status, 2) end

-- Ignore invalid types during msgpack.pack (e.g. userdata)
msgpack.setoption('ignore_invalid', true)

-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

function noop() end

-- Module loading states
local moduleStates = {}
local STATES = {
    UNLOADED = 'UNLOADED',
    LOADING = 'LOADING', 
    LOADED = 'LOADED',
    ERROR = 'ERROR'
}

-- Get logging level from convar
local logLevel = GetConvar('ox:loglevel', 'info'):lower()
local debugMode = logLevel == 'debug' or logLevel == 'verbose'

local function loadModule(self, module)
    -- Prevent circular loading
    if moduleStates[module] == STATES.LOADING then
        if lib.print then
            lib.print.error('loadModule', 'Circular dependency detected for module: %s', module)
        end
        return nil
    end
    
    -- Check if already loaded
    if moduleStates[module] == STATES.LOADED then
        return rawget(self, module)
    end
    
    moduleStates[module] = STATES.LOADING
    
    if debugMode and lib.print then
        lib.print.debug('loadModule', 'Loading module: %s', module)
    end
    
    local dir = ('imports/%s'):format(module)
    local chunk = LoadResourceFile(ox_lib, ('%s/%s.lua'):format(dir, context))
    local shared = LoadResourceFile(ox_lib, ('%s/shared.lua'):format(dir))

    if shared then
        chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
    end

    if chunk then
        local fn, err = load(chunk, ('@@ox_lib/imports/%s/%s.lua'):format(module, context))

        if not fn or err then
            if shared then
                lib.print.warn(("An error occurred when importing '@ox_lib/imports/%s'.\nThis is likely caused by improperly updating ox_lib.\n%s'")
                    :format(module, err))
                fn, err = load(shared, ('@@ox_lib/imports/%s/shared.lua'):format(module))
            end

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end
        end

        local success, result = pcall(fn)
        if not success then
            moduleStates[module] = STATES.ERROR
            if lib.print then
                lib.print.error('loadModule', 'Error executing module %s: %s', module, result)
            end
            return error(('\n^1Error executing module (%s): %s^0'):format(module, result), 3)
        end
        
        moduleStates[module] = STATES.LOADED
        self[module] = result or noop
        
        if debugMode and lib.print then
            lib.print.debug('loadModule', 'Module loaded successfully: %s', module)
        end
        
        return self[module]
    end

    -- Si no se encontró en imports, intentar cargar desde api?
    local apiDir = ('api/%s'):format(module)
    local apiContext = LoadResourceFile(ox_lib, ('%s/%s.lua'):format(apiDir, context))

    if apiContext then
        local fn, err = load(apiContext, ('@@ox_lib/api/%s/%s.lua'):format(module, context))

        if not fn or err then
            return error(('\n^1Error importing API module (%s/%s.lua): %s^0'):format(module, context, err), 3)
        end

        local success, result = pcall(fn)
        if not success then
            moduleStates[module] = STATES.ERROR
            if lib.print then
                lib.print.error('loadModule', 'Error executing API module %s: %s', module, result)
            end
            return error(('\n^1Error executing API module (%s): %s^0'):format(module, result), 3)
        end
        
        moduleStates[module] = STATES.LOADED
        self[module] = result or noop
        
        if debugMode and lib.print then
            lib.print.debug('loadModule', 'API module loaded successfully: %s', module)
        end
        
        return self[module]
    end

    -- Si no se encontró en api/, intentar cargar desde wrappers/
    local wrapperPath = ('wrappers/%s/%s.lua'):format(module, context)
    chunk = LoadResourceFile(ox_lib, wrapperPath)
    local sharedWrapper = LoadResourceFile(ox_lib, ('wrappers/%s/shared.lua'):format(module))

    if sharedWrapper then
        chunk = (chunk and ('%s\n%s'):format(sharedWrapper, chunk)) or sharedWrapper
    end

    if chunk then
        if debugMode and lib.print then
            lib.print.debug('loadModule', 'Loading wrapper: %s', module)
            lib.print.debug('loadModule', 'Path: %s', wrapperPath)
            if sharedWrapper then
                lib.print.debug('loadModule', 'Shared wrapper found')
            end
        end

        local fn, err = load(chunk, ('@@ox_lib/wrappers/%s/%s.lua'):format(module, context))

        if not fn or err then
            moduleStates[module] = STATES.ERROR
            if lib.print then
                lib.print.error('loadModule', 'Failed to load wrapper %s: %s', module, err)
            end
            return error(('\n^1Error importing wrapper class (wrappers/%s): %s^0'):format(module, err), 3)
        end

        local success, result = pcall(fn)
        if not success then
            moduleStates[module] = STATES.ERROR
            if lib.print then
                lib.print.error('loadModule', 'Error executing wrapper %s: %s', module, result)
            end
            return error(('\n^1Error executing wrapper (%s): %s^0'):format(module, result), 3)
        end
        
        moduleStates[module] = STATES.LOADED
        self[module] = result or noop
        
        if debugMode and lib.print then
            lib.print.debug('loadModule', 'Wrapper loaded successfully: %s', module)
            if module == 'core' and result and result.framework then
                lib.print.info('loadModule', 'Framework detected: %s', result.framework)
            end
        end
        
        return self[module]
    end
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local function call(self, index, ...)
    local module = rawget(self, index)

    if not module then
        self[index] = noop
        module = loadModule(self, index)

        if not module then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        end
    end

    return module
end

local lib = setmetatable({
    name = ox_lib,
    context = context,
}, {
    __index = call,
    __call = call,
})

local CitizenCreateThreadNow = Citizen.CreateThreadNow
local Wait = Wait
local jsonEncode = json.encode
local table_unpack = table.unpack

local intervals = {}

function SetInterval(callback, interval, ...)
    interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(jsonEncode(interval)))
    end

    local cbType = type(callback)

    if cbType == 'number' then
        if intervals[callback] then
            intervals[callback] = interval
        end
        return
    end

    if cbType ~= 'function' then
        return error(('Callback must be a function. Received %s'):format(cbType))
    end

    local args = { ... }
    local id

    CitizenCreateThreadNow(function(ref)
        id = ref
        intervals[id] = interval
        local cb = callback
        repeat
            local waitTime = intervals[id]
            if waitTime < 0 then break end
            Wait(waitTime)
            cb(table_unpack(args))
        until false
        intervals[id] = nil
    end)

    return id
end

---@param id number
function ClearInterval(id)
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id --[[@as unknown]])))
    end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
    end

    intervals[id] = -1
end

--[[
    lua language server doesn't support generics when using @overload
    see https://github.com/LuaLS/lua-language-server/issues/723
    this function stub allows the following to work

    local key = cache('key', function() return 'abc' end) -- fff: 'abc'
    local game = cache.game -- game: string
]]

---@generic T
---@param key string
---@param func fun(...: any): T
---@param timeout? number
---@return T
---Caches the result of a function, optionally clearing it after timeout ms.
function cache(key, func, timeout) end

local cacheEvents = {}
local cacheTimeouts = {}
local cacheHandlers = {}

local cache = setmetatable({ 
    game = GetGameName(), 
    resource = resourceName,
    _version = 1 -- Cache version control
}, {
    __index = function(self, key)
        -- Skip internal properties
        if key:sub(1, 1) == '_' then return nil end
        
        -- Initialize events array if needed
        cacheEvents[key] = cacheEvents[key] or {}
        
        -- Register event handler only once
        if not cacheHandlers[key] then
            cacheHandlers[key] = true
            
            AddEventHandler(('ox_lib:cache:%s'):format(key), function(value)
                local oldValue = self[key]
                
                -- Skip if no change
                if oldValue == value then return end
                
                local events = cacheEvents[key]
                if #events > 0 then
                    -- Batch process callbacks for better performance
                    Citizen.CreateThreadNow(function()
                        for i = 1, #events do
                            local success, err = pcall(events[i], value, oldValue)
                            if not success and lib.print then
                                lib.print.error('cache', 'Error in cache callback for %s: %s', key, err)
                            end
                        end
                    end)
                end
                
                self[key] = value
            end)
        end
        
        -- Initialize with exported value
        return rawset(self, key, export.cache(nil, key) or false)[key]
    end,
    
    __call = function(self, key, func, timeout)
        -- Clear existing timeout if any
        if cacheTimeouts[key] then
            ClearTimeout(cacheTimeouts[key])
            cacheTimeouts[key] = nil
        end
        
        local value = rawget(self, key)
        if value == nil then
            -- Execute function with error handling
            local success, result = pcall(func)
            if not success then
                if lib.print then
                    lib.print.error('cache', 'Error generating cache value for %s: %s', key, result)
                end
                return nil
            end
            
            value = result
            rawset(self, key, value)
            
            -- Set new timeout if specified
            if timeout then
                cacheTimeouts[key] = SetTimeout(timeout, function()
                    self[key] = nil
                    cacheTimeouts[key] = nil
                end)
            end
        end
        
        return value
    end,
})

function lib.onCache(key, cb)
    if not cacheEvents[key] then
        getmetatable(cache).__index(cache, key)
    end

    table.insert(cacheEvents[key], cb)
end

_ENV.lib = lib
_ENV.cache = cache
_ENV.require = lib.require
local notifyEvent = ('__ox_notify_%s'):format(cache.resource)

if context == 'client' then
    RegisterNetEvent(notifyEvent, function(data)
        if locale then
            if data.title then
                data.title = locale(data.title) or data.title
            end

            if data.description then
                data.description = locale(data.description) or data.description
            end
        end

        return export:notify(data)
    end)

    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(cache.playerId)
else
    ---`server`\
    ---Trigger a notification on the target playerId from the server.\
    ---If locales are loaded, the title and description will be formatted automatically.\
    ---Note: No support for locale placeholders when using this function.
    ---@param playerId number
    ---@param data NotifyProps
    ---@deprecated
    ---@diagnostic disable-next-line: duplicate-set-field
    function lib.notify(playerId, data)
        TriggerClientEvent(notifyEvent, playerId, data)
    end

    local poolNatives = {
        CPed = GetAllPeds,
        CObject = GetAllObjects,
        CVehicle = GetAllVehicles,
    }

    ---@param poolName 'CPed' | 'CObject' | 'CVehicle'
    ---@return number[]
    ---Server-side parity for the `GetGamePool` client native.
    function GetGamePool(poolName)
        local fn = poolNatives[poolName]
        return fn and fn() --[[@as number[] ]]
    end

    ---@return number[]
    ---Server-side parity for the `GetPlayers` client native.
    function GetActivePlayers()
        local playerNum = GetNumPlayerIndices()
        local players = table.create(playerNum, 0)

        for i = 1, playerNum do
            players[i] = tonumber(GetPlayerFromIndex(i - 1))
        end

        return players
    end
end

for i = 1, GetNumResourceMetadata(cache.resource, 'ox_lib') do
    local name = GetResourceMetadata(cache.resource, 'ox_lib', i - 1)

    if not rawget(lib, name) then
        local module = loadModule(lib, name)

        if type(module) == 'function' then pcall(module) end
    end
end

-- Auto-load lazy functions for advanced animation and network scenes modules
if context == 'client' then
    -- Lazy loader for playAnimAdvanced
    local original_playAnimAdvanced = lib.playAnimAdvanced
    lib.playAnimAdvanced = function(...)
        -- Load the actual module and auto-load all functions
        local loader = original_playAnimAdvanced
        if type(loader) == 'function' then
            -- Call the loader to populate all lib functions
            loader()
        end
        -- Now call the actual function
        return lib.playAnimAdvanced(...)
    end

    -- Lazy loader for playScene (NetworkScenes)
    local original_playScene = lib.playScene
    lib.playScene = function(...)
        -- Load the actual module and auto-load all functions
        local loader = original_playScene
        if type(loader) == 'function' then
            -- Call the loader to populate all lib functions
            loader()
        end
        -- Now call the actual function
        return lib.playScene(...)
    end
end

do
    local enumsPath = 'api/enums/init.lua'
    local enumsChunk = LoadResourceFile(ox_lib, enumsPath)

    if enumsChunk then
        local fn, err = load(enumsChunk, ('@@ox_lib/%s'):format(enumsPath))

        if fn and not err then
            pcall(fn)
        end
    end
end

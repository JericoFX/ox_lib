-- Client-side Events API with Cache Integration
local events = require 'api.events.init'

-- Client-specific event listeners
lib.events = lib.events or {}

-- Cache update functions using direct cache access
local function updatePlayerCache(playerData)
    if not playerData then return end

    -- Use ox_lib's existing cache system directly
    cache:set('playerData', playerData)

    if playerData.citizenid then
        cache:set('citizenid', playerData.citizenid)
        cache:set('identifier', playerData.citizenid)
    end

    if playerData.job then
        cache:set('job', playerData.job)
    end

    if playerData.gang then
        cache:set('gang', playerData.gang)
    end

    if playerData.money then
        cache:set('money', playerData.money)
    end
end

local function updateJobCache(jobData, oldJob)
    if not jobData then return end

    cache:set('job', jobData)

    -- Update player data cache with new job
    if cache.playerData then
        cache.playerData.job = jobData
        cache:set('playerData', cache.playerData)
    end
end

local function updateMoneyCache(moneyData, account, amount, reason)
    if not moneyData then return end

    cache:set('money', moneyData)

    -- Update player data cache with new money
    if cache.playerData then
        cache.playerData.money = moneyData
        cache:set('playerData', cache.playerData)
    end
end

local function clearPlayerCache()
    cache:set('playerData', nil)
    cache:set('job', nil)
    cache:set('gang', nil)
    cache:set('money', nil)
    cache:set('citizenid', nil)
    cache:set('identifier', nil)
end

-- Cache getter functions using direct access
lib.events.cache = {
    getPlayer = function()
        return cache.playerData
    end,

    getJob = function()
        return cache.job
    end,

    getGang = function()
        return cache.gang
    end,

    getMoney = function(account)
        if not cache.money then return 0 end

        if account then
            return cache.money[account] or 0
        end

        return cache.money
    end,

    getCitizenId = function()
        return cache.citizenid
    end,

    getIdentifier = function()
        return cache.identifier
    end,

    clear = clearPlayerCache,

    -- Internal update functions
    updatePlayer = updatePlayerCache,
    updateJob = updateJobCache,
    updateMoney = updateMoneyCache
}

-- Register client event
function lib.events.on(eventName, callback)
    return events.on(eventName, callback)
end

-- Remove client event listener
function lib.events.off(eventName, callback)
    return events.off(eventName, callback)
end

-- Trigger client event
function lib.events.trigger(eventName, ...)
    return events.trigger(eventName, ...)
end

-- Emit event to server
function lib.events.emitServer(eventName, ...)
    TriggerServerEvent('lib:events:' .. eventName, ...)
end

-- Emit event to all clients (if server allows)
function lib.events.emitAll(eventName, ...)
    TriggerServerEvent('lib:events:emitAll', eventName, ...)
end

-- Get available events for current framework
function lib.events.getAvailable()
    return events.getAvailableEvents()
end

-- Initialize common client events with cache integration
CreateThread(function()
    -- Player loaded event - cache all data
    lib.events.on('player:loaded', function(player)
        lib.print.info('Universal player loaded event triggered', player.citizenid)
        updatePlayerCache(player)
    end)

    -- Player logout event - clear cache
    lib.events.on('player:logout', function()
        lib.print.info('Player logged out - clearing cache')
        clearPlayerCache()
    end)

    -- Job change event - update job cache
    lib.events.on('player:job:changed', function(player, oldJob, newJob)
        lib.print.info('Player job changed', {
            citizenid = player.citizenid,
            from = oldJob and oldJob.name or 'none',
            to = newJob and newJob.name or 'none'
        })
        updateJobCache(newJob, oldJob)
    end)

    -- Money change event - update money cache
    lib.events.on('player:money:changed', function(player, account, amount, reason)
        lib.print.info('Player money changed', {
            citizenid = player.citizenid,
            account = account,
            amount = amount,
            reason = reason
        })
        updateMoneyCache(player.money, account, amount, reason)
    end)

    -- Money add event - update money cache
    lib.events.on('player:money:add', function(player, account, amount, reason)
        lib.print.info('Player money added', {
            citizenid = player.citizenid,
            account = account,
            amount = amount,
            reason = reason
        })
        updateMoneyCache(player.money, account, amount, reason)
    end)
end)

-- Register server event handlers
RegisterNetEvent('lib:events:trigger')
AddEventHandler('lib:events:trigger', function(eventName, ...)
    events.trigger(eventName, ...)
end)

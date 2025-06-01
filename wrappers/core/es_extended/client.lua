--[[
    ESX Core Wrapper - Client Side
    Handles ESX framework integration, data normalization, and universal cache management
]]
print(debug.traceback("ESX Core Wrapper - Client Side",1))
if  GetResourceState('es_extended') ~= 'started' then
    return
end

local Core = lib.class('Core')
local ESX = exports['es_extended']:getSharedObject()

-- Data normalization function
local function normalizePlayerData(playerData)
    if not playerData then return nil end

    local normalized = {
        -- Universal identifiers
        citizenid = playerData.identifier,
        identifier = playerData.identifier,
        name = playerData.name,

        -- Job data
        job = {
            name = playerData.job and playerData.job.name or 'unemployed',
            label = playerData.job and playerData.job.label or 'Unemployed',
            grade = playerData.job and playerData.job.grade or 0,
            salary = playerData.job and playerData.job.grade_salary or 0,
            onduty = true -- ESX doesn't handle duty by default
        },

        -- Gang data (if exists)
        gang = playerData.gang and {
            name = playerData.gang.name,
            grade = playerData.gang.grade,
            label = playerData.gang.label
        } or { name = 'none', grade = 0, label = 'None' },

        -- Money data
        money = {
            cash = 0,
            bank = 0,
            black_money = 0
        },

        -- Metadata
        metadata = playerData.metadata or {},

        -- Original ESX object for advanced usage
        _original = playerData
    }

    -- Normalize accounts to money structure
    if playerData.accounts then
        for i = 1, #playerData.accounts do
            local account = playerData.accounts[i]
            if account.name == 'money' then
                normalized.money.cash = account.money
            elseif account.name == 'bank' then
                normalized.money.bank = account.money
            elseif account.name == 'black_money' then
                normalized.money.black_money = account.money
            end
        end
    end

    return normalized
end

-- Universal cache management using ox_lib's native cache
local function updateUniversalCache(key, data)
    cache:set(key, data)
end

local function getFromUniversalCache(key)
    return cache[key]
end

local function clearUniversalCache()
    cache:set('playerData', nil)
    cache:set('citizenid', nil)
    cache:set('job', nil)
    cache:set('gang', nil)
    cache:set('money', nil)
    cache:set('metadata', nil)
end

-- Update player cache and emit universal event
local function updatePlayerCache(playerData)
    local normalized = normalizePlayerData(playerData)
    if not normalized then return end

    -- Update universal cache (framework-agnostic)
    updateUniversalCache('playerData', normalized)
    updateUniversalCache('citizenid', normalized.citizenid)
    updateUniversalCache('job', normalized.job)
    updateUniversalCache('gang', normalized.gang)
    updateUniversalCache('money', normalized.money)
    updateUniversalCache('metadata', normalized.metadata)

    -- Emit universal event
    if lib.events then
        lib.events.trigger('player:loaded', normalized)
    end

    return normalized
end

-- Update job cache and emit universal event
local function updateJobCache(jobData, oldJob)
    if not jobData then return end

    updateUniversalCache('job', jobData)

    -- Update player data cache with new job
    local playerData = getFromUniversalCache('playerData')
    if playerData then
        playerData.job = jobData
        updateUniversalCache('playerData', playerData)
    end

    -- Emit universal event
    if lib.events then
        lib.events.trigger('player:job:changed', playerData, oldJob, jobData)
    end
end

-- Update money cache and emit universal event
local function updateMoneyCache(account, amount, reason)
    local money = getFromUniversalCache('money') or {}
    money[account] = (money[account] or 0) + amount
    updateUniversalCache('money', money)

    -- Update player data cache with new money
    local playerData = getFromUniversalCache('playerData')
    if playerData then
        playerData.money = money
        updateUniversalCache('playerData', playerData)
    end

    -- Emit universal event
    if lib.events then
        lib.events.trigger('player:money:add', playerData, account, amount, reason)
    end
end

-- Constructor
function Core:constructor()
    self.framework = 'esx'
    self.frameworkObject = ESX
    self:setupEventListeners()
end

-- Setup ESX event listeners
function Core:setupEventListeners()
    -- Player loaded event
    RegisterNetEvent('esx:playerLoaded', function(playerData)
        updatePlayerCache(playerData)
    end)

    -- Player logout event
    AddEventHandler('esx:playerLogout', function()
        clearUniversalCache()
    end)

    -- Job change event
    RegisterNetEvent('esx:setJob', function(job)
        local oldJob = getFromUniversalCache('job')
        updateJobCache(job, oldJob)
    end)

    -- Money events
    RegisterNetEvent('esx:addMoney', function(account, amount)
        updateMoneyCache(account, amount, 'esx:addMoney')
    end)

    RegisterNetEvent('esx:removeMoney', function(account, amount)
        updateMoneyCache(account, -amount, 'esx:removeMoney')
    end)

    RegisterNetEvent('esx:setAccountMoney', function(account, money)
        local currentMoney = getFromUniversalCache('money') or {}
        local oldAmount = currentMoney[account] or 0
        local difference = money - oldAmount

        updateMoneyCache(account, difference, 'esx:setAccountMoney')
    end)
end

-- Core methods using universal cache
function Core:getPlayerData()
    local cachedData = getFromUniversalCache('playerData')
    if cachedData then
        return cachedData
    end

    -- Fallback to ESX API
    local playerData = ESX.GetPlayerData()
    return normalizePlayerData(playerData)
end

function Core:getJob()
    local job = getFromUniversalCache('job')
    if job then
        return job.name
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.job.name
end

function Core:getJobGrade()
    local job = getFromUniversalCache('job')
    if job then
        return job.grade
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.job.grade
end

function Core:getJobLabel()
    local job = getFromUniversalCache('job')
    if job then
        return job.label
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.job.label
end

function Core:getMoney(account)
    account = account or 'cash'

    local money = getFromUniversalCache('money')
    if money then
        return money[account] or 0
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.money[account] or 0
end

function Core:getIdentifier()
    local citizenid = getFromUniversalCache('citizenid')
    if citizenid then
        return citizenid
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.citizenid
end

function Core:isPlayerLoaded()
    return getFromUniversalCache('citizenid') ~= nil
end

-- Gang methods
function Core:getGang()
    local gang = getFromUniversalCache('gang')
    if gang then
        return gang.name
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.name or 'none'
end

function Core:getGangGrade()
    local gang = getFromUniversalCache('gang')
    if gang then
        return gang.grade
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.grade or 0
end

function Core:getGangLabel()
    local gang = getFromUniversalCache('gang')
    if gang then
        return gang.label
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.label or 'None'
end

-- Metadata methods
function Core:getMetadata(key)
    local metadata = getFromUniversalCache('metadata')
    if metadata then
        return key and metadata[key] or metadata
    end

    local playerData = self:getPlayerData()
    if not playerData or not playerData.metadata then return nil end

    return key and playerData.metadata[key] or playerData.metadata
end

function Core:setMetadata(key, value)
    local metadata = getFromUniversalCache('metadata') or {}
    metadata[key] = value
    updateUniversalCache('metadata', metadata)

    TriggerServerEvent('esx:setPlayerMetadata', key, value)
end

-- Framework-specific methods
function Core:showNotification(message, type, duration)
    ESX.ShowNotification(message, type, duration)
end

function Core:showAdvancedNotification(title, subject, msg, icon, iconType)
    ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end

-- Cache management
function Core:refreshCache()
    clearUniversalCache()
    local playerData = ESX.GetPlayerData()
    return updatePlayerCache(playerData)
end

function Core:clearCache()
    clearUniversalCache()
end

-- Compatibility methods for QB-Core
function Core:getCitizenId()
    return self:getIdentifier()
end

function Core:isLoggedIn()
    return self:isPlayerLoaded()
end

return Core

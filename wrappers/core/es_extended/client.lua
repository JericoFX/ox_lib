--[[
    ESX Core Wrapper - Client Side
    Handles ESX framework integration, data normalization, and universal cache management
]]
if GetResourceState('es_extended') ~= 'started' then
    return
end

local Core = lib.class('Core')
local ESX = exports['es_extended']:getSharedObject()

local normalize = require 'wrappers.core.normalizer'

local esxMap = {
    id       = 'identifier',
    name     = 'name',

    job      = function(pd)
        return {
            name   = pd.job and pd.job.name or 'unemployed',
            label  = pd.job and pd.job.label or 'Unemployed',
            grade  = pd.job and pd.job.grade or 0,
            salary = pd.job and pd.job.grade_salary or 0,
            onduty = true
        }
    end,

    gang     = function(pd)
        return pd.gang and {
            name  = pd.gang.name,
            label = pd.gang.label,
            grade = pd.gang.grade
        } or { name = 'none', label = 'None', grade = 0 }
    end,

    money    = function(pd)
        local m = { cash = 0, bank = 0, black_money = 0 }
        if pd.accounts then
            for _, acc in ipairs(pd.accounts) do
                if acc.name == 'money' then
                    m.cash = acc.money
                elseif acc.name == 'bank' then
                    m.bank = acc.money
                elseif acc.name == 'black_money' then
                    m.black_money = acc.money
                end
            end
        end
        return m
    end,

    metadata = 'metadata'
}

local function normalizePlayerData(playerData)
    return normalize(playerData, esxMap)
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
    cache:set('id', nil)
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
    updateUniversalCache('id', normalized.id)
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
    local refreshed = self:refreshCache()
    if refreshed then
        return refreshed
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
    local id = getFromUniversalCache('id')
    if id then
        return id
    end

    local playerData = self:getPlayerData()
    return playerData and playerData.id
end

function Core:isPlayerLoaded()
    return getFromUniversalCache('id') ~= nil
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

-- function Core:setMetadata(key, value)
--     local metadata = getFromUniversalCache('metadata') or {}
--     metadata[key] = value
--     updateUniversalCache('metadata', metadata)

--     TriggerServerEvent('esx:setPlayerMetadata', key, value)
-- end

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

-- Removed deprecated QB-Core compatibility block

return Core

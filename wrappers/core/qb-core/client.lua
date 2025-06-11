--[[
    QB-Core Wrapper - Client Side
    Handles QB-Core framework integration, data normalization, and universal cache management
]]
if GetResourceState('qb-core') ~= 'started' then
    -- No need for error if is not finded
    return
end

local Core = lib.class('Core')
local QBCore = exports['qb-core']:GetCoreObject()

-- Data normalization function
local function normalizePlayerData(playerData)
    if not playerData then return nil end

    local normalized = {
        -- Universal identifiers
        citizenid = playerData.citizenid,
        identifier = playerData.citizenid,
        name = playerData.charinfo and (playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname) or 'Unknown',

        -- Job data
        job = {
            name = playerData.job and playerData.job.name or 'unemployed',
            label = playerData.job and playerData.job.label or 'Unemployed',
            grade = playerData.job and playerData.job.grade and playerData.job.grade.level or 0,
            salary = playerData.job and playerData.job.payment or 0,
            onduty = playerData.job and playerData.job.onduty or false
        },

        -- Gang data
        gang = {
            name = playerData.gang and playerData.gang.name or 'none',
            label = playerData.gang and playerData.gang.label or 'None',
            grade = playerData.gang and playerData.gang.grade and playerData.gang.grade.level or 0
        },

        -- Money data
        money = {
            cash = playerData.money and playerData.money.cash or 0,
            bank = playerData.money and playerData.money.bank or 0,
            crypto = playerData.money and playerData.money.crypto or 0
        },

        -- Character info
        charinfo = playerData.charinfo or {},

        -- Metadata
        metadata = playerData.metadata or {},

        -- Original QB-Core object for advanced usage
        _original = playerData
    }

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
    money[account] = amount
    updateUniversalCache('money', money)

    -- Update player data cache with new money
    local playerData = getFromUniversalCache('playerData')
    if playerData then
        playerData.money = money
        updateUniversalCache('playerData', playerData)
    end

    -- Emit universal event
    if lib.events then
        lib.events.trigger('player:money:changed', playerData, account, amount, reason)
    end
end

-- Constructor
function Core:constructor()
    self.framework = 'qb-core'
    self.frameworkObject = QBCore
    self:setupEventListeners()
end

-- Setup QB-Core event listeners
function Core:setupEventListeners()
    -- Player loaded event
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        local playerData = QBCore.Functions.GetPlayerData()
        updatePlayerCache(playerData)
    end)

    -- Player logout event
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        clearUniversalCache()
    end)

    -- Job update event
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
        local oldJob = getFromUniversalCache('job')
        updateJobCache(jobInfo, oldJob)
    end)

    -- Money change event
    RegisterNetEvent('QBCore:Client:OnMoneyChange', function(account, amount, reason)
        updateMoneyCache(account, amount, reason or 'QBCore:Client:OnMoneyChange')
    end)
end

-- Core methods using universal cache
function Core:getPlayerData()
    local cachedData = getFromUniversalCache('playerData')
    if cachedData then
        return cachedData
    end

    -- Fallback to QB-Core API
    local playerData = QBCore.Functions.GetPlayerData()
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

-- Framework-specific methods
function Core:showNotification(message, type, duration)
    QBCore.Functions.Notify(message, type, duration)
end

function Core:drawText(text, position)
    QBCore.Functions.DrawText(text, position)
end

function Core:hideText()
    QBCore.Functions.HideText()
end

function Core:progressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    local progressData = {
        label = label,
        duration = duration,
        position = 'bottom',
        useWhileDead = useWhileDead or false,
        allowRagdoll = true,
        allowCuffed = false,
        allowFalling = false, 
        allowSwimming = false,
        canCancel = canCancel or false,
        anim = animation,
        prop = prop,
        disable = disableControls or {
            move = true,
            sprint = true,
            car = false,
            combat = true,
            mouse = false
        }
    }
    
    if propTwo then
        if type(progressData.prop) == 'table' and progressData.prop.model then
            progressData.prop = {progressData.prop, propTwo}
        else
            progressData.prop = propTwo
        end
    end
    
    local success = lib.progressBar(progressData)
    
    if success and onFinish then 
        onFinish() 
    elseif not success and onCancel then
        onCancel()
    end
end

-- Cache management
function Core:refreshCache()
    clearUniversalCache()
    local playerData = QBCore.Functions.GetPlayerData()
    return updatePlayerCache(playerData)
end

function Core:clearCache()
    clearUniversalCache()
end

-- Compatibility methods for ESX
function Core:getCitizenId()
    return self:getIdentifier()
end

function Core:isLoggedIn()
    return self:isPlayerLoaded()
end

return Core

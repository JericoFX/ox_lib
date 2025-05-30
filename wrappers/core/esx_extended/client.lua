--[[
    ESX pasarlo a clase y lo mismo que el qb
]]

-- Crear clase local, NO asignar a lib.core directamente
local Core = lib.class('Core')

local ESX = exports['es_extended']:getSharedObject()

local function normalizePlayerData()
    -- Try to get from cache first
    if cache.playerData then
        return cache.playerData
    end

    -- Fallback to ESX API
    local playerData = ESX.GetPlayerData()
    if not playerData then return nil end

    local normalizedData = {
        -- Identificadores normalizados
        citizenid = playerData.identifier,
        identifier = playerData.identifier,
        name = playerData.name,

        -- Job normalizado
        job = {
            name = playerData.job and playerData.job.name,
            label = playerData.job and playerData.job.label,
            grade = playerData.job and playerData.job.grade,
            salary = playerData.job and playerData.job.grade_salary,
            onduty = true -- ESX no maneja duty por defecto
        },

        -- Gang normalizado (si existe)
        gang = playerData.gang and {
            name = playerData.gang.name,
            grade = playerData.gang.grade,
            label = playerData.gang.label
        } or { name = 'none', grade = 0, label = 'None' },

        -- Money normalizado
        money = {
            cash = 0,
            bank = 0,
            black_money = 0
        },

        -- Metadata si existe
        metadata = playerData.metadata or {},

        -- Acceso directo al objeto original
        _original = playerData
    }

    -- Normalizar accounts a money
    if playerData.accounts then
        for i = 1, #playerData.accounts do
            local account = playerData.accounts[i]
            if account.name == 'money' then
                normalizedData.money.cash = account.money
            elseif account.name == 'bank' then
                normalizedData.money.bank = account.money
            elseif account.name == 'black_money' then
                normalizedData.money.black_money = account.money
            end
        end
    end

    -- Cache individual fields for faster access
    cache.playerData = normalizedData
    cache.citizenid = normalizedData.citizenid
    cache.job = normalizedData.job
    cache.money = normalizedData.money
    cache.gang = normalizedData.gang
    cache.metadata = normalizedData.metadata

    -- Cache the normalized data if events cache is available
    if lib.events and lib.events.cache and lib.events.cache.updatePlayer then
        lib.events.cache.updatePlayer(normalizedData)
    end

    return normalizedData
end

--- Constructor de la clase
function Core:constructor()
    self.framework = 'esx'
    self.frameworkObject = ESX
    self:setupEventListeners()
end

-- Setup de eventos para actualizar cache automáticamente
function Core:setupEventListeners()
    -- Eventos ESX que actualizan cache
    RegisterNetEvent('esx:setJob', function(job)
        cache.job = job
        -- Usar lib.events.cache si existe
        if lib.events and lib.events.cache and lib.events.cache.updateJob then
            lib.events.cache.updateJob(job)
        end
    end)

    RegisterNetEvent('esx:playerLoaded', function(playerData)
        normalizePlayerData()
    end)

    RegisterNetEvent('esx:addMoney', function(account, amount)
        if not cache.money then cache.money = {} end
        cache.money[account] = (cache.money[account] or 0) + amount

        -- Usar lib.events.cache si existe
        if lib.events and lib.events.cache and lib.events.cache.updateMoney then
            lib.events.cache.updateMoney(cache.money)
        end
    end)

    RegisterNetEvent('esx:removeMoney', function(account, amount)
        if not cache.money then cache.money = {} end
        cache.money[account] = (cache.money[account] or 0) - amount

        -- Usar lib.events.cache si existe
        if lib.events and lib.events.cache and lib.events.cache.updateMoney then
            lib.events.cache.updateMoney(cache.money)
        end
    end)
end

-- Métodos de la clase optimizados con cache directo
function Core:getPlayerData()
    -- Try cache first, fallback to API
    if cache.playerData then
        return cache.playerData
    end

    return normalizePlayerData()
end

function Core:getJob()
    -- Try cache first
    if cache.job then
        return cache.job.name
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.name
end

function Core:getJobGrade()
    -- Try cache first
    if cache.job then
        return cache.job.grade
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.grade
end

function Core:getJobLabel()
    -- Try cache first
    if cache.job then
        return cache.job.label
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.label
end

function Core:getMoney(account)
    account = account or 'cash'

    -- Try cache first
    if cache.money then
        return cache.money[account] or 0
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    if not playerData then return 0 end

    return playerData.money[account] or 0
end

function Core:getIdentifier()
    -- Try cache first
    if cache.citizenid then
        return cache.citizenid
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.citizenid
end

function Core:isPlayerLoaded()
    -- Try cache first
    if cache.citizenid then
        return true
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.citizenid ~= nil
end

function Core:showNotification(message, type, duration)
    ESX.ShowNotification(message, type, duration)
end

function Core:showAdvancedNotification(title, subject, msg, icon, iconType)
    ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end

-- Permission system
function Core:hasPermission(permission)
    local playerData = self:getPlayerData()
    if not playerData then return false end

    local group = playerData._original.group
    if group == 'admin' or group == 'superadmin' then
        return true
    end

    -- Check ACE permissions if available
    if IsPlayerAceAllowed then
        return IsPlayerAceAllowed(cache.serverId, permission)
    end

    return false
end

-- Command execution
function Core:executeCommand(command, args)
    args = args or {}
    ExecuteCommand(string.format('%s %s', command, table.concat(args, ' ')))
end

-- Teleportation
function Core:teleport(coords, heading)
    local ped = cache.ped or PlayerPedId()
    local oldCoords = GetEntityCoords(ped)

    if type(coords) == 'table' then
        SetEntityCoords(ped, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], false, false, false, true)
        if heading or coords.w or coords[4] then
            SetEntityHeading(ped, heading or coords.w or coords[4])
        end

        -- Log teleport event
        self:log('info', 'Player teleported', {
            from = oldCoords,
            to = coords
        })
    end
end

-- Item management
function Core:giveItem(item, amount, metadata)
    amount = amount or 1

    if exports.ox_inventory then
        return exports.ox_inventory:AddItem(item, amount, metadata)
    else
        -- Fallback to ESX
        ESX.TriggerServerCallback('esx:addInventoryItem', function(success)
            return success
        end, item, amount)
        return true
    end
end

function Core:removeItem(item, amount)
    amount = amount or 1

    if exports.ox_inventory then
        return exports.ox_inventory:RemoveItem(item, amount)
    else
        -- Fallback to ESX
        ESX.TriggerServerCallback('esx:removeInventoryItem', function(success)
            return success
        end, item, amount)
        return true
    end
end

-- Logging system
function Core:log(level, message, data)
    local logData = {
        framework = self.framework,
        level = level,
        message = message,
        data = data,
        timestamp = os.time(),
        player = self:getIdentifier(),
        ped = cache.ped,
        vehicle = cache.vehicle,
        weapon = cache.weapon,
        coords = cache.ped and GetEntityCoords(cache.ped) or nil
    }

    TriggerServerEvent('ox_lib:log', logData)
end

-- QB-Core compatibility methods
function Core:getCitizenId()
    return self:getIdentifier()
end

function Core:isLoggedIn()
    return self:isPlayerLoaded()
end

function Core:getPlayerGang()
    return {
        name = self:getGang(),
        grade = { level = self:getGangGrade() },
        label = self:getGangLabel()
    }
end

-- Método adicional para debugging
function Core:getFramework()
    return self.framework
end

-- Método para invalidar cache manualmente
function Core:invalidateCache()
    cache.playerData = nil
    cache.job = nil
    cache.money = nil
    cache.citizenid = nil
    cache.gang = nil
    cache.metadata = nil

    if lib.events and lib.events.cache and lib.events.cache.clear then
        lib.events.cache.clear()
    end
end

-- Método para refrescar datos completos
function Core:refreshPlayerData()
    self:invalidateCache()
    local freshData = normalizePlayerData()
    self:log('debug', 'Player data refreshed', { identifier = freshData.citizenid })
    return freshData
end

-- Event listeners para cache de ox_lib
function Core:onVehicleChange(callback)
    AddEventHandler('ox_lib:cache:vehicle', callback)
end

function Core:onWeaponChange(callback)
    AddEventHandler('ox_lib:cache:weapon', callback)
end

function Core:onPedChange(callback)
    AddEventHandler('ox_lib:cache:ped', callback)
end

-- Gang methods
function Core:getGang()
    -- Try cache first
    if cache.gang then
        return cache.gang.name
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.name or 'none'
end

function Core:getGangGrade()
    -- Try cache first
    if cache.gang then
        return cache.gang.grade
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.grade or 0
end

function Core:getGangLabel()
    -- Try cache first
    if cache.gang then
        return cache.gang.label
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.gang and playerData.gang.label or 'None'
end

-- Metadata methods
function Core:getMetadata(key)
    -- Try cache first
    if cache.metadata then
        return key and cache.metadata[key] or cache.metadata
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    if not playerData or not playerData._original.metadata then return nil end

    return key and playerData._original.metadata[key] or playerData._original.metadata
end

function Core:setMetadata(key, value)
    if not cache.metadata then cache.metadata = {} end
    cache.metadata[key] = value

    -- Trigger server event to save metadata
    TriggerServerEvent('esx:setPlayerMetadata', key, value)
end

-- Inventory methods
function Core:getInventoryItems()
    return ESX.GetPlayerData().inventory or {}
end

function Core:hasItem(itemName, amount)
    local inventory = self:getInventoryItems()
    amount = amount or 1

    for i = 1, #inventory do
        local item = inventory[i]
        if item.name == itemName and item.count >= amount then
            return true
        end
    end

    return false
end

-- Vehicle methods
function Core:getVehicles()
    -- Use callback to get owned vehicles
    return lib.callback.await('esx:getOwnedVehicles', false) or {}
end

-- Job duty methods (for compatibility)
function Core:isOnDuty()
    local playerData = self:getPlayerData()
    return playerData and playerData.job.onduty or false
end

function Core:setDuty(onDuty)
    if cache.job then
        cache.job.onduty = onDuty
    end
    TriggerServerEvent('esx:setJobDuty', onDuty)
end

-- Retornar la clase para que shared.lua la asigne a lib.core
return Core

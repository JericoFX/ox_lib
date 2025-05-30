-- Advanced NPC System for ox_lib
-- Provides intelligent NPC behavior, scheduling, interactions, and AI routines

local npc = {}
local activeNPCs = {}
local behaviors = {}
local interactions = {}
local schedules = {}
local relationships = {}
local aiStates = {}

-- NPC AI States
aiStates.IDLE = 'idle'
aiStates.PATROLLING = 'patrolling'
aiStates.INTERACTING = 'interacting'
aiStates.WORKING = 'working'
aiStates.ALERT = 'alert'
aiStates.FLEEING = 'fleeing'
aiStates.PURSUING = 'pursuing'

-- Initialize NPC system with main update loop
CreateThread(function()
    while true do
        for npcId, npcData in pairs(activeNPCs) do
            if DoesEntityExist(npcData.ped) then
                npc.updateAI(npcId)
                npc.updateSchedule(npcId)
                npc.updateRelationships(npcId)
            else
                -- Clean up deleted NPCs
                npc.cleanup(npcId)
            end
        end
        Wait(2000) -- Update every 2 seconds for performance
    end
end)

-- Register custom behavior
function npc.registerBehavior(name, behaviorFunc)
    behaviors[name] = behaviorFunc
    print('[NPC] Registered behavior: ' .. name)
    return true
end

-- Advanced Patrol Behavior
behaviors.patrol = function(npcData)
    local ped = npcData.ped
    local points = npcData.config.patrolPoints or {}

    if #points < 2 then return end

    local targetPoint = points[npcData.patrolIndex or 1]
    local coords = GetEntityCoords(ped)
    local distance = #(coords - vector3(targetPoint.x, targetPoint.y, targetPoint.z))

    if distance > 2.0 then
        -- Move to patrol point
        npcData.aiState = aiStates.PATROLLING

        -- Use different movement types based on NPC type
        if npcData.config.movementStyle == 'cautious' then
            TaskGoStraightToCoord(ped, targetPoint.x, targetPoint.y, targetPoint.z, 0.5, -1, targetPoint.heading or 0.0, 0.0)
        elseif npcData.config.movementStyle == 'urgent' then
            TaskGoToCoordAnyMeans(ped, targetPoint.x, targetPoint.y, targetPoint.z, 2.0, 0, 0, 786603, 0xbf800000)
        else
            TaskGoToCoordAnyMeans(ped, targetPoint.x, targetPoint.y, targetPoint.z, 1.0, 0, 0, 786603, 0xbf800000)
        end
    else
        -- Reached patrol point
        npcData.aiState = aiStates.IDLE
        npcData.patrolIndex = (npcData.patrolIndex or 1) % #points + 1

        -- Wait and look around
        local waitTime = npcData.config.patrolWait or math.random(5000, 15000)
        TaskStandStill(ped, waitTime)

        -- Random look around behavior
        if math.random() < 0.3 then
            local lookDirection = math.random(0, 360)
            TaskTurnPedToFaceCoord(ped, coords.x + math.cos(math.rad(lookDirection)), coords.y + math.sin(math.rad(lookDirection)), coords.z, waitTime)
        end
    end
end

-- Enhanced Guard Behavior with Alertness Levels
behaviors.guard = function(npcData)
    local ped = npcData.ped
    local guardZone = npcData.config.guardZone
    local alertLevel = npcData.alertLevel or 0

    if not guardZone then return end

    -- Scan for threats
    local threats = npc.detectThreats(npcData)

    if #threats > 0 then
        local primaryThreat = threats[1]
        npc.handleThreat(npcData, primaryThreat)
    else
        -- No threats - reduce alert level over time
        if alertLevel > 0 then
            npcData.alertLevel = math.max(0, alertLevel - 0.1)

            if npcData.alertLevel <= 0 then
                npcData.aiState = aiStates.IDLE
                ClearPedTasks(ped)
            end
        end

        -- Resume normal guard duties
        if npcData.aiState ~= aiStates.ALERT then
            npc.performGuardDuties(npcData)
        end
    end
end

-- Intelligent Civilian Behavior
behaviors.civilian = function(npcData)
    local ped = npcData.ped
    local playerCoords = GetEntityCoords(PlayerPedId())
    local npcCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - npcCoords)

    -- React based on player proximity and behavior
    if distance < 5.0 then
        local playerPed = PlayerPedId()
        local weapon = GetSelectedPedWeapon(playerPed)
        local isPlayerRunning = IsPedRunning(playerPed)
        local isPlayerArmed = weapon ~= GetHashKey('WEAPON_UNARMED')

        if isPlayerArmed or (isPlayerRunning and distance < 2.0) then
            -- Player seems threatening - show fear
            npc.showFearReaction(npcData)
        elseif distance < 3.0 and not npcData.hasInteracted then
            -- Friendly interaction
            npc.friendlyInteraction(npcData)
        end
    elseif distance > 15.0 then
        -- Reset interaction states when player is far
        npcData.hasInteracted = false
        npcData.fearLevel = 0
        npcData.aiState = aiStates.IDLE
    end

    -- Ambient civilian activities
    if npcData.aiState == aiStates.IDLE then
        npc.performCivilianActivities(npcData)
    end
end

-- Advanced Worker Behavior with Task Management
behaviors.worker = function(npcData)
    local ped = npcData.ped
    local workLocation = npcData.config.workLocation
    local workTasks = npcData.config.workTasks or { 'WORLD_HUMAN_CLIPBOARD' }

    if not workLocation then return end

    local coords = GetEntityCoords(ped)
    local distance = #(coords - workLocation)

    if distance > 3.0 then
        -- Go to work location
        TaskGoToCoordAnyMeans(ped, workLocation.x, workLocation.y, workLocation.z, 1.0, 0, 0, 786603, 0xbf800000)
        npcData.aiState = 'traveling_to_work'
    else
        -- At work location - perform work tasks
        npcData.aiState = aiStates.WORKING

        if not IsPedActiveInScenario(ped) then
            local currentTask = workTasks[npcData.currentTaskIndex or 1]
            TaskStartScenarioInPlace(ped, currentTask, 0, true)

            -- Change task periodically
            SetTimeout(math.random(30000, 60000), function()
                if DoesEntityExist(ped) and npcData.aiState == aiStates.WORKING then
                    ClearPedTasks(ped)
                    npcData.currentTaskIndex = (npcData.currentTaskIndex or 1) % #workTasks + 1
                end
            end)
        end
    end
end

-- Vendor/Shopkeeper Behavior
behaviors.vendor = function(npcData)
    local ped = npcData.ped
    local shopArea = npcData.config.shopArea

    if not shopArea then return end

    -- Look for customers
    local customers = npc.findNearbyPlayers(npcData, 5.0)

    if #customers > 0 then
        local primaryCustomer = GetPlayerPed(customers[1])
        TaskTurnPedToFaceEntity(ped, primaryCustomer, -1)

        if not npcData.hasGreetedCustomer then
            -- Greet customer
            TaskPlayAnim(ped, 'gestures@m@standing@casual', 'gesture_hello', 8.0, -8.0, 2000, 48, 0, false, false, false)
            npcData.hasGreetedCustomer = true
            npcData.customerTimeout = GetGameTimer() + 30000
        end
    else
        -- No customers - reset state
        if GetGameTimer() > (npcData.customerTimeout or 0) then
            npcData.hasGreetedCustomer = false
        end

        -- Idle vendor activities
        if math.random() < 0.1 then
            local vendorActivities = {
                'WORLD_HUMAN_STAND_MOBILE',
                'WORLD_HUMAN_CLIPBOARD'
            }
            local activity = vendorActivities[math.random(#vendorActivities)]
            TaskStartScenarioInPlace(ped, activity, 0, true)
        end
    end
end

-- Create advanced NPC with comprehensive configuration
function npc.create(config)
    if not config.model or not config.coords then
        print('[NPC] Error: Model and coords are required')
        return false
    end

    -- Load model
    local modelHash = GetHashKey(config.model)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 5000 do
            Wait(100)
            timeout = timeout + 100
        end

        if not HasModelLoaded(modelHash) then
            print('[NPC] Error: Failed to load model ' .. config.model)
            return false
        end
    end

    -- Create ped with advanced settings
    local ped = CreatePed(4, modelHash, config.coords.x, config.coords.y, config.coords.z, config.heading or 0.0, false, true)

    if not DoesEntityExist(ped) then
        print('[NPC] Error: Failed to create ped')
        return false
    end

    -- Advanced ped configuration
    SetEntityInvincible(ped, config.invincible or false)
    FreezeEntityPosition(ped, config.frozen or false)
    SetBlockingOfNonTemporaryEvents(ped, config.blockEvents ~= false)
    SetPedCanRagdoll(ped, config.canRagdoll ~= false)

    -- Combat and weapon settings
    if config.combat then
        SetPedCombatAbility(ped, config.combat.ability or 2)
        SetPedCombatRange(ped, config.combat.range or 2)
        SetPedCombatMovement(ped, config.combat.movement or 2)

        if config.combat.weapon then
            GiveWeaponToPed(ped, GetHashKey(config.combat.weapon), 250, false, true)
        end
    end

    -- Appearance customization
    if config.appearance then
        npc.setAppearance(ped, config.appearance)
    end

    -- Generate unique ID
    local npcId = #activeNPCs + 1

    -- Initialize comprehensive NPC data
    activeNPCs[npcId] = {
        ped = ped,
        config = config,
        aiState = aiStates.IDLE,
        currentBehavior = nil,
        schedule = config.schedule or {},
        patrolIndex = 1,
        alertLevel = 0,
        fearLevel = 0,
        relationships = {},
        memory = {},
        lastUpdate = GetGameTimer(),
        lastInteraction = 0,
        customData = config.customData or {}
    }

    -- Setup advanced features
    if config.schedule then
        npc.setupSchedule(npcId, config.schedule)
    end

    if config.interactions then
        npc.setupInteractions(npcId, config.interactions)
    end

    if config.relationships then
        npc.setupRelationships(npcId, config.relationships)
    end

    -- Set initial behavior
    if config.behaviors and #config.behaviors > 0 then
        npc.changeBehavior(npcId, config.behaviors[1])
    end

    print('[NPC] Created advanced NPC with ID: ' .. npcId)
    return npcId
end

-- AI Update System
function npc.updateAI(npcId)
    local npcData = activeNPCs[npcId]
    if not npcData or not DoesEntityExist(npcData.ped) then return end

    -- Update memory system
    npc.updateMemory(npcData)

    -- Execute current behavior
    if npcData.currentBehavior and behaviors[npcData.currentBehavior] then
        behaviors[npcData.currentBehavior](npcData)
    end

    -- Update last update time
    npcData.lastUpdate = GetGameTimer()
end

-- Schedule Management
function npc.updateSchedule(npcId)
    local npcData = activeNPCs[npcId]
    if not npcData.schedule then return end

    local currentHour = GetClockHours()
    local scheduledBehavior = npcData.schedule[currentHour]

    if scheduledBehavior and scheduledBehavior ~= npcData.currentBehavior then
        npc.changeBehavior(npcId, scheduledBehavior)
    end
end

-- Advanced Threat Detection
function npc.detectThreats(npcData)
    local threats = {}
    local ped = npcData.ped
    local coords = GetEntityCoords(ped)
    local guardZone = npcData.config.guardZone

    if not guardZone then return threats end

    -- Check all players in area
    for _, playerId in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - coords)

        if distance <= guardZone.radius then
            local threatLevel = npc.assessThreatLevel(npcData, playerPed)

            if threatLevel > 0 then
                table.insert(threats, {
                    ped = playerPed,
                    coords = playerCoords,
                    distance = distance,
                    threatLevel = threatLevel,
                    playerId = playerId
                })
            end
        end
    end

    -- Sort by threat level
    table.sort(threats, function(a, b) return a.threatLevel > b.threatLevel end)

    return threats
end

-- Threat Assessment
function npc.assessThreatLevel(npcData, targetPed)
    local threatLevel = 0
    local weapon = GetSelectedPedWeapon(targetPed)

    -- Armed threat
    if weapon ~= GetHashKey('WEAPON_UNARMED') then
        threatLevel = threatLevel + 3
    end

    -- Running towards NPC
    if IsPedRunning(targetPed) then
        local targetCoords = GetEntityCoords(targetPed)
        local npcCoords = GetEntityCoords(npcData.ped)
        local velocity = GetEntityVelocity(targetPed)

        -- Check if running towards NPC
        local directionToNPC = npcCoords - targetCoords
        if velocity.x * directionToNPC.x + velocity.y * directionToNPC.y > 0 then
            threatLevel = threatLevel + 1
        end
    end

    -- Vehicle threat
    local vehicle = GetVehiclePedIsIn(targetPed, false)
    if vehicle ~= 0 then
        local speed = GetEntitySpeed(vehicle)
        if speed > 15.0 then -- High speed
            threatLevel = threatLevel + 2
        end
    end

    -- Wanted level (if applicable)
    local wantedLevel = GetPlayerWantedLevel(NetworkGetPlayerIndexFromPed(targetPed))
    threatLevel = threatLevel + wantedLevel

    return threatLevel
end

-- Handle Threat Response
function npc.handleThreat(npcData, threat)
    local ped = npcData.ped
    npcData.alertLevel = math.min(5, npcData.alertLevel + 0.5)
    npcData.aiState = aiStates.ALERT

    if threat.threatLevel >= 3 then
        -- High threat - engage
        TaskCombatPed(ped, threat.ped, 0, 16)
        npcData.aiState = aiStates.PURSUING

        -- Alert other guards if networked
        if npcData.config.alertNetwork then
            npc.alertNetwork(npcData, threat)
        end
    elseif threat.threatLevel >= 1 then
        -- Medium threat - warn and prepare
        TaskTurnPedToFaceEntity(ped, threat.ped, 3000)

        if npcData.config.canSpeak then
            -- Could trigger warning voice lines here
        end
    end
end

-- Fear Reaction System
function npc.showFearReaction(npcData)
    local ped = npcData.ped
    npcData.fearLevel = math.min(5, npcData.fearLevel + 1)
    npcData.aiState = aiStates.FLEEING

    if npcData.fearLevel >= 3 then
        -- High fear - run away
        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, false, false)
    else
        -- Low fear - show nervous behavior
        TaskPlayAnim(ped, 'amb@world_human_stand_impatient@male@no_props@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end

-- Friendly Interaction
function npc.friendlyInteraction(npcData)
    local ped = npcData.ped

    if not npcData.hasInteracted then
        TaskTurnPedToFaceEntity(ped, PlayerPedId(), -1)

        local greetings = {
            'gestures@m@standing@casual@gesture_hello',
            'gestures@m@standing@casual@gesture_point'
        }

        local greeting = greetings[math.random(#greetings)]
        TaskPlayAnim(ped, 'gestures@m@standing@casual', 'gesture_hello', 8.0, -8.0, 2000, 48, 0, false, false, false)

        npcData.hasInteracted = true
        npcData.lastInteraction = GetGameTimer()
        npcData.aiState = aiStates.INTERACTING
    end
end

-- Civilian Activities
function npc.performCivilianActivities(npcData)
    if GetGameTimer() - npcData.lastInteraction < 30000 then return end

    if math.random() < 0.05 then -- 5% chance every update
        local activities = {
            'WORLD_HUMAN_STAND_MOBILE',
            'WORLD_HUMAN_SMOKING',
            'WORLD_HUMAN_TOURIST_MAP',
            'WORLD_HUMAN_STAND_IMPATIENT'
        }

        local activity = activities[math.random(#activities)]
        TaskStartScenarioInPlace(npcData.ped, activity, 0, true)
    end
end

-- Guard Duties
function npc.performGuardDuties(npcData)
    local ped = npcData.ped

    if math.random() < 0.1 then
        -- Look around alertly
        local coords = GetEntityCoords(ped)
        local lookDirection = math.random(0, 360)
        TaskTurnPedToFaceCoord(ped,
            coords.x + math.cos(math.rad(lookDirection)),
            coords.y + math.sin(math.rad(lookDirection)),
            coords.z, 3000)
    end
end

-- Memory System
function npc.updateMemory(npcData)
    local ped = npcData.ped
    local coords = GetEntityCoords(ped)
    local currentTime = GetGameTimer()

    -- Remember recent player interactions
    local nearbyPlayers = npc.findNearbyPlayers(npcData, 10.0)

    for _, playerId in ipairs(nearbyPlayers) do
        if not npcData.memory[playerId] then
            npcData.memory[playerId] = {
                firstSeen = currentTime,
                lastSeen = currentTime,
                interactions = 0,
                relationship = 0
            }
        else
            npcData.memory[playerId].lastSeen = currentTime
        end
    end

    -- Clean old memories (older than 1 hour)
    for playerId, memoryData in pairs(npcData.memory) do
        if currentTime - memoryData.lastSeen > 3600000 then
            npcData.memory[playerId] = nil
        end
    end
end

-- Utility Functions
function npc.findNearbyPlayers(npcData, radius)
    local players = {}
    local coords = GetEntityCoords(npcData.ped)

    for _, playerId in ipairs(GetActivePlayers()) do
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(coords - playerCoords) <= radius then
            table.insert(players, playerId)
        end
    end

    return players
end

function npc.setAppearance(ped, appearance)
    if appearance.clothing then
        for component, data in pairs(appearance.clothing) do
            SetPedComponentVariation(ped, component, data.drawable, data.texture, data.palette or 0)
        end
    end

    if appearance.props then
        for prop, data in pairs(appearance.props) do
            SetPedPropIndex(ped, prop, data.drawable, data.texture, true)
        end
    end
end

function npc.changeBehavior(npcId, behaviorName)
    local npcData = activeNPCs[npcId]
    if not npcData then return false end

    ClearPedTasks(npcData.ped)
    npcData.currentBehavior = behaviorName
    npcData.aiState = aiStates.IDLE

    print('[NPC] Changed behavior for NPC ' .. npcId .. ' to: ' .. behaviorName)
    return true
end

function npc.setupInteractions(npcId, interactionConfig)
    local npcData = activeNPCs[npcId]
    if not npcData then return end

    interactions[npcId] = interactionConfig

    -- Create interaction zone
    local coords = GetEntityCoords(npcData.ped)
    lib.zones.box({
        coords = coords,
        size = vector3(2, 2, 2),
        options = {
            {
                name = 'interact_npc_' .. npcId,
                label = interactionConfig.label or 'Hablar',
                icon = interactionConfig.icon or 'fa-solid fa-comments',
                onSelect = function()
                    npc.startInteraction(npcId)
                end
            }
        }
    })
end

function npc.setupSchedule(npcId, schedule)
    schedules[npcId] = schedule
end

function npc.setupRelationships(npcId, relationshipConfig)
    relationships[npcId] = relationshipConfig
end

function npc.updateRelationships(npcId)
    local npcData = activeNPCs[npcId]
    local relationshipConfig = relationships[npcId]

    if not relationshipConfig then return end

    -- Update relationships based on interactions and events
    -- This could be expanded based on specific needs
end

function npc.cleanup(npcId)
    if activeNPCs[npcId] then
        local npcData = activeNPCs[npcId]
        if DoesEntityExist(npcData.ped) then
            DeleteEntity(npcData.ped)
        end
    end

    activeNPCs[npcId] = nil
    interactions[npcId] = nil
    schedules[npcId] = nil
    relationships[npcId] = nil
end

function npc.remove(npcId)
    npc.cleanup(npcId)
    return true
end

function npc.getInfo(npcId)
    return activeNPCs[npcId]
end

function npc.getAll()
    return activeNPCs
end

function npc.getAllByBehavior(behaviorName)
    local result = {}
    for npcId, npcData in pairs(activeNPCs) do
        if npcData.currentBehavior == behaviorName then
            result[npcId] = npcData
        end
    end
    return result
end

return npc

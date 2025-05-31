-- Advanced NPC System for ox_lib using lib.class()
-- Object-oriented NPC system with intelligent behavior, scheduling, interactions, and AI routines

-- Create the NPC class using ox_lib's class system
lib.npc = lib.class('NPC')

-- Static class variables
lib.npc.activeNPCs = {}
lib.npc.behaviors = {}
lib.npc.globalInteractions = {}
lib.npc.globalSchedules = {}
lib.npc.globalRelationships = {}

-- AI States constants
lib.npc.AI_STATES = {
    IDLE = 'idle',
    PATROLLING = 'patrolling',
    INTERACTING = 'interacting',
    WORKING = 'working',
    ALERT = 'alert',
    FLEEING = 'fleeing',
    PURSUING = 'pursuing'
}

-- Constructor using ox_lib class system
function lib.npc:constructor(config)
    if not config.model or not config.coords then
        print('[NPC] Error: Model and coords are required')
        error('[NPC] Error: Model and coords are required')
        return
    end

    -- Initialize instance properties using private fields
    self.private.config = config
    self.private.ped = nil
    self.private.id = nil

    -- Public properties
    self.aiState = lib.npc.AI_STATES.IDLE
    self.currentBehavior = nil
    self.schedule = config.schedule or {}
    self.patrolIndex = 1
    self.alertLevel = 0
    self.fearLevel = 0
    self.relationships = {}
    self.memory = {}
    self.lastUpdate = GetGameTimer()
    self.lastInteraction = 0
    self.customData = config.customData or {}
    self.hasInteracted = false
    self.hasGreetedCustomer = false
    self.customerTimeout = 0
    self.currentTaskIndex = 1

    -- Create the actual ped entity
    if not self:_createPed() then
        error('[NPC] Failed to create ped entity')
        return
    end

    -- Generate unique ID and register
    self.private.id = #lib.npc.activeNPCs + 1
    lib.npc.activeNPCs[self.private.id] = self

    -- Setup advanced features
    self:_setupAdvancedFeatures()

    print('[NPC] Created advanced NPC with ID: ' .. self.private.id)
end

-- Getter for ID (since it's private)
function lib.npc:getId()
    return self.private.id
end

-- Getter for config (since it's private)
function lib.npc:getConfig()
    return self.private.config
end

-- Getter for ped (since it's private)
function lib.npc:getPed()
    return self.private.ped
end

-- Private method to create the ped entity
function lib.npc:_createPed()
    local config = self.private.config

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
    local coords = config.coords
    self.private.ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z, config.heading or 0.0, false, true)

    if not DoesEntityExist(self.private.ped) then
        print('[NPC] Error: Failed to create ped')
        return false
    end

    -- Advanced ped configuration
    SetEntityInvincible(self.private.ped, config.invincible or false)
    FreezeEntityPosition(self.private.ped, config.frozen or false)
    SetBlockingOfNonTemporaryEvents(self.private.ped, config.blockEvents ~= false)
    SetPedCanRagdoll(self.private.ped, config.canRagdoll ~= false)

    -- Combat and weapon settings
    if config.combat then
        SetPedCombatAbility(self.private.ped, config.combat.ability or 2)
        SetPedCombatRange(self.private.ped, config.combat.range or 2)
        SetPedCombatMovement(self.private.ped, config.combat.movement or 2)

        if config.combat.weapon then
            GiveWeaponToPed(self.private.ped, GetHashKey(config.combat.weapon), 250, false, true)
        end
    end

    -- Appearance customization
    if config.appearance then
        self:setAppearance(config.appearance)
    end

    return true
end

-- Private method to setup advanced features
function lib.npc:_setupAdvancedFeatures()
    local config = self.private.config

    -- Setup features
    if config.schedule then
        self:setupSchedule(config.schedule)
    end

    if config.interactions then
        self:setupInteractions(config.interactions)
    end

    if config.relationships then
        self:setupRelationships(config.relationships)
    end

    -- Set initial behavior
    if config.behaviors and #config.behaviors > 0 then
        self:changeBehavior(config.behaviors[1])
    end
end

-- Instance method to update AI
function lib.npc:updateAI()
    if not DoesEntityExist(self.private.ped) then return end

    -- Update memory system
    self:updateMemory()

    -- Execute current behavior
    if self.currentBehavior and lib.npc.behaviors[self.currentBehavior] then
        lib.npc.behaviors[self.currentBehavior](self)
    end

    -- Update last update time
    self.lastUpdate = GetGameTimer()
end

-- Instance method to update schedule
function lib.npc:updateSchedule()
    if not self.schedule then return end

    local currentHour = GetClockHours()
    local scheduledBehavior = self.schedule[currentHour]

    if scheduledBehavior and scheduledBehavior ~= self.currentBehavior then
        self:changeBehavior(scheduledBehavior)
    end
end

-- Instance method to update relationships
function lib.npc:updateRelationships()
    local relationshipConfig = lib.npc.globalRelationships[self.private.id]
    if not relationshipConfig then return end

    -- Update relationships based on interactions and events
    -- This could be expanded based on specific needs
end

-- Instance method to detect threats
function lib.npc:detectThreats()
    local threats = {}
    local coords = GetEntityCoords(self.private.ped)
    local guardZone = self.private.config.guardZone

    if not guardZone then return threats end

    -- Check all players in area
    for _, playerId in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - coords)

        if distance <= guardZone.radius then
            local threatLevel = self:assessThreatLevel(playerPed)

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

-- Instance method to assess threat level
function lib.npc:assessThreatLevel(targetPed)
    local threatLevel = 0
    local weapon = GetSelectedPedWeapon(targetPed)

    -- Armed threat
    if weapon ~= GetHashKey('WEAPON_UNARMED') then
        threatLevel = threatLevel + 3
    end

    -- Running towards NPC
    if IsPedRunning(targetPed) then
        local targetCoords = GetEntityCoords(targetPed)
        local npcCoords = GetEntityCoords(self.private.ped)
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

    return threatLevel
end

-- Instance method to handle threats
function lib.npc:handleThreat(threat)
    self.alertLevel = math.min(5, self.alertLevel + 0.5)
    self.aiState = lib.npc.AI_STATES.ALERT

    if threat.threatLevel >= 3 then
        -- High threat - engage
        TaskCombatPed(self.private.ped, threat.ped, 0, 16)
        self.aiState = lib.npc.AI_STATES.PURSUING

        -- Alert other guards if networked
        if self.private.config.alertNetwork then
            self:alertNetwork(threat)
        end
    elseif threat.threatLevel >= 1 then
        -- Medium threat - warn and prepare
        TaskTurnPedToFaceEntity(self.private.ped, threat.ped, 3000)

        if self.private.config.canSpeak then
            -- Could trigger warning voice lines here, dont know how to do it
        end
    end
end

-- Instance method to show fear reaction
function lib.npc:showFearReaction()
    self.fearLevel = math.min(5, self.fearLevel + 1)
    self.aiState = lib.npc.AI_STATES.FLEEING

    if self.fearLevel >= 3 then
        -- High fear - run away
        TaskSmartFleePed(self.private.ped, PlayerPedId(), 100.0, -1, false, false)
    else
        -- Low fear - show nervous behavior
        TaskPlayAnim(self.private.ped, 'amb@world_human_stand_impatient@male@no_props@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end

-- Instance method for friendly interaction
function lib.npc:friendlyInteraction()
    if not self.hasInteracted then
        TaskTurnPedToFaceEntity(self.private.ped, PlayerPedId(), -1)

        TaskPlayAnim(self.private.ped, 'gestures@m@standing@casual', 'gesture_hello', 8.0, -8.0, 2000, 48, 0, false, false, false)

        self.hasInteracted = true
        self.lastInteraction = GetGameTimer()
        self.aiState = lib.npc.AI_STATES.INTERACTING
    end
end

-- Instance method for civilian activities
function lib.npc:performCivilianActivities()
    if GetGameTimer() - self.lastInteraction < 30000 then return end

    if math.random() < 0.05 then -- 5% chance every update
        local activities = {
            'WORLD_HUMAN_STAND_MOBILE',
            'WORLD_HUMAN_SMOKING',
            'WORLD_HUMAN_TOURIST_MAP',
            'WORLD_HUMAN_STAND_IMPATIENT'
        }

        local activity = activities[math.random(#activities)]
        TaskStartScenarioInPlace(self.private.ped, activity, 0, true)
    end
end

-- Instance method for guard duties
function lib.npc:performGuardDuties()
    if math.random() < 0.1 then
        -- Look around alertly
        local coords = GetEntityCoords(self.private.ped)
        local lookDirection = math.random(0, 360)
        TaskTurnPedToFaceCoord(self.private.ped,
            coords.x + math.cos(math.rad(lookDirection)),
            coords.y + math.sin(math.rad(lookDirection)),
            coords.z, 3000)
    end
end

-- Instance method to update memory
function lib.npc:updateMemory()
    local coords = GetEntityCoords(self.private.ped)
    local currentTime = GetGameTimer()

    -- Remember recent player interactions
    local nearbyPlayers = self:findNearbyPlayers(10.0)

    for _, playerId in ipairs(nearbyPlayers) do
        if not self.memory[playerId] then
            self.memory[playerId] = {
                firstSeen = currentTime,
                lastSeen = currentTime,
                interactions = 0,
                relationship = 0
            }
        else
            self.memory[playerId].lastSeen = currentTime
        end
    end

    -- Clean old memories (older than 1 hour)
    for playerId, memoryData in pairs(self.memory) do
        if currentTime - memoryData.lastSeen > 3600000 then
            self.memory[playerId] = nil
        end
    end
end

-- Instance method to find nearby players
function lib.npc:findNearbyPlayers(radius)
    local players = {}
    local coords = GetEntityCoords(self.private.ped)

    for _, playerId in ipairs(GetActivePlayers()) do
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        if #(coords - playerCoords) <= radius then
            table.insert(players, playerId)
        end
    end

    return players
end

-- Instance method to set appearance
function lib.npc:setAppearance(appearance)
    if appearance.clothing then
        for component, data in pairs(appearance.clothing) do
            SetPedComponentVariation(self.private.ped, component, data.drawable, data.texture, data.palette or 0)
        end
    end

    if appearance.props then
        for prop, data in pairs(appearance.props) do
            SetPedPropIndex(self.private.ped, prop, data.drawable, data.texture, true)
        end
    end
end

-- Instance method to change behavior
function lib.npc:changeBehavior(behaviorName)
    ClearPedTasks(self.private.ped)
    self.currentBehavior = behaviorName
    self.aiState = lib.npc.AI_STATES.IDLE

    print('[NPC] Changed behavior for NPC ' .. self.private.id .. ' to: ' .. behaviorName)
    return true
end

-- Instance method to setup interactions
function lib.npc:setupInteractions(interactionConfig)
    lib.npc.globalInteractions[self.private.id] = interactionConfig

    -- Create interaction zone
    local coords = GetEntityCoords(self.private.ped)
    lib.zones.box({
        coords = coords,
        size = vector3(2, 2, 2),
        options = {
            {
                name = 'interact_npc_' .. self.private.id,
                label = interactionConfig.label or 'Hablar',
                icon = interactionConfig.icon or 'fa-solid fa-comments',
                onSelect = function()
                    self:startInteraction()
                end
            }
        }
    })
end

-- Instance method to setup schedule
function lib.npc:setupSchedule(schedule)
    lib.npc.globalSchedules[self.private.id] = schedule
    self.schedule = schedule
end

-- Instance method to setup relationships
function lib.npc:setupRelationships(relationshipConfig)
    lib.npc.globalRelationships[self.private.id] = relationshipConfig
    self.relationships = relationshipConfig
end

-- Instance method to start interaction
function lib.npc:startInteraction()
    local interactionConfig = lib.npc.globalInteractions[self.private.id]
    if not interactionConfig then return end

    -- Implementation for starting interaction
    print('[NPC] Starting interaction with NPC ' .. self.private.id)
end

-- Instance method to alert network
function lib.npc:alertNetwork(threat)
    -- Implementation for alerting other NPCs in network
    print('[NPC] Alerting network about threat for NPC ' .. self.private.id)
end

-- Instance method to cleanup
function lib.npc:cleanup()
    if DoesEntityExist(self.private.ped) then
        DeleteEntity(self.private.ped)
    end

    -- Remove from global registries
    lib.npc.activeNPCs[self.private.id] = nil
    lib.npc.globalInteractions[self.private.id] = nil
    lib.npc.globalSchedules[self.private.id] = nil
    lib.npc.globalRelationships[self.private.id] = nil
end

-- Instance method to destroy/remove
function lib.npc:destroy()
    self:cleanup()
    return true
end

-- Instance method to get info
function lib.npc:getInfo()
    return {
        id = self.private.id,
        ped = self.private.ped,
        config = self.private.config,
        aiState = self.aiState,
        currentBehavior = self.currentBehavior,
        alertLevel = self.alertLevel,
        fearLevel = self.fearLevel,
        memory = self.memory,
        customData = self.customData
    }
end

-- Static method to register custom behavior
function lib.npc.registerBehavior(name, behaviorFunc)
    lib.npc.behaviors[name] = behaviorFunc
    print('[NPC] Registered behavior: ' .. name)
    return true
end

-- Define built-in behaviors as static methods
-- Advanced Patrol Behavior
lib.npc.behaviors.patrol = function(npcInstance)
    local ped = npcInstance.private.ped
    local points = npcInstance.private.config.patrolPoints or {}

    if #points < 2 then return end

    local targetPoint = points[npcInstance.patrolIndex or 1]
    local coords = GetEntityCoords(ped)
    local distance = #(coords - vector3(targetPoint.x, targetPoint.y, targetPoint.z))

    if distance > 2.0 then
        -- Move to patrol point
        npcInstance.aiState = lib.npc.AI_STATES.PATROLLING

        -- Use different movement types based on NPC type
        if npcInstance.private.config.movementStyle == 'cautious' then
            TaskGoStraightToCoord(ped, targetPoint.x, targetPoint.y, targetPoint.z, 0.5, -1, targetPoint.heading or 0.0, 0.0)
        elseif npcInstance.private.config.movementStyle == 'urgent' then
            TaskGoToCoordAnyMeans(ped, targetPoint.x, targetPoint.y, targetPoint.z, 2.0, 0, 0, 786603, 0xbf800000)
        else
            TaskGoToCoordAnyMeans(ped, targetPoint.x, targetPoint.y, targetPoint.z, 1.0, 0, 0, 786603, 0xbf800000)
        end
    else
        -- Reached patrol point
        npcInstance.aiState = lib.npc.AI_STATES.IDLE
        npcInstance.patrolIndex = (npcInstance.patrolIndex or 1) % #points + 1

        -- Wait and look around
        local waitTime = npcInstance.private.config.patrolWait or math.random(5000, 15000)
        TaskStandStill(ped, waitTime)

        -- Random look around behavior
        if math.random() < 0.3 then
            local lookDirection = math.random(0, 360)
            TaskTurnPedToFaceCoord(ped, coords.x + math.cos(math.rad(lookDirection)), coords.y + math.sin(math.rad(lookDirection)), coords.z, waitTime)
        end
    end
end

-- Enhanced Guard Behavior with Alertness Levels
lib.npc.behaviors.guard = function(npcInstance)
    local ped = npcInstance.private.ped
    local guardZone = npcInstance.private.config.guardZone
    local alertLevel = npcInstance.alertLevel or 0

    if not guardZone then return end

    -- Scan for threats
    local threats = npcInstance:detectThreats()

    if #threats > 0 then
        local primaryThreat = threats[1]
        npcInstance:handleThreat(primaryThreat)
    else
        -- No threats - reduce alert level over time
        if alertLevel > 0 then
            npcInstance.alertLevel = math.max(0, alertLevel - 0.1)

            if npcInstance.alertLevel <= 0 then
                npcInstance.aiState = lib.npc.AI_STATES.IDLE
                ClearPedTasks(ped)
            end
        end

        -- Resume normal guard duties
        if npcInstance.aiState ~= lib.npc.AI_STATES.ALERT then
            npcInstance:performGuardDuties()
        end
    end
end

-- Intelligent Civilian Behavior
lib.npc.behaviors.civilian = function(npcInstance)
    local ped = npcInstance.private.ped
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
            npcInstance:showFearReaction()
        elseif distance < 3.0 and not npcInstance.hasInteracted then
            -- Friendly interaction
            npcInstance:friendlyInteraction()
        end
    elseif distance > 15.0 then
        -- Reset interaction states when player is far
        npcInstance.hasInteracted = false
        npcInstance.fearLevel = 0
        npcInstance.aiState = lib.npc.AI_STATES.IDLE
    end

    -- Ambient civilian activities
    if npcInstance.aiState == lib.npc.AI_STATES.IDLE then
        npcInstance:performCivilianActivities()
    end
end

-- Advanced Worker Behavior with Task Management
lib.npc.behaviors.worker = function(npcInstance)
    local ped = npcInstance.private.ped
    local workLocation = npcInstance.private.config.workLocation
    local workTasks = npcInstance.private.config.workTasks or { 'WORLD_HUMAN_CLIPBOARD' }

    if not workLocation then return end

    local coords = GetEntityCoords(ped)
    local distance = #(coords - workLocation)

    if distance > 3.0 then
        -- Go to work location
        TaskGoToCoordAnyMeans(ped, workLocation.x, workLocation.y, workLocation.z, 1.0, 0, 0, 786603, 0xbf800000)
        npcInstance.aiState = 'traveling_to_work'
    else
        -- At work location - perform work tasks
        npcInstance.aiState = lib.npc.AI_STATES.WORKING

        if not IsPedActiveInScenario(ped) then
            local currentTask = workTasks[npcInstance.currentTaskIndex or 1]
            TaskStartScenarioInPlace(ped, currentTask, 0, true)

            -- Change task periodically
            SetTimeout(math.random(30000, 60000), function()
                if DoesEntityExist(ped) and npcInstance.aiState == lib.npc.AI_STATES.WORKING then
                    ClearPedTasks(ped)
                    npcInstance.currentTaskIndex = (npcInstance.currentTaskIndex or 1) % #workTasks + 1
                end
            end)
        end
    end
end

-- Vendor/Shopkeeper Behavior
lib.npc.behaviors.vendor = function(npcInstance)
    local ped = npcInstance.private.ped
    local shopArea = npcInstance.private.config.shopArea

    if not shopArea then return end

    -- Look for customers
    local customers = npcInstance:findNearbyPlayers(5.0)

    if #customers > 0 then
        local primaryCustomer = GetPlayerPed(customers[1])
        TaskTurnPedToFaceEntity(ped, primaryCustomer, -1)

        if not npcInstance.hasGreetedCustomer then
            -- Greet customer
            TaskPlayAnim(ped, 'gestures@m@standing@casual', 'gesture_hello', 8.0, -8.0, 2000, 48, 0, false, false, false)
            npcInstance.hasGreetedCustomer = true
            npcInstance.customerTimeout = GetGameTimer() + 30000
        end
    else
        -- No customers - reset state
        if GetGameTimer() > (npcInstance.customerTimeout or 0) then
            npcInstance.hasGreetedCustomer = false
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

-- Static methods for managing NPCs
function lib.npc.getById(npcId)
    return lib.npc.activeNPCs[npcId]
end

function lib.npc.getAll()
    return lib.npc.activeNPCs
end

function lib.npc.getAllByBehavior(behaviorName)
    local result = {}
    for npcId, npcInstance in pairs(lib.npc.activeNPCs) do
        if npcInstance.currentBehavior == behaviorName then
            result[npcId] = npcInstance
        end
    end
    return result
end

function lib.npc.cleanup(npcId)
    local npcInstance = lib.npc.activeNPCs[npcId]
    if npcInstance then
        npcInstance:cleanup()
    end
end

function lib.npc.remove(npcId)
    lib.npc.cleanup(npcId)
    return true
end

-- Global update loop for all active NPCs
CreateThread(function()
    while next(lib.npc.activeNPCs) do
        for npcId, npcInstance in pairs(lib.npc.activeNPCs) do
            if DoesEntityExist(npcInstance.private.ped) then
                npcInstance:updateAI()
                npcInstance:updateSchedule()
                npcInstance:updateRelationships()
            else
                lib.npc.cleanup(npcId)
            end
        end
        Wait(2000) -- Update every 2 seconds for performance
    end
end)

return lib.npc
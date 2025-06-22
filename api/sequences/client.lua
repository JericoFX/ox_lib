---@meta

---@enum SequencePriority
local SequencePriority = {
    LOW = 1,
    NORMAL = 2,
    HIGH = 3,
    CRITICAL = 4
}

---@enum SequenceState
local SequenceState = {
    BUILDING = "building",
    READY = "ready",
    RUNNING = "running",
    COMPLETED = "completed",
    FAILED = "failed",
    CANCELLED = "cancelled"
}

---@class SequenceCallbacks
---@field onStart? fun(sequenceId: number, ped: number): nil
---@field onTaskComplete? fun(sequenceId: number, ped: number, taskIndex: number): nil
---@field onComplete? fun(sequenceId: number, ped: number): nil
---@field onFail? fun(sequenceId: number, ped: number, reason: string): nil
---@field onCancel? fun(sequenceId: number, ped: number): nil

---@class TaskStep
---@field type string Task type identifier
---@field params table Task parameters
---@field waitForCompletion? boolean Wait for this task to complete (default: true)
---@field timeout? number Task timeout in milliseconds
---@field condition? fun(ped: number): boolean Condition to execute this task

---@class SequenceConfig
---@field ped number Target ped entity
---@field name? string Sequence name for identification
---@field priority? SequencePriority Sequence priority level
---@field timeout? number Total sequence timeout in milliseconds
---@field loop? boolean Whether to loop the sequence
---@field interruptible? boolean Can be interrupted by other sequences
---@field callbacks? SequenceCallbacks Event callbacks
---@field tasks TaskStep[] Array of tasks to execute

---@class ActiveSequence
---@field id number Sequence ID
---@field config SequenceConfig Sequence configuration
---@field handle number Task sequence handle from OpenSequenceTask
---@field state SequenceState Current state
---@field startTime integer Start timestamp
---@field currentTask number Current task index
---@field ped number Target ped

---Task Sequence API - Client Only
---Advanced task sequence system for creating complex NPC behaviors
local sequences = {}
local activeSequences = {}
local nextSequenceId = 1

---Generate unique sequence ID
---@return number sequenceId
local function generateSequenceId()
    local id = nextSequenceId
    nextSequenceId = nextSequenceId + 1
    return id
end

---Validate sequence configuration
---@param config SequenceConfig
---@return boolean valid, string? error
local function validateSequenceConfig(config)
    if not config.ped or not DoesEntityExist(config.ped) then
        return false, "Invalid ped entity"
    end

    if not config.tasks or #config.tasks == 0 then
        return false, "Sequence must have at least one task"
    end

    if not IsPedAPlayer(config.ped) and GetEntityType(config.ped) ~= 1 then
        return false, "Target must be a ped entity"
    end

    return true
end

---Add synchronized scene task to sequence builder  
---@param sequenceHandle number Task sequence handle
---@param task TaskStep Task configuration
---@return boolean success
local function addSyncSceneTaskToSequence(sequenceHandle, task)
    if task.type == "sync_scene" then
        -- This will be handled differently since sync scenes need special coordination
        return true
    end
    return false
end

---Create a network synchronized scene with multiple entities
---@param config table Scene configuration
---@return number? sceneId Network scene ID or nil if failed
function lib.createSyncScene(config)
    local coords = config.coords or vector3(0.0, 0.0, 0.0)
    local rotation = config.rotation or vector3(0.0, 0.0, 0.0)
    local animDict = config.animDict
    local duration = config.duration or -1
    
    -- Create network synchronized scene
    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, 1.0, 0.0, 1.0)
    
    if scene == 0 then
        lib.print.error("Failed to create synchronized scene")
        return nil
    end
    
    -- Request animation dictionary
    if animDict and not lib.requestAnimDict(animDict) then
        lib.print.error("Failed to load animation dictionary: " .. animDict)
        return nil
    end
    
    -- Add entities to scene
    if config.entities then
        for _, entity in ipairs(config.entities) do
            if entity.type == "ped" then
                NetworkAddPedToSynchronisedScene(entity.entity, scene, animDict, entity.anim, 
                    entity.blendIn or 8.0, entity.blendOut or 8.0, duration, entity.flags or 0)
            elseif entity.type == "vehicle" then
                NetworkAddEntityToSynchronisedScene(entity.entity, scene, animDict, entity.anim, 
                    entity.blendIn or 8.0, entity.blendOut or 8.0, entity.flags or 0)
            elseif entity.type == "object" then
                NetworkAddEntityToSynchronisedScene(entity.entity, scene, animDict, entity.anim, 
                    entity.blendIn or 8.0, entity.blendOut or 8.0, entity.flags or 0)
            end
        end
    end
    
    return scene
end

---Play a synchronized scene and wait for completion
---@param sceneId number Network scene ID
---@param waitForPhase? number Phase to wait for (0.0-1.0, default: 0.8)
---@param callbacks? table Scene callbacks
function lib.playSyncScene(sceneId, waitForPhase, callbacks)
    if not sceneId or sceneId == 0 then
        lib.print.error("Invalid scene ID")
        return
    end
    
    waitForPhase = waitForPhase or 0.8
    callbacks = callbacks or {}
    
    if callbacks.onStart then
        callbacks.onStart(sceneId)
    end
    
    -- Start the scene
    NetworkStartSynchronisedScene(sceneId)
    
    CreateThread(function()
        Wait(0) -- Needed for proper scene initialization
        
        local localScene = NetworkGetLocalSceneFromNetworkId(sceneId)
        if localScene == 0 then
            lib.print.error("Failed to get local scene from network ID")
            return
        end
        
        -- Wait for scene completion
        while GetSynchronizedScenePhase(localScene) < waitForPhase do
            Wait(0)
        end
        
        if callbacks.onPhaseReached then
            callbacks.onPhaseReached(sceneId, waitForPhase)
        end
        
        -- Wait a bit more for full completion
        while GetSynchronizedScenePhase(localScene) < 1.0 do
            Wait(0)
        end
        
        -- Stop and cleanup scene
        NetworkStopSynchronisedScene(sceneId)
        
        if callbacks.onComplete then
            callbacks.onComplete(sceneId)
        end
    end)
end

---Calculate precise position for animation
---@param animDict string Animation dictionary
---@param animName string Animation name  
---@param entityCoords vector3 Entity coordinates
---@param entityRotation vector3 Entity rotation
---@return vector3 position Calculated position
function lib.getAnimPosition(animDict, animName, entityCoords, entityRotation)
    if not lib.requestAnimDict(animDict) then
        lib.print.error("Failed to load animation dictionary: " .. animDict)
        return entityCoords
    end
    
    return GetAnimInitialOffsetPosition(animDict, animName, entityCoords.x, entityCoords.y, entityCoords.z, entityRotation.x, entityRotation.y, entityRotation.z)
end

---Advanced Fleeca-style truck sequence
---@param driver number Driver ped
---@param guards table Array of guard peds  
---@param vehicle number Vehicle entity
---@param destinationCoords vector3 Destination coordinates
function lib.createFleecaSequence(driver, guards, vehicle, destinationCoords)
    local truckCoords = GetEntityCoords(vehicle)
    local truckRotation = GetEntityRotation(vehicle, 2)
    
    -- Step 1: Driver enters vehicle
    lib.quickSequence(driver, {
        {
            type = "enter_vehicle",
            params = { vehicle = vehicle, seat = -1, timeout = 10000 }
        }
    }, {
        onComplete = function()
            -- Step 2: Guards position themselves
            lib.positionGuardsForEntry(guards, vehicle)
        end
    })
end

---Position guards for vehicle entry using precise animation positioning
---@param guards table Array of guard peds
---@param vehicle number Vehicle entity  
function lib.positionGuardsForEntry(guards, vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleRotation = GetEntityRotation(vehicle, 2)
    
    for i, guard in ipairs(guards) do
        -- Calculate precise position using animation
        local targetPos = lib.getAnimPosition("random@security_van", "sec_case_into_van_calm", vehicleCoords, vehicleRotation)
        
        lib.quickSequence(guard, {
            {
                type = "goto_coord",
                params = { 
                    coords = targetPos,
                    speed = 1.0,
                    stoppingRange = 0.5
                }
            },
            {
                type = "turn_to_face_entity",
                params = { target = vehicle, duration = 1000 }
            }
        }, {
            onComplete = function()
                if i == #guards then -- Last guard positioned
                    lib.executeVehicleEntryScene(guards, vehicle)
                end
            end
        })
    end
end

---Execute synchronized vehicle entry scene
---@param guards table Array of guard peds
---@param vehicle number Vehicle entity
function lib.executeVehicleEntryScene(guards, vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleRotation = GetEntityRotation(vehicle, 2)
    
    -- Create synchronized scene
    local sceneConfig = {
        coords = vehicleCoords,
        rotation = vehicleRotation,
        animDict = "random@security_van",
        duration = 1000,
        entities = {
            {
                entity = vehicle,
                type = "vehicle", 
                anim = "van_case_into_van_panic",
                blendIn = 8.0,
                blendOut = 8.0
            }
        }
    }
    
    -- Add guards to scene
    for i, guard in ipairs(guards) do
        table.insert(sceneConfig.entities, {
            entity = guard,
            type = "ped",
            anim = "sec_case_into_van_panic", 
            blendIn = 8.0,
            blendOut = 8.0
        })
    end
    
    local scene = lib.createSyncScene(sceneConfig)
    
    if scene then
        lib.playSyncScene(scene, 0.8, {
            onStart = function()
                print("🎬 Vehicle entry scene started")
            end,
            onPhaseReached = function()
                print("🎯 Scene phase reached, closing doors")
                SetVehicleDoorShut(vehicle, 2, true)
                SetVehicleDoorShut(vehicle, 3, true)
            end,
            onComplete = function()
                print("✅ Vehicle entry scene completed")
                -- Guards enter vehicle properly
                for i, guard in ipairs(guards) do
                    lib.quickSequence(guard, {
                        {
                            type = "enter_vehicle",
                            params = { vehicle = vehicle, seat = i-1, timeout = 5000 }
                        }
                    })
                end
            end
        })
    end
end

---Add task to sequence builder
---@param sequenceHandle number Task sequence handle
---@param task TaskStep Task configuration
---@return boolean success
local function addTaskToSequence(sequenceHandle, task)
    local success = false

    if task.type == "goto_coord" then
        local coords = task.params.coords
        local speed = task.params.speed or 1.0
        local timeout = task.params.timeout or -1
        local stoppingRange = task.params.stoppingRange or 0.5
        TaskGoStraightToCoord(0, coords.x, coords.y, coords.z, speed, timeout, task.params.heading or 0.0, stoppingRange)
        success = true

    elseif task.type == "goto_entity" then
        local target = task.params.target
        local distance = task.params.distance or 1.0
        local speed = task.params.speed or 1.0
        TaskGoToEntity(0, target, -1, distance, speed, 1073741824.0, 0)
        success = true

    elseif task.type == "play_anim" then
        local dict = task.params.dict
        local anim = task.params.anim
        if lib.requestAnimDict(dict) then
            TaskPlayAnim(0, dict, anim, 
                task.params.blendIn or 8.0,
                task.params.blendOut or -8.0,
                task.params.duration or -1,
                task.params.flags or 0,
                task.params.playbackRate or 0.0,
                false, false, false)
            success = true
        end

    elseif task.type == "scenario" then
        local scenarioName = task.params.name
        local duration = task.params.duration or -1
        TaskStartScenarioInPlace(0, scenarioName, duration, true)
        success = true

    elseif task.type == "scenario_at_position" then
        local coords = task.params.coords
        local heading = task.params.heading or 0.0
        local duration = task.params.duration or -1
        TaskStartScenarioAtPosition(0, task.params.name, coords.x, coords.y, coords.z, heading, duration, false, true)
        success = true

    elseif task.type == "enter_vehicle" then
        local vehicle = task.params.vehicle
        local seat = task.params.seat or -1
        local timeout = task.params.timeout or -1
        TaskEnterVehicle(0, vehicle, timeout, seat, 1.0, 1, 0)
        success = true

    elseif task.type == "drive_to_coord" then
        local vehicle = task.params.vehicle
        local coords = task.params.coords
        local speed = task.params.speed or 20.0
        TaskVehicleDriveToCoord(0, vehicle, coords.x, coords.y, coords.z, speed, 0, GetEntityModel(vehicle), task.params.drivingStyle or 786603, 2.0, 0.0)
        success = true

    elseif task.type == "hands_up" then
        local duration = task.params.duration or -1
        TaskHandsUp(0, duration, 0, -1, false)
        success = true

    elseif task.type == "look_at_entity" then
        local target = task.params.target
        local duration = task.params.duration or -1
        TaskLookAtEntity(0, target, duration, 0, 2)
        success = true

    elseif task.type == "turn_to_face_entity" then
        local target = task.params.target
        local duration = task.params.duration or -1
        TaskTurnPedToFaceEntity(0, target, duration)
        success = true

    elseif task.type == "follow_ped" then
        local target = task.params.target
        local distance = task.params.distance or 2.0
        local speed = task.params.speed or 1.0
        TaskFollowNavMeshToPed(0, target, speed, -1, distance, 0, 0.0)
        success = true

    elseif task.type == "wait" then
        local duration = task.params.duration or 1000
        TaskPause(0, duration)
        success = true

    elseif task.type == "clear_tasks" then
        ClearPedTasks(0)
        success = true

    elseif task.type == "custom" then
        if task.params.func and type(task.params.func) == "function" then
            task.params.func()
            success = true
        end
    end

    return success
end

---Create a new task sequence
---@param config SequenceConfig Sequence configuration
---@return number? sequenceId Sequence ID or nil if failed
function lib.createSequence(config)
    local valid, error = validateSequenceConfig(config)
    if not valid then
        lib.print.error("Failed to create sequence: " .. (error or "Unknown error"))
        return nil
    end

    local sequenceId = generateSequenceId()
    local sequenceHandle = OpenSequenceTask()

    if sequenceHandle == 0 then
        lib.print.error("Failed to open task sequence")
        return nil
    end

    for i, task in ipairs(config.tasks) do
        if task.condition and not task.condition(config.ped) then
            goto continue
        end

        if not addTaskToSequence(sequenceHandle, task) then
            lib.print.warn(("Failed to add task %d to sequence %d"):format(i, sequenceId))
        end

        ::continue::
    end

    CloseSequenceTask(sequenceHandle)

    local activeSequence = {
        id = sequenceId,
        config = config,
        handle = sequenceHandle,
        state = SequenceState.READY,
        startTime = 0,
        currentTask = 1,
        ped = config.ped
    }

    activeSequences[sequenceId] = activeSequence
    sequences[sequenceId] = activeSequence

    return sequenceId
end

---Execute a task sequence
---@param sequenceId number Sequence ID
---@return boolean success True if sequence started successfully
function lib.executeSequence(sequenceId)
    local sequence = activeSequences[sequenceId]
    if not sequence then
        lib.print.error("Sequence not found: " .. sequenceId)
        return false
    end

    if sequence.state ~= SequenceState.READY then
        lib.print.warn("Sequence not ready for execution: " .. sequenceId)
        return false
    end

    if not DoesEntityExist(sequence.ped) then
        lib.print.error("Ped no longer exists for sequence: " .. sequenceId)
        return false
    end

    TaskPerformSequence(sequence.ped, sequence.handle)
    
    sequence.state = SequenceState.RUNNING
    sequence.startTime = GetGameTimer()

    if sequence.config.callbacks and sequence.config.callbacks.onStart then
        sequence.config.callbacks.onStart(sequenceId, sequence.ped)
    end

    CreateThread(function()
        lib._monitorSequence(sequenceId)
    end)

    return true
end

---Monitor sequence execution
---@param sequenceId number Sequence ID
function lib._monitorSequence(sequenceId)
    local sequence = activeSequences[sequenceId]
    if not sequence then return end

    local config = sequence.config
    local startTime = sequence.startTime
    local timeout = config.timeout or 60000

    while sequence.state == SequenceState.RUNNING do
        if not DoesEntityExist(sequence.ped) then
            sequence.state = SequenceState.FAILED
            break
        end

        local currentTime = GetGameTimer()
        if currentTime - startTime > timeout then
            sequence.state = SequenceState.FAILED
            if config.callbacks and config.callbacks.onFail then
                config.callbacks.onFail(sequenceId, sequence.ped, "timeout")
            end
            break
        end

        local scriptTaskStatus = GetScriptTaskStatus(sequence.ped, `SCRIPT_TASK_PERFORM_SEQUENCE`)
        if scriptTaskStatus == 7 then -- TASK_STATUS_FINISHED
            sequence.state = SequenceState.COMPLETED
            if config.callbacks and config.callbacks.onComplete then
                config.callbacks.onComplete(sequenceId, sequence.ped)
            end

            if config.loop then
                TaskPerformSequence(sequence.ped, sequence.handle)
                sequence.startTime = GetGameTimer()
                sequence.state = SequenceState.RUNNING
            end
            break
        end

        Wait(100)
    end

    if not config.loop or sequence.state ~= SequenceState.RUNNING then
        lib.cleanupSequence(sequenceId)
    end
end

---Cancel a running sequence
---@param sequenceId number Sequence ID
---@return boolean success True if sequence was cancelled
function lib.cancelSequence(sequenceId)
    local sequence = activeSequences[sequenceId]
    if not sequence then return false end

    if sequence.state == SequenceState.RUNNING then
        ClearPedTasks(sequence.ped)
        sequence.state = SequenceState.CANCELLED

        if sequence.config.callbacks and sequence.config.callbacks.onCancel then
            sequence.config.callbacks.onCancel(sequenceId, sequence.ped)
        end
    end

    lib.cleanupSequence(sequenceId)
    return true
end

---Cleanup sequence resources
---@param sequenceId number Sequence ID
function lib.cleanupSequence(sequenceId)
    local sequence = activeSequences[sequenceId]
    if not sequence then return end

    ClearSequenceTask(sequence.handle)
    activeSequences[sequenceId] = nil
end

---Get sequence status
---@param sequenceId number Sequence ID
---@return SequenceState? state Current sequence state or nil if not found
function lib.getSequenceState(sequenceId)
    local sequence = activeSequences[sequenceId]
    return sequence and sequence.state or nil
end

---Check if sequence is running
---@param sequenceId number Sequence ID
---@return boolean running True if sequence is currently running
function lib.isSequenceRunning(sequenceId)
    local sequence = activeSequences[sequenceId]
    return sequence and sequence.state == SequenceState.RUNNING or false
end

---Get all active sequences
---@return table<number, ActiveSequence> activeSequences
function lib.getAllActiveSequences()
    return activeSequences
end

---Get active sequences for a specific ped
---@param ped number Ped entity
---@return table<number, ActiveSequence> pedSequences
function lib.getPedSequences(ped)
    local pedSequences = {}
    for id, sequence in pairs(activeSequences) do
        if sequence.ped == ped then
            pedSequences[id] = sequence
        end
    end
    return pedSequences
end

---Cancel all sequences for a specific ped
---@param ped number Ped entity
---@return number cancelledCount Number of sequences cancelled
function lib.cancelPedSequences(ped)
    local cancelledCount = 0
    for id, sequence in pairs(activeSequences) do
        if sequence.ped == ped then
            lib.cancelSequence(id)
            cancelledCount = cancelledCount + 1
        end
    end
    return cancelledCount
end

---Quick sequence creation and execution
---@param ped number Target ped
---@param tasks TaskStep[] Array of tasks
---@param callbacks? SequenceCallbacks Event callbacks
---@return number? sequenceId Sequence ID or nil if failed
function lib.quickSequence(ped, tasks, callbacks)
    local config = {
        ped = ped,
        tasks = tasks,
        callbacks = callbacks
    }

    local sequenceId = lib.createSequence(config)
    if sequenceId then
        lib.executeSequence(sequenceId)
    end

    return sequenceId
end

---Create a pre-built patrol sequence
---@param ped number Target ped
---@param waypoints vector3[] Array of patrol waypoints
---@param options? table Additional options (speed, waitTime, scenarios)
---@return number? sequenceId Sequence ID or nil if failed
function lib.createPatrolSequence(ped, waypoints, options)
    if not waypoints or #waypoints < 2 then
        lib.print.error("Patrol sequence requires at least 2 waypoints")
        return nil
    end

    options = options or {}
    local speed = options.speed or 1.0
    local waitTime = options.waitTime or 5000
    local scenarios = options.scenarios or {}

    local tasks = {}

    for i, waypoint in ipairs(waypoints) do
        table.insert(tasks, {
            type = "goto_coord",
            params = {
                coords = waypoint,
                speed = speed,
                stoppingRange = 1.0
            }
        })

        local scenario = scenarios[i] or "WORLD_HUMAN_GUARD_STAND"
        table.insert(tasks, {
            type = "scenario",
            params = {
                name = scenario,
                duration = waitTime
            }
        })
    end

    local config = {
        ped = ped,
        name = options.name or "patrol_sequence",
        tasks = tasks,
        loop = options.loop ~= false,
        callbacks = options.callbacks
    }

    local sequenceId = lib.createSequence(config)
    if sequenceId and options.autoStart ~= false then
        lib.executeSequence(sequenceId)
    end

    return sequenceId
end

---Create a conversation sequence between two peds
---@param ped1 number First ped
---@param ped2 number Second ped
---@param animations? table Animation configurations
---@param duration? number Conversation duration in milliseconds
---@return number? sequenceId1, number? sequenceId2
function lib.createConversationSequence(ped1, ped2, animations, duration)
    animations = animations or {}
    duration = duration or 10000

    local ped1Tasks = {
        {
            type = "turn_to_face_entity",
            params = { target = ped2, duration = 2000 }
        },
        {
            type = "play_anim",
            params = {
                dict = animations.ped1_dict or "gestures@m@standing@casual",
                anim = animations.ped1_anim or "gesture_hello",
                duration = duration,
                flags = 0
            }
        }
    }

    local ped2Tasks = {
        {
            type = "turn_to_face_entity",
            params = { target = ped1, duration = 2000 }
        },
        {
            type = "wait",
            params = { duration = 1000 }
        },
        {
            type = "play_anim",
            params = {
                dict = animations.ped2_dict or "gestures@m@standing@casual",
                anim = animations.ped2_anim or "gesture_point",
                duration = duration,
                flags = 0
            }
        }
    }

    local sequence1 = lib.quickSequence(ped1, ped1Tasks)
    local sequence2 = lib.quickSequence(ped2, ped2Tasks)

    return sequence1, sequence2
end

---Cleanup all sequences on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for sequenceId in pairs(activeSequences) do
        lib.cleanupSequence(sequenceId)
    end

    activeSequences = {}
    sequences = {}
end)

return lib 
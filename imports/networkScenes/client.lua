---@enum SceneMode
local SceneMode = {
    ONESHOT = "oneshot",
    SEQUENCE = "sequence",
    LOOPED = "looped",
    INTERACTIVE = "interactive"
}

---@enum SceneState
local SceneState = {
    PREPARING = "preparing",
    RUNNING = "running",
    PAUSED = "paused",
    COMPLETED = "completed",
    STOPPED = "stopped"
}

---@enum EntityType
local EntityType = {
    PED = "ped",
    VEHICLE = "vehicle",
    OBJECT = "object",
    CAMERA = "camera"
}

---@enum BlendMode
local BlendMode = {
    INSTANT = "instant",
    SMOOTH = "smooth",
    CUSTOM = "custom"
}

---@class SceneCallbacks
---@field onStart? fun(sceneId: number): nil
---@field onPhaseChange? fun(sceneId: number, phase: number): nil
---@field onComplete? fun(sceneId: number): nil
---@field onStop? fun(sceneId: number, reason: string): nil
---@field onEntityAdded? fun(sceneId: number, entity: number, entityType: EntityType): nil
---@field onCameraActivated? fun(sceneId: number, camera: number): nil

---@class EntityConfig
---@field entity number
---@field type EntityType
---@field animDict string
---@field animName string
---@field blendIn? number
---@field blendOut? number
---@field duration? integer
---@field flags? number
---@field playbackRate? number
---@field startPhase? number
---@field endPhase? number

---@class CameraConfig
---@field animDict string
---@field animName string
---@field renderImmediate? boolean
---@field gracefulExit? boolean
---@field exitBlendTime? number

---@class SceneConfig
---@field position vector3
---@field rotation? vector3
---@field rotationOrder? integer
---@field holdLastFrame? boolean
---@field looped? boolean
---@field phaseToStart? number
---@field phaseToStop? number
---@field animSpeed? number
---@field entities EntityConfig[]
---@field camera? CameraConfig
---@field callbacks? SceneCallbacks
---@field mode? SceneMode
---@field authority? number
---@field syncToAll? boolean

---@class SequenceStep
---@field config SceneConfig
---@field waitForCompletion? boolean
---@field delay? number
---@field condition? fun(): boolean

---@class ActiveScene
---@field id number
---@field networkId number
---@field localId number
---@field config SceneConfig
---@field state SceneState
---@field startTime integer
---@field camera? number
---@field entities table<number, EntityConfig>
---@field phaseMonitor? integer

---@class SceneSequence
---@field id number
---@field steps SequenceStep[]
---@field currentStep integer
---@field callbacks? SceneCallbacks
---@field state SceneState

local activeScenes = {}
local sceneSequences = {}
local presetScenes = {}
local nextSceneId = 1

---@return integer
local function generateSceneId()
    local id = nextSceneId
    nextSceneId = nextSceneId + 1
    return id
end

---@param config SceneConfig
---@return boolean
local function validateSceneConfig(config)
    if not config.position then
        error("Scene position is required")
        return false
    end

    if not config.entities or #config.entities == 0 then
        error("Scene must have at least one entity")
        return false
    end

    for i, entity in ipairs(config.entities) do
        if not DoesEntityExist(entity.entity) then
            error(("Entity %d does not exist"):format(entity.entity))
            return false
        end

        if not entity.animDict or not entity.animName then
            error(("Entity %d missing animation data"):format(entity.entity))
            return false
        end
    end

    return true
end

---@param config SceneConfig
local function requestSceneAssets(config)
    local dictsToLoad = {}

    for _, entity in ipairs(config.entities) do
        if not dictsToLoad[entity.animDict] then
            dictsToLoad[entity.animDict] = true
            lib.requestAnimDict(entity.animDict)
        end
    end

    if config.camera and config.camera.animDict then
        if not dictsToLoad[config.camera.animDict] then
            lib.requestAnimDict(config.camera.animDict)
        end
    end
end

---@param sceneId number
---@param phase number
local function monitorScenePhase(sceneId, phase)
    local scene = activeScenes[sceneId]
    if not scene then return end

    if scene.config.callbacks and scene.config.callbacks.onPhaseChange then
        scene.config.callbacks.onPhaseChange(sceneId, phase)
    end

    if phase >= 0.99 and not scene.config.looped then
        lib.completeScene(sceneId)
    end
end

---@param sceneId number
local function startPhaseMonitoring(sceneId)
    local scene = activeScenes[sceneId]
    if not scene then return end

    local function checkPhase()
        if not activeScenes[sceneId] then return end

        local phase = GetSynchronizedScenePhase(scene.localId)
        monitorScenePhase(sceneId, phase)

        if activeScenes[sceneId] and activeScenes[sceneId].state == SceneState.RUNNING then
            scene.phaseMonitor = SetTimeout(50, checkPhase)
        end
    end

    scene.phaseMonitor = SetTimeout(100, checkPhase)
end

---@param config SceneConfig
---@return integer sceneId
function lib.createScene(config)
    if not validateSceneConfig(config) then
        error("Invalid scene configuration")
    end

    local sceneId = generateSceneId()
    requestSceneAssets(config)

    local rotation = config.rotation or vec3(0.0, 0.0, 0.0)
    local networkId = NetworkCreateSynchronisedScene(
        config.position.x, config.position.y, config.position.z,
        rotation.x, rotation.y, rotation.z,
        config.rotationOrder or 2,
        config.holdLastFrame or false,
        config.looped or false,
        config.phaseToStop or 1.0,
        config.phaseToStart or 0.0,
        config.animSpeed or 1.0
    )

    activeScenes[sceneId] = {
        id = sceneId,
        networkId = networkId,
        localId = -1,
        config = config,
        state = SceneState.PREPARING,
        startTime = GetGameTimer(),
        entities = {},
        camera = nil
    }

    for _, entityConfig in ipairs(config.entities) do
        lib.addEntityToScene(sceneId, entityConfig)
    end

    if config.camera then
        lib.addCameraToScene(sceneId, config.camera)
    end

    return sceneId
end

---@param sceneId number
---@param entityConfig EntityConfig
function lib.addEntityToScene(sceneId, entityConfig)
    local scene = activeScenes[sceneId]
    if not scene then
        error(("Scene %d not found"):format(sceneId))
        return
    end

    if scene.state ~= SceneState.PREPARING then
        error(("Cannot add entity to scene %d - scene is %s"):format(sceneId, scene.state))
        return
    end

    if entityConfig.type == EntityType.PED then
        NetworkAddPedToSynchronisedScene(
            entityConfig.entity,
            scene.networkId,
            entityConfig.animDict,
            entityConfig.animName,
            entityConfig.blendIn or 8.0,
            entityConfig.blendOut or 8.0,
            entityConfig.duration or 0,
            entityConfig.flags or 0,
            entityConfig.playbackRate or 1000.0,
            0
        )
    else
        NetworkAddEntityToSynchronisedScene(
            entityConfig.entity,
            scene.networkId,
            entityConfig.animDict,
            entityConfig.animName,
            entityConfig.blendIn or 8.0,
            entityConfig.blendOut or 8.0,
            entityConfig.flags or 0
        )
    end

    scene.entities[entityConfig.entity] = entityConfig

    if scene.config.callbacks and scene.config.callbacks.onEntityAdded then
        scene.config.callbacks.onEntityAdded(sceneId, entityConfig.entity, entityConfig.type)
    end
end

---@param sceneId number
---@param cameraConfig CameraConfig
function lib.addCameraToScene(sceneId, cameraConfig)
    local scene = activeScenes[sceneId]
    if not scene then
        error(("Scene %d not found"):format(sceneId))
        return
    end

    if cameraConfig.renderImmediate then
        NetworkAddSynchronisedSceneCamera(scene.networkId, cameraConfig.animDict, cameraConfig.animName)
    else
        local camera = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
        local pos = scene.config.position
        local rot = scene.config.rotation or vec3(0.0, 0.0, 0.0)

        PlayCamAnim(
            camera,
            cameraConfig.animName,
            cameraConfig.animDict,
            pos.x, pos.y, pos.z,
            rot.x, rot.y, rot.z,
            scene.config.looped and 1 or 0,
            2
        )

        scene.camera = camera
    end

    if scene.config.callbacks and scene.config.callbacks.onCameraActivated then
        scene.config.callbacks.onCameraActivated(sceneId, scene.camera or -1)
    end
end

---@param sceneId number
function lib.startScene(sceneId)
    local scene = activeScenes[sceneId]
    if not scene then
        error(("Scene %d not found"):format(sceneId))
        return
    end

    if scene.state ~= SceneState.PREPARING then
        error(("Cannot start scene %d - scene is %s"):format(sceneId, scene.state))
        return
    end

    scene.state = SceneState.RUNNING
    NetworkStartSynchronisedScene(scene.networkId)

    if scene.camera and not scene.config.camera.renderImmediate then
        RenderScriptCams(true, false, 0, true, false)
    end

    SetTimeout(0, function()
        scene.localId = NetworkGetLocalSceneFromNetworkId(scene.networkId)
        while scene.localId == -1 and activeScenes[sceneId] do
            Wait(0)
            scene.localId = NetworkGetLocalSceneFromNetworkId(scene.networkId)
        end

        if activeScenes[sceneId] then
            startPhaseMonitoring(sceneId)
        end
    end)

    if scene.config.callbacks and scene.config.callbacks.onStart then
        scene.config.callbacks.onStart(sceneId)
    end
end

---@param sceneId number
function lib.pauseScene(sceneId)
    local scene = activeScenes[sceneId]
    if not scene then return end

    if scene.localId ~= -1 then
        SetSynchronizedSceneRate(scene.localId, 0.0)
    end

    scene.state = SceneState.PAUSED
end

---@param sceneId number
---@param rate? number
function lib.resumeScene(sceneId, rate)
    local scene = activeScenes[sceneId]
    if not scene then return end

    if scene.localId ~= -1 then
        SetSynchronizedSceneRate(scene.localId, rate or scene.config.animSpeed or 1.0)
    end

    scene.state = SceneState.RUNNING
end

---@param sceneId number
function lib.completeScene(sceneId)
    local scene = activeScenes[sceneId]
    if not scene then return end

    scene.state = SceneState.COMPLETED

    if scene.phaseMonitor then
        ClearTimeout(scene.phaseMonitor)
    end

    if scene.config.callbacks and scene.config.callbacks.onComplete then
        scene.config.callbacks.onComplete(sceneId)
    end

    if not scene.config.holdLastFrame then
        lib.stopScene(sceneId)
    end
end

---@param sceneId number
---@param reason? string
function lib.stopScene(sceneId, reason)
    local scene = activeScenes[sceneId]
    if not scene then return end

    if scene.phaseMonitor then
        ClearTimeout(scene.phaseMonitor)
    end

    NetworkStopSynchronisedScene(scene.networkId)

    if scene.camera then
        if scene.config.camera and scene.config.camera.gracefulExit then
            StopRenderingScriptCamsUsingCatchUp(
                false,
                scene.config.camera.exitBlendTime or 4.0,
                3
            )
        else
            RenderScriptCams(false, false, 0, true, false)
        end
        DestroyCam(scene.camera, false)
    end

    scene.state = SceneState.STOPPED

    if scene.config.callbacks and scene.config.callbacks.onStop then
        scene.config.callbacks.onStop(sceneId, reason or "manual")
    end

    activeScenes[sceneId] = nil
end

---@param config SceneConfig
---@return integer sceneId
function lib.playScene(config)
    local sceneId = lib.createScene(config)
    lib.startScene(sceneId)
    return sceneId
end

---@param steps SequenceStep[]
---@param callbacks? SceneCallbacks
---@return integer sequenceId
function lib.playSceneSequence(steps, callbacks)
    local sequenceId = generateSceneId()

    sceneSequences[sequenceId] = {
        id = sequenceId,
        steps = steps,
        currentStep = 1,
        callbacks = callbacks,
        state = SceneState.PREPARING
    }

    local function playNextStep()
        local sequence = sceneSequences[sequenceId]
        if not sequence or sequence.currentStep > #sequence.steps then
            if sequence and sequence.callbacks and sequence.callbacks.onComplete then
                sequence.callbacks.onComplete(sequenceId)
            end
            sceneSequences[sequenceId] = nil
            return
        end

        local step = sequence.steps[sequence.currentStep]

        if step.condition and not step.condition() then
            sequence.currentStep = sequence.currentStep + 1
            playNextStep()
            return
        end

        if step.delay then
            SetTimeout(step.delay, function()
                playNextStep()
            end)
            return
        end

        local originalCallback = step.config.callbacks and step.config.callbacks.onComplete
        step.config.callbacks = step.config.callbacks or {}
        step.config.callbacks.onComplete = function(sceneId)
            if originalCallback then originalCallback(sceneId) end

            if step.waitForCompletion ~= false then
                sequence.currentStep = sequence.currentStep + 1
                playNextStep()
            end
        end

        lib.playScene(step.config)

        if step.waitForCompletion == false then
            sequence.currentStep = sequence.currentStep + 1
            playNextStep()
        end
    end

    if callbacks and callbacks.onStart then
        callbacks.onStart(sequenceId)
    end

    playNextStep()
    return sequenceId
end

---@param sceneId number
---@return number phase
function lib.getScenePhase(sceneId)
    local scene = activeScenes[sceneId]
    if not scene or scene.localId == -1 then return 0.0 end

    return GetSynchronizedScenePhase(scene.localId)
end

---@param sceneId number
---@return SceneState state
function lib.getSceneState(sceneId)
    local scene = activeScenes[sceneId]
    if not scene then return SceneState.STOPPED end

    return scene.state
end

---@param sceneId number
---@return boolean running
function lib.isSceneRunning(sceneId)
    local scene = activeScenes[sceneId]
    if not scene or scene.localId == -1 then return false end

    return IsSynchronizedSceneRunning(scene.localId)
end

---@param sceneId number
---@param rate number
function lib.setSceneRate(sceneId, rate)
    local scene = activeScenes[sceneId]
    if not scene or scene.localId == -1 then return end

    SetSynchronizedSceneRate(scene.localId, rate)
end

---@param name string
---@param config SceneConfig
function lib.registerScenePreset(name, config)
    presetScenes[name] = config
end

---@param name string
---@return SceneConfig?
function lib.getScenePreset(name)
    return presetScenes[name]
end

---@param preset string|SceneConfig
---@param overrides? table
---@return integer sceneId
function lib.playScenePreset(preset, overrides)
    local config

    if type(preset) == "string" then
        config = presetScenes[preset]
        if not config then
            error(("Scene preset '%s' not found"):format(preset))
        end
    else
        config = preset
    end

    if overrides then
        local function merge(target, source)
            for k, v in pairs(source) do
                if type(v) == "table" and type(target[k]) == "table" then
                    merge(target[k], v)
                else
                    target[k] = v
                end
            end
        end
        merge(config, overrides)
    end

    return lib.playScene(config)
end

---@return table<integer, ActiveScene>
function lib.getAllActiveScenes()
    return activeScenes
end

presetScenes = {
    hacking_keypad = {
        mode = SceneMode.SEQUENCE,
        position = vec3(0.0, 0.0, 0.0),
        entities = {},
        camera = {
            animDict = "anim_heist@hs3f@ig1_hack_keypad@male@",
            animName = "action_camera",
            gracefulExit = true,
            exitBlendTime = 2.0
        }
    },
    drilling = {
        mode = SceneMode.INTERACTIVE,
        position = vec3(0.0, 0.0, 0.0),
        holdLastFrame = true,
        entities = {}
    },
    gold_grabbing = {
        mode = SceneMode.SEQUENCE,
        position = vec3(0.0, 0.0, 0.0),
        entities = {}
    }
}

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for sceneId in pairs(activeScenes) do
        lib.stopScene(sceneId, "resource_stop")
    end

    sceneSequences = {}
end)

-- Lazy loader function that auto-loads all NetworkScene functions to lib namespace
return function()
    -- Load all functions into lib namespace when first called
    lib.createScene = lib.createScene
    lib.playScene = lib.playScene
    lib.startScene = lib.startScene
    lib.pauseScene = lib.pauseScene
    lib.resumeScene = lib.resumeScene
    lib.stopScene = lib.stopScene
    lib.completeScene = lib.completeScene
    lib.addEntityToScene = lib.addEntityToScene
    lib.addCameraToScene = lib.addCameraToScene
    lib.playSceneSequence = lib.playSceneSequence
    lib.getScenePhase = lib.getScenePhase
    lib.getSceneState = lib.getSceneState
    lib.isSceneRunning = lib.isSceneRunning
    lib.setSceneRate = lib.setSceneRate
    lib.registerScenePreset = lib.registerScenePreset
    lib.getScenePreset = lib.getScenePreset
    lib.playScenePreset = lib.playScenePreset
    lib.getAllActiveScenes = lib.getAllActiveScenes

    -- Return the main function
    return lib.playScene
end

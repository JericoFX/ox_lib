---@enum AnimPriority
local AnimPriority = {
    LOW = 1,
    NORMAL = 2,
    HIGH = 3,
    CRITICAL = 4
}

---@enum AnimContext
local AnimContext = {
    NORMAL = "normal",
    WATER = "water",
    VEHICLE = "vehicle",
    COMBAT = "combat",
    SOCIAL = "social"
}

---@enum InterruptReason
local InterruptReason = {
    USER = "user",
    DAMAGE = "damage",
    MOVEMENT = "movement",
    TIMEOUT = "timeout",
    PRIORITY = "priority"
}

---@class AnimCallbacks
---@field onStart? fun(ped: number, animId: number): nil
---@field onProgress? fun(ped: number, animId: number, progress: number): nil
---@field onComplete? fun(ped: number, animId: number): nil
---@field onInterrupt? fun(ped: number, animId: number, reason: InterruptReason): nil

---@class PropConfig
---@field model string|number
---@field bone? number
---@field offset? vector3
---@field rotation? vector3
---@field delete? boolean

---@class FacialConfig
---@field dict string
---@field name string
---@field weight? number

---@class AdvancedAnimConfig
---@field dict string
---@field name string
---@field blendIn? number
---@field blendOut? number
---@field duration? integer
---@field flags? number
---@field startPhase? number
---@field phaseControlled? boolean
---@field controlFlags? number
---@field overrideCloneUpdate? boolean
---@field props? PropConfig[]
---@field facial? FacialConfig
---@field callbacks? AnimCallbacks
---@field priority? AnimPriority
---@field interruptible? boolean
---@field context? AnimContext
---@field delay? integer

---@class NetworkAnimConfig : AdvancedAnimConfig
---@field syncToAll? boolean
---@field authority? number
---@field distance? number

---@class SceneConfig
---@field entities table<number, AdvancedAnimConfig>
---@field duration? integer
---@field syncTiming? boolean
---@field callbacks? AnimCallbacks

---@class AnimSequenceOptions
---@field loop? boolean
---@field callbacks? AnimCallbacks
---@field interruptOnMovement? boolean

---@class NetworkSyncOptions
---@field syncToAll? boolean
---@field authority? number
---@field distance? number

---@class ActiveAnimation
---@field ped number
---@field config AdvancedAnimConfig
---@field props table[]
---@field startTime integer
---@field id number

local animationCache = {}
local activeAnimations = {}
local presetAnimations = {}

---@return integer
local function generateAnimId()
    return math.random(100000, 999999)
end

---@param props table[]?
local function cleanupProps(props)
    if not props then return end
    for i = 1, #props do
        if props[i].entity and DoesEntityExist(props[i].entity) then
            if props[i].delete ~= false then
                DeleteEntity(props[i].entity)
            end
        end
    end
end

---@param ped number
---@param propConfig PropConfig
---@return number
local function createProp(ped, propConfig)
    local model = type(propConfig.model) == 'string' and GetHashKey(propConfig.model) or propConfig.model
    lib.requestModel(model)

    local prop = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
    SetEntityCollision(prop, false, false)

    if propConfig.bone then
        AttachEntityToEntity(
            prop, ped, GetPedBoneIndex(ped, propConfig.bone),
            propConfig.offset and propConfig.offset.x or 0.0,
            propConfig.offset and propConfig.offset.y or 0.0,
            propConfig.offset and propConfig.offset.z or 0.0,
            propConfig.rotation and propConfig.rotation.x or 0.0,
            propConfig.rotation and propConfig.rotation.y or 0.0,
            propConfig.rotation and propConfig.rotation.z or 0.0,
            true, true, false, true, 1, true
        )
    end

    SetModelAsNoLongerNeeded(model)
    return prop
end

---@param ped number
---@param facialConfig FacialConfig
local function playFacialAnim(ped, facialConfig)
    if not facialConfig then return end
    lib.requestAnimDict(facialConfig.dict)
    SetFacialIdleAnimOverride(ped, facialConfig.name, 0)
end

---@param ped number
local function stopFacialAnim(ped)
    ClearFacialIdleAnimOverride(ped)
end

presetAnimations = {
    drinking = {
        dict = "mp_player_intdrink",
        name = "loop_bottle",
        flags = 49,
        props = { {
            model = `prop_beer_bottle`,
            bone = 18905,
            offset = vec3(0.12, 0.028, 0.001),
            rotation = vec3(5.0, 5.0, -180.5)
        } }
    },
    phone_call = {
        dict = "cellphone@",
        name = "cellphone_call_listen_base",
        flags = 49,
        props = { {
            model = `prop_phone_mobile_01`,
            bone = 28422,
            offset = vec3(0.0, 0.0, 0.0),
            rotation = vec3(0.0, 0.0, 0.0)
        } }
    },
    mechanic_work = {
        dict = "mini@repair",
        name = "fixing_a_ped",
        flags = 1
    },
    smoking = {
        dict = "mp_player_int_uppersmoke",
        name = "mp_player_int_smoke",
        flags = 49,
        props = { {
            model = `prop_cigarette_01`,
            bone = 47419,
            offset = vec3(0.015, -0.009, 0.003),
            rotation = vec3(55.0, 0.0, 110.0)
        } }
    },
    clipboard = {
        dict = "missfam4",
        name = "base",
        flags = 49,
        props = { {
            model = `p_amb_clipboard_01`,
            bone = 18905,
            offset = vec3(0.10, 0.02, 0.08),
            rotation = vec3(-80.0, 0.0, 0.0)
        } }
    },
    coffee = {
        dict = "mp_player_intdrink",
        name = "loop_bottle",
        flags = 49,
        props = { {
            model = `p_amb_coffeecup_01`,
            bone = 18905,
            offset = vec3(0.12, 0.028, 0.001),
            rotation = vec3(5.0, 5.0, -180.5)
        } }
    },
    notepad = {
        dict = "missheistdockssetup1clipboard@base",
        name = "base",
        flags = 49,
        props = { {
            model = `prop_notepad_01`,
            bone = 18905,
            offset = vec3(0.10, 0.02, 0.08),
            rotation = vec3(-80.0, 0.0, 0.0)
        } }
    },
    tablet = {
        dict = "amb@world_human_seat_wall_tablet@female@base",
        name = "base",
        flags = 49,
        props = { {
            model = `prop_cs_tablet`,
            bone = 28422,
            offset = vec3(0.0, 0.0, 0.03),
            rotation = vec3(0.0, 0.0, 0.0)
        } }
    },
    newspaper = {
        dict = "amb@world_human_clipboard@male@base",
        name = "base",
        flags = 49,
        props = { {
            model = `prop_cliff_paper`,
            bone = 18905,
            offset = vec3(0.10, 0.02, 0.08),
            rotation = vec3(-80.0, 0.0, 0.0)
        } }
    }
}

---@param ped number
---@param config AdvancedAnimConfig|string
---@param callbacks? AnimCallbacks
---@return integer animId
function lib.playAnimAdvanced(ped, config, callbacks)
    if type(config) == 'string' then
        local presetConfig = presetAnimations[config]
        if not presetConfig then
            error(('Animation preset "%s" not found'):format(config))
        end
        config = presetConfig
    end

    local animId = generateAnimId()
    local props = {}

    lib.requestAnimDict(config.dict)

    if config.props then
        for i = 1, #config.props do
            props[i] = {
                entity = createProp(ped, config.props[i]),
                delete = config.props[i].delete
            }
        end
    end

    if config.facial then
        playFacialAnim(ped, config.facial)
    end

    activeAnimations[animId] = {
        ped = ped,
        config = config,
        props = props,
        startTime = GetGameTimer(),
        id = animId
    }

    if config.callbacks and config.callbacks.onStart then
        config.callbacks.onStart(ped, animId)
    end
    if callbacks and callbacks.onStart then
        callbacks.onStart(ped, animId)
    end

    TaskPlayAnim(
        ped, config.dict, config.name,
        config.blendIn or 8.0,
        config.blendOut or -8.0,
        config.duration or -1,
        config.flags or 0,
        config.startPhase or 0.0,
        config.phaseControlled or false,
        config.controlFlags or 0,
        config.overrideCloneUpdate or false
    )

    if config.duration and config.duration > 0 then
        SetTimeout(config.duration, function()
            lib.stopAnim(animId)
        end)
    end

    RemoveAnimDict(config.dict)
    return animId
end

---@param entities table<number, NetworkAnimConfig>
---@param options? NetworkSyncOptions
function lib.playNetworkAnim(entities, options)
    options = options or {}

    if options.syncToAll then
        TriggerServerEvent('ox_lib:syncNetworkAnim', entities, options)
    else
        for entity, config in pairs(entities) do
            lib.playAnimAdvanced(entity, config)
        end
    end
end

RegisterNetEvent('ox_lib:playNetworkAnim', function(entities, options)
    for entity, config in pairs(entities) do
        if DoesEntityExist(entity) then
            lib.playAnimAdvanced(entity, config)
        end
    end
end)

---@param sceneConfig SceneConfig
---@return integer sceneId
function lib.playScene(sceneConfig)
    local sceneId = generateAnimId()

    if sceneConfig.callbacks and sceneConfig.callbacks.onStart then
        sceneConfig.callbacks.onStart(sceneId)
    end

    for entity, animConfig in pairs(sceneConfig.entities) do
        if DoesEntityExist(entity) then
            if sceneConfig.syncTiming then
                SetTimeout(animConfig.delay or 0, function()
                    lib.playAnimAdvanced(entity, animConfig)
                end)
            else
                lib.playAnimAdvanced(entity, animConfig)
            end
        end
    end

    if sceneConfig.duration then
        SetTimeout(sceneConfig.duration, function()
            if sceneConfig.callbacks and sceneConfig.callbacks.onComplete then
                sceneConfig.callbacks.onComplete(sceneId)
            end
        end)
    end

    return sceneId
end

---@param ped number
---@param sequence AdvancedAnimConfig[]
---@param options? AnimSequenceOptions
function lib.playAnimSequence(ped, sequence, options)
    options = options or {}
    local currentIndex = 1

    local function playNext()
        if currentIndex > #sequence then
            if options.loop then
                currentIndex = 1
            else
                if options.callbacks and options.callbacks.onComplete then
                    options.callbacks.onComplete(ped)
                end
                return
            end
        end

        local currentAnim = sequence[currentIndex]
        currentIndex = currentIndex + 1

        currentAnim.callbacks = currentAnim.callbacks or {}
        local originalComplete = currentAnim.callbacks.onComplete

        currentAnim.callbacks.onComplete = function(...)
            if originalComplete then originalComplete(...) end
            playNext()
        end

        lib.playAnimAdvanced(ped, currentAnim)
    end

    if options.callbacks and options.callbacks.onStart then
        options.callbacks.onStart(ped)
    end

    playNext()
end

---@param animId number
function lib.stopAnim(animId)
    local anim = activeAnimations[animId]
    if not anim then return end

    ClearPedTasks(anim.ped)

    if anim.config.facial then
        stopFacialAnim(anim.ped)
    end

    cleanupProps(anim.props)

    if anim.config.callbacks and anim.config.callbacks.onComplete then
        anim.config.callbacks.onComplete(anim.ped, animId)
    end

    activeAnimations[animId] = nil
end

---@param ped number
function lib.stopAllAnims(ped)
    for animId, anim in pairs(activeAnimations) do
        if anim.ped == ped then
            lib.stopAnim(animId)
        end
    end
end

---@param ped number
---@return boolean
function lib.isPlayingAnim(ped)
    for _, anim in pairs(activeAnimations) do
        if anim.ped == ped then
            return true
        end
    end
    return false
end

---@param ped number
---@param animType string
---@param context? table
function lib.playContextualAnim(ped, animType, context)
    context = context or {}
    local inWater = IsEntityInWater(ped)

    local contextualAnims = {
        idle = inWater and 'swimming_idle' or 'standing_idle',
        work = context.job == 'mechanic' and 'mechanic_work' or 'generic_work',
        social = context.mood == 'happy' and 'cheerful_wave' or 'neutral_wave'
    }

    local selectedAnim = contextualAnims[animType] or animType
    lib.playAnimAdvanced(ped, selectedAnim)
end

---@param name string
---@param config AdvancedAnimConfig
function lib.registerAnimPreset(name, config)
    presetAnimations[name] = config
end

---@param name string
---@return AdvancedAnimConfig?
function lib.getAnimPreset(name)
    return presetAnimations[name]
end

---@return table<string, AdvancedAnimConfig>
function lib.getAllAnimPresets()
    return presetAnimations
end

---@param ped number
---@param fromConfig AdvancedAnimConfig
---@param toConfig AdvancedAnimConfig
---@param blendTime? number
function lib.blendAnimations(ped, fromConfig, toConfig, blendTime)
    blendTime = blendTime or 1000

    lib.requestAnimDict(toConfig.dict)

    TaskPlayAnim(
        ped, toConfig.dict, toConfig.name,
        toConfig.blendIn or 8.0,
        toConfig.blendOut or -8.0,
        blendTime,
        toConfig.flags or 0,
        toConfig.startPhase or 0.0,
        toConfig.phaseControlled or false,
        toConfig.controlFlags or 0,
        toConfig.overrideCloneUpdate or false
    )

    RemoveAnimDict(toConfig.dict)
end

---@param ped number
---@return number progress
function lib.getAnimProgress(ped)
    return GetEntityAnimCurrentTime(ped, lib.cache.animDict or "", lib.cache.animName or "")
end

---@param animId number
---@return ActiveAnimation?
function lib.getActiveAnimation(animId)
    return activeAnimations[animId]
end

---@return table<integer, ActiveAnimation>
function lib.getAllActiveAnimations()
    return activeAnimations
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for animId in pairs(activeAnimations) do
        lib.stopAnim(animId)
    end
end)

-- Lazy loader function that auto-loads all advanced animation functions to lib namespace
return function()
    -- Load all functions into lib namespace when first called
    lib.playAnimAdvanced = lib.playAnimAdvanced
    lib.playNetworkAnim = lib.playNetworkAnim
    lib.playScene = lib.playScene
    lib.playAnimSequence = lib.playAnimSequence
    lib.playContextualAnim = lib.playContextualAnim
    lib.registerAnimPreset = lib.registerAnimPreset
    lib.getAnimPreset = lib.getAnimPreset
    lib.getAllAnimPresets = lib.getAllAnimPresets
    lib.blendAnimations = lib.blendAnimations
    lib.getAnimProgress = lib.getAnimProgress
    lib.getActiveAnimation = lib.getActiveAnimation
    lib.getAllActiveAnimations = lib.getAllActiveAnimations
    lib.stopAnim = lib.stopAnim
    lib.stopAllAnims = lib.stopAllAnims
    lib.isPlayingAnim = lib.isPlayingAnim

    -- Return the main function
    return lib.playAnimAdvanced
end

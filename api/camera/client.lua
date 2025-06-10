---@meta

---@class CameraOptions
---@field fov? number Field of view (default: 50.0)
---@field near? number Near clip (default: 0.1)
---@field far? number Far clip (default: 10000.0)
---@field shake? string Shake type from enums
---@field shakeAmplitude? number Shake amplitude (0.0-1.0)

---@class CameraTransition
---@field duration number Transition duration in milliseconds
---@field easing? string Easing type from enums
---@field callback? function Callback when transition completes

---@class CinematicSplineNode
---@field coords vector3 Position of the node
---@field rotation vector3 Rotation at this node (optional)
---@field fov number Field of view at this node (optional)
---@field duration number Time to reach this node from previous (milliseconds)
---@field easing? string Easing type for this segment

---@class CinematicSequence
---@field name string Unique name for the sequence
---@field nodes CinematicSplineNode[] Array of spline nodes
---@field loop boolean Whether to loop the sequence
---@field onComplete? function Callback when sequence completes
---@field effects? table Visual effects to apply during sequence

---@class lib.camera
---@field private activeCameras table
---@field private currentCamera table|nil
---@field private isTransitioning boolean
---@field private freeCamActive boolean
---@field private freeCamHandle number|nil
---@field private cinematicSequences table
---@field private activeSequence table|nil
---@field private splineCameras table
local Camera = lib.class('Camera')

-- Static properties
Camera.activeCameras = {}

---Camera API Class - Client Only
---Advanced camera system with freecam, scripted cameras, smooth transitions and cinematic sequences
---@param options? table Camera system options
function Camera:constructor(options)
    options = options or {}

    self.private.activeCameras = {}
    self.private.currentCamera = nil
    self.private.isTransitioning = false
    self.private.freeCamActive = false
    self.private.freeCamHandle = nil
    self.private.cameraIdCounter = 0

    -- Cinematic system properties
    self.private.cinematicSequences = {}
    self.private.activeSequence = nil
    self.private.splineCameras = {}
    self.private.cinematicEffects = {
        motionBlur = false,
        depthOfField = false,
        timecycleModifier = nil
    }
end

-- =====================================
-- CORE CAMERA FUNCTIONS
-- =====================================

---Create a new camera
---@param coords vector3 Camera position
---@param rotation? vector3 Camera rotation (pitch, roll, yaw)
---@param options? CameraOptions Camera options
---@return number cameraId Unique camera ID
function Camera:create(coords, rotation, options)
    options = options or {}
    rotation = rotation or vector3(0, 0, 0)

    local fov = options.fov or 50.0
    local camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
        coords.x, coords.y, coords.z,
        rotation.x, rotation.y, rotation.z,
        fov, false, 0)

    self.private.cameraIdCounter = self.private.cameraIdCounter + 1
    local cameraId = self.private.cameraIdCounter

    self.private.activeCameras[cameraId] = {
        id = cameraId,
        handle = camera,
        coords = coords,
        rotation = rotation,
        options = options,
        active = false,
        instance = self
    }

    return cameraId
end

---Create a spline camera for cinematic sequences
---@param name string Unique name for the spline camera
---@return number splineId Spline camera ID
function Camera:createSplineCamera(name)
    local splineCamera = CreateCam("DEFAULT_SPLINE_CAMERA", true)

    local splineId = #self.private.splineCameras + 1
    self.private.splineCameras[splineId] = {
        id = splineId,
        name = name,
        handle = splineCamera,
        nodes = {},
        active = false
    }

    return splineId
end

---Activate a camera
---@param cameraId number Camera ID to activate
---@param transition? CameraTransition Transition options
function Camera:activate(cameraId, transition)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    if transition and transition.duration > 0 then
        self.private.isTransitioning = true

        if self.private.currentCamera then
            SetCamActiveWithInterp(camera.handle, self.private.currentCamera.handle, transition.duration, 1, 1)
        else
            RenderScriptCams(true, true, transition.duration, true, false)
            SetCamActive(camera.handle, true)
        end

        CreateThread(function()
            Wait(transition.duration)
            self.private.isTransitioning = false
            if transition.callback then
                transition.callback()
            end
        end)
    else
        RenderScriptCams(true, false, 0, true, false)
        SetCamActive(camera.handle, true)
    end

    if self.private.currentCamera and self.private.currentCamera ~= camera then
        SetCamActive(self.private.currentCamera.handle, false)
        self.private.currentCamera.active = false
    end

    self.private.currentCamera = camera
    camera.active = true
end

---Deactivate current camera and return to gameplay
---@param transition? CameraTransition Transition options
function Camera:deactivate(transition)
    if not self.private.currentCamera then return end

    if transition and transition.duration > 0 then
        self.private.isTransitioning = true
        RenderScriptCams(false, true, transition.duration, true, false)

        CreateThread(function()
            Wait(transition.duration)
            self.private.isTransitioning = false
            if transition.callback then
                transition.callback()
            end
        end)
    else
        RenderScriptCams(false, false, 0, true, false)
    end

    SetCamActive(self.private.currentCamera.handle, false)
    self.private.currentCamera.active = false
    self.private.currentCamera = nil
end

-- =====================================
-- CINEMATIC SYSTEM FUNCTIONS
-- =====================================

---Create a cinematic sequence with spline-based camera movement
---@param sequence CinematicSequence Sequence configuration
---@return boolean success Whether the sequence was created successfully
function Camera:createCinematicSequence(sequence)
    if not sequence.name or not sequence.nodes or #sequence.nodes < 2 then
        return false
    end

    local splineId = self:createSplineCamera(sequence.name)
    local splineCamera = self.private.splineCameras[splineId]

    -- Add nodes to the spline camera
    for i, node in ipairs(sequence.nodes) do
        AddCamSplineNode(splineCamera.handle,
            node.coords.x, node.coords.y, node.coords.z,
            node.rotation and node.rotation.x or 0.0,
            node.rotation and node.rotation.y or 0.0,
            node.rotation and node.rotation.z or 0.0,
            node.fov or 50.0,
            node.duration or 3000,
            i - 1) -- Node index starts at 0
    end

    -- Configure spline properties
    SetCamSplineDuration(splineCamera.handle, sequence.totalDuration or 10000)
    SetCamSplineSmoothingStyle(splineCamera.handle, 1) -- Smooth interpolation

    self.private.cinematicSequences[sequence.name] = {
        sequence = sequence,
        splineId = splineId,
        splineCamera = splineCamera
    }

    return true
end

---Play a cinematic sequence
---@param sequenceName string Name of the sequence to play
---@param options? table Playback options
function Camera:playCinematicSequence(sequenceName, options)
    local cinematicSeq = self.private.cinematicSequences[sequenceName]
    if not cinematicSeq then return false end

    options = options or {}
    local splineCamera = cinematicSeq.splineCamera
    local sequence = cinematicSeq.sequence

    -- Apply visual effects if specified
    if sequence.effects then
        self:_applyCinematicEffects(sequence.effects)
    end

    -- Activate the spline camera
    SetCamActive(splineCamera.handle, true)
    RenderScriptCams(true, true, options.fadeTime or 1000, true, false)

    -- Start spline playback
    SetCamSplinePhase(splineCamera.handle, 0.0)

    self.private.activeSequence = {
        name = sequenceName,
        startTime = GetGameTimer(),
        sequence = sequence,
        splineCamera = splineCamera
    }

    -- Create monitoring thread
    CreateThread(function()
        self:_monitorCinematicSequence()
    end)

    return true
end

---Stop the currently playing cinematic sequence
function Camera:stopCinematicSequence()
    if not self.private.activeSequence then return end

    local splineCamera = self.private.activeSequence.splineCamera
    SetCamActive(splineCamera.handle, false)
    RenderScriptCams(false, true, 1000, true, false)

    -- Remove visual effects
    self:_removeCinematicEffects()

    self.private.activeSequence = nil
end

---Private method to monitor cinematic sequence progress
function Camera:_monitorCinematicSequence()
    if not self.private.activeSequence then return end

    local sequence = self.private.activeSequence.sequence
    local splineCamera = self.private.activeSequence.splineCamera
    local startTime = self.private.activeSequence.startTime
    local duration = sequence.totalDuration or 10000

    while self.private.activeSequence do
        local currentTime = GetGameTimer()
        local elapsed = currentTime - startTime
        local progress = math.min(elapsed / duration, 1.0)

        -- Update spline phase
        SetCamSplinePhase(splineCamera.handle, progress)

        -- Check if sequence is complete
        if progress >= 1.0 then
            if sequence.loop then
                -- Restart sequence
                SetCamSplinePhase(splineCamera.handle, 0.0)
                self.private.activeSequence.startTime = GetGameTimer()
            else
                -- Sequence complete
                self:stopCinematicSequence()
                if sequence.onComplete then
                    sequence.onComplete()
                end
                break
            end
        end

        Wait(16) -- ~60 FPS
    end
end

---Apply cinematic visual effects
---@param effects table Effects configuration
function Camera:_applyCinematicEffects(effects)
    if effects.motionBlur then
        SetCamMotionBlurStrength(self.private.currentCamera and self.private.currentCamera.handle or 0, effects.motionBlur)
    end

    if effects.depthOfField then
        SetCamUseShallowDofMode(self.private.currentCamera and self.private.currentCamera.handle or 0, true)
        SetCamDofStrength(self.private.currentCamera and self.private.currentCamera.handle or 0, effects.depthOfField.strength or 1.0)
        SetCamDofPlanes(self.private.currentCamera and self.private.currentCamera.handle or 0,
            effects.depthOfField.nearPlane or 1.0,
            effects.depthOfField.nearBlur or 2.0,
            effects.depthOfField.farPlane or 8.0,
            effects.depthOfField.farBlur or 10.0)
    end

    if effects.timecycleModifier then
        SetTimecycleModifier(effects.timecycleModifier)
        if effects.timecycleStrength then
            SetTimecycleModifierStrength(effects.timecycleStrength)
        end
    end

    if effects.cinematicMode then
        SetCinematicModeActive(true)
    end

    self.private.cinematicEffects = effects
end

---Remove cinematic visual effects
function Camera:_removeCinematicEffects()
    if self.private.cinematicEffects.motionBlur and self.private.currentCamera then
        SetCamMotionBlurStrength(self.private.currentCamera.handle, 0.0)
    end

    if self.private.cinematicEffects.depthOfField and self.private.currentCamera then
        SetCamUseShallowDofMode(self.private.currentCamera.handle, false)
    end

    if self.private.cinematicEffects.timecycleModifier then
        ClearTimecycleModifier()
    end

    if self.private.cinematicEffects.cinematicMode then
        SetCinematicModeActive(false)
    end

    self.private.cinematicEffects = {
        motionBlur = false,
        depthOfField = false,
        timecycleModifier = nil
    }
end

---Create a cinematic loading screen sequence
---@param duration number Duration in milliseconds
---@param centerPoint vector3 Center point to orbit around
---@param radius number Orbit radius
---@param height number Camera height variation
function Camera:createLoadingScreenSequence(duration, centerPoint, radius, height)
    radius = radius or 50.0
    height = height or 10.0
    duration = duration or 30000

    local nodes = {}
    local nodeCount = 8 -- Number of orbital points

    for i = 1, nodeCount do
        local angle = (i - 1) * (360 / nodeCount)
        local radians = math.rad(angle)

        local coords = vector3(
            centerPoint.x + math.cos(radians) * radius,
            centerPoint.y + math.sin(radians) * radius,
            centerPoint.z + height + math.sin(radians * 2) * 5.0 -- Slight height variation
        )

        local rotation = vector3(
            -10.0 + math.sin(radians) * 5.0, -- Slight pitch variation
            0.0,
            angle + 90                       -- Always look toward center
        )

        table.insert(nodes, {
            coords = coords,
            rotation = rotation,
            fov = 60.0,
            duration = duration / nodeCount
        })
    end

    local sequence = {
        name = "loading_screen",
        nodes = nodes,
        loop = true,
        totalDuration = duration,
        effects = {
            cinematicMode = true,
            timecycleModifier = "cinema",
            motionBlur = 0.3
        }
    }

    return self:createCinematicSequence(sequence)
end

---Create a cinematic reveal sequence (like when entering a new area)
---@param startPos vector3 Starting position (usually player position)
---@param revealTarget vector3 Target to reveal
---@param options? table Additional options
function Camera:createRevealSequence(startPos, revealTarget, options)
    options = options or {}

    local distance = options.distance or 100.0
    local duration = options.duration or 8000
    local height = options.height or 25.0

    -- Calculate camera positions for a dramatic reveal
    local direction = vector3(
        revealTarget.x - startPos.x,
        revealTarget.y - startPos.y,
        0
    )
    local dirLength = math.sqrt(direction.x ^ 2 + direction.y ^ 2)
    direction = vector3(direction.x / dirLength, direction.y / dirLength, 0)

    local nodes = {
        -- Start close and low
        {
            coords = vector3(startPos.x, startPos.y, startPos.z + 5.0),
            rotation = vector3(-10.0, 0.0, 0.0),
            fov = 70.0,
            duration = duration * 0.3
        },
        -- Pull back and up
        {
            coords = vector3(
                startPos.x - direction.x * distance * 0.5,
                startPos.y - direction.y * distance * 0.5,
                startPos.z + height
            ),
            rotation = vector3(-20.0, 0.0, 180.0),
            fov = 50.0,
            duration = duration * 0.4
        },
        -- Final reveal position
        {
            coords = vector3(
                revealTarget.x - direction.x * distance,
                revealTarget.y - direction.y * distance,
                revealTarget.z + height
            ),
            rotation = vector3(-15.0, 0.0, 0.0),
            fov = 40.0,
            duration = duration * 0.3
        }
    }

    local sequence = {
        name = options.name or "reveal_sequence",
        nodes = nodes,
        loop = false,
        totalDuration = duration,
        effects = {
            cinematicMode = true,
            timecycleModifier = options.timecycle or "cinema",
            depthOfField = {
                strength = 0.8,
                nearPlane = 2.0,
                nearBlur = 4.0,
                farPlane = 200.0,
                farBlur = 300.0
            }
        },
        onComplete = options.onComplete
    }

    return self:createCinematicSequence(sequence)
end

-- =====================================
-- CAMERA CONTROL FUNCTIONS
-- =====================================

---Move camera to new position
---@param cameraId number Camera ID
---@param coords vector3 New position
---@param transition? CameraTransition Transition options
function Camera:moveTo(cameraId, coords, transition)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    if transition and transition.duration > 0 then
        local startCoords = camera.coords
        local startTime = GetGameTimer()

        CreateThread(function()
            while GetGameTimer() - startTime < transition.duration do
                local progress = (GetGameTimer() - startTime) / transition.duration
                local currentCoords = vector3(
                    startCoords.x + (coords.x - startCoords.x) * progress,
                    startCoords.y + (coords.y - startCoords.y) * progress,
                    startCoords.z + (coords.z - startCoords.z) * progress
                )
                SetCamCoord(camera.handle, currentCoords.x, currentCoords.y, currentCoords.z)
                Wait(16)
            end
            SetCamCoord(camera.handle, coords.x, coords.y, coords.z)
            camera.coords = coords
            if transition.callback then transition.callback() end
        end)
    else
        SetCamCoord(camera.handle, coords.x, coords.y, coords.z)
        camera.coords = coords
    end
end

---Point camera at target
---@param cameraId number Camera ID
---@param target vector3|number Target coordinates or entity
---@param transition? CameraTransition Transition options
function Camera:pointAt(cameraId, target, transition)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    local targetCoords
    if type(target) == "number" then
        targetCoords = GetEntityCoords(target)
    else
        targetCoords = target
    end

    PointCamAtCoord(camera.handle, targetCoords.x, targetCoords.y, targetCoords.z)
end

---Set camera FOV
---@param cameraId number Camera ID
---@param fov number Field of view
---@param transition? CameraTransition Transition options
function Camera:setFOV(cameraId, fov, transition)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    if transition and transition.duration > 0 then
        local startFOV = GetCamFov(camera.handle)
        local startTime = GetGameTimer()

        CreateThread(function()
            while GetGameTimer() - startTime < transition.duration do
                local progress = (GetGameTimer() - startTime) / transition.duration
                local currentFOV = startFOV + (fov - startFOV) * progress
                SetCamFov(camera.handle, currentFOV)
                Wait(16)
            end
            SetCamFov(camera.handle, fov)
            camera.options.fov = fov
            if transition.callback then transition.callback() end
        end)
    else
        SetCamFov(camera.handle, fov)
        camera.options.fov = fov
    end
end

-- =====================================
-- FREECAM FUNCTIONS
-- =====================================

---Enable freecam mode
---@param startCoords? vector3 Starting position (default: player position)
---@param speed? number Movement speed multiplier (default: 1.0)
function Camera:enableFreeCam(startCoords, speed)
    if self.private.freeCamActive then return end

    self.private.freeCamActive = true
    speed = speed or 1.0

    local ped = PlayerPedId()
    startCoords = startCoords or GetEntityCoords(ped)

    self.private.freeCamHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(self.private.freeCamHandle, startCoords.x, startCoords.y, startCoords.z)
    SetCamActive(self.private.freeCamHandle, true)
    RenderScriptCams(true, true, 1000, true, false)

    self:_startFreeCamThread(speed)
end

---Disable freecam mode
function Camera:disableFreeCam()
    if not self.private.freeCamActive then return end

    self.private.freeCamActive = false

    if self.private.freeCamHandle then
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(self.private.freeCamHandle, false)
        self.private.freeCamHandle = nil
    end
end

---Private method to handle freecam controls
---@param speed number Movement speed multiplier
function Camera:_startFreeCamThread(speed)
    CreateThread(function()
        local currentCoords = GetCamCoord(self.private.freeCamHandle)
        local currentHeading = 0.0
        local currentPitch = 0.0

        while self.private.freeCamActive and self.private.freeCamHandle do
            DisableAllControlActions(0)

            local mouseX = GetDisabledControlNormal(0, 1)
            local mouseY = GetDisabledControlNormal(0, 2)

            currentHeading = currentHeading - mouseX * 5.0
            currentPitch = math.max(-89.0, math.min(89.0, currentPitch - mouseY * 5.0))

            SetCamRot(self.private.freeCamHandle, currentPitch, 0.0, currentHeading, 2)

            local moveSpeed = speed * (IsControlPressed(0, 21) and 2.0 or 1.0)
            local forward = IsControlPressed(0, 32)
            local backward = IsControlPressed(0, 33)
            local left = IsControlPressed(0, 34)
            local right = IsControlPressed(0, 35)
            local up = IsControlPressed(0, 44)
            local down = IsControlPressed(0, 46)

            if forward or backward or left or right or up or down then
                local direction = vector3(0, 0, 0)

                if forward then direction = direction + vector3(0, moveSpeed, 0) end
                if backward then direction = direction + vector3(0, -moveSpeed, 0) end
                if left then direction = direction + vector3(-moveSpeed, 0, 0) end
                if right then direction = direction + vector3(moveSpeed, 0, 0) end
                if up then direction = direction + vector3(0, 0, moveSpeed) end
                if down then direction = direction + vector3(0, 0, -moveSpeed) end

                currentCoords = currentCoords + direction

                SetCamCoord(self.private.freeCamHandle, currentCoords.x, currentCoords.y, currentCoords.z)
            end

            Wait(0)
        end
    end)
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Destroy a camera
---@param cameraId number Camera ID to destroy
function Camera:destroy(cameraId)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    if camera.active then
        self:deactivate()
    end

    DestroyCam(camera.handle, false)
    self.private.activeCameras[cameraId] = nil
end

---Destroy a spline camera
---@param splineId number Spline camera ID to destroy
function Camera:destroySplineCamera(splineId)
    local splineCamera = self.private.splineCameras[splineId]
    if not splineCamera then return end

    if splineCamera.active then
        SetCamActive(splineCamera.handle, false)
    end

    DestroyCam(splineCamera.handle, false)
    self.private.splineCameras[splineId] = nil
end

---Get current camera info
---@return table? camera Current camera data or nil
function Camera:getCurrentCamera()
    return self.private.currentCamera
end

---Check if transitioning
---@return boolean transitioning True if camera is transitioning
function Camera:isTransitioning()
    return self.private.isTransitioning
end

---Check if a cinematic sequence is currently playing
---@return boolean playing True if a sequence is playing
function Camera:isCinematicSequencePlaying()
    return self.private.activeSequence ~= nil
end

---Get the currently playing cinematic sequence name
---@return string? sequenceName Name of the playing sequence or nil
function Camera:getCurrentSequenceName()
    return self.private.activeSequence and self.private.activeSequence.name or nil
end

-- Create default instance
lib.camera = Camera:new()

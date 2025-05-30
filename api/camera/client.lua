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

---@class lib.camera
---@field private activeCameras table
---@field private currentCamera table|nil
---@field private isTransitioning boolean
---@field private freeCamActive boolean
---@field private freeCamHandle number|nil
local Camera = lib.class('Camera')

-- Static properties
Camera.activeCameras = {}

---Camera API Class - Client Only
---Advanced camera system with freecam, scripted cameras, and smooth transitions
---@param options? table Camera system options
function Camera:constructor(options)
    options = options or {}

    -- Initialize private properties
    self.private.activeCameras = {}
    self.private.currentCamera = nil
    self.private.isTransitioning = false
    self.private.freeCamActive = false
    self.private.freeCamHandle = nil
    self.private.cameraIdCounter = 0
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

---Activate a camera
---@param cameraId number Camera ID to activate
---@param transition? CameraTransition Transition options
function Camera:activate(cameraId, transition)
    local camera = self.private.activeCameras[cameraId]
    if not camera then return end

    if transition and transition.duration > 0 then
        self.private.isTransitioning = true

        if self.private.currentCamera then
            -- Smooth transition between cameras
            SetCamActiveWithInterp(camera.handle, self.private.currentCamera.handle, transition.duration, 1, 1)
        else
            -- Transition from gameplay camera
            RenderScriptCams(true, true, transition.duration, true, false)
            SetCamActive(camera.handle, true)
        end

        -- Handle transition completion
        CreateThread(function()
            Wait(transition.duration)
            self.private.isTransitioning = false
            if transition.callback then
                transition.callback()
            end
        end)
    else
        -- Instant activation
        RenderScriptCams(true, false, 0, true, false)
        SetCamActive(camera.handle, true)
    end

    -- Deactivate previous camera
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
        -- Smooth movement
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
        -- Instant movement
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

    -- Smooth or instant pointing
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
        -- Smooth FOV change
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

    -- Create freecam
    self.private.freeCamHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(self.private.freeCamHandle, startCoords.x, startCoords.y, startCoords.z)
    SetCamActive(self.private.freeCamHandle, true)
    RenderScriptCams(true, true, 1000, true, false)

    -- Start freecam control thread
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

            -- Mouse look
            local mouseX = GetDisabledControlNormal(0, 1) -- Mouse X
            local mouseY = GetDisabledControlNormal(0, 2) -- Mouse Y

            currentHeading = currentHeading - mouseX * 5.0
            currentPitch = math.max(-89.0, math.min(89.0, currentPitch - mouseY * 5.0))

            SetCamRot(self.private.freeCamHandle, currentPitch, 0.0, currentHeading, 2)

            -- Movement controls
            local moveSpeed = speed * (IsControlPressed(0, 21) and 2.0 or 1.0) -- Shift for faster
            local forward = IsControlPressed(0, 32)                            -- W
            local backward = IsControlPressed(0, 33)                           -- S
            local left = IsControlPressed(0, 34)                               -- A
            local right = IsControlPressed(0, 35)                              -- D
            local up = IsControlPressed(0, 44)                                 -- Q
            local down = IsControlPressed(0, 46)                               -- E

            if forward or backward or left or right or up or down then
                local direction = vector3(0, 0, 0)

                if forward then direction = direction + vector3(0, moveSpeed, 0) end
                if backward then direction = direction + vector3(0, -moveSpeed, 0) end
                if left then direction = direction + vector3(-moveSpeed, 0, 0) end
                if right then direction = direction + vector3(moveSpeed, 0, 0) end
                if up then direction = direction + vector3(0, 0, moveSpeed) end
                if down then direction = direction + vector3(0, 0, -moveSpeed) end

                -- Apply rotation to movement (simplified for now)
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

-- Create default instance
lib.camera = Camera:new()

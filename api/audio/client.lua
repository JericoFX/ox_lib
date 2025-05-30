---@meta

---@class AudioOptions
---@field volume? number Volume level (0.0-1.0)
---@field pitch? number Pitch modification (-1.0 to 1.0)
---@field range? number 3D audio range in units
---@field fadeIn? number Fade in duration in milliseconds
---@field fadeOut? number Fade out duration in milliseconds
---@field loop? boolean Whether to loop the audio
---@field interior? boolean Whether audio plays only in interior
---@field entity? number Entity to attach audio to

---@class lib.audio
---@field private activeAudioSources table
---@field private audioPool table
---@field private maxPoolSize number
local Audio = lib.class('Audio')

-- Static properties
Audio.activeAudioSources = {}
Audio.audioPool = {}
Audio.maxPoolSize = 32

---Audio API Class - Client Only
---Advanced audio system with pooling, 3D audio, and fade effects
---@param options? table Audio system options
function Audio:constructor(options)
    options = options or {}

    -- Initialize private properties
    self.private.audioId = 0
    self.private.fadingAudio = {}

    -- Start cleanup thread for this instance
    self:_startCleanupThread()
end

-- =====================================
-- CORE AUDIO FUNCTIONS
-- =====================================

---Play a sound effect
---@param soundName string Sound name from enums
---@param soundSet? string Sound set name
---@param options? AudioOptions Audio options
---@return number audioId Unique audio ID for control
function Audio:playSound(soundName, soundSet, options)
    options = options or {}
    soundSet = soundSet or lib.enums.audio.DEFAULT_SOUND_SET

    self.private.audioId = self.private.audioId + 1
    local audioId = self.private.audioId
    local volume = options.volume or 1.0

    -- Play the sound
    PlaySoundFrontend(audioId, soundName, soundSet, true)

    -- Apply volume if specified
    if volume ~= 1.0 then
        SetAudioFrontendVolume(volume)
    end

    -- Store audio source
    Audio.activeAudioSources[audioId] = {
        id = audioId,
        soundName = soundName,
        soundSet = soundSet,
        options = options,
        startTime = GetGameTimer(),
        instance = self
    }

    -- Handle fade in
    if options.fadeIn then
        self:fadeIn(audioId, options.fadeIn)
    end

    return audioId
end

---Play 3D positioned audio
---@param soundName string Sound name from enums
---@param coords vector3 3D coordinates
---@param soundSet? string Sound set name
---@param options? AudioOptions Audio options
---@return number audioId Unique audio ID for control
function Audio:play3D(soundName, coords, soundSet, options)
    options = options or {}
    soundSet = soundSet or lib.enums.audio.DEFAULT_SOUND_SET

    self.private.audioId = self.private.audioId + 1
    local audioId = self.private.audioId
    local range = options.range or 50.0

    -- Play 3D sound
    PlaySoundFromCoord(audioId, soundName, coords.x, coords.y, coords.z, soundSet, false, range, false)

    -- Store audio source
    Audio.activeAudioSources[audioId] = {
        id = audioId,
        soundName = soundName,
        soundSet = soundSet,
        coords = coords,
        options = options,
        startTime = GetGameTimer(),
        is3D = true,
        instance = self
    }

    return audioId
end

---Play audio attached to entity
---@param soundName string Sound name from enums
---@param entity number Entity to attach to
---@param soundSet? string Sound set name
---@param options? AudioOptions Audio options
---@return number audioId Unique audio ID for control
function Audio:playOnEntity(soundName, entity, soundSet, options)
    options = options or {}
    soundSet = soundSet or lib.enums.audio.DEFAULT_SOUND_SET

    self.private.audioId = self.private.audioId + 1
    local audioId = self.private.audioId

    -- Play sound on entity
    PlaySoundFromEntity(audioId, soundName, entity, soundSet, false, false)

    -- Store audio source
    Audio.activeAudioSources[audioId] = {
        id = audioId,
        soundName = soundName,
        soundSet = soundSet,
        entity = entity,
        options = options,
        startTime = GetGameTimer(),
        isEntity = true,
        instance = self
    }

    return audioId
end

-- =====================================
-- AUDIO CONTROL FUNCTIONS
-- =====================================

---Stop specific audio by ID
---@param audioId number Audio ID to stop
---@param fadeOut? number Fade out duration in milliseconds
function Audio:stop(audioId, fadeOut)
    local audioSource = Audio.activeAudioSources[audioId]
    if not audioSource or audioSource.instance ~= self then return end

    if fadeOut then
        self:fadeOut(audioId, fadeOut, function()
            StopSound(audioId)
            Audio.activeAudioSources[audioId] = nil
        end)
    else
        StopSound(audioId)
        Audio.activeAudioSources[audioId] = nil
    end
end

---Stop all active audio for this instance
---@param fadeOut? number Fade out duration in milliseconds
function Audio:stopAll(fadeOut)
    for audioId, audioSource in pairs(Audio.activeAudioSources) do
        if audioSource.instance == self then
            self:stop(audioId, fadeOut)
        end
    end
end

---Set audio volume
---@param audioId number Audio ID
---@param volume number Volume level (0.0-1.0)
function Audio:setVolume(audioId, volume)
    local audioSource = Audio.activeAudioSources[audioId]
    if not audioSource or audioSource.instance ~= self then return end

    SetVariableOnSound(audioId, 'Volume', volume)
    audioSource.options.volume = volume
end

---Fade in audio
---@param audioId number Audio ID
---@param duration number Fade duration in milliseconds
function Audio:fadeIn(audioId, duration)
    local audioSource = Audio.activeAudioSources[audioId]
    if not audioSource or audioSource.instance ~= self then return end

    local startVolume = 0.0
    local targetVolume = audioSource.options.volume or 1.0
    local startTime = GetGameTimer()

    self.private.fadingAudio[audioId] = true

    CreateThread(function()
        while GetGameTimer() - startTime < duration and self.private.fadingAudio[audioId] do
            local progress = (GetGameTimer() - startTime) / duration
            local currentVolume = startVolume + (targetVolume - startVolume) * progress
            self:setVolume(audioId, currentVolume)
            Wait(16) -- ~60fps
        end
        if self.private.fadingAudio[audioId] then
            self:setVolume(audioId, targetVolume)
            self.private.fadingAudio[audioId] = nil
        end
    end)
end

---Fade out audio
---@param audioId number Audio ID
---@param duration number Fade duration in milliseconds
---@param callback? function Callback when fade completes
function Audio:fadeOut(audioId, duration, callback)
    local audioSource = Audio.activeAudioSources[audioId]
    if not audioSource or audioSource.instance ~= self then return end

    local startVolume = audioSource.options.volume or 1.0
    local targetVolume = 0.0
    local startTime = GetGameTimer()

    self.private.fadingAudio[audioId] = true

    CreateThread(function()
        while GetGameTimer() - startTime < duration and self.private.fadingAudio[audioId] do
            local progress = (GetGameTimer() - startTime) / duration
            local currentVolume = startVolume + (targetVolume - startVolume) * progress
            self:setVolume(audioId, currentVolume)
            Wait(16) -- ~60fps
        end
        if self.private.fadingAudio[audioId] then
            self:setVolume(audioId, targetVolume)
            self.private.fadingAudio[audioId] = nil
            if callback then callback() end
        end
    end)
end

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

---Check if audio is playing
---@param audioId number Audio ID to check
---@return boolean playing True if audio is playing
function Audio:isPlaying(audioId)
    local audioSource = Audio.activeAudioSources[audioId]
    if not audioSource or audioSource.instance ~= self then return false end

    return HasSoundFinished(audioId) == false
end

---Get active audio count for this instance
---@return number count Number of active audio sources
function Audio:getActiveCount()
    local count = 0
    for _, audioSource in pairs(Audio.activeAudioSources) do
        if audioSource.instance == self then
            count = count + 1
        end
    end
    return count
end

---Cleanup finished audio sources for this instance
function Audio:cleanup()
    for audioId, audioSource in pairs(Audio.activeAudioSources) do
        if audioSource.instance == self and HasSoundFinished(audioId) then
            Audio.activeAudioSources[audioId] = nil
        end
    end
end

---Private method to start cleanup thread
function Audio:_startCleanupThread()
    CreateThread(function()
        while true do
            Wait(5000) -- Cleanup every 5 seconds
            self:cleanup()
        end
    end)
end

-- Create default instance
lib.audio = Audio:new()

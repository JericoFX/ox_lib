---@meta

--[[
    Streaming Audio API for ox_lib

    Inspired by and compatible with mana_audio by Manason
    Original repository: https://github.com/Manason/mana_audio

    Credits to:
    - Manason (mana_audio creator)
    - PrinceAlbert, Demi-Automatic, ChatDisabled, Joe Szymkowicz, and Zoo

    This implementation provides native audio streaming functionality for custom audio files
    and GTA V native sounds using the game's streaming system.
]]

---@class StreamingAudioOptions
---@field audioBank string Audio bank name (supports custom audio banks for streaming custom sounds)
---@field audioName string|string[] Audio name or array of names for random selection (supports custom audio names)
---@field audioRef string Audio reference (supports custom audio references)
---@field entity? number Entity for PlaySoundFromEntity
---@field coords? vector3 Coordinates for PlaySoundFromCoords
---@field range? number Range for coordinate-based audio (default: 10)

---Server-side streaming audio API for ox_lib
---Provides native audio streaming functionality for custom audio files, similar to mana_audio
---Supports streaming of custom .awc audio files and native GTA V sounds
local streamingAudio = {}

---Play a sound not located within the 3D world to specific client(s)
---@param target number|number[] Client ID(s) or -1 for all clients
---@param options StreamingAudioOptions Audio options
function streamingAudio.playSound(target, options)
    if not options.audioBank or not options.audioName or not options.audioRef then
        return lib.print.error('streamingAudio.playSound: Missing required parameters (audioBank, audioName, audioRef)')
    end

    local audioName = options.audioName
    if type(audioName) == 'table' then
        audioName = audioName[math.random(#audioName)]
    end

    if target == -1 then
        TriggerClientEvent('ox_lib:streamingAudio:playSound', -1, {
            audioBank = options.audioBank,
            audioName = audioName,
            audioRef = options.audioRef
        })
    else
        if type(target) == 'table' then
            for _, playerId in ipairs(target) do
                TriggerClientEvent('ox_lib:streamingAudio:playSound', playerId, {
                    audioBank = options.audioBank,
                    audioName = audioName,
                    audioRef = options.audioRef
                })
            end
        else
            TriggerClientEvent('ox_lib:streamingAudio:playSound', target, {
                audioBank = options.audioBank,
                audioName = audioName,
                audioRef = options.audioRef
            })
        end
    end
end

---Play a sound originating from an entity to all clients
---@param options StreamingAudioOptions Audio options (entity required)
function streamingAudio.playSoundFromEntity(options)
    if not options.audioBank or not options.audioName or not options.audioRef or not options.entity then
        return lib.print.error('streamingAudio.playSoundFromEntity: Missing required parameters (audioBank, audioName, audioRef, entity)')
    end

    local audioName = options.audioName
    if type(audioName) == 'table' then
        audioName = audioName[math.random(#audioName)]
    end

    TriggerClientEvent('ox_lib:streamingAudio:playSoundFromEntity', -1, {
        audioBank = options.audioBank,
        audioName = audioName,
        audioRef = options.audioRef,
        entity = options.entity
    })
end

---Play a sound originating from coordinates to all clients in range
---@param options StreamingAudioOptions Audio options (coords required)
function streamingAudio.playSoundFromCoords(options)
    if not options.audioBank or not options.audioName or not options.audioRef or not options.coords then
        return lib.print.error('streamingAudio.playSoundFromCoords: Missing required parameters (audioBank, audioName, audioRef, coords)')
    end

    local audioName = options.audioName
    if type(audioName) == 'table' then
        audioName = audioName[math.random(#audioName)]
    end

    local range = options.range or 10

    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed and DoesEntityExist(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector3(options.coords.x, options.coords.y, options.coords.z) - playerCoords)

            if distance <= range then
                TriggerClientEvent('ox_lib:streamingAudio:playSoundFromCoords', playerId, {
                    audioBank = options.audioBank,
                    audioName = audioName,
                    audioRef = options.audioRef,
                    coords = options.coords,
                    range = range
                })
            end
        end
    end
end

lib.streamingAudio = streamingAudio

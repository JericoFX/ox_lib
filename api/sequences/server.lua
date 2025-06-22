---@meta

---@class ServerSequenceData
---@field id number Sequence ID
---@field source number Player source
---@field ped number Target ped entity
---@field name? string Sequence name
---@field startTime integer Start timestamp
---@field duration? number Expected duration
---@field state string Current state

---Task Sequence Server API
---Coordinates and monitors task sequences across clients
local serverSequences = {}
local nextSequenceId = 1

---Generate unique server sequence ID
---@return number sequenceId
local function generateServerSequenceId()
    local id = nextSequenceId
    nextSequenceId = nextSequenceId + 1
    return id
end

---Register a sequence start
---@param source number Player source
---@param data table Sequence data
---@return number sequenceId Server sequence ID
function lib.registerSequence(source, data)
    local sequenceId = generateServerSequenceId()
    
    serverSequences[sequenceId] = {
        id = sequenceId,
        source = source,
        ped = data.ped,
        name = data.name,
        startTime = os.time(),
        duration = data.duration,
        state = "running"
    }

    TriggerEvent('ox_lib:sequenceStarted', sequenceId, source, data)
    return sequenceId
end

---Update sequence state
---@param sequenceId number Sequence ID
---@param state string New state
---@param data? table Additional data
function lib.updateSequenceState(sequenceId, state, data)
    local sequence = serverSequences[sequenceId]
    if not sequence then return end

    sequence.state = state
    
    if data then
        for k, v in pairs(data) do
            sequence[k] = v
        end
    end

    TriggerEvent('ox_lib:sequenceStateChanged', sequenceId, state, sequence)
end

---Complete a sequence
---@param sequenceId number Sequence ID
function lib.completeSequence(sequenceId)
    local sequence = serverSequences[sequenceId]
    if not sequence then return end

    sequence.state = "completed"
    TriggerEvent('ox_lib:sequenceCompleted', sequenceId, sequence)
    
    serverSequences[sequenceId] = nil
end

---Cancel a sequence
---@param sequenceId number Sequence ID
---@param reason? string Cancellation reason
function lib.cancelServerSequence(sequenceId, reason)
    local sequence = serverSequences[sequenceId]
    if not sequence then return end

    sequence.state = "cancelled"
    TriggerEvent('ox_lib:sequenceCancelled', sequenceId, reason or "unknown", sequence)
    
    TriggerClientEvent('ox_lib:cancelSequence', sequence.source, sequenceId)
    serverSequences[sequenceId] = nil
end

---Get all active sequences
---@return table<number, ServerSequenceData> activeSequences
function lib.getAllServerSequences()
    return serverSequences
end

---Get sequences by player source
---@param source number Player source
---@return table<number, ServerSequenceData> playerSequences
function lib.getPlayerSequences(source)
    local playerSequences = {}
    for id, sequence in pairs(serverSequences) do
        if sequence.source == source then
            playerSequences[id] = sequence
        end
    end
    return playerSequences
end

---Cleanup sequences for disconnected player
---@param source number Player source
function lib.cleanupPlayerSequences(source)
    for id, sequence in pairs(serverSequences) do
        if sequence.source == source then
            serverSequences[id] = nil
        end
    end
end

---Network events
RegisterNetEvent('ox_lib:sequenceStarted', function(data)
    local source = source
    lib.registerSequence(source, data)
end)

RegisterNetEvent('ox_lib:sequenceCompleted', function(sequenceId)
    lib.completeSequence(sequenceId)
end)

RegisterNetEvent('ox_lib:sequenceStateUpdate', function(sequenceId, state, data)
    lib.updateSequenceState(sequenceId, state, data)
end)

---Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    lib.cleanupPlayerSequences(source)
end)

---Monitor long-running sequences
CreateThread(function()
    while true do
        local currentTime = os.time()
        
        for id, sequence in pairs(serverSequences) do
            if sequence.duration and (currentTime - sequence.startTime) > (sequence.duration / 1000) then
                lib.cancelServerSequence(id, "timeout")
            end
        end
        
        Wait(30000) -- Check every 30 seconds
    end
end)

return lib 
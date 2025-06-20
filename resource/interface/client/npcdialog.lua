--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@type table<number, table<string, NpcDialogStep>>
local npcDialogs = {}

---@type promise?
local npcPromise

---@class NpcDialogOption
---@field label string              -- Text displayed on the button
---@field next? string              -- Next dialog step id. `nil` will close the dialog.
---@field event? string             -- Client event triggered after selection
---@field serverEvent? string       -- Server event triggered after selection
---@field args? any                 -- Args passed to the event(s)

---@class NpcDialogStep
---@field header string             -- Dialog window title (usually the NPC name)
---@field content string            -- Body text (supports markdown)
---@field options NpcDialogOption[] -- List of selectable answers

---Registers a dialog tree for a specific NPC entity.
---@param ped number                        -- Ped or entity handle
---@param dialog table<string, NpcDialogStep> -- Dialog tree keyed by step id
function lib.registerNpcDialog(ped, dialog)
    if not DoesEntityExist(ped) then error('Invalid entity passed to registerNpcDialog') end
    local netId = NetworkGetNetworkIdFromEntity(ped)
    npcDialogs[netId] = dialog
end

---Internal helper to open an NUI window and await the player's answer.
---@param step NpcDialogStep
---@return integer? selectedIndex           -- 1-based index of the selected option or nil if cancelled
local function awaitDialog(step)
    if npcPromise then return end
    npcPromise = promise.new()

    lib.setNuiFocus(false)
    SendNUIMessage({
        action = 'openNpcDialog',
        data = step
    })

    return Citizen.Await(npcPromise)
end

---Starts the dialog with the given NPC.
---@param ped number       -- Ped or entity handle
---@param startId? string  -- Optional starting step id (defaults to "start")
function lib.startNpcDialog(ped, startId)
    if npcPromise then return end

    local netId = NetworkGetNetworkIdFromEntity(ped)
    local dialog = npcDialogs[netId]
    if not dialog then error('No dialog registered for this entity') end

    local stepId = startId or 'start'

    while stepId do
        local step = dialog[stepId]
        if not step then break end

        local choice = awaitDialog(step)
        if not choice then break end

        local option = step.options[choice]
        if not option then break end

        if option.event then TriggerEvent(option.event, option.args) end
        if option.serverEvent then TriggerServerEvent(option.serverEvent, option.args) end

        stepId = option.next
    end
end

---Forcefully close the current dialog window.
function lib.closeNpcDialog()
    if not npcPromise then return end

    lib.resetNuiFocus()
    SendNUIMessage({
        action = 'closeNpcDialog'
    })

    npcPromise:resolve(nil)
    npcPromise = nil
end

RegisterNUICallback('npcDialogSelect', function(index, cb)
    cb(1)

    lib.resetNuiFocus()

    if npcPromise then
        -- Convert 0-based index from JS to 1-based Lua
        if type(index) == 'number' then index = index + 1 end
        npcPromise:resolve(index)
        npcPromise = nil
    end
end)

RegisterNetEvent('ox_lib:startNpcDialog', function(...)
    lib.startNpcDialog(...)
end)

RegisterNetEvent('ox_lib:closeNpcDialog', lib.closeNpcDialog)

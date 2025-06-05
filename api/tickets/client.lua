---@meta
---@JericoFX
--[[
    Player Ticket System Client for ox_lib

    Client-side ticket system providing interfaces for both regular players
    to create reports and staff members to manage and respond to tickets
    with full administrative capabilities.

    Example usage:
    ```lua
    -- Player opens report menu
    lib.tickets.openPlayerReportMenu()

    -- Staff opens management interface
    lib.tickets.openStaffMenu()

    -- Quick report for stuck players
    lib.tickets.quickStuckReport()
    ```
--]]

local tickets = {}
local frozenState = false

---@class PlayerReportOption
---@field value string Category value
---@field label string Display label
---@field description string Category description

---@class TicketStatusText
---@field [string] string Status display text mapping

local statusTexts = {
    open = 'Open',
    assigned = 'Assigned',
    in_progress = 'In Progress',
    resolved = 'Resolved',
    closed = 'Closed'
}

---Opens player report creation menu
function tickets.openPlayerReportMenu()
    local categories = {
        { value = 'player_report', label = '👤 Report Player', description = 'Report inappropriate behavior' },
        { value = 'bug_report', label = '🐛 Report Bug', description = 'Technical server issue' },
        { value = 'help_request', label = '❓ Request Help', description = 'Need staff assistance' },
        { value = 'character_stuck', label = '🚫 Character Stuck', description = 'Cannot move my character' },
        { value = 'item_lost', label = '📦 Lost Item', description = 'Lost item due to bug' },
        { value = 'refund_request', label = '💰 Refund Request', description = 'Request refund for unfair loss' }
    }

    local nearbyPlayers = tickets.getNearbyPlayers(30.0)

    local input = lib.inputDialog('Create Report', {
        { type = 'input',    label = 'Title',                      description = 'Brief summary of the issue',            required = true, max = 80 },
        { type = 'textarea', label = 'Description',                description = 'Detailed explanation of what happened', required = true, max = 400 },
        { type = 'select',   label = 'Report Type',                options = categories,                                  required = true },
        { type = 'select',   label = 'Involved Player (Optional)', options = nearbyPlayers,                               clearable = true }
    })

    if input then
        local targetId = input[4] ~= 0 and input[4] or nil
        TriggerServerEvent('tickets:createPlayerReport', input[1], input[2], input[3], targetId)
    end
end

---Gets nearby players for selection
---@param maxDistance number Maximum distance to search
---@return PlayerReportOption[] nearbyPlayers Array of nearby player options
function tickets.getNearbyPlayers(maxDistance)
    local nearbyPlayers = {}
    local players = GetActivePlayers()
    local myCoords = GetEntityCoords(PlayerPedId())

    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local distance = #(myCoords - coords)

        if distance <= maxDistance and player ~= PlayerId() then
            local serverId = GetPlayerServerId(player)
            local name = GetPlayerName(player)
            table.insert(nearbyPlayers, {
                value = serverId,
                label = string.format('%s (ID: %d) - %.1fm', name, serverId, distance)
            })
        end
    end

    if #nearbyPlayers == 0 then
        table.insert(nearbyPlayers, { value = 0, label = 'No nearby players' })
    end

    return nearbyPlayers
end

---Opens player's own reports menu
function tickets.openMyReports()
    lib.callback('tickets:getPlayerTickets', false, function(myTickets)
        if not myTickets or #myTickets == 0 then
            lib.notify({
                type = 'info',
                description = 'You have no active reports'
            })
            return
        end

        local options = {}

        table.insert(options, {
            title = '➕ Create New Report',
            description = 'Submit a new report to staff',
            icon = 'plus',
            onSelect = function()
                tickets.openPlayerReportMenu()
            end
        })

        for _, ticket in ipairs(myTickets) do
            local statusIcon = tickets.getStatusIcon(ticket.status)
            local timeAgo = tickets.getTimeAgo(ticket.created_at)

            table.insert(options, {
                title = string.format('%s #%d - %s', statusIcon, ticket.id, ticket.title),
                description = string.format('Status: %s | %s ago', statusTexts[ticket.status], timeAgo),
                onSelect = function()
                    tickets.openMyReportDetails(ticket.id)
                end
            })
        end

        lib.registerContext({
            id = 'my_reports',
            title = 'My Reports',
            options = options
        })

        lib.showContext('my_reports')
    end)
end

---Gets status icon for ticket status
---@param status string Ticket status
---@return string icon Status icon
function tickets.getStatusIcon(status)
    local icons = {
        open = '🟡',
        assigned = '🔵',
        in_progress = '🟠',
        resolved = '🟢',
        closed = '⚫'
    }
    return icons[status] or '❓'
end

---Gets time ago text from timestamp
---@param timestamp number Unix timestamp
---@return string timeText Human readable time ago
function tickets.getTimeAgo(timestamp)
    local diff = os.difftime(os.time(), timestamp)

    if diff < 60 then
        return math.floor(diff) .. ' sec'
    elseif diff < 3600 then
        return math.floor(diff / 60) .. ' min'
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. ' hrs'
    else
        return math.floor(diff / 86400) .. ' days'
    end
end

---Opens detailed view of player's own report
---@param ticketId number Ticket ID
function tickets.openMyReportDetails(ticketId)
    lib.callback('tickets:getTicketDetails', false, function(ticket)
        if not ticket then
            lib.notify({ type = 'error', description = 'Report not found' })
            return
        end

        local options = {
            {
                title = '📋 Report Status',
                description = string.format('ID: #%d\nStatus: %s\nCreated: %s',
                    ticket.id,
                    statusTexts[ticket.status],
                    os.date('%d/%m/%Y %H:%M', ticket.created_at)
                ),
                disabled = true
            },
            {
                title = '📝 My Report',
                description = ticket.description,
                disabled = true
            }
        }

        if ticket.assigned_name then
            table.insert(options, {
                title = '👤 Assigned Staff',
                description = ticket.assigned_name,
                disabled = true
            })
        end

        if ticket.messages and #ticket.messages > 0 then
            table.insert(options, {
                title = '💬 View Messages (' .. #ticket.messages .. ')',
                description = 'Staff responses and updates',
                icon = 'comments',
                onSelect = function()
                    tickets.openPlayerMessages(ticketId, ticket.messages)
                end
            })
        end

        if ticket.status == 'in_progress' or ticket.status == 'assigned' then
            table.insert(options, {
                title = '✉️ Send Message',
                description = 'Add additional information',
                icon = 'envelope',
                onSelect = function()
                    tickets.addPlayerMessage(ticketId)
                end
            })
        end

        lib.registerContext({
            id = 'my_report_details',
            title = 'Report #' .. ticketId,
            menu = 'my_reports',
            options = options
        })

        lib.showContext('my_report_details')
    end, ticketId)
end

---Opens messages view for player's report
---@param ticketId number Ticket ID
---@param messages table Array of ticket messages
function tickets.openPlayerMessages(ticketId, messages)
    local options = {}

    for _, message in ipairs(messages) do
        if not message.is_internal then
            local senderIcon = message.is_staff and '👨‍💼' or '👤'
            local timeText = os.date('%d/%m %H:%M', message.timestamp)

            table.insert(options, {
                title = string.format('%s %s - %s', senderIcon, message.sender_name, timeText),
                description = message.message,
                disabled = true
            })
        end
    end

    if #options == 0 then
        table.insert(options, {
            title = 'No messages yet',
            description = 'Waiting for staff response',
            disabled = true
        })
    end

    lib.registerContext({
        id = 'report_messages',
        title = 'Report #' .. ticketId .. ' - Messages',
        menu = 'my_report_details',
        options = options
    })

    lib.showContext('report_messages')
end

---Opens dialog to add message to player's report
---@param ticketId number Ticket ID
function tickets.addPlayerMessage(ticketId)
    local input = lib.inputDialog('Add Message', {
        { type = 'textarea', label = 'Message', description = 'Additional information for staff', required = true, max = 400 }
    })

    if input and input[1] then
        TriggerServerEvent('tickets:addMessage', ticketId, input[1])
        lib.notify({
            type = 'success',
            description = 'Message sent to staff'
        })
    end
end

---Quick report for stuck characters
function tickets.quickStuckReport()
    local alert = lib.alertDialog({
        header = 'Character Stuck',
        content = 'Are you unable to move your character?\n\nThis will create an urgent report for staff assistance.',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Cancel',
            confirm = 'Send Report'
        }
    })

    if alert == 'confirm' then
        TriggerServerEvent('tickets:createPlayerReport',
            'Character Stuck - Auto Report',
            'Player is unable to move and needs immediate assistance',
            'character_stuck',
            nil
        )
    end
end

---Opens staff ticket management menu
function tickets.openStaffMenu()
    lib.callback('tickets:getStaffTickets', false, function(staffTickets)
        if not staffTickets or #staffTickets == 0 then
            lib.notify({
                type = 'info',
                description = 'No active tickets'
            })
            return
        end

        local options = {}

        table.insert(options, {
            title = '➕ Create Staff Ticket',
            description = 'Create an administrative ticket',
            icon = 'plus',
            onSelect = function()
                tickets.openStaffCreateMenu()
            end
        })

        for _, ticket in ipairs(staffTickets) do
            local priorityIcon = tickets.getPriorityIcon(ticket.priority)
            local statusIcon = tickets.getStatusIcon(ticket.status)
            local timeAgo = tickets.getTimeAgo(ticket.created_at)
            local ticketType = ticket.is_player_report == 1 and 'Player' or 'Staff'

            table.insert(options, {
                title = string.format('%s%s #%d - %s', priorityIcon, statusIcon, ticket.id, ticket.title),
                description = string.format('%s Report | By: %s | %s ago', ticketType, ticket.reporter_name, timeAgo),
                onSelect = function()
                    tickets.openStaffTicketDetails(ticket.id)
                end
            })
        end

        lib.registerContext({
            id = 'staff_tickets',
            title = 'Ticket Management - Staff',
            options = options
        })

        lib.showContext('staff_tickets')
    end)
end

---Gets priority icon for ticket priority
---@param priority string Ticket priority
---@return string icon Priority icon
function tickets.getPriorityIcon(priority)
    local icons = {
        low = '🟢',
        medium = '🟡',
        high = '🟠',
        urgent = '🔴'
    }
    return icons[priority] or '⚪'
end

---Opens staff ticket creation menu
function tickets.openStaffCreateMenu()
    local categories = {
        { value = 'rule_violation',   label = 'Rule Violation' },
        { value = 'exploit_abuse',    label = 'Exploit Abuse' },
        { value = 'staff_assistance', label = 'Staff Assistance' },
        { value = 'technical_issue',  label = 'Technical Issue' },
        { value = 'economy_issue',    label = 'Economy Issue' },
        { value = 'property_issue',   label = 'Property Issue' }
    }

    local priorities = {
        { value = 'low', label = '🟢 Low Priority' },
        { value = 'medium', label = '🟡 Medium Priority' },
        { value = 'high', label = '🟠 High Priority' },
        { value = 'urgent', label = '🔴 Urgent' }
    }

    local nearbyPlayers = tickets.getNearbyPlayers(50.0)

    local input = lib.inputDialog('Create Staff Ticket', {
        { type = 'input',    label = 'Title',                    description = 'Brief ticket title',   required = true,   max = 100 },
        { type = 'textarea', label = 'Description',              description = 'Detailed description', required = true,   max = 500 },
        { type = 'select',   label = 'Category',                 options = categories,                 required = true },
        { type = 'select',   label = 'Priority',                 options = priorities,                 default = 'medium' },
        { type = 'select',   label = 'Target Player (Optional)', options = nearbyPlayers,              clearable = true }
    })

    if input then
        local targetId = input[5] ~= 0 and input[5] or nil
        TriggerServerEvent('tickets:createStaffTicket', input[1], input[2], input[3], input[4], targetId)
    end
end

---Opens detailed view of staff ticket with actions
---@param ticketId number Ticket ID
function tickets.openStaffTicketDetails(ticketId)
    lib.callback('tickets:getTicketDetails', false, function(ticket)
        if not ticket then
            lib.notify({ type = 'error', description = 'Ticket not found' })
            return
        end

        local options = {
            {
                title = '📋 Ticket Information',
                description = string.format('ID: #%d\nStatus: %s\nCategory: %s\nPriority: %s\nReporter: %s',
                    ticket.id, statusTexts[ticket.status], ticket.category, ticket.priority, ticket.reporter_name),
                disabled = true
            },
            {
                title = '📝 Description',
                description = ticket.description,
                disabled = true
            }
        }

        if ticket.target_name then
            table.insert(options, {
                title = '🎯 Target Player',
                description = ticket.target_name .. ' (ID: ' .. (ticket.target_id or 'Offline') .. ')',
                disabled = true
            })
        end

        table.insert(options, {
            title = '💬 View Messages (' .. (#ticket.messages or 0) .. ')',
            description = 'Ticket conversation',
            icon = 'comments',
            onSelect = function()
                tickets.openStaffMessages(ticketId, ticket.messages or {})
            end
        })

        table.insert(options, {
            title = '✉️ Add Response',
            description = 'Send message to reporter',
            icon = 'reply',
            onSelect = function()
                tickets.addStaffMessage(ticketId, false)
            end
        })

        table.insert(options, {
            title = '📝 Internal Note',
            description = 'Staff-only internal note',
            icon = 'sticky-note',
            onSelect = function()
                tickets.addStaffMessage(ticketId, true)
            end
        })

        if ticket.reporter_id and ticket.is_player_report == 1 then
            table.insert(options, {
                title = '🛠️ Staff Actions',
                description = 'Administrative tools',
                icon = 'tools',
                onSelect = function()
                    tickets.openStaffActions(ticketId, ticket)
                end
            })
        end

        if ticket.status ~= 'closed' then
            table.insert(options, {
                title = '📊 Change Status',
                description = 'Update ticket status',
                icon = 'edit',
                onSelect = function()
                    tickets.changeTicketStatus(ticketId)
                end
            })
        end

        lib.registerContext({
            id = 'staff_ticket_details',
            title = 'Ticket #' .. ticketId,
            menu = 'staff_tickets',
            options = options
        })

        lib.showContext('staff_ticket_details')
    end, ticketId)
end

---Opens staff messages view
---@param ticketId number Ticket ID
---@param messages table Array of messages
function tickets.openStaffMessages(ticketId, messages)
    local options = {}

    for _, message in ipairs(messages) do
        local senderIcon = message.is_staff and '👨‍💼' or '👤'
        local internalFlag = message.is_internal and ' [INTERNAL]' or ''
        local timeText = os.date('%d/%m %H:%M', message.timestamp)

        table.insert(options, {
            title = string.format('%s %s - %s%s', senderIcon, message.sender_name, timeText, internalFlag),
            description = message.message,
            disabled = true
        })
    end

    if #options == 0 then
        table.insert(options, {
            title = 'No messages yet',
            description = 'Start the conversation',
            disabled = true
        })
    end

    lib.registerContext({
        id = 'staff_messages',
        title = 'Ticket #' .. ticketId .. ' - Messages',
        menu = 'staff_ticket_details',
        options = options
    })

    lib.showContext('staff_messages')
end

---Opens dialog to add staff message
---@param ticketId number Ticket ID
---@param isInternal boolean Whether message is internal
function tickets.addStaffMessage(ticketId, isInternal)
    local messageType = isInternal and 'Internal Note' or 'Response to Player'

    local input = lib.inputDialog(messageType, {
        { type = 'textarea', label = 'Message', description = isInternal and 'Staff-only note' or 'Message visible to player', required = true, max = 500 }
    })

    if input and input[1] then
        TriggerServerEvent('tickets:addMessage', ticketId, input[1])
        lib.notify({
            type = 'success',
            description = 'Message added successfully'
        })
    end
end

---Opens ticket status change dialog
---@param ticketId number Ticket ID
function tickets.changeTicketStatus(ticketId)
    local statusOptions = {
        { value = 'open', label = '🟡 Open' },
        { value = 'assigned', label = '🔵 Assigned' },
        { value = 'in_progress', label = '🟠 In Progress' },
        { value = 'resolved', label = '🟢 Resolved' },
        { value = 'closed', label = '⚫ Closed' }
    }

    local input = lib.inputDialog('Change Status', {
        { type = 'select', label = 'New Status', options = statusOptions, required = true }
    })

    if input and input[1] then
        TriggerServerEvent('tickets:updateStatus', ticketId, input[1])
    end
end

---Opens staff actions menu
---@param ticketId number Ticket ID
---@param ticket table Ticket data
function tickets.openStaffActions(ticketId, ticket)
    local options = {
        {
            title = '🚀 Go to Player',
            description = 'Teleport to player location',
            icon = 'location-arrow',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'goto_player')
            end
        },
        {
            title = '📍 Bring Player',
            description = 'Teleport player to you',
            icon = 'hand-paper',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'bring_player')
            end
        },

        {
            title = '🔧 Debug Player',
            description = 'Fix player position',
            icon = 'wrench',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'debug_player')
            end
        },
        {
            title = '❄️ Freeze Player',
            description = 'Freeze player movement',
            icon = 'snowflake',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'freeze_player')
            end
        },
        {
            title = '🔥 Unfreeze Player',
            description = 'Allow player movement',
            icon = 'fire',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'unfreeze_player')
            end
        },
        {
            title = '📍 Go to Location',
            description = 'Teleport to report location',
            icon = 'map-marker',
            onSelect = function()
                TriggerServerEvent('tickets:executeAction', ticketId, 'goto_location')
            end
        }
    }

    lib.registerContext({
        id = 'staff_actions',
        title = 'Staff Actions',
        menu = 'staff_ticket_details',
        options = options
    })

    lib.showContext('staff_actions')
end

RegisterNetEvent('tickets:statusUpdate', function(ticketId, newStatus)
    lib.notify({
        type = 'info',
        title = 'Report #' .. ticketId,
        description = 'Status updated to: ' .. statusTexts[newStatus],
        duration = 8000
    })
end)

RegisterNetEvent('tickets:staffResponse', function(ticketId, staffName, message)
    lib.notify({
        type = 'info',
        title = 'Staff Response',
        description = staffName .. ' responded to your report #' .. ticketId,
        duration = 10000,
        position = 'top'
    })

    PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
end)

RegisterNetEvent('tickets:teleportTo', function(coords)
    if not lib.hasPermission('tickets.admin') then
        lib.notify({ type = 'error', description = 'Access denied' })
        return
    end

    if not coords or not coords.x or not coords.y or not coords.z then
        lib.notify({ type = 'error', description = 'Invalid coordinates' })
        return
    end

    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    lib.notify({ type = 'success', description = 'Teleported successfully' })
end)



RegisterNetEvent('tickets:debugPlayer', function()
    if not lib.hasPermission('tickets.admin') then
        lib.notify({ type = 'error', description = 'Access denied' })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)

    if found then
        SetEntityCoords(ped, coords.x, coords.y, groundZ + 1.0, false, false, false, true)
        lib.notify({ type = 'success', description = 'Position debugged' })
    else
        lib.notify({ type = 'error', description = 'Could not find ground position' })
    end
end)

RegisterNetEvent('tickets:freezePlayer', function(freeze)
    if not lib.hasPermission('tickets.admin') then
        lib.notify({ type = 'error', description = 'Access denied' })
        return
    end

    if type(freeze) ~= 'boolean' then
        lib.notify({ type = 'error', description = 'Invalid freeze state' })
        return
    end

    frozenState = freeze
    FreezeEntityPosition(PlayerPedId(), freeze)
end)

RegisterNetEvent('tickets:playSound', function(soundType)
    if soundType == 'new_ticket' then
        PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", true)
    end
end)



RegisterCommand('report', function()
    tickets.openPlayerReportMenu()
end, false)

RegisterCommand('myreports', function()
    tickets.openMyReports()
end, false)

RegisterCommand('tickets', function()
    tickets.openStaffMenu()
end, false)

RegisterCommand('stuck', function()
    tickets.quickStuckReport()
end, false)

lib.tickets = tickets

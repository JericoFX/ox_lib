---@meta
--[[
    Player Ticket System for ox_lib

    A comprehensive support ticket system allowing players to create reports
    and staff to manage, respond to, and resolve player issues with full
    administrative actions including teleportation, debugging, spectating,
    and player management tools.

    Example usage:
    ```lua
    -- Player creates a ticket
    lib.tickets.createPlayerReport(playerId, "Player griefing", "Player X is destroying my car", "player_report", targetId)

    -- Staff responds to ticket
    lib.tickets.addMessage(ticketId, staffId, "I'm investigating this issue", true, false)

    -- Staff executes action
    lib.tickets.executeAction(ticketId, staffId, "goto_player")
    ```
--]]

local tickets = {}

---@class PlayerTicket
---@field id number Unique ticket identifier
---@field reporter_id number Reporter player server ID
---@field reporter_license string Reporter license identifier
---@field reporter_name string Reporter display name
---@field target_id? number Target player server ID (for reports)
---@field target_license? string Target player license
---@field target_name? string Target player name
---@field category string Ticket category
---@field priority string Priority level (low, medium, high, urgent)
---@field status string Current status (open, assigned, in_progress, resolved, closed)
---@field title string Ticket title/subject
---@field description string Detailed ticket description
---@field assigned_to? number Staff member server ID
---@field assigned_name? string Staff member display name
---@field created_at number Creation timestamp
---@field updated_at number Last update timestamp
---@field resolved_at? number Resolution timestamp
---@field location vector3 Incident location coordinates
---@field rating? number Player satisfaction rating (1-5)
---@field is_player_report boolean Whether created by regular player

---@class TicketMessage
---@field id number Message unique identifier
---@field ticket_id number Parent ticket ID
---@field sender_id number Message sender server ID
---@field sender_name string Sender display name
---@field message string Message content
---@field is_staff boolean Whether sender is staff member
---@field is_internal boolean Whether message is internal staff note
---@field timestamp number Message creation timestamp

---@class TicketConfig
---@field permissions table Permission configuration
---@field player_categories string[] Categories available to players
---@field staff_categories string[] Categories available to staff
---@field priorities table Priority level definitions
---@field limits table Various system limits
---@field discord_webhook? string Discord webhook URL for notifications
---@field auto_assign boolean Enable automatic staff assignment

local ticketConfig = {
    permissions = {
        create = 'tickets.create',
        player_report = 'basic',
        manage = 'tickets.manage',
        admin = 'tickets.admin',
        supervisor = 'tickets.supervisor'
    },
    player_categories = {
        'player_report',
        'bug_report',
        'help_request',
        'character_stuck',
        'item_lost',
        'refund_request'
    },
    staff_categories = {
        'rule_violation',
        'exploit_abuse',
        'staff_assistance',
        'technical_issue',
        'economy_issue',
        'property_issue'
    },
    priorities = {
        low = { name = 'Low', color = 'green', response_time = 30 },
        medium = { name = 'Medium', color = 'yellow', response_time = 15 },
        high = { name = 'High', color = 'orange', response_time = 5 },
        urgent = { name = 'Urgent', color = 'red', response_time = 2 }
    },
    limits = {
        max_player_tickets = 3,
        max_staff_tickets = 5,
        max_message_length = 500,
        max_title_length = 100
    },
    discord_webhook = GetConvar('tickets_discord_webhook', ''),
    auto_assign = true
}

local activeTickets = {}
local staffWorkload = {}

---Creates database tables automatically on resource start
local function createDatabaseTables()
    local queries = {
        [[
        CREATE TABLE IF NOT EXISTS `player_tickets` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `reporter_id` int(11) NOT NULL,
            `reporter_license` varchar(100) NOT NULL,
            `reporter_name` varchar(100) NOT NULL,
            `target_id` int(11) DEFAULT NULL,
            `target_license` varchar(100) DEFAULT NULL,
            `target_name` varchar(100) DEFAULT NULL,
            `category` varchar(50) NOT NULL,
            `priority` enum('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
            `status` enum('open','assigned','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
            `title` varchar(100) NOT NULL,
            `description` text NOT NULL,
            `assigned_to` int(11) DEFAULT NULL,
            `assigned_name` varchar(100) DEFAULT NULL,
            `location_x` float DEFAULT NULL,
            `location_y` float DEFAULT NULL,
            `location_z` float DEFAULT NULL,
            `created_at` int(11) NOT NULL,
            `updated_at` int(11) NOT NULL,
            `resolved_at` int(11) DEFAULT NULL,
            `rating` tinyint(1) DEFAULT NULL,
            `is_player_report` tinyint(1) NOT NULL DEFAULT 1,
            PRIMARY KEY (`id`),
            KEY `idx_reporter` (`reporter_license`),
            KEY `idx_assigned` (`assigned_to`),
            KEY `idx_status` (`status`),
            KEY `idx_category` (`category`),
            KEY `idx_priority` (`priority`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS `ticket_messages` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `ticket_id` int(11) NOT NULL,
            `sender_id` int(11) NOT NULL,
            `sender_name` varchar(100) NOT NULL,
            `message` text NOT NULL,
            `is_staff` tinyint(1) NOT NULL DEFAULT 0,
            `is_internal` tinyint(1) NOT NULL DEFAULT 0,
            `timestamp` int(11) NOT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_ticket` (`ticket_id`),
            KEY `idx_sender` (`sender_id`),
            CONSTRAINT `fk_messages_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `player_tickets` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS `ticket_staff_stats` (
            `staff_license` varchar(100) NOT NULL,
            `staff_name` varchar(100) NOT NULL,
            `tickets_handled` int(11) NOT NULL DEFAULT 0,
            `avg_response_time` float NOT NULL DEFAULT 0,
            `total_response_time` int(11) NOT NULL DEFAULT 0,
            `last_activity` int(11) NOT NULL,
            PRIMARY KEY (`staff_license`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    }

    for i, query in ipairs(queries) do
        MySQL.query(query, {}, function(result)
            if result ~= nil then
                print(string.format('[Tickets] Database table %d/3 created successfully', i))
            else
                print(string.format('[Tickets] Error creating database table %d/3', i))
            end
        end)
    end

    print('[Tickets] Database initialization completed')
end

---Gets player license identifier
---@param source number Player server ID
---@return string? license Player license or nil
local function getPlayerLicense(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and identifier:match('^license:') then
            return identifier
        end
    end
    return nil
end

---Gets all player identifiers
---@param source number Player server ID
---@return table identifiers Table of all player identifiers
local function getPlayerIdentifiers(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            local prefix = identifier:match('^([^:]+):')
            identifiers[prefix] = identifier
        end
    end
    return identifiers
end

---Creates a player report ticket
---@param playerId number Player server ID creating the report
---@param title string Ticket title
---@param description string Detailed description
---@param category string Ticket category
---@param targetId? number Target player server ID (optional)
---@return number|boolean ticketId Created ticket ID or false on failure
function tickets.createPlayerReport(playerId, title, description, category, targetId)
    if not lib.table.contains(ticketConfig.player_categories, category) then
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Invalid category selected'
        })
        return false
    end

    local playerLicense = getPlayerLicense(playerId)
    if not playerLicense then
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Failed to retrieve player identifiers'
        })
        return false
    end

    local openTickets = MySQL.scalar.await('SELECT COUNT(*) FROM player_tickets WHERE reporter_license = ? AND status NOT IN (?, ?)', {
        playerLicense, 'closed', 'resolved'
    })

    if openTickets >= ticketConfig.limits.max_player_tickets then
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'You can only have ' .. ticketConfig.limits.max_player_tickets .. ' open tickets'
        })
        return false
    end

    local reporterName = GetPlayerName(playerId)
    local reporterCoords = GetEntityCoords(GetPlayerPed(playerId))

    local targetInfo = {}
    if targetId and GetPlayerName(targetId) then
        targetInfo = {
            id = targetId,
            license = getPlayerLicense(targetId),
            name = GetPlayerName(targetId)
        }
    end

    local currentTime = os.time()
    local priority = 'medium'

    local ticketId = MySQL.insert.await(
        'INSERT INTO player_tickets (reporter_id, reporter_license, reporter_name, target_id, target_license, target_name, category, priority, status, title, description, location_x, location_y, location_z, created_at, updated_at, is_player_report) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)',
        {
            playerId, playerLicense, reporterName,
            targetInfo.id, targetInfo.license, targetInfo.name,
            category, priority, 'open', title, description,
            reporterCoords.x, reporterCoords.y, reporterCoords.z,
            currentTime, currentTime
        })

    if not ticketId then return false end

    local ticket = {
        id = ticketId,
        reporter_id = playerId,
        reporter_license = playerLicense,
        reporter_name = reporterName,
        target_id = targetInfo.id,
        target_name = targetInfo.name,
        category = category,
        priority = priority,
        status = 'open',
        title = title,
        description = description,
        location = reporterCoords,
        created_at = currentTime,
        is_player_report = true
    }

    activeTickets[ticketId] = ticket

    TriggerClientEvent('ox_lib:notify', playerId, {
        type = 'success',
        description = 'Ticket #' .. ticketId .. ' created successfully'
    })

    tickets.notifyStaff('new_ticket', ticket)

    if ticketConfig.auto_assign then
        tickets.autoAssign(ticketId)
    end

    return ticketId
end

---Creates a staff ticket
---@param staffId number Staff member server ID
---@param title string Ticket title
---@param description string Detailed description
---@param category string Ticket category
---@param priority string Ticket priority
---@param targetId? number Target player server ID
---@return number|boolean ticketId Created ticket ID or false on failure
function tickets.createStaffTicket(staffId, title, description, category, priority, targetId)
    if not lib.hasPermission(staffId, ticketConfig.permissions.create) then
        TriggerClientEvent('ox_lib:notify', staffId, {
            type = 'error',
            description = 'No permission to create tickets'
        })
        return false
    end

    if not lib.table.contains(ticketConfig.staff_categories, category) then
        TriggerClientEvent('ox_lib:notify', staffId, {
            type = 'error',
            description = 'Invalid category selected'
        })
        return false
    end

    local staffLicense = getPlayerLicense(staffId)
    local staffName = GetPlayerName(staffId)
    local staffCoords = GetEntityCoords(GetPlayerPed(staffId))

    local targetInfo = {}
    if targetId and GetPlayerName(targetId) then
        targetInfo = {
            id = targetId,
            license = getPlayerLicense(targetId),
            name = GetPlayerName(targetId)
        }
    end

    local currentTime = os.time()

    local ticketId = MySQL.insert.await(
        'INSERT INTO player_tickets (reporter_id, reporter_license, reporter_name, target_id, target_license, target_name, category, priority, status, title, description, location_x, location_y, location_z, created_at, updated_at, is_player_report) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)',
        {
            staffId, staffLicense, staffName,
            targetInfo.id, targetInfo.license, targetInfo.name,
            category, priority, 'open', title, description,
            staffCoords.x, staffCoords.y, staffCoords.z,
            currentTime, currentTime
        })

    if not ticketId then return false end

    TriggerClientEvent('ox_lib:notify', staffId, {
        type = 'success',
        description = 'Staff ticket #' .. ticketId .. ' created successfully'
    })

    return ticketId
end

---Assigns a ticket to a staff member
---@param ticketId number Ticket ID
---@param staffId number Staff member server ID
---@param autoAssign? boolean Whether this is an auto-assignment
---@return boolean success Whether assignment was successful
function tickets.assign(ticketId, staffId, autoAssign)
    if not lib.hasPermission(staffId, ticketConfig.permissions.manage) then
        return false
    end

    local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
    if not ticket or ticket.status == 'closed' then return false end

    local staffName = GetPlayerName(staffId)
    local currentTime = os.time()

    MySQL.update.await('UPDATE player_tickets SET assigned_to = ?, assigned_name = ?, status = ?, updated_at = ? WHERE id = ?', {
        staffId, staffName, 'assigned', currentTime, ticketId
    })

    ticket.assigned_to = staffId
    ticket.assigned_name = staffName
    ticket.status = 'assigned'

    staffWorkload[staffId] = (staffWorkload[staffId] or 0) + 1

    TriggerClientEvent('ox_lib:notify', staffId, {
        type = 'info',
        description = 'Assigned to ticket #' .. ticketId
    })

    if ticket.reporter_id and ticket.is_player_report then
        TriggerClientEvent('tickets:statusUpdate', ticket.reporter_id, ticketId, 'assigned')
    end

    if not autoAssign then
        tickets.addMessage(ticketId, staffId, 'Ticket assigned to ' .. staffName, true, true)
    end

    return true
end

---Adds a message to a ticket
---@param ticketId number Ticket ID
---@param senderId number Message sender server ID
---@param message string Message content
---@param isStaff boolean Whether sender is staff
---@param isInternal? boolean Whether message is internal staff note
---@return number|boolean messageId Created message ID or false on failure
function tickets.addMessage(ticketId, senderId, message, isStaff, isInternal)
    local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
    if not ticket then return false end

    if ticket.status == 'closed' then
        TriggerClientEvent('ox_lib:notify', senderId, {
            type = 'error',
            description = 'Cannot add message to closed ticket'
        })
        return false
    end

    local senderName = GetPlayerName(senderId)
    local currentTime = os.time()
    isInternal = isInternal or false

    local messageId = MySQL.insert.await(
        'INSERT INTO ticket_messages (ticket_id, sender_id, sender_name, message, is_staff, is_internal, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            ticketId, senderId, senderName, message, isStaff, isInternal, currentTime
        })

    if not messageId then return false end

    MySQL.update.await('UPDATE player_tickets SET updated_at = ? WHERE id = ?', {
        currentTime, ticketId
    })

    if ticket.status == 'assigned' and isStaff then
        tickets.updateStatus(ticketId, 'in_progress')
    end

    if isStaff and ticket.reporter_id and not isInternal then
        TriggerClientEvent('tickets:staffResponse', ticket.reporter_id, ticketId, senderName, message)
    end

    return messageId
end

---Updates ticket status
---@param ticketId number Ticket ID
---@param newStatus string New status
---@param staffId? number Staff member making the change
---@return boolean success Whether status was updated
function tickets.updateStatus(ticketId, newStatus, staffId)
    local validStatuses = { 'open', 'assigned', 'in_progress', 'resolved', 'closed' }
    if not lib.table.contains(validStatuses, newStatus) then
        return false
    end

    local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
    if not ticket then return false end

    local currentTime = os.time()
    local updateData = { newStatus, currentTime, ticketId }

    if newStatus == 'resolved' or newStatus == 'closed' then
        table.insert(updateData, 2, currentTime)
        MySQL.update.await('UPDATE player_tickets SET status = ?, resolved_at = ?, updated_at = ? WHERE id = ?', updateData)

        if staffWorkload[ticket.assigned_to] then
            staffWorkload[ticket.assigned_to] = math.max(0, staffWorkload[ticket.assigned_to] - 1)
        end
    else
        MySQL.update.await('UPDATE player_tickets SET status = ?, updated_at = ? WHERE id = ?', updateData)
    end

    ticket.status = newStatus

    if ticket.reporter_id and ticket.is_player_report then
        TriggerClientEvent('tickets:statusUpdate', ticket.reporter_id, ticketId, newStatus)
    end

    if staffId then
        tickets.addMessage(ticketId, staffId, 'Ticket status changed to: ' .. newStatus, true, true)
    end

    return true
end

---Auto-assigns ticket to available staff member with lowest workload
---@param ticketId number Ticket ID
---@return boolean success Whether auto-assignment was successful
function tickets.autoAssign(ticketId)
    local availableStaff = {}

    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        if lib.hasPermission(source, ticketConfig.permissions.manage) then
            local workload = staffWorkload[source] or 0
            if workload < ticketConfig.limits.max_staff_tickets then
                table.insert(availableStaff, { id = source, workload = workload })
            end
        end
    end

    if #availableStaff == 0 then return false end

    table.sort(availableStaff, function(a, b) return a.workload < b.workload end)

    return tickets.assign(ticketId, availableStaff[1].id, true)
end

---Gets a ticket by ID
---@param ticketId number Ticket ID
---@return PlayerTicket? ticket Ticket data or nil
function tickets.getTicket(ticketId)
    local result = MySQL.single.await('SELECT * FROM player_tickets WHERE id = ?', { ticketId })
    if result then
        result.location = vector3(result.location_x, result.location_y, result.location_z)
    end
    return result
end

---Notifies all available staff about ticket events
---@param eventType string Event type
---@param ticket PlayerTicket Ticket data
function tickets.notifyStaff(eventType, ticket)
    local staffPlayers = {}

    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        if lib.hasPermission(source, ticketConfig.permissions.manage) then
            table.insert(staffPlayers, source)
        end
    end

    for _, staffId in ipairs(staffPlayers) do
        if eventType == 'new_ticket' then
            local ticketType = ticket.is_player_report and 'Player Report' or 'Staff Ticket'
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'warning',
                description = 'New ' .. ticketType .. ' #' .. ticket.id .. ' - ' .. ticket.category,
                duration = 8000
            })

            TriggerClientEvent('tickets:playSound', staffId, 'new_ticket')
        end
    end
end

local staffActions = {
    goto_player = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.reporter_id then return false end

        local targetPed = GetPlayerPed(ticket.reporter_id)
        if targetPed == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Player is not online'
            })
            return false
        end

        local targetCoords = GetEntityCoords(targetPed)
        if not targetCoords or targetCoords.x == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Invalid player coordinates'
            })
            return false
        end

        TriggerClientEvent('tickets:teleportTo', staffId, targetCoords)
        tickets.addMessage(ticketId, staffId, 'Staff teleported to player', true, true)
        return true
    end,

    bring_player = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.reporter_id then return false end

        if GetPlayerPed(ticket.reporter_id) == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Player is not online'
            })
            return false
        end

        local staffPed = GetPlayerPed(staffId)
        local staffCoords = GetEntityCoords(staffPed)

        if not staffCoords or staffCoords.x == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Invalid staff coordinates'
            })
            return false
        end

        TriggerClientEvent('tickets:teleportTo', ticket.reporter_id, staffCoords)
        TriggerClientEvent('ox_lib:notify', ticket.reporter_id, {
            type = 'info',
            description = 'You have been teleported by staff'
        })

        tickets.addMessage(ticketId, staffId, 'Player teleported to staff', true, true)
        return true
    end,



    debug_player = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.reporter_id then return false end

        if GetPlayerPed(ticket.reporter_id) == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Player is not online'
            })
            return false
        end

        TriggerClientEvent('tickets:debugPlayer', ticket.reporter_id)
        TriggerClientEvent('ox_lib:notify', ticket.reporter_id, {
            type = 'success',
            description = 'You have been debugged by staff'
        })

        tickets.addMessage(ticketId, staffId, 'Player debugged successfully', true, true)
        return true
    end,

    freeze_player = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.reporter_id then return false end

        if GetPlayerPed(ticket.reporter_id) == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Player is not online'
            })
            return false
        end

        TriggerClientEvent('tickets:freezePlayer', ticket.reporter_id, true)
        TriggerClientEvent('ox_lib:notify', ticket.reporter_id, {
            type = 'warning',
            description = 'You have been frozen by staff'
        })

        tickets.addMessage(ticketId, staffId, 'Player frozen', true, true)
        return true
    end,

    unfreeze_player = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.reporter_id then return false end

        if GetPlayerPed(ticket.reporter_id) == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Player is not online'
            })
            return false
        end

        TriggerClientEvent('tickets:freezePlayer', ticket.reporter_id, false)
        TriggerClientEvent('ox_lib:notify', ticket.reporter_id, {
            type = 'success',
            description = 'You have been unfrozen by staff'
        })

        tickets.addMessage(ticketId, staffId, 'Player unfrozen', true, true)
        return true
    end,

    goto_location = function(ticketId, staffId)
        if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
            return false
        end

        local ticket = activeTickets[ticketId] or tickets.getTicket(ticketId)
        if not ticket or not ticket.location then return false end

        if not ticket.location.x or ticket.location.x == 0 then
            TriggerClientEvent('ox_lib:notify', staffId, {
                type = 'error',
                description = 'Invalid report location'
            })
            return false
        end

        TriggerClientEvent('tickets:teleportTo', staffId, ticket.location)
        tickets.addMessage(ticketId, staffId, 'Staff teleported to report location', true, true)
        return true
    end
}

---Executes a staff action on a ticket
---@param ticketId number Ticket ID
---@param staffId number Staff member server ID
---@param action string Action to execute
---@param params? any Additional parameters for action
---@return boolean success Whether action was executed successfully
function tickets.executeAction(ticketId, staffId, action, params)
    if not lib.hasPermission(staffId, ticketConfig.permissions.admin) then
        TriggerClientEvent('ox_lib:notify', staffId, {
            type = 'error',
            description = 'No permission to execute this action'
        })
        return false
    end

    local actionFunc = staffActions[action]
    if not actionFunc then
        TriggerClientEvent('ox_lib:notify', staffId, {
            type = 'error',
            description = 'Invalid action'
        })
        return false
    end

    local success = actionFunc(ticketId, staffId, params)
    if success then
        MySQL.update.await('UPDATE player_tickets SET updated_at = ? WHERE id = ?', {
            os.time(), ticketId
        })
    end

    return success
end

lib.callback.register('tickets:getStaffTickets', function(source)
    if not lib.hasPermission(source, ticketConfig.permissions.manage) then
        return {}
    end

    local result = MySQL.query.await('SELECT * FROM player_tickets WHERE status IN (?, ?, ?) ORDER BY priority DESC, created_at ASC', {
        'open', 'assigned', 'in_progress'
    })

    return result or {}
end)

lib.callback.register('tickets:getPlayerTickets', function(source)
    local playerLicense = getPlayerLicense(source)
    if not playerLicense then return {} end

    local result = MySQL.query.await('SELECT * FROM player_tickets WHERE reporter_license = ? AND status NOT IN (?) ORDER BY created_at DESC', {
        playerLicense, 'closed'
    })

    return result or {}
end)

lib.callback.register('tickets:getTicketDetails', function(source, ticketId)
    local ticket = tickets.getTicket(ticketId)
    if not ticket then return nil end

    if not lib.hasPermission(source, ticketConfig.permissions.manage) and ticket.reporter_license ~= getPlayerLicense(source) then
        return nil
    end

    local messages = MySQL.query.await('SELECT * FROM ticket_messages WHERE ticket_id = ? ORDER BY timestamp ASC', { ticketId })
    ticket.messages = messages or {}

    return ticket
end)

RegisterServerEvent('tickets:createPlayerReport', function(title, description, category, targetId)
    local source = source
    tickets.createPlayerReport(source, title, description, category, targetId)
end)

RegisterServerEvent('tickets:createStaffTicket', function(title, description, category, priority, targetId)
    local source = source
    tickets.createStaffTicket(source, title, description, category, priority, targetId)
end)

RegisterServerEvent('tickets:addMessage', function(ticketId, message)
    local source = source
    local isStaff = lib.hasPermission(source, ticketConfig.permissions.manage)
    tickets.addMessage(ticketId, source, message, isStaff, false)
end)

RegisterServerEvent('tickets:executeAction', function(ticketId, action, params)
    local source = source

    if not lib.hasPermission(source, ticketConfig.permissions.admin) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Access denied'
        })
        return
    end

    if not ticketId or not action then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid parameters'
        })
        return
    end

    tickets.executeAction(ticketId, source, action, params)
end)

RegisterServerEvent('tickets:assign', function(ticketId, staffId)
    local source = source
    if lib.hasPermission(source, ticketConfig.permissions.supervisor) then
        tickets.assign(ticketId, staffId or source)
    end
end)

RegisterServerEvent('tickets:updateStatus', function(ticketId, newStatus)
    local source = source
    if lib.hasPermission(source, ticketConfig.permissions.manage) then
        tickets.updateStatus(ticketId, newStatus, source)
    end
end)

lib.tickets = tickets

-- Initialize database tables on resource start
CreateThread(function()
    Wait(1000) -- Wait for MySQL to be ready
    createDatabaseTables()
end)

# ox_lib Extended - Universal API & Wrapper System

> **⚠️ EXPERIMENTAL BUILD - DO NOT USE IN PRODUCTION ⚠️**

## **🚨 IMPORTANT WARNING**

**THIS IS AN EXPERIMENTAL BUILD AND SHOULD NEVER BE USED IN PRODUCTION ENVIRONMENTS.**

- ❌ **NOT TESTED** - This code has not been thoroughly tested
- ❌ **NOT STABLE** - May contain bugs, memory leaks, or performance issues
- ❌ **NO SUPPORT** - This is proof-of-concept code only
- ❌ **BREAKING CHANGES** - Implementation may change without notice
- ❌ **DATA LOSS RISK** - Could potentially cause data corruption or loss

**Use at your own risk and only in development/testing environments.**

---

## What is this?

This is an **experimental extension** of the original ox_lib that adds:

### 🔧 **Universal API System**

- `lib.player` - Player management functions
- `lib.task` - Task and animation utilities
- `lib.vehicle` - Vehicle manipulation tools
- `lib.enums` - **NEW!** Comprehensive shared enumerations and constants
- `lib.events` - **NEW!** Universal event system with automatic caching
- `lib.npc` - **NEW!** Advanced NPC system with intelligent AI and behaviors
- `lib.blips` - **NEW!** Enhanced blip management system with object-oriented approach
- `lib.discord` - **NEW!** Instance-based Discord webhook integration system

### 🌐 **Framework Wrappers**

- `lib.core` - Universal framework wrapper (ESX/QBCore/ox_core)
- `lib.inventory` - Universal inventory wrapper (ox_inventory/qb-inventory/qs-inventory)
- `lib.dispatch` - Universal dispatch wrapper (cd_dispatch/ps-dispatch)
- `lib.phone` - Universal phone wrapper (qb-phone/qs-smartphone/etc)
- `lib.banking` - Universal banking wrapper (okokBanking/qb-banking/etc)
- `lib.tickets` - **NEW!** Advanced ticket system with player reporting and staff management

### ✨ **Key Features**

- **Auto-detection** of installed frameworks/systems
- **Normalized data structures** across different frameworks
- **Universal event system** with automatic framework mapping
- **Intelligent caching** using ox_lib's native cache system
- **Advanced NPC system** with AI, memory, and complex behaviors
- **Singleton pattern** for direct access
- **Lazy loading** for performance
- **Backward compatibility** with existing ox_lib imports

---

## 🎯 **NEW: Discord Integration System**

The **Discord Integration System** provides an instance-based approach to Discord webhook management with default configurations, rich embeds, and specialized logging functions.

### **The Problem It Solves**

```lua
-- Before: Repetitive webhook configuration for every message
local webhook = "https://discord.com/api/webhooks/..."
TriggerEvent('discord:sendMessage', webhook, message, {
    username = 'Server',
    avatar_url = 'https://...',
    -- Same config repeated everywhere
})
```

### **The Solution**

```lua
-- After: Instance-based configuration
local adminDiscord = lib.discord:new('ADMIN_WEBHOOK', {
    username = 'Admin System',
    avatar_url = 'https://admin-icon.png',
    default_color = 'red',
    server_name = 'My FiveM Server'
})

-- Simple usage with instance defaults
adminDiscord:sendSuccess('Admin Action', 'Player was banned')
adminDiscord:sendPlayerLog(playerId, 'Player Banned', 'Reason: Cheating')
```

### **Key Features**

- **📦 Instance Management** - Create multiple Discord instances for different channels
- **⚙️ Default Configuration** - Set webhook, username, colors per instance
- **🎨 Rich Embeds** - Automated embed creation with colors and formatting
- **👤 Player Logging** - Automatic player identifier extraction
- **🔧 Admin Logging** - Structured admin action logs
- **📊 Server Status** - Server monitoring and status updates
- **🎯 Text Formatting** - Discord markdown formatting utilities
- **🔒 Validation** - Automatic webhook URL validation
- **🔄 Override Support** - Override instance defaults per message

### **Creating Discord Instances**

```lua
-- Basic instance with webhook
local generalDiscord = lib.discord:new('https://discord.com/api/webhooks/...')

-- Advanced instance with full configuration
local adminDiscord = lib.discord:new('ADMIN_WEBHOOK_URL', {
    username = 'Admin System',
    avatar_url = 'https://example.com/admin-icon.png',
    server_name = 'My FiveM Server',
    server_icon = 'https://example.com/server-icon.png',
    default_color = 'red',
    validate_webhooks = true
})
```

### **Available Methods**

**Basic Messaging:**
- `:sendMessage(message, webhook?, options?)` - Send simple text message
- `:sendEmbed(embeds, webhook?, options?)` - Send rich embeds

**Log Methods:**
- `:sendLog(title, description, color?, webhook?, options?)` - Generic log
- `:sendSuccess(title, description, webhook?, options?)` - Success log (green)
- `:sendError(title, description, webhook?, options?)` - Error log (red)
- `:sendWarning(title, description, webhook?, options?)` - Warning log (yellow)
- `:sendInfo(title, description, webhook?, options?)` - Info log (blue)

**Specialized Logs:**
- `:sendPlayerLog(playerId, action, description, webhook?, options?)` - Player-specific logs
- `:sendAdminLog(admin, action, target, reason?, webhook?, options?)` - Admin action logs
- `:sendServerStatus(status, message?, webhook?, options?)` - Server status updates

**Embed Building:**
- `:createEmbed(options?)` - Create embed object
- `:addField(embed, name, value, inline?)` - Add field to embed

**Text Formatting:**
- `:formatCode(text, language?)` - Code blocks
- `:formatBold(text)` - **Bold text**
- `:formatItalic(text)` - *Italic text*
- `:formatUnderline(text)` - __Underlined text__
- `:formatStrikethrough(text)` - ~~Strikethrough text~~
- `:formatSpoiler(text)` - ||Spoiler text||
- `:formatQuote(text)` - > Quote text
- `:formatBlockQuote(text)` - >>> Block quote

**Instance Management:**
- `:getWebhook()` - Get current default webhook
- `:setWebhook(webhook)` - Set new default webhook
- `:getOptions()` - Get current instance options
- `:setOptions(options)` - Update instance options
- `:getColors()` - Get available color definitions

### **Example Usage**

```lua
-- Create instances for different purposes
local adminLogs = lib.discord:new(Config.AdminWebhook, {
    username = 'Admin System',
    default_color = 'red'
})

local playerLogs = lib.discord:new(Config.PlayerWebhook, {
    username = 'Player System',
    default_color = 'blue'
})

-- Player events
RegisterNetEvent('playerConnected')
AddEventHandler('playerConnected', function()
    local source = source
    playerLogs:sendPlayerLog(source, 'Player Connected', 'Player joined the server')
end)

-- Admin actions
RegisterCommand('ban', function(source, args)
    local target = tonumber(args[1])
    local reason = table.concat(args, ' ', 2)
    
    -- Your ban logic here
    
    adminLogs:sendAdminLog(
        GetPlayerName(source),
        'Player Banned',
        GetPlayerName(target),
        reason
    )
end, true)

-- Server status
RegisterNetEvent('onResourceStart')
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        playerLogs:sendServerStatus('online', 'Server has started successfully')
    end
end)

-- Rich embed example
local embed = adminLogs:createEmbed({
    title = 'Server Maintenance',
    description = 'Scheduled maintenance in 30 minutes',
    color = 'yellow',
    thumbnail = 'https://example.com/maintenance-icon.png'
})

adminLogs:addField(embed, 'Duration', '2 hours', true)
adminLogs:addField(embed, 'Reason', 'Database updates', true)
adminLogs:sendEmbed({ embed })
```

### **Configuration Options**

```lua
-- Instance options
{
    username = 'Custom Bot Name',           -- Default username
    avatar_url = 'https://...',            -- Default avatar
    server_name = 'My Server',             -- Footer server name
    server_icon = 'https://...',           -- Footer server icon
    default_color = 'blue',                -- Default embed color
    validate_webhooks = true               -- Validate webhook URLs
}

-- Message options (per message)
{
    username = 'Override Username',         -- Override instance username
    avatar_url = 'https://...',            -- Override instance avatar
    server_name = 'Override Server',       -- Override footer server name
    server_icon = 'https://...',           -- Override footer server icon
    timestamp = '2023-12-01T12:00:00Z',    -- Custom timestamp
    fields = {                             -- Additional embed fields
        { name = 'Field 1', value = 'Value 1', inline = true },
        { name = 'Field 2', value = 'Value 2', inline = false }
    }
}
```

---

## 🎟️ **NEW: Advanced Ticket System**

The **Advanced Ticket System** provides a comprehensive player reporting and staff management solution with intelligent auto-assignment, priority levels, administrative actions, and Discord integration.

### **The Problem It Solves**

```lua
-- Before: Basic reporting with no tracking or management
-- Players: "/report Player is hacking" → lost in chat
-- Staff: No organized way to handle reports
-- Result: Reports get lost, no accountability, poor player experience
```

### **The Solution**

```lua
-- After: Ticket management system
-- Players can create detailed reports
lib.tickets.createReport(source, {
    title = "Player Cheating",
    description = "Player X is using aimbot in the city",
    category = "cheating",
    priority = "high",
    location = GetEntityCoords(PlayerPedId())
})

-- Staff get organized ticket management
lib.tickets.getTickets(source, {
    status = "open",
    assignedTo = source,
    priority = "high"
})
```

### **Key Features**

- **📝 Player Reporting** - Easy `/report` command with categories and priorities
- **👥 Staff Management** - Complete ticket assignment and tracking system
- **🤖 Auto-Assignment** - Intelligent distribution based on staff workload
- **⚡ Quick Actions** - `/stuck` command for immediate help
- **🔧 Admin Tools** - Teleport, debug, freeze players, and more
- **💬 Message System** - Internal staff notes and player communication
- **📊 Analytics** - Performance tracking and statistics
- **🎯 Priority Levels** - Low, medium, high, critical priorities
- **🔗 Discord Integration** - Webhook notifications and logging
- **🗃️ Templates** - Pre-made responses for common issues

### **Available Commands**

**For Players:**

- `/report` - Create a new ticket
- `/myreports` - View your tickets
- `/stuck` - Quick help for being stuck

**For Staff:**

- `/tickets` - Main ticket management interface
- `/ticket [id]` - View specific ticket
- `/closeticket [id]` - Close a ticket
- `/assignticket [id] [player]` - Assign ticket to staff

### **Administrative Actions**

Staff with `tickets.admin` permission can:

- **Go to Player** - Teleport to player location
- **Bring Player** - Teleport player to staff
- **Debug Player** - Fix player position to nearest street
- **Freeze/Unfreeze Player** - Control player movement
- **Go to Location** - Teleport to report location

### **Example Usage**

```lua
-- Player creates a report
lib.tickets.createReport(source, {
    title = "Stuck in building",
    description = "I'm stuck inside the bank and can't get out",
    category = "stuck",
    priority = "medium",
    location = vector3(150.0, -1040.0, 29.3)
})

-- Staff receives notification and can take actions
lib.tickets.assignTicket(ticketId, staffId)
lib.tickets.addMessage(ticketId, staffId, "I'll help you right away!", false)

-- Administrative actions
lib.tickets.executeAction(ticketId, "bring_player", { playerId = playerId })
lib.tickets.executeAction(ticketId, "go_to_location", { coords = reportLocation })
```

### **Permission System**

```bash
# Admin permissions (full access)
add_ace group.admin tickets.create allow
add_ace group.admin tickets.manage allow
add_ace group.admin tickets.admin allow
add_ace group.admin tickets.supervisor allow

# Moderator permissions (manage tickets but limited admin actions)
add_ace group.mod tickets.create allow
add_ace group.mod tickets.manage allow
add_ace group.mod tickets.admin allow

# Helper permissions (can only manage tickets)
add_ace group.helper tickets.manage allow

# Assign players to groups
add_principal identifier.license:YOUR_LICENSE_HERE group.admin
add_principal identifier.license:MOD_LICENSE_HERE group.mod
```

---

## 📝 **NEW: Comprehensive Enumerations System**

The **Comprehensive Enumerations System** provides standardized constants and enumerations across all ox_lib APIs, ensuring consistency and reducing magic numbers throughout your codebase.

### **Available Enumerations**

ox_lib Extended includes the following enumeration modules:

- **`lib.enums.vehicles`** - Vehicle-related constants (doors, windows, classes, colors, etc.)
- **`lib.enums.weapons`** - Weapon hashes, categories, attachments, and ammo types
- **`lib.enums.notifications`** - Notification types, positions, icons, and colors
- **`lib.enums.animations`** - Animation dictionaries and names
- **`lib.enums.tasks`** - Task-related constants and parameters
- **`lib.enums.audio`** - Audio banks, sounds, and music constants
- **`lib.enums.camera`** - Camera types and transition effects
- **`lib.enums.damage`** - Damage types and severity levels
- **`lib.enums.statebags`** - StateBag keys and value types
- **`lib.enums.jobs`** - Job categories and role definitions
- **`lib.enums.flags`** - Various flag constants and bitwise operations

### **Example Usage**

```lua
-- Vehicle management with enums
local vehicle = lib.vehicle.getCurrent()
if vehicle then
    -- Use enum instead of magic numbers
    vehicle:setDoorState(lib.enums.vehicles.DOORS.FRONT_LEFT, true)
    vehicle:setWindowState(lib.enums.vehicles.WINDOWS.FRONT_LEFT, false)

    -- Check vehicle class
    local vehicleClass = vehicle:getClass()
    if vehicleClass == lib.enums.vehicles.CLASSES.EMERGENCY then
        -- Handle emergency vehicle
    end
end

-- Weapon management with enums
local playerPed = cache.ped
GiveWeaponToPed(playerPed, lib.enums.weapons.WEAPONS.COMBAT_PISTOL, 50, false, true)

-- Add weapon attachments using enums
GiveWeaponComponentToPed(playerPed,
    lib.enums.weapons.WEAPONS.COMBAT_PISTOL,
    lib.enums.weapons.ATTACHMENTS.SUPPRESSOR_LIGHT
)

-- Notification with standardized types and icons
lib.notify({
    type = lib.enums.notifications.TYPES.SUCCESS,
    icon = lib.enums.notifications.ICONS.MONEY,
    title = 'Payment Received',
    description = 'You received $500',
    position = lib.enums.notifications.POSITIONS.TOP_RIGHT,
    duration = lib.enums.notifications.DURATION.MEDIUM
})

-- Blip creation with vehicle class enum
local blip = lib.blips.createAtCoords(coords, {
    sprite = lib.enums.vehicles.CLASSES.EMERGENCY + 50, -- Emergency vehicle blip
    color = lib.enums.notifications.COLORS.POLICE
})
```

### **Key Benefits**

- **🔍 IntelliSense Support** - Full autocomplete and type checking
- **📖 Self-Documenting Code** - Clear, readable constant names
- **🛡️ Type Safety** - Reduced magic numbers and typos
- **🎯 Consistency** - Standardized values across all APIs
- **🔧 Maintainability** - Centralized constant management
- **⚡ Performance** - Pre-compiled constants for optimal performance

### **Vehicle Enums Example**

```lua
-- Available vehicle door constants
lib.enums.vehicles.DOORS = {
    FRONT_LEFT = 0,
    FRONT_RIGHT = 1,
    REAR_LEFT = 2,
    REAR_RIGHT = 3,
    HOOD = 4,
    TRUNK = 5
}

-- Vehicle color constants
lib.enums.vehicles.COLORS = {
    BLACK = 0,
    WHITE = 111,
    RED = 27,
    BLUE = 64,
    -- ... and many more
}

-- Vehicle seat positions
lib.enums.vehicles.SEATS = {
    DRIVER = -1,
    PASSENGER = 0,
    REAR_LEFT = 1,
    REAR_RIGHT = 2
}
```

### **Weapons Enums Example**

```lua
-- Common weapon hashes
lib.enums.weapons.WEAPONS = {
    UNARMED = "WEAPON_UNARMED",
    PISTOL = "WEAPON_PISTOL",
    COMBAT_PISTOL = "WEAPON_COMBATPISTOL",
    ASSAULT_RIFLE = "WEAPON_ASSAULTRIFLE",
    -- ... complete weapon list
}

-- Weapon categories
lib.enums.weapons.CATEGORIES = {
    MELEE = "melee",
    HANDGUN = "handgun",
    ASSAULT_RIFLE = "assault_rifle",
    -- ... all categories
}
```

---

## 🗺️ **NEW: Enhanced Blip Management System**

The **Enhanced Blip Management System** provides a powerful object-oriented approach to blip creation and management with automatic cleanup and advanced functionality.

### **The Problem It Solves**

```lua
-- Before: Manual blip management with potential memory leaks
local blip = AddBlipForCoord(100.0, 200.0, 30.0)
SetBlipSprite(blip, 1)
SetBlipColour(blip, 2)
SetBlipScale(blip, 1.0)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("My Location")
EndTextCommandSetBlipName(blip)
-- Result: Manual cleanup required, no centralized management
```

### **The Solution**

```lua
-- After: Object-oriented blip management
local myBlip = lib.blips.createAtCoords(vector3(100.0, 200.0, 30.0), {
    sprite = 1,
    color = 2,
    scale = 1.0,
    label = "My Location",
    shortRange = true
})

-- Easy management
myBlip:setRoute(true, 3)
myBlip:pulse()
local coords = myBlip:getCoords()
myBlip:remove() -- Automatic cleanup
```

### **Key Features**

- **🎯 Object-Oriented Design** - Each blip is a manageable instance
- **📍 Multiple Creation Methods** - Coordinates, entities, radius, and area blips
- **⚙️ Advanced Options** - Comprehensive blip configuration
- **🔧 Dynamic Updates** - Change blip properties after creation
- **🗺️ Route Management** - Easy GPS route creation
- **🔍 Search Functions** - Find blips by sprite or location
- **🧹 Automatic Cleanup** - Proper memory management

### **Available Methods**

**Static Creation Methods:**

```lua
-- Create blip at coordinates
lib.blips.createAtCoords(coords, options)

-- Create blip for entity
lib.blips.createForEntity(entity, options)

-- Create radius blip
lib.blips.createRadius(coords, radius, options)

-- Get all blips of specific sprite
lib.blips.getAllOfSprite(sprite)
```

**Instance Methods:**

```lua
blip:setSprite(sprite)       -- Change blip sprite
blip:setColor(color)         -- Change blip color
blip:setLabel(label)         -- Change blip text
blip:setRoute(enabled, color) -- Set/remove GPS route
blip:setCoords(coords)       -- Move blip location
blip:pulse()                 -- Make blip pulse
blip:getCoords()            -- Get blip position
blip:remove()               -- Delete blip
```

### **Example Usage**

```lua
-- Create a shop blip with full configuration
local shopBlip = lib.blips.createAtCoords(vector3(373.0, 325.0, 103.0), {
    sprite = 52,           -- Shop sprite
    color = 2,             -- Green color
    scale = 0.8,           -- Smaller scale
    label = "24/7 Store",  -- Display name
    shortRange = true,     -- Only show when close
    category = 1,          -- Category for filtering
    alpha = 200            -- Transparency
})

-- Add GPS route to the shop
shopBlip:setRoute(true, 3) -- Enable route with blue color

-- Create a temporary mission blip
local missionBlip = lib.blips.createAtCoords(targetLocation, {
    sprite = 1,
    color = 1,
    label = "Mission Objective"
})

-- Make it pulse for attention
missionBlip:pulse()

-- Clean up when mission is complete
missionBlip:remove()

-- Create a radius blip for an area
local areaBlip = lib.blips.createRadius(vector3(0.0, 0.0, 72.0), 50.0, {
    color = 1,
    alpha = 128,
    label = "Restricted Area"
})
```

---

## 🤖 **NEW: Advanced NPC System**

One of the most exciting additions to ox_lib Extended is the **Advanced NPC System** that provides intelligent AI-driven NPCs with complex behaviors, memory systems, and realistic interactions.

### **The Problem It Solves**

```lua
-- Before: Basic NPCs with static behaviors
local ped = CreatePed(4, GetHashKey('a_m_y_business_01'), 100, 200, 25, 0.0, false, true)
TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
-- Result: Lifeless, predictable NPCs that don't react to the world
```

### **The Solution**

```lua
-- After: Intelligent NPCs with advanced AI
local bankGuard = lib.npc.create({
    model = 's_m_y_cop_01',
    coords = vector3(150, -1040, 29.3),
    behaviors = {'guard', 'patrol'},

    -- Intelligent threat detection
    guardZone = {
        center = vector3(150, -1040, 29.3),
        radius = 20.0
    },

    -- Automatic scheduling
    schedule = {
        [8] = 'patrol',     -- Patrol during day
        [20] = 'guard'      -- Guard at night
    },

    -- Combat configuration
    combat = {
        ability = 3,
        weapon = 'WEAPON_PISTOL'
    }
})
```

### **Advanced NPC Features**

- **🧠 AI States** - 7 different AI states (IDLE, PATROLLING, ALERT, FLEEING, etc.)
- **👁️ Threat Detection** - Automatic assessment of player threats and appropriate responses
- **🧱 Memory System** - NPCs remember previous interactions and relationships
- **⏰ Dynamic Scheduling** - Behavior changes based on time of day
- **😨 Fear System** - Realistic reactions to weapons and aggressive behavior
- **🚨 Alert Networks** - Guards can communicate and coordinate responses
- **🎭 Multiple Behaviors** - Patrol, Guard, Civilian, Worker, Vendor behaviors
- **👔 Appearance Customization** - Complete clothing and prop configuration
- **💬 Interaction System** - Context-aware dialog and interaction zones

### **Available NPC Behaviors**

- `patrol` - Intelligent patrolling between points with different movement styles
- `guard` - Area protection with threat assessment and alert levels
- `civilian` - Realistic civilian behavior with fear reactions and friendly interactions
- `worker` - Task-based work routines with scheduling and breaks
- `vendor` - Customer service behavior with greetings and attention

### **Example: Intelligent Bank Guard**

```lua
local bankGuard = lib.npc.create({
    model = 's_m_y_cop_01',
    coords = vector3(150.0, -1040.0, 29.3),
    behaviors = {'guard', 'patrol'},

    -- Threat detection zone
    guardZone = {
        center = vector3(150.0, -1040.0, 29.3),
        radius = 20.0
    },

    -- Patrol route
    patrolPoints = {
        vector3(145.0, -1035.0, 29.3),
        vector3(155.0, -1035.0, 29.3),
        vector3(155.0, -1045.0, 29.3),
        vector3(145.0, -1045.0, 29.3)
    },

    -- Combat ready
    combat = {
        ability = 3,           -- Professional level
        weapon = 'WEAPON_PISTOL'
    },

    -- Alert network for coordination
    alertNetwork = 'bank_security',
    warningTime = 2000,        -- 2 second warning before engaging

    -- Work schedule
    schedule = {
        [8] = 'patrol',        -- Active patrol during business hours
        [18] = 'guard',        -- Static guarding after hours
        [22] = 'patrol'        -- Night patrol
    }
})
```

---

## 🎯 **NEW: Universal Events System with Cache**

The most powerful feature of ox_lib Extended is the **Universal Events System** that provides a consistent API for handling events across different frameworks, with **automatic intelligent caching**.

### **The Problem It Solves**

```lua
-- Before: Framework-specific events + repeated API calls
-- ESX
AddEventHandler('esx:playerLoaded', function(xPlayer)
    local money = xPlayer.getMoney() -- API call
    local job = xPlayer.getJob() -- Another API call
end)
-- QBCore
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBCore.Functions.GetPlayerData() -- API call
    local money = PlayerData.money.cash -- More processing
end)
```

### **The Solution**

```lua
-- After: One universal event + automatic caching
lib.events.on('player:loaded', function(player)
    -- Data is automatically cached for ultra-fast access
    print(player.citizenid)  -- Always normalized structure
    print(player.money.cash) -- Works regardless of framework
    print(player.job.name)   -- Consistent data format
end)

-- Later access is lightning fast (uses ox_lib native cache)
local job = lib.core.getJob() -- Instant - uses cache.job
local money = lib.core.getMoney('cash') -- Instant - uses cache.money
local citizenId = lib.core.getIdentifier() -- Instant - uses cache.citizenid
```

### **Available Events**

- `player:loaded` - Player connected/loaded (automatically caches all player data)
- `player:logout` - Player disconnected (automatically clears cache)
- `player:job:changed` - Job change events (automatically updates job cache)
- `player:money:changed` - Money change events (automatically updates money cache)
- `vehicle:spawned` - Vehicle spawn events
- `player:item:add` - Item addition events (automatically updates money cache)
- `player:item:remove` - Item removal events (automatically updates money cache)

### **Native Cache Integration**

The events system integrates seamlessly with ox_lib's native cache system:

```lua
-- Data is automatically cached when events are triggered
lib.events.on('player:loaded', function(player)
    -- Player data is now cached automatically in ox_lib's cache system
    -- All subsequent API calls will be lightning fast
end)

-- Direct access to ox_lib cache (advanced usage)
local playerData = cache.playerData
local job = cache.job
local money = cache.money
local citizenId = cache.citizenid

-- Framework wrappers automatically use cache when available
local money = lib.core:getMoney('cash') -- Uses cache.money if available, falls back to API
local job = lib.core:getJob() -- Uses cache.job if available, instantly fast
local identifier = lib.core.getIdentifier() -- Uses cache.citizenid, cache-first approach

-- Higher-level cache access through events API (optional)
local cachedPlayer = lib.events.cache.getPlayer()
local cachedJob = lib.events.cache.getJob()
local cachedMoney = lib.events.cache.getMoney('cash')
```

### **Cache Benefits**

- **⚡ Performance** - No repeated API calls to framework
- **🔄 Auto-sync** - Cache updates automatically on events
- **💾 Persistence** - Data stays cached until player logout
- **🛡️ Fallback** - Always falls back to framework API if cache is empty
- **🎯 Smart Updates** - Only updates cache when data actually changes
- **🧩 Native Integration** - Uses ox_lib's existing cache system (`cache.playerId`, `cache.ped`, etc.)

### **Bidirectional Communication**

```lua
-- Client to Server
lib.events.emitServer('custom:action', data)

-- Server to Client
lib.events.emitClient(source, 'notification', message)

-- Broadcast to All Clients
lib.events.emitAllClients('server:announcement', info)
```

---

## 🔧 **Syntax Differences Between Client and Server**

**Important:** There are key syntax differences when calling wrapper methods:

### **Client-Side (uses colon `:` for methods)**

```lua
-- Client uses colon syntax for methods
local player = lib.core:getPlayerData() -- Uses colon :
local money = lib.core:getMoney('cash') -- Uses colon :
local job = lib.core:getJob() -- Uses colon :
```

### **Server-Side (uses dot `.` for methods)**

```lua
-- Server uses dot syntax for methods
local player = lib.core.getPlayerData(source) -- Uses dot .
local money = lib.core.getMoney(source, 'cash') -- Uses dot .
local job = lib.core.getJob(source) -- Uses dot .
```

This difference exists because:

- **Client**: Methods operate on the current player (implicit `self`)
- **Server**: Methods require a player `source` parameter (explicit target)

---

## Example Usage (EXPERIMENTAL)

```lua
-- ⚠️ EXPERIMENTAL CODE - DO NOT USE IN PRODUCTION

-- Universal player access (works with ESX/QBCore/ox_core automatically)
local player = lib.core:getPlayerData() -- CLIENT: Uses colon : (cache.playerData when available)
-- local player = lib.core.getPlayerData(source) -- SERVER: Uses dot . with source parameter
print(player.citizenid)  -- Works regardless of framework
print(player.money.cash) -- Normalized money structure

-- Universal event handling (NEW!)
lib.events.on('player:loaded', function(player)
    -- This automatically caches all player data in ox_lib's cache system
    lib.notify({
        title = 'Welcome!',
        description = 'Hello ' .. player.charinfo.firstname,
        type = 'success'
    })
end)

-- Listen for job changes (works on all frameworks)
lib.events.on('player:job:changed', function(player, oldJob, newJob)
    print('Job changed from', oldJob.name, 'to', newJob.name)
    -- Job cache is automatically updated (cache.job)
end)

-- Ultra-fast subsequent access (uses ox_lib native cache)
local currentJob = lib.core:getJob() -- CLIENT: Instant response from cache.job
local currentMoney = lib.core:getMoney('cash') -- CLIENT: Instant response from cache.money
local isLoaded = lib.core:isPlayerLoaded() -- CLIENT: Instant response from cache.citizenid
-- SERVER equivalents:
-- local currentJob = lib.core.getJob(source)
-- local currentMoney = lib.core.getMoney(source, 'cash')
-- local isLoaded = lib.core.isPlayerLoaded(source)

-- Direct cache access (native ox_lib way)
local directJobAccess = cache.job and cache.job.name
local directMoneyAccess = cache.money and cache.money.cash
local directCitizenId = cache.citizenid

-- Manual cache operations (advanced usage)
lib.core.invalidateCache() -- Force cache refresh
local cachedData = lib.events.cache.getPlayer() -- Convenience access

-- Universal inventory (works with any inventory system)
lib.inventory.addItem(source, 'bread', 5)
local count = lib.inventory.getItemCount(source, 'bread')

-- Shared enums for consistency
SetVehicleDoorOpen(vehicle, lib.enums.vehicles.DOORS.FRONT_LEFT, false, false)
TaskStartScenarioInPlace(ped, lib.enums.tasks.TASKS.MECHANIC, 0, true)

-- Universal notifications with predefined styles
lib.notify({
    title = 'Success',
    type = lib.enums.notifications.TYPES.SUCCESS,
    icon = lib.enums.notifications.ICONS.MONEY,
    duration = lib.enums.notifications.DURATION.MEDIUM
})
```

### **Server-Side Events Example**

```lua
-- Server-side event handling
lib.events.on('player:connected', function(player)
    print('Player connected:', player.citizenid)

    -- Send welcome message to client
    lib.events.emitClient(player.source, 'welcome:message', {
        title = 'Welcome to the Server!',
        message = 'Hello ' .. player.charinfo.firstname
    })
end)

-- Listen for money transactions
lib.events.on('player:money:add', function(player, account, amount, reason)
    -- Log all money transactions automatically
    print('Money added:', player.citizenid, account, amount, reason)
end)
```

### **Client-Side Events Example**

```lua
-- Client-side event handling
lib.events.on('player:job:changed', function(player, oldJob, newJob)
    -- Show notification when job changes
    lib.notify({
        title = 'Job Updated',
        description = 'You are now a ' .. newJob.label,
        type = 'info',
        duration = 5000
    })

    -- Job cache is automatically updated here (cache.job = newJob)
    -- Subsequent calls to lib.core.getJob() will be instant
end)

-- Send custom events to server
lib.events.emitServer('player:action', {
    action = 'purchase',
    item = 'bread',
    amount = 5
})
```

---

## 🎭 **NEW: Advanced Animation System & NetworkScenes**

ox_lib Extended introduces two powerful animation systems that revolutionize how animations and cinematic scenes work in FiveM.

### **🎮 Advanced Animation System**

The advanced animation system extends the basic `lib.playAnim()` with props, callbacks, facial animations, and intelligent management.

#### **Basic vs Advanced Comparison**

```lua
-- Before: Basic animations
lib.playAnim(ped, "mp_player_intdrink", "loop_bottle")
-- Result: Simple animation, no props, no callbacks

-- After: Advanced animations with everything included
local animId = lib.playAnimAdvanced(ped, "drinking", {
    onStart = function() print("Started drinking") end,
    onComplete = function() print("Finished drinking") end
})
-- Result: Animation + beer bottle prop + callbacks + auto-cleanup
```

#### **Available Animation Presets**

```lua
-- Built-in presets with props and perfect positioning
lib.playAnimAdvanced(ped, "drinking")      -- Beer bottle automatically attached
lib.playAnimAdvanced(ped, "phone_call")    -- Phone prop with correct positioning
lib.playAnimAdvanced(ped, "smoking")       -- Cigarette with realistic attachment
lib.playAnimAdvanced(ped, "clipboard")     -- Clipboard for business/work scenarios
lib.playAnimAdvanced(ped, "coffee")        -- Coffee cup for casual interactions
lib.playAnimAdvanced(ped, "notepad")       -- Notepad for writing/notes
lib.playAnimAdvanced(ped, "tablet")        -- Tablet for modern tech usage
lib.playAnimAdvanced(ped, "newspaper")     -- Newspaper for reading scenarios
```

#### **Custom Animation Configurations**

```lua
-- Create custom animations with props and callbacks
local animId = lib.playAnimAdvanced(ped, {
    dict = "mp_player_intdrink",
    name = "loop_bottle",
    flags = 49,
    duration = 10000,

    -- Auto-spawned props with precise attachment
    props = {
        {
            model = `prop_beer_bottle`,
            bone = 18905,  -- Right hand
            offset = vec3(0.12, 0.028, 0.001),
            rotation = vec3(5.0, 5.0, -180.5)
        }
    },

    -- Facial animations for more realism
    facial = {
        dict = "facials@mood",
        name = "happy"
    },

    -- Complete callback system
    callbacks = {
        onStart = function(ped, animId)
            print("Animation started:", animId)
        end,
        onProgress = function(ped, animId, progress)
            if progress > 0.5 then
                -- Do something at 50% completion
            end
        end,
        onComplete = function(ped, animId)
            print("Animation completed")
            -- Props are automatically cleaned up
        end,
        onInterrupt = function(ped, animId, reason)
            print("Animation interrupted:", reason)
        end
    }
})

-- Control animations
lib.stopAnim(animId)                    -- Stop specific animation
lib.stopAllAnims(ped)                  -- Stop all animations on ped
local isPlaying = lib.isPlayingAnim(ped) -- Check if any animation is playing
```

#### **Animation Sequences & Network Sync**

```lua
-- Play animations in sequence automatically
lib.playAnimSequence(ped, {
    "drinking",           -- First: drinking animation
    "phone_call",         -- Then: phone call
    "smoking"             -- Finally: smoking
}, {
    loop = false,
    callbacks = {
        onComplete = function() print("All animations completed") end
    }
})

-- Network synchronized animations for multiple players
lib.playNetworkAnim({
    [ped1] = "drinking",
    [ped2] = "smoking",
    [vehicle] = {
        dict = "anim@heists@heist_corona@team_idles@male_a",
        name = "idle"
    }
}, {
    syncToAll = true,  -- Sync to all players in range
    authority = source -- Server controls the timing
})
```

### **🎬 NetworkScenes - Cinematic Scene System**

NetworkScenes handle complex, multi-entity synchronized scenes with cameras, perfect for heists, cutscenes, and interactive scenarios.

#### **Why NetworkScenes?**

```lua
-- Before: Complex manual scene setup
local scene = NetworkCreateSynchronisedScene(x, y, z, ...)
NetworkAddPedToSynchronisedScene(ped, scene, dict, anim, ...)
NetworkAddEntityToSynchronisedScene(prop, scene, dict, anim, ...)
NetworkAddSynchronisedSceneCamera(scene, dict, cam)
NetworkStartSynchronisedScene(scene)
-- Manually track phases, cleanup, etc.
-- Result: 50+ lines of complex code prone to errors

-- After: Simple, powerful scene system
lib.playScene({
    position = keypadCoords,
    entities = {
        {entity = ped, type = "ped", animDict = "dict", animName = "hack"},
        {entity = usb, type = "object", animDict = "dict", animName = "usb_hack"}
    },
    camera = {
        animDict = "dict",
        animName = "hack_camera",
        gracefulExit = true
    },
    callbacks = {
        onComplete = function() print("Hacking complete!") end
    }
})
-- Result: 15 lines, automatic management, no cleanup needed
```

#### **Simple Scene Examples**

```lua
-- Basic scene with automatic camera
local sceneId = lib.playScene({
    position = GetEntityCoords(PlayerPedId()),
    entities = {
        {
            entity = PlayerPedId(),
            type = "ped",
            animDict = "anim@scripted@heist@ig25_beach@male@",
            animName = "action"
        }
    },
    camera = {
        animDict = "anim@scripted@heist@ig25_beach@male@",
        animName = "action_camera",
        gracefulExit = true,
        exitBlendTime = 2.0
    }
})

-- Multi-entity scene (heist style)
lib.playScene({
    position = drillLocation,
    entities = {
        {entity = ped, type = "ped", animDict = "heist_drill", animName = "intro"},
        {entity = drill, type = "object", animDict = "heist_drill", animName = "intro_drill"},
        {entity = bag, type = "object", animDict = "heist_drill", animName = "intro_bag"}
    },
    holdLastFrame = true,  -- Hold at the end for smooth transitions
    callbacks = {
        onStart = function() print("Drilling started") end,
        onComplete = function() print("Ready for next phase") end
    }
})
```

#### **Complex Scene Sequences**

```lua
-- Multi-phase scenes (like Cayo Perico gold grabbing)
lib.playSceneSequence({
    -- Phase 1: Entry
    {
        config = {
            position = goldLocation,
            holdLastFrame = true,
            entities = {
                {entity = ped, type = "ped", animDict = "gold_grab", animName = "enter"},
                {entity = bag, type = "object", animDict = "gold_grab", animName = "enter_bag"}
            }
        },
        waitForCompletion = true
    },

    -- Phase 2: Grabbing (with delay)
    {
        config = {
            position = goldLocation,
            entities = {
                {entity = ped, type = "ped", animDict = "gold_grab", animName = "grab"},
                {entity = bag, type = "object", animDict = "gold_grab", animName = "grab_bag"},
                {entity = gold, type = "object", animDict = "gold_grab", animName = "grab_gold"}
            }
        },
        delay = 1000  -- 1 second delay between phases
    },

    -- Phase 3: Exit
    {
        config = {
            position = goldLocation,
            entities = {
                {entity = ped, type = "ped", animDict = "gold_grab", animName = "exit"},
                {entity = bag, type = "object", animDict = "gold_grab", animName = "exit_bag"}
            }
        },
        condition = function()
            return grabbingComplete  -- Only proceed if condition is met
        end
    }
}, {
    onComplete = function()
        DeleteObject(gold)  -- Cleanup after sequence
        print("Gold grabbing sequence complete!")
    end
})
```

#### **Scene Control & Monitoring**

```lua
-- Create scene for manual control
local sceneId = lib.createScene({
    position = coords,
    entities = {...}
})

-- Manual control
lib.startScene(sceneId)
lib.pauseScene(sceneId)          -- Pause the scene
lib.resumeScene(sceneId, 1.5)    -- Resume at 1.5x speed
lib.setSceneRate(sceneId, 0.5)   -- Slow motion effect

-- Monitor scene progress
local phase = lib.getScenePhase(sceneId)      -- 0.0 to 1.0
local state = lib.getSceneState(sceneId)      -- "running", "paused", etc.
local isRunning = lib.isSceneRunning(sceneId) -- boolean

-- Stop when needed
lib.stopScene(sceneId, "player_died")
```

#### **Scene Presets**

```lua
-- Register custom scene presets
lib.registerScenePreset("bank_hack", {
    mode = "sequence",
    entities = {},  -- Will be filled when used
    camera = {
        animDict = "anim_heist@hs3f@ig1_hack_keypad@male@",
        animName = "action_camera",
        gracefulExit = true
    }
})

-- Use presets with custom data
lib.playScenePreset("bank_hack", {
    position = keypadCoords,
    entities = {
        {entity = PlayerPedId(), type = "ped", animDict = "hack_dict", animName = "hack_anim"}
    }
})
```

---

## 🎵 **NEW: Streaming Audio API**

ox_lib Extended introduces a powerful **Streaming Audio API** that provides native audio streaming functionality for custom audio files (.awc) and GTA V sounds through the game's streaming system.

### **Credits**

This implementation is **inspired by and compatible with mana_audio** by **Manason**.

**Credits to:**

- **Manason** (creator of mana_audio)
- PrinceAlbert, Demi-Automatic, ChatDisabled, Joe Szymkowicz, and Zoo

**Original repository:** https://github.com/Manason/mana_audio

### **The Problem It Solves**

```lua
-- Before: No native streaming audio support in ox_lib
-- Had to use separate resources like interact-sound or mana_audio
-- Multiple dependencies and inconsistent APIs

-- After: Native streaming audio integrated into ox_lib
lib.audio:playStreamingSound({
    audioBank = 'custom_sounds',     -- Your custom .awc file
    audioName = 'my_custom_sound',   -- Custom audio from your files
    audioRef = 'CUSTOM_SOUNDS'       -- Custom audio reference
})
```

### **Key Features**

- ✅ **Custom Audio Streaming** - Stream custom .awc audio files natively
- ✅ **mana_audio Compatible** - Easy migration with similar API
- ✅ **3D Positional Audio** - Entity and coordinate-based audio
- ✅ **Range Control** - Specify hearing range for coordinate-based audio
- ✅ **Random Selection** - Array support for random audio selection
- ✅ **Automatic Management** - Auto-load and cleanup of audio banks
- ✅ **Server Control** - Play audio from server to specific/all clients
- ✅ **Native Integration** - Seamlessly integrated with ox_lib's audio system

### **Client-Side Functions**

```lua
-- Play streaming sound (2D)
local audioId = lib.audio:playStreamingSound({
    audioBank = 'custom_sounds',           -- Custom .awc file
    audioName = 'notification_sound',      -- Audio defined in .dat54.rel
    audioRef = 'CUSTOM_SOUNDS'             -- Custom reference
})

-- Play sound from entity (3D)
lib.audio:playStreamingSoundFromEntity({
    audioBank = 'vehicle_sounds',
    audioName = 'engine_custom',
    audioRef = 'VEHICLE_CUSTOM',
    entity = PlayerPedId()
})

-- Play sound from coordinates (3D with range)
lib.audio:playStreamingSoundFromCoords({
    audioBank = 'ambient_sounds',
    audioName = 'forest_ambiance',
    audioRef = 'AMBIENT_CUSTOM',
    coords = vector3(100, 200, 30),
    range = 25.0
})

-- Random sound selection
lib.audio:playStreamingSound({
    audioBank = 'notification_sounds',
    audioName = {'success', 'warning', 'error'}, -- Randomly picks one
    audioRef = 'NOTIFICATION_SOUNDS'
})
```

### **Server-Side Functions**

```lua
-- Play to all clients
lib.streamingAudio.playSound(-1, {
    audioBank = 'server_sounds',
    audioName = 'announcement',
    audioRef = 'SERVER_SOUNDS'
})

-- Play to specific client
lib.streamingAudio.playSound(playerId, {
    audioBank = 'personal_sounds',
    audioName = 'level_up',
    audioRef = 'PERSONAL_SOUNDS'
})

-- Play from entity to all clients
lib.streamingAudio.playSoundFromEntity({
    audioBank = 'event_sounds',
    audioName = 'explosion',
    audioRef = 'EVENT_SOUNDS',
    entity = GetPlayerPed(playerId)
})

-- Play from coordinates to clients in range
lib.streamingAudio.playSoundFromCoords({
    audioBank = 'location_sounds',
    audioName = 'alarm',
    audioRef = 'LOCATION_SOUNDS',
    coords = vector3(100, 200, 30),
    range = 50.0
})
```

### **Audio Bank Management**

```lua
-- Load custom audio bank
local success = lib.audio:requestAudioBank('custom_sounds', 15000)
if success then
    -- Use the audio bank
    lib.audio:playStreamingSound({
        audioBank = 'custom_sounds',
        audioName = 'my_sound',
        audioRef = 'CUSTOM_SOUNDS'
    })

    -- Release when done (automatic cleanup also available)
    lib.audio:releaseAudioBank('custom_sounds')
end
```

### **Custom Audio File Structure**

For custom audio files, organize your resource like this:

```
your_resource/
├── audiodirectory/
│   ├── custom_sounds.awc          # Your audio container
│   └── notification_sounds.awc    # Another audio container
├── data/
│   ├── custom_sounds.dat54.rel    # SimpleSounds definitions
│   └── notification_sounds.dat54.rel
├── fxmanifest.lua
├── client.lua
└── server.lua
```

Add to your `fxmanifest.lua`:

```lua
-- Audio files
files {
    'audiodirectory/*.awc',
    'data/*.dat54.rel'
}

-- Streaming configuration
data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data'
```

### **Migration from mana_audio**

```lua
-- Before (mana_audio)
exports.mana_audio:PlaySound({
    audioBank = 'myAudioBank',
    audioName = 'myAudioName',
    audioRef = 'myAudioRef'
})

-- After (ox_lib)
lib.audio:playStreamingSound({
    audioBank = 'myAudioBank',
    audioName = 'myAudioName',
    audioRef = 'myAudioRef'
})
```

### **Advanced Examples**

```lua
-- Notification system with custom sounds
local function playNotificationSound(type)
    local sounds = {
        success = 'success_chime',
        error = 'error_buzz',
        warning = 'warning_beep'
    }

    lib.audio:playStreamingSound({
        audioBank = 'notification_sounds',
        audioName = sounds[type],
        audioRef = 'NOTIFICATION_SOUNDS'
    })
end

-- Server event system
RegisterCommand('server_announcement', function(source)
    lib.streamingAudio.playSound(-1, {
        audioBank = 'server_events',
        audioName = 'announcement_horn',
        audioRef = 'SERVER_EVENTS'
    })
end)
```

### **🎯 Key Advantages**

#### **Animation System**

- ✅ **Zero Cleanup** - Props, timers, and resources cleaned automatically
- ✅ **Preset Library** - 8+ ready-to-use animations with perfect props
- ✅ **Network Sync** - Multi-player animation coordination
- ✅ **Sequence Support** - Chain animations automatically
- ✅ **Full Callbacks** - Complete lifecycle event handling
- ✅ **Facial Animations** - Synchronized facial expressions

#### **NetworkScenes**

- ✅ **Multi-Entity** - Coordinate multiple peds, objects, and vehicles
- ✅ **Camera Integration** - Cinematic camera work with graceful exits
- ✅ **Phase Monitoring** - Real-time progress tracking
- ✅ **Sequence Support** - Multi-phase scenes with conditions and delays
- ✅ **Error Handling** - Robust validation and automatic recovery
- ✅ **Memory Management** - No memory leaks or orphaned entities

### **🚀 Performance Benefits**

- **Lazy Loading** - Systems only load when first used
- **Resource Pooling** - Efficient reuse of animation dictionaries
- **Automatic Cleanup** - No memory leaks or performance degradation
- **Optimized Callbacks** - Event system designed for high frequency updates
- **Cache Integration** - Leverages ox_lib's native cache system

---

## Installation (FOR TESTING ONLY)

1. **⚠️ BACKUP YOUR SERVER FIRST ⚠️**
2. Replace your existing ox_lib with this version
3. Restart your server
4. Test in a **development environment only**

---

## 📊 **Normalized Data Structure**

All player data is normalized across frameworks:

```lua
{
    source = 1,
    citizenid = "ABC12345",
    charinfo = {
        firstname = "John",
        lastname = "Doe",
        phone = "555-0123"
    },
    money = {
        cash = 5000,
        bank = 25000
    },
    job = {
        name = "police",
        label = "Police Officer",
        grade = 2
    }
}
```

---

## 🚀 **Performance Improvements**

### **Before (Traditional Approach)**

```lua
-- Every call hits the framework API
local job1 = ESX.GetPlayerData().job.name      -- API call
local job2 = ESX.GetPlayerData().job.name      -- Another API call
local money = ESX.GetPlayerData().money        -- Yet another API call
-- Result: Multiple expensive API calls, poor performance
```

### **After (Cache-Optimized with ox_lib native cache)**

```lua
-- First call loads and caches data
lib.events.on('player:loaded', function(player)
    -- All data is now cached automatically in ox_lib's cache system
end)

-- Subsequent calls are lightning fast using native cache
local job1 = lib.core:getJob()        -- CLIENT: Cache hit - instant (uses cache.job)
local job2 = lib.core:getJob()        -- CLIENT: Cache hit - instant (uses cache.job)
local money = lib.core:getMoney()     -- CLIENT: Cache hit - instant (uses cache.money)
-- SERVER equivalents: lib.core.getJob(source), lib.core.getMoney(source)
-- Or direct access: cache.job.name, cache.money.cash, cache.citizenid
-- Result: Up to 100x faster response times
```

---

## Known Issues

- **Untested with all framework versions**
- **Potential compatibility issues**
- **Performance impact unknown**
- **Memory usage not optimized**
- **Error handling incomplete**
- **Events system requires thorough testing**
- **Cache system is experimental**

---

## 📜 Open Letter to Overextended, CommunityOX, and the FiveM Community

First of all, let's be honest: the work done by **Overextended** and **CommunityOX** has raised the bar in FiveM development. Your resources are impressive, your code is sharp, and there's no doubt you're some of the most talented developers in this space.

That said — and i say this with respect — talent doesn't excuse toxicity.

Lately, the way some of the leadership in these groups has handled community interactions has created a negative atmosphere. There's been gatekeeping, passive aggression, and a general vibe of "us vs them" that's making FiveM feel smaller and more divided than it should be.

We also understand the frustration that comes from seeing your work used without proper respect for the **GPL-3.0** license. That kind of misuse is wrong and unfair — no question about it. But those situations should be addressed through the right channels, with clarity and professionalism, not through public hostility or exclusion.

What's even more concerning is the way some Discord groups tied to these communities are being used almost like echo chambers — where negativity, personal attacks, and hostile behavior towards others are encouraged, even normalized. Turning followers into a tool for spreading resentment doesn't help protect your work — it just spreads more harm.

This platform was never meant to be controlled by one mindset or one circle. It thrives because people are free to build, share, and explore different ideas without fear of being dismissed or talked down to. When a few voices try to dominate or exclude others, the whole community suffers.

Im not here to cancel anyone. This isn't an attack. It's a reminder that being a good developer is only part of the picture — how we treat people matters just as much.

FiveM deserves to be a place where people can collaborate, not compete for status. Where knowledge is shared, not hoarded. And where differences spark conversation, not conflict.

So here's the ask: take a step back. Let's shift the tone. Let's make FiveM about creating, learning, and growing — together.

**There's enough room here for everyone.**

**Let's make this community better, not smaller.**

---

## 🎯 **Advantages of ox_lib Extended**

1. **Code Portability** - Write once, run on any framework
2. **Simplified Development** - Single API to learn instead of multiple
3. **Easy Migration** - Switch frameworks without rewriting code
4. **Consistent Data** - Normalized structures across all systems
5. **Better Maintainability** - Less framework-specific dependencies
6. **Future-Proof** - New frameworks can be added via wrappers
7. **⚡ Ultra Performance** - Cache-first approach with up to 100x speed improvements
8. **🧠 Smart Caching** - Automatic cache management with zero configuration
9. **🧩 Native Integration** - Uses ox_lib's existing cache system seamlessly

---

---

## Original ox_lib

This is based on the original ox_lib by Overextended and CommunityOX:

- Repository: https://github.com/overextended/ox_lib
- Documentation: https://overextended.dev/ox_lib

---

## Disclaimer

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.**

**USE THIS EXPERIMENTAL CODE AT YOUR OWN RISK.**

![](https://img.shields.io/github/downloads/communityox/ox_lib/total?logo=github)
![](https://img.shields.io/github/downloads/communityox/ox_lib/latest/total?logo=github)
![](https://img.shields.io/github/contributors/communityox/ox_lib?logo=github)
![](https://img.shields.io/github/v/release/communityox/ox_lib?logo=github)

For guidelines to contributing to the project, and to see our Contributor License Agreement, see [CONTRIBUTING.md](./CONTRIBUTING.md)

For additional legal notices, refer to [NOTICE.md](./NOTICE.md).

## 📚 Documentation

https://coxdocs.dev/ox_lib

## 💾 Download

https://github.com/communityox/ox_lib/releases/latest/download/ox_lib.zip

## 📦 npm package

https://www.npmjs.com/package/@communityox/ox_lib

## 🖥️ Lua Language Server

- Install [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) to ease development with annotations, type checking, diagnostics, and more.
- Install [CfxLua IntelliSense](https://marketplace.visualstudio.com/items?itemName=communityox.cfxlua-vscode-cox) to add natives and cfxlua runtime declarations to LLS.
- You can load ox_lib into your global development environment by modifying workspace/user settings "Lua.workspace.library" with the resource path.
  - e.g. "c:/fxserver/resources/ox_lib"

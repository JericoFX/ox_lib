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
- `lib.enums` - Shared enumerations and constants
- `lib.events` - **NEW!** Universal event system with automatic caching
- `lib.npc` - **NEW!** Advanced NPC system with intelligent AI and behaviors

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

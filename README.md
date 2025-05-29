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
- `lib.events` - **NEW!** Universal event system across frameworks

### 🌐 **Framework Wrappers**

- `lib.core` - Universal framework wrapper (ESX/QBCore/ox_core)
- `lib.inventory` - Universal inventory wrapper (ox_inventory/qb-inventory/qs-inventory)
- `lib.dispatch` - Universal dispatch wrapper (cd_dispatch/ps-dispatch)
- `lib.phone` - Universal phone wrapper (qb-phone/qs-smartphone/etc)
- `lib.banking` - Universal banking wrapper (okokBanking/qb-banking/etc)

### ✨ **Key Features**

- **Auto-detection** of installed frameworks/systems
- **Normalized data structures** across different frameworks
- **Universal event system** with automatic framework mapping
- **Singleton pattern** for direct access
- **Lazy loading** for performance
- **Backward compatibility** with existing ox_lib imports

---

## 🎯 **NEW: Universal Events System**

The most powerful feature of ox_lib Extended is the **Universal Events System** that provides a consistent API for handling events across different frameworks.

### **The Problem It Solves**

```lua
-- Before: Framework-specific events
-- ESX
AddEventHandler('esx:playerLoaded', function(xPlayer) end)
-- QBCore
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() end)
-- ox_core
AddEventHandler('ox:playerLoaded', function(player) end)
```

### **The Solution**

```lua
-- After: One universal event for all frameworks
lib.events.on('player:loaded', function(player)
    print(player.citizenid)  -- Always normalized structure
    print(player.money.cash) -- Works regardless of framework
    print(player.job.name)   -- Consistent data format
end)
```

### **Available Events**

- `player:loaded` - Player connected/loaded
- `player:logout` - Player disconnected

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

## Example Usage (EXPERIMENTAL)

```lua
-- ⚠️ EXPERIMENTAL CODE - DO NOT USE IN PRODUCTION

-- Universal player access (works with ESX/QBCore/ox_core automatically)
local player = lib.core.getPlayer(source)
print(player.citizenid)  -- Works regardless of framework
print(player.money.cash) -- Normalized money structure

-- Universal event handling (NEW!)
lib.events.on('player:loaded', function(player)
    lib.notify({
        title = 'Welcome!',
        description = 'Hello ' .. player.charinfo.firstname,
        type = 'success'
    })
end)

-- Listen for job changes (works on all frameworks)
lib.events.on('player:job:changed', function(player, oldJob, newJob)
    print('Job changed from', oldJob.name, 'to', newJob.name)
end)

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

## Known Issues

- **Untested with all framework versions**
- **Potential compatibility issues**
- **Performance impact unknown**
- **Memory usage not optimized**
- **Error handling incomplete**
- **Events system requires thorough testing**

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

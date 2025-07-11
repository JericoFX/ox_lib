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

## Enhanced Module System

This version includes an improved module loading system with:

- **State Management**: Modules now have defined states (UNLOADED, LOADING, LOADED, ERROR) to prevent circular dependencies
- **Improved Error Handling**: All module executions use pcall for safer error handling
- **Enhanced Logging**: New logging system with configurable levels (DEBUG, INFO, WARN, ERROR, FATAL)
- **Optimized Cache**: Better memory management with timeout handling and event deduplication
- **Performance Improvements**: Batch processing of cache callbacks and lazy loading optimizations

### Configuration

Set the logging level with the convar:
```
set ox:loglevel "info"  # Options: debug, info, warn, error, fatal
```

## What is this?

This is an **experimental extension** of the original ox_lib that adds:

### 🔧 **Universal API System**

- `lib.player` - Player management functions
- `lib.task` - Task and animation utilities
- `lib.vehicle` - Vehicle manipulation tools
- `lib.enums` - **NEW!** Comprehensive shared enumerations and constants
- `lib.events` - **NEW!** Universal event system with automatic caching
- `lib.hooks` - **NEW!** Server-side secure hook system for intercepting operations
- `lib.npc` - **NEW!** Advanced NPC system with intelligent AI and behaviors
- `lib.blips` - **NEW!** Enhanced blip management system with object-oriented approach
- `lib.discord` - **NEW!** Instance-based Discord webhook integration system
- `lib.dui` - **ENHANCED!** Direct-rendered UI system with mouse interaction and callback support
- `lib.achievements` - Lazy-loaded achievements system | not tested

### 🌐 **Framework Wrappers**

- `lib.core` - Universal framework wrapper (ESX/QBCore/ox_core)
- `lib.inventory` - **ENHANCED!** Universal inventory wrapper with ox_inventory hooks support (ox_inventory/qb-inventory/qs-inventory)
- `lib.dispatch` - Universal dispatch wrapper (cd_dispatch/ps-dispatch/qs-dispatch/origen_police/rcore_dispatch)
- `lib.fuel` - Universal fuel wrapper (cdn-fuel/ox_fuel/ps-fuel/LegacyFuel/lc_fuel/lj-fuel)
- `lib.phone` - Universal phone wrapper (qb-phone/qs-smartphone/lb-phone/renewed-phone/high_phone)
- `lib.banking` - Universal banking wrapper (okokBanking/qb-banking/etc)
- `lib.clothing` - **NEW!** Universal clothing wrapper (illenium-appearance/qb-clothing/fivem-appearance/bostra_appearance/esx_skin/clothing)
- `lib.tickets` - **NEW!** Advanced ticket system with player reporting and staff management
- `lib.shops` - **NEW!** Universal shop wrapper with ox_inventory hooks integration

### 🆕 **Unified Core API Aliases**

Neutral method names available on both client (class, colon `:`) and server (table, dot `.`) wrappers:

**Client (use colon)**

- `lib.core:player()`
- `lib.core:role()` / `:roleGrade()` / `:roleLabel()`
- `lib.core:funds(account?)`
- `lib.core:id()`
- `lib.core:isReady()`
- `lib.core:guild()` / `:guildGrade()` / `:guildLabel()`
- `lib.core:meta(key?)` / `:setMeta(key, value)`
- `lib.core:notify(message, type?, duration?)`

**Server (use dot)**

- `lib.core.player(source)`
- `lib.core.players()`
- `lib.core.walletAdd(source, amount, account?)`
- `lib.core.walletRemove(source, amount, account?)`
- `lib.core.wallet(source, account?)`
- `lib.core.role(source)` / `roleGrade(source)` / `roleSet(source, job, grade?)`
- `lib.core.guild(source)` / `guildSet(source, gang, grade?)`

These aliases complement the existing method names (`getJob`, `addMoney`, etc.) and provide a framework-neutral nomenclature without breaking backward compatibility.

### ✨ **Key Features**

- **Auto-detection** of installed frameworks/systems
- **Normalized data structures** across different frameworks
- **Universal event system** with automatic framework mapping
- **Intelligent caching** using ox_lib's native cache system
- **Advanced NPC system** with AI, memory, and complex behaviors
- **Singleton pattern** for direct access
- **Lazy loading** for performance
- **Backward compatibility** with existing ox_lib imports
- **Universal API** for seamless integration across different frameworks and systems

---

## 👕 **NEW: Universal Clothing Wrapper System**

The **Universal Clothing Wrapper System** provides a consistent API across all popular FiveM clothing systems, allowing seamless integration regardless of which clothing resource you're using.

### **Supported Systems**

- **illenium-appearance** - Advanced appearance system with tattoos, UI from ox_lib
- **bostra_appearance** - Enhanced fork of illenium-appearance with camera controls
- **fivem-appearance** - Original appearance system with configuration options
- **qb-clothing** - QBCore's clothing system with component-based approach
- **esx_skin + skinchanger** - Classic ESX skin system
- **clothing** - Modern clothing system with items support

### **Auto-Detection**

The wrapper automatically detects which clothing system is installed and uses the appropriate implementation:

```lua
-- Works with any supported clothing system
local clothing = lib.clothing

-- Open clothing menu (universal across all systems)
clothing:openClothing()

-- Save and load outfits
clothing:saveOutfit('work_outfit', outfit_data)
clothing:loadOutfit('work_outfit')

-- Get/set player appearance
local appearance = clothing:getPlayerClothing()
clothing:setPlayerClothing(appearance)
```

### **Universal Methods**

**Core Methods:**

- `:openClothing(config?)` - Open clothing customization menu
- `:openOutfits()` - Open saved outfits menu
- `:saveOutfit(name, outfit?)` - Save current or specified outfit
- `:loadOutfit(name)` - Load a saved outfit
- `:getPlayerClothing()` - Get current player appearance
- `:setPlayerClothing(appearance)` - Set player appearance

**System-Specific Methods:**

- `:openShop(shopType)` - Open clothing/barber/tattoo shop
- `:openPedMenu()` - Open ped customization (illenium/bostra)
- `:takeOffClothing(component)` - Remove clothing item (clothing system)
- `:isWearing(index)` - Check if wearing specific item (clothing system)
- `:changeSkin(skinData)` - Change skin component (esx_skin)

### **Example Usage**

```lua
-- Basic clothing operations
RegisterCommand('outfit', function()
    local clothing = lib.clothing

    -- Open clothing menu
    clothing:openClothing()
end)

-- Save current outfit
RegisterCommand('saveoutfit', function(source, args)
    local clothing = lib.clothing
    local outfitName = args[1] or 'default'

    clothing:saveOutfit(outfitName)
    lib.notify({
        title = 'Outfit Saved',
        description = 'Outfit "' .. outfitName .. '" saved successfully',
        type = 'success'
    })
end)

-- Advanced usage with appearance data
RegisterNetEvent('clothing:loadWorkOutfit')
AddEventHandler('clothing:loadWorkOutfit', function()
    local clothing = lib.clothing

    -- Get current appearance for backup
    local currentAppearance = clothing:getPlayerClothing()

    -- Load work outfit
    clothing:loadOutfit('work_uniform')

    -- Store civilian clothes for later
    TriggerServerEvent('clothing:storeCivilianClothes', currentAppearance)
end)
```

---

## 💰 **NEW: Universal Banking Wrapper System**

The **Universal Banking Wrapper System** provides a consistent API across all popular FiveM banking systems, allowing seamless integration regardless of which banking resource you're using.

### **Supported Systems**

- **okokBanking** - Advanced banking system with multiple account types and transaction history
- **qb-banking** - QBCore's banking system with checking and savings accounts
- **Renewed-Banking** - Modern banking system with enhanced features
- **pickle_banking** - Lightweight banking system with essential features
- **esx_atm** - Classic ESX banking integration using core wallet functions

### **Auto-Detection**

The wrapper automatically detects which banking system is installed and uses the appropriate implementation:

```lua
-- Works with any supported banking system
local banking = lib.banking

-- Open banking interface (universal across all systems)
banking:openBanking()

-- Check if banking interface is open
local isOpen = banking:isBankingOpen()

-- Close banking interface
banking:closeBanking()
```

### **Universal Methods**

**Client Methods (use colon `:`):**

- `:openBanking()` - Open banking interface
- `:closeBanking()` - Close banking interface
- `:isBankingOpen()` - Check if banking interface is open

**Server Methods (use dot `.`):**

- `.addMoney(source, amount, account?)` - Add money to player account
- `.removeMoney(source, amount, account?)` - Remove money from player account
- `.getMoney(source, account?)` - Get player account balance
- `.transferMoney(fromSource, toSource, amount, fromAccount?, toAccount?)` - Transfer money between players
- `.createAccount(source, accountName, accountType?)` - Create new account
- `.addTransaction(source, account, amount, reason, type?)` - Add transaction record

### **Example Usage**

```lua
-- Client-side banking operations
RegisterCommand('bank', function()
    local banking = lib.banking

    -- Open banking menu
    banking:openBanking()
end)

-- Check if banking is open
CreateThread(function()
    while true do
        Wait(1000)
        local banking = lib.banking

        if banking:isBankingOpen() then
            print("Banking interface is currently open")
        end
    end
end)

-- Server-side banking operations
RegisterCommand('addmoney', function(source, args)
    local amount = tonumber(args[1])
    local account = args[2] or 'checking'

    if amount and amount > 0 then
        local success = lib.banking.addMoney(source, amount, account)
        if success then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Banking", string.format("Added $%d to your %s account", amount, account)}
            })
        end
    end
end)

-- Transfer money between players
RegisterServerEvent('banking:transferMoney')
AddEventHandler('banking:transferMoney', function(targetSource, amount, fromAccount, toAccount)
    local source = source

    local success = lib.banking.transferMoney(source, targetSource, amount, fromAccount, toAccount)
    if success then
        TriggerClientEvent('banking:transferSuccess', source)
        TriggerClientEvent('banking:transferReceived', targetSource, amount)
    else
        TriggerClientEvent('banking:transferFailed', source)
    end
end)

-- Check account balance
RegisterServerEvent('banking:checkBalance')
AddEventHandler('banking:checkBalance', function(account)
    local source = source
    local balance = lib.banking.getMoney(source, account or 'checking')

    TriggerClientEvent('banking:balanceResponse', source, balance, account)
end)
```

---

## 🪝 **NEW: Server-Side Hooks System**

The **Server-Side Hooks System** provides secure middleware-style event hooks that allow intercepting and controlling server operations before they execute. This system is server-only for security reasons and provides a clean way to add custom logic to existing operations.

### **Key Features**

- **🔒 Server-Only Security** - Hooks execute only on server to prevent client manipulation
- **⚡ Priority System** - Control execution order with priority values (higher runs first)
- **🛑 Prevention Control** - Return false to prevent action from proceeding
- **🔧 Error Handling** - Built-in pcall protection with error logging
- **🧹 Hook Management** - Register, remove, and clear hooks dynamically
- **🔍 Debug Support** - List registered hooks for debugging
- **📦 Custom Handlers** - Advanced hook handling with custom result processing

### **Basic Usage**

```lua
-- Register a hook to intercept player money additions
lib.hooks.register('player:before_add_money', function(source, amount, account)
    local player = lib.core.player(source)

    -- Log the transaction
    print(('Player %s is receiving $%d in %s'):format(player.name, amount, account))

    -- Prevent if amount is too large (example business logic)
    if amount > 100000 then
        lib.core.notify(source, 'Amount too large!', 'error')
        return false -- Prevents the money addition
    end

    -- Allow transaction to proceed
    return true
end, 10) -- Priority 10 (higher priority)

-- Hook that runs after the first one (lower priority)
lib.hooks.register('player:before_add_money', function(source, amount, account)
    -- Anti-duplication check
    if IsPlayerCheating(source) then
        return false -- Prevent money addition
    end
end, 5) -- Priority 5 (lower priority, runs after priority 10)
```

### **Available Methods**

**Core Methods:**

- `lib.hooks.register(name, callback, priority?)` - Register a hook callback
- `lib.hooks.trigger(name, ...)` - Trigger a hook chain, returns boolean (allowed/prevented)
- `lib.hooks.remove(name, callback)` - Remove specific hook callback
- `lib.hooks.clear(name)` - Remove all hooks for a specific name
- `lib.hooks.exists(name)` - Check if hook has registered callbacks

**Management Methods:**

- `lib.hooks.getRegistered(name?)` - Get registered hooks (debugging)
- `lib.hooks.triggerWithHandler(name, handler, ...)` - Advanced hook execution with custom result handling

### **Common Hook Names**

While you can create any hook names, here are some common patterns:

**Player Operations:**

- `player:before_add_money` - Before adding money to player
- `player:before_remove_money` - Before removing money from player
- `player:before_give_item` - Before giving item to player
- `player:before_remove_item` - Before removing item from player
- `player:before_set_job` - Before changing player job

**Vehicle Operations:**

- `vehicle:before_spawn` - Before spawning a vehicle
- `vehicle:before_delete` - Before deleting a vehicle
- `vehicle:before_modify` - Before modifying vehicle properties

**Inventory Operations:**

- `inventory:before_add_item` - Before adding item to inventory
- `inventory:before_remove_item` - Before removing item from inventory
- `inventory:before_use_item` - Before using an item

### **Advanced Usage**

```lua
-- Complex hook with multiple conditions
lib.hooks.register('shop:before_purchase', function(source, shopId, item, quantity, price)
    local player = lib.core.player(source)

    -- Multiple validation checks
    if not player then return false end

    -- Check if player has enough money
    if lib.core.wallet(source, 'bank') < price then
        lib.core.notify(source, 'Insufficient funds', 'error')
        return false
    end

    -- Check if item is restricted
    if IsRestrictedItem(item) and not HasPermission(source, 'restricted_items') then
        lib.core.notify(source, 'No permission for this item', 'error')
        return false
    end

    -- Log the purchase attempt
    lib.discord:sendPlayerLog(source, 'Shop Purchase Attempt',
        ('Item: %s, Quantity: %d, Price: $%d'):format(item, quantity, price))

    return true -- Allow purchase
end)

-- Hook with custom result handling
local function collectResults(...)
    local results = {...}
    local denied = false
    local reasons = {}

    for i, result in ipairs(results) do
        if type(result) == 'table' and result.denied then
            denied = true
            reasons[#reasons + 1] = result.reason
        elseif result == false then
            denied = true
        end
    end

    return {
        allowed = not denied,
        reasons = reasons
    }
end

lib.hooks.triggerWithHandler('complex:validation', collectResults, source, data)
```

### **Integration Example**

```lua
-- In your inventory wrapper or core system
function GivePlayerItem(source, item, count)
    -- Trigger hook before giving item
    local allowed = lib.hooks.trigger('player:before_give_item', source, item, count)

    if not allowed then
        -- Hook prevented the action
        return false
    end

    -- Proceed with original logic
    local success = OriginalGiveItemFunction(source, item, count)

    if success then
        -- Trigger after hook (informational)
        lib.hooks.trigger('player:after_give_item', source, item, count)
    end

    return success
end
```

### **Hook Management**

```lua
-- Check what hooks are registered
local playerHooks = lib.hooks.getRegistered('player:before_add_money')
print(('Found %d hooks for player money additions'):format(#playerHooks))

-- List all registered hooks
local allHooks = lib.hooks.getRegistered()
for hookName, count in pairs(allHooks) do
    print(('Hook "%s" has %d callbacks'):format(hookName, count))
end

-- Remove specific hook
local function myMoneyHook(source, amount)
    -- Some logic
end

lib.hooks.register('player:before_add_money', myMoneyHook)
-- Later...
lib.hooks.remove('player:before_add_money', myMoneyHook)

-- Clear all hooks for a specific event
lib.hooks.clear('player:before_add_money')
```

### **Complete Example: Vehicle Module with Hooks**

Here's a complete example showing how to register hooks and use them with the vehicle module:

```lua
-- ================================================================================================
-- STEP 1: REGISTER HOOKS (This runs when your resource starts)
-- ================================================================================================

-- Register hook to control vehicle creation
lib.hooks.register('vehicle:before_create', function(model, coords, heading, options)
    print('[Hook] Attempting to create vehicle:', model)

    -- Prevent restricted vehicles
    local restrictedVehicles = { 'rhino', 'lazer', 'hydra' }
    local modelName = type(model) == 'string' and model:lower() or GetDisplayNameFromVehicleModel(model):lower()

    for _, restricted in ipairs(restrictedVehicles) do
        if modelName == restricted then
            print('[Hook] Blocked restricted vehicle:', modelName)
            return false -- This prevents the vehicle creation
        end
    end

    return true -- Allow creation
end, 10) -- Priority 10 (higher = runs first)

-- Register hook to log vehicle repairs
lib.hooks.register('vehicle:before_repair', function(vehicleEntity, vehicleInstance)
    print('[Hook] Vehicle repair requested for:', vehicleEntity)

    -- Check if player has mechanic job
    local vehicleCoords = GetEntityCoords(vehicleEntity)
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)

        if #(vehicleCoords - playerCoords) < 5.0 then
            local player = lib.core.player(playerId)
            if player and player.job == 'mechanic' then
                return true -- Allow repair
            end
        end
    end

    print('[Hook] No mechanic nearby, blocking repair')
    return false -- Prevent repair
end)

-- Register hook to control player vehicle entry
lib.hooks.register('vehicle:before_set_player', function(vehicleEntity, vehicleInstance, playerId, seat)
    local player = lib.core.player(playerId)
    if not player then return false end

    -- Check job restrictions
    local model = GetEntityModel(vehicleEntity)
    local modelName = GetDisplayNameFromVehicleModel(model)

    if modelName == 'POLICE' and player.job ~= 'police' then
        lib.core.notify(playerId, 'You need to be a police officer!', 'error')
        return false -- Prevent entry
    end

    return true -- Allow entry
end)

-- ================================================================================================
-- STEP 2: USE THE MODULE (The hooks will automatically trigger)
-- ================================================================================================

-- Example command that uses the vehicle module
RegisterCommand('spawncar', function(source, args)
    local model = args[1] or 'adder'
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    -- When this runs, it will trigger 'vehicle:before_create' hook
    local vehicle = lib.vehicle.create(model, coords, 0.0)

    if vehicle then
        print('Vehicle created successfully:', vehicle.vehicle)
        lib.core.notify(source, 'Vehicle spawned!', 'success')

        -- Set player into the vehicle (triggers 'vehicle:before_set_player' hook)
        vehicle:setPlayerIntoVehicle(source, -1) -- Driver seat
    else
        lib.core.notify(source, 'Vehicle creation was blocked by hooks!', 'error')
    end
end)

-- Example repair command
RegisterCommand('repaircar', function(source)
    local vehicle = lib.vehicle.getPlayerVehicle(source)

    if vehicle then
        -- This will trigger 'vehicle:before_repair' hook
        local success = vehicle:repair()

        if success then
            lib.core.notify(source, 'Vehicle repaired!', 'success')
        else
            lib.core.notify(source, 'Repair blocked - no mechanic nearby!', 'error')
        end
    else
        lib.core.notify(source, 'You must be in a vehicle!', 'error')
    end
end)

-- ================================================================================================
-- STEP 3: HOOK RESULTS FLOW
-- ================================================================================================

--[[
Flow when player runs /spawncar rhino:

1. lib.vehicle.create() is called
2. Hook 'vehicle:before_create' triggers with parameters (model='rhino', coords, heading, options)
3. Hook function checks if 'rhino' is in restrictedVehicles list
4. Hook returns false (blocked)
5. lib.vehicle.create() receives false from hook and returns nil
6. Player gets "Vehicle creation was blocked by hooks!" message

Flow when mechanic runs /repaircar:

1. vehicle:repair() is called
2. Hook 'vehicle:before_repair' triggers
3. Hook finds nearby mechanic player
4. Hook returns true (allowed)
5. Vehicle repair proceeds normally
6. Player gets "Vehicle repaired!" message
]]

-- ================================================================================================
-- STEP 4: ADVANCED HOOK EXAMPLE
-- ================================================================================================

-- Complex hook with multiple validations
lib.hooks.register('vehicle:before_create', function(model, coords, heading, options)
    local validations = {}

    -- Check coordinates
    if coords.z < -50 then
        validations[#validations + 1] = 'Cannot spawn underwater'
    end

    -- Check altitude
    if coords.z > 500 then
        validations[#validations + 1] = 'Cannot spawn at high altitude'
    end

    -- Check if model exists
    if not IsModelValid(model) then
        validations[#validations + 1] = 'Invalid vehicle model'
    end

    if #validations > 0 then
        print('[Hook] Vehicle creation blocked:', table.concat(validations, ', '))
        return false
    end

    return true
end, 5) -- Lower priority, runs after the first hook

-- ================================================================================================
-- STEP 5: HOOK MANAGEMENT COMMANDS
-- ================================================================================================

-- Admin command to list all registered hooks
RegisterCommand('listhooks', function(source)
    if not IsPlayerAceAllowed(source, 'admin') then return end

    local allHooks = lib.hooks.getRegistered()
    print('=== REGISTERED HOOKS ===')
    for hookName, count in pairs(allHooks) do
        print(('Hook: %s - Callbacks: %d'):format(hookName, count))
    end
end)

-- Admin command to clear specific hooks
RegisterCommand('clearhook', function(source, args)
    if not IsPlayerAceAllowed(source, 'admin') then return end

    local hookName = args[1]
    if hookName and lib.hooks.exists(hookName) then
        lib.hooks.clear(hookName)
        print('Cleared hooks for:', hookName)
    end
end)
```

**Available Vehicle Hooks:**

- `vehicle:before_create` - Before vehicle creation
- `vehicle:after_create` - After successful vehicle creation
- `vehicle:before_repair` - Before vehicle repair
- `vehicle:after_repair` - After successful vehicle repair
- `vehicle:before_delete` - Before vehicle deletion
- `vehicle:after_delete` - After successful vehicle deletion
- `vehicle:before_explode` - Before vehicle explosion
- `vehicle:after_explode` - After vehicle explosion
- `vehicle:before_set_player` - Before putting player in vehicle
- `vehicle:after_set_player` - After player enters vehicle

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
- `:formatItalic(text)` - _Italic text_
- `:formatUnderline(text)` - **Underlined text**
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
- **`lib.enums.npc`** - NPC-related constants (AI states, etc.)

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

### **Fluent configuration API (runtime setters)**

You can now spawn a lightweight NPC and attach extra systems later. Each setter returns the NPC instance, so you can chain calls.

| Method                           | Purpose                                                   |
| -------------------------------- | --------------------------------------------------------- |
| `npc:setSchedule(tbl)`           | Define or replace the hour-based schedule.                |
| `npc:setRelationships(tbl)`      | Attach relationship data.                                 |
| `npc:setInteractions(tbl)`       | Create an interaction zone when you need it.              |
| `npc:setGuardZone(tbl)`          | Add a guard zone and enable threat detection.             |
| `npc:setBehaviors(list, first?)` | Register available behaviors and optionally activate one. |

```lua
local npc = lib.npc:new({
    model = 'a_m_m_business_01',
    coords = vector3(100.0, 200.0, 30.0)
})

npc:setBehaviors({'civilian'})
   :setSchedule({ [8] = 'civilian' })
   :setInteractions({ label = 'Talk', icon = 'fa-user' })
```

### **NPC Event Hooks**

| Hook Name              | Parameters           | Triggered When                               |
| ---------------------- | -------------------- | -------------------------------------------- |
| `npc:spawned`          | `(npc)`              | NPC is created in world                      |
| `npc:behavior_changed` | `(npc, newBehavior)` | Behavior is switched via `:changeBehavior()` |
| `npc:destroyed`        | `(npc)`              | NPC entity is deleted                        |

Register callbacks from any script (client or server):

```lua
lib.npc.onSpawned(function(npc)
    print('NPC spawned:', npc:getPed())
end)

lib.npc.onBehaviorChanged(function(npc, behavior)
    print('NPC', npc:getId(), 'changed behavior to', behavior)
end)

lib.npc.onDestroyed(function(npc)
    print('NPC removed:', npc:getId())
end)
```

---

## 🖥️ **ENHANCED: Direct-Rendered UI (DUI) System**

The **Enhanced DUI System** provides a powerful class-based interface for creating interactive Direct-Rendered UI elements with mouse interaction, callback support, and advanced state management.

### **What is DUI?**

DUI (Direct-rendered UI) allows you to render web content (HTML/CSS/JS) directly onto game textures, enabling:

- **In-world screens** (cinema screens, TV displays, billboards)
- **Interactive surfaces** (ATM interfaces, computer terminals)
- **Vehicle displays** (dashboard screens, entertainment systems)
- **Dynamic textures** (real-time updating content)

### **Key Features**

- **🎯 Object-Oriented Design** - Each DUI is a manageable class instance
- **🖱️ Mouse Interaction** - Full mouse event support (click, move, wheel)
- **📞 Callback System** - Bidirectional communication between Lua and web content
- **🎮 Focus Management** - Control which DUI receives input
- **📐 Dynamic Sizing** - Change dimensions after creation
- **🔍 State Validation** - Check DUI availability and status
- **📊 Position Tracking** - Monitor mouse position within DUI
- **🧹 Automatic Cleanup** - Proper memory management on resource stop

### **Basic Usage**

```lua
-- Create a DUI instance
local myDui = lib.dui:new({
    url = 'https://example.com',
    width = 1920,
    height = 1080,
    debug = true
})

-- Use the DUI texture in game
-- The texture can be accessed via myDui.dictName and myDui.txtName
DrawSprite(myDui.dictName, myDui.txtName, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
```

### **Mouse Interaction Methods**

```lua
-- Mouse click events
myDui:sendMouseDown(x, y, button)  -- button: 0=left, 1=right, 2=middle
myDui:sendMouseUp(x, y, button)

-- Mouse movement
myDui:sendMouseMove(x, y)

-- Mouse wheel scrolling
myDui:sendMouseWheel(x, y, deltaX, deltaY)

-- Get current mouse position
local mousePos = myDui:getMousePosition()
print(mousePos.x, mousePos.y)
```

### **State Management**

```lua
-- Check if DUI is available
if myDui:isAvailable() then
    print("DUI is ready for interaction")
end

-- Validate DUI state
if myDui:isValid() then
    -- Safe to use DUI
end

-- Focus management
myDui:setFocus(true)   -- Give focus to this DUI
local hasFocus = myDui:hasFocus()

-- Get/set dimensions
local dimensions = myDui:getDimensions()
myDui:setDimensions(1280, 720)
```

### **Callback System**

```lua
-- Register callback handlers
myDui:onCallback('buttonClick', function(data)
    print('Button clicked:', data.buttonId)
end)

myDui:onCallback('formSubmit', function(data)
    print('Form submitted:', json.encode(data))
end)

-- Trigger callbacks from web content (JavaScript)
-- In your HTML/JS: window.postMessage({type: 'buttonClick', buttonId: 'submit'}, '*');

-- Trigger callbacks from Lua
myDui:triggerCallback('dataUpdate', {
    playerName = 'John Doe',
    score = 1500
})
```

### **Advanced Example: Interactive ATM**

```lua
-- Create ATM DUI
local atmDui = lib.dui:new({
    url = 'nui://my_banking/atm.html',
    width = 800,
    height = 600,
    debug = false
})

-- Set up callbacks
atmDui:onCallback('withdraw', function(data)
    local amount = tonumber(data.amount)
    if lib.core:getMoney('bank') >= amount then
        lib.core:removeMoney('bank', amount)
        lib.core:addMoney('cash', amount)
        atmDui:sendMessage({
            type = 'transaction_success',
            message = 'Withdrawal successful',
            newBalance = lib.core:getMoney('bank')
        })
    else
        atmDui:sendMessage({
            type = 'transaction_error',
            message = 'Insufficient funds'
        })
    end
end)

-- Handle mouse interactions
CreateThread(function()
    while atmDui:isValid() do
        local hit, coords, entity = lib.raycast.cam(511, 10.0)

        if hit and entity == atmEntity then
            -- Convert world coordinates to DUI coordinates
            local x, y = convertWorldToDuiCoords(coords)

            -- Send mouse position
            atmDui:sendMouseMove(x, y)

            -- Handle clicks
            if IsControlJustPressed(0, 24) then -- Left click
                atmDui:sendMouseDown(x, y, 0)
                atmDui:setFocus(true)
            end

            if IsControlJustReleased(0, 24) then
                atmDui:sendMouseUp(x, y, 0)
            end
        else
            atmDui:setFocus(false)
        end

        Wait(0)
    end
end)

-- Clean up when done
RegisterCommand('close_atm', function()
    atmDui:remove()
end)
```

### **Available Methods**

**Creation & Basic Operations:**

- `:new(properties)` - Create new DUI instance
- `:remove()` - Destroy DUI and clean up
- `:setUrl(url)` - Change DUI URL
- `:sendMessage(message)` - Send data to web content

**Mouse Interaction:**

- `:sendMouseDown(x, y, button)` - Send mouse down event
- `:sendMouseUp(x, y, button)` - Send mouse up event
- `:sendMouseMove(x, y)` - Send mouse movement
- `:sendMouseWheel(x, y, deltaX, deltaY)` - Send scroll wheel event
- `:getMousePosition()` - Get current mouse position

**State Management:**

- `:isAvailable()` - Check if DUI is available
- `:isValid()` - Validate DUI state
- `:getDimensions()` - Get current width/height
- `:setDimensions(width, height)` - Change DUI size
- `:setFocus(hasFocus)` - Set focus state
- `:hasFocus()` - Check focus state

**Callback System:**

- `:onCallback(eventName, callback)` - Register callback handler
- `:triggerCallback(eventName, data)` - Trigger callback

**Texture Replacement:**

- `:replaceTexture(origTxd, origTxn)` - Replace game texture with DUI content
- `:removeTextureReplacement(origTxd, origTxn)` - Remove specific texture replacement
- `:removeAllTextureReplacements()` - Remove all texture replacements
- `:getReplacedTextures()` - Get list of all replaced textures

### **Texture Replacement Examples**

```lua
-- Replace TV screens in a building
local tvDui = lib.dui:new({
    url = 'nui://my_tv_app/news.html',
    width = 1920,
    height = 1080
})

-- Replace specific TV textures
tvDui:replaceTexture('prop_tv_flat_01', 'script_rt_tvscreen')  -- Living room TV
tvDui:replaceTexture('prop_tv_flat_michael', 'script_rt_tvscreen')  -- Bedroom TV

-- Replace billboard textures
local billboardDui = lib.dui:new({
    url = 'https://my-ads-server.com/billboard',
    width = 1024,
    height = 512
})

billboardDui:replaceTexture('prop_billboard_01', 'billboard_texture')

-- Check what textures are replaced
local replacedTextures = tvDui:getReplacedTextures()
for i, texture in ipairs(replacedTextures) do
    print(('Replaced: %s:%s'):format(texture.txd, texture.txn))
end

-- Remove specific replacement
tvDui:removeTextureReplacement('prop_tv_flat_01', 'script_rt_tvscreen')

-- Clean up all replacements
tvDui:removeAllTextureReplacements()
```

### **Advanced Example: Dynamic Cinema Screen**

```lua
-- Create cinema screen DUI
local cinemaDui = lib.dui:new({
    url = 'nui://cinema_app/player.html',
    width = 1920,
    height = 1080,
    debug = true
})

-- Replace cinema screen texture
cinemaDui:replaceTexture('prop_cinema_screen', 'cinema_texture')

-- Set up movie controls
cinemaDui:onCallback('play_movie', function(data)
    -- Handle movie playback
    cinemaDui:sendMessage({
        type = 'load_video',
        url = data.movieUrl,
        title = data.movieTitle
    })
end)

cinemaDui:onCallback('pause_movie', function()
    -- Handle pause
    cinemaDui:sendMessage({ type = 'pause_video' })
end)

-- Cinema ticket booth interaction
RegisterNetEvent('cinema:buy_ticket')
AddEventHandler('cinema:buy_ticket', function(movieId)
    local movieUrl = GetMovieUrl(movieId)
    cinemaDui:triggerCallback('play_movie', {
        movieUrl = movieUrl,
        movieTitle = GetMovieTitle(movieId)
    })
end)
```

### **Properties**

Each DUI instance provides access to:

- `url` - Current DUI URL
- `width` / `height` - Current dimensions
- `duiObject` - Native DUI handle
- `duiHandle` - DUI texture handle
- `dictName` / `txtName` - Texture dictionary and name for rendering

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

-- Universal wrapper examples
lib.banking.addMoney(source, 1000, 'checking')
lib.fuel.setFuel(vehicle, 75.0)
lib.dispatch.sendPoliceAlert({title = 'Bank Robbery', coords = coords})
lib.phone.sendMessage('555-1234', 'Hello!')
lib.clothing.openClothing()
lib.garage.openMenu({index = 'pillboxgarage'})

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

```

---

## **Task Sequences API**

Advanced task sequence system for creating complex NPC behaviors using FiveM's OpenSequenceTask natives.

### **Basic Usage**

```lua
-- Create a simple sequence
local sequenceId = lib.createSequence({
    ped = npc,
    tasks = {
        {
            type = "goto_coord",
            params = { coords = vector3(100.0, 200.0, 30.0), speed = 1.0 }
        },
        {
            type = "play_anim",
            params = { dict = "gestures@m@standing@casual", anim = "gesture_hello", duration = 3000 }
        },
        {
            type = "scenario",
            params = { name = "WORLD_HUMAN_GUARD_STAND", duration = 10000 }
        }
    }
})

-- Execute the sequence
lib.executeSequence(sequenceId)
```

### **Quick Sequence**

```lua
-- Create and execute in one call
lib.quickSequence(npc, {
    { type = "goto_coord", params = { coords = targetPos } },
    { type = "hands_up", params = { duration = 5000 } },
    { type = "clear_tasks" }
})
```

### **Patrol Sequences**

```lua
-- Create patrol with custom scenarios
lib.createPatrolSequence(guardPed, {
    vector3(100.0, 200.0, 30.0),
    vector3(150.0, 200.0, 30.0),
    vector3(150.0, 250.0, 30.0)
}, {
    speed = 1.0,
    waitTime = 5000,
    scenarios = { "WORLD_HUMAN_GUARD_STAND", "WORLD_HUMAN_BINOCULARS", "WORLD_HUMAN_CLIPBOARD" },
    loop = true
})
```

### **Conversation Sequences**

```lua
-- Two NPCs having a conversation
local seq1, seq2 = lib.createConversationSequence(ped1, ped2, {
    ped1_dict = "gestures@m@standing@casual",
    ped1_anim = "gesture_hello",
    ped2_dict = "gestures@f@standing@casual",
    ped2_anim = "gesture_point"
}, 8000)
```

### **Advanced Sequence with Callbacks**

```lua
local sequenceId = lib.createSequence({
    ped = npc,
    name = "complex_behavior",
    timeout = 30000,
    loop = false,
    callbacks = {
        onStart = function(id, ped)
            print("Sequence started for ped", ped)
        end,
        onComplete = function(id, ped)
            print("Sequence completed")
            -- Trigger next behavior
        end,
        onFail = function(id, ped, reason)
            print("Sequence failed:", reason)
        end
    },
    tasks = {
        {
            type = "goto_entity",
            params = { target = PlayerPedId(), distance = 2.0 },
            condition = function(ped)
                return #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId())) > 10.0
            end
        },
        {
            type = "turn_to_face_entity",
            params = { target = PlayerPedId(), duration = 2000 }
        },
        {
            type = "play_anim",
            params = { dict = "gestures@m@standing@casual", anim = "gesture_hello" }
        },
        {
            type = "wait",
            params = { duration = 2000 }
        },
        {
            type = "custom",
            params = {
                func = function()
                    -- Custom logic here
                    TriggerEvent('custom:npcGreeting', npc)
                end
            }
        }
    }
})
```

### **Available Task Types**

- `goto_coord` - Walk to coordinates
- `goto_entity` - Walk to entity
- `play_anim` - Play animation
- `scenario` - Start scenario in place
- `scenario_at_position` - Start scenario at specific position
- `enter_vehicle` - Enter vehicle
- `drive_to_coord` - Drive to coordinates
- `hands_up` - Put hands up
- `look_at_entity` - Look at entity
- `turn_to_face_entity` - Turn to face entity
- `follow_ped` - Follow another ped
- `wait` - Pause for duration
- `clear_tasks` - Clear all tasks
- `custom` - Execute custom function

### **Sequence Management**

```lua
-- Check sequence state
local state = lib.getSequenceState(sequenceId)

-- Cancel sequence
lib.cancelSequence(sequenceId)

-- Get all active sequences
local activeSequences = lib.getAllActiveSequences()

-- Cancel all sequences for a ped
lib.cancelPedSequences(npc)
```

### **Complete Heist Examples**

#### **Casino Heist**

```lua
-- Load the casino heist module
local CasinoHeist = require('api.sequences.examples.casino_heist')

-- Start the complete casino heist
CasinoHeist.start()

-- Features:
-- - 3-phase heist (Infiltration, Vault Access, Escape)
-- - Multiple crew members with specific roles
-- - Security guards with patrol sequences
-- - Dynamic reactions to heist events
-- - Coordinated escape with getaway car
```

#### **Market 24 Robbery**

```lua
-- Load the market robbery module
local MarketRobbery = require('api.sequences.examples.market_robbery')

-- Start simple market robbery
MarketRobbery.startSimple()

-- Start advanced robbery with customer
MarketRobbery.startAdvanced()

-- Features:
-- - Simple but effective 3-phase robbery
-- - Clerk with realistic reactions
-- - Lookout providing security watch
-- - Customer interaction in advanced mode
-- - Police alert system
```

#### **Fleeca Truck Advanced Example**

```lua
-- Advanced Fleeca with Network Synchronized Scenes (Real-world replica)
RegisterCommand('fleeca_real', function()
    -- This example perfectly replicates the real Fleeca truck behavior you saw:
    -- 1. Driver enters vehicle, guard positions precisely using animation offset
    -- 2. Network synchronized scene with ped + vehicle + case animations
    -- 3. Automatic door closing, guard entry, departure sequence
end)

RegisterCommand('fleeca_enhanced', function()
    -- Enhanced version with additional case handling
end)
```

**Advanced Features Used:**

- `lib.createSyncScene()` - Network synchronized scenes
- `lib.getAnimPosition()` - Precise animation positioning
- `lib.playSyncScene()` - Scene execution with callbacks
- Perfect timing coordination between driver and guards
- Real animation dictionary usage (`random@security_van`)

#### **Quick Demo Commands**

```lua
-- Register these commands in your resource
RegisterCommand('start_casino_heist', function()
    local CasinoHeist = require('api.sequences.examples.casino_heist')
    CasinoHeist.start()
end, false)

RegisterCommand('start_market_robbery', function()
    local MarketRobbery = require('api.sequences.examples.market_robbery')
    MarketRobbery.startSimple()
end, false)

RegisterCommand('fleeca_real', function()
    -- Real-world Fleeca truck replica with synchronized scenes
end, false)

RegisterCommand('fleeca_enhanced', function()
    -- Enhanced version with case handling
end, false)

RegisterCommand('stop_heists', function()
    for id in pairs(lib.getAllActiveSequences()) do
        lib.cancelSequence(id)
    end
end, false)
```

#### **Custom Gang Robbery**

```lua
-- Create a custom 3-member gang robbery
local gang = {
    leader = lib.spawnPed("g_m_m_armboss_01", coords + vector3(5.0, 0.0, 0.0), 270.0),
    muscle = lib.spawnPed("g_m_m_chemwork_01", coords + vector3(7.0, 2.0, 0.0), 270.0),
    lookout = lib.spawnPed("g_m_y_mexgang_01", coords + vector3(7.0, -2.0, 0.0), 270.0)
}

-- Leader approaches and threatens
lib.quickSequence(gang.leader, {
    { type = "goto_entity", params = { target = PlayerPedId(), distance = 2.0 } },
    { type = "play_anim", params = { dict = "gestures@m@standing@casual", anim = "gesture_point" } },
    { type = "hands_up", params = { duration = 3000 } }
})

-- Muscle flanks from side
lib.quickSequence(gang.muscle, {
    { type = "goto_coord", params = { coords = GetEntityCoords(PlayerPedId()) + vector3(3.0, 2.0, 0.0) } },
    { type = "turn_to_face_entity", params = { target = PlayerPedId() } }
})

-- Lookout watches for police
lib.createPatrolSequence(gang.lookout, {
    coords + vector3(10.0, 0.0, 0.0),
    coords + vector3(15.0, 5.0, 0.0),
    coords + vector3(15.0, -5.0, 0.0)
}, { scenarios = {"WORLD_HUMAN_BINOCULARS", "WORLD_HUMAN_GUARD_STAND"} })
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

## NEW: Achievements API (Lazy Loaded)

The Achievements API is loaded only when first accessed to minimize resource usage. It allows scripts to register achievements, unlock them for players, and query progress using a unified interface.

### Basic Usage

```lua
-- Register achievement definitions (server-side)
lib.achievements.register({
    id = 'FIRST_LOGIN',
    name = 'First Login',
    description = 'Player joined the server for the first time'
})

-- Unlock when condition met
lib.achievements:unlock(source, 'FIRST_LOGIN')

-- Check status
local hasIt = lib.achievements:isUnlocked(source, 'FIRST_LOGIN')

-- Retrieve all unlocked achievements for a player
local list = lib.achievements:getAll(source)
```

### Available Methods

- `register(id, name, description)` – Register a new achievement definition.
- `unlock(src, id)` – Unlock an achievement for a player.
- `isUnlocked(src, id)` – Check if a player has unlocked a specific achievement.
- `getAll(src)` – Get a table of all achievements unlocked by a player.

The module resides at `imports/achievements.lua` and is resolved automatically the first time `lib.achievements` is referenced.

---

## 🏠 **NEW: Universal Housing Wrapper System**

The **Universal Housing Wrapper System** provides a consistent API across all popular FiveM housing systems, enabling seamless property management regardless of which housing resource you're using.

### **Supported Systems**

- **qb-houses** - QBCore's housing system with apartments and houses
- **ox_property** - Modern property system with advanced features
- **ps-housing** - Project Sloth housing system with enhanced customization

### **Auto-Detection**

The wrapper automatically detects which housing system is installed and uses the appropriate implementation:

```lua
-- Works with any supported housing system
local housing = lib.housing

-- Enter a house/property (universal across all systems)
housing:enterHouse(houseId)

-- Exit current house/property
housing:exitHouse()

-- Check if player is inside a property
local isInside = housing:isPlayerInsideHouse()
```

### **Universal Methods**

**Client Methods (use colon `:`):**

- `:enterHouse(houseId)` - Enter a specific house/property
- `:exitHouse()` - Exit current house/property
- `:createHouse(coords, price, houseType?)` - Create new house at coordinates
- `:buyHouse(houseId)` - Purchase a specific house
- `:openHouseMenu()` - Open house management menu
- `:getPlayerHouses()` - Get list of player-owned houses
- `:isPlayerInsideHouse()` - Check if player is inside property
- `:getCurrentHouse()` - Get current house data
- `:openInventory()` - Open house inventory (ps-housing)

**Server Methods (use dot `.`):**

- `.enterHouse(source, houseId)` - Teleport player into house
- `.exitHouse(source)` - Teleport player out of house
- `.createHouse(coords, price, owner, houseType?)` - Create new house
- `.buyHouse(source, houseId)` - Process house purchase
- `.getPlayerHouses(source)` - Get player's owned houses
- `.isPlayerInsideHouse(source)` - Check if player is inside property
- `.getHouseInfo(houseId)` - Get house information
- `.setHouseOwner(houseId, owner)` - Change house ownership (ox_property/ps-housing)
- `.deleteHouse(houseId)` - Delete house (ps-housing)

### **Example Usage**

```lua
-- Client-side housing operations
RegisterCommand('house', function()
    local housing = lib.housing

    -- Open house menu
    housing:openHouseMenu()
end)

-- Check player houses
RegisterCommand('myhouses', function()
    local housing = lib.housing
    local houses = housing:getPlayerHouses()

    for i, house in ipairs(houses) do
        print(('House %d: %s at %s'):format(i, house.label or 'Unknown', tostring(house.coords)))
    end
end)

-- Server-side housing management
RegisterNetEvent('housing:createHouse')
AddEventHandler('housing:createHouse', function(coords, price)
    local source = source
    local housing = lib.housing

    -- Create house for player
    local houseId = housing.createHouse(coords, price, GetPlayerIdentifier(source), 'house')

    if houseId then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'House Created',
            description = 'House created successfully',
            type = 'success'
        })
    end
end)
```

---

## 🪝 **NEW: Universal Inventory Hooks System**

The **Universal Inventory Hooks System** provides a powerful event-driven system that allows you to intercept and modify inventory operations in real-time across multiple inventory systems. This enables advanced validation, logging, anti-cheat measures, and custom business logic.

> **Credits:** The hooks system design is inspired by and based on the original ox_inventory hooks implementation by Overextended. We extend this excellent design to work across multiple inventory systems.

### **Supported Inventory Systems**

- **ox_inventory** - Full hooks support with all advanced features
- **qb-inventory** - Complete hooks implementation with all core operations
- **qs-inventory** - Basic hooks support (planned)

The wrapper automatically detects which inventory system is installed and provides hooks functionality where supported.

### **What are Hooks?**

Hooks are event listeners that trigger before and after inventory operations, allowing you to:

- **Validate operations** before they execute
- **Cancel operations** by returning `false`
- **Log activities** for auditing and anti-cheat
- **Apply custom logic** like discounts, restrictions, or notifications
- **Integrate with external systems** like databases or analytics

### **Available Hooks**

**Core Inventory Hooks (All Supported Systems):**

- `addItem` / `afterAddItem` - When items are added to inventory
- `removeItem` / `afterRemoveItem` - When items are removed from inventory
- `giveItem` / `afterGiveItem` - When items are given between players (where supported)
- `clearInventory` / `afterClearInventory` - When inventory is cleared

**Advanced Hooks (ox_inventory):**

- `swapSlots` / `afterSwapSlots` - When items are moved between slots
- `buyItem` / `afterBuyItem` - When items are purchased
- `createShop` / `afterCreateShop` - When shops are created
- `deleteShop` / `afterDeleteShop` - When shops are deleted
- `buyShopItem` / `afterBuyShopItem` - When items are purchased from shops
- `sellToShop` / `afterSellToShop` - When items are sold to shops

### **Hook Registration (Server-Side Only)**

```lua
-- Register a hook to validate item additions
lib.inventory.registerHook('addItem', function(data)
    print(('Player %s adding %s (x%s)'):format(data.source, data.item, data.count))

    -- Prevent adding weapons during first 5 minutes
    if data.item:match('weapon_') and GetGameTimer() < 300000 then
        TriggerClientEvent('ox_lib:notify', data.source, {
            type = 'error',
            description = 'Weapons are disabled during the first 5 minutes'
        })
        return false -- Cancel the operation
    end

    return true -- Allow the operation
end)

-- Register a hook for after item addition
lib.inventory.registerHook('afterAddItem', function(data, result)
    print(('Successfully added %s to player %s'):format(data.item, data.source))

    -- Log important transactions
    if data.item == 'money' and data.count > 10000 then
        print(('LARGE MONEY ADD: Player %s received $%s'):format(data.source, data.count))
    end
end)
```

### **Shop Hooks Example**

```lua
-- Apply VIP discounts on shop purchases
lib.inventory.registerHook('buyShopItem', function(data)
    local player = lib.core.getPlayerData(data.source)

    -- Apply 10% discount for VIP players
    if player and player.group == 'vip' then
        data.price = math.floor(data.price * 0.9)
        TriggerClientEvent('ox_lib:notify', data.source, {
            type = 'success',
            description = 'VIP discount applied!'
        })
    end

    return true
end)

-- Award loyalty points after purchases
lib.inventory.registerHook('afterBuyShopItem', function(data, result)
    local points = math.floor(data.price / 100)
    if points > 0 then
        -- Add loyalty points (example)
        TriggerServerEvent('loyalty:addPoints', data.source, points)
    end
end)
```

### **Anti-Cheat Integration**

```lua
-- Anti-duplication hook
lib.inventory.registerHook('addItem', function(data)
    local playerId = tostring(data.source)
    local currentTime = GetGameTimer()

    -- Track rapid item additions
    if not GlobalState.lastItemAdd then
        GlobalState.lastItemAdd = {}
    end

    local lastAdd = GlobalState.lastItemAdd[playerId] or 0
    if currentTime - lastAdd < 100 then -- Less than 100ms
        print(('ANTI-CHEAT: Rapid item addition detected for player %s'):format(data.source))
        return false
    end

    GlobalState.lastItemAdd[playerId] = currentTime
    return true
end)

-- Prevent dropping essential items
lib.inventory.registerHook('removeItem', function(data)
    if data.item == 'id_card' then
        TriggerClientEvent('ox_lib:notify', data.source, {
            type = 'error',
            description = 'You cannot drop your ID card'
        })
        return false
    end
    return true
end)
```

### **Hook Management Functions**

```lua
-- Register a new hook
lib.inventory.registerHook(hookName, callback)

-- Trigger a hook manually
lib.inventory.triggerHook(hookName, ...)

-- Remove a specific hook
lib.inventory.removeHook(hookName, callback)

-- Clear all hooks for an event
lib.inventory.clearHooks(hookName)

-- Clear all hooks
lib.inventory.clearHooks()
```

### **Data Structures**

Each hook receives a `data` table with relevant information:

**addItem/removeItem data:**

```lua
{
    source = 1,           -- Player server ID
    item = "weapon_pistol", -- Item name
    count = 1,            -- Item count
    metadata = {}         -- Item metadata
}
```

**buyShopItem data:**

```lua
{
    source = 1,           -- Player server ID
    shopName = "gunstore", -- Shop identifier
    itemName = "ammo_9mm", -- Item being purchased
    amount = 50,          -- Quantity
    price = 100           -- Purchase price
}
```

### **Compatibility Check**

Before registering hooks, check if they're supported by your inventory system:

```lua
-- Check if hooks are available
if lib.inventory.registerHook then
    print('Inventory hooks system is available')

    -- Safe hook registration
    lib.inventory.registerHook('addItem', function(data)
        -- Your hook logic here
        return true
    end)
else
    print('Current inventory system does not support hooks')
end

-- Helper function for safe registration
function registerInventoryHook(hookName, callback)
    if lib.inventory.registerHook then
        return lib.inventory.registerHook(hookName, callback)
    else
        print(('Warning: Hook %s not supported'):format(hookName))
        return false
    end
end
```

### **Cross-Inventory Examples**

```lua
-- Works with both ox_inventory and qb-inventory
lib.inventory.registerHook('addItem', function(data)
    -- Universal validation logic
    if data.item:match('weapon_') then
        local player = lib.core.getPlayerData(data.source)
        if not player or player.job ~= 'police' then
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'Only police can carry weapons'
            })
            return false
        end
    end
    return true
end)

-- Works across all supported inventories
lib.inventory.registerHook('giveItem', function(data)
    -- Prevent giving items to offline players
    if not GetPlayerName(data.target) then
        TriggerClientEvent('ox_lib:notify', data.source, {
            type = 'error',
            description = 'Target player is not online'
        })
        return false
    end
    return true
end)
```

### **Best Practices**

1. **Always validate input** - Check if data exists before using it
2. **Use pcall for safety** - Wrap risky operations in protected calls
3. **Return boolean values** - `false` cancels operation, `true` allows it
4. **Log important events** - Use hooks for audit trails
5. **Keep hooks lightweight** - Heavy operations can impact performance
6. **Clean up on resource stop** - Remove hooks when your resource stops
7. **Check compatibility** - Verify hooks are supported before registering
8. **Use universal functions** - Stick to core hooks for cross-inventory compatibility

### **Complete Example**

See `examples/inventory_hooks_usage.lua` for comprehensive examples including:

- Basic inventory validation
- Shop purchase modifications
- Anti-cheat integration
- Economy logging
- Dynamic hook management

---

## 🎯 **Advantages of ox_lib Extended**

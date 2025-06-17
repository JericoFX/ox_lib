# 🎁 Pickups API - ox_lib Extended

The Pickups API provides a comprehensive pickup creation and management system for FiveM. It handles automatic collection detection, respawning mechanics, custom callbacks, and intelligent cleanup of pickup entities.

## 📋 Key Features

- 🎯 **Smart Creation** - Automatic pickup creation with custom models and options
- 🔄 **Auto Collection** - Automatic collection detection and handling
- ♻️ **Respawn System** - Configurable respawn mechanics with timers
- 📊 **Usage Tracking** - Track collection counts and usage limits
- 🎮 **Event System** - Custom callbacks for pickup interactions
- 🧹 **Auto Cleanup** - Automatic cleanup of deleted pickups

---

## 🚀 Basic Usage

### Simple Pickup Creation

```lua
-- Create a money pickup
local coords = vector3(100.0, 200.0, 30.0)
local pickup = lib.pickups:createMoney(coords, 1000)

if pickup then
    print("Money pickup created:", pickup)
end
```

### Pickup with Custom Options

```lua
-- Create pickup with respawn and collection limit
local pickup = lib.pickups:create('PICKUP_HEALTH_STANDARD', coords, {
    amount = 100,
    respawnTime = 30000,  -- 30 seconds
    maxUses = 5,          -- Can be collected 5 times
    onCollect = function(pickup, info, playerId)
        print("Player", playerId, "collected health pickup")
    end
})
```

---

## 🎮 Pickup Creation

### `lib.pickups:create(pickupType, coords, options?)`

Create a pickup with full customization options.

```lua
-- Basic pickup
local pickup = lib.pickups:create('PICKUP_MONEY_CASE', coords)

-- Advanced pickup with options
local pickup = lib.pickups:create('PICKUP_ARMOUR_STANDARD', coords, {
    amount = 50,
    customModel = GetHashKey('prop_armour_pickup'),
    rotation = vector3(0, 0, 45),
    respawnTime = 60000,
    maxUses = -1,  -- Infinite uses
    onCollect = function(pickup, info, playerId)
        print("Armor collected by player:", playerId)
    end
})
```

### Specialized Creation Functions

```lua
-- Create money pickup
local money = lib.pickups:createMoney(coords, 5000)

-- Create weapon pickup
local weapon = lib.pickups:createWeapon('WEAPON_PISTOL', coords, 50)

-- Create health pickup
local health = lib.pickups:createHealth(coords, 100)

-- Create armor pickup
local armor = lib.pickups:createArmor(coords, 50)
```

---

## 📊 Pickup Management

### `lib.pickups:getInfo(pickup)`

Get detailed pickup information.

```lua
local info = lib.pickups:getInfo(myPickup)
if info then
    print("Type:", info.type)
    print("Amount:", info.amount)
    print("Collected:", info.collected, "/", info.maxUses)
    print("Respawn Time:", info.respawnTime)
end
```

### `lib.pickups:remove(pickup)`

Remove a pickup.

```lua
if lib.pickups:remove(myPickup) then
    print("Pickup removed successfully")
end
```

### `lib.pickups:removeAll()`

Remove all managed pickups.

```lua
local removedCount = lib.pickups:removeAll()
print("Removed", removedCount, "pickups")
```

---

## 🎯 Event System

### `lib.pickups:onCollect(pickupType, handler)`

Register global collection handler for pickup types.

```lua
-- Handle all money pickups
lib.pickups:onCollect('PICKUP_MONEY_CASE', function(pickup, info, playerId)
    local amount = info.amount
    print("Player", playerId, "collected $" .. amount)

    -- Add money to player (example)
    -- TriggerServerEvent('addMoney', amount)
end)

-- Handle weapon pickups
lib.pickups:onCollect('PICKUP_WEAPON_PISTOL', function(pickup, info, playerId)
    print("Player", playerId, "picked up a pistol with", info.amount, "bullets")

    -- Give weapon to player (example)
    -- GiveWeaponToPed(GetPlayerPed(playerId), GetHashKey('WEAPON_PISTOL'), info.amount, false, true)
end)
```

### `lib.pickups:collect(pickup, playerId?)`

Manually trigger pickup collection.

```lua
-- Force collection by specific player
lib.pickups:collect(myPickup, somePlayerId)

-- Force collection by local player
lib.pickups:collect(myPickup)
```

---

## 🔍 Pickup Discovery

### `lib.pickups:getNearest(coords, maxDistance?)`

Find nearest pickup to coordinates.

```lua
local playerCoords = GetEntityCoords(PlayerPedId())
local nearestPickup, distance = lib.pickups:getNearest(playerCoords, 10.0)

if nearestPickup then
    print("Nearest pickup is", distance, "meters away")
    local info = lib.pickups:getInfo(nearestPickup)
    print("Type:", info.type, "Amount:", info.amount)
end
```

### `lib.pickups:getNearby(coords, radius)`

Get all pickups within radius.

```lua
local playerCoords = GetEntityCoords(PlayerPedId())
local nearbyPickups = lib.pickups:getNearby(playerCoords, 25.0)

for _, data in ipairs(nearbyPickups) do
    print("Pickup:", data.pickup, "Distance:", data.distance)
    print("Type:", data.info.type, "Amount:", data.info.amount)
end
```

---

## 🔧 Advanced Examples

### Dynamic Loot System

```lua
local lootSpawns = {
    { coords = vector3(213.0, -810.0, 31.0), type = 'money', min = 100, max = 1000 },
    { coords = vector3(215.0, -810.0, 31.0), type = 'weapon', weapons = {'WEAPON_PISTOL', 'WEAPON_SMG'} },
    { coords = vector3(217.0, -810.0, 31.0), type = 'health', amount = 100 }
}

function SpawnRandomLoot()
    for _, spawn in ipairs(lootSpawns) do
        if spawn.type == 'money' then
            local amount = math.random(spawn.min, spawn.max)
            lib.pickups:createMoney(spawn.coords, amount, {
                respawnTime = 300000,  -- 5 minutes
                maxUses = 1,
                onCollect = function(pickup, info, playerId)
                    print("Player", playerId, "found $" .. amount)
                end
            })

        elseif spawn.type == 'weapon' then
            local weapon = spawn.weapons[math.random(#spawn.weapons)]
            lib.pickups:createWeapon(weapon, spawn.coords, 50, {
                respawnTime = 600000,  -- 10 minutes
                maxUses = 1
            })

        elseif spawn.type == 'health' then
            lib.pickups:createHealth(spawn.coords, spawn.amount, {
                respawnTime = 120000,  -- 2 minutes
                maxUses = -1  -- Infinite
            })
        end
    end
end

-- Spawn loot on resource start
CreateThread(function()
    Wait(1000)
    SpawnRandomLoot()
end)
```

### Collection Tracking System

```lua
local playerCollections = {}

function InitializePlayerTracking(playerId)
    playerCollections[playerId] = {
        money = 0,
        weapons = 0,
        health = 0,
        armor = 0
    }
end

-- Track money collections
lib.pickups:onCollect('PICKUP_MONEY_CASE', function(pickup, info, playerId)
    if not playerCollections[playerId] then
        InitializePlayerTracking(playerId)
    end

    playerCollections[playerId].money = playerCollections[playerId].money + info.amount
    print("Player", playerId, "total money collected:", playerCollections[playerId].money)
end)

-- Track weapon collections
lib.pickups:onCollect('PICKUP_WEAPON_PISTOL', function(pickup, info, playerId)
    if not playerCollections[playerId] then
        InitializePlayerTracking(playerId)
    end

    playerCollections[playerId].weapons = playerCollections[playerId].weapons + 1

    -- Achievement check
    if playerCollections[playerId].weapons >= 10 then
        print("Player", playerId, "unlocked 'Weapon Collector' achievement!")
    end
end)
```

### Mission-Based Pickup System

```lua
local missionPickups = {}

function CreateMissionPickups(missionId, pickupData)
    missionPickups[missionId] = {}

    for _, data in ipairs(pickupData) do
        local pickup = lib.pickups:create(data.type, data.coords, {
            amount = data.amount,
            maxUses = 1,
            onCollect = function(pickup, info, playerId)
                print("Mission item collected:", data.type)

                -- Check if all mission pickups collected
                CheckMissionCompletion(missionId, playerId)
            end
        })

        if pickup then
            table.insert(missionPickups[missionId], pickup)
        end
    end
end

function CheckMissionCompletion(missionId, playerId)
    local allCollected = true

    for _, pickup in ipairs(missionPickups[missionId]) do
        if DoesPickupExist(pickup) then
            allCollected = false
            break
        end
    end

    if allCollected then
        print("Mission", missionId, "completed by player", playerId)
        -- Trigger mission completion event
        TriggerEvent('mission:completed', missionId, playerId)
    end
end

-- Start a collection mission
CreateMissionPickups('evidence_collection', {
    { type = 'PICKUP_MONEY_CASE', coords = vector3(100, 100, 30), amount = 5000 },
    { type = 'PICKUP_HEALTH_STANDARD', coords = vector3(110, 100, 30), amount = 100 },
    { type = 'PICKUP_ARMOUR_STANDARD', coords = vector3(120, 100, 30), amount = 50 }
})
```

### Interactive Pickup Zones

```lua
local pickupZones = {}

function CreatePickupZone(center, radius, pickupType, spawnRate)
    local zoneId = #pickupZones + 1

    pickupZones[zoneId] = {
        center = center,
        radius = radius,
        pickupType = pickupType,
        spawnRate = spawnRate,
        lastSpawn = 0
    }

    return zoneId
end

function SpawnPickupsInZone(zoneId)
    local zone = pickupZones[zoneId]
    if not zone then return end

    local currentTime = GetGameTimer()
    if currentTime - zone.lastSpawn < zone.spawnRate then return end

    -- Random position within radius
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * zone.radius
    local spawnCoords = vector3(
        zone.center.x + math.cos(angle) * distance,
        zone.center.y + math.sin(angle) * distance,
        zone.center.z
    )

    local pickup = lib.pickups:create(zone.pickupType, spawnCoords, {
        maxUses = 1,
        onCollect = function(pickup, info, playerId)
            print("Zone pickup collected in zone", zoneId)
        end
    })

    if pickup then
        zone.lastSpawn = currentTime
    end
end

-- Create money spawn zone
local moneyZone = CreatePickupZone(
    vector3(200, 200, 30),  -- Center
    50,                      -- Radius
    'PICKUP_MONEY_CASE',    -- Type
    30000                   -- Spawn every 30 seconds
)

-- Monitor zones
CreateThread(function()
    while true do
        for zoneId, _ in pairs(pickupZones) do
            SpawnPickupsInZone(zoneId)
        end
        Wait(1000)
    end
end)
```

---

## 🎯 Integration Examples

### ESX Money System

```lua
-- Integrate with ESX money system
lib.pickups:onCollect('PICKUP_MONEY_CASE', function(pickup, info, playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.addMoney(info.amount)
        xPlayer.showNotification(('You picked up $%s'):format(info.amount))
    end
end)

-- ESX admin command to spawn money pickup
ESX.RegisterCommand('spawnmoney', 'admin', function(xPlayer, args, showError)
    local amount = tonumber(args.amount)
    if not amount then
        return showError('Invalid amount')
    end

    local coords = GetEntityCoords(GetPlayerPed(xPlayer.source))
    lib.pickups:createMoney(coords, amount)

    xPlayer.showNotification(('Spawned $%s pickup'):format(amount))
end, false, {
    help = 'Spawn a money pickup',
    validate = true,
    arguments = {
        { name = 'amount', help = 'Money amount', type = 'number' }
    }
})
```

### QB-Core Integration

```lua
-- Integrate with QB-Core
lib.pickups:onCollect('PICKUP_MONEY_CASE', function(pickup, info, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        Player.Functions.AddMoney('cash', info.amount)
        TriggerClientEvent('QBCore:Notify', playerId, ('You picked up $%s'):format(info.amount), 'success')
    end
end)

-- QB-Core job-specific pickups
RegisterNetEvent('police:createEvidencePickup', function(coords)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if Player.PlayerData.job.name == 'police' then
        local pickup = lib.pickups:create('PICKUP_MONEY_CASE', coords, {
            customModel = GetHashKey('prop_paper_bag_small'),
            maxUses = 1,
            onCollect = function(pickup, info, playerId)
                TriggerEvent('evidence:collected', playerId, coords)
            end
        })
    end
end)
```

---

## ⚠️ Important Notes

### Collection Detection

- Collection is automatically detected when pickups are moved or disappear
- Manual collection can be triggered with `collect()` function
- Collection callbacks are called safely with error handling

### Respawn System

- Respawn time is in milliseconds
- Set `respawnTime = 0` to disable respawning
- Respawned pickups maintain their collection count

### Performance

- Automatic cleanup prevents memory leaks
- Collection monitoring runs every second
- Use `removeAll()` for bulk cleanup

### Network Considerations

- Pickups are client-side by default
- Use appropriate network events for multiplayer synchronization
- Collection events should be validated server-side

### Best Practices

- Always validate pickup existence before operations
- Use appropriate pickup types for your use case
- Implement server-side validation for collections
- Clean up pickups when no longer needed

This Pickups API provides a comprehensive system for creating engaging collection mechanics in FiveM, with built-in respawning, tracking, and event systems that integrate seamlessly with existing frameworks.

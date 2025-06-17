# 🔗 Network API - ox_lib Extended

The Network API provides simplified and consistent network entity management across client/server environments. It automatically handles the confusion between `VehToNet`/`NetToVeh` and `NetworkGet*` natives, providing a unified interface that works the same way on both client and server.

## 📋 Key Features

- 🎯 **Unified API** - Same functions work on client and server
- 🔄 **Automatic Caching** - Intelligent caching of entity/network ID mappings
- ⚡ **Smart Detection** - Automatically chooses the best natives for each entity type
- 🧹 **Auto Cleanup** - Automatic cleanup of deleted entities
- 📊 **Error Handling** - Comprehensive error handling and logging
- 🔍 **Ownership Management** - Easy entity ownership tracking and control

---

## 🚀 Basic Usage

### Client & Server - Getting Network IDs

```lua
-- Works the same on client and server!
local vehicle = CreateVehicle(model, coords, heading, true, false)

-- Get network ID (handles VehToNet/PedToNet/ObjToNet automatically)
local netId = lib.network:getNetId(vehicle)
print("Network ID:", netId)

-- Get entity from network ID (handles NetToVeh/NetToPed/NetToObj automatically)
local entity = lib.network:getEntity(netId)
print("Entity handle:", entity)
```

### Client - Entity Validation

```lua
-- Check if entity exists and is networked
if lib.network:doesEntityExist(myVehicle) then
    print("Vehicle exists and is networked")
end

-- Check if network ID is valid
if lib.network:doesNetIdExist(myNetId) then
    print("Network ID is valid")
end
```

### Server - Entity Synchronization

```lua
-- Sync entity to network with options
local vehicle = CreateVehicle(model, coords, heading, false, false)
local netId = lib.network:sync(vehicle, {
    canMigrate = true,
    syncToPlayer = playerId
})

if netId then
    print("Vehicle synced with Network ID:", netId)
end
```

---

## 🖥️ Client-Side API

### Core Functions

#### `lib.network:getNetId(entity)`

Get Network ID from entity handle (works with vehicles, peds, objects).

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local netId = lib.network:getNetId(vehicle)

if netId then
    -- Send to server
    TriggerServerEvent('myResource:vehicleAction', netId)
end
```

#### `lib.network:getEntity(netId)`

Get entity handle from Network ID.

```lua
RegisterNetEvent('myResource:updateVehicle', function(netId, newColor)
    local vehicle = lib.network:getEntity(netId)

    if vehicle then
        SetVehicleCustomPrimaryColour(vehicle, newColor.r, newColor.g, newColor.b)
    end
end)
```

### Entity Information

#### `lib.network:getEntityInfo(entity)`

Get detailed network information about an entity.

```lua
local info = lib.network:getEntityInfo(myVehicle)
if info then
    print("Network ID:", info.netId)
    print("Owner:", info.owner)
    print("Created:", info.created)
end
```

#### `lib.network:getEntityOwner(entity)`

Get the player who owns the entity.

```lua
local owner = lib.network:getEntityOwner(myVehicle)
if owner == PlayerId() then
    print("I own this vehicle")
end
```

### Control Requests

#### `lib.network:requestControl(entity, timeout?)`

Request control of a networked entity.

```lua
-- Request control with 5 second timeout
if lib.network:requestControl(someVehicle, 5000) then
    -- Now we can modify the vehicle
    SetVehicleEngineOn(someVehicle, true, true, false)
end
```

#### `lib.network:requestControlOfNetId(netId, timeout?)`

Request control using Network ID.

```lua
RegisterNetEvent('takeControl', function(netId)
    if lib.network:requestControlOfNetId(netId, 3000) then
        local entity = lib.network:getEntity(netId)
        -- Do something with the entity
    end
end)
```

---

## 🖥️ Server-Side API

### Entity Synchronization

#### `lib.network:sync(entity, options?)`

Synchronize entity to network with advanced options.

```lua
-- Basic sync
local vehicle = CreateVehicle(model, coords, heading, false, false)
local netId = lib.network:sync(vehicle)

-- Advanced sync with options
local netId = lib.network:sync(vehicle, {
    canMigrate = true,        -- Allow migration between players
    syncToPlayer = playerId,  -- Sync to specific player
    autoCleanup = true        -- Auto cleanup when deleted
})
```

#### `lib.network:syncToPlayer(entity, playerId, sync?)`

Sync entity to specific player.

```lua
-- Sync vehicle to player
lib.network:syncToPlayer(myVehicle, playerId, true)

-- Unsync from player
lib.network:syncToPlayer(myVehicle, playerId, false)
```

#### `lib.network:syncToAllPlayers(entity, sync?)`

Sync entity to all players.

```lua
-- Sync to everyone
lib.network:syncToAllPlayers(myVehicle, true)

-- Unsync from everyone
lib.network:syncToAllPlayers(myVehicle, false)
```

### Entity Management

#### `lib.network:getEntityData(entity)`

Get detailed sync data for an entity.

```lua
local data = lib.network:getEntityData(myVehicle)
if data then
    print("Network ID:", data.netId)
    print("Owner:", data.owner)
    print("Players synced:", json.encode(data.players))
end
```

#### `lib.network:unsync(entity, deleteEntity?)`

Remove entity from network synchronization.

```lua
-- Just unsync (keep entity)
lib.network:unsync(myVehicle, false)

-- Unsync and delete
lib.network:unsync(myVehicle, true)
```

### Ownership Management

#### `lib.network:setEntityOwner(entity, playerId)`

Set entity owner.

```lua
-- Transfer ownership to player
lib.network:setEntityOwner(myVehicle, newOwnerId)
```

---

## 🔧 Advanced Examples

### Cross-Client Vehicle Spawning

**Server:**

```lua
RegisterNetEvent('spawnVehicleForAll', function(model, coords)
    local source = source

    -- Spawn vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, false, false)

    -- Sync to network
    local netId = lib.network:sync(vehicle, {
        canMigrate = true
    })

    if netId then
        -- Send to all clients
        TriggerClientEvent('vehicleSpawned', -1, netId, coords)
    end
end)
```

**Client:**

```lua
RegisterNetEvent('vehicleSpawned', function(netId, coords)
    -- Wait for entity to exist locally
    local timeout = GetGameTimer() + 5000
    local vehicle = nil

    while GetGameTimer() < timeout do
        vehicle = lib.network:getEntity(netId)
        if vehicle then break end
        Wait(100)
    end

    if vehicle then
        print("Vehicle spawned at:", coords)
        -- Do something with the vehicle
    else
        print("Failed to get vehicle entity")
    end
end)
```

### Smart Entity Sharing

**Server:**

```lua
-- Share entity between specific players
function ShareEntityBetweenPlayers(entity, playerIds)
    local netId = lib.network:sync(entity)

    if netId then
        -- Sync only to specified players
        for _, playerId in ipairs(playerIds) do
            lib.network:syncToPlayer(entity, playerId, true)
        end

        return netId
    end

    return nil
end

-- Usage
local sharedVehicle = CreateVehicle(model, coords, heading, false, false)
local netId = ShareEntityBetweenPlayers(sharedVehicle, {1, 2, 3})
```

### Automatic Ownership Transfer

**Server:**

```lua
-- Monitor and transfer ownership when player leaves
AddEventHandler('playerDropped', function(reason)
    local playerId = source

    -- Get all entities owned by disconnecting player
    for entity, data in pairs(lib.network:getAllSyncedEntities()) do
        if data.owner == playerId then
            -- Find nearest player to transfer ownership
            local entityCoords = GetEntityCoords(entity)
            local nearestPlayer = GetNearestPlayer(entityCoords)

            if nearestPlayer then
                lib.network:setEntityOwner(entity, nearestPlayer)
                print(("Transferred entity %s from %s to %s"):format(entity, playerId, nearestPlayer))
            else
                -- No players nearby, remove entity
                lib.network:unsync(entity, true)
            end
        end
    end
end)
```

### Client-Side Entity Validation

```lua
-- Validate entities before operations
function SafeEntityOperation(netId, operation)
    -- Validate network ID
    if not lib.network:doesNetIdExist(netId) then
        print("Invalid network ID:", netId)
        return false
    end

    -- Get entity
    local entity = lib.network:getEntity(netId)
    if not entity then
        print("Could not get entity for network ID:", netId)
        return false
    end

    -- Check if we can control it
    if not lib.network:requestControl(entity, 2000) then
        print("Could not gain control of entity")
        return false
    end

    -- Perform operation
    return operation(entity)
end

-- Usage
SafeEntityOperation(vehicleNetId, function(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    return true
end)
```

---

## ⚠️ Important Notes

### Network ID Consistency

- Network IDs remain consistent across clients and server
- Use Network IDs for cross-client communication
- Entity handles are local to each client

### Error Handling

- All functions include comprehensive error checking
- Invalid entities/network IDs return `nil`
- Check return values before proceeding with operations

### Performance

- Functions use intelligent caching for better performance
- Automatic cleanup prevents memory leaks
- Minimal overhead on native calls

### Best Practices

- Always validate entities before operations
- Use Network IDs for client-server communication
- Request control before modifying networked entities
- Clean up entities when no longer needed

---

## 🤝 Integration Examples

### ESX Integration

```lua
-- Server-side vehicle creation with network sync
ESX.RegisterServerCallback('esx:spawnVehicle', function(source, cb, model, coords)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, false, false)
    local netId = lib.network:sync(vehicle, {
        canMigrate = true,
        syncToPlayer = source
    })

    cb(netId)
end)
```

### QB-Core Integration

```lua
-- Client-side with QB-Core
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    -- Request owned vehicles to be synced
    QBCore.Functions.TriggerCallback('vehicles:getOwned', function(vehicles)
        for _, vehicle in pairs(vehicles) do
            if lib.network:doesNetIdExist(vehicle.netId) then
                -- Vehicle exists, get entity
                local entity = lib.network:getEntity(vehicle.netId)
                if entity then
                    print("Found owned vehicle:", GetDisplayNameFromVehicleModel(GetEntityModel(entity)))
                end
            end
        end
    end)
end)
```

This Network API eliminates the common confusion and errors developers face when working with networked entities in FiveM, providing a reliable and consistent interface across all environments.

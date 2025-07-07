-- ================================================================================================
-- VEHICLE HOOKS USAGE EXAMPLES
-- This file demonstrates how to use the hooks system with the vehicle module
-- ================================================================================================

-- ================================================================================================
-- EXAMPLE 1: VEHICLE CREATION HOOKS
-- ================================================================================================

-- Register hook to intercept vehicle creation
lib.hooks.register('vehicle:before_create', function(model, coords, heading, options)
    print('[Vehicle Hook] Attempting to create vehicle:', model)
    
    -- Log vehicle creation with coordinates
    local player = source or 'system'
    print(('Player %s is creating vehicle %s at %s'):format(player, model, coords))
    
    -- Example: Prevent certain vehicles from being created
    local restrictedVehicles = {
        'rhino',        -- Tank
        'lazer',        -- Fighter jet
        'hydra',        -- Attack helicopter
        'oppressor2'    -- MK2 Oppressor
    }
    
    local modelName = type(model) == 'string' and model:lower() or GetDisplayNameFromVehicleModel(model):lower()
    
    for _, restricted in ipairs(restrictedVehicles) do
        if modelName == restricted then
            print('[Vehicle Hook] Blocked creation of restricted vehicle:', modelName)
            return false -- Prevent vehicle creation
        end
    end
    
    -- Example: Limit vehicle creation in certain areas
    if coords and coords.z > 500 then
        print('[Vehicle Hook] Blocked vehicle creation at high altitude')
        return false
    end
    
    return true -- Allow vehicle creation
end, 10) -- High priority

-- Hook to log successful vehicle creations
lib.hooks.register('vehicle:after_create', function(vehicleInstance, model, coords, heading, options)
    print('[Vehicle Hook] Vehicle created successfully:', model, 'Entity:', vehicleInstance.vehicle)
    
    -- Example: Auto-apply properties to certain vehicles
    if type(model) == 'string' and model:lower() == 'police' then
        -- Auto-apply police properties
        vehicleInstance:setProperties({
            modHorns = 1,
            modEngine = 2,
            modTransmission = 2
        })
        print('[Vehicle Hook] Applied police vehicle modifications')
    end
    
    -- Example: Log to Discord
    if lib.discord then
        local adminDiscord = lib.discord:new('ADMIN_WEBHOOK')
        adminDiscord:sendInfo('Vehicle Created', 
            ('Vehicle: %s\nCoords: %s\nEntity: %s'):format(model, coords, vehicleInstance.vehicle))
    end
end, 5)

-- ================================================================================================
-- EXAMPLE 2: VEHICLE REPAIR HOOKS
-- ================================================================================================

-- Register hook to control vehicle repairs
lib.hooks.register('vehicle:before_repair', function(vehicleEntity, vehicleInstance)
    print('[Vehicle Hook] Attempting to repair vehicle:', vehicleEntity)
    
    -- Example: Check if player has permission to repair
    local nearbyPlayers = {}
    local vehicleCoords = GetEntityCoords(vehicleEntity)
    
    -- Find players near the vehicle
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        
        if #(vehicleCoords - playerCoords) < 5.0 then
            table.insert(nearbyPlayers, playerId)
        end
    end
    
    -- Check if any nearby player has mechanic job
    for _, playerId in ipairs(nearbyPlayers) do
        local player = lib.core.player(playerId)
        if player and player.job == 'mechanic' then
            print('[Vehicle Hook] Mechanic player found, allowing repair')
            return true
        end
    end
    
    -- Example: Allow repair if vehicle is in garage area
    local garageZones = {
        { coords = vector3(-337.0, -136.0, 39.0), radius = 50.0 }, -- Los Santos Customs
        { coords = vector3(731.0, -1088.0, 22.0), radius = 30.0 }  -- Another garage
    }
    
    for _, zone in ipairs(garageZones) do
        if #(vehicleCoords - zone.coords) <= zone.radius then
            print('[Vehicle Hook] Vehicle in garage zone, allowing repair')
            return true
        end
    end
    
    print('[Vehicle Hook] No mechanic nearby and not in garage, blocking repair')
    return false -- Prevent repair
end, 10)

-- Hook to log vehicle repairs
lib.hooks.register('vehicle:after_repair', function(vehicleEntity, vehicleInstance)
    print('[Vehicle Hook] Vehicle repaired successfully:', vehicleEntity)
    
    -- Example: Charge player for repair
    local vehicleCoords = GetEntityCoords(vehicleEntity)
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        
        if #(vehicleCoords - playerCoords) < 5.0 then
            local repairCost = 500
            if lib.core.wallet(playerId, 'bank') >= repairCost then
                lib.core.walletRemove(playerId, repairCost, 'bank')
                lib.core.notify(playerId, ('Vehicle repaired! Cost: $%d'):format(repairCost), 'success')
            end
            break
        end
    end
end)

-- ================================================================================================
-- EXAMPLE 3: VEHICLE DELETION HOOKS
-- ================================================================================================

-- Register hook to control vehicle deletion
lib.hooks.register('vehicle:before_delete', function(vehicleEntity, vehicleInstance)
    print('[Vehicle Hook] Attempting to delete vehicle:', vehicleEntity)
    
    -- Example: Prevent deletion of vehicles with players inside
    local occupants = vehicleInstance:getOccupants()
    local hasPlayers = false
    
    for seatIndex, ped in pairs(occupants) do
        if ped and ped ~= 0 then
            local playerId = NetworkGetPlayerIndexFromPed(ped)
            if playerId and playerId ~= -1 then
                hasPlayers = true
                break
            end
        end
    end
    
    if hasPlayers then
        print('[Vehicle Hook] Blocked deletion: Vehicle has players inside')
        return false
    end
    
    -- Example: Special handling for emergency vehicles
    local model = GetEntityModel(vehicleEntity)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    local emergencyVehicles = { 'POLICE', 'AMBULANCE', 'FIRETRUK' }
    for _, emergency in ipairs(emergencyVehicles) do
        if modelName == emergency then
            print('[Vehicle Hook] Deleting emergency vehicle:', modelName)
            -- Could add special logging or notifications here
            break
        end
    end
    
    return true -- Allow deletion
end)

-- ================================================================================================
-- EXAMPLE 4: PLAYER VEHICLE ENTRY HOOKS
-- ================================================================================================

-- Register hook to control player vehicle entry
lib.hooks.register('vehicle:before_set_player', function(vehicleEntity, vehicleInstance, playerId, seat)
    print('[Vehicle Hook] Player', playerId, 'attempting to enter vehicle:', vehicleEntity, 'seat:', seat)
    
    -- Example: Check if player has vehicle keys
    local player = lib.core.player(playerId)
    if not player then return false end
    
    -- Example: Check if vehicle is locked
    if vehicleInstance:isLocked() then
        -- Check if player has keys (example using metadata)
        local playerKeys = player.metadata and player.metadata.vehicle_keys or {}
        local vehicleKey = tostring(vehicleEntity)
        
        if not playerKeys[vehicleKey] then
            lib.core.notify(playerId, 'Vehicle is locked and you don\'t have keys!', 'error')
            return false
        end
    end
    
    -- Example: Job-restricted vehicles
    local model = GetEntityModel(vehicleEntity)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    if modelName == 'POLICE' and player.job ~= 'police' then
        lib.core.notify(playerId, 'You need to be a police officer to use this vehicle!', 'error')
        return false
    end
    
    if modelName == 'AMBULANCE' and player.job ~= 'ambulance' then
        lib.core.notify(playerId, 'You need to be a paramedic to use this vehicle!', 'error')
        return false
    end
    
    return true -- Allow entry
end, 10)

-- Hook to handle successful vehicle entry
lib.hooks.register('vehicle:after_set_player', function(vehicleEntity, vehicleInstance, playerId, seat, ped)
    print('[Vehicle Hook] Player', playerId, 'entered vehicle successfully')
    
    -- Example: Start engine if player enters driver seat
    if seat == -1 then -- Driver seat
        vehicleInstance:setEngineOn(true, true)
        lib.core.notify(playerId, 'Engine started automatically', 'info')
    end
    
    -- Example: Apply seat belt effect
    lib.core.notify(playerId, 'Remember to fasten your seatbelt!', 'info')
end)

-- ================================================================================================
-- EXAMPLE 5: VEHICLE EXPLOSION HOOKS
-- ================================================================================================

-- Register hook to control vehicle explosions
lib.hooks.register('vehicle:before_explode', function(vehicleEntity, vehicleInstance, damageSource, hasEntityDamage)
    print('[Vehicle Hook] Vehicle about to explode:', vehicleEntity)
    
    -- Example: Prevent explosions in safe zones
    local vehicleCoords = GetEntityCoords(vehicleEntity)
    local safeZones = {
        { coords = vector3(-1037.0, -2737.0, 20.0), radius = 100.0 }, -- Airport
        { coords = vector3(274.0, -343.0, 45.0), radius = 50.0 }       -- Hospital
    }
    
    for _, zone in ipairs(safeZones) do
        if #(vehicleCoords - zone.coords) <= zone.radius then
            print('[Vehicle Hook] Blocked explosion in safe zone')
            return false
        end
    end
    
    -- Example: Notify nearby players about explosion
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        
        local distance = #(vehicleCoords - playerCoords)
        if distance < 100.0 then
            lib.core.notify(playerId, 'DANGER: Vehicle explosion nearby!', 'error')
        end
    end
    
    return true -- Allow explosion
end)

-- ================================================================================================
-- EXAMPLE 6: COMPLEX HOOK WITH CUSTOM HANDLER
-- ================================================================================================

-- Register multiple validation hooks
lib.hooks.register('vehicle:validation', function(action, vehicleData)
    local validation = { passed = true, reason = nil }
    
    -- Validate coordinates
    if vehicleData.coords and vehicleData.coords.z < -100 then
        validation.passed = false
        validation.reason = 'Invalid coordinates (underwater)'
    end
    
    return validation
end, 10)

lib.hooks.register('vehicle:validation', function(action, vehicleData)
    local validation = { passed = true, reason = nil }
    
    -- Validate model
    if not IsModelValid(vehicleData.model) then
        validation.passed = false
        validation.reason = 'Invalid vehicle model'
    end
    
    return validation
end, 5)

-- Use custom handler to process all validation results
local function validateVehicleAction(action, vehicleData)
    local results = {}
    
    lib.hooks.triggerWithHandler('vehicle:validation', function(...)
        local validations = {...}
        local allPassed = true
        local reasons = {}
        
        for _, validation in ipairs(validations) do
            if validation and not validation.passed then
                allPassed = false
                table.insert(reasons, validation.reason)
            end
        end
        
        return {
            success = allPassed,
            reasons = reasons
        }
    end, action, vehicleData)
end

-- ================================================================================================
-- EXAMPLE USAGE IN COMMANDS
-- ================================================================================================

RegisterCommand('spawncar', function(source, args)
    local model = args[1] or 'adder'
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    -- This will trigger the hooks we registered above
    local vehicle = lib.vehicle.create(model, coords, 0.0, {
        plate = 'HOOK-' .. source
    })
    
    if vehicle then
        print('Vehicle created with hooks validation:', vehicle.vehicle)
        lib.core.notify(source, 'Vehicle spawned successfully!', 'success')
    else
        lib.core.notify(source, 'Vehicle creation was blocked by hooks!', 'error')
    end
end)

RegisterCommand('repaircar', function(source)
    local vehicle = lib.vehicle.getPlayerVehicle(source)
    
    if vehicle then
        local success = vehicle:repair() -- This will trigger repair hooks
        if success then
            lib.core.notify(source, 'Vehicle repaired!', 'success')
        else
            lib.core.notify(source, 'Repair was blocked!', 'error')
        end
    else
        lib.core.notify(source, 'You must be in a vehicle!', 'error')
    end
end)

-- ================================================================================================
-- UTILITY FUNCTIONS FOR HOOK MANAGEMENT
-- ================================================================================================

RegisterCommand('listhooks', function(source)
    if not IsPlayerAceAllowed(source, 'admin.hooks') then
        return
    end
    
    local allHooks = lib.hooks.getRegistered()
    print('=== REGISTERED HOOKS ===')
    for hookName, count in pairs(allHooks) do
        print(('Hook: %s - Callbacks: %d'):format(hookName, count))
    end
end)

RegisterCommand('clearhooks', function(source, args)
    if not IsPlayerAceAllowed(source, 'admin.hooks') then
        return
    end
    
    local hookName = args[1]
    if hookName then
        lib.hooks.clear(hookName)
        print('Cleared hooks for:', hookName)
    end
end) 
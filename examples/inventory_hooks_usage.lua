--[[
    Example: Using inventory hooks with ox_lib wrapper

    This example demonstrates how to use the hooks system for inventory operations.
    Works with any inventory system that has hooks implemented (ox_inventory, qb-inventory, etc.).
    All hooks must be registered on the server side.

    Credits: Hooks system design inspired by ox_inventory by Overextended
]]

-- Example 1: Basic inventory hooks
if IsDuplicityVersion() then
    -- Hook for when items are added to inventory
    lib.inventory.registerHook('addItem', function(data)
        print(('Player %s is adding item %s (x%s)'):format(data.source, data.item, data.count))

        -- Prevent adding certain items during specific times
        if data.item == 'weapon_pistol' and GetGameTimer() < 300000 then -- First 5 minutes
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'Weapons are disabled during the first 5 minutes'
            })
            return false -- Cancel the operation
        end

        return true -- Allow the operation
    end)

    -- Hook for after items are successfully added
    lib.inventory.registerHook('afterAddItem', function(data, result)
        print(('Successfully added %s (x%s) to player %s'):format(data.item, data.count, data.source))

        -- Log important items
        if data.item == 'money' and data.count > 10000 then
            print(('LARGE MONEY ADD: Player %s received $%s'):format(data.source, data.count))
        end
    end)

    -- Hook for item removal validation
    lib.inventory.registerHook('removeItem', function(data)
        print(('Player %s is removing item %s (x%s)'):format(data.source, data.item, data.count))

        -- Prevent removing essential items
        if data.item == 'id_card' then
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'You cannot drop your ID card'
            })
            return false
        end

        return true
    end)

    -- Hook for after items are successfully removed
    lib.inventory.registerHook('afterRemoveItem', function(data, result)
        print(('Successfully removed %s (x%s) from player %s'):format(data.item, data.count, data.source))
    end)

    -- Hook for giving items between players (if supported by inventory)
    lib.inventory.registerHook('giveItem', function(data)
        print(('Player %s giving %s (x%s) to player %s'):format(data.source, data.item, data.count, data.target))

        -- Prevent giving weapons to new players
        local targetPlayTime = GetPlayerRoutingBucket(data.target) -- Example check
        if data.item:match('weapon_') and targetPlayTime < 3600 then
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'Cannot give weapons to new players'
            })
            return false
        end

        return true
    end)

    -- Hook for clearing inventory
    lib.inventory.registerHook('clearInventory', function(data)
        print(('Player %s is clearing inventory (keep: %s)'):format(data.source, tostring(data.keep)))

        -- Require admin permission for clearing inventory
        local player = lib.core.getPlayerData(data.source)
        if not player or player.group ~= 'admin' then
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'Only admins can clear inventory'
            })
            return false
        end

        return true
    end)

    -- Hook for slot swapping (if supported by inventory like ox_inventory)
    if lib.inventory.registerHook then
        pcall(function()
            lib.inventory.registerHook('swapSlots', function(data)
                print(('Player %s swapping slots %s->%s'):format(data.source, data.fromSlot, data.toSlot))
                return true -- Allow all slot swaps by default
            end)
        end)
    end
end

-- Example 2: Advanced validation hooks
if IsDuplicityVersion() then
    -- Anti-duplication hook
    lib.inventory.registerHook('addItem', function(data)
        -- Check for suspicious rapid item additions
        local playerId = tostring(data.source)
        local currentTime = GetGameTimer()

        if not GlobalState.lastItemAdd then
            GlobalState.lastItemAdd = {}
        end

        local lastAdd = GlobalState.lastItemAdd[playerId] or 0
        if currentTime - lastAdd < 100 then -- Less than 100ms since last add
            print(('ANTI-CHEAT: Rapid item addition detected for player %s'):format(data.source))
            return false
        end

        GlobalState.lastItemAdd[playerId] = currentTime
        return true
    end)

    -- Item limit validation
    lib.inventory.registerHook('addItem', function(data)
        -- Limit certain items per player
        local itemLimits = {
            weapon_pistol = 1,
            weapon_rifle = 1,
            lockpick = 5
        }

        local limit = itemLimits[data.item]
        if limit then
            local currentCount = lib.inventory.getItemCount(data.source, data.item)
            if currentCount + (data.count or 1) > limit then
                TriggerClientEvent('ox_lib:notify', data.source, {
                    type = 'error',
                    description = ('You can only carry %s %s'):format(limit, data.item)
                })
                return false
            end
        end

        return true
    end)

    -- Economy tracking
    lib.inventory.registerHook('addItem', function(data)
        if data.item == 'money' then
            local logData = {
                player = data.source,
                action = 'money_add',
                amount = data.count,
                timestamp = os.time()
            }
            print(('MONEY LOG: %s'):format(json.encode(logData)))
        end
        return true
    end)
end

-- Example 3: Shop integration (for inventories that support shops)
if IsDuplicityVersion() then
    -- Hook for buying items (ox_inventory specific)
    if lib.inventory.registerHook then
        pcall(function()
            lib.inventory.registerHook('buyItem', function(data)
                print(('Player %s buying %s (x%s) for $%s'):format(
                    data.source, data.item, data.count, data.price or 'unknown'
                ))

                -- Apply VIP discounts
                local player = lib.core.getPlayerData(data.source)
                if player and player.group == 'vip' then
                    data.price = math.floor((data.price or 0) * 0.9) -- 10% discount
                    print(('VIP discount applied: New price $%s'):format(data.price))
                end

                return true
            end)

            lib.inventory.registerHook('afterBuyItem', function(data, result)
                print(('Purchase completed: %s bought %s'):format(data.source, data.item))

                -- Award loyalty points
                local points = math.floor((data.price or 0) / 100)
                if points > 0 then
                    print(('Player %s earned %s loyalty points'):format(data.source, points))
                end
            end)
        end)
    end
end

-- Example 4: Event-based hook management
if IsDuplicityVersion() then
    -- Dynamic hook registration
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == 'your_anticheat_resource' then
            lib.inventory.registerHook('addItem', function(data)
                return validateItemAdd(data)
            end)
        end
    end)

    -- Clean up hooks when resources stop
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == 'your_anticheat_resource' then
            lib.inventory.clearHooks('addItem')
        end
    end)
end

-- Example 5: Multi-inventory compatibility check
if IsDuplicityVersion() then
    -- Check which inventory system is being used and adjust accordingly
    CreateThread(function()
        Wait(1000) -- Wait for all systems to initialize

        if lib.inventory.registerHook then
            print('Inventory hooks system is available')

            -- Test which hooks are supported
            local supportedHooks = {
                'addItem',
                'removeItem',
                'afterAddItem',
                'afterRemoveItem',
                'giveItem',
                'clearInventory'
            }

            for _, hookName in ipairs(supportedHooks) do
                local success = pcall(function()
                    lib.inventory.registerHook(hookName, function() return true end)
                    lib.inventory.removeHook(hookName, function() return true end)
                end)

                if success then
                    print(('Hook %s is supported'):format(hookName))
                else
                    print(('Hook %s is not supported'):format(hookName))
                end
            end
        else
            print('Inventory hooks system is not available with current inventory')
        end
    end)
end

-- Example helper functions (server-side only)
if IsDuplicityVersion() then
    function validateItemAdd(data)
        local playerMoney = lib.inventory.getItemCount(data.source, 'money')

        if data.item == 'expensive_item' and playerMoney < 50000 then
            TriggerClientEvent('ox_lib:notify', data.source, {
                type = 'error',
                description = 'You need $50,000 to obtain this item'
            })
            return false
        end

        return true
    end

    -- Helper function to safely register hooks (handles compatibility)
    function registerInventoryHook(hookName, callback)
        if lib.inventory.registerHook then
            return lib.inventory.registerHook(hookName, callback)
        else
            print(('Warning: Hook %s not supported by current inventory system'):format(hookName))
            return false
        end
    end
end

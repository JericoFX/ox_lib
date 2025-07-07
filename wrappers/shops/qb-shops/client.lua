-- local Shops = lib.class('shops')
-- local Normalizer = require 'wrappers.normalizer'

-- function Shops:constructor()
-- self.system = 'qb-shops'
-- end

-- -- Create a new shop
-- function Shops:createShop(shopData)
-- if not shopData or not shopData.name then
-- print('[qb-shops] Error: Shop data or name is missing')
-- return false
-- end

-- -- Format shop data for qb-inventory compatibility
-- local formattedData = {
-- name = shopData.name,
-- label = shopData.label or shopData.name,
-- coords = shopData.coords,
-- slots = shopData.slots or #(shopData.items or {}),
-- items = shopData.items or {}
-- }

-- -- Use qb-inventory export if available
-- if GetResourceState('qb-inventory') == 'started' then
-- local success, result = pcall(function()
--     return exports['qb-inventory']:CreateShop(formattedData)
-- end)
-- if success then
--     print('[qb-shops] Shop created successfully: ' .. shopData.name)
--     return true
-- else
--     print('[qb-shops] Failed to create shop using qb-inventory export: ' .. tostring(result))
-- end
-- end

-- -- Fallback to event-based creation
-- TriggerServerEvent('qb-shops:server:CreateShop', formattedData)
-- return true
-- end

-- -- Open a shop
-- function Shops:openShop(shopName, playerSource)
-- if not shopName then
-- print('[qb-shops] Error: Shop name is required')
-- return false
-- end

-- -- Use qb-inventory export if available
-- if GetResourceState('qb-inventory') == 'started' then
-- local success, result = pcall(function()
--     return exports['qb-inventory']:OpenShop(playerSource or cache.serverId, shopName)
-- end)
-- if success then
--     return true
-- else
--     print('[qb-shops] Failed to open shop using qb-inventory export: ' .. tostring(result))
-- end
-- end

-- -- Fallback to event-based opening
-- TriggerServerEvent('qb-shops:server:OpenShop', shopName)
-- return true
-- end

-- -- Add item to shop
-- function Shops:addShopItem(shopName, itemData)
-- if not shopName or not itemData then
-- print('[qb-shops] Error: Shop name and item data are required')
-- return false
-- end

-- local formattedItem = {
-- name = itemData.name,
-- amount = itemData.amount or 10,
-- price = itemData.price or 1
-- }

-- TriggerServerEvent('qb-shops:server:AddShopItem', shopName, formattedItem)
-- return true
-- end

-- -- Remove item from shop
-- function Shops:removeShopItem(shopName, itemName)
-- if not shopName or not itemName then
-- print('[qb-shops] Error: Shop name and item name are required')
-- return false
-- end

-- TriggerServerEvent('qb-shops:server:RemoveShopItem', shopName, itemName)
-- return true
-- end

-- -- Update shop item
-- function Shops:updateShopItem(shopName, itemName, updateData)
-- if not shopName or not itemName or not updateData then
-- print('[qb-shops] Error: Shop name, item name and update data are required')
-- return false
-- end

-- TriggerServerEvent('qb-shops:server:UpdateShopItem', shopName, itemName, updateData)
-- return true
-- end

-- -- Get shop data
-- function Shops:getShop(shopName)
-- if not shopName then
-- print('[qb-shops] Error: Shop name is required')
-- return nil
-- end

-- -- This would need to be implemented server-side with a callback
-- local promise = promise.new()
-- TriggerServerEvent('qb-shops:server:GetShop', shopName, function(shopData)
-- promise:resolve(shopData)
-- end)
-- return Citizen.Await(promise)
-- end

-- -- Delete shop
-- function Shops:deleteShop(shopName)
-- if not shopName then
-- print('[qb-shops] Error: Shop name is required')
-- return false
-- end

-- TriggerServerEvent('qb-shops:server:DeleteShop', shopName)
-- return true
-- end

-- -- Get all shops
-- function Shops:getAllShops()
-- local promise = promise.new()
-- TriggerServerEvent('qb-shops:server:GetAllShops', function(shopsData)
-- promise:resolve(shopsData)
-- end)
-- return Citizen.Await(promise)
-- end

-- -- Buy item from shop
-- function Shops:buyItem(shopName, itemName, amount)
-- if not shopName or not itemName then
-- print('[qb-shops] Error: Shop name and item name are required')
-- return false
-- end

-- TriggerServerEvent('qb-shops:server:BuyItem', shopName, itemName, amount or 1)
-- return true
-- end

-- -- Check if shop exists
-- function Shops:shopExists(shopName)
-- if not shopName then return false end

-- local shopData = self:getShop(shopName)
-- return shopData ~= nil
-- end

-- -- Create shop with items easily
-- function Shops:createQuickShop(name, label, coords, items)
-- local shopData = {
-- name = name,
-- label = label,
-- coords = coords,
-- items = items or {},
-- slots = #(items or {})
-- }

-- return self:createShop(shopData)
-- end

-- -- Register implementation in Normalizer ------------------------------------
-- Normalizer.shops.createShop      = function(...) return Shops:createShop(...) end
-- Normalizer.shops.openShop        = function(...) return Shops:openShop(...) end
-- Normalizer.shops.addShopItem     = function(...) return Shops:addShopItem(...) end
-- Normalizer.shops.removeShopItem  = function(...) return Shops:removeShopItem(...) end
-- Normalizer.shops.updateShopItem  = function(...) return Shops:updateShopItem(...) end
-- Normalizer.shops.getShop         = function(...) return Shops:getShop(...) end
-- Normalizer.shops.deleteShop      = function(...) return Shops:deleteShop(...) end
-- Normalizer.shops.getAllShops     = function(...) return Shops:getAllShops(...) end
-- Normalizer.shops.buyItem         = function(...) return Shops:buyItem(...) end
-- Normalizer.shops.shopExists      = function(...) return Shops:shopExists(...) end
-- Normalizer.shops.createQuickShop = function(...) return Shops:createQuickShop(...) end
-- Normalizer.capabilities.shops    = true

-- return Shops

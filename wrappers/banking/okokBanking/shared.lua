-- --[[
--     OkOk Banking Functions
-- ]]

-- return {
--     addMoney = function(source, account, amount)
--         if lib.context == 'server' then
--             local player = lib.core.getPlayer(source)
--             if not player then return false end

--             exports['okokBanking']:AddMoney(player.PlayerData.citizenid, amount)
--             return true
--         end
--     end,

--     removeMoney = function(source, account, amount)
--         if lib.context == 'server' then
--             local player = lib.core.getPlayer(source)
--             if not player then return false end

--             exports['okokBanking']:RemoveMoney(player.PlayerData.citizenid, amount)
--             return true
--         end
--     end,

--     getMoney = function(source, account)
--         if lib.context == 'server' then
--             local player = lib.core.getPlayer(source)
--             if not player then return 0 end

--             return exports['okokBanking']:GetAccount(player.PlayerData.citizenid)
--         end
--         return 0
--     end,

--     transferMoney = function(fromSource, toSource, amount)
--         if lib.context == 'server' then
--             local fromPlayer = lib.core.getPlayer(fromSource)
--             local toPlayer = lib.core.getPlayer(toSource)

--             if not fromPlayer or not toPlayer then return false end

--             local success = exports['okokBanking']:RemoveMoney(fromPlayer.PlayerData.citizenid, amount)
--             if success then
--                 exports['okokBanking']:AddMoney(toPlayer.PlayerData.citizenid, amount)
--                 return true
--             end
--         end
--         return false
--     end,

--     createAccount = function(source, accountName, accountType)
--         if lib.context == 'server' then
--             local player = lib.core.getPlayer(source)
--             if not player then return false end

--             exports['okokBanking']:CreateAccount(player.PlayerData.citizenid, accountName, accountType)
--             return true
--         end
--     end,

--     addTransaction = function(source, account, amount, reason, type)
--         if lib.context == 'server' then
--             local player = lib.core.getPlayer(source)
--             if not player then return false end

--             exports['okokBanking']:AddTransaction(player.PlayerData.citizenid, amount, reason, type)
--             return true
--         end
--     end,

--     openBanking = function()
--         if lib.context == 'client' then
--             TriggerEvent('okokBanking:openBankMenu')
--         end
--     end,

--     closeBanking = function()
--         if lib.context == 'client' then
--             TriggerEvent('okokBanking:closeBankMenu')
--         end
--     end,

--     isBankingOpen = function()
--         if lib.context == 'client' then
--             return exports['okokBanking']:isBankOpen()
--         end
--         return false
--     end
-- }

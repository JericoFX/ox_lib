-- --[[
--     Task API - Server Functions
--     Tabla de funciones que se agregan a lib.task
-- ]]

-- local Task = {}

-- -- =====================================
-- -- FUNCIONES VALIDACION
-- -- =====================================

-- -- Validar identificador de jugador
-- function Task.isValidPlayerId(playerId)
--     return type(playerId) == 'number' and playerId > 0
-- end

-- -- Validar entity handle
-- function Task.isValidEntity(entity)
--     return type(entity) == 'number' and entity > 0 and DoesEntityExist(entity)
-- end

-- -- =====================================
-- -- FUNCIONES TAREAS
-- -- =====================================

-- -- Limpiar tareas de un jugador
-- function Task.clearPlayerTasks(source)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         ClearPedTasks(ped)
--         return true
--     end

--     return false
-- end

-- -- Limpiar tareas inmediatamente
-- function Task.clearPlayerTasksImmediately(source)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         ClearPedTasksImmediately(ped)
--         return true
--     end

--     return false
-- end

-- -- Asignar tarea de caminar a coordenadas
-- function Task.setPlayerGoToCoord(source, coords, speed)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
--         return false
--     end

--     speed = speed or 1.0

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskGoToCoordAnyMeans(ped, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], speed, 0, false, 786603, 0.0)
--         return true
--     end

--     return false
-- end

-- -- Congelar jugador en su lugar
-- function Task.freezePlayer(source, toggle)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         FreezeEntityPosition(ped, toggle == true)
--         return true
--     end

--     return false
-- end

-- -- Asignar scenario al jugador
-- function Task.setPlayerScenario(source, scenario, duration)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     if type(scenario) ~= 'string' then
--         return false
--     end

--     duration = duration or -1

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskStartScenarioInPlace(ped, scenario, duration, true)
--         return true
--     end

--     return false
-- end

-- -- Hacer que el jugador levante las manos
-- function Task.setPlayerHandsUp(source, duration)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     duration = duration or -1

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskHandsUp(ped, duration, 0, -1, false)
--         return true
--     end

--     return false
-- end

-- -- Asignar tarea de entrar en vehículo
-- function Task.setPlayerEnterVehicle(source, vehicle, seat, timeout)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     if not Task.isValidEntity(vehicle) then
--         return false
--     end

--     seat = seat or -1
--     timeout = timeout or -1

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskEnterVehicle(ped, vehicle, timeout, seat, 1.0, 1, 0)
--         return true
--     end

--     return false
-- end

-- -- Asignar tarea de salir del vehículo
-- function Task.setPlayerLeaveVehicle(source, vehicle, flags)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     flags = flags or 0

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskLeaveVehicle(ped, vehicle or 0, flags)
--         return true
--     end

--     return false
-- end

-- -- Verificar si el jugador está realizando una tarea específica
-- function Task.isPlayerDoingTask(source, taskHash)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         return GetScriptTaskStatus(ped, taskHash) ~= 7
--     end

--     return false
-- end

-- -- Obtener tarea actual del jugador
-- function Task.getPlayerCurrentTask(source)
--     if not Task.isValidPlayerId(source) then
--         return nil
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         return GetCurrentPedTask(ped)
--     end

--     return nil
-- end

-- -- Asignar tarea de seguir a otro ped
-- function Task.setPlayerFollowPed(source, targetPed, distance, timeout)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     if not Task.isValidEntity(targetPed) then
--         return false
--     end

--     distance = distance or 2.0
--     timeout = timeout or -1

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskFollowNavMeshToPed(ped, targetPed, 1.0, timeout, distance, 0, 0.0)
--         return true
--     end

--     return false
-- end

-- -- Verificar si el jugador puede realizar tareas
-- function Task.canPlayerDoTask(source)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         return not IsEntityDead(ped) and not IsPedRagdoll(ped)
--     end

--     return false
-- end

-- -- Obtener velocidad de movimiento del jugador
-- function Task.getPlayerMoveSpeed(source)
--     if not Task.isValidPlayerId(source) then
--         return 0.0
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         return GetEntitySpeed(ped)
--     end

--     return 0.0
-- end

-- -- Establecer velocidad de movimiento del jugador
-- function Task.setPlayerMoveSpeed(source, speed)
--     if not Task.isValidPlayerId(source) then
--         return false
--     end

--     speed = tonumber(speed)
--     if not speed or speed < 0 then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         -- No hay nativo directo para esto, se manejaria via cliente
--         return true
--     end

--     return false
-- end

-- lib.task = Task
-- return lib.task

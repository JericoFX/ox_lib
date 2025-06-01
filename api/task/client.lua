
---@class lib.task
---@field ped number The ped entity this task system controls
lib.task = lib.class("task")

---Task API Class - Client Only
---Task management system for client-side only
---@param ped? number If passed, it's for that specific ped. If not passed, uses cache.ped
---@return lib.task
function lib.task:constructor(ped)
    -- Si se pasa ped, es para ese ped específico
    -- Si no se pasa, es para el ped local
    self.ped = ped or cache.ped
end

-- =====================================
-- CLIENT FUNCTIONS
-- =====================================

---Check if the ped is valid
---@return boolean valid True if ped exists and is valid
function lib.task:isValidPed()
    return self.ped and self.ped ~= 0 and DoesEntityExist(self.ped)
end

---Clear all tasks
---@return boolean success True if tasks were cleared successfully
function lib.task:clearTasks()
    if not self:isValidPed() then return false end

    ClearPedTasks(self.ped)
    return true
end

---Clear tasks immediately
---@return boolean success True if tasks were cleared successfully
function lib.task:clearTasksImmediately()
    if not self:isValidPed() then return false end

    ClearPedTasksImmediately(self.ped)
    return true
end

---Play animation
---@param dict string Animation dictionary
---@param name string Animation name
---@param blendInSpeed? number Blend in speed (default: 8.0)
---@param blendOutSpeed? number Blend out speed (default: -8.0)
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@param flag? number Animation flag (default: 0)
---@param playbackRate? number Playback rate (default: 0.0)
---@return boolean success True if animation started successfully
function lib.task:playAnim(dict, name, blendInSpeed, blendOutSpeed, duration, flag, playbackRate)
    if not self:isValidPed() then return false end

    blendInSpeed = blendInSpeed or 8.0
    blendOutSpeed = blendOutSpeed or -8.0
    duration = duration or -1
    flag = flag or 0
    playbackRate = playbackRate or 0.0

    if lib.requestAnimDict(dict) then
        TaskPlayAnim(self.ped, dict, name, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, false, false, false)
        return true
    end

    return false
end

---Walk to coordinates
---@param coords vector3 Target coordinates
---@param speed? number Movement speed (default: 1.0)
---@param timeout? number Timeout in milliseconds (default: 20000)
---@param stoppingRange? number Stopping distance (default: 0.0)
---@param persistFollowing? boolean Persist following (default: false)
---@return boolean success True if task started successfully
function lib.task:goToCoord(coords, speed, timeout, stoppingRange, persistFollowing)
    if not self:isValidPed() then return false end

    speed = speed or 1.0
    timeout = timeout or 20000
    stoppingRange = stoppingRange or 0.0
    persistFollowing = persistFollowing or false

    TaskGoToCoordAnyMeans(self.ped, coords.x, coords.y, coords.z, speed, 0, false, 786603, stoppingRange)
    return true
end

---Drive to coordinates
---@param vehicle number Vehicle entity
---@param coords vector3 Target coordinates
---@param speed? number Driving speed (default: 20.0)
---@param driveStyle? number Driving style flag (default: 786603)
---@param stoppingRange? number Stopping distance (default: 2.0)
---@return boolean success True if task started successfully
function lib.task:driveToCoord(vehicle, coords, speed, driveStyle, stoppingRange)
    if not self:isValidPed() then return false end

    speed = speed or 20.0
    driveStyle = driveStyle or 786603
    stoppingRange = stoppingRange or 2.0

    TaskVehicleDriveToCoord(self.ped, vehicle, coords.x, coords.y, coords.z, speed, 0, GetEntityModel(vehicle), driveStyle, stoppingRange, 0.0)
    return true
end

---Enter vehicle
---@param vehicle number Vehicle entity
---@param seat? number|string Seat index or seat name from enums
---@param timeout? number Timeout in milliseconds (default: -1 for infinite)
---@return boolean success True if task started successfully
function lib.task:enterVehicle(vehicle, seat, timeout)
    if not self:isValidPed() then return false end
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    local seatIndex = self:_normalizeSeatIndex(seat)
    timeout = timeout or -1

    TaskEnterVehicle(self.ped, vehicle, timeout, seatIndex, 1.0, 1, 0)
    return true
end

---Leave vehicle
---@param vehicle number Vehicle entity
---@param flags? number Exit flags (default: 0)
---@return boolean success True if task started successfully
function lib.task:leaveVehicle(vehicle, flags)
    if not self:isValidPed() then return false end
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    flags = flags or 0

    TaskLeaveVehicle(self.ped, vehicle, flags)
    return true
end

---Use nearest scenario to coordinates
---@param coords vector3 Target coordinates
---@param distance? number Search distance (default: 3.0)
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@return boolean success True if task started successfully
function lib.task:useNearestScenarioToCoord(coords, distance, duration)
    if not self:isValidPed() then return false end

    distance = distance or 3.0
    duration = duration or -1

    TaskUseNearestScenarioToCoord(self.ped, coords.x, coords.y, coords.z, distance, duration)
    return true
end

---Follow another ped
---@param targetPed number Target ped entity
---@param distance? number Follow distance (default: 2.0)
---@param timeout? number Timeout in milliseconds (default: -1 for infinite)
---@return boolean success True if task started successfully
function lib.task:followPed(targetPed, distance, timeout)
    if not self:isValidPed() then return false end

    distance = distance or 2.0
    timeout = timeout or -1

    TaskFollowNavMeshToPed(self.ped, targetPed, 1.0, timeout, distance, 0, 0.0)
    return true
end

---Aim gun at coordinates
---@param coords vector3 Target coordinates
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@param firingPattern? number Firing pattern hash (default: FIRING_PATTERN_FULL_AUTO)
---@return boolean success True if task started successfully
function lib.task:aimGunAtCoord(coords, duration, firingPattern)
    if not self:isValidPed() then return false end

    duration = duration or -1
    firingPattern = firingPattern or `FIRING_PATTERN_FULL_AUTO`

    TaskAimGunAtCoord(self.ped, coords.x, coords.y, coords.z, duration, false, false)
    return true
end

---Shoot at coordinates
---@param coords vector3 Target coordinates
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@param firingPattern? number Firing pattern hash (default: FIRING_PATTERN_FULL_AUTO)
---@return boolean success True if task started successfully
function lib.task:shootAtCoord(coords, duration, firingPattern)
    if not self:isValidPed() then return false end

    duration = duration or -1
    firingPattern = firingPattern or `FIRING_PATTERN_FULL_AUTO`

    TaskShootAtCoord(self.ped, coords.x, coords.y, coords.z, duration, firingPattern)
    return true
end

---Reload weapon
---@return boolean success True if task started successfully
function lib.task:reloadWeapon()
    if not self:isValidPed() then return false end

    TaskReloadWeapon(self.ped, true)
    return true
end

---Hands up
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@return boolean success True if task started successfully
function lib.task:handsUp(duration)
    if not self:isValidPed() then return false end

    duration = duration or -1

    TaskHandsUp(self.ped, duration, 0, -1, false)
    return true
end

---Duck/crouch
---@param duration? number Duration in milliseconds (default: -1 for infinite)
---@return boolean success True if task started successfully
function lib.task:duck(duration)
    if not self:isValidPed() then return false end

    duration = duration or -1

    -- Usar scenario para agacharse
    TaskStartScenarioInPlace(self.ped, "WORLD_HUMAN_STUPOR", duration, true)
    return true
end

---Check if task is active
---@return boolean active True if ped is performing a task
function lib.task:isActive()
    if not self:isValidPed() then return false end

    return GetScriptTaskStatus(self.ped, `SCRIPT_TASK_FOLLOW_NAV_MESH_TO_COORD`) ~= 7
end

---Get current task type hash
---@return number? taskHash The current task hash or nil if invalid ped
function lib.task:getCurrentTaskType()
    if not self:isValidPed() then return nil end

    return GetCurrentPedTask(self.ped)
end

-- =====================================
-- ADVANCED VEHICLE TASKS
-- =====================================

---Enter vehicle using seat enum
---@param vehicle number Vehicle entity
---@param seat string|number Seat name from enums or seat index
---@param timeout? number Timeout in milliseconds (default: -1 for infinite)
---@param speed? number Entry speed (default: 1.0)
---@return boolean success True if task started successfully
function lib.task:enterVehicleSeat(vehicle, seat, timeout, speed)
    if not self:isValidPed() then return false end
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    local seatIndex = self:_normalizeSeatIndex(seat)
    if not seatIndex then return false end -- Asiento inválido

    timeout = timeout or -1
    speed = speed or 1.0

    TaskEnterVehicle(self.ped, vehicle, timeout, seatIndex, speed, 1, 0)
    return true
end

-- Cambiar de asiento dentro del vehículo
function lib.task:shuffleToSeat(seat)
    if not self:isValidPed() then return false end

    local vehicle = GetVehiclePedIsIn(self.ped, false)
    if not vehicle or vehicle == 0 then return false end

    if not seat then
        -- Sin seat específico, usar shuffle normal
        TaskShuffleToNextVehicleSeat(self.ped, vehicle)
        return true
    end

    local seatIndex = self:_normalizeSeatIndex(seat)
    if not seatIndex then return false end -- Asiento inválido

    -- Para ir a un asiento específico, usar TaskEnterVehicle desde dentro del vehículo
    TaskEnterVehicle(self.ped, vehicle, -1, seatIndex, 1.0, 1, 0)
    return true
end

-- Conducir vehículo en patrón de vagabundeo
function lib.task:wander(driveStyle, cruiseSpeed)
    if not self:isValidPed() then return false end

    local vehicle = GetVehiclePedIsIn(self.ped, false)
    if not vehicle or vehicle == 0 then return false end

    driveStyle = driveStyle or 786603
    cruiseSpeed = cruiseSpeed or 20.0

    TaskVehicleDriveWander(self.ped, vehicle, cruiseSpeed, driveStyle)
    return true
end

-- Escapar usando vehículo
function lib.task:escapeInVehicle(coords, speed, driveStyle)
    if not self:isValidPed() then return false end

    local vehicle = GetVehiclePedIsIn(self.ped, false)
    if not vehicle or vehicle == 0 then return false end

    speed = speed or 50.0
    driveStyle = driveStyle or 786471

    TaskVehicleEscort(self.ped, vehicle, -1, -1, speed, driveStyle, 20.0)
    return true
end

-- =====================================
-- TAREAS CON OBJETOS Y PROPS
-- =====================================

-- Usar objeto específico
function lib.task:useObject(objectModel, animDict, animName, duration)
    if not self:isValidPed() then return false end

    -- Buscar objeto cercano
    local coords = GetEntityCoords(self.ped)
    local objects = lib.getNearbyObjects(coords, 5.0)

    for _, objectData in ipairs(objects) do
        local model = GetEntityModel(objectData.object)
        if model == joaat(objectModel) then
            -- Cargar animación si se proporciona
            if animDict and animName then
                if lib.requestAnimDict(animDict) then
                    TaskPlayAnim(self.ped, animDict, animName, 8.0, -8.0, duration or -1, 0, 0.0, false, false, false)
                end
            end
            TaskStartScenarioAtPosition(self.ped, "WORLD_HUMAN_LEANING", coords.x, coords.y, coords.z, GetEntityHeading(self.ped), duration or -1, true, true)
            return true
        end
    end

    return false
end

-- Crear y usar prop temporal
function lib.task:useTemporaryProp(propModel, bone, offset, rotation, animDict, animName, duration)
    if not self:isValidPed() then return false end

    -- Crear prop
    if lib.requestModel(propModel) then
        local coords = GetEntityCoords(self.ped)
        local prop = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)

        if prop and prop ~= 0 then
            -- Adjuntar al ped
            bone = bone or 60309 -- mano derecha por defecto
            offset = offset or vector3(0.0, 0.0, 0.0)
            rotation = rotation or vector3(0.0, 0.0, 0.0)

            AttachEntityToEntity(prop, self.ped, GetPedBoneIndex(self.ped, bone),
                offset.x, offset.y, offset.z,
                rotation.x, rotation.y, rotation.z,
                true, true, false, true, 1, true)

            -- Reproducir animación si se proporciona
            if animDict and animName then
                if lib.requestAnimDict(animDict) then
                    TaskPlayAnim(self.ped, animDict, animName, 8.0, -8.0, duration or -1, 50, 0.0, false, false, false)
                end
            end

            -- Eliminar prop después de la duración
            if duration and duration > 0 then
                CreateThread(function()
                    Wait(duration)
                    if DoesEntityExist(prop) then
                        DeleteEntity(prop)
                    end
                end)
            end

            return true, prop
        end
    end

    return false
end

-- =====================================
-- TAREAS DE COMBATE Y ARMAS AVANZADAS
-- =====================================

-- Equipar arma específica
function lib.task:equipWeapon(weaponHash, ammo)
    if not self:isValidPed() then return false end

    -- Asegurar que el arma esté disponible
    if lib.requestWeaponAsset(weaponHash) then
        GiveWeaponToPed(self.ped, weaponHash, ammo or 250, false, true)
        SetCurrentPedWeapon(self.ped, weaponHash, true)
        return true
    end

    return false
end

-- Atacar entidad específica
function lib.task:attackEntity(target, duration, attackType)
    if not self:isValidPed() then return false end
    if not target or not DoesEntityExist(target) then return false end

    duration = duration or -1
    attackType = attackType or 0 -- 0 = cualquier método

    TaskCombatPed(self.ped, target, 0, 16)
    return true
end

-- Cubrir detrás de objeto
function lib.task:takeCoverAt()
    if not self:isValidPed() then return false end
    TaskStayInCover(self.ped)
    return true
end

-- =====================================
-- TAREAS SOCIALES Y DE INTERACCIÓN
-- =====================================


-- Saludar a jugador cercano
function lib.task:greetNearestPlayer()
    if not self:isValidPed() then return false end

    local coords = GetEntityCoords(self.ped)
    local _, playerPed = lib.getClosestPlayer(coords, 5.0, false)

    if playerPed then
        TaskTurnPedToFaceEntity(self.ped, playerPed, -1)
        Wait(1000)
        if lib.requestAnimDict("gestures@m@standing@casual") then
            TaskPlayAnim(self.ped, "gestures@m@standing@casual", "gesture_hello", 8.0, -8.0, 2000, 0, 0.0, false, false, false)
            return true
        end
    end

    return false
end

-- Huir del jugador más cercano
function lib.task:fleeFromNearestPlayer(distance, duration)
    if not self:isValidPed() then return false end

    local coords = GetEntityCoords(self.ped)
    local _, playerPed = lib.getClosestPlayer(coords, 20.0, false)

    if playerPed then
        distance = distance or 100.0
        duration = duration or 10000
        TaskSmartFleePed(self.ped, playerPed, distance, duration, false, false)
        return true
    end

    return false
end

-- =====================================
-- TAREAS DE SCENARIOS Y AMBIENTES
-- =====================================

-- Usar scenario en posición específica
function lib.task:startScenarioAt(scenarioName, coords, heading, duration, sitOnGround)
    if not self:isValidPed() then return false end

    coords = coords or GetEntityCoords(self.ped)
    heading = heading or GetEntityHeading(self.ped)
    duration = duration or -1
    sitOnGround = sitOnGround or false

    TaskStartScenarioAtPosition(self.ped, scenarioName, coords.x, coords.y, coords.z, heading, duration, sitOnGround, true)
    return true
end

-- =====================================
-- TAREAS DE MOVIMIENTO AVANZADO
-- =====================================

-- Caminar con estilo específico
function lib.task:walkWithStyle(movementClipset, coords, speed)
    if not self:isValidPed() then return false end

    -- Cargar clipset de movimiento
    if lib.requestAnimSet(movementClipset) then
        SetPedMovementClipset(self.ped, movementClipset, 1.0)

        if coords then
            speed = speed or 1.0
            TaskGoStraightToCoord(self.ped, coords.x, coords.y, coords.z, speed, -1, GetEntityHeading(self.ped), 0.0)
        end

        return true
    end

    return false
end

-- Patrullar entre puntos
function lib.task:patrol(waypoints, speed, waitTime)
    if not self:isValidPed() then return false end
    if not waypoints or #waypoints < 2 then return false end

    speed = speed or 1.0
    waitTime = waitTime or 2000

    CreateThread(function()
        local currentWaypoint = 1

        while true do
            local waypoint = waypoints[currentWaypoint]
            if waypoint then
                TaskGoStraightToCoord(self.ped, waypoint.x, waypoint.y, waypoint.z, speed, -1, 0.0, 0.0)

                -- Esperar hasta llegar al punto
                local timeout = 30000 -- 30 segundos timeout
                local startTime = GetGameTimer()

                while GetGameTimer() - startTime < timeout do
                    local pedCoords = GetEntityCoords(self.ped)
                    local distance = #(pedCoords - waypoint)

                    if distance < 2.0 then
                        break
                    end

                    Wait(500)
                end

                -- Esperar en el punto
                Wait(waitTime)

                -- Siguiente waypoint
                currentWaypoint = currentWaypoint + 1
                if currentWaypoint > #waypoints then
                    currentWaypoint = 1 -- Volver al inicio
                end
            else
                break
            end
        end
    end)

    return true
end

-- Caminar aleatoriamente en área
function lib.task:wanderInArea(centerCoords, radius, duration)
    if not self:isValidPed() then return false end

    radius = radius or 50.0
    duration = duration or -1

    TaskWanderInArea(self.ped, centerCoords.x, centerCoords.y, centerCoords.z, radius, 1.0, 1.0)

    if duration > 0 then
        CreateThread(function()
            Wait(duration)
            self:clearTasks()
        end)
    end

    return true
end

-- =====================================
-- TAREAS ESPECIALES Y UTILIDADES
-- =====================================

-- Teletransportarse suavemente
function lib.task:teleportSmooth(coords, heading)
    if not self:isValidPed() then return false end

    heading = heading or GetEntityHeading(self.ped)

    -- Fade out
    DoScreenFadeOut(1000)
    Wait(1000)

    -- Teletransportar
    SetEntityCoords(self.ped, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(self.ped, heading)

    -- Fade in
    Wait(500)
    DoScreenFadeIn(1000)

    return true
end

-- Congelar/descongelar ped
function lib.task:freeze(state)
    if not self:isValidPed() then return false end

    FreezeEntityPosition(self.ped, state)
    return true
end

-- Hacer invencible/vulnerable
function lib.task:setInvincible(state)
    if not self:isValidPed() then return false end

    SetEntityInvincible(self.ped, state)
    return true
end

-- Configurar relación con jugador
function lib.task:setRelationshipWithPlayer(relationshipType)
    if not self:isValidPed() then return false end

    local playerGroup = GetPlayerGroup(PlayerId())
    local pedGroup = GetPedRelationshipGroupHash(self.ped)

    SetRelationshipBetweenGroups(relationshipType, pedGroup, playerGroup)
    SetRelationshipBetweenGroups(relationshipType, playerGroup, pedGroup)

    return true
end

-- =====================================
-- FUNCIONES DE ESTADO Y VERIFICACIÓN
-- =====================================

-- Verificar si está ejecutando tarea específica
function lib.task:isDoingTask(taskHash)
    if not self:isValidPed() then return false end
    return GetScriptTaskStatus(self.ped, taskHash) == 1
end

-- Obtener distancia a coordenadas
function lib.task:getDistanceTo(coords)
    if not self:isValidPed() then return nil end
    local pedCoords = GetEntityCoords(self.ped)
    return #(pedCoords - coords)
end

-- Verificar si puede ver entidad
function lib.task:canSeeEntity(entity)
    if not self:isValidPed() then return false end
    if not entity or not DoesEntityExist(entity) then return false end

    return HasEntityClearLosToEntity(self.ped, entity, 17)
end

-- Obtener vehículo más cercano
function lib.task:getNearestVehicle(radius)
    if not self:isValidPed() then return nil end

    local coords = GetEntityCoords(self.ped)
    radius = radius or 10.0

    return lib.getClosestVehicle(coords, radius, true)
end

-- Obtener jugador más cercano
function lib.task:getNearestPlayer(radius)
    if not self:isValidPed() then return nil end

    local coords = GetEntityCoords(self.ped)
    radius = radius or 10.0

    return lib.getClosestPlayer(coords, radius, false)
end

-- =====================================
-- FUNCIONES AUXILIARES
-- =====================================

-- Función auxiliar para normalizar el índice de asiento
function lib.task:_normalizeSeatIndex(seat)
    if type(seat) == 'string' then
        -- Si es string, buscar en el enum que es medio al pedo tener un enum con strings
        local seatIndex = lib.enums.vehicles.SEATS[seat]
        return seatIndex -- Puede ser nil si no existe
    elseif type(seat) == 'number' then
        return seat
    else
        return -1
    end
end

-- Validar si un asiento es válido
function lib.task:_isValidSeat(seat)
    local seatIndex = self:_normalizeSeatIndex(seat)
    return seatIndex ~= nil
end

return lib.task

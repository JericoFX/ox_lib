--[[
    Task API Class - Client Only
    Sistema de clases solo para el lado del cliente
]]

lib.task = lib.class('Task')

function lib.task:constructor(ped)
    -- Si se pasa ped, es para ese ped específico
    -- Si no se pasa, es para el ped local
    self.ped = ped or cache.ped
end

-- =====================================
-- FUNCIONES CLIENT
-- =====================================

-- Verificar si el ped es válido
function lib.task:isValidPed()
    return self.ped and self.ped ~= 0 and DoesEntityExist(self.ped)
end

-- Limpiar todas las tareas
function lib.task:clearTasks()
    if not self:isValidPed() then return false end

    ClearPedTasks(self.ped)
    return true
end

-- Limpiar tareas inmediatamente
function lib.task:clearTasksImmediately()
    if not self:isValidPed() then return false end

    ClearPedTasksImmediately(self.ped)
    return true
end

-- Reproducir animación
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

-- Caminar hacia coordenadas
function lib.task:goToCoord(coords, speed, timeout, stoppingRange, persistFollowing)
    if not self:isValidPed() then return false end

    speed = speed or 1.0
    timeout = timeout or 20000
    stoppingRange = stoppingRange or 0.0
    persistFollowing = persistFollowing or false

    TaskGoToCoordAnyMeans(self.ped, coords.x, coords.y, coords.z, speed, 0, false, 786603, stoppingRange)
    return true
end

-- Conducir hacia coordenadas
function lib.task:driveToCoord(vehicle, coords, speed, driveStyle, stoppingRange)
    if not self:isValidPed() then return false end

    speed = speed or 20.0
    driveStyle = driveStyle or 786603
    stoppingRange = stoppingRange or 2.0

    TaskVehicleDriveToCoord(self.ped, vehicle, coords.x, coords.y, coords.z, speed, 0, GetEntityModel(vehicle), driveStyle, stoppingRange, 0.0)
    return true
end

-- Entrar en vehículo
function lib.task:enterVehicle(vehicle, seat, timeout) -- chequear si el vehiculo existe
    if not self:isValidPed() then return false end

    seat = seat or -1
    timeout = timeout or -1

    TaskEnterVehicle(self.ped, vehicle, timeout, seat, 1.0, 1, 0)
    return true
end

-- Salir del vehículo
function lib.task:leaveVehicle(vehicle, flags) -- chequear si el vehiculo existe aca tambien
    if not self:isValidPed() then return false end

    flags = flags or 0

    TaskLeaveVehicle(self.ped, vehicle, flags)
    return true
end

-- Usar objeto más cercano
function lib.task:useNearestScenarioToCoord(coords, distance, duration) -- chequear si el objeto existe
    if not self:isValidPed() then return false end

    distance = distance or 3.0
    duration = duration or -1

    TaskUseNearestScenarioToCoord(self.ped, coords.x, coords.y, coords.z, distance, duration)
    return true
end

-- Seguir a otro ped
function lib.task:followPed(targetPed, distance, timeout)
    if not self:isValidPed() then return false end

    distance = distance or 2.0
    timeout = timeout or -1

    TaskFollowNavMeshToPed(self.ped, targetPed, 1.0, timeout, distance, 0, 0.0)
    return true
end

-- Apuntar arma
function lib.task:aimGunAtCoord(coords, duration, firingPattern)
    if not self:isValidPed() then return false end

    duration = duration or -1
    firingPattern = firingPattern or `FIRING_PATTERN_FULL_AUTO`

    TaskAimGunAtCoord(self.ped, coords.x, coords.y, coords.z, duration, false, false)
    return true
end

-- Disparar arma
function lib.task:shootAtCoord(coords, duration, firingPattern)
    if not self:isValidPed() then return false end

    duration = duration or -1
    firingPattern = firingPattern or `FIRING_PATTERN_FULL_AUTO`

    TaskShootAtCoord(self.ped, coords.x, coords.y, coords.z, duration, firingPattern)
    return true
end

-- Recargar arma
function lib.task:reloadWeapon()
    if not self:isValidPed() then return false end

    TaskReloadWeapon(self.ped, true)
    return true
end

-- Manos arriba
function lib.task:handsUp(duration)
    if not self:isValidPed() then return false end

    duration = duration or -1

    TaskHandsUp(self.ped, duration, 0, -1, false)
    return true
end

-- Agacharse
function lib.task:duck(duration)
    if not self:isValidPed() then return false end

    duration = duration or -1

    -- Usar scenario para agacharse
    TaskStartScenarioInPlace(self.ped, "WORLD_HUMAN_STUPOR", duration, true)
    return true
end

-- Verificar si está haciendo una tarea
function lib.task:isActive()
    if not self:isValidPed() then return false end

    return GetScriptTaskStatus(self.ped, `SCRIPT_TASK_FOLLOW_NAV_MESH_TO_COORD`) ~= 7
end

-- Obtener el hash de la tarea actual
function lib.task:getCurrentTaskType()
    if not self:isValidPed() then return nil end

    return GetCurrentPedTask(self.ped)
end

return lib.task

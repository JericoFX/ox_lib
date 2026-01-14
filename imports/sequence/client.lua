-- I think i found all task....

-- ---@param ped number
-- ---@param target number
-- ---@param vehicle number
-- local function exampleTaskSequence(ped, target, vehicle)
--     local ok, reason = lib.taskSequence()
--         :keepTask(true)
--         :blockNonTemporaryEvents(true)
--         :alertness(2)
--         :combat(2, 2)
--         :combatRange(1)
--         :combatAttribute(46, true)
--         :driveStyle(786603)
--         :driveCruiseSpeed(18.0)
--         :turnToEntity(target, 1500)
--         :lookAtEntity(target, 1500, 0)
--         :wait(250)
--         :enterVehicle(vehicle, -1, 8000, 1.0, 0)
--         :vehicleWander(vehicle, 18.0, 786603)
--         :run(ped, {
--             clearTasks = true,
--             strict = false,
--             notify = true,
--             notifyTitle = 'AI',
--             notifyType = 'inform',
--             notifyPosition = 'top-right',
--         })

--     if not ok then
--         lib.notify({
--             title = 'AI',
--             description = ('Task sequence failed: %s'):format(reason or 'unknown'),
--             type = 'error',
--             position = 'top-right',
--         })
--     end
-- end

---@class TaskSequenceOptions
---@field clearTasks? boolean
---@field requestControl? boolean
---@field timeout? number
---@field strict? boolean
---@field debug? boolean
---@field notify? boolean
---@field notifyTitle? string
---@field notifyPosition? 'top'|'top-right'|'top-left'|'bottom'|'bottom-right'|'bottom-left'|'center-right'|'center-left'
---@field notifyType? 'inform'|'success'|'warning'|'error'

---@alias TaskSequenceStep fun(seq: number, ped: number, ctx: table)
---@alias TaskSequenceHook fun(ped: number, ctx: table)

---@class TaskSequence
---@field private _seq number
---@field private _tasks TaskSequenceStep[]
---@field private _pre TaskSequenceHook[]
---@field private _post TaskSequenceHook[]
---@field private _failed boolean
---@field private _failReason string?
---@field private _ctx table

local TaskSequence = {}
TaskSequence.__index = TaskSequence

local function notifyIf(opts, msg, ntype)
    if not opts or not opts.notify then return end
    lib.notify({
        title = opts.notifyTitle or 'Task Sequence',
        description = msg,
        type = ntype or opts.notifyType or 'inform',
        position = opts.notifyPosition or 'top-right',
    })
end

local function dbg(opts, msg)
    if not opts or not opts.debug then return end
    notifyIf(opts, msg, 'inform')
end

local function requestAnimDict(dict, timeout)
    if lib.requestAnimDict then
        return lib.requestAnimDict(dict, timeout or 1000)
    end

    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local start = GetGameTimer()
    local limit = timeout or 1000
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() - start > limit then
            return false
        end
    end
    return true
end

local function requestModel(model, timeout)
    if lib.requestModel then
        return lib.requestModel(model, timeout or 1000)
    end

    local hash = type(model) == 'string' and joaat(model) or model
    if HasModelLoaded(hash) then return true end
    RequestModel(hash)
    local start = GetGameTimer()
    local limit = timeout or 1000
    while not HasModelLoaded(hash) do
        Wait(0)
        if GetGameTimer() - start > limit then
            return false
        end
    end
    return true
end

---@return TaskSequence
function lib.taskSequence()
    local self = setmetatable({}, TaskSequence)
    self._seq = 0
    self._tasks = {}
    self._pre = {}
    self._post = {}
    self._failed = false
    self._failReason = nil
    self._ctx = {}
    return self
end

function TaskSequence:_ensureOpen()
    if self._seq ~= 0 then return end
    local seq = OpenSequenceTask()
    if not seq or seq == 0 then
        error('[lib.taskSequence] Failed to open task sequence (OpenSequenceTask).')
        return
    end
    self._seq = seq
end

---@param reason string
function TaskSequence:_fail(reason)
    self._failed = true
    self._failReason = reason
end

---@param fn TaskSequenceStep
function TaskSequence:_push(fn)
    self._tasks[#self._tasks + 1] = fn
end

---@param fn TaskSequenceHook
function TaskSequence:_pushPre(fn)
    self._pre[#self._pre + 1] = fn
end

---@param fn TaskSequenceHook
function TaskSequence:_pushPost(fn)
    self._post[#self._post + 1] = fn
end

---@return TaskSequence
function TaskSequence:clear()
    self._tasks = {}
    self._failed = false
    self._failReason = nil
    return self
end

---@return TaskSequence
function TaskSequence:reset()
    self._seq = 0
    self._tasks = {}
    self._pre = {}
    self._post = {}
    self._failed = false
    self._failReason = nil
    self._ctx = {}
    return self
end

---@param key string
---@param value any
---@return TaskSequence
function TaskSequence:ctx(key, value)
    self._ctx[key] = value
    return self
end

---@param fn TaskSequenceHook
---@return TaskSequence
function TaskSequence:before(fn)
    self:_pushPre(fn)
    return self
end

---@param fn TaskSequenceHook
---@return TaskSequence
function TaskSequence:after(fn)
    self:_pushPost(fn)
    return self
end

---@param ped number
---@param opts TaskSequenceOptions?
---@return boolean ok, string? reason
function TaskSequence:run(ped, opts)
    opts = opts or {}

    if ped == 0 or not DoesEntityExist(ped) then
        return false, 'ped_invalid'
    end

    if opts.clearTasks then
        ClearPedTasks(ped)
    end

    self._failed = false
    self._failReason = nil

    self:_ensureOpen()

    local ok, err = xpcall(function()
        for i = 1, #self._pre do
            self._pre[i](ped, self._ctx)
        end

        local seq = self._seq
        for i = 1, #self._tasks do
            if self._failed and opts.strict then break end
            self._tasks[i](seq, ped, self._ctx)
        end

        CloseSequenceTask(seq)

        if self._failed and opts.strict then
            return
        end

        TaskPerformSequence(ped, seq)

        for i = 1, #self._post do
            self._post[i](ped, self._ctx)
        end
    end, debug.traceback)

    if self._seq ~= 0 then
        ClearSequenceTask(self._seq)
        self._seq = 0
    end

    if not ok then
        notifyIf(opts, tostring(err), 'error')
        return false, tostring(err)
    end

    if self._failed and opts.strict then
        notifyIf(opts, self._failReason or 'failed', 'error')
        return false, self._failReason or 'failed'
    end

    return true, nil
end

---@param enabled boolean
---@return TaskSequence
function TaskSequence:keepTask(enabled)
    self:before(function(ped)
        SetPedKeepTask(ped, enabled and true or false)
    end)
    return self
end

---@param level number
---@return TaskSequence
function TaskSequence:alertness(level)
    self:before(function(ped)
        SetPedAlertness(ped, level)
    end)
    return self
end

---@param hearing number?
---@param sight number?
---@return TaskSequence
function TaskSequence:senses(hearing, sight)
    self:before(function(ped)
        if hearing then SetPedHearingRange(ped, hearing) end
        if sight then SetPedSeeingRange(ped, sight) end
    end)
    return self
end

---@param ability number?
---@param movement number?
---@return TaskSequence
function TaskSequence:combat(ability, movement)
    self:before(function(ped)
        if ability then SetPedCombatAbility(ped, ability) end
        if movement then SetPedCombatMovement(ped, movement) end
    end)
    return self
end

---@param range number
---@return TaskSequence
function TaskSequence:combatRange(range)
    self:before(function(ped)
        SetPedCombatRange(ped, range)
    end)
    return self
end

---@param attr number
---@param enabled boolean
---@return TaskSequence
function TaskSequence:combatAttribute(attr, enabled)
    self:before(function(ped)
        SetPedCombatAttributes(ped, attr, enabled and true or false)
    end)
    return self
end

---@param flag number
---@param enabled boolean
---@return TaskSequence
function TaskSequence:configFlag(flag, enabled)
    self:before(function(ped)
        SetPedConfigFlag(ped, flag, enabled and true or false)
    end)
    return self
end

---@param attrs number
---@param enabled boolean
---@return TaskSequence
function TaskSequence:fleeAttributes(attrs, enabled)
    self:before(function(ped)
        SetPedFleeAttributes(ped, attrs, enabled and true or false)
    end)
    return self
end

---@param group number|string
---@return TaskSequence
function TaskSequence:relationshipGroup(group)
    self:before(function(ped)
        local hash = type(group) == 'string' and GetHashKey(group) or group
        SetPedRelationshipGroupHash(ped, hash)
    end)
    return self
end

---@param canRagdoll boolean
---@return TaskSequence
function TaskSequence:ragdoll(canRagdoll)
    self:before(function(ped)
        SetPedCanRagdoll(ped, canRagdoll and true or false)
    end)
    return self
end

---@param value boolean
---@return TaskSequence
function TaskSequence:blockNonTemporaryEvents(value)
    self:before(function(ped)
        SetBlockingOfNonTemporaryEvents(ped, value and true or false)
    end)
    return self
end

---@param ms number
---@return TaskSequence
function TaskSequence:wait(ms)
    self:_push(function(seq)
        TaskPause(seq, ms)
    end)
    return self
end

---@param ms? number
---@return TaskSequence
function TaskSequence:standStill(ms)
    self:_push(function(seq)
        TaskStandStill(seq, ms or -1)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param speed? number
---@param timeout? number
---@param heading? number
---@param distanceToSlide? number
---@return TaskSequence
function TaskSequence:goTo(x, y, z, speed, timeout, heading, distanceToSlide)
    speed = speed or 1.0
    timeout = timeout or 10000
    heading = heading or 0.0
    distanceToSlide = distanceToSlide or 0.0
    self:_push(function(seq)
        TaskGoStraightToCoord(seq, x, y, z, speed, timeout, heading, distanceToSlide)
    end)
    return self
end

---@param entity number
---@param duration? number
---@param distance? number
---@param speed? number
---@return TaskSequence
function TaskSequence:goToEntity(entity, duration, distance, speed)
    duration = duration or -1
    distance = distance or 1.0
    speed = speed or 1.0
    self:_push(function(seq)
        TaskGoToEntity(seq, entity, duration, distance, speed, 0, 0)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param speed? number
---@param timeout? number
---@param flags? number
---@param heading? number
---@return TaskSequence
function TaskSequence:goToAnyMeans(x, y, z, speed, timeout, flags, heading)
    speed = speed or 1.0
    timeout = timeout or 10000
    flags = flags or 0
    heading = heading or 0.0
    self:_push(function(seq)
        TaskGoToCoordAnyMeans(seq, x, y, z, speed, 0, false, flags, heading)
    end)
    return self
end

---@param wanderType? number
---@return TaskSequence
function TaskSequence:wanderStandard(wanderType)
    self:_push(function(seq)
        TaskWanderStandard(seq, wanderType or 10, 0)
    end)
    return self
end

---@param heading number
---@param timeout? number
---@return TaskSequence
function TaskSequence:turnToHeading(heading, timeout)
    self:_push(function(seq)
        TaskAchieveHeading(seq, heading, timeout or 2000)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param duration? number
---@return TaskSequence
function TaskSequence:turnToCoord(x, y, z, duration)
    self:_push(function(seq)
        TaskTurnPedToFaceCoord(seq, x, y, z, duration or 2000)
    end)
    return self
end

---@param entity number
---@param duration? number
---@return TaskSequence
function TaskSequence:turnToEntity(entity, duration)
    self:_push(function(seq)
        TaskTurnPedToFaceEntity(seq, entity, duration or 2000)
    end)
    return self
end

---@param entity number
---@param duration? number
---@param flags? number
---@return TaskSequence
function TaskSequence:lookAtEntity(entity, duration, flags)
    self:_push(function(seq)
        TaskLookAtEntity(seq, entity, duration or 2000, flags or 0, 2)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param duration? number
---@param flags? number
---@return TaskSequence
function TaskSequence:lookAtCoord(x, y, z, duration, flags)
    self:_push(function(seq)
        TaskLookAtCoord(seq, x, y, z, duration or 2000, flags or 0, 2)
    end)
    return self
end

---@param entity number
---@param duration? number
---@param shoot? boolean
---@return TaskSequence
function TaskSequence:aimAtEntity(entity, duration, shoot)
    self:_push(function(seq)
        TaskAimGunAtEntity(seq, entity, duration or 2000, shoot and true or false)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param duration? number
---@param shoot? boolean
---@return TaskSequence
function TaskSequence:aimAtCoord(x, y, z, duration, shoot)
    self:_push(function(seq)
        TaskAimGunAtCoord(seq, x, y, z, duration or 2000, shoot and true or false, false)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param duration? number
---@param firingPattern? number
---@return TaskSequence
function TaskSequence:shootAtCoord(x, y, z, duration, firingPattern)
    self:_push(function(seq)
        TaskShootAtCoord(seq, x, y, z, duration or 2000, firingPattern or GetHashKey('FIRING_PATTERN_FULL_AUTO'))
    end)
    return self
end

---@param entity number
---@param duration? number
---@param firingPattern? number
---@return TaskSequence
function TaskSequence:shootAtEntity(entity, duration, firingPattern)
    self:_push(function(seq)
        TaskShootAtEntity(seq, entity, duration or 2000, firingPattern or GetHashKey('FIRING_PATTERN_FULL_AUTO'))
    end)
    return self
end

---@param targetPed number
---@param p2? number
---@param p3? number
---@return TaskSequence
function TaskSequence:combatPed(targetPed, p2, p3)
    self:_push(function(seq)
        TaskCombatPed(seq, targetPed, p2 or 0, p3 or 16)
    end)
    return self
end

---@param radius? number
---@param flags? number
---@return TaskSequence
function TaskSequence:combatHatedTargets(radius, flags)
    self:_push(function(seq)
        TaskCombatHatedTargetsInArea(seq, 0.0, 0.0, 0.0, radius or 50.0, flags or 0)
    end)
    return self
end

---@param fromPed number
---@param safeDist? number
---@param duration? number
---@param flags? number
---@return TaskSequence
function TaskSequence:fleePed(fromPed, safeDist, duration, flags)
    self:_push(function(seq)
        TaskFleePed(seq, fromPed, flags or 0, false, safeDist or 50.0, duration or -1)
    end)
    return self
end

---@param x number
---@param y number
---@param z number
---@param safeDist? number
---@param duration? number
---@param flags? number
---@return TaskSequence
function TaskSequence:fleeCoord(x, y, z, safeDist, duration, flags)
    self:_push(function(seq)
        TaskFleeCoord(seq, x, y, z, flags or 0, false, safeDist or 50.0, duration or -1)
    end)
    return self
end

---@param scenario string
---@param x number
---@param y number
---@param z number
---@param heading? number
---@param duration? number
---@param seated? boolean
---@param teleport? boolean
---@return TaskSequence
function TaskSequence:scenarioAt(scenario, x, y, z, heading, duration, seated, teleport)
    self:_push(function(seq)
        TaskStartScenarioAtPosition(seq, scenario, x, y, z, heading or 0.0, duration or -1, seated and true or false, teleport and true or false)
    end)
    return self
end

---@param scenario string
---@param duration? number
---@param playEnterAnim? boolean
---@return TaskSequence
function TaskSequence:scenarioInPlace(scenario, duration, playEnterAnim)
    self:_push(function(seq)
        TaskStartScenarioInPlace(seq, scenario, duration or -1, playEnterAnim ~= false)
    end)
    return self
end

---@param duration? number
---@return TaskSequence
function TaskSequence:usePhone(duration)
    self:_push(function(seq)
        TaskUseMobilePhone(seq, duration or -1)
    end)
    return self
end

---@param dict string
---@param name string
---@param flags? number
---@param duration? number
---@param blendIn? number
---@param blendOut? number
---@param lockX? boolean
---@param lockY? boolean
---@param lockZ? boolean
---@param timeout? number
---@return TaskSequence
function TaskSequence:anim(dict, name, flags, duration, blendIn, blendOut, lockX, lockY, lockZ, timeout)
    self:_push(function(seq, _ped, _ctx)
        local ok = requestAnimDict(dict, timeout or 1000)
        if not ok then
            self:_fail(('anim_dict_timeout:%s'):format(dict))
            return
        end
        TaskPlayAnim(seq, dict, name, blendIn or 8.0, blendOut or -8.0, duration or -1, flags or 0, 0, lockX and true or false, lockY and true or false, lockZ and true or false)
    end)
    return self
end

---@param dict string
---@param name string
---@param x number
---@param y number
---@param z number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param flags? number
---@param duration? number
---@param blendIn? number
---@param blendOut? number
---@param timeout? number
---@return TaskSequence
function TaskSequence:animAdvanced(dict, name, x, y, z, rotX, rotY, rotZ, flags, duration, blendIn, blendOut, timeout)
    self:_push(function(seq)
        local ok = requestAnimDict(dict, timeout or 1000)
        if not ok then
            self:_fail(('anim_dict_timeout:%s'):format(dict))
            return
        end
        TaskPlayAnimAdvanced(seq, dict, name, x, y, z, rotX, rotY, rotZ, blendIn or 8.0, blendOut or -8.0, duration or -1, flags or 0, 0, 0, 0)
    end)
    return self
end

---@param vehicle number
---@param seat? number
---@param timeoutMs? number
---@param speed? number
---@param flags? number
---@return TaskSequence
function TaskSequence:enterVehicle(vehicle, seat, timeoutMs, speed, flags)
    self:_push(function(seq)
        TaskEnterVehicle(seq, vehicle, timeoutMs or -1, seat or -1, speed or 1.0, flags or 0, 0)
    end)
    return self
end

---@param vehicle number
---@param flags? number
---@return TaskSequence
function TaskSequence:leaveVehicle(vehicle, flags)
    self:_push(function(seq)
        TaskLeaveVehicle(seq, vehicle, flags or 0)
    end)
    return self
end

---@param vehicle number
---@param x number
---@param y number
---@param z number
---@param speed? number
---@param drivingStyle? number
---@param radius? number
---@param p7? number
---@return TaskSequence
function TaskSequence:driveTo(vehicle, x, y, z, speed, drivingStyle, radius, p7)
    self:_push(function(seq)
        TaskVehicleDriveToCoord(seq, vehicle, x, y, z, speed or 15.0, p7 or 0, GetEntityModel(vehicle), drivingStyle or 786603, radius or 5.0, true)
    end)
    return self
end

---@param vehicle number
---@param speed? number
---@param drivingStyle? number
---@return TaskSequence
function TaskSequence:vehicleWander(vehicle, speed, drivingStyle)
    self:_push(function(seq)
        TaskVehicleDriveWander(seq, vehicle, speed or 15.0, drivingStyle or 786603)
    end)
    return self
end

---@param vehicle number
---@param targetPed number
---@param speed? number
---@param drivingStyle? number
---@return TaskSequence
function TaskSequence:vehicleChase(vehicle, targetPed, speed, drivingStyle)
    self:_push(function(seq)
        TaskVehicleChase(seq, targetPed)
        SetDriveTaskCruiseSpeed(seq, speed or 25.0)
        SetDriveTaskDrivingStyle(seq, drivingStyle or 786603)
        SetDriveTaskMaxCruiseSpeed(seq, speed or 25.0)
    end)
    return self
end

---@param vehicle number
---@param targetEntity number
---@param missionType number
---@param speed? number
---@param drivingStyle? number
---@param dist? number
---@param p7? number
---@param p8? number
---@return TaskSequence
function TaskSequence:vehicleMission(vehicle, targetEntity, missionType, speed, drivingStyle, dist, p7, p8)
    self:_push(function(seq)
        TaskVehicleMission(seq, vehicle, targetEntity, missionType, speed or 20.0, drivingStyle or 786603, dist or 5.0, p7 or 0, p8 or 0, true)
    end)
    return self
end

---@param vehicle number
---@param x number
---@param y number
---@param z number
---@param heading number
---@param mode? number
---@return TaskSequence
function TaskSequence:parkVehicle(vehicle, x, y, z, heading, mode)
    self:_push(function(seq)
        TaskVehiclePark(seq, vehicle, x, y, z, heading, mode or 0, 20.0, true)
    end)
    return self
end

---@param speed number
---@return TaskSequence
function TaskSequence:driveCruiseSpeed(speed)
    self:before(function(ped)
        SetDriveTaskCruiseSpeed(ped, speed)
    end)
    return self
end

---@param style number
---@return TaskSequence
function TaskSequence:driveStyle(style)
    self:before(function(ped)
        SetDriveTaskDrivingStyle(ped, style)
    end)
    return self
end

---@param model number|string
---@param timeout? number
---@return TaskSequence
function TaskSequence:ensureModel(model, timeout)
    self:before(function(_ped)
        local ok = requestModel(model, timeout or 1000)
        if not ok then
            self:_fail(('model_timeout:%s'):format(tostring(model)))
        end
    end)
    return self
end

---@param fn fun(seq: number, ped: number, ctx: table)
---@return TaskSequence
function TaskSequence:custom(fn)
    self:_push(fn)
    return self
end

---@param fn fun(ped: number, ctx: table)
---@return TaskSequence
function TaskSequence:setup(fn)
    self:before(fn)
    return self
end

---@param fn fun(ped: number, ctx: table)
---@return TaskSequence
function TaskSequence:teardown(fn)
    self:after(fn)
    return self
end

return lib.taskSequence

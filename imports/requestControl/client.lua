---@param entity number handle (veh, ped, object)
---@param timeout number? Max tiem in MS 
---@return boolean success Return true if we have the control, else false.
function lib.requestControl(entity, timeout)
    if (entity == 0 or type(entity) ~= "number") or not DoesEntityExist(entity) then
        lib.print.error("Entity does not exist or is not a number")
        return false
    end

    timeout = tonumber(timeout) or 1000
    local start = GetGameTimer()

    NetworkRequestControlOfEntity(entity)

    while not NetworkHasControlOfEntity(entity) do
        Wait(0)
        if GetGameTimer() - start > timeout then
            lib.print.error("Request Control Timeout")
            return false
        end
    end

    if NetworkHasControlOfEntity(entity) then
        return true
    end
    lib.print.error("Failed to take control of entity : %s",entity)
    return false
end
return lib.requestControl
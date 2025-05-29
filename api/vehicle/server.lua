-- --[[
--     Vehicle API - Server Functions
--     Tabla de funciones que se agregan a lib.vehicle
-- ]]

-- local Vehicle = {}

-- -- =====================================
-- -- FUNCIONES VALIDACION
-- -- =====================================

-- -- Validar identificador de jugador
-- function Vehicle.isValidPlayerId(playerId)
--     return type(playerId) == 'number' and playerId > 0
-- end

-- -- Validar entity handle
-- function Vehicle.isValidEntity(entity)
--     return type(entity) == 'number' and entity > 0 and DoesEntityExist(entity)
-- end

-- -- Validar modelo de vehículo
-- function Vehicle.isValidModel(model)
--     return type(model) == 'string' or type(model) == 'number'
-- end

-- -- =====================================
-- -- FUNCIONES VEHICULOS
-- -- =====================================

-- -- Crear vehículo
-- function Vehicle.createVehicle(model, coords, heading, networked)
--     if not Vehicle.isValidModel(model) then
--         return nil
--     end

--     if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
--         return nil
--     end

--     heading = heading or 0.0
--     networked = networked ~= false -- Por defecto true

--     -- Convertir string a hash si es necesario
--     if type(model) == 'string' then
--         model = GetHashKey(model)
--     end

--     local vehicle = CreateVehicle(model, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], heading, networked, false)

--     if vehicle and vehicle ~= 0 then
--         return vehicle
--     end

--     return nil
-- end

-- -- Eliminar vehículo
-- function Vehicle.deleteVehicle(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     DeleteEntity(vehicle)
--     return true
-- end

-- -- Obtener vehículo del jugador
-- function Vehicle.getPlayerVehicle(source)
--     if not Vehicle.isValidPlayerId(source) then
--         return nil
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         local vehicle = GetVehiclePedIsIn(ped, false)
--         return vehicle ~= 0 and vehicle or nil
--     end

--     return nil
-- end

-- -- Establecer jugador en vehículo
-- function Vehicle.setPlayerIntoVehicle(source, vehicle, seat)
--     if not Vehicle.isValidPlayerId(source) or not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     seat = seat or -1

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         SetPedIntoVehicle(ped, vehicle, seat)
--         return true
--     end

--     return false
-- end

-- -- Remover jugador del vehículo
-- function Vehicle.removePlayerFromVehicle(source)
--     if not Vehicle.isValidPlayerId(source) then
--         return false
--     end

--     local ped = GetPlayerPed(source)
--     if ped and ped ~= 0 then
--         TaskLeaveVehicle(ped, 0, 0)
--         return true
--     end

--     return false
-- end

-- -- Obtener propiedades del vehículo
-- function Vehicle.getVehicleProperties(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return nil
--     end

--     local props = {
--         model = GetEntityModel(vehicle),
--         coords = GetEntityCoords(vehicle),
--         heading = GetEntityHeading(vehicle),
--         health = {
--             engine = GetVehicleEngineHealth(vehicle),
--             body = GetVehicleBodyHealth(vehicle),
--             petrol = GetVehiclePetrolTankHealth(vehicle)
--         },
--         fuel = GetVehicleFuelLevel(vehicle),
--         locked = GetVehicleDoorLockStatus(vehicle),
--         engine = GetIsVehicleEngineRunning(vehicle)
--     }

--     return props
-- end

-- -- Establecer propiedades del vehículo
-- function Vehicle.setVehicleProperties(vehicle, props)
--     if not Vehicle.isValidEntity(vehicle) or type(props) ~= 'table' then
--         return false
--     end

--     if props.coords then
--         SetEntityCoords(vehicle, props.coords.x, props.coords.y, props.coords.z, false, false, false, true)
--     end

--     if props.heading then
--         SetEntityHeading(vehicle, props.heading)
--     end

--     if props.health then
--         if props.health.engine then
--             SetVehicleEngineHealth(vehicle, props.health.engine)
--         end
--         if props.health.body then
--             SetVehicleBodyHealth(vehicle, props.health.body)
--         end
--         if props.health.petrol then
--             SetVehiclePetrolTankHealth(vehicle, props.health.petrol)
--         end
--     end

--     if props.fuel then
--         SetVehicleFuelLevel(vehicle, props.fuel)
--     end

--     if props.locked ~= nil then
--         SetVehicleDoorsLocked(vehicle, props.locked and 2 or 1)
--     end

--     if props.engine ~= nil then
--         SetVehicleEngineOn(vehicle, props.engine, true, true)
--     end

--     return true
-- end

-- -- Reparar vehículo
-- function Vehicle.repairVehicle(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     SetVehicleFixed(vehicle)
--     SetVehicleDeformationFixed(vehicle)
--     SetVehicleUndriveable(vehicle, false)
--     SetVehicleEngineOn(vehicle, true, true, true)

--     return true
-- end

-- -- Explotar vehículo
-- function Vehicle.explodeVehicle(vehicle, damageSource, hasEntityDamage)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     damageSource = damageSource or 0
--     hasEntityDamage = hasEntityDamage ~= false

--     ExplodeVehicle(vehicle, hasEntityDamage, false)
--     return true
-- end

-- -- Establecer combustible
-- function Vehicle.setVehicleFuel(vehicle, level)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     level = tonumber(level)
--     if not level or level < 0 or level > 100 then
--         return false
--     end

--     SetVehicleFuelLevel(vehicle, level)
--     return true
-- end

-- -- Bloquear/desbloquear vehículo
-- function Vehicle.setVehicleLocked(vehicle, locked)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     SetVehicleDoorsLocked(vehicle, locked and 2 or 1)
--     return true
-- end

-- -- Obtener todos los vehículos
-- function Vehicle.getAllVehicles()
--     return GetAllVehicles()
-- end

-- -- Obtener vehículos cercanos a coordenadas
-- function Vehicle.getVehiclesInArea(coords, radius)
--     if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
--         return {}
--     end

--     radius = radius or 50.0

--     local vehicles = Vehicle.getAllVehicles()
--     local nearbyVehicles = {}

--     for i = 1, #vehicles do
--         local vehicle = vehicles[i]
--         local vehicleCoords = GetEntityCoords(vehicle)
--         local distance = #(vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3]) - vehicleCoords)

--         if distance <= radius then
--             table.insert(nearbyVehicles, {
--                 vehicle = vehicle,
--                 coords = vehicleCoords,
--                 distance = distance
--             })
--         end
--     end

--     -- Ordenar por distancia
--     table.sort(nearbyVehicles, function(a, b)
--         return a.distance < b.distance
--     end)

--     return nearbyVehicles
-- end

-- -- Obtener conductor del vehículo
-- function Vehicle.getVehicleDriver(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return nil
--     end

--     local driver = GetPedInVehicleSeat(vehicle, -1)
--     return driver ~= 0 and driver or nil
-- end

-- -- Obtener ocupantes del vehículo
-- function Vehicle.getVehicleOccupants(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return {}
--     end

--     local occupants = {}
--     local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)

--     -- Conductor
--     local driver = Vehicle.getVehicleDriver(vehicle)
--     if driver then
--         occupants[-1] = driver
--     end

--     -- Pasajeros
--     for seat = 0, maxSeats - 1 do
--         local passenger = GetPedInVehicleSeat(vehicle, seat)
--         if passenger and passenger ~= 0 then
--             occupants[seat] = passenger
--         end
--     end

--     return occupants
-- end

-- -- Verificar si el vehículo tiene asientos libres
-- function Vehicle.hasFreeSeat(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle) + 1 -- +1 para conductor
--     local occupants = Vehicle.getVehicleOccupants(vehicle)

--     local occupiedCount = 0
--     for _ in pairs(occupants) do
--         occupiedCount = occupiedCount + 1
--     end

--     return occupiedCount < maxSeats
-- end

-- -- Obtener el primer asiento libre
-- function Vehicle.getFreeSeat(vehicle)
--     if not Vehicle.isValidEntity(vehicle) then
--         return nil
--     end

--     -- Verificar conductor
--     if not Vehicle.getVehicleDriver(vehicle) then
--         return -1
--     end

--     -- Verificar asientos de pasajeros
--     local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
--     for seat = 0, maxSeats - 1 do
--         local passenger = GetPedInVehicleSeat(vehicle, seat)
--         if not passenger or passenger == 0 then
--             return seat
--         end
--     end

--     return nil
-- end

-- -- Teletransportar vehículo
-- function Vehicle.teleportVehicle(vehicle, coords, heading)
--     if not Vehicle.isValidEntity(vehicle) then
--         return false
--     end

--     if type(coords) ~= 'vector3' and type(coords) ~= 'table' then
--         return false
--     end

--     SetEntityCoords(vehicle, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], false, false, false, true)

--     if heading then
--         SetEntityHeading(vehicle, heading)
--     end

--     return true
-- end

-- lib.vehicle = Vehicle
-- return lib.vehicle

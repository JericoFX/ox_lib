# 🔄 Sistema de StateBags Reactivo - ox_lib Extended

El Sistema de StateBags Reactivo proporciona una interfaz avanzada para gestionar estados sincronizados en FiveM con watchers automáticos, listeners reactivos y gestión inteligente de cambios de estado.

## 📋 Características Principales

- 🔄 **Estados reactivos** con watchers automáticos
- 🌍 **Estados globales** sincronizados entre todos los clientes
- 👤 **Estados de jugador** individuales y seguimiento
- 🚗 **Estados de entidad** para vehículos, objetos, etc.
- 🎯 **Listeners automáticos** para cambios de estado
- 📊 **Metadata avanzado** con opciones de persistencia
- 🧹 **Gestión automática** de memoria y limpieza

---

## 🚀 Uso Básico

### Instanciación

```lua
-- Usar la instancia global (recomendado)
local statebags = lib.statebags

-- O crear una nueva instancia
local customStateBags = lib.class('StateBags'):new()
```

### Estados Globales

```lua
-- Establecer estado global
statebags:setGlobalState('serverTime', os.time())
statebags:setGlobalState('weather', 'sunny')
statebags:setGlobalState('playerCount', GetNumPlayerIndices())

-- Obtener estado global
local serverTime = statebags:getGlobalState('serverTime')
local weather = statebags:getGlobalState('weather')

-- Estado con opciones
statebags:setGlobalState('importantData', {
    value = 42,
    timestamp = os.time()
}, {
    persistent = true,
    replicated = true
})
```

---

## 👤 Estados de Jugador

### Gestión de Estados de Jugador

```lua
-- Establecer estado de jugador
local playerId = GetPlayerServerId(PlayerId())
statebags:setPlayerState(playerId, 'health', GetEntityHealth(PlayerPedId()))
statebags:setPlayerState(playerId, 'money', 5000)
statebags:setPlayerState(playerId, 'job', 'police')

-- Obtener estado de jugador
local playerHealth = statebags:getPlayerState(playerId, 'health')
local playerMoney = statebags:getPlayerState(playerId, 'money')

-- Estado privado del jugador
statebags:setPlayerState(playerId, 'secretData', 'confidential', {
    private = true
})
```

### Sistema de Status de Jugador

```lua
local PlayerStatus = {}

function PlayerStatus:updateAll(playerId)
    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))

    if ped and ped ~= 0 then
        -- Estados básicos
        lib.statebags:setPlayerState(playerId, lib.enums.statebags.COMMON_KEYS.PLAYER_HEALTH, GetEntityHealth(ped))
        lib.statebags:setPlayerState(playerId, lib.enums.statebags.COMMON_KEYS.PLAYER_ARMOR, GetPedArmour(ped))
        lib.statebags:setPlayerState(playerId, lib.enums.statebags.COMMON_KEYS.PLAYER_COORDS, GetEntityCoords(ped))

        -- Estado del vehículo si está en uno
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            lib.statebags:setPlayerState(playerId, 'currentVehicle', NetworkGetNetworkIdFromEntity(vehicle))
        else
            lib.statebags:setPlayerState(playerId, 'currentVehicle', nil)
        end
    end
end

function PlayerStatus:startTracking(playerId)
    CreateThread(function()
        while true do
            self:updateAll(playerId)
            Wait(1000) -- Actualizar cada segundo
        end
    end)
end

-- Iniciar tracking para jugador local
PlayerStatus:startTracking(GetPlayerServerId(PlayerId()))
```

---

## 🚗 Estados de Entidad

### Estados de Vehículo

```lua
local VehicleStates = {}

function VehicleStates:setupVehicle(vehicle)
    local networkId = NetworkGetNetworkIdFromEntity(vehicle)

    -- Estados básicos del vehículo
    lib.statebags:setEntityState(vehicle, lib.enums.statebags.COMMON_KEYS.VEHICLE_LOCKED, GetVehicleDoorLockStatus(vehicle) > 1)
    lib.statebags:setEntityState(vehicle, lib.enums.statebags.COMMON_KEYS.VEHICLE_ENGINE, GetIsVehicleEngineRunning(vehicle))
    lib.statebags:setEntityState(vehicle, lib.enums.statebags.COMMON_KEYS.VEHICLE_FUEL, GetVehicleFuelLevel(vehicle))

    -- Propiedades del vehículo
    local properties = {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        color = {GetVehicleColours(vehicle)},
        health = GetEntityHealth(vehicle)
    }

    lib.statebags:setEntityState(vehicle, lib.enums.statebags.COMMON_KEYS.VEHICLE_PROPERTIES, properties, {
        persistent = true
    })
end

function VehicleStates:updateVehicleEngine(vehicle, running)
    lib.statebags:setEntityState(vehicle, lib.enums.statebags.COMMON_KEYS.VEHICLE_ENGINE, running)

    -- Trigger para otros sistemas
    TriggerEvent('vehicleStates:engineChanged', vehicle, running)
end

-- Event handlers
AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat, displayName, netId)
    VehicleStates:setupVehicle(vehicle)
end)
```

---

## 🎯 Sistema de Watchers Reactivos

### Watchers Básicos

```lua
-- Watch cambios en estado global
local watcherId = statebags:watchGlobalState('weather', function(key, newValue, oldValue)
    print(string.format("Clima cambió de %s a %s", oldValue or 'unknown', newValue))

    -- Actualizar efectos visuales según el clima
    if newValue == 'rain' then
        SetWeatherTypePersist('RAIN')
    elseif newValue == 'sunny' then
        SetWeatherTypePersist('CLEAR')
    end
end)

-- Watch cambios en estado de jugador
local playerWatcherId = statebags:watchPlayerState(GetPlayerServerId(PlayerId()), 'health', function(playerId, key, newValue, oldValue)
    if newValue < oldValue then
        print("¡Jugador recibió daño!")
        -- Trigger efectos de daño
    elseif newValue > oldValue then
        print("Jugador se curó")
        -- Trigger efectos de curación
    end
end)

-- Watch cambios en estado de entidad
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    local vehicleWatcherId = statebags:watchEntityState(vehicle, 'engine', function(entity, key, newValue, oldValue)
        if newValue then
            print("Motor encendido")
            -- Activar efectos de motor
        else
            print("Motor apagado")
            -- Desactivar efectos de motor
        end
    end)
end
```

### Sistema de Sincronización Automática

```lua
local AutoSync = {}
AutoSync.watchers = {}

function AutoSync:syncPlayerData(playerId)
    -- Watch para health
    self.watchers['health_' .. playerId] = lib.statebags:watchPlayerState(playerId, 'health', function(pid, key, newValue, oldValue)
        if pid == GetPlayerServerId(PlayerId()) then
            -- Solo sincronizar si es el jugador local
            return
        end

        -- Actualizar UI de salud para otros jugadores
        TriggerEvent('hud:updatePlayerHealth', pid, newValue)
    end)

    -- Watch para position
    self.watchers['coords_' .. playerId] = lib.statebags:watchPlayerState(playerId, 'coords', function(pid, key, newValue, oldValue)
        if newValue then
            -- Actualizar marcador en mapa
            TriggerEvent('map:updatePlayerPosition', pid, newValue)
        end
    end)

    -- Watch para job
    self.watchers['job_' .. playerId] = lib.statebags:watchPlayerState(playerId, 'job', function(pid, key, newValue, oldValue)
        print(string.format("Jugador %d cambió trabajo de %s a %s", pid, oldValue or 'none', newValue))

        -- Actualizar permisos y UI
        TriggerEvent('job:playerJobChanged', pid, newValue, oldValue)
    end)
end

function AutoSync:unsyncPlayer(playerId)
    -- Remover watchers del jugador
    for key, watcherId in pairs(self.watchers) do
        if string.find(key, '_' .. playerId) then
            lib.statebags:removeWatcher(watcherId)
            self.watchers[key] = nil
        end
    end
end

-- Setup automático para todos los jugadores
AddEventHandler('playerConnecting', function()
    local playerId = source
    AutoSync:syncPlayerData(playerId)
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    AutoSync:unsyncPlayer(playerId)
end)
```

---

## 🎮 Ejemplos Prácticos

### Sistema de Clima Dinámico

```lua
local DynamicWeather = {}
DynamicWeather.weatherCycle = {
    'CLEAR', 'CLOUDS', 'OVERCAST', 'RAIN', 'CLEARING', 'CLEAR'
}
DynamicWeather.currentIndex = 1

function DynamicWeather:init()
    -- Establecer clima inicial
    lib.statebags:setGlobalState('currentWeather', self.weatherCycle[1])
    lib.statebags:setGlobalState('weatherDuration', 300000) -- 5 minutos

    -- Watch para cambios de clima
    lib.statebags:watchGlobalState('currentWeather', function(key, newValue, oldValue)
        if newValue then
            print("Cambiando clima a:", newValue)
            SetWeatherTypeOvertimePersist(newValue, 30.0) -- Transición de 30 segundos

            -- Notify a todos los jugadores
            TriggerClientEvent('weather:changed', -1, newValue, oldValue)
        end
    end)

    -- Ciclo automático de clima
    CreateThread(function()
        while true do
            local duration = lib.statebags:getGlobalState('weatherDuration') or 300000
            Wait(duration)

            self.currentIndex = self.currentIndex < #self.weatherCycle and self.currentIndex + 1 or 1
            lib.statebags:setGlobalState('currentWeather', self.weatherCycle[self.currentIndex])
        end
    end)
end

function DynamicWeather:setWeather(weather, duration)
    lib.statebags:setGlobalState('currentWeather', weather)
    if duration then
        lib.statebags:setGlobalState('weatherDuration', duration)
    end
end

-- Inicializar sistema
DynamicWeather:init()
```

### Sistema de Zonas Dinámicas

```lua
local DynamicZones = {}
DynamicZones.zones = {}
DynamicZones.playerStates = {}

function DynamicZones:createZone(zoneId, coords, radius, data)
    self.zones[zoneId] = {
        coords = coords,
        radius = radius,
        data = data,
        players = {}
    }

    -- Establecer estado global de la zona
    lib.statebags:setGlobalState('zone_' .. zoneId, {
        active = true,
        players = {},
        data = data
    })
end

function DynamicZones:checkPlayerZones(playerId)
    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
    if not ped or ped == 0 then return end

    local playerCoords = GetEntityCoords(ped)
    local currentZones = {}

    -- Verificar todas las zonas
    for zoneId, zone in pairs(self.zones) do
        local distance = #(playerCoords - zone.coords)

        if distance <= zone.radius then
            currentZones[zoneId] = true

            -- Jugador entró en zona
            if not zone.players[playerId] then
                zone.players[playerId] = true
                self:onPlayerEnterZone(playerId, zoneId, zone)
            end
        else
            -- Jugador salió de zona
            if zone.players[playerId] then
                zone.players[playerId] = nil
                self:onPlayerExitZone(playerId, zoneId, zone)
            end
        end
    end

    -- Actualizar estado del jugador
    lib.statebags:setPlayerState(playerId, 'currentZones', currentZones)
end

function DynamicZones:onPlayerEnterZone(playerId, zoneId, zone)
    print(string.format("Jugador %d entró en zona %s", playerId, zoneId))

    -- Actualizar lista de jugadores en la zona
    local zoneState = lib.statebags:getGlobalState('zone_' .. zoneId)
    if zoneState then
        zoneState.players[playerId] = true
        lib.statebags:setGlobalState('zone_' .. zoneId, zoneState)
    end

    -- Trigger eventos específicos de zona
    TriggerClientEvent('zones:playerEntered', playerId, zoneId, zone.data)
end

function DynamicZones:onPlayerExitZone(playerId, zoneId, zone)
    print(string.format("Jugador %d salió de zona %s", playerId, zoneId))

    -- Actualizar lista de jugadores en la zona
    local zoneState = lib.statebags:getGlobalState('zone_' .. zoneId)
    if zoneState then
        zoneState.players[playerId] = nil
        lib.statebags:setGlobalState('zone_' .. zoneId, zoneState)
    end

    -- Trigger eventos específicos de zona
    TriggerClientEvent('zones:playerExited', playerId, zoneId, zone.data)
end

-- Thread de verificación continua
CreateThread(function()
    while true do
        for _, playerId in ipairs(GetPlayers()) do
            DynamicZones:checkPlayerZones(tonumber(playerId))
        end
        Wait(1000)
    end
end)

-- Crear zonas de ejemplo
DynamicZones:createZone('hospital', vector3(300.0, -600.0, 43.0), 50.0, {
    type = 'safe_zone',
    healing = true
})

DynamicZones:createZone('police_station', vector3(400.0, -1000.0, 29.0), 75.0, {
    type = 'restricted',
    job_required = 'police'
})
```

### Sistema de Estado de Servidor

```lua
local ServerState = {}

function ServerState:init()
    -- Estados básicos del servidor
    lib.statebags:setGlobalState('serverStartTime', os.time())
    lib.statebags:setGlobalState('serverStatus', 'online')
    lib.statebags:setGlobalState('maxPlayers', GetConvarInt('sv_maxclients', 32))

    -- Watch para conteo de jugadores
    lib.statebags:watchGlobalState('playerCount', function(key, newValue, oldValue)
        print(string.format("Jugadores en línea: %d/%d", newValue, lib.statebags:getGlobalState('maxPlayers')))

        -- Actualizar Discord status si está configurado
        if GetResourceState('discordrich') == 'started' then
            exports.discordrich:updatePresence({
                details = string.format("Jugadores: %d/%d", newValue, lib.statebags:getGlobalState('maxPlayers'))
            })
        end
    end)

    -- Actualización automática de estadísticas
    CreateThread(function()
        while true do
            lib.statebags:setGlobalState('playerCount', GetNumPlayerIndices())
            lib.statebags:setGlobalState('serverUptime', os.time() - lib.statebags:getGlobalState('serverStartTime'))

            Wait(5000) -- Actualizar cada 5 segundos
        end
    end)
end

function ServerState:setMaintenanceMode(enabled, reason)
    lib.statebags:setGlobalState('maintenanceMode', enabled)
    lib.statebags:setGlobalState('maintenanceReason', reason or 'Mantenimiento del servidor')

    if enabled then
        -- Notificar a todos los jugadores
        TriggerClientEvent('server:maintenanceMode', -1, true, reason)
    end
end

-- Inicializar sistema de estado del servidor
ServerState:init()
```

---

## 🔧 Utilidades Avanzadas

### Gestión de Watchers

```lua
-- Obtener conteo de watchers activos
local watcherCount = statebags:getWatcherCount()
print("Watchers activos:", watcherCount)

-- Remover watcher específico
statebags:removeWatcher(watcherId)

-- Remover todos los watchers de la instancia
statebags:removeAllWatchers()

-- Verificar si un estado existe
local exists = statebags:stateExists('global', 'weather')
if exists then
    print("Estado 'weather' existe")
end

-- Obtener estados que coincidan con patrón
local weatherStates = statebags:getGlobalStatesMatching('weather.*')
for key, value in pairs(weatherStates) do
    print(key, value)
end
```

### Debugging y Monitoreo

```lua
local StateMonitor = {}

function StateMonitor:init()
    -- Monitor para cambios de estado global
    lib.statebags:watchGlobalState('.*', function(key, newValue, oldValue)
        if GetConvarInt('debug_statebags', 0) > 0 then
            print(string.format("[StateBags] Global: %s = %s (was: %s)", key, tostring(newValue), tostring(oldValue)))
        end
    end)

    -- Monitor de performance
    CreateThread(function()
        while true do
            local watcherCount = lib.statebags:getWatcherCount()

            if watcherCount > 50 then
                print("⚠️ Advertencia: Muchos watchers activos:", watcherCount)
            end

            Wait(30000) -- Check cada 30 segundos
        end
    end)
end

-- Activar con debug_statebags 1
StateMonitor:init()
```

---

## 📚 Enums Disponibles

### Tipos de Estado

```lua
lib.enums.statebags.STATE_TYPES.GLOBAL
lib.enums.statebags.STATE_TYPES.PLAYER
lib.enums.statebags.STATE_TYPES.ENTITY
```

### Claves Comunes

```lua
-- Estados de jugador
lib.enums.statebags.COMMON_KEYS.PLAYER_HEALTH
lib.enums.statebags.COMMON_KEYS.PLAYER_ARMOR
lib.enums.statebags.COMMON_KEYS.PLAYER_COORDS
lib.enums.statebags.COMMON_KEYS.PLAYER_JOB

-- Estados de vehículo
lib.enums.statebags.COMMON_KEYS.VEHICLE_LOCKED
lib.enums.statebags.COMMON_KEYS.VEHICLE_ENGINE
lib.enums.statebags.COMMON_KEYS.VEHICLE_FUEL

-- Estados globales
lib.enums.statebags.COMMON_KEYS.SERVER_TIME
lib.enums.statebags.COMMON_KEYS.WEATHER
lib.enums.statebags.COMMON_KEYS.PLAYER_COUNT
```

---

## ⚠️ Consideraciones

### Performance

- Limite el número de watchers simultáneos
- Use patterns específicos en lugar de wildcard cuando sea posible
- Considere la frecuencia de actualización de estados

### Limitaciones

- Los StateBags tienen límites de tamaño en FiveM
- Estados muy complejos pueden afectar el rendimiento de red
- La persistencia depende de la configuración del servidor

---

## 🔗 APIs Relacionadas

- [**Sistema de Audio**](./AUDIO_API.md) - Para sincronizar estados de audio
- [**Sistema de Cámaras**](./CAMERA_API.md) - Para estados de cámara sincronizados
- [**Sistema de Armas**](./WEAPONS_API.md) - Para estados de armas de jugador

---

Esta documentación cubre el uso del Sistema de StateBags Reactivo. Para implementaciones específicas, consulta los ejemplos prácticos y experimenta con las diferentes opciones de configuración.

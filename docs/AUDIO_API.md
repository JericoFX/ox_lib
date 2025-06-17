# 🎵 Sistema de Audio Avanzado - ox_lib Extended

El Sistema de Audio Avanzado proporciona una interfaz completa para gestionar audio en FiveM con funciones avanzadas como audio 3D, efectos de fade, pooling automático y gestión inteligente de recursos.

## 📋 Características Principales

- 🎯 **Audio 3D posicional** con control de rango
- 🔄 **Efectos de fade** in/out suaves
- 🎛️ **Control de volumen** dinámico
- 📦 **Pooling automático** de recursos de audio
- 🎪 **Audio adjunto a entidades**
- 📻 **Control de radio** y música personalizada
- 🧹 **Limpieza automática** de audio finalizado

---

## 🚀 Uso Básico

### Instanciación

```lua
-- Usar la instancia global (recomendado)
local audio = lib.audio

-- O crear una nueva instancia
local customAudio = lib.class('Audio'):new()
```

### Reproducir Sonidos Básicos

```lua
-- Sonido simple
local audioId = audio:playSound("SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")

-- Sonido con opciones
local audioId = audio:playSound("EXPLOSION", lib.enums.audio.SOUND_SETS.WORLD, {
    volume = 0.8,
    fadeIn = 1000
})
```

---

## 🎯 Audio 3D Posicional

### Reproducir Audio en Coordenadas

```lua
-- Audio 3D básico
local coords = vector3(100.0, 200.0, 50.0)
local audioId = audio:play3D("ENGINE_START", coords, lib.enums.audio.SOUND_SETS.VEHICLE, {
    range = 100.0,
    volume = 0.7
})

-- Audio con fade in
local audioId = audio:play3D("RADIO_STATIC", coords, "RADIO_SOUNDSET", {
    range = 75.0,
    volume = 0.5,
    fadeIn = 2000
})
```

### Audio Adjunto a Entidades

```lua
-- Adjuntar sonido a vehículo
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local audioId = audio:playOnEntity("ENGINE_IDLE", vehicle, lib.enums.audio.SOUND_SETS.VEHICLE)

-- Adjuntar sonido a ped con opciones
local ped = PlayerPedId()
local audioId = audio:playOnEntity("HEARTBEAT", ped, "HEALTH_SOUNDSET", {
    volume = 0.6,
    loop = true
})
```

---

## 🎛️ Control de Audio

### Control de Volumen

```lua
-- Cambiar volumen dinámicamente
audio:setVolume(audioId, 0.3)

-- Ejemplo de control de volumen por distancia
CreateThread(function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local audioCoords = vector3(100.0, 200.0, 50.0)

    while audio:isPlaying(audioId) do
        local distance = #(playerCoords - audioCoords)
        local volume = math.max(0.1, 1.0 - (distance / 100.0))

        audio:setVolume(audioId, volume)
        Wait(100)
    end
end)
```

### Efectos de Fade

```lua
-- Fade in manual
audio:fadeIn(audioId, 3000) -- 3 segundos

-- Fade out con callback
audio:fadeOut(audioId, 2000, function()
    print("Audio fade out completado")
end)

-- Detener con fade out
audio:stop(audioId, 1500) -- Fade out de 1.5 segundos
```

---

## 📻 Control de Radio

### Estaciones de Radio

```lua
-- Cambiar estación de radio
audio:setRadioStation(lib.enums.audio.RADIO_STATIONS.NON_STOP_POP)

-- Obtener estación actual
local currentStation = audio:getRadioStation()
print("Estación actual:", currentStation)

-- Radio personalizada
audio:setCustomRadio("Mi Canción Favorita", "Artista Genial")
```

---

## 🎮 Ejemplos Prácticos

### Sistema de Ambiente Dinámico

```lua
local AmbientAudio = {}
AmbientAudio.zones = {}

function AmbientAudio:createZone(coords, radius, soundName, soundSet)
    local zoneId = #self.zones + 1

    self.zones[zoneId] = {
        coords = coords,
        radius = radius,
        soundName = soundName,
        soundSet = soundSet,
        audioId = nil,
        active = false
    }

    return zoneId
end

function AmbientAudio:updateZones()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for zoneId, zone in pairs(self.zones) do
        local distance = #(playerCoords - zone.coords)
        local shouldPlay = distance <= zone.radius

        if shouldPlay and not zone.active then
            -- Entrar en zona
            zone.audioId = lib.audio:play3D(zone.soundName, zone.coords, zone.soundSet, {
                range = zone.radius,
                volume = 0.0,
                loop = true
            })

            lib.audio:fadeIn(zone.audioId, 2000)
            zone.active = true

        elseif not shouldPlay and zone.active then
            -- Salir de zona
            lib.audio:fadeOut(zone.audioId, 2000, function()
                lib.audio:stop(zone.audioId)
            end)
            zone.active = false
        end
    end
end

-- Uso del sistema
AmbientAudio:createZone(vector3(100, 200, 30), 50, "OCEAN_WAVES", "WORLD_SOUNDSET")
AmbientAudio:createZone(vector3(300, 400, 25), 75, "CITY_TRAFFIC", "WORLD_SOUNDSET")

CreateThread(function()
    while true do
        AmbientAudio:updateZones()
        Wait(1000)
    end
end)
```

### Sistema de Notificaciones con Audio

```lua
local NotificationAudio = {}

function NotificationAudio:success(message)
    lib.audio:playSound(lib.enums.audio.SOUNDS.SUCCESS, lib.enums.audio.SOUND_SETS.DEFAULT, {
        volume = 0.6
    })
    -- Mostrar notificación visual
    lib.notify({
        title = 'Éxito',
        description = message,
        type = 'success'
    })
end

function NotificationAudio:error(message)
    lib.audio:playSound(lib.enums.audio.SOUNDS.ERROR, lib.enums.audio.SOUND_SETS.DEFAULT, {
        volume = 0.8
    })
    -- Mostrar notificación visual
    lib.notify({
        title = 'Error',
        description = message,
        type = 'error'
    })
end

function NotificationAudio:phone(caller)
    local ringId = lib.audio:playSound(lib.enums.audio.SOUNDS.PHONE_RING, lib.enums.audio.SOUND_SETS.PHONE, {
        volume = 0.7,
        loop = true
    })

    -- Simular llamada por 10 segundos
    SetTimeout(10000, function()
        lib.audio:stop(ringId, 500) -- Fade out de 500ms
    end)

    return ringId
end

-- Uso
NotificationAudio:success("Operación completada correctamente")
NotificationAudio:error("Ha ocurrido un error")
local callId = NotificationAudio:phone("Juan Pérez")
```

### Sistema de Audio para Vehículos

```lua
local VehicleAudio = {}
VehicleAudio.engines = {}

function VehicleAudio:startEngine(vehicle)
    if self.engines[vehicle] then return end

    local audioId = lib.audio:playOnEntity("ENGINE_START", vehicle, lib.enums.audio.SOUND_SETS.VEHICLE, {
        volume = 0.8
    })

    self.engines[vehicle] = {
        startId = audioId,
        idleId = nil,
        running = true
    }

    -- Después del sonido de inicio, reproducir idle
    SetTimeout(2000, function()
        if self.engines[vehicle] then
            self.engines[vehicle].idleId = lib.audio:playOnEntity("ENGINE_IDLE", vehicle, lib.enums.audio.SOUND_SETS.VEHICLE, {
                volume = 0.4,
                loop = true
            })
        end
    end)
end

function VehicleAudio:stopEngine(vehicle)
    if not self.engines[vehicle] then return end

    local engineData = self.engines[vehicle]

    -- Detener idle
    if engineData.idleId then
        lib.audio:stop(engineData.idleId, 1000)
    end

    -- Reproducir sonido de apagado
    lib.audio:playOnEntity("ENGINE_STOP", vehicle, lib.enums.audio.SOUND_SETS.VEHICLE, {
        volume = 0.6
    })

    self.engines[vehicle] = nil
end

-- Eventos del vehículo
AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat, displayName, netId)
    if seat == -1 then -- Driver seat
        VehicleAudio:startEngine(vehicle)
    end
end)

AddEventHandler('baseevents:leftVehicle', function(vehicle, seat, displayName, netId)
    if seat == -1 then -- Driver seat
        VehicleAudio:stopEngine(vehicle)
    end
end)
```

---

## 🔧 Utilidades

### Gestión de Audio

```lua
-- Verificar si audio está reproduciéndose
if audio:isPlaying(audioId) then
    print("Audio activo")
end

-- Obtener cantidad de audio activo
local activeCount = audio:getActiveCount()
print("Audios activos:", activeCount)

-- Detener todo el audio
audio:stopAll(2000) -- Con fade out de 2 segundos

-- Limpieza manual (normalmente automática)
audio:cleanup()
```

### Estadísticas de Audio

```lua
-- Monitorear uso de audio
CreateThread(function()
    while true do
        local activeCount = lib.audio:getActiveCount()

        if activeCount > 10 then
            print("⚠️ Muchos audios activos:", activeCount)
        end

        Wait(5000)
    end
end)
```

---

## 📚 Enums Disponibles

### Conjuntos de Sonidos

```lua
lib.enums.audio.SOUND_SETS.DEFAULT
lib.enums.audio.SOUND_SETS.PHONE
lib.enums.audio.SOUND_SETS.WEAPON
lib.enums.audio.SOUND_SETS.VEHICLE
lib.enums.audio.SOUND_SETS.RADIO
lib.enums.audio.SOUND_SETS.UI
lib.enums.audio.SOUND_SETS.MISSION
lib.enums.audio.SOUND_SETS.WORLD
```

### Sonidos Comunes

```lua
-- UI
lib.enums.audio.SOUNDS.SELECT
lib.enums.audio.SOUNDS.BACK
lib.enums.audio.SOUNDS.ERROR
lib.enums.audio.SOUNDS.SUCCESS

-- Teléfono
lib.enums.audio.SOUNDS.PHONE_RING
lib.enums.audio.SOUNDS.PHONE_PICKUP
lib.enums.audio.SOUNDS.PHONE_HANGUP

-- Armas
lib.enums.audio.SOUNDS.WEAPON_RELOAD
lib.enums.audio.SOUNDS.WEAPON_EMPTY
lib.enums.audio.SOUNDS.WEAPON_SWITCH
```

### Estaciones de Radio

```lua
lib.enums.audio.RADIO_STATIONS.NON_STOP_POP
lib.enums.audio.RADIO_STATIONS.LOS_SANTOS_ROCK
lib.enums.audio.RADIO_STATIONS.CHANNEL_X
lib.enums.audio.RADIO_STATIONS.REBEL_RADIO
-- ... y muchas más
```

---

## ⚠️ Consideraciones

### Performance

- El sistema incluye limpieza automática cada 5 segundos
- Se recomienda no tener más de 20 audios simultáneos
- Los efectos de fade consumen más recursos

### Limitaciones

- Los audios 3D tienen un límite de rango del motor
- Algunos sonidos pueden no estar disponibles en todos los contextos
- La gestión de memoria depende del motor de FiveM

---

## 🔗 APIs Relacionadas

- [**Sistema de StateBags**](./STATEBAGS_API.md) - Para sincronizar estados de audio
- [**Sistema de NPCs**](./NPC_SYSTEM.md) - Para audio de NPCs
- [**Sistema de Cámaras**](./CAMERA_API.md) - Para audio cinemático

---

Esta documentación cubre el uso básico y avanzado del Sistema de Audio. Para casos de uso específicos, consulta los ejemplos prácticos o experimenta con las diferentes opciones disponibles.

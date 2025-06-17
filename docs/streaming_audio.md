# Streaming Audio API

La API de streaming de audio de ox_lib proporciona funcionalidades nativas de audio streaming inspiradas en **mana_audio** por Manason. Esta implementación permite reproducir **audios personalizados** (.awc) y audios nativos de GTA V usando los sistemas de streaming del juego con soporte para 3D audio y control avanzado.

## Créditos

Esta implementación está inspirada en y es compatible con **mana_audio** por Manason.

**Créditos a:**

- **Manason** (creador de mana_audio)
- PrinceAlbert, Demi-Automatic, ChatDisabled, Joe Szymkowicz, y Zoo

**Repositorio original:** https://github.com/Manason/mana_audio

## Búsque en:

- Documentación de FiveM sobre nativos de audio: https://docs.fivem.net/natives/?_0xE65F427EB70AB1ED
- Tutorial de audio nativo: https://forum.cfx.re/t/how-to-make-a-simplesound-using-native-audio/5156001
- Repositorio mana_audio: https://github.com/Manason/mana_audio

## Características

- ✅ **Streaming de audio personalizado**: Reproduce archivos .awc personalizados via streaming nativo
- ✅ **Compatibilidad con mana_audio**: API similar para migración fácil
- ✅ **Soporte 3D**: Audio posicional con entidades y coordenadas
- ✅ **Control de rango**: Especifica el rango de audición para audio basado en coordenadas
- ✅ **Selección aleatoria**: Soporte para arrays de nombres de audio para selección aleatoria
- ✅ **Gestión automática**: Carga y descarga automática de audio banks (.awc)
- ✅ **Control lado servidor**: Reproducir audio desde el servidor a clientes específicos o todos
- ✅ **Integración completa**: Se integra perfectamente con el sistema de audio existente de ox_lib

## Funciones Cliente

### `lib.audio:playStreamingSound(options)`

Reproduce un sonido streaming que no está ubicado en el mundo 3D.

```lua
---@param options table
---@field audioBank string Nombre del audio bank
---@field audioName string|string[] Nombre del audio o array para selección aleatoria
---@field audioRef string Referencia de audio
---@return number|nil audioId ID único del audio para control

local audioId = lib.audio:playStreamingSound({
    audioBank = 'HUD_GLOBAL_SOUNDSET',
    audioName = 'SELECT',
    audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
})
```

### `lib.audio:playStreamingSoundFromEntity(options)`

Reproduce un sonido streaming originado desde una entidad.

```lua
---@param options table
---@field audioBank string Nombre del audio bank
---@field audioName string|string[] Nombre del audio
---@field audioRef string Referencia de audio
---@field entity number Entidad desde la que reproducir
---@return number|nil audioId ID único del audio

local audioId = lib.audio:playStreamingSoundFromEntity({
    audioBank = 'WEAPONS_SOUNDSET',
    audioName = 'WEAPON_RELOAD',
    audioRef = 'WEAPONS_SOUNDSET',
    entity = PlayerPedId()
})
```

### `lib.audio:playStreamingSoundFromCoords(options)`

Reproduce un sonido streaming originado desde coordenadas específicas.

```lua
---@param options table
---@field audioBank string Nombre del audio bank
---@field audioName string|string[] Nombre del audio
---@field audioRef string Referencia de audio
---@field coords vector3 Coordenadas desde donde reproducir
---@field range? number Rango de audición (por defecto: 10)
---@return number|nil audioId ID único del audio

local audioId = lib.audio:playStreamingSoundFromCoords({
    audioBank = 'AMBIENT_SOUNDSET',
    audioName = 'EXPLOSION',
    audioRef = 'WORLD_SOUNDSET',
    coords = vector3(0, 0, 72),
    range = 15.0
})
```

## Funciones Servidor

### `lib.streamingAudio.playSound(target, options)`

Reproduce un sonido a cliente(s) específico(s) desde el servidor.

```lua
---@param target number|number[] ID(s) de cliente o -1 para todos
---@param options StreamingAudioOptions Opciones de audio

-- Reproducir para todos los clientes
lib.streamingAudio.playSound(-1, {
    audioBank = 'HUD_GLOBAL_SOUNDSET',
    audioName = 'SUCCESS',
    audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
})

-- Reproducir para cliente específico
lib.streamingAudio.playSound(playerId, {
    audioBank = 'DIALOGUE_SOUNDSET',
    audioName = 'Phone_SoundSet_Michael',
    audioRef = 'PHONE_SOUNDSET'
})

-- Reproducir para múltiples clientes
lib.streamingAudio.playSound({1, 2, 3}, {
    audioBank = 'PAIN_SOUNDSET',
    audioName = 'PAIN_SHORT',
    audioRef = 'PAIN_SOUNDSET'
})
```

### `lib.streamingAudio.playSoundFromEntity(options)`

Reproduce un sonido desde una entidad para todos los clientes.

```lua
---@param options StreamingAudioOptions Opciones (entity requerido)

lib.streamingAudio.playSoundFromEntity({
    audioBank = 'VEHICLES_SOUNDSET',
    audioName = 'ENGINE_START',
    audioRef = 'VEHICLES_SOUNDSET',
    entity = GetPlayerPed(playerId)
})
```

### `lib.streamingAudio.playSoundFromCoords(options)`

Reproduce un sonido desde coordenadas para todos los clientes en rango.

```lua
---@param options StreamingAudioOptions Opciones (coords requerido)

lib.streamingAudio.playSoundFromCoords({
    audioBank = 'WEAPONS_SOUNDSET',
    audioName = 'EXPLOSION',
    audioRef = 'WEAPONS_SOUNDSET',
    coords = vector3(100, 200, 30),
    range = 25.0
})
```

## Enums Disponibles

### Audio Banks

```lua
lib.enums.audio.AUDIO_BANKS = {
    SCRIPT = "SCRIPT",
    INTERACTIVE_MUSIC = "INTERACTIVE_MUSIC",
    MICHAEL = "MICHAEL_SOUNDS",
    FRANKLIN = "FRANKLIN_SOUNDS",
    TREVOR = "TREVOR_SOUNDS",
    FLEECA_HEIST = "DLC_HEIST_FLEECA_SOUNDSET",
    CASINO_HEIST = "DLC_CASINO_SOUNDSET",
    CUSTOM = "CUSTOM_AUDIO_BANK"
}
```

### Audio References

```lua
lib.enums.audio.AUDIO_REFS = {
    DEFAULT = "",
    HUD_GLOBAL_SOUNDSET = "HUD_GLOBAL_SOUNDSET",
    DIALOGUE_SOUNDSET = "DIALOGUE_SOUNDSET",
    PHONE_SOUNDSET = "PHONE_SOUNDSET",
    PAIN_SOUNDSET = "PAIN_SOUNDSET",
    AMBIENT_SOUNDSET = "AMBIENT_SOUNDSET",
    WEAPON_SOUNDSET = "WEAPONS_SOUNDSET",
    VEHICLE_SOUNDSET = "VEHICLES_SOUNDSET",
    POLICE_SCANNER = "POLICE_SCANNER_SOUNDS",
    HUD_FRONTEND = "HUD_FRONTEND_DEFAULT_SOUNDSET",
    CUSTOM = "CUSTOM_SOUNDS"
}
```

## Gestión de Audio Banks

### `lib.audio:requestAudioBank(audioBank, timeout)`

Solicita y carga un audio bank con manejo de errores.

```lua
---@param audioBank string Nombre del audio bank
---@param timeout? number Timeout en milisegundos (por defecto: 10000)
---@return boolean success Si el bank se cargó exitosamente

local success = lib.audio:requestAudioBank('CUSTOM_AUDIO_BANK', 15000)
if success then
    -- Usar el audio bank
end
```

### `lib.audio:releaseAudioBank(audioBank)`

Libera un audio bank de la memoria.

```lua
---@param audioBank string Nombre del audio bank

lib.audio:releaseAudioBank('CUSTOM_AUDIO_BANK')
```

## Selección Aleatoria de Audio

Puedes proporcionar un array de nombres de audio para selección aleatoria:

```lua
lib.audio:playStreamingSound({
    audioBank = 'PAIN_SOUNDSET',
    audioName = {'PAIN_SHORT', 'PAIN_LONG', 'PAIN_MEDIUM'}, -- Selección aleatoria
    audioRef = 'PAIN_SOUNDSET'
})
```

## Ejemplos de Uso

### Ejemplo Básico - Cliente

```lua
-- Reproducir sonido simple
local audioId = lib.audio:playStreamingSound({
    audioBank = lib.enums.audio.AUDIO_BANKS.SCRIPT,
    audioName = lib.enums.audio.SOUNDS.SELECT,
    audioRef = lib.enums.audio.AUDIO_REFS.HUD_FRONTEND
})

-- Detener el sonido después de 5 segundos
if audioId then
    SetTimeout(5000, function()
        lib.audio:stop(audioId)
    end)
end
```

### Ejemplo Básico - Servidor

```lua
-- Reproducir sonido para todos cuando un jugador se conecta
AddEventHandler('playerConnecting', function()
    lib.streamingAudio.playSound(-1, {
        audioBank = 'HUD_GLOBAL_SOUNDSET',
        audioName = 'SUCCESS',
        audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    })
end)
```

### Ejemplo Avanzado - Audio Personalizado

```lua
-- Cliente: Cargar y reproducir audio personalizado
RegisterCommand('custom_sound', function()
    -- Solicitar el audio bank personalizado
    local success = lib.audio:requestAudioBank('MY_CUSTOM_BANK', 15000)

    if success then
        local audioId = lib.audio:playStreamingSound({
            audioBank = 'MY_CUSTOM_BANK',
            audioName = 'MY_CUSTOM_SOUND',
            audioRef = 'CUSTOM_SOUNDS'
        })

        if audioId then
            lib.notify({
                title = 'Audio',
                description = 'Reproduciendo audio personalizado',
                type = 'success'
            })

            -- Liberar el bank después de usar
            SetTimeout(10000, function()
                lib.audio:releaseAudioBank('MY_CUSTOM_BANK')
            end)
        end
    else
        lib.notify({
            title = 'Error',
            description = 'No se pudo cargar el audio bank personalizado',
            type = 'error'
        })
    end
end)
```

## Compatibilidad con mana_audio

Esta implementación es compatible con el estilo de mana_audio pero integrada nativamente en ox_lib. La migración desde mana_audio es simple:

### Antes (mana_audio)

```lua
exports.mana_audio:PlaySound({
    audioBank = 'myAudioBank',
    audioName = 'myAudioName',
    audioRef = 'myAudioRef'
})
```

### Después (ox_lib)

```lua
lib.audio:playStreamingSound({
    audioBank = 'myAudioBank',
    audioName = 'myAudioName',
    audioRef = 'myAudioRef'
})
```

## Uso con Archivos de Audio Personalizados

### Preparación de Audio Personalizado

Para usar archivos de audio personalizados (.awc), necesitas:

1. **Crear archivos .awc**: Usa CodeWalker para crear contenedores .awc con tus sonidos
2. **Crear archivos .dat54.rel**: Define los SimpleSounds en archivos .dat54.rel
3. **Estructura de archivos**: Organiza tus archivos de audio en tu resource

### Estructura de Archivos Recomendada

```
tu_resource/
├── audiodirectory/
│   ├── custom_sounds.awc          # Tu contenedor de audio personalizado
│   └── ambient_sounds.awc         # Otro contenedor de audio
├── data/
│   ├── custom_sounds.dat54.rel    # Definiciones de SimpleSounds
│   └── ambient_sounds.dat54.rel   # Más definiciones
├── fxmanifest.lua
├── client.lua
└── server.lua
```

### Ejemplo con Audio Personalizado

```lua
-- Ejemplo usando audio personalizado
RegisterCommand('play_custom_audio', function()
    -- Cargar el audio bank personalizado
    local success = lib.audio:requestAudioBank('custom_sounds', 15000)

    if success then
        local audioId = lib.audio:playStreamingSound({
            audioBank = 'custom_sounds',           -- Tu .awc personalizado
            audioName = 'mi_sonido_personalizado', -- Definido en tu .dat54.rel
            audioRef = 'CUSTOM_SOUNDS'             -- Tu referencia personalizada
        })

        if audioId then
            lib.notify({
                title = 'Audio Personalizado',
                description = 'Reproduciendo tu sonido personalizado',
                type = 'success'
            })
        end
    end
end)

-- Ejemplo desde servidor con audio personalizado
RegisterCommand('server_custom_audio', function(source)
    lib.streamingAudio.playSound(-1, {
        audioBank = 'ambient_sounds',        -- Tu .awc de sonidos ambientales
        audioName = 'sonido_ambiente_1',     -- Sonido definido en .dat54.rel
        audioRef = 'AMBIENT_CUSTOM'          -- Referencia personalizada
    })
end)
```

### Ejemplo Avanzado: Sistema de Notificaciones con Audio Personalizado

```lua
-- Cliente: Sistema de notificaciones con sonidos personalizados
function playNotificationSound(notificationType)
    local audioConfig = {
        success = {
            audioBank = 'notification_sounds',
            audioName = 'success_chime',
            audioRef = 'NOTIFICATION_SOUNDS'
        },
        error = {
            audioBank = 'notification_sounds',
            audioName = 'error_buzz',
            audioRef = 'NOTIFICATION_SOUNDS'
        },
        warning = {
            audioBank = 'notification_sounds',
            audioName = 'warning_beep',
            audioRef = 'NOTIFICATION_SOUNDS'
        }
    }

    local config = audioConfig[notificationType]
    if config then
        lib.audio:playStreamingSound(config)
    end
end

-- Uso del sistema
RegisterCommand('test_notifications', function()
    playNotificationSound('success')

    SetTimeout(2000, function()
        playNotificationSound('warning')
    end)

    SetTimeout(4000, function()
        playNotificationSound('error')
    end)
end)
```

### Configuración en fxmanifest.lua

Para usar audio personalizado, asegúrate de incluir tus archivos en el fxmanifest:

```lua
-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

-- Archivos de audio
files {
    'audiodirectory/*.awc',
    'data/*.dat54.rel'
}

-- Streaming de archivos de audio
data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data'
```

## Notas Importantes

- ⚠️ **Audio Banks**: Asegúrate de que los audio banks existan y estén disponibles
- ⚠️ **Rendimiento**: Los audio banks se cargan automáticamente pero liberarlos manualmente mejora el rendimiento
- ⚠️ **Rango**: El rango para audio basado en coordenadas es en unidades del juego
- ⚠️ **Cleanup**: El sistema hace cleanup automático de audio finalizado cada 5 segundos

## Solución de Problemas

### El audio no se reproduce

1. Verifica que el audio bank existe
2. Confirma que el nombre del audio es correcto
3. Asegúrate de que la referencia de audio es válida

### Audio bank no se carga

1. Verifica el nombre del audio bank
2. Aumenta el timeout si es necesario
3. Revisa la consola para mensajes de error

### Audio se reproduce pero no se escucha

1. Verifica el volumen del juego
2. Confirma que estás en el rango correcto (para audio 3D)
3. Revisa si hay otros audios interfiriendo

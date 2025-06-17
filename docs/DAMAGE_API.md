# ⚔️ Sistema de Daño Simple - ox_lib Extended

El Sistema de Daño Simple proporciona un wrapper básico pero efectivo alrededor de los eventos de daño de bajo nivel de FiveM, facilitando la captura, procesamiento y gestión de eventos de daño.

## 📋 Características Principales

- 🎯 **Wrapper simple** de eventos de daño nativos
- 📊 **Handlers personalizados** para diferentes tipos de daño
- 🛡️ **Sistema de cancelación** de daño
- 👤 **Tracking específico** por jugador y entidad
- 💾 **Información detallada** de daño con contexto
- 🔧 **Utilidades básicas** para gestión de salud

---

## 🚀 Uso Básico

### Instanciación

```lua
-- Usar la instancia global (recomendado)
local damage = lib.damage

-- O crear una nueva instancia
local customDamage = lib.class('Damage'):new()
```

### Handlers de Daño Básicos

```lua
-- Handler general de daño
local handlerId = damage:onDamage(function(damageInfo)
    print(string.format("Daño detectado: %d a entidad %d por %d",
        damageInfo.damage, damageInfo.entity, damageInfo.attacker))

    -- Retornar false para cancelar el daño
    return true -- Permitir daño
end)

-- Handler específico para jugador
local playerHandlerId = damage:onPlayerDamage(function(damageInfo)
    print(string.format("Jugador recibió %d de daño", damageInfo.damage))

    -- Ejemplo: reducir daño si el jugador tiene armadura especial
    if GetPedArmour(damageInfo.entity) > 50 then
        -- Reducir daño a la mitad
        damageInfo.damage = damageInfo.damage * 0.5
        return true
    end

    return true
end)

-- Handler para entidad específica
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    local vehicleHandlerId = damage:onEntityDamage(vehicle, function(damageInfo)
        print(string.format("Vehículo %d recibió %d de daño", damageInfo.entity, damageInfo.damage))
        return true
    end)
end
```

---

## 🎯 Aplicación Manual de Daño

### Daño Básico

```lua
-- Aplicar daño a entidad
damage:applyDamage(PlayerPedId(), 50)

-- Aplicar daño con arma específica
damage:applyDamage(PlayerPedId(), 25, "WEAPON_PISTOL")

-- Aplicar daño completo con contexto
damage:applyDamage(PlayerPedId(), 75, "WEAPON_ASSAULTRIFLE", GetPlayerPed(GetPlayerFromServerId(1)), GetEntityCoords(PlayerPedId()))

-- Daño a vehículo
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    damage:applyVehicleDamage(vehicle, 500, 1) -- Daño al motor
end
```

---

## 🎮 Ejemplos Prácticos

### Sistema de Daño por Zonas

```lua
local ZoneDamage = {}
ZoneDamage.zones = {}

function ZoneDamage:createDamageZone(coords, radius, damagePerSecond, damageType)
    local zoneId = #self.zones + 1

    self.zones[zoneId] = {
        coords = coords,
        radius = radius,
        damagePerSecond = damagePerSecond,
        damageType = damageType or "fire",
        active = true
    }

    return zoneId
end

function ZoneDamage:checkZones()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for zoneId, zone in pairs(self.zones) do
        if zone.active then
            local distance = #(playerCoords - zone.coords)

            if distance <= zone.radius then
                -- Jugador dentro de zona de daño
                local damageAmount = math.max(1, zone.damagePerSecond * (1 - (distance / zone.radius)))

                -- Aplicar daño basado en el tipo
                if zone.damageType == "fire" then
                    lib.damage:applyDamage(playerPed, damageAmount, "WEAPON_FIRE")

                    -- Efectos visuales de fuego
                    StartEntityFire(playerPed)

                elseif zone.damageType == "radiation" then
                    lib.damage:applyDamage(playerPed, damageAmount)

                    -- Efectos de radiación
                    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)

                elseif zone.damageType == "toxic" then
                    lib.damage:applyDamage(playerPed, damageAmount)

                    -- Efectos tóxicos
                    SetPedToRagdoll(playerPed, 1000, 1000, 0, false, false, false)
                end

                print(string.format("Daño de zona %s: %.1f", zone.damageType, damageAmount))
            end
        end
    end
end

-- Thread de verificación
CreateThread(function()
    while true do
        ZoneDamage:checkZones()
        Wait(1000) -- Verificar cada segundo
    end
end)

-- Crear zonas de ejemplo
ZoneDamage:createDamageZone(vector3(100, 200, 30), 25.0, 5, "fire")      -- Zona de fuego
ZoneDamage:createDamageZone(vector3(200, 300, 25), 50.0, 2, "radiation") -- Zona radioactiva
ZoneDamage:createDamageZone(vector3(300, 400, 20), 15.0, 8, "toxic")     -- Zona tóxica
```

### Sistema de Daño Personalizado por Arma

```lua
local CustomWeaponDamage = {}
CustomWeaponDamage.weaponMultipliers = {}

function CustomWeaponDamage:init()
    -- Configurar multiplicadores de daño por arma
    self.weaponMultipliers = {
        [GetHashKey("WEAPON_PISTOL")] = 0.8,        -- 80% del daño base
        [GetHashKey("WEAPON_ASSAULTRIFLE")] = 1.2,  -- 120% del daño base
        [GetHashKey("WEAPON_SNIPERRIFLE")] = 2.0,   -- 200% del daño base
        [GetHashKey("WEAPON_KNIFE")] = 1.5,         -- 150% del daño base
    }

    -- Handler para modificar daño de armas
    lib.damage:onDamage(function(damageInfo)
        local weaponHash = damageInfo.weapon
        local multiplier = self.weaponMultipliers[weaponHash]

        if multiplier then
            local originalDamage = damageInfo.damage
            damageInfo.damage = math.floor(damageInfo.damage * multiplier)

            print(string.format("Daño modificado: %d -> %d (x%.1f)",
                originalDamage, damageInfo.damage, multiplier))
        end

        return true
    end)
end

function CustomWeaponDamage:setWeaponMultiplier(weaponName, multiplier)
    local weaponHash = GetHashKey(weaponName)
    self.weaponMultipliers[weaponHash] = multiplier
end

-- Inicializar sistema
CustomWeaponDamage:init()

-- Configurar multiplicadores personalizados
CustomWeaponDamage:setWeaponMultiplier("WEAPON_COMBATPISTOL", 0.9)
CustomWeaponDamage:setWeaponMultiplier("WEAPON_PUMPSHOTGUN", 1.8)
```

### Sistema de Protección por Trabajo/Rol

```lua
local RoleProtection = {}
RoleProtection.protections = {}

function RoleProtection:init()
    -- Configurar protecciones por trabajo
    self.protections = {
        police = {
            damageReduction = 0.2,  -- 20% menos daño
            immuneTo = {"WEAPON_STUNGUN"},
            healingBonus = 1.5
        },
        medic = {
            damageReduction = 0.1,  -- 10% menos daño
            immuneTo = {},
            healingBonus = 2.0
        },
        firefighter = {
            damageReduction = 0.15, -- 15% menos daño
            immuneTo = {"WEAPON_FIRE", "WEAPON_MOLOTOV"},
            healingBonus = 1.2
        }
    }

    -- Handler de protección
    lib.damage:onPlayerDamage(function(damageInfo)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(damageInfo.entity))
        local playerJob = self:getPlayerJob(playerId)

        if playerJob and self.protections[playerJob] then
            local protection = self.protections[playerJob]

            -- Verificar inmunidad
            local weaponName = self:getWeaponNameFromHash(damageInfo.weapon)
            for _, immuneWeapon in ipairs(protection.immuneTo) do
                if weaponName == immuneWeapon then
                    print(string.format("Jugador %d es inmune a %s", playerId, weaponName))
                    return false -- Cancelar daño
                end
            end

            -- Aplicar reducción de daño
            if protection.damageReduction > 0 then
                local originalDamage = damageInfo.damage
                damageInfo.damage = math.floor(damageInfo.damage * (1 - protection.damageReduction))

                print(string.format("Daño reducido para %s: %d -> %d",
                    playerJob, originalDamage, damageInfo.damage))
            end
        end

        return true
    end)
end

function RoleProtection:getPlayerJob(playerId)
    -- Integración con framework (ejemplo)
    if GetResourceState('es_extended') == 'started' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer and xPlayer.job.name or nil
    elseif GetResourceState('qb-core') == 'started' then
        local Player = QBCore.Functions.GetPlayer(playerId)
        return Player and Player.PlayerData.job.name or nil
    end

    return nil
end

function RoleProtection:getWeaponNameFromHash(weaponHash)
    -- Buscar nombre del arma por hash
    for weaponName, data in pairs(lib.enums.weapons.WEAPONS) do
        if GetHashKey(weaponName) == weaponHash then
            return weaponName
        end
    end
    return "UNKNOWN"
end

-- Inicializar protecciones
RoleProtection:init()
```

### Sistema de Daño por Caída Realista

```lua
local FallDamage = {}
FallDamage.lastHeights = {}

function FallDamage:init()
    -- Handler para daño por caída
    lib.damage:onPlayerDamage(function(damageInfo)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(damageInfo.entity))

        -- Verificar si el daño es por caída
        if damageInfo.weapon == 0 and damageInfo.damage > 0 then
            local ped = damageInfo.entity

            if IsPedFalling(ped) or HasEntityCollidedWithAnything(ped) then
                -- Calcular daño realista basado en altura
                local fallHeight = self:calculateFallHeight(playerId, ped)

                if fallHeight > 3.0 then -- Caída de más de 3 metros
                    local calculatedDamage = self:calculateFallDamage(fallHeight)

                    -- Reemplazar daño original con calculado
                    damageInfo.damage = calculatedDamage

                    print(string.format("Caída de %.1fm: %d de daño", fallHeight, calculatedDamage))

                    -- Efectos adicionales para caídas graves
                    if fallHeight > 10.0 then
                        -- Caída muy alta - efectos adicionales
                        SetPedToRagdoll(ped, 3000, 3000, 0, false, false, false)
                        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.5)
                    elseif fallHeight > 6.0 then
                        -- Caída alta - ragdoll temporal
                        SetPedToRagdoll(ped, 1500, 1500, 0, false, false, false)
                    end
                end
            end
        end

        return true
    end)

    -- Thread para trackear alturas
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local playerId = GetPlayerServerId(PlayerId())

            if not IsPedInAnyVehicle(ped, false) then
                self.lastHeights[playerId] = coords.z
            end

            Wait(500)
        end
    end)
end

function FallDamage:calculateFallHeight(playerId, ped)
    local currentCoords = GetEntityCoords(ped)
    local lastHeight = self.lastHeights[playerId]

    if lastHeight then
        return math.max(0, lastHeight - currentCoords.z)
    end

    return 0
end

function FallDamage:calculateFallDamage(height)
    -- Fórmula realista de daño por caída
    if height < 3.0 then
        return 0
    elseif height < 6.0 then
        return math.floor((height - 3.0) * 15) -- 0-45 daño
    elseif height < 15.0 then
        return math.floor(45 + (height - 6.0) * 10) -- 45-135 daño
    else
        return 200 -- Caída mortal
    end
end

-- Inicializar sistema de caída
FallDamage:init()
```

---

## 🔧 Utilidades de Salud

### Gestión Básica de Salud

```lua
-- Obtener salud de entidad
local health = damage:getEntityHealth(PlayerPedId())
print("Salud actual:", health)

-- Establecer salud
damage:setEntityHealth(PlayerPedId(), 200)

-- Verificar si está muerto
if damage:isEntityDead(PlayerPedId()) then
    print("El jugador está muerto")
end

-- Obtener multiplicador de daño por parte del cuerpo
local headMultiplier = damage:getDamageMultiplier(lib.enums.damage.BODY_PARTS.HEAD)
print("Multiplicador de cabeza:", headMultiplier) -- 2.0
```

### Sistema de Curación Gradual

```lua
local HealingSystem = {}

function HealingSystem:healOverTime(entity, totalAmount, duration, callback)
    local startTime = GetGameTimer()
    local currentHealth = lib.damage:getEntityHealth(entity)
    local maxHealth = GetEntityMaxHealth(entity)
    local targetHealth = math.min(maxHealth, currentHealth + totalAmount)

    CreateThread(function()
        while GetGameTimer() - startTime < duration do
            local progress = (GetGameTimer() - startTime) / duration
            local newHealth = currentHealth + (totalAmount * progress)

            lib.damage:setEntityHealth(entity, math.floor(newHealth))

            Wait(100) -- Actualizar cada 100ms
        end

        lib.damage:setEntityHealth(entity, targetHealth)

        if callback then
            callback()
        end
    end)
end

-- Uso del sistema de curación
HealingSystem:healOverTime(PlayerPedId(), 50, 5000, function()
    print("Curación completada")
end)
```

---

## 🔧 Gestión de Handlers

```lua
-- Remover handler específico
damage:removeDamageHandler(handlerId)

-- Ejemplo de handler temporal
local tempHandlerId = damage:onDamage(function(damageInfo)
    print("Handler temporal activado")

    -- Auto-remover después de 30 segundos
    SetTimeout(30000, function()
        lib.damage:removeDamageHandler(tempHandlerId)
        print("Handler temporal removido")
    end)

    return true
end)
```

---

## 📚 Enums Disponibles

### Tipos de Daño

```lua
lib.enums.damage.DAMAGE_TYPES.MELEE
lib.enums.damage.DAMAGE_TYPES.BULLET
lib.enums.damage.DAMAGE_TYPES.EXPLOSION
lib.enums.damage.DAMAGE_TYPES.FIRE
lib.enums.damage.DAMAGE_TYPES.COLLISION
lib.enums.damage.DAMAGE_TYPES.FALL
```

### Partes del Cuerpo

```lua
lib.enums.damage.BODY_PARTS.HEAD      -- 31086
lib.enums.damage.BODY_PARTS.NECK      -- 39317
lib.enums.damage.BODY_PARTS.SPINE_1   -- 24816
lib.enums.damage.BODY_PARTS.LEFT_ARM  -- 61163
lib.enums.damage.BODY_PARTS.RIGHT_ARM -- 28252
```

### Multiplicadores de Daño

```lua
-- Automáticamente disponibles
local headMultiplier = lib.enums.damage.DAMAGE_MULTIPLIERS[31086] -- 2.0
local neckMultiplier = lib.enums.damage.DAMAGE_MULTIPLIERS[39317] -- 1.5
```

---

## ⚠️ Consideraciones

### Performance

- Los handlers de daño se ejecutan frecuentemente en combate
- Evite operaciones costosas dentro de los handlers
- Limite el número de handlers activos simultáneamente

### Limitaciones

- Este es un wrapper simple, no modifica el motor de daño nativo
- Algunos tipos de daño pueden no ser interceptables
- La cancelación de daño puede no funcionar en todos los contextos

---

## 🔗 APIs Relacionadas

- [**Sistema de Armas**](./WEAPONS_API.md) - Para integrar daño de armas
- [**Sistema de StateBags**](./STATEBAGS_API.md) - Para sincronizar estados de salud
- [**Sistema de Audio**](./AUDIO_API.md) - Para efectos de audio de daño

---

Esta documentación cubre el uso básico del Sistema de Daño Simple. Para implementaciones más complejas, considera combinar con otros sistemas de ox_lib Extended.

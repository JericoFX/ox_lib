# 🔫 Sistema de Armas Completo - ox_lib Extended

El Sistema de Armas Completo proporciona gestión avanzada de armas en FiveM, incluyendo control de attachments, modificaciones, tracking automático y sistemas de customización completos.

## 📋 Características Principales

- 🎯 **Gestión completa** de armas con cache inteligente
- 🔧 **Sistema de attachments** avanzado
- 🎨 **Customización visual** con tints y skins
- 📊 **Tracking automático** de cambios de arma
- 💾 **Cache persistente** de configuraciones
- 🔄 **Sincronización** con otros sistemas
- 📈 **Estadísticas** y monitoreo de uso

---

## 🚀 Uso Básico

### Instanciación

```lua
-- Usar la instancia global (recomendado)
local weapons = lib.weapons

-- O crear una nueva instancia
local customWeapons = lib.class('Weapons'):new()
```

### Gestión Básica de Armas

```lua
-- Dar arma básica
local success = weapons:giveWeapon(nil, "WEAPON_PISTOL")

-- Dar arma con opciones
local success = weapons:giveWeapon(PlayerPedId(), "WEAPON_ASSAULTRIFLE", {
    ammo = 500,
    visible = true,
    equipNow = true,
    attachments = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_MEDIUM"}
})

-- Verificar si tiene arma
if weapons:hasWeapon(nil, "WEAPON_PISTOL") then
    print("El jugador tiene pistola")
end

-- Obtener arma actual
local currentWeapon = weapons:getCurrentWeapon()
if currentWeapon then
    print("Arma actual:", currentWeapon)
end

-- Remover arma
weapons:removeWeapon(nil, "WEAPON_PISTOL")
```

---

## 🔧 Sistema de Attachments

### Attachments Básicos

```lua
-- Añadir attachment
local success = weapons:addAttachment(nil, "WEAPON_ASSAULTRIFLE", "COMPONENT_AT_AR_FLSH")
if success then
    print("Linterna añadida al rifle")
end

-- Remover attachment
local success = weapons:removeAttachment(nil, "WEAPON_ASSAULTRIFLE", "COMPONENT_AT_AR_FLSH")
if success then
    print("Linterna removida del rifle")
end

-- Obtener todos los attachments de un arma
local attachments = weapons:getAttachments(nil, "WEAPON_ASSAULTRIFLE")
for _, attachment in ipairs(attachments) do
    print("Attachment:", attachment)
end
```

### Sistema de Loadouts Avanzado

```lua
local WeaponLoadouts = {}

function WeaponLoadouts:createLoadout(name, weaponConfigs)
    local loadout = {
        name = name,
        weapons = {},
        created = os.time()
    }

    for _, config in ipairs(weaponConfigs) do
        table.insert(loadout.weapons, {
            weapon = config.weapon,
            ammo = config.ammo or 250,
            attachments = config.attachments or {},
            tint = config.tint or 0
        })
    end

    return loadout
end

function WeaponLoadouts:applyLoadout(ped, loadout)
    ped = ped or PlayerPedId()

    -- Remover todas las armas primero
    RemoveAllPedWeapons(ped, true)

    -- Aplicar cada arma del loadout
    for _, weaponConfig in ipairs(loadout.weapons) do
        -- Dar arma base
        lib.weapons:giveWeapon(ped, weaponConfig.weapon, {
            ammo = weaponConfig.ammo,
            visible = true
        })

        -- Añadir attachments
        for _, attachment in ipairs(weaponConfig.attachments) do
            lib.weapons:addAttachment(ped, weaponConfig.weapon, attachment)
        end

        -- Aplicar tint
        if weaponConfig.tint > 0 then
            lib.weapons:setTint(ped, weaponConfig.weapon, weaponConfig.tint)
        end
    end

    print(string.format("Loadout '%s' aplicado con %d armas", loadout.name, #loadout.weapons))
end

-- Crear loadouts predefinidos
local policeLoadout = WeaponLoadouts:createLoadout("Police", {
    {
        weapon = "WEAPON_COMBATPISTOL",
        ammo = 150,
        attachments = {"COMPONENT_AT_PI_FLSH"},
        tint = lib.enums.weapons.TINTS.LSPD
    },
    {
        weapon = "WEAPON_PUMPSHOTGUN",
        ammo = 50,
        attachments = {"COMPONENT_AT_AR_FLSH"},
        tint = lib.enums.weapons.TINTS.LSPD
    }
})

local militaryLoadout = WeaponLoadouts:createLoadout("Military", {
    {
        weapon = "WEAPON_ASSAULTRIFLE",
        ammo = 300,
        attachments = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_AR_AFGRIP"},
        tint = lib.enums.weapons.TINTS.ARMY
    },
    {
        weapon = "WEAPON_COMBATPISTOL",
        ammo = 100,
        attachments = {"COMPONENT_AT_PI_SUPP"},
        tint = lib.enums.weapons.TINTS.ARMY
    }
})

-- Aplicar loadout
WeaponLoadouts:applyLoadout(PlayerPedId(), policeLoadout)
```

---

## 🎨 Customización Visual

### Tints y Apariencia

```lua
-- Aplicar tint dorado
weapons:setTint(nil, "WEAPON_PISTOL", lib.enums.weapons.TINTS.GOLD)

-- Obtener tint actual
local currentTint = weapons:getTint(nil, "WEAPON_PISTOL")
print("Tint actual:", currentTint)

-- Sistema de customización avanzada
local WeaponCustomizer = {}

function WeaponCustomizer:customizeWeapon(ped, weaponName, customization)
    ped = ped or PlayerPedId()

    if not lib.weapons:hasWeapon(ped, weaponName) then
        print("El jugador no tiene el arma:", weaponName)
        return false
    end

    -- Aplicar tint si se especifica
    if customization.tint then
        lib.weapons:setTint(ped, weaponName, customization.tint)
    end

    -- Remover attachments existentes si se especifica
    if customization.clearAttachments then
        local currentAttachments = lib.weapons:getAttachments(ped, weaponName)
        for _, attachment in ipairs(currentAttachments) do
            lib.weapons:removeAttachment(ped, weaponName, attachment)
        end
    end

    -- Añadir nuevos attachments
    if customization.attachments then
        for _, attachment in ipairs(customization.attachments) do
            lib.weapons:addAttachment(ped, weaponName, attachment)
        end
    end

    -- Configurar munición
    if customization.ammo then
        lib.weapons:setAmmo(ped, weaponName, customization.ammo)
    end

    return true
end

-- Uso del customizer
WeaponCustomizer:customizeWeapon(PlayerPedId(), "WEAPON_ASSAULTRIFLE", {
    tint = lib.enums.weapons.TINTS.GOLD,
    clearAttachments = true,
    attachments = {
        "COMPONENT_AT_AR_FLSH",
        "COMPONENT_AT_SCOPE_LARGE",
        "COMPONENT_AT_AR_SUPP",
        "COMPONENT_AT_AR_AFGRIP"
    },
    ammo = 999
})
```

---

## 🎮 Ejemplos Prácticos

### Sistema de Inventario de Armas

```lua
local WeaponInventory = {}
WeaponInventory.inventory = {}

function WeaponInventory:addWeapon(playerId, weaponName, data)
    if not self.inventory[playerId] then
        self.inventory[playerId] = {}
    end

    self.inventory[playerId][weaponName] = {
        ammo = data.ammo or 0,
        attachments = data.attachments or {},
        tint = data.tint or 0,
        condition = data.condition or 100,
        serial = data.serial or self:generateSerial(),
        addedTime = os.time()
    }
end

function WeaponInventory:removeWeapon(playerId, weaponName)
    if self.inventory[playerId] then
        self.inventory[playerId][weaponName] = nil
    end
end

function WeaponInventory:getWeaponData(playerId, weaponName)
    if self.inventory[playerId] then
        return self.inventory[playerId][weaponName]
    end
    return nil
end

function WeaponInventory:equipWeapon(playerId, weaponName)
    local weaponData = self:getWeaponData(playerId, weaponName)
    if not weaponData then
        print("Arma no encontrada en inventario")
        return false
    end

    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))

    -- Dar arma con configuración guardada
    lib.weapons:giveWeapon(ped, weaponName, {
        ammo = weaponData.ammo,
        equipNow = true,
        attachments = weaponData.attachments
    })

    -- Aplicar tint
    lib.weapons:setTint(ped, weaponName, weaponData.tint)

    print(string.format("Arma %s equipada para jugador %d", weaponName, playerId))
    return true
end

function WeaponInventory:saveCurrentWeapons(playerId)
    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
    local weapons = lib.weapons:getAllWeapons(ped)

    for _, weaponName in ipairs(weapons) do
        local weaponData = {
            ammo = lib.weapons:getAmmo(ped, weaponName),
            attachments = lib.weapons:getAttachments(ped, weaponName),
            tint = lib.weapons:getTint(ped, weaponName),
            condition = math.random(80, 100) -- Simulado
        }

        self:addWeapon(playerId, weaponName, weaponData)
    end
end

function WeaponInventory:generateSerial()
    return string.format("WPN-%d-%s", os.time(), string.upper(string.sub(tostring(math.random()), 3, 8)))
end

-- Event handlers para auto-guardar
AddEventHandler('playerDropped', function()
    local playerId = source
    WeaponInventory:saveCurrentWeapons(playerId)
end)
```

### Sistema de Tienda de Armas

```lua
local WeaponShop = {}
WeaponShop.catalog = {}

function WeaponShop:addItem(weaponName, price, category, requirements)
    self.catalog[weaponName] = {
        weapon = weaponName,
        price = price,
        category = category or "general",
        requirements = requirements or {},
        inStock = true
    }
end

function WeaponShop:canPurchase(playerId, weaponName)
    local item = self.catalog[weaponName]
    if not item then
        return false, "Arma no disponible"
    end

    if not item.inStock then
        return false, "Arma fuera de stock"
    end

    -- Verificar requisitos (ejemplo: licencia, trabajo, etc.)
    if item.requirements.license then
        -- Verificar licencia del jugador
        local hasLicense = exports.framework:hasLicense(playerId, item.requirements.license)
        if not hasLicense then
            return false, "Licencia requerida: " .. item.requirements.license
        end
    end

    if item.requirements.job then
        -- Verificar trabajo del jugador
        local playerJob = exports.framework:getPlayerJob(playerId)
        if playerJob ~= item.requirements.job then
            return false, "Trabajo requerido: " .. item.requirements.job
        end
    end

    -- Verificar dinero
    local playerMoney = exports.framework:getPlayerMoney(playerId)
    if playerMoney < item.price then
        return false, "Dinero insuficiente"
    end

    return true
end

function WeaponShop:purchaseWeapon(playerId, weaponName, customization)
    local canPurchase, reason = self:canPurchase(playerId, weaponName)
    if not canPurchase then
        return false, reason
    end

    local item = self.catalog[weaponName]
    local ped = GetPlayerPed(GetPlayerFromServerId(playerId))

    -- Remover dinero
    exports.framework:removePlayerMoney(playerId, item.price)

    -- Dar arma
    lib.weapons:giveWeapon(ped, weaponName, {
        ammo = 250,
        visible = true
    })

    -- Aplicar customización si se proporciona
    if customization then
        if customization.attachments then
            for _, attachment in ipairs(customization.attachments) do
                lib.weapons:addAttachment(ped, weaponName, attachment)
            end
        end

        if customization.tint then
            lib.weapons:setTint(ped, weaponName, customization.tint)
        end
    end

    -- Añadir al inventario
    WeaponInventory:addWeapon(playerId, weaponName, {
        ammo = 250,
        attachments = customization and customization.attachments or {},
        tint = customization and customization.tint or 0,
        condition = 100,
        purchased = true,
        purchaseTime = os.time()
    })

    return true, "Arma comprada exitosamente"
end

-- Configurar catálogo de la tienda
WeaponShop:addItem("WEAPON_PISTOL", 5000, "handgun", {license = "weapon_license"})
WeaponShop:addItem("WEAPON_COMBATPISTOL", 8000, "handgun", {license = "weapon_license"})
WeaponShop:addItem("WEAPON_PUMPSHOTGUN", 15000, "shotgun", {license = "weapon_license", job = "police"})
WeaponShop:addItem("WEAPON_ASSAULTRIFLE", 25000, "rifle", {license = "weapon_license", job = "military"})

-- Comando para comprar arma
RegisterCommand('buyweapon', function(source, args)
    local weaponName = args[1]
    if not weaponName then
        TriggerClientEvent('chat:addMessage', source, {args = {"Error", "Especifica el nombre del arma"}})
        return
    end

    local success, message = WeaponShop:purchaseWeapon(source, weaponName:upper())
    TriggerClientEvent('chat:addMessage', source, {
        args = {success and "Éxito" or "Error", message}
    })
end)
```

### Sistema de Degradación de Armas

```lua
local WeaponDegradation = {}
WeaponDegradation.weaponConditions = {}

function WeaponDegradation:initWeapon(ped, weaponName)
    local pedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    if not self.weaponConditions[pedId] then
        self.weaponConditions[pedId] = {}
    end

    if not self.weaponConditions[pedId][weaponName] then
        self.weaponConditions[pedId][weaponName] = {
            condition = 100,
            shots = 0,
            lastUsed = os.time()
        }
    end
end

function WeaponDegradation:degradeWeapon(ped, weaponName, amount)
    local pedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    if not self.weaponConditions[pedId] or not self.weaponConditions[pedId][weaponName] then
        return
    end

    local weaponData = self.weaponConditions[pedId][weaponName]
    weaponData.condition = math.max(0, weaponData.condition - amount)
    weaponData.shots = weaponData.shots + 1
    weaponData.lastUsed = os.time()

    -- Aplicar efectos basados en la condición
    if weaponData.condition < 20 then
        -- Arma casi rota - reducir daño significativamente
        self:applyConditionEffects(ped, weaponName, 0.5)

        if math.random(1, 100) <= 10 then -- 10% chance de atasco
            self:jamWeapon(ped, weaponName)
        end
    elseif weaponData.condition < 50 then
        -- Arma en mal estado - reducir daño moderadamente
        self:applyConditionEffects(ped, weaponName, 0.7)

        if math.random(1, 100) <= 5 then -- 5% chance de atasco
            self:jamWeapon(ped, weaponName)
        end
    elseif weaponData.condition < 80 then
        -- Arma desgastada - reducir daño ligeramente
        self:applyConditionEffects(ped, weaponName, 0.9)
    end

    print(string.format("Arma %s: condición %d%% (%d disparos)", weaponName, weaponData.condition, weaponData.shots))
end

function WeaponDegradation:applyConditionEffects(ped, weaponName, damageMultiplier)
    -- Este sería implementado con modificadores de daño reales
    print(string.format("Aplicando multiplicador de daño %.1fx para %s", damageMultiplier, weaponName))
end

function WeaponDegradation:jamWeapon(ped, weaponName)
    print(string.format("¡Arma %s se atascó!", weaponName))

    -- Simular atasco removiendo temporalmente el arma
    lib.weapons:removeWeapon(ped, weaponName)

    -- Devolver arma después de unos segundos
    SetTimeout(3000, function()
        lib.weapons:giveWeapon(ped, weaponName, {ammo = 1, equipNow = true})
        print("Arma desbloqueada")
    end)
end

function WeaponDegradation:repairWeapon(ped, weaponName, amount)
    local pedId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))

    if self.weaponConditions[pedId] and self.weaponConditions[pedId][weaponName] then
        local weaponData = self.weaponConditions[pedId][weaponName]
        weaponData.condition = math.min(100, weaponData.condition + amount)
        print(string.format("Arma %s reparada. Condición: %d%%", weaponName, weaponData.condition))
    end
end

-- Event listener para disparos
AddEventHandler('weaponDamageEvent', function(sender, data)
    local ped = GetPlayerPed(sender)
    local currentWeapon = lib.weapons:getCurrentWeapon(ped)

    if currentWeapon then
        WeaponDegradation:initWeapon(ped, currentWeapon)
        WeaponDegradation:degradeWeapon(ped, currentWeapon, math.random(1, 3))
    end
end)
```

---

## 🔧 Utilidades y Estadísticas

### Información de Armas

```lua
-- Obtener todas las armas del jugador
local weapons = weapons:getAllWeapons()
for _, weapon in ipairs(weapons) do
    local ammo = weapons:getAmmo(nil, weapon)
    local attachments = weapons:getAttachments(nil, weapon)
    local tint = weapons:getTint(nil, weapon)

    print(string.format("Arma: %s, Munición: %d, Attachments: %d, Tint: %d",
        weapon, ammo, #attachments, tint))
end

-- Obtener daño de arma
local damage = weapons:getWeaponDamage("WEAPON_ASSAULTRIFLE")
print("Daño del rifle:", damage)

-- Verificar validez de arma
if weapons:isValidWeapon("WEAPON_PISTOL") then
    print("Pistola es un arma válida")
end
```

### Sistema de Estadísticas

```lua
local WeaponStats = {}
WeaponStats.stats = {}

function WeaponStats:trackShot(playerId, weaponName, target, damage)
    if not self.stats[playerId] then
        self.stats[playerId] = {}
    end

    if not self.stats[playerId][weaponName] then
        self.stats[playerId][weaponName] = {
            shots = 0,
            hits = 0,
            kills = 0,
            totalDamage = 0,
            accuracy = 0
        }
    end

    local weaponStats = self.stats[playerId][weaponName]
    weaponStats.shots = weaponStats.shots + 1

    if target and damage > 0 then
        weaponStats.hits = weaponStats.hits + 1
        weaponStats.totalDamage = weaponStats.totalDamage + damage

        -- Verificar si fue kill
        if IsEntityDead(target) then
            weaponStats.kills = weaponStats.kills + 1
        end
    end

    -- Calcular accuracy
    weaponStats.accuracy = (weaponStats.hits / weaponStats.shots) * 100
end

function WeaponStats:getPlayerStats(playerId)
    return self.stats[playerId] or {}
end

function WeaponStats:getWeaponStats(playerId, weaponName)
    if self.stats[playerId] then
        return self.stats[playerId][weaponName]
    end
    return nil
end

-- Comando para ver estadísticas
RegisterCommand('weaponstats', function(source)
    local stats = WeaponStats:getPlayerStats(source)

    for weaponName, weaponStats in pairs(stats) do
        local message = string.format("%s: %d disparos, %d aciertos, %.1f%% precisión, %d kills",
            weaponName, weaponStats.shots, weaponStats.hits, weaponStats.accuracy, weaponStats.kills)

        TriggerClientEvent('chat:addMessage', source, {args = {"Stats", message}})
    end
end)
```

---

## 📚 Enums Disponibles

### Categorías de Armas

```lua
lib.enums.weapons.CATEGORIES.MELEE
lib.enums.weapons.CATEGORIES.HANDGUN
lib.enums.weapons.CATEGORIES.SMG
lib.enums.weapons.CATEGORIES.SHOTGUN
lib.enums.weapons.CATEGORIES.ASSAULT_RIFLE
lib.enums.weapons.CATEGORIES.SNIPER
lib.enums.weapons.CATEGORIES.HEAVY
```

### Armas Comunes

```lua
-- Pistolas
lib.enums.weapons.WEAPONS.PISTOL
lib.enums.weapons.WEAPONS.COMBAT_PISTOL
lib.enums.weapons.WEAPONS.AP_PISTOL

-- Rifles
lib.enums.weapons.WEAPONS.ASSAULT_RIFLE
lib.enums.weapons.WEAPONS.CARBINE_RIFLE
lib.enums.weapons.WEAPONS.SPECIAL_CARBINE

-- Escopetas
lib.enums.weapons.WEAPONS.PUMP_SHOTGUN
lib.enums.weapons.WEAPONS.ASSAULT_SHOTGUN
```

### Attachments

```lua
-- Scopes
lib.enums.weapons.ATTACHMENTS.SCOPE
lib.enums.weapons.ATTACHMENTS.SCOPE_SMALL
lib.enums.weapons.ATTACHMENTS.SCOPE_MEDIUM

-- Suppressors
lib.enums.weapons.ATTACHMENTS.SUPPRESSOR
lib.enums.weapons.ATTACHMENTS.SUPPRESSOR_LIGHT

-- Flashlights
lib.enums.weapons.ATTACHMENTS.FLASHLIGHT
lib.enums.weapons.ATTACHMENTS.FLASHLIGHT_LIGHT
```

### Tints

```lua
lib.enums.weapons.TINTS.DEFAULT   -- 0
lib.enums.weapons.TINTS.GREEN     -- 1
lib.enums.weapons.TINTS.GOLD      -- 2
lib.enums.weapons.TINTS.PINK      -- 3
lib.enums.weapons.TINTS.ARMY      -- 4
lib.enums.weapons.TINTS.LSPD      -- 5
lib.enums.weapons.TINTS.ORANGE    -- 6
lib.enums.weapons.TINTS.PLATINUM  -- 7
```

---

## ⚠️ Consideraciones

### Performance

- El tracking automático consume recursos si hay muchos jugadores
- Cache las consultas frecuentes de attachments
- Limite el número de armas simultáneas por jugador

### Limitaciones

- Los attachments dependen de compatibilidad del modelo de arma
- Algunos tints pueden no estar disponibles para todas las armas
- La persistencia depende de la implementación del framework

---

## 🔗 APIs Relacionadas

- [**Sistema de Daño**](./DAMAGE_API.md) - Para integrar con el sistema de daño
- [**Sistema de StateBags**](./STATEBAGS_API.md) - Para sincronizar estados de armas
- [**Sistema de Base de Datos**](./DATABASE_API.md) - Para persistir configuraciones

---

Esta documentación cubre el uso completo del Sistema de Armas. Para implementaciones específicas de frameworks, consulta los ejemplos prácticos y adapta según tu configuración.

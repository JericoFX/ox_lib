# 🤖 Sistema Avanzado de NPCs - ox_lib

Sistema inteligente de NPCs con IA avanzada, comportamientos complejos, programación horaria y sistema de memoria.

## 📋 Índice

1. [Instalación](#instalación)
2. [Conceptos Básicos](#conceptos-básicos)
3. [API Reference](#api-reference)
4. [Comportamientos](#comportamientos)
5. [Configuración Avanzada](#configuración-avanzada)
6. [Ejemplos Prácticos](#ejemplos-prácticos)
7. [Sistema de IA](#sistema-de-ia)
8. [Best Practices](#best-practices)

---

## 🚀 Instalación

```lua
-- En tu resource, agrega la dependencia
dependency 'ox_lib'

-- En tu código
local npc = lib.npc
```

---

## 🎯 Conceptos Básicos

### **Estados de IA**

- `IDLE` - En reposo, sin actividad específica
- `PATROLLING` - Patrullando entre puntos
- `INTERACTING` - Interactuando con jugadores
- `WORKING` - Realizando tareas de trabajo
- `ALERT` - Estado de alerta por amenaza
- `FLEEING` - Huyendo por miedo
- `PURSUING` - Persiguiendo una amenaza

### **Estructura Básica de NPC**

```lua
local npcConfig = {
    model = 'a_m_y_business_01',        -- Modelo del NPC
    coords = vector3(100, 200, 25),     -- Coordenadas de spawn
    heading = 180.0,                    -- Orientación inicial
    behaviors = {'civilian'},           -- Comportamientos activos

    -- Configuración básica
    invincible = false,                 -- Si es invencible
    frozen = false,                     -- Si está congelado
    blockEvents = true,                 -- Bloquear eventos temporales
    canRagdoll = true,                  -- Puede caer/ragdoll
}
```

---

## 📚 API Reference

### **npc.create(config)**

Crea un nuevo NPC con configuración avanzada.

```lua
-- Parámetros:
-- config (table): Configuración completa del NPC

local guardId = lib.npc.create({
    model = 's_m_y_cop_01',
    coords = vector3(150, -1040, 29.3),
    heading = 0.0,
    behaviors = {'guard'},

    guardZone = {
        center = vector3(150, -1040, 29.3),
        radius = 25.0
    },

    combat = {
        ability = 3,        -- 0-3 (0=poor, 3=professional)
        range = 2,          -- 0-3 (0=close, 3=long)
        movement = 2,       -- 0-3 (0=stationary, 3=mobile)
        weapon = 'WEAPON_PISTOL'
    }
})

-- Retorna: number (ID del NPC) o false si falló
```

### **npc.registerBehavior(name, behaviorFunc)**

Registra un comportamiento personalizado.

```lua
-- Parámetros:
-- name (string): Nombre del comportamiento
-- behaviorFunc (function): Función que define el comportamiento

lib.npc.registerBehavior('custom_patrol', function(npcData)
    local ped = npcData.ped
    -- Tu lógica personalizada aquí
    print('Ejecutando comportamiento personalizado')
end)

-- Retorna: boolean (éxito)
```

### **npc.changeBehavior(npcId, behaviorName)**

Cambia el comportamiento de un NPC.

```lua
-- Parámetros:
-- npcId (number): ID del NPC
-- behaviorName (string): Nombre del nuevo comportamiento

lib.npc.changeBehavior(guardId, 'patrol')

-- Retorna: boolean (éxito)
```

### **npc.getInfo(npcId)**

Obtiene información completa de un NPC.

```lua
-- Parámetros:
-- npcId (number): ID del NPC

local npcInfo = lib.npc.getInfo(guardId)
--[[
Retorna:
{
    ped = entity,
    config = { ... },
    aiState = 'alert',
    currentBehavior = 'guard',
    alertLevel = 2.5,
    fearLevel = 0,
    memory = { [playerId] = { ... } },
    relationships = { ... },
    customData = { ... }
}
--]]
```

### **npc.getAll()**

Obtiene todos los NPCs activos.

```lua
local allNPCs = lib.npc.getAll()
-- Retorna: table con todos los NPCs indexados por ID
```

### **npc.getAllByBehavior(behaviorName)**

Obtiene todos los NPCs con un comportamiento específico.

```lua
local guards = lib.npc.getAllByBehavior('guard')
-- Retorna: table con NPCs que tienen el comportamiento especificado
```

### **npc.remove(npcId)**

Elimina un NPC del mundo.

```lua
lib.npc.remove(guardId)
-- Retorna: boolean (éxito)
```

---

## 🎭 Comportamientos

### **1. Patrol (Patrullaje)**

NPCs que patrullan entre puntos definidos.

```lua
local patrolConfig = {
    model = 's_m_y_cop_01',
    coords = vector3(100, 200, 25),
    behaviors = {'patrol'},

    patrolPoints = {
        vector3(100, 200, 25),
        vector3(120, 200, 25),
        vector3(120, 220, 25),
        vector3(100, 220, 25)
    },

    patrolWait = 5000,          -- Tiempo de espera en cada punto (ms)
    movementStyle = 'normal'    -- 'cautious', 'normal', 'urgent'
}
```

### **2. Guard (Guardia)**

NPCs que protegen un área específica.

```lua
local guardConfig = {
    model = 's_m_y_cop_01',
    coords = vector3(150, -1040, 29.3),
    behaviors = {'guard'},

    guardZone = {
        center = vector3(150, -1040, 29.3),
        radius = 30.0
    },

    alertNetwork = 'police_station_1',  -- Red de alerta
    warningTime = 3000,                 -- Tiempo antes de atacar
    canSpeak = true,                    -- Puede dar advertencias

    combat = {
        ability = 3,
        weapon = 'WEAPON_PISTOL'
    }
}
```

### **3. Civilian (Civil)**

NPCs que actúan como civiles normales.

```lua
local civilianConfig = {
    model = 'a_f_y_tourist_01',
    coords = vector3(200, 300, 25),
    behaviors = {'civilian'},

    -- Reacciones personalizadas
    greetings = {
        'gestures@m@standing@casual@gesture_hello'
    },

    fearThreshold = 2,          -- Nivel de miedo para huir
    interactionCooldown = 30000 -- Tiempo entre interacciones
}
```

### **4. Worker (Trabajador)**

NPCs que realizan tareas de trabajo.

```lua
local workerConfig = {
    model = 's_m_y_construct_01',
    coords = vector3(300, 400, 25),
    behaviors = {'worker'},

    workLocation = vector3(305, 405, 25),
    workTasks = {
        'WORLD_HUMAN_HAMMERING',
        'WORLD_HUMAN_WELDING',
        'WORLD_HUMAN_CLIPBOARD'
    },

    schedule = {
        [8] = 'worker',     -- 8 AM - Empezar trabajo
        [12] = 'civilian',  -- 12 PM - Descanso
        [13] = 'worker',    -- 1 PM - Volver al trabajo
        [17] = 'civilian'   -- 5 PM - Terminar trabajo
    }
}
```

### **5. Vendor (Vendedor)**

NPCs que actúan como vendedores/comerciantes.

```lua
local vendorConfig = {
    model = 'a_m_m_indian_01',
    coords = vector3(25, -1347, 29.5),
    behaviors = {'vendor'},

    shopArea = {
        center = vector3(25, -1347, 29.5),
        radius = 5.0
    },

    interactions = {
        label = 'Hablar con vendedor',
        icon = 'fa-solid fa-store',
        dialogs = {
            default = {
                { title = 'Comprar productos', description = 'Ver catálogo' },
                { title = 'Información', description = 'Preguntar sobre productos' }
            }
        }
    }
}
```

---

## ⚙️ Configuración Avanzada

### **Sistema de Combate**

```lua
combat = {
    ability = 3,            -- Habilidad de combate (0-3)
    range = 2,              -- Rango preferido (0-3)
    movement = 2,           -- Movilidad en combate (0-3)
    weapon = 'WEAPON_PISTOL',
    accuracy = 0.8,         -- Precisión (0.0-1.0)
    reactionTime = 500      -- Tiempo de reacción (ms)
}
```

### **Apariencia Personalizada**

```lua
appearance = {
    clothing = {
        [1] = { drawable = 0, texture = 0 },    -- Máscara
        [3] = { drawable = 1, texture = 0 },    -- Torso
        [4] = { drawable = 2, texture = 0 },    -- Piernas
        [6] = { drawable = 3, texture = 0 },    -- Zapatos
        [11] = { drawable = 4, texture = 0 }    -- Camisa
    },
    props = {
        [0] = { drawable = 1, texture = 0 },    -- Sombrero
        [1] = { drawable = 2, texture = 0 }     -- Gafas
    }
}
```

### **Sistema de Horarios**

```lua
schedule = {
    [6] = 'wake_up',        -- 6 AM
    [8] = 'work',           -- 8 AM
    [12] = 'lunch',         -- 12 PM
    [13] = 'work',          -- 1 PM
    [18] = 'go_home',       -- 6 PM
    [22] = 'sleep'          -- 10 PM
}
```

### **Sistema de Relaciones**

```lua
relationships = {
    police = 50,            -- Relación con policía (0-100)
    criminals = -30,        -- Relación con criminales
    civilians = 75,         -- Relación con civiles

    -- Reacciones específicas
    reactions = {
        police_approach = function(npcData, playerId)
            -- Reacción cuando se acerca policía
        end
    }
}
```

---

## 💡 Ejemplos Prácticos

### **Ejemplo 1: Guardia de Banco Inteligente**

```lua
local bankGuard = lib.npc.create({
    model = 's_m_y_cop_01',
    coords = vector3(150.0, -1040.0, 29.3),
    heading = 180.0,
    behaviors = {'guard', 'patrol'},

    -- Zona de protección
    guardZone = {
        center = vector3(150.0, -1040.0, 29.3),
        radius = 20.0
    },

    -- Puntos de patrullaje
    patrolPoints = {
        vector3(145.0, -1035.0, 29.3),
        vector3(155.0, -1035.0, 29.3),
        vector3(155.0, -1045.0, 29.3),
        vector3(145.0, -1045.0, 29.3)
    },

    -- Configuración de combate
    combat = {
        ability = 3,
        range = 2,
        movement = 2,
        weapon = 'WEAPON_PISTOL'
    },

    -- Horario de trabajo
    schedule = {
        [8] = 'patrol',     -- Patrullar de día
        [20] = 'guard',     -- Solo guardar de noche
        [6] = 'patrol'      -- Volver a patrullar
    },

    -- Red de alerta
    alertNetwork = 'bank_security',
    warningTime = 2000,
    canSpeak = true
})
```

### **Ejemplo 2: Civil con Rutina Compleja**

```lua
local citizen = lib.npc.create({
    model = 'a_f_y_tourist_01',
    coords = vector3(200.0, 300.0, 25.0),
    behaviors = {'civilian'},

    -- Configuración de miedo
    fearThreshold = 1,

    -- Horario detallado
    schedule = {
        [7] = 'morning_jog',
        [9] = 'work_commute',
        [10] = 'worker',
        [12] = 'lunch_break',
        [13] = 'worker',
        [17] = 'shopping',
        [19] = 'go_home',
        [22] = 'sleep'
    },

    -- Interacciones amigables
    interactions = {
        label = 'Hablar',
        icon = 'fa-solid fa-comments',
        dialogs = {
            default = {
                { title = 'Hola', description = 'Saludar amigablemente' },
                { title = 'Direcciones', description = 'Pedir direcciones' }
            },
            morning = {
                { title = 'Buenos días', description = 'Saludo matutino' }
            },
            night = {
                { title = 'Es tarde...', description = 'Comentario nocturno' }
            }
        }
    }
})
```

### **Ejemplo 3: Trabajador de Construcción**

```lua
local constructionWorker = lib.npc.create({
    model = 's_m_y_construct_01',
    coords = vector3(300.0, 400.0, 25.0),
    behaviors = {'worker'},

    -- Ubicación de trabajo
    workLocation = vector3(305.0, 405.0, 25.0),

    -- Tareas rotativas
    workTasks = {
        'WORLD_HUMAN_HAMMERING',
        'WORLD_HUMAN_WELDING',
        'WORLD_HUMAN_CLIPBOARD',
        'WORLD_HUMAN_CONST_DRILL'
    },

    -- Equipo de protección
    appearance = {
        clothing = {
            [0] = { drawable = 0, texture = 0 },    -- Cabeza
            [1] = { drawable = 0, texture = 0 },    -- Barba
            [2] = { drawable = 5, texture = 0 },    -- Cabello
            [3] = { drawable = 12, texture = 0 },   -- Torso
            [4] = { drawable = 9, texture = 0 },    -- Piernas
            [6] = { drawable = 24, texture = 0 },   -- Zapatos
            [11] = { drawable = 59, texture = 0 }   -- Camisa
        },
        props = {
            [0] = { drawable = 1, texture = 0 }     -- Casco
        }
    },

    -- Horario de trabajo
    schedule = {
        [6] = 'prepare_work',
        [7] = 'worker',
        [12] = 'lunch_break',
        [13] = 'worker',
        [17] = 'end_work',
        [18] = 'go_home'
    }
})
```

### **Ejemplo 4: Comportamiento Personalizado**

```lua
-- Registrar comportamiento de DJ
lib.npc.registerBehavior('dj', function(npcData)
    local ped = npcData.ped
    local djBooth = npcData.config.djBooth

    if djBooth then
        local coords = GetEntityCoords(ped)
        local distance = #(coords - djBooth)

        if distance > 2.0 then
            -- Ir al booth
            TaskGoToCoordAnyMeans(ped, djBooth.x, djBooth.y, djBooth.z, 1.0, 0, 0, 786603, 0xbf800000)
        else
            -- Actuar como DJ
            if not IsPedActiveInScenario(ped) then
                TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MUSICIAN', 0, true)
            end

            -- Cambiar música periódicamente
            if math.random() < 0.1 then
                -- Lógica para cambiar música
                TriggerEvent('club:changeSong')
            end
        end
    end
end)

-- Crear DJ
local clubDJ = lib.npc.create({
    model = 'a_m_y_hipster_01',
    coords = vector3(120.0, -1280.0, 29.0),
    behaviors = {'dj'},

    djBooth = vector3(125.0, -1285.0, 29.0),

    schedule = {
        [20] = 'dj',        -- Empezar a las 8 PM
        [4] = 'civilian'    -- Terminar a las 4 AM
    }
})
```

---

## 🧠 Sistema de IA

### **Detección de Amenazas**

El sistema evalúa automáticamente las amenazas basándose en:

- **Armas equipadas** (+3 puntos de amenaza)
- **Movimiento hacia el NPC** (+1 punto)
- **Velocidad del vehículo** (+2 puntos)
- **Nivel de búsqueda** (+N puntos)

### **Sistema de Memoria**

Los NPCs recuerdan:

- **Jugadores que han visto**
- **Últimas interacciones**
- **Relaciones desarrolladas**
- **Comportamientos observados**

### **Niveles de Alerta**

- **0-1**: Normal, sin amenazas
- **1-2**: Cautela, observando
- **2-3**: Alerta, preparado para actuar
- **3-4**: Combate defensivo
- **4-5**: Combate agresivo

---

## 📖 Best Practices

### **1. Rendimiento**

```lua
-- ✅ BIEN: Limitar número de NPCs activos
local maxNPCs = 50

-- ✅ BIEN: Usar grupos de comportamiento
local securityTeam = {
    lib.npc.create(guardConfig1),
    lib.npc.create(guardConfig2),
    lib.npc.create(guardConfig3)
}

-- ❌ MAL: Demasiados NPCs individuales
for i = 1, 200 do
    lib.npc.create(randomConfig)
end
```

### **2. Configuración Eficiente**

```lua
-- ✅ BIEN: Reutilizar configuraciones base
local baseGuardConfig = {
    model = 's_m_y_cop_01',
    behaviors = {'guard'},
    combat = { ability = 3, weapon = 'WEAPON_PISTOL' }
}

local bankGuard = lib.table.deepclone(baseGuardConfig)
bankGuard.coords = vector3(150, -1040, 29.3)
bankGuard.guardZone = { center = vector3(150, -1040, 29.3), radius = 20 }
```

### **3. Gestión de Memoria**

```lua
-- ✅ BIEN: Limpiar NPCs cuando no se necesiten
RegisterNetEvent('player:leftArea', function(areaId)
    local npcsInArea = lib.npc.getAllByArea(areaId)
    for npcId, _ in pairs(npcsInArea) do
        lib.npc.remove(npcId)
    end
end)
```

### **4. Debugging**

```lua
-- Comando para inspeccionar NPCs
RegisterCommand('npc_debug', function()
    local allNPCs = lib.npc.getAll()
    for npcId, npcData in pairs(allNPCs) do
        print(string.format('NPC %d: State=%s, Behavior=%s, Alert=%d',
            npcId, npcData.aiState, npcData.currentBehavior, npcData.alertLevel))
    end
end)
```

### **5. Integración con Eventos**

```lua
-- Reaccionar a eventos del servidor
RegisterNetEvent('bank:robbery:started', function(bankCoords)
    local nearbyGuards = lib.npc.getAllByBehavior('guard')
    for npcId, npcData in pairs(nearbyGuards) do
        local distance = #(GetEntityCoords(npcData.ped) - bankCoords)
        if distance < 100.0 then
            npcData.alertLevel = 5
            lib.npc.changeBehavior(npcId, 'emergency_response')
        end
    end
end)
```

---

Este sistema de NPCs proporciona una base sólida para crear mundos más inmersivos y dinámicos en FiveM, con NPCs que se comportan de manera inteligente y realista.

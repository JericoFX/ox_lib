# 📹 Sistema de Cámaras Completo - ox_lib Extended

El Sistema de Cámaras Completo proporciona control total sobre las cámaras en FiveM, incluyendo freecam, cámaras cinemáticas, transiciones suaves y sistemas de scripted cameras avanzados.

## 📋 Características Principales

- 🎥 **Cámaras scriptadas** con control total
- 🆓 **FreeCam** con controles WASD y mouse
- 🎬 **Transiciones suaves** entre cámaras
- 🎯 **Apuntado automático** a coordenadas y entidades
- 🔄 **Control de FOV** dinámico con transiciones
- 📐 **Movimiento cinemático** con easing
- 🎪 **Múltiples instancias** de cámara simultáneas

---

## 🚀 Uso Básico

### Instanciación

```lua
-- Usar la instancia global (recomendado)
local camera = lib.camera

-- O crear una nueva instancia
local customCamera = lib.class('Camera'):new()
```

### Crear y Activar Cámaras

```lua
-- Crear cámara básica
local coords = vector3(100.0, 200.0, 50.0)
local rotation = vector3(0, 0, 90.0)
local cameraId = camera:create(coords, rotation)

-- Activar cámara instantáneamente
camera:activate(cameraId)

-- Activar con transición suave
camera:activate(cameraId, {
    duration = 2000,
    callback = function()
        print("Transición completada")
    end
})
```

---

## 🎬 Cámaras Cinemáticas

### Crear Secuencias Cinemáticas

```lua
local CinematicSequence = {}

function CinematicSequence:create()
    -- Crear múltiples cámaras para la secuencia
    local cam1 = lib.camera:create(vector3(100, 200, 30), vector3(-10, 0, 45), {
        fov = 40.0
    })

    local cam2 = lib.camera:create(vector3(150, 250, 40), vector3(-15, 0, 135), {
        fov = 60.0
    })

    local cam3 = lib.camera:create(vector3(80, 180, 25), vector3(5, 0, 225), {
        fov = 50.0
    })

    return {cam1, cam2, cam3}
end

function CinematicSequence:play(cameras)
    -- Activar primera cámara
    lib.camera:activate(cameras[1], {duration = 1000})

    -- Transición a segunda cámara después de 5 segundos
    SetTimeout(5000, function()
        lib.camera:activate(cameras[2], {
            duration = 3000,
            easing = lib.enums.camera.EASING_TYPES.EASE_IN_OUT
        })
    end)

    -- Transición a tercera cámara después de 10 segundos
    SetTimeout(10000, function()
        lib.camera:activate(cameras[3], {
            duration = 2000,
            easing = lib.enums.camera.EASING_TYPES.EASE_OUT
        })
    end)

    -- Regresar a gameplay después de 15 segundos
    SetTimeout(15000, function()
        lib.camera:deactivate({
            duration = 2000,
            callback = function()
                print("Secuencia cinemática terminada")
            end
        })
    end)
end

-- Uso
local cameras = CinematicSequence:create()
CinematicSequence:play(cameras)
```

### Control de Movimiento Dinámico

```lua
-- Crear cámara
local cameraId = camera:create(vector3(100, 200, 30))
camera:activate(cameraId)

-- Mover cámara con transición suave
camera:moveTo(cameraId, vector3(150, 250, 45), {
    duration = 3000,
    easing = lib.enums.camera.EASING_TYPES.EASE_IN_OUT,
    callback = function()
        print("Movimiento completado")
    end
})

-- Cambiar FOV gradualmente
camera:setFOV(cameraId, 80.0, {
    duration = 2000
})

-- Apuntar a coordenadas específicas
local targetCoords = vector3(200, 300, 20)
camera:pointAt(cameraId, targetCoords)

-- Apuntar a entidad
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
camera:pointAt(cameraId, vehicle)
```

---

## 🆓 Sistema FreeCam

### FreeCam Básico

```lua
-- Activar freecam
camera:enableFreeCam()

-- Activar freecam desde posición específica
local startCoords = vector3(100, 200, 50)
camera:enableFreeCam(startCoords, 2.0) -- Velocidad x2

-- Desactivar freecam
camera:disableFreeCam()
```

### FreeCam Avanzado con Restricciones

```lua
local AdvancedFreeCam = {}

function AdvancedFreeCam:enable(bounds, speed)
    bounds = bounds or {
        min = vector3(-1000, -1000, 0),
        max = vector3(1000, 1000, 200)
    }

    speed = speed or 1.0

    -- Activar freecam básico
    lib.camera:enableFreeCam(nil, speed)

    -- Thread para verificar límites
    CreateThread(function()
        while lib.camera.private and lib.camera.private.freeCamActive do
            local camCoords = GetCamCoord(lib.camera.private.freeCamHandle)

            -- Verificar límites
            local newCoords = vector3(
                math.max(bounds.min.x, math.min(bounds.max.x, camCoords.x)),
                math.max(bounds.min.y, math.min(bounds.max.y, camCoords.y)),
                math.max(bounds.min.z, math.min(bounds.max.z, camCoords.z))
            )

            -- Aplicar límites si es necesario
            if #(camCoords - newCoords) > 0.1 then
                SetCamCoord(lib.camera.private.freeCamHandle, newCoords.x, newCoords.y, newCoords.z)
            end

            Wait(50)
        end
    end)
end

-- Uso
AdvancedFreeCam:enable({
    min = vector3(-500, -500, 10),
    max = vector3(500, 500, 100)
}, 1.5)
```

---

## 🎮 Ejemplos Prácticos

### Sistema de Cámaras de Seguridad

```lua
local SecurityCameras = {}
SecurityCameras.cameras = {}
SecurityCameras.currentCam = nil

function SecurityCameras:addCamera(id, coords, rotation, label)
    self.cameras[id] = {
        id = id,
        coords = coords,
        rotation = rotation,
        label = label,
        cameraId = nil
    }
end

function SecurityCameras:viewCamera(id)
    local camData = self.cameras[id]
    if not camData then return false end

    -- Crear cámara si no existe
    if not camData.cameraId then
        camData.cameraId = lib.camera:create(camData.coords, camData.rotation, {
            fov = 60.0
        })
    end

    -- Activar cámara
    lib.camera:activate(camData.cameraId, {duration = 1000})

    self.currentCam = id

    -- Mostrar HUD de cámara
    self:showCameraHUD(camData.label)

    return true
end

function SecurityCameras:nextCamera()
    local camIds = {}
    for id, _ in pairs(self.cameras) do
        table.insert(camIds, id)
    end

    table.sort(camIds)

    local currentIndex = 1
    for i, id in ipairs(camIds) do
        if id == self.currentCam then
            currentIndex = i
            break
        end
    end

    local nextIndex = currentIndex < #camIds and currentIndex + 1 or 1
    self:viewCamera(camIds[nextIndex])
end

function SecurityCameras:exitCameras()
    lib.camera:deactivate({duration = 500})
    self.currentCam = nil
    self:hideCameraHUD()
end

function SecurityCameras:showCameraHUD(label)
    -- Implementar HUD de cámara
    SendNUIMessage({
        type = "showCameraHUD",
        label = label
    })
end

-- Configurar cámaras
SecurityCameras:addCamera(1, vector3(100, 200, 30), vector3(-15, 0, 45), "Entrada Principal")
SecurityCameras:addCamera(2, vector3(200, 300, 25), vector3(-10, 0, 135), "Estacionamiento")
SecurityCameras:addCamera(3, vector3(150, 100, 35), vector3(-20, 0, 225), "Área Trasera")

-- Controles
RegisterKeyMapping('security_cam_next', 'Siguiente Cámara', 'keyboard', 'RIGHT')
RegisterKeyMapping('security_cam_exit', 'Salir Cámaras', 'keyboard', 'ESC')

RegisterCommand('security_cam_next', function()
    if SecurityCameras.currentCam then
        SecurityCameras:nextCamera()
    end
end)

RegisterCommand('security_cam_exit', function()
    if SecurityCameras.currentCam then
        SecurityCameras:exitCameras()
    end
end)
```

### Sistema de Cámara para Vehículos

```lua
local VehicleCamera = {}
VehicleCamera.cameras = {}

function VehicleCamera:createVehicleCameras(vehicle)
    if self.cameras[vehicle] then return end

    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleHeading = GetEntityHeading(vehicle)

    -- Cámara frontal
    local frontOffset = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 5.0, 2.0)
    local frontCam = lib.camera:create(frontOffset, vector3(-10, 0, vehicleHeading + 180), {
        fov = 70.0
    })

    -- Cámara trasera
    local rearOffset = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -8.0, 3.0)
    local rearCam = lib.camera:create(rearOffset, vector3(-15, 0, vehicleHeading), {
        fov = 80.0
    })

    -- Cámara lateral
    local sideOffset = GetOffsetFromEntityInWorldCoords(vehicle, 10.0, 0.0, 2.0)
    local sideCam = lib.camera:create(sideOffset, vector3(-5, 0, vehicleHeading + 90), {
        fov = 60.0
    })

    self.cameras[vehicle] = {
        front = frontCam,
        rear = rearCam,
        side = sideCam,
        current = nil
    }
end

function VehicleCamera:activateView(vehicle, view)
    if not self.cameras[vehicle] then
        self:createVehicleCameras(vehicle)
    end

    local cameraId = self.cameras[vehicle][view]
    if not cameraId then return false end

    lib.camera:activate(cameraId, {duration = 800})
    self.cameras[vehicle].current = view

    return true
end

function VehicleCamera:followVehicle(vehicle)
    if not self.cameras[vehicle] or not self.cameras[vehicle].current then return end

    CreateThread(function()
        while self.cameras[vehicle] and self.cameras[vehicle].current do
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehicleHeading = GetEntityHeading(vehicle)
            local currentView = self.cameras[vehicle].current
            local cameraId = self.cameras[vehicle][currentView]

            -- Calcular nueva posición basada en el tipo de vista
            local newCoords, newRotation

            if currentView == 'front' then
                newCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 5.0, 2.0)
                newRotation = vector3(-10, 0, vehicleHeading + 180)
            elseif currentView == 'rear' then
                newCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -8.0, 3.0)
                newRotation = vector3(-15, 0, vehicleHeading)
            elseif currentView == 'side' then
                newCoords = GetOffsetFromEntityInWorldCoords(vehicle, 10.0, 0.0, 2.0)
                newRotation = vector3(-5, 0, vehicleHeading + 90)
            end

            -- Mover cámara suavemente
            lib.camera:moveTo(cameraId, newCoords, {duration = 100})

            Wait(50)
        end
    end)
end

-- Uso
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
VehicleCamera:activateView(vehicle, 'front')
VehicleCamera:followVehicle(vehicle)

-- Cambiar vista después de 5 segundos
SetTimeout(5000, function()
    VehicleCamera:activateView(vehicle, 'rear')
end)
```

### Sistema de Presentación de Propiedades

```lua
local PropertyShowcase = {}

function PropertyShowcase:createTour(propertyData)
    local tour = {
        cameras = {},
        currentIndex = 1,
        isPlaying = false
    }

    -- Crear cámaras para cada punto de interés
    for i, point in ipairs(propertyData.viewpoints) do
        local cameraId = lib.camera:create(point.coords, point.rotation, {
            fov = point.fov or 50.0
        })

        table.insert(tour.cameras, {
            id = cameraId,
            duration = point.duration or 5000,
            description = point.description
        })
    end

    return tour
end

function PropertyShowcase:playTour(tour)
    if tour.isPlaying then return end

    tour.isPlaying = true
    tour.currentIndex = 1

    local function nextCamera()
        if tour.currentIndex > #tour.cameras then
            -- Tour terminado
            lib.camera:deactivate({duration = 2000})
            tour.isPlaying = false
            print("Tour de propiedad completado")
            return
        end

        local currentCam = tour.cameras[tour.currentIndex]

        -- Mostrar descripción
        if currentCam.description then
            lib.notify({
                title = 'Tour de Propiedad',
                description = currentCam.description,
                duration = currentCam.duration
            })
        end

        -- Activar cámara
        lib.camera:activate(currentCam.id, {
            duration = 1500,
            callback = function()
                -- Programar siguiente cámara
                SetTimeout(currentCam.duration, function()
                    tour.currentIndex = tour.currentIndex + 1
                    nextCamera()
                end)
            end
        })
    end

    nextCamera()
end

-- Configuración de ejemplo
local propertyData = {
    viewpoints = {
        {
            coords = vector3(100, 200, 30),
            rotation = vector3(-10, 0, 45),
            fov = 60.0,
            duration = 4000,
            description = "Vista frontal de la propiedad"
        },
        {
            coords = vector3(150, 180, 25),
            rotation = vector3(0, 0, 135),
            fov = 70.0,
            duration = 5000,
            description = "Jardín y área exterior"
        },
        {
            coords = vector3(120, 220, 35),
            rotation = vector3(-20, 0, 225),
            fov = 55.0,
            duration = 4500,
            description = "Vista aérea del conjunto"
        }
    }
}

-- Iniciar tour
local tour = PropertyShowcase:createTour(propertyData)
PropertyShowcase:playTour(tour)
```

---

## 🔧 Utilidades

### Gestión de Cámaras

```lua
-- Verificar si hay transición activa
if camera:isTransitioning() then
    print("Cámara en transición")
end

-- Obtener cámara actual
local currentCam = camera:getCurrentCamera()
if currentCam then
    print("Cámara activa:", currentCam.id)
end

-- Destruir cámara específica
camera:destroy(cameraId)

-- Limpiar todas las cámaras de una instancia
for cameraId, _ in pairs(camera.private.activeCameras) do
    camera:destroy(cameraId)
end
```

### Control Avanzado de FOV

```lua
-- Sistema de zoom dinámico
local function createZoomSystem(cameraId)
    local baseSpeed = 1.0
    local zoomLevel = 1.0

    CreateThread(function()
        while lib.camera:getCurrentCamera() and lib.camera:getCurrentCamera().id == cameraId do
            -- Control con scroll del mouse
            if IsControlJustPressed(0, 241) then -- Mouse scroll up
                zoomLevel = math.max(0.5, zoomLevel - 0.1)
            elseif IsControlJustPressed(0, 242) then -- Mouse scroll down
                zoomLevel = math.min(2.0, zoomLevel + 0.1)
            end

            -- Aplicar zoom
            local newFOV = 50.0 / zoomLevel
            lib.camera:setFOV(cameraId, newFOV, {duration = 200})

            Wait(0)
        end
    end)
end

-- Uso
local cameraId = camera:create(vector3(100, 200, 30))
camera:activate(cameraId)
createZoomSystem(cameraId)
```

---

## 📚 Enums Disponibles

### Tipos de Cámara

```lua
lib.enums.camera.CAMERA_TYPES.DEFAULT_SCRIPTED
lib.enums.camera.CAMERA_TYPES.DEFAULT_ANIMATED
lib.enums.camera.CAMERA_TYPES.SCRIPTED_FLY
```

### Tipos de Easing

```lua
lib.enums.camera.EASING_TYPES.LINEAR
lib.enums.camera.EASING_TYPES.EASE_IN
lib.enums.camera.EASING_TYPES.EASE_OUT
lib.enums.camera.EASING_TYPES.EASE_IN_OUT
lib.enums.camera.EASING_TYPES.BOUNCE_IN
lib.enums.camera.EASING_TYPES.BOUNCE_OUT
```

### Presets de FOV

```lua
lib.enums.camera.FOV_PRESETS.VERY_NARROW -- 15.0
lib.enums.camera.FOV_PRESETS.NARROW      -- 30.0
lib.enums.camera.FOV_PRESETS.NORMAL      -- 50.0
lib.enums.camera.FOV_PRESETS.WIDE        -- 70.0
lib.enums.camera.FOV_PRESETS.VERY_WIDE   -- 90.0
```

---

## ⚠️ Consideraciones

### Performance

- Limite el número de cámaras activas simultáneamente
- Use transiciones con duración razonable (>200ms)
- Destruya cámaras que no vaya a usar

### Limitaciones

- FreeCam puede interferir con otros sistemas de input
- Las transiciones muy rápidas pueden causar problemas visuales
- Algunos efectos pueden no funcionar en todas las versiones de FiveM

---

## 🔗 APIs Relacionadas

- [**Sistema de Audio**](./AUDIO_API.md) - Para audio cinemático
- [**Sistema de NPCs**](./NPC_SYSTEM.md) - Para cámaras de NPCs
- [**Sistema de StateBags**](./STATEBAGS_API.md) - Para sincronizar estados de cámara

---

Esta documentación cubre el uso básico y avanzado del Sistema de Cámaras. Para casos de uso específicos, consulta los ejemplos prácticos o experimenta con las diferentes opciones disponibles.

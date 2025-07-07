-- examples/phone_usage.lua
-- Ejemplos de uso de las nuevas funciones de teléfono en ox_lib

-- Básicamente, usar lib.phone para acceder a todas las funciones
local phone = lib.phone

-- ===============================================
-- FUNCIONES BÁSICAS DE TELÉFONO
-- ===============================================

-- Enviar mensaje
phone.sendMessage("555-1234", "Hola, ¿cómo estás?")

-- Agregar contacto
phone.addContact("Juan Pérez", "555-1234", "https://example.com/avatar.jpg")

-- Remover contacto
phone.removeContact("555-1234")

-- Mostrar notificación
phone.notification("Nuevo mensaje", "Tienes un mensaje de Juan", "fa fa-message", "#25D366", 5000)

-- Abrir teléfono
phone.open()

-- Cerrar teléfono
phone.close()

-- Verificar si está abierto
if phone.isOpen() then
    print("El teléfono está abierto")
end

-- ===============================================
-- FUNCIONES DE LLAMADAS
-- ===============================================

-- Hacer una llamada
phone.makeCall("555-1234")

-- Responder llamada entrante
phone.answerCall()

-- Declinar llamada
phone.declineCall()

-- Terminar llamada
phone.endCall()

-- Verificar si está en llamada
if phone.isInCall() then
    print("Actualmente en llamada")
end

-- ===============================================
-- FUNCIONES DE CÁMARA Y GALERÍA
-- ===============================================

-- Tomar una foto
phone.takePhoto()

-- Abrir galería
phone.openGallery()

-- Eliminar foto (si el sistema lo soporta)
phone.deletePhoto("photo_id_123")

-- Compartir foto (si el sistema lo soporta)
phone.sharePhoto("photo_id_123", { "555-1234", "555-5678" })

-- ===============================================
-- FUNCIONES DE APLICACIONES
-- ===============================================

-- Abrir aplicación específica
phone.openApp("banking")
phone.openApp("gallery")
phone.openApp("contacts")

-- Cerrar aplicación
phone.closeApp("banking")

-- Instalar app (si el sistema lo soporta)
phone.installApp("instagram")

-- Desinstalar app (si el sistema lo soporta)
phone.uninstallApp("instagram")

-- Obtener apps instaladas
local installedApps = phone.getInstalledApps()
for _, app in pairs(installedApps) do
    print("App instalada: " .. app.name)
end

-- ===============================================
-- FUNCIONES DE INFORMACIÓN
-- ===============================================

-- Obtener número de teléfono del jugador
local myNumber = phone.getPhoneNumber()
if myNumber then
    print("Mi número es: " .. myNumber)
end

-- Obtener lista de contactos
local contacts = phone.getContacts()
for _, contact in pairs(contacts) do
    print("Contacto: " .. contact.name .. " - " .. contact.number)
end

-- Actualizar contacto
phone.updateContact("contact_id_123", {
    name = "Juan Carlos Pérez",
    avatar = "https://example.com/new_avatar.jpg"
})

-- ===============================================
-- EJEMPLO DE USO COMPLETO
-- ===============================================

-- Función para enviar mensaje con verificación
local function sendMessageSafe(number, message)
    if phone.isOpen() then
        phone.sendMessage(number, message)
        phone.notification("Mensaje enviado", "Tu mensaje fue enviado exitosamente", "fa fa-check", "#4CAF50")
    else
        phone.open()
        Citizen.Wait(1000) -- Esperar que abra
        phone.sendMessage(number, message)
        phone.close()
    end
end

-- Función para realizar llamada con manejo de errores
local function makeCallSafe(number)
    if not phone.isInCall() then
        phone.makeCall(number)
        phone.notification("Llamando...", "Llamando a " .. number, "fa fa-phone", "#2196F3")
    else
        phone.notification("Error", "Ya estás en una llamada", "fa fa-warning", "#FF5722")
    end
end

-- Usar las funciones
sendMessageSafe("555-1234", "Hola desde ox_lib!")
makeCallSafe("555-5678")
